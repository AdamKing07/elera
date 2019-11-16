{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sistemmesaj.pas
  Dosya İşlevi: hata ayıklama (debug) amaçlı mesaj yönetim işlevlerini içerir

  Güncelleme Tarihi: 29/09/2019

 ==============================================================================}
{$mode objfpc}
unit sistemmesaj;

interface

uses paylasim;

type
  PMesaj = ^TMesaj;
  TMesaj = record
    SiraNo: TISayi4;
    Saat: TSayi4;
    Mesaj: string;
  end;

type
  PSistemMesaj = ^TSistemMesaj;
  TSistemMesaj = object
  private
    FServisCalisiyor: Boolean;
    FToplamMesaj: Integer;
  public
    procedure Yukle;
    procedure Ekle(AMesaj: string);
    procedure MesajAl(ASiraNo: TSayi4; var AMesaj: PMesaj);
    property ServisCalisiyor: Boolean read FServisCalisiyor write FServisCalisiyor;
    property ToplamMesaj: Integer read FToplamMesaj;
  end;

procedure SISTEM_MESAJ_YAZI(AMesaj: string);
procedure SISTEM_MESAJ_YAZI(AMesaj: PWideChar);
procedure SISTEM_MESAJ_YAZI(AMesaj1, AMesaj2: string);
procedure SISTEM_MESAJ_YAZI(AMesaj: PChar; AMesajUz: TISayi4);
procedure SISTEM_MESAJ_YAZI(ABellekAdres: Isaretci; ABellekUz: TSayi4);
procedure SISTEM_MESAJ_S10(AMesaj: string; ASayi10: TISayi4);
procedure SISTEM_MESAJ_S16(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
procedure SISTEM_MESAJ_MAC(AMesaj: string; AMACAdres: TMACAdres);
procedure SISTEM_MESAJ_IP(AMesaj: string; AIPAdres: TIPAdres);

implementation

uses genel, cmos, donusum;

const
  USTSINIR_MESAJ = 32;

var
  MesajBellekAdresi: Isaretci;
  MesajListesi: array[1..USTSINIR_MESAJ] of PMesaj;

{==============================================================================
  oluşturulacak mesajların ana yükleme işlevlerini içerir
 ==============================================================================}
procedure TSistemMesaj.Yukle;
var
  i: TSayi4;
begin

  // mesajlar için bellek ayır
  MesajBellekAdresi := GGercekBellek.Ayir(USTSINIR_MESAJ * SizeOf(TMesaj));

  // bellek girişlerini mesaj yapılarıyla eşleştir
  for i := 1 to USTSINIR_MESAJ do
  begin

    MesajListesi[i] := MesajBellekAdresi;
    MesajBellekAdresi += SizeOf(TMesaj);
  end;

  // toplam mesaj sayısını sıfırla
  FToplamMesaj := 0;

  // mesaj servisini başlat
  ServisCalisiyor := True;
end;

{==============================================================================
  mesajı sistem kayıtlarına ekler
 ==============================================================================}
procedure TSistemMesaj.Ekle(AMesaj: string);
var
  Saat, Dakika, Saniye: TSayi1;
begin

  if not(ServisCalisiyor) then Exit;

  // kaydedilecek mesaj sıra numarasını belirle
  Inc(FToplamMesaj);

  // mesaj sayısı > USTSINIR_MESAJ = sayacı sıfırla
  if(FToplamMesaj > USTSINIR_MESAJ) then
  begin

    FToplamMesaj := 0;
    Inc(FToplamMesaj);
  end;

  // mesaj sıra numarası (1..USTSINIR_MESAJ)
  MesajListesi[ToplamMesaj]^.SiraNo := ToplamMesaj;

  // mesaj saati
  SaatAl(Saat, Dakika, Saniye);
  MesajListesi[ToplamMesaj]^.Saat := (Saniye shl 16) or (Dakika shl 8) or Saat;

  // mesaj
  MesajListesi[ToplamMesaj]^.Mesaj := AMesaj;
end;

{==============================================================================
  mesaj kayıtlarından istenen sıradaki mesajı alır
 ==============================================================================}
procedure TSistemMesaj.MesajAl(ASiraNo: TSayi4; var AMesaj: PMesaj);
begin

  // istenen mesajın belirtilen aralıkta olup olmadığını kontrol et
  if(ASiraNo > 0) and (ASiraNo <= USTSINIR_MESAJ) then
  begin

    AMesaj^.SiraNo := MesajListesi[ASiraNo]^.SiraNo;
    AMesaj^.Saat := MesajListesi[ASiraNo]^.Saat;
    AMesaj^.Mesaj := MesajListesi[ASiraNo]^.Mesaj;
  end;
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - sadece mesaj
 ==============================================================================}
procedure SISTEM_MESAJ_YAZI(AMesaj: string);
begin

  // sistem mesaj servisi çalışıyorsa, mesajı kayıt listesine ekle
  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(AMesaj);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - sadece mesaj (her bir karakterin 2 byte olduğu)
 ==============================================================================}
procedure SISTEM_MESAJ_YAZI(AMesaj: PWideChar);
var
  s: string;
begin

  // 16 bitlik UTF karakterini tek bytlık ascii değere çevir
  s := UTF16Ascii(AMesaj);

  SISTEM_MESAJ_YAZI(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - 2 mesajı birleştirerek
 ==============================================================================}
procedure SISTEM_MESAJ_YAZI(AMesaj1, AMesaj2: string);
var
  i, j: Integer;
  s: string;
begin

  s := '';

  // 1. karakter katarı
  j := Length(AMesaj1);
  if(j > 0) then
  begin

    for i := 1 to j do s := s + AMesaj1[i];
  end;

  // 2. karakter katarı
  j := Length(AMesaj2);
  if(j > 0) then
  begin

    for i := 1 to j do s := s + AMesaj2[i];
  end;

  SISTEM_MESAJ_YAZI(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - sadece mesaj (pchar türünde veri)
 ==============================================================================}
procedure SISTEM_MESAJ_YAZI(AMesaj: PChar; AMesajUz: TISayi4);
var
  i: Integer;
  p: PChar;
  s: string;
begin

  p := AMesaj;
  s := '';
  for i := 0 to AMesajUz - 1 do s := s + p[i];

  // sistem mesaj servisi çalışıyorsa, mesajı kayıt listesine ekle
  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - belirli bellek adresinden, belirli uzunlukta veri
 ==============================================================================}
procedure SISTEM_MESAJ_YAZI(ABellekAdres: Isaretci; ABellekUz: TSayi4);
var
  i: TSayi4;
  p: PChar;
  s: string;
begin

  p := PChar(ABellekAdres);
  s := '';
  for i := 0 to ABellekUz - 1 do s := s + p[i];

  // sistem mesaj servisi çalışıyorsa, mesajı kayıt listesine ekle
  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - mesaj + 10lu sayı sisteminde sayı birleşimi
 ==============================================================================}
procedure SISTEM_MESAJ_S10(AMesaj: string; ASayi10: TISayi4);
var
  Deger10: string[10];
  s: string;
begin

  // sayısal değeri karaktere çevir
  Deger10 := IntToStr(ASayi10);

  s := AMesaj + Deger10;

  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - mesaj + 16lı sayı sisteminde sayı birleşimi
 ==============================================================================}
procedure SISTEM_MESAJ_S16(AMesaj: string; ASayi16, AHaneSayisi: TSayi4);
var
  Deger16: string[10];
  s: string;
begin

  // sayısal değeri karaktere çevir
  Deger16 := '0x' + hexStr(ASayi16, AHaneSayisi);

  s := AMesaj + Deger16;

  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - mesaj + mac adres birleşimi
 ==============================================================================}
procedure SISTEM_MESAJ_MAC(AMesaj: string; AMACAdres: TMACAdres);
var
  _MACAdres: string[17];
  s: string;
begin

  // mac adres değerini karaktere çevir
  _MACAdres := MacToStr(AMACAdres);

  s := AMesaj + _MACAdres;

  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

{==============================================================================
  sistem kayıtlarına mesaj ekle - mesaj + ip adres birleşimi
 ==============================================================================}
procedure SISTEM_MESAJ_IP(AMesaj: string; AIPAdres: TIPAdres);
var
  _IPAdres: string[15];
  s: string;
begin

  // ip adres değerini karaktere çevir
  _IPAdres := IpToStr(AIPAdres);

  s := AMesaj + _IPAdres;

  if(GSistemMesaj.ServisCalisiyor) then GSistemMesaj.Ekle(s);
end;

end.
