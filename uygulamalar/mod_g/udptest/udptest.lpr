program udptest;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: udptest.lpr
  Program Ýþlevi: udp test programý

  Güncelleme Tarihi: 26/10/2019

  // udptest program adý baglanti olarak deðiþtirilecek

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_durumcubugu, gn_karmaliste,
  zamanlayici, baglanti;

const
  ProgramAdi: string = 'UDP Test';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  DurumCubugu0: TDurumCubugu;
  Zamanlayici0: TZamanlayici;
  gkMesaj: TGirisKutusu;
  klBaglanti: TKarmaListe;
  dugBaglan, dugGonder: TDugme;
  OlayKayit: TOlayKayit;
  Baglanti0: TBaglanti;
  IPAdres: TIPAdres;
  SonGelenMesaj, s: string;
  VeriUzunlugu: Integer;
begin

  SonGelenMesaj := '';

  Pencere0.Olustur(-1, 100, 100, 450, 150, ptIletisim, ProgramAdi, $DAF7A6);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Tuval.KalemRengi := $000000;
  Pencere0.Tuval.YaziYaz(342, 10, 'Baðlantý');

  klBaglanti.Olustur(Pencere0.Kimlik, 338, 30, 84, 22);
  klBaglanti.ElemanEkle('TCP');
  klBaglanti.ElemanEkle('UDP');

  Pencere0.Tuval.YaziYaz(10, 10, 'IP Adres: 193.1.1.11, Port: 365');

  dugBaglan.Olustur(Pencere0.Kimlik, 268, 6, 55, 22, 'Baðlan');
  dugBaglan.Goster;

  Pencere0.Tuval.YaziYaz(10, 34, 'Mesaj:');

  gkMesaj.Olustur(Pencere0.Kimlik, 66, 30, 180, 22, 'UDP Mesaj');
  gkMesaj.Goster;

  dugGonder.Olustur(Pencere0.Kimlik, 268, 30, 55, 22, 'Gönder');
  dugGonder.Goster;

  Pencere0.Tuval.YaziYaz(10, 60, 'Son Gelen Mesaj:');
  Pencere0.Tuval.KalemRengi := $FF0000;
  Pencere0.Tuval.YaziYaz(10, 80, SonGelenMesaj);

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Baðlantý yok.');
  DurumCubugu0.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  IPAdres[0] := 193;
  IPAdres[1] := 1;
  IPAdres[2] := 1;
  IPAdres[3] := 11;
  Baglanti0.Olustur(ptUdp, IPAdres, 365);
  if(Baglanti0.Baglanti <> -1) then Baglanti0.Baglan;

  if(Baglanti0.BagliMi) then DurumCubugu0.DurumYazisiDegistir('Baðlantý mevcut.');

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      if(Baglanti0.BagliMi) then
      begin

        VeriUzunlugu := Baglanti0.VeriUzunluguAl;
        if(VeriUzunlugu > 0) then
        begin

          VeriUzunlugu := Baglanti0.VeriOku(@SonGelenMesaj[1]);
          SetLength(SonGelenMesaj, VeriUzunlugu);

          Pencere0.Ciz;
        end;
      end;
    end
    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugBaglan.Kimlik) then
      begin

        s := klBaglanti.SeciliYaziAl;
        SonGelenMesaj := s;
        Pencere0.Ciz;
      end
      else if(OlayKayit.Kimlik = dugGonder.Kimlik) then
      begin

        s := gkMesaj.IcerikAl;
        Baglanti0.VeriYaz(@s[1], Length(s));
        gkMesaj.IcerikYaz('');
      end;
    end
    else if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      if(OlayKayit.Deger1 = 10) then
      begin

        s := gkMesaj.IcerikAl;
        Baglanti0.VeriYaz(@s[1], Length(s));
        gkMesaj.IcerikYaz('');
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := $000000;
      Pencere0.Tuval.YaziYaz(342, 10, 'Baðlantý');
      Pencere0.Tuval.YaziYaz(10, 10, 'IP Adres: 193.1.1.11, Port: 365');
      Pencere0.Tuval.YaziYaz(10, 34, 'Mesaj:');

      Pencere0.Tuval.YaziYaz(10, 60, 'Son Gelen Mesaj:');
      Pencere0.Tuval.KalemRengi := $FF0000;
      Pencere0.Tuval.YaziYaz(10, 80, SonGelenMesaj);
    end;

  until (1 = 2);

  //Baglanti0.Close;
end.
