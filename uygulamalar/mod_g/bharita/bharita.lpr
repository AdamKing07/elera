program bharita;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: bharita.lpr
  Program Ýþlevi: bellek içerik harita programý

  Güncelleme Tarihi: 07/06/2020

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
  ToplamRAMBlok, AyrilmisRAMBlok,
  KullanilanRAMBlok, _BosRAMBlok,
  RAMUzunlugu: TSayi4;
  s: string;
  Sol, Ust: TSayi4;
  p: PSayi1;

procedure NoktaIsaretle(ASol, AUst: TSayi4; ARenk: TRenk);
var
  Sol, Ust: Integer;
begin

  Sol := ASol * 3;
  Ust := AUst * 3;

  Pencere0.Tuval.PixelYaz(Sol, Ust, ARenk);
  Pencere0.Tuval.PixelYaz(Sol + 1, Ust, ARenk);

  Pencere0.Tuval.PixelYaz(Sol, Ust + 1, ARenk);
  Pencere0.Tuval.PixelYaz(Sol + 1, Ust + 1, ARenk);
end;

var
  Veriler: array[0..4095] of TSayi1;

begin

  Pencere0.Olustur(-1, 5, 5, (128 * 3) - 1, (64 * 3) + 20 - 1, ptBoyutlandirilabilir,
    ProgramAdi, RENK_SIYAH);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Boþ Blok Sayýsý: 0');
  DurumCubugu0.Goster;

  Pencere0.Goster;

  // 3 saniyelik frekansla güncelle
  Zamanlayici0.Olustur(300);
  Zamanlayici0.Baslat;

  while True do
  begin

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      GenelBellekBilgisiAl(@ToplamRAMBlok, @AyrilmisRAMBlok, @KullanilanRAMBlok,
        @_BosRAMBlok, @RAMUzunlugu);

      s := 'Boþ Blok Sayýsý: ' + IntToStr(ToplamRAMBlok);
      s += ' / ';
      s += IntToStr(_BosRAMBlok);
      DurumCubugu0.DurumYazisiDegistir(s);

//      Pencere0.Tuval.Dikdortgen(0, 0, 128 * 3, 64 * 3, $000000, True);

      // 1. 4K bellek sistemden okunuyor
      BellekIcerikOku(ISaretci(MEVCUTBELLEKADRESI), @Veriler[0], 4096);

      p := PByte(@Veriler[0]);
      for Ust := 0 to 31 do
      begin

        for Sol := 0 to 127 do
        begin

          if(p^ = 0) then

            NoktaIsaretle(Sol, Ust, $00FF00)
          else if(p^ = 1) then NoktaIsaretle(Sol, Ust, $FF0000);

          Inc(p);
        end;
      end;

      // 2. 4K bellek sistemden okunuyor
      BellekIcerikOku(Pointer(MEVCUTBELLEKADRESI + 4096), @Veriler[0], 4096);

      p := PByte(@Veriler[0]);
      for Ust := 32 to 63 do
      begin

        for Sol := 0 to 127 do
        begin

          if(p^ = 0) then

            NoktaIsaretle(Sol, Ust, $00FF00)
          else if(p^ = 1) then NoktaIsaretle(Sol, Ust, $FF0000);

          Inc(p);
        end;
      end;
    end;
  end;
end.
