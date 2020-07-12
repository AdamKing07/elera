{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_pencere.pas
  Dosya ��levi: pencere (TForm) y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 11/07/2020

  �nemli Bilgiler:

    2. TPencere'nin alt nesnelerinden biri yeniden k�smi olarak (TEtiket nesnesi gibi)
      �izilmek istendi�inde mutlaka �st nesne olan TPencere.Guncelle i�levini �a��rmal�d�r.
      B�ylece pencere �izim tasar�m gere�i pencere �ncelikle kendini �izecek daha
      sonra ise alt nesnelerinin �izilmesi i�in alt nesnenin Ciz i�levini �a��racakt�r.
      Bu durum en son geli�tirilen, pencerelerin bellekten belle�e aktar�lmas� ve
      e�imli dolgu (gradient) �izim i�levleri i�in gereklidir

 ==============================================================================}
{$mode objfpc}
unit gn_pencere;

interface

uses gorselnesne, paylasim, gn_panel, gn_dugme, gn_resimdugmesi;

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
  gn_kaydirmacubugu, gn_karmaliste, gn_degerlistesi, gn_izgara, gn_araccubugu,
  gn_renksecici, temelgorselnesne, sistemmesaj;

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
    pencere kesme �a�r�lar�n� y�netir
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

      // nesnenin kimlik, tip de�erlerini denetle.
      Pencere := PPencere(Pencere^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Pencere <> nil) then Pencere^.Guncelle;
    end;

    $0180:
    begin

      // nesnenin kimlik, tip de�erlerini denetle.
      Pencere := PPencere(Pencere^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Pencere <> nil) then Pencere^.FPencereDurum := pdNormal;
    end;

    $0280:
    begin

      // nesnenin kimlik, tip de�erlerini denetle.
      Pencere := PPencere(Pencere^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Pencere <> nil) then Pencere^.FPencereDurum := pdKucultuldu;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  pencere nesnesini olu�turur
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
  pencere nesnesini olu�turur
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

  // ata nesne nil ise �st nesne ge�erli masa�st�d�r
  if(AAtaNesne = nil) then

    Masaustu := GAktifMasaustu
  else Masaustu := PMasaustu(Masaustu^.NesneTipiniKontrolEt(AAtaNesne^.Kimlik, gntMasaustu));

  // ge�erli masa�st� yok ise hata kodunu ver ve ��k
  if(Masaustu = nil) then Exit(nil);

  // pencere limit kontrolleri - ba�l�ks�z pencere hari�
  if not(APencereTipi = ptBasliksiz) then
  begin

    // pencere geni�li�inin en alt s�n�r de�erinin alt�nda olup olmad���n� kontrol et
    if(AGenislik < PENCERE_ALTLIMIT_GENISLIK) then
      Genislik := PENCERE_ALTLIMIT_GENISLIK
    else Genislik := AGenislik + (AktifGiysi.ResimSolGenislik + AktifGiysi.ResimSagGenislik);

    // pencere y�ksekli�inin en alt s�n�r de�erinin alt�nda olup olmad���n� kontrol et
    if(AYukseklik < PENCERE_ALTLIMIT_YUKSEKLIK) then
      Yukseklik := PENCERE_ALTLIMIT_YUKSEKLIK
    else Yukseklik := AYukseklik + (AktifGiysi.BaslikYukseklik + AktifGiysi.ResimAltYukseklik);
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

  // pencere nesnesi olu�tur
  Pencere := PPencere(inherited Olustur(ktTuvalNesne, Masaustu, Sol, Ust, Genislik,
    Yukseklik, 0, AGovdeRenk, AGovdeRenk, 0, ABaslik));

  Pencere^.NesneTipi := gntPencere;

  Pencere^.Baslik := ABaslik;

  Pencere^.FTuvalNesne := Pencere;

  Pencere^.AnaOlayCagriAdresi := @OlaylariIsle;

  Gorev := Gorev^.GorevBul(CalisanGorev);
  // g�revin ana penceresi sadece 1 kere atanacak
  if not(Gorev = nil) and (Gorev^.FAnaPencere = nil) then Gorev^.FAnaPencere := Pencere;

  Pencere^.FPencereTipi := APencereTipi;
  Pencere^.FPencereDurum := pdNormal;

  Pencere^.FKucultmeDugmesi := nil;
  Pencere^.FBuyutmeDugmesi := nil;
  Pencere^.FKapatmaDugmesi := nil;

  if(APencereTipi = ptBasliksiz) then
  begin

    // pencere kal�nl�klar�
    Pencere^.FKalinlik.Sol := 0;
    Pencere^.FKalinlik.Ust := 0;
    Pencere^.FKalinlik.Sag := 0;
    Pencere^.FKalinlik.Alt := 0;

    // pencere �izim alan�
    Pencere^.FCizimAlan.Sol := 0;
    Pencere^.FCizimAlan.Ust := 0;
    Pencere^.FCizimAlan.Sag := Pencere^.FBoyut.Genislik - 1;
    Pencere^.FCizimAlan.Alt := Pencere^.FBoyut.Yukseklik - 1;
  end
  else
  begin

    // pencere kal�nl�klar�
    Pencere^.FKalinlik.Sol := AktifGiysi.ResimSolGenislik;
    Pencere^.FKalinlik.Ust := AktifGiysi.BaslikYukseklik;
    Pencere^.FKalinlik.Sag := AktifGiysi.ResimSagGenislik;
    Pencere^.FKalinlik.Alt := AktifGiysi.ResimAltYukseklik;

    // pencere �izim alan�
    Pencere^.FCizimAlan.Sol := 0;
    Pencere^.FCizimAlan.Ust := 0;
    Pencere^.FCizimAlan.Sag := Pencere^.FBoyut.Genislik -
      (Pencere^.FKalinlik.Sol + Pencere^.FKalinlik.Sag) - 1;
    Pencere^.FCizimAlan.Alt := Pencere^.FBoyut.Yukseklik -
      (Pencere^.FKalinlik.Ust + Pencere^.FKalinlik.Alt) - 1;

    // pencere kontrol d��meleri
    if(Pencere^.FPencereTipi = ptBoyutlanabilir) then
    begin

      // k���ltme d��mesi
      i := AktifGiysi.KucultmeDugmesiSol;
      if(i < 0) then
        i := AGenislik - AktifGiysi.KucultmeDugmesiSol
      else i := ASol + i;
      Pencere^.FKucultmeDugmesi := FKucultmeDugmesi^.Olustur(ktBilesen, Pencere,
        i, AktifGiysi.KucultmeDugmesiUst, AktifGiysi.KucultmeDugmesiGenislik,
        AktifGiysi.KucultmeDugmesiYukseklik, $20000000 + 4, False);
      Pencere^.FKucultmeDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
      Pencere^.FKucultmeDugmesi^.Goster;

      // b�y�tme d��mesi
      i := AktifGiysi.BuyutmeDugmesiSol;
      if(i < 0) then
        i := AGenislik - AktifGiysi.BuyutmeDugmesiSol
      else i := ASol + i;
      Pencere^.FBuyutmeDugmesi := FBuyutmeDugmesi^.Olustur(ktBilesen, Pencere,
        i, AktifGiysi.BuyutmeDugmesiUst, AktifGiysi.BuyutmeDugmesiGenislik,
        AktifGiysi.BuyutmeDugmesiYukseklik, $20000000 + 2, False);
      Pencere^.FBuyutmeDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
      Pencere^.FBuyutmeDugmesi^.Goster;
    end;

    // kapatma d��mesi
    i := AktifGiysi.KapatmaDugmesiSol;
    if(i < 0) then
      i := AGenislik - AktifGiysi.KapatmaDugmesiSol
    else i := ASol + i;
    Pencere^.FKapatmaDugmesi := FKapatmaDugmesi^.Olustur(ktBilesen, Pencere,
      i, AktifGiysi.KapatmaDugmesiUst, AktifGiysi.KapatmaDugmesiGenislik,
      AktifGiysi.KapatmaDugmesiYukseklik, $20000000 + 0, False);
    Pencere^.FKapatmaDugmesi^.FRDOlayGeriDonusumAdresi := @KontrolDugmesiOlaylariniIsle;
    Pencere^.FKapatmaDugmesi^.Goster;
  end;

  // pencere'ye ait �zel �izim alan� mevcut oldu�undan dolay� �izim ba�lang��
  // sol ve �st de�erlerini s�f�r olarak ayarla
  Pencere^.FCizimBaslangic.Sol := 0;
  Pencere^.FCizimBaslangic.Ust := 0;

  // pencere �izimi i�in gereken bellek uzunlu�u
  Pencere^.FCizimBellekUzunlugu := (Pencere^.FBoyut.Genislik *
    Pencere^.FBoyut.Yukseklik * 4);

  // pencere �izimi i�in bellekte yer ay�r
  Pencere^.FCizimBellekAdresi := GGercekBellek.Ayir(Pencere^.FCizimBellekUzunlugu);
  if(Pencere^.FCizimBellekAdresi = nil) then
  begin

    // hata olmas� durumunda nesneyi yok et ve i�levden ��k
    Pencere^.YokEt;
    Result := nil;
    Exit;
  end;

  // nesne adresini geri d�nd�r
  Result := Pencere;
end;

{==============================================================================
  pencere nesnesini g�r�nt�ler
 ==============================================================================}
procedure TPencere.Goster;
var
  Pencere: PPencere;
begin

  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  inherited Goster;

  // pencere nesnesinin �st nesnesi olan masa�st� g�r�n�r ise masa�st� nesnesini
  // en �ste getir ve yeniden �iz
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
  pencere nesnesini boyutland�r�r
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

  // kontrol d��mesine sahip olan pencerelerin i� bile�enlerini konumland�r
  if not(Pencere^.FPencereTipi = ptBasliksiz) then

    IcBilesenleriKonumlandir(Pencere)
  else
  // aksi durumda SADECE hiza alan�n� belirle
  begin

    Pencere^.FCizimAlan.Sag := Pencere^.FBoyut.Genislik -
      (Pencere^.FKalinlik.Sol + Pencere^.FKalinlik.Sag) - 1;
    Pencere^.FCizimAlan.Alt := Pencere^.FBoyut.Yukseklik -
      (Pencere^.FKalinlik.Ust + Pencere^.FKalinlik.Alt) - 1;

    // alt nesnelerin s�n�rlanaca�� hiza alan�n� s�f�rla
    Pencere^.HizaAlaniniSifirla;
  end;

  // pencere alt nesnelerini yeniden boyutland�r
  if(Pencere^.FAltNesneSayisi > 0) then
  begin

    AltNesneler := Pencere^.FAltNesneBellekAdresi;

    // ilk olu�turulan alt nesneden son olu�turulan alt nesneye do�ru
    // pencerenin alt nesnelerini yeniden boyutland�r
    for i := 0 to Pencere^.FAltNesneSayisi - 1 do
    begin

      GorunurNesne := AltNesneler[i];
      if(GorunurNesne^.Gorunum) then
      begin

        // yeni eklenecek g�rsel nesne - g�rsel nesneyi buraya ekle...
        case GorunurNesne^.NesneTipi of
          //gntAcilirMenu     :
          gntAracCubugu     : PAracCubugu(GorunurNesne)^.Boyutlandir;
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
          //gntMasaustu;
          //gntMenu;
          gntOnayKutusu     : POnayKutusu(GorunurNesne)^.Boyutlandir;
          gntPanel          : PPanel(GorunurNesne)^.Boyutlandir;
          //gntPencere;
          gntRenkSecici     : PRenkSecici(GorunurNesne)^.Boyutlandir;
          gntResim          : PResim(GorunurNesne)^.Boyutlandir;
          gntResimDugmesi   : PResimDugmesi(GorunurNesne)^.Boyutlandir;
          gntSecimDugmesi   : PSecimDugmesi(GorunurNesne)^.Boyutlandir;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  pencere nesnesini �izer

  �nemli: pencere nesnesi �izilmeden �nce i�sel bile�enler (kapatma, b�y�tme d��mesi)
    ve di�er alt g�rsel bile�enler yeniden boyutland�r�lmal�d�r. Bu sebepten dolay�
    boyutland�rmalara ba�l� �izim istekleri i�in TPencere.Guncelle i�levi �a�r�lmal�d�r
 ==============================================================================}
procedure TPencere.Ciz;
var
  Pencere: PPencere;
  GRSolUst, GRUst, GRSagUst,
  GRSol, GRSag,
  GRSolAlt, GRAlt, GRSagAlt: TGiysiResim;
  Olay: TOlay;
  Alan: TAlan;
  Sol, Sag, Genislik, Ust, Alt, i, j: TISayi4;
  Renk, BaslikRengi: TRenk;
  PencereAktif: Boolean;
  AltNesneler: PPGorselNesne;
  GorunurNesne: PGorselNesne;
  RenkBellek: PRenk;
begin

  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  Pencere^.FCiziliyor := True;

  Pencere^.Boyutlandir;

  // pencerenin kendi de�erlerine ba�l� (0, 0) koordinatlar�n� al
  Alan := Pencere^.FCizimAlan;

  Alan.Sag += (Pencere^.FKalinlik.Sol + Pencere^.FKalinlik.Sag);
  Alan.Alt += (Pencere^.FKalinlik.Ust + Pencere^.FKalinlik.Alt);

  // pencere tipi ba�l�ks�z ise, artan renk ile (e�imli) doldur
  if(Pencere^.FPencereTipi = ptBasliksiz) then

    EgimliDoldur3(Pencere, Alan, $D0DBFB, $B9C9F9)
  else
  // ba�l�kl� pencere nesnesinin �izimi
  begin

    // aktif veya pasif �izimin belirlenmesi
    PencereAktif := (Pencere = AktifPencere);

    if(PencereAktif) then
    begin

      GRSolUst := AktifGiysi.ResimSolUstA;
      GRUst := AktifGiysi.ResimUstA;
      GRSagUst := AktifGiysi.ResimSagUstA;
      GRSol := AktifGiysi.ResimSolA;
      GRSag := AktifGiysi.ResimSagA;
      GRSolAlt := AktifGiysi.ResimSolAltA;
      GRAlt := AktifGiysi.ResimAltA;
      GRSagAlt := AktifGiysi.ResimSagAltA;
      BaslikRengi := AktifGiysi.AktifBaslikYaziRengi;

      // kontrol d��melerini aktifle�tir
      if not(Pencere^.FKucultmeDugmesi = nil) then
        Pencere^.FKucultmeDugmesi^.Deger := $20000000 + 4;
      if not(Pencere^.FBuyutmeDugmesi = nil) then
        Pencere^.FBuyutmeDugmesi^.Deger := $20000000 + 2;
      if not(Pencere^.FKapatmaDugmesi = nil) then
        Pencere^.FKapatmaDugmesi^.Deger := $20000000 + 0;
    end
    else
    begin

      GRSolUst := AktifGiysi.ResimSolUstP;
      GRUst := AktifGiysi.ResimUstP;
      GRSagUst := AktifGiysi.ResimSagUstP;
      GRSol := AktifGiysi.ResimSolP;
      GRSag := AktifGiysi.ResimSagP;
      GRSolAlt := AktifGiysi.ResimSolAltP;
      GRAlt := AktifGiysi.ResimAltP;
      GRSagAlt := AktifGiysi.ResimSagAltP;
      BaslikRengi := AktifGiysi.PasifBaslikYaziRengi;

      // kontrol d��melerini pasifle�tir
      if not(Pencere^.FKucultmeDugmesi = nil) then
        Pencere^.FKucultmeDugmesi^.Deger := $20000000 + 5;
      if not(Pencere^.FBuyutmeDugmesi = nil) then
        Pencere^.FBuyutmeDugmesi^.Deger := $20000000 + 3;
      if not(Pencere^.FKapatmaDugmesi = nil) then
        Pencere^.FKapatmaDugmesi^.Deger := $20000000 + 1;
    end;

    // pencerenin giydirilmesi

    // 1. sol �st k��enin giydirilmesi
    RenkBellek := GRSolUst.BellekAdresi;
    for Ust := 0 to GRSolUst.Yukseklik - 1 do
    begin

      for Sol := 0 to GRSolUst.Genislik - 1 do
      begin

        Renk := RenkBellek^;
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol, Ust, Renk);
        Inc(RenkBellek);
      end;
    end;

    // 2. �st yatay b�l�m�n giydirilmesi
    Sol := AktifGiysi.ResimSolUstGenislik;
    Sag := Alan.Sag - AktifGiysi.ResimSagUstGenislik + 1;
    while True do
    begin

      RenkBellek := GRUst.BellekAdresi;

      for i := 0 to GRUst.Yukseklik - 1 do
      begin

        for j := 0 to GRUst.Genislik - 1 do
        begin

          Renk := RenkBellek^;
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, i, Renk);
          Inc(RenkBellek);
        end;
      end;

      Sol += GRUst.Genislik;
      if(Sol >= Sag) then Break;

      if(Sol + GRUst.Genislik > Sag) then Sol := Sag - GRUst.Genislik;
    end;

    // 3. sa� �st k��enin giydirilmesi
    RenkBellek := GRSagUst.BellekAdresi;
    i := Alan.Sag - GRSagUst.Genislik + 1;
    for Ust := 0 to GRSagUst.Yukseklik - 1 do
    begin

      for Sol := 0 to GRSagUst.Genislik - 1 do
      begin

        Renk := RenkBellek^;
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, i + Sol, Ust, Renk);
        Inc(RenkBellek);
      end;
    end;

    // 4. sol k��enin giydirilmesi
    Ust := AktifGiysi.BaslikYukseklik;
    Alt := Alan.Alt - AktifGiysi.ResimSolAltYukseklik + 1;
    while True do
    begin

      RenkBellek := GRSol.BellekAdresi;

      for i := 0 to GRSol.Yukseklik - 1 do
      begin

        for j := 0 to GRSol.Genislik - 1 do
        begin

          Renk := RenkBellek^;
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, j, Ust + i, Renk);
          Inc(RenkBellek);
        end;
      end;

      Ust += GRSol.Yukseklik;
      if(Ust >= Alt) then Break;

      if(Ust + GRSol.Yukseklik > Alt) then Ust := (Alt - GRSol.Yukseklik)
    end;

    // 5. sa� k��enin giydirilmesi
    Ust := AktifGiysi.BaslikYukseklik;
    Alt := Alan.Alt - AktifGiysi.ResimSagAltYukseklik + 1;
    Sol := Alan.Sag - AktifGiysi.ResimSagGenislik + 1;
    while True do
    begin

      RenkBellek := GRSag.BellekAdresi;

      for i := 0 to GRSag.Yukseklik - 1 do
      begin

        for j := 0 to GRSag.Genislik - 1 do
        begin

          Renk := RenkBellek^;
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, Ust + i, Renk);
          Inc(RenkBellek);
        end;
      end;

      Ust += GRSag.Yukseklik;
      if(Ust >= Alt) then Break;

      if(Ust + GRSag.Yukseklik > Alt) then Ust := (Alt - GRSag.Yukseklik);
    end;

    // 6. sol alt k��enin giydirilmesi
    RenkBellek := GRSolAlt.BellekAdresi;
    Ust := Alan.Alt - GRSolAlt.Yukseklik + 1;
    for i := 0 to GRSolAlt.Yukseklik - 1 do
    begin

      for j := 0 to GRSolAlt.Genislik - 1 do
      begin

        Renk := RenkBellek^;
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, j, Ust + i, Renk);
        Inc(RenkBellek);
      end;
    end;

    // 7. alt k��enin giydirilmesi
    Sol := AktifGiysi.ResimSolAltGenislik;
    Ust := Alan.Alt - GRAlt.Yukseklik + 1;
    Sag := Alan.Sag - AktifGiysi.ResimSagAltGenislik + 1;
    while True do
    begin

      RenkBellek := GRAlt.BellekAdresi;

      for i := 0 to GRAlt.Yukseklik - 1 do
      begin

        for j := 0 to GRAlt.Genislik - 1 do
        begin

          Renk := RenkBellek^;
          if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, Ust + i, Renk);
          Inc(RenkBellek);
        end;
      end;

      Sol += GRAlt.Genislik;
      if(Sol >= Sag) then Break;

      if(Sol + GRAlt.Genislik > Sag) then Sol := Sag - GRAlt.Genislik;
    end;

    // 8. sa� alt k��enin giydirilmesi
    RenkBellek := GRSagAlt.BellekAdresi;
    Sol := Alan.Sag - GRSagAlt.Genislik + 1;
    Ust := Alan.Alt - GRSagAlt.Yukseklik + 1;
    for i := 0 to GRSagAlt.Yukseklik - 1 do
    begin

      for j := 0 to GRSagAlt.Genislik - 1 do
      begin

        Renk := RenkBellek^;
        if not(Renk = $FFFFFFFF) then PixelYaz(Pencere, Sol + j, Ust + i, Renk);
        Inc(RenkBellek);
      end;
    end;

    // pencere i� b�l�m boyama
    Renk := AktifGiysi.IcDolguRengi;
    if(Renk = $FFFFFFFF) then Renk := Pencere^.FGovdeRenk1;

    DikdortgenDoldur(Pencere, AktifGiysi.ResimSolGenislik, AktifGiysi.BaslikYukseklik,
      Alan.Sag - AktifGiysi.ResimSagGenislik, Alan.Alt - AktifGiysi.ResimAltYukseklik, Renk, Renk);

    // pencere ba�l���n� yaz
    i := AktifGiysi.BaslikYaziSol;
    if(i = -1) then
      i := (Pencere^.FBoyut.Genislik div 2) - ((Length(Pencere^.Baslik) * 8) div 2);

    j := AktifGiysi.BaslikYaziUst;
    if(j = -1) then
      j := (AktifGiysi.BaslikYukseklik div 2) - (16 div 2);

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

    // ilk olu�turulan alt nesneden son olu�turulan alt nesneye do�ru
    // pencerenin alt nesnelerini �iz
    for i := 0 to Pencere^.FAltNesneSayisi - 1 do
    begin

      GorunurNesne := AltNesneler[i];
      if(GorunurNesne^.Gorunum) and not(GorunurNesne^.Kimlik = HATA_KIMLIK) then
      begin

        // yeni eklenecek g�rsel nesne - g�rsel nesneyi buraya ekle...
        case GorunurNesne^.NesneTipi of
          //gntAcilirMenu     :
          gntAracCubugu     : PAracCubugu(GorunurNesne)^.Ciz;
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
          //gntMasaustu;
          //gntMenu;
          gntOnayKutusu     : POnayKutusu(GorunurNesne)^.Ciz;
          gntPanel          : PPanel(GorunurNesne)^.Ciz;
          //gntPencere;
          gntRenkSecici     : PRenkSecici(GorunurNesne)^.Ciz;
          gntResim          : PResim(GorunurNesne)^.Ciz;
          gntResimDugmesi   : PResimDugmesi(GorunurNesne)^.Ciz;
          gntSecimDugmesi   : PSecimDugmesi(GorunurNesne)^.Ciz;
        end;
      end;
    end;
  end;

  // uygulamaya veya efendi nesneye mesaj g�nder
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
  pencere nesne olaylar�n� i�ler
 ==============================================================================}
procedure TPencere.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
begin

  Pencere := PPencere(AGonderici);
  if(Pencere = nil) then Exit;

  // olaylar� ilgili i�levlere y�nlendir
  case Pencere^.FPencereTipi of
    ptBasliksiz       : BasliksizPencereOlaylariniIsle(Pencere, AOlay);
    ptIletisim        : IletisimPencereOlaylariniIsle(Pencere, AOlay);
    ptBoyutlanabilir  : BoyutlanabilirPencereOlaylariniIsle(Pencere, AOlay);
  end;
end;

{==============================================================================
  ba�l�ks�z pencere nesne olaylar�n� i�ler
 ==============================================================================}
procedure TPencere.BasliksizPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
begin

  // sol tu�a bas�m i�lemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif de�ilse aktifle�tir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // sol tu� bas�m i�lemi olay alan�nda ger�ekle�tiyse
    if(APencere^.FareNesneOlayAlanindaMi(APencere)) then
    begin

      // fare mesajlar�n� APencere nesnesine y�nlendir
      OlayYakalamayaBasla(APencere);

      // uygulamaya veya efendi nesneye mesaj g�nder
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;
  end

  // sol tu� b�rak�m i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare mesajlar�n� yakalamay� b�rak
    OlayYakalamayiBirak(APencere);

    // sol tu� b�rak�m i�lemi olay alan�nda ger�ekle�tiyse
    if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
    begin

      // uygulamaya veya efendi nesneye mesaj g�nder
      AOlay.Olay := FO_TIKLAMA;
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj g�nder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end
  // di�er olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
end;

{==============================================================================
  ileti�im pencere nesne olaylar�n� i�ler
 ==============================================================================}
procedure TPencere.IletisimPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
var
  Alan: TAlan;
begin

  // sol tu�a bas�m i�lemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif de�ilse aktifle�tir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // sol tu� bas�m i�lemi olay alan�nda ger�ekle�tiyse
    if(APencere^.FareNesneOlayAlanindaMi(APencere)) then
    begin

      // fare mesajlar�n� APencere nesnesine y�nlendir
      OlayYakalamayaBasla(APencere);

      // e�er t�klama pencerenin g�vdesinde ger�ekle�mi�se
      if(FareKonumu = fkGovde) then
      begin

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj g�nder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else

      // aksi durumda t�klama i�lemi yakalama �ubu�unda ger�ekle�mi�tir
      // o zaman pencerenin kenarl�klar�n� sakla
      begin

        GecerliFareGostegeTipi := fitBoyutTum;
        SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
        SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;
      end;
    end else GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
  end

  // sol tu� b�rak�m i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylar�n� almay� b�rak
    OlayYakalamayiBirak(APencere);

    // ta��ma i�lemi pencere �izim alan�nda ger�ekle�mi�se
    if not(FareKonumu = fkKontrolCubugu) then
    begin

      // b�rakma i�lemi APencere i�erinde ger�ekle�tiyse
      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj g�nder
        AOlay.Olay := FO_TIKLAMA;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);

        // uygulamaya veya efendi nesneye mesaj g�nder
        AOlay.Olay := FO_SOLTUS_BIRAKILDI;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else

      // b�rakma i�lemi APencere d���nda ger�ekle�tiyse
      begin

        { TODO : b�rakma i�lemi APencere d���nda olursa normalde kursor de ilgili
          nesnenin kurs�r� olur }
        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj g�nder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;
    end;
  end

  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // fare yakalanmam��sa sadece fare g�stergesini g�ncelle
    if(YakalananGorselNesne = nil) then
    begin

      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin

        FareKonumu := fkGovde;
        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

        // uygulamaya veya efendi nesneye mesaj g�nder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end
      else
      begin

        FareKonumu := fkKontrolCubugu;
        GecerliFareGostegeTipi := fitBoyutTum;

        // uygulamaya veya efendi nesneye mesaj g�nder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;
    end
    else

    // fare yakalanm�� oldu�u i�in ta��ma i�lemlerini ger�ekle�tir
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

        // uygulamaya veya efendi nesneye mesaj g�nder
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);

        GecerliFareGostegeTipi := APencere^.FFareImlecTipi;
      end;
    end;
  end
  // di�er olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;
end;

{==============================================================================
  boyutland�r�labilir pencere nesne olaylar�n� i�ler
 ==============================================================================}
procedure TPencere.BoyutlanabilirPencereOlaylariniIsle(APencere: PPencere; AOlay: TOlay);
var
  Alan: TAlan;
begin

  // sol tu�a bas�m i�lemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // APencere nesnesi aktif de�ilse aktifle�tir
    if(APencere <> AktifPencere) then EnUsteGetir(APencere);

    // fare olaylar�n� APencere nesnesine y�nlendir
    OlayYakalamayaBasla(APencere);

    // e�er farenin sol tu�u APencere nesnesinin g�vdesine t�klanm��sa ...
    if(FareKonumu = fkGovde) then
    begin

      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end
    else
    begin

      // aksi durumda ta��ma / boyutland�rma i�lemi ger�ekle�tirilecektir.
      // de�i�ken i�eriklerini g�ncelle
      SonFareYatayKoordinat := GFareSurucusu.YatayKonum;
      SonFareDikeyKoordinat := GFareSurucusu.DikeyKonum;
    end;
  end

  // sol tu� b�rakma i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare mesajlar�n� yakalamay� b�rak
    OlayYakalamayiBirak(APencere);

    // fare b�rakma i�lemi nesnenin i�erisinde mi ger�ekle�ti ?
    if(FareKonumu = fkGovde) then
    begin

      if(APencere^.FarePencereCizimAlanindaMi(APencere)) then
      begin
        // yakalama & b�rakma i�lemi bu nesnede oldu�u i�in
        // nesneye FO_TIKLAMA mesaj� g�nder
        AOlay.Olay := FO_TIKLAMA;
        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
      end;

      // nesneye sadece FO_SOLTUS_BIRAKILDI mesaj� g�nder
      AOlay.Olay := FO_SOLTUS_BIRAKILDI;
      if not(APencere^.OlayCagriAdresi = nil) then
        APencere^.OlayCagriAdresi(APencere, AOlay)
      else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
    end;
  end

  // fare hareket i�lemleri
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // FO_HAREKET - nesne yakalanmam��
    if(YakalananGorselNesne = nil) then
    begin

      // fare > sol �izgi kal�nl�k
      if(AOlay.Deger1 > APencere^.FKalinlik.Sol) then
      begin

        // fare < sa� �izgi kal�nl�k
        if(AOlay.Deger1 < (APencere^.FBoyut.Genislik - APencere^.FKalinlik.Sag)) then
        begin

          // fare < alt �izgi kal�nl�k
          if(AOlay.Deger2 < (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
          begin

            // fare > alt �izgi kal�nl�k
            // bilgi: �st �izgi kal�nl�k de�eri ba�l�k �ubu�u de�eri oldu�undan dolay�
            // �st �izgi kal�nl�k de�eri olarak alt �izgi kal�nl�k de�eri kullan�lmaktad�r
            if(AOlay.Deger2 > APencere^.FKalinlik.Alt) then
            begin

              // fare > yakalama �ubu�u
              // bu de�er yakalama �ubu�u i�in kullan�l�yor. hata yok
              if(AOlay.Deger2 > APencere^.FKalinlik.Ust) then
              begin

                // fare g�stergesi APencere g�vdesinde
                FareKonumu := fkGovde;
                GecerliFareGostegeTipi := APencere^.FFareImlecTipi;

                if not(APencere^.OlayCagriAdresi = nil) then
                  APencere^.OlayCagriAdresi(APencere, AOlay)
                else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
              end
              else
              begin

                // fare g�stergesi yakalama �ubu�unda
                FareKonumu := fkKontrolCubugu;
                GecerliFareGostegeTipi := fitBoyutTum;
              end;
            end
            else
            begin

              // fare g�stergesi �st boyutland�rmada
              FareKonumu := fkUst;
              GecerliFareGostegeTipi := fitBoyutKG;
            end;
          end
          else
          begin

            // fare g�stergesi alt boyutland�rmada
            FareKonumu := fkAlt;
            GecerliFareGostegeTipi := fitBoyutKG;
          end;
        end
        else
        // sa� - alt / �st / orta (sa�) kontrol�
        begin

          // bilgi: APencere^.FKalinlik.Alt de�eri asl�nda APencere^.FKalinlik.Ust de�eri olmal�d�r
          // fakat APencere^.FKalinlik.Ust de�eri ba�l�k kal�nl��� olarak kullan�lmaktad�r
          if(AOlay.Deger2 < APencere^.FKalinlik.Alt) then
          begin

            // fare g�stergesi sa� & �st boyutland�rmada
            FareKonumu := fkSagUst;
            GecerliFareGostegeTipi := fitBoyutKDGB;
          end
          else if(AOlay.Deger2 > (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
          begin

            // fare g�stergesi sa� & alt boyutland�rmada
            FareKonumu := fkSagAlt;
            GecerliFareGostegeTipi := fitBoyutKBGD;
          end
          else
          begin

            // fare g�stergesi sa� k�s�m boyutland�rmada
            FareKonumu := fkSag;
            GecerliFareGostegeTipi := fitBoyutBD;
          end;
        end;
      end
      else
      // sol - alt / �st / orta (sol) kontrol�
      begin

        if(AOlay.Deger2 < APencere^.FKalinlik.Alt) then
        begin

          // fare g�stergesi �st & sol k�s�m boyutland�rmada
          FareKonumu := fkSolUst;
          GecerliFareGostegeTipi := fitBoyutKBGD;
        end
        else if(AOlay.Deger2 > (APencere^.FBoyut.Yukseklik - APencere^.FKalinlik.Alt)) then
        begin

          // fare g�stergesi alt & sol k�s�m boyutland�rmada
          FareKonumu := fkSolAlt;
          GecerliFareGostegeTipi := fitBoyutKDGB;
        end
        else
        begin

          // fare g�stergesi sol k�s�m boyutland�rmada
          FareKonumu := fkSol;
          GecerliFareGostegeTipi := fitBoyutBD;
        end;
      end;
    end
    else

    // FO_HAREKET - nesne yakalanm�� - ta��ma, boyutland�rma
    begin

      if(FareKonumu = fkGovde) then
      begin

        if not(APencere^.OlayCagriAdresi = nil) then
          APencere^.OlayCagriAdresi(APencere, AOlay)
        else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
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

        // �izim i�in ayr�lan belle�i yok et ve yeni bellek ay�r
        { TODO : ileride �izimlerin daha h�zl� olmas� i�in APencere k���lmesi i�in bellek ayr�lmayabilir }
        GGercekBellek.YokEt(APencere^.FCizimBellekAdresi, APencere^.FCizimBellekUzunlugu);

        APencere^.FCizimBellekUzunlugu := (APencere^.FBoyut.Genislik * APencere^.FBoyut.Yukseklik * 4);
        APencere^.FCizimBellekAdresi := GGercekBellek.Ayir(APencere^.FCizimBellekUzunlugu);

        APencere^.Ciz;
      end;
    end;
  end
  // di�er olaylar
  else
  begin

    // uygulamaya veya efendi nesneye mesaj g�nder
    if not(APencere^.OlayCagriAdresi = nil) then
      APencere^.OlayCagriAdresi(APencere, AOlay)
    else GorevListesi[APencere^.GorevKimlik]^.OlayEkle(APencere^.GorevKimlik, AOlay);
  end;
end;

{==============================================================================
  pencere nesnesi ve alt nesnelerini g�nceller
  �nemli: t�m alt nesneler �izim istekleri i�in bu i�levi (TPencere.Guncelle) �a��rmal�d�r
 ==============================================================================}
procedure TPencere.Guncelle;
var
  Pencere: PPencere;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  Pencere := PPencere(Pencere^.NesneAl(Kimlik));
  if(Pencere = nil) then Exit;

  Pencere^.Boyutlandir;

  Pencere^.Ciz;
end;

{==============================================================================
  belirtilen pencere nesnesini en �ste getirir ve yeniden �izer
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
  S�ralama            0   1   2
                    +---+---+---+
  Nesne Kimlikleri  | 1 | 2 | 3 |
                    +-+-+---+-+-+
                      |       +----- en �st nesne
                      +------------- en alt nesne
-------------------------------------------------------------------------------}

  // aktif masa�st�n� al
  Masaustu := GAktifMasaustu;

  // masa�st�n�n alt nesne bellek de�erini al
  AltNesneBellekAdresi := Masaustu^.FAltNesneBellekAdresi;

  // nesnenin alt nesne say�s� var ise
  if(Masaustu^.FAltNesneSayisi > 1) then
  begin

    BirOncekiPencere := PPencere(AltNesneBellekAdresi[Masaustu^.FAltNesneSayisi - 1]);

    // alt nesneler i�erisinde pencere nesnesini ara
    for i := (Masaustu^.FAltNesneSayisi - 1) downto 0 do
    begin

      if(PPencere(AltNesneBellekAdresi[i]) = APencere) then Break;
    end;

    // e�er pencere nesnesi en �stte de�il ise
    if(i <> Masaustu^.FAltNesneSayisi - 1) then
    begin

      // pencere nesnesini masa�st� nesne belle�inde en �ste getir
      for j := i to Masaustu^.FAltNesneSayisi - 2 do
      begin

        GorselNesne := AltNesneBellekAdresi[j + 0];
        AltNesneBellekAdresi[j + 0] := AltNesneBellekAdresi[j + 1];
        AltNesneBellekAdresi[j + 1] := GorselNesne;
      end;
    end;

    // pencere en �stte olsa da olmasa da aktif pencere olarak tan�mla
    // not: pencere en �stte olup g�r�nt�lenmi� olmayabilir
    AktifPencere := APencere;

    // bir �nceki pencereyi yeniden �iz
    if(BirOncekiPencere^.Gorunum) then BirOncekiPencere^.Guncelle;

    // aktif pencereyi yeniden �iz
    AktifPencere^.Guncelle;
  end;
end;

{==============================================================================
  fare g�stergesinin pencere nesnesinin g�vde (�izim alan�) i�erisinde
  olup olmad���n� kontrol eder
 ==============================================================================}
function TPencere.FarePencereCizimAlanindaMi(APencere: PPencere): Boolean;
var
  Alan: TAlan;
begin

  Alan.Sol := APencere^.FKonum.Sol + APencere^.FKalinlik.Sol;
  Alan.Ust := APencere^.FKonum.Ust + APencere^.FKalinlik.Ust;
  Alan.Sag := Alan.Sol + (APencere^.FBoyut.Genislik + APencere^.FKalinlik.Sag);
  Alan.Alt := Alan.Ust + (APencere^.FBoyut.Yukseklik + APencere^.FKalinlik.Alt);

  // �nde�er d�n�� de�eri
  Result := False;

  // fare belirtilen koordinatlar i�erisinde mi ?
  if(GFareSurucusu.YatayKonum < Alan.Sol) then Exit;
  if(GFareSurucusu.YatayKonum > Alan.Sag) then Exit;
  if(GFareSurucusu.DikeyKonum < Alan.Ust) then Exit;
  if(GFareSurucusu.DikeyKonum > Alan.Alt) then Exit;

  Result := True;
end;

{==============================================================================
  pencere nesnesini yeniden boyutland�r�r i� bile�enlerini konumland�r�r
 ==============================================================================}
procedure TPencere.IcBilesenleriKonumlandir(var APencere: PPencere);
var
  i: TISayi4;
begin

  APencere^.FCizimAlan.Sag := APencere^.FBoyut.Genislik -
    (APencere^.FKalinlik.Sol + APencere^.FKalinlik.Sag) - 1;
  APencere^.FCizimAlan.Alt := APencere^.FBoyut.Yukseklik -
    (APencere^.FKalinlik.Ust + APencere^.FKalinlik.Alt) - 1;

  // alt nesnelerin s�n�rlanaca�� hiza alan�n� s�f�rla
  APencere^.HizaAlaniniSifirla;

  if(APencere^.FPencereTipi = ptBoyutlanabilir) then
  begin

    i := AktifGiysi.KucultmeDugmesiSol;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik + AktifGiysi.KucultmeDugmesiSol;
    APencere^.FKucultmeDugmesi^.FKonum.Sol := i;
    APencere^.FKucultmeDugmesi^.FKonum.Ust := AktifGiysi.KucultmeDugmesiUst;

    i := AktifGiysi.BuyutmeDugmesiSol;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik + AktifGiysi.BuyutmeDugmesiSol;
    APencere^.FBuyutmeDugmesi^.FKonum.Sol := i;
    APencere^.FKucultmeDugmesi^.FKonum.Ust := AktifGiysi.BuyutmeDugmesiUst;

    i := AktifGiysi.KapatmaDugmesiSol;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik + AktifGiysi.KapatmaDugmesiSol;
    APencere^.FKapatmaDugmesi^.FKonum.Sol := i;
    APencere^.FKapatmaDugmesi^.FKonum.Ust := AktifGiysi.KapatmaDugmesiUst;

    APencere^.FKucultmeDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FKucultmeDugmesi^.FKonum.Sol;
    APencere^.FKucultmeDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FKucultmeDugmesi^.FKonum.Ust;
    APencere^.FBuyutmeDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FBuyutmeDugmesi^.FKonum.Sol;
    APencere^.FBuyutmeDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FBuyutmeDugmesi^.FKonum.Ust;
    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Sol := APencere^.FCizimBaslangic.Sol + APencere^.FKapatmaDugmesi^.FKonum.Sol;
    APencere^.FKapatmaDugmesi^.FCizimBaslangic.Ust := APencere^.FCizimBaslangic.Ust + APencere^.FKapatmaDugmesi^.FKonum.Ust;
  end
  else if(APencere^.FPencereTipi = ptIletisim) then
  begin

    i := AktifGiysi.KapatmaDugmesiSol;
    if(i < 0) then
      i := APencere^.FBoyut.Genislik + AktifGiysi.KapatmaDugmesiSol;
    APencere^.FKapatmaDugmesi^.FKonum.Sol := i;
    APencere^.FKapatmaDugmesi^.FKonum.Ust := AktifGiysi.KapatmaDugmesiUst;

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
      SISTEM_MESAJ('Bilgi: b�y�tme d��mesi i�levi yap�land�r�lacak', [])
    else if(ResimDugmesi^.Kimlik = Pencere^.FKapatmaDugmesi^.Kimlik) then
    begin

      Gorev^.Sonlandir(Pencere^.GorevKimlik);
    end;
  end;
end;

end.
