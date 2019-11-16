{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.inc
  Dosya İşlevi: sistem pencere çağrı işlevlerini içerir
  İşlev No: 0x02

 ==============================================================================}
function _PencereOlustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik; assembler;
asm
  push  AGovdeRenk
  push  ABaslik
  push  APencereTipi
  push  Yukseklik
  push  Genislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,PENCERE_OLUSTUR
  int   $34
  add   esp,32
end;

procedure _PencereGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,PENCERE_GOSTER
  int   $34
  add   esp,4
end;

procedure _PencereCiz(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,PENCERE_CIZ
  int   $34
  add   esp,4
end;
