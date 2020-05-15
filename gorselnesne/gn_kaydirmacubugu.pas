{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_kaydirmacubugu.pas
  Dosya Ýþlevi: kaydýrma çubuðu yönetim iþlevlerini içerir

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
    FAzalmaDDurum, FArtmaDDurum: TDugmeDurumu;    // azalma ve artma düðme durumlarý
    FMevcutDeger, FAltDeger, FUstDeger: TISayi4;
    FCubukU: TISayi4;                             // kaydýrma çubuðunun ortasýndaki çubuðun uzunluðu
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

uses genel, gn_islevler, temelgorselnesne, hamresim2, sistemmesaj;

{==============================================================================
  kaydýrma çubuðu kesme çaðrýlarýný yönetir
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

    // alt, üst deðerlerini belirle
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
  kaydýrma çubuðu nesnesini oluþturur
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
  kaydýrma çubuðu nesnesini oluþturur
 ==============================================================================}
function TKaydirmaCubugu.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): PKaydirmaCubugu;
var
  _AtaNesne: PGorselNesne;
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  // nesnenin baðlanacaðý ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // kaydýrma çubuðu nesnesi oluþtur
  _KaydirmaCubugu := PKaydirmaCubugu(Olustur0(gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // kaydýrma çubuðu nesnesini ata nesneye ekle
  if(_KaydirmaCubugu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olmasý durumunda nesneyi yok et ve hata koduyla iþlevden çýk
    _KaydirmaCubugu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesnenin ilk özellik deðerlerini ata
  _KaydirmaCubugu^.GorevKimlik := CalisanGorev;
  _KaydirmaCubugu^.AtaNesne := _AtaNesne;
  _KaydirmaCubugu^.Hiza := hzYok;
  _KaydirmaCubugu^.FBoyutlar.Sol2 := A1;
  _KaydirmaCubugu^.FBoyutlar.Ust2 := B1;

  // dikey kaydýrma çubuðunun geniþliði 15px olarak sabitleniyor
  if(AYon = yDikey) then
    _KaydirmaCubugu^.FBoyutlar.Genislik2 := 15
  else _KaydirmaCubugu^.FBoyutlar.Genislik2 := AGenislik;

  // yatay kaydýrma çubuðunun yüksekliði 15px olarak sabitleniyor
  if(AYon = yYatay) then
    _KaydirmaCubugu^.FBoyutlar.Yukseklik2 := 15
  else _KaydirmaCubugu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalýnlýklarý
  _KaydirmaCubugu^.FKalinlik.Sol := 0;
  _KaydirmaCubugu^.FKalinlik.Ust := 0;
  _KaydirmaCubugu^.FKalinlik.Sag := 0;
  _KaydirmaCubugu^.FKalinlik.Alt := 0;

  // kenar boþluklarý
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
  _KaydirmaCubugu^.FGorunum := False;
  _KaydirmaCubugu^.FBaslik := '';
  _KaydirmaCubugu^.FAzalmaDDurum := ddNormal;
  _KaydirmaCubugu^.FArtmaDDurum := ddNormal;

  // nesnenin ad deðeri
  _KaydirmaCubugu^.NesneAdi := NesneAdiAl(gntKaydirmaCubugu);

  // uygulamaya mesaj gönder
  GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,
    _KaydirmaCubugu, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _KaydirmaCubugu;
end;

{==============================================================================
  iþlem göstergesi en alt, en üst deðerlerini belirler
 ==============================================================================}
procedure TKaydirmaCubugu.DegerleriBelirle(AAltDeger, AUstDeger: TISayi4);
begin

  FAltDeger := AAltDeger;
  FUstDeger := AUstDeger;
  FMevcutDeger := AAltDeger;
end;

{==============================================================================
  kaydýrma çubuðu nesnesini görüntüler
 ==============================================================================}
procedure TKaydirmaCubugu.Goster;
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(Kimlik,
    gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then Exit;

  // nesne görünür durumda mý ?
  if(_KaydirmaCubugu^.FGorunum = False) then
  begin

    // kaydýrma çubuðu nesnesinin görünürlüðünü aktifleþtir
    _KaydirmaCubugu^.FGorunum := True;

    // ata nesne görünür durumda mý ?
    if(_KaydirmaCubugu^.AtaNesneGorunurMu) then
    begin

      // kaydýrma çubuðu nesnesinin ata nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);

      // pencere nesnesini güncelle
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  kaydýrma çubuðu nesnesini çizer
 ==============================================================================}
procedure TKaydirmaCubugu.Ciz;
var
  _Pencere: PPencere;
  _KaydirmaCubugu: PKaydirmaCubugu;
  _Alan: TAlan;
  FYuzde1, FYuzde2: Double;
  i: TISayi4;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneTipiniKontrolEt(Kimlik,
    gntKaydirmaCubugu));
  if(_KaydirmaCubugu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);
  if(_Pencere = nil) then Exit;

  // kaydýrma çubuðunun ata nesne olan pencere nesnesine baðlý olarak koordinatlarýný al
  _Alan := _KaydirmaCubugu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  if(_KaydirmaCubugu^.Yon = yDikey) then
  begin

    // kaydýrma çubuk uzunluðu = ara boþluðun yarýsý
    FCubukU := ((_Alan.Alt - _Alan.Ust) - ((_KaydirmaCubugu^.FBoyutlar.Genislik2 + 1) * 2)) div 2;
  end
  else
  begin

    // kaydýrma çubuk uzunluðu = ara boþluðun yarýsý
    FCubukU := ((_Alan.Sag - _Alan.Sol) - ((_KaydirmaCubugu^.FBoyutlar.Yukseklik2 + 1) * 2)) div 2;
  end;

  FYuzde1 := (FMevcutDeger * 100) / FUstDeger;
  FYuzde2 := FCubukU / 100;
  i := Round(FYuzde1 * FYuzde2);

  // yatay kaydýrma çubuðu
  if(_KaydirmaCubugu^.Yon = yYatay) then
  begin

    DikdortgenDoldur(_Pencere, _Alan, RENK_BEYAZ, RENK_BEYAZ);

    if(FAzalmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sol + 14, _Alan.Alt,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sol + 14, _Alan.Alt,
        $7F7F7F, $C3C3C3);

    if(FArtmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.Sag - 14, _Alan.Ust, _Alan.Sag, _Alan.Alt,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.Sag - 14, _Alan.Ust, _Alan.Sag, _Alan.Alt,
        $7F7F7F, $C3C3C3);

    KaydirmaOklariniCiz(_Pencere, _Alan, _KaydirmaCubugu^.Yon);

    Cizgi(_Pencere, _Alan.Sol + 16, _Alan.Ust, _Alan.Sag - 16, _Alan.Ust, $7F7F7F);
    Cizgi(_Pencere, _Alan.Sol + 16, _Alan.Alt, _Alan.Sag - 16, _Alan.Alt, $7F7F7F);

    DikdortgenDoldur(_Pencere, _Alan.Sol + 16 + i, _Alan.Ust + 2, _Alan.Sol + 16 + i + FCubukU,
      _Alan.Alt - 2, $7F7F7F, $7F7F7F);
  end
  else
  // dikey kaydýrma çubuðu
  begin

    DikdortgenDoldur(_Pencere, _Alan, RENK_BEYAZ, RENK_BEYAZ);

    if(FAzalmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sag, _Alan.Ust + 14,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sag, _Alan.Ust + 14,
        $7F7F7F, $C3C3C3);

    if(FArtmaDDurum = ddNormal) then
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Alt - 14, _Alan.Sag, _Alan.Alt,
        $7F7F7F, RENK_BEYAZ)
    else
      DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Alt - 14, _Alan.Sag, _Alan.Alt,
        $7F7F7F, $C3C3C3);

    KaydirmaOklariniCiz(_Pencere, _Alan, _KaydirmaCubugu^.Yon);

    Cizgi(_Pencere, _Alan.Sol, _Alan.Ust + 16, _Alan.Sol, _Alan.Alt - 16, $7F7F7F);
    Cizgi(_Pencere, _Alan.Sag, _Alan.Ust + 16, _Alan.Sag, _Alan.Alt - 16, $7F7F7F);

    DikdortgenDoldur(_Pencere, _Alan.Sol + 2, _Alan.Ust + 16 + i, _Alan.Sag - 2,
      _Alan.Ust + 16 + i + FCubukU, $7F7F7F, $7F7F7F);
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
          PixelYaz(APencere, AAlan.Sol + 4 + A1, AAlan.Ust + 3 + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;

    p1 := PByte(@OKSag);
    for B1 := 1 to 7 do
    begin

      for A1 := 1 to 4 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, (AAlan.Sag - 9) + A1, AAlan.Ust + 3 + B1, RENK_SIYAH);

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
          PixelYaz(APencere, AAlan.Sol + 3 + A1, AAlan.Ust + 4 + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;

    p1 := PByte(@OKAlt);
    for B1 := 1 to 4 do
    begin

      for A1 := 1 to 7 do
      begin

        if(p1^ = 1) then
          PixelYaz(APencere, (AAlan.Sol + 3) + A1, (AAlan.Alt - 9) + B1, RENK_SIYAH);

        Inc(p1);
      end;
    end;
  end;
end;

{==============================================================================
  kaydýrma çubuðu nesne olaylarýný iþler
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

  // farenin sol tuþuna basým iþlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // kaydýrma çubuðunun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_KaydirmaCubugu);

    // en üstte olmamasý durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuþa basým iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(_KaydirmaCubugu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // tek kat artýþ ve eksiltme ->
      if(_KaydirmaCubugu^.FYon = yYatay) then
      begin

        _AlanAzalma.Sol := 0;
        _AlanAzalma.Sag := 14;
        _AlanAzalma.Ust := 0;
        _AlanAzalma.Alt := 14;

        _AlanArtis.Sag := _KaydirmaCubugu^.FBoyutlar.Genislik2;
        _AlanArtis.Sol := _AlanArtis.Sag - 14;
        _AlanArtis.Ust := 0;
        _AlanArtis.Alt := _KaydirmaCubugu^.FBoyutlar.Yukseklik2;
      end
      else
      begin

        _AlanAzalma.Sol := 0;
        _AlanAzalma.Sag := 14;
        _AlanAzalma.Ust := 0;
        _AlanAzalma.Alt := 14;

        _AlanArtis.Sol := 0;
        _AlanArtis.Sag := _KaydirmaCubugu^.FBoyutlar.Genislik2;
        _AlanArtis.Alt := _KaydirmaCubugu^.FBoyutlar.Yukseklik2;
        _AlanArtis.Ust := _AlanArtis.Alt - 14;
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
      end
      // <- tek kat artýþ ve eksiltme

      else
      // 20 kat artýþ ve eksiltme ->
      begin

        if(_KaydirmaCubugu^.FYon = yYatay) then
        begin

          _AlanAzalma.Sol := 14;
          _AlanAzalma.Sag := 28;
          _AlanAzalma.Ust := 0;
          _AlanAzalma.Alt := 14;

          _AlanArtis.Sag := _KaydirmaCubugu^.FBoyutlar.Genislik2 - 14;
          _AlanArtis.Sol := _AlanArtis.Sag - 14;
          _AlanArtis.Ust := 0;
          _AlanArtis.Alt := _KaydirmaCubugu^.FBoyutlar.Yukseklik2;
        end
        else
        begin

          _AlanAzalma.Sol := 0;
          _AlanAzalma.Sag := 14;
          _AlanAzalma.Ust := 14;
          _AlanAzalma.Alt := 28;

          _AlanArtis.Sol := 0;
          _AlanArtis.Sag := _KaydirmaCubugu^.FBoyutlar.Genislik2;
          _AlanArtis.Alt := _KaydirmaCubugu^.FBoyutlar.Yukseklik2 - 14;
          _AlanArtis.Ust := _AlanArtis.Alt - 14;
        end;

        if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _AlanAzalma)) then
          _KaydirmaCubugu^.FAzalmaDDurum := ddBasili
        else if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _AlanArtis)) then
          _KaydirmaCubugu^.FArtmaDDurum := ddBasili;

        if(FAzalmaDDurum = ddBasili) then
        begin

          Dec(FMevcutDeger, 20);
          if(FMevcutDeger < FAltDeger) then FMevcutDeger := FAltDeger;
        end
        else if(FArtmaDDurum = ddBasili) then
        begin

          Inc(FMevcutDeger, 20);
          if(FMevcutDeger > FUstDeger) then FMevcutDeger := FUstDeger;
        end;
      end;
      // <- 20 kat artýþ ve eksiltme

      // fare olaylarýný yakala
      OlayYakalamayaBasla(_KaydirmaCubugu);

      // kaydýrma çubuðu nesnesini yeniden çiz
      _KaydirmaCubugu^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(_KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi = nil) then

        _KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi(_KaydirmaCubugu^.Kimlik, AOlay)

      else GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,

        _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarýný almayý býrak
    OlayYakalamayiBirak(_KaydirmaCubugu);

    //  kaydýrma çubuðu durumlarýný eski konumuna geri getir
    _KaydirmaCubugu^.FAzalmaDDurum := ddNormal;
    _KaydirmaCubugu^.FArtmaDDurum := ddNormal;

    // kaydýrma çubuðu nesnesini yeniden çiz
    _KaydirmaCubugu^.Ciz;

    // farenin tuþ býrakma iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(_KaydirmaCubugu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(_KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi = nil) then

        _KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi(_KaydirmaCubugu^.Kimlik, AOlay)

      else GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,

        _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;

    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(_KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi = nil) then

      _KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi(_KaydirmaCubugu^.Kimlik, AOlay)

    else GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,

      _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // kaydýrma çubuðu nesnesini yeniden çiz
    _KaydirmaCubugu^.Ciz;

    if not(_KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi = nil) then

      _KaydirmaCubugu^.FEfendiNesneOlayCagriAdresi(_KaydirmaCubugu^.Kimlik, AOlay)

    else GorevListesi[_KaydirmaCubugu^.GorevKimlik]^.OlayEkle1(_KaydirmaCubugu^.GorevKimlik,

      _KaydirmaCubugu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
