{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_gucdugmesi.pas
  Dosya İşlevi: güç düğmesi yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/06/2020

 ==============================================================================}
{$mode objfpc}
unit gn_gucdugmesi;

interface

uses gorselnesne, paylasim, gn_panel;

type
  PGucDugmesi = ^TGucDugmesi;
  TGucDugmesi = object(TPanel)
  private
    FDurum: TDugmeDurumu;
    FDolguluCizim: Boolean;         // dolgulu çizim mi, normal çizim mi?
    FYaziRenkNormal, FYaziRenkBasili: TRenk;
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4; ABaslik: string): PGucDugmesi;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure CizimModelDegistir(ADolguluCizim: Boolean; AGovdeRenk1, AGovdeRenk2,
      AYaziRenkNormal, AYaziRenkBasili: TRenk);
    procedure DurumYaz(AKimlik: TKimlik; ADurum: TSayi4);
  end;

function GucDugmeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_islevler, temelgorselnesne, giysi_mac, gn_pencere;

{==============================================================================
  güç düğme kesme çağrılarını yönetir
 ==============================================================================}
function GucDugmeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  GucDugmesi: PGucDugmesi;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur( GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^,
        PKarakterKatari(PSayi4(ADegiskenler + 20)^ + CalisanGorevBellekAdresi)^);
    end;

    ISLEV_YOKET:
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      GucDugmesi^.YokEt;
    end;

    ISLEV_GOSTER:
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      GucDugmesi^.Goster;
    end;

    ISLEV_GIZLE:
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      GucDugmesi^.Gizle;
    end;

    $0204:
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if not(GucDugmesi = nil) then
      begin

        GucDugmesi^.Baslik := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^;
      end;
    end;

    // güç düğme durumunu değiştir
    $0304:
    begin

      GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(GucDugmesi <> nil) then
        GucDugmesi^.DurumYaz(PKimlik(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^);

    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  güç düğme nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
var
  GucDugmesi: PGucDugmesi;
begin

  GucDugmesi := GucDugmesi^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik, ABaslik);

  if(GucDugmesi = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := GucDugmesi^.Kimlik;
end;

{==============================================================================
  güç düğme nesnesini oluşturur
 ==============================================================================}
function TGucDugmesi.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4; ABaslik: string): PGucDugmesi;
var
  GucDugmesi: PGucDugmesi;
begin

  GucDugmesi := PGucDugmesi(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst, AGenislik,
    AYukseklik, 4, DUGME_NORMAL_ILKRENK, DUGME_NORMAL_SONRENK, DUGME_NORMAL_YAZIRENK, ABaslik));

  // görsel nesne tipi
  GucDugmesi^.NesneTipi := gntGucDugmesi;

  GucDugmesi^.Baslik := ABaslik;

  GucDugmesi^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  GucDugmesi^.AnaOlayCagriAdresi := @OlaylariIsle;

  GucDugmesi^.FDurum := ddNormal;

  // çizim öndeğerleri
  GucDugmesi^.FDolguluCizim := True;
  GucDugmesi^.FGovdeRenk1 := DUGME_NORMAL_ILKRENK;
  GucDugmesi^.FGovdeRenk2 := DUGME_NORMAL_SONRENK;
  GucDugmesi^.FYaziRenkNormal := DUGME_NORMAL_YAZIRENK;
  GucDugmesi^.FYaziRenkBasili := DUGME_BASILI_YAZIRENK;

  // nesne adresini geri döndür
  Result := GucDugmesi;
end;

{==============================================================================
  güç düğme nesnesini yok eder
 ==============================================================================}
procedure TGucDugmesi.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  güç düğme nesnesini görüntüler
 ==============================================================================}
procedure TGucDugmesi.Goster;
begin

  inherited Goster;
end;

{==============================================================================
  güç düğme nesnesini gizler
 ==============================================================================}
procedure TGucDugmesi.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  güç düğme nesnesini boyutlandırır
 ==============================================================================}
procedure TGucDugmesi.Boyutlandir;
var
  GucDugmesi: PGucDugmesi;
begin

  GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(Kimlik));
  if(GucDugmesi = nil) then Exit;

  GucDugmesi^.Hizala;
end;

{==============================================================================
  güç düğme nesnesini çizer
 ==============================================================================}
procedure TGucDugmesi.Ciz;
var
  GucDugmesi: PGucDugmesi;
begin

  GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(Kimlik));
  if(GucDugmesi= nil) then Exit;

  // düğme başlığı
  if(GucDugmesi^.FDurum = ddNormal) then
    GucDugmesi^.FYaziRenk := FYaziRenkNormal
  else GucDugmesi^.FYaziRenk := FYaziRenkBasili;

  inherited Ciz;
end;

{==============================================================================
  güç düğme nesne olaylarını işler
 ==============================================================================}
procedure TGucDugmesi.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
  GucDugmesi: PGucDugmesi;
  i: TISayi4;
begin

  GucDugmesi := PGucDugmesi(AGonderici);

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // güç düğmesinin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(GucDugmesi);

    // en üstte olmaması durumunda en üste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // fare olaylarını yakala
    OlayYakalamayaBasla(GucDugmesi);

    // güç düğmesinin durumunu NORMAL / BASILI olarak değiştir
    if(GucDugmesi^.FDurum = ddBasili) then
    begin

      i := 0;
      GucDugmesi^.FDurum := ddNormal;
    end
    else
    begin

      i := 1;
      GucDugmesi^.FDurum := ddBasili;
    end;

    // güç düğme nesnesini yeniden çiz
    GucDugmesi^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := CO_DURUMDEGISTI;
    AOlay.Deger1 := i;
    if not(GucDugmesi^.OlayCagriAdresi = nil) then
      GucDugmesi^.OlayCagriAdresi(GucDugmesi, AOlay)
    else GorevListesi[GucDugmesi^.GorevKimlik]^.OlayEkle(GucDugmesi^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(GucDugmesi);
  end
  else if(AOlay.Olay = CO_NORMALDURUMAGEC) then
  begin

    if(GucDugmesi^.FDurum = ddBasili) then
    begin

      GucDugmesi^.FDurum := ddNormal;

      // güç düğme nesnesini yeniden çiz
      GucDugmesi^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := CO_DURUMDEGISTI;
      if not(GucDugmesi^.OlayCagriAdresi = nil) then
        GucDugmesi^.OlayCagriAdresi(GucDugmesi, AOlay)
      else GorevListesi[GucDugmesi^.GorevKimlik]^.OlayEkle(GucDugmesi^.GorevKimlik, AOlay);
    end;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := GucDugmesi^.FFareImlecTipi;
end;

{==============================================================================
  güç düğmesinin çizim modelini değiştirir ve renk değerlerini belirler
 ==============================================================================}
procedure TGucDugmesi.CizimModelDegistir(ADolguluCizim: Boolean; AGovdeRenk1, AGovdeRenk2,
  AYaziRenkNormal, AYaziRenkBasili: TRenk);
var
  GucDugmesi: PGucDugmesi;
begin

  // kimlik değerinden nesneyi al
  GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(Kimlik));
  if(GucDugmesi = nil) then Exit;

  GucDugmesi^.FDolguluCizim := ADolguluCizim;
  if(ADolguluCizim) then
    GucDugmesi^.FCizimModel := 4
  else GucDugmesi^.FCizimModel := 3;

  GucDugmesi^.FGovdeRenk1 := AGovdeRenk1;
  GucDugmesi^.FGovdeRenk2 := AGovdeRenk2;
  GucDugmesi^.FYaziRenkNormal := AYaziRenkNormal;
  GucDugmesi^.FYaziRenkBasili := AYaziRenkBasili;
end;

{==============================================================================
  güç düğme nesnesinin durumunu değiştirir
 ==============================================================================}
procedure TGucDugmesi.DurumYaz(AKimlik: TKimlik; ADurum: TSayi4);
var
  GucDugmesi: PGucDugmesi;
begin

  // kimlik değerinden nesneyi al
  GucDugmesi := PGucDugmesi(GucDugmesi^.NesneAl(AKimlik));
  if(GucDugmesi = nil) then Exit;

  if(ADurum = 1) then
    GucDugmesi^.FDurum := ddBasili
  else GucDugmesi^.FDurum := ddNormal;

  GucDugmesi^.Ciz;
end;

end.
