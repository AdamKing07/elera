program saat;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: saat.lpr
  Program Ýþlevi: dijital tarih / saat programý

  Güncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, n_zamanlayici;

var
  Gorev: TGorev;
  Pencere: TPencere;
  Zamanlayici: TZamanlayici;
  OlayKayit: TOlayKayit;
  SaatDizi: array[0..2] of TSayi1;      // saat / dakika / saniye
  TarihDizi: array[0..3] of TSayi2;     // gün / ay / yýl / haftanýn günü
  s: string;

begin

  Pencere.Olustur(-1, 200, 200, 160, 52, ptIletisim, 'Tarih / Saat', $E3F5AB);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Pencere.Goster;

  Zamanlayici.Olustur(100);
  Zamanlayici.Baslat;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := $041F2F;

      SaatAl(@SaatDizi);
      s := TimeToStr(SaatDizi);
      Pencere.Tuval.YaziYaz(46, 8, s);

      TarihAl(@TarihDizi);
      s := DateToStr(TarihDizi, True);
      Pencere.Tuval.YaziYaz(22, 28, s);
    end;
  end;
end.
