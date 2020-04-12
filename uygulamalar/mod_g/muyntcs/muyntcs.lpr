program muyntcs;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: muyntcs.lpr
  Program Ýþlevi: çoklu masaüstü yönetim programý

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, ekran, gn_masaustu, gn_pencere, zamanlayici, gn_dugme, gn_gucdugme,
  gn_menu, gn_etiket, gn_resimdugme, gn_acilirmenu;

const
  PROGRAM_SAYISI = 10;

const
  ProgramAdi: string = 'Masaüstü Yöneticisi';

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
    ('Bellek Kullaným Bilgisi'),
    ('Disk Ýçerik Görüntüleyisi'),
    ('Dosya Yöneticisi'),
    ('Dijital Defter'),
    ('Dijital Saat'),
    ('Ana Ýskelet Programý'),
    ('Görev Yöneticisi'),
    ('PCI Aygýt Bilgisi'),
    ('Program Yazmaç Bilgileri'),
    ('Sistem Mesaj Görüntüleyicisi'));

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
  Tarih: array[0..3] of TSayi2;     // gün / ay / yýl / haftanýn günü

begin

  // ekran çözünürlüðünü al
  Ekran0.CozunurlukAl;

  // oluþturulan masaüstü sayýsýný al
  if(Masaustu0.MevcutMasaustuSayisi >= 4) then Gorev0.Sonlandir(-1);

  // yeni masaüstü oluþtur
  Masaustu0.Olustur(ProgramAdi);

  // yeni masaüstünün duvar kaðýdý
  Masaustu0.MasaustuResminiDegistir('disk1:\1.bmp');

  // görev yönetim ana paneli
  Pencere0.Olustur(Masaustu0.Kimlik, Ekran0.A0, Ekran0.Yukseklik0 - 40, Ekran0.Genislik0,
    40, ptBasliksiz, '', $FFFFFF);

  // ELERA ana düðmesini oluþtur
  gdELERA.Olustur(Pencere0.Kimlik, 6, 5, 60, 22, 'ELERA');
  gdELERA.Goster;

  // 4 adet masaüstü düðmesi oluþtur
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

  // dosya yöneticisi programý için düðme
  A1 += 22+6;
  dugDosyaYoneticisi.Olustur(Pencere0.Kimlik, A1, 5, 24, 22, 'DY');
  dugDosyaYoneticisi.Goster;

  // görev yöneticisi programý için düðme
  A1 += 26;
  dugGorevYoneticisi.Olustur(Pencere0.Kimlik, A1, 5, 24, 22, 'GY');
  dugGorevYoneticisi.Goster;

  // sistem mesaj görüntüleyici programý için düðme
  A1 += 26;
  dugMesajGoruntuleyici.Olustur(Pencere0.Kimlik, A1, 5, 32, 22, 'MSJ');
  dugMesajGoruntuleyici.Goster;

  // açýklama haline getirilen aþaðýdaki kodlar TResimDugme'nin þeffaf özelliði
  // (transparent) sonrasýnda aktifleþtirilecek
  {dugDosyaYoneticisi.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 1);
  dugDosyaYoneticisi.Goster;

  // görev yöneticisi programý için düðme
  A1 += 26;
  dugGorevYoneticisi.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 9);
  dugGorevYoneticisi.Goster;

  // sistem mesaj görüntüleyici programý için düðme
  A1 += 26;
  dugMesajGoruntuleyici.Olustur(Pencere0.Kimlik, A1, 4, 24, 24, $80000000 + 4);
  dugMesajGoruntuleyici.Goster;}

  etiSaat.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 100, 1, $800000, '00:00:00');
  etiSaat.Goster;

  etiTarih.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 118, 18, $800000, '00.00.0000 Aa');
  etiTarih.Goster;

  etiAgBilgi.Olustur(Pencere0.Kimlik, Ekran0.Genislik0 - 160, 9, $FF0000, '[Að]');
  etiAgBilgi.Goster;

  // paneli (pencere) görüntüle
  Pencere0.Goster;

  // masaüstünü görüntüle
  Masaustu0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  // masaüstü için ELERA düðmesine baðlý menü oluþtur
  menBaslat.Olustur(0, Ekran0.Yukseklik0 - 40 - ((PROGRAM_SAYISI * 26) + 8),
    300, (PROGRAM_SAYISI * 26) + 8, 26);

  // programlarý listeye ekle
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
  amenMasaustu.ElemanEkle('Duvar Kaðýdýný Deðiþtir', 12);
  amenMasaustu.ElemanEkle('Telif Hakký Dosyasýný Görüntüle', 12);
  amenMasaustu.ElemanEkle('Nesne Görüntüleyicisi', 12);
  amenMasaustu.ElemanEkle('Ekran Koruyucuyu', 12);
  amenMasaustu.ElemanEkle('Sistem Bilgisi', 12);

  // ve ana döngü
  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      // baþlat menüsüne týklandýðýnda
      if(OlayKayit.Kimlik = menBaslat.Kimlik) then
      begin

        gdELERA.DurumYaz(0);
        i := menBaslat.SeciliSiraNoAl;
        Gorev0.Calistir(Programlar[i]);
      end
      // masaüstü menüsüne týklandýðýnda
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
    // masaüstüne sað tuþ basýlýp býrakýldýðýnda
    else if(OlayKayit.Olay = FO_SAGTUS_BIRAKILDI) then
    begin

      if(OlayKayit.Kimlik = Masaustu0.Kimlik) then amenMasaustu.Goster;
    end

    // baþlat menüsü
    else if(OlayKayit.Olay = CO_DURUMDEGISTI) then
    begin

      if(OlayKayit.Kimlik = gdELERA.Kimlik) then
        if(OlayKayit.Deger1 = 1) then
          menBaslat.Goster
        else if(OlayKayit.Deger1 = 0) then
          menBaslat.Gizle;
    end
    // saat deðerini güncelleþtir
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
