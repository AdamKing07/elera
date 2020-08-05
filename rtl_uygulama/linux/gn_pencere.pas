{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.pas
  Dosya İşlevi: pencere (TPencere) yönetim işlevlerini içerir

  Güncelleme Tarihi: 23/07/2020

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
    procedure Gizle;
    procedure Ciz;
    procedure DurumNormal(AKimlik: TKimlik);
    procedure DurumKucult(AKimlik: TKimlik);
    property Kimlik: TKimlik read FKimlik;
    property Tuval: TTuval read FTuval;
  end;

function _PencereOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik; assembler;
procedure _PencereGoster(AKimlik: TKimlik); assembler;
procedure _PencereGizle(AKimlik: TKimlik); assembler;
procedure _PencereCiz(AKimlik: TKimlik); assembler;
procedure _PencereDurumNormal(AKimlik: TKimlik); assembler;
procedure _PencereDurumKucult(AKimlik: TKimlik); assembler;

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

procedure TPencere.Gizle;
begin

  _PencereGizle(FKimlik);
end;

procedure TPencere.Ciz;
begin

  _PencereCiz(FKimlik);
end;

procedure TPencere.DurumNormal(AKimlik: TKimlik);
begin

  _PencereDurumNormal(AKimlik);
end;

procedure TPencere.DurumKucult(AKimlik: TKimlik);
begin

  _PencereDurumKucult(AKimlik);
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

procedure _PencereGizle(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,PENCERE_GIZLE
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

procedure _PencereDurumNormal(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,PENCERE_DRM_NORMAL
  int   $34
  add   esp,4
end;

procedure _PencereDurumKucult(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,PENCERE_DRM_KUCULT
  int   $34
  add   esp,4
end;

end.
