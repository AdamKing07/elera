{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: agbilgi.lpr
  Program Ýþlevi: að yapýlandýrmasý hakkýnda bilgi verir

  Güncelleme Tarihi: 07/06/2020

 ==============================================================================}
{$mode objfpc}
program agbilgi;

uses gorev, gn_pencere, gn_dugme, tuval, elera;

const
  ProgramAdi: string = 'Að Ayarlarý';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  dugYenile: TDugme;
  OlayKayit: TOlayKayit;
  AgBilgisi: TAgBilgisi;

begin

  Pencere0.Olustur(-1, 300, 200, 330, 200, ptIletisim, ProgramAdi, $FAE6FF);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  dugYenile.Olustur(Pencere0.Kimlik, 240, 170, 70, 20, 'Yenile');
  dugYenile.Goster;
  Pencere0.Goster;

  AgBilgisiAl(@AgBilgisi);

  while True do
  begin

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugYenile.Kimlik) then
      begin

        AgBilgisiAl(@AgBilgisi);
        Pencere0.Ciz;
      end;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(2, 02, 'MAC Adresi:');
      Pencere0.Tuval.MACAdresiYaz(166, 02, @AgBilgisi.MACAdres);
      Pencere0.Tuval.YaziYaz(2, 18, 'IP4 Adresi:');
      Pencere0.Tuval.IPAdresiYaz(166, 18, @AgBilgisi.IP4Adres);
      Pencere0.Tuval.YaziYaz(2, 34, 'IP4 Alt Að Maskesi:');
      Pencere0.Tuval.IPAdresiYaz(166, 34, @AgBilgisi.AltAgMaskesi);
      Pencere0.Tuval.YaziYaz(2, 50, 'Að Geçidi:');
      Pencere0.Tuval.IPAdresiYaz(166, 50, @AgBilgisi.AgGecitAdresi);
      Pencere0.Tuval.YaziYaz(2, 66, 'DHCP Sunucusu:');
      Pencere0.Tuval.IPAdresiYaz(166, 66, @AgBilgisi.DHCPSunucusu);
      Pencere0.Tuval.YaziYaz(2, 82, 'DNS Sunucusu:');
      Pencere0.Tuval.IPAdresiYaz(166, 82, @AgBilgisi.DNSSunucusu);
      Pencere0.Tuval.YaziYaz(2, 98, 'IP Kira Süresi:');
      Pencere0.Tuval.SayiYaz10(166, 98, AgBilgisi.IPKiraSuresi);

      Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
      Pencere0.Tuval.YaziYaz(2, 130, 'DHCP sunucundan yeni IP adresi almak');
      Pencere0.Tuval.YaziYaz(2, 146, 'için Ctrl+2 tuþuna basýnýz.');
    end;
  end;
end.
