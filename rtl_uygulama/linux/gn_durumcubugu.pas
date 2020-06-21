{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_durumcubugu.pas
  Dosya İşlevi: durum çubuğu (statusbar) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_durumcubugu;

interface

type
  PDurumCubugu = ^TDurumCubugu;
  TDurumCubugu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADurumYazisi: string): TKimlik;
    procedure DurumYazisiDegistir(ADurumYazisi: string);
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _DurumCubuguOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik; assembler;
procedure _DurumCubuguYazisiDegistir(AKimlik: TKimlik; ADurumYazisi: string); assembler;
procedure _DurumCubuguGoster(AKimlik: TKimlik); assembler;

implementation

function TDurumCubugu.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik;
begin

  FKimlik := _DurumCubuguOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADurumYazisi);
  Result := FKimlik;
end;

procedure TDurumCubugu.DurumYazisiDegistir(ADurumYazisi: string);
begin

  _DurumCubuguYazisiDegistir(FKimlik, ADurumYazisi);
end;

procedure TDurumCubugu.Goster;
begin

  _DurumCubuguGoster(FKimlik);
end;

function _DurumCubuguOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik;
asm
  push  ADurumYazisi
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DURUMCUBUGU_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _DurumCubuguYazisiDegistir(AKimlik: TKimlik; ADurumYazisi: string);
asm
  push  ADurumYazisi
  push  AKimlik
  mov   eax,DURUMCUBUGU_YAZIDEGISTIR
  int   $34
  add   esp,8
end;

procedure _DurumCubuguGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DURUMCUBUGU_GOSTER
  int   $34
  add   esp,4
end;

end.
