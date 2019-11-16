{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_defter.pas
  Dosya İşlevi: defter nesnesi (memo) yönetim işlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_defter;

interface

uses gorselnesne, paylasim;

type
  PDefter = ^TDefter;
  TDefter = object(TGorselNesne)
  public
    FDefterRenk, FYaziRenk: TRenk;
    FYaziUzunlugu: TSayi4;
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADefterRenk, AYaziRenk: TRenk): PDefter;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Ciz;
    procedure Temizle;
    procedure YaziEkle(AYaziBellekAdresi: Isaretci);
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
function DefterCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses gn_islevler, gn_pencere, genel, temelgorselnesne;

{==============================================================================
  defter kesme çağrılarını yönetir
 ==============================================================================}
function DefterCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _Defter: PDefter;
  _Hiza: THiza;
begin

  case IslevNo of
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PRenk(Degiskenler + 20)^, PRenk(Degiskenler + 24)^);

    ISLEV_GOSTER:
    begin

      _Defter := PDefter(_Defter^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Defter^.Goster;
    end;

    // defter nesnesine veri ekle
    $0100:
    begin

      // nesnenin handle, tip değerlerini denetle.
      _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntDefter));
      if(_Defter <> nil) then
      begin

        _Defter^.YaziEkle(Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi));
        Result := 1;
      end;
    end;

    // defter nesnesinin içerisindeki verileri sil
    $0200:
    begin

      // nesnenin kimlik, tip değerlerini denetle.
      _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntDefter));
      if(_Defter <> nil) then
      begin

        _Defter^.Temizle;
      end;
    end;

    $0104:
    begin

      _Defter := PDefter(_Defter^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _Defter^.Hiza := _Hiza;

      _Pencere := PPencere(_Defter^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
var
  _Defter: PDefter;
begin

  _Defter := _Defter^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADefterRenk,
    AYaziRenk);

  if(_Defter = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Defter^.Kimlik;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function TDefter.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): PDefter;
var
  _AtaNesne: PGorselNesne;
  _Defter: PDefter;
  _YaziBellekAdresi: Isaretci;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // defter nesnesi için kimlik oluştur
  _Defter := PDefter(Olustur0(gntDefter));
  if(_Defter = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // defter nesnesini ata nesneye ekle
  if(_Defter^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Defter^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Defter^.GorevKimlik := AktifGorev;
  _Defter^.AtaNesne := _AtaNesne;
  _Defter^.Hiza := hzYok;
  _Defter^.FBoyutlar.Sol2 := A1;
  _Defter^.FBoyutlar.Ust2 := B1;
  _Defter^.FBoyutlar.Genislik2 := AGenislik;
  _Defter^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _Defter^.FKalinlik.Sol := 0;
  _Defter^.FKalinlik.Ust := 0;
  _Defter^.FKalinlik.Sag := 0;
  _Defter^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Defter^.FKenarBosluklari.Sol := 0;
  _Defter^.FKenarBosluklari.Ust := 0;
  _Defter^.FKenarBosluklari.Sag := 0;
  _Defter^.FKenarBosluklari.Alt := 0;

  _Defter^.FAtaNesneMi := False;
  _Defter^.FareGostergeTipi := fitGiris;
  _Defter^.Gorunum := False;
  _Defter^.FDefterRenk := ADefterRenk;
  _Defter^.FYaziRenk := AYaziRenk;

  // defter nesnesinin içeriği için bellek rezerv et
  _YaziBellekAdresi := GGercekBellek.Ayir(4095);
  _Defter^.FAltNesneBellekAdresi := _YaziBellekAdresi;
  _Defter^.FYaziUzunlugu := 0;

  // nesnenin ad ve başlık değeri
  _Defter^.NesneAdi := NesneAdiAl(gntDefter);
  _Defter^.Baslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_Defter^.GorevKimlik]^.OlayEkle1(_Defter^.GorevKimlik, _Defter,
    CO_OLUSTUR, 0, 0);

  // kimlik değerini geri döndür
  Result := _Defter;
end;

{==============================================================================
  nesne ve nesneye ayrılan kaynakları yok eder
 ==============================================================================}
procedure TDefter.YokEt(AKimlik: TKimlik);
var
  _Defter: PDefter;
begin

  // AtaNesne nesnesinin doğruluğunu kontrol et
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(AKimlik, gntDefter));
  if(_Defter = nil) then Exit;

  if(_Defter^.FAltNesneBellekAdresi <> nil) then
    GGercekBellek.YokEt(_Defter^.FAltNesneBellekAdresi, 4096);

  YokEt0;
end;

{==============================================================================
  defter nesnesini görüntüler
 ==============================================================================}
procedure TDefter.Goster;
var
  _Pencere: PPencere;
  _Defter: PDefter;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(Kimlik, gntDefter));
  if(_Defter = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Defter^.Gorunum = False) then
  begin

    // defter nesnesinin görünürlüğünü aktifleştir
    _Defter^.Gorunum := True;

    // defter nesnesi ve üst nesneler görünür durumda mı ?
    if(_Defter^.AtaNesneGorunurMu) then
    begin

      // görünür ise defter nesnesinin ata nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Defter);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  defter nesnesini çizer
 ==============================================================================}
procedure TDefter.Ciz;
var
  _Pencere: PPencere;
  _Defter: PDefter;
  _Alan: TAlan;
  _A1, _B1: TISayi4;
  _YaziBellekAdresi: PChar;
  _SatirGenisligi: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(Kimlik, gntDefter));
  if(_Defter = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Defter);
  if(_Pencere = nil) then Exit;

  // defterin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _Defter^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarlık çizgisini çiz
  KenarlikCiz(_Pencere, _Alan, 2);

  // iç dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.A1 + 2, _Alan.B1 + 2, _Alan.A2 - 2, _Alan.B2 - 2,
    _Defter^.FDefterRenk, _Defter^.FDefterRenk);

  // eğer defter nesnesi için bellek ayrıldıysa defter içeriğini nesne içeriğine
  // eklenen bilgilerle doldur
  if(Self.FAltNesneBellekAdresi <> nil) and (Self.FYaziUzunlugu > 0) then
  begin

    // _A1 ve _B1 başlangıç değerleri
    _A1 := _Alan.A1 + 4;
    _B1 := _Alan.B1 + 4;

    // defter içerik bellek bölgesine konumlan
    _YaziBellekAdresi := PChar(Self.FAltNesneBellekAdresi);

    _SatirGenisligi := 0;

    // bellek içeriği sıfır oluncaya kadar devam et
    while (_YaziBellekAdresi^ <> #0) do
    begin

      // giriş (enter) tuşu olması durumunda herhangi birşey yapma
      if(_YaziBellekAdresi^ = #13) then
      begin

        Inc(_YaziBellekAdresi);
      end

      // satır başı + bir alt satıra geç
      else if(_YaziBellekAdresi^ = #10) then
      begin

        Inc(_YaziBellekAdresi);
        _B1 += 16;
        _A1 := _Alan.A1 + 4;
        _SatirGenisligi := 0;
      end
      else
      begin

        HarfYaz(_Pencere, _A1, _B1, _YaziBellekAdresi^, _Defter^.FYaziRenk);
        _SatirGenisligi += 8;
        if(_A1 > _Alan.A2) then
        begin

          _B1 += 16;
          _A1 := _Alan.A1 + 4;
          _SatirGenisligi := 0;
        end else _A1 += 8;

        Inc(_YaziBellekAdresi);
      end;
    end;
  end;
end;

{==============================================================================
  defter nesnesinin içeriğindeki verileri siler
 ==============================================================================}
procedure TDefter.Temizle;
begin

  Self.FYaziUzunlugu := 0;

  BellekDoldur(Self.FAltNesneBellekAdresi, 4096, 0);

  Ciz;
end;

{==============================================================================
  defter nesnesine karakter katarı ekler
 ==============================================================================}
procedure TDefter.YaziEkle(AYaziBellekAdresi: Isaretci);
var
  p: PSayi1;
  _Uzunluk: TSayi4;
begin

  // karakter katarı için bellek ayrılmış mı ?
  if(Self.FAltNesneBellekAdresi = nil) then Exit;

  // verinin uzunluğunu al
  _Uzunluk := StrLen(AYaziBellekAdresi);
  if(_Uzunluk = 0) or (_Uzunluk > 4096) then Exit;

  // karakter katarını hedef bölgeye kopyala
  p := PByte(Self.FAltNesneBellekAdresi);
  Tasi2(AYaziBellekAdresi, p, _Uzunluk);

  // sıfır sonlandırma işaretini ekle
  FYaziUzunlugu += _Uzunluk;
  p := PByte(Self.FAltNesneBellekAdresi + FYaziUzunlugu);
  p^ := 0;

  Ciz;
end;

{==============================================================================
  defter nesne olaylarını işler
 ==============================================================================}
procedure TDefter.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Defter: PDefter;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(AKimlik, gntDefter));
  if(_Defter = nil) then Exit;

  // sol mouse tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // defterin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_Defter);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;
  end;

  // uygulamaya mesaj gönder
  GorevListesi[_Defter^.GorevKimlik]^.OlayEkle1(_Defter^.GorevKimlik, _Defter,
    AOlay.Olay, AOlay.Deger1, AOlay.Deger2);

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
