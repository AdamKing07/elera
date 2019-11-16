{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_dugme.pas
  Dosya İşlevi: düğme nesne işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit gn_dugme;

interface

type
  PDugme = ^TDugme;
  TDugme = object
  private
    FKimlik: TKimlik;
    FEtiket: TSayi4;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
  published
    property Kimlik: TKimlik read FKimlik;
    property Etiket: TSayi4 read FEtiket write FEtiket;
  end;

implementation

function TDugme.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
begin

  FKimlik := _DugmeOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);
  Result := FKimlik;
end;

procedure TDugme.Goster;
begin

  _DugmeGoster(FKimlik);
end;

procedure TDugme.Hizala(AHiza: THiza);
begin

  _DugmeHizala(FKimlik, AHiza);
end;

end.
