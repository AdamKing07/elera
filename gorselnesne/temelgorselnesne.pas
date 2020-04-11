{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: temelgorselnesne.pas
  Dosya ��levi: temel g�rsel nesne yap�s�n� i�erir

  G�ncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit temelgorselnesne;

interface

uses nesne, paylasim;

type
  PTemelGorselNesne = ^TTemelGorselNesne;
  TTemelGorselNesne = object(TNesne)
  public
    FGorevKimlik: TKimlik;                        // nesnenin sahibi olan g�rev / program
    FNesneAdi: string;                            // nesnenin ad�
    FBaslik: string;                              // nesnenin ba�l�k de�eri
    FGorunum: Boolean;                            // g�r�n�r / g�r�nmez �zelli�i
    FHiza: THiza;                                 // nesnenin hizalanaca�� (�izgi �st�nde tutulaca��) y�n
    FBoyutlar: TAlan;                             // nesnenin dikd�rtgensel koordinatlar�

    // nesnenin d�� boyutlar� (ve e�er i�eri�ine nesne alabiliyorsa (TMasaUstu, TPencere gibi))
    // di�er nesnelerin yaslanma durumlar�n�n hesaplanaca�� i� ger�ek (ekran�n 0 koordinat�na ba�l�) boyutlar
    FDisGercekBoyutlar, FIcGercekBoyutlar: TAlan;

    FKalinlik: TAlan;                             // alt nesne i�eren nesnenin dikd�rtgensel kal�nl��� (1)
    FKenarBosluklari: TAlan;                      // nesnenin bir �st i�in kenar bo�luklar� (2)
    FAltNesneSayisi: TISayi4;                     // nesnenin alt nesne say�s�
    FFareGostergeTipi: TFareImlecTipi;            // nesnenin fare g�stergesi
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
  (1) FKalinlik de�eri, alt nesne i�eren nesneler i�in alt nesnelerin ba�lang�� koordinat
  de�erini belirledi�i i�in �nemlidir

  (2) FKenarBosluklari de�i�keninin i�levi FHiza ile kullan�ld���nda �nemi daha fazla
  �n plana ��kmaktad�r
}

function NesneAdiAl(AGorselNesneTipi: TGorselNesneTipi): string;

implementation

uses donusum;

{==============================================================================
  g�rsel nesnelere isim �retir
 ==============================================================================}
function NesneAdiAl(AGorselNesneTipi: TGorselNesneTipi): string;
begin

  case AGorselNesneTipi of
    gntMasaustu:
    begin
      Inc(MasaustuSayac);
      Result := 'masa�st�' + '.' + IntToStr(MasaustuSayac);
    end;
    gntPencere:
    begin
      Inc(PencereSayac);
      Result := 'pencere' + '.' + IntToStr(PencereSayac);
    end;
    gntDugme:
    begin
      Inc(DugmeSayac);
      Result := 'd��me' + '.' + IntToStr(DugmeSayac);
    end;
    gntGucDugme:
    begin
      Inc(GucDugmesiSayac);
      Result := 'g��d��mesi' + '.' + IntToStr(GucDugmesiSayac);
    end;
    gntListeKutusu:
    begin
      Inc(ListeKutusuSayac);
      Result := 'listekutusu' + '.' + IntToStr(ListeKutusuSayac);
    end;
    gntMenu:
    begin
      Inc(MenuSayac);
      Result := 'men�' + '.' + IntToStr(MenuSayac);
    end;
    gntDefter:
    begin
      Inc(DefterSayac);
      Result := 'defter' + '.' + IntToStr(DefterSayac);
    end;
    gntIslemGostergesi:
    begin
      Inc(IslemGostergesiSayac);
      Result := 'i�lemg�stergesi' + '.' + IntToStr(IslemGostergesiSayac);
    end;
    gntIsaretKutusu:
    begin
      Inc(IsaretKutusuSayac);
      Result := 'i�aretkutusu' + '.' + IntToStr(IsaretKutusuSayac);
    end;
    gntGirisKutusu:
    begin
      Inc(GirisKutusuSayac);
      Result := 'giri�kutusu' + '.' + IntToStr(GirisKutusuSayac);
    end;
    gntDegerDugmesi:
    begin
      Inc(DegerDugmesiSayac);
      Result := 'de�erd��mesi' + '.' + IntToStr(DegerDugmesiSayac);
    end;
    gntEtiket:
    begin
      Inc(EtiketSayac);
      Result := 'etiket' + '.' + IntToStr(EtiketSayac);
    end;
    gntDurumCubugu:
    begin
      Inc(DurumCubuguSayac);
      Result := 'durum�ubu�u' + '.' + IntToStr(DurumCubuguSayac);
    end;
    gntSecimDugmesi:
    begin
      Inc(SecimKutusuSayac);
      Result := 'se�imkutusu' + '.' + IntToStr(SecimKutusuSayac);
    end;
    gntBaglanti:
    begin
      Inc(BaglantiSayac);
      Result := 'ba�lant�' + '.' + IntToStr(BaglantiSayac);
    end;
    gntResim:
    begin
      Inc(ResimSayac);
      Result := 'resim' + '.' + IntToStr(ResimSayac);
    end;
    gntListeGorunum:
    begin
      Inc(ListeGorunumSayac);
      Result := 'listeg�r�n�m' + '.' + IntToStr(ListeGorunumSayac);
    end;
    gntPanel:
    begin
      Inc(PanelSayac);
      Result := 'panel' + '.' + IntToStr(PanelSayac);
    end;
    gntResimDugme:
    begin
      Inc(ResimDugmeSayac);
      Result := 'resimd��me' + '.' + IntToStr(ResimDugmeSayac);
    end;
    gntKaydirmaCubugu:
    begin
      Inc(KaydirmaCubugu);
      Result := 'kayd�rma�ubu�u' + '.' + IntToStr(KaydirmaCubugu);
    end;
    gntKarmaListe:
    begin
      Inc(KarmaListe);
      Result := 'karmaliste' + '.' + IntToStr(KarmaListe);
    end;
    gntAcilirMenu:
    begin
      Inc(AcilirMenu);
      Result := 'a��l�rmenu' + '.' + IntToStr(AcilirMenu);
    end;
  end;
end;

end.
