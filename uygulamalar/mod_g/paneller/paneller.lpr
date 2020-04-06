{  Önemli Not:

    Program dosyalarını, diğer programların bulunduğu eleraos\progs\gmode 
    dizininin altında bir klasör altına kaydetmeniz, programın
    hatasız derlenmesi yönünden faydalı olacaktır.

}
program paneller;
{==============================================================================

  Kodlayan:
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: proje1.lpr
  Program İşlevi:

  Güncelleme Tarihi:

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_panel;

const
  PencereBaslik: string = 'Paneller';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  OlayKayit: TOlayKayit;
  PanelListesi: array[0..8] of TPanel;

begin

  Pencere0.Olustur(-1, 10, 10, 700, 450, ptBoyutlandirilabilir, PencereBaslik,
    $EBEBE0);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  PanelListesi[0].Olustur(Pencere0.Kimlik, 10, 10, 50, 50, 2, RENK_KIRMIZI,
    RENK_BEYAZ, RENK_SIYAH, 'Panel1');
  PanelListesi[0].Hizala(hzUst);
  PanelListesi[0].Goster;

  PanelListesi[1].Olustur(Pencere0.Kimlik, 150, 10, 50, 50, 2, RENK_KIRMIZI,
    RENK_BEYAZ, RENK_SIYAH, 'Panel2');
  PanelListesi[1].Hizala(hzAlt);
  PanelListesi[1].Goster;

  PanelListesi[2].Olustur(Pencere0.Kimlik, 290, 10, 50, 50, 2, RENK_MAVI,
    RENK_BEYAZ, RENK_SIYAH, 'Panel3');
  PanelListesi[2].Hizala(hzSol);
  PanelListesi[2].Goster;

  PanelListesi[3].Olustur(Pencere0.Kimlik, 10, 150, 50, 50, 2, RENK_MAVI,
    RENK_BEYAZ, RENK_SIYAH, 'Panel4');
  PanelListesi[3].Hizala(hzSag);
  PanelListesi[3].Goster;

  PanelListesi[4].Olustur(Pencere0.Kimlik, 150, 150, 50, 50, 2, RENK_YESIL,
    RENK_BEYAZ, RENK_SIYAH, 'Panel5');
  PanelListesi[4].Hizala(hzSol);
  PanelListesi[4].Goster;

  PanelListesi[5].Olustur(Pencere0.Kimlik, 290, 150, 50, 50, 2, RENK_YESIL,
    RENK_BEYAZ, RENK_SIYAH, 'Panel6');
  PanelListesi[5].Hizala(hzSag);
  PanelListesi[5].Goster;

  PanelListesi[6].Olustur(Pencere0.Kimlik, 10, 290, 50, 50, 2, RENK_BORDO,
    RENK_BEYAZ, RENK_SIYAH, 'Panel7');
  PanelListesi[6].Hizala(hzUst);
  PanelListesi[6].Goster;

  PanelListesi[7].Olustur(Pencere0.Kimlik, 150, 290, 50, 50, 2, RENK_BORDO,
    RENK_BEYAZ, RENK_SIYAH, 'Panel8');
  PanelListesi[7].Hizala(hzAlt);
  PanelListesi[7].Goster;

  PanelListesi[8].Olustur(Pencere0.Kimlik, 290, 290, 50, 50, 2, RENK_PEMBE,
    RENK_SARI, RENK_SIYAH, 'Panel9');
  PanelListesi[8].Hizala(hzTum);
  PanelListesi[8].Goster;

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
