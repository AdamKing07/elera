{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_karmaliste.pas
  Dosya ��levi: karma liste (a��l�r / kapan�r liste kutusu (TComboBox)) y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
unit gn_karmaliste;

interface

uses gorselnesne, paylasim, gn_pencere, n_yazilistesi, gn_panel, gn_acilirmenu;

type
  PKarmaListe = ^TKarmaListe;
  TKarmaListe = object(TPanel)
  private
    FAcilirMenu: PAcilirMenu;
    procedure OkResminiCiz(AGorselNesne: PGorselNesne; AAlan: TAlan);
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4): PKarmaListe;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure AcilirMenuOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure ListeyeEkle(ADeger: string);
    procedure ListeyiTemizle;
    procedure BaslikSiraNoYaz(ASiraNo: TISayi4);
  end;

function KarmaListeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_islevler, temelgorselnesne, hamresim, sistemmesaj;

{==============================================================================
  karma liste kesme �a�r�lar�n� y�netir
 ==============================================================================}
function KarmaListeCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  KarmaListe: PKarmaListe;
  Hiza: THiza;
  p: PKarakterKatari;
  i: ISayi4;
begin

  case AIslevNo of

    // nesne olu�tur
    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);
    end;

    ISLEV_GOSTER:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneAl(PKimlik(ADegiskenler + 00)^));
      KarmaListe^.Goster;
    end;

    // eleman ekle
    $0100:
    begin

      { TODO : nesneye her eleman eklendik�e nesnenin y�ksekli�i otomatik art�r�lacak }
      KarmaListe := PKarmaListe(KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntKarmaListe));
      if(KarmaListe <> nil) then
        KarmaListe^.ListeyeEkle(PKarakterKatari(PSayi4(ADegiskenler + 04)^ +
          CalisanGorevBellekAdresi)^);

      Result := 1;
    end;

    // liste i�eri�ini temizle
    $0300:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntKarmaListe));
      if(KarmaListe <> nil) then
      begin

        // e�er daha �nce bellek ayr�ld�ysa
        KarmaListe^.Baslik := '';

        KarmaListe^.FAcilirMenu^.FMenuBaslikListesi^.Temizle;
        KarmaListe^.Ciz;
      end;
    end;

    // karma listedeki se�ilen yaz� (text) de�erini geri d�nd�r
    $0400:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntKarmaListe));
      if(KarmaListe <> nil) then
      begin

        p := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
        p^ := KarmaListe^.Baslik;
      end;
    end;

    $0104:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      KarmaListe^.FHiza := Hiza;

      Pencere := PPencere(KarmaListe^.FAtaNesne);
      Pencere^.Guncelle;
    end;

    $0102:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if not(KarmaListe = nil) then Result := KarmaListe^.FAcilirMenu^.FMenuBaslikListesi^.ElemanSayisi;
    end;

    $0204:
    begin

      KarmaListe := PKarmaListe(KarmaListe^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if not(KarmaListe = nil) then
      begin

        i := PISayi4(ADegiskenler + 04)^;
        KarmaListe^.BaslikSiraNoYaz(i);
      end;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  karma liste nesnesini olu�turur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  KarmaListe: PKarmaListe;
begin

  KarmaListe := KarmaListe^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik);
  if(KarmaListe = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := KarmaListe^.Kimlik;
end;

{==============================================================================
  karma liste nesnesini olu�turur
 ==============================================================================}
function TKarmaListe.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PKarmaListe;
var
  KarmaListe: PKarmaListe;
begin

  KarmaListe := PKarmaListe(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst,
    AGenislik, 22 {AYukseklik}, 2, RENK_GRI, RENK_BEYAZ, 0, ''));

  KarmaListe^.NesneTipi := gntKarmaListe;

  KarmaListe^.Baslik := '';

  KarmaListe^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  KarmaListe^.OlayCagriAdresi := @OlaylariIsle;

  KarmaListe^.FAcilirMenu := KarmaListe^.FAcilirMenu^.Olustur(KarmaListe, 0, 0,
    AGenislik, (24 * 2) + 2, 24, RENK_GRI, RENK_BEYAZ, RENK_SARI, RENK_SIYAH, RENK_LACIVERT);
  KarmaListe^.FAcilirMenu^.FYardimciNesne := True;
  KarmaListe^.FAcilirMenu^.FAcilirMenuOlayGeriDonusAdresi := @AcilirMenuOlaylariniIsle;

  // nesne adresini geri d�nd�r
  Result := KarmaListe;
end;

{==============================================================================
  karma liste nesnesini yok eder
 ==============================================================================}
procedure TKarmaListe.YokEt;
var
  KarmaListe: PKarmaListe;
begin

  KarmaListe := PKarmaListe(KarmaListe^.NesneAl(Kimlik));
  if(KarmaListe = nil) then Exit;

  KarmaListe^.FAcilirMenu^.YokEt;

  inherited YokEt;
end;

{==============================================================================
  karma liste nesnesini g�r�nt�ler
 ==============================================================================}
procedure TKarmaListe.Goster;
begin

  inherited Goster;
end;

{==============================================================================
  karma liste nesnesini gizler
 ==============================================================================}
procedure TKarmaListe.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  karma liste nesnesini boyutland�r�r
 ==============================================================================}
procedure TKarmaListe.Boyutlandir;
begin

end;

{==============================================================================
  karma liste nesnesini �izer
 ==============================================================================}
procedure TKarmaListe.Ciz;
var
  KarmaListe: PKarmaListe;
  Alan: TAlan;
begin

  inherited Ciz;

  // nesnenin kimlik, tip de�erlerini denetle.
  KarmaListe := PKarmaListe(KarmaListe^.NesneAl(Kimlik));
  if(KarmaListe = nil) then Exit;

  // karma listenin �izim alan koordinatlar�n� al
  Alan := KarmaListe^.FCizimAlan;

  OkResminiCiz(KarmaListe, Alan);

  KarmaListe^.YaziYaz(KarmaListe, Alan.Sol + 4, Alan.Ust + 4, KarmaListe^.Baslik,
    RENK_SIYAH);
end;

{==============================================================================
  karma liste nesne olaylar�n� i�ler
 ==============================================================================}
procedure TKarmaListe.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
  KarmaListe: PKarmaListe;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  KarmaListe := PKarmaListe(AGonderici);
  if(KarmaListe = nil) then Exit;

  // sol fare tu� bas�m�
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // hi� bir �ey yapma
  end

  // sol fare tu� b�rak�m i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // bilgi: olay y�netimindeki tu� bas�m i�lemindeki bir tasar�mdan dolay�
    // bas�m olay sonras�nda men� hemen kapat�lmaktad�r. bu sebepten dolay�
    // men�n�n a��lmas� b�rak�lma i�lemine al�nm��t�r

    Pencere := EnUstPencereNesnesiniAl(KarmaListe);
    if not(Pencere = nil) then
    begin

      // men�y� farenin bulundu�u konumda g�r�nt�le
      KarmaListe^.FAcilirMenu^.FKonum.Sol := Pencere^.FKonum.Sol + KarmaListe^.FCizimBaslangic.Sol;
      KarmaListe^.FAcilirMenu^.FKonum.Ust := Pencere^.FKonum.Ust + KarmaListe^.FCizimBaslangic.Ust + 21;

      // a��l�r men�n�n g�r�n�rl���n� aktifle�tir
      KarmaListe^.FAcilirMenu^.Goster;

      // aktif men�y� belirle
      GAktifMenu := KarmaListe^.FAcilirMenu;
    end;
  end;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := KarmaListe^.FFareImlecTipi;
end;

{==============================================================================
  karma listeye ba�l� a��l�r men� nesne olaylar�n� i�ler
 ==============================================================================}
procedure TKarmaListe.AcilirMenuOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  KarmaListe: PKarmaListe;
  AcilirMenu: PAcilirMenu;
  SeciliEleman: String;
  Olay: TOlay;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  AcilirMenu := PAcilirMenu(AGonderici);
  if(AcilirMenu = nil) then Exit;

  // men�ye t�klanmas� durumunda ba�l�k de�erini de�i�tir
  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    KarmaListe := PKarmaListe(AcilirMenu^.AtaNesne);

    SeciliEleman := AcilirMenu^.FMenuBaslikListesi^.Eleman[AcilirMenu^.FSeciliSiraNo];
    KarmaListe^.Baslik := SeciliEleman;
    KarmaListe^.Ciz;

    // uygulamaya veya efendi nesneye mesaj g�nder
    Olay.Kimlik := KarmaListe^.Kimlik;
    Olay.Olay := CO_SECIMDEGISTI;
    Olay.Deger1 := AcilirMenu^.FSeciliSiraNo;
    Olay.Deger2 := 0;
    if not(KarmaListe^.OlayYonlendirmeAdresi = nil) then
      KarmaListe^.OlayYonlendirmeAdresi(KarmaListe, Olay)
    else GorevListesi[KarmaListe^.GorevKimlik]^.OlayEkle(KarmaListe^.GorevKimlik, Olay);
  end;
end;

procedure TKarmaListe.OkResminiCiz(AGorselNesne: PGorselNesne; AAlan: TAlan);
var
  Renk: PSayi4;
  Yatay, Dikey: TSayi4;
begin

  Renk := PSayi4(@ResimOKAlt);
  for Dikey := 1 to 4 do
  begin

    for Yatay := 1 to 7 do
    begin

      if(Renk^ = $00000000) then
        PixelYaz(AGorselNesne, (AAlan.Sag - 12) + Yatay, (AAlan.Ust + 9) + Dikey, RENK_SIYAH);

      Inc(Renk);
    end;
  end;
end;

procedure TKarmaListe.ListeyeEkle(ADeger: string);
var
  KarmaListe: PKarmaListe = nil;
  i: TISayi4;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  KarmaListe := PKarmaListe(KarmaListe^.NesneAl(Kimlik));
  if(KarmaListe = nil) then Exit;

  KarmaListe^.FAcilirMenu^.MenuEkle(ADeger, -1, True);

  i := KarmaListe^.FAcilirMenu^.FMenuBaslikListesi^.ElemanSayisi;
  if(i > 0) then
  begin

    KarmaListe^.FAcilirMenu^.FBoyut.Yukseklik := (i * 24);
  end;
end;

procedure TKarmaListe.ListeyiTemizle;
var
  KarmaListe: PKarmaListe = nil;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  KarmaListe := PKarmaListe(KarmaListe^.NesneAl(Kimlik));
  if(KarmaListe = nil) then Exit;

  KarmaListe^.Baslik := '';
  KarmaListe^.Ciz;

  KarmaListe^.FAcilirMenu^.Temizle;
  KarmaListe^.FAcilirMenu^.FBoyut.Yukseklik := 6;
end;

procedure TKarmaListe.BaslikSiraNoYaz(ASiraNo: TISayi4);
var
  KarmaListe: PKarmaListe = nil;
  Olay: TOlay;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  KarmaListe := PKarmaListe(KarmaListe^.NesneAl(Kimlik));
  if(KarmaListe = nil) then Exit;

  KarmaListe^.Baslik := KarmaListe^.FAcilirMenu^.FMenuBaslikListesi^.Eleman[ASiraNo];
  KarmaListe^.Ciz;

  // uygulamaya veya efendi nesneye mesaj g�nder
  Olay.Kimlik := KarmaListe^.Kimlik;
  Olay.Olay := CO_SECIMDEGISTI;
  Olay.Deger1 := ASiraNo;
  Olay.Deger2 := 0;
  if not(KarmaListe^.OlayYonlendirmeAdresi = nil) then
    KarmaListe^.OlayYonlendirmeAdresi(KarmaListe, Olay)
  else GorevListesi[KarmaListe^.GorevKimlik]^.OlayEkle(KarmaListe^.GorevKimlik, Olay);
end;

end.
