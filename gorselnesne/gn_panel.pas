{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_panel.pas
  Dosya İşlevi: panel yönetim işlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_panel;

interface

uses gorselnesne, paylasim;

type
  PPanel = ^TPanel;
  TPanel = object(TGorselNesne)
  protected
    FGovdeRenkSecim: TSayi4;    // 0 = renksiz, 1 = tek renk (FGovdeRenk1)
    FGovdeRenk1, FGovdeRenk2,   // 2 = FGovdeRenk1 ve FGovdeRenk2 ile eğimli dolgu
    FYaziRenk: TRenk;
    FKapatmaDugmeBoyut, FBuyutmeDugmeBoyut,
    FKucultmeDugmeBoyut: TAlan;
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
      ABaslik: string): PPanel;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function PanelCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): TKimlik;

implementation

uses genel, gorev, gn_islevler, gn_dugme, gn_gucdugme, gn_listekutusu,
  gn_defter, gn_islemgostergesi, gn_onaykutusu, gn_giriskutusu, gn_degerdugmesi,
  gn_etiket, gn_durumcubugu, gn_secimdugme, gn_baglanti, gn_resim, gn_listegorunum,
  temelgorselnesne, gn_pencere;

{==============================================================================
    panel kesme çağrılarını yönetir
 ==============================================================================}
function PanelCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Panel: PPanel;
  _Hiza: THiza;
  _Pencere: PPencere;
begin

  case IslevNo of

    ISLEV_OLUSTUR: Result := NesneOlustur(PKimlik(Degiskenler + 00)^,
      PISayi4(Degiskenler + 04)^, PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^,
      PISayi4(Degiskenler + 16)^, PSayi4(Degiskenler + 20)^, PRenk(Degiskenler + 24)^,
      PRenk(Degiskenler + 28)^, PRenk(Degiskenler + 32)^,
      PShortString(PSayi4(Degiskenler + 36)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _Panel := PPanel(_Panel^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Panel^.Goster;
    end;

    $0104:
    begin

      _Panel := PPanel(_Panel^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _Panel^.Hiza := _Hiza;

      _Pencere := PPencere(_Panel^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  panel nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): TKimlik;
var
  _Panel: PPanel;
begin

  _Panel := _Panel^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik,
    AGovdeRenkSecim, AGovdeRenk1, AGovdeRenk2, AYaziRenk, ABaslik);

  if(_Panel = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Panel^.Kimlik;
end;

{==============================================================================
  panel nesnesini oluşturur
 ==============================================================================}
function TPanel.Olustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  AGovdeRenkSecim: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): PPanel;
var
  _Pencere: PPencere;
  _Panel: PPanel;
begin

  { TODO : şu aşamada panel SADECE pencerenin içerisine eklenebilir.
    Panel içerisine başka panellerin de eklenmesi sağlanacaktır }

  // üst nesnenin doğruluğunu kontrol et
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AtaKimlik, gntPencere));
  if(_Pencere = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // panel nesnesi oluştur
  _Panel := PPanel(Olustur0(gntPanel));
  if(_Panel = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // panel nesnesini ata nesneye ekle
  if(_Panel^.AtaNesneyeEkle(_Pencere) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve işlevden çık
    _Panel^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Panel^.GorevKimlik := CalisanGorev;
  _Panel^.AtaNesne := _Pencere;
  _Panel^.Hiza := hzYok;

  _Panel^.FBoyutlar.Sol2 := A1;
  _Panel^.FBoyutlar.Ust2 := B1;
  _Panel^.FBoyutlar.Genislik2 := AGenislik;
  _Panel^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _Panel^.FKalinlik.Sol := 0;
  _Panel^.FKalinlik.Ust := 0;
  _Panel^.FKalinlik.Sag := 0;
  _Panel^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Panel^.FKenarBosluklari.Sol := 0;
  _Panel^.FKenarBosluklari.Ust := 0;
  _Panel^.FKenarBosluklari.Sag := 0;
  _Panel^.FKenarBosluklari.Alt := 0;

  // nesne, alt nesne alabilecek yapıda bir ata nesne
  _Panel^.FAtaNesneMi := True;

  // alt nesnelerin bellek adresi (nil = bellek oluşturulmadı)
  _Panel^.FAltNesneBellekAdresi := nil;

  // nesnenin alt nesne sayısı
  _Panel^.AltNesneSayisi := 0;

  // nesnenin üzerine gelindiğinde görüntülenecek fare göstergesi
  _Panel^.FareGostergeTipi := fitOK;

  // nesnenin görünüm durumu
  _Panel^.Gorunum := False;

  // nesnenin başlık değeri
  _Panel^.Baslik := ABaslik;

  // nesnenin gövde renk değerleri
  _Panel^.FGovdeRenkSecim := AGovdeRenkSecim;
  _Panel^.FGovdeRenk1 := AGovdeRenk1;
  _Panel^.FGovdeRenk2 := AGovdeRenk2;
  _Panel^.FYaziRenk := AYaziRenk;
  _Panel^.FBaslik := ABaslik;

  // nesnenin ad değeri
  _Panel^.NesneAdi := NesneAdiAl(gntPanel);

  // uygulamaya mesaj gönder
  GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
    _Panel, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Panel;
end;

{==============================================================================
  panel nesnesini görüntüler
 ==============================================================================}
procedure TPanel.Goster;
var
  _Pencere: PPencere;
  _Panel: PPanel;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Panel := PPanel(_Panel^.NesneTipiniKontrolEt(Kimlik, gntPanel));
  if(_Panel = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Panel^.Gorunum = False) then
  begin

    // panel nesnesinin görünürlüğünü aktifleştir
    _Panel^.Gorunum := True;

    // ata nesne görünür durumda mı?
    if(_Panel^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Panel);

      // pencereyi güncelleştir
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  panel nesnesini çizer
 ==============================================================================}
procedure TPanel.Ciz;
var
  _Pencere: PPencere;
  _Panel: PPanel;
  _Alan: TAlan;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Panel := PPanel(_Panel^.NesneTipiniKontrolEt(Kimlik, gntPanel));
  if(_Panel = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Panel);
  if(_Pencere = nil) then Exit;

  // panelin ata (pencere) nesnesine bağlı (0, 0) koordinatlarını al
  _Alan := _Panel^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // FGovdeRenkSecim = 0, içeriği doldurma

  // FGovdeRenkSecim = 1, içeriği tek renk ile doldur
  if(Self.FGovdeRenkSecim = 1) then

    DikdortgenDoldur(_Pencere, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2,
      FGovdeRenk1, FGovdeRenk1)

  // FGovdeRenkSecim = 2, artan renk ile (eğimli) doldur
  else if(Self.FGovdeRenkSecim = 2) then
    EgimliDoldur3(_Pencere, _Alan, FGovdeRenk1, FGovdeRenk2);

  // panel başlığını yaz
  if(Length(FBaslik) > 0) then YaziYaz(_Pencere, _Alan.A1 + 5, _Alan.B1 + 5,
    FBaslik, FYaziRenk);

  // uygulamaya mesaj gönder
  GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
    _Panel, CO_CIZIM, 0, 0);
end;

{==============================================================================
  panel nesne olaylarını işler
 ==============================================================================}
procedure TPanel.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _Panel: PPanel;
begin

  _Panel := PPanel(_Panel^.NesneTipiniKontrolEt(AKimlik, gntPanel));
  if(_Panel = nil) then Exit;

  // sol tuşa basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // panelin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_Panel);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuş basım işlemi olay alanında gerçekleştiyse
    if(_Panel^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare mesajlarını pencere nesnesine yönlendir
      OlayYakalamayaBasla(_Panel);

      // uygulamaya mesaj gönder
      GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
        _Panel, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end

  // sol tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // mouse mesajlarını yakalamayı bırak
    OlayYakalamayiBirak(_Panel);

    // fare bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Panel^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
        _Panel, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
      _Panel, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
      _Panel, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  // diğer olaylar
  else
  begin

    GorevListesi[_Panel^.GorevKimlik]^.OlayEkle1(_Panel^.GorevKimlik,
      _Panel, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
