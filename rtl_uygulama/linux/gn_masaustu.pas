{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_masaustu.pas
  Dosya İşlevi: masaüstü nesne işlevlerini içerir

  Güncelleme Tarihi: 13/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
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

function _MasaustuOlustur(AMasaustuAdi: string): TKimlik; assembler;
function _MasaustuGoster(AKimlik: TKimlik): TKimlik; assembler;
function _MevcutMasaustuSayisi: TSayi4; assembler;
function _AktifMasaustu: TKimlik; assembler;
function _MasaustuAktiflestir(AKimlik: TKimlik): Boolean; assembler;
procedure _MasaustuGuncelle(AKimlik: TKimlik); assembler;
procedure _MasaustuRenginiDegistir(AKimlik: TKimlik; ARenk: TRenk); assembler;
procedure _MasaustuResminiDegistir(AKimlik: TKimlik; ADosyaTamYol: string); assembler;

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

function _MasaustuOlustur(AMasaustuAdi: string): TKimlik;
asm
  push  AMasaustuAdi
  mov	  eax,MASAUSTU_OLUSTUR
  int	  $34
  add	  esp,4
end;

function _MasaustuGoster(AKimlik: TKimlik): TKimlik;
asm
  push	AKimlik
  mov	  eax,MASAUSTU_GOSTER
  int	  $34
  add	  esp,4
end;

function _MevcutMasaustuSayisi: TSayi4;
asm
  mov	  eax,MASAUSTU_MEVCUTSAYI
  int	  $34
end;

function _AktifMasaustu: TKimlik;
asm
  mov	  eax,$04020102
  int	  $34
end;

function _MasaustuAktiflestir(AKimlik: TKimlik): Boolean;
asm
  push	AKimlik
  mov	  eax,MASAUSTU_AKTIFLESTIR
  int	  $34
  add	  esp,4
end;

procedure _MasaustuGuncelle(AKimlik: TKimlik);
asm
  push	AKimlik
  mov	  eax,$08040102
  int	  $34
  add	  esp,4
end;

procedure _MasaustuRenginiDegistir(AKimlik: TKimlik; ARenk: TRenk);
asm
  push	ARenk
  push  AKimlik
  mov	  eax,$02040102
  int	  $34
  add	  esp,8
end;

procedure _MasaustuResminiDegistir(AKimlik: TKimlik; ADosyaTamYol: string);
asm
  push	ADosyaTamYol
  push  AKimlik
  mov	  eax,$04040102
  int	  $34
  add	  esp,8
end;

end.
