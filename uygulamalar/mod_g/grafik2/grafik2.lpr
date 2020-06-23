program grafik2;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik2.lpr
  Program İşlevi: grafik test programı

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, gn_dugme, n_zamanlayici;

const
  ProgramAdi: string = 'Grafik-2';

var
  Gorev: TGorev;
  Pencere: TPencere;
  Zamanlayici: TZamanlayici;
  OlayKayit: TOlayKayit;
  Renkler: array[0..7] of TRenk = (
    $000000, $4D001F, $99003D, $E6005C,
    $FF1A75, $FF66A3, $FFB3D1, $FFE6f0);
  Renk: TRenk;
  RenkSiraNo, i: TSayi4;

begin

  Pencere.Olustur(-1, 100, 100, 200, 200, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Pencere.Goster;

  Zamanlayici.Olustur(20);
  Zamanlayici.Baslat;

  i := 20;
  RenkSiraNo := 0;
  Renk := Renkler[RenkSiraNo];

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Inc(i);
      if(i > 99) then
      begin

        i := 20;
        Inc(RenkSiraNo);
        if(RenkSiraNo > 7) then RenkSiraNo := 0;
        Renk := Renkler[RenkSiraNo];
      end;

      Pencere.Tuval.Daire(100, 100, i, Renk, False);
    end;
  end;
end.
