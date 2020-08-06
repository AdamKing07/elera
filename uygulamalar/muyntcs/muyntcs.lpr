program muyntcs;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: muyntcs.lpr
  Program ��levi: �oklu masa�st� y�netim program�

  G�ncelleme Tarihi: 05/08/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, n_ekran, gn_masaustu, gn_pencere, n_zamanlayici, gn_dugme, gn_gucdugmesi,
  gn_menu, gn_etiket, gn_resim, gn_acilirmenu, gn_panel, n_genel;

const
  BASLATMENUSU_PSAYISI = 11;    // ba�lat men�s�ndeki program say�s�
  GOREVDUGMESI_G = 125;         // her bir g�rev d��mesinin geni�lik �nde�eri

const
  ProgramAdi: string = 'Masa�st� Y�neticisi';

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
    ('Dosya Y�neticisi'),
    ('Resim G�r�nt�leyici'),
    ('Disk ��erik G�r�nt�leyisi'),
    ('Dijital Defter'),
    ('Dijital Saat'),
    ('Ana �skelet Program�'),
    ('G�rev Y�neticisi'),
    ('PCI Ayg�t Bilgisi'),
    ('Program Yazma� Bilgileri'),
    ('Sistem Mesaj G�r�nt�leyicisi'),
    ('Program �al��t�r'));

  MasaustuMenuProgramAdi: array[0..4] of string = (
    ('mustudk.c'),
    ('haklar.txt'),
    ('nesnegor.c'),
    ('grafik3.c'),
    ('sisbilgi.c'));

type
  // t�m pencereye sahip programlar�n kay�tlar�n�n tutuldu�u de�i�ken yap�
  TCalisanProgramlar = record
    ProgramKayit: TProgramKayit;
    Dugme: TGucDugmesi;
    KayitGuncellendi: Boolean;
  end;

const
  // g�rev �ubu�unda g�sterilecek program say�s�
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
  GCGenislik, GDGenislik: TSayi4;  // g�rev �ubu�u / g�rev d��mesi
  ProgramKayit: TProgramKayit;
  Konum: TKonum;
  Boyut: TBoyut;
  PencereKimlik: TKimlik;

procedure TarihSaatBilgileriniGuncelle;
var
  Saat: array[0..2] of TSayi1;      // saat / dakika / saniye
  Tarih: array[0..3] of TSayi2;     // g�n / ay / y�l / haftan�n g�n�
begin

  Genel.SaatAl(@Saat);
  s := TimeToStr(Saat);
  SaatDegeri.Degistir(s);

  Genel.TarihAl(@Tarih);
  s := DateToStr(Tarih, True);
  TarihDegeri.Degistir(s);
end;

// program� �al��an program listesine ekler, daha �nce kayd� varsa (gerekirse)
// aktifli�ini g�nceller
procedure CalisanProgramListesineEkle(AProgramKayit: TProgramKayit);
var
  i: TSayi4;
begin

  // listeye eklenecek program daha �nce listeye eklenmi� mi?
  // eklenmi� ise aktifli�ini kontrol et
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

  // eklenmemi� ise listenin sonuna ekle
  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
  begin

    if(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) then
    begin

      // eklenmemi� ise listeye ekle
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

// kapat�lm�� programlar� listeden ��kar�r
// g�rev d��melerinin boyutlar�n� yeniden belirler
procedure GorevCubugunuGuncelle;
begin

  AktifProgram := Gorev.AktifProgramiAl;
  CalisanProgramSayisi := Gorev.CalisanProgramSayisiniAl;

  // her liste al�m �ncesinde g�rev �ubu�unun (orta panelin) geni�li�ini al
  OrtaPanel.BoyutAl(Konum, Boyut);
  GCGenislik := Boyut.Genislik;

  // t�m kay�tlar� G�NCELLENMED� olarak i�aretle
  // not: bu i�lem kapat�lm�� pencere / pencereleri bulmak i�indir
  for i := 0 to CALISAN_PROGRAM_SAYISI - 1 do
    CalisanProgramlar[i].KayitGuncellendi := False;

  // �al��an programlar� g�ncelle
  if(CalisanProgramSayisi > 0) then
  begin

    for i := 0 to CalisanProgramSayisi - 1 do
    begin

      Gorev.CalisanProgramBilgisiAl(i, ProgramKayit);
      CalisanProgramListesineEkle(ProgramKayit);
    end;
  end;

  // kapat�lm�� pencerelere ait d��meleri yok et
  i := 0;
  while i < CALISAN_PROGRAM_SAYISI do
  begin

    if not(CalisanProgramlar[i].ProgramKayit.PencereKimlik = -1) and
      (CalisanProgramlar[i].KayitGuncellendi = False) then
    begin

      CalisanProgramlar[i].Dugme.YokEt;
      CalisanProgramlar[i].ProgramKayit.PencereKimlik := -1;
      //CalisanProgramlar[i].KayitGuncellendi := True;

      // silinen kay�ttan itibaren t�m kay�tlar� ilk kay�tlara do�ru kayd�r
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

// g�rev d��mesinin temsil etti�i pencere nesne kimli�ini al�r
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

  // ekran ��z�n�rl���n� al
  Ekran.CozunurlukAl;

  // olu�turulan masa�st� say�s�n� al
  if(Masaustu.MevcutMasaustuSayisi >= 4) then Gorev.Sonlandir(-1);

  // yeni masa�st� olu�tur
  Masaustu.Olustur(ProgramAdi);

  // yeni masa�st�n�n duvar ka��d�
  Masaustu.MasaustuResminiDegistir('disk1:\1.bmp');

  // g�rev y�netim ana paneli
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

  // ELERA ana d��mesini olu�tur
  ELERA.Olustur(SolPanel.Kimlik, 4, 4, 56, 32, 'ELERA');
  ELERA.Goster;

  AgBilgisi.Olustur(SagPanel.Kimlik, 0, 14, $FF0000, '[A�]');
  AgBilgisi.Goster;

  SaatDegeri.Olustur(SagPanel.Kimlik, 60, 5, $800000, '00:00:00');
  SaatDegeri.Goster;

  TarihDegeri.Olustur(SagPanel.Kimlik, 42, 23, $800000, '00.00.0000 Aa');
  TarihDegeri.Goster;

  // paneli (GorevPenceresi) g�r�nt�le
  GorevPenceresi.Goster;

  // masa�st�n� g�r�nt�le
  Masaustu.Goster;

  Zamanlayici.Olustur(100);
  Zamanlayici.Baslat;

  // masa�st� i�in ELERA d��mesine ba�l� men� olu�tur
  BaslatMenusu.Olustur(0, Ekran.Yukseklik0 - 40 - ((BASLATMENUSU_PSAYISI * 26) + 8),
    300, (BASLATMENUSU_PSAYISI * 26) + 8, 26);

  // programlar� listeye ekle
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
  AcilirMenu.ElemanEkle('Duvar Ka��d�n� De�i�tir', 12);
  AcilirMenu.ElemanEkle('Telif Hakk� Dosyas�n� G�r�nt�le', 12);
  AcilirMenu.ElemanEkle('Nesne G�r�nt�leyicisi', 12);
  AcilirMenu.ElemanEkle('Ekran Koruyucuyu', 12);
  AcilirMenu.ElemanEkle('Sistem Bilgisi', 12);

  // ve ana d�ng�
  while True do
  begin

    Gorev.OlayBekle(Olay);

    if(Olay.Olay = FO_TIKLAMA) then
    begin

      // ba�lat men�s�ne t�kland���nda
      if(Olay.Kimlik = BaslatMenusu.Kimlik) then
      begin

        ELERA.DurumDegistir(0);
        i := BaslatMenusu.SeciliSiraNoAl;
        Gorev.Calistir(Programlar[i]);
      end
      // masa�st� men�s�ne t�kland���nda
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
    // masa�st�ne sa� tu� bas�l�p b�rak�ld���nda
    else if(Olay.Olay = FO_SAGTUS_BIRAKILDI) then
    begin

      if(Olay.Kimlik = Masaustu.Kimlik) then AcilirMenu.Goster;
    end
    // ba�lat d��mesi olaylar�
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
    // ba�lat men�s� olaylar�
    else if(Olay.Kimlik = BaslatMenusu.Kimlik) then
    begin

      if(Olay.Olay = CO_MENUACILDI) then
        ELERA.DurumDegistir(1)
      else if(Olay.Olay = CO_MENUKAPATILDI) then
        ELERA.DurumDegistir(0);
    end
    // saat de�erini g�ncelle�tir
    else if(Olay.Olay = CO_ZAMANLAYICI) then
    begin

      TarihSaatBilgileriniGuncelle;
      GorevCubugunuGuncelle;
    end;
  end;
end.
