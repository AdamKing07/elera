{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listegorunum.pas
  Dosya İşlevi: liste görünüm (TListView) yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_listegorunum;

interface

type
  PListeGorunum = ^TListeGorunum;
  TListeGorunum = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(ADeger: string);
    function SeciliSiraAl: TISayi4;
    function SeciliYaziAl: string;
    procedure Temizle;
    procedure BasliklariTemizle;
    procedure BaslikEkle(ABaslikDeger: string; ABaslikGenisligi: TSayi4);
    property Kimlik: TKimlik read FKimlik;
  end;

function _ListeGorunumOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _ListeGorunumHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _ListeGorunumElemanEkle(AKimlik: TKimlik; ADeger: string); assembler;
function _ListeGorunumSeciliSiraAl(AKimlik: TKimlik): TISayi4; assembler;
procedure _ListeGorunumSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
procedure _ListeGorunumTemizle(AKimlik: TKimlik); assembler;
procedure _ListeGorunumBasliklariTemizle(AKimlik: TKimlik); assembler;
procedure _ListeGorunumBaslikEkle(AKimlik: TKimlik; ABaslikDeger: string;
  ABaslikGenisligi: TSayi4); assembler;

implementation

function TListeGorunum.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _ListeGorunumOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TListeGorunum.Hizala(AHiza: THiza);
begin

  _ListeGorunumHizala(FKimlik, AHiza);
end;

procedure TListeGorunum.ElemanEkle(ADeger: string);
begin

  _ListeGorunumElemanEkle(FKimlik, ADeger);
end;

function TListeGorunum.SeciliSiraAl: TISayi4;
begin

  Result := _ListeGorunumSeciliSiraAl(FKimlik);
end;

procedure TListeGorunum.Temizle;
begin

  _ListeGorunumTemizle(FKimlik);
end;

function TListeGorunum.SeciliYaziAl: string;
var
  s: string;
begin

  _ListeGorunumSeciliYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

procedure TListeGorunum.BasliklariTemizle;
begin

  _ListeGorunumBasliklariTemizle(FKimlik);
end;

procedure TListeGorunum.BaslikEkle(ABaslikDeger: string; ABaslikGenisligi: TSayi4);
begin

  _ListeGorunumBaslikEkle(FKimlik, ABaslikDeger, ABaslikGenisligi);
end;

function _ListeGorunumOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
asm
  push  DWORD AYukseklik
  push  DWORD AGenislik
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,LISTEGORUNUM_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _ListeGorunumHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  DWORD AHiza
  push  DWORD AKimlik
  mov   eax,PANEL_HIZALA
  int   $34
  add   esp,8
end;

procedure _ListeGorunumElemanEkle(AKimlik: TKimlik; ADeger: string);
asm
  push  DWORD ADeger
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_ELEMANEKLE
  int   $34
  add   esp,8
end;

function _ListeGorunumSeciliSiraAl(AKimlik: TKimlik): TISayi4;
asm
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_SECILISIRAAL
  int   $34
  add   esp,4
end;

procedure _ListeGorunumSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  DWORD AHedefBellek
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_SECILIYAZIAL
  int   $34
  add   esp,8
end;

procedure _ListeGorunumTemizle(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _ListeGorunumBasliklariTemizle(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_BTEMIZLE
  int   $34
  add   esp,4
end;

procedure _ListeGorunumBaslikEkle(AKimlik: TKimlik; ABaslikDeger: string;
  ABaslikGenisligi: TSayi4);
asm
  push  DWORD ABaslikGenisligi
  push  DWORD ABaslikDeger
  push  DWORD AKimlik
  mov   eax,LISTEGORUNUM_BASLIKEKLE
  int   $34
  add   esp,12
end;

end.
