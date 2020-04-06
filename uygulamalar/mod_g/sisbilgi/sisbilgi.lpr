program sisbilgi;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: sisbilgi.lpr
  Program Ýþlevi: sistem hakkýnda bilgi verir

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme;

const
  ProgramAdi: string = 'Sistem Bilgisi';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  dugSistem, dugIslemci, dugKapat: TDugme;
  OlayKayit: TOlayKayit;
  SistemBilgisi0: TSistemBilgisi;
  IslemciBilgisi0: TIslemciBilgisi;
  BolumSiraNo: TSayi4;

procedure SayfayiYenile;
begin

  if(BolumSiraNo = 0) then
  begin

    Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
    Pencere0.Tuval.YaziYaz(16, 96, 'Lütfen bir seçenek seçiniz');
  end
  else if(BolumSiraNo = 1) then
  begin

    Pencere0.Tuval.KalemRengi := RENK_BORDO;
    Pencere0.Tuval.YaziYaz(8, 48, 'Sistem: ' + SistemBilgisi0.SistemAdi);
    Pencere0.Tuval.YaziYaz(8, 64, 'Mimari: ' + SistemBilgisi0.FPCMimari);
    Pencere0.Tuval.YaziYaz(8, 80, 'FPC Sürüm: ' + SistemBilgisi0.FPCSurum);
    Pencere0.Tuval.YaziYaz(8, 96, 'Derleme Tarihi: ' + SistemBilgisi0.DerlemeBilgisi);

    Pencere0.Tuval.YaziYaz(8, 128,  'Yatay Çözünürlük:');
    Pencere0.Tuval.SayiYaz16(8 + (18 * 8), 128, True, 4, SistemBilgisi0.YatayCozunurluk);
    Pencere0.Tuval.YaziYaz(8, 144, 'Dikey Çözünürlük:');
    Pencere0.Tuval.SayiYaz16(8 + (18 * 8), 144, True, 4, SistemBilgisi0.DikeyCozunurluk);
  end
  else if(BolumSiraNo = 2) then
  begin

    Pencere0.Tuval.KalemRengi := RENK_MOR;
    Pencere0.Tuval.YaziYaz(8, 48, 'Ýþlemci: ' + IslemciBilgisi0.Satici);

    Pencere0.Tuval.YaziYaz(8, 80, 'CPUID = 1 [EAX]:');
    Pencere0.Tuval.SayiYaz16(8 + (18 * 8), 80, True, 8, IslemciBilgisi0.Ozellik1_EAX);
    Pencere0.Tuval.YaziYaz(8, 96, 'CPUID = 1 [EDX]:');
    Pencere0.Tuval.SayiYaz16(8 + (18 * 8), 96, True, 8, IslemciBilgisi0.Ozellik1_EDX);
    Pencere0.Tuval.YaziYaz(8, 112, 'CPUID = 1 [ECX]:');
    Pencere0.Tuval.SayiYaz16(8 + (18 * 8), 112, True, 8, IslemciBilgisi0.Ozellik1_ECX);
  end;
end;

begin

  Pencere0.Olustur(-1, 100, 100, 375, 240, ptIletisim, ProgramAdi, $F0CDE5);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  dugSistem.Olustur(Pencere0.Kimlik, 25, 5, 150, 22, 'Sistem Bilgisi');
  dugSistem.Goster;

  dugIslemci.Olustur(Pencere0.Kimlik, 180, 5, 150, 22, 'Ýþlemci Bilgisi');
  dugIslemci.Goster;

  dugKapat.Olustur(Pencere0.Kimlik, 280, 180, 80, 22, '  Kapat');
  dugKapat.Goster;

  Pencere0.Goster;

  Gorev0.SistemBilgisiAl(@SistemBilgisi0);
  Gorev0.IslemciBilgisiAl(@IslemciBilgisi0);

  BolumSiraNo := 0;

  SayfayiYenile;

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugSistem.Kimlik) then
      begin

        BolumSiraNo := 1;
        Pencere0.Ciz;
      end
      else if(OlayKayit.Kimlik = dugIslemci.Kimlik) then
      begin

        BolumSiraNo := 2;
        Pencere0.Ciz;
      end
      else if(OlayKayit.Kimlik = dugKapat.Kimlik) then
      begin

        Gorev0.Sonlandir(-1);
      end;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      SayfayiYenile;
    end;

  until (1 = 2);
end.
