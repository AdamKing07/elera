{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_islemgostergesi.inc
  Dosya ��levi: i�lem g�stergesi (progressbar) �a�r� i�levlerini i�erir
  ��lev No: 0x08

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