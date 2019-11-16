{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sistem.pp
  Dosya İşlevi: sistem ile ilgili bilgileri görüntüler

  Güncelleme Tarihi: 03/12/2017

 ==============================================================================}
{$mode objfpc}
unit sistem;

interface

procedure SysInfo;

implementation

uses shared, tmode;

{==============================================================================
  sistem bilgisini görüntüler
 ==============================================================================}
procedure SysInfo;
begin

  Write(#10 + '   Sistem: ' + OsVer);
  Write(#10 + '   Derleme Tarihi: ' + CompileDate);
  Write(#10 + '   Derleme Ortami: ' + FpcTarget);
  Write(#10 + '   Fpc Surum: ' + FpcVer);
end;

end.
