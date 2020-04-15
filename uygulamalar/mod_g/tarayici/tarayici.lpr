program tarayici;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: tarayici.lpr
  Program Ýþlevi: internet tarayýcý programý

  Güncelleme Tarihi: 15/04/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_durumcubugu, gn_karmaliste,
  zamanlayici, n_iletisim, gn_defter, gn_etiket;

const
  ProgramAdi: string = 'Ýnternet Tarayýcý';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Defter0: TDefter;
  DurumCubugu0: TDurumCubugu;
  etAdres: TEtiket;
  gkAdres: TGirisKutusu;
  Zamanlayici0: TZamanlayici;
  dugBaglan, dugGonder, dugBKes: TDugme;
  OlayKayit: TOlayKayit;
  Iletisim0: TIletisim;
  IPAdres, s: string;
  VeriUzunlugu: Integer;
begin

  IPAdres := '193.1.1.1';

  Pencere0.Olustur(-1, 50, 50, 456, 274, ptIletisim, ProgramAdi, $F8F9F9);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  etAdres.Olustur(Pencere0.Kimlik, 10, 10, RENK_SIYAH, 'Adres');
  etAdres.Goster;

  gkAdres.Olustur(Pencere0.Kimlik, 55, 6, 200, 22, IPAdres);
  gkAdres.Goster;

  dugBaglan.Olustur(Pencere0.Kimlik, 268, 6, 55, 22, 'Baðlan');
  dugBaglan.Goster;

  dugGonder.Olustur(Pencere0.Kimlik, 325, 6, 55, 22, 'Gönder');
  dugGonder.Goster;

  dugBKes.Olustur(Pencere0.Kimlik, 382, 6, 55, 22, 'B.Kes');
  dugBKes.Goster;

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Baðlantý yok!');
  DurumCubugu0.Goster;

  Defter0.Olustur(Pencere0.Kimlik, 10, 34, 428, 178, RENK_BEYAZ, RENK_SIYAH);
  //Defter0.Hizala(hzTum);
  Defter0.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      if(Iletisim0.BagliMi) then
      begin

        DurumCubugu0.DurumYazisiDegistir('Baðlantý kuruldu.');

        VeriUzunlugu := Iletisim0.VeriUzunluguAl;
        if(VeriUzunlugu > 0) then
        begin

          VeriUzunlugu := Iletisim0.VeriOku(@s[1]);
          SetLength(s, VeriUzunlugu);

          Defter0.YaziEkle(s + #13#10);

          //Pencere0.Ciz;
        end;
      end else DurumCubugu0.DurumYazisiDegistir('Baðlantý yok!');
    end
    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugBaglan.Kimlik) then
      begin

        Iletisim0.Baglan(ptTCP, IPAdres, 80)
      end
      else if(OlayKayit.Kimlik = dugGonder.Kimlik) then
      begin

        IPAdres := gkAdres.IcerikAl;

        s := 'GET / HTTP/1.1' + #13#10;
        s += 'Host: ' + IPAdres + #13#10#13#10;

        Iletisim0.VeriYaz(@s[1], Length(s));
      end
      else if(OlayKayit.Kimlik = dugBKes.Kimlik) then
      begin

        Iletisim0.BaglantiyiKes;
        Defter0.Temizle;
        Pencere0.Ciz;
      end;
    end;

  until (1 = 2);

  //Iletisim0.Close;
end.
