program tasarim;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: tasarim.lpr
  Program Ýþlevi: nesne tasarým - test programý

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme;

const
  ProgramAdi: string = 'Nesne Tasarým - Test';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  dugSol, dugSag, dugUst, dugAlt,
  dugIlkDurum, dugTestDugmesi: TDugme;
  OlayKayit: TOlayKayit;

begin

  Pencere0.Olustur(-1, 100, 100, 400, 400, ptBoyutlandirilabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  dugSol.Olustur(Pencere0.Kimlik, 100, 150, 45, 45, 'Sol');
  dugSol.Goster;

  dugUst.Olustur(Pencere0.Kimlik, 150, 100, 45, 45, 'Üst');
  dugUst.Goster;

  dugSag.Olustur(Pencere0.Kimlik, 200, 150, 45, 45, 'Sað');
  dugSag.Goster;

  dugAlt.Olustur(Pencere0.Kimlik, 150, 200, 45, 45, 'Alt');
  dugAlt.Goster;

  dugIlkDurum.Olustur(Pencere0.Kimlik, 150, 150, 45, 45, '');
  dugIlkDurum.Goster;

  dugTestDugmesi.Olustur(Pencere0.Kimlik, 5, 5, 45, 45, 'Test');
  dugTestDugmesi.Goster;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugSol.Kimlik) then
      begin

        dugTestDugmesi.Hizala(hzSol);
      end
      else if(OlayKayit.Kimlik = dugUst.Kimlik) then
      begin

        dugTestDugmesi.Hizala(hzUst);
      end
      else if(OlayKayit.Kimlik = dugSag.Kimlik) then
      begin

        dugTestDugmesi.Hizala(hzSag);
      end
      else if(OlayKayit.Kimlik = dugAlt.Kimlik) then
      begin

        dugTestDugmesi.Hizala(hzAlt);
      end
      else if(OlayKayit.Kimlik = dugIlkDurum.Kimlik) then
      begin

        dugTestDugmesi.Hizala(hzYok);
      end;
    end;

  until (1 = 2);
end.
