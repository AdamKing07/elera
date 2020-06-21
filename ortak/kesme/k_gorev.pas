{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_gorev.pas
  Dosya İşlevi: görev (program) yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/06/2020

 ==============================================================================}
{$mode objfpc}
unit k_gorev;

interface

uses paylasim;

function GorevCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;

implementation

uses genel, gorev, sistemmesaj;

{==============================================================================
  uygulama kesme çağrılarını yönetir
 ==============================================================================}
function GorevCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorevKimlik: TGorevKimlik;
  DosyaAdi: string;
  GorevKayit: PGorevKayit;
  p: PGorev;
  p2: PSayi4;
  p4: Isaretci;
  IslevNo: TSayi4;
  GorevNo: TISayi4;
  TSS: PTSS;
begin

  IslevNo := (AIslevNo and $FF);

  // program çalıştır
  if(IslevNo = 1) then
  begin

    DosyaAdi := PKarakterKatari(PSayi4(ADegiskenler + 00)^ + AktifGorevBellekAdresi)^;

    p := p^.Calistir(DosyaAdi);
    if(p <> nil) then

      Result := p^.GorevKimlik
    else Result := -1;
  end

  // program sonlandır
  else if(IslevNo = 2) then
  begin

    GorevNo := PISayi4(ADegiskenler + 00)^;

    // -1 = çalışan uygulamayı sonlandır
    if(GorevNo = -1) then
    begin

      p := GorevListesi[CalisanGorev];
      p^.Sonlandir(CalisanGorev);
    end
    else if(GorevNo > 0) and (GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      p := GorevListesi[GorevNo];
      p^.Sonlandir(GorevNo);
    end;
  end

  // görev sayaç değerlerini al
  else if(IslevNo = 3) then
  begin

    p2 := PSayi4(PSayi4(ADegiskenler + 00)^ + AktifGorevBellekAdresi);
    p2^ := USTSINIR_GOREVSAYISI;
    p2 := PSayi4(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi);
    p2^ := CalisanGorevSayisi;

    Result := 1;
  end

  // görev hakkında detaylı bilgi al
  else if(IslevNo = 4) then
  begin

    GorevNo := PISayi4(ADegiskenler + 00)^;
    if(GorevNo > 0) and (GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      p := GorevBilgisiAl(GorevNo);
      if(p <> nil) then
      begin

        GorevKayit := PGorevKayit(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi);
        GorevKayit^.GorevDurum := p^.FGorevDurum;
        GorevKayit^.GorevKimlik := p^.GorevKimlik;
        GorevKayit^.GorevSayaci := p^.GorevSayaci;
        GorevKayit^.BellekBaslangicAdresi := p^.BellekBaslangicAdresi;
        GorevKayit^.BellekUzunlugu := p^.BellekUzunlugu;
        GorevKayit^.OlaySayisi := p^.OlaySayisi;
        GorevKayit^.ProgramAdi := p^.FProgramAdi;

        Result := HATA_YOK;
      end else Result := HATA_GOREVNO;
    end else Result := HATA_GOREVNO;
  end

  // görev yazmaç içerik bilgilerini al
  else if(IslevNo = 5) then
  begin

    GorevNo := PISayi4(ADegiskenler + 00)^;
    if(GorevNo > 0) and (GorevNo <= USTSINIR_GOREVSAYISI) then
    begin

      GorevKimlik := GorevSiraNumarasiniAl(GorevNo);
      if(GorevKimlik > 0) then
      begin

        p4 := Isaretci(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi);
        TSS := GorevTSSListesi[GorevKimlik];
        Tasi2(TSS, p4, 104);

        Result := HATA_YOK;
      end else Result := HATA_GOREVNO;
    end else Result := HATA_GOREVNO;
  end;
end;

end.
