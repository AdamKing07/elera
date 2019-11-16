program grvyntcs;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: grvyntcs.lpr
  Program Ýþlevi: görev yöneticisi

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici, gn_durumcubugu;

const
  ProgramAdi: string = 'Görev Yöneticisi';

  // GRV = çalýþan görev kimlik
  GorevBaslik0: string  = 'GRV  Program Adý   Belk.Baþl  Belk.Uz.   Durum  Olay Syç  Görev Syç';
  GorevBaslik1: string  = '---  ------------  ---------  ---------  -----  --------  ---------';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  DurumCubugu0: TDurumCubugu;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  GorevKayit: TGorevKayit;
  UstSinirGorevSayisi, CalisanGorevSayisi: TSayi4;
  i: TKimlik;
  s: string;

begin

  Pencere0.Olustur(-1, 10, 10, 580, 300, ptBoyutlandirilabilir, ProgramAdi, $E3DBC8);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  s := 'Çalýþabilir Program: 0 - Çalýþan Program: 0';
  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 180, 400, 18, s);
  DurumCubugu0.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      // her tetiklemede iþlem sayýsýný denetle ve
      // pencereye yeniden çizilme mesajý gönder
      Gorev0.GorevSayilariniAl(UstSinirGorevSayisi, CalisanGorevSayisi);
      Pencere0.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      s := 'Çalýþabilir Program: ' + IntToStr1(UstSinirGorevSayisi) +
        ' - Çalýþan Program: ' + IntToStr1(CalisanGorevSayisi);
      DurumCubugu0.DurumYazisiDegistir(s);

      Pencere0.Tuval.YaziYaz(0, 0 * 16, GorevBaslik0);
      Pencere0.Tuval.YaziYaz(0, 1 * 16, GorevBaslik1);

      for i := 1 to CalisanGorevSayisi do
      begin

        if(Gorev0.GorevBilgisiAl(i, @GorevKayit) = 0) then
        begin

          if(Ord(GorevKayit.GorevDurum) = 3) then
            Pencere0.Tuval.KalemRengi := RENK_KIRMIZI
          else Pencere0.Tuval.KalemRengi := RENK_SIYAH;

          Pencere0.Tuval.SayiYaz16(0, (1 + i) * 16, False, 3, GorevKayit.GorevKimlik);
          Pencere0.Tuval.YaziYaz(5 * 8, (1 + i) * 16, GorevKayit.ProgramAdi);
          Pencere0.Tuval.SayiYaz16(19 * 8, (1 + i) * 16, False, 8, GorevKayit.BellekBaslangicAdresi);
          Pencere0.Tuval.SayiYaz16(30 * 8, (1 + i) * 16, False, 8, GorevKayit.BellekUzunlugu);
          Pencere0.Tuval.SayiYaz16(44 * 8, (1 + i) * 16, False, 2, Ord(GorevKayit.GorevDurum));
          Pencere0.Tuval.SayiYaz16(52 * 8, (1 + i) * 16, False, 4, GorevKayit.OlaySayisi);
          Pencere0.Tuval.SayiYaz16(59 * 8, (1 + i) * 16, False, 8, GorevKayit.GorevSayaci);
        end;
      end;
    end;

  until (1 = 2);
end.
