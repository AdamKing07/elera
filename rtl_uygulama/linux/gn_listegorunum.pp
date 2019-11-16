{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listegorunum.pas
  Dosya İşlevi: liste görünüm nesne işlevlerini içerir

  Güncelleme Tarihi: 02/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_listegorunum;

interface

type
  PListeGorunum = ^TListeGorunum;

  { TListeGorunum }

  TListeGorunum = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(ADeger: string);
    function SeciliSiraAl: LongInt;
    function SeciliYaziAl: string;
    procedure Temizle;
    procedure BasliklariTemizle;
    procedure BaslikEkle(ABaslikDeger: string; ABaslikGenisligi: TSayi4);
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TListeGorunum.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _ListeGorunumOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TListeGorunum.Hizala(AHiza: THiza);
begin

  _ListeGorunumHizala(FKimlik, AHiza);
end;

procedure TListeGorunum.ElemanEkle(ADeger: string);
begin

  _ListeGorunumElemanEkle(FKimlik, ADeger);
end;

function TListeGorunum.SeciliSiraAl: LongInt;
begin

  Result := _ListeGorunumSeciliSiraAl(FKimlik);
end;

procedure TListeGorunum.Temizle;
begin

  _ListeGorunumTemizle(FKimlik);
end;

function TListeGorunum.SeciliYaziAl: string;
var
  s: string;
begin

  _ListeGorunumSeciliYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

procedure TListeGorunum.BasliklariTemizle;
begin

  _ListeGorunumBasliklariTemizle(FKimlik);
end;

procedure TListeGorunum.BaslikEkle(ABaslikDeger: string; ABaslikGenisligi: TSayi4);
begin

  _ListeGorunumBaslikEkle(FKimlik, ABaslikDeger, ABaslikGenisligi);
end;

end.
