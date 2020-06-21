program dsybil;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dsybil.lpr
  Program Ýþlevi: dosyalar hakkýnda bilgi verir

  Güncelleme Tarihi: 08/06/2020

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme;

const
  ProgramAdi: string = 'Dosya Bilgisi';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  dugKapat: TDugme;
  OlayKayit: TOlayKayit;

begin

  Pencere0.Olustur(-1, 100, 100, 300, 150, ptIletisim, ProgramAdi, $EADEA5);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  dugKapat.Olustur(Pencere0.Kimlik, 110, 100, 80, 22, 'Kapat');
  dugKapat.Goster;

  Pencere0.Goster;

  while True do
  begin

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugKapat.Kimlik) then Gorev0.Sonlandir(-1);
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(8, 16, 'Dosya Yolu (Path):');
      Pencere0.Tuval.YaziYaz(8, 32, '------------------');
      Pencere0.Tuval.YaziYaz(8, 48, ParamStr1(1));
    end;
  end;
end.
