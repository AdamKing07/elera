{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_kaydirmacubugu.pas
  Dosya İşlevi: kaydırma çubuğu nesne işlevlerini içerir

  Güncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}
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

end.
