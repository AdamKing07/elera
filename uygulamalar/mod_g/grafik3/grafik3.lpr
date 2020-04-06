program grafik3;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik3.lpr
  Program İşlevi: çoklu yönlendirilmiş nokta (pixel) işaretleme programı

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici;

const
  ProgramAdi: string = 'Grafik - 3';
  RenkListesi: array[0..15] of TRenk = (
      $FFFFFF, $C0C0C0, $808080, $000000,
      $FF0000, $800000, $FFFF00, $808000,
      $00FF00, $008000, $00FFFF, $008080,
      $0000FF, $000080, $FF00FF, $800080);
  USTDEGER_NOKTASAYISI = 16;

type
  TNoktaKayit = record
    A1, B1,
    YatayDeger, DikeyDeger,
    Renk: TISayi4;
  end;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Noktalar: array[0..USTDEGER_NOKTASAYISI - 1] of TNoktaKayit;
  i, _YatayDeger, _DikeyDeger, Renk: TISayi4;

begin

  Pencere0.Olustur(-1, 50, 50, 400 + 8, 300 + 30, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  for i := 0 to USTDEGER_NOKTASAYISI - 1 do
  begin

    Randomize;
    _YatayDeger := Random(500);
    _DikeyDeger := Random(500);
    Renk := RenkListesi[Random(15)];

    Noktalar[i].A1 := _YatayDeger;
    if(_YatayDeger > 255) then
      Noktalar[i].YatayDeger := 1
    else Noktalar[i].YatayDeger := -1;

    Noktalar[i].B1 := _DikeyDeger;
    if(_DikeyDeger > 255) then
      Noktalar[i].DikeyDeger := 1
    else Noktalar[i].DikeyDeger := -1;

    Noktalar[i].Renk := Renk;
  end;

  repeat

    for i := 0 to USTDEGER_NOKTASAYISI - 1 do
    begin

      _YatayDeger := Noktalar[i].A1;
      _YatayDeger := _YatayDeger + Noktalar[i].YatayDeger;
      if(_YatayDeger < 0) then
      begin

        _YatayDeger := 0;
        Noktalar[i].YatayDeger := 1;
      end
      else if(_YatayDeger > 400) then
      begin

        _YatayDeger := 400;
        Noktalar[i].YatayDeger := -1;
      end;
      Noktalar[i].A1 := _YatayDeger;

      _DikeyDeger := Noktalar[i].B1;
      _DikeyDeger := _DikeyDeger + Noktalar[i].DikeyDeger;
      if(_DikeyDeger < 0) then
      begin

        _DikeyDeger := 0;
        Noktalar[i].DikeyDeger := 1;
      end
      else if(_DikeyDeger > 300) then
      begin

        _DikeyDeger := 300;
        Noktalar[i].DikeyDeger := -1;
      end;
      Noktalar[i].B1 := _DikeyDeger;

      Renk := Noktalar[i].Renk;

      Pencere0.Tuval.PixelYaz(_YatayDeger, _DikeyDeger, Renk);
    end;

  until (1 = 2);
end.
