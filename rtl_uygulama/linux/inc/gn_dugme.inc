{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_dugme.inc
  Dosya Ýþlevi: düðme çaðrý iþlevlerini içerir
  Ýþlev No: 0x02

 ==============================================================================}
function _DugmeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
asm
  push  ABaslik
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,DUGME_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _DugmeGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,DUGME_GOSTER
  int   $34
  add   esp,4
end;

procedure _DugmeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,DUGME_HIZALA
  int   $34
  add   esp,8
end;
