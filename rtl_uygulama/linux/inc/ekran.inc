{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: ekran.inc
  Dosya Ýþlevi: ekran nesne iþlevlerini içerir
  Ýþlev No: 0x01

 ==============================================================================}
procedure EkranCozunurlugunuAl(ANokta: PNokta); assembler;
asm
  push  ANokta
  mov   eax,EKRAN_COZUNURLUGUNUAL
  int   $34
  add   esp,4
end;
