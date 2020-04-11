{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_acilirmenu.pas
  Dosya İşlevi: açılır menü nesne işlevlerini içerir

  Güncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_acilirmenu;

interface

type
  PAcilirMenu = ^TAcilirMenu;
  TAcilirMenu = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
      ASeciliYaziRenk: TRenk): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
    function SeciliSiraNoAl: TISayi4;
    property Kimlik: TKimlik read FKimlik;
  end;

implementation

function TAcilirMenu.Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;
begin

  FKimlik := _AcilirMenuOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
    ASeciliYaziRenk);
  Result := FKimlik;
end;

procedure TAcilirMenu.Goster;
begin

  _AcilirMenuGoster(FKimlik);
end;

procedure TAcilirMenu.Gizle;
begin

  _AcilirMenuGizle(FKimlik);
end;

procedure TAcilirMenu.ElemanEkle(AElemanAdi: string; AResimSiraNo: TISayi4);
begin

  _AcilirMenuElemanEkle(FKimlik, AElemanAdi, AResimSiraNo);
end;

function TAcilirMenu.SeciliSiraNoAl: TISayi4;
begin

  Result := _AcilirMenuSeciliSiraNoAl(FKimlik);
end;

end.
