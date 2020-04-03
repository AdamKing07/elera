{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_kaydirmacubugu.pas
  Dosya İşlevi: kaydırma çubuğu yönetim işlevlerini içerir

  Güncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_kaydirmacubugu;

interface

uses gorselnesne, paylasim, gn_pencere;

type
  PKaydirmaCubugu = ^TKaydirmaCubugu;
  TKaydirmaCubugu = object(TGorselNesne)
  private
    FYon: TYon;
    FAzalmaDDurum, FArtmaDDurum: TDugmeDurumu;    // azalma ve artma düğme durumları
    FMevcutDeger, FAltDeger, FUstDeger: TISayi4;
    FCubukU: TISayi4;                             // kaydırma çubuğunun ortasındaki çubuğun uzunluğu
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      AYon: TYon): PKaydirmaCubugu;
    procedure DegerleriBelirle(AAltDeger, AUstDeger: TISayi4);
    procedure Goster;
    procedure Ciz;
    procedure KaydirmaOklariniCiz(APencere: PPencere; AAlan: TAlan; AYon: TYon);
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  published
    property Yon: TYon read FYon write FYon;
    property MevcutDeger: TISayi4 read FMevcutDeger write FMevcutDeger;
    property AltDeger: TISayi4 read FAltDeger write FAltDeger;
    property UstDeger: TISayi4 read FUstDeger write FUstDeger;
  end;

function KaydirmaCubuguCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): TKimlik;

implementation

uses genel, gn_islevler, temelgorselnesne, hamresim2;

{==============================================================================
  kaydırma çubuğu kesme çağrılarını yönetir
 ==============================================================================}
function KaydirmaCubuguCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
  _Hiza: THiza;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PYon(Degiskenler + 20)^);

    ISLEV_GOSTER:
    begin

      _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _KaydirmaCubugu^.Goster;
    end;

    $0104:
    begin

      _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _KaydirmaCubugu^.Hiza := _Hiza;

      _Pencere := PPencere(_KaydirmaCubugu^.FAtaNesne);
      _Pencere^.Guncelle;
    end;

    // alt, üst değerlerini belirle
    $0204:
    begin

      _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntKaydirmaCubugu));
      if(_KaydirmaCubugu <> nil) then _KaydirmaCubugu^.DegerleriBelirle(
        PISayi4(Degiskenler + 04)^, PISayi4(Degiskenler + 08)^);
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  kaydırma çubuğu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TKimlik;
  AYon: TYon): TKimlik;
var
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  _KaydirmaCubugu := _KaydirmaCubugu^.Olustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, AYon);

  if(_KaydirmaCubugu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _KaydirmaCubugu^.Kimlik;
end;

{==============================================================================
  kaydırma çubuğu nesnesini oluşturur
 ==============================================================================}
function TKaydirmaCubugu.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): PKaydirmaCubugu;
var
  _AtaNesne: PGorselNesne;
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // kaydırma çubuğu nesnesi oluştur
  _KaydirmaCubugu := PKaydirmaCubugu(Olustur0(gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // kaydırma çubuğu nesnesini ata nesneye ekle
  if(_KaydirmaCubugu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _KaydirmaCubugu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesnenin ilk özellik değerlerini ata
  _KaydirmaCubugu^.GorevKimlik := CalisanGorev;
  _KaydirmaCubugu^.AtaNesne := _AtaNesne;
  _KaydirmaCubugu^.Hiza := hzYok;
  _KaydirmaCubugu^.FBoyutlar.Sol2 := A1;
  _KaydirmaCubugu^.FBoyutlar.Ust2 := B1;

  // dikey kaydırma çubuğunun genişliği 15px olarak sabitleniyor
  if(AYon = yDikey) then
    _KaydirmaCubugu^.FBoyutlar.Genislik2 := 15
  else _KaydirmaCubugu^.FBoyutlar.Genislik2 := AGenislik;

  // yatay kaydırma çubuğunun yüksekliği 15px olarak sabitleniyor
  if(AYon = yYatay) then
    _KaydirmaCubugu^.FBoyutlar.Yukseklik2 := 15
  else _KaydirmaCubugu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _KaydirmaCubugu^.FKalinlik.Sol := 0;
  _KaydirmaCubugu^.FKalinlik.Ust := 0;
  _KaydirmaCubugu^.FKalinlik.Sag := 0;
  _KaydirmaCubugu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _KaydirmaCubugu^.FKenarBosluklari.Sol := 0;
  _KaydirmaCubugu^.FKenarBosluklari.Ust := 0;
  _KaydirmaCubugu^.FKenarBosluklari.Sag := 0;
  _KaydirmaCubugu^.FKenarBosluklari.Alt := 0;

  _KaydirmaCubugu^.Yon := AYon;
  _KaydirmaCubugu^.MevcutDeger := 0;
  _KaydirmaCubugu^.AltDeger := 0;
  _KaydirmaCubugu^.UstDeger := 100;

  _KaydirmaCubugu^.FAtaNesneMi := False;
  _KaydirmaCubugu^.FareGostergeTipi := fitOK;
  _KaydirmaCubugu^.Gorunum := False;
  _KaydirmaCubugu^.Baslik := '';
  _KaydirmaCubugu^.FAzalmaDDurum := ddNormal;
  _KaydirmaCubugu^.FArtmaDDurum := ddNormal;

  // nesnenin ad değeri
  _KaydirmaCubugu^.NesneAdi := NesneAdiAl(gntKaydirmaCubugu);

  // uygulamaya mesaj gönder
  GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
    _KaydirmaCubugu, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _KaydirmaCubugu;
end;

{==============================================================================
  işlem göstergesi en alt, en üst değerlerini belirler
 ==============================================================================}
procedure TKaydirmaCubugu.DegerleriBelirle(AAltDeger, AUstDeger: TISayi4);
begin

  FAltDeger := AAltDeger;
  FUstDeger := AUstDeger;
end;

{==============================================================================
  kaydırma çubuğu nesnesini görüntüler
 ==============================================================================}
procedure TKaydirmaCubugu.Goster;
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(Kimlik,
    gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_KaydirmaCubugu^.Gorunum = False) then
  begin

    // kaydırma çubuğu nesnesinin görünürlüğünü aktifleştir
    _KaydirmaCubugu^.Gorunum := True;

    // ata nesne görünür durumda mı ?
    if(_KaydirmaCubugu^.AtaNesneGorunurMu) then
    begin

      // kaydırma çubuğu nesnesinin ata nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);

      // pencere nesnesini güncelle
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  kaydırma çubuğu nesnesini çizer
 ==============================================================================}
procedure TKaydirmaCubugu.Ciz;
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
  _Alan: TAlan;
  FYuzde1, FYuzde2: Double;
  i: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(Kimlik,
    gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);
  if(_Pencere = nil) then Exit;

  // kaydırma çubuğunun ata nesne olan pencere nesnesine bağlı olarak koordinatlarını al
  _Alan := _KaydirmaCubugu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  if(_KaydirmaCubugu^.Yon = yDikey) then
  begin

    // kaydırma çubuk uzunluğu = ara boşluğun yarısı
    FCubukU := ((_Alan.B2 - _Alan.B1) - ((_KaydirmaCubugu^.FBoyutlar.Genislik2 + 1) * 2)) div 2;
  end
  else
  begin

    // kaydırma çubuk uzunluğu = ara boşluğun yarısı
    FCubukU := ((_Alan.A2 - _Alan.A1) - ((_KaydirmaCubugu^.FBoyutlar.Yukseklik2 + 1) * 2)) div 2;
  end;

  FYuzde1 := (FMevcutDeger * 100) / FUstDeger;
  FYuzde2 := FCubukU / 100;
  i := Round(FYuzde1 * FYuzde2);

  // yatay kaydırma çubuğu
  if(_KaydirmaCubugu^.Yon = yYatay) then
  begin

    DikdortgenDoldur(_Pencere, _Alan, RENK_BEYAZ, RENK_BEYAZ);

    if(FAzalmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A1 + 14, _Alan.B2,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A1 + 14, _Alan.B2,
        $7F7F7F, $C3C3C3);

    if(FArtmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.A2 - 14, _Alan.B1, _Alan.A2, _Alan.B2,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.A2 - 14, _Alan.B1, _Alan.A2, _Alan.B2,
        $7F7F7F, $C3C3C3);

    KaydirmaOklariniCiz(_Pencere, _Alan, _KaydirmaCubugu^.Yon);

    Cizgi(_Pencere, _Alan.A1 + 16, _Alan.B1, _Alan.A2 - 16, _Alan.B1, $7F7F7F);
    Cizgi(_Pencere, _Alan.A1 + 16, _Alan.B2, _Alan.A2 - 16, _Alan.B2, $7F7F7F);

    DikdortgenDoldur(_Pencere, _Alan.A1 + 16 + i, _Alan.B1 + 2, _Alan.A1 + 16 + i + FCubukU,
      _Alan.B2 - 2, $7F7F7F, $7F7F7F);
  end
  else
  // dikey kaydırma çubuğu
  begin

    DikdortgenDoldur(_Pencere, _Alan, RENK_BEYAZ, RENK_BEYAZ);

    if(FAzalmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B1 + 14,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B1 + 14,
        $7F7F7F, $C3C3C3);

    if(FArtmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B2 - 14, _Alan.A2, _Alan.B2,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B2 - 14, _Alan.A2, _Alan.B2,
        $7F7F7F, $C3C3C3);

    KaydirmaOklariniCiz(_Pencere, _Alan, _KaydirmaCubugu^.Yon);

    Cizgi(_Pencere, _Alan.A1, _Alan.B1 + 16, _Alan.A1, _Alan.B2 - 16, $7F7F7F);
    Cizgi(_Pencere, _Alan.A2, _Alan.B1 + 16, _Alan.A2, _Alan.B2 - 16, $7F7F7F);

    DikdortgenDoldur(_Pencere, _Alan.A1 + 2, _Alan.B1 + 16 + i, _Alan.A2 - 2,
      _Alan.B1 + 16 + i + FCubukU, $7F7F7F, $7F7F7F);
  end;

  // uygulamaya mesaj gönder
  GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
    _KaydirmaCubugu, CO_CIZIM, 0, 0);
end;

procedure TKaydirmaCubugu.KaydirmaOklariniCiz(APencere: PPencere; AAlan: TAlan; AYon: TYon);
var
  p1: PByte;
  B1, A1: Integer;
begin

  if(AYon = yYatay) then
  begin

    p1 := PByte(@OKSol);
    for B1 := 1 to 7 do
    begin

      for A1 := 1 to 4 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, AAlan.A1 + 4 + A1, AAlan.B1 + 3 + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;

    p1 := PByte(@OKSag);
    for B1 := 1 to 7 do
    begin

      for A1 := 1 to 4 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, (AAlan.A2 - 9) + A1, AAlan.B1 + 3 + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;
  end
  else
  begin

    p1 := PByte(@OKUst);
    for B1 := 1 to 4 do
    begin

      for A1 := 1 to 7 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, AAlan.A1 + 3 + A1, AAlan.B1 + 4 + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;

    p1 := PByte(@OKAlt);
    for B1 := 1 to 4 do
    begin

      for A1 := 1 to 7 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, (AAlan.A1 + 3) + A1, (AAlan.B2 - 9) + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;
  end;
end;

{==============================================================================
  kaydırma çubuğu nesne olaylarını işler
 ==============================================================================}
procedure TKaydirmaCubugu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
  _AlanArtis, _AlanAzalma: TAlan;
begin

  _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(AKimlik,
    gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // kaydırma çubuğunun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_KaydirmaCubugu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      if(_KaydirmaCubugu^.FYon = yYatay) then
      begin

        _AlanAzalma.A1 := 0;
        _AlanAzalma.B1 := 0;
        _AlanAzalma.A2 := 14;
        _AlanAzalma.B2 := 14;

        _AlanArtis.A2 := _KaydirmaCubugu^.FBoyutlar.Genislik2;
        _AlanArtis.B2 := _KaydirmaCubugu^.FBoyutlar.Yukseklik2;
        _AlanArtis.A1 := _AlanArtis.A2 - 14;
        _AlanArtis.B1 := 0;
      end
      else
      begin

        _AlanAzalma.A1 := 0;
        _AlanAzalma.B1 := 0;
        _AlanAzalma.A2 := 14;
        _AlanAzalma.B2 := 14;

        _AlanArtis.A2 := _KaydirmaCubugu^.FBoyutlar.Genislik2;
        _AlanArtis.B2 := _KaydirmaCubugu^.FBoyutlar.Yukseklik2;
        _AlanArtis.A1 := 0;
        _AlanArtis.B1 := _AlanArtis.B2 - 14;
      end;

      if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _AlanAzalma)) then
        _KaydirmaCubugu^.FAzalmaDDurum := ddBasili
      else if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _AlanArtis)) then
        _KaydirmaCubugu^.FArtmaDDurum := ddBasili;

      if(FAzalmaDDurum = ddBasili) then
      begin

        Dec(FMevcutDeger);
        if(FMevcutDeger < FAltDeger) then FMevcutDeger := FAltDeger;
      end
      else if(FArtmaDDurum = ddBasili) then
      begin

        Inc(FMevcutDeger);
        if(FMevcutDeger > FUstDeger) then FMevcutDeger := FUstDeger;
      end;

      // fare olaylarını yakala
      OlayYakalamayaBasla(_KaydirmaCubugu);

      // kaydırma çubuğu nesnesini yeniden çiz
      _KaydirmaCubugu^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
        _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_KaydirmaCubugu);

    //  kaydırma çubuğu durumlarını eski konumuna geri getir
    _KaydirmaCubugu^.FAzalmaDDurum := ddNormal;
    _KaydirmaCubugu^.FArtmaDDurum := ddNormal;

    // kaydırma çubuğu nesnesini yeniden çiz
    _KaydirmaCubugu^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_KaydirmaCubugu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
        _KaydirmaCubugu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
      _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // kaydırma çubuğu nesnesini yeniden çiz
    _KaydirmaCubugu^.Ciz;

    GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
      _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
