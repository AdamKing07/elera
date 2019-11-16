{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_panel.inc
  Dosya İşlevi: sistem pencere çağrı işlevlerini içerir
  İşlev No: 0x12

 ==============================================================================}
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
