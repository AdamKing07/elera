{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: masaustu.inc
  Dosya Ýþlevi: sistem masaüstü çaðrý iþlevlerini içerir
  Ýþlev No: 0x02

 ==============================================================================}
function _MasaustuOlustur(AMasaustuAdi: string): TKimlik; assembler;
asm
  push  AMasaustuAdi
  mov	  eax,MASAUSTU_OLUSTUR
  int	  $34
  add	  esp,4
end;

function _MasaustuGoster(AKimlik: TKimlik): TKimlik; assembler;
asm
  push	AKimlik
  mov	  eax,MASAUSTU_GOSTER
  int	  $34
  add	  esp,4
end;

function _MevcutMasaustuSayisi: TSayi4; assembler;
asm
  mov	  eax,MASAUSTU_MEVCUTSAYI
  int	  $34
end;

function _AktifMasaustu: TKimlik; assembler;
asm
  mov	  eax,$04020102
  int	  $34
end;

function _MasaustuAktiflestir(AKimlik: TKimlik): Boolean; assembler;
asm
  push	AKimlik
  mov	  eax,MASAUSTU_AKTIFLESTIR
  int	  $34
  add	  esp,4
end;

procedure _MasaustuGuncelle(AKimlik: TKimlik); assembler;
asm
  push	AKimlik
  mov	  eax,$08040102
  int	  $34
  add	  esp,4
end;

procedure _MasaustuRenginiDegistir(AKimlik: TKimlik; ARenk: TRenk); assembler;
asm
  push	ARenk
  push  AKimlik
  mov	  eax,$02040102
  int	  $34
  add	  esp,8
end;

procedure _MasaustuResminiDegistir(AKimlik: TKimlik; ADosyaTamYol: string);  assembler;
asm
  push	ADosyaTamYol
  push  AKimlik
  mov	  eax,$04040102
  int	  $34
  add	  esp,8
end;
