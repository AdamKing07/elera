{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_pci.pas
  Dosya İşlevi: pci yönetim işlevlerini içerir

  Güncelleme Tarihi: 22/09/2019

 ==============================================================================}
{$mode objfpc}
unit k_pci;

interface

uses paylasim;

function PCICagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses pci;

{==============================================================================
  pci kesme çağrılarını yönetir
 ==============================================================================}
function PCICagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  p: Isaretci;
  _Islev: TSayi1;
  _PCIAygitSiraNo: TISayi4;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // toplam pci aygıt sayısını al
  if(_Islev = 1) then
  begin

    Result := ToplamPCIAygitSayisi;
  end

  // pci bilgilerini al
  else if(_Islev = 2) then
  begin

    _PCIAygitSiraNo := PSayi4(Degiskenler + 00)^;
    if(_PCIAygitSiraNo >= 0) and (_PCIAygitSiraNo < ToplamPCIAygitSayisi) then
    begin

      p := Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      Move(PCIAygitBellekAdresi[_PCIAygitSiraNo]^, Isaretci(p)^, SizeOf(TPCI));
    end else Result := HATA_DEGERARALIKDISI;
  end

  // pci aygıtından 1 byte veri oku
  else if(_Islev = 3) then
  begin

    Result := PCIOku1(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^,
      PSayi4(Degiskenler + 08)^, PSayi4(Degiskenler + 12)^) and $FF;
  end

  // pci aygıtından 2 byte veri oku
  else if(_Islev = 4) then
  begin

    Result := PCIOku2(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^,
      PSayi4(Degiskenler + 08)^, PSayi4(Degiskenler + 12)^) and $FFFF;
  end

  // pci aygıtından 4 byte veri oku
  else if(_Islev = 5) then
  begin

    Result := PCIOku4(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^,
      PSayi4(Degiskenler + 08)^, PSayi4(Degiskenler + 12)^);
  end

  // pci aygıtına 1 byte veri yaz
  else if(_Islev = 6) then
  begin

    PCIYaz1(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^, PSayi4(Degiskenler + 08)^,
      PSayi4(Degiskenler + 12)^, PSayi4(Degiskenler + 16)^);
  end

  // pci aygıtına 2 byte veri yaz
  else if(_Islev = 7) then
  begin

    PCIYaz2(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^, PSayi4(Degiskenler + 08)^,
      PSayi4(Degiskenler + 12)^, PSayi4(Degiskenler + 16)^);
  end

  // pci aygıtına 4 byte veri yaz
  else if(_Islev = 8) then
  begin

    PCIYaz4(PSayi4(Degiskenler + 00)^, PSayi4(Degiskenler + 04)^, PSayi4(Degiskenler + 08)^,
      PSayi4(Degiskenler + 12)^, PSayi4(Degiskenler + 16)^);
  end

  else Result := HATA_ISLEV;
end;

end.
