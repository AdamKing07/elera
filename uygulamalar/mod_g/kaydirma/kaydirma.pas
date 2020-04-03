program kaydirma;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: kaydirma.lpr
  Program ��levi: kayd�rma �ubu�u tasar�m �al��mas�

  G�ncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}

uses gorev, gn_pencere, gn_kaydirmacubugu;

const
  ProgramAdi: string = 'Kayd�rma �ubu�u - Tasar�m';

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
