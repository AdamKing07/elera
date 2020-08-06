program muyntcs;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: muyntcs.lpr
  Program Ýþlevi: çoklu masaüstü yönetim programý

  Güncelleme Tarihi: 05/08/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, n_ekran, gn_masaustu, gn_pencere, n_zamanlayici, gn_dugme, gn_gucdugmesi,
  gn_menu, gn_etiket, gn_resim, gn_acilirmenu, gn_panel, n_genel;

const
  BASLATMENUSU_PSAYISI = 11;    // baþlat menüsündeki program sayýsý
  GOREVDUGMESI_G = 125;         // her bir görev düðmesinin geniþlik öndeðeri

const
  ProgramAdi: string = 'Masaüstü Yöneticisi';

  Programlar: array[0..BASLATMENUSU_PSAYISI - 1] of string = (
    ('dsyyntcs.c'),
    ('resimgor.c'),
    ('dskgor.c'),
    ('defter.c'),
    ('saat.c'),
    ('iskelet.c'),
    ('grvyntcs.c'),
    ('pcibil.c'),
    ('yzmcgor.c'),
    ('smsjgor.c'),
    ('calistir.c'));

  ProgramAciklamalari: array[0..BASLATMENUSU_PSAYISI - 1] of string = (
    ('Dosya Yöneticisi'),
    ('Resim Görüntüleyici'),
    ('Disk Ýçerik Görüntüleyisi'),
    ('Dijital Defter'),
    ('Dijital Saat'),
    ('Ana Ýskelet Programý'),
    ('Görev Yöneticisi'),
    ('PCI Aygýt Bilgisi'),
    ('Program Yazmaç Bilgileri'),
    ('Sistem Mesaj Görüntüleyicisi'),
    ('Program Çalýþtýr'));

  MasaustuMenuProgramAdi: array[0..4] of string = (
    ('mustudk.c'),
    ('haklar.txt'),
    ('nesnegor.c'),
    ('grafik3.c'),
    ('sisbilgi.c'));

type
  // tüm pencereye sahip programlarýn kayýtlarýnýn tutulduðu deðiþken yapý
  TCalisanProgramlar = record
    ProgramKayit: TProgramKayit;
    Dugme: TGucDugmesi;
    KayitGuncellendi: Boolean;
  end;

const
  // görev çubuðunda gösterilecek program sayýsý
  CALISAN_PROGRAM_SAYISI = 20;

var
  Genel: TGenel;
  Gorev: TGorev;
  Ekran: TEkran;
  Masaustu: TMasaustu;
  GorevPenceresi: TPencere;
  SolPanel, SagPanel, OrtaPanel: TPanel;
  CalisanProgramlar: array[0..CALISAN_PROGRAM_SAYISI - 1] of TCalisanProgramlar;
  BaslatMenusu: TMenu;
  AcilirMenu: TAcilirMenu;
  ELERA: TGucDugmesi;
  SaatDegeri, TarihDegeri, AgBilgisi: TEtiket;
  Zamanlayici: TZamanlayici;
  Olay: TOlay;
  i, j: TSayi4;
  s: string;

  AktifProgram: TISayi4;
  CalisanProgramSayisi,
  GCGenislik, GDGenislik: TSayi4;  // görev çubuðu / görev düðmesi
  ProgramKayit: TProgramKayit;
  Konum: TKonum;
  Boyut: TBoyut;
  PencereKimlik: TKimlik;

procedure TarihSaatBilgileriniGuncelle;
var
  Saat: array[0..2] of TSayi1;      // saat / dakika / saniye
  Tarih: array[0..3] of TSayi2;     // gün / ay / yýl / haftanýn günü
begin

  Genel.SaatAl(@Saat);
  s := TimeToStr(Saat);
  SaatDegeri.Degistir(s);

  Genel.TarihAl(@Tarih);
  s := DateToStr(Tarih, True);
  TarihDegeri.Degistir(s);
end;

// programý çalýþan program listesine ekler, daha önce kaydý varsa (gerekirse)
// aktifliðini günceller
procedure CalisanProgramListesineEkle(AProgramKayit: TProgramKayit);
var
  i: TSayi4;
begin

  // listeye eklenecek program daha önce listeye eklenmiþ mi?
  // eklenmiþ ise aktifliðini kontrol et
  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
  begin

    if(CalisanProgramlar[i].ProgramKayit.PencereKimlik = AProgramKayit.PencereKimlik) then
    begin

      CalisanProgramlar[i].KayitGuncellendi := True;

      // program listedeyse aktiflik durumunu kontrol et
      if(CalisanProgramlar[i].ProgramKayit.PencereKimlik = AktifProgram) then
        CalisanProgramlar[i].Dugme.DurumDegistir(1)
      else CalisanProgramlar[i].Dugme.DurumDegistir(0);

      Exit;
    end;
  end;

  // eklenmemiþ ise listenin sonuna ekle
  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
  begin

    if(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) then
    begin

      // eklenmemiþ ise listeye ekle
      CalisanProgramlar[i].ProgramKayit.PencereKimlik := AProgramKayit.PencereKimlik;
      CalisanProgramlar[i].ProgramKayit.GorevKimlik := AProgramKayit.GorevKimlik;
      CalisanProgramlar[i].ProgramKayit.PencereTipi := AProgramKayit.PencereTipi;
      CalisanProgramlar[i].ProgramKayit.PencereDurum := AProgramKayit.PencereDurum;
      CalisanProgramlar[i].ProgramKayit.ProgramAdi := AProgramKayit.ProgramAdi;

      CalisanProgramlar[i].Dugme.Olustur(OrtaPanel.Kimlik, (i * GDGenislik) + 5, 4,
        GDGenislik - 5, 32, AProgramKayit.ProgramAdi);
      CalisanProgramlar[i].Dugme.Goster;

      if(AProgramKayit.PencereKimlik = AktifProgram) then CalisanProgramlar[i].Dugme.DurumDegistir(1);

      CalisanProgramlar[i].KayitGuncellendi := True;
      Exit;
    end;
  end;
end;

// kapatýlmýþ programlarý listeden çýkarýr
// görev düðmelerinin boyutlarýný yeniden belirler
procedure GorevCubugunuGuncelle;
begin

  AktifProgram := Gorev.AktifProgramiAl;
  CalisanProgramSayisi := Gorev.CalisanProgramSayisiniAl;

  // her liste alým öncesinde görev çubuðunun (orta panelin) geniþliðini al
  OrtaPanel.BoyutAl(Konum, Boyut);
  GCGenislik := Boyut.Genislik;

  // tüm kayýtlarý GÜNCELLENMEDÝ olarak iþaretle
  // not: bu iþlem kapatýlmýþ pencere / pencereleri bulmak içindir
  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
    CalisanProgramlar[i].KayitGuncellendi := False;

  // çalýþan programlarý güncelle
  if(CalisanProgramSayisi > 0) then
  begin

    for i := 0 to CalisanProgramSayisi - 1 do
    begin

      Gorev.CalisanProgramBilgisiAl(i, ProgramKayit);
      CalisanProgramListesineEkle(ProgramKayit);
    end;
  end;

  // kapatýlmýþ pencerelere ait düðmeleri yok et
  i := 0;
  while i < CALISAN_PROGRAM_SAYISI do
  begin

    if not(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) and
      (CalisanProgramlar[i].KayitGuncellendi = False) then
    begin

      CalisanProgramlar[i].Dugme.YokEt;
      CalisanProgramlar[i].ProgramKayit.PencereKimlik := -1;
      //CalisanProgramlar[i].KayitGuncellendi := True;

      // silinen kayýttan itibaren tüm kayýtlarý ilk kayýtlara doðru kaydýr
      if(i < CALISAN_PROGRAM_SAYISI - 1) then
      begin

        for j := i + 1 to CALISAN_PROGRAM_SAYISI - 1 do
        begin

          CalisanProgramlar[j - 1].ProgramKayit := CalisanProgramlar[j].ProgramKayit;
          CalisanProgramlar[j - 1].Dugme := CalisanProgramlar[j].Dugme;
          CalisanProgramlar[j - 1].KayitGuncellendi := CalisanProgramlar[j].KayitGuncellendi;
        end;
      end;

      Dec(i);
    end;

    Inc(i);
  end;

  if(CalisanProgramSayisi * GOREVDUGMESI_G > GCGenislik) then
  begin

    GDGenislik := GCGenislik div CalisanProgramSayisi;
  end else GDGenislik := GOREVDUGMESI_G;

  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
  begin

    if not(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) then
    begin

      Konum.Sol := (i * GDGenislik) + 5;
      Konum.Ust := 4;
      Boyut.Genislik := GDGenislik - 5;
      Boyut.Yukseklik := 32;
      CalisanProgramlar[i].Dugme.Boyutlandir(Konum, Boyut);
    end;
  end;
end;

// görev düðmesinin temsil ettiði pencere nesne kimliðini alýr
function PencereKimliginiAl(ABasilanDugme: TKimlik): TKimlik;
var
  i: TSayi4;
begin

  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
  begin

    if not(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) then
    begin

      if not(CalisanProgramlar[i].Dugme.Kimlik = ABasilanDugme) then
        Exit(CalisanProgramlar[i].ProgramKayit.PencereKimlik);
    end;
  end;

  Result := -1;
end;

begin

  Gorev.Yukle;
  Gorev.Ad := ProgramAdi;

  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
    CalisanProgramlar[i].ProgramKayit.PencereKimlik := -1;

  // ekran çözünürlüðünü al
  Ekran.CozunurlukAl;

  // oluþturulan masaüstü sayýsýný al
  if(Masaustu.MevcutMasaustuSayisi >= 4) then Gorev.Sonlandir(-1);

  // yeni masaüstü oluþtur
  Masaustu.Olustur(ProgramAdi);

  // yeni masaüstünün duvar kaðýdý
  Masaustu.MasaustuResminiDegistir('disk1:\1.bmp');

  // görev yönetim ana paneli
  GorevPenceresi.Olustur(Masaustu.Kimlik, Ekran.A0, Ekran.Yukseklik0 - 40, Ekran.Genislik0,
    40, ptBasliksiz, '', $FFFFFF);

  SolPanel.Olustur(GorevPenceresi.Kimlik, 0, 0, 65, 18, 4, $C0CFFA, $DCE4FC, 0, '');
  SolPanel.Hizala(hzSol);
  SolPanel.Goster;

  SagPanel.Olustur(GorevPenceresi.Kimlik, 0, 0, 160, 18, 4, $C0CFFA, $DCE4FC, 0, '');
  SagPanel.Hizala(hzSag);
  SagPanel.Goster;

  OrtaPanel.Olustur(GorevPenceresi.Kimlik, 10, 10, 50, 18, 4, $C0CFFA, $DCE4FC, 0, '');
  OrtaPanel.Hizala(hzTum);
  OrtaPanel.Goster;

  // ELERA ana düðmesini oluþtur
  ELERA.Olustur(SolPanel.Kimlik, 4, 4, 56, 32, 'ELERA');
  ELERA.Goster;

  AgBilgisi.Olustur(SagPanel.Kimlik, 0, 14, $FF0000, '[Að]');
  AgBilgisi.Goster;

  SaatDegeri.Olustur(SagPanel.Kimlik, 60, 5, $800000, '00:00:00');
  SaatDegeri.Goster;

  TarihDegeri.Olustur(SagPanel.Kimlik, 42, 23, $800000, '00.00.0000 Aa');
  TarihDegeri.Goster;

  // paneli (GorevPenceresi) görüntüle
  GorevPenceresi.Goster;

  // masaüstünü görüntüle
  Masaustu.Goster;

  Zamanlayici.Olustur(100);
  Zamanlayici.Baslat;

  // masaüstü için ELERA düðmesine baðlý menü oluþtur
  BaslatMenusu.Olustur(0, Ekran.Yukseklik0 - 40 - ((BASLATMENUSU_PSAYISI * 26) + 8),
    300, (BASLATMENUSU_PSAYISI * 26) + 8, 26);

  // programlarý listeye ekle
  for i := 0 to BASLATMENUSU_PSAYISI - 1 do
  begin

    case i of
      0: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 01);
      1: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 10);
      2: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 06);
      3: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 07);
      4: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 08);
      5: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 14);
      6: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 09);
      7: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 05);
      8: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 15);
      9: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 04);
     10: BaslatMenusu.ElemanEkle(ProgramAciklamalari[i], 16);
    end;
  end;

  AcilirMenu.Olustur($2C3E50, RENK_BEYAZ, $7FB3D5, RENK_SIYAH, RENK_BEYAZ);
  AcilirMenu.ElemanEkle('Duvar Kaðýdýný Deðiþtir', 12);
  AcilirMenu.ElemanEkle('Telif Hakký Dosyasýný Görüntüle', 12);
  AcilirMenu.ElemanEkle('Nesne Görüntüleyicisi', 12);
  AcilirMenu.ElemanEkle('Ekran Koruyucuyu', 12);
  AcilirMenu.ElemanEkle('Sistem Bilgisi', 12);

  // ve ana döngü
  while True do
  begin

    Gorev.OlayBekle(Olay);

    if(Olay.Olay = FO_TIKLAMA) then
    begin

      // baþlat menüsüne týklandýðýnda
      if(Olay.Kimlik = BaslatMenusu.Kimlik) then
      begin

        ELERA.DurumDegistir(0);
        i := BaslatMenusu.SeciliSiraNoAl;
        Gorev.Calistir(Programlar[i]);
      end
      // masaüstü menüsüne týklandýðýnda
      else if(Olay.Kimlik = AcilirMenu.Kimlik) then
      begin

        i := AcilirMenu.SeciliSiraNoAl;
        Gorev.Calistir(MasaustuMenuProgramAdi[i]);
      end

      else if(Olay.Kimlik = TarihDegeri.Kimlik) then
      begin

        Gorev.Calistir('takvim.c');
      end

      else if(Olay.Kimlik = SaatDegeri.Kimlik) then
      begin

        Gorev.Calistir('saat.c');
      end

      else if(Olay.Kimlik = AgBilgisi.Kimlik) then
      begin

        Gorev.Calistir('agbilgi.c');
      end
    end
    // masaüstüne sað tuþ basýlýp býrakýldýðýnda
    else if(Olay.Olay = FO_SAGTUS_BIRAKILDI) then
    begin

      if(Olay.Kimlik = Masaustu.Kimlik) then AcilirMenu.Goster;
    end
    // baþlat düðmesi olaylarý
    else if(Olay.Olay = CO_DURUMDEGISTI) then
    begin

      if(Olay.Kimlik = ELERA.Kimlik) then
      begin

        if(Olay.Deger1 = 1) then
          BaslatMenusu.Goster
        else if(Olay.Deger1 = 0) then
          BaslatMenusu.Gizle;
      end
      else
      begin

        PencereKimlik := PencereKimliginiAl(Olay.Kimlik);
        if(PencereKimlik > -1) then
          if(Olay.Deger1 = 1) then
            GorevPenceresi.DurumNormal(PencereKimlik)
          else GorevPenceresi.DurumKucult(PencereKimlik);
      end;
    end
    // baþlat menüsü olaylarý
    else if(Olay.Kimlik = BaslatMenusu.Kimlik) then
    begin

      if(Olay.Olay = CO_MENUACILDI) then
        ELERA.DurumDegistir(1)
      else if(Olay.Olay = CO_MENUKAPATILDI) then
        ELERA.DurumDegistir(0);
    end
    // saat deðerini güncelleþtir
    else if(Olay.Olay = CO_ZAMANLAYICI) then
    begin

      TarihSaatBilgileriniGuncelle;
      GorevCubugunuGuncelle;
    end;
  end;
end.
