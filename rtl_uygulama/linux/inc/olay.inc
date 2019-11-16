{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: olay.inc
  Dosya Ýþlevi: sistem olay çaðrý iþlevlerini içerir
  Ýþlev No: 0x03

 ==============================================================================}
function _OlayAl(var AOlayKayit: TOlayKayit): TISayi4; assembler;
asm
  push  AOlayKayit
  mov   eax,OLAY_AL
  int   $34
  add   esp,4
end;

function _OlayBekle(var AOlayKayit: TOlayKayit): TISayi4; assembler;
asm
  push  AOlayKayit
  mov   eax,OLAY_BEKLE
  int   $34
  add   esp,4
end;
