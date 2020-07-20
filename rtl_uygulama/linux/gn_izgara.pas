{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_izgara.pas
  Dosya İşlevi: ızgara nesnesi (TStringGrid) yönetim işlevlerini içerir

  Güncelleme Tarihi: 20/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_izgara;

interface

type
  PIzgara = ^TIzgara;
  TIzgara = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Gizle;
    procedure Ciz;
    procedure Hizala(AHiza: THiza);
    procedure Temizle;
    procedure ElemanEkle(AElemanAdi: string);
    procedure SabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4);
    procedure HucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4);
    procedure HucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4);
    procedure KaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: Boolean);
    procedure SeciliHucreyiYaz(ASatir, ASutun: TISayi4);
    property Kimlik: TKimlik read FKimlik;
  end;

function _IzgaraOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _IzgaraGoster(AKimlik: TKimlik); assembler;
procedure _IzgaraGizle(AKimlik: TKimlik); assembler;
procedure _IzgaraCiz(AKimlik: TKimlik); assembler;
procedure _IzgaraHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _IzgaraTemizle(AKimlik: TKimlik); assembler;
procedure _IzgaraElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _IzgaraSabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4); assembler;
procedure _IzgaraHucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4); assembler;
procedure _IzgaraHucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4); assembler;
procedure _IzgaraKaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: LongBool); assembler;
procedure _IzgaraSeciliHucreyiYaz(ASatir, ASutun: TISayi4); assembler;

implementation

function TIzgara.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _IzgaraOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TIzgara.Goster;
begin

  _IzgaraGoster(FKimlik);
end;

procedure TIzgara.Gizle;
begin

  _IzgaraGizle(FKimlik);
end;

procedure TIzgara.Ciz;
begin

  _IzgaraCiz(FKimlik);
end;

procedure TIzgara.Hizala(AHiza: THiza);
begin

  _IzgaraHizala(FKimlik, AHiza);
end;

procedure TIzgara.Temizle;
begin

  _IzgaraTemizle(FKimlik);
end;

procedure TIzgara.ElemanEkle(AElemanAdi: string);
begin

  _IzgaraElemanEkle(FKimlik, AElemanAdi);
end;

procedure TIzgara.SabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4);
begin

  _IzgaraSabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi);
end;

procedure TIzgara.HucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4);
begin

  _IzgaraHucreSayisiYaz(ASatirSayisi, ASutunSayisi);
end;

procedure TIzgara.HucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4);
begin

  _IzgaraHucreBoyutuYaz(ASatirYukseklik, ASutunGenislik);
end;

procedure TIzgara.KaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: Boolean);
begin

  _IzgaraKaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster);
end;

procedure TIzgara.SeciliHucreyiYaz(ASatir, ASutun: TISayi4);
begin

  _IzgaraSeciliHucreyiYaz(ASatir, ASutun);
end;

function _IzgaraOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
asm
  push  DWORD AYukseklik
  push  DWORD AGenislik
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,IZGARA_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _IzgaraGoster(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,IZGARA_GOSTER
  int   $34
  add   esp,4
end;

procedure _IzgaraGizle(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,IZGARA_GIZLE
  int   $34
  add   esp,4
end;

procedure _IzgaraCiz(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,IZGARA_CIZ
  int   $34
  add   esp,4
end;

procedure _IzgaraHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
asm
  push  DWORD AHiza
  push  DWORD AKimlik
  mov   eax,IZGARA_HIZALA
  int   $34
  add   esp,8
end;

procedure _IzgaraTemizle(AKimlik: TKimlik); assembler;
asm
  push  DWORD AKimlik
  mov   eax,IZGARA_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _IzgaraElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
asm
  push  DWORD AElemanAdi
  push  DWORD AKimlik
  mov   eax,IZGARA_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _IzgaraSabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4); assembler;
asm
  push  DWORD ASabitSutunSayisi
  push  DWORD ASabitSatirSayisi
  mov   eax,IZGARA_SABITHUCRESAYISIYAZ
  int   $34
  add   esp,8
end;

procedure _IzgaraHucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4); assembler;
asm
  push  DWORD ASutunSayisi
  push  DWORD ASatirSayisi
  mov   eax,IZGARA_HUCRESAYISIYAZ
  int   $34
  add   esp,8
end;

procedure _IzgaraHucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4); assembler;
asm
  push  DWORD ASutunGenislik
  push  DWORD ASatirYukseklik
  mov   eax,IZGARA_HUCREBOYUTUYAZ
  int   $34
  add   esp,8
end;

procedure _IzgaraKaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: LongBool); assembler;
asm
  push  DWORD ADikeyKCGoster
  push  DWORD AYatayKCGoster
  mov   eax,IZGARA_KCUBUGUGORUNUMYAZ
  int   $34
  add   esp,8
end;

procedure _IzgaraSeciliHucreyiYaz(ASatir, ASutun: TISayi4); assembler;
asm
  push  DWORD ASutun
  push  DWORD ASatir
  mov   eax,IZGARA_SECILIHUCREYIYAZ
  int   $34
  add   esp,8
end;

end.
