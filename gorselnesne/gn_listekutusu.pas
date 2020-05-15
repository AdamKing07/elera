{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_listekutusu.pas
  Dosya İşlevi: liste kutusu yönetim işlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_listekutusu;

interface

uses gorselnesne, paylasim, n_yazilistesi;

type
  PListeKutusu = ^TListeKutusu;
  TListeKutusu = object(TGorselNesne)
  private
    FSeciliSiraNo: TISayi4;               // seçili sıra değeri
    FGorunenIlkSiraNo: TISayi4;           // görünen ilk elemanın sıra numarası
    FGorunenElemanSayisi: TISayi4;        // nesne içindeki görünen eleman sayısı
    FYaziListesi: PYaziListesi;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PListeKutusu;
    procedure YokEt(AKimlik: TKimlik);
    function SeciliYaziyiAl: string;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function ListeKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_islevler, gn_pencere, temelgorselnesne;

{==============================================================================
  liste kutusu kesme çağrılarını yönetir
 ==============================================================================}
function ListeKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _ListeKutusu: PListeKutusu;
  _Hiza: THiza;
  p1: PShortString;
begin

  case IslevNo of

    // nesne oluştur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // eleman ekle
    $0100:
    begin

      _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeKutusu));
      if(_ListeKutusu <> nil) then _ListeKutusu^.FYaziListesi^.Ekle(
        PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^);
      Result := 1;
    end;

    // seçilen sıra değerini al
    $0200:
    begin

      _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeKutusu));
      if(_ListeKutusu <> nil) then Result := _ListeKutusu^.FSeciliSiraNo;
    end;

    // liste içeriğini temizle
    $0300:
    begin

      _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeKutusu));
      if(_ListeKutusu <> nil) then
      begin

        // eğer daha önce bellek ayrıldıysa
        _ListeKutusu^.FGorunenIlkSiraNo := 0;
        _ListeKutusu^.FSeciliSiraNo := -1;

        _ListeKutusu^.FYaziListesi^.Temizle;
        _ListeKutusu^.Ciz;
      end;
    end;

    // liste kutusundaki seçilen yazı (text) değerini geri döndür
    $0400:
    begin

      _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeKutusu));
      if(_ListeKutusu <> nil) then Result := _ListeKutusu^.FSeciliSiraNo;
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      p1^ := _ListeKutusu^.SeciliYaziyiAl;
    end;

    $0104:
    begin

      _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _ListeKutusu^.Hiza := _Hiza;

      _Pencere := PPencere(_ListeKutusu^.FAtaNesne);
      _Pencere^.Guncelle;
    end;

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  liste kutusu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  _ListeKutusu: PListeKutusu;
begin

  _ListeKutusu := _ListeKutusu^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik);
  if(_ListeKutusu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _ListeKutusu^.Kimlik;
end;

{==============================================================================
  liste kutusu nesnesini oluşturur
 ==============================================================================}
function TListeKutusu.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PListeKutusu;
var
  _AtaNesne: PGorselNesne;
  _ListeKutusu: PListeKutusu;
  YL: PYaziListesi;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // liste kutusu nesnesi için yer ayır
  _ListeKutusu := PListeKutusu(Olustur0(gntListeKutusu));
  if(_ListeKutusu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // liste kutusu nesnesini ata nesnesine ekle
  if(_ListeKutusu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _ListeKutusu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _ListeKutusu^.GorevKimlik := CalisanGorev;
  _ListeKutusu^.AtaNesne := _AtaNesne;
  _ListeKutusu^.Hiza := hzYok;
  _ListeKutusu^.FBoyutlar.Sol2 := A1;
  _ListeKutusu^.FBoyutlar.Ust2 := B1;
  _ListeKutusu^.FBoyutlar.Genislik2 := AGenislik;
  _ListeKutusu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _ListeKutusu^.FKalinlik.Sol := 0;
  _ListeKutusu^.FKalinlik.Ust := 0;
  _ListeKutusu^.FKalinlik.Sag := 0;
  _ListeKutusu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _ListeKutusu^.FKenarBosluklari.Sol := 0;
  _ListeKutusu^.FKenarBosluklari.Ust := 0;
  _ListeKutusu^.FKenarBosluklari.Sag := 0;
  _ListeKutusu^.FKenarBosluklari.Alt := 0;

  _ListeKutusu^.FAtaNesneMi := False;
  _ListeKutusu^.FareGostergeTipi := fitOK;
  _ListeKutusu^.FGorunum := False;

  _ListeKutusu^.FYaziListesi := nil;
  YL := YL^.Olustur;
  if(YL <> nil) then _ListeKutusu^.FYaziListesi := YL;

  // nesnenin kullanacağı diğer değerler
  _ListeKutusu^.FGorunenIlkSiraNo := 0;
  _ListeKutusu^.FSeciliSiraNo := -1;

  // liste kutusunda görüntülenecek eleman sayısı
  _ListeKutusu^.FGorunenElemanSayisi := (AYukseklik + 17) div 18;

  // nesnenin ad ve başlık değeri
  _ListeKutusu^.NesneAdi := NesneAdiAl(gntListeKutusu);
  _ListeKutusu^.FBaslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
    _ListeKutusu, CO_OLUSTUR, 0, 0);

  // liste kutusunu görüntüle
  _ListeKutusu^.Goster;

  // nesne adresini geri döndür
  Result := _ListeKutusu;
end;

{==============================================================================
  nesne ve nesneye ayrılan kaynakları yok eder
 ==============================================================================}
procedure TListeKutusu.YokEt(AKimlik: TKimlik);
var
  _ListeKutusu: PListeKutusu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(AKimlik, gntListeKutusu));
  if(_ListeKutusu = nil) then Exit;

  if(_ListeKutusu^.FYaziListesi <> nil) then _ListeKutusu^.FYaziListesi^.YokEt;

  YokEt0;
end;

{==============================================================================
  liste kutusundaki seçili elemanın yazı (text) değerini geri döndürür
 ==============================================================================}
function TListeKutusu.SeciliYaziyiAl: string;
var
  _ListeKutusu: PListeKutusu;
  YL: PYaziListesi;
begin

  Result := '';

  // nesnenin Kimlik, tip değerlerini denetle.
  _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(Kimlik, gntListeKutusu));
  if(_ListeKutusu = nil) then Exit;

  YL := _ListeKutusu^.FYaziListesi;

  // nesnenin elemanı var mı ?
  if(YL^.ElemanSayisi > 0) then
  begin

    if(FSeciliSiraNo < YL^.ElemanSayisi) then

      Result := YL^.Eleman[FSeciliSiraNo]
    else Result := '';
  end;
end;

{==============================================================================
  liste kutusu nesnesini görüntüler
 ==============================================================================}
procedure TListeKutusu.Goster;
var
  _Pencere: PPencere;
  _ListeKutusu: PListeKutusu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(Kimlik, gntListeKutusu));
  if(_ListeKutusu = nil) then Exit;

  // eğer nesne görünür değilse
  if(_ListeKutusu^.FGorunum = False) then
  begin

    // nesnenin görünürlüğünü aktifleştir
    _ListeKutusu^.FGorunum := True;

    // nesne ve üst nesneler görünür ise
    if(_ListeKutusu^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_ListeKutusu);

      // pencereyi güncelleştir
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  liste kutusu nesnesini çizer
 ==============================================================================}
procedure TListeKutusu.Ciz;
var
  _Pencere: PPencere;
  _ListeKutusu: PListeKutusu;
  YL: PYaziListesi;
  _Alan: TAlan;
  _SiraNo, X, Y,
  _GorunenElemanSayisi: TISayi4;
  s: string;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(Kimlik, gntListeKutusu));
  if(_ListeKutusu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_ListeKutusu);
  if(_Pencere = nil) then Exit;

  // liste kutusunun üst nesneye bağlı olarak koordinatlarını al
  _Alan := _ListeKutusu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarlık çizgisini çiz
  KenarlikCiz(_Pencere, _Alan, 2);

  // iç dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.Sol + 2, _Alan.Ust + 2, _Alan.Sag - 2, _Alan.Alt - 2,
    RENK_BEYAZ, RENK_BEYAZ);

  YL := _ListeKutusu^.FYaziListesi;

  // nesnenin elemanı var mı ?
  if(YL^.ElemanSayisi > 0) then
  begin

    // çizim / yazım için kullanılacak x & y koordinatları
    X := _Alan.Sol + 4;
    Y := _Alan.Ust + 4;

    _ListeKutusu^.FGorunenElemanSayisi := ((_ListeKutusu^.FDisGercekBoyutlar.Alt -
      _ListeKutusu^.FDisGercekBoyutlar.Ust) + 17) div 18;

    // liste kutusunda görüntülenecek eleman sayısı
    if(YL^.ElemanSayisi > _ListeKutusu^.FGorunenElemanSayisi) then
      _GorunenElemanSayisi := _ListeKutusu^.FGorunenElemanSayisi + _ListeKutusu^.FGorunenIlkSiraNo
    else _GorunenElemanSayisi := YL^.ElemanSayisi + _ListeKutusu^.FGorunenIlkSiraNo;

    // listenin ilk elemanın sıra numarası
    for _SiraNo := _ListeKutusu^.FGorunenIlkSiraNo to _GorunenElemanSayisi - 1 do
    begin

      // belirtilen elemanın karakter katar değerini al
      s := YL^.Eleman[_SiraNo];

      // elemanın seçili olması durumunda seçili olduğunu belirt
      // belirtilen sıra seçili değilse sadece eleman değerini yaz
      if(_SiraNo = _ListeKutusu^.FSeciliSiraNo) then
      begin

        DikdortgenDoldur(_Pencere, X, Y, X + _ListeKutusu^.FBoyutlar.Sag - 4 - 4,
          Y + 18, $3EC5FF, $3EC5FF);
      end;
      YaziYaz(_Pencere, X, Y + 1, s, RENK_SIYAH);

      y += 18;
    end;
  end;
end;

{==============================================================================
  liste kutusu nesne olaylarını işler
 ==============================================================================}
procedure TListeKutusu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _ListeKutusu: PListeKutusu;
  i, _SeciliSiraNo: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _ListeKutusu := PListeKutusu(_ListeKutusu^.NesneTipiniKontrolEt(AKimlik, gntListeKutusu));
  if(_ListeKutusu = nil) then Exit;

  // sol fare tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // liste kutusunun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_ListeKutusu);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_ListeKutusu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_ListeKutusu);

      // seçilen sıra numarasını belirle
      _SeciliSiraNo := (AOlay.Deger2 - 4) div 18;

      // bu değere kaydırılan değeri de ekle
      _ListeKutusu^.FSeciliSiraNo := (_SeciliSiraNo + _ListeKutusu^.FGorunenIlkSiraNo);

      // liste kutusunu yeniden çiz
      _ListeKutusu^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
        _ListeKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end

  // sol fare tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_ListeKutusu);

    // fare bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_ListeKutusu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
        _ListeKutusu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
      _ListeKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  // fare hakeret işlemi
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ise
    if(YakalananGorselNesne <> nil) then
    begin

      // fare liste kutusunun yukarısında ise
      if(AOlay.Deger2 < 0) then
      begin

        _SeciliSiraNo := _ListeKutusu^.FGorunenIlkSiraNo;
        Dec(_SeciliSiraNo);
        if(_SeciliSiraNo >= 0) then
        begin

          _ListeKutusu^.FGorunenIlkSiraNo := _SeciliSiraNo;
          _ListeKutusu^.FSeciliSiraNo := _SeciliSiraNo;
        end;
      end

      // fare liste kutusunun aşağısında ise
      else if(AOlay.Deger2 > _ListeKutusu^.FBoyutlar.Alt) then
      begin

        // azami kaydırma değeri
        i := _ListeKutusu^.FYaziListesi^.ElemanSayisi - _ListeKutusu^.FGorunenElemanSayisi;
        if(i < 0) then i := 0;

        _SeciliSiraNo := _ListeKutusu^.FGorunenIlkSiraNo;
        Inc(_SeciliSiraNo);
        if(_SeciliSiraNo < i) then
        begin

          _ListeKutusu^.FGorunenIlkSiraNo := _SeciliSiraNo;
          i := (AOlay.Deger2 - 4) div 18;
          _ListeKutusu^.FSeciliSiraNo := i + _ListeKutusu^.FGorunenIlkSiraNo;
        end
      end

      // fare liste kutusunun içerisinde ise
      else
      begin

        i := (AOlay.Deger2 - 4) div 18;
        _ListeKutusu^.FSeciliSiraNo := i + _ListeKutusu^.FGorunenIlkSiraNo;
      end;

      // liste kutusunu yeniden çiz
      _ListeKutusu^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
        _ListeKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end

    // nesne yakalanmamış ise uygulamaya sadece mesaj gönder
    else GorevListesi[_ListeKutusu^.GorevKimlik]^.OlayEkle1(_ListeKutusu^.GorevKimlik,
      _ListeKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukarı kaydırma. ilk elemana doğru
    if(AOlay.Deger1 < 0) then
    begin

      _SeciliSiraNo := _ListeKutusu^.FGorunenIlkSiraNo;
      Dec(_SeciliSiraNo);
      if(_SeciliSiraNo >= 0) then _ListeKutusu^.FGorunenIlkSiraNo := _SeciliSiraNo;
    end

    // listeyi aşağıya kaydırma. son elemana doğru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kaydırma değeri
      i := _ListeKutusu^.FYaziListesi^.ElemanSayisi - _ListeKutusu^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      _SeciliSiraNo := _ListeKutusu^.FGorunenIlkSiraNo;
      Inc(_SeciliSiraNo);
      if(_SeciliSiraNo < i) then _ListeKutusu^.FGorunenIlkSiraNo := _SeciliSiraNo;
    end;

    _ListeKutusu^.Ciz;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
