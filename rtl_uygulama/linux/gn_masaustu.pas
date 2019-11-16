{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_masaustu.pas
  Dosya İşlevi: masaüstü nesne işlevlerini içerir

  Güncelleme Tarihi: 13/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_masaustu;

interface

type
  PMasaustu = ^TMasaustu;
  TMasaustu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AMasaustuAdi: string): TKimlik;
    function Goster: TKimlik;
    function MevcutMasaustuSayisi: TSayi4;
    function AktifMasaustu: TKimlik;
    function Aktiflestir(AKimlik: TKimlik): Boolean;
    procedure Guncelle;
    procedure MasaustuRenginiDegistir(ARenk: TRenk);
    procedure MasaustuResminiDegistir(ADosyaTamYol: string);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TMasaustu.Olustur(AMasaustuAdi: string): TKimlik;
begin

  FKimlik := _MasaustuOlustur(AMasaustuAdi);
  Result := FKimlik;
end;

function TMasaustu.Goster: TKimlik;
begin

  Result := _MasaustuGoster(FKimlik);
end;

function TMasaustu.MevcutMasaustuSayisi: TSayi4;
begin

  Result := _MevcutMasaustuSayisi;
end;

function TMasaustu.AktifMasaustu: TKimlik;
begin

  FKimlik := _AktifMasaustu;
  Result := FKimlik;
end;

function TMasaustu.Aktiflestir(AKimlik: TKimlik): Boolean;
begin

  Result := _MasaustuAktiflestir(AKimlik);
end;

procedure TMasaustu.Guncelle;
begin

  _MasaustuGuncelle(FKimlik);
end;

procedure TMasaustu.MasaustuRenginiDegistir(ARenk: TRenk);
begin

  _MasaustuRenginiDegistir(FKimlik, ARenk);
end;

procedure TMasaustu.MasaustuResminiDegistir(ADosyaTamYol: string);
begin

  _MasaustuResminiDegistir(FKimlik, ADosyaTamYol);
end;

end.
