{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_sistem.pas
  Dosya İşlevi: sistem kesme işlevlerini içerir

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit k_sistem;

interface

uses paylasim;

function SistemCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel;

function SistemCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _SB: PSistemBilgisi;
  _IB: PIslemciBilgisi;
  _Islev: TSayi4;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // sistem bilgilerini al
  if(_Islev = 1) then
  begin

    _SB := PSistemBilgisi(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi);
    _SB^.SistemAdi := SistemAdi;
    _SB^.DerlemeBilgisi := DerlemeTarihi;
    _SB^.FPCMimari := FPCMimari;
    _SB^.FPCSurum := FPCSurum;
    _SB^.YatayCozunurluk := GEkranKartSurucusu.KartBilgisi.YatayCozunurluk;
    _SB^.DikeyCozunurluk := GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk;
  end
  // işlemci bilgisini al
  else if(_Islev = 2) then
  begin

    _IB := PIslemciBilgisi(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi);
    _IB^.Satici := GIslemciBilgisi.Satici;
    _IB^.Ozellik1_EAX := GIslemciBilgisi.Ozellik1_EAX;
    _IB^.Ozellik1_EDX := GIslemciBilgisi.Ozellik1_EDX;
    _IB^.Ozellik1_ECX := GIslemciBilgisi.Ozellik1_ECX;
  end

  // işlev belirtilen aralıkta değilse hata kodunu geri döndür
  else Result := HATA_ISLEV;
end;

end.
