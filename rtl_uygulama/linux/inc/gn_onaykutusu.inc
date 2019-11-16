{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_onaykutusu.inc
  Dosya Ýþlevi: onay kutusu nesne iþlevlerini içerir
  Ýþlev No: 0x09

 ==============================================================================}
function _OnayKutusuOlustur(AtaKimlik: TKimlik; A1, B1: TISayi4; ABaslik: string): TKimlik; assembler;
asm
  push  ABaslik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,ONAYKUTUSU_OLUSTUR
  int   $34
  add   esp,16
end;

procedure _OnayKutusuGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,ONAYKUTUSU_GOSTER
  int   $34
  add   esp,4
end;
