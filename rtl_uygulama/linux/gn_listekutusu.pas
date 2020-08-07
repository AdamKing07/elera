{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listekutusu.pas
  Dosya İşlevi: liste kutusu (TListBox) yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/08/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_listekutusu;

interface

type
  PListeKutusu = ^TListeKutusu;

  { TListeKutusu }

  TListeKutusu = object
  private
    FKimlik: TKimlik;
    FGorunum: Boolean;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function ToplamElemanSayisiAl: TISayi4;
    function SeciliSiraNoAl: TISayi4;
    function SeciliYaziAl(ASiraNo: TISayi4): string;
    procedure SeciliSiraNoYaz(ASiraNo: TISayi4);

    property Kimlik: TKimlik read FKimlik;
    property Gorunum: Boolean read FGorunum;
  end;

function _ListeKutusuOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _ListeKutusuGoster(AKimlik: TKimlik); assembler;
procedure _ListeKutusuGizle(AKimlik: TKimlik); assembler;
procedure _ListeKutusuHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _ListeKutusuElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _ListeKutusuTemizle(AKimlik: TKimlik); assembler;
function _ListeKutusuToplamElemanSayisiAl(AKimlik: TKimlik): TISayi4; assembler;
function _ListeKutusuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4; assembler;
procedure _ListeKutusuSeciliYaziAl(AKimlik: TKimlik; ASiraNo: TISayi4; AHedefBellek: Isaretci); assembler;
procedure _ListeKutusuSeciliSiraNoYaz(AKimlik: TKimlik; ASiraNo: TISayi4); assembler;

implementation

function TListeKutusu.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _ListeKutusuOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  FGorunum := True;
  Result := FKimlik;
end;

procedure TListeKutusu.Goster;
begin

  FGorunum := True;
  _ListeKutusuGoster(FKimlik);
end;

procedure TListeKutusu.Gizle;
begin

  FGorunum := False;
  _ListeKutusuGizle(FKimlik);
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

function TListeKutusu.ToplamElemanSayisiAl: TISayi4;
begin

  Result := _ListeKutusuToplamElemanSayisiAl(FKimlik);
end;

function TListeKutusu.SeciliSiraNoAl: TISayi4;
begin

  Result := _ListeKutusuSeciliSiraNoAl(FKimlik);
end;

function TListeKutusu.SeciliYaziAl(ASiraNo: TISayi4): string;
var
  s: string;
begin

  _ListeKutusuSeciliYaziAl(FKimlik, ASiraNo, Isaretci(@s[0]));
  Result := s;
end;

procedure TListeKutusu.SeciliSiraNoYaz(ASiraNo: TISayi4);
begin

  _ListeKutusuSeciliSiraNoYaz(FKimlik, ASiraNo);
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

procedure _ListeKutusuGizle(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_GIZLE
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

function _ListeKutusuToplamElemanSayisiAl(AKimlik: TKimlik): TISayi4; assembler;
asm
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_TELEMANSAYISIAL
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

procedure _ListeKutusuSeciliYaziAl(AKimlik: TKimlik; ASiraNo: TISayi4; AHedefBellek: Isaretci);
asm
  push  DWORD AHedefBellek
  push  DWORD ASiraNo
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_SECILIYAZIAL
  int   $34
  add   esp,12
end;

procedure _ListeKutusuSeciliSiraNoYaz(AKimlik: TKimlik; ASiraNo: TISayi4); assembler;
asm
  push  DWORD ASiraNo
  push  DWORD AKimlik
  mov   eax,LISTEKUTUSU_SECILISIRANOYAZ
  int   $34
  add   esp,8
end;

end.
