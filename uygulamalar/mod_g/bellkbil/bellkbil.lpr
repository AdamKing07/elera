program bellkbil;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: bellkbil.lpr
  Program ��levi: bellek kullan�m� hakk�nda bilgi verir

  G�ncelleme Tarihi: 07/06/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_islemgostergesi, zamanlayici, elera;

const
  ProgramAdi: string = 'Bellek Kullan�m Bilgisi';
  CekirdekBaslangicAdresiK: string = '�ekirdek Ba�. Adresi  :';
  CekirdekBitisAdresiK: string = '�ekirdek Bit. Adresi  :';
  CekirdekUzunluguK: string = '�ekirdek Kod Uzunlu�u :';
  BlokBilgisi: string = 'Blok Bilgileri (1 Blok = 4K)';
  BlokBaslik1: string =  'Toplam  Ayr�lm��  Kullan�lan  Bo�';
  BlokBaslik2: string = '------  --------  ----------  ----';

var
  CekirdekBaslangicAdresi: TSayi4 = 0;
  CekirdekBitisAdresi: TSayi4 = 0;
  CekirdekUzunlugu: TSayi4 = 0;
  ToplamRAMBlok: TSayi4 = 0;
  AyrilmisRAMBlok: TSayi4 = 0;
  KullanilmisRAMBlok: TSayi4 = 0;
  BosRAMBlok: TSayi4 = 0;
  BlokUzunlugu: TSayi4 = 0;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  IslemGostergesi0: TIslemGostergesi;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;

begin

  Pencere0.Olustur(-1, 50, 50, 290, 172, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  IslemGostergesi0.Olustur(Pencere0.Kimlik, 0, 86, 280, 22);
  IslemGostergesi0.DegerleriBelirle(1, 8095);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  while True do
  begin

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 0 * 16, CekirdekBaslangicAdresiK);
      Pencere0.Tuval.SayiYaz16(24 * 8, 0 * 16, True, 8, CekirdekBaslangicAdresi);

      Pencere0.Tuval.YaziYaz(0, 1 * 16, CekirdekBitisAdresiK);
      Pencere0.Tuval.SayiYaz16(24 * 8, 1 * 16, True, 8, CekirdekBitisAdresi);

      Pencere0.Tuval.YaziYaz(0, 2 * 16, CekirdekUzunluguK);
      Pencere0.Tuval.SayiYaz16(24 * 8, 2 * 16, True, 8, CekirdekUzunlugu);

      Pencere0.Tuval.YaziYaz(0, 4 * 16, BlokBilgisi);
      Pencere0.Tuval.YaziYaz(0, 7 * 16, BlokBaslik1);
      Pencere0.Tuval.YaziYaz(0, 8 * 16, BlokBaslik2);

      Pencere0.Tuval.SayiYaz10(1 * 8, 9 * 16, ToplamRAMBlok);
      Pencere0.Tuval.SayiYaz10(10 * 8, 9 * 16, AyrilmisRAMBlok);
      Pencere0.Tuval.SayiYaz10(20 * 8, 9 * 16, KullanilmisRAMBlok);
      Pencere0.Tuval.SayiYaz10(30 * 8, 9 * 16, BosRAMBlok);

      IslemGostergesi0.KonumBelirle(KullanilmisRAMBlok);
    end
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      CekirdekBellekBilgisiAl(@CekirdekBaslangicAdresi, @CekirdekBitisAdresi,
        @CekirdekUzunlugu);
      GenelBellekBilgisiAl(@ToplamRAMBlok, @AyrilmisRAMBlok, @KullanilmisRAMBlok,
        @BosRAMBlok, @BlokUzunlugu);

      Pencere0.Ciz;
    end;
  end;
end.
