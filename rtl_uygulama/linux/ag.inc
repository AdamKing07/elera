{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: ag.inc
  Dosya İşlevi: sistem ağ çağrı işlevlerini içerir
  İşlev No: 0x0E

 ==============================================================================}
{$asmmode intel}
procedure AgBilgisiAl(AAgBilgisi: PAgBilgisi); assembler;
asm
  push  AAgBilgisi
  mov   eax,AG_BILGISIAL
  int   $34
  add   esp,4
end;

