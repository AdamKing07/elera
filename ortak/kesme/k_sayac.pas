{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_sayac.pas
  Dosya İşlevi: sayaç kesme işlevlerini içerir

  Güncelleme Tarihi: 15/05/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit k_sayac;

interface

uses paylasim;

function SayacCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses cmos;

function SayacCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  P1: PSayi1;
  P2: PSayi2;
  Deger4: TSayi4;
  Saat, Dakika, Saniye: TSayi1;
  Gun, Ay, Yil, HaftaninGunu: TSayi2;
  _Islev: TSayi4;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // geçerli saat değerini al
  if(_Islev = 1) then
  begin

    P1 := Isaretci(PSayi4(Degiskenler)^ + CalisanGorevBellekAdresi);

    SaatAl(Saat, Dakika, Saniye);
    P1^ := Saat;
    Inc(P1);
    P1^ := Dakika;
    Inc(P1);
    P1^ := Saniye;
  end
  // geçerli tarih değerini al
  else if(_Islev = 2) then
  begin

    P2 := Isaretci(PSayi4(Degiskenler)^ + CalisanGorevBellekAdresi);

    TarihAl(Gun, Ay, Yil, HaftaninGunu);
    P2^ := Gun;
    Inc(P2);
    P2^ := Ay;
    Inc(P2);
    P2^ := Yil;
    Inc(P2);
    P2^ := HaftaninGunu;
  end
  // belirtilen milisaniye kadar bekle
  else if(_Islev = $10) then
  begin

    Deger4 := PSayi4(Degiskenler)^;

    Deger4 := ZamanlayiciSayaci + Deger4;
    while (Deger4 > ZamanlayiciSayaci) do begin asm int $20; end; end;
  end

  // işlev belirtilen aralıkta değilse hata kodunu geri döndür
  else Result := HATA_ISLEV;
end;

end.
