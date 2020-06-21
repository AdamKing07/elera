{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_resimdugmesi.pas
  Dosya İşlevi: resim düğme nesne işlevlerini içerir

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_resimdugmesi;

interface

type
  PResimDugme = ^TResimDugme;
  TResimDugme = object
  private
    FKimlik: TKimlik;
    FEtiket: TSayi4;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
      ADeger: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
  published
    property Kimlik: TKimlik read FKimlik;
    property Etiket: TSayi4 read FEtiket write FEtiket;
  end;

function _ResimDugmeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  ADeger: TISayi4): TKimlik; assembler;
procedure _ResimDugmeGoster(AKimlik: TKimlik); assembler;
procedure _ResimDugmeHizala(AKimlik: TKimlik; AHiza: THiza); assembler;

implementation

function TResimDugme.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  ADeger: TISayi4): TKimlik;
begin

  FKimlik := _ResimDugmeOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, ADeger);
  Result := FKimlik;
end;

procedure TResimDugme.Goster;
begin

  _ResimDugmeGoster(FKimlik);
end;

procedure TResimDugme.Hizala(AHiza: THiza);
begin

  _ResimDugmeHizala(FKimlik, AHiza);
end;

function _ResimDugmeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  ADeger: TISayi4): TKimlik;
asm
  push  ADeger
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,RESIMDUGME_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _ResimDugmeGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,RESIMDUGME_GOSTER
  int   $34
  add   esp,4
end;

procedure _ResimDugmeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,RESIMDUGME_HIZALA
  int   $34
  add   esp,8
end;

end.
