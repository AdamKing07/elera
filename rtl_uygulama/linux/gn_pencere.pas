{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.pp
  Dosya İşlevi: pencere nesne işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit gn_pencere;

interface

uses tuval;

type
  PPencere = ^TPencere;
  TPencere = object
  private
    FKimlik: TKimlik;
    FTuval: TTuval;
  public
    procedure Olustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
      APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk);
    procedure Goster;
    procedure Ciz;
    property Tuval: TTuval read FTuval;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

procedure TPencere.Olustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk);
begin

  FKimlik := _PencereOlustur(AtaKimlik, A1, B1, Genislik, Yukseklik, APencereTipi,
    ABaslik, AGovdeRenk);

  FTuval.Olustur(FKimlik);
end;

procedure TPencere.Goster;
begin

  _PencereGoster(FKimlik);
end;

procedure TPencere.Ciz;
begin

  _PencereCiz(FKimlik);
end;

end.
