{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_secimdugme.inc
  Dosya Ýþlevi: seçim düðmesi çaðrý iþlevlerini içerir
  Ýþlev No: 0x0E

 ==============================================================================}
function _SecimDugmeOlustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik; assembler;
asm
  push  ABaslik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,SECIMDUGME_OLUSTUR
  int   $34
  add   esp,16
end;

procedure _SecimDugmeDurumDegistir(AKimlik: TKimlik; ASecimDurumu: TSecimDurumu); assembler;
asm
  push  ASecimDurumu
  push  AKimlik
  mov   eax,SECIMDUGME_DURUMDEGISTIR
  int   $34
  add   esp,8
end;

procedure _SecimDugmeGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,SECIMDUGME_GOSTER
  int   $34
  add   esp,4
end;
