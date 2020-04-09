{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_sistemmesaj.pas
  Dosya İşlevi: hata ayıklama (debug) amaçlı mesaj yönetim işlevlerini içerir

  Güncelleme Tarihi: 29/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_sistemmesaj;

interface

uses paylasim;

function SistemMesajCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel, sistemmesaj;

{==============================================================================
  mesaj kesme çağrılarını yönetir
 ==============================================================================}
function SistemMesajCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  p: PMesaj;
  _IslevNo: TSayi4;
begin

  // ana işlev
  _IslevNo := (IslevNo and $ff);

  // toplam ssitem mesaj sayısını al
  if(_IslevNo = 1) then
  begin

    Result := GSistemMesaj.ToplamMesaj;
  end

  // sistem mesaj bilgisini program hedef bellek bölgesine kopyala
  else if(_IslevNo = 2) then
  begin

    p := PMesaj(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
    GSistemMesaj.MesajAl(PSayi4(Degiskenler + 00)^, p);
    Result := GSistemMesaj.ToplamMesaj;
  end

  // programdan karakter katarı türünde gelen mesajı sistem mesajlarına ekle
  else if(_IslevNo = 3) then
  begin

    SISTEM_MESAJ(PShortString(Isaretci(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi))^, []);
  end

  // programdan karakter katarı + sayısal değer türünde gelen mesajı sistem mesajlarına ekle
  else if(_IslevNo = 4) then
  begin

    SISTEM_MESAJ_S16(PShortString(Isaretci(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi))^,
      PSayi4(Degiskenler + 04)^, PSayi4(Degiskenler + 08)^);
  end;
end;

end.
