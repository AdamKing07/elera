{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_gucdugme.pas
  Dosya İşlevi: güç düğmesi yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_gucdugme;

interface

uses gorselnesne, paylasim;

type
  PGucDugme = ^TGucDugme;
  TGucDugme = object(TGorselNesne)
  private
    FDurum: TDugmeDurumu;
  public
    function Create(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): PGucDugme;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: THandle; AOlay: TOlayKayit);
    procedure DurumYaz(AKimlik: TKimlik; ADurum: TSayi4);
  end;

function GucDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_islevler, gn_pencere, temelgorselnesne, giysi;

{==============================================================================
  güç düğmesi kesme çağrılarını yönetir
 ==============================================================================}
function GucDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _GucDugme: PGucDugme;
begin

  case IslevNo of
    ISLEV_OLUSTUR: Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
      PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
      PShortString(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _GucDugme := PGucDugme(_GucDugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _GucDugme^.Goster;
    end;

    // düğme durumunu değiştir
    $0204:
    begin

      _GucDugme := PGucDugme(_GucDugme^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntGucDugme));
      if(_GucDugme <> nil) then
        _GucDugme^.DurumYaz(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^);
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  güç düğmesi nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
var
  _GucDugme: PGucDugme;
begin

  _GucDugme := _GucDugme^.Create(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);

  if(_GucDugme = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _GucDugme^.Kimlik;
end;

{==============================================================================
  güç düğmesi nesnesini oluşturur
 ==============================================================================}
function TGucDugme.Create(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): PGucDugme;
var
  _AtaNesne: PGorselNesne;
  _GucDugme: PGucDugme;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // güç düğmesi için bellekte yer ayır
  _GucDugme := PGucDugme(Olustur0(gntGucDugme));
  if(_GucDugme = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // güç düğmesi nesnesini üst nesneye ekle
  if(_GucDugme^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _GucDugme^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _GucDugme^.GorevKimlik := CalisanGorev;
  _GucDugme^.AtaNesne := _AtaNesne;
  _GucDugme^.Hiza := hzYok;
  _GucDugme^.FBoyutlar.Sol2 := A1;
  _GucDugme^.FBoyutlar.Ust2 := B1;
  _GucDugme^.FBoyutlar.Genislik2 := AGenislik;
  _GucDugme^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _GucDugme^.FKalinlik.Sol := 0;
  _GucDugme^.FKalinlik.Ust := 0;
  _GucDugme^.FKalinlik.Sag := 0;
  _GucDugme^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _GucDugme^.FKenarBosluklari.Sol := 0;
  _GucDugme^.FKenarBosluklari.Ust := 0;
  _GucDugme^.FKenarBosluklari.Sag := 0;
  _GucDugme^.FKenarBosluklari.Alt := 0;

  _GucDugme^.FAtaNesneMi := False;
  _GucDugme^.FareGostergeTipi := fitOK;
  _GucDugme^.FGorunum := False;
  _GucDugme^.FDurum := ddNormal;

  // nesnenin ad ve başlık değeri
  _GucDugme^.NesneAdi := NesneAdiAl(gntGucDugme);
  _GucDugme^.FBaslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_GucDugme^.GorevKimlik]^.OlayEkle1(_GucDugme^.GorevKimlik,
    _GucDugme, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _GucDugme;
end;

{==============================================================================
  güç düğmesi nesnesini görüntüler
 ==============================================================================}
procedure TGucDugme.Goster;
var
  _Pencere: PPencere;
  _GucDugme: PGucDugme;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _GucDugme := PGucDugme(_GucDugme^.NesneTipiniKontrolEt(Kimlik, gntGucDugme));
  if(_GucDugme = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_GucDugme^.FGorunum = False) then
  begin

    // güç düğmesi nesnesinin görünürlüğünü aktifleştir
    _GucDugme^.FGorunum := True;

    // güç düğmesi nesnesi ve üst nesneler görünür durumda mı ?
    if(_GucDugme^.AtaNesneGorunurMu) then
    begin

      // görünür ise güç düğmesi nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_GucDugme);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  güç düğmesi nesnesini çizer
 ==============================================================================}
procedure TGucDugme.Ciz;
var
  _Pencere: PPencere;
  _GucDugme: PGucDugme;
  _Alan: TAlan;
begin

  _GucDugme := PGucDugme(_GucDugme^.NesneTipiniKontrolEt(Kimlik, gntGucDugme));
  if(_GucDugme = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_GucDugme);
  if(_Pencere = nil) then Exit;

  // güç düğmesinin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _GucDugme^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // güç düğmesinin durumunu test et
  if(_GucDugme^.FDurum = ddNormal) then
  begin

    EgimliDoldur(_Pencere, _Alan, DUGME_NORMAL_ILKRENK, DUGME_NORMAL_SONRENK);

    // düğmenin başlığı
    YaziYaz(_Pencere, _Alan.Sol + 4, _Alan.Ust + 4, _GucDugme^.FBaslik,
      DUGME_NORMAL_YAZIRENK);
  end
  else if(_GucDugme^.FDurum = ddBasili) then
  begin

    EgimliDoldur(_Pencere, _Alan, DUGME_BASILI_ILKRENK, DUGME_BASILI_SONRENK);

    // düğmenin başlığı
    YaziYaz(_Pencere, _Alan.Sol + 5, _Alan.Ust + 5, _GucDugme^.FBaslik,
      DUGME_BASILI_YAZIRENK);
  end;

  GorevListesi[_GucDugme^.GorevKimlik]^.OlayEkle1(_GucDugme^.GorevKimlik,
    _GucDugme, CO_CIZIM, 0, 0);
end;

{==============================================================================
  güç düğmesi nesne olaylarını işler
 ==============================================================================}
procedure TGucDugme.OlaylariIsle(AKimlik: THandle; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _GucDugme: PGucDugme;
  i: TISayi4;
begin

  _GucDugme := PGucDugme(_GucDugme^.NesneTipiniKontrolEt(AKimlik, gntGucDugme));
  if(_GucDugme = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // güç düğmesinin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_GucDugme);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // fare olaylarını yakala
    OlayYakalamayaBasla(_GucDugme);

    // güç düğmesinin durumunu NORMAL / BASILI olarak değiştir
    if(_GucDugme^.FDurum = ddBasili) then
    begin

      i := 0;
      _GucDugme^.FDurum := ddNormal;
    end
    else
    begin

      i := 1;
      _GucDugme^.FDurum := ddBasili;
    end;

    // güç düğmesi nesnesini yeniden çiz
    _GucDugme^.Ciz;

    // uygulamaya mesaj gönder
    GorevListesi[_GucDugme^.GorevKimlik]^.OlayEkle1(_GucDugme^.GorevKimlik,
      _GucDugme, CO_DURUMDEGISTI, i, 0);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_GucDugme);
  end
  else if(AOlay.Olay = CO_NORMALDURUMAGEC) then
  begin

    if(_GucDugme^.FDurum = ddBasili) then
    begin

      _GucDugme^.FDurum := ddNormal;

      // güç düğmesi nesnesini yeniden çiz
      _GucDugme^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_GucDugme^.GorevKimlik]^.OlayEkle1(_GucDugme^.GorevKimlik,
        _GucDugme, CO_DURUMDEGISTI, 0, 0);
    end;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

{==============================================================================
  güç düğmesi nesnesinin durumunu değiştirir
 ==============================================================================}
procedure TGucDugme.DurumYaz(AKimlik: TKimlik; ADurum: TSayi4);
var
  _GucDugme: PGucDugme;
begin

  _GucDugme := PGucDugme(_GucDugme^.NesneTipiniKontrolEt(AKimlik, gntGucDugme));
  if(_GucDugme = nil) then Exit;

  if(ADurum = 1) then

    _GucDugme^.FDurum := ddBasili
  else _GucDugme^.FDurum := ddNormal;

  _GucDugme^.Ciz;
end;

end.
