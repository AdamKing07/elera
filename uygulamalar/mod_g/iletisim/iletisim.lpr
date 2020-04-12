program iletisim;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: udptest.lpr
  Program ��levi: udp test program�

  G�ncelleme Tarihi: 26/10/2019

  // udptest program ad� baglanti olarak de�i�tirilecek

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_durumcubugu, gn_karmaliste,
  zamanlayici, n_iletisim, gn_defter;

const
  ProgramAdi: string = '�leti�im - TCP/UDP';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Defter0: TDefter;
  DurumCubugu0: TDurumCubugu;
  Zamanlayici0: TZamanlayici;
  gkMesaj: TGirisKutusu;
  klBaglanti: TKarmaListe;
  dugBaglan, dugGonder, dugBKes: TDugme;
  OlayKayit: TOlayKayit;
  Iletisim0: TIletisim;
  IPAdres: TIPAdres;
  s: string;
  VeriUzunlugu: Integer;
begin

  Pencere0.Olustur(-1, 50, 50, 444, 270, ptIletisim, ProgramAdi, $DAF7A6);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Tuval.KalemRengi := $000000;
  Pencere0.Tuval.YaziYaz(342, 10, 'Ba�lant�');

  klBaglanti.Olustur(Pencere0.Kimlik, 338, 30, 84, 22);
  klBaglanti.ElemanEkle('TCP');
  klBaglanti.ElemanEkle('UDP');

  Pencere0.Tuval.YaziYaz(10, 10, 'IP Adres: 193.1.1.11, Port: 365');

  dugBaglan.Olustur(Pencere0.Kimlik, 268, 6, 55, 22, 'Ba�lan');
  dugBaglan.Goster;

  Pencere0.Tuval.YaziYaz(10, 34, 'Mesaj:');

  gkMesaj.Olustur(Pencere0.Kimlik, 66, 30, 180, 22, 'Mesaj');
  gkMesaj.Goster;

  dugGonder.Olustur(Pencere0.Kimlik, 268, 30, 55, 22, 'G�nder');
  dugGonder.Goster;

  dugBKes.Olustur(Pencere0.Kimlik, 268, 54, 55, 22, 'B.Kes');
  dugBKes.Goster;

  Pencere0.Tuval.YaziYaz(10, 66, 'Haberle�me:');

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Ba�lant� yok!');
  DurumCubugu0.Goster;

  Defter0.Olustur(Pencere0.Kimlik, 10, 84, 410, 122, RENK_BEYAZ, RENK_SIYAH);
  //Defter0.Hizala(hzTum);
  Defter0.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  IPAdres[0] := 193;
  IPAdres[1] := 1;
  IPAdres[2] := 1;
  IPAdres[3] := 11;

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      if(Iletisim0.BagliMi) then
      begin

        DurumCubugu0.DurumYazisiDegistir('Ba�lant� kuruldu.');

        VeriUzunlugu := Iletisim0.VeriUzunluguAl;
        if(VeriUzunlugu > 0) then
        begin

          VeriUzunlugu := Iletisim0.VeriOku(@s[1]);
          SetLength(s, VeriUzunlugu);

          Defter0.YaziEkle('O: ' + s + #13#10);

          //Pencere0.Ciz;
        end;
      end else DurumCubugu0.DurumYazisiDegistir('Ba�lant� yok!');
    end
    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugBaglan.Kimlik) then
      begin

        s := klBaglanti.SeciliYaziAl;
        if(s = 'TCP') then
          Iletisim0.Baglan(ptTCP, IPAdres, 365)
        else Iletisim0.Baglan(ptUDP, IPAdres, 365)
      end
      else if(OlayKayit.Kimlik = dugBKes.Kimlik) then
      begin

        Iletisim0.BaglantiyiKes;
        Defter0.Temizle;
        Pencere0.Ciz;
      end
      else if(OlayKayit.Kimlik = dugGonder.Kimlik) then
      begin

        s := gkMesaj.IcerikAl + #13#10;
        Iletisim0.VeriYaz(@s[1], Length(s));

        Defter0.YaziEkle('Ben: ' + s);

        gkMesaj.IcerikYaz('');
      end;
    end
    else if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      if(OlayKayit.Deger1 = 10) then
      begin

        s := gkMesaj.IcerikAl + #13#10;;
        Iletisim0.VeriYaz(@s[1], Length(s));

        Defter0.YaziEkle('Ben: ' + s);

        gkMesaj.IcerikYaz('');
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := $000000;
      Pencere0.Tuval.YaziYaz(342, 10, 'Ba�lant�');
      Pencere0.Tuval.YaziYaz(10, 10, 'IP Adres: 193.1.1.11, Port: 365');
      Pencere0.Tuval.YaziYaz(10, 34, 'Mesaj:');

      Pencere0.Tuval.YaziYaz(10, 66, 'Haberle�me:');
    end;

  until (1 = 2);

  //Iletisim0.Close;
end.
