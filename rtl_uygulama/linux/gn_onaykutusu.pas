{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_onaykutusu.pas
  Dosya İşlevi: onay kutusu nesne işlevlerini içerir

  Güncelleme Tarihi: 20/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_onaykutusu;

interface

type
  POnayKutusu = ^TOnayKutusu;
  TOnayKutusu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TOnayKutusu.Olustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik;
begin

  FKimlik := _OnayKutusuOlustur(AtaKimlik, A1, B1, ABaslik);
  Result := FKimlik;
end;

procedure TOnayKutusu.Goster;
begin

  _OnayKutusuGoster(FKimlik);
end;

end.
