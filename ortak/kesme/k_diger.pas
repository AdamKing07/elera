{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_diger.pas
  Dosya İşlevi: kategorik olmayan diğer işlevleri içerir

  Güncelleme Tarihi: 08/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit k_diger;

interface

uses paylasim;

function DigerCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses sistemmesaj;

{==============================================================================
  kategorik olmayan kesme çağrılarını yönetir
 ==============================================================================}
function DigerCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Islev, _Sayi4: TSayi4;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // test işlevi
  // zamanlayıcı sayacını geri döndür
  //if(_Islev = 1) then
  begin

    asm
      rdtsc
      mov _Sayi4,eax
    end;

    SISTEM_MESAJ_S16('Değer: ', _Sayi4, 8);
    Result := _Sayi4;
  end

  // işlev belirtilen aralıkta değil ise hata kodunu geri döndü_Sayi4
  //else Result := HATA_ISLEV;
end;

end.
