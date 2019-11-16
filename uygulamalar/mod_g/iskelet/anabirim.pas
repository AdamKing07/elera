{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: anabirim.pas
  Program ��levi: ana program�n ana birimi

  G�ncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
unit anabirim;

interface

uses gn_pencere, gorev;

type
  TAnaBirim = object
  public
    Gorev0: TGorev;
    Pencere0: TPencere;
    OlayKayit: TOlayKayit;
    TiklamaSayisi: Integer;
    procedure OlusturVeCalistir;
  end;

var
  GAnaBirim: TAnaBirim;

implementation

const
  ProgramAdi: string = 'Temel �skelet';

procedure TAnaBirim.OlusturVeCalistir;
begin

  Pencere0.Olustur(-1, 100, 100, 200, 100, ptBoyutlandirilabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  TiklamaSayisi := 0;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      Inc(TiklamaSayisi);
      Pencere0.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(8, 24, 'T�klama Say�s�:');
      Pencere0.Tuval.SayiYaz10(17 * 8, 24, TiklamaSayisi);
    end;

  until (1 = 2);
end;

end.
