{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_islemgostergesi.pas
  Dosya İşlevi: işlem göstergesi (progressbar) nesne işlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_islemgostergesi;

interface

type
  PIslemGostergesi = ^TIslemGostergesi;
  TIslemGostergesi = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
    procedure KonumBelirle(AKonum: TSayi4);
  end;

function _IslemGostergesiOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
procedure _IslemGostergesiDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4); assembler;
procedure _IslemGostergesiKonumBelirle(AKimlik: TKimlik; AKonum: TSayi4); assembler;

implementation

function TIslemGostergesi.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _IslemGostergesiOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TIslemGostergesi.DegerleriBelirle(AAltDeger, AUstDeger: TSayi4);
begin

  _IslemGostergesiDegerleriBelirle(FKimlik, AAltDeger, AUstDeger);
end;

procedure TIslemGostergesi.KonumBelirle(AKonum: TSayi4);
begin

  _IslemGostergesiKonumBelirle(FKimlik, AKonum);
end;

function _IslemGostergesiOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,ISLEMGOSTERGESI_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _IslemGostergesiDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4);
asm
  push  AUstDeger
  push  AAltDeger
  push  AKimlik
  mov   eax,ISLEMGOSTERGESI_ALTUSTDEGER
  int   $34
  add   esp,12
end;

procedure _IslemGostergesiKonumBelirle(AKimlik: TKimlik; AKonum: TSayi4);
asm
  push  AKonum
  push  AKimlik
  mov   eax,ISLEMGOSTERGESI_KONUMBELIRLE
  int   $34
  add   esp,8
end;

end.
