program grafik1;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik1.lpr
  Program İşlevi: grafik test programı

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, zamanlayici;

const
  ProgramAdi: string = 'Grafik-1';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;

var
  OlayKayit: TOlayKayit;
  Dizi: array[0..149] of TISayi4;
  i: TSayi4;

begin

  Pencere0.Olustur(-1, 100, 100, 150 + 8, 50 + 30, ptBoyutlandirilabilir, ProgramAdi,
    RENK_SIYAH);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  for i := 0 to 149 do
  begin

    Dizi[i] := 0;
  end;

  Zamanlayici0.Olustur(50);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      for i := 2 to 149 do
      begin

        Dizi[i - 1] := Dizi[i];
      end;

      Randomize;
      Dizi[149] := Random(50);

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      for i := 1 to 149 do
      begin

        Pencere0.Tuval.Cizgi(i - 1, 50 - Dizi[i - 1], i, 50 - Dizi[i], RENK_BEYAZ);
      end;
    end;

  until (1 = 2);
end.
