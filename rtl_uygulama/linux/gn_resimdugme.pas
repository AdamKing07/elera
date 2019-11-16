{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_resimdugme.pas
  Dosya İşlevi: resim düğme nesne işlevlerini içerir

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_resimdugme;

interface

type
  PResimDugme = ^TResimDugme;
  TResimDugme = object
  private
    FKimlik: TKimlik;
    FEtiket: TSayi4;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
      ADeger: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
  published
    property Kimlik: TKimlik read FKimlik;
    property Etiket: TSayi4 read FEtiket write FEtiket;
  end;

implementation

function TResimDugme.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  ADeger: TISayi4): TKimlik;
begin

  FKimlik := _ResimDugmeOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, ADeger);
  Result := FKimlik;
end;

procedure TResimDugme.Goster;
begin

  _ResimDugmeGoster(FKimlik);
end;

procedure TResimDugme.Hizala(AHiza: THiza);
begin

  _ResimDugmeHizala(FKimlik, AHiza);
end;

end.
