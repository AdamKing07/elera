{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: k_olay.pas
  Dosya Ýþlevi: olay (event) yönetim iþlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_olay;

interface

uses paylasim;

function OlayCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel, gorev, zamanlayici;

{==============================================================================
  olay kesme çaðrýlarýný yönetir
 ==============================================================================}
function OlayCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Gorev: PGorev;
  p: POlayKayit;
  _Olay: TOlayKayit;
  _IslevNo: TSayi4;
  OlayMevcut: Boolean;
begin

  _IslevNo := (IslevNo and $FF);

  // görev için olay olsun (olayla) veya olmasýn (olaysýz) göreve geri döner
  if(_IslevNo = 1) then
  begin

    _Gorev := GorevListesi[CalisanGorev];

    // çalýþan proses'e ait olay var mý ?
    if(_Gorev^.OlayAl(_Olay)) then

      OlayMevcut := True
    else OlayMevcut := False;

    // olay deðiþkenlerini görevin yýðýn alanýna kopyala
    if(OlayMevcut) then
    begin

      p := POlayKayit(PSayi4(Degiskenler)^ + AktifGorevBellekAdresi);
      p^.Kimlik := _Olay.Kimlik;
      p^.Olay := _Olay.Olay;
      p^.Deger1 := _Olay.Deger1;
      p^.Deger2 := _Olay.Deger2;

      Result := _Gorev^.OlaySayisi;
    end

    // olay yok ise tek bir görev deðiþikliði yap ve görevi istekte bulunan devret.
    // aksi durumda kaynaklarýn hemen hemen hepsini kendisi kullanýr
    else
    begin

      ElleGorevDegistir;
      Result := 0;
    end;
  end

  // istekte bulunan görev için olay mevcut oluncaya kadar bekle ve olayý geri döndür
  else if(_IslevNo = 2) then
  begin

    _Gorev := GorevListesi[CalisanGorev];

    // uygulama için olay üretilinceye kadar bekle
    // olay olmamasý durumda bir sonraki göreve geç (mevcut görev olay bekliyor)
    // ta ki ilgili görev için olay mevcut oluncaya kadar
    repeat

      if(_Gorev^.OlayAl(_Olay)) then

        OlayMevcut := True
      else OlayMevcut := False;

      if not(OlayMevcut) then ElleGorevDegistir;
    until (OlayMevcut = True);

    // olay deðiþkenlerini görevin yýðýn alanýna kopyala
    p := POlayKayit(PSayi4(Degiskenler)^ + AktifGorevBellekAdresi);
    p^.Kimlik := _Olay.Kimlik;
    p^.Olay := _Olay.Olay;
    p^.Deger1 := _Olay.Deger1;
    p^.Deger2 := _Olay.Deger2;

    Result := _Gorev^.OlaySayisi;
  end;
end;

end.
