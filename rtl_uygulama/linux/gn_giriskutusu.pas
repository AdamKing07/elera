{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_giriskutusu.pas
  Dosya İşlevi: giriş kutusu nesne işlevlerini içerir

  Güncelleme Tarihi: 20/10/2019

 ==============================================================================}
{$mode objfpc}
unit gn_giriskutusu;

interface

type
  PGirisKutusu = ^TGirisKutusu;
  TGirisKutusu = object
  private
    FKimlik: TKimlik;
    FYazilamaz: LongBool;
    FSadeceRakam: LongBool;
    procedure SadeceRakam0(ADeger: LongBool);
    procedure Yazilamaz0(ADeger: LongBool);
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      AIcerikDeger: string): TKimlik;
    procedure Goster;
    function IcerikAl: string;
    procedure IcerikYaz(AIcerikDeger: string);
  published
    property Kimlik: TKimlik read FKimlik;
    property Yazilamaz: LongBool read FYazilamaz write Yazilamaz0;
    property SadeceRakam: LongBool read FSadeceRakam write SadeceRakam0;
  end;

implementation

function TGirisKutusu.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AIcerikDeger: string): TKimlik;
begin

  FKimlik := _GirisKutusuOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik, AIcerikDeger);

  FYazilamaz := False;
  FSadeceRakam := False;

  Result := FKimlik;
end;

procedure TGirisKutusu.Goster;
begin

  _GirisKutusuGoster(FKimlik);
end;

function TGirisKutusu.IcerikAl: string;
var
  s: string;
begin

  _GirisKutusuIcerikAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

procedure TGirisKutusu.IcerikYaz(AIcerikDeger: string);
begin

  _GirisKutusuIcerikYaz(FKimlik, AIcerikDeger);
end;

procedure TGirisKutusu.Yazilamaz0(ADeger: LongBool);
begin

  if(FYazilamaz = ADeger) then Exit;

  FYazilamaz := ADeger;
  _GirisKutusuYazilamaz0(FKimlik, FYazilamaz);
end;

procedure TGirisKutusu.SadeceRakam0(ADeger: LongBool);
begin

  if(FSadeceRakam = ADeger) then Exit;

  FSadeceRakam := ADeger;
  _GirisKutusuSadeceRakam0(FKimlik, FSadeceRakam);
end;

end.
