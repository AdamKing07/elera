{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_degerdugmesi.pas
  Dosya İşlevi: artırma / eksiltme (updown) düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_degerdugmesi;

interface

type
  PDegerDugmesi = ^TDegerDugmesi;
  TDegerDugmesi = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _DegerDugmesiOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
procedure _DegerDugmesiGoster(AKimlik: TKimlik); assembler;

implementation

function TDegerDugmesi.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _DegerDugmesiOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TDegerDugmesi.Goster;
begin

  _DegerDugmesiGoster(FKimlik);
end;

function _DegerDugmesiOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DEGERDUGMESI_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _DegerDugmesiGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEGERDUGMESI_GOSTER
  int   $34
  add   esp,4
end;

end.
