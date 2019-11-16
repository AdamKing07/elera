{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_listekutusu.inc
  Dosya Ýþlevi: liste kutusu nesne iþlevlerini içerir
  Ýþlev No: 0x02

 ==============================================================================}
function _ListeKutusuOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,LISTEKUTUSU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _ListeKutusuHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,LISTEKUTUSU_HIZALA
  int   $34
  add   esp,8
end;

procedure _ListeKutusuElemanEkle(AKimlik: TKimlik; AElemanAdi: string);
asm
  push  AElemanAdi
  push  AKimlik
  mov   eax,LISTEKUTUSU_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _ListeKutusuTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,LISTEKUTUSU_TEMIZLE
  int   $34
  add   esp,4
end;

function _ListeKutusuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,LISTEKUTUSU_SECILISIRANOAL
  int   $34
  add   esp,4
end;

procedure _ListeKutusuSeciliSiraYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,LISTEKUTUSU_SECILISIRAYAZIAL
  int   $34
  add   esp,8
end;
