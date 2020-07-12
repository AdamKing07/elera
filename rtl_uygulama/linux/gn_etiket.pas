{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_etiket.pas
  Dosya İşlevi: etiket (label) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_etiket;

interface

type
  PEtiket = ^TEtiket;
  TEtiket = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
      ABaslik: string): TKimlik;
    procedure Goster;
    procedure Degistir(ABaslik: string);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _EtiketOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik; assembler;
procedure _EtiketGoster(AKimlik: TKimlik); assembler;
procedure _EtiketDegistir(AKimlik: TKimlik; ABaslik: string); assembler;

implementation

function TEtiket.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik;
begin

  FKimlik := _EtiketOlustur(AAtaKimlik, A1, B1, ARenk, ABaslik);
  Result := FKimlik;
end;

procedure TEtiket.Goster;
begin

  _EtiketGoster(FKimlik);
end;

procedure TEtiket.Degistir(ABaslik: string);
begin

  _EtiketDegistir(FKimlik, ABaslik);
end;

function _EtiketOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  ARenk
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,ETIKET_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _EtiketGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ETIKET_GOSTER
  int   $34
  add   esp,4
end;

procedure _EtiketDegistir(AKimlik: TKimlik; ABaslik: string);
asm
  push  ABaslik
  push  AKimlik
  mov   eax,ETIKET_DEGISTIR
  int   $34
  add   esp,8
end;

end.
