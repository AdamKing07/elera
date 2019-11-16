{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: zamanlayici.pas
  Dosya İşlevi: zamanlayıcı nesne işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
unit zamanlayici;

interface

type
  PZamanlayici = ^TZamanlayici;
  TZamanlayici = object
  private
  public
    FKimlik: TKimlik;
    function Olustur(AMilisaniye: TSayi4): TKimlik;
    procedure Baslat;
    procedure Durdur;
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

{$i zamanlayici.inc}

function TZamanlayici.Olustur(AMilisaniye: TSayi4): TKimlik;
begin

  FKimlik := _ZamanlayiciOlustur(AMilisaniye);
  Result := FKimlik;
end;

procedure TZamanlayici.Baslat;
begin

  _ZamanlayiciBaslat(FKimlik);
end;

procedure TZamanlayici.Durdur;
begin

  _ZamanlayiciDurdur(FKimlik);
end;

end.
