{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_acilirmenu.inc
  Dosya Ýþlevi: açýlýr menü nesne iþlevlerini içerir
  Ýþlev No: 0x16

 ==============================================================================}
function _AcilirMenuOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;
asm
  push  ASeciliYaziRenk
  push  ANormalYaziRenk
  push  ASecimRenk
  push  AGovdeRenk
  push  AKenarRenk
  mov   eax,ACILIRMENU_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _AcilirMenuGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ACILIRMENU_GOSTER
  int   $34
  add   esp,4
end;

procedure _AcilirMenuGizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,ACILIRMENU_GIZLE
  int   $34
  add   esp,4
end;

procedure _AcilirMenuElemanEkle(AKimlik: TKimlik; AElemanAdi: string; AResimSiraNo: TISayi4);
asm
  push  AResimSiraNo
  push  AElemanAdi
  push  AKimlik
  mov   eax,ACILIRMENU_ELEMANEKLE
  int   $34
  add   esp,12
end;

function _AcilirMenuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4;
asm
  push  AKimlik
  mov   eax,ACILIRMENU_SECILISIRANOAL
  int   $34
  add   esp,4
end;
