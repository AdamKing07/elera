{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_baglanti.pas
  Dosya İşlevi: bağlantı (link) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit gn_baglanti;

interface

type
  PBaglanti = ^TBaglanti;
  TBaglanti = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
      AOdakRenk: TRenk; ABaslik: string): TKimlik;
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TBaglanti.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): TKimlik;
begin

  FKimlik := _BaglantiOlustur(AAtaKimlik, A1, B1, ANormalRenk, AOdakRenk, ABaslik);
  Result := FKimlik;
end;

procedure TBaglanti.Goster;
begin

  _BaglantiGoster(FKimlik);
end;

end.
