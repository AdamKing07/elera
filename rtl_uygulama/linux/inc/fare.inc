{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: fare.inc
  Dosya İşlevi: fare (mouse) çağrı işlevlerini içerir
  İşlev No: 0x10

 ==============================================================================}
procedure _FarePozisyonunuAl(ANokta: PNokta); assembler;
asm
  push  ANokta
  mov   eax,FARE_KONUMAL
  int   $34
  add   esp,4
end;
