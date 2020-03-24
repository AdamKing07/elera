{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_baglanti.pas
  Dosya İşlevi: bağlantı (link) nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_baglanti;

interface

uses gorselnesne, paylasim;

type
  PBaglanti = ^TBaglanti;
  TBaglanti = object(TGorselNesne)
  private
    FOdakMevcut: Boolean;
    FNormalColor, FOdakRenk: TRenk;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk, AOdakRenk:
      TRenk; ABaslik: string): PBaglanti;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function BaglantiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk, AOdakRenk: TRenk;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  bağlantı (link) nesne kesme çağrılarını yönetir
 ==============================================================================}
function BaglantiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Baglanti: PBaglanti;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PRenk(Degiskenler + 12)^, PRenk(Degiskenler + 16)^,
        PShortString(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _Baglanti := PBaglanti(_Baglanti^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Baglanti^.Goster;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  bağlantı (link) nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk, AOdakRenk: TRenk;
  ABaslik: string): TKimlik;
var
  _Baglanti: PBaglanti;
begin

  _Baglanti := _Baglanti^.Olustur(AAtaKimlik, A1, B1, ANormalRenk, AOdakRenk, ABaslik);

  if(_Baglanti = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Baglanti^.Kimlik;
end;

{==============================================================================
  bağlantı (link) nesnesini oluşturur
 ==============================================================================}
function TBaglanti.Olustur(AAtaKimlik: TKimlik; A1, B1: TISayi4; ANormalRenk,
  AOdakRenk: TRenk; ABaslik: string): PBaglanti;
var
  _AtaNesne: PGorselNesne;
  _Baglanti: PBaglanti;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // bağlantı nesnesi için bellekte yer ayır
  _Baglanti := PBaglanti(Olustur0(gntBaglanti));
  if(_Baglanti = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // bağlantı nesnesini üst nesneye ekle
  if(_Baglanti^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Baglanti^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Baglanti^.GorevKimlik := CalisanGorev;
  _Baglanti^.AtaNesne := _AtaNesne;
  _Baglanti^.Hiza := hzYok;
  _Baglanti^.FBoyutlar.Sol2 := A1;
  _Baglanti^.FBoyutlar.Ust2 := B1;
  _Baglanti^.FBoyutlar.Genislik2 := Length(ABaslik) * 8;
  _Baglanti^.FBoyutlar.Yukseklik2 := 16;

  // kenar kalınlıkları
  _Baglanti^.FKalinlik.Sol := 0;
  _Baglanti^.FKalinlik.Ust := 0;
  _Baglanti^.FKalinlik.Sag := 0;
  _Baglanti^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Baglanti^.FKenarBosluklari.Sol := 0;
  _Baglanti^.FKenarBosluklari.Ust := 0;
  _Baglanti^.FKenarBosluklari.Sag := 0;
  _Baglanti^.FKenarBosluklari.Alt := 0;

  _Baglanti^.FAtaNesneMi := False;
  _Baglanti^.FareGostergeTipi := fitEl;
  _Baglanti^.Gorunum := False;
  _Baglanti^.FNormalColor := ANormalRenk;
  _Baglanti^.FOdakRenk := AOdakRenk;
  _Baglanti^.FOdakMevcut := False;

  // nesnenin ad ve başlık değeri
  _Baglanti^.NesneAdi := NesneAdiAl(gntBaglanti);
  _Baglanti^.Baslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_Baglanti^.GorevKimlik]^.OlayEkle1(_Baglanti^.GorevKimlik,
    _Baglanti, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Baglanti;
end;

{==============================================================================
  bağlantı (link) nesnesini görüntüler
 ==============================================================================}
procedure TBaglanti.Goster;
var
  _Pencere: PPencere;
  _Baglanti: PBaglanti;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Baglanti := PBaglanti(_Baglanti^.NesneTipiniKontrolEt(Kimlik, gntBaglanti));
  if(_Baglanti = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Baglanti^.Gorunum = False) then
  begin

    // bağlantı nesnesinin görünürlüğünü aktifleştir
    _Baglanti^.Gorunum := True;

    // bağlantı nesnesi ve üst nesneler görünür durumda mı ?
    if(_Baglanti^.AtaNesneGorunurMu) then
    begin

      // görünür ise bağlantı nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Baglanti);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  bağlantı (link) nesnesini çizer
 ==============================================================================}
procedure TBaglanti.Ciz;
var
  _Pencere: PPencere;
  _Baglanti: PBaglanti;
  _Alan: TAlan;
begin

  _Baglanti := PBaglanti(_Baglanti^.NesneTipiniKontrolEt(Kimlik, gntBaglanti));
  if(_Baglanti = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Baglanti);
  if(_Pencere = nil) then Exit;

  // bağlantı nesnesinin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _Baglanti^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // bağlantı başlığını yaz
  if(FOdakMevcut) then

    YaziYaz(_Pencere, _Alan.A1, _Alan.B1, _Baglanti^.Baslik, FOdakRenk)
  else YaziYaz(_Pencere, _Alan.A1, _Alan.B1, _Baglanti^.Baslik, FNormalColor);

  // uygulamaya mesaj gönder
  {GorevListesi[_Baglanti^.GorevKimlik]^.OlayEkle1(_Baglanti^.GorevKimlik,
    _Baglanti, CEKIRDEK_PNC_CIZIM, 0, 0);}
end;

{==============================================================================
  bağlantı (link) nesne olaylarını işler
 ==============================================================================}
procedure TBaglanti.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Baglanti: PBaglanti;
begin

  _Baglanti := PBaglanti(_Baglanti^.NesneTipiniKontrolEt(AKimlik, gntBaglanti));
  if(_Baglanti = nil) then Exit;

  // bağlantının sahibi olan pencere en üstte mi ? kontrol et
  _Pencere := PencereAtaNesnesiniAl(_Baglanti);

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // fare olaylarını yakala
    OlayYakalamayaBasla(_Baglanti);

    // uygulamaya mesaj gönder
    GorevListesi[_Baglanti^.GorevKimlik]^.OlayEkle1(_Baglanti^.GorevKimlik,
      _Baglanti, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_Baglanti);

    // uygulamaya mesaj gönder
    GorevListesi[_Baglanti^.GorevKimlik]^.OlayEkle1(_Baglanti^.GorevKimlik,
      _Baglanti, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Baglanti^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_Baglanti^.GorevKimlik]^.OlayEkle1(_Baglanti^.GorevKimlik,
        _Baglanti, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = CO_ODAKKAZANILDI) then
  begin

    _Baglanti^.FOdakMevcut := True;

    // bağlantı nesnesini yeniden çiz
    _Pencere^.Guncelle;
  end
  else if(AOlay.Olay = CO_ODAKKAYBEDILDI) then
  begin

    _Baglanti^.FOdakMevcut := False;

    // bağlantı nesnesini yeniden çiz
    _Pencere^.Guncelle;
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
