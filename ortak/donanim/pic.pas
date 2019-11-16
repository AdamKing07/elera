{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: pic.pas
  Dosya İşlevi: pic yönetim işlevlerini içerir

  Güncelleme Tarihi: 22/09/2019

 ==============================================================================}
{$mode objfpc}{$H+}
{$asmmode intel}
unit pic;

interface

procedure Yukle;
procedure IRQKesmeleriniBaslat;
procedure IRQKesmeleriniDurdur;

implementation

uses port, paylasim;

{==============================================================================
  donanım kesme (irq) giriş noktalarını ön değerlerle yükler
 ==============================================================================}
procedure Yukle;
begin

  // ICW1 - her iki pic kontrolcüsüne init kodu gönder
  PortYaz1(PIC1_KOMUT, $11);
  PortYaz1(PIC2_KOMUT, $11);

  // ICW2 - pic1 : irq0-irq7 -> int 0x20-0x27, pic2 : irq8-irq15 -> int 0x28-0x30
  PortYaz1(PIC1_VERI, $20);
  PortYaz1(PIC2_VERI, $28);

  // ICW3 - irq2 (bit 2=1) slave, slave id is 2. bit 1=1
  PortYaz1(PIC1_VERI, 4);
  PortYaz1(PIC2_VERI, 2);

  // ICW4 - her iki pic kontrolcüsü 8086/8088 modunda
  PortYaz1(PIC1_VERI, 1);
  PortYaz1(PIC2_VERI, 1);
end;

{==============================================================================
  tüm donanım kesmelerini (irq) pasifleştirir
 ==============================================================================}
procedure IRQKesmeleriniDurdur; nostackframe; assembler;
asm

  cli
  mov al,$FF
  out PIC1_VERI,al
  out PIC2_VERI,al
end;

{==============================================================================
  tüm donanım kesmelerini (irq) aktifleştirir
 ==============================================================================}
procedure IRQKesmeleriniBaslat; nostackframe; assembler;
asm

  mov al,0
  out PIC1_VERI,al
  out PIC2_VERI,al
  sti
end;

end.
