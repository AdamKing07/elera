{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_secimdugme.pas
  Dosya İşlevi: seçim düğmesi çağrı işlevlerini içerir

  Güncelleme Tarihi: 12/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_secimdugme;

interface

type
  PSecimDugme = ^TSecimDugme;
  TSecimDugme = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TISayi4;
    procedure DurumDegistir(ASecimDurumu: TSecimDurumu);
    procedure Goster;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TSecimDugme.Olustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TISayi4;
begin

  FKimlik := _SecimDugmeOlustur(AtaKimlik, A1, B1, ABaslik);
  Result := FKimlik;
end;

procedure TSecimDugme.DurumDegistir(ASecimDurumu: TSecimDurumu);
begin

  _SecimDugmeDurumDegistir(FKimlik, ASecimDurumu);
end;

procedure TSecimDugme.Goster;
begin

  _SecimDugmeGoster(FKimlik);
end;

end.
