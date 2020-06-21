{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: temelgorselnesne.pas
  Dosya ��levi: temel g�rsel nesne yap�s�n� i�erir

  G�ncelleme Tarihi: 15/06/2020

 ==============================================================================}
{$mode objfpc}
unit temelgorselnesne;

interface

uses paylasim;

type
  PTemelGorselNesne = ^TTemelGorselNesne;
  TTemelGorselNesne = object
  private
    // nesnenin sahibi olan g�rev / program
    FGorevKimlik: TKimlik;
    // nesne kimli�i. kimlik de�eri, nesnenin dizi i�erisindeki s�ra numaras�d�r.
    FKimlik: TKimlik;
    // nesnenin tipi
    FNesneTipi: TGNTip;
    // nesnenin ad�
    FNesneAdi: string;
    // nesnenin ba�l�k de�eri
    FBaslik: string;
    // nesnenin g�r�n�m �zelli�i
    FGorunum: Boolean;
  public
    // nesnenin kullan�m tipi
    FKullanimTipi: TKullanimTipi;
    // nesnenin ilk olu�turulmas�nda atanan de�erler
    // �u a�amada sadece hizalanan nesnenin normal durumuna d�nd�r�lmesi i�in kullan�lmaktad�r
    FIlkKonum: TKonum;
    FIlkBoyut: TBoyut;
    // nesnenin sol / �st ba�lang�� koordinatlar�
    FKonum: TKonum;
    // nesnenin geni�lik / y�kseklik boyutlar�
    FBoyut: TBoyut;
    // nesnenin sol, �st, sa�, alt kal�nl�klar�
    FKalinlik: TAlan;
    // nesnenin sol / �st �izim ba�lang�� koordinat�
    FCizimBaslangic: TKonum;
    // nesnenin 0 ba�lang�c�na sahip i� �izim alan kordinatlar�
    // bilgi: nesnenin ger�ek fiziksel koordinatlar� FCizimAlan de�erine FCizimBaslangic
    //   de�erinin eklenmesiyle elde edilir
    FCizimAlan: TAlan;
    // nesnenin alt nesne i�in hiza alan� (alt nesne i�eren nesneler i�in)
    FHizaAlani: TAlan;
    // nesnenin hizalanaca�� y�n
    FHiza: THiza;
    // nesneye yaz�lacak yaz�n�n yatay + dikey hizalanmas�
    FYaziHiza: TYaziHiza;
    // nesnenin alt nesne say�s�
    FAltNesneSayisi: TISayi4;
    // nesnenin �zerine gelindi�inde g�r�nt�lenecek fare g�stergesi
    FFareImlecTipi: TFareImlecTipi;
    // nesnenin o anda �izilip �izilmedi�ini belirten de�i�ken.
    // bilgi: pencere �iziminin kontrol� i�in eklendi
    FCiziliyor: Boolean;
  private
    procedure NesneTipiYaz(AGNTip: TGNTip);
    procedure BaslikYaz(ABaslik: string);
  published
    property GorevKimlik: TKimlik read FGorevKimlik write FGorevKimlik;
    property Kimlik: TKimlik read FKimlik write FKimlik;
    property NesneTipi: TGNTip read FNesneTipi write NesneTipiYaz;
    property NesneAdi: string read FNesneAdi;
    property Baslik: string read FBaslik write BaslikYaz;
    property Gorunum: Boolean read FGorunum write FGorunum;
  end;

var
  AcilirMenu: TISayi4 = 0;
  BaglantiSayac: TISayi4 = 0;
  DefterSayac: TISayi4 = 0;
  DegerDugmesiSayac: TISayi4 = 0;
  DugmeSayac: TISayi4 = 0;
  DurumCubuguSayac: TISayi4 = 0;
  EtiketSayac: TISayi4 = 0;
  GirisKutusuSayac: TISayi4 = 0;
  GucDugmesiSayac: TISayi4 = 0;
  IsaretKutusuSayac: TISayi4 = 0;
  IslemGostergesiSayac: TISayi4 = 0;
  KarmaListe: TISayi4 = 0;
  KaydirmaCubugu: TISayi4 = 0;
  ListeGorunumSayac: TISayi4 = 0;
  ListeKutusuSayac: TISayi4 = 0;
  MasaustuSayac: TISayi4 = 0;
  MenuSayac: TISayi4 = 0;
  PanelSayac: TISayi4 = 0;
  PencereSayac: TISayi4 = 0;
  ResimDugmeSayac: TISayi4 = 0;
  ResimSayac: TISayi4 = 0;
  SecimKutusuSayac: TISayi4 = 0;

function NesneAdiAl(AGNTip: TGNTip): string;

implementation

uses donusum;

{==============================================================================
  g�rsel nesneler i�in isim �retir
 ==============================================================================}
function NesneAdiAl(AGNTip: TGNTip): string;
begin

  case AGNTip of
    gntAcilirMenu:
    begin
      Inc(AcilirMenu);
      Result := 'a��l�rmenu' + '.' + IntToStr(AcilirMenu);
    end;
    gntBaglanti:
    begin
      Inc(BaglantiSayac);
      Result := 'ba�lant�' + '.' + IntToStr(BaglantiSayac);
    end;
    gntDegerDugmesi:
    begin
      Inc(DegerDugmesiSayac);
      Result := 'de�erd��mesi' + '.' + IntToStr(DegerDugmesiSayac);
    end;
    gntDugme:
    begin
      Inc(DugmeSayac);
      Result := 'd��me' + '.' + IntToStr(DugmeSayac);
    end;
    gntDurumCubugu:
    begin
      Inc(DurumCubuguSayac);
      Result := 'durum�ubu�u' + '.' + IntToStr(DurumCubuguSayac);
    end;
    gntEtiket:
    begin
      Inc(EtiketSayac);
      Result := 'etiket' + '.' + IntToStr(EtiketSayac);
    end;
    gntGirisKutusu:
    begin
      Inc(GirisKutusuSayac);
      Result := 'giri�kutusu' + '.' + IntToStr(GirisKutusuSayac);
    end;
    gntGucDugmesi:
    begin
      Inc(GucDugmesiSayac);
      Result := 'g��d��mesi' + '.' + IntToStr(GucDugmesiSayac);
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
    gntKarmaListe:
    begin
      Inc(KarmaListe);
      Result := 'karmaliste' + '.' + IntToStr(KarmaListe);
    end;
    gntKaydirmaCubugu:
    begin
      Inc(KaydirmaCubugu);
      Result := 'kayd�rma�ubu�u' + '.' + IntToStr(KaydirmaCubugu);
    end;
    gntListeGorunum:
    begin
      Inc(ListeGorunumSayac);
      Result := 'listeg�r�n�m' + '.' + IntToStr(ListeGorunumSayac);
    end;
    gntListeKutusu:
    begin
      Inc(ListeKutusuSayac);
      Result := 'listekutusu' + '.' + IntToStr(ListeKutusuSayac);
    end;
    gntMasaustu:
    begin
      Inc(MasaustuSayac);
      Result := 'masa�st�' + '.' + IntToStr(MasaustuSayac);
    end;
    gntMenu:
    begin
      Inc(MenuSayac);
      Result := 'men�' + '.' + IntToStr(MenuSayac);
    end;
    gntOnayKutusu:
    begin
      Inc(IsaretKutusuSayac);
      Result := 'i�aretkutusu' + '.' + IntToStr(IsaretKutusuSayac);
    end;
    gntPanel:
    begin
      Inc(PanelSayac);
      Result := 'panel' + '.' + IntToStr(PanelSayac);
    end;
    gntPencere:
    begin
      Inc(PencereSayac);
      Result := 'pencere' + '.' + IntToStr(PencereSayac);
    end;
    gntResim:
    begin
      Inc(ResimSayac);
      Result := 'resim' + '.' + IntToStr(ResimSayac);
    end;
    gntResimDugmesi:
    begin
      Inc(ResimDugmeSayac);
      Result := 'resimd��mesi' + '.' + IntToStr(ResimDugmeSayac);
    end;
    gntSecimDugmesi:
    begin
      Inc(SecimKutusuSayac);
      Result := 'se�imkutusu' + '.' + IntToStr(SecimKutusuSayac);
    end;
  end;
end;

procedure TTemelGorselNesne.NesneTipiYaz(AGNTip: TGNTip);
begin

  if(AGNTip = FNesneTipi) then Exit;

  FNesneTipi := AGNTip;

  FNesneAdi := NesneAdiAl(AGNTip);

  FBaslik := FNesneAdi;
end;

procedure TTemelGorselNesne.BaslikYaz(ABaslik: string);
begin

  if(ABaslik = FBaslik) then Exit;

  FBaslik := ABaslik;
end;

end.
