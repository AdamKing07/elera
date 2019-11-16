{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: baglanti.pas
  Dosya İşlevi: ağ bağlantı (soket) yönetim işlevlerini içerir
  İşlev No: 0x12

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit baglanti;

interface

type
  PBaglanti = ^TBaglanti;
  TBaglanti = object
  private
    FBaglanti: TKimlik;
  public
    function Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres;
      {AKaynakIPAdres, } AHedefPort: TSayi2): TISayi4;
    function Baglan: Integer;
    function BagliMi: Boolean;
    function VeriUzunluguAl: TISayi4;
    function VeriOku(ABellek: Isaretci): TISayi4;
    procedure VeriYaz(ABellek: Isaretci; AUzunluk: TISayi4);
    function BaglantiyiKes: Boolean;
    property Baglanti: TKimlik read FBaglanti;
  end;

function _Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres;
  AHedefPort: TSayi2): TISayi4;
function _Baglan(ABaglanti: TKimlik): TISayi4;
function _BagliMi(ABaglanti: TKimlik): Boolean;
function _VeriUzunluguAl(ABaglanti: TKimlik): TISayi4;
function _VeriOku(ABaglanti: TKimlik; ABellek: Isaretci): TISayi4;
procedure _VeriYaz(ABaglanti: TKimlik; ABellek: Isaretci; AUzunluk: TISayi4);
function _BaglantiyiKes(ABaglanti: TKimlik): Boolean;

implementation

function TBaglanti.Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres;
  {AKaynakIPAdres, } AHedefPort: TSayi2): TISayi4;
begin

  FBaglanti := _Olustur(AProtokolTip, AHedefIPAdres, AHedefPort);
  Result := FBaglanti;
end;

function TBaglanti.Baglan: Integer;
begin

  Result := _Baglan(FBaglanti);
end;

function TBaglanti.BagliMi: Boolean;
begin

  Result := _BagliMi(FBaglanti);
end;

function TBaglanti.VeriUzunluguAl: TISayi4;
begin

  Result := _VeriUzunluguAl(FBaglanti);
end;

function TBaglanti.VeriOku(ABellek: Isaretci): TISayi4;
begin

  Result := _VeriOku(FBaglanti, ABellek);
end;

procedure TBaglanti.VeriYaz(ABellek: Isaretci; AUzunluk: TISayi4);
begin

  _VeriYaz(FBaglanti, ABellek, AUzunluk);
end;

function TBaglanti.BaglantiyiKes: Boolean;
begin

  Result := _BaglantiyiKes(FBaglanti);
  FBaglanti := -1;
end;

function _Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres;
  AHedefPort: TSayi2): TISayi4; assembler;
asm
  push  AHedefPort
  push  DWORD AHedefIPAdres
  push  DWORD AProtokolTip
  mov   eax,BAGLANTI0_OLUSTUR
  int   $34
  add   esp,12
end;

function _Baglan(ABaglanti: TKimlik): TISayi4; assembler;
asm
  push  ABaglanti
  mov   eax,BAGLANTI0_BAGLAN
  int   $34
  add   esp,4
end;

function _BagliMi(ABaglanti: TKimlik): Boolean; assembler;
asm
  push  ABaglanti
  mov   eax,BAGLANTI0_BAGLIMI
  int   $34
  add   esp,4
end;

function _VeriUzunluguAl(ABaglanti: TKimlik): TISayi4; assembler;
asm
  push  ABaglanti
  mov   eax,BAGLANTI0_VERIUZUNLUGU
  int   $34
  add   esp,4
end;

function _VeriOku(ABaglanti: TKimlik; ABellek: Isaretci): TISayi4; assembler;
asm
  push  ABellek
  push  ABaglanti
  mov   eax,BAGLANTI0_VERIOKU
  int   $34
  add   esp,8
end;

procedure _VeriYaz(ABaglanti: TKimlik; ABellek: Isaretci; AUzunluk: TISayi4); assembler;
asm
  push  AUzunluk
  push  ABellek
  push  ABaglanti
  mov   eax,BAGLANTI0_VERIYAZ
  int   $34
  add   esp,12
end;

function _BaglantiyiKes(ABaglanti: TKimlik): Boolean; assembler;
asm
  push  ABaglanti
  mov   eax,BAGLANTI0_BAGKES
  int   $34
  add   esp,4
end;

end.
