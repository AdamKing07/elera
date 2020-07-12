{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.pp
  Dosya İşlevi: pencere nesne işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

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
    procedure Olustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
      APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk);
    procedure Goster;
    procedure Ciz;
    property Tuval: TTuval read FTuval;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _PencereOlustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik; assembler;
procedure _PencereGoster(AKimlik: TKimlik); assembler;
procedure _PencereCiz(AKimlik: TKimlik); assembler;

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

function _PencereOlustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;
asm
  push  AGovdeRenk
  push  ABaslik
  push  APencereTipi
  push  Yukseklik
  push  Genislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,PENCERE_OLUSTUR
  int   $34
  add   esp,32
end;

procedure _PencereGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,PENCERE_GOSTER
  int   $34
  add   esp,4
end;

procedure _PencereCiz(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,PENCERE_CIZ
  int   $34
  add   esp,4
end;

end.
