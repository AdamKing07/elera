{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_gorselanayapi.pp
  Dosya Ýþlevi: tüm görsel nesnelerin türediði temel görsel ana yapý

  Güncelleme Tarihi: 14/05/2020

  Bilgi: bu görsel yapý, tüm nesnelerin ihtiyaç duyabileceði ana yapýlarý içerir

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
    //   0: dolgu ve yazý yok
    //   1: arka plan rengi yok, yazý var
    //   2: FGovdeRenk1 = kenarlýk rengi, FGovdeRenk2 = dolgu rengi
    //   3: FGovdeRenk1'den FGovdeRenk2'ye doðru eðimli dolgu
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
  görsel ana yapý nesnesini oluþturur
 ==============================================================================}
function TGorselAnaYapi.Olustur(AGorselNesneTipi: TGorselNesneTipi; AAtaKimlik: TKimlik;
  ASol, AUst, AGenislik, AYukseklik: TISayi4; ACizimModel: TSayi4;
  AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): PGorselAnaYapi;
var
  AtaGorselNesne: PGorselNesne;
  GorselAnaYapi: PGorselAnaYapi;
  NesneTipi: TGorselNesneTipi;
begin

  // üst nesnenin doðruluðunu kontrol et
  NesneTipi := GorselAnaYapi^.NesneTipiniAl(AAtaKimlik);
  if(NesneTipi = gntPencere) or (NesneTipi = gntPanel) then
  begin

    AtaGorselNesne := AtaGorselNesne^.NesneyiAl(AAtaKimlik);

    // görsel ana yapý nesnesini oluþtur
    GorselAnaYapi := PGorselAnaYapi(Olustur0(AGorselNesneTipi));
    if(GorselAnaYapi = nil) then Exit(nil);

    // görsel nesneyi ata nesneye ekle
    if(GorselAnaYapi^.AtaNesneyeEkle(AtaGorselNesne) = False) then
    begin

      // hata olmasý durumunda nesneyi yok et ve iþlevden çýk
      GorselAnaYapi^.YokEt0;
      Exit(nil);
    end;

    // temel nesne deðerlerini ata
    GorselAnaYapi^.GorevKimlik := CalisanGorev;
    GorselAnaYapi^.AtaNesne := AtaGorselNesne;

    // nesne olaylarý öndeðer olarak nesneyi oluþturan programa yönlendirilecek
    // aksi durumda belirtilen çaðrý adresine yönlendirilecek
    GorselAnaYapi^.FEfendiNesne := nil;
    GorselAnaYapi^.FEfendiNesneOlayCagriAdresi := nil;

    GorselAnaYapi^.Hiza := hzYok;

    GorselAnaYapi^.FBoyutlar.Sol2 := ASol;
    GorselAnaYapi^.FBoyutlar.Ust2 := AUst;
    GorselAnaYapi^.FBoyutlar.Genislik2 := AGenislik;
    GorselAnaYapi^.FBoyutlar.Yukseklik2 := AYukseklik;

    // kenar kalýnlýklarý
    GorselAnaYapi^.FKalinlik.Sol := 0;
    GorselAnaYapi^.FKalinlik.Ust := 0;
    GorselAnaYapi^.FKalinlik.Sag := 0;
    GorselAnaYapi^.FKalinlik.Alt := 0;

    // kenar boþluklarý
    GorselAnaYapi^.FKenarBosluklari.Sol := 0;
    GorselAnaYapi^.FKenarBosluklari.Ust := 0;
    GorselAnaYapi^.FKenarBosluklari.Sag := 0;
    GorselAnaYapi^.FKenarBosluklari.Alt := 0;

    GorselAnaYapi^.FAtaNesneMi := False;

    // alt nesnelerin bellek adresi (nil = bellek oluþturulmadý)
    GorselAnaYapi^.FAltNesneBellekAdresi := nil;

    // nesnenin alt nesne sayýsý
    GorselAnaYapi^.AltNesneSayisi := 0;

    // nesnenin üzerine gelindiðinde görüntülenecek fare göstergesi
    GorselAnaYapi^.FareGostergeTipi := fitOK;

    // nesnenin görünüm durumu
    GorselAnaYapi^.Gorunum := False;

    // nesnenin baþlýk deðeri
    GorselAnaYapi^.FYaziHiza.Yatay := yhOrta;
    GorselAnaYapi^.FYaziHiza.Dikey := dhOrta;
    GorselAnaYapi^.Baslik := ABaslik;

    // nesnenin renk deðerleri
    GorselAnaYapi^.FCizimModel := ACizimModel;
    GorselAnaYapi^.FGovdeRenk1 := AGovdeRenk1;
    GorselAnaYapi^.FGovdeRenk2 := AGovdeRenk2;
    GorselAnaYapi^.FYaziRenk := AYaziRenk;

    GorselAnaYapi^.FEtiket := 0;

    // nesnenin ad deðeri
    GorselAnaYapi^.NesneAdi := 'tanýmsýz';

    // nesne adresini geri döndür
    Result := GorselAnaYapi;

  end else Result := nil;
end;

{==============================================================================
  görsel ana yapý nesnesini yok eder
 ==============================================================================}
procedure TGorselAnaYapi.YokEt;
begin

  YokEt0;
end;

{==============================================================================
  görsel ana nesnesini görüntüler
 ==============================================================================}
procedure TGorselAnaYapi.Goster;
var
  Pencere: PPencere;
  GorselAnaYapi: PGorselAnaYapi;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  GorselAnaYapi := PGorselAnaYapi(GorselAnaYapi^.NesneTipiniKontrolEt(Kimlik, GorselNesneTipi));
  if(GorselAnaYapi = nil) then Exit;

  // nesne görünür durumda mý ?
  if(GorselAnaYapi^.Gorunum = False) then
  begin

    // görsel ana yapý nesnesinin görünürlüðünü aktifleþtir
    GorselAnaYapi^.Gorunum := True;

    // ata nesne görünür durumda mý?
    if(GorselAnaYapi^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      Pencere := PencereAtaNesnesiniAl(GorselAnaYapi);

      // pencereyi güncelleþtir
      Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  görsel ana nesnesini çizer
 ==============================================================================}
procedure TGorselAnaYapi.Ciz;
var
  Pencere: PPencere;
  GorselAnaYapi: PGorselAnaYapi;
  Alan: TAlan;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  GorselAnaYapi := PGorselAnaYapi(GorselAnaYapi^.NesneTipiniKontrolEt(Kimlik, GorselNesneTipi));
  if(GorselAnaYapi = nil) then Exit;

  // ata nesne bir pencere mi?
  Pencere := PencereAtaNesnesiniAl(GorselAnaYapi);
  if(Pencere = nil) then Exit;

  // nesnenin görünüm durumu yok ise üst nesneyi yeniden çiz ve çýk
  if(GorselAnaYapi^.Gorunum = False) then
  begin

    Pencere^.Guncelle;
    Exit;
  end;

  // görsel ana yapýnýn ata (pencere) nesnesine baðlý (0, 0) koordinatlarýný al
  Alan := GorselAnaYapi^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // FCizimModel = 0 = hiçbir çizim yapma
  if(FCizimModel > 0) then
  begin

    // FCizimModel = 2 = kenarlýðý çiz ve içeriði doldur
    if(FCizimModel = 2) then

      DikdortgenDoldur(Pencere, Alan.Sol, Alan.Ust, Alan.Sag, Alan.Alt,
        FGovdeRenk1, FGovdeRenk2)

    // FCizimModel = 3 = artan renk ile (eðimli) doldur
    else if(FCizimModel = 3) then
      EgimliDoldur3(Pencere, Alan, FGovdeRenk1, FGovdeRenk2);

    // görsel ana yapý baþlýðýný yaz
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
