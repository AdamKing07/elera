{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: n_tuval.pas
  Dosya İşlevi: pencere içeriğine yazım - çizim işlevlerini içerir

  Güncelleme Tarihi: 06/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit n_tuval;

interface

type
  TFirca = object
  public
    Renk: TRenk;
  end;

  TKalem = object
  public
    Renk: TRenk;
  end;

  TTuval = object
  private
    FKimlik: TKimlik;
    FFirca: TFirca;
    FKalem: TKalem;
    function KalemRengiAl: TRenk;
    procedure KalemRengiYaz(ARenk: TRenk);
    function FircaRengiAl: TRenk;
    procedure FircaRengiYaz(ARenk: TRenk);
  public
    procedure Olustur(APencereKimlik: TKimlik);
    procedure HarfYaz(A1, B1: TISayi4; AKarakter: Char);
    procedure YaziYaz(A1, B1: TISayi4; ADeger: string);
    procedure SayiYaz10(A1, B1: TISayi4; ADeger: TISayi4);
    procedure SayiYaz16(A1, B1: TISayi4; AOnekYaz: LongBool; AHaneSayisi: TSayi4;
      ADeger: TISayi4);
    procedure SaatYaz(A1, B1: TISayi4; ASaat: TSaat);
    procedure IPAdresiYaz(A1, B1: TISayi4; AIPAdres: PIPAdres);
    procedure MACAdresiYaz(A1, B1: TISayi4; AMACAdres: PMACAdres);
    procedure PixelYaz(A1, B1: TISayi4; ARenk: TRenk);
    procedure Cizgi(A1, B1, A2, B2: TISayi4; ARenk: TRenk);
    procedure Dikdortgen(A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: Boolean);
    procedure Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: Boolean);
    property FircaRengi: TColor read FircaRengiAl write FircaRengiYaz;
    property KalemRengi: TColor read KalemRengiAl write KalemRengiYaz;
  published
  end;

procedure _HarfYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AKarakter: Char); assembler;
procedure _YaziYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: string); assembler;
procedure _SayiYaz10(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: TISayi4); assembler;
procedure _SayiYaz16(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AOnekYaz: LongBool;
  AHaneSayisi: TSayi4; ADeger: TISayi4); assembler;
procedure _SaatYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ASaat: TSaat); assembler;
procedure _MACAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AMACAdres: PMACAdres); assembler;
procedure _IPAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AIPAdres: PIPAdres); assembler;
procedure _PixelYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk); assembler;
procedure _Cizgi(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk); assembler;
procedure _Dikdortgen(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: LongBool); assembler;
procedure _Daire(AKimlik: TKimlik; A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: LongBool); assembler;

implementation

procedure TTuval.Olustur(APencereKimlik: TKimlik);
begin

  FKimlik := APencereKimlik;
  FFirca.Renk := RENK_KIRMIZI;
  FKalem.Renk := RENK_SIYAH;
end;

function TTuval.KalemRengiAl: TRenk;
begin

  Result := FKalem.Renk;
end;

procedure TTuval.KalemRengiYaz(ARenk: TRenk);
begin

  FKalem.Renk := ARenk;
end;

function TTuval.FircaRengiAl: TRenk;
begin

  Result := FFirca.Renk;
end;

procedure TTuval.FircaRengiYaz(ARenk: TRenk);
begin

  FFirca.Renk := ARenk;
end;

procedure TTuval.HarfYaz(A1, B1: TISayi4; AKarakter: Char);
begin

  _HarfYaz(FKimlik, A1, B1, FKalem.Renk, AKarakter);
end;

procedure TTuval.YaziYaz(A1, B1: TISayi4; ADeger: string);
begin

  _YaziYaz(FKimlik, A1, B1, FKalem.Renk, ADeger);
end;

procedure TTuval.SayiYaz10(A1, B1: TISayi4; ADeger: TISayi4);
begin

  _SayiYaz10(FKimlik, A1, B1, FKalem.Renk, ADeger);
end;

procedure TTuval.SayiYaz16(A1, B1: TISayi4; AOnekYaz: LongBool; AHaneSayisi: TSayi4;
  ADeger: TISayi4);
begin

  _SayiYaz16(FKimlik, A1, B1, FKalem.Renk, AOnekYaz, AHaneSayisi, ADeger);
end;

procedure TTuval.SaatYaz(A1, B1: TISayi4; ASaat: TSaat);
begin

  _SaatYaz(FKimlik, A1, B1, FKalem.Renk, ASaat);
end;

procedure TTuval.IPAdresiYaz(A1, B1: TISayi4; AIPAdres: PIPAdres);
begin

  _IPAdresiYaz(FKimlik, A1, B1, FKalem.Renk, AIPAdres);
end;

procedure TTuval.MACAdresiYaz(A1, B1: TISayi4; AMACAdres: PMACAdres);
begin

  _MACAdresiYaz(FKimlik, A1, B1, FKalem.Renk, AMACAdres);
end;

procedure TTuval.PixelYaz(A1, B1: TISayi4; ARenk: TRenk);
begin

  _PixelYaz(FKimlik, A1, B1, ARenk);
end;

procedure TTuval.Cizgi(A1, B1, A2, B2: TISayi4; ARenk: TRenk);
begin

  _Cizgi(FKimlik, A1, B1, A2, B2, ARenk);
end;

procedure TTuval.Dikdortgen(A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: Boolean);
begin

  _Dikdortgen(FKimlik, A1, B1, A2, B2, ARenk, ADoldur);
end;

procedure TTuval.Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: Boolean);
begin

  _Daire(FKimlik, A1, B1, AYariCap, ARenk, ADoldur);
end;

var
  _eax: TSayi4;

procedure _HarfYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AKarakter: Char);
asm
  mov   _eax,eax
  movzx eax,AKarakter
  push  eax
  push  ARenk
  push  B1
  push  A1
  push  _eax
  mov   eax,HARF_YAZ
  int   $34
  add   esp,20
end;

procedure _YaziYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: string);
asm
  push  ADeger
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,YAZI_YAZ
  int   $34
  add   esp,20
end;

procedure _SayiYaz10(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: TISayi4);
asm
  push  ADeger
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAYI_YAZ10
  int   $34
  add   esp,20
end;

procedure _SayiYaz16(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AOnekYaz: LongBool;
  AHaneSayisi: TSayi4; ADeger: TISayi4);
asm
  push  ADeger
  push  AHaneSayisi
  push  AOnekYaz
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAYI_YAZ16
  int   $34
  add   esp,28
end;

procedure _SaatYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ASaat: TSaat);
asm
  push  ASaat
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAAT_YAZ
  int   $34
  add   esp,20
end;

procedure _MACAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AMACAdres: PMACAdres);
asm
  push  AMACAdres
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,MACADRES_YAZ
  int   $34
  add   esp,20
end;

procedure _IPAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AIPAdres: PIPAdres);
asm
  push  AIPAdres
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,IPADRES_YAZ
  int   $34
  add   esp,20
end;

procedure _PixelYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk);
asm
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,PIXEL_YAZ
  int   $34
  add   esp,4 * 4
end;

procedure _Cizgi(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk);
asm
  push  ARenk
  push  B2
  push  A2
  push  B1
  push  A1
  push  AKimlik
  mov   eax,CIZGI_CIZ
  int   $34
  add   esp,6 * 4
end;

procedure _Dikdortgen(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: LongBool);
asm
  push  ADoldur
  push  ARenk
  push  B2
  push  A2
  push  B1
  push  A1
  push  AKimlik
  mov   eax,DIKDORTGEN_CIZ
  int   $34
  add   esp,7 * 4
end;

procedure _Daire(AKimlik: TKimlik; A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: LongBool);
asm
  push  ADoldur
  push  ARenk
  push  AYariCap
  push  B1
  push  A1
  push  AKimlik
  mov   eax,DAIRE_CIZ
  int   $34
  add   esp,6 * 4
end;

end.
