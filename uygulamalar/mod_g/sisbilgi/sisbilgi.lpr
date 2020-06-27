program sisbilgi;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: sisbilgi.lpr
  Program Ýþlevi: sistem hakkýnda bilgi verir

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, gn_dugme;

const
  ProgramAdi: string = 'Sistem Bilgisi';

var
  Gorev: TGorev;
  Pencere: TPencere;
  dugSistem, dugIslemci, dugKapat: TDugme;
  OlayKayit: TOlayKayit;
  SistemBilgisi: TSistemBilgisi;
  IslemciBilgisi: TIslemciBilgisi;
  BolumSiraNo: TSayi4;

procedure SayfayiYenile;
begin

  if(BolumSiraNo = 0) then
  begin

    Pencere.Tuval.KalemRengi := RENK_KIRMIZI;
    Pencere.Tuval.YaziYaz(16, 96, 'Lütfen bir seçenek seçiniz');
  end
  else if(BolumSiraNo = 1) then
  begin

    Pencere.Tuval.KalemRengi := RENK_BORDO;
    Pencere.Tuval.YaziYaz(8, 48, 'Sistem: ' + SistemBilgisi.SistemAdi);
    Pencere.Tuval.YaziYaz(8, 64, 'Mimari: ' + SistemBilgisi.FPCMimari);
    Pencere.Tuval.YaziYaz(8, 80, 'FPC Sürüm: ' + SistemBilgisi.FPCSurum);
    Pencere.Tuval.YaziYaz(8, 96, 'Derleme Tarihi: ' + SistemBilgisi.DerlemeBilgisi);

    Pencere.Tuval.YaziYaz(8, 128,  'Yatay Çözünürlük:');
    Pencere.Tuval.SayiYaz16(8 + (18 * 8), 128, True, 4, SistemBilgisi.YatayCozunurluk);
    Pencere.Tuval.YaziYaz(8, 144, 'Dikey Çözünürlük:');
    Pencere.Tuval.SayiYaz16(8 + (18 * 8), 144, True, 4, SistemBilgisi.DikeyCozunurluk);
  end
  else if(BolumSiraNo = 2) then
  begin

    Pencere.Tuval.KalemRengi := RENK_MOR;
    Pencere.Tuval.YaziYaz(8, 48, 'Ýþlemci: ' + IslemciBilgisi.Satici);

    Pencere.Tuval.YaziYaz(8, 80, 'CPUID = 1 [EAX]:');
    Pencere.Tuval.SayiYaz16(8 + (18 * 8), 80, True, 8, IslemciBilgisi.Ozellik1_EAX);
    Pencere.Tuval.YaziYaz(8, 96, 'CPUID = 1 [EDX]:');
    Pencere.Tuval.SayiYaz16(8 + (18 * 8), 96, True, 8, IslemciBilgisi.Ozellik1_EDX);
    Pencere.Tuval.YaziYaz(8, 112, 'CPUID = 1 [ECX]:');
    Pencere.Tuval.SayiYaz16(8 + (18 * 8), 112, True, 8, IslemciBilgisi.Ozellik1_ECX);
  end;
end;

begin

  Pencere.Olustur(-1, 100, 100, 375, 220, ptIletisim, ProgramAdi, $FEF5E7);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  dugSistem.Olustur(Pencere.Kimlik, 25, 5, 150, 22, 'Sistem Bilgisi');
  dugSistem.Goster;

  dugIslemci.Olustur(Pencere.Kimlik, 180, 5, 150, 22, 'Ýþlemci Bilgisi');
  dugIslemci.Goster;

  dugKapat.Olustur(Pencere.Kimlik, 300, 180, 60, 22, 'Kapat');
  dugKapat.Goster;

  Pencere.Goster;

  Gorev.SistemBilgisiAl(@SistemBilgisi);
  Gorev.IslemciBilgisiAl(@IslemciBilgisi);

  BolumSiraNo := 0;

  SayfayiYenile;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugSistem.Kimlik) then
      begin

        BolumSiraNo := 1;
        Pencere.Ciz;
      end
      else if(OlayKayit.Kimlik = dugIslemci.Kimlik) then
      begin

        BolumSiraNo := 2;
        Pencere.Ciz;
      end
      else if(OlayKayit.Kimlik = dugKapat.Kimlik) then
      begin

        Gorev.Sonlandir(-1);
      end;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      SayfayiYenile;
    end;
  end;
end.
