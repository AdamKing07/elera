{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: ohci.pas
  Dosya ��levi: usb ohci y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 11/10/2019

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

  SISTEM_MESAJ_YAZI('  -> USB:OHCI kontrol ayg�t� bulundu...');
end;

end.
