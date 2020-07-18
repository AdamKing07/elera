{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: birim2.pas
  Program İşlevi: 3. birim

  Güncelleme Tarihi: 17/07/2020

 ==============================================================================}
{$mode objfpc}
unit birim3;

interface

uses gn_pencere, n_gorev, gn_dugme;

type
  TPencere3 = object
  public
    Gorev: TGorev;
    Pencere: TPencere;
    Dugme1: TDugme;
    OlayKayit: TOlayKayit;
    procedure Olustur;
    procedure Goster;
    function OlaylariIsle: TISayi4;
  end;

var
  Pencere3: TPencere3;

implementation

const
  PencereAdi: string = 'Pencere-3';

procedure TPencere3.Olustur;
begin

  Pencere.Olustur(-1, 150, 150, 300, 300, ptBoyutlanabilir, PencereAdi, RENK_KIRMIZI);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Dugme1.Olustur(Pencere.Kimlik, 100, 100, 100, 100, PencereAdi);

//  SistemMesaj.YaziEkle('iskelet -> Pencere3 oluşturuldu...');
end;

procedure TPencere3.Goster;
begin

  Dugme1.Goster;
  Pencere.Goster;
end;

function TPencere3.OlaylariIsle: TISayi4;
begin

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
  end;

  Result := -1;
end;

end.
