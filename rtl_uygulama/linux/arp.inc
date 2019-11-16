{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: arp.inc
  Dosya Ýþlevi: sistem ARP çaðrý iþlevlerini içerir
  Ýþlev No: 0x0E

 ==============================================================================}
{$asmmode intel}
function ARPKayitSayisiAl: TSayi4; assembler;
asm
  mov   eax,ARP_KAYITSAYISIAL
  int   $34
end;

function ARPKayitBilgisiAl(ASiraNo: TSayi4; AARPKayit: TARPKayit): TISayi4; assembler;
asm
  push  AARPKayit
  push  ASiraNo
  mov   eax,ARP_KAYITBILGISIAL
  int   $34
  add   esp,8
end;
