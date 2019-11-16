{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: arpbilgi.lpr
  Program Ýþlevi: ARP girdileri hakkýnda bilgi verir

  Güncelleme Tarihi: 25/10/2019

 ==============================================================================}
{$mode objfpc}
program arpbilgi;

uses gorev, gn_pencere, zamanlayici, elera;

const
  ProgramAdi: string = 'ARP Girdi Bilgisi';
  ARPGirdiSayisi: string  = 'Toplam ARP Girdi Sayýsý: ';
  Baslik1: string   = 'IP Adresi       MAC Adresi        Sayaç ';
  Baslik2: string  = '--------------- ----------------- ------';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  ARPKayit: TARPKayit;
  ARPKayitSayisi, i, j: TSayi4;

begin

  Pencere0.Olustur(-1, 50, 50, 340, 280, ptIletisim, ProgramAdi, $D8DFB4);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  ARPKayitSayisi := 0;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      ARPKayitSayisi := ARPKayitSayisiAl;
      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := $39525E;
      Pencere0.Tuval.YaziYaz(0, 0 * 16, ARPGirdiSayisi);
      Pencere0.Tuval.SayiYaz16(25 * 8, 0 * 16, True, 2, ARPKayitSayisi);

      Pencere0.Tuval.YaziYaz(0, 2 * 16, Baslik1);
      Pencere0.Tuval.YaziYaz(0, 3 * 16, Baslik2);

      if(ARPKayitSayisi > 0) then
      begin

        for i := 0 to ARPKayitSayisi - 1 do
        begin

          j := ARPKayitBilgisiAl(i, ARPKayit);
          if(j = 0) then
          begin

            Pencere0.Tuval.IPAdresiYaz(0, (i + 1 + 3) * 16, @ARPKayit.IPAdres);
            Pencere0.Tuval.MACAdresiYaz(16 * 8, (i + 1 + 3) * 16, @ARPKayit.MACAdres);
            Pencere0.Tuval.SayiYaz16(34 * 8, (i + 1 + 3) * 16, True, 4,  ARPKayit.YasamSuresi);
          end;
        end;
      end;
    end;

  until (1 = 2);
end.
