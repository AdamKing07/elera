{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_degerdugmesi.inc
  Dosya Ýþlevi: artýrma / eksiltme (updown) düðme yönetim iþlevlerini içerir
  Ýþlev No: 0x0B

 ==============================================================================}
function _DegerDugmesiOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DEGERDUGMESI_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _DegerDugmesiGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,DEGERDUGMESI_GOSTER
  int   $34
  add   esp,4
end;
