{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: k_olay.pas
  Dosya ��levi: olay (event) y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_olay;

interface

uses paylasim;

function OlayCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel, gorev, zamanlayici;

{==============================================================================
  olay kesme �a�r�lar�n� y�netir
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

  // g�rev i�in olay olsun (olayla) veya olmas�n (olays�z) g�reve geri d�ner
  if(_IslevNo = 1) then
  begin

    _Gorev := GorevListesi[CalisanGorev];

    // �al��an proses'e ait olay var m� ?
    if(_Gorev^.OlayAl(_Olay)) then

      OlayMevcut := True
    else OlayMevcut := False;

    // olay de�i�kenlerini g�revin y���n alan�na kopyala
    if(OlayMevcut) then
    begin

      p := POlayKayit(PSayi4(Degiskenler)^ + AktifGorevBellekAdresi);
      p^.Kimlik := _Olay.Kimlik;
      p^.Olay := _Olay.Olay;
      p^.Deger1 := _Olay.Deger1;
      p^.Deger2 := _Olay.Deger2;

      Result := _Gorev^.OlaySayisi;
    end

    // olay yok ise tek bir g�rev de�i�ikli�i yap ve g�revi istekte bulunan devret.
    // aksi durumda kaynaklar�n hemen hemen hepsini kendisi kullan�r
    else
    begin

      ElleGorevDegistir;
      Result := 0;
    end;
  end

  // istekte bulunan g�rev i�in olay mevcut oluncaya kadar bekle ve olay� geri d�nd�r
  else if(_IslevNo = 2) then
  begin

    _Gorev := GorevListesi[CalisanGorev];

    // uygulama i�in olay �retilinceye kadar bekle
    // olay olmamas� durumda bir sonraki g�reve ge� (mevcut g�rev olay bekliyor)
    // ta ki ilgili g�rev i�in olay mevcut oluncaya kadar
    repeat

      if(_Gorev^.OlayAl(_Olay)) then

        OlayMevcut := True
      else OlayMevcut := False;

      if not(OlayMevcut) then ElleGorevDegistir;
    until (OlayMevcut = True);

    // olay de�i�kenlerini g�revin y���n alan�na kopyala
    p := POlayKayit(PSayi4(Degiskenler)^ + AktifGorevBellekAdresi);
    p^.Kimlik := _Olay.Kimlik;
    p^.Olay := _Olay.Olay;
    p^.Deger1 := _Olay.Deger1;
    p^.Deger2 := _Olay.Deger2;

    Result := _Gorev^.OlaySayisi;
  end;
end;

end.
