{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_kaydirmacubugu.pas
  Dosya İşlevi: kaydırma çubuğu nesne işlevlerini içerir

  Güncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_kaydirmacubugu;

interface

type
  PKaydirmaCubugu = ^TKaydirmaCubugu;
  TKaydirmaCubugu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      AYon: TYon): TKimlik;
    procedure DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
    procedure Goster;
    procedure Hizala(AHiza: THiza);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _KaydirmaCubuguOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): TKimlik; assembler;
procedure _KaydirmaCubuguDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4); assembler;
procedure _KaydirmaCubuguGoster(AKimlik: TKimlik); assembler;
procedure _KaydirmaCubuguHizala(AKimlik: TKimlik; AHiza: THiza); assembler;

implementation

function TKaydirmaCubugu.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): TKimlik;
begin

  FKimlik := _KaydirmaCubuguOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, AYon);
  Result := FKimlik;
end;

procedure TKaydirmaCubugu.DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
begin

  _KaydirmaCubuguDegerleriBelirle(FKimlik, AAltDeger, AUstDeger);
end;

procedure TKaydirmaCubugu.Goster;
begin

  _KaydirmaCubuguGoster(FKimlik);
end;

procedure TKaydirmaCubugu.Hizala(AHiza: THiza);
begin

  _KaydirmaCubuguHizala(FKimlik, AHiza);
end;

function _KaydirmaCubuguOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): TKimlik;
asm
  push  AYon
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,KAYDIRMACUBUGU_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _KaydirmaCubuguDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4);
asm
  push  AUstDeger
  push  AAltDeger
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_ALTUSTDEGER
  int   $34
  add   esp,12
end;

procedure _KaydirmaCubuguGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_GOSTER
  int   $34
  add   esp,4
end;

procedure _KaydirmaCubuguHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_HIZALA
  int   $34
  add   esp,8
end;

end.
