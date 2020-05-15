{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_dugme.pp
  Dosya İşlevi: düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 14/05/2020

 ==============================================================================}
{$mode objfpc}
unit gn_dugme;

interface

uses gorselnesne, paylasim, gn_gorselanayapi;

type
  PDugme = ^TDugme;
  TDugme = object(TGorselAnaYapi)
  private
    FDurum: TDugmeDurumu;
    FDolguluCizim: Boolean;         // dolgulu çizim mi, normal çizim mi?
    FYaziRenkNormal, FYaziRenkBasili: TRenk;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): PDugme;
    procedure YokEt;
    procedure CizimModelDegistir(ADolguluCizim: Boolean; AGovdeRenk1, AGovdeRenk2,
      AYaziRenkNormal, AYaziRenkBasili: TRenk);
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  published
    property Durum: TDugmeDurumu read FDurum write FDurum;
  end;

function DugmeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne, giysi, sistemmesaj;

{==============================================================================
  düğme kesme çağrılarını yönetir
 ==============================================================================}
function DugmeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Pencere: PPencere;
  Dugme: PDugme;
  Hiza: THiza;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^,
        PKarakterKatari(PSayi4(ADegiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_YOKET:
    begin

      Dugme := PDugme(Dugme^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Dugme^.YokEt;
    end;

    ISLEV_GOSTER:
    begin

      Dugme := PDugme(Dugme^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Dugme^.Goster;
    end;

    ISLEV_GIZLE:
    begin

      Dugme := PDugme(Dugme^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Dugme^.Gorunum := False;
    end;

    $0104:
    begin

      Dugme := PDugme(Dugme^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      Dugme^.Hiza := Hiza;

      Pencere := PPencere(Dugme^.FAtaNesne);
      Pencere^.Guncelle;
    end;

    $0204:
    begin

      Dugme := PDugme(Dugme^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if not(Dugme = nil) then
      begin

        Dugme^.Baslik := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi)^;
      end;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  düğme nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
var
  Dugme: PDugme;
begin

  Dugme := Dugme^.Olustur(AtaKimlik, ASol, AUst, AGenislik, AYukseklik, ABaslik);

  if(Dugme = nil) then

    Result := HATA_NESNEOLUSTURMA
  else
  begin

    Dugme^.FCizimModel := 3;

    Result := Dugme^.Kimlik;
  end;
end;

{==============================================================================
  düğme nesnesini oluşturur
 ==============================================================================}
function TDugme.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): PDugme;
var
  Dugme: PDugme;
begin

  Dugme := PDugme(inherited Olustur(gntDugme, AAtaKimlik, ASol, AUst, AGenislik,
    AYukseklik, 2, DUGME_NORMAL_ILKRENK, DUGME_NORMAL_SONRENK, DUGME_NORMAL_YAZIRENK,
    ABaslik));

  SISTEM_MESAJ('Dugme Kimlik: %d', [Dugme^.Kimlik]);

  // nesnenin ad değeri
  Dugme^.NesneAdi := NesneAdiAl(gntDugme);

  Dugme^.Durum := ddNormal;

  // çizim öndeğerleri
  Dugme^.FDolguluCizim := True;
  Dugme^.FGovdeRenk1 := DUGME_NORMAL_ILKRENK;
  Dugme^.FGovdeRenk2 := DUGME_NORMAL_SONRENK;
  Dugme^.FYaziRenkNormal := DUGME_NORMAL_YAZIRENK;
  Dugme^.FYaziRenkBasili := DUGME_BASILI_YAZIRENK;

  // nesne adresini geri döndür
  Result := Dugme;
end;

{==============================================================================
  düğme nesnesini yok eder
 ==============================================================================}
procedure TDugme.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  düğme nesnesini görüntüler
 ==============================================================================}
procedure TDugme.Goster;
begin

  inherited Goster;
end;

{==============================================================================
  düğme nesnesini çizer
 ==============================================================================}
procedure TDugme.Ciz;
var
  Dugme: PDugme;
  Olay: TOlayKayit;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Dugme := PDugme(Dugme^.NesneTipiniKontrolEt(Kimlik, gntDugme));
  if(Dugme = nil) then Exit;

  // düğme başlığı
  if(Dugme^.Durum = ddNormal) then
    Dugme^.FYaziRenk := FYaziRenkNormal
  else Dugme^.FYaziRenk := FYaziRenkBasili;

  inherited Ciz;

  Olay.Kimlik := Dugme^.Kimlik;
  Olay.Olay := CO_CIZIM;
  Olay.Deger1 := 0;
  Olay.Deger2 := 0;

  // uygulamaya veya efendi nesneye mesaj gönder
  if not(Dugme^.FEfendiNesneOlayCagriAdresi = nil) then

    Dugme^.FEfendiNesneOlayCagriAdresi(Dugme^.Kimlik, Olay)

  else GorevListesi[Dugme^.GorevKimlik]^.OlayEkle2(Dugme^.GorevKimlik, Olay);
end;

{==============================================================================
  düğme nesne olaylarını işler
 ==============================================================================}
procedure TDugme.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  Pencere: PPencere;
  Dugme: PDugme;
begin

  Dugme := PDugme(Dugme^.NesneTipiniKontrolEt(AKimlik, gntDugme));
  if(Dugme = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // düğme'nin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := PencereAtaNesnesiniAl(Dugme);

    // en üstte olmaması durumunda en üste getir
    if(Pencere <> AktifPencere) then Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(Dugme);

      // düğme'nin durumunu BASILI olarak belirle
      Dugme^.Durum := ddBasili;

      // düğme nesnesini yeniden çiz
      Dugme^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(Dugme^.FEfendiNesneOlayCagriAdresi = nil) then

        Dugme^.FEfendiNesneOlayCagriAdresi(Dugme^.Kimlik, AOlay)

      else GorevListesi[Dugme^.GorevKimlik]^.OlayEkle2(Dugme^.GorevKimlik, AOlay);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(Dugme);

    //  basılan düğmeyi eski konumuna geri getir
    Dugme^.Durum := ddNormal;

    // düğme nesnesini yeniden çiz
    Dugme^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // uygulamaya veya efendi nesneye FO_TIKLAMA mesajı gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Dugme^.FEfendiNesneOlayCagriAdresi = nil) then

        Dugme^.FEfendiNesneOlayCagriAdresi(Dugme^.Kimlik, AOlay)

      else GorevListesi[Dugme^.GorevKimlik]^.OlayEkle2(Dugme^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(Dugme^.FEfendiNesneOlayCagriAdresi = nil) then

      Dugme^.FEfendiNesneOlayCagriAdresi(Dugme^.Kimlik, AOlay)

    else GorevListesi[Dugme^.GorevKimlik]^.OlayEkle2(Dugme^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ve
    // 1 - fare göstergesi düğmenin içerisindeyse
    // 2 - fare göstergesi düğmenin dışarısındaysa
    // koşula göre düğmenin durumunu yeniden çiz ...
    if(YakalananGorselNesne <> nil) then
    begin

      if(Dugme^.FareNesneOlayAlanindaMi(AKimlik)) then

        Dugme^.Durum := ddBasili
      else Dugme^.Durum := ddNormal;
    end;

    // düğme nesnesini yeniden çiz
    Dugme^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(Dugme^.FEfendiNesneOlayCagriAdresi = nil) then

      Dugme^.FEfendiNesneOlayCagriAdresi(Dugme^.Kimlik, AOlay)

    else GorevListesi[Dugme^.GorevKimlik]^.OlayEkle2(Dugme^.GorevKimlik, AOlay);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

{==============================================================================
  düğmenin çizim modelini değiştirir ve renk değerlerini belirler
 ==============================================================================}
procedure TDugme.CizimModelDegistir(ADolguluCizim: Boolean; AGovdeRenk1, AGovdeRenk2,
  AYaziRenkNormal, AYaziRenkBasili: TRenk);
var
  Dugme: PDugme;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Dugme := PDugme(Dugme^.NesneTipiniKontrolEt(Kimlik, gntDugme));
  if(Dugme = nil) then Exit;

  Dugme^.FDolguluCizim := ADolguluCizim;
  if(ADolguluCizim) then
    Dugme^.FCizimModel := 3
  else Dugme^.FCizimModel := 2;

  Dugme^.FGovdeRenk1 := AGovdeRenk1;
  Dugme^.FGovdeRenk2 := AGovdeRenk2;
  Dugme^.FYaziRenkNormal := AYaziRenkNormal;
  Dugme^.FYaziRenkBasili := AYaziRenkBasili;
end;

end.
