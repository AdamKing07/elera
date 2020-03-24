{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gorev.pas
  Dosya ��levi: g�rev (program) y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 23/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gorev;

interface

uses paylasim, gorselnesne;

const
  // bir g�rev i�in tan�mlanan �st s�n�r olay say�s�
  // olay belle�i 4K olarak tan�mlanm��t�r. 4096 / SizeOf(TOlay)
  USTSINIR_OLAY         = 64;
  PROGRAM_YIGIN_BELLEK  = 4096 * 4;    // program y���n� (stack) i�in ayr�lacak bellek

type
  TDosyaTip = (dtDiger, dtCalistirilabilir, dtSurucu, dtResim, dtBelge);

type
  TDosyaIliskisi = record
    Uzanti: string[5];            // ili�ki kurulacak dosya uzant�s�
    Uygulama: string[30];         // uzant�n�n ili�kili oldu�u program ad�
    DosyaTip: TDosyaTip;          // uzant�n�n ili�kili oldu�u dosya tipi
  end;

type
  PGorev = ^TGorev;
  TGorev = object
  private
    FBellekUzunlugu: TSayi4;              // i�lemin kulland��� bellek uzunlu�u
    FKodBaslangicAdres: TSayi4;           // i�lemin bellek ba�lang�� adresi
    FYiginBaslangicAdres: TSayi4;         // i�lemin y���n adresi
    FOlaySayisi: TSayi4;                  // olay sayac�
    FOlayBellekAdresi: POlayKayit;        // olaylar�n yerle�tirilece�i bellek b�lgesi
    procedure GorevSayaciYaz(ASayacDegeri: TSayi4);
    procedure OlaySayisiYaz(AOlaySayisi: TSayi4);
  protected
    function Olustur: PGorev;
    function BosGorevBul: PGorev;
    procedure SecicileriOlustur;
  public
    FGorevKimlik: TGorevKimlik;           // i�lem numaras�
    FGorevDurum: TGorevDurum;             // i�lem durumu
    FGorevSayaci: TSayi4;                 // g�rev de�i�im sayac�
    FBellekBaslangicAdresi: TSayi4;       // i�lemin y�klendi�i bellek adresi
    FProgramAdi: string;                  // i�lem ad�
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
    ('S�f�ra B�lme Hatas�'),
    ('Hata Ay�klama'),
    ('Engellenemeyen Kesme'),
    ('Durma Noktas�'),
    ('Ta�ma Hatas�'),
    ('Dizi Aral��� A�ma Hatas�'),
    ('Hatal� ��lemci Kodu'),
    ('Matematik ��lemci Mevcut De�il'),
    ('�ifte Hata'),
    ('Matematik ��lemci Yazma� Hatas�'),
    ('Hatal� TSS Giri�i'),
    ('Yazma� Mevcut De�il'),
    ('Y���n Hatas�'),
    ('Genel Koruma Hatas�'),
    ('Sayfa Hatas�'),
    ('Hata No: 15 - Tan�mlanmam��'));

const
  ILISKILI_UYGULAMA_SAYISI = 5;
  IliskiliUygulamaListesi: array[0..ILISKILI_UYGULAMA_SAYISI - 1] of TDosyaIliskisi = (
    (Uzanti: '';     Uygulama: 'dsybil.c';     DosyaTip: dtDiger),
    (Uzanti: 'c';    Uygulama: '';             DosyaTip: dtCalistirilabilir),
    (Uzanti: 's';    Uygulama: '';             DosyaTip: dtSurucu),
    (Uzanti: 'bmp';  Uygulama: 'resimgor.c';   DosyaTip: dtResim),
    (Uzanti: 'txt';  Uygulama: 'defter.c';     DosyaTip: dtBelge));

{==============================================================================
  �al��t�r�lacak g�revlerin ana y�kleme i�levlerini i�erir
 ==============================================================================}
procedure TGorev.Yukle;
var
  _Gorev: PGorev;
  i: TISayi4;
begin

  // g�rev bilgilerinin yerle�tirilmesi i�in bellek ay�r
  _Gorev := GGercekBellek.Ayir(SizeOf(TGorev) * USTSINIR_GOREVSAYISI);

  // bellek giri�lerini g�rev yap�lar�yla e�le�tir
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    GorevListesi[i] := _Gorev;

    // g�revi bo� olarak belirle
    _Gorev^.FGorevDurum := gdBos;
    _Gorev^.FGorevKimlik := i;

    Inc(_Gorev);
  end;
end;

{==============================================================================
  g�rev (program) dosyalar�n� �al��t�r�r
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

  // bo� i�lem giri�i bul
  _Gorev := _Gorev^.Olustur;
  if(_Gorev = nil) then
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + ATamDosyaYolu + ' i�in g�rev olu�turulam�yor!');
    Result := nil;
    GorevDegisimBayragi := 1;
    asm sti end;
    Exit;
  end;

  // dosyay�, s�r�c� + dizin + dosya ad� par�alar�na ay�r
  DosyaYolunuParcala(ATamDosyaYolu, _Surucu, _Dizin, _DosyaAdi);

  // dosya ad�n�n uzunlu�unu al
  _DosyaU := Length(_DosyaAdi);

  { TODO : .c dosyalar� ileride .� (�al��t�r�labilir) olarak de�i�tirilecek. }

  // dosya uzant�s�n� al
  i := Pos('.', _DosyaAdi);
  if(i > 0) then

    _DosyaUzanti := Copy(_DosyaAdi, i + 1, _DosyaU - i)
  else _DosyaUzanti := '';

  _IliskiliProgram := IliskiliProgramAl(_DosyaUzanti);

  _Degiskenler := '';
  _TamDosyaYolu := _Surucu + ':\' + _DosyaAdi;

  // dosya �al��t�r�labilir bir dosya de�il ise dosyan�n birlikte a��laca��
  // �nde�er olarak tan�mlanan program� bul
  if((_IliskiliProgram.DosyaTip = dtResim) or (_IliskiliProgram.DosyaTip = dtBelge)
    or (_IliskiliProgram.DosyaTip = dtDiger)) then
  begin

    // e�er dosya �al��t�r�labilir de�il ise dosyay�, �nde�er olarak tan�mlanan
    // program ile �al��t�r
    _Degiskenler := _Surucu + ':\' + _DosyaAdi;     // �al��t�r�lacak dosya
    _DosyaAdi := _IliskiliProgram.Uygulama;         // �al��t�r�lacak dosyay� �al��t�racak program
    _TamDosyaYolu := AcilisSurucuAygiti + ':\' + _DosyaAdi;
  end;

  // �al��t�r�lacak dosyay� tan�mla ve a�
  AssignFile(_DosyaKimlik, _TamDosyaYolu);
  Reset(_DosyaKimlik);
  if(IOResult = 0) then
  begin

    // dosya uzunlu�unu al
    _DosyaU := FileSize(_DosyaKimlik);

    // dosyan�n �al��t�r�lmas� i�in bellekte yer rezerv et
    _DosyaBellek := GGercekBellek.Ayir(_DosyaU + PROGRAM_YIGIN_BELLEK);
    if(_DosyaBellek = nil) then
    begin

      SISTEM_MESAJ_YAZI('GOREV.PAS: ' + ATamDosyaYolu + ' i�in yeterli bellek yok!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // dosyay� hedef adrese kopyala
    if(Read(_DosyaKimlik, _DosyaBellek) = 0) then
    begin

      // dosyay� kapat
      CloseFile(_DosyaKimlik);
      SISTEM_MESAJ_YAZI('GOREV.PAS: ' + _TamDosyaYolu + ' dosyas� okunam�yor!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // dosyay� kapat
    CloseFile(_DosyaKimlik);

    // ELF bi�imindeki dosyan�n ba� taraf�na konumlan
    _ELFBaslik := _DosyaBellek;

    // ayg�t s�r�c�s� �al��malar� - test - 31012019
    // testsrc.s �al��t�r�labilir ayg�t s�r�c�s� dosyas� �al��malar devam etmektedir
    if(_IliskiliProgram.DosyaTip = dtSurucu) then
    begin

      _AygitSurucusu := PAygitSurucusu(_DosyaBellek + PSayi4(_DosyaBellek + $100 + 8)^);
      SISTEM_MESAJ_YAZI('Ayg�t s�r�c�s� / a��klama');
      SISTEM_MESAJ_YAZI(_AygitSurucusu^.AygitAdi);
      SISTEM_MESAJ_YAZI(_AygitSurucusu^.Aciklama);
      SISTEM_MESAJ_S16('De�er-1: ', _AygitSurucusu^.Deger1, 8);
      SISTEM_MESAJ_S16('De�er-2: ', _AygitSurucusu^.Deger2, 8);
      SISTEM_MESAJ_S16('De�er-3: ', _AygitSurucusu^.Deger3, 8);
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // olay i�lemleri i�in bellekte yer ay�r
    _OlayKayit := POlayKayit(GGercekBellek.Ayir(4096));
    if(_OlayKayit = nil) then
    begin

      SISTEM_MESAJ_YAZI('GOREV.PAS: olay bilgisi i�in bellek ayr�lam�yor!');
      Result := nil;
      GorevDegisimBayragi := 1;
      asm sti end;
      Exit;
    end;

    // bellek ba�lang�� adresi
    _Gorev^.FBellekBaslangicAdresi := TSayi4(_DosyaBellek);

    // bellek miktar�
    _Gorev^.FBellekUzunlugu := _DosyaU + PROGRAM_YIGIN_BELLEK;

    // i�lem ba�lang�� adresi
    _Gorev^.FKodBaslangicAdres := _ELFBaslik^.KodBaslangicAdresi;

    // i�lemin y���n adresi
    _Gorev^.FYiginBaslangicAdres := (_DosyaU + PROGRAM_YIGIN_BELLEK) - 1024;

    // dosyan�n �al��t�r�lmas� i�in se�icileri olu�tur
    _Gorev^.SecicileriOlustur;

    // g�rev de�i�im sayac�n� s�f�rla
    _Gorev^.FGorevSayaci := 0;

    // g�rev olay sayac�n� s�f�rla
    _Gorev^.FOlaySayisi := 0;

    // i�lemin olay bellek b�lgesini ata
    _Gorev^.FOlayBellekAdresi := _OlayKayit;

    // i�lemin ad�
    _Gorev^.FProgramAdi := _DosyaAdi;

    // de�i�ken g�nderimi
    // ilk de�i�ken - �al��an i�lemin ad�
    PSayi4(_DosyaBellek)^ := 0;
    p1 := PChar(_DosyaBellek + 4);
    Tasi2(@_TamDosyaYolu[1], p1, Length(_TamDosyaYolu));
    p1 += Length(_TamDosyaYolu);
    p1^ := #0;

    // e�er varsa ikinci de�i�ken - �al��an program�n kullanaca�� de�er
    if(_Degiskenler <> '') then
    begin

      PSayi4(_DosyaBellek)^ := 1;
      Inc(p1);
      Tasi2(@_Degiskenler[1], p1, Length(_Degiskenler));
      p1 += Length(_Degiskenler);
      p1^ := #0;
    end;

    // g�revin durumunu �al���yor olarak belirle
    _Gorev^.FGorevDurum := gdCalisiyor;

    // g�rev i�lem say�s�n� bir art�r
    Inc(CalisanGorevSayisi);

    // g�rev bellek adresini geri d�nd�r
    Result := @Self;

    GorevDegisimBayragi := 1;

    asm sti end;
  end
  else
  begin

    CloseFile(_DosyaKimlik);
    _Gorev^.DurumDegistir(_Gorev^.GorevKimlik, gdBos);
    GorevDegisimBayragi := 1;
    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + _TamDosyaYolu + ' dosyas� bulunamad�!');
    asm sti end;
  end;
end;

{==============================================================================
  �al��acak g�rev i�in bo� g�rev bul
 ==============================================================================}
function TGorev.Olustur: PGorev;
var
  _Gorev: PGorev;
begin

  // bo� i�lem giri�i bul
  _Gorev := _Gorev^.BosGorevBul;

  Result := _Gorev;
end;

{==============================================================================
  �al��acak g�rev i�in bo� g�rev bul
 ==============================================================================}
function TGorev.BosGorevBul: PGorev;
var
  _Gorev: PGorev;
  i: TSayi4;
begin

  // t�m i�lem giri�lerini incele
  for i := 2 to USTSINIR_GOREVSAYISI do
  begin

    _Gorev := GorevListesi[i];

    // e�er g�rev giri�i bo� ise
    if(_Gorev^.FGorevDurum = gdBos) then
    begin

      // g�rev giri�ini ayr�lm�� olarak i�aretle ve �a��ran i�leve geri d�n
      _Gorev^.DurumDegistir(i, gdOlusturuldu);
      Exit(_Gorev);
    end;
  end;

  Result := nil;
end;

{==============================================================================
  g�rev i�in TSS se�icilerini (selekt�r) olu�turur
 ==============================================================================}
procedure TGorev.SecicileriOlustur;
var
  _SeciciCSSiraNo, _SeciciDSSiraNo,
  _SeciciTSSSiraNo: TGorevKimlik;
  _Uzunluk, i: TSayi4;
begin

  i := GorevKimlik;

  _Uzunluk := FBellekUzunlugu shr 12;

  // uygulaman�n TSS, CS, DS se�icilerini belirle
  // uygulaman�n ilk g�rev kimli�i 2'dir. her bir program 3 se�ici i�erir
  _SeciciCSSiraNo := ((i - 2) * 3) + AYRILMIS_SECICISAYISI;
  _SeciciDSSiraNo := _SeciciCSSiraNo + 1;
  _SeciciTSSSiraNo := _SeciciDSSiraNo + 1;

  // uygulama i�in CS selekt�r�n� olu�tur
  // access = p, dpl3, 1, 1, conforming, readable, accessed
  // gran = gran = 1, default = 1, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciCSSiraNo, FBellekBaslangicAdresi, _Uzunluk, $FA, $D0);

  // uygulama i�in DS selekt�r�n� olu�tur
  // access = p, dpl3, 1, 0, exp direction, writable, accessed
  // gran = gran = 1, big = 1, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciDSSiraNo, FBellekBaslangicAdresi, _Uzunluk, $F2, $D0);

  // uygulama i�in TSS selekt�r�n� olu�tur
  // access = p, dpl3, 0, 1, 0, 0 (non_busy), 1
  // gran = g = 0, 0, 0, avl = 1, _Uzunluk (4 bit)
  GDTRGirdisiEkle(_SeciciTSSSiraNo, TSayi4(@GorevTSSListesi[i]), SizeOf(TTSS) - 1,
    $E9, $10);

  // TSS'nin i�eri�ini s�f�rla
  FillByte(GorevTSSListesi[i], SizeOf(TTSS), 0);

  // TSS i�eri�ini doldur
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
  i�lemin yeni �al��ma durumunu belirler
 ==============================================================================}
procedure TGorev.DurumDegistir(AGorevKimlik: TGorevKimlik; AGorevDurum: TGorevDurum);
var
  _Gorev: PGorev;
begin

  _Gorev := GorevListesi[AGorevKimlik];
  if(AGorevDurum <> _Gorev^.FGorevDurum) then _Gorev^.FGorevDurum := AGorevDurum;
end;

{==============================================================================
  g�rev sayac�n� belirler
 ==============================================================================}
procedure TGorev.GorevSayaciYaz(ASayacDegeri: TSayi4);
begin

  if(ASayacDegeri <> FGorevSayaci) then FGorevSayaci := ASayacDegeri;
end;

{==============================================================================
  g�revin olay say�s�n� belirler
 ==============================================================================}
procedure TGorev.OlaySayisiYaz(AOlaySayisi: TSayi4);
begin

  if(AOlaySayisi <> FOlaySayisi) then FOlaySayisi := AOlaySayisi;
end;

{==============================================================================
  �ekirdek taraf�ndan g�rev i�in olu�turulan olay� kaydeder
  not: bu i�lev g�rsel nesneler i�indir
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

    // olay belle�i dolu de�ilse olay� kaydet
    if(_Gorev^.FOlaySayisi < USTSINIR_OLAY) then
    begin

      // i�lemin olay belle�ine konumlan
      _OlayKayit := _Gorev^.FOlayBellekAdresi;
      Inc(_OlayKayit, _Gorev^.FOlaySayisi);

      // olay� i�lem belle�ine kaydet
      _OlayKayit^.Kimlik := AGorselNesne^.Kimlik;
      _OlayKayit^.Olay := AOlay;
      _OlayKayit^.Deger1 := ADeger1;
      _OlayKayit^.Deger2 := ADeger2;

      // g�revin olay sayac�n� art�r
      _Gorev^.FOlaySayisi := _Gorev^.FOlaySayisi + 1;
    end;
  end;
end;

{==============================================================================
  �ekirdek taraf�ndan g�rev i�in olu�turulan olay� kaydeder
  not: bu i�lev g�rsel olmayan nesneler i�indir
 ==============================================================================}
procedure TGorev.OlayEkle2(AGorevKimlik: TGorevKimlik; AOlayKayit: TOlayKayit);
var
  _Gorev: PGorev;
  _OlayKayit: POlayKayit;
begin

  _Gorev := GorevListesi[AGorevKimlik];

  if(_Gorev^.FGorevDurum = gdCalisiyor) then
  begin

    // olay belle�i dolu de�ilse olay� kaydet
    if(_Gorev^.OlaySayisi < USTSINIR_OLAY) then
    begin

      // i�lemin olay belle�ine konumlan
      _OlayKayit := _Gorev^.EvBuffer;
      Inc(_OlayKayit, _Gorev^.OlaySayisi);

      // olay� i�lem belle�ine kaydet
      _OlayKayit^.Kimlik := AOlayKayit.Kimlik;
      _OlayKayit^.Olay := AOlayKayit.Olay;
      _OlayKayit^.Deger1 := AOlayKayit.Deger1;
      _OlayKayit^.Deger2 := AOlayKayit.Deger2;

      // g�revin olay sayac�n� art�r
      _Gorev^.OlaySayisi := _Gorev^.OlaySayisi + 1;
    end;
  end;
end;

{==============================================================================
  g�rev i�in (�ekirdek taraf�ndan) olu�turulan olay� al�r
 ==============================================================================}
function TGorev.OlayAl(var AOlay: TOlayKayit): Boolean;
var
  _OlayKayit1, _OlayKayit2: POlayKayit;
begin

  // �nde�er ��k�� de�eri
  Result := False;

  // g�rev i�in olu�turulan olay yoksa ��k
  if(OlaySayisi = 0) then Exit;

  // �nde�er ��k�� de�eri
  Result := True;

  // g�revin olay belle�ine konumlan
  _OlayKayit1 := EvBuffer;

  // olaylar� hedef alana kopyala
  AOlay.Olay := _OlayKayit1^.Olay;
  AOlay.Kimlik := _OlayKayit1^.Kimlik;
  AOlay.Deger1 := _OlayKayit1^.Deger1;
  AOlay.Deger2 := _OlayKayit1^.Deger2;

  // g�revin olay sayac�n� azalt
  OlaySayisi := OlaySayisi - 1;

  // tek bir olay var ise olay belle�ini g�ncellemeye gerek yok
  if(OlaySayisi = 0) then Exit;

  // olay� g�revin olay belle�inden sil
  _OlayKayit2 := _OlayKayit1;
  Inc(_OlayKayit2);

  Tasi2(_OlayKayit2, _OlayKayit1, SizeOf(TOlayKayit) * OlaySayisi);
end;

{==============================================================================
  �al��an g�revi sonland�r�r
 ==============================================================================}
function TGorev.Sonlandir(AGorevKimlik: TGorevKimlik;
  const ASonlanmaSebebi: TISayi4 = -1): TISayi4;
var
  _Gorev: PGorev;
begin

  GorevDegisimBayragi := 0;

  //cli;

  // �al��an g�revi durdur
  _Gorev^.DurumDegistir(AGorevKimlik, gdDurduruldu);

  // g�revin sonland�r�lma bilgisini ver
  if(ASonlanmaSebebi = -1) then
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + GorevListesi[AGorevKimlik]^.FProgramAdi +
      ' normal bir �ekilde sonland�r�ld�.');
  end
  else
  begin

    SISTEM_MESAJ_YAZI('GOREV.PAS: ' + GorevListesi[AGorevKimlik]^.FProgramAdi +
      ' program� sonland�r�ld�');
    SISTEM_MESAJ_YAZI('GOREV.PAS: Hata Kodu: ' + IntToStr(ASonlanmaSebebi) + ' - ' +
      IstisnaAciklamaListesi[ASonlanmaSebebi]);
  end;

  // g�reve ait zamanlay�c�lar� yok et
  ZamanlayicilariYokEt(AGorevKimlik);

  { TODO : G�rsel olmayan nesnelerin bellekten at�lmas�nda (TGorev.Sonlandir)
    g�rsel i�levlerin �al��mamas� sa�lanacak }

  // g�reve ait g�rsel nesneleri yok et
  GorevGorselNesneleriniYokEt(AGorevKimlik);

  // g�reve ait olay bellek b�lgesini iptal et
  GGercekBellek.YokEt(EvBuffer, 4096);

  // g�rev i�in ayr�lan bellek b�lgesini serbest b�rak
  GGercekBellek.YokEt(Isaretci(BellekBaslangicAdresi), FBellekUzunlugu +
    PROGRAM_YIGIN_BELLEK);

  // g�revi i�lem listesinden ��kart
  DurumDegistir(AGorevKimlik, gdBos);

  // g�rev say�s�n� bir azalt
  Dec(CalisanGorevSayisi);

  GAktifMasaustu^.Guncelle;

  //sti;

  //asm jmp SistemAnaKontrol; end;

  GorevDegisimBayragi := 1;
end;

{==============================================================================
  g�rev ile ilgili bellek b�lgesini geri d�nd�r�r
 ==============================================================================}
function GorevBilgisiAl(AGorevSiraNo: TISayi4): PGorev;
var
  i, j: TISayi4;
begin

  // aranacak g�rev s�ra numaras�
  j := 0;

  // t�m i�lem bellek b�lgelerini ara�t�r
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    // g�rev bo� de�il ise g�rev s�ra numaras�n� bir art�r
    if not(GorevListesi[i]^.FGorevDurum = gdBos) then Inc(j);

    // g�rev s�ra no aranan g�rev ise i�lem bellek b�lgesini geri d�nd�r
    if(AGorevSiraNo = j) then Exit(GorevListesi[i]);
  end;

  Result := nil;
end;

{==============================================================================
  g�rev bellek s�ra numaras�n� geri d�nd�r�r
 ==============================================================================}
function GorevSiraNumarasiniAl(AGorevSiraNo: TISayi4): TGorevKimlik;
var
  i, j: TISayi4;
begin

  // aranacak g�rev s�ra numaras�
  j := 0;

  // t�m i�lem bellek b�lgelerini ara�t�r
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    // g�rev �al���yor ise g�rev s�ra numaras�n� bir art�r
    if(GorevListesi[i]^.FGorevDurum = gdCalisiyor) then Inc(j);

    // g�rev s�ra no aranan g�rev ise i�lem bellek b�lgesini geri d�nd�r
    if(AGorevSiraNo = j) then Exit(i);
  end;

  Result := 0;
end;

{==============================================================================
  �al��t�r�lacak bir sonraki g�revi bulur
 ==============================================================================}
function CalistirilacakBirSonrakiGoreviBul: TGorevKimlik;
var
  _GorevKimlik: TGorevKimlik;
  i: TISayi4;
begin

  // �al��an g�reve konumlan
  _GorevKimlik := CalisanGorev;

  // bir sonraki g�revden itibaren t�m g�revleri incele
  for i := 1 to USTSINIR_GOREVSAYISI do
  begin

    Inc(_GorevKimlik);
    if(_GorevKimlik > CalisanGorevSayisi) then _GorevKimlik := 1;

    // �al��an g�rev aranan g�rev ise �a��ran i�leve geri d�n
    if(GorevListesi[_GorevKimlik]^.FGorevDurum = gdCalisiyor) then Break;
  end;

  Result := _GorevKimlik;
end;

{==============================================================================
  dosya uzant�s� ile ili�kili program ad�n� geri d�nd�r�r
 ==============================================================================}
function IliskiliProgramAl(ADosyaUzanti: string): TDosyaIliskisi;
var
  i: TSayi4;
begin

  // dosyalarla ili�kilendirilen �nde�er program
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
