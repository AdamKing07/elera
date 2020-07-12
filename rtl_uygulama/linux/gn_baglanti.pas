{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_baglanti.pas
  Dosya İşlevi: bağlantı (link) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_baglanti;

interface

type
  PBaglanti = ^TBaglanti;
  TBaglanti = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
      AOdakRenk: TRenk; ABaslik: string): TKimlik;
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _BaglantiOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): TKimlik; assembler;
procedure _BaglantiGoster(AKimlik: TKimlik); assembler;

implementation

function TBaglanti.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): TKimlik;
begin

  FKimlik := _BaglantiOlustur(AAtaKimlik, A1, B1, ANormalRenk, AOdakRenk, ABaslik);
  Result := FKimlik;
end;

procedure TBaglanti.Goster;
begin

  _BaglantiGoster(FKimlik);
end;

function _BaglantiOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  AOdakRenk
  push  ANormalRenk
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,BAGLANTI_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _BaglantiGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,BAGLANTI_GOSTER
  int   $34
  add   esp,4
end;

end.
