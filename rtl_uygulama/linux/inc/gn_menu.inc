{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_menu.inc
  Dosya Ýþlevi: menü nesne iþlevlerini içerir
  Ýþlev No: 0x02

 ==============================================================================}
function _MenuOlustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
asm
  push  AElemanYukseklik
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  mov   eax,MENU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _MenuGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,MENU_GOSTER
  int   $34
  add   esp,4
end;

procedure _MenuGizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,MENU_GIZLE
  int   $34
  add   esp,4
end;

procedure _MenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4);
asm
  push  AResimSiraNo
  push  AElemanAdi
  push  AKimlik
  mov   eax,MENU_ELEMANEKLE
  int   $34
  add   esp,12
end;

function _MenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,MENU_SECILISIRANOAL
  int   $34
  add   esp,4
end;
