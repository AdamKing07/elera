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
  gn_gucdugmesi, gn_resim, gn_karmaliste, gn_degerlistesi, gn_dugme, gn_izgara;

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
  TArGe = object
  private
    P1Dugmeler: array[0..44] of PGucDugmesi;
    P2Dugmeler: array[0..44] of PGucDugmesi;
  public
    TestSinif: TTestSinif;
    Degerler: array[1..8] of TSayi4;
    BulunanCiftSayisi, TiklamaSayisi,
    SecilenEtiket, ToplamTiklamaSayisi: TSayi4;
    procedure Program1Basla;
    procedure Program2Basla;
    procedure Program3Basla;
    procedure P1NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure P2NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure P3NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

var
  SDPencere: PPencere;
  SDZamanlayici, P1Zamanlayici: PZamanlayici;
  P1Pencere, P1Pencere2,
  P2Pencere, P3Pencere: PPencere;
  P1Panel: PPanel;
  P1KarmaListe: PKarmaListe;
  P1Dugme: PDugme;
  P1DegerListesi: PDegerListesi;
  P3Izgara: PIzgara;
  GNEtiket: PEtiket;
  Resim: PResim;
  _DNS: PDNS = nil;
  DugmeSayisi: TSayi4;
  TestAlani: TArGe;

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
  GorevListesi[1]^.FAnaPencere := nil;

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

  //TestAlani.Program1Basla;

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

    // fare olaylarýný iþle
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
  GorevListesi[2]^.FAnaPencere := nil;

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

      if(Olay.Kimlik = SDZamanlayici^.Kimlik) then
        SDPencere^.Ciz
      else TestAlani.P1NesneTestOlayIsle(nil, Olay);
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

procedure TArGe.Program1Basla;
var
  i: TSayi4;
begin

  for i := 0 to 99 do P1Dugmeler[i] := nil;

  P1Pencere := P1Pencere^.Olustur(nil, GAktifMasaustu^.FBoyut.Genislik - 220,
    80, 200, 260, ptBoyutlanabilir, 'Görev Yönetim', RENK_BEYAZ);
  P1Pencere^.OlayCagriAdresi := @P1NesneTestOlayIsle;

  P1Zamanlayici := P1Zamanlayici^.Olustur(200);
  P1Zamanlayici^.Durum := zdCalisiyor;

  P1Pencere2 := P1Pencere2^.Olustur(nil, 10, 10, 180, 400, ptBoyutlanabilir,
    'Yazmaçlar', RENK_BEYAZ);
  //P1Pencere2^.OlayCagriAdresi := @P1NesneTestOlayIsle;

  P1Panel := P1Panel^.Olustur(ktNesne, P1Pencere2, 0, 0, 100, 29, 0, 0, 0, 0, '');
  P1Panel^.FHiza := hzUst;
  P1Panel^.Goster;

  P1KarmaListe := P1KarmaListe^.Olustur(ktNesne, P1Panel, 2, 3, 100, 28);
  P1KarmaListe^.ListeyeEkle('Görev-1');
  P1KarmaListe^.ListeyeEkle('Görev-2');
  P1KarmaListe^.ListeyeEkle('Görev-3');
  P1KarmaListe^.ListeyeEkle('Görev-4');
  P1KarmaListe^.ListeyeEkle('Görev-5');
  P1KarmaListe^.Goster;

  P1Dugme := P1Dugme^.Olustur(ktNesne, P1Panel, 105, 2, 70, 24, 'Yenile');
  P1Dugme^.Goster;

  P1DegerListesi := P1DegerListesi^.Olustur(ktNesne, P1Pencere2, 0, 0, 100, 100);
  P1DegerListesi^.FHiza := hzTum;
  P1DegerListesi^.BaslikEkle('Yazmaç', 'Deðer', 80);
  P1DegerListesi^.Goster;

//  TestSinif := TTestSinif.Create;
//  TestSinif.FDeger1 := 10;

  P1Pencere2^.Goster;
  P1Pencere^.Goster;
end;

procedure TArGe.P1NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  i, j: TSayi4;
  Gorev: PGorev;
  Pencere: PPencere;
  GucDugmesi: PGucDugmesi;
  TSS: PTSS;
begin

  if(AOlay.Olay = CO_ZAMANLAYICI) then
  begin

    for i := 0 to 99 do
    begin

      if not(P1Dugmeler[i] = nil) then P1Dugmeler[i]^.YokEt;
    end;

    j := 0;
    for i := 0 to CalisanGorevSayisi - 1 do
    begin

      Gorev := GorevBilgisiAl(i + 1);
      if not(Gorev^.FAnaPencere = nil) then
      begin

        if not(PPencere(Gorev^.FAnaPencere)^.FPencereTipi = ptBasliksiz) then
        begin

          P1Dugmeler[i] := P1Dugmeler[i]^.Olustur(ktNesne, P1Pencere,
            5, (j * 25) + 5, 190, 20, Gorev^.FProgramAdi);
          P1Dugmeler[i]^.FEtiket := Gorev^.GorevKimlik;
          P1Dugmeler[i]^.OlayCagriAdresi := @P1NesneTestOlayIsle;

          if(Gorev^.FGorevKimlik = AktifPencere^.GorevKimlik) then
            P1Dugmeler[i]^.DurumYaz(P1Dugmeler[i]^.Kimlik, 1);

          Inc(j);
        end;
      end;
    end;

    for i := 0 to CalisanGorevSayisi - 1 do
    begin

      if not(P1Dugmeler[i] = nil) then P1Dugmeler[i]^.Goster;
    end;

    P1DegerListesi^.DegerIceriginiTemizle;

    TSS := GorevTSSListesi[2];

    P1DegerListesi^.DegerEkle('EAX|0x' + hexStr(TSS^.EAX, 8));
    P1DegerListesi^.DegerEkle('ECX|0x' + hexStr(TSS^.ECX, 8));
    P1DegerListesi^.DegerEkle('EDX|0x' + hexStr(TSS^.EDX, 8));
    P1DegerListesi^.DegerEkle('EBX|0x' + hexStr(TSS^.EBX, 8));
    P1DegerListesi^.DegerEkle('ESP|0x' + hexStr(TSS^.ESP, 8));
    P1DegerListesi^.DegerEkle('EBP|0x' + hexStr(TSS^.EBP, 8));
    P1DegerListesi^.DegerEkle('ESI|0x' + hexStr(TSS^.ESI, 8));
    P1DegerListesi^.DegerEkle('EDI|0x' + hexStr(TSS^.EDI, 8));
    P1DegerListesi^.DegerEkle('CS|0x' + hexStr(TSS^.CS, 8));
    P1DegerListesi^.DegerEkle('DS|0x' + hexStr(TSS^.DS, 8));
    P1DegerListesi^.DegerEkle('ES|0x' + hexStr(TSS^.ES, 8));
    P1DegerListesi^.DegerEkle('SS|0x' + hexStr(TSS^.SS, 8));
    P1DegerListesi^.DegerEkle('FS|0x' + hexStr(TSS^.FS, 8));
    P1DegerListesi^.DegerEkle('GS|0x' + hexStr(TSS^.GS, 8));
    P1DegerListesi^.DegerEkle('SS0|0x' + hexStr(TSS^.SS0, 8));
    P1DegerListesi^.DegerEkle('ESP0|0x' + hexStr(TSS^.ESP0, 8));
    P1DegerListesi^.DegerEkle('SS1|0x' + hexStr(TSS^.SS1, 8));
    P1DegerListesi^.DegerEkle('ESP1|0x' + hexStr(TSS^.ESP1, 8));
    P1DegerListesi^.DegerEkle('SS2|0x' + hexStr(TSS^.SS2, 8));
    P1DegerListesi^.DegerEkle('ESP2|0x' + hexStr(TSS^.ESP2, 8));
    P1DegerListesi^.DegerEkle('CR3|0x' + hexStr(TSS^.CR3, 8));
    P1DegerListesi^.DegerEkle('EIP|0x' + hexStr(TSS^.EIP, 8));
    P1DegerListesi^.DegerEkle('EFLAGS|0x' + hexStr(TSS^.EFLAGS, 8));
    P1DegerListesi^.DegerEkle('LDT|0x' + hexStr(TSS^.LDT, 8));
    P1DegerListesi^.Ciz;
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

            // pencere küçültülmüþ durumda ise normal duruma çevir
            if(Pencere^.FPencereDurum = pdKucultuldu) then
              Pencere^.FPencereDurum := pdNormal;

            Pencere^.EnUsteGetir(Pencere);
          end;
        end;
      end;
    end;
  end;
end;

procedure TArGe.Program2Basla;
var
  P2Masaustu: PMasaustu;
begin

  P2Masaustu := P2Masaustu^.Olustur('giriþ');
  P2Masaustu^.MasaustuRenginiDegistir($9FB6BF);
  //P2Masaustu^.Aktiflestir;

  P2Pencere := P2Pencere^.Olustur(P2Masaustu, 100, 100, 500, 400, ptBoyutlanabilir,
    'Görsel Nesne Yönetim', RENK_BEYAZ);
  P2Pencere^.OlayCagriAdresi := @P2NesneTestOlayIsle;

  P2Dugmeler[0] := P2Dugmeler[0]^.Olustur(ktNesne, P2Pencere,
    10, 10, 100, 100, 'Artýr');
  P2Dugmeler[0]^.OlayCagriAdresi := @P2NesneTestOlayIsle;
  P2Dugmeler[0]^.Goster;

  P2Dugmeler[1] := P2Dugmeler[1]^.Olustur(ktNesne, P2Pencere,
    120, 10, 100, 100, 'Eksilt');
  P2Dugmeler[1]^.OlayCagriAdresi := @P2NesneTestOlayIsle;
  P2Dugmeler[1]^.Goster;

//  TestSinif := TTestSinif.Create;
//  TestSinif.FDeger1 := 10;

  P2Pencere^.Goster;

  P2Masaustu^.Gorunum := True;
end;

procedure TArGe.P2NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
begin

end;

procedure TArGe.Program3Basla;
var
  i: Integer;
begin

  P3Pencere := P3Pencere^.Olustur(nil, 10, 10, 300, 300, ptBoyutlanabilir, 'Izgara', RENK_BEYAZ);
  P3Pencere^.OlayCagriAdresi := @P3NesneTestOlayIsle;

  P3Izgara := P3Izgara^.Olustur(ktNesne, P3Pencere, 0, 0, 180, 180);
  P3Izgara^.FHiza := hzTum;
  //P3Izgara^.
  //P3Izgara^.BaslikEkle('Yazmaç', 'Deðer', 80);
  P3Izgara^.Goster;

  P3Pencere^.Goster;
end;

procedure TArGe.P3NesneTestOlayIsle(AGonderici: PGorselNesne; AOlay: TOlay);
begin

end;

end.
