{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_pencere.pas
  Dosya İşlevi: pencere yönetim işlevlerini içerir

  Güncelleme Tarihi: 09/11/2019

  Önemli Bilgiler:

    2. TPencere'nin alt nesnelerinden biri yeniden kısmi olarak (TEtiket nesnesi gibi)
      çizilmek istendiğinde mutlaka üst nesne olan TPencere.Guncelle işlevini çağırmalıdır.
      Böylece pencere çizim tasarım gereği pencere öncelikle kendini çizecek daha
      sonra ise alt nesnelerinin çizilmesi için alt nesnenin Ciz işlevini çağıracaktır.
      Bu durum en son geliştirilen, pencerelerin bellekten belleğe aktarılması ve
      eğimli dolgu (gradient) çizim işlevleri için gereklidir

 ==============================================================================}
{$mode objfpc}
unit gn_pencere;

interface

uses gorselnesne, paylasim;

type
  TKontrolDugmesi = (kdKucultme, kdBuyutme, kdKapatma);
  TKontrolDugmeleri = set of TKontrolDugmesi;
  PPencereTipi = ^TPencereTipi;
  TPencereTipi = (ptBoyutlandirilabilir, ptBasliksiz, ptIletisim);

type
  PPencere = ^TPencere;
  TPencere = object(TGorselNesne)
  protected
    FPencereTipi: TPencereTipi;
    FGovdeRenk: TRenk;
    FKontrolDugmeleri: TKontrolDugmeleri;
    FKapatmaDugmeBoyut, FBuyutmeDugmeBoyut,
    FKucultmeDugmeBoyut: TAlan;
    procedure BoyutlandirilabilirPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
    procedure BasliksizPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
    procedure IletisimPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
    property PencereTipi: TPencereTipi read FPencereTipi write FPencereTipi;
    property KontrolDugmeleri: TKontrolDugmeleri read FKontrolDugmeleri write FKontrolDugmeleri;
  private
    function FarePencereCizimAlanindaMi(AKimlik: TKimlik): Boolean;
    procedure KontrolDugmeleriniCiz(APencere: PPencere; APencereCizimAlani: TAlan;
      APencereAktif: Boolean);
  public
    function Olustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
      APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): PPencere;
    procedure Goster;
    procedure Ciz;
    procedure Guncelle;
    procedure EnUsteGetir;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function PencereCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;

implementation

uses genel, gorev, gn_islevler, gn_masaustu, gn_dugme, gn_gucdugme, gn_listekutusu,
  gn_defter, gn_islemgostergesi, gn_onaykutusu, gn_giriskutusu, gn_degerdugmesi,
  gn_etiket, gn_durumcubugu, gn_secimdugme, gn_baglanti, gn_resim, gn_listegorunum,
  gn_panel, gn_resimdugme, temelgorselnesne, giysi;

const
  PENCERE_ALTLIMIT_GENISLIK = 110;
  PENCERE_ALTLIMIT_YUKSEKLIK = 26;

type
  TFareKonumu = (fkSolAlt, fkSol, fkSolUst, fkUst, fkSagUst, fkSag, fkSagAlt, fkAlt,
    fkGovde, fkKontrolCubugu, fkKapatmaDugmesi);

var
  FareKonumu: TFareKonumu = fkGovde;
  SonFareYatayKoordinat, SonFareDikeyKoordinat: TISayi4;

{==============================================================================
    pencere kesme çağrılarını yönetir
 ==============================================================================}
function PencereCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
begin

  case IslevNo of

    ISLEV_OLUSTUR: Result := NesneOlustur(PKimlik(Degiskenler + 00)^,
      PISayi4(Degiskenler + 04)^, PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^,
      PISayi4(Degiskenler + 16)^, PPencereTipi(Degiskenler + 20)^,
      PShortString(PSayi4(Degiskenler + 24)^ + AktifGorevBellekAdresi)^,
      PRenk(Degiskenler + 28)^);

    ISLEV_GOSTER:
    begin

      _Pencere := PPencere(_Pencere^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Pencere^.Goster;
    end;

    ISLEV_CIZ:
    begin

      if(YakalananGorselNesne = nil) then
      begin

        // nesnenin kimlik, tip değerlerini denetle.
        _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
          gntPencere));
        if(_Pencere <> nil) then _Pencere^.Guncelle;
      end else Result := -1;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  pencere nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;
var
  _Pencere: PPencere;
begin

  _Pencere := _Pencere^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, APencereTipi,
    ABaslik, AGovdeRenk);

  if(_Pencere = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Pencere^.Kimlik;
end;

{==============================================================================
  pencere nesnesini oluşturur
 ==============================================================================}
function TPencere.Olustur(AtaKimlik: TKimlik; A1, B1, Genislik, Yukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): PPencere;
var
  _Masaustu: PMasaustu;
  _Pencere: PPencere;
begin

  // ata nesne -1 (HATA_KIMLIK) ise üst nesne geçerli masaüstüdür
  if(AtaKimlik = HATA_KIMLIK) then

    _Masaustu := GAktifMasaustu
  else _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(AtaKimlik, gntMasaustu));

  // geçerli masaüstü yok ise hata kodunu ver ve çık
  if(_Masaustu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // pencere nesnesi oluştur
  _Pencere := PPencere(Olustur0(gntPencere));
  if(_Pencere = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // pencere nesnesini ata nesneye ekle
  if(_Pencere^.AtaNesneyeEkle(_Masaustu) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve işlevden çık
    _Pencere^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Pencere^.GorevKimlik := CalisanGorev;
  _Pencere^.AtaNesne := _Masaustu;
  _Pencere^.Hiza := hzYok;

  _Pencere^.FBoyutlar.Sol2 := A1;
  _Pencere^.FBoyutlar.Ust2 := B1;

  // pencere genişliğinin en alt sınır değerin altında olup olmadığını kontrol et
  if(Genislik < PENCERE_ALTLIMIT_GENISLIK) then

    _Pencere^.FBoyutlar.Genislik2 := PENCERE_ALTLIMIT_GENISLIK
  else _Pencere^.FBoyutlar.Genislik2 := Genislik;

  // pencere yüksekliğinin en alt sınır değerin altında olup olmadığını kontrol et
  if(Yukseklik < PENCERE_ALTLIMIT_YUKSEKLIK) then

    _Pencere^.FBoyutlar.Yukseklik2 := PENCERE_ALTLIMIT_YUKSEKLIK
  else _Pencere^.FBoyutlar.Yukseklik2 := Yukseklik;

  // kenar kalınlıkları
  if(APencereTipi = ptBoyutlandirilabilir) or (APencereTipi = ptIletisim) then
  begin

    _Pencere^.FKalinlik.Sol := KENAR_DOLGU_KENARLIGI + 2;
    _Pencere^.FKalinlik.Ust := GIYSI_BASLIK_YUKSEKLIK;
    _Pencere^.FKalinlik.Sag := KENAR_DOLGU_KENARLIGI + 2;
    _Pencere^.FKalinlik.Alt := KENAR_DOLGU_KENARLIGI + 2;
  end
  else //if(APencereTipi = ptBasliksiz) then
  begin
    _Pencere^.FKalinlik.Sol := 4;
    _Pencere^.FKalinlik.Ust := 4;
    _Pencere^.FKalinlik.Sag := 4;
    _Pencere^.FKalinlik.Alt := 4;
  end;

  // kenar boşlukları
  _Pencere^.FKenarBosluklari.Sol := 0;
  _Pencere^.FKenarBosluklari.Ust := 0;
  _Pencere^.FKenarBosluklari.Sag := 0;
  _Pencere^.FKenarBosluklari.Alt := 0;

  // pencere çizimi için gereken bellek uzunluğu
  _Pencere^.FCizimBellekUzunlugu := (_Pencere^.FBoyutlar.Genislik2 *
    _Pencere^.FBoyutlar.Yukseklik2 * 4);

  // pencere çizimi için bellekte yer ayır
  _Pencere^.FCizimBellekAdresi := GGercekBellek.Ayir(_Pencere^.FCizimBellekUzunlugu);
  if(_Pencere^.FCizimBellekAdresi = nil) then
  begin

    // hata olması durumunda nesneyi yok et ve işlevden çık
    _Pencere^.YokEt0;
    Result := nil;
    Exit;
  end;

  // pencerenin özelliğine göre değer atamaları yap

  // pencere tipi - boyutlandırılabilir pencere
  if(APencereTipi = ptBoyutlandirilabilir) then
  begin

    _Pencere^.PencereTipi := ptBoyutlandirilabilir;
    _Pencere^.KontrolDugmeleri := [kdKucultme, kdBuyutme, kdKapatma];

    // kapatma düğmesi
    _Pencere^.FKapatmaDugmeBoyut.Sol3 := - 6 - 16;
    _Pencere^.FKapatmaDugmeBoyut.Ust3 := 4;
    _Pencere^.FKapatmaDugmeBoyut.Genislik3 := 16 - 1;
    _Pencere^.FKapatmaDugmeBoyut.Yukseklik3 := 16 - 1;

    // büyütme düğmesi
    _Pencere^.FBuyutmeDugmeBoyut.Sol3 := - 6 - 16 - 2 - 16;
    _Pencere^.FBuyutmeDugmeBoyut.Ust3 := 4;
    _Pencere^.FBuyutmeDugmeBoyut.Genislik3 := 16 - 1;
    _Pencere^.FBuyutmeDugmeBoyut.Yukseklik3 := 16 - 1;

    // küçültme düğmesi
    _Pencere^.FKucultmeDugmeBoyut.Sol3 := - 6 - 16 - 2 - 16 - 2 - 16;
    _Pencere^.FKucultmeDugmeBoyut.Ust3 := 4;
    _Pencere^.FKucultmeDugmeBoyut.Genislik3 := 16 - 1;
    _Pencere^.FKucultmeDugmeBoyut.Yukseklik3 := 16 - 1;
  end

  // pencere tipi - boyutlandırılamaz & başlıksız
  else if(APencereTipi = ptBasliksiz) then
  begin

    _Pencere^.PencereTipi := ptBasliksiz;
    _Pencere^.KontrolDugmeleri := [];
  end

  // pencere tipi - iletişim kutusu (öndeğer)
  else if(APencereTipi = ptIletisim) then
  begin

    _Pencere^.PencereTipi := ptIletisim;
    _Pencere^.KontrolDugmeleri := [kdKapatma];

    // kapatma düğmesi
    _Pencere^.FKapatmaDugmeBoyut.Sol3 := - 6 - 16;
    _Pencere^.FKapatmaDugmeBoyut.Ust3 := 4;
    _Pencere^.FKapatmaDugmeBoyut.Genislik3 := 16 - 1;
    _Pencere^.FKapatmaDugmeBoyut.Yukseklik3 := 16 - 1;
  end;

  // nesne, alt nesne alabilecek yapıda bir ata nesne
  _Pencere^.FAtaNesneMi := True;

  // alt nesnelerin bellek adresi (nil = bellek oluşturulmadı)
  _Pencere^.FAltNesneBellekAdresi := nil;

  // nesnenin alt nesne sayısı
  _Pencere^.AltNesneSayisi := 0;

  // nesnenin üzerine gelindiğinde görüntülenecek fare göstergesi
  _Pencere^.FareGostergeTipi := fitOK;

  // nesnenin görünüm durumu
  _Pencere^.Gorunum := False;

  // nesnenin başlık değeri
  _Pencere^.Baslik := ABaslik;

  // nesnenin gövde renk değeri
  _Pencere^.FGovdeRenk := AGovdeRenk;

  // nesnenin ad değeri
  _Pencere^.NesneAdi := NesneAdiAl(gntPencere);

  // uygulamaya mesaj gönder
  GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
    _Pencere, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _Pencere;
end;

{==============================================================================
  pencere nesnesini görüntüler
 ==============================================================================}
procedure TPencere.Goster;
var
  _Pencere: PPencere;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(Kimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Pencere^.Gorunum = False) then
  begin

    // pencere nesnesinin görünürlüğünü aktifleştir
    _Pencere^.Gorunum := True;

    // pencere nesnesini en üste getir ve yeniden çiz
    _Pencere^.EnUsteGetir;

    _Pencere^.Guncelle;
  end;
end;

{==============================================================================
  pencere nesnesini çizer
  önemli: tüm alt nesneler çizim istekleri için TPencere.Guncelle işlevini çağırmalıdır
 ==============================================================================}
procedure TPencere.Ciz;
var
  _Pencere: PPencere;
  _GiysiSol: PAktifGiysiBaslikSol;
  _GiysiOrta: PAktifGiysiBaslikOrta;
  _GiysiSag: PAktifGiysiBaslikSag;
  _Alan: TAlan;
  _A1, _A2, _B1, i: TISayi4;
  _Renk, _KenarDolguRengi, _BaslikRengi: TRenk;
  _PencereAktif: Boolean;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(Kimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // pencerenin kendi değerlerine bağlı (0, 0) koordinatlarını al
  _Alan := _Pencere^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // pencere tipi başlıksız ise
  if(_Pencere^.PencereTipi = ptBasliksiz) then
  begin

    // artan _Renk ile (eğimli) doldur
    EgimliDoldur3(_Pencere, _Alan, GOREVCUBUGU_ILKRENK, GOREVCUBUGU_SONRENK);

    // uygulamaya mesaj gönder ve çık
    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
      _Pencere, CO_CIZIM, 0, 0);

    Exit;
  end;

  // başlıklı pencere nesnesinin çizimi

  // aktif veya pasif çizimin belirlenmesi
  _PencereAktif := (_Pencere = AktifPencere);

  if(_PencereAktif) then
  begin

    _GiysiSol := @AktifGiysiBaslikSol;
    _GiysiOrta := @AktifGiysiBaslikOrta;
    _GiysiSag := @AktifGiysiBaslikSag;
    _KenarDolguRengi := AKTIF_KENAR_DOLGU_RENGI;
    _BaslikRengi := AKTIF_BASLIK_RENGI;
  end
  else
  begin

    _GiysiSol := @PasifGiysiBaslikSol;
    _GiysiOrta := @PasifGiysiBaslikOrta;
    _GiysiSag := @PasifGiysiBaslikSag;
    _KenarDolguRengi := PASIF_KENAR_DOLGU_RENGI;
    _BaslikRengi := PASIF_BASLIK_RENGI;
  end;

  // pencerenin 3 aşamada giydirilmesi

  // 1. sol başlık kısmının çizilmesi
  for _B1 := 0 to GIYSI_BASLIK_YUKSEKLIK - 1 do
  begin

    for _A1 := 0 to GIYSI_BASLIK_SOL_GENISLIK - 1 do
    begin

      _Renk := _GiysiSol^[_B1, _A1];
      PixelYaz(_Pencere, _A1, _B1, _Renk);
    end;
  end;

  // 2. orta başlık kısmının çizilmesi
  _A1 := GIYSI_BASLIK_SOL_GENISLIK;
  _A2 := _Alan.Sag - GIYSI_BASLIK_SAG_GENISLIK + 1;
  while _A1 < _A2 do
  begin

    for _B1 := 0 to GIYSI_BASLIK_YUKSEKLIK - 1 do
    begin

      _Renk := _GiysiOrta^[_B1, 0];
      PixelYaz(_Pencere, _A1, _B1, _Renk);
    end;

    Inc(_A1);
  end;

  // 3. sağ başlık kısmının çizilmesi
  i := _Alan.Sag - GIYSI_BASLIK_SAG_GENISLIK;
  for _B1 := 0 to GIYSI_BASLIK_YUKSEKLIK - 1 do
  begin

    for _A1 := 0 to GIYSI_BASLIK_SAG_GENISLIK - 1 do
    begin

      _Renk := _GiysiSag^[_B1, _A1];
      PixelYaz(_Pencere, i + _A1, _B1, _Renk);
    end;
  end;

  // pencere başlığını yaz
  YaziYaz(_Pencere, 7, 5, _Pencere^.Baslik, _BaslikRengi);

  // pencere sol kenar çizgisi
  Cizgi(_Pencere, 0, GIYSI_BASLIK_YUKSEKLIK, 0, _Alan.Alt, DIS_KENAR_CIZGI_RENGI);
  if(KENAR_DOLGU_KENARLIGI > 0) then
  begin

    for i := 1 to KENAR_DOLGU_KENARLIGI do
    begin

      Cizgi(_Pencere, i, GIYSI_BASLIK_YUKSEKLIK, i, _Alan.Alt - i, _KenarDolguRengi);
    end;
  end;
  i := KENAR_DOLGU_KENARLIGI + 1;
  Cizgi(_Pencere, i, GIYSI_BASLIK_YUKSEKLIK, i, _Alan.Alt - i, IC_KENAR_CIZGI_RENGI);

  // pencere sağ kenar çizgisi
  Cizgi(_Pencere, _Alan.Sag, GIYSI_BASLIK_YUKSEKLIK, _Alan.Sag, _Alan.Alt, DIS_KENAR_CIZGI_RENGI);
  if(KENAR_DOLGU_KENARLIGI > 0) then
  begin

    for i := 1 to KENAR_DOLGU_KENARLIGI do
    begin

      Cizgi(_Pencere, _Alan.Sag - i, GIYSI_BASLIK_YUKSEKLIK, _Alan.Sag - i,
        _Alan.Alt - i, _KenarDolguRengi);
    end;
  end;
  i := KENAR_DOLGU_KENARLIGI + 1;
  Cizgi(_Pencere, _Alan.Sag - i, GIYSI_BASLIK_YUKSEKLIK, _Alan.Sag - i, _Alan.Alt - i,
    IC_KENAR_CIZGI_RENGI);

  // pencere alt kenar çizgisi
  Cizgi(_Pencere, 0, _Alan.Alt, _Alan.Sag, _Alan.Alt, DIS_KENAR_CIZGI_RENGI);
  if(KENAR_DOLGU_KENARLIGI > 0) then
  begin

    for i := 1 to KENAR_DOLGU_KENARLIGI do
    begin

      Cizgi(_Pencere, i, _Alan.Alt - i, _Alan.Sag - i, _Alan.Alt - i, _KenarDolguRengi);
    end;
  end;
  i := KENAR_DOLGU_KENARLIGI + 1;
  Cizgi(_Pencere, i, _Alan.Alt - i, _Alan.Sag - i, _Alan.Alt - i, IC_KENAR_CIZGI_RENGI);

  // pencere iç bölüm boyama
  DikdortgenDoldur(_Pencere, KENAR_DOLGU_KENARLIGI + 2, GIYSI_BASLIK_YUKSEKLIK,
    _Alan.Sag - (KENAR_DOLGU_KENARLIGI + 2), _Alan.Alt - (KENAR_DOLGU_KENARLIGI + 2),
    _Pencere^.FGovdeRenk, _Pencere^.FGovdeRenk);

  // pencere kontrol düğmelerini çiz
  KontrolDugmeleriniCiz(_Pencere, _Alan, _PencereAktif);

  // uygulamaya mesaj gönder
  GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
    _Pencere, CO_CIZIM, 0, 0);
end;

{==============================================================================
  pencere nesnesi ve alt nesnelerini günceller
  önemli: tüm alt nesneler çizim istekleri için TPencere.Guncelle işlevini çağırmalıdır
 ==============================================================================}
procedure TPencere.Guncelle;
var
  _Pencere: PPencere;
  _AltNesneler, _PanelAltNesneler: PPGorselNesne;
  _GorunurNesne: PGorselNesne;
  i: TISayi4;
  _Panel: PPanel;
  j: Integer;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(Kimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // öncelikle pencerenin kendisini, daha sonra alt nesneleri çiz
  _Pencere^.IcVeDisBoyutlariYenidenHesapla;

  _Pencere^.Ciz;

  // pencere nesnesinin alt nesnelerinin bellek bölgesine konumlan
  _AltNesneler := _Pencere^.FAltNesneBellekAdresi;
  if(_Pencere^.AltNesneSayisi > 0) then
  begin

    // ilk oluşturulan alt nesneden son oluşturulan alt nesneye doğru
    // pencerenin alt nesnelerini çiz
    for i := 0 to _Pencere^.AltNesneSayisi - 1 do
    begin

      _GorunurNesne := _AltNesneler[i];
      if(_GorunurNesne^.Gorunum) then
      begin

        // pencere nesnesinin altında çizilecek nesneler
        case _GorunurNesne^.GorselNesneTipi of
          gntDugme          : PDugme(_GorunurNesne)^.Ciz;
          gntGucDugme       : PGucDugme(_GorunurNesne)^.Ciz;
          gntListeKutusu    : PListeKutusu(_GorunurNesne)^.Ciz;
          gntDefter         : PDefter(_GorunurNesne)^.Ciz;
          gntIslemGostergesi: PIslemGostergesi(_GorunurNesne)^.Ciz;
          gntIsaretKutusu   : POnayKutusu(_GorunurNesne)^.Ciz;
          gntGirisKutusu    : PGirisKutusu(_GorunurNesne)^.Ciz;
          gntDegerDugmesi   : PDegerDugmesi(_GorunurNesne)^.Ciz;
          gntEtiket         : PEtiket(_GorunurNesne)^.Ciz;
          gntDurumCubugu    : PDurumCubugu(_GorunurNesne)^.Ciz;
          gntSecimDugmesi   : PSecimDugme(_GorunurNesne)^.Ciz;
          gntBaglanti       : PBaglanti(_GorunurNesne)^.Ciz;
          gntResim          : PResim(_GorunurNesne)^.Ciz;
          gntListeGorunum   : PListeGorunum(_GorunurNesne)^.Ciz;
          gntPanel          :
          begin

            // panel ve alt nesneleri çiz
            _Panel := PPanel(_GorunurNesne);
            _Panel^.Ciz;

            if(_Panel^.AltNesneSayisi > 0) then
            begin

              _PanelAltNesneler := _Panel^.FAltNesneBellekAdresi;
              for j := 0 to _Panel^.AltNesneSayisi - 1 do
              begin

                _GorunurNesne := _PanelAltNesneler[j];
                if(_GorunurNesne^.Gorunum) then
                begin

                  // panelin altında olabilecek tüm nesneler
                  case _GorunurNesne^.GorselNesneTipi of
                    gntDugme          : PDugme(_GorunurNesne)^.Ciz;
                    gntGucDugme       : PGucDugme(_GorunurNesne)^.Ciz;
                    gntListeKutusu    : PListeKutusu(_GorunurNesne)^.Ciz;
                    gntDefter         : PDefter(_GorunurNesne)^.Ciz;
                    gntIslemGostergesi: PIslemGostergesi(_GorunurNesne)^.Ciz;
                    gntIsaretKutusu   : POnayKutusu(_GorunurNesne)^.Ciz;
                    gntGirisKutusu    : PGirisKutusu(_GorunurNesne)^.Ciz;
                    gntDegerDugmesi   : PDegerDugmesi(_GorunurNesne)^.Ciz;
                    gntEtiket         : PEtiket(_GorunurNesne)^.Ciz;
                    gntDurumCubugu    : PDurumCubugu(_GorunurNesne)^.Ciz;
                    gntSecimDugmesi   : PSecimDugme(_GorunurNesne)^.Ciz;
                    gntBaglanti       : PBaglanti(_GorunurNesne)^.Ciz;
                    gntResim          : PResim(_GorunurNesne)^.Ciz;
                    gntListeGorunum   : PListeGorunum(_GorunurNesne)^.Ciz;
                    gntPanel          : PPanel(_GorunurNesne)^.Ciz;
                  end;
                end;
              end;
            end;
          end;
          gntResimDugme     : PResimDugme(_GorunurNesne)^.Ciz;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  belirtilen pencere nesnesini en üste getirir ve yeniden çizer
 ==============================================================================}
procedure TPencere.EnUsteGetir;
var
  _Masaustu: PMasaustu;
  _BirOncekiPencere, _Pencere: PPencere;
  _AltNesneler: PPGorselNesne;
  _GorselNesne: PGorselNesne;
  i, j: TISayi4;
begin

{------------------------------------------------------------------------------
  Sıralama            0   1   2
                    +---+---+---+
  Nesne Kimlikleri  | 1 | 2 | 3 |
                    +-+-+---+-+-+
                      |       +----- en üst nesne
                      +------------- en alt nesne
-------------------------------------------------------------------------------}

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(Kimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // aktif masaüstünü al
  _Masaustu := GAktifMasaustu;

  // masaüstünün alt nesne bellek değerini al
  _AltNesneler := _Masaustu^.FAltNesneBellekAdresi;

  // nesnenin alt nesne sayısı var ise
  if(_Masaustu^.AltNesneSayisi > 1) then
  begin

    _BirOncekiPencere := PPencere(_AltNesneler[_Masaustu^.AltNesneSayisi - 1]);

    // alt nesneler içerisinde pencere nesnesini ara
    for i := (_Masaustu^.AltNesneSayisi - 1) downto 0 do
    begin

      if(PPencere(_AltNesneler[i]) = _Pencere) then Break;
    end;

    // eğer pencere nesnesi en üstte değil ise
    if(i <> _Masaustu^.AltNesneSayisi - 1) then
    begin

      // pencere nesnesini masaüstü nesne belleğinde en üste getir
      for j := i to _Masaustu^.AltNesneSayisi - 2 do
      begin

        _GorselNesne := _AltNesneler[j + 0];
        _AltNesneler[j + 0] := _AltNesneler[j + 1];
        _AltNesneler[j + 1] := _GorselNesne;
      end;
    end;

    // pencere en üstte olsa da olmasa da aktif pencere olarak tanımla
    // not: pencere en üstte olup görüntülenmiş olmayabilir
    AktifPencere := _Pencere;

    // bir önceki pencereyi yeniden çiz
    _BirOncekiPencere^.Guncelle;

    // aktif pencereyi yeniden çiz
    AktifPencere^.Guncelle;
  end;
end;

{==============================================================================
  pencere nesne olaylarını işler
 ==============================================================================}
procedure TPencere.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
begin

  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AKimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // sol tuşa basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // olayları ilgili işlevlere yönlendir
    case _Pencere^.PencereTipi of
      ptBoyutlandirilabilir : BoyutlandirilabilirPencereOlaylariniIsle(AKimlik, AOlay);
      ptBasliksiz           : BasliksizPencereOlaylariniIsle(AKimlik, AOlay);
      ptIletisim            : IletisimPencereOlaylariniIsle(AKimlik, AOlay);
    end;
  end

  // sol tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // olayları ilgili işlevlere yönlendir
    case _Pencere^.PencereTipi of
      ptBoyutlandirilabilir : BoyutlandirilabilirPencereOlaylariniIsle(AKimlik, AOlay);
      ptBasliksiz           : BasliksizPencereOlaylariniIsle(AKimlik, AOlay);
      ptIletisim            : IletisimPencereOlaylariniIsle(AKimlik, AOlay);
    end;
  end

  // diğer olaylar
  else
  begin

    // olayları ilgili işlevlere yönlendir
    case _Pencere^.PencereTipi of
      ptBoyutlandirilabilir : BoyutlandirilabilirPencereOlaylariniIsle(AKimlik, AOlay);
      ptBasliksiz           : BasliksizPencereOlaylariniIsle(AKimlik, AOlay);
      ptIletisim            : IletisimPencereOlaylariniIsle(AKimlik, AOlay);
    end;
  end;
end;

{==============================================================================
  başlıksız pencere nesne olaylarını işler
 ==============================================================================}
procedure TPencere.BasliksizPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
var
  _Pencere: PPencere;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AKimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // sol tuşa basım işlemi
  if(Olay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // pencere nesnesi aktif değilse aktifleştir
    if(_Pencere <> AktifPencere) then EnUsteGetir;

    // sol tuş basım işlemi olay alanında gerçekleştiyse
    if(_Pencere^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare mesajlarını pencere nesnesine yönlendir
      OlayYakalamayaBasla(_Pencere);

      // uygulamaya mesaj gönder
      GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
        _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
    end;
  end

  // sol tuş bırakım işlemi
  else if(Olay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // mouse mesajlarını yakalamayı bırak
    OlayYakalamayiBirak(_Pencere);

    // sol tuş bırakım işlemi olay alanında gerçekleştiyse
    if(_Pencere^.FarePencereCizimAlanindaMi(AKimlik)) then
      GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
        _Pencere, FO_TIKLAMA, Olay.Deger1, Olay.Deger2);

    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
      _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
  end
  else if(Olay.Olay = FO_HAREKET) then
  begin

    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
      _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
  end
  // diğer olaylar
  else
  begin

    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
      _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

{==============================================================================
  iletişim pencere nesne olaylarını işler
 ==============================================================================}
procedure TPencere.IletisimPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
var
  _Pencere: PPencere;
  _Gorev: PGorev;
  _EskiBoyut, _YeniBoyut: TAlan;
  _Nokta: TNokta;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AKimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // sol tuşa basım işlemi
  if(Olay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // program kapatma işlevi
    if(FareKonumu = fkKapatmaDugmesi) then
    begin

      _Gorev^.Sonlandir(_Pencere^.GorevKimlik);
      Exit;
    end;

    // pencere nesnesi aktif değilse aktifleştir
    if(_Pencere <> AktifPencere) then EnUsteGetir;

    // sol tuş basım işlemi olay alanında gerçekleştiyse
    if(_Pencere^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare mesajlarını pencere nesnesine yönlendir
      OlayYakalamayaBasla(_Pencere);

      // eğer tıklama pencerenin gövdesinde gerçekleşmişse
      if(FareKonumu = fkGovde) then
      begin

        GecerliFareGostegeTipi := FareGostergeTipi;
        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
      end
      else

      // aksi durumda tıklama işlemi yakalama çubuğunda gerçekleşmiştir
      // o zaman pencerenin kenarlıklarını sakla
      begin

        GecerliFareGostegeTipi := fitBoyutTum;
        SonFareYatayKoordinat := Olay.Deger1;
        SonFareDikeyKoordinat := Olay.Deger2;
      end;
    end else GecerliFareGostegeTipi := FareGostergeTipi;

    Exit;
  end

  // sol tuş bırakım işlemi
  else if(Olay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_Pencere);

    // taşıma işlemi kontrol çubuğu dışında gerçekleşmişse
    if not(FareKonumu = fkKontrolCubugu) then
    begin

      // bırakma işlemi pencere içerinde gerçekleştiyse
      if(_Pencere^.FarePencereCizimAlanindaMi(AKimlik)) then
      begin

        GecerliFareGostegeTipi := FareGostergeTipi;
        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik, _Pencere,
          FO_TIKLAMA, Olay.Deger1, Olay.Deger2);

        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik, _Pencere,
          Olay.Olay, Olay.Deger1, Olay.Deger2);
      end
      else

      // bırakma işlemi pencere dışında gerçekleştiyse
      begin

        { TODO : bırakma işlemi pencere dışında olursa normalde kursor de ilgili
          nesnenin kursörü olur }
        GecerliFareGostegeTipi := FareGostergeTipi;
        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
      end;

      Exit;
    end;
  end

  else if(Olay.Olay = FO_HAREKET) then
  begin

    // fare yakalanmamışsa sadece fare göstergesini güncelle
    if(YakalananGorselNesne = nil) then
    begin

      if not(_Pencere^.FareNesneOlayAlanindaMi(AKimlik)) then
      begin

        GecerliFareGostegeTipi := FareGostergeTipi;
        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
      end
      else
      begin

        if(_Pencere^.FarePencereCizimAlanindaMi(AKimlik)) then
        begin

          FareKonumu := fkGovde;
          GecerliFareGostegeTipi := FareGostergeTipi;
          GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
            _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
        end
        else
        begin

          // fare pencere kapatma düğmesinin üzerinde mi ?
          _YeniBoyut.Sol := _Pencere^.FBoyutlar.Sag + _Pencere^.FKapatmaDugmeBoyut.Sol3;
          _YeniBoyut.Ust := _Pencere^.FKapatmaDugmeBoyut.Ust3;
          _YeniBoyut.Sag := _YeniBoyut.Sol + _Pencere^.FKapatmaDugmeBoyut.Genislik3;
          _YeniBoyut.Alt := _YeniBoyut.Ust + _Pencere^.FKapatmaDugmeBoyut.Yukseklik3;
          _Nokta.A1 := Olay.Deger1;
          _Nokta.B1 := Olay.Deger2;

          if(NoktaAlanIcindeMi(_Nokta, _YeniBoyut)) then
          begin

            FareKonumu := fkKapatmaDugmesi;
            GecerliFareGostegeTipi := fitOK;
          end
          else
          begin

            FareKonumu := fkKontrolCubugu;
            GecerliFareGostegeTipi := fitBoyutTum;
            GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
              _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
          end;
        end;
      end;

      Exit;
    end
    else

    // fare yakalanmış olduğu için taşıma işlemlerini gerçekleştir
    begin

      if(FareKonumu = fkKontrolCubugu) then
      begin

        _EskiBoyut.Sol := Olay.Deger1 - SonFareYatayKoordinat;
        _EskiBoyut.Ust := Olay.Deger2 - SonFareDikeyKoordinat;
        _EskiBoyut.Sag := 0;
        _EskiBoyut.Alt := 0;

        FBoyutlar.Sol += _EskiBoyut.Sol;
        FBoyutlar.Sag += _EskiBoyut.Sag;
        FBoyutlar.Ust += _EskiBoyut.Ust;
        FBoyutlar.Alt += _EskiBoyut.Alt;

        GecerliFareGostegeTipi := fitBoyutTum;

        _Pencere^.Guncelle;
      end
      else
      begin

        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
        GecerliFareGostegeTipi := FareGostergeTipi;
      end;
    end;
  end
  // diğer olaylar
  else
  begin

    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
      _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
  end;
end;

{==============================================================================
  boyutlandırılabilir pencere nesne olaylarını işler
 ==============================================================================}
procedure TPencere.BoyutlandirilabilirPencereOlaylariniIsle(AKimlik: TKimlik; Olay: TOlayKayit);
var
  _Pencere: PPencere;
  _Gorev: PGorev;
  _EskiBoyut, _YeniBoyut: TAlan;
  _Nokta: TNokta;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AKimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // sol tuşa basım işlemi
  if(Olay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // program kapatma işlevi
    if(FareKonumu = fkKapatmaDugmesi) then
    begin

      _Gorev^.Sonlandir(_Pencere^.GorevKimlik);
      Exit;
    end;

    // pencere nesnesi aktif değilse aktifleştir
    if(_Pencere <> AktifPencere) then EnUsteGetir;

    // fare olaylarını pencere nesnesine yönlendir
    OlayYakalamayaBasla(_Pencere);

    // eğer farenin sol tuşu pencere nesnesinin gövdesine tıklanmışsa ...
    if(FareKonumu = fkGovde) then
    begin

      GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
        _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
    end
    else
    begin

      // aksi durumda taşıma işlemi gerçekleştirilecektir.
      // değişken içeriklerini güncelle
      SonFareYatayKoordinat := Olay.Deger1;
      SonFareDikeyKoordinat := Olay.Deger2;
    end;

    Exit;
  end

  // sol tuş bırakma işlemi
  else if(Olay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare mesajlarını yakalamayı bırak
    OlayYakalamayiBirak(_Pencere);

    // fare bırakma işlemi nesnenin içerisinde mi gerçekleşti ?
    if(FareKonumu = fkGovde) then
    begin

      if(_Pencere^.FarePencereCizimAlanindaMi(AKimlik)) then

        // yakalama & bırakma işlemi bu nesnede olduğu için
        // nesneye FO_TIKLAMA mesajı gönder
        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, FO_TIKLAMA, Olay.Deger1, Olay.Deger2);

      // nesneye sadece FO_SOLTUS_BIRAKILDI mesajı gönder
      GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
        _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);

      Exit;
    end;
  end

  // fare hareket işlemleri
  else if(Olay.Olay = FO_HAREKET) then
  begin

    // FO_HAREKET - nesne yakalanmamış
    if(YakalananGorselNesne = nil) then
    begin

      // fare > sol çizgi kalınlık
      if(Olay.Deger1 > _Pencere^.FKalinlik.Sol) then
      begin

        // fare < sağ çizgi kalınlık
        if(Olay.Deger1 < _Pencere^.FBoyutlar.Sag - _Pencere^.FKalinlik.Sag) then
        begin

          // fare < alt çizgi kalınlık
          if(Olay.Deger2 < _Pencere^.FBoyutlar.Alt - _Pencere^.FKalinlik.Alt) then
          begin

            // fare > alt çizgi kalınlık
            // bilgi: üst çizgi kalınlık değeri başlık çubuğu değeri olduğundan dolayı
            // üst çizgi kalınlık değeri olarak alt çizgi kalınlık değeri kullanılmaktadır
            if(Olay.Deger2 > _Pencere^.FKalinlik.Alt) then
            begin

              // fare > yakalama çubuğu
              // bu değer yakalama çubuğu için kullanılıyor. hata yok
              if(Olay.Deger2 > _Pencere^.FKalinlik.Ust) then
              begin

                // fare göstergesi pencere gövdesinde
                FareKonumu := fkGovde;
                GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
                  _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);
                GecerliFareGostegeTipi := FareGostergeTipi;
              end
              else
              begin

                // fare, pencere kapatma düğmesinin üzerinde mi ?
                _EskiBoyut.Sol := _Pencere^.FBoyutlar.Sag + _Pencere^.FKapatmaDugmeBoyut.Sol3;
                _EskiBoyut.Ust := _Pencere^.FKapatmaDugmeBoyut.Ust3;
                _EskiBoyut.Sag := _EskiBoyut.Sol + _Pencere^.FKapatmaDugmeBoyut.Genislik3;
                _EskiBoyut.Alt := _EskiBoyut.Ust + _Pencere^.FKapatmaDugmeBoyut.Yukseklik3;
                _Nokta.A1 := Olay.Deger1;
                _Nokta.B1 := Olay.Deger2;

                if(NoktaAlanIcindeMi(_Nokta, _EskiBoyut)) then
                begin

                  FareKonumu := fkKapatmaDugmesi;
                  GecerliFareGostegeTipi := fitOK;
                end

                // diğer kontrol düğmeleri (büyütme, küçültme) de buraya eklenecek
                else
                begin

                  // fare göstergesi yakalama çubuğunda
                  FareKonumu := fkKontrolCubugu;
                  GecerliFareGostegeTipi := fitBoyutTum;
                end;
              end;
            end
            else
            begin

              // fare göstergesi üst boyutlandırmada
              FareKonumu := fkUst;
              GecerliFareGostegeTipi := fitBoyutKG;
            end;
          end
          else
          begin

            // fare göstergesi alt boyutlandırmada
            FareKonumu := fkAlt;
            GecerliFareGostegeTipi := fitBoyutKG;
          end;
        end
        else
        // sağ - alt / üst / orta (sağ) kontrolü
        begin

          // bilgi: _Pencere^.FKalinlik.Alt değeri aslında _Pencere^.FKalinlik.Ust değeri olmalıdır
          // fakat _Pencere^.FKalinlik.Ust değeri başlık kalınlığı olarak kullanılmaktadır
          if(Olay.Deger2 < _Pencere^.FKalinlik.Alt) then
          begin

            // fare göstergesi sağ & üst boyutlandırmada
            FareKonumu := fkSagUst;
            GecerliFareGostegeTipi := fitBoyutKDGB;
          end
          else if(Olay.Deger2 > _Pencere^.FBoyutlar.Alt - _Pencere^.FKalinlik.Alt) then
          begin

            // fare göstergesi sağ & alt boyutlandırmada
            FareKonumu := fkSagAlt;
            GecerliFareGostegeTipi := fitBoyutKBGD;
          end
          else
          begin

            // fare göstergesi sağ kısım boyutlandırmada
            FareKonumu := fkSag;
            GecerliFareGostegeTipi := fitBoyutBD;
          end;
        end;

        Exit;
      end
      else
      // sol - alt / üst / orta (sol) kontrolü
      begin

        if(Olay.Deger2 < _Pencere^.FKalinlik.Alt) then
        begin

          // fare göstergesi üst & sol kısım boyutlandırmada
          FareKonumu := fkSolUst;
          GecerliFareGostegeTipi := fitBoyutKBGD;
        end
        else if(Olay.Deger2 > _Pencere^.FBoyutlar.Alt - _Pencere^.FKalinlik.Alt) then
        begin

          // fare göstergesi alt & sol kısım boyutlandırmada
          FareKonumu := fkSolAlt;
          GecerliFareGostegeTipi := fitBoyutKDGB;
        end
        else
        begin

          // fare göstergesi sol kısım boyutlandırmada
          FareKonumu := fkSol;
          GecerliFareGostegeTipi := fitBoyutBD;
        end;
      end;

      Exit;
    end
    else

    // FO_HAREKET - nesne yakalanmış - taşıma, boyutlandırma
    begin

      if(FareKonumu = fkGovde) then
      begin

        GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik,
          _Pencere, Olay.Olay, Olay.Deger1, Olay.Deger2);

        Exit;
      end
      else
      begin

        if(FareKonumu = fkSolUst) then
        begin

          _YeniBoyut.Sol := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Ust := Olay.Deger2 - SonFareDikeyKoordinat;
          _YeniBoyut.Sag := -_YeniBoyut.Sol;
          _YeniBoyut.Alt := -_YeniBoyut.Ust;
        end
        else if(FareKonumu = fkSol) then
        begin

          _YeniBoyut.Sol := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Ust := 0;
          _YeniBoyut.Sag := -_YeniBoyut.Sol;
          _YeniBoyut.Alt := 0;
        end
        else if(FareKonumu = fkSolAlt) then
        begin

          _YeniBoyut.Sol := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Ust := 0;
          _YeniBoyut.Sag := -_YeniBoyut.Sol;
          _YeniBoyut.Alt := Olay.Deger2 - SonFareDikeyKoordinat;
          SonFareDikeyKoordinat := Olay.Deger2;
        end
        else if(FareKonumu = fkAlt) then
        begin

          _YeniBoyut.Sol := 0;
          _YeniBoyut.Ust := 0;
          _YeniBoyut.Sag := 0;
          _YeniBoyut.Alt := Olay.Deger2 - SonFareDikeyKoordinat;
          SonFareDikeyKoordinat := Olay.Deger2;
        end
        else if(FareKonumu = fkSagAlt) then
        begin

          _YeniBoyut.Sol := 0;
          _YeniBoyut.Ust := 0;
          _YeniBoyut.Sag := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Alt := Olay.Deger2 - SonFareDikeyKoordinat;
          SonFareYatayKoordinat := Olay.Deger1;
          SonFareDikeyKoordinat := Olay.Deger2;
        end
        else if(FareKonumu = fkSag) then
        begin

          _YeniBoyut.Sol := 0;
          _YeniBoyut.Ust := 0;
          _YeniBoyut.Sag := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Alt := 0;
          SonFareYatayKoordinat := Olay.Deger1;
        end
        else if(FareKonumu = fkSagUst) then
        begin

          _YeniBoyut.Sol := 0;
          _YeniBoyut.Ust := Olay.Deger2 - SonFareDikeyKoordinat;
          _YeniBoyut.Sag := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Alt := -_YeniBoyut.Ust;
          SonFareYatayKoordinat := Olay.Deger1;
        end
        else if(FareKonumu = fkUst) then
        begin

          _YeniBoyut.Sol := 0;
          _YeniBoyut.Ust := Olay.Deger2 - SonFareDikeyKoordinat;
          _YeniBoyut.Sag := 0;
          _YeniBoyut.Alt := -_YeniBoyut.Ust;
        end
        else if(FareKonumu = fkKontrolCubugu) then
        begin

          _YeniBoyut.Sol := Olay.Deger1 - SonFareYatayKoordinat;
          _YeniBoyut.Ust := Olay.Deger2 - SonFareDikeyKoordinat;
          _YeniBoyut.Sag := 0;
          _YeniBoyut.Alt := 0;
        end;

        FBoyutlar.Sol += _YeniBoyut.Sol;
        FBoyutlar.Sag += _YeniBoyut.Sag;
        FBoyutlar.Ust += _YeniBoyut.Ust;
        FBoyutlar.Alt += _YeniBoyut.Alt;

        // çizim için ayrılan belleği yok et ve yeni bellek ayır
        { TODO : ileride çizimlerin daha hızlı olması için pencere küçülmesi için bellek ayrılmayabilir }
        GGercekBellek.YokEt(_Pencere^.FCizimBellekAdresi, _Pencere^.FCizimBellekUzunlugu);

        _Pencere^.FCizimBellekUzunlugu := (FBoyutlar.Sag * FBoyutlar.Alt * 4);
        _Pencere^.FCizimBellekAdresi := GGercekBellek.Ayir(_Pencere^.FCizimBellekUzunlugu);

        _Pencere^.Guncelle;
      end;
    end;
  end
  // diğer olaylar
  else
  begin

    GorevListesi[_Pencere^.GorevKimlik]^.OlayEkle1(_Pencere^.GorevKimlik, _Pencere,
      Olay.Olay, Olay.Deger1, Olay.Deger2);
  end;
end;

{==============================================================================
  pencere kontrol düğmelerini çizer
 ==============================================================================}
procedure TPencere.KontrolDugmeleriniCiz(APencere: PPencere; APencereCizimAlani: TAlan;
  APencereAktif: Boolean);
var
  _KapatmaDugmesi, _BuyutmeDugmesi,
  _KucultmeDugmesi: PPencereDugme;
  B1, A1, i, j: TISayi4;
  Renk: TRenk;
begin

  // pencere düğmelerinin aktif / pasif olması
  if(APencereAktif) then
  begin

    _KapatmaDugmesi := @AktifKapatmaDugmesi;
    _BuyutmeDugmesi := @AktifBuyutmeDugmesi;
    _KucultmeDugmesi := @AktifKucultmeDugmesi;
  end
  else
  begin

    _KapatmaDugmesi := @PasifKapatmaDugmesi;
    _BuyutmeDugmesi := @PasifBuyutmeDugmesi;
    _KucultmeDugmesi := @PasifKucultmeDugmesi;
  end;

  // kapatma düğmesinin çizimi
  A1 := APencereCizimAlani.Sag + APencere^.FKapatmaDugmeBoyut.Sol3;
  B1 := APencereCizimAlani.Ust + APencere^.FKapatmaDugmeBoyut.Ust3;

  for j := 0 to APencere^.FKapatmaDugmeBoyut.B2 do
  begin

    for i := 0 to APencere^.FKapatmaDugmeBoyut.A2 do
    begin

      Renk := _KapatmaDugmesi^[j, i];
      PixelYaz(APencere, A1 + i, B1 + j, Renk);
    end;
  end;

  // pencere bir iletişim penceresi ise, çık
  if(APencere^.PencereTipi = ptIletisim) then Exit;

  // büyütme düğmesinin çizimi
  A1 := APencereCizimAlani.Sag + APencere^.FBuyutmeDugmeBoyut.Sol3;
  B1 := APencereCizimAlani.Ust + APencere^.FBuyutmeDugmeBoyut.Ust3;

  for j := 0 to APencere^.FBuyutmeDugmeBoyut.B2 do
  begin

    for i := 0 to APencere^.FBuyutmeDugmeBoyut.A2 do
    begin

      Renk := _BuyutmeDugmesi^[j, i];
      PixelYaz(APencere, A1 + i, B1 + j, Renk);
    end;
  end;

  // küçültme düğmesinin çizimi
  A1 := APencereCizimAlani.Sag + APencere^.FKucultmeDugmeBoyut.Sol3;
  B1 := APencereCizimAlani.Ust + APencere^.FKucultmeDugmeBoyut.Ust3;

  for j := 0 to APencere^.FKucultmeDugmeBoyut.B2 do
  begin

    for i := 0 to APencere^.FKucultmeDugmeBoyut.A2 do
    begin

      Renk := _KucultmeDugmesi^[j, i];
      PixelYaz(APencere, A1 + i, B1 + j, Renk);
    end;
  end;
end;

{==============================================================================
  fare göstergesinin pencere nesnesinin gövde (çizim alanı) içerisinde
  olup olmadığını kontrol eder
 ==============================================================================}
function TPencere.FarePencereCizimAlanindaMi(AKimlik: TKimlik): Boolean;
var
  _Pencere: PPencere;
  _Alan: TAlan;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Pencere := PPencere(_Pencere^.NesneTipiniKontrolEt(AKimlik, gntPencere));
  if(_Pencere = nil) then Exit;

  // nesnenin üst nesneye bağlı gerçek koordinatlarını al
  _Alan.Sol2 := _Pencere^.FDisGercekBoyutlar.Sol2;
  _Alan.Ust2 := _Pencere^.FDisGercekBoyutlar.Ust2;
  _Alan.Genislik2 := _Pencere^.FDisGercekBoyutlar.Genislik2;
  _Alan.Yukseklik2 := _Pencere^.FDisGercekBoyutlar.Yukseklik2;

  _Alan.Sol2 += _Pencere^.FKalinlik.Sol;
  _Alan.Ust2 += _Pencere^.FKalinlik.Ust;
  _Alan.Genislik2 -= _Pencere^.FKalinlik.Sag;
  _Alan.Yukseklik2 -= _Pencere^.FKalinlik.Alt;

  Result := False;

  if(_Alan.Sol > GFareSurucusu.YatayKonum) then Exit;
  if(_Alan.Sag < GFareSurucusu.YatayKonum) then Exit;
  if(_Alan.Ust > GFareSurucusu.DikeyKonum) then Exit;
  if(_Alan.Alt < GFareSurucusu.DikeyKonum) then Exit;

  Result := True;
end;

end.
