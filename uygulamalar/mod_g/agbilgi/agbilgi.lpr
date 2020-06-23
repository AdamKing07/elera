{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: agbilgi.lpr
  Program Ýþlevi: að yapýlandýrmasý hakkýnda bilgi verir

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
program agbilgi;

uses n_gorev, gn_pencere, gn_dugme, n_tuval, elera;

const
  ProgramAdi: string = 'Að Ayarlarý';

var
  Gorev: TGorev;
  Pencere: TPencere;
  dugYenile: TDugme;
  OlayKayit: TOlayKayit;
  AgBilgisi: TAgBilgisi;

begin

  Pencere.Olustur(-1, 300, 200, 330, 200, ptIletisim, ProgramAdi, $FAE6FF);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  dugYenile.Olustur(Pencere.Kimlik, 240, 170, 70, 20, 'Yenile');
  dugYenile.Goster;
  Pencere.Goster;

  AgBilgisiAl(@AgBilgisi);

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugYenile.Kimlik) then
      begin

        AgBilgisiAl(@AgBilgisi);
        Pencere.Ciz;
      end;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := RENK_SIYAH;
      Pencere.Tuval.YaziYaz(2, 02, 'MAC Adresi:');
      Pencere.Tuval.MACAdresiYaz(166, 02, @AgBilgisi.MACAdres);
      Pencere.Tuval.YaziYaz(2, 18, 'IP4 Adresi:');
      Pencere.Tuval.IPAdresiYaz(166, 18, @AgBilgisi.IP4Adres);
      Pencere.Tuval.YaziYaz(2, 34, 'IP4 Alt Að Maskesi:');
      Pencere.Tuval.IPAdresiYaz(166, 34, @AgBilgisi.AltAgMaskesi);
      Pencere.Tuval.YaziYaz(2, 50, 'Að Geçidi:');
      Pencere.Tuval.IPAdresiYaz(166, 50, @AgBilgisi.AgGecitAdresi);
      Pencere.Tuval.YaziYaz(2, 66, 'DHCP Sunucusu:');
      Pencere.Tuval.IPAdresiYaz(166, 66, @AgBilgisi.DHCPSunucusu);
      Pencere.Tuval.YaziYaz(2, 82, 'DNS Sunucusu:');
      Pencere.Tuval.IPAdresiYaz(166, 82, @AgBilgisi.DNSSunucusu);
      Pencere.Tuval.YaziYaz(2, 98, 'IP Kira Süresi:');
      Pencere.Tuval.SayiYaz10(166, 98, AgBilgisi.IPKiraSuresi);

      Pencere.Tuval.KalemRengi := RENK_KIRMIZI;
      Pencere.Tuval.YaziYaz(2, 130, 'DHCP sunucundan yeni IP adresi almak');
      Pencere.Tuval.YaziYaz(2, 146, 'için Ctrl+2 tuþuna basýnýz.');
    end;
  end;
end.
