{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: tuval.pas
  Dosya İşlevi: pencere içeriğine yazım - çizim işlevlerini içerir

  Güncelleme Tarihi: 06/10/2019

 ==============================================================================}
{$mode objfpc}
unit tuval;

interface

type
  TFirca = object
  public
    Renk: TRenk;
  end;

  TKalem = object
  public
    Renk: TRenk;
  end;

  TTuval = object
  private
    FKimlik: TKimlik;
    FFirca: TFirca;
    FKalem: TKalem;
    function KalemRengiAl: TRenk;
    procedure KalemRengiYaz(ARenk: TRenk);
    function FircaRengiAl: TRenk;
    procedure FircaRengiYaz(ARenk: TRenk);
  public
    procedure Olustur(APencereKimlik: TKimlik);
    procedure HarfYaz(A1, B1: TISayi4; AKarakter: Char);
    procedure YaziYaz(A1, B1: TISayi4; ADeger: string);
    procedure SayiYaz10(A1, B1: TISayi4; ADeger: TISayi4);
    procedure SayiYaz16(A1, B1: TISayi4; AOnekYaz: LongBool; AHaneSayisi: TSayi4;
      ADeger: TISayi4);
    procedure SaatYaz(A1, B1: TISayi4; ASaat: TSaat);
    procedure IPAdresiYaz(A1, B1: TISayi4; AIPAdres: PIPAdres);
    procedure MACAdresiYaz(A1, B1: TISayi4; AMACAdres: PMACAdres);
    procedure PixelYaz(A1, B1: TISayi4; ARenk: TRenk);
    procedure Cizgi(A1, B1, A2, B2: TISayi4; ARenk: TRenk);
    procedure Dikdortgen(A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: Boolean);
    procedure Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: Boolean);
    property FircaRengi: TColor read FircaRengiAl write FircaRengiYaz;
    property KalemRengi: TColor read KalemRengiAl write KalemRengiYaz;
  published
  end;

implementation

procedure TTuval.Olustur(APencereKimlik: TKimlik);
begin

  FKimlik := APencereKimlik;
  FFirca.Renk := RENK_KIRMIZI;
  FKalem.Renk := RENK_SIYAH;
end;

function TTuval.KalemRengiAl: TRenk;
begin

  Result := FKalem.Renk;
end;

procedure TTuval.KalemRengiYaz(ARenk: TRenk);
begin

  FKalem.Renk := ARenk;
end;

function TTuval.FircaRengiAl: TRenk;
begin

  Result := FFirca.Renk;
end;

procedure TTuval.FircaRengiYaz(ARenk: TRenk);
begin

  FFirca.Renk := ARenk;
end;

procedure TTuval.HarfYaz(A1, B1: TISayi4; AKarakter: Char);
begin

  _HarfYaz(FKimlik, A1, B1, FKalem.Renk, AKarakter);
end;

procedure TTuval.YaziYaz(A1, B1: TISayi4; ADeger: string);
begin

  _YaziYaz(FKimlik, A1, B1, FKalem.Renk, ADeger);
end;

procedure TTuval.SayiYaz10(A1, B1: TISayi4; ADeger: TISayi4);
begin

  _SayiYaz10(FKimlik, A1, B1, FKalem.Renk, ADeger);
end;

procedure TTuval.SayiYaz16(A1, B1: TISayi4; AOnekYaz: LongBool; AHaneSayisi: TSayi4;
  ADeger: TISayi4);
begin

  _SayiYaz16(FKimlik, A1, B1, FKalem.Renk, AOnekYaz, AHaneSayisi, ADeger);
end;

procedure TTuval.SaatYaz(A1, B1: TISayi4; ASaat: TSaat);
begin

  _SaatYaz(FKimlik, A1, B1, FKalem.Renk, ASaat);
end;

procedure TTuval.IPAdresiYaz(A1, B1: TISayi4; AIPAdres: PIPAdres);
begin

  _IPAdresiYaz(FKimlik, A1, B1, FKalem.Renk, AIPAdres);
end;

procedure TTuval.MACAdresiYaz(A1, B1: TISayi4; AMACAdres: PMACAdres);
begin

  _MACAdresiYaz(FKimlik, A1, B1, FKalem.Renk, AMACAdres);
end;

procedure TTuval.PixelYaz(A1, B1: TISayi4; ARenk: TRenk);
begin

  _PixelYaz(FKimlik, A1, B1, ARenk);
end;

procedure TTuval.Cizgi(A1, B1, A2, B2: TISayi4; ARenk: TRenk);
begin

  _Cizgi(FKimlik, A1, B1, A2, B2, ARenk);
end;

procedure TTuval.Dikdortgen(A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: Boolean);
begin

  _Dikdortgen(FKimlik, A1, B1, A2, B2, ARenk, ADoldur);
end;

procedure TTuval.Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: Boolean);
begin

  _Daire(FKimlik, A1, B1, AYariCap, ARenk, ADoldur);
end;

end.
