{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_acilirmenu.pas
  Dosya Ýþlevi: açýlýr menü yönetim iþlevlerini içerir

  Güncelleme Tarihi: 20/06/2020

 ==============================================================================}
{$mode objfpc}
unit gn_acilirmenu;

interface

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi, gn_menu;

type
  PAcilirMenu = ^TAcilirMenu;
  TAcilirMenu = object(TMenu)
  public
    FAcilirMenuOlayGeriDonusAdresi: TOlaylariIsle;
    function Olustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik,
      AElemanYukseklik: TISayi4; AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
      ASeciliYaziRengi: TRenk): PAcilirMenu;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

function AcilirMenuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
  ASeciliYaziRengi: TRenk): TKimlik;

implementation

uses genel, temelgorselnesne;

{==============================================================================
  açýlýr menü kesme çaðrýlarýný yönetir
 ==============================================================================}
function AcilirMenuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  AcilirMenu: PAcilirMenu;
  AElemanAdi: string;
  AResimSiraNo: TISayi4;
begin

  case AIslevNo of

    // nesne oluþtur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);

    // açýlýr menüyü görüntüle
    ISLEV_GOSTER:
    begin

      AcilirMenu := PAcilirMenu(AcilirMenu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^,
        gntAcilirMenu));
      if(AcilirMenu <> nil) then AcilirMenu^.Goster;
    end;

    // açýlýr menüyü gizle
    ISLEV_GIZLE:
    begin

      AcilirMenu := PAcilirMenu(AcilirMenu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^,
        gntAcilirMenu));
      if(AcilirMenu <> nil) then AcilirMenu^.Gizle;
    end;

    // eleman ekle
    $0100:
    begin

      AcilirMenu := PAcilirMenu(AcilirMenu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^,
        gntAcilirMenu));

      AElemanAdi := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^;
      AResimSiraNo := PISayi4(ADegiskenler + 08)^;

      if(AcilirMenu <> nil) then
      begin

        { TODO : her bir menü eklendiðinde menünün yüksekliði yeniden belirlenecektir }
        AcilirMenu^.FMenuBaslikListesi^.Ekle(AElemanAdi);
        AcilirMenu^.FMenuResimListesi^.Ekle(AResimSiraNo);

        Result := 1;
      end else Result := 0;
    end;

    // seçilen elemanýn sýra deðerini al
    $0200:
    begin

      AcilirMenu := PAcilirMenu(AcilirMenu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^,
        gntAcilirMenu));
      if(AcilirMenu <> nil) then Result := AcilirMenu^.FSeciliSiraNo
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  açýlýr menü nesnesini oluþturur
 ==============================================================================}
function NesneOlustur(AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
  ASeciliYaziRengi: TRenk): TKimlik;
var
  AcilirMenu: PAcilirMenu;
begin

  { TODO : GAktifMasaustu deðeri API iþlevlerinde deðiþtirilerek nesnenin sahibi olan nesne atanacak }
  AcilirMenu := AcilirMenu^.Olustur(GAktifMasaustu, 0, 0, 300, (24 * 5) + 6, 24,
    AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi, ASeciliYaziRengi);

  if(AcilirMenu = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := AcilirMenu^.Kimlik;
end;

{==============================================================================
  açýlýr menü nesnesini oluþturur
 ==============================================================================}
function TAcilirMenu.Olustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik,
  AElemanYukseklik: TISayi4; AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
  ASeciliYaziRengi: TRenk): PAcilirMenu;
var
  AcilirMenu: PAcilirMenu;
begin

  { TODO : menünün geniþlik ve yüksekliði otomatik olarak belirlenecektir }
  AcilirMenu := PAcilirMenu(inherited Olustur(AAtaNesne, gntAcilirMenu, ASol, AUst,
    AGenislik, AYukseklik, AElemanYukseklik, AKenarlikRengi, AGovdeRengi));

  AcilirMenu^.FMenuOlayGeriDonusAdresi := @OlaylariIsle;
  AcilirMenu^.FAcilirMenuOlayGeriDonusAdresi := nil;

  AcilirMenu^.FSecimRenk := ASecimRengi;
  AcilirMenu^.FNormalYaziRenk := ANormalYaziRengi;
  AcilirMenu^.FSeciliYaziRenk := ASeciliYaziRengi;

  // nesne adresini geri döndür
  Result := AcilirMenu;
end;

{==============================================================================
  açýlýr menü nesnesini yok eder
 ==============================================================================}
procedure TAcilirMenu.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  açýlýr menü nesnesini görüntüler
 ==============================================================================}
procedure TAcilirMenu.Goster;
var
  AcilirMenu: PAcilirMenu;
begin

  inherited Goster;

  AcilirMenu := PAcilirMenu(AcilirMenu^.NesneAl(Kimlik));
  if(AcilirMenu = nil) then Exit;

  // menüyü farenin bulunduðu konumda görüntüle
  AcilirMenu^.FKonum.Sol := GFareSurucusu.YatayKonum;
  AcilirMenu^.FKonum.Ust := GFareSurucusu.DikeyKonum;
end;

{==============================================================================
  açýlýr menü nesnesini gizler
 ==============================================================================}
procedure TAcilirMenu.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  açýlýr menü nesnesini boyutlandýrýr
 ==============================================================================}
procedure TAcilirMenu.Boyutlandir;
begin

end;

{==============================================================================
  açýlýr menü nesnesini çizer
 ==============================================================================}
procedure TAcilirMenu.Ciz;
begin

  inherited Ciz;
end;

{==============================================================================
  açýlýr menü nesne olaylarýný iþler
 ==============================================================================}
procedure TAcilirMenu.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  AcilirMenu: PAcilirMenu;
begin

  AcilirMenu := PAcilirMenu(AGonderici);
  if(AcilirMenu = nil) then Exit;

  if not(AcilirMenu^.FAcilirMenuOlayGeriDonusAdresi = nil) then
    AcilirMenu^.FAcilirMenuOlayGeriDonusAdresi(AcilirMenu, AOlay)
  else GorevListesi[AcilirMenu^.GorevKimlik]^.OlayEkle(AcilirMenu^.GorevKimlik, AOlay);
end;

end.
