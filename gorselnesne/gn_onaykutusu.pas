{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_onaykutusu.pas
  Dosya İşlevi: onay kutusu (checkbox) yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_onaykutusu;

interface

uses gorselnesne, paylasim;

const
  TamamResimDizi: array[1..7, 1..7] of TSayi1 = (
    (0, 0, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 1, 1),
    (1, 0, 0, 0, 1, 1, 1),
    (1, 1, 0, 1, 1, 1, 0),
    (1, 1, 1, 1, 1, 0, 0),
    (0, 1, 1, 1, 0, 0, 0),
    (0, 0, 1, 0, 0, 0, 0));

type
  POnayKutusu = ^TOnayKutusu;
  TOnayKutusu = object(TGorselNesne)
  private
    FOncekiSecimDurumu,
    FSecimDurumu: TSecimDurumu;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): POnayKutusu;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function IsaretKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  onay kutusu çağrılarını yönetir
 ==============================================================================}
function IsaretKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _OnayKutusu: POnayKutusu;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PShortString(PSayi4(Degiskenler + 12)^ +
        AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _OnayKutusu := POnayKutusu(_OnayKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _OnayKutusu^.Goster;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  onay kutusu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;
var
  _OnayKutusu: POnayKutusu;
begin

  _OnayKutusu := _OnayKutusu^.Olustur(AAtaNesne, A1, B1, ABaslik);

  if(_OnayKutusu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _OnayKutusu^.Kimlik;
end;

{==============================================================================
  onay kutusu nesnesini oluşturur
 ==============================================================================}
function TOnayKutusu.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): POnayKutusu;
var
  _AtaNesne: PGorselNesne;
  _OnayKutusu: POnayKutusu;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // onay kutusu için bellekte yer ayır
  _OnayKutusu := POnayKutusu(Olustur0(gntIsaretKutusu));
  if(_OnayKutusu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // onay kutusu nesnesini üst nesneye ekle
  if(_OnayKutusu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _OnayKutusu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _OnayKutusu^.GorevKimlik := CalisanGorev;
  _OnayKutusu^.AtaNesne := _AtaNesne;
  _OnayKutusu^.Hiza := hzYok;
  _OnayKutusu^.FBoyutlar.Sol2 := A1;
  _OnayKutusu^.FBoyutlar.Ust2 := B1;
  _OnayKutusu^.FBoyutlar.Genislik2 := 16 + 6 + (Length(ABaslik) * 8);
  _OnayKutusu^.FBoyutlar.Yukseklik2 := 16;

  // kenar kalınlıkları
  _OnayKutusu^.FKalinlik.Sol := 0;
  _OnayKutusu^.FKalinlik.Ust := 0;
  _OnayKutusu^.FKalinlik.Sag := 0;
  _OnayKutusu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _OnayKutusu^.FKenarBosluklari.Sol := 0;
  _OnayKutusu^.FKenarBosluklari.Ust := 0;
  _OnayKutusu^.FKenarBosluklari.Sag := 0;
  _OnayKutusu^.FKenarBosluklari.Alt := 0;

  _OnayKutusu^.FAtaNesneMi := False;
  _OnayKutusu^.FareGostergeTipi := fitOK;
  _OnayKutusu^.Gorunum := False;
  _OnayKutusu^.FSecimDurumu := sdSecili;

  // nesnenin ad ve başlık değeri
  _OnayKutusu^.NesneAdi := NesneAdiAl(gntIsaretKutusu);
  _OnayKutusu^.Baslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_OnayKutusu^.GorevKimlik]^.OlayEkle1(_OnayKutusu^.GorevKimlik,
    _OnayKutusu, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _OnayKutusu;
end;

{==============================================================================
  onay kutusu nesnesini görüntüler
 ==============================================================================}
procedure TOnayKutusu.Goster;
var
  _Pencere: PPencere;
  _OnayKutusu: POnayKutusu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _OnayKutusu := POnayKutusu(_OnayKutusu^.NesneTipiniKontrolEt(Kimlik, gntIsaretKutusu));
  if(_OnayKutusu = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_OnayKutusu^.Gorunum = False) then
  begin

    // onay kutusu nesnesinin görünürlüğünü aktifleştir
    _OnayKutusu^.Gorunum := True;

    // onay kutusu nesnesi ve üst nesneler görünür durumda mı ?
    if(_OnayKutusu^.AtaNesneGorunurMu) then
    begin

      // görünür ise onay kutusu nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_OnayKutusu);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  onay kutusu nesnesini çizer
 ==============================================================================}
procedure TOnayKutusu.Ciz;
var
  _Pencere: PPencere;
  _OnayKutusu: POnayKutusu;
  _Alan: TAlan;
  X, Y: TISayi4;
  p1: PSayi1;
begin

  _OnayKutusu := POnayKutusu(_OnayKutusu^.NesneTipiniKontrolEt(Kimlik, gntIsaretKutusu));
  if(_OnayKutusu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_OnayKutusu);
  if(_Pencere = nil) then Exit;

  // onay kutusu üst nesneye bağlı olarak koordinatlarını al
  _Alan := _OnayKutusu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  _Alan.A2 := _Alan.A1 + 15;
  _Alan.B2 := _Alan.B1 + 15;

  // onay kutusu normal çizimi
  if(_OnayKutusu^.FSecimDurumu = sdNormal) then
  begin

    // dış kenarlığı çiz
    KenarlikCiz(_Pencere, _Alan, 2);

    // pencere içeriğini boya
    DikdortgenDoldur(_Pencere, _Alan.A1 + 2, _Alan.B1 + 2, _Alan.A2 - 2, _Alan.B2 -2,
      RENK_BEYAZ, RENK_BEYAZ);

    p1 := PByte(@TamamResimDizi);
    for Y := 1 to 7 do
    begin

      for X := 1 to 7 do
      begin

        if(p1^ = 1) then PixelYaz(_Pencere, _Alan.A1 + 4 + X, _Alan.B1 + 4 + Y, RENK_SIYAH);
        Inc(p1);
      end;
    end;

    // onay kutusu başlığı
    YaziYaz(_Pencere, _Alan.A2 + 6, _Alan.B1, _OnayKutusu^.Baslik, RENK_SIYAH);
  end
  else if(_OnayKutusu^.FSecimDurumu = sdSecili) then
  begin

    // dış kenarlığı çiz
    KenarlikCiz(_Pencere, _Alan, 2);

    // pencere içeriğini boya
    DikdortgenDoldur(_Pencere, _Alan.A1 + 2, _Alan.B1 + 2, _Alan.A2 - 2, _Alan.B2 -2,
      RENK_BEYAZ, RENK_BEYAZ);

    // onay kutusu başlığı
    YaziYaz(_Pencere, _Alan.A2 + 6, _Alan.B1, _OnayKutusu^.Baslik, RENK_SIYAH);
  end;

  // uygulamaya mesaj gönder
  GorevListesi[_OnayKutusu^.GorevKimlik]^.OlayEkle1(_OnayKutusu^.GorevKimlik,
    _OnayKutusu, CO_CIZIM, 0, 0);
end;

{==============================================================================
  onay kutusu nesne olaylarını işler
 ==============================================================================}
procedure TOnayKutusu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _OnayKutusu: POnayKutusu;
begin

  _OnayKutusu := POnayKutusu(_OnayKutusu^.NesneTipiniKontrolEt(AKimlik, gntIsaretKutusu));
  if(_OnayKutusu = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // onay kutusu'nun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_OnayKutusu);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_OnayKutusu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_OnayKutusu);

      // mevcut durum değerini sakla
      FOncekiSecimDurumu := _OnayKutusu^.FSecimDurumu;

      if(FSecimDurumu = sdNormal) then

        _OnayKutusu^.FSecimDurumu := sdSecili
      else _OnayKutusu^.FSecimDurumu := sdNormal;

      // onay kutusu nesnesini yeniden çiz
      _OnayKutusu^.Ciz;
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_OnayKutusu);

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_OnayKutusu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      if(_OnayKutusu^.FSecimDurumu = sdNormal) then

        GorevListesi[_OnayKutusu^.GorevKimlik]^.OlayEkle1(_OnayKutusu^.GorevKimlik,
          _OnayKutusu, CO_DURUMDEGISTI, 1, 0)
      else GorevListesi[_OnayKutusu^.GorevKimlik]^.OlayEkle1(_OnayKutusu^.GorevKimlik,
        _OnayKutusu, CO_DURUMDEGISTI, 0, 0);

    // aksi durumda onay kutusu durumunu bir önceki duruma getir
    end else _OnayKutusu^.FSecimDurumu := _OnayKutusu^.FOncekiSecimDurumu;

    // onay kutusu nesnesini yeniden çiz
    _OnayKutusu^.Ciz;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
