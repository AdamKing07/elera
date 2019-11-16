{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_listegorunum.inc
  Dosya Ýþlevi: liste görünüm nesne iþlevlerini içerir
  Ýþlev No: 0x02

 ==============================================================================}
function _ListeGorunumOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,LISTEGORUNUM_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _ListeGorunumHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,PANEL_HIZALA
  int   $34
  add   esp,8
end;

procedure _ListeGorunumElemanEkle(AKimlik: TKimlik; ADeger: string);
asm
  push  ADeger
  push  AKimlik
  mov   eax,LISTEGORUNUM_ELEMANEKLE
  int   $34
  add   esp,8
end;

function _ListeGorunumSeciliSiraAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,LISTEGORUNUM_SECILISIRAAL
  int   $34
  add   esp,4
end;

procedure _ListeGorunumSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,LISTEGORUNUM_SECILIYAZIAL
  int   $34
  add   esp,8
end;

procedure _ListeGorunumTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,LISTEGORUNUM_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _ListeGorunumBasliklariTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,LISTEGORUNUM_BTEMIZLE
  int   $34
  add   esp,4
end;

procedure _ListeGorunumBaslikEkle(AKimlik: TKimlik; ABaslikDeger: string;
  ABaslikGenisligi: TSayi4);
asm
  push  ABaslikGenisligi
  push  ABaslikDeger
  push  AKimlik
  mov   eax,LISTEGORUNUM_BASLIKEKLE
  int   $34
  add   esp,12
end;
