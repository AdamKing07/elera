program grafik5;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: grafik5.lpr
  Program İşlevi: çoklu dikdörtgen / kare çizim programı - double değer testi

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, zamanlayici;

const
  ProgramAdi: string = 'Grafik - 5';
  USTDEGER_NOKTASAYISI = 55;

type
  TSayac = record
    AzamiDeger: TSayi4;
    MevcutDeger, Hiz: Double;
    Renk: TRenk;
  end;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  i, j, X, Y: TISayi4;
  SayacListesi: array[0..USTDEGER_NOKTASAYISI - 1] of TSayac;
  HizListesi: array[0..7] of Double = (0.1, 1.0, 2.0, 3.0, 3.5, 2.5, 1.5, 0.5);
  RenkListesi: array[0..7] of Integer = ($FF0000, $00FF00, $FFFF00, $0000FF, $FF00FF,
    $00FFFF, $000080, $008000);

function RDTSCDegeriAl: TISayi4;
var
  _Deger: TISayi4;
begin

  // RDTSC değerini al - geçici işlev
  asm
    mov eax,19
    int $34
    mov _Deger,eax
  end;

  Result := _Deger;
end;

begin

  Pencere0.Olustur(-1, 150, 150, 450 + 8, 300 + 35, ptIletisim, ProgramAdi, $F7EEF3);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Zamanlayici0.Olustur(50);

  Pencere0.Goster;

  // tüm nokta değişkenlerini ilk değerlerle yükle
  for i := 0 to USTDEGER_NOKTASAYISI - 1 do
  begin

    j := RDTSCDegeriAl;
    SayacListesi[i].MevcutDeger := 0.0;
    SayacListesi[i].AzamiDeger := 300;
    SayacListesi[i].Hiz := HizListesi[j and 7];
    SayacListesi[i].Renk := RenkListesi[j and 7];
  end;

  // zamanlayıcıyı başlat
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayAl(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      // tüm dikdörtgen / kare dikey değerlerini artır
      for i := 0 to USTDEGER_NOKTASAYISI - 1 do
      begin

        SayacListesi[i].MevcutDeger := SayacListesi[i].MevcutDeger + SayacListesi[i].Hiz;
        if(SayacListesi[i].MevcutDeger > SayacListesi[i].AzamiDeger) then
        begin

          SayacListesi[i].MevcutDeger := 0.0;
          j := RDTSCDegeriAl;
          SayacListesi[i].Hiz := HizListesi[j and 7];
        end;
      end;

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      // yeni koordinatlarla çizimleri yenile
      for i := 0 to USTDEGER_NOKTASAYISI - 1 do
      begin

        X := i * 8;
        Y := Round(SayacListesi[i].MevcutDeger);
        Pencere0.Tuval.Dikdortgen(X, Y, 7, 7, SayacListesi[i].Renk, True);
      end;
    end;

  until (1 = 2);
end.
