program grafik4;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik4.lpr
  Program İşlevi: çoklu poligon çizim programı

  Güncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, gn_dugme, n_zamanlayici, gn_islemgostergesi, gn_onaykutusu,
  gn_giriskutusu, gn_degerdugmesi;

const
  ProgramAdi: string = 'Grafik-4';
  USTDEGER_NOKTASAYISI = 28;

type
  TNoktaKayit = record
    Sol, Ust,
    YatayDeger, DikeyDeger: TISayi4;
  end;

var
  Gorev: TGorev;
  Pencere: TPencere;
  Zamanlayici: TZamanlayici;
  Olay: TOlay;
  Noktalar: array[0..USTDEGER_NOKTASAYISI - 1] of TNoktaKayit;
  Sol, Ust, i: TISayi4;

procedure NoktalariCiz(AIlk, ASon: TSayi4; ARenk: TRenk);
var
  i: TISayi4;
begin

  for i := AIlk to ASon - 1 do
  begin

    if(i = ASon - 1) then
      Pencere.Tuval.Cizgi(Noktalar[i].Sol, Noktalar[i].Ust,
        Noktalar[AIlk].Sol, Noktalar[AIlk].Ust, ARenk)
    else Pencere.Tuval.Cizgi(Noktalar[i].Sol, Noktalar[i].Ust,
      Noktalar[i + 1].Sol, Noktalar[i + 1].Ust, ARenk);
  end;
end;

begin

  Pencere.Olustur(-1, 150, 150, 500, 400, ptIletisim, ProgramAdi, $F5F6D7);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Zamanlayici.Olustur(30);

  Pencere.Goster;

  for i := 0 to USTDEGER_NOKTASAYISI - 1 do
  begin

    Randomize;

    Sol := Random(500);
    Noktalar[i].Sol := Sol;
    if(Sol > 255) then
      Noktalar[i].YatayDeger := 1
    else Noktalar[i].YatayDeger := -1;

    Ust := Random(400);
    Noktalar[i].Ust := Ust;
    if(Ust > 255) then
      Noktalar[i].DikeyDeger := 1
    else Noktalar[i].DikeyDeger := -1;
  end;

  Zamanlayici.Baslat;

  while True do
  begin

    Gorev.OlayAl(Olay);
    if(Olay.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere.Ciz;
    end
    else if(Olay.Olay = CO_CIZIM) then
    begin

      // yeni nokta koordinatlarını çiz
      NoktalariCiz(00, 04, $0000FF);
      NoktalariCiz(04, 08, $000000);
      NoktalariCiz(08, 12, $FF0000);
      NoktalariCiz(12, 16, $8000FF);
      NoktalariCiz(16, 20, $0000FF);
      NoktalariCiz(20, 24, $000000);
      NoktalariCiz(24, 28, $FF0000);
    end;
  end;
end.
