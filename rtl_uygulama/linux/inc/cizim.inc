{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: cizim.inc
  Dosya Ýþlevi: sistem çizim çaðrý iþlevlerini içerir
  Ýþlev No: 0x08

 ==============================================================================}
procedure _PixelYaz(AKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk); assembler;
asm
  push  ARenk
  push  B1
  push  A1
  push  AKimlik
  mov   eax,PIXEL_YAZ
  int   $34
  add   esp,4 * 4
end;

procedure _Cizgi(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk); assembler;
asm
  push  ARenk
  push  B2
  push  A2
  push  B1
  push  A1
  push  AKimlik
  mov   eax,CIZGI_CIZ
  int   $34
  add   esp,6 * 4
end;

procedure _Dikdortgen(AKimlik: TKimlik; A1, B1, A2, B2: TISayi4; ARenk: TRenk; ADoldur: LongBool); assembler;
asm
  push  ADoldur
  push  ARenk
  push  B2
  push  A2
  push  B1
  push  A1
  push  AKimlik
  mov   eax,DIKDORTGEN_CIZ
  int   $34
  add   esp,7 * 4
end;

procedure _Daire(AKimlik: TKimlik; A1, B1, AYariCap: TISayi4; ARenk: TRenk; ADoldur: LongBool); assembler;
asm
  push  ADoldur
  push  ARenk
  push  AYariCap
  push  B1
  push  A1
  push  AKimlik
  mov   eax,DAIRE_CIZ
  int   $34
  add   esp,6 * 4
end;
