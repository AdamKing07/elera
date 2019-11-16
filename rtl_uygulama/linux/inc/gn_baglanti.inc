{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_baglanti.inc
  Dosya Ýþlevi: baðlantý (link) nesne çaðrý iþlevlerini içerir
  Ýþlev No: 0x0F

 ==============================================================================}
function _BaglantiOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): LongInt; assembler;
asm
  push  ABaslik
  push  AOdakRenk
  push  ANormalRenk
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,BAGLANTI_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _BaglantiGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,BAGLANTI_GOSTER
  int   $34
  add   esp,4
end;
