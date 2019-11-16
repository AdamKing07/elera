{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gorselnesne.inc
  Dosya İşlevi: görsel nesne çağrı işlevlerini içerir
  İşlev No: 0x02

 ==============================================================================}
function _GorselNesneKimlikAl(KonumA1, KonumB1: TISayi4): TISayi4; assembler;
asm
  push  dword KonumB1
  push  dword KonumA1
  mov   eax,GORSELNESNE_KIMLIKAL
  int   $34
  add   esp,8
end;

function _GorselNesneAdiAl(KonumA1, KonumB1: TISayi4; ANesneAdi: Isaretci): TISayi4; assembler;
asm
  push  dword ANesneAdi
  push  dword KonumB1
  push  dword KonumA1
  mov   eax,GORSELNESNE_NESNEADIAL
  int   $34
  add   esp,12
end;

// bu işlevin alt yapı çalışması yapılacak
function _GorselNesneBilgisiAl(AKimlik: TKimlik; AHedefBellek: Isaretci): TISayi4; assembler;
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,GORSELNESNE_BILGIAL
  int   $34
  add   esp,8
end;

