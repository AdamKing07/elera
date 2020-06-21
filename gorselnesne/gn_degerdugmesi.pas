{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_degerdugmesi.pp
  Dosya ��levi: art�rma / eksiltme (updown) d��me y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 20/06/2020

 ==============================================================================}
{$mode objfpc}
unit gn_degerdugmesi;

interface

uses gorselnesne, paylasim, gn_resimdugmesi, gn_panel;

type
  PDegerDugmesi = ^TDegerDugmesi;
  TDegerDugmesi = object(TPanel)
  private
    FArtirmaDugmesi,
    FEksiltmeDugmesi: PResimDugmesi;
    procedure ResimDugmeOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4): PDegerDugmesi;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

function DegerDugmesiCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, temelgorselnesne;

{==============================================================================
  art�rma / eksiltme d��me kesme �a�r�lar�n� y�netir
 ==============================================================================}
function DegerDugmesiCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  DegerDugmesi: PDegerDugmesi;
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

      DegerDugmesi := PDegerDugmesi(DegerDugmesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      DegerDugmesi^.Goster;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini olu�turur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  DegerDugmesi: PDegerDugmesi;
begin

  DegerDugmesi := DegerDugmesi^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik);

  if(DegerDugmesi = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := DegerDugmesi^.Kimlik;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini olu�turur
 ==============================================================================}
function TDegerDugmesi.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PDegerDugmesi;
var
  DegerDugmesi: PDegerDugmesi;
begin

  DegerDugmesi := PDegerDugmesi(inherited Olustur(AKullanimTipi, AAtaNesne,
    ASol, AUst, 18, 21, 0, 0, 0, 0, ''));

  DegerDugmesi^.NesneTipi := gntDegerDugmesi;

  DegerDugmesi^.Baslik := '';

  DegerDugmesi^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  DegerDugmesi^.AnaOlayCagriAdresi := @OlaylariIsle;

  // $10000000 + 1 = yukar� ok resmi
  DegerDugmesi^.FArtirmaDugmesi := DegerDugmesi^.FArtirmaDugmesi^.Olustur(ktBilesen,
    DegerDugmesi, 0, 0, 18, 10, $10000000 + 1, True);
  DegerDugmesi^.FArtirmaDugmesi^.FRDOlayGeriDonusumAdresi := @ResimDugmeOlaylariniIsle;

  // $10000000 + 2 = a�a�� ok resmi
  DegerDugmesi^.FEksiltmeDugmesi := DegerDugmesi^.FEksiltmeDugmesi^.Olustur(ktBilesen,
    DegerDugmesi, 0, 11, 18, 10, $10000000 + 2, True);
  DegerDugmesi^.FEksiltmeDugmesi^.FRDOlayGeriDonusumAdresi := @ResimDugmeOlaylariniIsle;

  // kimlik adresini geri d�nd�r
  Result := DegerDugmesi;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini yok eder
 ==============================================================================}
procedure TDegerDugmesi.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini g�r�nt�ler
 ==============================================================================}
procedure TDegerDugmesi.Goster;
var
  DegerDugmesi: PDegerDugmesi;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  DegerDugmesi := PDegerDugmesi(DegerDugmesi^.NesneAl(Kimlik));
  if(DegerDugmesi = nil) then Exit;

  DegerDugmesi^.FArtirmaDugmesi^.Goster;
  DegerDugmesi^.FEksiltmeDugmesi^.Goster;

  inherited Goster;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini gizler
 ==============================================================================}
procedure TDegerDugmesi.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini boyutland�r�r
 ==============================================================================}
procedure TDegerDugmesi.Boyutlandir;
var
  DegerDugmesi: PDegerDugmesi;
begin

  DegerDugmesi := PDegerDugmesi(DegerDugmesi^.NesneAl(Kimlik));
  if(DegerDugmesi = nil) then Exit;

  DegerDugmesi^.Hizala;
end;

{==============================================================================
  art�rma / eksiltme d��me nesnesini �izer
 ==============================================================================}
procedure TDegerDugmesi.Ciz;
var
  DegerDugmesi: PDegerDugmesi;
begin

  DegerDugmesi := PDegerDugmesi(DegerDugmesi^.NesneAl(Kimlik));
  if(DegerDugmesi = nil) then Exit;

  inherited Ciz;

  DegerDugmesi^.FEksiltmeDugmesi^.Ciz;
  DegerDugmesi^.FArtirmaDugmesi^.Ciz;
end;

{==============================================================================
  art�rma / eksiltme d��me nesne olaylar�n� i�ler
 ==============================================================================}
procedure TDegerDugmesi.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  DegerDugmesi: PDegerDugmesi;
begin

  DegerDugmesi := PDegerDugmesi(AGonderici);
  if(DegerDugmesi = nil) then Exit;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := DegerDugmesi^.FFareImlecTipi;
end;

{==============================================================================
  art�rma / eksiltme d��mesinin sahip oldu�u resim d��mesi olaylar�n� i�ler
 ==============================================================================}
procedure TDegerDugmesi.ResimDugmeOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  DegerDugmesi: PDegerDugmesi;
  ResimDugmesi: PResimDugmesi;
begin

  ResimDugmesi := PResimDugmesi(AGonderici);
  if(ResimDugmesi = nil) then Exit;

  DegerDugmesi := PDegerDugmesi(ResimDugmesi^.AtaNesne);

  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    if(AOlay.Kimlik = DegerDugmesi^.FArtirmaDugmesi^.Kimlik) then
    begin

      // nesnenin olay �a�r� adresini �a��r veya uygulamaya mesaj g�nder
      AOlay.Kimlik := DegerDugmesi^.Kimlik;
      AOlay.Deger1 := 0;
      if not(DegerDugmesi^.OlayCagriAdresi = nil) then
        DegerDugmesi^.OlayCagriAdresi(DegerDugmesi, AOlay)
      else GorevListesi[DegerDugmesi^.GorevKimlik]^.OlayEkle(DegerDugmesi^.GorevKimlik, AOlay);
    end
    else if(AOlay.Kimlik = DegerDugmesi^.FEksiltmeDugmesi^.Kimlik) then
    begin

      // nesnenin olay �a�r� adresini �a��r veya uygulamaya mesaj g�nder
      AOlay.Kimlik := DegerDugmesi^.Kimlik;
      AOlay.Deger1 := 1;
      if not(DegerDugmesi^.OlayCagriAdresi = nil) then
        DegerDugmesi^.OlayCagriAdresi(DegerDugmesi, AOlay)
      else GorevListesi[DegerDugmesi^.GorevKimlik]^.OlayEkle(DegerDugmesi^.GorevKimlik, AOlay);
    end;
  end;
end;

end.
