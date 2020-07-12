{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_panel.pas
  Dosya İşlevi: panel nesne işlevlerini içerir

  Güncelleme Tarihi: 30/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_panel;

interface

type
  PPanel = ^TPanel;
  TPanel = object
  private
    FKimlik: TKimlik;
  public
    procedure Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
      ABaslik: string);
    procedure Goster;
    procedure Hizala(AHiza: THiza);
  published
    property Kimlik: TKimlik read FKimlik;
  end;

function _PanelOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): TKimlik; assembler;
procedure _PanelGoster(AKimlik: TKimlik); assembler;
procedure _PanelHizala(AKimlik: TKimlik; AHiza: THiza); assembler;

implementation

procedure TPanel.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string);
begin

  FKimlik := _PanelOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, AGovdeRenkSecim,
    AGovdeRenk1, AGovdeRenk2, AYaziRenk, ABaslik);
end;

procedure TPanel.Goster;
begin

  _PanelGoster(FKimlik);
end;

procedure TPanel.Hizala(AHiza: THiza);
begin

  _PanelHizala(FKimlik, AHiza);
end;

function _PanelOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  AYaziRenk
  push  AGovdeRenk2
  push  AGovdeRenk1
  push  AGovdeRenkSecim
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,PANEL_OLUSTUR
  int   $34
  add   esp,40
end;

procedure _PanelGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,PANEL_GOSTER
  int   $34
  add   esp,4
end;

procedure _PanelHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,PANEL_HIZALA
  int   $34
  add   esp,8
end;

end.
