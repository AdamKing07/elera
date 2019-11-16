{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: bellek.inc
  Dosya Ýþlevi: sistem bellek çaðrý iþlevlerini içerir
  Ýþlev No: 0x0B

 ==============================================================================}
{$asmmode intel}
procedure CekirdekBellekBilgisiAl(ACekirdekBaslangicAdresi, ACekirdekBitisAdresi,
  ACekirdekUzunlugu: Isaretci); assembler;
asm
  push  ACekirdekUzunlugu
  push  ACekirdekBitisAdresi
  push  ACekirdekBaslangicAdresi
  mov   eax,BELLEK_CEKIRDEKBILGISI
  int   $34
  add   esp,12
end;

procedure GenelBellekBilgisiAl(AToplamRAMBlok, AAyrilmisRAMBlok, AKullanilanRAMBlok,
  ABosRAMBlok, ARAMBlokUzunlugu: Isaretci); assembler;
asm
  push  ARAMBlokUzunlugu
  push  ABosRAMBlok
  push  AKullanilanRAMBlok
  push  AAyrilmisRAMBlok
  push  AToplamRAMBlok
  mov   eax,BELLEK_GENELBILGI
  int   $34
  add   esp,20
end;

procedure BellekIcerikOku(AKaynakBellek, AHedefBellek: Isaretci; AMiktar: TSayi4); assembler;
asm
  push  AMiktar
  push  AHedefBellek
  push  AKaynakBellek
  mov   eax,BELLEK_ICERIKOKU
  int   $34
  add   esp,12
end;
