{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dugmeler.lpr
  Program Ýþlevi: resim düðme test programý

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
{$mode objfpc}
program dugmeler;

uses gorev, gn_pencere, gn_resimdugme;

const
  ProgramAdi: string = 'Düðmeler';

  RenkListesi: array[0..15] of TRenk = (
    $FFFFFF, $C0C0C0, $808080, $000000,
    $FF0000, $800000, $FFFF00, $808000,
    $00FF00, $008000, $00FFFF, $008080,
    $0000FF, $000080, $FF00FF, $800080);

  ResimListesi: array[0..15] of TRenk = (
    $80000000, $80000001, $80000002, $80000003,
    $80000004, $80000005, $80000006, $80000007,
    $80000008, $80000009, $8000000A, $8000000B,
    $8000000C, $8000000D, $8000000E, $8000000F);

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  rdDugmeler: array[0..15] of TResimDugme;
  OlayKayit: TOlayKayit;
  _A1, _B1, i: TISayi4;

begin
  Pencere0.Olustur(-1, 200, 200, 142, 164, ptBoyutlandirilabilir, ProgramAdi,
    RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  _A1 := 8;
  _B1 := 8;
  for i := 1 to 16 do
  begin

    //rdDugmeler[i - 1].Olustur(Pencere0.Kimlik, _A1, _B1, 26, 26, RenkListesi[i - 1]);
    rdDugmeler[i - 1].Olustur(Pencere0.Kimlik, _A1, _B1, 26, 26, ResimListesi[i - 1]);
    rdDugmeler[i - 1].Goster;

    _A1 += 30;
    if((i mod 4) = 0) then
    begin

      _A1 := 8;
      _B1 += 30;
    end;
  end;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

    end;
  until (1 = 2);
end.
