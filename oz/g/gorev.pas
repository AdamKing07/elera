{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gorev.pas
  Dosya Ýþlevi: görev (program) yönetim iþlevlerini içerir

  Güncelleme Tarihi: 23/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gorev;

interface

uses paylasim, gorselnesne;

const
  // bir görev için tanýmlanan üst sýnýr olay sayýsý
  // olay belleði 4K olarak tanýmlanmýþtýr. 4096 / SizeOf(TOlay)
  USTSINIR_OLAY         = 64;
  PROGRAM_YIGIN_BELLEK  = 4096 * 4;    // program yýðýný (stack) için ayrýlacak bellek

type
  TDosyaTip = (dtDiger, dtCalistirilabilir, dtSurucu, dtResim, dtBelge);

type
  TDosyaIliskisi = record
    Uzanti: string[5];            // iliþki kurulacak dosya uzantýsý
    Uygulama: string[30];         // uzantýnýn iliþkili olduðu program adý
    DosyaTip: TDosyaTip;          // uzantýnýn iliþkili olduðu dosya tipi
  end;

type
  PGorev = ^TGorev;
  TGorev = object
  private
    FBellekUzunlugu: TSayi4;              // iþlemin kullandýðý bellek uzunluðu
    FKodBaslangicAdres: TSayi4;           // iþlemin bellek baþlangýç adresi
    FYiginBaslangicAdres: TSayi4;         // iþlemin yýðýn adresi
    FOlaySayisi: TSayi4;                  // olay sayacý
    FOlayBellekAdresi: POlayKayit;        // olaylarýn yerleþtirileceði bellek bölgesi
    procedure GorevSayaciYaz(ASayacDegeri: TSayi4);
    procedure OlaySayisiYaz(AOlaySayisi: TSayi4);
  protected
    function Olustur: PGorev;
    function BosGorevBul: PGorev;
    procedure SecicileriOlustur;
  public
    FGorevKimlik: TGorevKimlik;           // iþlem numarasý
    FGorevDurum: TGorevDurum;             // iþlem durumu
    FGorevSayaci: TSayi4;                 // görev deðiþim sayacý
    FBellekBaslangicAdresi: TSayi4;       // iþlemin yüklendiði bellek adresi
    FProgramAdi: string;                  // iþlem adý
    procedure Yukle;
    function Calistir(ATamDosyaYolu: string): PGorev;
    procedure DurumDegistir(AGorevKimlik: TGorevKimlik; AGorevDurum: TGorevDurum);
    procedure OlayEkle1(AGorevKimlik: TGorevKimlik; AGorselNesne: PGorselNesne;
      AOlay, ADeger1, ADeger2: TISayi4);
    procedure OlayEkle2(AGorevKimlik: TGorevKimlik; AOlayKayit: TOlayKayit);
    function OlayAl(var AOlay: TOlayKayit): Boolean;
    function Sonlandir(AGorevKimlik: TGorevKimlik;
      const ASonlanmaSebebi: TISayi4 = -1): TISayi4;
    property EvBuffer: POlayKayit read FOlayBellekAdresi write FOlayBellekAdresi;
  published
    property GorevKimlik: TGorevKimlik read FGorevKimlik;
    property BellekBaslangicAdresi: TSayi4 read FBellekBaslangicAdresi write FBellekBaslangicAdresi;
    property BellekUzunlugu: TSayi4 read FBellekUzunlugu write FBellekUzunlugu;
    property KodBaslangicAdres: TSayi4 read FKodBaslangicAdres write FKodBaslangicAdres;
    property YiginBaslangicAdres: TSayi4 read FYiginBaslangicAdres write FYiginBaslangicAdres;
    property GorevSayaci: TSayi4 read FGorevSayaci write GorevSayaciYaz;
    property OlaySayisi: TSayi4 read FOlaySayisi write OlaySayisiYaz;
  end;

function GorevBilgisiAl(AGorevSiraNo: TISayi4): PGorev;
function GorevSiraNumarasiniAl(AGorevSiraNo: TISayi4): TGorevKimlik;
function CalistirilacakBirSonrakiGoreviBul: TGorevKimlik;
function IliskiliProgramAl(ADosyaUzanti: string): TDosyaIliskisi;

implementation

uses genel, gdt, bolumleme, dosya, sistemmesaj, donusum, zamanlayici, gn_islevler,
  yonetim, islevler;

const
  IstisnaAciklamaListesi: array[0..15] of string = (
    ('Sýfýra Bölme Hatasý'),
    ('Hata Ayýklama'),
    ('Engellenemeyen Kesme'),
    ('Durma Noktasý'),
    ('Taþma Hatasý'),
    ('Dizi Aralýðý Aþma Hatasý'),
    ('Hatalý Ýþlemci Kodu'),
    ('Matematik Ýþlemci Mevcut Deðil'),
    ('Çifte Hata'),
    ('Matematik Ýþlemci Yazmaç Hatasý'),
    ('Hatalý TSS Giriþi'),
    ('Yazmaç Mevcut Deðil'),
    ('Yýðýn Hatasý'),
    ('Genel Koruma Hatasý'),
    ('Sayfa Hatasý'),
    ('Hata No: 15 - Tanýmlanmamýþ'));

const
  ILISKILI_UYGULAMA_SAYISI = 5;
  IliskiliUygulamaListesi: array[0..ILISKILI_UYGULAMA_SAYISI - 1] of TDosyaIliskisi = (
    (Uzanti: '';     Uygulama: 'dsybil.c';     DosyaTip: dtDiger),
    (Uzanti: 'c';    Uygulama: '';             DosyaTip: dtCalistirilabilir),
    (Uzanti: 's';    Uygulama: '';             DosyaTip: dtSurucu),
    (Uzanti: 'bmp';  Uygulama: 'resimgor.c';   DosyaTip: dtResim),
    (Uzanti: 'txt';  Uygulama: 'defter.c';     DosyaTip: dtBelge));

{==============================================================================
  çalýþtýrýlacak görevlerin ana yükleme iþlevlerini içerir
 ==============================================================================}
procedure TGorev.Yukle;
var
  _Gorev: PGorev;
  i: TISayi4;
begin

  // görev bilgilerinin yerleþtirilmesi için bellek ayýr
  _Gorev := GGercekBellek.Ayir(SizeOf(TGorev) * USTSINIR_GOREVSAYISI);

  // bellek giriþlerini görev yapýlarýyla eþleþtir
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    GorevListesi[i] := _Gorev;

    // görevi boþ olarak belirle
    _Gorev^.FGorevDurum := gdBos;
    _Gorev^.FGorevKimlik := i;

    Inc(_Gorev);
  end;
end;

{==============================================================================
  görev (program) dosyalarýný çalýþtýrýr
 ==============================================================================}
function TGorev.Calistir(ATamDosyaYolu: string): PGorev;
var
  _Gorev: PGorev;
  _DosyaBellek: Isaretci;
  _OlayKayit: POlayKayit;
  _DosyaU, i: TSayi4;
  _Surucu, _Dizin,
  _DosyaAdi: string;
  _DosyaKimlik: TKimlik;
  _ELFBaslik: PELFBaslik;
  _TamDosyaYolu, _Degiskenler,
  _DosyaUzanti: string;
  p1: PChar;
  _IliskiliProgram: TDosyaIliskisi;
  _AygitSurucusu: PAygitSurucusu;
begin

  GorevDegisimBayragi := 0;

  asm cli end;

  // boþ iþlem giriþi bul
  _Gorev := _Gorev^.Olustur;
  if(_Gorev = nil) then
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + ATamDosyaYolu + ' için görev oluþturulamýyor!');
    Result := nil;
    GorevDegisimBayragi := 1;
    asm sti end;
    Exit;
  end;

  // dosyayý, sürücü + dizin + dosya adý parçalarýna ayýr
  DosyaYolunuParcala(ATamDosyaYolu, _Surucu, _Dizin, _DosyaAdi);

  // dosya adýnýn uzunluðunu al
  _DosyaU := Length(_DosyaAdi);

  { TODO : .c dosyalarý ileride .ç (çalýþtýrýlabilir) olarak deðiþtirilecek. }

  // dosya uzantýsýný al
  i := Pos('.', _DosyaAdi);
  if(i > 0) then

    _DosyaUzanti := Copy(_DosyaAdi, i + 1, _DosyaU - i)
  else _DosyaUzanti := '';

  _IliskiliProgram := IliskiliProgramAl(_DosyaUzanti);

  _Degiskenler := '';
  _TamDosyaYolu := _Surucu + ':\' + _DosyaAdi;

  // dosya çalýþtýrýlabilir bir dosya deðil ise dosyanýn birlikte açýlacaðý
  // öndeðer olarak tanýmlanan programý bul
  if((_IliskiliProgram.DosyaTip = dtResim) or (_IliskiliProgram.DosyaTip = dtBelge)
    or (_IliskiliProgram.DosyaTip = dtDiger)) then
  begin

    // eðer dosya çalýþtýrýlabilir deðil ise dosyayý, öndeðer olarak tanýmlanan
    // program ile çalýþtýr
    _Degiskenler := _Surucu + ':\' + _DosyaAdi;     // çalýþtýrýlacak dosya
    _DosyaAdi := _IliskiliProgram.Uygulama;         // çalýþtýrýlacak dosyayý çalýþtýracak program
    _TamDosyaYolu := AcilisSurucuAygiti + ':\' + _DosyaAdi;
  end;

  // çalýþtýrýlacak dosyayý tanýmla ve aç
  AssignFile(_DosyaKimlik, _TamDosyaYolu);
  Reset(_DosyaKimlik);
  if(IOResult = 0) then
  begin

    // dosya uzunluðunu al
    _DosyaU := FileSize(_DosyaKimlik);

    // dosyanýn çalýþtýrýlmasý için bellekte yer rezerv et
    _DosyaBellek := GGercekBellek.Ayir(_DosyaU + PROGRAM_YIGIN_BELLEK);
    if(_DosyaBellek = nil) then
    begin

      SISTEM_MESAJ_YAZI('GOREV.PAS: ' + ATamDosyaYolu + ' için yeterli bellek yok!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // dosyayý hedef adrese kopyala
    if(Read(_DosyaKimlik, _DosyaBellek) = 0) then
    begin

      // dosyayý kapat
      CloseFile(_DosyaKimlik);
      SISTEM_MESAJ_YAZI('GOREV.PAS: ' + _TamDosyaYolu + ' dosyasý okunamýyor!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // dosyayý kapat
    CloseFile(_DosyaKimlik);

    // ELF biçimindeki dosyanýn baþ tarafýna konumlan
    _ELFBaslik := _DosyaBellek;

    // aygýt sürücüsü çalýþmalarý - test - 31012019
    // testsrc.s çalýþtýrýlabilir aygýt sürücüsü dosyasý çalýþmalar devam etmektedir
    if(_IliskiliProgram.DosyaTip = dtSurucu) then
    begin

      _AygitSurucusu := PAygitSurucusu(_DosyaBellek + PSayi4(_DosyaBellek + $100 + 8)^);
      SISTEM_MESAJ_YAZI('Aygýt sürücüsü / açýklama');
      SISTEM_MESAJ_YAZI(_AygitSurucusu^.AygitAdi);
      SISTEM_MESAJ_YAZI(_AygitSurucusu^.Aciklama);
      SISTEM_MESAJ_S16('Deðer-1: ', _AygitSurucusu^.Deger1, 8);
      SISTEM_MESAJ_S16('Deðer-2: ', _AygitSurucusu^.Deger2, 8);
      SISTEM_MESAJ_S16('Deðer-3: ', _AygitSurucusu^.Deger3, 8);
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // olay iþlemleri için bellekte yer ayýr
    _OlayKayit := POlayKayit(GGercekBellek.Ayir(4096));
    if(_OlayKayit = nil) then
    begin

      SISTEM_MESAJ_YAZI('GOREV.PAS: olay bilgisi için bellek ayrýlamýyor!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // bellek baþlangýç adresi
    _Gorev^.FBellekBaslangicAdresi := TSayi4(_DosyaBellek);

    // bellek miktarý
    _Gorev^.FBellekUzunlugu := _DosyaU + PROGRAM_YIGIN_BELLEK;

    // iþlem baþlangýç adresi
    _Gorev^.FKodBaslangicAdres := _ELFBaslik^.KodBaslangicAdresi;

    // iþlemin yýðýn adresi
    _Gorev^.FYiginBaslangicAdres := (_DosyaU + PROGRAM_YIGIN_BELLEK) - 1024;

    // dosyanýn çalýþtýrýlmasý için seçicileri oluþtur
    _Gorev^.SecicileriOlustur;

    // görev deðiþim sayacýný sýfýrla
    _Gorev^.FGorevSayaci := 0;

    // görev olay sayacýný sýfýrla
    _Gorev^.FOlaySayisi := 0;

    // iþlemin olay bellek bölgesini ata
    _Gorev^.FOlayBellekAdresi := _OlayKayit;

    // iþlemin adý
    _Gorev^.FProgramAdi := _DosyaAdi;

    // deðiþken gönderimi
    // ilk deðiþken - çalýþan iþlemin adý
    PSayi4(_DosyaBellek)^ := 0;
    p1 := PChar(_DosyaBellek + 4);
    Tasi2(@_TamDosyaYolu[1], p1, Length(_TamDosyaYolu));
    p1 += Length(_TamDosyaYolu);
    p1^ := #0;

    // eðer varsa ikinci deðiþken - çalýþan programýn kullanacaðý deðer
    if(_Degiskenler <> '') then
    begin

      PSayi4(_DosyaBellek)^ := 1;
      Inc(p1);
      Tasi2(@_Degiskenler[1], p1, Length(_Degiskenler));
      p1 += Length(_Degiskenler);
      p1^ := #0;
    end;

    // görevin durumunu çalýþýyor olarak belirle
    _Gorev^.FGorevDurum := gdCalisiyor;

    // görev iþlem sayýsýný bir artýr
    Inc(CalisanGorevSayisi);

    // görev bellek adresini geri döndür
    Result := @Self;

    GorevDegisimBayragi := 1;

    asm sti end;
  end
  else
  begin

    CloseFile(_DosyaKimlik);
    _Gorev^.DurumDegistir(_Gorev^.GorevKimlik, gdBos);
    GorevDegisimBayragi := 1;
    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + _TamDosyaYolu + ' dosyasý bulunamadý!');
    asm sti end;
  end;
end;

{==============================================================================
  çalýþacak görev için boþ görev bul
 ==============================================================================}
function TGorev.Olustur: PGorev;
var
  _Gorev: PGorev;
begin

  // boþ iþlem giriþi bul
  _Gorev := _Gorev^.BosGorevBul;

  Result := _Gorev;
end;

{==============================================================================
  çalýþacak görev için boþ görev bul
 ==============================================================================}
function TGorev.BosGorevBul: PGorev;
var
  _Gorev: PGorev;
  i: TSayi4;
begin

  // tüm iþlem giriþlerini incele
  for i := 2 to USTSINIR_GOREVSAYISI do
  begin

    _Gorev := GorevListesi[i];

    // eðer görev giriþi boþ ise
    if(_Gorev^.FGorevDurum = gdBos) then
    begin

      // görev giriþini ayrýlmýþ olarak iþaretle ve çaðýran iþleve geri dön
      _Gorev^.DurumDegistir(i, gdOlusturuldu);
      Exit(_Gorev);
    end;
  end;

  Result := nil;
end;

{==============================================================================
  görev için TSS seçicilerini (selektör) oluþturur
 ==============================================================================}
procedure TGorev.SecicileriOlustur;
var
  _SeciciCSSiraNo, _SeciciDSSiraNo,
  _SeciciTSSSiraNo: TGorevKimlik;
  _Uzunluk, i: TSayi4;
begin

  i := GorevKimlik;

  _Uzunluk := FBellekUzunlugu shr 12;

  // uygulamanýn TSS, CS, DS seçicilerini belirle
  // uygulamanýn ilk görev kimliði 2'dir. her bir program 3 seçici içerir
  _SeciciCSSiraNo := ((i - 2) * 3) + AYRILMIS_SECICISAYISI;
  _SeciciDSSiraNo := _SeciciCSSiraNo + 1;
  _SeciciTSSSiraNo := _SeciciDSSiraNo + 1;

  // uygulama için CS selektörünü oluþtur
  // access = p, dpl3, 1, 1, conforming, readable, accessed
  // gran = gran = 1, default = 1, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciCSSiraNo, FBellekBaslangicAdresi, _Uzunluk, $FA, $D0);

  // uygulama için DS selektörünü oluþtur
  // access = p, dpl3, 1, 0, exp direction, writable, accessed
  // gran = gran = 1, big = 1, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciDSSiraNo, FBellekBaslangicAdresi, _Uzunluk, $F2, $D0);

  // uygulama için TSS selektörünü oluþtur
  // access = p, dpl3, 0, 1, 0, 0 (non_busy), 1
  // gran = g = 0, 0, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciTSSSiraNo, TSayi4(@GorevTSSListesi[i]), SizeOf(TTSS) - 1,
    $E9, $10);

  // TSS'nin içeriðini sýfýrla
  FillByte(GorevTSSListesi[i], SizeOf(TTSS), 0);

  // TSS içeriðini doldur
  //GorevTSSListesi[i].CR3 := GERCEKBELLEK_DIZINADRESI;
  GorevTSSListesi[i].EIP := FKodBaslangicAdres;
  GorevTSSListesi[i].EFLAGS := $202;
  GorevTSSListesi[i].ESP := FYiginBaslangicAdres;
  GorevTSSListesi[i].CS := (_SeciciCSSiraNo * 8) + 3;
  GorevTSSListesi[i].DS := (_SeciciDSSiraNo * 8) + 3;
  GorevTSSListesi[i].ES := (_SeciciDSSiraNo * 8) + 3;
  GorevTSSListesi[i].SS := (_SeciciDSSiraNo * 8) + 3;
  GorevTSSListesi[i].FS := (_SeciciDSSiraNo * 8) + 3;
  GorevTSSListesi[i].GS := (_SeciciDSSiraNo * 8) + 3;
  GorevTSSListesi[i].SS0 := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[i].ESP0 := (i * GOREV3_ESP_U) + GOREV3_ESP;
end;

{==============================================================================
  iþlemin yeni çalýþma durumunu belirler
 ==============================================================================}
procedure TGorev.DurumDegistir(AGorevKimlik: TGorevKimlik; AGorevDurum: TGorevDurum);
var
  _Gorev: PGorev;
begin

  _Gorev := GorevListesi[AGorevKimlik];
  if(AGorevDurum <> _Gorev^.FGorevDurum) then _Gorev^.FGorevDurum := AGorevDurum;
end;

{==============================================================================
  görev sayacýný belirler
 ==============================================================================}
procedure TGorev.GorevSayaciYaz(ASayacDegeri: TSayi4);
begin

  if(ASayacDegeri <> FGorevSayaci) then FGorevSayaci := ASayacDegeri;
end;

{==============================================================================
  görevin olay sayýsýný belirler
 ==============================================================================}
procedure TGorev.OlaySayisiYaz(AOlaySayisi: TSayi4);
begin

  if(AOlaySayisi <> FOlaySayisi) then FOlaySayisi := AOlaySayisi;
end;

{==============================================================================
  çekirdek tarafýndan görev için oluþturulan olayý kaydeder
  not: bu iþlev görsel nesneler içindir
 ==============================================================================}
procedure TGorev.OlayEkle1(AGorevKimlik: TGorevKimlik; AGorselNesne: PGorselNesne;
  AOlay, ADeger1, ADeger2: TISayi4);
var
  _Gorev: PGorev;
  _OlayKayit: POlayKayit;
begin

  _Gorev := GorevListesi[AGorevKimlik];

  if(_Gorev^.FGorevDurum = gdCalisiyor) then
  begin

    // olay belleði dolu deðilse olayý kaydet
    if(_Gorev^.FOlaySayisi < USTSINIR_OLAY) then
    begin

      // iþlemin olay belleðine konumlan
      _OlayKayit := _Gorev^.FOlayBellekAdresi;
      Inc(_OlayKayit, _Gorev^.FOlaySayisi);

      // olayý iþlem belleðine kaydet
      _OlayKayit^.Kimlik := AGorselNesne^.Kimlik;
      _OlayKayit^.Olay := AOlay;
      _OlayKayit^.Deger1 := ADeger1;
      _OlayKayit^.Deger2 := ADeger2;

      // görevin olay sayacýný artýr
      _Gorev^.FOlaySayisi := _Gorev^.FOlaySayisi + 1;
    end;
  end;
end;

{==============================================================================
  çekirdek tarafýndan görev için oluþturulan olayý kaydeder
  not: bu iþlev görsel olmayan nesneler içindir
 ==============================================================================}
procedure TGorev.OlayEkle2(AGorevKimlik: TGorevKimlik; AOlayKayit: TOlayKayit);
var
  _Gorev: PGorev;
  _OlayKayit: POlayKayit;
begin

  _Gorev := GorevListesi[AGorevKimlik];

  if(_Gorev^.FGorevDurum = gdCalisiyor) then
  begin

    // olay belleði dolu deðilse olayý kaydet
    if(_Gorev^.OlaySayisi < USTSINIR_OLAY) then
    begin

      // iþlemin olay belleðine konumlan
      _OlayKayit := _Gorev^.EvBuffer;
      Inc(_OlayKayit, _Gorev^.OlaySayisi);

      // olayý iþlem belleðine kaydet
      _OlayKayit^.Kimlik := AOlayKayit.Kimlik;
      _OlayKayit^.Olay := AOlayKayit.Olay;
      _OlayKayit^.Deger1 := AOlayKayit.Deger1;
      _OlayKayit^.Deger2 := AOlayKayit.Deger2;

      // görevin olay sayacýný artýr
      _Gorev^.OlaySayisi := _Gorev^.OlaySayisi + 1;
    end;
  end;
end;

{==============================================================================
  görev için (çekirdek tarafýndan) oluþturulan olayý alýr
 ==============================================================================}
function TGorev.OlayAl(var AOlay: TOlayKayit): Boolean;
var
  _OlayKayit1, _OlayKayit2: POlayKayit;
begin

  // öndeðer çýkýþ deðeri
  Result := False;

  // görev için oluþturulan olay yoksa çýk
  if(OlaySayisi = 0) then Exit;

  // öndeðer çýkýþ deðeri
  Result := True;

  // görevin olay belleðine konumlan
  _OlayKayit1 := EvBuffer;

  // olaylarý hedef alana kopyala
  AOlay.Olay := _OlayKayit1^.Olay;
  AOlay.Kimlik := _OlayKayit1^.Kimlik;
  AOlay.Deger1 := _OlayKayit1^.Deger1;
  AOlay.Deger2 := _OlayKayit1^.Deger2;

  // görevin olay sayacýný azalt
  OlaySayisi := OlaySayisi - 1;

  // tek bir olay var ise olay belleðini güncellemeye gerek yok
  if(OlaySayisi = 0) then Exit;

  // olayý görevin olay belleðinden sil
  _OlayKayit2 := _OlayKayit1;
  Inc(_OlayKayit2);

  Tasi2(_OlayKayit2, _OlayKayit1, SizeOf(TOlayKayit) * OlaySayisi);
end;

{==============================================================================
  çalýþan görevi sonlandýrýr
 ==============================================================================}
function TGorev.Sonlandir(AGorevKimlik: TGorevKimlik;
  const ASonlanmaSebebi: TISayi4 = -1): TISayi4;
var
  _Gorev: PGorev;
begin

  GorevDegisimBayragi := 0;

  //cli;

  // çalýþan görevi durdur
  _Gorev^.DurumDegistir(AGorevKimlik, gdDurduruldu);

  // görevin sonlandýrýlma bilgisini ver
  if(ASonlanmaSebebi = -1) then
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + GorevListesi[AGorevKimlik]^.FProgramAdi +
      ' normal bir þekilde sonlandýrýldý.');
  end
  else
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + GorevListesi[AGorevKimlik]^.FProgramAdi +
      ' programý sonlandýrýldý');
    SISTEM_MESAJ_YAZI('GOREV.PAS: Hata Kodu: ' + IntToStr(ASonlanmaSebebi) + ' - ' +
      IstisnaAciklamaListesi[ASonlanmaSebebi]);
  end;

  // göreve ait zamanlayýcýlarý yok et
  ZamanlayicilariYokEt(AGorevKimlik);

  { TODO : Görsel olmayan nesnelerin bellekten atýlmasýnda (TGorev.Sonlandir)
    görsel iþlevlerin çalýþmamasý saðlanacak }

  // göreve ait görsel nesneleri yok et
  GorevGorselNesneleriniYokEt(AGorevKimlik);

  // göreve ait olay bellek bölgesini iptal et
  GGercekBellek.YokEt(EvBuffer, 4096);

  // görev için ayrýlan bellek bölgesini serbest býrak
  GGercekBellek.YokEt(Isaretci(BellekBaslangicAdresi), FBellekUzunlugu +
    PROGRAM_YIGIN_BELLEK);

  // görevi iþlem listesinden çýkart
  DurumDegistir(AGorevKimlik, gdBos);

  // görev sayýsýný bir azalt
  Dec(CalisanGorevSayisi);

  GAktifMasaustu^.Guncelle;

  //sti;

  //asm jmp SistemAnaKontrol; end;

  GorevDegisimBayragi := 1;
end;

{==============================================================================
  görev ile ilgili bellek bölgesini geri döndürür
 ==============================================================================}
function GorevBilgisiAl(AGorevSiraNo: TISayi4): PGorev;
var
  i, j: TISayi4;
begin

  // aranacak görev sýra numarasý
  j := 0;

  // tüm iþlem bellek bölgelerini araþtýr
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    // görev boþ deðil ise görev sýra numarasýný bir artýr
    if not(GorevListesi[i]^.FGorevDurum = gdBos) then Inc(j);

    // görev sýra no aranan görev ise iþlem bellek bölgesini geri döndür
    if(AGorevSiraNo = j) then Exit(GorevListesi[i]);
  end;

  Result := nil;
end;

{==============================================================================
  görev bellek sýra numarasýný geri döndürür
 ==============================================================================}
function GorevSiraNumarasiniAl(AGorevSiraNo: TISayi4): TGorevKimlik;
var
  i, j: TISayi4;
begin

  // aranacak görev sýra numarasý
  j := 0;

  // tüm iþlem bellek bölgelerini araþtýr
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    // görev çalýþýyor ise görev sýra numarasýný bir artýr
    if(GorevListesi[i]^.FGorevDurum = gdCalisiyor) then Inc(j);

    // görev sýra no aranan görev ise iþlem bellek bölgesini geri döndür
    if(AGorevSiraNo = j) then Exit(i);
  end;

  Result := 0;
end;

{==============================================================================
  çalýþtýrýlacak bir sonraki görevi bulur
 ==============================================================================}
function CalistirilacakBirSonrakiGoreviBul: TGorevKimlik;
var
  _GorevKimlik: TGorevKimlik;
  i: TISayi4;
begin

  // çalýþan göreve konumlan
  _GorevKimlik := CalisanGorev;

  // bir sonraki görevden itibaren tüm görevleri incele
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    Inc(_GorevKimlik);
    if(_GorevKimlik > CalisanGorevSayisi) then _GorevKimlik := 1;

    // çalýþan görev aranan görev ise çaðýran iþleve geri dön
    if(GorevListesi[_GorevKimlik]^.FGorevDurum = gdCalisiyor) then Break;
  end;

  Result := _GorevKimlik;
end;

{==============================================================================
  dosya uzantýsý ile iliþkili program adýný geri döndürür
 ==============================================================================}
function IliskiliProgramAl(ADosyaUzanti: string): TDosyaIliskisi;
var
  i: TSayi4;
begin

  // dosyalarla iliþkilendirilen öndeðer program
  Result.Uzanti := ADosyaUzanti;
  Result.Uygulama := IliskiliUygulamaListesi[0].Uygulama;
  Result.DosyaTip := IliskiliUygulamaListesi[0].DosyaTip;

  for i := 1 to ILISKILI_UYGULAMA_SAYISI - 1 do
  begin

    if(IliskiliUygulamaListesi[i].Uzanti = ADosyaUzanti) then
    begin

      Result.Uzanti := IliskiliUygulamaListesi[i].Uzanti;
      Result.Uygulama := IliskiliUygulamaListesi[i].Uygulama;
      Result.DosyaTip := IliskiliUygulamaListesi[i].DosyaTip;
      Exit;
    end;
  end;
end;

end.
