{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_acilirmenu.pas
  Dosya İşlevi: açılır menü nesne işlevlerini içerir

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_acilirmenu;

interface

type
  PAcilirMenu = ^TAcilirMenu;
  TAcilirMenu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
      ASeciliYaziRenk: TRenk): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
    function SeciliSiraNoAl: TISayi4;
    property Kimlik: TKimlik read FKimlik;
  end;

function _AcilirMenuOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik; assembler;
procedure _AcilirMenuGoster(AKimlik: TKimlik); assembler;
procedure _AcilirMenuGizle(AKimlik: TKimlik); assembler;
procedure _AcilirMenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4); assembler;
function _AcilirMenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4; assembler;

implementation

function TAcilirMenu.Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;
begin

  FKimlik := _AcilirMenuOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
    ASeciliYaziRenk);
  Result := FKimlik;
end;

procedure TAcilirMenu.Goster;
begin

  _AcilirMenuGoster(FKimlik);
end;

procedure TAcilirMenu.Gizle;
begin

  _AcilirMenuGizle(FKimlik);
end;

procedure TAcilirMenu.ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
begin

  _AcilirMenuElemanEkle(FKimlik, AElemanAdi, AResimSiraNo);
end;

function TAcilirMenu.SeciliSiraNoAl: TISayi4;
begin

  Result := _AcilirMenuSeciliSiraNoAl(FKimlik);
end;

function _AcilirMenuOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;
asm
  push  ASeciliYaziRenk
  push  ANormalYaziRenk
  push  ASecimRenk
  push  AGovdeRenk
  push  AKenarRenk
  mov   eax,ACILIRMENU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _AcilirMenuGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ACILIRMENU_GOSTER
  int   $34
  add   esp,4
end;

procedure _AcilirMenuGizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ACILIRMENU_GIZLE
  int   $34
  add   esp,4
end;

procedure _AcilirMenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4);
asm
  push  AResimSiraNo
  push  AElemanAdi
  push  AKimlik
  mov   eax,ACILIRMENU_ELEMANEKLE
  int   $34
  add   esp,12
end;

function _AcilirMenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,ACILIRMENU_SECILISIRANOAL
  int   $34
  add   esp,4
end;

end.