{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_islemgostergesi.pas
  Dosya Ýþlevi: iþlem göstergesi (progressbar) nesne iþlevlerini içerir

  Güncelleme Tarihi: 19/10/2019

 ==============================================================================}

{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: pbar.inc
  Dosya Ýþlevi: iþlem göstergesi (progress bar) çaðrý iþlevlerini içerir
  Ýþlev No: 0x08
 ==============================================================================}
function _IslemGostergesiOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,ISLEMGOSTERGESI_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _IslemGostergesiDegerleriBelirle(AKimlik: TKimlik; AAltDeger, AUstDeger: TSayi4); assembler;
asm
  push  AUstDeger
  push  AAltDeger
  push  AKimlik
  mov   eax,ISLEMGOSTERGESI_ALTUSTDEGER
  int   $34
  add   esp,12
end;

procedure _IslemGostergesiKonumBelirle(AKimlik: TKimlik; AKonum: TSayi4); assembler;
asm
  push  AKonum
  push  AKimlik
  mov   eax,ISLEMGOSTERGESI_KONUMBELIRLE
  int   $34
  add   esp,8
end;
