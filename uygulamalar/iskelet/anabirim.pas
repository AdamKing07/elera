{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: anabirim.pas
  Program ��levi: ana program�n ana birimi

  G�ncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
unit anabirim;

interface

uses gn_pencere, n_gorev, gn_dugme, birim2, birim3;

type
  TPencere1 = object
  public
    Gorev: TGorev;
    Pencere: TPencere;
    Dugme2, Dugme3: TDugme;
//    SistemMesaj: TSistemMesaj;
    OlayKayit: TOlayKayit;
    TiklamaSayisi: TSayi4;
    procedure Olustur;
    procedure Goster;
    function OlaylariIsle: TISayi4;
  end;

var
  Pencere1: TPencere1;

implementation

const
  PencereAdi: string = 'Ana Pencere';

procedure TPencere1.Olustur;
begin

  TiklamaSayisi := 0;

  Pencere.Olustur(-1, 100, 100, 300, 300, ptBoyutlanabilir, PencereAdi, RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Dugme2.Olustur(Pencere.Kimlik, 10, 10, 280, 130, '2. Pencere');
  Dugme3.Olustur(Pencere.Kimlik, 10, 150, 280, 130, '3. Pencere');

//  SistemMesaj.YaziEkle('iskelet -> Pencere1 olu�turuldu...');
end;

procedure TPencere1.Goster;
begin

  Dugme2.Goster;
  Dugme3.Goster;

  Pencere.Goster;
end;

function TPencere1.OlaylariIsle: TISayi4;
begin

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = Dugme2.Kimlik) then
        Pencere2.Goster
      else if(OlayKayit.Kimlik = Dugme3.Kimlik) then
        Pencere3.Goster
      else
      begin

        Inc(TiklamaSayisi);
        Pencere.Ciz;
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := RENK_SIYAH;
      Pencere.Tuval.YaziYaz(0, 0, 'T�klama Say�s�:');
      Pencere.Tuval.SayiYaz10(17 * 8, 0, TiklamaSayisi);
    end;
  end;

  Result := -1;
end;

end.
