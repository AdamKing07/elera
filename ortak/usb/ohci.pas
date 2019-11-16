{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: ohci.pas
  Dosya Ýþlevi: usb ohci yönetim iþlevlerini içerir

  Güncelleme Tarihi: 11/10/2019

 ==============================================================================}
{$mode objfpc}
unit ohci;

interface

uses paylasim;

procedure Yukle(APCI: PPCI);

implementation

uses sistemmesaj;

procedure Yukle(APCI: PPCI);
begin

  SISTEM_MESAJ_YAZI('  -> USB:OHCI kontrol aygýtý bulundu...');
end;

end.
