{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_etiket.inc
  Dosya Ýþlevi: etiket (label) nesne çaðrý iþlevlerini içerir
  Ýþlev No: 0x0C

 ==============================================================================}
function _EtiketOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ARenk: TRenk;
  ABaslik: string): TKimlik; assembler;
asm
  push  ABaslik
  push  ARenk
  push  B1
  push  A1
  push  AAtaKimlik
  mov   eax,ETIKET_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _EtiketGoster(AKimlik: TKimlik); assembler;
asm
  push  AKimlik
  mov   eax,ETIKET_GOSTER
  int   $34
  add   esp,4
end;

procedure _EtiketDegistir(AKimlik: TKimlik; ABaslik: string); assembler;
asm
  push  ABaslik
  push  AKimlik
  mov   eax,ETIKET_DEGISTIR
  int   $34
  add   esp,8
end;
