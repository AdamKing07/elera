{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gorev.inc
  Dosya Ýþlevi: görev (program) nesnesini yönetir
  Ýþlev No: 0x0C

 ==============================================================================}
function _GorevCalistir(ADosyaTamYol: string): TKimlik; assembler;
asm
  push	ADosyaTamYol
  mov	  eax,GOREV_CALISTIR
  int	  $34
  add	  esp,4
end;

function _GorevSonlandir(AGorevNo: TISayi4): TISayi4 assembler;
asm
  push  AGorevNo
  mov	  eax,GOREV_SONLANDIR
  int	  $34
  add   esp,4
end;

procedure _GorevSayilariniAl(var AUstSinirGorevSayisi, ACalisanGorevSayisi: TSayi4); assembler;
asm
  push  ACalisanGorevSayisi
  push  AUstSinirGorevSayisi
  mov	  eax,GOREV_SAYISINIAL
  int	  $34
  add	  esp,8
end;

function _GorevBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4; assembler;
asm
  push	ABellekAdresi
  push	AKimlik
  mov	  eax,GOREV_BILGISIAL
  int	  $34
  add	  esp,8
end;

function _GorevYazmacBilgisiAl(AKimlik: TKimlik; ABellekAdresi: Isaretci): TISayi4; assembler;
asm
  push	ABellekAdresi
  push	AKimlik
  mov	  eax,GOREV_YAZMACBILGISIAL
  int	  $34
  add	  esp,8
end;
