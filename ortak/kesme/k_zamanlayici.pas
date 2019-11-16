{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: k_zamanlayici.pas
  Dosya Ýþlevi: zamanlayýcý kesme iþlevlerini içerir

  Güncelleme Tarihi: 14/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_zamanlayici;

interface

uses paylasim;

function ZamanlayiciCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses zamanlayici;

{==============================================================================
  zamanlayýcý kesme çaðrýlarýný yönetir
 ==============================================================================}
function ZamanlayiciCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Zamanlayici: PZamanlayici;
  _Islev: TSayi4;
begin

  // iþlev no
  _Islev := (IslevNo and $FF);

  // zamanlayýcý nesnesi oluþtur
  if(_Islev = ISLEV_OLUSTUR) then
  begin

    _Zamanlayici := _Zamanlayici^.Olustur(PISayi4(Degiskenler)^);

    if(_Zamanlayici <> nil) then
      Result := _Zamanlayici^.Kimlik
    else Result := -1;
  end

  // zamanlayýcý nesnesini baþlatýr
  else if(_Islev = 2) then
  begin

    _Zamanlayici := ZamanlayiciListesi[PKimlik(Degiskenler)^];
    if(_Zamanlayici <> nil) then _Zamanlayici^.Durum := zdCalisiyor;
  end

  // zamanlayýcý nesnesini durdurur
  else if(_Islev = 3) then
  begin

    _Zamanlayici := ZamanlayiciListesi[PKimlik(Degiskenler)^];

    if(_Zamanlayici <> nil) then _Zamanlayici^.Durum := zdDurduruldu;
  end

  // iþlev belirtilen aralýkta deðilse hata kodunu geri döndür
  else Result := HATA_ISLEV;
end;

end.
