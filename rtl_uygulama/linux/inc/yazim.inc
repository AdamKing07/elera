{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: yazim.inc
  Dosya Ýþlevi: sistem yazým çaðrý iþlevlerini içerir
  Ýþlev No: 0x05

 ==============================================================================}
var
  _eax: TSayi4;

procedure _HarfYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AKarakter: Char); assembler;
asm
  mov   _eax,eax
  movzx eax,AKarakter
  push  eax
  push  ARenk
  push  B1
  push  A1
  push  _eax
  mov   eax,HARF_YAZ
  int   $34
  add   esp,20
end;

procedure _YaziYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: string); assembler;
asm
  push  ADeger
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,YAZI_YAZ
  int   $34
  add   esp,20
end;

procedure _SayiYaz10(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ADeger: TISayi4); assembler;
asm
  push  ADeger
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAYI_YAZ10
  int   $34
  add   esp,20
end;

procedure _SayiYaz16(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AOnekYaz: LongBool;
  AHaneSayisi: TSayi4; ADeger: TISayi4); assembler;
asm
  push  ADeger
  push  AHaneSayisi
  push  AOnekYaz
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAYI_YAZ16
  int   $34
  add   esp,28
end;

procedure _SaatYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; ASaat: TSaat); assembler;
asm
  push  ASaat
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,SAAT_YAZ
  int   $34
  add   esp,20
end;

procedure _MACAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AMACAdres: PMACAdres); assembler;
asm
  push  AMACAdres
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,MACADRES_YAZ
  int   $34
  add   esp,20
end;

procedure _IPAdresiYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk; AIPAdres: PIPAdres); assembler;
asm
  push  AIPAdres
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,IPADRES_YAZ
  int   $34
  add   esp,20
end;
