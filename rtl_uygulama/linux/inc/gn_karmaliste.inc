{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_karmaliste.inc
  Dosya Ýþlevi: açýlýr / kapanýr liste kutusu nesne iþlevlerini içerir
  Ýþlev No: 0x15

 ==============================================================================}
function _KarmaListeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,KARMALISTE_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _KarmaListeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,KARMALISTE_HIZALA
  int   $34
  add   esp,8
end;

procedure _KarmaListeElemanEkle(AKimlik: TKimlik; AElemanAdi: string);
asm
  push  AElemanAdi
  push  AKimlik
  mov   eax,KARMALISTE_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _KarmaListeTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,KARMALISTE_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _KarmaListeSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,KARMALISTE_SECILIYAZIAL
  int   $34
  add   esp,8
end;
