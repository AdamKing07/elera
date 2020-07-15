{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: n_gorev.pas
  Dosya İşlevi: görev (program) nesnesini yönetir

  Güncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit n_gorev;

interface

type
  PGorev = ^TGorev;
  TGorev = object
  public
    function Calistir(ADosyaTamYol: string): TKimlik;
    function Sonlandir(AGorevNo: TISayi4): TISayi4;
    procedure GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4);
    function GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
    function GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
    function GorevKimligiAl(AGorevAdi: string): TKimlik;
    function OlayAl(var AOlayKayit: TOlayKayit): TISayi4;
    function OlayBekle(var AOlayKayit: TOlayKayit): TISayi4;
    procedure SistemBilgisiAl(ABellekAdresi: Isaretci);
    procedure IslemciBilgisiAl(ABellekAdresi: Isaretci);
    function FarePozisyonunuAl: TNokta;
    function GorselNesneKimlikAl(ANokta: TNokta): TKimlik;
    procedure GorselNesneAdiAl(ANokta: TNokta; ANesneAdi: Isaretci);
    function GorselNesneBilgisiAl(AKimlik: TKimlik; AHedefBellek: Isaretci): TISayi4;
    function CalisanProgramSayisiniAl: TSayi4; assembler;
    procedure CalisanProgramBilgisiAl(ASiraNo: TSayi4; var AProgramKayit: TProgramKayit); assembler;
    function AktifProgramiAl: TSayi4; assembler;
  end;

function _GorevCalistir(ADosyaTamYol: string): TKimlik; assembler;
function _GorevSonlandir(AGorevNo: TISayi4): TISayi4; assembler;
procedure _GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4); assembler;
function _GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4; assembler;
function _GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4; assembler;
function _GorevKimligiAl(AGorevAdi: string): TKimlik; assembler;

implementation

function TGorev.Calistir(ADosyaTamYol: string): TKimlik;
begin

  Result := _GorevCalistir(ADosyaTamYol);
end;

function TGorev.Sonlandir(AGorevNo: TISayi4): TISayi4;
begin

  Result := _GorevSonlandir(AGorevNo);
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

function TGorev.GorevKimligiAl(AGorevAdi: string): TKimlik;
begin

  Result := _GorevKimligiAl(AGorevAdi);
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

function TGorev.CalisanProgramSayisiniAl: TSayi4;
asm
  mov	  eax,GOREV_CALISANPSAYISINIAL
  int	  $34
end;

procedure TGorev.CalisanProgramBilgisiAl(ASiraNo: TSayi4; var AProgramKayit: TProgramKayit);
asm
  push  DWORD AProgramKayit
  push  DWORD ASiraNo
  mov	  eax,GOREV_CALISANPBILGISIAL
  int	  $34
  add   esp,8
end;

function TGorev.AktifProgramiAl: TSayi4;
asm
  mov	  eax,GOREV_AKTIFPROGRAMIAL
  int	  $34
end;

function _GorevCalistir(ADosyaTamYol: string): TKimlik;
asm
  push	DWORD ADosyaTamYol
  mov	  eax,GOREV_CALISTIR
  int	  $34
  add	  esp,4
end;

function _GorevSonlandir(AGorevNo: TISayi4): TISayi4;
asm
  push  DWORD AGorevNo
  mov	  eax,GOREV_SONLANDIR
  int	  $34
  add   esp,4
end;

procedure _GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4);
asm
  push  DWORD ACalisanGorevSayisi
  push  DWORD AUstSinirGorevSayisi
  mov	  eax,GOREV_SAYISINIAL
  int	  $34
  add	  esp,8
end;

function _GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
asm
  push	DWORD ABellekAdresi
  push	DWORD AKimlik
  mov	  eax,GOREV_BILGISIAL
  int	  $34
  add	  esp,8
end;

function _GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4;
asm
  push	DWORD ABellekAdresi
  push	DWORD AKimlik
  mov	  eax,GOREV_YAZMACBILGISIAL
  int	  $34
  add	  esp,8
end;

function _GorevKimligiAl(AGorevAdi: string): TKimlik;
asm
  push	DWORD AGorevAdi
  mov	  eax,GOREV_KIMLIGIAL
  int	  $34
  add	  esp,4
end;

end.
