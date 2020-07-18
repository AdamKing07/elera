program dsyyntcs;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dsyyntcs.lpr
  Program Ýþlevi: dosya yöneticisi

  Güncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses n_gorev, gn_pencere, gn_dugme, gn_listegorunum, gn_durumcubugu, gn_panel, n_genel;

const
  ProgramAdi: string = 'Dosya Yöneticisi';

var
  Genel: TGenel;
  Gorev: TGorev;
  Pencere: TPencere;
  Panel: TPanel;
  DurumCubugu: TDurumCubugu;
  lgDosyaListesi: TListeGorunum;
  dugSuruculer: array[1..6] of TDugme;
  OlayKayit: TOlayKayit;
  MantiksalSurucuListesi: array[1..6] of TMantiksalSurucu3;
  MantiksalDepolamaAygitSayisi, i, DugmeSol, DosyaSayisi: TSayi4;
  GecerliSurucu, SeciliYazi, s: string;

function MantiksalDepolamaAygitSayisiAl: TISayi4; assembler;
asm
  mov   eax,$010F
  int   $34
end;

function MantiksalDepolamaAygitBilgisiAl(AAygitKimlik: TSayi4;
  AMantiksalSurucu3: PMantiksalSurucu3): Boolean; assembler;
asm
  push  AMantiksalSurucu3
  push  AAygitKimlik
  mov   eax,$020F
  int   $34
  add   esp,8
end;

procedure DosyalariListele;
var
  DosyaArama: TDosyaArama;
  AramaSonuc: TSayi4;
  SonDegisimTarihi, SonDegisimSaati: TSayi2;
  TarihDizi: array[0..2] of TSayi2;
  SaatDizi: array[0..2] of TSayi1;
  Tarih, Saat, GirdiTip: string;
begin

  if(GecerliSurucu <> '') then
  begin

    lgDosyaListesi.Temizle;

    DosyaSayisi := 0;

    AramaSonuc := Genel._FindFirst(GecerliSurucu + ':\*.*', 0, DosyaArama);

    while (AramaSonuc = 0) do
    begin

      SonDegisimTarihi := DosyaArama.SonDegisimTarihi;
      TarihDizi[0] := SonDegisimTarihi and 31;
      TarihDizi[1] := (SonDegisimTarihi shr 5) and 15;
      TarihDizi[2] := ((SonDegisimTarihi shr 9) and 127) + 1980;
      Tarih := DateToStr(TarihDizi, False);

      SonDegisimSaati := DosyaArama.SonDegisimSaati;
      SaatDizi[2] := (SonDegisimSaati and 31) * 2;
      SaatDizi[1] := (SonDegisimSaati shr 5) and 63;
      SaatDizi[0] := (SonDegisimSaati shr 11) and 31;
      Saat := TimeToStr(SaatDizi);

      if((DosyaArama.Ozellikler and $10) = $10) then
        GirdiTip := 'Dizin'
      else GirdiTip := 'Dosya';

      lgDosyaListesi.ElemanEkle(DosyaArama.DosyaAdi + '|' + Tarih + ' ' + Saat + '|' +
        GirdiTip + '|' + IntToStr(DosyaArama.DosyaUzunlugu));

      Inc(DosyaSayisi);

      AramaSonuc := Genel._FindNext(DosyaArama);
    end;
    Genel._FindClose(DosyaArama);

    DurumCubugu.DurumYazisiDegistir('Toplam Dosya: ' + IntToStr(DosyaSayisi));

    Pencere.Ciz;
  end;
end;

begin

  Pencere.Olustur(-1, 80, 80, 510, 355, ptBoyutlanabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Panel.Olustur(Pencere.Kimlik, 0, 0, 100, 45, 0, 0, 0, 0, '');
  Panel.Hizala(hzUst);
  Panel.Goster;

  // yerel deðiþkenleri sýfýrla
  for i := 1 to 6 do
  begin

    FillByte(MantiksalSurucuListesi[i], SizeOf(TMantiksalSurucu3), 0);
  end;

  // geçerli sürücü atamasý
  GecerliSurucu := '';

  // her mantýksal sürücü için bir adet düðme oluþtur
  MantiksalDepolamaAygitSayisi := MantiksalDepolamaAygitSayisiAl;
  if(MantiksalDepolamaAygitSayisi > 0) then
  begin

    DugmeSol := 2;
    for i := 1 to MantiksalDepolamaAygitSayisi do
    begin

      if(MantiksalDepolamaAygitBilgisiAl(i, @MantiksalSurucuListesi[i])) then
      begin

        dugSuruculer[i].Olustur(Panel.Kimlik, DugmeSol, 2, 65, 22, MantiksalSurucuListesi[i].AygitAdi);
        dugSuruculer[i].Goster;
        DugmeSol += 70;
      end;
    end;
  end;

  DurumCubugu.Olustur(Pencere.Kimlik, 0, 0, 100, 20, 'Toplam Dosya: -');
  DurumCubugu.Goster;

  // liste görünüm nesnesi oluþtur
  lgDosyaListesi.Olustur(Pencere.Kimlik, 2, 47, 496, 300 - 73);
  lgDosyaListesi.Hizala(hzTum);

  // liste görünüm baþlýklarýný ekle
  lgDosyaListesi.BaslikEkle('Dosya Adý', 150);
  lgDosyaListesi.BaslikEkle('Tarih / Saat', 165);
  lgDosyaListesi.BaslikEkle('Tip', 80);
  lgDosyaListesi.BaslikEkle('Boyut', 80);

  // pencereyi görüntüle
  Pencere.Goster;

  // ana döngü
  while True do
  begin

    Gorev.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = Pencere.Kimlik) then
      begin

      end

      // liste kutusuna týklanmasý halinde dosyayý çalýþtýr
      else if(OlayKayit.Kimlik = lgDosyaListesi.Kimlik) then
      begin

        SeciliYazi := lgDosyaListesi.SeciliYaziAl;

        // dosya bilgisinden dosya ad ve uzantý bilgisini al
        i := Pos('|', SeciliYazi);
        if(i > 0) then
          s := Copy(SeciliYazi, 1, i - 1)
        else s := SeciliYazi;

        Gorev.Calistir(GecerliSurucu + ':\' + s);
      end
      else

      // aksi durumda hangi düðmeye týklandý ?
      begin

        // bul.
        for i := 1 to 6 do
        begin

          if(dugSuruculer[i].Kimlik = OlayKayit.Kimlik) then
          begin

            GecerliSurucu := MantiksalSurucuListesi[i].AygitAdi;
            Break;
          end;
        end;

        DosyalariListele;
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := RENK_MAVI;

      if(GecerliSurucu = '') then

        Pencere.Tuval.YaziYaz(2, 30, 'Aktif Sürücü: Yok')
      else Pencere.Tuval.YaziYaz(2, 30, 'Aktif Sürücü: ' + GecerliSurucu);
    end;
  end;
end.
