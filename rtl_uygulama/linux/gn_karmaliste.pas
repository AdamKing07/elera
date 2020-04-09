{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_karmaliste.pas
  Dosya İşlevi: açılır / kapanır liste kutusu nesne işlevlerini içerir

  Güncelleme Tarihi: 09/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_karmaliste;

interface

type
  PKarmaListe = ^TKarmaListe;
  TKarmaListe = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function SeciliYaziAl: string;
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TKarmaListe.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _KarmaListeOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TKarmaListe.Hizala(AHiza: THiza);
begin

  _KarmaListeHizala(FKimlik, AHiza);
end;

procedure TKarmaListe.ElemanEkle(AElemanAdi: string);
begin

  _KarmaListeElemanEkle(FKimlik, AElemanAdi);
end;

procedure TKarmaListe.Temizle;
begin

  _KarmaListeTemizle(FKimlik);
end;

function TKarmaListe.SeciliYaziAl: string;
var
  s: string;
begin

  _KarmaListeSeciliYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

end.
