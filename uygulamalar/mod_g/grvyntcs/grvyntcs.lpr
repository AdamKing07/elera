program grvyntcs;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: grvyntcs.lpr
  Program ��levi: g�rev y�neticisi

  G�ncelleme Tarihi: 05/04/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici, gn_panel, gn_durumcubugu, gn_listegorunum,
  gn_dugme;

const
  ProgramAdi: string = 'G�rev Y�neticisi';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Panel0: TPanel;
  dugSonlandir: TDugme;
  DurumCubugu0: TDurumCubugu;
  lgGorevListesi: TListeGorunum;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  GorevKayit: TGorevKayit;
  UstSinirGorevSayisi, CalisanGorevSayisi: TSayi4;
  SeciliGorevNo, Sonuc: TISayi4;
  i: TKimlik;
  SeciliYazi, s: string;

begin

  SeciliGorevNo := 0;

  Pencere0.Olustur(-1, 100, 150, 600, 300, ptBoyutlandirilabilir, ProgramAdi, $E3DBC8);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Panel0.Olustur(Pencere0.Kimlik, 0, 0, 100, 27, 0, 0, 0, 0, '');
  Panel0.Hizala(hzUst);
  Panel0.Goster;

  dugSonlandir.Olustur(Panel0.Kimlik, 3, 3, 17 * 8, 22, 'G�revi Sonland�r');
  dugSonlandir.Goster;

  s := '�al��abilir Program: 0 - �al��an Program: 0';
  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 180, 400, 18, s);
  DurumCubugu0.Goster;

  // liste g�r�n�m nesnesi olu�tur
  lgGorevListesi.Olustur(Pencere0.Kimlik, 2, 47, 496, 300 - 73);
  lgGorevListesi.Hizala(hzTum);

  // liste g�r�n�m ba�l�klar�n� ekle
  lgGorevListesi.BaslikEkle('GRV', 32);
  lgGorevListesi.BaslikEkle('Program Ad�', 150);
  lgGorevListesi.BaslikEkle('Belk.Ba�l', 90);
  lgGorevListesi.BaslikEkle('Belk.Uz.', 90);
  lgGorevListesi.BaslikEkle('Durum', 50);
  lgGorevListesi.BaslikEkle('Olay Sy�', 80);
  lgGorevListesi.BaslikEkle('G�rev Sy�', 80);

  Pencere0.Goster;

  Zamanlayici0.Olustur(300);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugSonlandir.Kimlik) then
      begin

        if(SeciliGorevNo > 0) then Gorev0.Sonlandir(SeciliGorevNo);

        // se�ilen g�rev de�erini s�f�rla
        SeciliGorevNo := 0;
      end
      else if(OlayKayit.Kimlik = lgGorevListesi.Kimlik) then
      begin

        SeciliYazi := lgGorevListesi.SeciliYaziAl;

        // dosya bilgisinden dosya ad ve uzant� bilgisini al
        i := Pos('|', SeciliYazi);
        if(i > 0) then
        begin

          s := Copy(SeciliYazi, 1, i - 1);

          Val(s, SeciliGorevNo, Sonuc);
          if(Sonuc <> 0) then SeciliGoreVNo := 0;
        end;
      end
    end
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      // her tetiklemede i�lem say�s�n� denetle ve
      // pencereye yeniden �izilme mesaj� g�nder
      lgGorevListesi.Temizle;
      Gorev0.GorevSayilariniAl(UstSinirGorevSayisi, CalisanGorevSayisi);

      for i := 1 to CalisanGorevSayisi do
      begin

        if(Gorev0.GorevBilgisiAl(i, @GorevKayit) = 0) then
        begin

          lgGorevListesi.ElemanEkle(IntToStr(GorevKayit.GorevKimlik) + '|' +
            GorevKayit.ProgramAdi + '|' +
            IntToStr(GorevKayit.BellekBaslangicAdresi) + '|' +
            IntToStr(GorevKayit.BellekUzunlugu) + '|' +
            IntToStr(Ord(GorevKayit.GorevDurum)) + '|' +
            IntToStr(GorevKayit.OlaySayisi) + '|' +
            IntToStr(GorevKayit.GorevSayaci));
        end;
      end;

      s := '�al��abilir Program: ' + IntToStr(UstSinirGorevSayisi) +
        ' - �al��an Program: ' + IntToStr(CalisanGorevSayisi);
      DurumCubugu0.DurumYazisiDegistir(s);

      Pencere0.Ciz;
    end;

  until (1 = 2);
end.
