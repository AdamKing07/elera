{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gorev.pas
  Dosya İşlevi: görev (program) nesnesini yönetir

  Güncelleme Tarihi: 22/10/2019

 ==============================================================================}
{$mode objfpc}
unit gorev;

interface

type
  PGorev = ^TGorev;
  TGorev = object
  public
    function Calistir(ADosyaTamYol: string): TKimlik;
    function Sonlandir: TISayi4;
    procedure GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4);
    function GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
    function GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
    function OlayAl(var AOlayKayit: TOlayKayit): TISayi4;
    function OlayBekle(var AOlayKayit: TOlayKayit): TISayi4;
    procedure SistemBilgisiAl(ABellekAdresi: Isaretci);
    procedure IslemciBilgisiAl(ABellekAdresi: Isaretci);
    function FarePozisyonunuAl: TNokta;
    function GorselNesneKimlikAl(ANokta: TNokta): TKimlik;
    procedure GorselNesneAdiAl(ANokta: TNokta; ANesneAdi: Isaretci);
    function GorselNesneBilgisiAl(AKimlik: TKimlik; AHedefBellek: Isaretci): TISayi4;
  end;

implementation

function TGorev.Calistir(ADosyaTamYol: string): TKimlik;
begin

  Result := _GorevCalistir(ADosyaTamYol);
end;

function TGorev.Sonlandir: TISayi4;
begin

  Result := _GorevSonlandir;
end;

procedure TGorev.GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4);
begin

  _GorevSayilariniAl(AUstSinirGorevSayisi, ACalisanGorevSayisi);
end;

function TGorev.GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
begin

  Result := _GorevBilgisiAl(AKimlik, ABellekAdresi);
end;

function TGorev.GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
begin

  Result := _GorevYazmacBilgisiAl(AKimlik, ABellekAdresi);
end;

function TGorev.OlayAl(var AOlayKayit: TOlayKayit): TISayi4;
begin

  Result := _OlayAl(AOlayKayit);
end;

function TGorev.OlayBekle(var AOlayKayit: TOlayKayit): TISayi4;
begin

  Result := _OlayBekle(AOlayKayit);
end;

procedure TGorev.SistemBilgisiAl(ABellekAdresi: Isaretci);
begin

  _SistemBilgisiAl(ABellekAdresi);
end;

procedure TGorev.IslemciBilgisiAl(ABellekAdresi: Isaretci);
begin

  _IslemciBilgisiAl(ABellekAdresi);
end;

function TGorev.FarePozisyonunuAl: TNokta;
var
  _Nokta: TNokta;
begin

  _FarePozisyonunuAl(@_Nokta);
  Result.A1 := _Nokta.A1;
  Result.B1 := _Nokta.B1;
end;

function TGorev.GorselNesneKimlikAl(ANokta: TNokta): TKimlik;
begin

  Result := _GorselNesneKimlikAl(ANokta.A1, ANokta.B1);
end;

procedure TGorev.GorselNesneAdiAl(ANokta: TNokta; ANesneAdi: Isaretci);
begin

  _GorselNesneAdiAl(ANokta.A1, ANokta.B1, ANesneAdi);
end;

function TGorev.GorselNesneBilgisiAl(AKimlik: TKimlik; AHedefBellek: Isaretci): TISayi4;
begin

  // bu işlevin alt yapı çalışması yapılacak
end;

end.
