{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_sayfakontrol.pas
  Dosya ��levi: sayfa kontrol (TPageControl) nesne y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 13/07/2020

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
  sayfa kontrol nesne kesme �a�r�lar�n� y�netir
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

    // SayfaKontrol ba�l���n� de�i�tir
    $0104:
    begin

      SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(PKimlik(ADegiskenler + 00)^));
      p := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
      SayfaKontrol^.Baslik := p^;

      // sayfa kontrol�n�n ba�l� oldu�u pencere nesnesini g�ncelle
      Pencere := EnUstPencereNesnesiniAl(SayfaKontrol);
      if not(Pencere = nil) then Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  sayfa kontrol nesnesini olu�turur
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
  sayfa kontrol nesnesini olu�turur
 ==============================================================================}
function TSayfaKontrol.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PSayfaKontrol;
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(inherited Olustur(AKullanimTipi, AAtaNesne,
    ASol, AUst, AGenislik, AYukseklik, 2, RENK_BEYAZ, RENK_BEYAZ, 0, ''));

  // nesnenin ad de�eri
  SayfaKontrol^.NesneTipi := gntSayfaKontrol;

  SayfaKontrol^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  SayfaKontrol^.OlayCagriAdresi := @OlaylariIsle;

  SayfaKontrol^.FSayfaSayisi := 0;
  SayfaKontrol^.FAktifSayfa := -1;

  SayfaKontrol^.FYedekDugme := nil;

  // nesne adresini geri d�nd�r
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
  sayfa kontrol nesnesini g�r�nt�ler
 ==============================================================================}
procedure TSayfaKontrol.Goster;
var
  SayfaKontrol: PSayfaKontrol;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
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

  // nesnenin kimlik, tip de�erlerini denetle.
  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  inherited Gizle;
end;

{==============================================================================
  sayfa kontrol nesnesini boyutland�r�r
 ==============================================================================}
procedure TSayfaKontrol.Boyutlandir;
begin

  inherited Boyutlandir;
end;

{==============================================================================
  sayfa kontrol nesnesini �izer
 ==============================================================================}
procedure TSayfaKontrol.Ciz;
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(SayfaKontrol^.NesneAl(Kimlik));
  if(SayfaKontrol = nil) then Exit;

  // �ncelikle kendini �iz
  inherited Ciz;

  if(SayfaKontrol^.FSayfaSayisi > 0) then SayfaKontrol^.FDugmeler[0]^.Ciz;
  if(SayfaKontrol^.FSayfaSayisi = 2) then SayfaKontrol^.FDugmeler[1]^.Ciz;

  if(SayfaKontrol^.FAktifSayfa = 0) then
    SayfaKontrol^.FPaneller[0]^.Ciz
  else SayfaKontrol^.FPaneller[1]^.Ciz;

//  if not(SayfaKontrol^.FYedekDugme = nil) then SayfaKontrol^.FYedekDugme^.Ciz;
end;

{==============================================================================
  sayfa kontrol nesne olaylar�n� i�ler
 ==============================================================================}
procedure TSayfaKontrol.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  SayfaKontrol: PSayfaKontrol;
begin

  SayfaKontrol := PSayfaKontrol(AGonderici);

  // farenin sol tu�una bas�m i�lemi
{  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sayfa kontrol�n�n sahibi olan pencere en �stte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(SayfaKontrol);

    // en �stte olmamas� durumunda en �ste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // fare olaylar�n� yakala
    OlayYakalamayaBasla(SayfaKontrol);

    // SayfaKontrol nesnesini yeniden �iz
    SayfaKontrol^.Ciz;

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylar�n� almay� b�rak
    OlayYakalamayiBirak(SayfaKontrol);

    // SayfaKontrol nesnesini yeniden �iz
    SayfaKontrol^.Ciz;

    // farenin tu� b�rakma i�lemi nesnenin olay alan�nda m� ger�ekle�ti ?
    if(SayfaKontrol^.FareNesneOlayAlanindaMi(SayfaKontrol)) then
    begin

      // yakalama & b�rakma i�lemi bu nesnede oldu�u i�in
      // uygulamaya veya efendi nesneye FO_TIKLAMA mesaj� g�nder
      AOlay.Olay := FO_TIKLAMA;
      if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
        SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
      else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj g�nder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // SayfaKontrol nesnesini yeniden �iz
    SayfaKontrol^.Ciz;

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(SayfaKontrol^.OlayYonlendirmeAdresi = nil) then
      SayfaKontrol^.OlayYonlendirmeAdresi(SayfaKontrol, AOlay)
    else GorevListesi[SayfaKontrol^.GorevKimlik]^.OlayEkle(SayfaKontrol^.GorevKimlik, AOlay);
  end;
}
  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := SayfaKontrol^.FFareImlecTipi;
end;

procedure TSayfaKontrol.TabDugmeOlaylariniIsle(AGonderici: PGorselNesne;
  AOlay: TOlay);
var
  GirisKutusu: PGirisKutusu;
  Dugme: PDugme;
  SayfaKontrol: PSayfaKontrol;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  Dugme := PDugme(AGonderici);
  if(Dugme = nil) then Exit;

  SayfaKontrol := PSayfaKontrol(Dugme^.AtaNesne);

  // silme d��mesine t�klama ger�ekle�tirildi�inde
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

  // nesnenin kimlik, tip de�erlerini denetle.
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
      SayfaKontrol^.FPaneller[i], 10, 10, 100, 100, 'D��me');
    SayfaKontrol^.FYedekDugme^.Goster;
}
    Inc(i);
    SayfaKontrol^.FSayfaSayisi := i;

    SayfaKontrol^.FAktifSayfa := 0;

    Result := SayfaKontrol^.FPaneller[1]^.Kimlik;
  end;
end;

end.
