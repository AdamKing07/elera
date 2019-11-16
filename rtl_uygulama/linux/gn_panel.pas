{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_panel.pas
  Dosya İşlevi: panel nesne işlevlerini içerir

  Güncelleme Tarihi: 30/10/2019

 ==============================================================================}
{$mode objfpc}
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

end.
