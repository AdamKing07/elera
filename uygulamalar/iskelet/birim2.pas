{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: birim2.pas
  Program İşlevi: 2. birim

  Güncelleme Tarihi: 17/07/2020

 ==============================================================================}
{$mode objfpc}
unit birim2;

interface

uses gn_pencere, n_gorev, gn_dugme;

type
  TPencere2 = object
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
  Pencere2: TPencere2;

implementation

const
  PencereAdi: string = 'Pencere-2';

procedure TPencere2.Olustur;
begin

  Pencere.Olustur(-1, 120, 120, 300, 300, ptIletisim, PencereAdi, RENK_SARI);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Dugme1.Olustur(Pencere.Kimlik, 100, 100, 100, 100, PencereAdi);

//  SistemMesaj.YaziEkle('iskelet -> Pencere2 oluşturuldu...');
end;

procedure TPencere2.Goster;
begin

  Dugme1.Goster;
  Pencere.Goster;
end;

function TPencere2.OlaylariIsle: TISayi4;
begin

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
  end;

  Result := -1;
end;

end.
