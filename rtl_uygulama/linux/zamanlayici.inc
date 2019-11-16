{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: zamanlayici.inc
  Dosya Ýþlevi: sistem zamanlayýcý çaðrý iþlevlerini içerir
  Ýþlev No: 0x09

 ==============================================================================}
{$asmmode intel}
function _ZamanlayiciOlustur(AMilisaniye: TSayi4): TKimlik; assembler;
asm
  push	AMilisaniye
  mov	  eax,ZAMANLAYICI_OLUSTUR
  int	  $34
  add	  esp,4
end;

procedure _ZamanlayiciBaslat(AKimlik: TKimlik); assembler;
asm
  push	AKimlik
  mov	  eax,ZAMANLAYICI_BASLAT
  int	  $34
  add	  esp,4
end;

procedure _ZamanlayiciDurdur(AKimlik: TKimlik); assembler;
asm
  push	AKimlik
  mov	  eax,ZAMANLAYICI_DURDUR
  int	  $34
  add	  esp,4
end;
