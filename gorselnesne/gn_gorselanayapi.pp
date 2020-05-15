{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_gorselanayapi.pp
  Dosya ��levi: t�m g�rsel nesnelerin t�redi�i temel g�rsel ana yap�

  G�ncelleme Tarihi: 14/05/2020

  Bilgi: bu g�rsel yap�, t�m nesnelerin ihtiya� duyabilece�i ana yap�lar� i�erir

 ==============================================================================}
{$mode objfpc}
unit gn_gorselanayapi;

interface

uses gorselnesne, paylasim;

type
  PGorselAnaYapi = ^TGorselAnaYapi;

  { TGorselAnaYapi }

  TGorselAnaYapi = object(TGorselNesne)
  public
    // FCizimModel
    //   0: dolgu ve yaz� yok
    //   1: arka plan rengi yok, yaz� var
    //   2: FGovdeRenk1 = kenarl�k rengi, FGovdeRenk2 = dolgu rengi
    //   3: FGovdeRenk1'den FGovdeRenk2'ye do�ru e�imli dolgu
    FCizimModel: TSayi4;
    FGovdeRenk1, FGovdeRenk2,
    FYaziRenk: TRenk;
    function Olustur(AGorselNesneTipi: TGorselNesneTipi; AAtaKimlik: TKimlik;
      ASol, AUst, AGenislik, AYukseklik: TISayi4; ACizimModel: TSayi4;
      AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): PGorselAnaYapi;
    procedure YokEt;
    procedure Goster;
    procedure Ciz;
    procedure BaslikYaz(ABaslik: string);
    procedure GorunumYaz(AGorunum: Boolean);
  published
    property Baslik: string read FBaslik write BaslikYaz;
    property Gorunum: Boolean read FGorunum write GorunumYaz;
  end;

implementation

uses gn_islevler, temelgorselnesne, gn_pencere, gn_panel;

{==============================================================================
  g�rsel ana yap� nesnesini olu�turur
 ==============================================================================}
function TGorselAnaYapi.Olustur(AGorselNesneTipi: TGorselNesneTipi; AAtaKimlik: TKimlik;
  ASol, AUst, AGenislik, AYukseklik: TISayi4; ACizimModel: TSayi4;
  AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): PGorselAnaYapi;
var
  AtaGorselNesne: PGorselNesne;
  GorselAnaYapi: PGorselAnaYapi;
  NesneTipi: TGorselNesneTipi;
begin

  // �st nesnenin do�rulu�unu kontrol et
  NesneTipi := GorselAnaYapi^.NesneTipiniAl(AAtaKimlik);
  if(NesneTipi = gntPencere) or (NesneTipi = gntPanel) then
  begin

    AtaGorselNesne := AtaGorselNesne^.NesneyiAl(AAtaKimlik);

    // g�rsel ana yap� nesnesini olu�tur
    GorselAnaYapi := PGorselAnaYapi(Olustur0(AGorselNesneTipi));
    if(GorselAnaYapi = nil) then Exit(nil);

    // g�rsel nesneyi ata nesneye ekle
    if(GorselAnaYapi^.AtaNesneyeEkle(AtaGorselNesne) = False) then
    begin

      // hata olmas� durumunda nesneyi yok et ve i�levden ��k
      GorselAnaYapi^.YokEt0;
      Exit(nil);
    end;

    // temel nesne de�erlerini ata
    GorselAnaYapi^.GorevKimlik := CalisanGorev;
    GorselAnaYapi^.AtaNesne := AtaGorselNesne;

    // nesne olaylar� �nde�er olarak nesneyi olu�turan programa y�nlendirilecek
    // aksi durumda belirtilen �a�r� adresine y�nlendirilecek
    GorselAnaYapi^.FEfendiNesne := nil;
    GorselAnaYapi^.FEfendiNesneOlayCagriAdresi := nil;

    GorselAnaYapi^.Hiza := hzYok;

    GorselAnaYapi^.FBoyutlar.Sol2 := ASol;
    GorselAnaYapi^.FBoyutlar.Ust2 := AUst;
    GorselAnaYapi^.FBoyutlar.Genislik2 := AGenislik;
    GorselAnaYapi^.FBoyutlar.Yukseklik2 := AYukseklik;

    // kenar kal�nl�klar�
    GorselAnaYapi^.FKalinlik.Sol := 0;
    GorselAnaYapi^.FKalinlik.Ust := 0;
    GorselAnaYapi^.FKalinlik.Sag := 0;
    GorselAnaYapi^.FKalinlik.Alt := 0;

    // kenar bo�luklar�
    GorselAnaYapi^.FKenarBosluklari.Sol := 0;
    GorselAnaYapi^.FKenarBosluklari.Ust := 0;
    GorselAnaYapi^.FKenarBosluklari.Sag := 0;
    GorselAnaYapi^.FKenarBosluklari.Alt := 0;

    GorselAnaYapi^.FAtaNesneMi := False;

    // alt nesnelerin bellek adresi (nil = bellek olu�turulmad�)
    GorselAnaYapi^.FAltNesneBellekAdresi := nil;

    // nesnenin alt nesne say�s�
    GorselAnaYapi^.AltNesneSayisi := 0;

    // nesnenin �zerine gelindi�inde g�r�nt�lenecek fare g�stergesi
    GorselAnaYapi^.FareGostergeTipi := fitOK;

    // nesnenin g�r�n�m durumu
    GorselAnaYapi^.Gorunum := False;

    // nesnenin ba�l�k de�eri
    GorselAnaYapi^.FYaziHiza.Yatay := yhOrta;
    GorselAnaYapi^.FYaziHiza.Dikey := dhOrta;
    GorselAnaYapi^.Baslik := ABaslik;

    // nesnenin renk de�erleri
    GorselAnaYapi^.FCizimModel := ACizimModel;
    GorselAnaYapi^.FGovdeRenk1 := AGovdeRenk1;
    GorselAnaYapi^.FGovdeRenk2 := AGovdeRenk2;
    GorselAnaYapi^.FYaziRenk := AYaziRenk;

    GorselAnaYapi^.FEtiket := 0;

    // nesnenin ad de�eri
    GorselAnaYapi^.NesneAdi := 'tan�ms�z';

    // nesne adresini geri d�nd�r
    Result := GorselAnaYapi;

  end else Result := nil;
end;

{==============================================================================
  g�rsel ana yap� nesnesini yok eder
 ==============================================================================}
procedure TGorselAnaYapi.YokEt;
begin

  YokEt0;
end;

{==============================================================================
  g�rsel ana nesnesini g�r�nt�ler
 ==============================================================================}
procedure TGorselAnaYapi.Goster;
var
  Pencere: PPencere;
  GorselAnaYapi: PGorselAnaYapi;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  GorselAnaYapi := PGorselAnaYapi(GorselAnaYapi^.NesneTipiniKontrolEt(Kimlik, GorselNesneTipi));
  if(GorselAnaYapi = nil) then Exit;

  // nesne g�r�n�r durumda m� ?
  if(GorselAnaYapi^.Gorunum = False) then
  begin

    // g�rsel ana yap� nesnesinin g�r�n�rl���n� aktifle�tir
    GorselAnaYapi^.Gorunum := True;

    // ata nesne g�r�n�r durumda m�?
    if(GorselAnaYapi^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      Pencere := PencereAtaNesnesiniAl(GorselAnaYapi);

      // pencereyi g�ncelle�tir
      Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  g�rsel ana nesnesini �izer
 ==============================================================================}
procedure TGorselAnaYapi.Ciz;
var
  Pencere: PPencere;
  GorselAnaYapi: PGorselAnaYapi;
  Alan: TAlan;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  GorselAnaYapi := PGorselAnaYapi(GorselAnaYapi^.NesneTipiniKontrolEt(Kimlik, GorselNesneTipi));
  if(GorselAnaYapi = nil) then Exit;

  // ata nesne bir pencere mi?
  Pencere := PencereAtaNesnesiniAl(GorselAnaYapi);
  if(Pencere = nil) then Exit;

  // nesnenin g�r�n�m durumu yok ise �st nesneyi yeniden �iz ve ��k
  if(GorselAnaYapi^.Gorunum = False) then
  begin

    Pencere^.Guncelle;
    Exit;
  end;

  // g�rsel ana yap�n�n ata (pencere) nesnesine ba�l� (0, 0) koordinatlar�n� al
  Alan := GorselAnaYapi^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // FCizimModel = 0 = hi�bir �izim yapma
  if(FCizimModel > 0) then
  begin

    // FCizimModel = 2 = kenarl��� �iz ve i�eri�i doldur
    if(FCizimModel = 2) then

      DikdortgenDoldur(Pencere, Alan.Sol, Alan.Ust, Alan.Sag, Alan.Alt,
        FGovdeRenk1, FGovdeRenk2)

    // FCizimModel = 3 = artan renk ile (e�imli) doldur
    else if(FCizimModel = 3) then
      EgimliDoldur3(Pencere, Alan, FGovdeRenk1, FGovdeRenk2);

    // g�rsel ana yap� ba�l���n� yaz
    if(Length(FBaslik) > 0) then YaziYaz(Pencere, GorselAnaYapi^.FYaziHiza,
      Alan, FBaslik, FYaziRenk);
  end;
end;

procedure TGorselAnaYapi.BaslikYaz(ABaslik: string);
begin

  if(ABaslik = FBaslik) then Exit;

  FBaslik := ABaslik;
  Ciz;
end;

procedure TGorselAnaYapi.GorunumYaz(AGorunum: Boolean);
begin

  if(AGorunum = FGorunum) then Exit;

  FGorunum := AGorunum;
  Ciz;
end;

end.
