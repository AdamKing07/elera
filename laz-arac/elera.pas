{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: elera.pas
  Program İşlevi: elera işletim sistemi - lazarus programlama dili
    uygulama oluşturma modülü ana kod birimi

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
unit elera;

interface

uses eleram, LazarusPackageIntf;

implementation

procedure Register;
begin

  RegisterUnit('eleram', @eleram.Register);
end;

initialization
  RegisterPackage('elera', @Register);

end.
