{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_gucdugme.inc
  Dosya İşlevi: güç düğme çağrı işlevlerini içerir
  İşlev No: 0x02

 ==============================================================================}
function _GucDugmeOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik; assembler;
asm
  push  ABaslik
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,GUCDUGME_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _GucDugmeGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,GUCDUGME_GOSTER
  int   $34
  add   esp,4
end;

procedure _GucDugmeDurumYaz(AKimlik: TKimlik; ADurum: TSayi4); assembler;
asm
  push  ADurum
  push  AKimlik
  mov   eax,GUCDUGME_DURUMYAZ
  int   $34
  add   esp,8
end;
