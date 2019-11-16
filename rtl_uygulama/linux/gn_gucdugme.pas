{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_gucdugme.pas
  Dosya İşlevi: güç düğme nesne işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit gn_gucdugme;

interface

type
  PGucDugme = ^TGucDugme;
  TGucDugme = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): TKimlik;
    procedure Goster;
    procedure DurumYaz(ADurum: TSayi4);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TGucDugme.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
begin

  FKimlik := _GucDugmeOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);
  Result := FKimlik;
end;

procedure TGucDugme.Goster;
begin

  _GucDugmeGoster(FKimlik);
end;

procedure TGucDugme.DurumYaz(ADurum: TSayi4);
begin

  _GucDugmeDurumYaz(FKimlik, ADurum);
end;

end.
