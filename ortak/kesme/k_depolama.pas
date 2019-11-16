{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_depolama.pas
  Dosya İşlevi: depolama aygıt kesme çağrılarını yönetir

  Güncelleme Tarihi: 17/10/2019

 ==============================================================================}
{$mode objfpc}
unit k_depolama;

interface

uses paylasim;

function DepolamaCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses depolama;

{==============================================================================
  depolama aygıt kesme çağrılarını yönetir
 ==============================================================================}
function DepolamaCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Islev: TSayi4;
  _AygitKimlik: TKimlik;
  _p: Isaretci;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  //********** mantıksal aygıt işlevleri ***********

  // toplam mantıksal depolama aygıt sayısını al
  if(_Islev = 1) then
  begin

    Result := MantiksalDepolamaAygitSayisi;
  end

  // mantıksal depolama aygıt bilgilerini al
  else if(_Islev = 2) then
  begin

    _AygitKimlik := PISayi4(Degiskenler + 00)^;
    _p := Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
    Result := MantiksalDepolamaAygitBilgisiAl(_AygitKimlik, _p);
  end

  // mantıksal depolama aygıtından veri oku
  else if(_Islev = 3) then
  begin

    _AygitKimlik := PSayi4(Degiskenler + 00)^;
    _p := Isaretci(PSayi4(Degiskenler + 12)^ + AktifGorevBellekAdresi);
    Result := MantiksalDepolamaVeriOku(_AygitKimlik, PSayi4(Degiskenler + 04)^,
      PSayi4(Degiskenler + 08)^, _p);
  end;

  //********** fiziksel aygıt işlevleri ***********

  // toplam fiziksel depolama aygıt sayısını al
  if(_Islev = $71) then
  begin

    Result := FizikselDepolamaAygitSayisi;
  end

  // fiziksel depolama aygıt bilgilerini al
  else if(_Islev = $72) then
  begin

    _AygitKimlik := PSayi4(Degiskenler + 00)^;
    _p := Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
    Result := FizikselDepolamaAygitBilgisiAl(_AygitKimlik, _p);
  end

  // fiziksel depolama aygıtından veri oku
  else if(_Islev = $73) then
  begin

    _AygitKimlik := PSayi4(Degiskenler + 00)^;
    _p := Isaretci(PSayi4(Degiskenler + 12)^ + AktifGorevBellekAdresi);
    Result := FizikselDepolamaVeriOku(_AygitKimlik, PSayi4(Degiskenler + 04)^,
      PSayi4(Degiskenler + 08)^, _p);
  end;
end;

end.
