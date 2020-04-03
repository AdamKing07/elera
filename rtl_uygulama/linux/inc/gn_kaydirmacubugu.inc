{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_kaydirmacubugu.inc
  Dosya Ýþlevi: kaydýrma çubuðu çaðrý iþlevlerini içerir
  Ýþlev No: 0x14

 ==============================================================================}
function _KaydirmaCubuguOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AYon: TYon): TKimlik;
asm
  push  AYon
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,KAYDIRMACUBUGU_OLUSTUR
  int   $34
  add   esp,24
end;

procedure _KaydirmaCubuguDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4); assembler;
asm
  push  AUstDeger
  push  AAltDeger
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_ALTUSTDEGER
  int   $34
  add   esp,12
end;

procedure _KaydirmaCubuguGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_GOSTER
  int   $34
  add   esp,4
end;

procedure _KaydirmaCubuguHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,KAYDIRMACUBUGU_HIZALA
  int   $34
  add   esp,8
end;
