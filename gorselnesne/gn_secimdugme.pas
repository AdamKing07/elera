{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_secimdugme.pas
  Dosya İşlevi: seçim düğmesi (radio button) yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_secimdugme;

interface

uses gorselnesne, paylasim;

const
  SecimDugmeNormal: array[1..12, 1..12] of TSayi1 = (
    (1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1),
    (1, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1),
    (1, 2, 3, 3, 4, 4, 4, 4, 3, 3, 4, 1),
    (1, 2, 3, 4, 4, 4, 4, 4, 4, 1, 4, 1),
    (2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 1, 4),
    (2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 1, 4),
    (2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 1, 4),
    (2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 1, 4),
    (1, 2, 3, 4, 4, 4, 4, 4, 4, 1, 4, 1),
    (1, 2, 1, 1, 4, 4, 4, 4, 1, 1, 4, 1),
    (1, 1, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1),
    (1, 1, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1));

  SecimDugmeSecili: array[1..12, 1..12] of TSayi1 = (
    (1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1),
    (1, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1),
    (1, 2, 3, 3, 4, 4, 4, 4, 3, 3, 4, 1),
    (1, 2, 3, 4, 4, 4, 4, 4, 4, 1, 4, 1),
    (2, 3, 4, 4, 4, 5, 5, 4, 4, 4, 1, 4),
    (2, 3, 4, 4, 5, 5, 5, 5, 4, 4, 1, 4),
    (2, 3, 4, 4, 5, 5, 5, 5, 4, 4, 1, 4),
    (2, 3, 4, 4, 4, 5, 5, 4, 4, 4, 1, 4),
    (1, 2, 3, 4, 4, 4, 4, 4, 4, 1, 4, 1),
    (1, 2, 1, 1, 4, 4, 4, 4, 1, 1, 4, 1),
    (1, 1, 4, 4, 1, 1, 1, 1, 4, 4, 1, 1),
    (1, 1, 1, 1, 4, 4, 4, 4, 1, 1, 1, 1));

type
  PSecimDugme = ^TSecimDugme;
  TSecimDugme = object(TGorselNesne)
  private
    FSecimDurumu: TSecimDurumu;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): PSecimDugme;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function SecimDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  seçim düğmesi çağrılarını yönetir
 ==============================================================================}
function SecimDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _SecimDugme: PSecimDugme;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PShortString(PSayi4(Degiskenler + 12)^ +
        AktifGorevBellekAdresi)^);

    $0104:
    begin

      _SecimDugme := PSecimDugme(_SecimDugme^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntSecimDugmesi));

      _SecimDugme^.FSecimDurumu := PSecimDurumu(Degiskenler + 04)^;
      _SecimDugme^.Ciz;
    end;

    ISLEV_GOSTER:
    begin

      _SecimDugme := PSecimDugme(_SecimDugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _SecimDugme^.Goster;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  seçim düğmesi nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;
var
  _SecimDugme: PSecimDugme;
begin

  _SecimDugme := _SecimDugme^.Olustur(AAtaKimlik, A1, B1, ABaslik);

  if(_SecimDugme = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _SecimDugme^.Kimlik;
end;

{==============================================================================
  seçim düğmesi nesnesini oluşturur
 ==============================================================================}
function TSecimDugme.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): PSecimDugme;
var
  _AtaNesne: PGorselNesne;
  _SecimDugme: PSecimDugme;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // seçim düğmesi için bellekte yer ayır
  _SecimDugme := PSecimDugme(Olustur0(gntSecimDugmesi));
  if(_SecimDugme = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // seçim düğmesi nesnesini üst nesneye ekle
  if(_SecimDugme^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _SecimDugme^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _SecimDugme^.GorevKimlik := AktifGorev;
  _SecimDugme^.AtaNesne := _AtaNesne;
  _SecimDugme^.Hiza := hzYok;
  _SecimDugme^.FBoyutlar.Sol2 := A1;
  _SecimDugme^.FBoyutlar.Ust2 := B1;
  _SecimDugme^.FBoyutlar.Genislik2 := 16 + 2 + (Length(ABaslik) * 8);
  _SecimDugme^.FBoyutlar.Yukseklik2 := 16;

  // kenar kalınlıkları
  _SecimDugme^.FKalinlik.Sol := 0;
  _SecimDugme^.FKalinlik.Ust := 0;
  _SecimDugme^.FKalinlik.Sag := 0;
  _SecimDugme^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _SecimDugme^.FKenarBosluklari.Sol := 0;
  _SecimDugme^.FKenarBosluklari.Ust := 0;
  _SecimDugme^.FKenarBosluklari.Sag := 0;
  _SecimDugme^.FKenarBosluklari.Alt := 0;

  _SecimDugme^.FAtaNesneMi := False;
  _SecimDugme^.FareGostergeTipi := fitOK;
  _SecimDugme^.Gorunum := False;
  _SecimDugme^.FSecimDurumu := sdNormal;

  // nesnenin ad ve başlık değeri
  _SecimDugme^.NesneAdi := NesneAdiAl(gntSecimDugmesi);
  _SecimDugme^.Baslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_SecimDugme^.GorevKimlik]^.OlayEkle1(_SecimDugme^.GorevKimlik,
    _SecimDugme, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _SecimDugme;
end;

{==============================================================================
  seçim düğmesi nesnesini görüntüler
 ==============================================================================}
procedure TSecimDugme.Goster;
var
  _Pencere: PPencere;
  _SecimDugme: PSecimDugme;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _SecimDugme := PSecimDugme(_SecimDugme^.NesneTipiniKontrolEt(Kimlik, gntSecimDugmesi));
  if(_SecimDugme = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_SecimDugme^.Gorunum = False) then
  begin

    // seçim düğmesi nesnesinin görünürlüğünü aktifleştir
    _SecimDugme^.Gorunum := True;

    // seçim düğmesi nesnesi ve üst nesneler görünür durumda mı ?
    if(_SecimDugme^.AtaNesneGorunurMu) then
    begin

      // görünür ise seçim düğmesi nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_SecimDugme);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  seçim düğmesi nesnesini çizer
 ==============================================================================}
procedure TSecimDugme.Ciz;
var
  _Pencere: PPencere;
  _SecimDugme: PSecimDugme;
  _Alan: TAlan;
  X, Y: TISayi4;
  _p: PSayi1;
begin

  _SecimDugme := PSecimDugme(_SecimDugme^.NesneTipiniKontrolEt(Kimlik, gntSecimDugmesi));
  if(_SecimDugme = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_SecimDugme);
  if(_Pencere = nil) then Exit;

  // seçim düğmesi üst nesneye bağlı olarak koordinatlarını al
  _Alan := _SecimDugme^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // seçim düğmesi çizim
  if(_SecimDugme^.FSecimDurumu = sdNormal) then
  begin

    _p := PByte(@SecimDugmeNormal);
    for Y := 1 to 12 do
    begin

      for X := 1 to 12 do
      begin

        case _p^ of
          1: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $D4D0C8);
          2: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $808080);
          3: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $404040);
          4: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, RENK_BEYAZ);
          5: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, RENK_SIYAH);
        end;

        Inc(_p);
      end;
    end;
  end
  else if(_SecimDugme^.FSecimDurumu = sdSecili) then
  begin

    _p := PByte(@SecimDugmeSecili);
    for Y := 1 to 12 do
    begin

      for X := 1 to 12 do
      begin

        case _p^ of
          1: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $D4D0C8);
          2: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $808080);
          3: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, $404040);
          4: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, RENK_BEYAZ);
          5: PixelYaz(_Pencere, _Alan.A1 + 1 + X, _Alan.B1 + 1 + Y, RENK_SIYAH);
        end;

        Inc(_p);
      end;
    end;
  end;

  // seçim düğmesi başlığı
  if(Length(_SecimDugme^.Baslik) > 0) then YaziYaz(_Pencere, _Alan.A1 + 17,
    _Alan.B1 + 1, _SecimDugme^.Baslik, RENK_SIYAH);

  // uygulamaya mesaj gönder
  GorevListesi[_SecimDugme^.GorevKimlik]^.OlayEkle1(_SecimDugme^.GorevKimlik,
    _SecimDugme, CO_CIZIM, 0, 0);
end;

{==============================================================================
  seçim düğmesi nesne olaylarını işler
 ==============================================================================}
procedure TSecimDugme.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _SecimDugme: PSecimDugme;
begin

  _SecimDugme := PSecimDugme(_SecimDugme^.NesneTipiniKontrolEt(AKimlik, gntSecimDugmesi));
  if(_SecimDugme = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // seçim düğmesinin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_SecimDugme);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_SecimDugme^.FareNesneOlayAlanindaMi(AKimlik)) then
      OlayYakalamayaBasla(_SecimDugme);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_SecimDugme);

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_SecimDugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // sadece seçim durumu normal (seçili değil) olduğunda işlem yap
      if(_SecimDugme^.FSecimDurumu = sdNormal) then
      begin

        _SecimDugme^.FSecimDurumu := sdSecili;
        GorevListesi[_SecimDugme^.GorevKimlik]^.OlayEkle1(_SecimDugme^.GorevKimlik,
          _SecimDugme, CO_DURUMDEGISTI, TSayi4(sdSecili) , 0);

        // seçim düğmesi nesnesini yeniden çiz
        _SecimDugme^.Ciz;
      end;
    end;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
