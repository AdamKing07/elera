{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_karmaliste.pas
  Dosya İşlevi: açılır / kapanır liste kutusu nesne işlevlerini içerir

  Güncelleme Tarihi: 09/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit gn_karmaliste;

interface

type
  PKarmaListe = ^TKarmaListe;

  { TKarmaListe }

  TKarmaListe = object
  private
    FKimlik: TKimlik;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
      AYukseklik: TISayi4): TKimlik;
    procedure Goster;
    procedure Hizala(AHiza: THiza);
    procedure ElemanEkle(AElemanAdi: string);
    procedure Temizle;
    function SeciliYaziAl: string;
    property Kimlik: TKimlik read FKimlik;
  end;

function _KarmaListeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
procedure _KarmaListeGoster(AKimlik: TKimlik); assembler;
procedure _KarmaListeHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _KarmaListeElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _KarmaListeTemizle(AKimlik: TKimlik); assembler;
procedure _KarmaListeSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;

implementation

function TKarmaListe.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
begin

  FKimlik := _KarmaListeOlustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
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

function _KarmaListeOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik;
asm
  push  AYukseklik
  push  AGenislik
  push  B1
  push  A1
  push  AtaKimlik
  mov   eax,KARMALISTE_OLUSTUR
  int   $34
  add   esp,20
end;

procedure _KarmaListeGoster(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,KARMALISTE_GOSTER
  int   $34
  add   esp,4
end;

procedure _KarmaListeHizala(AKimlik: TKimlik; AHiza: THiza);
asm
  push  AHiza
  push  AKimlik
  mov   eax,KARMALISTE_HIZALA
  int   $34
  add   esp,8
end;

procedure _KarmaListeElemanEkle(AKimlik: TKimlik; AElemanAdi: string);
asm
  push  AElemanAdi
  push  AKimlik
  mov   eax,KARMALISTE_ELEMANEKLE
  int   $34
  add   esp,8
end;

procedure _KarmaListeTemizle(AKimlik: TKimlik);
asm
  push  AKimlik
  mov   eax,KARMALISTE_TEMIZLE
  int   $34
  add   esp,4
end;

procedure _KarmaListeSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci);
asm
  push  AHedefBellek
  push  AKimlik
  mov   eax,KARMALISTE_SECILIYAZIAL
  int   $34
  add   esp,8
end;

end.
