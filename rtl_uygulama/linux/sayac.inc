{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: sayac.inc
  Dosya ��levi: sistem saya� de�erleri �a�r� i�levlerini i�erir
  ��lev No: 0x06

 ==============================================================================}
procedure SaatAl(ABellek: Isaretci);
asm
  push  ABellek
  mov   eax,SAYAC_SAAT_AL
  int   $34
  add   esp,4
end;

procedure TarihAl(ABellek: Isaretci);
asm
  push  ABellek
  mov   eax,SAYAC_TARIH_AL
  int   $34
  add   esp,4
end;

// 1 saniye = 100 milisaniye
procedure Bekle(AMiliSaniye: TSayi4);
asm
  push  AMiliSaniye
  mov   eax,SAYAC_BEKLE
  int   $34
  add   esp,4
end;