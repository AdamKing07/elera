{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_karmaliste.pas
  Dosya İşlevi: karma liste (açılır / kapanır liste kutusu (TComboBox)) yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_karmaliste;

interface

type
  PKarmaListe = ^TKarmaListe;
  TKarmaListe = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function SeciliYaziAl: string;
    function ElemanSayisi: TSayi4;
    procedure BaslikSiraNoYaz(ASiraNo: TISayi4);

    property Kimlik: TKimlik read FKimlik;
  end;

function _KarmaListeOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _KarmaListeGoster(AKimlik: TKimlik); assembler;
procedure _KarmaListeHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _KarmaListeElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _KarmaListeTemizle(AKimlik: TKimlik); assembler;
procedure _KarmaListeSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
function _KarmaListeElemanSayisi(AKimlik: TKimlik): TSayi4; assembler;
procedure _KarmaListeBaslikSiraNoYaz(AKimlik: TKimlik; ASiraNo: TISayi4); assembler;

implementation

function TKarmaListe.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _KarmaListeOlustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik);
  Result := FKimlik;
end;

procedure TKarmaListe.Goster;
begin

  _KarmaListeGoster(FKimlik);
end;

procedure TKarmaListe.Hizala(AHiza: THiza);
begin

  _KarmaListeHizala(FKimlik, AHiza);
end;

procedure TKarmaListe.ElemanEkle(AElemanAdi: string);
begin

  _KarmaListeElemanEkle(FKimlik, AElemanAdi);
end;

procedure TKarmaListe.Temizle;
begin

  _KarmaListeTemizle(FKimlik);
end;

function TKarmaListe.SeciliYaziAl: string;
var
  s: string;
begin

  _KarmaListeSeciliYaziAl(FKimlik, Isaretci(@s[0]));
  Result := s;
end;

function TKarmaListe.ElemanSayisi: TSayi4;
begin

  Result := _KarmaListeElemanSayisi(FKimlik);
end;

procedure TKarmaListe.BaslikSiraNoYaz(ASiraNo: TISayi4);
begin

  _KarmaListeBaslikSiraNoYaz(FKimlik, ASiraNo);
end;

function _KarmaListeOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
asm
  push  DWORD AYukseklik
  push  DWORD AGenislik
  push  DWORD AUst
  push  DWORD ASol
  push  DWORD AAtaKimlik
  mov   eax,KARMALISTE_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _KarmaListeGoster(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,KARMALISTE_GOSTER
  int   $34
  add   esp,4
end;

procedure _KarmaListeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  DWORD AHiza
  push  DWORD AKimlik
  mov   eax,KARMALISTE_HIZALA
  int   $34
  add   esp,8
end;

procedure _KarmaListeElemanEkle(AKimlik: TKimlik; AElemanAdi: string);
asm
  push  DWORD AElemanAdi
  push  DWORD AKimlik
  mov   eax,KARMALISTE_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _KarmaListeTemizle(AKimlik: TKimlik);
asm
  push  DWORD AKimlik
  mov   eax,KARMALISTE_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _KarmaListeSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  DWORD AHedefBellek
  push  DWORD AKimlik
  mov   eax,KARMALISTE_SECILIYAZIAL
  int   $34
  add   esp,8
end;

function _KarmaListeElemanSayisi(AKimlik: TKimlik): TSayi4; assembler;
asm
  push  DWORD AKimlik
  mov   eax,KARMALISTE_TOPLAMAL
  int   $34
  add   esp,4
end;

procedure _KarmaListeBaslikSiraNoYaz(AKimlik: TKimlik; ASiraNo: TISayi4); assembler;
asm
  push  DWORD ASiraNo
  push  DWORD AKimlik
  mov   eax,KARMALISTE_BASLIKSNYAZ
  int   $34
  add   esp,8
end;

end.
