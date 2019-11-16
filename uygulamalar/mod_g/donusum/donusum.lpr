program donusum;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: donusum.lpr
  Program ��levi: say�sal de�er �evrim / d�n���m program�

  G�ncelleme Tarihi: 25/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_etiket, gn_durumcubugu;

const
  ProgramAdi: string = 'Say�sal De�er �evrimi';

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
      Pencere0.Tuval.YaziYaz(62, 04, 'De�er - 10lu Sistem');
      Pencere0.Tuval.YaziYaz(62, 50, 'De�er - 16l� Sistem');
      Pencere0.Tuval.YaziYaz(62, 90, 'De�er - 2li Sistem');

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
