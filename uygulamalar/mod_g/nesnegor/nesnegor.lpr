program nesnegor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: nesnegor.lpr
  Program Ýþlevi: Görsel nesneler hakkýnda bilgiler verir.

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses n_gorev, gn_pencere, n_zamanlayici;

const
  ProgramAdi: string = 'Nesne Görüntüleyici';

var
  Gorev: TGorev;
  Pencere: TPencere;
  Zamanlayici: TZamanlayici;
  OlayKayit: TOlayKayit;
  FarePozisyonu: TNokta;
  GorselNesneKimlik: TKimlik;
  NesneAdi: string[40];

begin

  Pencere.Olustur(-1, 110, 110, 250, 130, ptBoyutlandirilabilir, ProgramAdi, $906AD1);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Pencere.Goster;

  Zamanlayici.Olustur(50);
  Zamanlayici.Baslat;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

    end
    else if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Zamanlayici.Durdur;

      FarePozisyonu := Gorev.FarePozisyonunuAl;

      GorselNesneKimlik := Gorev.GorselNesneKimlikAl(FarePozisyonu);
      Gorev.GorselNesneAdiAl(FarePozisyonu, @NesneAdi[0]);

      Pencere.Tuval.KalemRengi := RENK_BEYAZ;
      Pencere.Tuval.FircaRengi := RENK_BEYAZ;

      Pencere.Tuval.YaziYaz(18, 20, 'Yatay    : ');
      Pencere.Tuval.SayiYaz16(106, 20, True, 4, FarePozisyonu.A1);
      Pencere.Tuval.YaziYaz(18, 36, 'Dikey    : ');
      Pencere.Tuval.SayiYaz16(106, 36, True, 4, FarePozisyonu.B1);
      Pencere.Tuval.YaziYaz(18, 52, 'Kimlik   : ');
      Pencere.Tuval.SayiYaz16(106, 52, True, 8, GorselNesneKimlik);
      Pencere.Tuval.YaziYaz(18, 68, 'Nesne Adý: ');
      Pencere.Tuval.YaziYaz(106, 68, NesneAdi);

      Zamanlayici.Baslat;
    end;
  end;
end.
