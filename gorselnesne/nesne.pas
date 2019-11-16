{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: nesne.pas
  Dosya İşlevi: tüm görsel nesnelerin türetildiği en üst seviyedeki nesne

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit nesne;

interface

uses paylasim;

type
  TNesne = object
  public
    FGorselNesneTipi: TGorselNesneTipi;           // nesnenin tipi

    // nesne kimliği. kimlik değeri, nesnenin dizi içerisindeki sıra numarasıdır.
    FKimlik: TKimlik;
  published
    property GorselNesneTipi: TGorselNesneTipi read FGorselNesneTipi
      write FGorselNesneTipi;
    property Kimlik: TKimlik read FKimlik write FKimlik;
  end;

implementation

end.
