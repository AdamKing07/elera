{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dosya.inc
  Program Ýþlevi: sistem dosya çaðrý iþlevlerini içerir
  Ýþlev No: 0x04

  Bilgi: _ ile baþlayan bu isimler ileride derleyicinin ilgili iþlevleriyle
    birleþtirilecektir

 ==============================================================================}
function _FindFirst(const AAramaSuzgec: string; ADosyaOzellik: TSayi2;
  var ADosyaArama: TDosyaArama): TISayi4; assembler;
asm
  push	dword ADosyaArama
  push	dword ADosyaOzellik
  push	dword AAramaSuzgec
  mov   eax,DOSYA_ARAMAYABASLA
  int	  $34
  add	  esp,12
end;

function _FindNext(var ADosyaArama: TDosyaArama): TISayi4; assembler;
asm
  push  ADosyaArama
  mov	  eax,DOSYA_SONRAKINIARA
  int	  $34
  add	  esp,4
end;

function _FindClose(var ADosyaArama: TDosyaArama): TISayi4; assembler;
asm
  push	ADosyaArama
  mov	  eax,DOSYA_ARAMASONLANDIR
  int	  $34
  add	  esp,4
end;

procedure _AssignFile(out ADosyaKimlik: TKimlik; const ADosyaAdi: string); assembler;
asm
  push  ADosyaAdi
  push	ADosyaKimlik
  mov	  eax,DOSYA_TANIMLA
  int	  $34
  add	  esp,8
end;

procedure _Reset(ADosyaKimlik: TKimlik); assembler;
asm
  push	ADosyaKimlik
  mov	  eax,DOSYA_AC
  int	  $34
  add	  esp,4
end;

function _IOResult: TISayi4; assembler;
asm
  mov	  eax,DOSYA_ISLEMKONTROL
  int	  $34
end;

function _EOF(ADosyaKimlik: TKimlik): Boolean; assembler;
asm
  push	ADosyaKimlik
  mov	  eax,DOSYA_DOSYASONU
  int	  $34
  add	  esp,4
end;

function _FileSize(ADosyaKimlik: TKimlik): TISayi4; assembler;
asm
  push	ADosyaKimlik
  mov	  eax,DOSYA_DOSYAUZUNLUGU
  int	  $34
  add	  esp,4
end;

// Read olarak deðiþtirilecek. Aþaðýdaki hatayý veriyor
// fileh.inc(7,15) Error: overloaded identifier "Read" isn't a function
procedure _FileRead(ADosyaKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
asm
  push	AHedefBellek
  push  ADosyaKimlik
  mov	  eax,DOSYA_OKU
  int	  $34
  add	  esp,8
end;

procedure _CloseFile(ADosyaKimlik: TKimlik); assembler;
asm
  push	ADosyaKimlik
  mov	  eax,DOSYA_KAPAT
  int	  $34
  add	  esp,4
end;
