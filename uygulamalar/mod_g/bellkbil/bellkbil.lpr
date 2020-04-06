program bellkbil;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: bellkbil.lpr
  Program Ýþlevi: bellek kullanýmý hakkýnda bilgi verir

  Güncelleme Tarihi: 25/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_islemgostergesi, zamanlayici, elera;

const
  ProgramAdi: string = 'Bellek Kullaným Bilgisi';
  CekirdekBaslangicAdresi: string = 'Çekirdek Baþ. Adresi  :';
  CekirdekBitisAdresi: string = 'Çekirdek Bit. Adresi  :';
  CekirdekUzunlugu: string = 'Çekirdek Kod Uzunluðu :';
  BlokBilgisi: string = 'Blok Bilgileri (1 Blok = 4K)';
  BlokBaslik1: string =  'Toplam  Ayrýlmýþ  Kullanýlan  Boþ';
  BlokBaslik2: string = '------  --------  ----------  ----';

var
  _CekirdekBaslangicAdresi: TSayi4 = 0;
  _CekirdekBitisAdresi: TSayi4 = 0;
  _CekirdekUzunlugu: TSayi4 = 0;
  _ToplamRAMBlok: TSayi4 = 0;
  _AyrilmisRAMBlok: TSayi4 = 0;
  _KullanilmisRAMBlok: TSayi4 = 0;
  _BosRAMBlok: TSayi4 = 0;
  _BlokUzunlugu: TSayi4 = 0;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  IslemGostergesi0: TIslemGostergesi;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;

begin

  Pencere0.Olustur(-1, 50, 50, 290, 200, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  IslemGostergesi0.Olustur(Pencere0.Kimlik, 0, 86, 280, 22);
  IslemGostergesi0.DegerleriBelirle(1, 8095);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 0 * 16, CekirdekBaslangicAdresi);
      Pencere0.Tuval.SayiYaz16(24 * 8, 0 * 16, True, 8, _CekirdekBaslangicAdresi);

      Pencere0.Tuval.YaziYaz(0, 1 * 16, CekirdekBitisAdresi);
      Pencere0.Tuval.SayiYaz16(24 * 8, 1 * 16, True, 8, _CekirdekBitisAdresi);

      Pencere0.Tuval.YaziYaz(0, 2 * 16, CekirdekUzunlugu);
      Pencere0.Tuval.SayiYaz16(24 * 8, 2 * 16, True, 8, _CekirdekUzunlugu);

      Pencere0.Tuval.YaziYaz(0, 4 * 16, BlokBilgisi);
      Pencere0.Tuval.YaziYaz(0, 7 * 16, BlokBaslik1);
      Pencere0.Tuval.YaziYaz(0, 8 * 16, BlokBaslik2);

      Pencere0.Tuval.SayiYaz10(1 * 8, 9 * 16, _ToplamRAMBlok);
      Pencere0.Tuval.SayiYaz10(10 * 8, 9 * 16, _AyrilmisRAMBlok);
      Pencere0.Tuval.SayiYaz10(20 * 8, 9 * 16, _KullanilmisRAMBlok);
      Pencere0.Tuval.SayiYaz10(30 * 8, 9 * 16, _BosRAMBlok);

      IslemGostergesi0.KonumBelirle(_KullanilmisRAMBlok);
    end
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      CekirdekBellekBilgisiAl(@_CekirdekBaslangicAdresi, @_CekirdekBitisAdresi,
        @_CekirdekUzunlugu);
      GenelBellekBilgisiAl(@_ToplamRAMBlok, @_AyrilmisRAMBlok, @_KullanilmisRAMBlok,
        @_BosRAMBlok, @_BlokUzunlugu);

      Pencere0.Ciz;
    end;

  until (1 = 2);
end.
