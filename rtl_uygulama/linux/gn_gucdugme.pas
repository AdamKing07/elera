{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_gucdugme.pas
  Dosya İşlevi: güç düğme nesne işlevlerini içerir
  İşlev No: 0x02

  Güncelleme Tarihi: 16/05/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_gucdugme;

interface

type
  PGucDugme = ^TGucDugme;
  TGucDugme = object
  private
    FKimlik: TKimlik;
    FEtiket: TSayi4;
    FBaslik: string;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): TKimlik;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure BaslikDegistir(ABaslik: string);
    procedure DurumYaz(ADurum: TSayi4);
  published
    property Kimlik: TKimlik read FKimlik;
    property Etiket: TSayi4 read FEtiket write FEtiket;
  end;

function _GucDugmeOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik; assembler;
procedure _GucDugmeYokEt(AKimlik: TKimlik); assembler;
procedure _GucDugmeGoster(AKimlik: TKimlik); assembler;
procedure _GucDugmeGizle(AKimlik: TKimlik); assembler;
procedure _GucDugmeBaslikDegistir(AKimlik: TKimlik; ABaslik: string); assembler;
procedure _GucDugmeDurumYaz(AKimlik: TKimlik; ADurum: TSayi4); assembler;

implementation

function TGucDugme.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
begin

  FBaslik := ABaslik;

  FKimlik := _GucDugmeOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);
  Result := FKimlik;
end;

procedure TGucDugme.YokEt;
begin

  _GucDugmeYokEt(FKimlik);
end;

procedure TGucDugme.Goster;
begin

  _GucDugmeGoster(FKimlik);
end;

procedure TGucDugme.Gizle;
begin

  _GucDugmeGizle(FKimlik);
end;

procedure TGucDugme.BaslikDegistir(ABaslik: string);
begin

  if(FBaslik = ABaslik) then Exit;

  FBaslik := ABaslik;

  _GucDugmeBaslikDegistir(FKimlik, FBaslik);
end;

procedure TGucDugme.DurumYaz(ADurum: TSayi4);
begin

  _GucDugmeDurumYaz(FKimlik, ADurum);
end;

function _GucDugmeOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,GUCDUGME_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _GucDugmeYokEt(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,GUCDUGME_YOKET
  int   $34
  add   esp,4
end;

procedure _GucDugmeGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,GUCDUGME_GOSTER
  int   $34
  add   esp,4
end;

procedure _GucDugmeGizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,GUCDUGME_GIZLE
  int   $34
  add   esp,4
end;

procedure _GucDugmeBaslikDegistir(AKimlik: TKimlik; ABaslik: string);
asm
  push  ABaslik
  push  AKimlik
  mov   eax,GUCDUGME_BASLIKDEGISTIR
  int   $34
  add   esp,8
end;

procedure _GucDugmeDurumYaz(AKimlik: TKimlik; ADurum: TSayi4);
asm
  push  ADurum
  push  AKimlik
  mov   eax,GUCDUGME_DURUMYAZ
  int   $34
  add   esp,8
end;

end.
