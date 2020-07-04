{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_pencere.pas
  Dosya Ýþlevi: pencere yönetim iþlevlerini içerir

  Güncelleme Tarihi: 23/06/2020

  Önemli Bilgiler:

    2. TPencere'nin alt nesnelerinden biri yeniden kýsmi olarak (TEtiket nesnesi gibi)
      çizilmek istendiðinde mutlaka üst nesne olan TPencere.Guncelle iþlevini çaðýrmalýdýr.
      Böylece pencere çizim tasarým gereði pencere öncelikle kendini çizecek daha
      sonra ise alt nesnelerinin çizilmesi için alt nesnenin Ciz iþlevini çaðýracaktýr.
      Bu durum en son geliþtirilen, pencerelerin bellekten belleðe aktarýlmasý ve
      eðimli dolgu (gradient) çizim iþlevleri için gereklidir

 ==============================================================================}
{$mode objfpc}
unit gn_pencere;

interface

uses gorselnesne, paylasim, gn_panel, gn_dugme, gn_resimdugmesi;

type
  PPencereTipi = ^TPencereTipi;
  TPencereTipi = (ptBoyutlanabilir, ptBasliksiz, ptIletisim);

  PPencereDurum = ^TPencereDurum;
  TPencereDurum = (pdNormal, pdKucultuldu, pdBuyutuldu);

type
  PPencere = ^TPencere;
  TPencere = object(TPanel)
  private
    procedure BasliksizPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
    procedure IletisimPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
    procedure BoyutlanabilirPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
    function FarePencereCizimAlanindaMi(APencere: PPencere): Boolean;
    procedure IcBilesenleriKonumlandir(var APencere: PPencere);
    procedure KontrolDugmesiOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  public
    FPencereDurum: TPencereDurum;
    FPencereTipi: TPencereTipi;
    FKucultmeDugmesi, FBuyutmeDugmesi, FKapatmaDugmesi: PResimDugmesi;
    function Olustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
      APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): PPencere;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure Guncelle;
    procedure EnUsteGetir(APencere: PPencere);
  end;

function PencereCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;

implementation

uses genel, gorev, gn_islevler, gn_masaustu, gn_gucdugmesi, gn_listekutusu,
  gn_defter, gn_islemgostergesi, gn_onaykutusu, gn_giriskutusu, gn_degerdugmesi,
  gn_etiket, gn_durumcubugu, gn_secimdugmesi, gn_baglanti, gn_resim, gn_listegorunum,
  gn_kaydirmacubugu, gn_karmaliste, gn_degerlistesi, gn_izgara, temelgorselnesne,
  giysi_mac, sistemmesaj;

const
  PENCERE_ALTLIMIT_GENISLIK = 110;
  PENCERE_ALTLIMIT_YUKSEKLIK = 26;

type
  TFareKonumu = (fkSolAlt, fkSol, fkSolUst, fkUst, fkSagUst, fkSag, fkSagAlt, fkAlt,
    fkGovde, fkKontrolCubugu);

var
  FareKonumu: TFareKonumu = fkGovde;
  SonFareYatayKoordinat, SonFareDikeyKoordinat: TISayi4;

{==============================================================================
    pencere kesme çaðrýlarýný yönetir
 ==============================================================================}
function PencereCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  AtaNesneKimlik: TISayi4;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:
    begin

      AtaNesneKimlik := PKimlik(ADegiskenler + 00)^;
      if(AtaNesneKimlik = -1) then
        GorselNesne := nil
      else GorselNesne := GorselNesne^.NesneAl(AtaNesneKimlik);

      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
      PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^,
      PISayi4(ADegiskenler + 16)^, PPencereTipi(ADegiskenler + 20)^,
      PKarakterKatari(PSayi4(ADegiskenler + 24)^ + CalisanGorevBellekAdresi)^,
      PRenk(ADegiskenler + 28)^);
    end;

    ISLEV_GOSTER:
    begin

      Pencere := PPencere(Pencere^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Pencere^.Goster;
    end;

    ISLEV_CIZ:
    begin

      // nesnenin kimlik, tip deðerlerini denetle.
      Pencere := PPencere(Pencere^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Pencere <> nil) then Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  pencere nesnesini oluþturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): TKimlik;
var
  Pencere: PPencere;
begin

  Pencere := Pencere^.Olustur(AAtaNesne, ASol, AUst, AGenislik, AYukseklik,
    APencereTipi, ABaslik, AGovdeRenk);

  if(Pencere = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := Pencere^.Kimlik;
end;

{==============================================================================
  pencere nesnesini oluþturur
 ==============================================================================}
function TPencere.Olustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  APencereTipi: TPencereTipi; ABaslik: string; AGovdeRenk: TRenk): PPencere;
var
  Gorev: PGorev;
  Masaustu: PMasaustu;
  Pencere: PPencere;
  Genislik, Yukseklik: TSayi4;
  Sol, Ust: TISayi4;
  i: TISayi4;
begin

  // ata nesne nil ise üst nesne geçerli masaüstüdür
  if(AAtaNesne = nil) then

    Masaustu := GAktifMasaustu
  else Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(AAtaNesne^.Kimlik, gntMasaustu));

  // geçerli masaüstü yok ise hata kodunu ver ve çýk
  if(Masaustu = nil) then Exit(nil);

  // pencere limit kontrolleri - baþlýksýz pencere hariç
  if not(APencereTipi = ptBasliksiz) then
  begin

    // pencere geniþliðinin en alt sýnýr deðerinin altýnda olup olmadýðýný kontrol et
    if(AGenislik < PENCERE_ALTLIMIT_GENISLIK) then
      Genislik := PENCERE_ALTLIMIT_GENISLIK
    else Genislik := AGenislik + (RESIM_SOL_G + RESIM_SAG_G);

    // pencere yüksekliðinin en alt sýnýr deðerinin altýnda olup olmadýðýný kontrol et
    if(AYukseklik < PENCERE_ALTLIMIT_YUKSEKLIK) then
      Yukseklik := PENCERE_ALTLIMIT_YUKSEKLIK
    else Yukseklik := AYukseklik + (BASLIK_Y + RESIM_ALT_Y);
  end
  else
  begin

    Genislik := AGenislik;
    Yukseklik := AYukseklik;
  end;

  Sol := ASol;
  Ust := AUst;
  if not(APencereTipi = ptBasliksiz) then
  begin

    if(AnaPencereyiOrtala) then
    begin

      Sol := (Masaustu^.FBoyut.Genislik div 2) - (AGenislik div 2);
      Ust := (Masaustu^.FBoyut.Yukseklik div 2) - (AYukseklik div 2);
    end;
  end;

  // pencere nesnesi oluþtur
  Pencere := PPencere(inherited Olustur(ktTuvalNesne, Masaustu, Sol, Ust, Genislik,
    Yukseklik, 0, AGovdeRenk, AGovdeRenk, 0, ABaslik));

  Pencere^.NesneTipi := gntPencere;

  Pencere^.Baslik := ABaslik;

  Pencere^.FTuvalNesne := Pencere;

  Pencere^.AnaOlayCagriAdresi := @OlaylariIsle;

  Gorev := Gorev^.GorevBul(CalisanGorev);
  if not(Gorev = nil) then Gorev^.FAnaPencere := Pencere;

  Pencere^.FPencereTipi := APencereTipi;
  Pencere^.FPencereDurum := pdNormal;

  Pencere^.FKucultmeDugmesi := nil;
  Pencere^.FBuyutmeDugmesi := nil;
  Pencere^.FKapatmaDugmesi := nil;

  if(APencereTipi = ptBasliksiz) then
  begin

    // pencere kalýnlýklarý
    Pencere^.FKalinlik.Sol := 0;
    Pencere^.FKalinlik.Ust := 0;
    Pencere^.FKalinlik.Sag := 0;
    Pencere^.FKalinlik.Alt := 0;

    // pencere çizim alaný
    Pencere^.FCizimAlan.Sol := 0;
    Pencere^.FCizimAlan.Ust := 0;
    Pencere^.FCizimAlan.Sag := Pencere^.FBoyut.Genislik - 1;
    Pencere^.FCizimAlan.Alt := Pencere^.FBoyut.Yukseklik - 1;
  end
  else
  begin

    // pencere kalýnlýklarý
    Pencere^.FKalinlik.Sol := RESIM_SOL_G;
    Pencere^.FKalinlik.Ust := BASLIK_Y;
    Pencere^.FKalinlik.Sag := RESIM_SAG_G;
    Pencere^.FKalinlik.Alt := RESIM_ALT_Y;

    // pencere çizim alaný
    Pencere^.FCizimAlan.Sol := 0;
    Pencere^.FCizimAlan.Ust := 0;
    Pencere^.FCizimAlan.Sag := Pencere^.FBoyut.Genislik -
      (Pencere^.FKalinlik.Sol + Pencere^.FKalinlik.Sag) - 1;
    Pencere^.FCizimAlan.Alt := Pencere^.FBoyut.Yukseklik -
      (Pencere^.FKalinlik.Ust + Pencere^.FKalinlik.Alt) - 1;

    // pencere kontrol düðmeleri
    if(Pencere^.FPencereTipi = ptBoyutlanabilir) then
    begin

      // küçültme düðmesi
      i := KUCULTME_DUGMESI_S;
      if(i < 0) then
        i := AGenislik - KUCULTME_DUGMESI_S
      else i := ASol + i;
      Pencere^.FKucultmeDugmesi := FKucultmeDugmesi^.Olustur(ktBilesen, Pencere,
        i, KUCULTME_DUGMESI_U, KUCULTME_DUGMESI_G, KUCULTME_DUGMESI_Y, $20000000 + 4, False);
      Pencere^.FKucultmeDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
      Pencere^.FKucultmeDugmesi^.Goster;

      // büyütme düðmesi
      i := BUYUTME_DUGMESI_S;
      if(i < 0) then
        i := AGenislik - BUYUTME_DUGMESI_S
      else i := ASol + i;
      Pencere^.FBuyutmeDugmesi := FBuyutmeDugmesi^.Olustur(ktBilesen, Pencere,
        i, BUYUTME_DUGMESI_U, BUYUTME_DUGMESI_G, BUYUTME_DUGMESI_Y, $20000000 + 2, False);
      Pencere^.FBuyutmeDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
      Pencere^.FBuyutmeDugmesi^.Goster;
    end;

    // kapatma düðmesi
    i := KAPATMA_DUGMESI_S;
    if(i < 0) then
      i := AGenislik - KAPATMA_DUGMESI_S
    else i := ASol + i;
    Pencere^.FKapatmaDugmesi := FKapatmaDugmesi^.Olustur(ktBilesen, Pencere,
      i, KAPATMA_DUGMESI_U, KAPATMA_DUGMESI_G, KAPATMA_DUGMESI_Y,
      $20000000 + 0, False);
    Pencere^.FKapatmaDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
    Pencere^.FKapatmaDugmesi^.Goster;
  end;

  // pencere'ye ait özel çizim alaný mevcut olduðundan dolayý çizim baþlangýç
  // sol ve üst deðerlerini sýfýr olarak ayarla
  Pencere^.FCizimBaslangic.Sol := 0;
  Pencere^.FCizimBaslangic.Ust := 0;

  // pencere çizimi için gereken bellek uzunluðu
  Pencere^.FCizimBellekUzunlugu := (Pencere^.FBoyut.Genislik *
    Pencere^.FBoyut.Yukseklik * 4);

  // pencere çizimi için bellekte yer ayýr
  Pencere^.FCizimBellekAdresi := GGercekBellek.Ayir(Pencere^.FCizimBellekUzunlugu);
  if(Pencere^.FCizimBellekAdresi = nil) then
  begin

    // hata olmasý durumunda nesneyi yok et ve iþlevden çýk
    Pencere^.YokEt;
    Result := nil;
    Exit;
  end;

  // nesne adresini geri döndür
  Result := Pencere;
end;

{==============================================================================
  pencere nesnesini görüntüler
 ==============================================================================}
procedure TPencere.Goster;
var
  Pencere: PPencere;
begin

  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  inherited Goster;

  // pencere nesnesinin üst nesnesi olan masaüstü görünür ise masaüstü nesnesini
  // en üste getir ve yeniden çiz
  if(Pencere^.AtaNesne^.Gorunum) then Pencere^.EnUsteGetir(Pencere);
end;

{==============================================================================
  pencere nesnesini gizler
 ==============================================================================}
procedure TPencere.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  pencere nesnesini boyutlandýrýr
 ==============================================================================}
procedure TPencere.Boyutlandir;
var
  Pencere: PPencere;
  GorunurNesne: PGorselNesne;
  AltNesneler: PPGorselNesne;
  i: TSayi4;
begin

  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  // kontrol düðmesine sahip olan pencerelerin iç bileþenlerini konumlandýr
  if not(Pencere^.FPencereTipi = ptBasliksiz) then
    IcBilesenleriKonumlandir(Pencere);

  // pencere alt nesnelerini yeniden boyutlandýr
  if(Pencere^.FAltNesneSayisi > 0) then
  begin

    AltNesneler := Pencere^.FAltNesneBellekAdresi;

    // ilk oluþturulan alt nesneden son oluþturulan alt nesneye doðru
    // pencerenin alt nesnelerini yeniden boyutlandýr
    for i := 0 to Pencere^.FAltNesneSayisi - 1 do
    begin

      GorunurNesne := AltNesneler[i];
      if(GorunurNesne^.Gorunum) then
      begin

        case GorunurNesne^.NesneTipi of
          gntBaglanti       : PBaglanti(GorunurNesne)^.Boyutlandir;
          gntDefter         : PDefter(GorunurNesne)^.Boyutlandir;
          gntDegerDugmesi   : PDegerDugmesi(GorunurNesne)^.Boyutlandir;
          gntDegerListesi   : PDegerListesi(GorunurNesne)^.Boyutlandir;
          gntDugme          : PDugme(GorunurNesne)^.Boyutlandir;
          gntDurumCubugu    : PDurumCubugu(GorunurNesne)^.Boyutlandir;
          gntEtiket         : PEtiket(GorunurNesne)^.Boyutlandir;
          gntGirisKutusu    : PGirisKutusu(GorunurNesne)^.Boyutlandir;
          gntGucDugmesi     : PGucDugmesi(GorunurNesne)^.Boyutlandir;
          gntIslemGostergesi: PIslemGostergesi(GorunurNesne)^.Boyutlandir;
          gntIzgara         : PIzgara(GorunurNesne)^.Boyutlandir;
          gntKarmaListe     : PKarmaListe(GorunurNesne)^.Boyutlandir;
          gntKaydirmaCubugu : PKaydirmaCubugu(GorunurNesne)^.Boyutlandir;
          gntListeGorunum   : PListeGorunum(GorunurNesne)^.Boyutlandir;
          gntListeKutusu    : PListeKutusu(GorunurNesne)^.Boyutlandir;
          gntOnayKutusu     : POnayKutusu(GorunurNesne)^.Boyutlandir;
          gntPanel          : PPanel(GorunurNesne)^.Boyutlandir;
          gntResim          : PResim(GorunurNesne)^.Boyutlandir;
          gntResimDugmesi   : PResimDugmesi(GorunurNesne)^.Boyutlandir;
          gntSecimDugmesi   : PSecimDugmesi(GorunurNesne)^.Boyutlandir;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  pencere nesnesini çizer

  önemli: pencere nesnesi çizilmeden önce içsel bileþenler (kapatma, büyütme düðmesi)
    ve diðer alt görsel bileþenler yeniden boyutlandýrýlmalýdýr. Bu sebepten dolayý
    boyutlandýrmalara baðlý çizim istekleri için TPencere.Guncelle iþlevi çaðrýlmalýdýr
 ==============================================================================}
procedure TPencere.Ciz;
var
  Pencere: PPencere;
  GiysiSol: PResimSolUst;
  GiysiSolAlt: PResimSolAlt;
  GiysiSagAlt: PResimSagAlt;
  GiysiOrta: PResimUst;
  GiysiAlt2: PResimAlt;
  GiysiSol2: PResimSol;
  GiysiSag2: PResimSag;
  GiysiSag: PResimSagUst;
  Olay: TOlay;
  Alan: TAlan;
  Sol, Sag, Genislik, Ust, Alt, i, j: TISayi4;
  Renk, BaslikRengi: TRenk;
  PencereAktif: Boolean;
  AltNesneler: PPGorselNesne;
  GorunurNesne: PGorselNesne;
begin

  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  Pencere^.FCiziliyor := True;

  Pencere^.Boyutlandir;

  // pencerenin kendi deðerlerine baðlý (0, 0) koordinatlarýný al
  Alan := Pencere^.FCizimAlan;

  Alan.Sag += (Pencere^.FKalinlik.Sol + Pencere^.FKalinlik.Sag);
  Alan.Alt += (Pencere^.FKalinlik.Ust + Pencere^.FKalinlik.Alt);

  // pencere tipi baþlýksýz ise, artan renk ile (eðimli) doldur
  if(Pencere^.FPencereTipi = ptBasliksiz) then

    EgimliDoldur3(Pencere, Alan, $D0DBFB, $B9C9F9)
  else
  // baþlýklý pencere nesnesinin çizimi
  begin

    // aktif veya pasif çizimin belirlenmesi
    PencereAktif := (Pencere = AktifPencere);

    if(PencereAktif) then
    begin

      GiysiSol := @ResimSolUstA;
      GiysiOrta := @ResimUstA;
      GiysiSag := @ResimSagUstA;
      GiysiSol2 := @ResimSolA;
      GiysiSag2 := @ResimSagA;
      GiysiAlt2 := @ResimAltA;
      GiysiSolAlt := @ResimSolAltA;
      GiysiSagAlt := @ResimSagAltA;
      BaslikRengi := AKTIF_BASLIK_RENGI;

      // kontrol düðmelerini aktifleþtir
      if not(Pencere^.FKucultmeDugmesi = nil) then
        Pencere^.FKucultmeDugmesi^.Deger := $20000000 + 4;
      if not(Pencere^.FBuyutmeDugmesi = nil) then
        Pencere^.FBuyutmeDugmesi^.Deger := $20000000 + 2;
      if not(Pencere^.FKapatmaDugmesi = nil) then
        Pencere^.FKapatmaDugmesi^.Deger := $20000000 + 0;
    end
    else
    begin

      GiysiSol := @ResimSolUstP;
      GiysiOrta := @ResimUstP;
      GiysiSag := @ResimSagUstP;
      GiysiSol2 := @ResimSolP;
      GiysiSag2 := @ResimSagP;
      GiysiAlt2 := @ResimAltP;
      GiysiSolAlt := @ResimSolAltP;
      GiysiSagAlt := @ResimSagAltP;
      BaslikRengi := PASIF_BASLIK_RENGI;

      // kontrol düðmelerini pasifleþtir
      if not(Pencere^.FKucultmeDugmesi = nil) then
        Pencere^.FKucultmeDugmesi^.Deger := $20000000 + 5;
      if not(Pencere^.FBuyutmeDugmesi = nil) then
        Pencere^.FBuyutmeDugmesi^.Deger := $20000000 + 3;
      if not(Pencere^.FKapatmaDugmesi = nil) then
        Pencere^.FKapatmaDugmesi^.Deger := $20000000 + 1;
    end;

    // pencerenin giydirilmesi

    // 1. sol baþlýk kýsmýnýn çizilmesi
    for Ust := 0 to BASLIK_Y - 1 do
    begin

      for Sol := 0 to RESIM_SOLUST_G - 1 do
      begin

        Renk := GiysiSol^[Ust, Sol];
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol, Ust, Renk);
      end;
    end;

    // 2. orta baþlýk kýsmýnýn çizilmesi
    Sol := RESIM_SOLUST_G;
    Sag := Alan.Sag - RESIM_SAGUST_G + 1;
    while True do
    begin

      for i := 0 to BASLIK_Y - 1 do
      begin

        for j := 0 to RESIM_UST_G - 1 do
        begin

          Renk := GiysiOrta^[i, j];
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, i, Renk);
        end;
      end;

      Sol += RESIM_UST_G;
      if(Sol >= Sag) then Break;

      if(Sol + RESIM_UST_G > Sag) then
        Sol := Sag - RESIM_UST_G;
    end;

    // 3. sað baþlýk kýsmýnýn çizilmesi
    i := Alan.Sag - RESIM_SAGUST_G + 1;
    for Ust := 0 to BASLIK_Y - 1 do
    begin

      for Sol := 0 to RESIM_SAGUST_G - 1 do
      begin

        Renk := GiysiSag^[Ust, Sol];
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, i + Sol, Ust, Renk);
      end;
    end;

    // 2. sol kenarlýðýn çizilmesi
    Ust := BASLIK_Y;
    Alt := Alan.Alt - RESIM_SOLALT_Y + 1;
    while True do
    begin

      for i := 0 to RESIM_SOL_Y - 1 do
      begin

        for j := 0 to RESIM_SOL_G - 1 do
        begin

          Renk := GiysiSol2^[i, j];
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, j, Ust + i, Renk);
        end;
      end;

      Ust += RESIM_SOL_Y;
      if(Ust >= Alt) then Break;

      if(Ust + RESIM_SOL_Y > Alt) then Ust := (Alt - RESIM_SOL_Y)
    end;

    // 2. sað kenarlýðýn çizilmesi
    Ust := BASLIK_Y;
    Alt := Alan.Alt - RESIM_SAGALT_Y + 1;
    Sol := Alan.Sag - RESIM_SAG_G + 1;
    while True do
    begin

      for i := 0 to RESIM_SAG_Y - 1 do
      begin

        for j := 0 to RESIM_SAG_G - 1 do
        begin

          Renk := GiysiSag2^[i, j];
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, Ust + i, Renk);
        end;
      end;

      Ust += RESIM_SAG_Y;
      if(Ust >= Alt) then Break;

      if(Ust + RESIM_SAG_Y > Alt) then Ust := (Alt - RESIM_SAG_Y)
    end;

    // 2. alt kenarlýðýn çizilmesi
    Sol := RESIM_SOLALT_G;
    Ust := Alan.Alt - RESIM_ALT_Y + 1;
    Sag := Alan.Sag - RESIM_SAGALT_G + 1;
    while True do
    begin

     for i := 0 to RESIM_ALT_Y - 1 do
     begin

       for j := 0 to RESIM_ALT_G - 1 do
       begin

         Renk := GiysiAlt2^[i, j];
         if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, Ust + i, Renk);
       end;
     end;

     Sol += RESIM_ALT_G;
     if(Sol >= Sag) then Break;

     if(Sol + RESIM_ALT_G > Sag) then
       Sol := Sag - RESIM_ALT_G;
    end;

    // 1. sol alt kýsmýnýn çizilmesi
    i := Alan.Alt - RESIM_SOLALT_Y + 1;
    for Ust := 0 to RESIM_SOLALT_Y - 1 do
    begin

      for Sol := 0 to RESIM_SOLALT_G - 1 do
      begin

        Renk := GiysiSolAlt^[Ust, Sol];
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol, i + Ust, Renk);
      end;
    end;

    // 1. sað alt kýsmýnýn çizilmesi
    i := Alan.Sag - RESIM_SAGALT_G + 1;
    j := Alan.Alt - RESIM_SAGALT_Y + 1;
    for Ust := 0 to RESIM_SAGALT_Y - 1 do
    begin

      for Sol := 0 to RESIM_SAGALT_G - 1 do
      begin

        Renk := GiysiSagAlt^[Ust, Sol];
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, i + Sol, j + Ust, Renk);
      end;
    end;

    // pencere iç bölüm boyama
    Renk := IC_DOLGU_RENGI;
    if(Renk = $FFFFFFFF) then Renk := Pencere^.FGovdeRenk1;

    DikdortgenDoldur(Pencere, RESIM_SOL_G, BASLIK_Y, Alan.Sag - RESIM_SAG_G,
      Alan.Alt - RESIM_ALT_Y, Renk, Renk);

    // pencere baþlýðýný yaz
    i := GIYSI_BASLIK_YAZI_S;
    if(i = -1) then
      i := (Pencere^.FBoyut.Genislik div 2) - ((Length(Pencere^.Baslik) * 8) div 2);

    j := GIYSI_BASLIK_YAZI_S;
    if(j = -1) then
      j := (BASLIK_Y div 2) - (16 div 2);

    YaziYaz(Pencere, i, j, Pencere^.Baslik, BaslikRengi);

    if not(Pencere^.FPencereTipi = ptBasliksiz) then
    begin

      if(Pencere^.FPencereTipi = ptBoyutlanabilir) then
      begin

        Pencere^.FKucultmeDugmesi^.Ciz;
        Pencere^.FBuyutmeDugmesi^.Ciz;
      end;

      Pencere^.FKapatmaDugmesi^.Ciz;
    end;
  end;

  AltNesneler := Pencere^.FAltNesneBellekAdresi;
  if(Pencere^.FAltNesneSayisi > 0) then
  begin

    // ilk oluþturulan alt nesneden son oluþturulan alt nesneye doðru
    // pencerenin alt nesnelerini çiz
    for i := 0 to Pencere^.FAltNesneSayisi - 1 do
    begin

      GorunurNesne := AltNesneler[i];
      if(GorunurNesne^.Gorunum) and not(GorunurNesne^.Kimlik = HATA_KIMLIK) then
      begin

        // pencere nesnesinin altýnda çizilecek nesneler
        case GorunurNesne^.NesneTipi of
          gntBaglanti       : PBaglanti(GorunurNesne)^.Ciz;
          gntDefter         : PDefter(GorunurNesne)^.Ciz;
          gntDegerDugmesi   : PDegerDugmesi(GorunurNesne)^.Ciz;
          gntDegerListesi   : PDegerListesi(GorunurNesne)^.Ciz;
          gntDugme          : PDugme(GorunurNesne)^.Ciz;
          gntDurumCubugu    : PDurumCubugu(GorunurNesne)^.Ciz;
          gntEtiket         : PEtiket(GorunurNesne)^.Ciz;
          gntGirisKutusu    : PGirisKutusu(GorunurNesne)^.Ciz;
          gntGucDugmesi     : PGucDugmesi(GorunurNesne)^.Ciz;
          gntIslemGostergesi: PIslemGostergesi(GorunurNesne)^.Ciz;
          gntIzgara         : PIzgara(GorunurNesne)^.Ciz;
          gntKarmaListe     : PKarmaListe(GorunurNesne)^.Ciz;
          gntKaydirmaCubugu : PKaydirmaCubugu(GorunurNesne)^.Ciz;
          gntListeGorunum   : PListeGorunum(GorunurNesne)^.Ciz;
          gntListeKutusu    : PListeKutusu(GorunurNesne)^.Ciz;
          gntOnayKutusu     : POnayKutusu(GorunurNesne)^.Ciz;
          gntPanel          : PPanel(GorunurNesne)^.Ciz;
          gntResim          : PResim(GorunurNesne)^.Ciz;
          gntResimDugmesi   : PResimDugmesi(GorunurNesne)^.Ciz;
          gntSecimDugmesi   : PSecimDugmesi(GorunurNesne)^.Ciz;
        end;
      end;
    end;
  end;

  // uygulamaya veya efendi nesneye mesaj gönder
  Olay.Kimlik := Pencere^.Kimlik;
  Olay.Olay := CO_CIZIM;
  Olay.Deger1 := 0;
  Olay.Deger2 := 0;
  if not(Pencere^.OlayCagriAdresi = nil) then
    Pencere^.OlayCagriAdresi(Pencere, Olay)
  else GorevListesi[Pencere^.GorevKimlik]^.OlayEkle(Pencere^.GorevKimlik, Olay);

  Pencere^.FCiziliyor := False;
end;

{==============================================================================
  pencere nesne olaylarýný iþler
 ==============================================================================}
procedure TPencere.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
begin

  Pencere := PPencere(AGonderici);
  if(Pencere = nil) then Exit;

  // olaylarý ilgili iþlevlere yönlendir
  case Pencere^.FPencereTipi of
    ptBasliksiz       : BasliksizPencereOlaylariniIsle(Pencere, AOlay);
    ptIletisim        : IletisimPencereOlaylariniIsle(Pencere, AOlay);
    ptBoyutlanabilir  : BoyutlanabilirPencereOlaylariniIsle(Pencere, AOlay);
  end;
end;

{==============================================================================
  baþlýksýz pencere nesne olaylarýný iþler
 ==============================================================================}
procedure TPencere.BasliksizPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
begin

  // sol tuþa basým iþlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif deðilse aktifleþtir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // sol tuþ basým iþlemi olay alanýnda gerçekleþtiyse
    if(APencere^.FareNesneOlayAlanindaMi(APencere)) then
    begin

      // fare mesajlarýný APencere nesnesine yönlendir
      OlayYakalamayaBasla(APencere);

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;
  end

  // sol tuþ býrakým iþlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare mesajlarýný yakalamayý býrak
    OlayYakalamayiBirak(APencere);

    // sol tuþ býrakým iþlemi olay alanýnda gerçekleþtiyse
    if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end
  // diðer olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
end;

{==============================================================================
  iletiþim pencere nesne olaylarýný iþler
 ==============================================================================}
procedure TPencere.IletisimPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
var
  Alan: TAlan;
begin

  // sol tuþa basým iþlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif deðilse aktifleþtir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // sol tuþ basým iþlemi olay alanýnda gerçekleþtiyse
    if(APencere^.FareNesneOlayAlanindaMi(APencere)) then
    begin

      // fare mesajlarýný APencere nesnesine yönlendir
      OlayYakalamayaBasla(APencere);

      // eðer týklama pencerenin gövdesinde gerçekleþmiþse
      if(FareKonumu = fkGovde) then
      begin

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj gönder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else

      // aksi durumda týklama iþlemi yakalama çubuðunda gerçekleþmiþtir
      // o zaman pencerenin kenarlýklarýný sakla
      begin

        GecerliFareGostegeTipi := fitBoyutTum;
        SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
        SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;
      end;
    end else GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
  end

  // sol tuþ býrakým iþlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarýný almayý býrak
    OlayYakalamayiBirak(APencere);

    // taþýma iþlemi pencere çizim alanýnda gerçekleþmiþse
    if not(FareKonumu = fkKontrolCubugu) then
    begin

      // býrakma iþlemi APencere içerinde gerçekleþtiyse
      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj gönder
        AOlay.Olay := FO_TIKLAMA;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);

        // uygulamaya veya efendi nesneye mesaj gönder
        AOlay.Olay := FO_SOLTUS_BIRAKILDI;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else

      // býrakma iþlemi APencere dýþýnda gerçekleþtiyse
      begin

        { TODO : býrakma iþlemi APencere dýþýnda olursa normalde kursor de ilgili
          nesnenin kursörü olur }
        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj gönder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;
    end;
  end

  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // fare yakalanmamýþsa sadece fare göstergesini güncelle
    if(YakalananGorselNesne = nil) then
    begin

      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin

        FareKonumu := fkGovde;
        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj gönder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else
      begin

        FareKonumu := fkKontrolCubugu;
        GecerliFareGostegeTipi := fitBoyutTum;

        // uygulamaya veya efendi nesneye mesaj gönder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;
    end
    else

    // fare yakalanmýþ olduðu için taþýma iþlemlerini gerçekleþtir
    begin

      if(FareKonumu = fkKontrolCubugu) then
      begin

        Alan.Sol := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
        Alan.Ust := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
        Alan.Sag := 0;
        Alan.Alt := 0;

        SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
        SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;

        APencere^.FKonum.Sol += Alan.Sol;
        APencere^.FBoyut.Genislik += Alan.Sag;
        APencere^.FKonum.Ust += Alan.Ust;
        APencere^.FBoyut.Yukseklik += Alan.Alt;

        GecerliFareGostegeTipi := fitBoyutTum;

        APencere^.Guncelle;
      end
      else
      begin

        // uygulamaya veya efendi nesneye mesaj gönder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
      end;
    end;
  end
  // diðer olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;
end;

{==============================================================================
  boyutlandýrýlabilir pencere nesne olaylarýný iþler
 ==============================================================================}
procedure TPencere.BoyutlanabilirPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
var
  Alan: TAlan;
begin

  // sol tuþa basým iþlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif deðilse aktifleþtir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // fare olaylarýný APencere nesnesine yönlendir
    OlayYakalamayaBasla(APencere);

    // eðer farenin sol tuþu APencere nesnesinin gövdesine týklanmýþsa ...
    if(FareKonumu = fkGovde) then
    begin

      GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik,
        AOlay);
    end
    else
    begin

      // aksi durumda taþýma / boyutlandýrma iþlemi gerçekleþtirilecektir.
      // deðiþken içeriklerini güncelle
      SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
      SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;
    end;
  end

  // sol tuþ býrakma iþlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare mesajlarýný yakalamayý býrak
    OlayYakalamayiBirak(APencere);

    // fare býrakma iþlemi nesnenin içerisinde mi gerçekleþti ?
    if(FareKonumu = fkGovde) then
    begin

      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin
        // yakalama & býrakma iþlemi bu nesnede olduðu için
        // nesneye FO_TIKLAMA mesajý gönder
        AOlay.Olay := FO_TIKLAMA;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;

      // nesneye sadece FO_SOLTUS_BIRAKILDI mesajý gönder
      AOlay.Olay := FO_SOLTUS_BIRAKILDI;
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;
  end

  // fare hareket iþlemleri
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // FO_HAREKET - nesne yakalanmamýþ
    if(YakalananGorselNesne = nil) then
    begin

      // fare > sol çizgi kalýnlýk
      if(AOlay.Deger1 > APencere^.FKalinlik.Sol) then
      begin

        // fare < sað çizgi kalýnlýk
        if(AOlay.Deger1 < (APencere^.FBoyut.Genislik - APencere^.FKalinlik.Sag)) then
        begin

          // fare < alt çizgi kalýnlýk
          if(AOlay.Deger2 < (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
          begin

            // fare > alt çizgi kalýnlýk
            // bilgi: üst çizgi kalýnlýk deðeri baþlýk çubuðu deðeri olduðundan dolayý
            // üst çizgi kalýnlýk deðeri olarak alt çizgi kalýnlýk deðeri kullanýlmaktadýr
            if(AOlay.Deger2 > APencere^.FKalinlik.Alt) then
            begin

              // fare > yakalama çubuðu
              // bu deðer yakalama çubuðu için kullanýlýyor. hata yok
              if(AOlay.Deger2 > APencere^.FKalinlik.Ust) then
              begin

                // fare göstergesi APencere gövdesinde
                FareKonumu := fkGovde;
                GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
                GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
              end
              else
              begin

                // fare göstergesi yakalama çubuðunda
                FareKonumu := fkKontrolCubugu;
                GecerliFareGostegeTipi := fitBoyutTum;
              end;
            end
            else
            begin

              // fare göstergesi üst boyutlandýrmada
              FareKonumu := fkUst;
              GecerliFareGostegeTipi := fitBoyutKG;
            end;
          end
          else
          begin

            // fare göstergesi alt boyutlandýrmada
            FareKonumu := fkAlt;
            GecerliFareGostegeTipi := fitBoyutKG;
          end;
        end
        else
        // sað - alt / üst / orta (sað) kontrolü
        begin

          // bilgi: APencere^.FKalinlik.Alt deðeri aslýnda APencere^.FKalinlik.Ust deðeri olmalýdýr
          // fakat APencere^.FKalinlik.Ust deðeri baþlýk kalýnlýðý olarak kullanýlmaktadýr
          if(AOlay.Deger2 < APencere^.FKalinlik.Alt) then
          begin

            // fare göstergesi sað & üst boyutlandýrmada
            FareKonumu := fkSagUst;
            GecerliFareGostegeTipi := fitBoyutKDGB;
          end
          else if(AOlay.Deger2 > (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
          begin

            // fare göstergesi sað & alt boyutlandýrmada
            FareKonumu := fkSagAlt;
            GecerliFareGostegeTipi := fitBoyutKBGD;
          end
          else
          begin

            // fare göstergesi sað kýsým boyutlandýrmada
            FareKonumu := fkSag;
            GecerliFareGostegeTipi := fitBoyutBD;
          end;
        end;
      end
      else
      // sol - alt / üst / orta (sol) kontrolü
      begin

        if(AOlay.Deger2 < APencere^.FKalinlik.Alt) then
        begin

          // fare göstergesi üst & sol kýsým boyutlandýrmada
          FareKonumu := fkSolUst;
          GecerliFareGostegeTipi := fitBoyutKBGD;
        end
        else if(AOlay.Deger2 > (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
        begin

          // fare göstergesi alt & sol kýsým boyutlandýrmada
          FareKonumu := fkSolAlt;
          GecerliFareGostegeTipi := fitBoyutKDGB;
        end
        else
        begin

          // fare göstergesi sol kýsým boyutlandýrmada
          FareKonumu := fkSol;
          GecerliFareGostegeTipi := fitBoyutBD;
        end;
      end;
    end
    else

    // FO_HAREKET - nesne yakalanmýþ - taþýma, boyutlandýrma
    begin

      if(FareKonumu = fkGovde) then
      begin

        GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else
      begin

        if(FareKonumu = fkSolUst) then
        begin

          Alan.Sol := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Ust := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
          Alan.Sag := -Alan.Sol;
          Alan.Alt := -Alan.Ust;
        end
        else if(FareKonumu = fkSol) then
        begin

          Alan.Sol := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Ust := 0;
          Alan.Sag := -GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Alt := 0;
        end
        else if(FareKonumu = fkSolAlt) then
        begin

          Alan.Sol := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Ust := 0;
          Alan.Sag := -Alan.Sol;
          Alan.Alt := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
        end
        else if(FareKonumu = fkAlt) then
        begin

          Alan.Sol := 0;
          Alan.Ust := 0;
          Alan.Sag := 0;
          Alan.Alt := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
        end
        else if(FareKonumu = fkSagAlt) then
        begin

          Alan.Sol := 0;
          Alan.Ust := 0;
          Alan.Sag := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Alt := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
        end
        else if(FareKonumu = fkSag) then
        begin

          Alan.Sol := 0;
          Alan.Ust := 0;
          Alan.Sag := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Alt := 0;
        end
        else if(FareKonumu = fkSagUst) then
        begin

          Alan.Sol := 0;
          Alan.Ust := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
          Alan.Sag := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Alt := -Alan.Ust;
        end
        else if(FareKonumu = fkUst) then
        begin

          Alan.Sol := 0;
          Alan.Ust := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
          Alan.Sag := 0;
          Alan.Alt := -Alan.Ust;
        end
        else if(FareKonumu = fkKontrolCubugu) then
        begin

          Alan.Sol := GFareSurucusu.YatayKonum - SonFareYatayKoordinat;
          Alan.Ust := GFareSurucusu.DikeyKonum - SonFareDikeyKoordinat;
          Alan.Sag := 0;
          Alan.Alt := 0;
        end;

        SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
        SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;

        APencere^.FKonum.Sol += Alan.Sol;
        APencere^.FBoyut.Genislik += Alan.Sag;
        APencere^.FKonum.Ust += Alan.Ust;
        APencere^.FBoyut.Yukseklik += Alan.Alt;

        APencere^.FCizimAlan.Sol := 0;
        APencere^.FCizimAlan.Ust := 0;
        APencere^.FCizimAlan.Sag := APencere^.FBoyut.Genislik - 1;
        APencere^.FCizimAlan.Alt := APencere^.FBoyut.Yukseklik - 1;

        //if(APencere^.FCiziliyor) then Exit;

        APencere^.Boyutlandir;

        // çizim için ayrýlan belleði yok et ve yeni bellek ayýr
        { TODO : ileride çizimlerin daha hýzlý olmasý için APencere küçülmesi için bellek ayrýlmayabilir }
        GGercekBellek.YokEt(APencere^.FCizimBellekAdresi, APencere^.FCizimBellekUzunlugu);

        APencere^.FCizimBellekUzunlugu := (APencere^.FBoyut.Genislik * APencere^.FBoyut.Yukseklik * 4);
        APencere^.FCizimBellekAdresi := GGercekBellek.Ayir(APencere^.FCizimBellekUzunlugu);

        APencere^.Ciz;
      end;
    end;
  end
  // diðer olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;
end;

{==============================================================================
  pencere nesnesi ve alt nesnelerini günceller
  önemli: tüm alt nesneler çizim istekleri için bu iþlevi (TPencere.Guncelle) çaðýrmalýdýr
 ==============================================================================}
procedure TPencere.Guncelle;
var
  Pencere: PPencere;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  Pencere^.Boyutlandir;

  Pencere^.Ciz;
end;

{==============================================================================
  belirtilen pencere nesnesini en üste getirir ve yeniden çizer
 ==============================================================================}
procedure TPencere.EnUsteGetir(APencere: PPencere);
var
  Masaustu: PMasaustu;
  BirOncekiPencere: PPencere;
  AltNesneBellekAdresi: PPGorselNesne;
  GorselNesne: PGorselNesne;
  i, j: TISayi4;
begin

{------------------------------------------------------------------------------
  Sýralama            0   1   2
                    +---+---+---+
  Nesne Kimlikleri  | 1 | 2 | 3 |
                    +-+-+---+-+-+
                      |       +----- en üst nesne
                      +------------- en alt nesne
-------------------------------------------------------------------------------}

  // aktif masaüstünü al
  Masaustu := GAktifMasaustu;

  // masaüstünün alt nesne bellek deðerini al
  AltNesneBellekAdresi := Masaustu^.FAltNesneBellekAdresi;

  // nesnenin alt nesne sayýsý var ise
  if(Masaustu^.FAltNesneSayisi > 1) then
  begin

    BirOncekiPencere := PPencere(AltNesneBellekAdresi[Masaustu^.FAltNesneSayisi - 1]);

    // alt nesneler içerisinde pencere nesnesini ara
    for i := (Masaustu^.FAltNesneSayisi - 1) downto 0 do
    begin

      if(PPencere(AltNesneBellekAdresi[i]) = APencere) then Break;
    end;

    // eðer pencere nesnesi en üstte deðil ise
    if(i <> Masaustu^.FAltNesneSayisi - 1) then
    begin

      // pencere nesnesini masaüstü nesne belleðinde en üste getir
      for j := i to Masaustu^.FAltNesneSayisi - 2 do
      begin

        GorselNesne := AltNesneBellekAdresi[j + 0];
        AltNesneBellekAdresi[j + 0] := AltNesneBellekAdresi[j + 1];
        AltNesneBellekAdresi[j + 1] := GorselNesne;
      end;
    end;

    // pencere en üstte olsa da olmasa da aktif pencere olarak tanýmla
    // not: pencere en üstte olup görüntülenmiþ olmayabilir
    AktifPencere := APencere;

    // bir önceki pencereyi yeniden çiz
    if(BirOncekiPencere^.Gorunum) then BirOncekiPencere^.Guncelle;

    // aktif pencereyi yeniden çiz
    AktifPencere^.Guncelle;
  end;
end;

{==============================================================================
  fare göstergesinin pencere nesnesinin gövde (çizim alaný) içerisinde
  olup olmadýðýný kontrol eder
 ==============================================================================}
function TPencere.FarePencereCizimAlanindaMi(APencere: PPencere): Boolean;
var
  Alan: TAlan;
begin

  Alan.Sol := APencere^.FKonum.Sol + APencere^.FKalinlik.Sol;
  Alan.Ust := APencere^.FKonum.Ust + APencere^.FKalinlik.Ust;
  Alan.Sag := Alan.Sol + (APencere^.FBoyut.Genislik + APencere^.FKalinlik.Sag);
  Alan.Alt := Alan.Ust + (APencere^.FBoyut.Yukseklik + APencere^.FKalinlik.Alt);

  // öndeðer dönüþ deðeri
  Result := False;

  // fare belirtilen koordinatlar içerisinde mi ?
  if(GFareSurucusu.YatayKonum < Alan.Sol) then Exit;
  if(GFareSurucusu.YatayKonum > Alan.Sag) then Exit;
  if(GFareSurucusu.DikeyKonum < Alan.Ust) then Exit;
  if(GFareSurucusu.DikeyKonum > Alan.Alt) then Exit;

  Result := True;
end;

{==============================================================================
  pencere nesnesini yeniden boyutlandýrýr iç bileþenlerini konumlandýrýr
 ==============================================================================}
procedure TPencere.IcBilesenleriKonumlandir(var APencere: PPencere);
var
  i: TISayi4;
begin

  APencere^.FCizimAlan.Sag := APencere^.FBoyut.Genislik -
    (APencere^.FKalinlik.Sol + APencere^.FKalinlik.Sag) - 1;
  APencere^.FCizimAlan.Alt := APencere^.FBoyut.Yukseklik -
    (APencere^.FKalinlik.Ust + APencere^.FKalinlik.Alt) - 1;

  // alt nesnelerin sýnýrlanacaðý hiza alanýný sýfýrla
  APencere^.HizaAlaniniSifirla;

  if(APencere^.FPencereTipi = ptBoyutlanabilir) then
  begin

    i := KUCULTME_DUGMESI_S;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik - KUCULTME_DUGMESI_S;
    APencere^.FKucultmeDugmesi^.FKonum.Sol := i;
    APencere^.FKucultmeDugmesi^.FKonum.Ust := KUCULTME_DUGMESI_U;

    i := BUYUTME_DUGMESI_S;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik - BUYUTME_DUGMESI_S;
    APencere^.FBuyutmeDugmesi^.FKonum.Sol := i;
    APencere^.FKucultmeDugmesi^.FKonum.Ust := BUYUTME_DUGMESI_U;

    i := KAPATMA_DUGMESI_S;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik - KAPATMA_DUGMESI_S;
    APencere^.FKapatmaDugmesi^.FKonum.Sol := i;
    APencere^.FKapatmaDugmesi^.FKonum.Ust := KAPATMA_DUGMESI_U;

    APencere^.FKucultmeDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FKucultmeDugmesi^.FKonum.Sol;
    APencere^.FKucultmeDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FKucultmeDugmesi^.FKonum.Ust;
    APencere^.FBuyutmeDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FBuyutmeDugmesi^.FKonum.Sol;
    APencere^.FBuyutmeDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FBuyutmeDugmesi^.FKonum.Ust;
    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FKapatmaDugmesi^.FKonum.Sol;
    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FKapatmaDugmesi^.FKonum.Ust;
  end
  else
  begin

    i := KAPATMA_DUGMESI_S;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik - KAPATMA_DUGMESI_S;
    APencere^.FKapatmaDugmesi^.FKonum.Sol := i;
    APencere^.FKapatmaDugmesi^.FKonum.Ust := KAPATMA_DUGMESI_U;

    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FKapatmaDugmesi^.FKonum.Sol;
    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FKapatmaDugmesi^.FKonum.Ust;
  end;
end;

procedure TPencere.KontrolDugmesiOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  ResimDugmesi: PResimDugmesi;
  Pencere: PPencere;
  Gorev: PGorev;
begin

  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    ResimDugmesi := PResimDugmesi(AGonderici);
    if(ResimDugmesi = nil) then Exit;

    Pencere := PPencere(ResimDugmesi^.AtaNesne);

    if(ResimDugmesi^.Kimlik = Pencere^.FKucultmeDugmesi^.Kimlik) then
      Pencere^.FPencereDurum := pdKucultuldu
    else if(ResimDugmesi^.Kimlik = Pencere^.FBuyutmeDugmesi^.Kimlik) then
      SISTEM_MESAJ('Bilgi: büyütme düðmesi iþlevi yapýlandýrýlacak', [])
    else if(ResimDugmesi^.Kimlik = Pencere^.FKapatmaDugmesi^.Kimlik) then
    begin

      Gorev^.Sonlandir(Pencere^.GorevKimlik);
    end;
  end;
end;

end.
