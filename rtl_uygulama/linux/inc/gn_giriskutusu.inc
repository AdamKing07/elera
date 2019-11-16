{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_giriskutusu.inc
  Dosya Ýþlevi: giriþ kutusu nesne iþlevlerini içerir
  Ýþlev No: 0x0A

 ==============================================================================}
function _GirisKutusuOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4; AIcerikDeger: string): TKimlik; assembler;
asm
  push  AIcerikDeger
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,GIRISKUTUSU_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _GirisKutusuGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,GIRISKUTUSU_GOSTER
  int   $34
  add   esp,4
end;

procedure _GirisKutusuIcerikAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,GIRISKUTUSU_ICERIKAL
  int   $34
  add   esp,8
end;

procedure _GirisKutusuIcerikYaz(AKimlik: TKimlik; AIcerikDeger: string); assembler;
asm
  push  AIcerikDeger
  push  AKimlik
  mov   eax,GIRISKUTUSU_ICERIKYAZ
  int   $34
  add   esp,8
end;

procedure _GirisKutusuYazilamaz0(AKimlik: TKimlik; AYazilamaz: LongBool); assembler;
asm
  push  AYazilamaz
  push  AKimlik
  mov   eax,GIRISKUTUSU_YAZILAMAZ0
  int   $34
  add   esp,8
end;

procedure _GirisKutusuSadeceRakam0(AKimlik: TKimlik; ASadeceSayi: LongBool); assembler;
asm
  push  ASadeceSayi
  push  AKimlik
  mov   eax,GIRISKUTUSU_SADECESAYI0
  int   $34
  add   esp,8
end;
