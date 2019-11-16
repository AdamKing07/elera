{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_islemgostergesi.pas
  Dosya İşlevi: işlem göstergesi (progress bar) yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_islemgostergesi;

interface

uses gorselnesne, paylasim;

type
  PIslemGostergesi = ^TIslemGostergesi;
  TIslemGostergesi = object(TGorselNesne)
  public
    FAltDeger, FUstDeger, FPozisyon: TISayi4;
    procedure DegerleriBelirle(AAltDeger, AUstDeger: TISayi4);
    procedure PozisyonYaz(APozisyon: TISayi4);
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PIslemGostergesi;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function IslemGostergesiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function ObjCreate(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_pencere, temelgorselnesne, gn_islevler, giysi;

{==============================================================================
  işlem göstergesi kesme çağrılarını yönetir
 ==============================================================================}
function IslemGostergesiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _IslemGostergesi: PIslemGostergesi;
begin

  // $DDCCBBAA
  //      BBAA  -> kesme tarafından değerlendirildi
  // DDCC       -> IslevNo değeri
  case IslevNo of

    // nesneyi oluştur
    ISLEV_OLUSTUR:
    begin

      Result := ObjCreate(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);
    end;

    // alt, üst değerlerini belirle
    $0104:
    begin

      _IslemGostergesi := PIslemGostergesi(_IslemGostergesi^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntIslemGostergesi));
      if(_IslemGostergesi <> nil) then _IslemGostergesi^.DegerleriBelirle(
        PISayi4(Degiskenler + 04)^, PISayi4(Degiskenler + 08)^);
    end;

    // nesne gösterge pozisyonunu belirle
    $0204:
    begin

      _IslemGostergesi := PIslemGostergesi(_IslemGostergesi^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntIslemGostergesi));
      if(_IslemGostergesi <> nil) then _IslemGostergesi^.PozisyonYaz(PISayi4(Degiskenler + 04)^);
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  işlem göstergesi (progress bar) nesnesini oluşturur
 ==============================================================================}
function ObjCreate(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  _IslemGostergesi: PIslemGostergesi;
begin

  _IslemGostergesi := _IslemGostergesi^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik);

  if(_IslemGostergesi = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _IslemGostergesi^.Kimlik;
end;

{==============================================================================
  işlem göstergesi (progress bar) nesnesini oluşturur
 ==============================================================================}
function TIslemGostergesi.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PIslemGostergesi;
var
  _AtaNesne: PGorselNesne;
  _IslemGostergesi: PIslemGostergesi;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // işlem göstergesi için bellekte yer ayır
  _IslemGostergesi := PIslemGostergesi(Olustur0(gntIslemGostergesi));
  if(_IslemGostergesi = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // işlem göstergesi nesnesini üst nesneye ekle
  if(_IslemGostergesi^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _IslemGostergesi^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _IslemGostergesi^.GorevKimlik := AktifGorev;
  _IslemGostergesi^.AtaNesne := _AtaNesne;
  _IslemGostergesi^.Hiza := hzYok;
  _IslemGostergesi^.FBoyutlar.Sol2 := A1;
  _IslemGostergesi^.FBoyutlar.Ust2 := B1;
  _IslemGostergesi^.FBoyutlar.Genislik2 := AGenislik;
  _IslemGostergesi^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _IslemGostergesi^.FKalinlik.Sol := 0;
  _IslemGostergesi^.FKalinlik.Ust := 0;
  _IslemGostergesi^.FKalinlik.Sag := 0;
  _IslemGostergesi^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _IslemGostergesi^.FKenarBosluklari.Sol := 0;
  _IslemGostergesi^.FKenarBosluklari.Ust := 0;
  _IslemGostergesi^.FKenarBosluklari.Sag := 0;
  _IslemGostergesi^.FKenarBosluklari.Alt := 0;

  _IslemGostergesi^.FAtaNesneMi := False;
  _IslemGostergesi^.FareGostergeTipi := fitOK;
  _IslemGostergesi^.Gorunum := True;

  // diğer değer atamaları
  FAltDeger := 1;
  FUstDeger := 100;
  FPozisyon := 0;

  // nesnenin ad ve başlık değeri
  _IslemGostergesi^.NesneAdi := NesneAdiAl(gntIslemGostergesi);
  _IslemGostergesi^.Baslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_IslemGostergesi^.GorevKimlik]^.OlayEkle1(_IslemGostergesi^.GorevKimlik,
    _IslemGostergesi, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _IslemGostergesi;
end;

{==============================================================================
  işlem göstergesi nesnesini çizer
 ==============================================================================}
procedure TIslemGostergesi.Ciz;
var
  _Pencere: PPencere;
  _IslemGostergesi: PIslemGostergesi;
  _Alan: TAlan;
  _U1, _U2, _Frekans, _Deger: TISayi4;
begin

  _IslemGostergesi := PIslemGostergesi(_IslemGostergesi^.NesneTipiniKontrolEt(
    Kimlik, gntIslemGostergesi));
  if(_IslemGostergesi = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_IslemGostergesi);
  if(_Pencere = nil) then Exit;

  // işlem göstergesinin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _IslemGostergesi^.CizimGorselNesneBoyutlariniAl(Kimlik);

  _U1 := (FUstDeger - FAltDeger) + 1;
  _U2 := _Alan.A2;
  if(_U1 > _U2) then
  begin

    _Frekans := _U1 div _U2;
    _Deger := FPozisyon div _Frekans;
  end
  else
  begin

    _Frekans := _U2 div _U1;
    _Deger := FPozisyon * _Frekans;
  end;

  // ön renk doldurma işlemi. dolgu öncesi çizim
  DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2, RENK_BEYAZ,
    RENK_BEYAZ);

  // artan renk ile (eğimli) doldur
  _Alan.A2 := _Alan.A1 + _Deger;
  EgimliDoldur(_Pencere, _Alan, DUGME_NORMAL_ILKRENK, DUGME_NORMAL_SONRENK);

  // uygulamaya mesaj gönder
  GorevListesi[_IslemGostergesi^.GorevKimlik]^.OlayEkle1(_IslemGostergesi^.GorevKimlik,
    _IslemGostergesi, CO_CIZIM, 0, 0);
end;

{==============================================================================
  işlem göstergesi olaylarını işler
 ==============================================================================}
procedure TIslemGostergesi.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _IslemGostergesi: PIslemGostergesi;
begin

  // işlenecek hiçbir olay yok
end;

{==============================================================================
  işlem göstergesi en alt, en üst değerlerini belirler
 ==============================================================================}
procedure TIslemGostergesi.DegerleriBelirle(AAltDeger, AUstDeger: TISayi4);
begin

  FAltDeger := AAltDeger;
  FUstDeger := AUstDeger;

  Ciz;
end;

{==============================================================================
  işlem göstergesi pozisyon değerlerini belirler
 ==============================================================================}
procedure TIslemGostergesi.PozisyonYaz(APozisyon: TISayi4);
begin

  FPozisyon := APozisyon;

  Ciz;
end;

end.
