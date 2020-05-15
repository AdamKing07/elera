{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_masaustu.pas
  Dosya İşlevi: masaüstü yönetim işlevlerini içerir

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_masaustu;

interface

uses gorselnesne, paylasim;

type
  PMasaustu = ^TMasaustu;
  TMasaustu = object(TGorselNesne)
  public
    FMasaustuArkaPlan: TISayi4;       // 1 = renk değeri, 2 = resim
    FMasaustuRenk: TRenk;
    FGoruntuYapi: TGoruntuYapi;
    FMenu: PGorselNesne;              // PMenu veya PAcilirMenu
    function Olustur(AMasaustuAdi: string): PMasaustu;
    function Olustur2: PMasaustu;
    procedure MasaustuRenginiDegistir;
    procedure Goster;
    procedure Ciz;
    procedure Guncelle;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
    procedure Kesme_MasaustuRenginiDegistir(ARenk: TRenk);
    procedure Kesme_MasaustuResminiDegistir(ADosyaYolu: string);
  end;

function MasaustuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AMasaustuAdi: string): TKimlik;

implementation

uses gn_islevler, genel, bmp, temelgorselnesne;

{==============================================================================
  masaüstü kesme çağrılarını yönetir
 ==============================================================================}
function MasaustuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Masaustu: PMasaustu;
  i: TISayi4;
begin

  case IslevNo of

    ISLEV_OLUSTUR: Result := NesneOlustur(PShortString(PSayi4(Degiskenler + 04)^ +
      AktifGorevBellekAdresi)^);

    // oluşturulmuş toplam masaüstü sayısı
    $0102:
    begin

      Result := ToplamMasaustu;
    end;

    // aktif masaüstü kimliği
    $0402:
    begin

      Result := GAktifMasaustu^.Kimlik;
    end;

    $0104:
    begin

      // aktifleştirilecek masaüstü sıra numarasını al
      i := PISayi4(Degiskenler + 00)^;

      // eğer belirtilen aralıktaysa ...
      if(i > 0) and (i <= USTSINIR_MASAUSTU) then
      begin

        // belirlenen sıradaki masüstü mevcut ise
        if(MasaustuListesi[i] <> nil) then
        begin

          // masaüstünü aktif olarak işaretle
          GAktifMasaustu := MasaustuListesi[i];

          // masaüstü ve alt nesnelerinin hepsini yeniden çiz
          GAktifMasaustu^.Guncelle;

          // işlemin başarılı olduğuna dair mesajı geri döndür
          Result := TISayi4(True);

        end else Result := TISayi4(False);
      end else Result := TISayi4(False);
    end;

    // masaüstü rengini değiştir
    $0204:
    begin

      _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntMasaustu));
      if(_Masaustu <> nil) then _Masaustu^.Kesme_MasaustuRenginiDegistir(
        PRenk(Degiskenler + 04)^);
    end;

    // masaüstü resmini değiştir
    $0404:
    begin

      _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntMasaustu));
      if(_Masaustu <> nil) then _Masaustu^.Kesme_MasaustuResminiDegistir(
        PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^);
    end;

    // masaüstünü güncelleştir (yeniden çiz)
    $0804:
    begin

      _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntMasaustu));
      if(_Masaustu <> nil) then _Masaustu^.Guncelle;
    end;

    ISLEV_GOSTER:
    begin

      _Masaustu := PMasaustu(_Masaustu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Masaustu^.Goster;
    end else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  masaüstü nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AMasaustuAdi: string): TKimlik;
var
  _Masaustu: PMasaustu;
begin

  _Masaustu := _Masaustu^.Olustur(AMasaustuAdi);
  if(_Masaustu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Masaustu^.Kimlik;
end;

{==============================================================================
  masaüstü nesnesini oluşturur
 ==============================================================================}
function TMasaustu.Olustur(AMasaustuAdi: string): PMasaustu;
var
  _Masaustu: PMasaustu;
begin

  // masaüstü nesnesi oluştur
  _Masaustu := Olustur2;
  if(_Masaustu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Masaustu^.GorevKimlik := CalisanGorev;
  _Masaustu^.AtaNesne := nil;
  _Masaustu^.Hiza := hzYok;
  _Masaustu^.FBoyutlar.Sol2 := 0;
  _Masaustu^.FBoyutlar.Ust2 := 0;
  _Masaustu^.FBoyutlar.Genislik2 := GEkranKartSurucusu.KartBilgisi.YatayCozunurluk;
  _Masaustu^.FBoyutlar.Yukseklik2 := GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk;

  // kenar kalınlıkları
  _Masaustu^.FKalinlik.Sol := 0;
  _Masaustu^.FKalinlik.Ust := 0;
  _Masaustu^.FKalinlik.Sag := 0;
  _Masaustu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Masaustu^.FKenarBosluklari.Sol := 0;
  _Masaustu^.FKenarBosluklari.Ust := 0;
  _Masaustu^.FKenarBosluklari.Sag := 0;
  _Masaustu^.FKenarBosluklari.Alt := 0;

  // nesnenin iç ve dış boyutlarını yeniden hesapla
  _Masaustu^.IcVeDisBoyutlariYenidenHesapla;

  _Masaustu^.FAtaNesneMi := True;
  _Masaustu^.AltNesneSayisi := 0;
  _Masaustu^.FAltNesneBellekAdresi := nil;
  _Masaustu^.FareGostergeTipi := fitOK;
  _Masaustu^.FGorunum := False;
  _Masaustu^.FMasaustuArkaPlan := 1;        // masaüstü arkaplan renk değeri kullanılacak
  _Masaustu^.FMasaustuRenk := RENK_SIYAH;
  _Masaustu^.FMenu := nil;

  // nesnenin ad ve başlık değeri
  _Masaustu^.NesneAdi := NesneAdiAl(gntMasaustu);
  _Masaustu^.FBaslik := AMasaustuAdi;

  // masaüstünün çizileceği bellek adresi
  _Masaustu^.FCizimBellekAdresi := GGercekBellek.Ayir(_Masaustu^.FBoyutlar.Genislik2 *
    _Masaustu^.FBoyutlar.Yukseklik2 * 4);

  // masaüstüne çizilecek resmin bellek bilgileri
  _Masaustu^.FGoruntuYapi.BellekAdresi := nil;

  // uygulamaya mesaj gönder
  GorevListesi[_Masaustu^.GorevKimlik]^.OlayEkle1(_Masaustu^.GorevKimlik,
    _Masaustu, CO_OLUSTUR, 0, 0);

  // geri dönüş değeri
  Result := _Masaustu;
end;

{==============================================================================
  masaüstü nesnesi için yer tahsis eder
 ==============================================================================}
function TMasaustu.Olustur2: PMasaustu;
var
  _Masaustu: PMasaustu;
  i: TSayi4;
begin

  Result := nil;

  // tüm masaüstü nesneleri oluşturulduysa çık
  if(ToplamMasaustu >= USTSINIR_MASAUSTU) then Exit;

  _Masaustu := PMasaustu(_Masaustu^.Olustur0(gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // masaüstü nesnesi için bellekte boş yer bul
  for i := 1 to USTSINIR_MASAUSTU do
  begin

    if(MasaustuListesi[i] = nil) then
    begin

      // 1. masaüstü kimliğini bulunan boş olarak bulunan yere kaydet
      // 2. oluşturulan masaüstü nesne sayısını artır
      // 3. geriye nesneyi döndür
      MasaustuListesi[i] := _Masaustu;
      Inc(ToplamMasaustu);

      // masaüstü kimliğini geri döndür
      Exit(_Masaustu);
    end;
  end;
end;

{==============================================================================
  masaüstünü aktifleştirir / görüntüler
 ==============================================================================}
procedure TMasaustu.Goster;
var
  _Masaustu: PMasaustu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // eğer masaüstü nesnesi aktif değil ise
  if(_Masaustu <> GAktifMasaustu) then
  begin

    // aktif masaüstü olarak belirle
    GAktifMasaustu := _Masaustu;

    // nesnenin görünürlüğünü aktifleştir
    GAktifMasaustu^.FGorunum := True;

    // masaüstü ve alt nesnelerinin hepsini yeniden çiz
    GAktifMasaustu^.Guncelle;
  end;
end;

{==============================================================================
  masaüstü ve alt nesnelerin tümünü yeniden çizer
 ==============================================================================}
procedure TMasaustu.Guncelle;
var
  _Masaustu: PMasaustu;
begin

  // geçerli masaüstü var mı ? test et. yok ise çık
  _Masaustu := GAktifMasaustu;
  if(_Masaustu = nil) then Exit;

  // masaüstünü çiz
  _Masaustu^.Ciz;
end;

{==============================================================================
  masaüstünü çizer
 ==============================================================================}
procedure TMasaustu.Ciz;
var
  _Masaustu: PMasaustu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // masaüstü arka plan resmini çiz
  if(_Masaustu^.FMasaustuArkaPlan = 1) then
    MasaustuRenginiDegistir
  else BMPGoruntusuCiz(gntMasaustu, _Masaustu^.Kimlik, _Masaustu^.FGoruntuYapi);

  // uygulamaya mesaj gönder
  GorevListesi[_Masaustu^.GorevKimlik]^.OlayEkle1(_Masaustu^.GorevKimlik,
    _Masaustu, CO_CIZIM, 0, 0);
end;

{==============================================================================
  masaüstünü belirtilen renk değeri ile boyar
 ==============================================================================}
procedure TMasaustu.MasaustuRenginiDegistir;
var
  _Masaustu: PMasaustu;
  _A1, _B1: TISayi4;
  _Renk: TRenk;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  FMasaustuArkaPlan := 1;

  _Renk := _Masaustu^.FMasaustuRenk;

  for _B1 := _Masaustu^.FDisGercekBoyutlar.Ust to _Masaustu^.FDisGercekBoyutlar.Alt do
  begin

    for _A1 := _Masaustu^.FDisGercekBoyutlar.Sol to _Masaustu^.FDisGercekBoyutlar.Sag do
    begin

      GEkranKartSurucusu.NoktaYaz(_Masaustu, _A1, _B1, _Renk, False);
    end;
  end;
end;

{==============================================================================
  masaüstü olaylarını işler
 ==============================================================================}
procedure TMasaustu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Masaustu: PMasaustu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(AKimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // sağ / sol fare tuş basımı
  if(AOlay.Olay = FO_SAGTUS_BASILDI) or (AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // olayları bu nesneye yönlendir
    OlayYakalamayaBasla(_Masaustu);

    // uygulamaya mesaj gönder
    GorevListesi[_Masaustu^.GorevKimlik]^.OlayEkle1(_Masaustu^.GorevKimlik,
      _Masaustu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  // sağ / sol fare tuş bırakımı
  else if(AOlay.Olay = FO_SAGTUS_BIRAKILDI) or (AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // olayları bu nesneye yönlendirmeyi iptal et
    OlayYakalamayiBirak(_Masaustu);

    // uygulamaya mesaj gönder
    if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
      GorevListesi[_Masaustu^.GorevKimlik]^.OlayEkle1(_Masaustu^.GorevKimlik,
        _Masaustu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);

    GorevListesi[_Masaustu^.GorevKimlik]^.OlayEkle1(_Masaustu^.GorevKimlik,
      _Masaustu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

{==============================================================================
  masaüstü renk değerini değiştirir - kesme işlevi
 ==============================================================================}
procedure TMasaustu.Kesme_MasaustuRenginiDegistir(ARenk: TRenk);
var
  _Masaustu: PMasaustu;
begin

  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // masaüstünün renk değerini değiştir
  FMasaustuArkaPlan := 1;
  FMasaustuRenk := ARenk;
end;

{==============================================================================
  masaüstü resmini değiştirir - kesme işlevi
 ==============================================================================}
procedure TMasaustu.Kesme_MasaustuResminiDegistir(ADosyaYolu: string);
var
  _Masaustu: PMasaustu;
begin

  _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(_Masaustu = nil) then Exit;

  // masaüstü resmini değiştir
  FMasaustuArkaPlan := 2;

  // daha önce masaüstü resmi için bellek ayrıldıysa belleği iptal et
  if not(_Masaustu^.FGoruntuYapi.BellekAdresi = nil) then
  begin

    GGercekBellek.YokEt(_Masaustu^.FGoruntuYapi.BellekAdresi, _Masaustu^.FGoruntuYapi.Genislik *
      _Masaustu^.FGoruntuYapi.Yukseklik * 4);

    _Masaustu^.FGoruntuYapi.BellekAdresi := nil;
  end;

  // resim dosyasını masaüstü yapısına yükle
  _Masaustu^.FGoruntuYapi := BMPDosyasiYukle(ADosyaYolu);
end;

end.
