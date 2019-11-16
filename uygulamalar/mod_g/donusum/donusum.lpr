program donusum;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: donusum.lpr
  Program Ýþlevi: sayýsal deðer çevrim / dönüþüm programý

  Güncelleme Tarihi: 25/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_etiket, gn_durumcubugu;

const
  ProgramAdi: string = 'Sayýsal Deðer Çevrimi';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  OlayKayit: TOlayKayit;
  gkAdres: TGirisKutusu;
  Sayi, Sonuc: TISayi4;
  Hata: Boolean;
  s: string;

begin

  Pencere0.Olustur(-1, 5, 5, 290, 160, ptIletisim, ProgramAdi, $CDF0DB);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  Hata := True;

  gkAdres.Olustur(Pencere0.Kimlik, 80, 22, 120, 22, '');
  gkAdres.SadeceRakam := True;
  gkAdres.Goster;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      s := gkAdres.IcerikAl;
      if(Length(s) > 0) then
      begin

        Val(s, Sayi, Sonuc);
        Hata := Sonuc <> 0;
      end else Hata := True;

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(62, 04, 'Deðer - 10lu Sistem');
      Pencere0.Tuval.YaziYaz(62, 50, 'Deðer - 16lý Sistem');
      Pencere0.Tuval.YaziYaz(62, 90, 'Deðer - 2li Sistem');

      Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
      if not(Hata) then
      begin

        Pencere0.Tuval.YaziYaz(100, 70, HexStr(Sayi, 8));
        Pencere0.Tuval.YaziYaz(10, 110, BinStr(Sayi, 32));
      end
      else
      begin

        Pencere0.Tuval.YaziYaz(130, 070, '-');
        Pencere0.Tuval.YaziYaz(130, 110, '-');
      end;
    end;

  until (1 = 2);
end.
