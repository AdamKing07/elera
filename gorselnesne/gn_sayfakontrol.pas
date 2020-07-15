{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_sayfakontrol.pas
  Dosya Ýþlevi: sayfa kontrol (TPageControl) nesne yönetim iþlevlerini içerir

  Güncelleme Tarihi: 13/07/2020

 ==============================================================================}
{$mode objfpc}
unit gn_sayfakontrol;

interface

uses gorselnesne, paylasim, gn_panel, gn_dugme, gn_giriskutusu, sistemmesaj;

const
  AZAMI_DUGME_SAYISI = 50;

type
  PSayfaKontrol = ^TSayfaKontrol;

  { TSayfaKontrol }

  TSayfaKontrol = object(TPanel)
  private
    FSayfaSayisi, FAktifSayfa: TSayi4;
    FPaneller: array[0..1] of PPanel;
    FDugmeler: array[0..1] of PDugme;
    FYedekDugme: PDugme;
    FBaslikG: array[0..1] of TSayi4;
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4): PSayfaKontrol;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure TabDugmeOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    function SayfaEkle(ABaslik: string): TKimlik;
  end;

function SayfaKontrolCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  sayfa kontrol nesne kesme çaðrýlarýný yönetir
 ==============================================================================}
function SayfaKontrolCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  SayfaKontrol: PSayfaKontrol;
  p: PKarakterKatari;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);
    end;

    ISLEV_GOSTER:
    begin

      SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(PKimlik(ADegiskenler + 00)^));
      SayfaKontrol^.Goster;
    end;

    // SayfaKontrol baþlýðýný deðiþtir
    $0104:
    begin

      SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(PKimlik(ADegiskenler + 00)^));
      p := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
      SayfaKontrol^.Baslik := p^;

      // sayfa kontrolünün baðlý olduðu pencere nesnesini güncelle
      Pencere := EnUstPencereNesnesiniAl(SayfaKontrol);
      if not(Pencere = nil) then Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  sayfa kontrol nesnesini oluþturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := SayfaKontrol^.Olustur(ktNesne, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik);

  if(SayfaKontrol = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := SayfaKontrol^.Kimlik;
end;

{==============================================================================
  sayfa kontrol nesnesini oluþturur
 ==============================================================================}
function TSayfaKontrol.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PSayfaKontrol;
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(inherited Olustur(AKullanimTipi, AAtaNesne,
    ASol, AUst, AGenislik, AYukseklik, 2, RENK_BEYAZ, RENK_BEYAZ, 0, ''));

  // nesnenin ad deðeri
  SayfaKontrol^.NesneTipi := gntSayfaKontrol;

  SayfaKontrol^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  SayfaKontrol^.OlayCagriAdresi := @OlaylariIsle;

  SayfaKontrol^.FSayfaSayisi := 0;
  SayfaKontrol^.FAktifSayfa := -1;

  SayfaKontrol^.FYedekDugme := nil;

  // nesne adresini geri döndür
  Result := SayfaKontrol;
end;

{==============================================================================
  sayfa kontrol nesnesini yok eder
 ==============================================================================}
procedure TSayfaKontrol.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  sayfa kontrol nesnesini görüntüler
 ==============================================================================}
procedure TSayfaKontrol.Goster;
var
  SayfaKontrol: PSayfaKontrol;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  if(SayfaKontrol^.FSayfaSayisi > 0) then SayfaKontrol^.FDugmeler[0]^.Goster;
  if(SayfaKontrol^.FSayfaSayisi = 2) then SayfaKontrol^.FDugmeler[1]^.Goster;

  if(SayfaKontrol^.FAktifSayfa = 0) then
  begin

    SayfaKontrol^.FPaneller[0]^.Goster;
    SayfaKontrol^.FPaneller[1]^.Gizle;
  end
  else if(SayfaKontrol^.FAktifSayfa = 1) then
  begin

    SayfaKontrol^.FPaneller[0]^.Gizle;
    SayfaKontrol^.FPaneller[1]^.Goster;
  end;

  inherited Goster;
end;

{==============================================================================
  sayfa kontrol nesnesini gizler
 ==============================================================================}
procedure TSayfaKontrol.Gizle;
var
  SayfaKontrol: PSayfaKontrol;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  inherited Gizle;
end;

{==============================================================================
  sayfa kontrol nesnesini boyutlandýrýr
 ==============================================================================}
procedure TSayfaKontrol.Boyutlandir;
begin

  inherited Boyutlandir;
end;

{==============================================================================
  sayfa kontrol nesnesini çizer
 ==============================================================================}
procedure TSayfaKontrol.Ciz;
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  // öncelikle kendini çiz
  inherited Ciz;

  if(SayfaKontrol^.FSayfaSayisi > 0) then SayfaKontrol^.FDugmeler[0]^.Ciz;
  if(SayfaKontrol^.FSayfaSayisi = 2) then SayfaKontrol^.FDugmeler[1]^.Ciz;

  if(SayfaKontrol^.FAktifSayfa = 0) then
    SayfaKontrol^.FPaneller[0]^.Ciz
  else SayfaKontrol^.FPaneller[1]^.Ciz;

//  if not(SayfaKontrol^.FYedekDugme = nil) then SayfaKontrol^.FYedekDugme^.Ciz;
end;

{==============================================================================
  sayfa kontrol nesne olaylarýný iþler
 ==============================================================================}
procedure TSayfaKontrol.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(AGonderici);

  // farenin sol tuþuna basým iþlemi
{  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sayfa kontrolünün sahibi olan pencere en üstte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(SayfaKontrol);

    // en üstte olmamasý durumunda en üste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // fare olaylarýný yakala
    OlayYakalamayaBasla(SayfaKontrol);

    // SayfaKontrol nesnesini yeniden çiz
    SayfaKontrol^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarýný almayý býrak
    OlayYakalamayiBirak(SayfaKontrol);

    // SayfaKontrol nesnesini yeniden çiz
    SayfaKontrol^.Ciz;

    // farenin tuþ býrakma iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(SayfaKontrol^.FareNesneOlayAlanindaMi(SayfaKontrol)) then
    begin

      // yakalama & býrakma iþlemi bu nesnede olduðu için
      // uygulamaya veya efendi nesneye FO_TIKLAMA mesajý gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
        SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
      else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // SayfaKontrol nesnesini yeniden çiz
    SayfaKontrol^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end;
}
  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := SayfaKontrol^.FFareImlecTipi;
end;

procedure TSayfaKontrol.TabDugmeOlaylariniIsle(AGonderici: PGorselNesne;
  AOlay: TOlay);
var
  GirisKutusu: PGirisKutusu;
  Dugme: PDugme;
  SayfaKontrol: PSayfaKontrol;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  Dugme := PDugme(AGonderici);
  if(Dugme = nil) then Exit;

  SayfaKontrol := PSayfaKontrol(Dugme^.AtaNesne);

  // silme düðmesine týklama gerçekleþtirildiðinde
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    if(AOlay.Kimlik = SayfaKontrol^.FDugmeler[0]^.Kimlik) then
      SayfaKontrol^.FAktifSayfa := 0
    else SayfaKontrol^.FAktifSayfa := 1;

    SayfaKontrol^.Ciz;
  end
end;

function TSayfaKontrol.SayfaEkle(ABaslik: string): TKimlik;
var
  SayfaKontrol: PSayfaKontrol = nil;
  i: TSayi4;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  i := SayfaKontrol^.FSayfaSayisi;
  if(i >= 2) then Exit;

  if(i = 0) then
  begin

    FBaslikG[0] := Length(ABaslik) * 8 + 10;

    SayfaKontrol^.FDugmeler[i] := SayfaKontrol^.FDugmeler[i]^.Olustur(ktBilesen,
      SayfaKontrol, 0, 0, FBaslikG[0], 20, ABaslik);
    SayfaKontrol^.FDugmeler[i]^.CizimModelDegistir(False, RENK_GRI, RENK_BEYAZ, RENK_SIYAH, RENK_KIRMIZI);
    SayfaKontrol^.FDugmeler[i]^.OlayYonlendirmeAdresi := @TabDugmeOlaylariniIsle;

    // paneller
    SayfaKontrol^.FPaneller[i] := SayfaKontrol^.FPaneller[i]^.Olustur(ktBilesen,
      SayfaKontrol, 0, 20, 300, 275, 3, RENK_KIRMIZI, RENK_BEYAZ, RENK_SIYAH, ABaslik);

    Inc(i);
    SayfaKontrol^.FSayfaSayisi := i;

    SayfaKontrol^.FAktifSayfa := 0;

    Result := SayfaKontrol^.FPaneller[0]^.Kimlik;
  end
  else
  begin

    FBaslikG[1] := Length(ABaslik) * 8 + 10;

    SayfaKontrol^.FDugmeler[i] := SayfaKontrol^.FDugmeler[i]^.Olustur(ktBilesen,
      SayfaKontrol, FBaslikG[0] + 4, 0, FBaslikG[1], 20, ABaslik);
    SayfaKontrol^.FDugmeler[i]^.CizimModelDegistir(False, RENK_GRI, RENK_BEYAZ, RENK_SIYAH, RENK_KIRMIZI);
    SayfaKontrol^.FDugmeler[i]^.OlayYonlendirmeAdresi := @TabDugmeOlaylariniIsle;

    // paneller
    SayfaKontrol^.FPaneller[i] := SayfaKontrol^.FPaneller[i]^.Olustur(ktBilesen,
      SayfaKontrol, 0, 20, 300, 275, 3, RENK_YESIL, RENK_BEYAZ, RENK_SIYAH, ABaslik);

{    SayfaKontrol^.FYedekDugme := SayfaKontrol^.FYedekDugme^.Olustur(ktNesne,
      SayfaKontrol^.FPaneller[i], 10, 10, 100, 100, 'Düðme');
    SayfaKontrol^.FYedekDugme^.Goster;
}
    Inc(i);
    SayfaKontrol^.FSayfaSayisi := i;

    SayfaKontrol^.FAktifSayfa := 0;

    Result := SayfaKontrol^.FPaneller[1]^.Kimlik;
  end;
end;

end.
