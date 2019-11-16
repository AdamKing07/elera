{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: noktalar.lpr
  Program İşlevi: nokta işaretleme test programı

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
program noktalar;

uses gorev, gn_pencere, gn_dugme, zamanlayici, gn_islemgostergesi, gn_onaykutusu;

const
  ProgramAdi: string = 'Noktalar (300 x 300) - 0.5 saniye';
  Renkler: array[0..7] of TRenk = (
      $D2691E, $7FFF00, $00008B, $008B8B,
      $9932CC, $8FBC8F, $9400D3, $FFD700);

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  OnayKutusu0: TOnayKutusu;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;

procedure NoktalariCiz;
var
  i, j, A1, B1: TSayi4;
begin

  for i := 0 to 89999 do
  begin

    Randomize;
    A1 := Random(300);
    B1 := Random(300);
    j := Random(7);
    Pencere0.Tuval.PixelYaz(A1, B1 + 20, Renkler[j]);
  end;
end;

begin

  Pencere0.Olustur(-1, 100, 100, 300 + 8, 300 + 50, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  OnayKutusu0.Olustur(Pencere0.Kimlik, 2, 2, 'Devam Et');
  OnayKutusu0.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(50);

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = CO_ZAMANLAYICI) then

      NoktalariCiz
    else if(OlayKayit.Olay = CO_DURUMDEGISTI) then
    begin

      if(OlayKayit.Deger1 = 1) then Zamanlayici0.Baslat
      else if(OlayKayit.Deger1 = 0) then Zamanlayici0.Durdur;
    end;

  until (1 = 2);

end.
