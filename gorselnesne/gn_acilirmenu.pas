{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_acilirmenu.pas
  Dosya ��levi: a��l�r men� y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 20/06/2020

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
  a��l�r men� kesme �a�r�lar�n� y�netir
 ==============================================================================}
function AcilirMenuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  AcilirMenu: PAcilirMenu;
  AElemanAdi: string;
  AResimSiraNo: TISayi4;
begin

  case AIslevNo of

    // nesne olu�tur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);

    // a��l�r men�y� g�r�nt�le
    ISLEV_GOSTER:
    begin

      AcilirMenu := PAcilirMenu(AcilirMenu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^,
        gntAcilirMenu));
      if(AcilirMenu <> nil) then AcilirMenu^.Goster;
    end;

    // a��l�r men�y� gizle
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

        { TODO : her bir men� eklendi�inde men�n�n y�ksekli�i yeniden belirlenecektir }
        AcilirMenu^.FMenuBaslikListesi^.Ekle(AElemanAdi);
        AcilirMenu^.FMenuResimListesi^.Ekle(AResimSiraNo);

        Result := 1;
      end else Result := 0;
    end;

    // se�ilen eleman�n s�ra de�erini al
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
  a��l�r men� nesnesini olu�turur
 ==============================================================================}
function NesneOlustur(AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
  ASeciliYaziRengi: TRenk): TKimlik;
var
  AcilirMenu: PAcilirMenu;
begin

  { TODO : GAktifMasaustu de�eri API i�levlerinde de�i�tirilerek nesnenin sahibi olan nesne atanacak }
  AcilirMenu := AcilirMenu^.Olustur(GAktifMasaustu, 0, 0, 300, (24 * 5) + 6, 24,
    AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi, ASeciliYaziRengi);

  if(AcilirMenu = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := AcilirMenu^.Kimlik;
end;

{==============================================================================
  a��l�r men� nesnesini olu�turur
 ==============================================================================}
function TAcilirMenu.Olustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik,
  AElemanYukseklik: TISayi4; AKenarlikRengi, AGovdeRengi, ASecimRengi, ANormalYaziRengi,
  ASeciliYaziRengi: TRenk): PAcilirMenu;
var
  AcilirMenu: PAcilirMenu;
begin

  { TODO : men�n�n geni�lik ve y�ksekli�i otomatik olarak belirlenecektir }
  AcilirMenu := PAcilirMenu(inherited Olustur(AAtaNesne, gntAcilirMenu, ASol, AUst,
    AGenislik, AYukseklik, AElemanYukseklik, AKenarlikRengi, AGovdeRengi));

  AcilirMenu^.FMenuOlayGeriDonusAdresi := @OlaylariIsle;
  AcilirMenu^.FAcilirMenuOlayGeriDonusAdresi := nil;

  AcilirMenu^.FSecimRenk := ASecimRengi;
  AcilirMenu^.FNormalYaziRenk := ANormalYaziRengi;
  AcilirMenu^.FSeciliYaziRenk := ASeciliYaziRengi;

  // nesne adresini geri d�nd�r
  Result := AcilirMenu;
end;

{==============================================================================
  a��l�r men� nesnesini yok eder
 ==============================================================================}
procedure TAcilirMenu.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  a��l�r men� nesnesini g�r�nt�ler
 ==============================================================================}
procedure TAcilirMenu.Goster;
var
  AcilirMenu: PAcilirMenu;
begin

  inherited Goster;

  AcilirMenu := PAcilirMenu(AcilirMenu^.NesneAl(Kimlik));
  if(AcilirMenu = nil) then Exit;

  // men�y� farenin bulundu�u konumda g�r�nt�le
  AcilirMenu^.FKonum.Sol := GFareSurucusu.YatayKonum;
  AcilirMenu^.FKonum.Ust := GFareSurucusu.DikeyKonum;
end;

{==============================================================================
  a��l�r men� nesnesini gizler
 ==============================================================================}
procedure TAcilirMenu.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  a��l�r men� nesnesini boyutland�r�r
 ==============================================================================}
procedure TAcilirMenu.Boyutlandir;
begin

end;

{==============================================================================
  a��l�r men� nesnesini �izer
 ==============================================================================}
procedure TAcilirMenu.Ciz;
begin

  inherited Ciz;
end;

{==============================================================================
  a��l�r men� nesne olaylar�n� i�ler
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
