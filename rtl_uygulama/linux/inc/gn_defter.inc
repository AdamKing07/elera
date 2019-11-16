{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: defter.inc
  Dosya Ýþlevi: defter nesnesi (memo) yönetim iþlevlerini içerir
  Ýþlev No: 0x03

 ==============================================================================}
function _DefterOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
asm
  push  AYaziRenk
  push  ADefterRenk
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DEFTER_OLUSTUR
  int   $34
  add   esp,28
end;

procedure _DefterHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,DEFTER_HIZALA
  int   $34
  add   esp,8
end;

procedure _DefterGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEFTER_GOSTER
  int   $34
  add   esp,4
end;

procedure _DefterYaziEkle(AKimlik: TKimlik; ABellekAdresi: PChar);
asm
  push  ABellekAdresi
  push  AKimlik
  mov   eax,DEFTER_YAZIEKLE
  int   $34
  add   esp,8
end;

procedure _DefterTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DEFTER_TEMIZLE
  int   $34
  add   esp,4
end;
