{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sistemmesaj.pas
  Dosya İşlevi: hata ayıklama (debug) amaçlı mesaj yönetim işlevlerini içerir

  Güncelleme Tarihi: 24/09/2019

 ==============================================================================}
{$mode objfpc}
unit sistemmesaj;

interface

type
  PSistemMesaj = ^TSistemMesaj;
  TSistemMesaj = object
  private
    FToplamMesaj: TSayi4;
  public
    function Toplam: TSayi4;
    procedure Al(ASiraNo: TSayi4; AMesaj: PMesaj);
    procedure YaziEkle(AMesaj: string);
    procedure Sayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
  end;

implementation

function TSistemMesaj.Toplam: TSayi4;
begin

  Result := _SistemMesajToplam;
end;

procedure TSistemMesaj.Al(ASiraNo: TSayi4; AMesaj: PMesaj);
begin

  _SistemMesajAl(ASiraNo, AMesaj);
end;

procedure TSistemMesaj.YaziEkle(AMesaj: string);
begin

  _SistemMesajYaziEkle(AMesaj);
end;

procedure TSistemMesaj.Sayi16Ekle(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
begin

  _SistemMesajSayi16Ekle(AMesaj, ASayi16, AHaneSayisi);
end;

end.
