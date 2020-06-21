{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: yonetim.pas
  Dosya Ýþlevi: sistem ana yönetim / kontrol kýsmý

  Güncelleme Tarihi: 21/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit yonetim;

interface

uses paylasim, gn_pencere, gn_etiket, zamanlayici, dns, gn_panel, gorselnesne,
  gn_dugme, gn_resim, gn_karmaliste;

type
  // gerçek moddan gelen veri yapýsý
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
  TTestAlani = object
    TestSinif: TTestSinif;
    Degerler: array[1..8] of TSayi4;
    BulunanCiftSayisi, TiklamaSayisi,
    SecilenEtiket, ToplamTiklamaSayisi: TSayi4;
    procedure Basla;
    procedure NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

var
  SDPencere: PPencere;
  SDZamanlayici: PZamanlayici;

  NTPencere: PPencere;
  GNEtiket: PEtiket;
  KarmaListe: PKarmaListe;
  Resim: PResim;
  _DNS: PDNS = nil;
  DugmeSayisi: TSayi4;
  GorselNesneler: array[0..1] of PDugme;
  TestAlani: TTestAlani;

procedure Yukle;
procedure SistemAnaKontrol;
procedure SistemDenetcisiOlustur;
procedure SistemCalismasiniDenetle;
procedure EkranGuncelle;
procedure SistemDegerleriBasla;
procedure SistemDegerleriOlayIsle;

implementation

uses gdt, gorev, src_klavye, genel, ag, dhcp, iletisim, arp,
  sistemmesaj, src_vesa20, acpi, donusum, gn_masaustu;

{==============================================================================
  sistem ilk yükleme iþlevlerini gerçekleþtirir
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

  // çekirdek bilgilerini al
  CekirdekBaslangicAdresi := GMBilgi^.CekirdekBaslangicAdresi;
  CekirdekUzunlugu := GMBilgi^.CekirdekKodUzunluk;

  // zamanlayýcý sayacýný sýfýrla
  ZamanlayiciSayaci := 0;

  // sistem sayacýný sýfýrla
  SistemSayaci := 0;

  // öndeðer fare göstergesini belirle
  GecerliFareGostegeTipi := fitBekle;

  // çekirdeðin kullanacaðý TSS'nin içeriðini sýfýrla
  FillByte(GorevTSSListesi[1]^, 104, $00);

  // TSS içeriðini doldur
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

  // not: sistem için CS ve DS seçicileri bilden programý tarafýndan
  // oluþturuldu. tekrar oluþturmaya gerek yok

  // sistem için görev seçicisi (TSS)
  // Eriþim  : 1 = mevcut, 00 = DPL0, 010 = 32 bit kullanýlabilir TSS, 0 = meþgul biti (meþgul deðil), 1
  // Esneklik: 1 = gran = 1Byte çözünürlük, 00, 1 = bana tahsis edildi, 0000 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_SISTEM_TSS, TSayi4(GorevTSSListesi[1]), 104,
    %10001001, %00010000);

  // sistem görev deðerlerini belirle
  GorevListesi[1]^.GorevSayaci := 0;
  GorevListesi[1]^.BellekBaslangicAdresi := CekirdekBaslangicAdresi;
  GorevListesi[1]^.BellekUzunlugu := CekirdekUzunlugu;
  GorevListesi[1]^.OlaySayisi := 0;
  GorevListesi[1]^.OlayBellekAdresi := nil;

  GorevListesi[1]^.FProgramAdi := 'cekirdek.bin';

  // sistem görevini çalýþýyor olarak iþaretle
  Gorev := GorevListesi[1];
  Gorev^.OlaySayisi := 0;

  Olay := POlay(GGercekBellek.Ayir(4096));
  if not(Olay = nil) then
  begin

    Gorev^.FOlayBellekAdresi := Olay;
  end else Gorev^.FOlayBellekAdresi := nil;

  Gorev^.DurumDegistir(1, gdCalisiyor);

  // çalýþan ve oluþturulan görev deðerlerini belirle
  CalisanGorevSayisi := 1;
  CalisanGorev := CalisanGorevSayisi;

  // ilk TSS'yi yükle
  // not : tss'nin yükleme iþlevi görev geçiþini gerçekleþtirmez. sadece
  // TSS'yi meþgul olarak ayarlar.
  asm
    mov   ax, SECICI_SISTEM_TSS * 8;
    ltr   ax
  end;

  // ana çekirdeðin iþleyiþini takip eden sistem denetçisini oluþtur
  SistemDenetcisiOlustur;
end;

{==============================================================================
  sistem ana kontrol kýsmý
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

  // masaüstü aktif olana kadar bekle
  while GAktifMasaustu = nil do;

  // sistem deðer görüntüleyicisini baþlat
  SistemDegerleriBasla;

  TestAlani.Basla;

  // sistem için DHCP sunucusundan IP adresi al
  if(AgYuklendi) then DHCPSunucuKesfet;

  repeat

    // sistem sayacýný artýr
    Inc(SistemSayaci);

    // klavyeden basýlan tuþu al
    TusDurum := KlavyedenTusAl(Tus);
    if(TusDurum = tdBasildi) and (Tus <> #0) then
    begin

      if(KONTROLTusDurumu = tdBasildi) then
      begin

        // DHCP sunucusundan IP adresi al
        // bilgi: agbilgi.c programýnýn seçeneðine baðlýdýr
        if(Tus = '2') then
        begin

          DHCPSunucuKesfet;
        end
        // test amaçlý
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
          Gorev^.Calistir('disk1:\sisbilgi.c');
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

        // klavye olaylarýný iþle
        GOlayYonetim.KlavyeOlaylariniIsle(Tus);
      end;
    end;

    if(AgYuklendi) then AgKartiVeriAlmaIslevi;

    // mouse olaylarýný iþle
    GOlayYonetim.FareOlaylariniIsle;

//    GEkranKartSurucusu.EkranBelleginiGuncelle;

    SistemDegerleriOlayIsle;

  until (1 = 2);
end;

procedure SistemDenetcisiOlustur;
var
  Gorev: PGorev;
begin

  // kod seçicisi (CS)
  // Eriþim  : 1 = mevcut, 00 = DPL0, 11 = kod yazmaç, 0 = dallanýlamaz, 1 = okunabilir, 0 = eriþilmedi
  // Esneklik: 1 = gran = 4K çözünürlük, 1 = 32 bit, 0, 1 = bana tahsis edildi, 1111 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_KOD, 0, $FFFFFFFF, %10011010, %11011111);
  // veri seçicisi (DS)
  // Eriþim  : 1 = mevcut, 00 = DPL0, 10 = veri yazmaç, 0 = artarak büyüyen, 1 = yazýlabilir, 0 = eriþilmedi
  // Esneklik: 1 = gran = 4K çözünürlük, 1 = 32 bit, 0, 1 = bana tahsis edildi, 1111 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_VERI, 0, $FFFFFFFF, %10010010, %11011111);
  // görev seçicisi (TSS)
  // Eriþim  : 1 = mevcut, 00 = DPL0, 010 = 32 bit kullanýlabilir TSS, 0 = meþgul biti (meþgul deðil), 1
  // Esneklik: 1 = gran = 1Byte çözünürlük, 00, 1 = bana tahsis edildi, 0000 = uzunluk 16..19 bit
  GDTRGirdisiEkle(SECICI_DENETIM_TSS, TSayi4(GorevTSSListesi[2]), 104,
    %10001001, %00010000);

  // denetçinin kullanacaðý TSS'nin içeriðini sýfýrla
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

  // sistem görev deðerlerini belirle
  GorevListesi[2]^.GorevSayaci := 0;
  GorevListesi[2]^.BellekBaslangicAdresi := 0;
  GorevListesi[2]^.BellekUzunlugu := $FFFFFFFF;
  GorevListesi[2]^.OlaySayisi := 0;
  GorevListesi[2]^.OlayBellekAdresi := nil;

  // sistem görev adý (dosya adý)
  GorevListesi[2]^.FProgramAdi := 'denetci.???';

  // sistem görevini çalýþýyor olarak iþaretle
  Gorev := GorevListesi[2];
  Gorev^.DurumDegistir(2, gdCalisiyor);

  // çalýþan ve oluþturulan görev deðerlerini belirle
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

      SDPencere^.Ciz;
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

// görsel nesne test çalýþma alaný
procedure TTestAlani.Basla;
var
  Masaustu: PMasaustu;
begin

  Exit;

  Masaustu := Masaustu^.Olustur('giriþ');
  Masaustu^.MasaustuRenginiDegistir($9FB6BF);
  Masaustu^.Aktiflestir;

  NTPencere := NTPencere^.Olustur(nil, 100, 100, 500, 400, ptBoyutlanabilir,
    'Görsel Nesne Yönetim', RENK_BEYAZ);
  NTPencere^.OlayCagriAdresi := @NesneTestOlayIsle;

  GorselNesneler[0] := GorselNesneler[0]^.Olustur(ktNesne, NTPencere,
    10, 10, 100, 100, 'Artýr');
  GorselNesneler[0]^.Goster;

  GorselNesneler[1] := GorselNesneler[1]^.Olustur(ktNesne, NTPencere,
    120, 10, 100, 100, 'Eksilt');
  GorselNesneler[1]^.Goster;

//  TestSinif := TTestSinif.Create;
//  TestSinif.FDeger1 := 10;

  NTPencere^.Goster;

  Masaustu^.Goster;
end;

// görsel nesne olay iþleme alaný
procedure TTestAlani.NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
begin

  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    if(AOlay.Kimlik = GorselNesneler[0]^.Kimlik) then
    begin

      SISTEM_MESAJ('Artýrma Düðmesi Kimlik: %d', [AOlay.Kimlik]);

      //TestSinif.Artir;
    end
    else if(AOlay.Kimlik = GorselNesneler[1]^.Kimlik) then
    begin

      SISTEM_MESAJ('Eksiltme Düðmesi Kimlik: %d', [AOlay.Kimlik]);

      //TestSinif.Eksilt;
    end;
  end;
end;

end.
