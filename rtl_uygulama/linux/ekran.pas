{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: ekran.pas
  Dosya İşlevi: ekran nesne işlevlerini içerir

  Güncelleme Tarihi: 20/10/2019

 ==============================================================================}
{$mode objfpc}
unit ekran;

interface

type
  PEkran = ^TEkran;
  TEkran = object
  protected
    FGenislik,              // ekran yatay çözünürlük
    FYukseklik,             // ekran dikey çözünürlük
    FA0,                    // 0 başlangıca sahip yatay ekran başlangıç
    FB0,                    // 0 başlangıca sahip dikey ekran başlangıç
    FGenislik0,             // 0 başlangıca sahip yatay ekran uzunluk
    FYukseklik0: TISayi4;   // 0 başlangıca sahip dikey ekran uzunluk
  public
    procedure CozunurlukAl;
  published
    property Genislik: TISayi4 read FGenislik;
    property Yukseklik: TISayi4 read FYukseklik;
    property A0: TISayi4 read FA0;
    property B1: TISayi4 read FB0;
    property Genislik0: TISayi4 read FGenislik0;
    property Yukseklik0: TISayi4 read FYukseklik0;
  end;

implementation

procedure TEkran.CozunurlukAl;
var
  _Nokta: TNokta;
begin

  EkranCozunurlugunuAl(@_Nokta);
  FGenislik := _Nokta.A1;
  FYukseklik := _Nokta.B1;
  FA0 := 0;
  FB0 := 0;
  FGenislik0 := FGenislik - 1;
  FYukseklik0 := FYukseklik - 1;
end;

end.
