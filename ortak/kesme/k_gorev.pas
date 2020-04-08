{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_gorev.pas
  Dosya İşlevi: görev (program) yönetim işlevlerini içerir

  Güncelleme Tarihi: 05/04/2020

 ==============================================================================}
{$mode objfpc}
unit k_gorev;

interface

uses paylasim;

function GorevCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses genel, gorev;

{==============================================================================
  uygulama kesme çağrılarını yönetir
 ==============================================================================}
function GorevCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _GorevKimlik: TGorevKimlik;
  _DosyaAdi: string;
  _GorevB1: PGorevKayit;
  p: PGorev;
  p2: PSayi4;
  p4: Isaretci;
  _IslevNo: TSayi4;
  _GorevNo: TISayi4;
  _TSS: PTSS;
begin

  _IslevNo := (IslevNo and $FF);

  // program çalıştır
  if(_IslevNo = 1) then
  begin

    _DosyaAdi := PShortString(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi)^;

    p := p^.Calistir(_DosyaAdi);
    if(p <> nil) then

      Result := p^.GorevKimlik
    else Result := -1;
  end

  // program sonlandır
  else if(_IslevNo = 2) then
  begin

    _GorevNo := PISayi4(Degiskenler + 00)^;

    // -1 = çalışan uygulamayı sonlandır
    if(_GorevNo = -1) then
    begin

      p := GorevListesi[CalisanGorev];
      p^.Sonlandir(CalisanGorev);
    end
    else if(_GorevNo > 0) and (_GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      p := GorevListesi[_GorevNo];
      p^.Sonlandir(_GorevNo);
    end;
  end

  // görev sayaç değerlerini al
  else if(_IslevNo = 3) then
  begin

    p2 := PSayi4(PSayi4(Degiskenler + 00)^ + AktifGorevBellekAdresi);
    p2^ := USTSINIR_GOREVSAYISI;
    p2 := PSayi4(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
    p2^ := CalisanGorevSayisi;

    Result := 1;
  end

  // görev hakkında detaylı bilgi al
  else if(_IslevNo = 4) then
  begin

    _GorevNo := PISayi4(Degiskenler + 00)^;
    if(_GorevNo > 0) and (_GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      p := GorevBilgisiAl(_GorevNo);
      if(p <> nil) then
      begin

        _GorevB1 := PGorevKayit(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
        _GorevB1^.GorevDurum := p^.FGorevDurum;
        _GorevB1^.GorevKimlik := p^.GorevKimlik;
        _GorevB1^.GorevSayaci := p^.GorevSayaci;
        _GorevB1^.BellekBaslangicAdresi := p^.BellekBaslangicAdresi;
        _GorevB1^.BellekUzunlugu := p^.BellekUzunlugu;
        _GorevB1^.OlaySayisi := p^.OlaySayisi;
        _GorevB1^.ProgramAdi := p^.FProgramAdi;

        Result := ISLEM_BASARILI;
      end else Result := HATA_GOREVNO;
    end else Result := HATA_GOREVNO;
  end

  // görev yazmaç içerik bilgilerini al
  else if(_IslevNo = 5) then
  begin

    _GorevNo := PISayi4(Degiskenler + 00)^;
    if(_GorevNo > 0) and (_GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      _GorevKimlik := GorevSiraNumarasiniAl(_GorevNo);
      if(_GorevKimlik > 0) then
      begin

        p4 := Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
        _TSS := GorevTSSListesi[_GorevKimlik];
        Tasi2(_TSS, p4, 104);

        Result := ISLEM_BASARILI;
      end else Result := HATA_GOREVNO;
    end else Result := HATA_GOREVNO;
  end;
end;

end.
