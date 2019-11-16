{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_resimdugme.pas
  Dosya İşlevi: resim düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_resimdugme;

interface

uses gorselnesne, paylasim;

type
  PResimDugme = ^TResimDugme;
  TResimDugme = object(TGorselNesne)
  private
    FDurum: TDugmeDurumu;

    // FDeger >= 0 = düğme içeriğine sistemde belirtilen sıradaki resmi çiz
    // FDeger < 0  = düğme içeriğini (FDeger and $FFFFFF) renk değeri ile doldur
    FDeger: TSayi4;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
      AResimSiraNo: TSayi4): PResimDugme;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  published
    property Durum: TDugmeDurumu read FDurum write FDurum;
  end;

function ResimDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  AResimSiraNo: TSayi4): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne, hamresim;

{==============================================================================
  resim düğme kesme çağrılarını yönetir
 ==============================================================================}
function ResimDugmeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _ResimDugme: PResimDugme;
  _Hiza: THiza;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PISayi4(Degiskenler + 20)^);

    ISLEV_GOSTER:
    begin

      _ResimDugme := PResimDugme(_ResimDugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _ResimDugme^.Goster;
    end;

    $0104:
    begin

      _ResimDugme := PResimDugme(_ResimDugme^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _ResimDugme^.Hiza := _Hiza;

      _Pencere := PPencere(_ResimDugme^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  resim düğme nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  AResimSiraNo: TSayi4): TKimlik;
var
  _ResimDugme: PResimDugme;
begin

  _ResimDugme := _ResimDugme^.Olustur(AtaKimlik, A1, B1, AGenislik, AYukseklik,
    AResimSiraNo);

  if(_ResimDugme = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _ResimDugme^.Kimlik;
end;

{==============================================================================
  resim düğme nesnesini oluşturur
 ==============================================================================}
function TResimDugme.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  AResimSiraNo: TSayi4): PResimDugme;
var
  _AtaNesne: PGorselNesne;
  _ResimDugme: PResimDugme;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // resim düğme nesnesi oluştur
  _ResimDugme := PResimDugme(Olustur0(gntResimDugme));
  if(_ResimDugme = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // resim düğme nesnesini ata nesneye ekle
  if(_ResimDugme^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _ResimDugme^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesnenin ilk özellik değerlerini ata
  _ResimDugme^.GorevKimlik := AktifGorev;
  _ResimDugme^.AtaNesne := _AtaNesne;
  _ResimDugme^.Hiza := hzYok;
  _ResimDugme^.FBoyutlar.Sol2 := A1;
  _ResimDugme^.FBoyutlar.Ust2 := B1;
  _ResimDugme^.FBoyutlar.Genislik2 := AGenislik;
  _ResimDugme^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _ResimDugme^.FKalinlik.Sol := 0;
  _ResimDugme^.FKalinlik.Ust := 0;
  _ResimDugme^.FKalinlik.Sag := 0;
  _ResimDugme^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _ResimDugme^.FKenarBosluklari.Sol := 0;
  _ResimDugme^.FKenarBosluklari.Ust := 0;
  _ResimDugme^.FKenarBosluklari.Sag := 0;
  _ResimDugme^.FKenarBosluklari.Alt := 0;

  _ResimDugme^.FAtaNesneMi := False;
  _ResimDugme^.FareGostergeTipi := fitOK;
  _ResimDugme^.Gorunum := False;
  _ResimDugme^.Baslik := '';
  _ResimDugme^.FDeger := AResimSiraNo;
  _ResimDugme^.Durum := ddNormal;

  // nesnenin ad değeri
  _ResimDugme^.NesneAdi := NesneAdiAl(gntResimDugme);

  // uygulamaya mesaj gönder
  GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
    CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _ResimDugme;
end;

{==============================================================================
  resim düğme nesnesini görüntüler
 ==============================================================================}
procedure TResimDugme.Goster;
var
  _Pencere: PPencere;
  _ResimDugme: PResimDugme;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ResimDugme := PResimDugme(_ResimDugme^.NesneTipiniKontrolEt(Kimlik, gntResimDugme));
  if(_ResimDugme = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_ResimDugme^.Gorunum = False) then
  begin

    // resim düğme nesnesinin görünürlüğünü aktifleştir
    _ResimDugme^.Gorunum := True;

    // ata nesne görünür durumda mı ?
    if(_ResimDugme^.AtaNesneGorunurMu) then
    begin

      // resim düğme nesnesinin ata nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_ResimDugme);

      // pencere nesnesini güncelle
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  resim düğme nesnesini çizer
 ==============================================================================}
procedure TResimDugme.Ciz;
var
  _Pencere: PPencere;
  _ResimDugme: PResimDugme;
  _Alan: TAlan;
  _ResimSiraNo: TSayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ResimDugme := PResimDugme(_ResimDugme^.NesneTipiniKontrolEt(Kimlik, gntResimDugme));
  if(_ResimDugme = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_ResimDugme);
  if(_Pencere = nil) then Exit;

  // resim düğmenin ata nesne olan pencere nesnesine bağlı olarak koordinatlarını al
  _Alan := _ResimDugme^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarlık çizimi
  if(_ResimDugme^.FDurum = ddNormal) then
    DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2,
      RENK_GUMUS, RENK_GUMUS)
  else
    DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2,
      RENK_SIYAH, RENK_SIYAH);

  // resim düğme içeriğinin resim ile çizilmesi
  if((_ResimDugme^.FDeger and $80000000) > 0) then
  begin

    _ResimSiraNo := _ResimDugme^.FDeger and $FFFFFF;

    // sistem kaynak resim sayısı şu an itibariyle 16 tanedir
    if(_ResimSiraNo > 15) then _ResimSiraNo := 0;

    KaynaktanResimCiz(_Pencere, _Alan.A1 + 1, _Alan.B1 + 1, _ResimSiraNo);
  end
  // resim düğme içeriğinin renk ile doldurulması
  else
    DikdortgenDoldur(_Pencere, _Alan.A1 + 1, _Alan.B1 + 1, _Alan.A2 - 1, _Alan.B2 - 1,
      _ResimDugme^.FDeger, _ResimDugme^.FDeger);

  // uygulamaya mesaj gönder
  GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
    CO_CIZIM, 0, 0);
end;

{==============================================================================
  resim düğme nesne olaylarını işler
 ==============================================================================}
procedure TResimDugme.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _ResimDugme: PResimDugme;
begin

  _ResimDugme := PResimDugme(_ResimDugme^.NesneTipiniKontrolEt(AKimlik, gntResimDugme));
  if(_ResimDugme = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // resim düğme'nin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_ResimDugme);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_ResimDugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_ResimDugme);

      // resim düğme'nin durumunu BASILI olarak belirle
      _ResimDugme^.Durum := ddBasili;

      // resim düğme nesnesini yeniden çiz
      _ResimDugme^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
        AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_ResimDugme);

    //  basılan resim düğmeyi eski konumuna geri getir
    _ResimDugme^.Durum := ddNormal;

    // resim düğme nesnesini yeniden çiz
    _ResimDugme^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_ResimDugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
        FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ve
    // 1 - fare göstergesi resim düğmenin içerisindeyse
    // 2 - fare göstergesi resim düğmenin dışarısındaysa
    // koşula göre resim düğmenin durumunu yeniden çiz ...
    if(YakalananGorselNesne <> nil) then
    begin

      if(_ResimDugme^.FareNesneOlayAlanindaMi(AKimlik)) then

        _ResimDugme^.Durum := ddBasili
      else _ResimDugme^.Durum := ddNormal;
    end;

    // resim düğme nesnesini yeniden çiz
    _ResimDugme^.Ciz;

    GorevListesi[_ResimDugme^.GorevKimlik]^.OlayEkle1(_ResimDugme^.GorevKimlik, _ResimDugme,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
