{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_menu.pas
  Dosya İşlevi: menü nesne işlevlerini içerir

  Güncelleme Tarihi: 28/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_menu;

interface

type
  PMenu = ^TMenu;
  TMenu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
    function SeciliSiraNoAl: TISayi4;
    property Kimlik: TKimlik read FKimlik;
  end;

function _MenuOlustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik; assembler;
procedure _MenuGoster(AKimlik: TKimlik); assembler;
procedure _MenuGizle(AKimlik: TKimlik); assembler;
procedure _MenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4); assembler;
function _MenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4; assembler;

implementation

function TMenu.Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _MenuOlustur(A1, B1, AYukseklik, AYukseklik, AElemanYukseklik);
  Result := FKimlik;
end;

procedure TMenu.Goster;
begin

  _MenuGoster(FKimlik);
end;

procedure TMenu.Gizle;
begin

  _MenuGizle(FKimlik);
end;

procedure TMenu.ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
begin

  _MenuElemanEkle(FKimlik, AElemanAdi, AResimSiraNo);
end;

function TMenu.SeciliSiraNoAl: TISayi4;
begin

  Result := _MenuSeciliSiraNoAl(FKimlik);
end;

function _MenuOlustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
asm
  push  AElemanYukseklik
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  mov   eax,MENU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _MenuGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,MENU_GOSTER
  int   $34
  add   esp,4
end;

procedure _MenuGizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,MENU_GIZLE
  int   $34
  add   esp,4
end;

procedure _MenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4);
asm
  push  AResimSiraNo
  push  AElemanAdi
  push  AKimlik
  mov   eax,MENU_ELEMANEKLE
  int   $34
  add   esp,12
end;

function _MenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,MENU_SECILISIRANOAL
  int   $34
  add   esp,4
end;

end.
