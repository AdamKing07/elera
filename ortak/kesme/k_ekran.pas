{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_ekran.pas
  Dosya İşlevi: ekran (screen) yönetim işlevlerini içerir

  Güncelleme Tarihi: 08/10/2019

 ==============================================================================}
{$mode objfpc}
unit k_ekran;

interface

uses paylasim;

function EkranCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel;

{==============================================================================
  ekran kesme çağrılarını yönetir
 ==============================================================================}
function EkranCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Islev: TSayi4;
  _Nokta: PNokta;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // AL'ma işlevi
  if(_Islev = ISLEV_AL) then
  begin

    _Islev := ((IslevNo shr 8) and $FF);

    // ekran çözünürlüğünü al
    if(_Islev = 1) then
    begin

      // çözünürlük değerlerini belirtilen bellek adreslerine kopyala
      _Nokta := PNokta(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi);


      _Nokta^.A1 := GEkranKartSurucusu.KartBilgisi.YatayCozunurluk;
      _Nokta^.B1 := GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk;

      // işlev başarı kodunu geri döndür
      Result := 1;
    end;
  end

  // işlev belirtilen aralıkta değil ise hata kodunu geri döndür
  else Result := HATA_ISLEV;
end;

end.
