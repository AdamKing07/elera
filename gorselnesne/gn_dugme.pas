{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_dugme.pas
  Dosya İşlevi: düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_dugme;

interface

uses gorselnesne, paylasim;

type
  PDugme = ^TDugme;
  TDugme = object(TGorselNesne)
  private
    FDurum: TDugmeDurumu;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): PDugme;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  published
    property Durum: TDugmeDurumu read FDurum write FDurum;
  end;

function DugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne, giysi, sistemmesaj;

{==============================================================================
  düğme kesme çağrılarını yönetir
 ==============================================================================}
function DugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _Dugme: PDugme;
  _Hiza: THiza;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PKarakterKatari(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _Dugme := PDugme(_Dugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Dugme^.Goster;
    end;

    $0104:
    begin

      _Dugme := PDugme(_Dugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _Dugme^.Hiza := _Hiza;

      _Pencere := PPencere(_Dugme^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  düğme nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TKimlik;
  ABaslik: string): TKimlik;
var
  _Dugme: PDugme;
begin

  _Dugme := _Dugme^.Olustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);

  if(_Dugme = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Dugme^.Kimlik;
end;

{==============================================================================
  düğme nesnesini oluşturur
 ==============================================================================}
function TDugme.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): PDugme;
var
  _AtaNesne: PGorselNesne;
  _Dugme: PDugme;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // düğme nesnesi oluştur
  _Dugme := PDugme(Olustur0(gntDugme));
  if(_Dugme = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // düğme nesnesini ata nesneye ekle
  if(_Dugme^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Dugme^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesnenin ilk özellik değerlerini ata
  _Dugme^.GorevKimlik := AktifGorev;
  _Dugme^.AtaNesne := _AtaNesne;
  _Dugme^.Hiza := hzYok;
  _Dugme^.FBoyutlar.Sol2 := A1;
  _Dugme^.FBoyutlar.Ust2 := B1;
  _Dugme^.FBoyutlar.Genislik2 := AGenislik;
  _Dugme^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _Dugme^.FKalinlik.Sol := 0;
  _Dugme^.FKalinlik.Ust := 0;
  _Dugme^.FKalinlik.Sag := 0;
  _Dugme^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Dugme^.FKenarBosluklari.Sol := 0;
  _Dugme^.FKenarBosluklari.Ust := 0;
  _Dugme^.FKenarBosluklari.Sag := 0;
  _Dugme^.FKenarBosluklari.Alt := 0;

  _Dugme^.FAtaNesneMi := False;
  _Dugme^.FareGostergeTipi := fitOK;
  _Dugme^.Gorunum := False;
  _Dugme^.Baslik := ABaslik;
  _Dugme^.Durum := ddNormal;

  // nesnenin ad değeri
  _Dugme^.NesneAdi := NesneAdiAl(gntDugme);

  // uygulamaya mesaj gönder
  GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
    CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Dugme;
end;

{==============================================================================
  düğme nesnesini görüntüler
 ==============================================================================}
procedure TDugme.Goster;
var
  _Pencere: PPencere;
  _Dugme: PDugme;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Dugme := PDugme(_Dugme^.NesneTipiniKontrolEt(Kimlik, gntDugme));
  if(_Dugme = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Dugme^.Gorunum = False) then
  begin

    // düğme nesnesinin görünürlüğünü aktifleştir
    _Dugme^.Gorunum := True;

    // ata nesne görünür durumda mı ?
    if(_Dugme^.AtaNesneGorunurMu) then
    begin

      // düğme nesnesinin ata nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Dugme);

      // pencere nesnesini güncelle
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  düğme nesnesini çizer
 ==============================================================================}
procedure TDugme.Ciz;
var
  _Pencere: PPencere;
  _Dugme: PDugme;
  _Alan: TAlan;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Dugme := PDugme(_Dugme^.NesneTipiniKontrolEt(Kimlik, gntDugme));
  if(_Dugme = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Dugme);
  if(_Pencere = nil) then Exit;

  // düğmenin ata nesne olan pencere nesnesine bağlı olarak koordinatlarını al
  _Alan := _Dugme^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // düğme başlığı
  if(_Dugme^.Durum = ddNormal) then
  begin

    // artan renk ile (eğimli) doldur
    EgimliDoldur(_Pencere, _Alan, DUGME_NORMAL_ILKRENK, DUGME_NORMAL_SONRENK);

    YaziYaz(_Pencere, _Alan.A1 + 4, _Alan.B1 + 4, _Dugme^.Baslik, DUGME_NORMAL_YAZIRENK)
  end
  else
  begin

    // artan renk ile (eğimli) doldur
    EgimliDoldur(_Pencere, _Alan, DUGME_BASILI_ILKRENK, DUGME_BASILI_SONRENK);

    YaziYaz(_Pencere, _Alan.A1 + 4, _Alan.B1 + 4, _Dugme^.Baslik, DUGME_BASILI_YAZIRENK);
  end;

  // uygulamaya mesaj gönder
  GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
    CO_CIZIM, 0, 0);
end;

{==============================================================================
  düğme nesne olaylarını işler
 ==============================================================================}
procedure TDugme.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Dugme: PDugme;
begin

  _Dugme := PDugme(_Dugme^.NesneTipiniKontrolEt(AKimlik, gntDugme));
  if(_Dugme = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // düğme'nin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_Dugme);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_Dugme);

      // düğme'nin durumunu BASILI olarak belirle
      _Dugme^.Durum := ddBasili;

      // düğme nesnesini yeniden çiz
      _Dugme^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
        AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_Dugme);

    //  basılan düğmeyi eski konumuna geri getir
    _Dugme^.Durum := ddNormal;

    // düğme nesnesini yeniden çiz
    _Dugme^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
        FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ve
    // 1 - fare göstergesi düğmenin içerisindeyse
    // 2 - fare göstergesi düğmenin dışarısındaysa
    // koşula göre düğmenin durumunu yeniden çiz ...
    if(YakalananGorselNesne <> nil) then
    begin

      if(_Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then

        _Dugme^.Durum := ddBasili
      else _Dugme^.Durum := ddNormal;
    end;

    // düğme nesnesini yeniden çiz
    _Dugme^.Ciz;

    GorevListesi[_Dugme^.GorevKimlik]^.OlayEkle1(_Dugme^.GorevKimlik, _Dugme,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
