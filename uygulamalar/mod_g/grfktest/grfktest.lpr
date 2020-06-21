program grfktest;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: grfktest.lpr
  Program Ýþlevi: grafik test programý (fps deðerini ölçer)

  Güncelleme Tarihi: 08/06/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici;

const
  ProgramAdi: string = 'Grafik Test - 200x200';
  RenkListesi: array[0..7] of TRenk = (
    $00FF8080, $00FF6060, $00FF4040, $00FF2020,
    $00FF2020, $00FF4040, $00FF6060, $00FF8080);

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  RenkSiraDegeri: TSayi4 = 0;
  FPSDegeri: TSayi4 = 0;
  FPSSayaci: TSayi4 = 0;

procedure NoktalariCiz;
var
  Renk: TRenk;
  Sol, Ust: TSayi4;
begin

  Inc(RenkSiraDegeri);
  RenkSiraDegeri := RenkSiraDegeri and 7;
  Renk := RenkListesi[RenkSiraDegeri];

  for Ust := 0 to 200 - 1 do
  begin

    for Sol := 0 to 200 - 1 do
    begin

      Pencere0.Tuval.PixelYaz(Sol, Ust, Renk);
    end;
  end;

  Pencere0.Tuval.KalemRengi := RENK_SIYAH;
  Pencere0.Tuval.Dikdortgen(0, 0, 10 * 8, 1 * 16, RENK_SIYAH, True);
  Pencere0.Tuval.KalemRengi := RENK_BEYAZ;
  Pencere0.Tuval.SayiYaz16(0, 0, True, 8, FPSDegeri);
  Inc(FPSSayaci);
end;

begin

  Pencere0.Olustur(-1, 100, 100, 200, 200, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  while True do
  begin

    if(Gorev0.OlayAl(OlayKayit) = 0) then

      NoktalariCiz

    else if(OlayKayit.Olay = CO_CIZIM) then

      NoktalariCiz

    // her bir saniyede FPS deðerini kaydet ve yeniden FPS sayacýný baþlat
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      FPSDegeri := FPSSayaci;
      FPSSayaci := 0;
    end;
  end;
end.
