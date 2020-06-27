{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: n_sistemmesaj.pas
  Dosya İşlevi: hata ayıklama (debug) amaçlı mesaj yönetim işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit n_sistemmesaj;

interface

type
  PSistemMesaj = ^TSistemMesaj;
  TSistemMesaj = object
  private
    FToplamMesaj: TSayi4;
  public
    function Toplam: TSayi4;
    procedure Al(ASiraNo: TSayi4; AMesaj: PMesaj);
    procedure YaziEkle(AMesaj: string);
    procedure Sayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
  end;

function _SistemMesajToplam: TSayi4; assembler;
procedure _SistemMesajAl(ASiraNo: TSayi4; AMesaj: PMesaj); assembler;
procedure _SistemMesajYaziEkle(AMesaj: string); assembler;
procedure _SistemMesajSayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4); assembler;

implementation

function TSistemMesaj.Toplam: TSayi4;
begin

  Result := _SistemMesajToplam;
end;

procedure TSistemMesaj.Al(ASiraNo: TSayi4; AMesaj: PMesaj);
begin

  _SistemMesajAl(ASiraNo, AMesaj);
end;

procedure TSistemMesaj.YaziEkle(AMesaj: string);
begin

  _SistemMesajYaziEkle(AMesaj);
end;

procedure TSistemMesaj.Sayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
begin

  _SistemMesajSayi16Ekle(AMesaj, ASayi16, AHaneSayisi);
end;

function _SistemMesajToplam: TSayi4;
asm
  mov   eax,SISTEMMESAJ_TOPLAM
  int   $34
end;

procedure _SistemMesajAl(ASiraNo: TSayi4; AMesaj: PMesaj);
asm
  push  AMesaj
  push  ASiraNo
  mov   eax,SISTEMMESAJ_MESAJAL
  int   $34
  add   esp,8
end;

procedure _SistemMesajYaziEkle(AMesaj: string);
asm
  push  AMesaj
  mov   eax,SISTEMMESAJ_YAZIEKLE
  int   $34
  add   esp,4
end;

procedure _SistemMesajSayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
asm
  push  AHaneSayisi
  push  ASayi16
  push  AMesaj
  mov   eax,SISTEMMESAJ_SAYI16EKLE
  int   $34
  add   esp,12
end;

end.