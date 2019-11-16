{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_durumcubugu.inc
  Dosya Ýþlevi: durum çubuðu (statusbar) nesne çaðrý iþlevlerini içerir
  Ýþlev No: 0x0D

 ==============================================================================}
function _DurumCubuguOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADurumYazisi: string): TKimlik; assembler;
asm
  push  ADurumYazisi
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,DURUMCUBUGU_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _DurumCubuguYazisiDegistir(AKimlik: TKimlik; ADurumYazisi: string); assembler;
asm
  push  ADurumYazisi
  push  AKimlik
  mov   eax,DURUMCUBUGU_YAZIDEGISTIR
  int   $34
  add   esp,8
end;

procedure _DurumCubuguGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,DURUMCUBUGU_GOSTER
  int   $34
  add   esp,4
end;
