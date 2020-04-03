program kaydirma;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: kaydirma.lpr
  Program Ýþlevi: kaydýrma çubuðu tasarým çalýþmasý

  Güncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}

uses gorev, gn_pencere, gn_kaydirmacubugu;

const
  ProgramAdi: string = 'Kaydýrma Çubuðu - Tasarým';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  dugKaydirmaCubugu1: TKaydirmaCubugu;
  OlayKayit: TOlayKayit;

begin
  Pencere0.Olustur(-1, 100, 100, 270, 260, ptBoyutlandirilabilir, ProgramAdi,
    RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  dugKaydirmaCubugu1.Olustur(Pencere0.Kimlik, 30, 10, 200, 15, yYatay);
  dugKaydirmaCubugu1.DegerleriBelirle(0, 5);
  dugKaydirmaCubugu1.Goster;

  dugKaydirmaCubugu1.Olustur(Pencere0.Kimlik, 30, 195, 200, 15, yYatay);
  dugKaydirmaCubugu1.DegerleriBelirle(0, 10);
  dugKaydirmaCubugu1.Goster;

  dugKaydirmaCubugu1.Olustur(Pencere0.Kimlik, 10, 10, 15, 200, yDikey);
  dugKaydirmaCubugu1.DegerleriBelirle(0, 15);
  dugKaydirmaCubugu1.Goster;

  dugKaydirmaCubugu1.Olustur(Pencere0.Kimlik, 235, 10, 15, 200, yDikey);
  dugKaydirmaCubugu1.DegerleriBelirle(0, 20);
  dugKaydirmaCubugu1.Goster;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

    end;
  until (1 = 2);
end.
