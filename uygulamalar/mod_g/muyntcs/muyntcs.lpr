program muyntcs;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: muyntcs.lpr
  Program ��levi: �oklu masa�st� y�netim program�

  G�ncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, ekran, gn_masaustu, gn_pencere, zamanlayici, gn_dugme, gn_gucdugme,
  gn_menu, gn_etiket, gn_resimdugme, gn_acilirmenu;

const
  PROGRAM_SAYISI = 10;

const
  ProgramAdi: string = 'Masa�st� Y�neticisi';

  Programlar: array[0..PROGRAM_SAYISI - 1] of string = (
    ('bellkbil.c'),
    ('dskgor.c'),
    ('dsyyntcs.c'),
    ('defter.c'),
    ('saat.c'),
    ('iskelet.c'),
    ('grvyntcs.c'),
    ('pcibil.c'),
    ('yzmcgor.c'),
    ('smsjgor.c'));

  ProgramAciklamalari: array[0..PROGRAM_SAYISI - 1] of string = (
    ('Bellek Kullan�m Bilgisi'),
    ('Disk ��erik G�r�nt�leyisi'),
    ('Dosya Y�neticisi'),
    ('Dijital Defter'),
    ('Dijital Saat'),
    ('Ana �skelet Program�'),
    ('G�rev Y�neticisi'),
    ('PCI Ayg�t Bilgisi'),
    ('Program Yazma� Bilgileri'),
    ('Sistem Mesaj G�r�nt�leyicisi'));

  MasaustuMenuProgramAdi: array[0..4] of string = (
      ('mustudk.c'),
      ('haklar.txt'),
      ('nesnegor.c'),
      ('grafik3.c'),
      ('sisbilgi.c'));

var
  Gorev0: TGorev;
  Ekran0: TEkran;
  Masaustu0: TMasaustu;
  Pencere0: TPencere;
  menBaslat: TMenu;
  amenMasaustu: TAcilirMenu;
  gdELERA: TGucDugme;
  dugDosyaYoneticisi, dugMesajGoruntuleyici,
  dugGorevYoneticisi: TDugme; //TResimDugme;
  dugMasaustuDugmeleri: array[0..3] of TDugme;
  etiSaat, etiTarih, etiAgBilgi: TEtiket;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  i, A1: TSayi4;
  s: string;
  Saat: array[0..2] of TSayi1;      // saat / dakika / saniye
  Tarih: array[0..3] of TSayi2;     // g�n / ay / y�l / haftan�n g�n�

begin

  // ekran ��z�n�rl���n� al
  Ekran0.CozunurlukAl;

  // olu�turulan masa�st� say�s�n� al
  if(Masaustu0.MevcutMasaustuSayisi >= 4) then Gorev0.Sonlandir(-1);

  // yeni masa�st� olu�tur
  Masaustu0.Olustur(ProgramAdi);

  // yeni masa�st�n�n duvar ka��d�
  Masaustu0.MasaustuResminiDegistir('disk1:\1.bmp');

  // g�rev y�netim ana paneli
  Pencere0.Olustur(Masaustu0.Kimlik, Ekran0.A0, Ekran0.Yukseklik0 - 40, Ekran0.Genislik0,
    40, ptBasliksiz, '', $FFFFFF);

  // ELERA ana d��mesini olu�tur
  gdELERA.Olustur(Pencere0.Kimlik, 6, 5, 60, 22, 'ELERA');
  gdELERA.Goster;

  // 4 adet masa�st� d��mesi olu�tur
  A1 := 75;
  dugMasaustuDugmeleri[0].Olustur(Pencere0.Kimlik, A1, 5, 20, 22, '1');
  dugMasaustuDugmeleri[0].Goster;

  A1 += 22;
  dugMasaustuDugmeleri[1].Olustur(Pencere0.Kimlik, A1, 5, 20, 22, '2');
  dugMasaustuDugmeleri[1].Goster;

  A1 += 22;
  dugMasaustuDugmeleri[2].Olustur(Pencere0.Kimlik, A1, 5, 20, 22, '3');
  dugMasaustuDugmeleri[2].Goster;

  A1 += 22;
  dugMasaustuDugmeleri[3].Olustur(Pencere0.Kimlik, A1, 5, 20, 22, '4');
  dugMasaustuDugmeleri[3].Goster;

  // dosya y�neticisi program� i�in d��me
  A1 += 22+6;
  dugDosyaYoneticisi.Olustur(Pencere0.Kimlik, A1, 5, 24, 22, 'DY');
  dugDosyaYoneticisi.Goster;

  // g�rev y�neticisi program� i�in d��me
  A1 += 26;
  dugGorevYoneticisi.Olustur(Pencere0.Kimlik, A1, 5, 24, 22, 'GY');
  dugGorevYoneticisi.Goster;

  // sistem mesaj g�r�nt�leyici program� i�in d��me
  A1 += 26;
  dugMesajGoruntuleyici.Olustur(Pencere0.Kimlik, A1, 5, 32, 22, 'MSJ');
  dugMesajGoruntuleyici.Goster;

  // a��klama haline getirilen a�a��daki kodlar TResimDugme'nin �effaf �zelli�i
  // (transparent) sonras�nda aktifle�tirilecek
  {dugDosyaYoneticisi.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 1);
  dugDosyaYoneticisi.Goster;

  // g�rev y�neticisi program� i�in d��me
  A1 += 26;
  dugGorevYoneticisi.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 9);
  dugGorevYoneticisi.Goster;

  // sistem mesaj g�r�nt�leyici program� i�in d��me
  A1 += 26;
  dugMesajGoruntuleyici.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 4);
  dugMesajGoruntuleyici.Goster;}

  etiSaat.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 100, 1, $800000, '00:00:00');
  etiSaat.Goster;

  etiTarih.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 118, 18, $800000, '00.00.0000 Aa');
  etiTarih.Goster;

  etiAgBilgi.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 160, 9, $FF0000, '[A�]');
  etiAgBilgi.Goster;

  // paneli (pencere) g�r�nt�le
  Pencere0.Goster;

  // masa�st�n� g�r�nt�le
  Masaustu0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  // masa�st� i�in ELERA d��mesine ba�l� men� olu�tur
  menBaslat.Olustur(0, Ekran0.Yukseklik0 - 40 - ((PROGRAM_SAYISI * 26) + 8),
    300, (PROGRAM_SAYISI * 26) + 8, 26);

  // programlar� listeye ekle
  for i := 0 to PROGRAM_SAYISI - 1 do
  begin

    case i of
      0: menBaslat.ElemanEkle(ProgramAciklamalari[i], 05);
      1: menBaslat.ElemanEkle(ProgramAciklamalari[i], 06);
      2: menBaslat.ElemanEkle(ProgramAciklamalari[i], 01);
      3: menBaslat.ElemanEkle(ProgramAciklamalari[i], 07);
      4: menBaslat.ElemanEkle(ProgramAciklamalari[i], 08);
      5: menBaslat.ElemanEkle(ProgramAciklamalari[i], 14);
      6: menBaslat.ElemanEkle(ProgramAciklamalari[i], 09);
      7: menBaslat.ElemanEkle(ProgramAciklamalari[i], 10);
      8: menBaslat.ElemanEkle(ProgramAciklamalari[i], 15);
      9: menBaslat.ElemanEkle(ProgramAciklamalari[i], 04);
    end;
  end;

  amenMasaustu.Olustur($2C3E50, RENK_BEYAZ, $7FB3D5, RENK_SIYAH, RENK_BEYAZ);
  amenMasaustu.ElemanEkle('Duvar Ka��d�n� De�i�tir', 12);
  amenMasaustu.ElemanEkle('Telif Hakk� Dosyas�n� G�r�nt�le', 12);
  amenMasaustu.ElemanEkle('Nesne G�r�nt�leyicisi', 12);
  amenMasaustu.ElemanEkle('Ekran Koruyucuyu', 12);
  amenMasaustu.ElemanEkle('Sistem Bilgisi', 12);

  // ve ana d�ng�
  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      // ba�lat men�s�ne t�kland���nda
      if(OlayKayit.Kimlik = menBaslat.Kimlik) then
      begin

        gdELERA.DurumYaz(0);
        i := menBaslat.SeciliSiraNoAl;
        Gorev0.Calistir(Programlar[i]);
      end
      // masa�st� men�s�ne t�kland���nda
      else if(OlayKayit.Kimlik = amenMasaustu.Kimlik) then
      begin

        i := amenMasaustu.SeciliSiraNoAl;
        Gorev0.Calistir(MasaustuMenuProgramAdi[i]);
      end

      else if(OlayKayit.Kimlik = dugDosyaYoneticisi.Kimlik) then
      begin

        Gorev0.Calistir('dsyyntcs.c');
      end

      else if(OlayKayit.Kimlik = dugGorevYoneticisi.Kimlik) then
      begin

        Gorev0.Calistir('grvyntcs.c');
      end

      else if(OlayKayit.Kimlik = dugMesajGoruntuleyici.Kimlik) then
      begin

        Gorev0.Calistir('smsjgor.c');
      end

      else if(OlayKayit.Kimlik = etiSaat.Kimlik) or (OlayKayit.Kimlik = etiTarih.Kimlik) then
      begin

        Gorev0.Calistir('saat.c');
      end

      else if(OlayKayit.Kimlik = etiAgBilgi.Kimlik) then
      begin

        Gorev0.Calistir('agbilgi.c');
      end

      else if(OlayKayit.Kimlik = dugMasaustuDugmeleri[0].Kimlik) then
      begin

        Masaustu0.Aktiflestir(1);
      end

      else if(OlayKayit.Kimlik = dugMasaustuDugmeleri[1].Kimlik) then
      begin

        Masaustu0.Aktiflestir(2);
      end

      else if(OlayKayit.Kimlik = dugMasaustuDugmeleri[2].Kimlik) then
      begin

        Masaustu0.Aktiflestir(3);
      end

      else if(OlayKayit.Kimlik = dugMasaustuDugmeleri[3].Kimlik) then
      begin

        Masaustu0.Aktiflestir(4);
      end
    end
    // masa�st�ne sa� tu� bas�l�p b�rak�ld���nda
    else if(OlayKayit.Olay = FO_SAGTUS_BIRAKILDI) then
    begin

      if(OlayKayit.Kimlik = Masaustu0.Kimlik) then amenMasaustu.Goster;
    end

    // ba�lat men�s�
    else if(OlayKayit.Olay = CO_DURUMDEGISTI) then
    begin

      if(OlayKayit.Kimlik = gdELERA.Kimlik) then
        if(OlayKayit.Deger1 = 1) then
          menBaslat.Goster
        else if(OlayKayit.Deger1 = 0) then
          menBaslat.Gizle;
    end
    // saat de�erini g�ncelle�tir
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      GetTime(@Saat);
      s := TimeToStr(Saat);
      etiSaat.Degistir(s);

      GetDate(@Tarih);
      s := DateToStr(Tarih, True);
      etiTarih.Degistir(s);
    end;

  until (1 = 2);
end.
