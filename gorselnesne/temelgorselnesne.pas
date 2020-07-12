{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: temelgorselnesne.pas
  Dosya Ýþlevi: temel görsel nesne yapýsýný içerir

  Güncelleme Tarihi: 15/06/2020

 ==============================================================================}
{$mode objfpc}
unit temelgorselnesne;

interface

uses paylasim;

type
  PTemelGorselNesne = ^TTemelGorselNesne;
  TTemelGorselNesne = object
  private
    // nesnenin sahibi olan görev / program
    FGorevKimlik: TKimlik;
    // nesne kimliði. kimlik deðeri, nesnenin dizi içerisindeki sýra numarasýdýr.
    FKimlik: TKimlik;
    // nesnenin tipi
    FNesneTipi: TGNTip;
    // nesnenin adý
    FNesneAdi: string;
    // nesnenin baþlýk deðeri
    FBaslik: string;
    // nesnenin görünüm özelliði
    FGorunum: Boolean;
  public
    // nesnenin kullaným tipi
    FKullanimTipi: TKullanimTipi;
    // nesnenin ilk oluþturulmasýnda atanan deðerler
    // þu aþamada sadece hizalanan nesnenin normal durumuna döndürülmesi için kullanýlmaktadýr
    FIlkKonum: TKonum;
    FIlkBoyut: TBoyut;
    // nesnenin sol / üst baþlangýç koordinatlarý
    FKonum: TKonum;
    // nesnenin geniþlik / yükseklik boyutlarý
    FBoyut: TBoyut;
    // nesnenin sol, üst, sað, alt kalýnlýklarý
    FKalinlik: TAlan;
    // nesnenin sol / üst çizim baþlangýç koordinatý
    FCizimBaslangic: TKonum;
    // nesnenin 0 baþlangýcýna sahip iç çizim alan kordinatlarý
    // bilgi: nesnenin gerçek fiziksel koordinatlarý FCizimAlan deðerine FCizimBaslangic
    //   deðerinin eklenmesiyle elde edilir
    FCizimAlan: TAlan;
    // nesnenin alt nesne için hiza alaný (alt nesne içeren nesneler için)
    FHizaAlani: TAlan;
    // nesnenin hizalanacaðý yön
    FHiza: THiza;
    // nesneye yazýlacak yazýnýn yatay + dikey hizalanmasý
    FYaziHiza: TYaziHiza;
    // nesnenin alt nesne sayýsý
    FAltNesneSayisi: TISayi4;
    // nesnenin üzerine gelindiðinde görüntülenecek fare göstergesi
    FFareImlecTipi: TFareImlecTipi;
    // nesnenin o anda çizilip çizilmediðini belirten deðiþken.
    // bilgi: pencere çiziminin kontrolü için eklendi
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
  görsel nesneler için isim üretir
 ==============================================================================}
function NesneAdiAl(AGNTip: TGNTip): string;
begin

  case AGNTip of
    gntAcilirMenu:
    begin
      Inc(AcilirMenu);
      Result := 'açýlýrmenu' + '.' + IntToStr(AcilirMenu);
    end;
    gntBaglanti:
    begin
      Inc(BaglantiSayac);
      Result := 'baðlantý' + '.' + IntToStr(BaglantiSayac);
    end;
    gntDegerDugmesi:
    begin
      Inc(DegerDugmesiSayac);
      Result := 'deðerdüðmesi' + '.' + IntToStr(DegerDugmesiSayac);
    end;
    gntDugme:
    begin
      Inc(DugmeSayac);
      Result := 'düðme' + '.' + IntToStr(DugmeSayac);
    end;
    gntDurumCubugu:
    begin
      Inc(DurumCubuguSayac);
      Result := 'durumçubuðu' + '.' + IntToStr(DurumCubuguSayac);
    end;
    gntEtiket:
    begin
      Inc(EtiketSayac);
      Result := 'etiket' + '.' + IntToStr(EtiketSayac);
    end;
    gntGirisKutusu:
    begin
      Inc(GirisKutusuSayac);
      Result := 'giriþkutusu' + '.' + IntToStr(GirisKutusuSayac);
    end;
    gntGucDugmesi:
    begin
      Inc(GucDugmesiSayac);
      Result := 'güçdüðmesi' + '.' + IntToStr(GucDugmesiSayac);
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
    gntKarmaListe:
    begin
      Inc(KarmaListe);
      Result := 'karmaliste' + '.' + IntToStr(KarmaListe);
    end;
    gntKaydirmaCubugu:
    begin
      Inc(KaydirmaCubugu);
      Result := 'kaydýrmaçubuðu' + '.' + IntToStr(KaydirmaCubugu);
    end;
    gntListeGorunum:
    begin
      Inc(ListeGorunumSayac);
      Result := 'listegörünüm' + '.' + IntToStr(ListeGorunumSayac);
    end;
    gntListeKutusu:
    begin
      Inc(ListeKutusuSayac);
      Result := 'listekutusu' + '.' + IntToStr(ListeKutusuSayac);
    end;
    gntMasaustu:
    begin
      Inc(MasaustuSayac);
      Result := 'masaüstü' + '.' + IntToStr(MasaustuSayac);
    end;
    gntMenu:
    begin
      Inc(MenuSayac);
      Result := 'menü' + '.' + IntToStr(MenuSayac);
    end;
    gntOnayKutusu:
    begin
      Inc(IsaretKutusuSayac);
      Result := 'iþaretkutusu' + '.' + IntToStr(IsaretKutusuSayac);
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
      Result := 'resimdüðmesi' + '.' + IntToStr(ResimDugmeSayac);
    end;
    gntSecimDugmesi:
    begin
      Inc(SecimKutusuSayac);
      Result := 'seçimkutusu' + '.' + IntToStr(SecimKutusuSayac);
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
