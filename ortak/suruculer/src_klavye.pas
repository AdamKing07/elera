{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: src_klavye.pas
  Dosya İşlevi: standart klavye sürücüsü

  Güncelleme Tarihi: 08/10/2019

  kaynak bağlantı: http://www.computer-engineering.org/ps2keyboard/

 ==============================================================================}
{$mode objfpc}
unit src_klavye;
 
interface

uses paylasim, port;

procedure Yukle;
procedure KlavyeKesmeCagrisi;
function KlavyedenTusAl(var ATus: Char): TTusDurum;

implementation

uses irq;

const
  USTLIMIT_KLAVYE_BELLEK = 128;

  KlavyeHaritasiTR: array[0..127] of Char = (
    #0, #27 {Esc}, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '*', '-',
    {14} #08 {Backspace}, #09 {Tab}, 'q', 'w', 'e', 'r', 't', 'y', 'u', Chr($FD) {ı},
    {24} 'o', 'p', Chr($F0) {ğ}, Chr($FC) {ü}, #10 {Enter}, TUS_KONTROL, 'a', 's', 'd',
    'f', 'g', 'h', 'j', 'k', 'l', Chr($FE) {ş}, 'i', '"', TUS_DEGISIM {Left Shift},
    ',', 'z', 'x', 'c', 'v', 'b', 'n', 'm', Chr($F6) {ö}, Chr($E7) {ç}, '.',
    TUS_DEGISIM {Right Shift}, '*', TUS_ALT, ' ', #0 {Caps Lock}, #33, #34,
    #0, #0, #0, #0, #0, #0, #0, #0, //F1 - F10  // geçici değer
    #0,   // Num Lock
    #0,   // Scroll Lock
    {71} '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', ',',
    {84} #0, #0, '<',
    #0,   // F11 Key
    #0,   // F12 Key
    #0,   // All other keys are undefined
    #0,
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0,
    #0, #0, #0, #0, #0, #0, #0);

var
  ToplamVeriUzunlugu: TSayi4;
  KlavyeVeriBellegi: array[0..USTLIMIT_KLAVYE_BELLEK - 1] of TSayi1;

{==============================================================================
  klavye yükleme işlevlerini içerir
 ==============================================================================}
procedure Yukle;
begin

  // klavye kesme (irq) girişini ata
  IRQIsleviAta(1, @KlavyeKesmeCagrisi);

  // klavye sayacını sıfırla
  ToplamVeriUzunlugu := 0;
end;

{==============================================================================
  klavye kesme işlevi
 ==============================================================================}
procedure KlavyeKesmeCagrisi;
var
  _Tus: TSayi1;
begin

  // klavye belleğindeki veriyi al
  _Tus := PortAl1($60);

  // eğer azami veri aşılmamışsa
  if(ToplamVeriUzunlugu < USTLIMIT_KLAVYE_BELLEK) then
  begin

    // veriyi sistem belleğine kaydet
    KlavyeVeriBellegi[ToplamVeriUzunlugu] := _Tus;

    // klavye sayacını artır
    Inc(ToplamVeriUzunlugu);
  end;
end;

{==============================================================================
  klavye kesme işlevi
 ==============================================================================}
function KlavyedenTusAl(var ATus: Char): TTusDurum;
var
  _C: Char;
  _Sayi1: TSayi1;
  _TusBirakildi: Boolean;
begin

  // eğer klavyeden veri gelmemişse çık
  if(ToplamVeriUzunlugu = 0) then
  begin

    ATus := #0;
    Result := tdYok;
  end
  else
  begin

    _Sayi1 := KlavyeVeriBellegi[0];

    Dec(ToplamVeriUzunlugu);
    if(ToplamVeriUzunlugu > 0) then
    begin

      Tasi2(@KlavyeVeriBellegi[1], @KlavyeVeriBellegi[0], ToplamVeriUzunlugu);
    end;

    _TusBirakildi := (_Sayi1 and $80) = $80;

    // tuşun bırakılması
    if(_TusBirakildi) then
    begin

      _C := KlavyeHaritasiTR[_Sayi1 and $7F];

      if(_C = TUS_KONTROL) then
      begin

        ATus := #0;
        KONTROLTusDurumu := tdBirakildi;
      end
      else if(ATus = TUS_ALT) then
      begin

        ATus := #0;
        ALTTusDurumu := tdBirakildi;
      end
      else if(ATus = TUS_DEGISIM) then
      begin

        ATus := #0;
        DEGISIMTusDurumu := tdBirakildi;
      end else ATus := _C;

      Result := tdBirakildi;
    end
    else
    begin

      _C := KlavyeHaritasiTR[_Sayi1];

      if(_C = TUS_KONTROL) then
      begin

        ATus := #0;
        KONTROLTusDurumu := tdBasildi;
      end
      else if(ATus = TUS_ALT) then
      begin

        ATus := #0;
        ALTTusDurumu := tdBasildi;
      end
      else if(ATus = TUS_DEGISIM) then
      begin

        ATus := #0;
        DEGISIMTusDurumu := tdBasildi;
      end else ATus := _C;

      Result := tdBasildi;
    end;
  end;
end;

end.
