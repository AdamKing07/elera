{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_depolama.pas
  Dosya İşlevi: depolama aygıt kesme çağrılarını yönetir

  Güncelleme Tarihi: 23/06/2020

 ==============================================================================}
{$mode objfpc}
unit k_depolama;

interface

uses paylasim;

function DepolamaCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;

implementation

uses depolama;

{==============================================================================
  depolama aygıt kesme çağrılarını yönetir
 ==============================================================================}
function DepolamaCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Islev: TSayi4;
  AygitKimlik: TKimlik;
  p: Isaretci;
begin

  // işlev no
  Islev := (AIslevNo and $FF);

  //********** mantıksal aygıt işlevleri ***********

  // toplam mantıksal depolama aygıt sayısını al
  if(Islev = 1) then
  begin

    Result := MantiksalDepolamaAygitSayisi;
  end

  // mantıksal depolama aygıt bilgilerini al
  else if(Islev = 2) then
  begin

    AygitKimlik := PISayi4(ADegiskenler + 00)^;
    p := Isaretci(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
    Result := MantiksalDepolamaAygitBilgisiAl(AygitKimlik, p);
  end

  // mantıksal depolama aygıtından veri oku
  else if(Islev = 3) then
  begin

    AygitKimlik := PSayi4(ADegiskenler + 00)^;
    p := Isaretci(PSayi4(ADegiskenler + 12)^ + CalisanGorevBellekAdresi);
    Result := MantiksalDepolamaVeriOku(AygitKimlik, PSayi4(ADegiskenler + 04)^,
      PSayi4(ADegiskenler + 08)^, p);
  end;

  //********** fiziksel aygıt işlevleri ***********

  // toplam fiziksel depolama aygıt sayısını al
  if(Islev = $71) then
  begin

    Result := FizikselDepolamaAygitSayisi;
  end

  // fiziksel depolama aygıt bilgilerini al
  else if(Islev = $72) then
  begin

    AygitKimlik := PSayi4(ADegiskenler + 00)^;
    p := Isaretci(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
    Result := FizikselDepolamaAygitBilgisiAl(AygitKimlik, p);
  end

  // fiziksel depolama aygıtından veri oku
  else if(Islev = $73) then
  begin

    AygitKimlik := PSayi4(ADegiskenler + 00)^;
    p := Isaretci(PSayi4(ADegiskenler + 12)^ + CalisanGorevBellekAdresi);
    Result := FizikselDepolamaVeriOku(AygitKimlik, PSayi4(ADegiskenler + 04)^,
      PSayi4(ADegiskenler + 08)^, p);
  end;
end;

end.
