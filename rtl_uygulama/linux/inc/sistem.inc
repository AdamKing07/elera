{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sistem.inc
  Dosya İşlevi: sistem çağrı işlevlerini içerir
  İşlev No: 0x07

 ==============================================================================}
procedure _SistemBilgisiAl(ABellekAdresi: Isaretci); assembler;
asm
  push  ABellekAdresi
  mov	  eax,SISTEMBILGISI_AL
  int	  $34
  add	  esp,4
end;

procedure _IslemciBilgisiAl(ABellekAdresi: Isaretci); assembler;
asm
  push  ABellekAdresi
  mov	  eax,ISLEMCIBILGISI_AL
  int	  $34
  add	  esp,4
end;
