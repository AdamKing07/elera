{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_degerlistesi.pas
  Dosya İşlevi: değer listesi (valuelisteditor) yönetim işlevlerini içerir

  Güncelleme Tarihi: 27/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_degerlistesi;

interface

type
  PDegerListesi = ^TDegerListesi;
  TDegerListesi = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
    procedure BaslikBelirle(ABaslik1, ABaslik2: string; ABaslik1U: TSayi4);
    procedure DegerEkle(ADeger: string);
    procedure Temizle;
    function SeciliYaziAl: string;
    property Kimlik: TKimlik read FKimlik;
  end;

function _DegerListesiOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
procedure _DegerListesiGoster(AKimlik: TKimlik); assembler;
procedure _DegerListesiHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _DegerListesiBaslikBelirle(AKimlik: TKimlik; ABaslik1, ABaslik2: string;
  ABaslik1U: TSayi4); assembler;
procedure _DegerListesiDegerEkle(AKimlik: TKimlik; ADeger: string); assembler;
procedure _DegerListesiTemizle(AKimlik: TKimlik); assembler;
procedure _DegerListesiSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;

implementation

function TDegerListesi.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _DegerListesiOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TDegerListesi.Goster;
begin

  _DegerListesiGoster(FKimlik);
end;

procedure TDegerListesi.Hizala(AHiza: THiza);
begin

  _DegerListesiHizala(FKimlik, AHiza);
end;

procedure TDegerListesi.BaslikBelirle(ABaslik1, ABaslik2: string;
  ABaslik1U: TSayi4);
begin

  _DegerListesiBaslikBelirle(FKimlik, ABaslik1, ABaslik2, ABaslik1U);
end;

procedure TDegerListesi.DegerEkle(ADeger: string);
begin

  _DegerListesiDegerEkle(FKimlik, ADeger);
end;

procedure TDegerListesi.Temizle;
begin

  _DegerListesiTemizle(FKimlik);
end;

function TDegerListesi.SeciliYaziAl: string;
var
  s: string;
begin

  _DegerListesiSeciliYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

function _DegerListesiOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  AUst
  push  ASol
  push  AAtaKimlik
  mov   eax,DEGERLISTESI_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _DegerListesiGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEGERLISTESI_GOSTER
  int   $34
  add   esp,4
end;

procedure _DegerListesiHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,DEGERLISTESI_HIZALA
  int   $34
  add   esp,8
end;

procedure _DegerListesiBaslikBelirle(AKimlik: TKimlik; ABaslik1, ABaslik2: string;
  ABaslik1U: TSayi4);
asm
  push  ABaslik1U
  push  ABaslik2
  push  ABaslik1
  push  AKimlik;
  mov   eax,DEGERLISTESI_BASLIKBELIRLE
  int   $34
  add   esp,16
end;

procedure _DegerListesiDegerEkle(AKimlik: TKimlik; ADeger: string);
asm
  push  ADeger
  push  AKimlik
  mov   eax,DEGERLISTESI_DEGEREKLE
  int   $34
  add   esp,8
end;

procedure _DegerListesiTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEGERLISTESI_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _DegerListesiSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,DEGERLISTESI_SECILIYAZIAL
  int   $34
  add   esp,8
end;

end.
