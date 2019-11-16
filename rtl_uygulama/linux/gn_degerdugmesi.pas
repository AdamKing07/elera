{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_degerdugmesi.pas
  Dosya İşlevi: artırma / eksiltme (updown) düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
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

end.
