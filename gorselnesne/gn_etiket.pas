{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_etiket.pas
  Dosya İşlevi: etiket (label) nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_etiket;

interface

uses gorselnesne, paylasim;

type
  PEtiket = ^TEtiket;
  TEtiket = object(TGorselNesne)
  private
    FYaziRenk: TRenk;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1: TSayi4; AYaziRenk: TRenk;
      ABaslik: string): PEtiket;
    procedure Goster;
    procedure Guncelle;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function EtiketCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  etiket (label) nesne kesme çağrılarını yönetir
 ==============================================================================}
function EtiketCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Etiket: PEtiket;
  p1: PShortString;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PRenk(Degiskenler + 12)^,
        PShortString(PSayi4(Degiskenler + 16)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _Etiket := PEtiket(_Etiket^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Etiket^.Goster;
    end;

    // etiket (label) başlığını değiştir
    $0104:
    begin

      _Etiket := PEtiket(_Etiket^.NesneAl(PKimlik(Degiskenler + 00)^));
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      _Etiket^.Baslik := p1^;
      _Etiket^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  etiket (label) nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): TKimlik;
var
  _Etiket: PEtiket;
begin

  _Etiket := _Etiket^.Olustur(AAtaKimlik, A1, B1, AYaziRenk, ABaslik);

  if(_Etiket = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Etiket^.Kimlik;
end;

{==============================================================================
  etiket (label) nesnesini oluşturur
 ==============================================================================}
function TEtiket.Olustur(AAtaKimlik: TKimlik; A1, B1: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): PEtiket;
var
  _AtaNesne: PGorselNesne;
  _Etiket: PEtiket;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // etiket nesnesi için bellekte yer ayır
  _Etiket := PEtiket(Olustur0(gntEtiket));
  if(_Etiket = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // etiket nesnesi nesnesini üst nesneye ekle
  if(_Etiket^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Etiket^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Etiket^.GorevKimlik := AktifGorev;
  _Etiket^.AtaNesne := _AtaNesne;
  _Etiket^.Hiza := hzYok;
  _Etiket^.FBoyutlar.Sol2 := A1;
  _Etiket^.FBoyutlar.Ust2 := B1;
  _Etiket^.FBoyutlar.Genislik2 := Length(ABaslik) * 8;
  _Etiket^.FBoyutlar.Yukseklik2 := 16;

  // kenar kalınlıkları
  _Etiket^.FKalinlik.Sol := 0;
  _Etiket^.FKalinlik.Ust := 0;
  _Etiket^.FKalinlik.Sag := 0;
  _Etiket^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Etiket^.FKenarBosluklari.Sol := 0;
  _Etiket^.FKenarBosluklari.Ust := 0;
  _Etiket^.FKenarBosluklari.Sag := 0;
  _Etiket^.FKenarBosluklari.Alt := 0;

  _Etiket^.FAtaNesneMi := False;
  _Etiket^.FareGostergeTipi := fitOK;
  _Etiket^.Gorunum := False;
  _Etiket^.FYaziRenk := AYaziRenk;

  // nesnenin ad ve başlık değeri
  _Etiket^.NesneAdi := NesneAdiAl(gntEtiket);
  _Etiket^.Baslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
    CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Etiket;
end;

{==============================================================================
  etiket (label) nesnesini görüntüler
 ==============================================================================}
procedure TEtiket.Goster;
var
  _Pencere: PPencere;
  _Etiket: PEtiket;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Etiket := PEtiket(_Etiket^.NesneTipiniKontrolEt(Kimlik, gntEtiket));
  if(_Etiket = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Etiket^.Gorunum = False) then
  begin

    // etiket nesnesinin görünürlüğünü aktifleştir
    _Etiket^.Gorunum := True;

    // etiket nesnesi ve üst nesneler görünür durumda mı ?
    if(_Etiket^.AtaNesneGorunurMu) then
    begin

      // görünür ise düğme nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Etiket);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  etiket (label) nesnesini çizer
 ==============================================================================}
procedure TEtiket.Guncelle;
var
  _Pencere: PPencere;
  _Etiket: PEtiket;
begin

  _Etiket := PEtiket(_Etiket^.NesneTipiniKontrolEt(Kimlik, gntEtiket));
  if(_Etiket = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Etiket);
  if(_Pencere = nil) then Exit;

  _Pencere^.Guncelle;
end;

{==============================================================================
  etiket (label) nesnesini çizer
 ==============================================================================}
procedure TEtiket.Ciz;
var
  _Pencere: PPencere;
  _Etiket: PEtiket;
  _Alan: TAlan;
begin

  _Etiket := PEtiket(_Etiket^.NesneTipiniKontrolEt(Kimlik, gntEtiket));
  if(_Etiket = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Etiket);
  if(_Pencere = nil) then Exit;

  // etiket nesnesinin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _Etiket^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // etiket nesnesini yaz
  YaziYaz(_Pencere, _Alan.A1, _Alan.B1, _Etiket^.Baslik, FYaziRenk);

  // uygulamaya mesaj gönder
  {GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
    CEKIRDEK_PNC_CIZIM, 0, 0);}
end;

{==============================================================================
  etiket (label) nesne olaylarını işler
 ==============================================================================}
procedure TEtiket.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Etiket: PEtiket;
begin

  _Etiket := PEtiket(_Etiket^.NesneTipiniKontrolEt(AKimlik, gntEtiket));
  if(_Etiket = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // etiketin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_Etiket);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // fare olaylarını yakala
    OlayYakalamayaBasla(_Etiket);

    // etiket nesnesini yeniden çiz
    _Etiket^.Ciz;

    // uygulamaya mesaj gönder
    GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_Etiket);

    // etiket nesnesini yeniden çiz
    _Etiket^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Etiket^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
        FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // etiket nesnesini yeniden çiz
    _Etiket^.Ciz;

    GorevListesi[_Etiket^.GorevKimlik]^.OlayEkle1(_Etiket^.GorevKimlik, _Etiket,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
