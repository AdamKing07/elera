program grafik2;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik2.lpr
  Program İşlevi: grafik test programı

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, zamanlayici;

const
  ProgramAdi: string = 'Grafik-2';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  Renkler: array[0..7] of TRenk = ($000000, $4D001F,
    $99003D, $E6005C, $FF1A75, $FF66A3, $FFB3D1, $FFE6f0);
  Renk: TRenk;
  RenkSiraNo, i: TSayi4;

begin

  Pencere0.Olustur(-1, 100, 100, 200 + 8, 200 + 30, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  Pencere0.Goster;

  Zamanlayici0.Olustur(20);
  Zamanlayici0.Baslat;

  i := 20;
  RenkSiraNo := 0;
  Renk := Renkler[RenkSiraNo];

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Inc(i);
      if(i > 100) then
      begin

        i := 20;
        Inc(RenkSiraNo);
        if(RenkSiraNo > 7) then RenkSiraNo := 0;
        Renk := Renkler[RenkSiraNo];
      end;

      Pencere0.Tuval.Daire(100, 100, i, Renk, False);
    end;

  until (1 = 2);
end.
