{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: temelgorselnesne.pas
  Dosya Ýþlevi: temel görsel nesne yapýsýný içerir

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit temelgorselnesne;

interface

uses nesne, paylasim;

type
  PTemelGorselNesne = ^TTemelGorselNesne;
  TTemelGorselNesne = object(TNesne)
  public
    FGorevKimlik: TKimlik;                        // nesnenin sahibi olan görev / program
    FNesneAdi: string;                            // nesnenin adý
    FBaslik: string;                              // nesnenin baþlýk deðeri
    FGorunum: Boolean;                            // görünür / görünmez özelliði
    FHiza: THiza;                                 // nesnenin hizalanacaðý (çizgi üstünde tutulacaðý) yön
    FBoyutlar: TAlan;                             // nesnenin dikdörtgensel koordinatlarý

    // nesnenin dýþ boyutlarý (ve eðer içeriðine nesne alabiliyorsa (TMasaUstu, TPencere gibi))
    // diðer nesnelerin yaslanma durumlarýnýn hesaplanacaðý iç gerçek (ekranýn 0 koordinatýna baðlý) boyutlar
    FDisGercekBoyutlar, FIcGercekBoyutlar: TAlan;

    FKalinlik: TAlan;                             // alt nesne içeren nesnenin dikdörtgensel kalýnlýðý (1)
    FKenarBosluklari: TAlan;                      // nesnenin bir üst için kenar boþluklarý (2)
    FAltNesneSayisi: TISayi4;                     // nesnenin alt nesne sayýsý
    FFareGostergeTipi: TFareImlecTipi;            // nesnenin fare göstergesi
  published
    property GorevKimlik: TKimlik read FGorevKimlik write FGorevKimlik;
    property NesneAdi: string read FNesneAdi write FNesneAdi;
    property Baslik: string read FBaslik write FBaslik;
    property Gorunum: Boolean read FGorunum write FGorunum;
    property Hiza: THiza read FHiza write FHiza;
    property AltNesneSayisi: TISayi4 read FAltNesneSayisi write FAltNesneSayisi;
    property FareGostergeTipi: TFareImlecTipi read FFareGostergeTipi write FFareGostergeTipi;
  end;

var
  MasaustuSayac: TISayi4 = 0;
  PencereSayac: TISayi4 = 0;
  DugmeSayac: TISayi4 = 0;
  GucDugmesiSayac: TISayi4 = 0;
  ListeKutusuSayac: TISayi4 = 0;
  MenuSayac: TISayi4 = 0;
  DefterSayac: TISayi4 = 0;
  IslemGostergesiSayac: TISayi4 = 0;
  IsaretKutusuSayac: TISayi4 = 0;
  GirisKutusuSayac: TISayi4 = 0;
  DegerDugmesiSayac: TISayi4 = 0;
  EtiketSayac: TISayi4 = 0;
  DurumCubuguSayac: TISayi4 = 0;
  SecimKutusuSayac: TISayi4 = 0;
  BaglantiSayac: TISayi4 = 0;
  ResimSayac: TISayi4 = 0;
  ListeGorunumSayac: TISayi4 = 0;
  PanelSayac: TISayi4 = 0;
  ResimDugmeSayac: TISayi4 = 0;
  KaydirmaCubugu: TISayi4 = 0;
  KarmaListe: TISayi4 = 0;
  AcilirMenu: TISayi4 = 0;

{
  (1) FKalinlik deðeri, alt nesne içeren nesneler için alt nesnelerin baþlangýç koordinat
  deðerini belirlediði için önemlidir

  (2) FKenarBosluklari deðiþkeninin iþlevi FHiza ile kullanýldýðýnda önemi daha fazla
  ön plana çýkmaktadýr
}

function NesneAdiAl(AGorselNesneTipi: TGorselNesneTipi): string;

implementation

uses donusum;

{==============================================================================
  görsel nesnelere isim üretir
 ==============================================================================}
function NesneAdiAl(AGorselNesneTipi: TGorselNesneTipi): string;
begin

  case AGorselNesneTipi of
    gntMasaustu:
    begin
      Inc(MasaustuSayac);
      Result := 'masaüstü' + '.' + IntToStr(MasaustuSayac);
    end;
    gntPencere:
    begin
      Inc(PencereSayac);
      Result := 'pencere' + '.' + IntToStr(PencereSayac);
    end;
    gntDugme:
    begin
      Inc(DugmeSayac);
      Result := 'düðme' + '.' + IntToStr(DugmeSayac);
    end;
    gntGucDugme:
    begin
      Inc(GucDugmesiSayac);
      Result := 'güçdüðmesi' + '.' + IntToStr(GucDugmesiSayac);
    end;
    gntListeKutusu:
    begin
      Inc(ListeKutusuSayac);
      Result := 'listekutusu' + '.' + IntToStr(ListeKutusuSayac);
    end;
    gntMenu:
    begin
      Inc(MenuSayac);
      Result := 'menü' + '.' + IntToStr(MenuSayac);
    end;
    gntDefter:
    begin
      Inc(DefterSayac);
      Result := 'defter' + '.' + IntToStr(DefterSayac);
    end;
    gntIslemGostergesi:
    begin
      Inc(IslemGostergesiSayac);
      Result := 'iþlemgöstergesi' + '.' + IntToStr(IslemGostergesiSayac);
    end;
    gntIsaretKutusu:
    begin
      Inc(IsaretKutusuSayac);
      Result := 'iþaretkutusu' + '.' + IntToStr(IsaretKutusuSayac);
    end;
    gntGirisKutusu:
    begin
      Inc(GirisKutusuSayac);
      Result := 'giriþkutusu' + '.' + IntToStr(GirisKutusuSayac);
    end;
    gntDegerDugmesi:
    begin
      Inc(DegerDugmesiSayac);
      Result := 'deðerdüðmesi' + '.' + IntToStr(DegerDugmesiSayac);
    end;
    gntEtiket:
    begin
      Inc(EtiketSayac);
      Result := 'etiket' + '.' + IntToStr(EtiketSayac);
    end;
    gntDurumCubugu:
    begin
      Inc(DurumCubuguSayac);
      Result := 'durumçubuðu' + '.' + IntToStr(DurumCubuguSayac);
    end;
    gntSecimDugmesi:
    begin
      Inc(SecimKutusuSayac);
      Result := 'seçimkutusu' + '.' + IntToStr(SecimKutusuSayac);
    end;
    gntBaglanti:
    begin
      Inc(BaglantiSayac);
      Result := 'baðlantý' + '.' + IntToStr(BaglantiSayac);
    end;
    gntResim:
    begin
      Inc(ResimSayac);
      Result := 'resim' + '.' + IntToStr(ResimSayac);
    end;
    gntListeGorunum:
    begin
      Inc(ListeGorunumSayac);
      Result := 'listegörünüm' + '.' + IntToStr(ListeGorunumSayac);
    end;
    gntPanel:
    begin
      Inc(PanelSayac);
      Result := 'panel' + '.' + IntToStr(PanelSayac);
    end;
    gntResimDugme:
    begin
      Inc(ResimDugmeSayac);
      Result := 'resimdüðme' + '.' + IntToStr(ResimDugmeSayac);
    end;
    gntKaydirmaCubugu:
    begin
      Inc(KaydirmaCubugu);
      Result := 'kaydýrmaçubuðu' + '.' + IntToStr(KaydirmaCubugu);
    end;
    gntKarmaListe:
    begin
      Inc(KarmaListe);
      Result := 'karmaliste' + '.' + IntToStr(KarmaListe);
    end;
    gntAcilirMenu:
    begin
      Inc(AcilirMenu);
      Result := 'açýlýrmenu' + '.' + IntToStr(AcilirMenu);
    end;
  end;
end;

end.
