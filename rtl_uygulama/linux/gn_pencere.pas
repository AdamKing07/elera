{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.pas
  Dosya İşlevi: pencere nesne işlevlerini içerir

  Güncelleme Tarihi: 09/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_pencere;

interface

uses n_tuval;

type
  PPencere = ^TPencere;
  TPencere = object
  private
    FKimlik: TKimlik;
    FTuval: TTuval;
  public
    procedure Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
      APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk);
    procedure Goster;
    procedure Ciz;
    property Tuval: TTuval read FTuval;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _PencereOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik; assembler;
procedure _PencereGoster(AKimlik: TKimlik); assembler;
procedure _PencereCiz(AKimlik: TKimlik); assembler;

implementation

procedure TPencere.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk);
begin

  FKimlik := _PencereOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik,
    APencereTipi, ABaslik, AGovdeRenk);

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

function _PencereOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;
asm
  push  DWORD AGovdeRenk
  push  DWORD ABaslik
  push  DWORD APencereTipi
  push  DWORD AYukseklik
  push  DWORD AGenislik
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,PENCERE_OLUSTUR
  int   $34
  add   esp,32
end;

procedure _PencereGoster(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,PENCERE_GOSTER
  int   $34
  add   esp,4
end;

procedure _PencereCiz(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,PENCERE_CIZ
  int   $34
  add   esp,4
end;

end.
