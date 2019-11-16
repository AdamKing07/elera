{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: k_zamanlayici.pas
  Dosya ��levi: zamanlay�c� kesme i�levlerini i�erir

  G�ncelleme Tarihi: 14/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_zamanlayici;

interface

uses paylasim;

function ZamanlayiciCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses zamanlayici;

{==============================================================================
  zamanlay�c� kesme �a�r�lar�n� y�netir
 ==============================================================================}
function ZamanlayiciCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Zamanlayici: PZamanlayici;
  _Islev: TSayi4;
begin

  // i�lev no
  _Islev := (IslevNo and $FF);

  // zamanlay�c� nesnesi olu�tur
  if(_Islev = ISLEV_OLUSTUR) then
  begin

    _Zamanlayici := _Zamanlayici^.Olustur(PISayi4(Degiskenler)^);

    if(_Zamanlayici <> nil) then
      Result := _Zamanlayici^.Kimlik
    else Result := -1;
  end

  // zamanlay�c� nesnesini ba�lat�r
  else if(_Islev = 2) then
  begin

    _Zamanlayici := ZamanlayiciListesi[PKimlik(Degiskenler)^];
    if(_Zamanlayici <> nil) then _Zamanlayici^.Durum := zdCalisiyor;
  end

  // zamanlay�c� nesnesini durdurur
  else if(_Islev = 3) then
  begin

    _Zamanlayici := ZamanlayiciListesi[PKimlik(Degiskenler)^];

    if(_Zamanlayici <> nil) then _Zamanlayici^.Durum := zdDurduruldu;
  end

  // i�lev belirtilen aral�kta de�ilse hata kodunu geri d�nd�r
  else Result := HATA_ISLEV;
end;

end.
