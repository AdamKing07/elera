{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: src_vesa20.pas
  Dosya İşlevi: genel vesa 2.0 grafik kartı sürücüsü

  Güncelleme Tarihi: 13/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit src_vesa20;

interface

uses paylasim, gorselnesne, gn_pencere, gn_masaustu;

type
  PEkranKartSurucusu = ^TEkranKartSurucusu;
  TEkranKartSurucusu = object
  private
    function NoktaOku16(A1, B1: TISayi4): TRenk;
    function NoktaOku24(A1, B1: TISayi4): TRenk;
    function NoktaOku32(A1, B1: TISayi4): TRenk;
    procedure NoktaYaz16(AGorselNesne: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk;
      ARenkDonustur: Boolean);
    procedure NoktaYaz24(AGorselNesne: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk;
      AKullanilmiyor: Boolean);
    procedure NoktaYaz32(AGorselNesne: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk;
      AKullanilmiyor: Boolean);
    procedure GorselNesneleriArkaBellegeCiz;
    procedure FareGostergesiCiz;
  public
    KartBilgisi: TEkranKartBilgisi;
    procedure Yukle;
    function NoktaOku(A1, B1: TISayi4): TRenk;
    procedure NoktaYaz(AGorselNesne: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk;
      ARenkDonustur: Boolean);
    procedure EkranBelleginiGuncelle;
  end;

procedure TaniBilgileriniMasaustuneYaz;

implementation

uses genel, donusum, gn_menu, fareimlec, gdt;

var
  ArkaBellek, EkranBellegi: Isaretci;

{==============================================================================
  vesa 2.0 grafik sürücüsünün ana yükleme işlevlerini içerir
 ==============================================================================}
procedure TEkranKartSurucusu.Yukle;
begin

  // grafik
  GDTRGirdisiEkle(SECICI_SISTEM_GRAFIK, KartBilgisi.BellekAdresi, $FFFFFF, $92, $D0);

  // arka plan için bellek ayır
  ArkaBellek := GGercekBellek.Ayir(GEkranKartSurucusu.KartBilgisi.YatayCozunurluk *
    GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk * (KartBilgisi.PixelBasinaBitSayisi div 8));

  // grafik kartı video belleği
  EkranBellegi := Isaretci(KartBilgisi.BellekAdresi);
end;

{==============================================================================
  nokta okuma işlevi
 ==============================================================================}
function TEkranKartSurucusu.NoktaOku(A1, B1: TISayi4): TRenk;
begin

  if(A1 < 0) or (A1 > KartBilgisi.YatayCozunurluk - 1) then Exit(RENK_SIYAH);
  if(B1 < 0) or (B1 > KartBilgisi.DikeyCozunurluk - 1) then Exit(RENK_SIYAH);

  case KartBilgisi.PixelBasinaBitSayisi of
    16: Result := NoktaOku16(A1, B1);
    24: Result := NoktaOku24(A1, B1);
    32: Result := NoktaOku32(A1, B1);
  end;
end;

{==============================================================================
  nokta işaretleme işlevi
 ==============================================================================}
procedure TEkranKartSurucusu.NoktaYaz(AGorselNesne: PGorselNesne; A1, B1: TISayi4;
  ARenk: TRenk; ARenkDonustur: Boolean);
begin

  if not(AGorselNesne = nil) then
  begin

    if(A1 < 0) or (A1 > AGorselNesne^.FBoyutlar.Genislik2 - 1) then Exit;
    if(B1 < 0) or (B1 > AGorselNesne^.FBoyutlar.Yukseklik2 - 1) then Exit;
  end;

  case KartBilgisi.PixelBasinaBitSayisi of
    16: NoktaYaz16(AGorselNesne, A1, B1, ARenk, ARenkDonustur);
    24: NoktaYaz24(AGorselNesne, A1, B1, ARenk, ARenkDonustur);
    32: NoktaYaz32(AGorselNesne, A1, B1, ARenk, ARenkDonustur);
  end;
end;

{==============================================================================
  belirtilen koordinattaki 16 bitlik nokta renk değerini alır
 ==============================================================================}
function TEkranKartSurucusu.NoktaOku16(A1, B1: TISayi4): TRenk;
var
  _BellekAdresi: TSayi4;
begin

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * KartBilgisi.SatirdakiByteSayisi) + (A1 * 2);
  _BellekAdresi += TSayi4(ArkaBellek);

  //  noktanın renk değerini al
  Result := PRenk(_BellekAdresi)^ and $FFFF;
end;

{==============================================================================
  belirtilen koordinattaki noktayı 16 bitlik renk değeri ile işaretler
 ==============================================================================}
procedure TEkranKartSurucusu.NoktaYaz16(AGorselNesne: PGorselNesne; A1, B1: TISayi4;
  ARenk: TRenk; ARenkDonustur: Boolean);
var
  _BellekAdresi: TSayi4;
  _SatirBasinaBitSayisi: TISayi4;
  _PAdres16: PSayi2;
  _Renk16: TSayi2;
begin

  if(AGorselNesne = nil) or (AGorselNesne^.GorselNesneTipi = gntMasaustu) then
    _SatirBasinaBitSayisi := KartBilgisi.SatirdakiByteSayisi
  else _SatirBasinaBitSayisi := AGorselNesne^.FBoyutlar.Genislik2 * 2;

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * _SatirBasinaBitSayisi) + (A1 * 2);
  if(AGorselNesne = nil) then
    _BellekAdresi += TSayi4(ArkaBellek)
  else _BellekAdresi += TSayi4(AGorselNesne^.FCizimBellekAdresi);

  // eğer dönüşüm isteniyorsa 24 / 32 bitlik renk değerini
  // 16 bitlik renk değerine çevir
  if(ARenkDonustur) then

    _Renk16 := RGB24CevirRGB16(ARenk)
  else _Renk16 := (ARenk and $FFFF);

  // noktayı belirtilen renk ile işaretle
  _PAdres16 := PSayi2(_BellekAdresi);
  _PAdres16^ := _Renk16;
end;

{==============================================================================
  belirtilen koordinattaki 24 bitlik nokta renk değerini alır
 ==============================================================================}
function TEkranKartSurucusu.NoktaOku24(A1, B1: TISayi4): TRenk;
var
  _BellekAdresi: TSayi4;
begin

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * KartBilgisi.SatirdakiByteSayisi) + (A1 * 3);
  _BellekAdresi += TSayi4(ArkaBellek);

  // noktanın renk değerini al
  Result := PRenk(_BellekAdresi)^ and $FFFFFF;
end;

{==============================================================================
  belirtilen koordinattaki noktayı 24 bitlik renk değeri ile işaretler
 ==============================================================================}
procedure TEkranKartSurucusu.NoktaYaz24(AGorselNesne: PGorselNesne; A1, B1: TISayi4;
  ARenk: TRenk; AKullanilmiyor: Boolean);
var
  _BellekAdresi, _SatirBasinaBitSayisi: TISayi4;
  _PAdres8: PSayi1;
  _RGB: PRGB;
begin

  if(AGorselNesne = nil) or (AGorselNesne^.GorselNesneTipi = gntMasaustu) then
    _SatirBasinaBitSayisi := KartBilgisi.SatirdakiByteSayisi
  else _SatirBasinaBitSayisi := AGorselNesne^.FBoyutlar.Genislik2 * 3;

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * _SatirBasinaBitSayisi) + (A1 * 3);
  if(AGorselNesne = nil) then
    _BellekAdresi += TSayi4(ArkaBellek)
  else _BellekAdresi += TSayi4(AGorselNesne^.FCizimBellekAdresi);

  // noktayı belirtilen renk ile işaretle
  _PAdres8 := PByte(_BellekAdresi);
  _RGB := @ARenk;
  _PAdres8[0] := _RGB^.B;
  _PAdres8[1] := _RGB^.G;
  _PAdres8[2] := _RGB^.R;
end;

{==============================================================================
  belirtilen koordinattaki 32 bitlik nokta renk değerini alır
 ==============================================================================}
function TEkranKartSurucusu.NoktaOku32(A1, B1: TISayi4): TRenk;
var
  _BellekAdresi: TSayi4;
begin

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * KartBilgisi.SatirdakiByteSayisi) + (A1 * 4);
  _BellekAdresi += TSayi4(ArkaBellek);

  // noktanın renk değerini al
  Result := PRenk(_BellekAdresi)^;
end;

{==============================================================================
  belirtilen koordinattaki noktayı 32 bitlik renk değeri ile işaretler
 ==============================================================================}
procedure TEkranKartSurucusu.NoktaYaz32(AGorselNesne: PGorselNesne; A1, B1: TISayi4;
  ARenk: TRenk; AKullanilmiyor: Boolean);
var
  _BellekAdresi, _SatirBasinaBitSayisi: TSayi4;
begin

  if(AGorselNesne = nil) or (AGorselNesne^.GorselNesneTipi = gntMasaustu) then
    _SatirBasinaBitSayisi := KartBilgisi.SatirdakiByteSayisi
  else _SatirBasinaBitSayisi := AGorselNesne^.FBoyutlar.Genislik2 * 4;

  // belirtilen koordinata konumlan
  _BellekAdresi := (B1 * _SatirBasinaBitSayisi) + (A1 * 4);
  _BellekAdresi += TSayi4(AGorselNesne^.FCizimBellekAdresi);

  // noktayı belirtilen renk ile işaretle
  _BellekAdresi := ARenk;
end;

// arka plana çizilen görsel nesne çizimlerini ekran belleğine (grafik kart) çizer
procedure TEkranKartSurucusu.EkranBelleginiGuncelle;
var
  i: TSayi4;
begin

  // ekran belleğine taşımadan önce yapılması gereken ön işlemler

  // 1. görsel nesneleri arka belleğe çizerek arka belleği güncelleştir
  GorselNesneleriArkaBellegeCiz;

  // 2. tanı bilgilerini masaüstüne yaz
  TaniBilgileriniMasaustuneYaz;

  // 3. fare göstergesini çiz
  FareGostergesiCiz;

  // arka belleği ekran belleğine (grafik bellek) taşı
  i := KartBilgisi.YatayCozunurluk * KartBilgisi.DikeyCozunurluk *
    KartBilgisi.NoktaBasinaByteSayisi;

  { TODO : ileride 2 ve 4 byte'lık taşımalar gerçekleştirilerek hızlandırma artırılabilir }
  asm
    pushad
    mov eax,SECICI_SISTEM_GRAFIK * 8
    mov gs,ax
    mov esi,ArkaBellek
    mov edi,0
    mov ecx,i
    shr ecx,2
    @1:
    mov eax,ds:[esi]
    mov gs:[edi],eax //dword fs:[edi], 1 // EkranBellegi
    add esi,4
    add edi,4
    loop  @1
    //mov ecx,i
    //cld
    //rep movsb
    popad
  end
end;

// görsel nesne çizimlerini arka belleğe çizer
procedure TEkranKartSurucusu.GorselNesneleriArkaBellegeCiz;
var
  _Masaustu: PMasaustu;
  _Pencere: PPencere;
  _BaslatmaMenusu: PMenu;
  _PencereBellekAdresi: PPGorselNesne;
  _KaynakA1, _KaynakA2,       // nesnelerin taşınması için
  _KaynakB1, _KaynakB2,       // nesnelerin taşınması için
  _HedefA1, _HedefB1,         // nesnelerin taşınması için
  _B1, _B2, _A2, _KaynakSatirdakiByteSayisi,
  _HedefSatirdakiByteSayisi: TISayi4;
  _KaynakBellek, _HedefBellek: Isaretci;
  _NoktaBasinaByteSayisi, i, j: TSayi4;
begin

  // geçerli masaüstü yok ise çık
  _Masaustu := GAktifMasaustu;
  if(_Masaustu = nil) then Exit;

  _A2 := _Masaustu^.FBoyutlar.Genislik2;       // sütundaki toplam pixel sayısı
  _B2 := _Masaustu^.FBoyutlar.Yukseklik2;      // satırdaki toplam pixel sayısı

  _NoktaBasinaByteSayisi := KartBilgisi.NoktaBasinaByteSayisi;
  _HedefSatirdakiByteSayisi := KartBilgisi.SatirdakiByteSayisi;
  _KaynakSatirdakiByteSayisi := _A2 * _NoktaBasinaByteSayisi;

  // arka planın çizilmesi işlemi

  // 1. masaüstünün arka belleğe çizilmesi
  for _B1 := 0 to _B2 - 1 do
  begin

    _KaynakBellek := (_B1 * _KaynakSatirdakiByteSayisi) + _Masaustu^.FCizimBellekAdresi;
    _HedefBellek := (_B1 * _HedefSatirdakiByteSayisi) + ArkaBellek;

    asm
      pushad
      mov esi,_KaynakBellek
      mov edi,_HedefBellek
      mov ecx,_KaynakSatirdakiByteSayisi
      cld
      rep movsb
      popad
    end;
  end;

  // 2. pencere ve alt nesnelerin arka belleğe çizilmesi
  if(_Masaustu^.AltNesneSayisi > 0) then
  begin

    _PencereBellekAdresi := _Masaustu^.FAltNesneBellekAdresi;

    for i := 0 to _Masaustu^.AltNesneSayisi - 1 do
    begin

      _Pencere := PPencere(_PencereBellekAdresi[i]);

      // sol sınır kontrol
      if(_Pencere^.FBoyutlar.Sol2 < 0) then
      begin

        _KaynakA1 := Abs(_Pencere^.FBoyutlar.Sol2);
        _KaynakA2 := _Pencere^.FBoyutlar.Genislik2 - _KaynakA1;
        _HedefA1 := 0;
      end
      else
      begin

        _KaynakA1 := 0;
        _KaynakA2 := _Pencere^.FBoyutlar.Genislik2;
        _HedefA1 := _Pencere^.FBoyutlar.Sol2;
      end;

      // sağ sınır kontrol
      if((_Pencere^.FBoyutlar.Sol2 + _Pencere^.FBoyutlar.Genislik2) >
        _Masaustu^.FBoyutlar.Genislik2 - 1) then
      begin

        _KaynakA2 := _Pencere^.FBoyutlar.Genislik2 -
          ((_Pencere^.FBoyutlar.Sol2 + _Pencere^.FBoyutlar.Genislik2) - (_Masaustu^.FBoyutlar.Genislik2 - 1))
      end
      else
      begin

        if(_Pencere^.FBoyutlar.Sol2 >= 0) then _KaynakA2 := _Pencere^.FBoyutlar.Genislik2;
      end;

      // üst sınır kontrol
      if(_Pencere^.FBoyutlar.Ust2 < 0) then
      begin

        _KaynakB1 := Abs(_Pencere^.FBoyutlar.Ust2);
        _KaynakB2 := _Pencere^.FBoyutlar.Yukseklik2;
        _HedefB1 := 0;
      end
      else
      begin

        _KaynakB1 := 0;
        _KaynakB2 := _Pencere^.FBoyutlar.Yukseklik2;
        _HedefB1 := _Pencere^.FBoyutlar.Ust2;
      end;

      // alt sınır kontrol
      if((_Pencere^.FBoyutlar.Ust2 + _Pencere^.FBoyutlar.Yukseklik2) >
        _Masaustu^.FBoyutlar.Yukseklik2 - 1) then
      begin

        _KaynakB2 := _Pencere^.FBoyutlar.Yukseklik2 -
          ((_Pencere^.FBoyutlar.Ust2 + _Pencere^.FBoyutlar.Yukseklik2) - (_Masaustu^.FBoyutlar.Yukseklik2 - 1))
      end
      else
      begin

        if(_Pencere^.FBoyutlar.Ust2 >= 0) then _KaynakB2 := _Pencere^.FBoyutlar.Yukseklik2;
      end;

      _KaynakSatirdakiByteSayisi := _Pencere^.FBoyutlar.Genislik2 * _NoktaBasinaByteSayisi;
      _HedefSatirdakiByteSayisi := KartBilgisi.SatirdakiByteSayisi;

      for _B1 := _KaynakB1 to _KaynakB2 - 1 do
      begin

        _KaynakBellek := (_B1 * _KaynakSatirdakiByteSayisi) +
          (_KaynakA1 * _NoktaBasinaByteSayisi) + _Pencere^.FCizimBellekAdresi;
        _HedefBellek := ((_Pencere^.FBoyutlar.Ust2 + _B1) * (_HedefSatirdakiByteSayisi)) +
          (_HedefA1 * _NoktaBasinaByteSayisi) + ArkaBellek;

        j := _KaynakA2 * _NoktaBasinaByteSayisi;
        asm
          pushad
          mov esi,_KaynakBellek
          mov edi,_HedefBellek
          mov ecx,j
          cld
          rep movsb
          popad
        end;
      end;
    end;
  end;

  // 3. ana menünün alt nesnelerin arka belleğe çizilmesi
  _BaslatmaMenusu := PMenu(_Masaustu^.FBaslatmaMenusu);
  if(_BaslatmaMenusu^.Gorunum) then
  begin

    _BaslatmaMenusu^.Ciz;

    _KaynakA1 := _BaslatmaMenusu^.FBoyutlar.Sol2;
    _KaynakB1 := _BaslatmaMenusu^.FBoyutlar.Ust2;
    _A2 := _BaslatmaMenusu^.FBoyutlar.Genislik2;     // sütundaki toplam pixel sayısı
    _B2 := _BaslatmaMenusu^.FBoyutlar.Yukseklik2;    // satırdaki toplam pixel sayısı

    _NoktaBasinaByteSayisi := KartBilgisi.NoktaBasinaByteSayisi;
    _HedefSatirdakiByteSayisi := KartBilgisi.SatirdakiByteSayisi;
    _KaynakSatirdakiByteSayisi := _A2 * _NoktaBasinaByteSayisi;

    for _B1 := 0 to _B2 - 1 do
    begin

      _KaynakBellek := (_B1 * _KaynakSatirdakiByteSayisi) + _BaslatmaMenusu^.FCizimBellekAdresi;
      _HedefBellek := (((_B1 + _KaynakB1) * _HedefSatirdakiByteSayisi) + (_KaynakA1 * _NoktaBasinaByteSayisi)) + ArkaBellek;

      asm
        pushad
        mov esi,_KaynakBellek
        mov edi,_HedefBellek
        mov ecx,_KaynakSatirdakiByteSayisi
        cld
        rep movsb
        popad
      end;
    end;
  end;
end;

// tanı bilgilerini aktif masaüstüne çizer / yazar
// EIP / ESP ve 5 döngüde 1 sağa / sola hareket eden nokta
var
  GostergeDegeri: TSayi4 = 10;
  GostergeyeEklenecekDeger: TISayi4 = 1;

procedure TaniBilgileriniMasaustuneYaz;
var
  _Masaustu: PMasaustu;
  i: TSayi4;
begin

  _Masaustu := GAktifMasaustu;

  _Masaustu^.DikdortgenDoldur(nil, 10, 10, 130, 44, $82E3DA, $82E3DA);
  _Masaustu^.YaziYaz(nil, 12, 16, 'EIP:', $6C3483);
  _Masaustu^.YaziYaz(nil, 46, 16, '0x' + hexStr(GorevTSSListesi[1].EIP, 8), $6C3483);
  //_Masaustu^.YaziYaz(nil, 12, 30, 'ESP:', $641E16);
  //_Masaustu^.YaziYaz(nil, 46, 30, '0x' + hexStr(GorevTSSListesi[1].ESP, 8), $641E16);
  _Masaustu^.YaziYaz(nil, 12, 30, 'DNT:', $641E16);
  _Masaustu^.YaziYaz(nil, 46, 30, '0x' + hexStr(SistemKontrolSayaci, 8), $641E16);

  Inc(GostergeDegeri, GostergeyeEklenecekDeger);
  if(GostergeDegeri >= (128 * 5)) then
    GostergeyeEklenecekDeger := -1
  else if(GostergeDegeri <= (10)) then
    GostergeyeEklenecekDeger := 1;

  i := GostergeDegeri div 5;
  _Masaustu^.Dikdortgen(nil, i, 13, i + 1, 14, RENK_SIYAH);
end;

{==============================================================================
  fare imleç göstergesini çizer
 ==============================================================================}
procedure TEkranKartSurucusu.FareGostergesiCiz;
var
  _FareImlec: TFareImlec;
  _ImlecBellekAdresi: PSayi1;
  _A1, _B1, _ImlecYatayBaslangic, _ImlecYatayBitis,
  _ImlecDikeyBaslangic, _ImlecDikeyBitis,
  _FareYatayBaslangic, _FareDikeyBaslangic,
  Val: TISayi4;
begin

  // geçerli fare gösterge bilgilerini al
  _FareImlec := CursorList[Ord(GecerliFareGostegeTipi)];

  // fare yatay başlangıç ve imleç yatay başlangıç değerlerinin hesaplanması
  _FareYatayBaslangic := GFareSurucusu.YatayKonum - _FareImlec.YatayOdak;
  if(_FareYatayBaslangic < 0) then
    _ImlecYatayBaslangic := Abs(_FareYatayBaslangic)
  else _ImlecYatayBaslangic := 0;

  // imleç yatay bitiş değerlerinin hesaplanması
  Val := GFareSurucusu.YatayKonum + (_FareImlec.Genislik - _FareImlec.YatayOdak);
  if(Val > GEkranKartSurucusu.KartBilgisi.YatayCozunurluk - 1) then
    _ImlecYatayBitis := _FareImlec.Genislik - (Val - GEkranKartSurucusu.KartBilgisi.YatayCozunurluk - 1)
  else _ImlecYatayBitis := _FareImlec.Genislik - 1;

  // fare dikey başlangıç ve imleç dikey başlangıç değerlerinin hesaplanması
  _FareDikeyBaslangic := GFareSurucusu.DikeyKonum - _FareImlec.DikeyOdak;
  if(_FareDikeyBaslangic < 0) then
    _ImlecDikeyBaslangic := Abs(_FareDikeyBaslangic)
  else _ImlecDikeyBaslangic := 0;

  // imleç dikey bitiş değerlerinin hesaplanması
  Val := GFareSurucusu.DikeyKonum + (_FareImlec.Yukseklik - _FareImlec.DikeyOdak);
  if(Val > GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk - 1) then
    _ImlecDikeyBitis := _FareImlec.Yukseklik - (Val - GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk - 1)
  else _ImlecDikeyBitis := _FareImlec.Yukseklik - 1;

  for _B1 := _ImlecDikeyBaslangic to _ImlecDikeyBitis do
  begin

    for _A1 := _ImlecYatayBaslangic to _ImlecYatayBitis do
    begin

      // fare imleç göstergesi bellek adresi
      _ImlecBellekAdresi := _FareImlec.BellekAdresi + (_B1 * _FareImlec.Genislik) + _A1;

      if(_ImlecBellekAdresi^ = 1) then
        GEkranKartSurucusu.NoktaYaz(nil, _FareYatayBaslangic + _A1, _FareDikeyBaslangic + _B1,
          RENK_SIYAH, True)
      else if(_ImlecBellekAdresi^ = 2) then
        GEkranKartSurucusu.NoktaYaz(nil, _FareYatayBaslangic + _A1, _FareDikeyBaslangic + _B1,
          RENK_BEYAZ, True);
    end;
  end;
end;

end.
