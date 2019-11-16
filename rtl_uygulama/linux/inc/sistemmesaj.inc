{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sistemmesaj.inc
  Dosya İşlevi: hata ayıklama (debug) amaçlı mesaj yönetim işlevlerini içerir
  İşlev No: 0x0A

 ==============================================================================}
function _SistemMesajToplam: TSayi4; assembler;
asm
  mov   eax,SISTEMMESAJ_TOPLAM
  int   $34
end;

procedure _SistemMesajAl(ASiraNo: TSayi4; AMesaj: PMesaj); assembler;
asm
  push  AMesaj
  push  ASiraNo
  mov   eax,SISTEMMESAJ_MESAJAL
  int   $34
  add   esp,8
end;

procedure _SistemMesajYaziEkle(AMesaj: string); assembler;
asm
  push  AMesaj
  mov   eax,SISTEMMESAJ_YAZIEKLE
  int   $34
  add   esp,4
end;

procedure _SistemMesajSayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4); assembler;
asm
  push  AHaneSayisi
  push  ASayi16
  push  AMesaj
  mov   eax,SISTEMMESAJ_SAYI16EKLE
  int   $34
  add   esp,12
end;
