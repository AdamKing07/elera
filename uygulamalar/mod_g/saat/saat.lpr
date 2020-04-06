program saat;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: saat.lpr
  Program Ýþlevi: dijital tarih / saat programý

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  SaatDizi: array[0..2] of TSayi1;      // saat / dakika / saniye
  TarihDizi: array[0..3] of TSayi2;     // gün / ay / yýl / haftanýn günü
  s: string;

begin

  Pencere0.Olustur(-1, 200, 200, 160, 80, ptIletisim, 'Tarih / Saat', $E3F5AB);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := $041F2F;

      GetTime(@SaatDizi);
      s := TimeToStr(SaatDizi);
      Pencere0.Tuval.YaziYaz(46, 8, s);

      GetDate(@TarihDizi);
      s := DateToStr(TarihDizi, True);
      Pencere0.Tuval.YaziYaz(22, 28, s);
    end;

  until (1 = 2);
end.
