{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_etiket.pas
  Dosya İşlevi: etiket (TLabel) nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/07/2020

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
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ARenk: TRenk;
      ABaslik: string): TKimlik;
    procedure Goster;
    procedure Degistir(ABaslik: string);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _EtiketOlustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik; assembler;
procedure _EtiketGoster(AKimlik: TKimlik); assembler;
procedure _EtiketDegistir(AKimlik: TKimlik; ABaslik: string); assembler;

implementation

function TEtiket.Olustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik;
begin

  FKimlik := _EtiketOlustur(AAtaKimlik, ASol, AUst, ARenk, ABaslik);
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

function _EtiketOlustur(AAtaKimlik: TKimlik; ASol, AUst: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik;
asm
  push  DWORD ABaslik
  push  DWORD ARenk
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,ETIKET_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _EtiketGoster(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,ETIKET_GOSTER
  int   $34
  add   esp,4
end;

procedure _EtiketDegistir(AKimlik: TKimlik; ABaslik: string);
asm
  push  DWORD ABaslik
  push  DWORD AKimlik
  mov   eax,ETIKET_DEGISTIR
  int   $34
  add   esp,8
end;

end.
