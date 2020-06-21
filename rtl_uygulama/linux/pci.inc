{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: pci.inc
  Dosya Ýþlevi: sistem PCI çaðrý iþlevlerini içerir
  Ýþlev No: 0x0D

 ==============================================================================}
function ToplamPCIAygitSayisiAl: TISayi4; assembler;
asm
  mov   eax,PCI_TOPLAMAYGITSAYISI
  int   $34
end;

procedure PCIAygitBilgisiAl(AAygitSiraNo: TSayi4; ABellek: Isaretci); assembler;
asm
  push  ABellek
  push  AAygitSiraNo
  mov   eax,PCI_AYGITBILGISIAL
  int   $34
  add   esp,8
end;

function PCIOku1(AYol, AAygit, AIslev, ASiraNo: TSayi4): TSayi1; assembler;
asm
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_OKU1
  int   $34
  add   esp,16
  and   eax,$FF
end;

function PCIOku2(AYol, AAygit, AIslev, ASiraNo: TSayi4): TSayi2; assembler;
asm
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_OKU2
  int   $34
  add   esp,16
  and   eax,$FFFF
end;

function PCIOku4(AYol, AAygit, AIslev, ASiraNo: TSayi4): TSayi4; assembler;
asm
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_OKU4
  int   $34
  add   esp,16
end;

var
  _Deger: TSayi4;

procedure PCIYaz1(AYol, AAygit, AIslev, ASiraNo: TSayi4; ADeger: TSayi1); assembler;
asm
  push  eax
  xor eax,eax
  mov al,ADeger
  mov   _Deger,eax
  pop eax
  push  _Deger
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_YAZ1
  int   $34
  add   esp,20
end;

procedure PCIYaz2(AYol, AAygit, AIslev, ASiraNo: TSayi4; ADeger: TSayi2); assembler;
asm
  push  eax
  xor eax,eax
  mov ax,ADeger
  mov   _Deger,eax
  pop eax
  push  _Deger
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_YAZ1
  int   $34
  add   esp,20
end;

procedure PCIYaz4(AYol, AAygit, AIslev, ASiraNo, ADeger: TSayi4); assembler;
asm
  push  ADeger
  push  ASiraNo
  push  AIslev
  push  AAygit
  push  AYol
  mov   eax,PCI_YAZ4
  int   $34
  add   esp,20
end;

