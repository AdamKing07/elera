{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_menu.pas
  Dosya İşlevi: menü nesne işlevlerini içerir

  Güncelleme Tarihi: 28/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_menu;

interface

type
  PMenu = ^TMenu;
  TMenu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
    function SeciliSiraNoAl: TISayi4;
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TMenu.Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _MenuOlustur(A1, B1, AYukseklik, AYukseklik, AElemanYukseklik);
  Result := FKimlik;
end;

procedure TMenu.Goster;
begin

  _MenuGoster(FKimlik);
end;

procedure TMenu.Gizle;
begin

  _MenuGizle(FKimlik);
end;

procedure TMenu.ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
begin

  _MenuElemanEkle(FKimlik, AElemanAdi, AResimSiraNo);
end;

function TMenu.SeciliSiraNoAl: TISayi4;
begin

  Result := _MenuSeciliSiraNoAl(FKimlik);
end;

end.
