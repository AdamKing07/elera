{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_defter.pas
  Dosya İşlevi: defter nesnesi (memo) yönetim işlevlerini içerir

  Güncelleme Tarihi: 03/11/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_defter;

interface

type
  PDefter = ^TDefter;
  TDefter = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADefterRenk, AYaziRenk: TRenk): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure Goster;
    procedure YaziEkle(ABellekAdresi: PChar);
    procedure YaziEkle(ADeger: string);
    procedure Temizle;
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _DefterOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik; assembler;
procedure _DefterHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _DefterGoster(AKimlik: TKimlik); assembler;
procedure _DefterYaziEklePChar(AKimlik: TKimlik; ABellekAdresi: PChar); assembler;
procedure _DefterYaziEkleStr(AKimlik: TKimlik; ADeger: string); assembler;
procedure _DefterTemizle(AKimlik: TKimlik); assembler;

implementation

function TDefter.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
begin

  FKimlik := _DefterOlustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADefterRenk,
    AYaziRenk);
  Result := FKimlik;
end;

procedure TDefter.Hizala(AHiza: THiza);
begin

  _DefterHizala(FKimlik, AHiza);
end;

procedure TDefter.Goster;
begin

  _DefterGoster(FKimlik);
end;

procedure TDefter.YaziEkle(ABellekAdresi: PChar);
begin

  _DefterYaziEklePChar(FKimlik, ABellekAdresi);
end;

procedure TDefter.YaziEkle(ADeger: string);
begin

  _DefterYaziEkleStr(FKimlik, ADeger);
end;

procedure TDefter.Temizle;
begin

  _DefterTemizle(FKimlik);
end;

function _DefterOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
asm
  push  AYaziRenk
  push  ADefterRenk
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DEFTER_OLUSTUR
  int   $34
  add   esp,28
end;

procedure _DefterHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,DEFTER_HIZALA
  int   $34
  add   esp,8
end;

procedure _DefterGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEFTER_GOSTER
  int   $34
  add   esp,4
end;

procedure _DefterYaziEklePChar(AKimlik: TKimlik; ABellekAdresi: PChar);
asm
  push  ABellekAdresi
  push  AKimlik
  mov   eax,DEFTER_YAZIEKLEP
  int   $34
  add   esp,8
end;

procedure _DefterYaziEkleStr(AKimlik: TKimlik; ADeger: string);
asm
  push  ADeger
  push  AKimlik
  mov   eax,DEFTER_YAZIEKLES
  int   $34
  add   esp,8
end;

procedure _DefterTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEFTER_TEMIZLE
  int   $34
  add   esp,4
end;

end.
