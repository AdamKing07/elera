{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_durumcubugu.pas
  Dosya İşlevi: durum çubuğu (statusbar) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
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

end.
