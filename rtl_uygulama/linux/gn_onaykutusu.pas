{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_onaykutusu.pas
  Dosya İşlevi: onay kutusu nesne işlevlerini içerir
  İşlev No: 0x02 / 0x09

  Güncelleme Tarihi: 31/05/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_onaykutusu;

interface

type
  POnayKutusu = ^TOnayKutusu;
  TOnayKutusu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ABaslik: string): TKimlik;
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _OnayKutusuOlustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ABaslik: string): TKimlik; assembler;
procedure _OnayKutusuGoster(AKimlik: TKimlik); assembler;

implementation

function TOnayKutusu.Olustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ABaslik: string): TKimlik;
begin

  FKimlik := _OnayKutusuOlustur(AAtaKimlik, ASol, AUst, ABaslik);
  Result := FKimlik;
end;

procedure TOnayKutusu.Goster;
begin

  _OnayKutusuGoster(FKimlik);
end;

function _OnayKutusuOlustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  AUst
  push  ASol
  push  AAtaKimlik
  mov   eax,ONAYKUTUSU_OLUSTUR
  int   $34
  add   esp,16
end;

procedure _OnayKutusuGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ONAYKUTUSU_GOSTER
  int   $34
  add   esp,4
end;

end.
