{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_defter.pas
  Dosya İşlevi: defter nesnesi (memo) yönetim işlevlerini içerir

  Güncelleme Tarihi: 03/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_defter;

interface

type
  PDefter = ^TDefter;
  TDefter = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADefterRenk, AYaziRenk: TRenk): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure Goster;
    procedure YaziEkle(ABellekAdresi: PChar);
    procedure Temizle;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TDefter.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
begin

  FKimlik := _DefterOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADefterRenk,
    AYaziRenk);
  Result := FKimlik;
end;

procedure TDefter.Hizala(AHiza: THiza);
begin

  _DefterHizala(FKimlik, AHiza);
end;

procedure TDefter.Goster;
begin

  _DefterGoster(FKimlik);
end;

procedure TDefter.YaziEkle(ABellekAdresi: PChar);
begin

  _DefterYaziEkle(FKimlik, ABellekAdresi);
end;

procedure TDefter.Temizle;
begin

  _DefterTemizle(FKimlik);
end;

end.
