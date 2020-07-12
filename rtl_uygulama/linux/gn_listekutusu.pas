{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listekutusu.pas
  Dosya İşlevi: liste kutusu (TListBox) yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_listekutusu;

interface

type
  PListeKutusu = ^TListeKutusu;
  TListeKutusu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function SeciliSiraNoAl: TISayi4;
    function SeciliSiraYaziAl: string;
    property Kimlik: TKimlik read FKimlik;
  end;

function _ListeKutusuOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _ListeKutusuGoster(AKimlik: TKimlik); assembler;
procedure _ListeKutusuHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _ListeKutusuElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _ListeKutusuTemizle(AKimlik: TKimlik); assembler;
function _ListeKutusuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4; assembler;
procedure _ListeKutusuSeciliSiraYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;

implementation

function TListeKutusu.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _ListeKutusuOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TListeKutusu.Goster;
begin

  _ListeKutusuGoster(FKimlik);
end;

procedure TListeKutusu.Hizala(AHiza: THiza);
begin

  _ListeKutusuHizala(FKimlik, AHiza);
end;

procedure TListeKutusu.ElemanEkle(AElemanAdi: string);
begin

  _ListeKutusuElemanEkle(FKimlik, AElemanAdi);
end;

procedure TListeKutusu.Temizle;
begin

  _ListeKutusuTemizle(FKimlik);
end;

function TListeKutusu.SeciliSiraNoAl: TISayi4;
begin

  Result := _ListeKutusuSeciliSiraNoAl(FKimlik);
end;

function TListeKutusu.SeciliSiraYaziAl: string;
var
  s: string;
begin

  _ListeKutusuSeciliSiraYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

function _ListeKutusuOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
asm
  push  DWORD AYukseklik
  push  DWORD AGenislik
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,LISTEKUTUSU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _ListeKutusuGoster(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_GOSTER
  int   $34
  add   esp,4
end;

procedure _ListeKutusuHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  DWORD AHiza
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_HIZALA
  int   $34
  add   esp,8
end;

procedure _ListeKutusuElemanEkle(AKimlik: TKimlik; AElemanAdi: string);
asm
  push  DWORD AElemanAdi
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _ListeKutusuTemizle(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_TEMIZLE
  int   $34
  add   esp,4
end;

function _ListeKutusuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_SECILISIRANOAL
  int   $34
  add   esp,4
end;

procedure _ListeKutusuSeciliSiraYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  DWORD AHedefBellek
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_SECILISIRAYAZIAL
  int   $34
  add   esp,8
end;

end.
