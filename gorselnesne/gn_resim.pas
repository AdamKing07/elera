{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_resim.pas
  Dosya İşlevi: resim nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 08/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_resim;

interface

uses gorselnesne, paylasim, temelgorselnesne;

type
  PResim = ^TResim;
  TResim = object(TGorselNesne)
  public
    FTuvaleSigdir: LongBool;
    FGoruntuYapi: TGoruntuYapi;
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADosyaYolu: string): PResim;
    procedure ResimYaz(ADosyaYolu: string);
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function ResimCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADosyaYolu: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, bmp;

{==============================================================================
  resim nesnesi kesme çağrılarını yönetir
 ==============================================================================}
function ResimCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _Resim: PResim;
  _Hiza: THiza;
  p: PShortString;
  _TuvaleSigdir: Boolean;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PShortString(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _Resim := PResim(_Resim^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Resim^.Goster;
    end;

    $0104:
    begin

      _Resim := PResim(_Resim^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _Resim^.Hiza := _Hiza;

      _Pencere := PPencere(_Resim^.FAtaNesne);
      _Pencere^.Guncelle;
    end;

    // resmi değiştir
    $0204:
    begin

      _Resim := PResim(_Resim^.NesneAl(PKimlik(Degiskenler + 00)^));
      p := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      _Resim^.ResimYaz(p^);
    end;

    $0304:
    begin

      _Resim := PResim(_Resim^.NesneAl(PKimlik(Degiskenler + 00)^));
      _TuvaleSigdir := PLongBool(Degiskenler + 04)^;
      _Resim^.FTuvaleSigdir := _TuvaleSigdir;

      _Pencere := PPencere(_Resim^.FAtaNesne);
      _Pencere^.Guncelle;
    end;

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  resim nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADosyaYolu: string): TKimlik;
var
  _Resim: PResim;
begin

  _Resim := _Resim^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADosyaYolu);

  if(_Resim = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Resim^.Kimlik;
end;

{==============================================================================
  resim nesnesini oluşturur
 ==============================================================================}
function TResim.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADosyaYolu: string): PResim;
var
  _AtaNesne: PGorselNesne;
  _Resim: PResim;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // resim nesnesi için bellekte yer ayır
  _Resim := PResim(Olustur0(gntResim));
  if(_Resim = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // resim nesnesini üst nesneye ekle
  if(_Resim^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Resim^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Resim^.GorevKimlik := CalisanGorev;
  _Resim^.AtaNesne := _AtaNesne;
  _Resim^.FTuvaleSigdir := False;
  _Resim^.Hiza := hzYok;
  _Resim^.FBoyutlar.Sol2 := A1;
  _Resim^.FBoyutlar.Ust2 := B1;
  _Resim^.FBoyutlar.Genislik2 := AGenislik;
  _Resim^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _Resim^.FKalinlik.Sol := 0;
  _Resim^.FKalinlik.Ust := 0;
  _Resim^.FKalinlik.Sag := 0;
  _Resim^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Resim^.FKenarBosluklari.Sol := 0;
  _Resim^.FKenarBosluklari.Ust := 0;
  _Resim^.FKenarBosluklari.Sag := 0;
  _Resim^.FKenarBosluklari.Alt := 0;

  _Resim^.FAtaNesneMi := False;
  _Resim^.FareGostergeTipi := fitOK;
  _Resim^.FGorunum := False;
  _Resim^.FGoruntuYapi.BellekAdresi := nil;

  // nesnenin ad ve başlık değeri
  _Resim^.NesneAdi := NesneAdiAl(gntResim);
  _Resim^.FBaslik := '';

  // eğer dosya adı belirtilmişse, dosyayı yükle
  if(Length(ADosyaYolu) > 0) then ResimYaz(ADosyaYolu);

  // uygulamaya mesaj gönder
  GorevListesi[_Resim^.GorevKimlik]^.OlayEkle1(_Resim^.GorevKimlik, _Resim,
    CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Resim;
end;

{==============================================================================
  resim değerini belirler
 ==============================================================================}
procedure TResim.ResimYaz(ADosyaYolu: string);
var
  _Resim: PResim;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Resim := PResim(_Resim^.NesneTipiniKontrolEt(Kimlik, gntResim));
  if(_Resim = nil) then Exit;

  // daha önce resim için bellek rezerv edildiyse belleği iptal et
  if not(_Resim^.FGoruntuYapi.BellekAdresi = nil) then
  begin

    GGercekBellek.YokEt(_Resim^.FGoruntuYapi.BellekAdresi, _Resim^.FGoruntuYapi.Genislik *
      _Resim^.FGoruntuYapi.Yukseklik * 4);
    _Resim^.FGoruntuYapi.BellekAdresi := nil;
  end;

  if(Length(ADosyaYolu) > 0) then _Resim^.FGoruntuYapi := BMPDosyasiYukle(ADosyaYolu);

  Ciz;
end;

{==============================================================================
  resim nesnesini görüntüler
 ==============================================================================}
procedure TResim.Goster;
var
  _Pencere: PPencere;
  _Resim: PResim;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Resim := PResim(_Resim^.NesneTipiniKontrolEt(Kimlik, gntResim));
  if(_Resim = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Resim^.FGorunum = False) then
  begin

    // resim nesnesinin görünürlüğünü aktifleştir
    _Resim^.FGorunum := True;

    // resim nesnesi ve üst nesneler görünür durumda mı ?
    if(_Resim^.AtaNesneGorunurMu) then
    begin

      // görünür ise düğme nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Resim);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  resim nesnesini çizer
 ==============================================================================}
procedure TResim.Ciz;
var
  _Pencere: PPencere;
  _Resim: PResim;
  _Alan: TAlan;
begin

  _Resim := PResim(_Resim^.NesneTipiniKontrolEt(Kimlik, gntResim));
  if(_Resim = nil) then Exit;

  _Pencere := PPencere(_Resim^.AtaNesne);

  if(_Resim^.FGorunum) then
  begin

    // resim nesnesinin üst nesneye bağlı olarak koordinatlarını al
    _Alan := _Resim^.CizimGorselNesneBoyutlariniAl(Kimlik);
    DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sag, _Alan.Alt, RENK_BEYAZ,
      RENK_BEYAZ);

    if not(_Resim^.FGoruntuYapi.BellekAdresi = nil) then
      ResimCiz(gntResim, _Resim^.Kimlik, _Resim^.FGoruntuYapi);
  end;
end;

{==============================================================================
  resim nesne olaylarını işler
 ==============================================================================}
procedure TResim.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Resim: PResim;
begin

  _Resim := PResim(_Resim^.NesneTipiniKontrolEt(AKimlik, gntResim));
  if(_Resim = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // resim nesnesinin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_Resim);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // fare olaylarını yakala
    OlayYakalamayaBasla(_Resim);

    // uygulamaya mesaj gönder
    GorevListesi[_Resim^.GorevKimlik]^.OlayEkle1(_Resim^.GorevKimlik, _Resim,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_Resim);

    // uygulamaya mesaj gönder
    GorevListesi[_Resim^.GorevKimlik]^.OlayEkle1(_Resim^.GorevKimlik, _Resim,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Resim^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_Resim^.GorevKimlik]^.OlayEkle1(_Resim^.GorevKimlik, _Resim,
        FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    GorevListesi[_Resim^.GorevKimlik]^.OlayEkle1(_Resim^.GorevKimlik, _Resim,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
