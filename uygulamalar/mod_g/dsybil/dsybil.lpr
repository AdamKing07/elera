program dsybil;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dsybil.lpr
  Program Ýþlevi: dosyalar hakkýnda bilgi verir

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, gn_dugme;

const
  ProgramAdi: string = 'Dosya Bilgisi';

var
  Gorev: TGorev;
  Pencere: TPencere;
  dugKapat: TDugme;
  OlayKayit: TOlayKayit;

begin

  Pencere.Olustur(-1, 100, 100, 300, 150, ptIletisim, ProgramAdi, $EADEA5);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  dugKapat.Olustur(Pencere.Kimlik, 110, 100, 80, 22, 'Kapat');
  dugKapat.Goster;

  Pencere.Goster;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugKapat.Kimlik) then Gorev.Sonlandir(-1);
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := RENK_SIYAH;
      Pencere.Tuval.YaziYaz(8, 16, 'Dosya Yolu (Path):');
      Pencere.Tuval.YaziYaz(8, 32, '------------------');
      Pencere.Tuval.YaziYaz(8, 48, ParamStr1(1));
    end;
  end;
end.
