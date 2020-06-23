{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: yonetim.pas
  Dosya ��levi: sistem ana y�netim / kontrol k�sm�

  G�ncelleme Tarihi: 21/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit yonetim;

interface

uses paylasim, gn_pencere, gn_etiket, zamanlayici, dns, gn_panel, gorselnesne,
  gn_gucdugmesi, gn_resim, gn_karmaliste;

type
  // ger�ek moddan gelen veri yap�s�
  PGMBilgi = ^TGMBilgi;
  TGMBilgi = packed record
    VideoBellekUzunlugu: TSayi2;
    VideoEkranMod: TSayi2;
    VideoYatayCozunurluk: TSayi2;
    VideoDikeyCozunurluk: TSayi2;
    VideoBellekAdresi: TSayi4;
    VideoPixelBasinaBitSayisi: TSayi1;
    VideoSatirdakiByteSayisi: TSayi2;
    CekirdekBaslangicAdresi: TSayi4;
    CekirdekKodUzunluk: TSayi4;
  end;

type
  TTestSinif = class(TObject)
  public
    FDeger1: TSayi4;
    constructor Create;
    procedure Artir;
    procedure Eksilt;
  end;

type
  TGorevYonetici = object
  private
    dugGorevler: array[0..99] of PGucDugmesi;
  public
    TestSinif: TTestSinif;
    Degerler: array[1..8] of TSayi4;
    BulunanCiftSayisi, TiklamaSayisi,
    SecilenEtiket, ToplamTiklamaSayisi: TSayi4;
    procedure MasaustuBasla;
    procedure ProgramBasla;
    procedure NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

var
  SDPencere: PPencere;
  SDZamanlayici, SDZamanlayici2: PZamanlayici;

  NTPencere: PPencere;
  GNEtiket: PEtiket;
  KarmaListe: PKarmaListe;
  Resim: PResim;
  _DNS: PDNS = nil;
  DugmeSayisi: TSayi4;
  TestAlani: TGorevYonetici;

procedure Yukle;
procedure SistemAnaKontrol;
procedure SistemDenetcisiOlustur;
procedure SistemCalismasiniDenetle;
procedure EkranGuncelle;
procedure SistemDegerleriBasla;
procedure SistemDegerleriOlayIsle;

implementation

uses gdt, gorev, src_klavye, genel, ag, dhcp, sistemmesaj, src_vesa20,
  gn_masaustu, donusum, gn_islevler;

{==============================================================================
  sistem ilk y�kleme i�levlerini ger�ekle�tirir
 ==============================================================================}
procedure Yukle;
var
  Gorev: PGorev;
  GMBilgi: PGMBilgi;
  Olay: POlay;
begin

  GMBilgi := PGMBilgi(BILDEN_VERIADRESI);

  // video bilgilerini al
  GEkranKartSurucusu.KartBilgisi.BellekUzunlugu := GMBilgi^.VideoBellekUzunlugu;
  GEkranKartSurucusu.KartBilgisi.EkranMod := GMBilgi^.VideoEkranMod;
  GEkranKartSurucusu.KartBilgisi.YatayCozunurluk := GMBilgi^.VideoYatayCozunurluk;
  GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk := GMBilgi^.VideoDikeyCozunurluk;
  GEkranKartSurucusu.KartBilgisi.BellekAdresi := GMBilgi^.VideoBellekAdresi; //VIDEO_MEM_ADDR;
  GEkranKartSurucusu.KartBilgisi.PixelBasinaBitSayisi := GMBilgi^.VideoPixelBasinaBitSayisi;
  GEkranKartSurucusu.KartBilgisi.NoktaBasinaByteSayisi := (GMBilgi^.VideoPixelBasinaBitSayisi div 8);
  GEkranKartSurucusu.KartBilgisi.SatirdakiByteSayisi := GMBilgi^.VideoSatirdakiByteSayisi;

  // �ekirdek bilgilerini al
  CekirdekBaslangicAdresi := GMBilgi^.CekirdekBaslangicAdresi;
  CekirdekUzunlugu := GMBilgi^.CekirdekKodUzunluk;

  // zamanlay�c� sayac�n� s�f�rla
  ZamanlayiciSayaci := 0;

  // sistem sayac�n� s�f�rla
  SistemSayaci := 0;

  // �nde�er fare g�stergesini belirle
  GecerliFareGostegeTipi := fitBekle;

  // �ekirde�in kullanaca�� TSS'nin i�eri�ini s�f�rla
  FillByte(GorevTSSListesi[1]^, 104, $00);

  // TSS i�eri�ini doldur
  //GorevTSSListesi[1].CR3 := GERCEKBELLEK_DIZINADRESI;
  GorevTSSListesi[1]^.EIP := TSayi4(@SistemAnaKontrol);
  GorevTSSListesi[1]^.EFLAGS := $202;
  GorevTSSListesi[1]^.ESP := GOREV0_ESP;
  GorevTSSListesi[1]^.CS := SECICI_SISTEM_KOD * 8;
  GorevTSSListesi[1]^.DS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1]^.ES := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1]^.SS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1]^.FS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1]^.GS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1]^.SS0 := SECICI_SISTEM_VERI * 8;

  // not: sistem i�in CS ve DS se�icileri bilden program� taraf�ndan
  // olu�turuldu. tekrar olu�turmaya gerek yok

  // sistem i�in g�rev se�icisi (TSS)
  // Eri�im  : 1 = mevcut, 00 = DPL0, 010 = 32 bit kullan�labilir TSS, 0 = me�gul biti (me�gul de�il), 1
  // Esneklik: 1 = gran = 1Byte ��z�n�rl�k, 00, 1 = bana tahsis edildi, 0000 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_SISTEM_TSS, TSayi4(GorevTSSListesi[1]), 104,
    %10001001, %00010000);

  // sistem g�rev de�erlerini belirle
  GorevListesi[1]^.GorevSayaci := 0;
  GorevListesi[1]^.BellekBaslangicAdresi := CekirdekBaslangicAdresi;
  GorevListesi[1]^.BellekUzunlugu := CekirdekUzunlugu;
  GorevListesi[1]^.OlaySayisi := 0;
  GorevListesi[1]^.OlayBellekAdresi := nil;
  GorevListesi[1]^.FAnaPencere := nil;

  GorevListesi[1]^.FProgramAdi := 'cekirdek.bin';

  // sistem g�revini �al���yor olarak i�aretle
  Gorev := GorevListesi[1];
  Gorev^.OlaySayisi := 0;

  Olay := POlay(GGercekBellek.Ayir(4096));
  if not(Olay = nil) then
  begin

    Gorev^.FOlayBellekAdresi := Olay;
  end else Gorev^.FOlayBellekAdresi := nil;

  Gorev^.DurumDegistir(1, gdCalisiyor);

  // �al��an ve olu�turulan g�rev de�erlerini belirle
  CalisanGorevSayisi := 1;
  CalisanGorev := CalisanGorevSayisi;

  // ilk TSS'yi y�kle
  // not : tss'nin y�kleme i�levi g�rev ge�i�ini ger�ekle�tirmez. sadece
  // TSS'yi me�gul olarak ayarlar.
  asm
    mov   ax, SECICI_SISTEM_TSS * 8;
    ltr   ax
  end;

  // ana �ekirde�in i�leyi�ini takip eden sistem denet�isini olu�tur
  SistemDenetcisiOlustur;
end;

{==============================================================================
  sistem ana kontrol k�sm�
 ==============================================================================}
procedure SistemAnaKontrol;
var
  Gorev: PGorev;
  Tus: Char;
  TusDurum: TTusDurum;
begin

{  if(CalisanGorevSayisi = 1) then
  repeat

    Gorev^.Calistir(AcilisSurucuAygiti + ':\' + OnDegerMasaustuProgram);
    ElleGorevDegistir;
  until CalisanGorevSayisi > 1;
}
  KONTROLTusDurumu := tdYok;
  ALTTusDurumu := tdYok;
  DEGISIMTusDurumu := tdYok;

  // masa�st� aktif olana kadar bekle
  while GAktifMasaustu = nil do;

  // sistem de�er g�r�nt�leyicisini ba�lat
  SistemDegerleriBasla;

  TestAlani.ProgramBasla;

  // sistem i�in DHCP sunucusundan IP adresi al
  if(AgYuklendi) then DHCPSunucuKesfet;

  repeat

    // sistem sayac�n� art�r
    Inc(SistemSayaci);

    // klavyeden bas�lan tu�u al
    TusDurum := KlavyedenTusAl(Tus);
    if(TusDurum = tdBasildi) and (Tus <> #0) then
    begin

      if(KONTROLTusDurumu = tdBasildi) then
      begin

        // DHCP sunucusundan IP adresi al
        // bilgi: agbilgi.c program�n�n se�ene�ine ba�l�d�r
        if(Tus = '2') then
        begin

          DHCPSunucuKesfet;
        end
        // test ama�l�
        else if(Tus = '3') then
        begin

          //Gorev^.Calistir('disk1:\dnssorgu.c');
          {i := FindFirst('disk1:\kaynak\*.*', 0, AramaKaydi);
          while i = 0 do
          begin

            SISTEM_MESAJ('Dosya: ' + AramaKaydi.DosyaAdi, []);
            i := FindNext(AramaKaydi);
          end;
          FindClose(AramaKaydi);}
          //Gorev^.Calistir('disk1:\6.bmp');
          Gorev^.Calistir('disk1:\tasarim.c');
        end
        else if(Tus = 'd') then
        begin

          Gorev^.Calistir('disk1:\dsyyntcs.c');
        end
        else if(Tus = 'g') then
        begin

          Gorev^.Calistir('disk1:\grvyntcs.c');
        end
        else if(Tus = 'm') then
        begin

          Gorev^.Calistir('disk1:\smsjgor.c');
        end
      end
      else
      begin

        // klavye olaylar�n� i�le
        GOlayYonetim.KlavyeOlaylariniIsle(Tus);
      end;
    end;

    if(AgYuklendi) then AgKartiVeriAlmaIslevi;

    // fare olaylar�n� i�le
    GOlayYonetim.FareOlaylariniIsle;

//    GEkranKartSurucusu.EkranBelleginiGuncelle;

    SistemDegerleriOlayIsle;

  until (1 = 2);
end;

procedure SistemDenetcisiOlustur;
var
  Gorev: PGorev;
begin

  // kod se�icisi (CS)
  // Eri�im  : 1 = mevcut, 00 = DPL0, 11 = kod yazma�, 0 = dallan�lamaz, 1 = okunabilir, 0 = eri�ilmedi
  // Esneklik: 1 = gran = 4K ��z�n�rl�k, 1 = 32 bit, 0, 1 = bana tahsis edildi, 1111 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_KOD, 0, $FFFFFFFF, %10011010, %11011111);
  // veri se�icisi (DS)
  // Eri�im  : 1 = mevcut, 00 = DPL0, 10 = veri yazma�, 0 = artarak b�y�yen, 1 = yaz�labilir, 0 = eri�ilmedi
  // Esneklik: 1 = gran = 4K ��z�n�rl�k, 1 = 32 bit, 0, 1 = bana tahsis edildi, 1111 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_VERI, 0, $FFFFFFFF, %10010010, %11011111);
  // g�rev se�icisi (TSS)
  // Eri�im  : 1 = mevcut, 00 = DPL0, 010 = 32 bit kullan�labilir TSS, 0 = me�gul biti (me�gul de�il), 1
  // Esneklik: 1 = gran = 1Byte ��z�n�rl�k, 00, 1 = bana tahsis edildi, 0000 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_TSS, TSayi4(GorevTSSListesi[2]), 104,
    %10001001, %00010000);

  // denet�inin kullanaca�� TSS'nin i�eri�ini s�f�rla
  FillByte(GorevTSSListesi[2]^, 104, $00);

  GorevTSSListesi[2]^.EIP := TSayi4(@SistemCalismasiniDenetle);    // DPL 0
  GorevTSSListesi[2]^.EFLAGS := $202;
  GorevTSSListesi[2]^.ESP := $4000000 - $100;
  GorevTSSListesi[2]^.CS := SECICI_DENETIM_KOD * 8;
  GorevTSSListesi[2]^.DS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.ES := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.SS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.FS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.GS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.SS0 := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2]^.ESP0 := $4000000 - $100;

  // sistem g�rev de�erlerini belirle
  GorevListesi[2]^.GorevSayaci := 0;
  GorevListesi[2]^.BellekBaslangicAdresi := 0;
  GorevListesi[2]^.BellekUzunlugu := $FFFFFFFF;
  GorevListesi[2]^.OlaySayisi := 0;
  GorevListesi[2]^.OlayBellekAdresi := nil;
  GorevListesi[2]^.FAnaPencere := nil;

  // sistem g�rev ad� (dosya ad�)
  GorevListesi[2]^.FProgramAdi := 'denetci.???';

  // sistem g�revini �al���yor olarak i�aretle
  Gorev := GorevListesi[2];
  Gorev^.DurumDegistir(2, gdCalisiyor);

  // �al��an ve olu�turulan g�rev de�erlerini belirle
  CalisanGorevSayisi := 2;
end;

procedure SistemCalismasiniDenetle;
begin

  while True do
  begin
  asm
//  @@1:

    mov eax,SistemKontrolSayaci
    inc eax
    mov SistemKontrolSayaci,eax

//  jmp @@1
  end;

  GEkranKartSurucusu.EkranBelleginiGuncelle;

  end;
end;

procedure EkranGuncelle;
begin
end;

procedure SistemDegerleriBasla;
var
  Sol: TISayi4;
begin

  Sol := GAktifMasaustu^.FBoyut.Genislik - 150;
  SDPencere := SDPencere^.Olustur(nil, Sol, 10, 140, 54, ptBasliksiz,
    'Sistem Durumu', 0);
  SDPencere^.Goster;

  SDZamanlayici := SDZamanlayici^.Olustur(100);
  SDZamanlayici^.Durum := zdCalisiyor;
end;

procedure SistemDegerleriOlayIsle;
var
  Gorev: PGorev;
  Olay: TOlay;
begin

  Gorev := GorevListesi[1];

  if(Gorev^.OlayAl(Olay)) then
  begin

    if(Olay.Olay = CO_ZAMANLAYICI) then
    begin

      if(Olay.Kimlik = SDZamanlayici^.Kimlik) then
        SDPencere^.Ciz
      else TestAlani.NesneTestOlayIsle(nil, Olay);
    end
    else if(Olay.Olay = CO_CIZIM) then
    begin

      SDPencere^.YaziYaz(SDPencere, 12, 10, 'EIP:', RENK_LACIVERT);
      SDPencere^.YaziYaz(SDPencere, 46, 10, '0x' + hexStr(GorevTSSListesi[1]^.EIP, 8), RENK_LACIVERT);
      SDPencere^.YaziYaz(SDPencere, 12, 28, 'DNT:', RENK_MAVI);
      SDPencere^.YaziYaz(SDPencere, 46, 28, '0x' + hexStr(SistemKontrolSayaci, 8), RENK_MAVI);
    end;
  end;
end;

constructor TTestSinif.Create;
begin

end;

procedure TTestSinif.Artir;
begin

  Inc(FDeger1);
  SISTEM_MESAJ('TTest1.Artir: %d', [FDeger1]);
  SISTEM_MESAJ_YAZI('Birim: ', UnitName);
end;

procedure TTestSinif.Eksilt;
begin

  Dec(FDeger1);
  SISTEM_MESAJ('TTestSinif.Eksilt: %d', [FDeger1]);
end;

// g�rsel nesne test �al��ma alan�
procedure TGorevYonetici.MasaustuBasla;
var
  Masaustu: PMasaustu;
begin

  Masaustu := Masaustu^.Olustur('giri�');
  Masaustu^.MasaustuRenginiDegistir($9FB6BF);
  //Masaustu^.Aktiflestir;

  NTPencere := NTPencere^.Olustur(Masaustu, 100, 100, 500, 400, ptBoyutlanabilir,
    'G�rsel Nesne Y�netim', RENK_BEYAZ);
  NTPencere^.OlayCagriAdresi := @NesneTestOlayIsle;

  dugGorevler[0] := dugGorevler[0]^.Olustur(ktNesne, NTPencere,
    10, 10, 100, 100, 'Art�r');
  dugGorevler[0]^.OlayCagriAdresi := @NesneTestOlayIsle;
  dugGorevler[0]^.Goster;

  dugGorevler[1] := dugGorevler[1]^.Olustur(ktNesne, NTPencere,
    120, 10, 100, 100, 'Eksilt');
  dugGorevler[1]^.OlayCagriAdresi := @NesneTestOlayIsle;
  dugGorevler[1]^.Goster;

//  TestSinif := TTestSinif.Create;
//  TestSinif.FDeger1 := 10;

  NTPencere^.Goster;

  Masaustu^.Gorunum := True;
end;

// g�rsel nesne test �al��ma alan�
procedure TGorevYonetici.ProgramBasla;
var
  i: Integer;
begin

  for i := 0 to 99 do dugGorevler[i] := nil;

  NTPencere := NTPencere^.Olustur(nil, GAktifMasaustu^.FBoyut.Genislik - 220,
    80, 200, 260, ptBoyutlanabilir, 'G�rev Y�netim', RENK_BEYAZ);
  NTPencere^.OlayCagriAdresi := @NesneTestOlayIsle;

  SDZamanlayici2 := SDZamanlayici2^.Olustur(100);
  SDZamanlayici2^.Durum := zdCalisiyor;

//  TestSinif := TTestSinif.Create;
//  TestSinif.FDeger1 := 10;

  NTPencere^.Goster;
end;

// g�rsel nesne olay i�leme alan�
procedure TGorevYonetici.NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  i, j: TSayi4;
  Gorev: PGorev;
  Pencere: PPencere;
  GucDugmesi: PGucDugmesi;
begin

  if(AOlay.Olay = CO_ZAMANLAYICI) then
  begin

    for i := 0 to 99 do
    begin

      if not(dugGorevler[i] = nil) then dugGorevler[i]^.YokEt;
    end;

    j := 0;
    for i := 0 to CalisanGorevSayisi - 1 do
    begin

      Gorev := GorevBilgisiAl(i + 1);
      if not(Gorev^.FAnaPencere = nil) then
      begin

        if not(PPencere(Gorev^.FAnaPencere)^.FPencereTipi = ptBasliksiz) then
        begin

          dugGorevler[i] := dugGorevler[i]^.Olustur(ktNesne, NTPencere,
            5, (j * 25) + 5, 190, 20, Gorev^.FProgramAdi);
          dugGorevler[i]^.FEtiket := Gorev^.GorevKimlik;
          dugGorevler[i]^.OlayCagriAdresi := @NesneTestOlayIsle;

          if(Gorev^.FGorevKimlik = AktifPencere^.GorevKimlik) then
            dugGorevler[i]^.DurumYaz(dugGorevler[i]^.Kimlik, 1);

          Inc(j);
        end;
      end;
    end;

    for i := 0 to CalisanGorevSayisi - 1 do
    begin

      if not(dugGorevler[i] = nil) then dugGorevler[i]^.Goster;
    end;
  end
  else if(AOlay.Olay = CO_DURUMDEGISTI) then
  begin

    if(AOlay.Deger1 = 1) then
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(AOlay.Kimlik));
      if not(GucDugmesi = nil) then
      begin

        Gorev := Gorev^.GorevBul(GucDugmesi^.FEtiket);
        if not(Gorev = nil) then
        begin

          Pencere := PPencere(Gorev^.FAnaPencere);
          if not(Pencere = nil) and (Pencere^.NesneTipi = gntPencere) then
          begin

            // pencere k���lt�lm�� durumda ise normal duruma �evir
            if(Pencere^.FPencereDurum = pdKucultuldu) then
              Pencere^.FPencereDurum := pdNormal;

            Pencere^.EnUsteGetir(Pencere);
          end;
        end;
      end;
    end;
  end;
end;

end.
