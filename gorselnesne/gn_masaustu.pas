{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_masaustu.pas
  Dosya İşlevi: masaüstü yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/08/2020

 ==============================================================================}
{$mode objfpc}
unit gn_masaustu;

interface

uses gorselnesne, gn_panel, paylasim;

type
  PMasaustu = ^TMasaustu;
  TMasaustu = object(TPanel)
  public
    FMasaustuArkaPlan: TISayi4;       // 1 = renk değeri, 2 = resim
    FMasaustuRenk: TRenk;
    FGoruntuYapi: TGoruntuYapi;
    function Olustur(AMasaustuAdi: string): PMasaustu;
    function Olustur2(AMasaustuAdi: string): PMasaustu;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure Aktiflestir;
    procedure MasaustunuRenkIleDoldur;
    procedure MasaustuRenginiDegistir(ARenk: TRenk);
    procedure MasaustuResminiDegistir(ADosyaYolu: string);
  end;

function MasaustuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AMasaustuAdi: string): TKimlik;

implementation

uses gn_islevler, genel, bmp, temelgorselnesne, sistemmesaj, gn_pencere;

{==============================================================================
  masaüstü kesme çağrılarını yönetir
 ==============================================================================}
function MasaustuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Masaustu: PMasaustu;
  i: TISayi4;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKarakterKatari(PSayi4(ADegiskenler + 04)^ +
        CalisanGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      Masaustu := PMasaustu(Masaustu^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Masaustu^.Goster;
    end;

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
      i := PISayi4(ADegiskenler + 00)^;

      // eğer belirtilen aralıktaysa ...
      if(i > 0) and (i <= USTSINIR_MASAUSTU) then
      begin

        // belirlenen sıradaki masüstü mevcut ise
        if(MasaustuListesi[i] <> nil) then
        begin

          // masaüstünü aktif olarak işaretle
          GAktifMasaustu := MasaustuListesi[i];

          GAktifMasaustu^.Aktiflestir;

          // masaüstünü çiz
          GAktifMasaustu^.Ciz;

          // işlemin başarılı olduğuna dair mesajı geri döndür
          Result := TISayi4(True);

        end else Result := TISayi4(False);
      end else Result := TISayi4(False);
    end;

    // masaüstü rengini değiştir
    $0204:
    begin

      Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntMasaustu));
      if(Masaustu <> nil) then Masaustu^.MasaustuRenginiDegistir(
        PRenk(ADegiskenler + 04)^);
    end;

    // masaüstü resmini değiştir
    $0404:
    begin

      Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntMasaustu));
      if(Masaustu <> nil) then Masaustu^.MasaustuResminiDegistir(
        PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^);
    end;

    // masaüstünü güncelleştir (yeniden çiz)
    $0804:
    begin

      Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntMasaustu));
      if(Masaustu <> nil) then Masaustu^.Ciz;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  masaüstü nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AMasaustuAdi: string): TKimlik;
var
  Masaustu: PMasaustu;
begin

  Masaustu := Masaustu^.Olustur(AMasaustuAdi);
  if(Masaustu = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := Masaustu^.Kimlik;
end;

{==============================================================================
  masaüstü nesnesini oluşturur
 ==============================================================================}
function TMasaustu.Olustur(AMasaustuAdi: string): PMasaustu;
var
  Masaustu: PMasaustu;
begin

  // masaüstü nesnesi oluştur
  Masaustu := Olustur2(AMasaustuAdi);
  if(Masaustu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  Masaustu^.FMasaustuArkaPlan := 1;        // masaüstü arkaplan renk değeri kullanılacak
  Masaustu^.FMasaustuRenk := RENK_ZEYTINYESILI;

  // masaüstünün çizileceği bellek adresi
  Masaustu^.FCizimBellekAdresi := GGercekBellek.Ayir(Masaustu^.FBoyut.Genislik *
    Masaustu^.FBoyut.Yukseklik * 4);

  // masaüstüne çizilecek resmin bellek bilgileri
  Masaustu^.FGoruntuYapi.BellekAdresi := nil;

  // nesne adresini geri döndür
  Result := Masaustu;
end;

{==============================================================================
  masaüstü nesnesi için yer tahsis eder
 ==============================================================================}
function TMasaustu.Olustur2(AMasaustuAdi: string): PMasaustu;
var
  Masaustu: PMasaustu;
  Genislik, Yukseklik: TISayi4;
  i: TSayi4;
begin

  Result := nil;

  // tüm masaüstü nesneleri oluşturulduysa çık
  if(ToplamMasaustu >= USTSINIR_MASAUSTU) then Exit;

  Genislik := GEkranKartSurucusu.KartBilgisi.YatayCozunurluk;
  Yukseklik := GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk;

  Masaustu := PMasaustu(inherited Olustur(ktTuvalNesne, nil, 0, 0,
    Genislik, Yukseklik, 0, 0, 0, 0, ''));

  Masaustu^.NesneTipi := gntMasaustu;

  Masaustu^.Baslik := AMasaustuAdi;

  Masaustu^.FTuvalNesne := Masaustu;

  Masaustu^.OlayCagriAdresi := @OlaylariIsle;

  Masaustu^.FCizimBaslangic.Sol := 0;
  Masaustu^.FCizimBaslangic.Ust := 0;

  // masaüstü nesnesi için bellekte boş yer bul
  for i := 1 to USTSINIR_MASAUSTU do
  begin

    if(MasaustuListesi[i] = nil) then
    begin

      // 1. masaüstü kimliğini boş olarak bulunan yere kaydet
      // 2. oluşturulan masaüstü nesne sayısını artır
      // 3. geriye nesneyi döndür
      MasaustuListesi[i] := Masaustu;
      Inc(ToplamMasaustu);

      // nesne adresini geri döndür
      Exit(Masaustu);
    end;
  end;
end;

procedure TMasaustu.YokEt;
begin

  { TODO : öncelikle ayrılan bellek serbest bırakılacak }

  inherited YokEt;
end;

{==============================================================================
  masaüstünü aktifleştirir / görüntüler
 ==============================================================================}
procedure TMasaustu.Goster;
var
  Masaustu: PMasaustu;
  AltNesneler: PPGorselNesne;
  Pencere: PGorselNesne;
  i: Integer;
begin

  inherited Goster;

  // nesnenin kimlik, tip değerlerini denetle.
  Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(Masaustu = nil) then Exit;

  // masaüstünü aktifleştir
  Masaustu^.Aktiflestir;

  Masaustu^.Ciz;

  // masaüstü alt nesnesi olan pencereleri çiz
  if(Masaustu^.FAltNesneSayisi > 0) then
  begin

    AltNesneler := Masaustu^.FAltNesneBellekAdresi;

    // ilk oluşturulan pencereden son oluşturulan pencereye doğru nesneleri çiz
    for i := 0 to Masaustu^.FAltNesneSayisi - 1 do
    begin

      Pencere := AltNesneler[i];
      if(Pencere^.Gorunum) and (Pencere^.NesneTipi = gntPencere) then
        PPencere(Pencere)^.Ciz;
    end;
  end;
end;

{==============================================================================
  masaüstünü gizler
 ==============================================================================}
procedure TMasaustu.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  masaüstünü boyutlandırır
 ==============================================================================}
procedure TMasaustu.Boyutlandir;
begin

end;

{==============================================================================
  masaüstünü çizer
 ==============================================================================}
procedure TMasaustu.Ciz;
var
  Masaustu: PMasaustu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(Masaustu = nil) then Exit;

  // masaüstü arka plan resmini çiz
  if(Masaustu^.Gorunum) then
  begin

    if(Masaustu^.FMasaustuArkaPlan = 1) then
      MasaustunuRenkIleDoldur
    else BMPGoruntusuCiz(gntMasaustu, Masaustu, Masaustu^.FGoruntuYapi);
  end;
end;

{==============================================================================
  masaüstü olaylarını işler
 ==============================================================================}
procedure TMasaustu.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Masaustu: PMasaustu;
  BirOncekiOlay: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Masaustu := PMasaustu(AGonderici);

  // sağ / sol fare tuş basımı
  if(AOlay.Olay = FO_SAGTUS_BASILDI) or (AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // olayları bu nesneye yönlendir
    OlayYakalamayaBasla(Masaustu);

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(Masaustu^.OlayYonlendirmeAdresi = nil) then
      Masaustu^.OlayYonlendirmeAdresi(Masaustu, AOlay)
    else GorevListesi[Masaustu^.GorevKimlik]^.OlayEkle(Masaustu^.GorevKimlik, AOlay);
  end

  // sağ / sol fare tuş bırakımı
  else if(AOlay.Olay = FO_SAGTUS_BIRAKILDI) or (AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // olayları bu nesneye yönlendirmeyi iptal et
    OlayYakalamayiBirak(Masaustu);

    BirOncekiOlay := AOlay.Olay;

    // uygulamaya mesaj gönder
    if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Masaustu^.OlayYonlendirmeAdresi = nil) then
        Masaustu^.OlayYonlendirmeAdresi(Masaustu, AOlay)
      else GorevListesi[Masaustu^.GorevKimlik]^.OlayEkle(Masaustu^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := BirOncekiOlay;
    if not(Masaustu^.OlayYonlendirmeAdresi = nil) then
      Masaustu^.OlayYonlendirmeAdresi(Masaustu, AOlay)
    else GorevListesi[Masaustu^.GorevKimlik]^.OlayEkle(Masaustu^.GorevKimlik, AOlay);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Masaustu^.FFareImlecTipi;
end;

{==============================================================================
  masaüstünü aktifleştirir
 ==============================================================================}
procedure TMasaustu.Aktiflestir;
begin

  // eğer masaüstü nesnesi aktif değil ise
  if(@Self <> GAktifMasaustu) then
  begin

    // aktif masaüstü olarak belirle
    GAktifMasaustu := @Self;
  end;
end;

{==============================================================================
  masaüstünü belirtilen renk değeri ile boyar
 ==============================================================================}
procedure TMasaustu.MasaustunuRenkIleDoldur;
var
  Masaustu: PMasaustu;
  Sol, Ust: TISayi4;
  Renk: TRenk;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(Masaustu = nil) then Exit;

  Masaustu^.FMasaustuArkaPlan := 1;

  Renk := Masaustu^.FMasaustuRenk;

  for Ust := Masaustu^.FCizimAlan.Ust to Masaustu^.FCizimAlan.Alt do
  begin

    for Sol := Masaustu^.FCizimAlan.Sol to Masaustu^.FCizimAlan.Sag do
    begin

      GEkranKartSurucusu.NoktaYaz(Masaustu, Sol, Ust, Renk, False);
    end;
  end;
end;

{==============================================================================
  masaüstü renk değerini değiştirir
 ==============================================================================}
procedure TMasaustu.MasaustuRenginiDegistir(ARenk: TRenk);
var
  Masaustu: PMasaustu;
begin

  Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(Masaustu = nil) then Exit;

  // masaüstünün renk değerini değiştir
  Masaustu^.FMasaustuArkaPlan := 1;
  Masaustu^.FMasaustuRenk := ARenk;

  if(Masaustu^.Gorunum) then Masaustu^.Ciz;
end;

{==============================================================================
  masaüstü resmini değiştirir - kesme işlevi
 ==============================================================================}
procedure TMasaustu.MasaustuResminiDegistir(ADosyaYolu: string);
var
  Masaustu: PMasaustu;
begin

  Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(Kimlik, gntMasaustu));
  if(Masaustu = nil) then Exit;

  // masaüstü resmini değiştir
  Masaustu^.FMasaustuArkaPlan := 2;

  // daha önce masaüstü resmi için bellek ayrıldıysa belleği iptal et
  if not(Masaustu^.FGoruntuYapi.BellekAdresi = nil) then
  begin

    GGercekBellek.YokEt(Masaustu^.FGoruntuYapi.BellekAdresi, Masaustu^.FGoruntuYapi.Genislik *
      Masaustu^.FGoruntuYapi.Yukseklik * 4);

    Masaustu^.FGoruntuYapi.BellekAdresi := nil;
  end;

  // resim dosyasını masaüstü yapısına yükle
  Masaustu^.FGoruntuYapi := BMPDosyasiYukle(ADosyaYolu);

  if(Masaustu^.Gorunum) then Masaustu^.Ciz;
end;

end.
