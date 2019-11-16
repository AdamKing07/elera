{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_durumcubugu.pas
  Dosya İşlevi: durum çubuğu yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_durumcubugu;

interface

uses gorselnesne, paylasim;

const
  // 1 = $FFFFFF
  // 2 = $808080
  DurumCubuguResim: array[1..12, 1..12] of Byte = (
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2),
    (0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0),
    (0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 1),
    (0, 0, 0, 0, 0, 0, 1, 2, 2, 0, 1, 2),
    (0, 0, 0, 0, 0, 1, 2, 2, 0, 1, 2, 2),
    (0, 0, 0, 0, 1, 2, 2, 0, 1, 2, 2, 0),
    (0, 0, 0, 1, 2, 2, 0, 1, 2, 2, 0, 1),
    (0, 0, 1, 2, 2, 0, 1, 2, 2, 0, 1, 2),
    (0, 1, 2, 2, 0, 1, 2, 2, 0, 1, 2, 2),
    (1, 2, 2, 0, 1, 2, 2, 0, 1, 2, 2, 0));

type
  PDurumCubugu = ^TDurumCubugu;
  TDurumCubugu = object(TGorselNesne)
  private
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADurumYazisi: string): PDurumCubugu;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function DurumCubuguCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  durum çubuğu kesme çağrılarını yönetir
 ==============================================================================}
function DurumCubuguCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _DurumCubugu: PDurumCubugu;
  p1: PShortString;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PShortString(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _DurumCubugu := PDurumCubugu(_DurumCubugu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _DurumCubugu^.Goster;
    end;

    // durum çubuğundaki veriyi değiştir
    $0104:
    begin

      _DurumCubugu := PDurumCubugu(_DurumCubugu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      _DurumCubugu^.Baslik := p1^;
      _DurumCubugu^.Ciz;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  durum çubuğu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik;
var
  _DurumCubugu: PDurumCubugu;
begin

  _DurumCubugu := _DurumCubugu^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik,
    ADurumYazisi);

  if(_DurumCubugu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _DurumCubugu^.Kimlik;
end;

{==============================================================================
  durum çubuğu nesnesini oluşturur
 ==============================================================================}
function TDurumCubugu.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): PDurumCubugu;
var
  _AtaNesne: PGorselNesne;
  _DurumCubugu: PDurumCubugu;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // durum çubuğu için bellekte yer ayır
  _DurumCubugu := PDurumCubugu(Olustur0(gntDurumCubugu));
  if(_DurumCubugu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // durum çubuğu nesnesini üst nesneye ekle
  if(_DurumCubugu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _DurumCubugu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _DurumCubugu^.GorevKimlik := AktifGorev;
  _DurumCubugu^.AtaNesne := _AtaNesne;
  _DurumCubugu^.Hiza := hzAlt;                        // alta hizala
  _DurumCubugu^.FBoyutlar.Sol2 := A1;
  _DurumCubugu^.FBoyutlar.Ust2 := B1;
  _DurumCubugu^.FBoyutlar.Genislik2 := AGenislik;
  _DurumCubugu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _DurumCubugu^.FKalinlik.Sol := 0;
  _DurumCubugu^.FKalinlik.Ust := 0;
  _DurumCubugu^.FKalinlik.Sag := 0;
  _DurumCubugu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _DurumCubugu^.FKenarBosluklari.Sol := 0;
  _DurumCubugu^.FKenarBosluklari.Ust := 0;
  _DurumCubugu^.FKenarBosluklari.Sag := 0;
  _DurumCubugu^.FKenarBosluklari.Alt := 0;

  _DurumCubugu^.FAtaNesneMi := False;
  _DurumCubugu^.FareGostergeTipi := fitOK;
  _DurumCubugu^.Gorunum := False;

  // nesnenin ad ve başlık değeri
  _DurumCubugu^.NesneAdi := NesneAdiAl(gntDurumCubugu);
  _DurumCubugu^.Baslik := ADurumYazisi;

  // uygulamaya mesaj gönder
  GorevListesi[_DurumCubugu^.GorevKimlik]^.OlayEkle1(_DurumCubugu^.GorevKimlik,
    _DurumCubugu, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _DurumCubugu;
end;

{==============================================================================
  durum çubuğu nesnesini görüntüler
 ==============================================================================}
procedure TDurumCubugu.Goster;
var
  _Pencere: PPencere;
  _DurumCubugu: PDurumCubugu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _DurumCubugu := PDurumCubugu(_DurumCubugu^.NesneTipiniKontrolEt(Kimlik, gntDurumCubugu));
  if(_DurumCubugu = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_DurumCubugu^.Gorunum = False) then
  begin

    // durum çubuğu nesnesinin görünürlüğünü aktifleştir
    _DurumCubugu^.Gorunum := True;

    // durum çubuğu nesnesi ve üst nesneler görünür durumda mı ?
    if(_DurumCubugu^.AtaNesneGorunurMu) then
    begin

      // görünür ise durum çubuğu nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_DurumCubugu);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  durum çubuğu nesnesini çizer
 ==============================================================================}
procedure TDurumCubugu.Ciz;
var
  _Pencere: PPencere;
  _DurumCubugu: PDurumCubugu;
  _Alan: TAlan;
  p1: PSayi1;
  X, Y, XX, YY: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _DurumCubugu := PDurumCubugu(_DurumCubugu^.NesneTipiniKontrolEt(Kimlik, gntDurumCubugu));
  if(_DurumCubugu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_DurumCubugu);
  if(_Pencere = nil) then Exit;

  // durum çubuğunun üst nesneye bağlı olarak koordinatlarını al
  _Alan := _DurumCubugu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarlık çizgisini çiz
  KenarlikCiz(_Pencere, _Alan, 1);

  // iç dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.A1 + 1, _Alan.B1 + 1, _Alan.A2 - 1, _Alan.B2 - 1,
    $D4D0C8, $D4D0C8);

  XX := _Alan.A2 - 12 - 1;
  YY := _Alan.B2 - 12 - 1;

  p1 := PByte(@DurumCubuguResim);
  for Y := 1 to 12 do
  begin

    for X := 1 to 12 do
    begin

      if(p1^ = 1) then
        PixelYaz(_Pencere, XX + X, YY + Y, RENK_BEYAZ)
      else if(p1^ = 2) then
        PixelYaz(_Pencere, XX + X, YY + Y, $808080);

      Inc(p1);
    end;
  end;

  // durum çubuğu başlığı
  YaziYaz(_Pencere, _Alan.A1 + 3, _Alan.B1 + 2, _DurumCubugu^.Baslik, RENK_SIYAH);

  // uygulamaya mesaj gönder
  {GorevListesi[_DurumCubugu^.GorevKimlik]^.EventAdd1(_DurumCubugu^.GorevKimlik,
    _DurumCubugu, CO_CIZIM, 0, 0);}
end;

{==============================================================================
  durum çubuğu olaylarını işler
 ==============================================================================}
procedure TDurumCubugu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _DurumCubugu: PDurumCubugu;
begin

  _DurumCubugu := PDurumCubugu(_DurumCubugu^.NesneTipiniKontrolEt(AKimlik, gntDurumCubugu));
  if(_DurumCubugu = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // durum çubuğunun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_DurumCubugu);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    if(FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_DurumCubugu);
    end;
 end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_DurumCubugu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      GorevListesi[_DurumCubugu^.GorevKimlik]^.OlayEkle1(_DurumCubugu^.GorevKimlik,
        _DurumCubugu, FO_TIKLAMA, 0, 0)
    end;

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_DurumCubugu);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
