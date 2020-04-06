program bharita;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: bharita.lpr
  Program Ýþlevi: bellek içerik harita programý

  Güncelleme Tarihi: 25/10/2019

  Not:
    programýn çalýþmasý için gereken 8K bellek makinenin kilitlenmesine sebep olduðu
    ve dinamik hafýza henüz tasarlanmadýðýndan dolayý 4K'lýk parça bellek kullanýlmýþtýr.

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_durumcubugu, zamanlayici, elera;

const
  ProgramAdi: string = 'Bellek Haritasý';
  // MEVCUTBELLEKADRESI = bellek haritasýnýn adresi
  MEVCUTBELLEKADRESI = $510000;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  DurumCubugu0: TDurumCubugu;
  _ToplamRAMBlok, _AyrilmisRAMBlok,
  _KullanilanRAMBlok, _BosRAMBlok,
  _RAMUzunlugu: TSayi4;
  s: string;
  A1, B1: TSayi4;
  p: PSayi1;

procedure NoktaIsaretle(AA1, AB1: Integer; ARenk: TRenk);
var
  _A1, _B1: Integer;
begin

  _A1 := AA1 * 3;
  _B1 := AB1 * 3;

  Pencere0.Tuval.PixelYaz(_A1, _B1, ARenk);
  Pencere0.Tuval.PixelYaz(_A1 + 1, _B1, ARenk);

  Pencere0.Tuval.PixelYaz(_A1, _B1 + 1, ARenk);
  Pencere0.Tuval.PixelYaz(_A1 + 1, _B1 + 1, ARenk);
end;

var
  _VeriBellek: array[0..4095] of TSayi1;

begin

  Pencere0.Olustur(-1, 5, 5, 395, 250, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Boþ Blok Sayýsý: 0');
  DurumCubugu0.Goster;

  Pencere0.Goster;

  // 3 saniyelik frekansla güncelle
  Zamanlayici0.Olustur(300);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      GenelBellekBilgisiAl(@_ToplamRAMBlok, @_AyrilmisRAMBlok, @_KullanilanRAMBlok,
        @_BosRAMBlok, @_RAMUzunlugu);

      s := 'Boþ Blok Sayýsý: ' + IntToStr1(_ToplamRAMBlok);
      s += ' / ';
      s += IntToStr1(_BosRAMBlok);
      DurumCubugu0.DurumYazisiDegistir(s);

      Pencere0.Tuval.Dikdortgen(0, 0, 128 * 3, 64 * 3, $000000, True);

      // 1. 4K bellek sistemden okunuyor
      BellekIcerikOku(ISaretci(MEVCUTBELLEKADRESI), @_VeriBellek[0], 4096);

      p := PByte(@_VeriBellek[0]);
      for B1 := 0 to 31 do
      begin

        for A1 := 0 to 127 do
        begin

          if(p^ = 0) then

            NoktaIsaretle(A1, B1, $00FF00)
          else if(p^ = 1) then NoktaIsaretle(A1, B1, $FF0000);

          Inc(p);
        end;
      end;

      // 2. 4K bellek sistemden okunuyor
      BellekIcerikOku(Pointer(MEVCUTBELLEKADRESI + 4096), @_VeriBellek[0], 4096);

      p := PByte(@_VeriBellek[0]);
      for B1 := 32 to 63 do
      begin

        for A1 := 0 to 127 do
        begin

          if(p^ = 0) then

            NoktaIsaretle(A1, B1, $00FF00)
          else if(p^ = 1) then NoktaIsaretle(A1, B1, $FF0000);

          Inc(p);
        end;
      end;
    end;

  until (1 = 2);
end.
