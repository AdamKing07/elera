{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_listegorunum.pas
  Dosya Ýþlevi: liste görünüm yönetim iþlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_listegorunum;

interface

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi;

type
  PListeGorunum = ^TListeGorunum;
  TListeGorunum = object(TGorselNesne)
  private
    FSeciliSiraNo: TISayi4;               // seçili sira deðeri
    FGorunenIlkSiraNo: TISayi4;           // liste görünümde en üstte görüntülenen elemanýn sýra deðeri
    FGorunenElemanSayisi: TISayi4;        // kullanýcýya nesne içerisinde gösterilen eleman sayýsý
    FKolonAdlari: PYaziListesi;           // kolon ad listesi
    FKolonUzunluklari: PSayiListesi;      // kolon uzunluklarý
    FDegerler,                            // kolon içerik deðerleri
    FDegerDizisi: PYaziListesi;           // FDegerler içeriðini bölümlemek için kullanýlacak
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PListeGorunum;
    procedure YokEt(AKimlik: TKimlik);
    function SeciliSatirDegeriniAl: string;
    procedure Goster;
    procedure Ciz;
    procedure Bolumle(ABicimlenmisDeger: string; AAyiracDeger: Char;
      DegerDizisi: PYaziListesi);
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function ListeGorunumCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_islevler, gn_pencere, temelgorselnesne;

{==============================================================================
  liste görünüm kesme çaðrýlarýný yönetir
 ==============================================================================}
function ListeGorunumCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
  p1: PShortString;
  _Hiza: THiza;
begin

  case IslevNo of

    // nesne oluþtur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // eleman ekle
    $0100:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then _ListeGorunum^.FDegerler^.Ekle(
        PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^);
      Result := 1;
    end;

    // seçilen sýra deðerini al
    $0200:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then Result := _ListeGorunum^.FSeciliSiraNo;
    end;

    // liste içeriðini temizle
    $0300:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then
      begin

        // içeriði temizle, deðerleri ön deðerlere çek
        _ListeGorunum^.FDegerler^.Temizle;
        _ListeGorunum^.FGorunenIlkSiraNo := 0;
        _ListeGorunum^.FSeciliSiraNo := -1;
        _ListeGorunum^.Ciz;
      end;
    end;

    // seçilen yazý (text) deðerini geri döndür
    $0400:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then Result := _ListeGorunum^.FSeciliSiraNo;
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      p1^ := _ListeGorunum^.SeciliSatirDegeriniAl;
    end;

    // liste görüntüleyicisinin baþlýklarýný sil
    $0500:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then
      begin

        _ListeGorunum^.FKolonUzunluklari^.Temizle;
        _ListeGorunum^.FKolonAdlari^.Temizle;
        Result := 1;
      end;
    end;

    // liste görüntüleyicisine kolon ekle
    $0600:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then
      begin

        _ListeGorunum^.FKolonAdlari^.Ekle(
          PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^);
        _ListeGorunum^.FKolonUzunluklari^.Ekle(PISayi4(Degiskenler + 08)^);
        Result := 1;
      end;
    end;

    $0104:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _ListeGorunum^.Hiza := _Hiza;

      _Pencere := PPencere(_ListeGorunum^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  liste görünüm nesnesini oluþturur
 ==============================================================================}
function NesneOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  _ListeGorunum: PListeGorunum;
begin

  _ListeGorunum := _ListeGorunum^.Olustur(AtaKimlik, A1, B1, AGenislik, AYukseklik);
  if(_ListeGorunum = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _ListeGorunum^.Kimlik;
end;

{==============================================================================
  liste görünüm nesnesini oluþturur
 ==============================================================================}
function TListeGorunum.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PListeGorunum;
var
  _AtaNesne: PGorselNesne;
  _ListeGorunum: PListeGorunum;
  _KolonAdlari, _Degerler, _DegerDizisi: PYaziListesi;
  _KolonUzunluklari: PSayiListesi;
begin

  // nesnenin baðlanacaðý ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // liste görünüm nesnesini oluþtur
  _ListeGorunum := PListeGorunum(Olustur0(gntListeGorunum));
  if(_ListeGorunum = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // nesneyi ata nesneye ekle
  if(_ListeGorunum^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olmasý durumunda nesneyi yok et ve hata koduyla iþlevden çýk
    _ListeGorunum^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne deðerlerini ata
  _ListeGorunum^.GorevKimlik := AktifGorev;
  _ListeGorunum^.AtaNesne := _AtaNesne;
  _ListeGorunum^.Hiza := hzYok;
  _ListeGorunum^.FBoyutlar.Sol2 := A1;
  _ListeGorunum^.FBoyutlar.Ust2 := B1;
  _ListeGorunum^.FBoyutlar.Genislik2 := AGenislik;
  _ListeGorunum^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalýnlýklarý
  _ListeGorunum^.FKalinlik.Sol := 0;
  _ListeGorunum^.FKalinlik.Ust := 0;
  _ListeGorunum^.FKalinlik.Sag := 0;
  _ListeGorunum^.FKalinlik.Alt := 0;

  // kenar boþluklarý
  _ListeGorunum^.FKenarBosluklari.Sol := 0;
  _ListeGorunum^.FKenarBosluklari.Ust := 0;
  _ListeGorunum^.FKenarBosluklari.Sag := 0;
  _ListeGorunum^.FKenarBosluklari.Alt := 0;

  _ListeGorunum^.FAtaNesneMi := False;
  _ListeGorunum^.FareGostergeTipi := fitOK;
  _ListeGorunum^.Gorunum := False;

  _ListeGorunum^.FKolonAdlari := nil;
  _KolonAdlari := _KolonAdlari^.Olustur;
  if(_KolonAdlari <> nil) then _ListeGorunum^.FKolonAdlari := _KolonAdlari;

  _ListeGorunum^.FKolonUzunluklari := nil;
  _KolonUzunluklari := _KolonUzunluklari^.Olustur;
  if(_KolonUzunluklari <> nil) then _ListeGorunum^.FKolonUzunluklari := _KolonUzunluklari;

  _ListeGorunum^.FDegerler := nil;
  _Degerler := _Degerler^.Olustur;
  if(_Degerler <> nil) then _ListeGorunum^.FDegerler := _Degerler;

  _ListeGorunum^.FDegerDizisi := nil;
  _DegerDizisi := _DegerDizisi^.Olustur;
  if(_DegerDizisi <> nil) then _ListeGorunum^.FDegerDizisi := _DegerDizisi;

  // nesnenin kullanacaðý diðer deðerler
  _ListeGorunum^.FGorunenIlkSiraNo := 0;
  _ListeGorunum^.FSeciliSiraNo := -1;

  // liste görünüm nesnesinde görüntülenecek eleman sayýsý
  _ListeGorunum^.FGorunenElemanSayisi := (AYukseklik - 24) div 21;

  // nesnenin ad ve baþlýk deðeri
  _ListeGorunum^.NesneAdi := NesneAdiAl(gntListeGorunum);
  _ListeGorunum^.Baslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
    _ListeGorunum, CO_OLUSTUR, 0, 0);

  // nesneyi görüntüle
  _ListeGorunum^.Goster;

  // nesne adresini geri döndür
  Result := _ListeGorunum;
end;

{==============================================================================
  nesneye ayrýlan kaynaklarý ve nesneyi yok eder
 ==============================================================================}
procedure TListeGorunum.YokEt(AKimlik: TKimlik);
var
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin Kimlik, tip deðerlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(AKimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  if(_ListeGorunum^.FDegerler <> nil) then _ListeGorunum^.FDegerler^.YokEt;
  if(_ListeGorunum^.FDegerDizisi <> nil) then _ListeGorunum^.FDegerDizisi^.YokEt;
  if(_ListeGorunum^.FKolonAdlari <> nil) then _ListeGorunum^.FKolonAdlari^.YokEt;
  if(_ListeGorunum^.FKolonUzunluklari <> nil) then _ListeGorunum^.FKolonUzunluklari^.YokEt;

  YokEt0;
end;

{==============================================================================
  seçili elemanýn yazý (text) deðerini geri döndürür
 ==============================================================================}
function TListeGorunum.SeciliSatirDegeriniAl: string;
var
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  if(FSeciliSiraNo = -1) or (FSeciliSiraNo > FDegerler^.ElemanSayisi) then Exit('');

  Result := _ListeGorunum^.FDegerler^.Eleman[FSeciliSiraNo];
end;

{==============================================================================
  liste görünüm nesnesini görüntüler
 ==============================================================================}
procedure TListeGorunum.Goster;
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // eðer nesne görünür deðilse
  if(_ListeGorunum^.Gorunum = False) then
  begin

    // nesnenin görünürlüðünü aktifleþtir
    _ListeGorunum^.Gorunum := True;

    // nesne ve üst nesneler görünür ise
    if(_ListeGorunum^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);

      // pencereyi güncelleþtir
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  liste görünüm nesnesini çizer
 ==============================================================================}
procedure TListeGorunum.Ciz;
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
  _KolonAdlari: PYaziListesi;
  _KolonUzunluklari: PSayiListesi;
  _Alan1, _Alan2: TAlan;
  _ElemanSayisi, _SatirNo, i, j,
  XX, YY: TISayi4;
  s: string;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // liste görünümün üst nesneye baðlý olarak koordinatlarýný al
  _Alan1 := _ListeGorunum^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);
  if(_Pencere = nil) then Exit;

  // dýþ kenarlýk
  DikdortgenDoldur(_Pencere, _Alan1.A1, _Alan1.B1, _Alan1.A2, _Alan1.B2, $828790, RENK_BEYAZ);

  _KolonUzunluklari := _ListeGorunum^.FKolonUzunluklari;
  _KolonAdlari := _ListeGorunum^.FKolonAdlari;

  // tanýmlanmýþ hiçbir kolon yok ise, çýk
  if(_KolonAdlari^.ElemanSayisi = 0) then Exit;

  // kolon baþlýk ve deðerleri
  XX := _Alan1.A1 + 1;
  for i := 0 to _KolonUzunluklari^.ElemanSayisi - 1 do
  begin

    XX += _KolonUzunluklari^.Eleman[i];

    // dikey kýlavuz çizgisi
    Cizgi(_Pencere, XX, _Alan1.B1 + 1, XX, _Alan1.B2 - 1, $F0F0F0);

    // baþlýk dolgusu
    _Alan2.A1 := XX - _KolonUzunluklari^.Eleman[i];
    _Alan2.B1 := _Alan1.B1 + 1;
    _Alan2.A2 := XX - 1;
    _Alan2.B2 := _Alan1.B1 + 1 + 22;
    EgimliDoldur3(_Pencere, _Alan2, $EAECEE, $ABB2B9);

    // baþlýk
    AlanaYaziYaz(_Pencere, _Alan2, 4, 3, _KolonAdlari^.Eleman[i], RENK_LACIVERT);

    Inc(XX);    // 1 px çizgi kalýnlýðý
  end;

  // yatay kýlavuz çizgileri
  YY := _Alan1.B1 + 1 + 22;
  YY += 20;
  while YY < _Alan1.B2 do
  begin

    Cizgi(_Pencere, _Alan1.A1 + 1, YY, _Alan1.A2 - 1, YY, $F0F0F0);
    YY += 1 + 20;
  end;

  // liste görünüm nesnesinde görüntülenecek eleman sayýsý
  _ListeGorunum^.FGorunenElemanSayisi := ((_ListeGorunum^.FDisGercekBoyutlar.B2 -
    _ListeGorunum^.FDisGercekBoyutlar.B1) - 24) div 21;

  // liste görünüm kutusunda görüntülenecek eleman sayýsýnýn belirlenmesi
  if(FDegerler^.ElemanSayisi > _ListeGorunum^.FGorunenElemanSayisi) then
    _ElemanSayisi := _ListeGorunum^.FGorunenElemanSayisi + _ListeGorunum^.FGorunenIlkSiraNo
  else _ElemanSayisi := FDegerler^.ElemanSayisi + _ListeGorunum^.FGorunenIlkSiraNo;

  YY := _Alan1.B1 + 1 + 22;
  YY += 20;
  _SatirNo := 0;
  _KolonUzunluklari := _ListeGorunum^.FKolonUzunluklari;

  // liste görünüm deðerlerini yerleþtir
  for _SatirNo := _ListeGorunum^.FGorunenIlkSiraNo to _ElemanSayisi - 1 do
  begin

    // deðeri belirtilen karakter ile bölümle
    Bolumle(FDegerler^.Eleman[_SatirNo], '|', FDegerDizisi);

    XX := _Alan1.A1 + 1;
    if(FDegerDizisi^.ElemanSayisi > 0) then
    begin

      for j := 0 to FDegerDizisi^.ElemanSayisi - 1 do
      begin

        s := FDegerDizisi^.Eleman[j];
        _Alan2.A1 := XX + 1;
        _Alan2.B1 := YY - 20 + 1;
        _Alan2.A2 := XX + _KolonUzunluklari^.Eleman[j] - 1;
        _Alan2.B2 := YY - 1;

        // satýr verisini boyama ve yazma iþlemi
        if(_SatirNo = _ListeGorunum^.FSeciliSiraNo) then
        begin

          DikdortgenDoldur(_Pencere, _Alan2.A1 - 1, _Alan2.B1 - 1, _Alan2.A2, _Alan2.B2,
            $3EC5FF, $3EC5FF);
        end
        else
        begin

          DikdortgenDoldur(_Pencere, _Alan2.A1 - 1, _Alan2.B1 - 1, _Alan2.A2, _Alan2.B2,
            RENK_BEYAZ, RENK_BEYAZ);
        end;
        AlanaYaziYaz(_Pencere, _Alan2, 2, 2, s, RENK_SIYAH);

        XX += 1 + _KolonUzunluklari^.Eleman[j];
      end;
    end;

    YY += 1 + 20;
  end;
end;

{==============================================================================
  | ayýracýyla gelen karakter katarýný bölümler
 ==============================================================================}
procedure TListeGorunum.Bolumle(ABicimlenmisDeger: string; AAyiracDeger: Char;
  DegerDizisi: PYaziListesi);
var
  _Uzunluk, i: TISayi4;
  s: string;
begin

  DegerDizisi^.Temizle;

  _Uzunluk := Length(ABicimlenmisDeger);
  if(_Uzunluk > 0) then
  begin

    i := 1;
    s := '';
    while i <= _Uzunluk do
    begin

      if(ABicimlenmisDeger[i] = AAyiracDeger) or (i = _Uzunluk) then
      begin

        if(i = _Uzunluk) then s += ABicimlenmisDeger[i];

        if(Length(s) > 0) then
        begin

          DegerDizisi^.Ekle(s);
          s := '';
        end;
      end else s += ABicimlenmisDeger[i];

      Inc(i);
    end;
  end;
end;

{==============================================================================
  liste görünüm nesne olaylarýný iþler
 ==============================================================================}
procedure TListeGorunum.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
  i, j: TISayi4;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(AKimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // sol fare tuþ basýmý
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // liste görünümün sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);

    // en üstte olmamasý durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tuþa basým iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(_ListeGorunum^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarýný yakala
      OlayYakalamayaBasla(_ListeGorunum);

      // seçilen sýrayý yeniden belirle
      j := (AOlay.Deger2 - 24) div 21;

      // bu deðere kaydýrýlan deðeri de ekle
      _ListeGorunum^.FSeciliSiraNo := (j + _ListeGorunum^.FGorunenIlkSiraNo);

      // liste görünüm nesnesini yeniden çiz
      _ListeGorunum^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end

  // sol fare tuþ býrakým iþlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarýný almayý býrak
    OlayYakalamayiBirak(_ListeGorunum);

    // fare býrakma iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(_ListeGorunum^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & býrakma iþlemi bu nesnede olduðu için
      // nesneye FO_TIKLAMA mesajý gönder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
      _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  // fare hakeret iþlemi
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eðer nesne yakalanmýþ ise
    if(YakalananGorselNesne <> nil) then
    begin

      // fare liste görünüm nesnesinin yukarýsýnda ise
      if(AOlay.Deger2 < 0) then
      begin

        j := _ListeGorunum^.FGorunenIlkSiraNo;
        Dec(j);
        if(j >= 0) then
        begin

          _ListeGorunum^.FGorunenIlkSiraNo := j;
          _ListeGorunum^.FSeciliSiraNo := j;
        end;
      end

      // fare liste görünüm nesnesinin aþaðýsýnda ise
      else if(AOlay.Deger2 > _ListeGorunum^.FBoyutlar.B2) then
      begin

        // azami kaydýrma deðeri
        i := _ListeGorunum^.FKolonAdlari^.ElemanSayisi - _ListeGorunum^.FGorunenElemanSayisi;
        if(i < 0) then i := 0;

        j := _ListeGorunum^.FGorunenIlkSiraNo;
        Inc(j);
        if(j < i) then
        begin

          _ListeGorunum^.FGorunenIlkSiraNo := j;
          i := (AOlay.Deger2 - 24) div 21;
          _ListeGorunum^.FSeciliSiraNo := i + _ListeGorunum^.FGorunenIlkSiraNo;
        end
      end

      // fare liste görünüm kutusunun içerisinde ise
      else
      begin

        i := (AOlay.Deger2 - 24) div 21;
        _ListeGorunum^.FSeciliSiraNo := i + _ListeGorunum^.FGorunenIlkSiraNo;
      end;

      // liste görünüm nesnesini yeniden çiz
      _ListeGorunum^.Ciz;

      // uygulamaya mesaj gönder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end

    // nesne yakalanmamýþ ise uygulamaya sadece mesaj gönder
    else GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
      _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukarý kaydýrma iþlemi. ilk elemana doðru
    if(AOlay.Deger1 < 0) then
    begin

      j := _ListeGorunum^.FGorunenIlkSiraNo;
      Dec(j);
      if(j >= 0) then _ListeGorunum^.FGorunenIlkSiraNo := j;
    end

    // listeyi aþaðýya kaydýrma iþlemi. son elemana doðru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kaydýrma deðeri
      i := _ListeGorunum^.FDegerler^.ElemanSayisi - _ListeGorunum^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      j := _ListeGorunum^.FGorunenIlkSiraNo;
      Inc(j);
      if(j < i) then _ListeGorunum^.FGorunenIlkSiraNo := j;
    end;

    _ListeGorunum^.Ciz;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
