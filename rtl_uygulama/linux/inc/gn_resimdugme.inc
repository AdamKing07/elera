{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_resimdugme.inc
  Dosya İşlevi: resim düğme çağrı işlevlerini içerir
  İşlev No: 0x02

 ==============================================================================}
function _ResimDugmeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik,
  ADeger: TISayi4): TKimlik;
asm
  push  ADeger
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,RESIMDUGME_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _ResimDugmeGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,RESIMDUGME_GOSTER
  int   $34
  add   esp,4
end;

procedure _ResimDugmeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,RESIMDUGME_HIZALA
  int   $34
  add   esp,8
end;
