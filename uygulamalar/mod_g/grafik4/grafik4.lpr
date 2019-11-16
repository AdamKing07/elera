program grafik4;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik4.lpr
  Program İşlevi: çoklu poligon çizim programı

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, zamanlayici, gn_islemgostergesi, gn_onaykutusu,
  gn_giriskutusu, gn_degerdugmesi;

const
  ProgramAdi: string = 'Grafik - 4';
  USTDEGER_NOKTASAYISI = 28;

type
  TNoktaKayit = record
    A1, B1,
    YatayDeger, DikeyDeger: TISayi4;
  end;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  Noktalar: array[0..USTDEGER_NOKTASAYISI - 1] of TNoktaKayit;
  i, A1, B1: TISayi4;

procedure NoktalariCiz(AIlk, ASon: TSayi4; ARenk: TRenk);
var
  _i: Integer;
begin

  for _i := AIlk to ASon - 1 do
  begin

    if(_i = ASon - 1) then
      Pencere0.Tuval.Cizgi(Noktalar[_i].A1, Noktalar[_i].B1,
        Noktalar[AIlk].A1, Noktalar[AIlk].B1, ARenk)
    else Pencere0.Tuval.Cizgi(Noktalar[_i].A1, Noktalar[_i].B1,
      Noktalar[_i + 1].A1, Noktalar[_i + 1].B1, ARenk);
  end;
end;

begin

  Pencere0.Olustur(-1, 150, 150, 500 + 8, 400 + 30, ptIletisim, ProgramAdi, $F5F6D7);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  Zamanlayici0.Olustur(10);

  Pencere0.Goster;

  for i := 0 to USTDEGER_NOKTASAYISI - 1 do
  begin

    Randomize;

    A1 := Random(500);
    Noktalar[i].A1 := A1;
    if(A1 > 255) then
      Noktalar[i].YatayDeger := 1
    else Noktalar[i].YatayDeger := -1;

    B1 := Random(400);
    Noktalar[i].B1 := B1;
    if(B1 > 255) then
      Noktalar[i].DikeyDeger := 1
    else Noktalar[i].DikeyDeger := -1;
  end;

  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayAl(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
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

  until (1 = 2);
end.
