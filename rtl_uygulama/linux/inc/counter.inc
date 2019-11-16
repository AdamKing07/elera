{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: counter.inc
  Dosya Ýþlevi: sistem sayaç deðerleri çaðrý iþlevlerini içerir
  Ýþlev No: 0x06
 ==============================================================================}
procedure GetTime(Buffer: Pointer); assembler;
asm
  push  Buffer
  mov   eax,GET_TIME
  int   $34
  add esp,4
end;

procedure GetDate(Buffer: Pointer); assembler;
asm
  push  Buffer
  mov   eax,GET_DATE
  int   $34
  add esp,4
end;
