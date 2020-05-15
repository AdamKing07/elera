{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: yonetim.pas
  Dosya ��levi: sistem ana y�netim / kontrol k�sm�

  G�ncelleme Tarihi: 19/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit yonetim;

interface

uses paylasim, gn_pencere, gn_dugme, gn_giriskutusu, gn_etiket, gn_defter,
  zamanlayici, dns, gn_panel, gorselnesne;

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

  { TDeneme }

  TDeneme = object
    Degerler: array[1..8] of TSayi4;
    BulunanCiftSayisi, TiklamaSayisi,
    SecilenEtiket, ToplamTiklamaSayisi: TSayi4;
    procedure NesneTestBasla;
    procedure IlkDegerAtamalari;
    function SayacDegeriAl: TSayi4;
    procedure NesneTestOlayIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

var
  _SDPencere: PPencere;
  _SDZamanlayici: PZamanlayici;

  _NTPencere: PPencere;
  GNEtiket: PEtiket;
  _NTDefter: PDefter;
  _DNS: PDNS = nil;
  DugmeSayisi: TSayi4;
  _Dugme: array[0..15] of PDugme;
  Deneme: TDeneme;

procedure Yukle;
procedure SistemAnaKontrol;
procedure SistemDenetcisiOlustur;
procedure SistemCalismasiniDenetle;
procedure SistemDegerleriBasla;
procedure SistemDegerleriOlayIsle;

implementation

uses gdt, gorev, src_klavye, genel, ag, dhcp, iletisim, arp,
  sistemmesaj, src_vesa20, acpi, donusum;

{==============================================================================
  sistem ilk y�kleme i�levlerini ger�ekle�tirir
 ==============================================================================}
procedure Yukle;
var
  _Gorev: PGorev;
  _GMBilgi: PGMBilgi;
  _OlayKayit: POlayKayit;
begin

  _GMBilgi := PGMBilgi(BILDEN_VERIADRESI);

  // video bilgilerini al
  GEkranKartSurucusu.KartBilgisi.BellekUzunlugu := _GMBilgi^.VideoBellekUzunlugu;
  GEkranKartSurucusu.KartBilgisi.EkranMod := _GMBilgi^.VideoEkranMod;
  GEkranKartSurucusu.KartBilgisi.YatayCozunurluk := _GMBilgi^.VideoYatayCozunurluk;
  GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk := _GMBilgi^.VideoDikeyCozunurluk;
  GEkranKartSurucusu.KartBilgisi.BellekAdresi := _GMBilgi^.VideoBellekAdresi; //VIDEO_MEM_ADDR;
  GEkranKartSurucusu.KartBilgisi.PixelBasinaBitSayisi := _GMBilgi^.VideoPixelBasinaBitSayisi;
  GEkranKartSurucusu.KartBilgisi.NoktaBasinaByteSayisi := (_GMBilgi^.VideoPixelBasinaBitSayisi div 8);
  GEkranKartSurucusu.KartBilgisi.SatirdakiByteSayisi := _GMBilgi^.VideoSatirdakiByteSayisi;

  // �ekirdek bilgilerini al
  CekirdekBaslangicAdresi := _GMBilgi^.CekirdekBaslangicAdresi;
  CekirdekUzunlugu := _GMBilgi^.CekirdekKodUzunluk;

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
  GorevListesi[1]^.EvBuffer := nil;

  GorevListesi[1]^.FProgramAdi := 'cekirdek.bin';

  // sistem g�revini �al���yor olarak i�aretle
  _Gorev := GorevListesi[1];
  _Gorev^.OlaySayisi := 0;

  _OlayKayit := POlayKayit(GGercekBellek.Ayir(4096));
  if not(_OlayKayit = nil) then
  begin

    _Gorev^.FOlayBellekAdresi := _OlayKayit;
  end else _Gorev^.FOlayBellekAdresi := nil;

  _Gorev^.DurumDegistir(1, gdCalisiyor);

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
  _Gorev: PGorev;
  _Tus: Char;
  _TusDurum: TTusDurum;
begin

  if(CalisanGorevSayisi = 1) then
  repeat

    _Gorev^.Calistir(AcilisSurucuAygiti + ':\' + OnDegerMasaustuProgram);
    ElleGorevDegistir;
  until CalisanGorevSayisi > 1;

  KONTROLTusDurumu := tdYok;
  ALTTusDurumu := tdYok;
  DEGISIMTusDurumu := tdYok;

  // masa�st� aktif olana kadar bekle
  while GAktifMasaustu = nil do;

  // sistem de�er g�r�nt�leyicisini ba�lat
  SistemDegerleriBasla;
  Deneme.NesneTestBasla;

  // sistem i�in DHCP sunucusundan IP adresi al
  if(AgYuklendi) then DHCPSunucuKesfet;

  repeat

    // sistem sayac�n� art�r
    Inc(SistemSayaci);

    // klavyeden bas�lan tu�u al
    _TusDurum := KlavyedenTusAl(_Tus);
    if(_TusDurum = tdBasildi) and (_Tus <> #0) then
    begin

      if(KONTROLTusDurumu = tdBasildi) then
      begin

        // DHCP sunucusundan IP adresi al
        // bilgi: agbilgi.c program�n�n se�ene�ine ba�l�d�r
        if(_Tus = '2') then
        begin

          DHCPSunucuKesfet;
        end
        // test ama�l�
        else if(_Tus = '3') then
        begin

          //_Gorev^.Calistir('disk1:\dnssorgu.c');
          {i := FindFirst('disk1:\kaynak\*.*', 0, AramaKaydi);
          while i = 0 do
          begin

            SISTEM_MESAJ('Dosya: ' + AramaKaydi.DosyaAdi, []);
            i := FindNext(AramaKaydi);
          end;
          FindClose(AramaKaydi);}
          //_Gorev^.Calistir('disket1:\aliimran.txt');
          _Gorev^.Calistir('disk1:\hafiza.c');
        end
        else if(_Tus = 'd') then
        begin

          _Gorev^.Calistir('disk1:\dsyyntcs.c');
        end
        else if(_Tus = 'g') then
        begin

          _Gorev^.Calistir('disk1:\grvyntcs.c');
        end
        else if(_Tus = 'm') then
        begin

          _Gorev^.Calistir('disk1:\smsjgor.c');
        end
      end
      else
      begin

        // klavye olaylar�n� i�le
        GOlay.KlavyeOlaylariniIsle(_Tus);
      end;
    end;

    if(AgYuklendi) then AgKartiVeriAlmaIslevi;

    // mouse olaylar�n� i�le
    GOlay.FareOlaylariniIsle;

    GEkranKartSurucusu.EkranBelleginiGuncelle;

    SistemDegerleriOlayIsle;

  until (1 = 2);
end;

procedure SistemDenetcisiOlustur;
var
  _Gorev: PGorev;
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
  GorevListesi[2]^.EvBuffer := nil;

  // sistem g�rev ad� (dosya ad�)
  GorevListesi[2]^.FProgramAdi := 'denetci.???';

  // sistem g�revini �al���yor olarak i�aretle
  _Gorev := GorevListesi[2];
  _Gorev^.DurumDegistir(2, gdCalisiyor);

  // �al��an ve olu�turulan g�rev de�erlerini belirle
  CalisanGorevSayisi := 2;
end;

procedure SistemCalismasiniDenetle;
begin

  asm
  @@1:

    mov eax,SistemKontrolSayaci
    inc eax
    mov SistemKontrolSayaci,eax
  jmp @@1
  end;
end;

procedure SistemDegerleriBasla;
var
  _Sol: TISayi4;
begin

  _Sol := GAktifMasaustu^.FBoyutlar.Genislik2 - 150;
  _SDPencere := _SDPencere^.Olustur(-1, _Sol, 10, 140, 50, ptBasliksiz,
    'Sistem Durumu', RENK_BEYAZ);
  _SDPencere^.Goster;

  _SDZamanlayici := _SDZamanlayici^.Olustur(100);
  _SDZamanlayici^.Durum := zdCalisiyor;
end;

procedure SistemDegerleriOlayIsle;
var
  _Gorev: PGorev;
  _OlayKayit: TOlayKayit;
begin

  _Gorev := GorevListesi[1];

  if(_Gorev^.OlayAl(_OlayKayit)) then
  begin

    if(_OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      _SDPencere^.Ciz;
    end
    else if(_OlayKayit.Olay = CO_CIZIM) then
    begin

      _SDPencere^.YaziYaz(_SDPencere, 12, 10, 'EIP:', RENK_BEYAZ);
      _SDPencere^.YaziYaz(_SDPencere, 46, 10, '0x' + hexStr(GorevTSSListesi[1]^.EIP, 8), RENK_BEYAZ);
      _SDPencere^.YaziYaz(_SDPencere, 12, 28, 'DNT:', RENK_BEYAZ);
      _SDPencere^.YaziYaz(_SDPencere, 46, 28, '0x' + hexStr(SistemKontrolSayaci, 8), RENK_BEYAZ);
    end //else NesneTestOlayIsle(_OlayKayit);
  end;
end;

// dns test �al��mas�
procedure TDeneme.NesneTestBasla;
begin

  exit;
  _NTPencere := _NTPencere^.Olustur(-1, 100, 100, 335, 385, ptBoyutlandirilabilir,
    'Haf�za G��lendirme', RENK_BEYAZ);

  GNEtiket := GNEtiket^.Olustur(_NTPencere^.Kimlik, 92, 330, RENK_LACIVERT,
    'T�klama Say�s�: 0  ');
  GNEtiket^.Goster;

  IlkDegerAtamalari;

  _NTPencere^.Goster;
end;

procedure TDeneme.IlkDegerAtamalari;
var
  Sol, Ust: TISayi4;
  i, j: Integer;
begin

  ToplamTiklamaSayisi := 0;

  TiklamaSayisi := 0;

  BulunanCiftSayisi := 0;

  Sol := 12;
  Ust := 12;

  for i := 1 to 8 do Degerler[i] := 0;

  DugmeSayisi := 0;
  for i := 0 to 3 do
  for j := 0 to 3 do
  begin

    _Dugme[DugmeSayisi] := _Dugme[DugmeSayisi]^.Olustur(_NTPencere^.Kimlik,
      Sol + i * 76, Ust + j * 76, 74, 74, '?');
    _Dugme[DugmeSayisi]^.FEtiket := SayacDegeriAl;
    _Dugme[DugmeSayisi]^.CizimModelDegistir(True, $F2D8AF, $FAECD6, RENK_SIYAH, RENK_KIRMIZI);
    _Dugme[DugmeSayisi]^.FEfendiNesneOlayCagriAdresi := @NesneTestOlayIsle;
    _Dugme[DugmeSayisi]^.Goster;

    Inc(DugmeSayisi);
  end;

  GNEtiket^.Baslik := 'T�klama Say�s�: 0';
end;

function TDeneme.SayacDegeriAl: TSayi4;

  function Al: TSayi4;
  begin
    asm
    rdtsc
    end;
  end;
var
  Deger: TSayi4;
begin

  while True do
  begin

    Deger := Al;
    Deger := (Deger and 7) + 1;

    if(Deger >= 1) and (Deger <= 8) then
    begin

      if(Degerler[Deger] < 2) then
      begin

        Inc(Degerler[Deger]);
        Exit(Deger);
      end;
    end;
  end;
end;

procedure TDeneme.NesneTestOlayIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
begin

  exit;
  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    Inc(TiklamaSayisi);
    Inc(ToplamTiklamaSayisi);

    GNEtiket^.Baslik := 'T�klama Say�s�: ' + IntToStr(ToplamTiklamaSayisi);

    if(TiklamaSayisi = 1) then
    begin

      _Dugme[0] := PDugme(_Dugme[0]^.NesneAl(AKimlik));
      _Dugme[0]^.Baslik := IntToStr(_Dugme[0]^.FEtiket);
    end

    else if(TiklamaSayisi = 2) then
    begin

      _Dugme[1] := PDugme(_Dugme[1]^.NesneAl(AKimlik));

      if(_Dugme[0]^.Kimlik = AKimlik) then
      begin

        _Dugme[1]^.Baslik := '?';
      end
      else
      begin

        if(_Dugme[0]^.FEtiket = _Dugme[1]^.FEtiket) then
        begin

          _Dugme[1]^.Baslik := IntToStr(_Dugme[1]^.FEtiket);

          _Dugme[0]^.Gorunum := False;
          _Dugme[1]^.Gorunum := False;

          Inc(BulunanCiftSayisi);
          if(BulunanCiftSayisi = 8) then
          begin

            // oyunu ba�a d�nd�r
            IlkDegerAtamalari;
          end;
        end
        else
        begin

          _Dugme[1]^.Baslik := IntToStr(_Dugme[1]^.FEtiket);

          GEkranKartSurucusu.EkranBelleginiGuncelle;

          Bekle(50);

          _Dugme[0]^.Baslik := '?';
          _Dugme[1]^.Baslik := '?';
        end;
      end;

      TiklamaSayisi := 0;
    end;
  end;
end;

end.
