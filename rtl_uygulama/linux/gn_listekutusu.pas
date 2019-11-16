{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listekutusu.pas
  Dosya İşlevi: liste kutusu nesne işlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_listekutusu;

interface

type
  PListeKutusu = ^TListeKutusu;
  TListeKutusu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function SeciliSiraNoAl: TISayi4;
    function SeciliSiraYaziAl: string;
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TListeKutusu.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _ListeKutusuOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TListeKutusu.Hizala(AHiza: THiza);
begin

  _ListeKutusuHizala(FKimlik, AHiza);
end;

procedure TListeKutusu.ElemanEkle(AElemanAdi: string);
begin

  _ListeKutusuElemanEkle(FKimlik, AElemanAdi);
end;

procedure TListeKutusu.Temizle;
begin

  _ListeKutusuTemizle(FKimlik);
end;

function TListeKutusu.SeciliSiraNoAl: TISayi4;
begin

  Result := _ListeKutusuSeciliSiraNoAl(FKimlik);
end;

function TListeKutusu.SeciliSiraYaziAl: string;
var
  s: string;
begin

  _ListeKutusuSeciliSiraYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

end.
