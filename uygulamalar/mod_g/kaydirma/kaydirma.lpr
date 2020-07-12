program kaydirma;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: kaydirma.lpr
  Program ��levi: kayd�rma �ubu�u tasar�m �al��mas�

  G�ncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}

uses n_gorev, gn_pencere, gn_kaydirmacubugu;

const
  ProgramAdi: string = 'Kayd�rma �ubu�u - Tasar�m';

var
  Gorev: TGorev;
  Pencere: TPencere;
  dugKaydirmaCubugu: TKaydirmaCubugu;
  OlayKayit: TOlayKayit;

begin
  Pencere.Olustur(-1, 100, 100, 270, 260, ptBoyutlanabilir, ProgramAdi,
    RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  dugKaydirmaCubugu.Olustur(Pencere.Kimlik, 30, 10, 200, 15, yYatay);
  dugKaydirmaCubugu.DegerleriBelirle(0, 5);
  dugKaydirmaCubugu.Goster;

  dugKaydirmaCubugu.Olustur(Pencere.Kimlik, 30, 195, 200, 15, yYatay);
  dugKaydirmaCubugu.DegerleriBelirle(0, 10);
  dugKaydirmaCubugu.Goster;

  dugKaydirmaCubugu.Olustur(Pencere.Kimlik, 10, 10, 15, 200, yDikey);
  dugKaydirmaCubugu.DegerleriBelirle(0, 15);
  dugKaydirmaCubugu.Goster;

  dugKaydirmaCubugu.Olustur(Pencere.Kimlik, 235, 10, 15, 200, yDikey);
  dugKaydirmaCubugu.DegerleriBelirle(0, 20);
  dugKaydirmaCubugu.Goster;

  Pencere.Goster;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

    end;
  end;
end.
