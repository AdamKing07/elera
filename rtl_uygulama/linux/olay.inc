{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: olay.inc
  Dosya ��levi: sistem olay �a�r� i�levlerini i�erir
  ��lev No: 0x03

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