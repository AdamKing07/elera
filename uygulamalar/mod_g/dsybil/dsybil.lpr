program dsybil;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: dsybil.lpr
  Program ��levi: dosyalar hakk�nda bilgi verir

  G�ncelleme Tarihi: 26/10/2019

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

  Pencere0.Olustur(-1, 100, 100, 300, 170, ptIletisim, ProgramAdi, $EADEA5);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  dugKapat.Olustur(Pencere0.Kimlik, 110, 100, 80, 22, '  Kapat');
  dugKapat.Goster;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugKapat.Kimlik) then Gorev0.Sonlandir;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(8, 16, 'Dosya Yolu (Path):');
      Pencere0.Tuval.YaziYaz(8, 32, '------------------');
      Pencere0.Tuval.YaziYaz(8, 48, ParamStr1(1));
    end;

  until (1 = 2);
end.
