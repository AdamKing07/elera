{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: anabirim.pas
  Program Ýþlevi: ana programýn ana birimi

  Güncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
unit anabirim;

interface

uses gn_pencere, n_gorev;

type
  TAnaBirim = object
  public
    Gorev: TGorev;
    Pencere: TPencere;
    OlayKayit: TOlayKayit;
    TiklamaSayisi: Integer;
    procedure OlusturVeCalistir;
  end;

var
  GAnaBirim: TAnaBirim;

implementation

const
  ProgramAdi: string = 'Temel Ýskelet';

procedure TAnaBirim.OlusturVeCalistir;
begin

  Pencere.Olustur(-1, 100, 100, 200, 100, ptBoyutlanabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  TiklamaSayisi := 0;

  Pencere.Goster;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      Inc(TiklamaSayisi);
      Pencere.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := RENK_SIYAH;
      Pencere.Tuval.YaziYaz(8, 24, 'Týklama Sayýsý:');
      Pencere.Tuval.SayiYaz10(17 * 8, 24, TiklamaSayisi);
    end;
  end;
end;

end.
