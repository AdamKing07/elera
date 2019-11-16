{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_islemgostergesi.pas
  Dosya İşlevi: işlem göstergesi (progressbar) nesne işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_islemgostergesi;

interface

type
  PIslemGostergesi = ^TIslemGostergesi;
  TIslemGostergesi = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
    procedure KonumBelirle(AKonum: TSayi4);
  end;

implementation

function TIslemGostergesi.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _IslemGostergesiOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TIslemGostergesi.DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
begin

  _IslemGostergesiDegerleriBelirle(FKimlik, AAltDeger, AUstDeger);
end;

procedure TIslemGostergesi.KonumBelirle(AKonum: TSayi4);
begin

  _IslemGostergesiKonumBelirle(FKimlik, AKonum);
end;

end.
