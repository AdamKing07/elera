{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: genel.pas
  Dosya İşlevi: sistem genelinde kullanılan sabit, değişken ve yapıları içerir

  Güncelleme Tarihi: 16/10/2019

 ==============================================================================}
{$mode objfpc}
unit genel;

interface

uses gercekbellek, src_vesa20, src_ps2, gorev, zamanlayici, paylasim, olay, gorselnesne,
  sistemmesaj, gn_masaustu, iletisim, n_yazilistesi, n_sayilistesi;

const
  USTSINIR_YAZILISTESI = 128;    // 4096 byte / 32 byte = 128 adet liste
  USTSINIR_SAYILISTESI = 128;    // 4096 byte / 32 byte = 128 adet liste

var
  GGercekBellek: TGercekBellek;
  GEkranKartSurucusu: TEkranKartSurucusu;
  GFareSurucusu: TFareSurucusu;
  GZamanlayici: TZamanlayici;
  GSistemMesaj: TSistemMesaj;
  GOlay: TOlay;
  GIslemciBilgisi: TIslemciBilgisi;
  GAktifMasaustu: PMasaustu;
  GBaglanti: PBaglanti;
  // 24 x 24 sistemler. yukleyici.pas dosyasından yükleme işlemi yapılır
  GSistemResimler: TGoruntuYapi;

  // fare ile sağ veya sol tuş ile basılan son görsel nesne
  // TGucDugme ve benzeri görsel nesnelerin normal duruma (basılı olmayan) gelmesi için
  GFareIleBasilanSonGN: PGorselNesne = nil;

  GorevListesi: array[1..USTSINIR_GOREVSAYISI] of PGorev;
  GorselNesneListesi: array[1..USTSINIR_GORSELNESNE] of PGorselNesne;
  AgIletisimListesi: array[1..USTSINIR_AGILETISIM] of PBaglanti;
  MasaustuListesi: array[1..USTSINIR_MASAUSTU] of PMasaustu = (nil, nil, nil, nil);

  // sistem içerisinde kullanılacak görsel olmayan listeler
  GYaziListesi: array[1..USTSINIR_YAZILISTESI] of PYaziListesi;
  GSayiListesi: array[1..USTSINIR_SAYILISTESI] of PSayiListesi;

procedure ListeleriIlkDegerlerleYukle;

implementation

{==============================================================================
  çalıştırılacak işlemlerin ana yükleme işlevlerini içerir
 ==============================================================================}
procedure ListeleriIlkDegerlerleYukle;
var
  _YaziListesi: PYaziListesi;
  _SayiListesi: PSayiListesi;
  i: TISayi4;
begin

  // 1. görsel olmayan yazı listesi için bellekte yer ayır
  _YaziListesi := GGercekBellek.Ayir(Align(SizeOf(TYaziListesi), 16) * USTSINIR_YAZILISTESI);

  // bellek girişlerini nesne yapı girişleriyle eşleştir
  for i := 1 to USTSINIR_YAZILISTESI do
  begin

    GYaziListesi[i] := _YaziListesi;

    // nesneyi kullanılabilir olarak işaretle
    _YaziListesi^.NesneKullanilabilir := True;
    _YaziListesi^.Tanimlayici := i;

    Inc(_YaziListesi);
  end;

  // 2. görsel olmayan sayı listesi için bellekte yer ayır
  _SayiListesi := GGercekBellek.Ayir(Align(SizeOf(TSayiListesi), 16) * USTSINIR_SAYILISTESI);

  // bellek girişlerini nesne yapı girişleriyle eşleştir
  for i := 1 to USTSINIR_SAYILISTESI do
  begin

    GSayiListesi[i] := _SayiListesi;

    // nesneyi kullanılabilir olarak işaretle
    _SayiListesi^.NesneKullanilabilir := True;
    _SayiListesi^.Tanimlayici := i;

    Inc(_SayiListesi);
  end;
end;

end.
