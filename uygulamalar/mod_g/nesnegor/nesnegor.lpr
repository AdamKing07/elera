program nesnegor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: nesnegor.lpr
  Program Ýþlevi: Görsel nesneler hakkýnda bilgiler verir.

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, zamanlayici;

const
  ProgramAdi: string = 'Nesne Görüntüleyici';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  FarePozisyonu: TNokta;
  GorselNesneKimlik: TKimlik;
  NesneAdi: string[40];

begin

  Pencere0.Olustur(-1, 110, 110, 250, 130, ptBoyutlandirilabilir, ProgramAdi, $906AD1);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  Pencere0.Goster;

  Zamanlayici0.Olustur(50);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

    end
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Zamanlayici0.Durdur;

      FarePozisyonu := Gorev0.FarePozisyonunuAl;

      GorselNesneKimlik := Gorev0.GorselNesneKimlikAl(FarePozisyonu);
      Gorev0.GorselNesneAdiAl(FarePozisyonu, @NesneAdi[0]);

      Pencere0.Tuval.KalemRengi := RENK_BEYAZ;
      Pencere0.Tuval.FircaRengi := RENK_BEYAZ;

      Pencere0.Tuval.YaziYaz(18, 20, 'Yatay    : ');
      Pencere0.Tuval.SayiYaz16(106, 20, True, 4, FarePozisyonu.A1);
      Pencere0.Tuval.YaziYaz(18, 36, 'Dikey    : ');
      Pencere0.Tuval.SayiYaz16(106, 36, True, 4, FarePozisyonu.B1);
      Pencere0.Tuval.YaziYaz(18, 52, 'Kimlik   : ');
      Pencere0.Tuval.SayiYaz16(106, 52, True, 8, GorselNesneKimlik);
      Pencere0.Tuval.YaziYaz(18, 68, 'Nesne Adý: ');
      Pencere0.Tuval.YaziYaz(106, 68, NesneAdi);

      Zamanlayici0.Baslat;
    end;

  until (1 = 2);
end.
