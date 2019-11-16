{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_yazimod.pas
  Dosya İşlevi: yazı (text) mod işlevlerini içerir

  Güncelleme Tarihi: 22/10/2019

 ==============================================================================}
{$mode objfpc}
unit k_yazimod;

interface

uses paylasim;

function YaziModCagriIslevleri(IslevNo: TSayi4; Degiskenler: Pointer): TISayi4;

implementation

uses tmode;

{==============================================================================
  yazı (text) mod işlevlerini yönetir
 ==============================================================================}
function YaziModCagriIslevleri(IslevNo: TSayi4; Degiskenler: Pointer): TISayi4;
begin

  WriteKernelMsg('Yazi Modundan Merhaba...');

  Result := ISLEM_BASARILI;
end;

end.
