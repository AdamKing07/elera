{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_karmaliste.pas
  Dosya ��levi: a��l�r / kapan�r liste kutusu y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 09/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_karmaliste;

interface

uses gorselnesne, paylasim, gn_pencere, n_yazilistesi;

type
  PKarmaListe = ^TKarmaListe;
  TKarmaListe = object(TGorselNesne)
  private
    FListeKutusuAcik: Boolean;
    FGorunenIlkSiraNo: TISayi4;           // g�r�nen ilk eleman�n s�ra numaras�
    FGorunenElemanSayisi: TISayi4;        // nesne i�indeki g�r�nen eleman say�s�
    FYaziListesi: PYaziListesi;
    procedure OkResminiCiz(APencere: PPencere; AAlan: TAlan);
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PKarmaListe;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function KarmaListeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
procedure ListeyeEkle(AKarmaListe: PKarmaListe; ADeger: string);

implementation

uses genel, gn_islevler, temelgorselnesne, hamresim2, sistemmesaj;

{==============================================================================
  karma liste kesme �a�r�lar�n� y�netir
 ==============================================================================}
function KarmaListeCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _KarmaListe: PKarmaListe;
  _Hiza: THiza;
  p1: PShortString;
begin

  case IslevNo of

    // nesne olu�tur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // eleman ekle
    $0100:
    begin

      _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntKarmaListe));
      if(_KarmaListe <> nil) then
        ListeyeEkle(_KarmaListe, PShortString(PSayi4(Degiskenler + 04)^ +
          AktifGorevBellekAdresi)^);

      Result := 1;
    end;

    // liste i�eri�ini temizle
    $0300:
    begin

      _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntKarmaListe));
      if(_KarmaListe <> nil) then
      begin

        // e�er daha �nce bellek ayr�ld�ysa
        _KarmaListe^.FGorunenElemanSayisi := 0;
        _KarmaListe^.FGorunenIlkSiraNo := 0;
        _KarmaListe^.FBaslik := '';
        _KarmaListe^.FBoyutlar.Yukseklik2 := 22;

        _KarmaListe^.FYaziListesi^.Temizle;
        _KarmaListe^.Ciz;
      end;
    end;

    // karma listedeki se�ilen yaz� (text) de�erini geri d�nd�r
    $0400:
    begin

      _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntKarmaListe));
      if(_KarmaListe <> nil) then
      begin

        p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
        p1^ := _KarmaListe^.FBaslik;
      end;
    end;

    $0104:
    begin

      _KarmaListe := PKarmaListe(_KarmaListe^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _KarmaListe^.Hiza := _Hiza;

      _Pencere := PPencere(_KarmaListe^.FAtaNesne);
      _Pencere^.Guncelle;
    end;

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  karma liste nesnesini olu�turur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  _KarmaListe: PKarmaListe;
begin

  _KarmaListe := _KarmaListe^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik);
  if(_KarmaListe = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _KarmaListe^.Kimlik;
end;

{==============================================================================
  karma liste nesnesini olu�turur
 ==============================================================================}
function TKarmaListe.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PKarmaListe;
var
  _AtaNesne: PGorselNesne;
  _KarmaListe: PKarmaListe;
  YL: PYaziListesi;
begin

  // nesnenin ba�lanaca�� ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // karma liste nesnesi i�in yer ay�r
  _KarmaListe := PKarmaListe(Olustur0(gntKarmaListe));
  if(_KarmaListe = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // karma liste nesnesini ata nesnesine ekle
  if(_KarmaListe^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olmas� durumunda nesneyi yok et ve hata koduyla i�levden ��k
    _KarmaListe^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne de�erlerini ata
  _KarmaListe^.GorevKimlik := CalisanGorev;
  _KarmaListe^.AtaNesne := _AtaNesne;
  _KarmaListe^.Hiza := hzYok;
  _KarmaListe^.FBoyutlar.Sol2 := A1;
  _KarmaListe^.FBoyutlar.Ust2 := B1;
  _KarmaListe^.FBoyutlar.Genislik2 := AGenislik;
  _KarmaListe^.FBoyutlar.Yukseklik2 := 22; //AYukseklik;

  // kenar kal�nl�klar�
  _KarmaListe^.FKalinlik.Sol := 0;
  _KarmaListe^.FKalinlik.Ust := 0;
  _KarmaListe^.FKalinlik.Sag := 0;
  _KarmaListe^.FKalinlik.Alt := 0;

  // kenar bo�luklar�
  _KarmaListe^.FKenarBosluklari.Sol := 0;
  _KarmaListe^.FKenarBosluklari.Ust := 0;
  _KarmaListe^.FKenarBosluklari.Sag := 0;
  _KarmaListe^.FKenarBosluklari.Alt := 0;

  _KarmaListe^.FAtaNesneMi := False;
  _KarmaListe^.FareGostergeTipi := fitOK;
  _KarmaListe^.FGorunum := False;

  _KarmaListe^.FYaziListesi := nil;
  YL := YL^.Olustur;
  if(YL <> nil) then _KarmaListe^.FYaziListesi := YL;

  // nesnenin kullanaca�� di�er de�erler
  _KarmaListe^.FListeKutusuAcik := False;
  _KarmaListe^.FGorunenIlkSiraNo := 0;

  // karma listesinde g�r�nt�lenecek eleman say�s�
  _KarmaListe^.FGorunenElemanSayisi := 0;

  // nesnenin ad ve ba�l�k de�eri
  _KarmaListe^.NesneAdi := NesneAdiAl(gntKarmaListe);
  _KarmaListe^.FBaslik := '';

  // uygulamaya mesaj g�nder
  GorevListesi[_KarmaListe^.GorevKimlik]^.OlayEkle1(_KarmaListe^.GorevKimlik,
    _KarmaListe, CO_OLUSTUR, 0, 0);

  // karma listeni g�r�nt�le
  _KarmaListe^.Goster;

  // nesne adresini geri d�nd�r
  Result := _KarmaListe;
end;

{==============================================================================
  nesne ve nesneye ayr�lan kaynaklar� yok eder
 ==============================================================================}
procedure TKarmaListe.YokEt(AKimlik: TKimlik);
var
  _KarmaListe: PKarmaListe;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(AKimlik, gntKarmaListe));
  if(_KarmaListe = nil) then Exit;

  if(_KarmaListe^.FYaziListesi <> nil) then _KarmaListe^.FYaziListesi^.YokEt;

  YokEt0;
end;

{==============================================================================
  karma liste nesnesini g�r�nt�ler
 ==============================================================================}
procedure TKarmaListe.Goster;
var
  _Pencere: PPencere;
  _KarmaListe: PKarmaListe;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(Kimlik, gntKarmaListe));
  if(_KarmaListe = nil) then Exit;

  // e�er nesne g�r�n�r de�ilse
  if(_KarmaListe^.FGorunum = False) then
  begin

    // nesnenin g�r�n�rl���n� aktifle�tir
    _KarmaListe^.FGorunum := True;

    // nesne ve �st nesneler g�r�n�r ise
    if(_KarmaListe^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_KarmaListe);

      // pencereyi g�ncelle�tir
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  karma liste nesnesini �izer
 ==============================================================================}
procedure TKarmaListe.Ciz;
var
  _Pencere: PPencere;
  _KarmaListe: PKarmaListe;
  YL: PYaziListesi;
  _Alan: TAlan;
  _SiraNo, X, Y,
  _GorunenElemanSayisi: TISayi4;
  s: string;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(Kimlik, gntKarmaListe));
  if(_KarmaListe = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_KarmaListe);
  if(_Pencere = nil) then Exit;

  // karma listenin �st nesneye ba�l� olarak koordinatlar�n� al
  _Alan := _KarmaListe^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // karma liste kutusunun a��k olmas� durumunda
  if(_KarmaListe^.FListeKutusuAcik) then
  begin

    YL := _KarmaListe^.FYaziListesi;

    DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sag - 15, _Alan.Alt,
      $7F7F7F, RENK_BEYAZ);

    DikdortgenDoldur(_Pencere, _Alan.Sag - 15, _Alan.Ust, _Alan.Alt, _Alan.Ust + 22,
      $7F7F7F, $C3C3C3);
    OkResminiCiz(_Pencere, _Alan);

    YaziYaz(_Pencere, _Alan.Sol + 4, _Alan.Ust + 4, _KarmaListe^.FBaslik, RENK_LACIVERT);

    // nesnenin eleman� var m� ?
    if(YL^.ElemanSayisi > 0) then
    begin

      // �izim / yaz�m i�in kullan�lacak x & y koordinatlar�
      X := _Alan.Sol + 4;
      Y := _Alan.Ust + 22 + 5;

      // karma listende g�r�nt�lenecek eleman say�s�
      if(YL^.ElemanSayisi > _KarmaListe^.FGorunenElemanSayisi) then
        _GorunenElemanSayisi := _KarmaListe^.FGorunenElemanSayisi + _KarmaListe^.FGorunenIlkSiraNo
      else _GorunenElemanSayisi := YL^.ElemanSayisi + _KarmaListe^.FGorunenIlkSiraNo;

      // listenin ilk eleman�n s�ra numaras�
      for _SiraNo := _KarmaListe^.FGorunenIlkSiraNo to _GorunenElemanSayisi - 1 do
      begin

        // belirtilen eleman�n karakter katar de�erini al
        s := YL^.Eleman[_SiraNo];
        YaziYaz(_Pencere, X, Y, s, RENK_SIYAH);
        y += 22;
      end;
    end;
  end
  else
  // karma liste kutusunun kapal� olmas� durumunda
  begin

    DikdortgenDoldur(_Pencere, _Alan.Sol, _Alan.Ust, _Alan.Sag - 15, _Alan.Ust + 22,
      $7F7F7F, RENK_BEYAZ);

    DikdortgenDoldur(_Pencere, _Alan.Sag - 15, _Alan.Ust, _Alan.Sag, _Alan.Ust + 22,
      $7F7F7F, $C3C3C3);
    OkResminiCiz(_Pencere, _Alan);

    YaziYaz(_Pencere, _Alan.Sol + 4, _Alan.Ust + 4, _KarmaListe^.FBaslik, RENK_LACIVERT);
  end;
end;

{==============================================================================
  karma liste nesne olaylar�n� i�ler
 ==============================================================================}
procedure TKarmaListe.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _KarmaListe: PKarmaListe;
  _Alan: TAlan;
  i, _SeciliSiraNo: TISayi4;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _KarmaListe := PKarmaListe(_KarmaListe^.NesneTipiniKontrolEt(AKimlik, gntKarmaListe));
  if(_KarmaListe = nil) then Exit;

  // sol fare tu� bas�m�
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // karma listenin sahibi olan pencere en �stte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_KarmaListe);

    // en �stte olmamas� durumunda en �ste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tu�a bas�m i�lemi nesnenin olay alan�nda m� ger�ekle�ti ?
    if(_KarmaListe^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylar�n� yakala
      OlayYakalamayaBasla(_KarmaListe);

      _Alan.Sag := _KarmaListe^.FBoyutlar.Genislik2 - 1;
      _Alan.Alt := 22;
      _Alan.Sol := _Alan.Sag - 15;
      _Alan.Ust := 1;

      if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _Alan)) then
      begin

        _KarmaListe^.FListeKutusuAcik := not _KarmaListe^.FListeKutusuAcik;

        // karma listeni yeniden �iz
        _Pencere^.Guncelle;
      end
      else
      begin

        if(AOlay.Deger1 < _Alan.Sag - 22) then
        begin

          // se�ilen s�ra numaras�n� belirle
          _SeciliSiraNo := AOlay.Deger2 div 22;

          if(_SeciliSiraNo > 0) then
          begin

            _KarmaListe^.FBaslik := FYaziListesi^.Eleman[_KarmaListe^.FGorunenIlkSiraNo + _SeciliSiraNo - 1];
          end;

          _KarmaListe^.FListeKutusuAcik := False;

          // karma listeni yeniden �iz
          _Pencere^.Guncelle;

          _KarmaListe^.FGorunenIlkSiraNo := 0;

          // uygulamaya mesaj g�nder
          //GorevListesi[_KarmaListe^.GorevKimlik]^.OlayEkle1(_KarmaListe^.GorevKimlik,
            //_KarmaListe, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
        end;
      end;
    end;
  end

  // sol fare tu� b�rak�m i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylar�n� almay� b�rak
    OlayYakalamayiBirak(_KarmaListe);
  end
  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukar� kayd�rma. ilk elemana do�ru
    if(AOlay.Deger1 < 0) then
    begin

      _SeciliSiraNo := _KarmaListe^.FGorunenIlkSiraNo;
      Dec(_SeciliSiraNo);
      if(_SeciliSiraNo >= 0) then _KarmaListe^.FGorunenIlkSiraNo := _SeciliSiraNo;
    end

    // listeyi a�a��ya kayd�rma. son elemana do�ru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kayd�rma de�eri
      i := _KarmaListe^.FYaziListesi^.ElemanSayisi - _KarmaListe^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      _SeciliSiraNo := _KarmaListe^.FGorunenIlkSiraNo;
      Inc(_SeciliSiraNo);
      if(_SeciliSiraNo <= i) then _KarmaListe^.FGorunenIlkSiraNo := _SeciliSiraNo;
    end;

    _KarmaListe^.Ciz;
  end;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

procedure TKarmaListe.OkResminiCiz(APencere: PPencere; AAlan: TAlan);
var
  p1: PByte;
  B1, A1: Integer;
begin

  p1 := PByte(@OKAlt);
  for B1 := 1 to 4 do
  begin

    for A1 := 1 to 7 do
    begin

      if(p1^ = 1) then
        PixelYaz(APencere, (AAlan.Sag - 12) + A1, (AAlan.Ust + 9) + B1, RENK_SIYAH);

      Inc(p1);
    end;
  end;
end;

procedure ListeyeEkle(AKarmaListe: PKarmaListe; ADeger: string);
begin

  AKarmaListe^.FYaziListesi^.Ekle(ADeger);

  // g�r�nen azami eleman say�s� = 2
  if(AKarmaListe^.FYaziListesi^.ElemanSayisi = 1) then
    AKarmaListe^.FGorunenElemanSayisi := 1
  else if(AKarmaListe^.FYaziListesi^.ElemanSayisi >= 2) then
    AKarmaListe^.FGorunenElemanSayisi := 2;

  if(AKarmaListe^.FYaziListesi^.ElemanSayisi > 0) then
    AKarmaListe^.FBaslik := AKarmaListe^.FYaziListesi^.Eleman[0];

  AKarmaListe^.FBoyutlar.Yukseklik2 := 22 + (AKarmaListe^.FGorunenElemanSayisi * 22);
end;

end.
