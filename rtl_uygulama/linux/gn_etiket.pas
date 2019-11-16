{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_etiket.pas
  Dosya İşlevi: etiket (label) nesne çağrı işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_etiket;

interface

type
  PEtiket = ^TEtiket;
  TEtiket = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
      ABaslik: string): TKimlik;
    procedure Goster;
    procedure Degistir(ABaslik: string);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TEtiket.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik;
begin

  FKimlik := _EtiketOlustur(AAtaKimlik, A1, B1, ARenk, ABaslik);
  Result := FKimlik;
end;

procedure TEtiket.Goster;
begin

  _EtiketGoster(FKimlik);
end;

procedure TEtiket.Degistir(ABaslik: string);
begin

  _EtiketDegistir(FKimlik, ABaslik);
end;

end.
