{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_listegorunum.pas
  Dosya ��levi: liste g�r�n�m y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_listegorunum;

interface

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi;

type
  PListeGorunum = ^TListeGorunum;
  TListeGorunum = object(TGorselNesne)
  private
    FSeciliSiraNo: TISayi4;               // se�ili sira de�eri
    FGorunenIlkSiraNo: TISayi4;           // liste g�r�n�mde en �stte g�r�nt�lenen eleman�n s�ra de�eri
    FGorunenElemanSayisi: TISayi4;        // kullan�c�ya nesne i�erisinde g�sterilen eleman say�s�
    FKolonAdlari: PYaziListesi;           // kolon ad listesi
    FKolonUzunluklari: PSayiListesi;      // kolon uzunluklar�
    FDegerler,                            // kolon i�erik de�erleri
    FDegerDizisi: PYaziListesi;           // FDegerler i�eri�ini b�l�mlemek i�in kullan�lacak
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
  liste g�r�n�m kesme �a�r�lar�n� y�netir
 ==============================================================================}
function ListeGorunumCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
  p1: PShortString;
  _Hiza: THiza;
begin

  case IslevNo of

    // nesne olu�tur
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

    // se�ilen s�ra de�erini al
    $0200:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then Result := _ListeGorunum^.FSeciliSiraNo;
    end;

    // liste i�eri�ini temizle
    $0300:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then
      begin

        // i�eri�i temizle, de�erleri �n de�erlere �ek
        _ListeGorunum^.FDegerler^.Temizle;
        _ListeGorunum^.FGorunenIlkSiraNo := 0;
        _ListeGorunum^.FSeciliSiraNo := -1;
        _ListeGorunum^.Ciz;
      end;
    end;

    // se�ilen yaz� (text) de�erini geri d�nd�r
    $0400:
    begin

      _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(
        PKimlik(Degiskenler + 00)^, gntListeGorunum));
      if(_ListeGorunum <> nil) then Result := _ListeGorunum^.FSeciliSiraNo;
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      p1^ := _ListeGorunum^.SeciliSatirDegeriniAl;
    end;

    // liste g�r�nt�leyicisinin ba�l�klar�n� sil
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

    // liste g�r�nt�leyicisine kolon ekle
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
  liste g�r�n�m nesnesini olu�turur
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
  liste g�r�n�m nesnesini olu�turur
 ==============================================================================}
function TListeGorunum.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PListeGorunum;
var
  _AtaNesne: PGorselNesne;
  _ListeGorunum: PListeGorunum;
  _KolonAdlari, _Degerler, _DegerDizisi: PYaziListesi;
  _KolonUzunluklari: PSayiListesi;
begin

  // nesnenin ba�lanaca�� ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // liste g�r�n�m nesnesini olu�tur
  _ListeGorunum := PListeGorunum(Olustur0(gntListeGorunum));
  if(_ListeGorunum = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // nesneyi ata nesneye ekle
  if(_ListeGorunum^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olmas� durumunda nesneyi yok et ve hata koduyla i�levden ��k
    _ListeGorunum^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne de�erlerini ata
  _ListeGorunum^.GorevKimlik := AktifGorev;
  _ListeGorunum^.AtaNesne := _AtaNesne;
  _ListeGorunum^.Hiza := hzYok;
  _ListeGorunum^.FBoyutlar.Sol2 := A1;
  _ListeGorunum^.FBoyutlar.Ust2 := B1;
  _ListeGorunum^.FBoyutlar.Genislik2 := AGenislik;
  _ListeGorunum^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kal�nl�klar�
  _ListeGorunum^.FKalinlik.Sol := 0;
  _ListeGorunum^.FKalinlik.Ust := 0;
  _ListeGorunum^.FKalinlik.Sag := 0;
  _ListeGorunum^.FKalinlik.Alt := 0;

  // kenar bo�luklar�
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

  // nesnenin kullanaca�� di�er de�erler
  _ListeGorunum^.FGorunenIlkSiraNo := 0;
  _ListeGorunum^.FSeciliSiraNo := -1;

  // liste g�r�n�m nesnesinde g�r�nt�lenecek eleman say�s�
  _ListeGorunum^.FGorunenElemanSayisi := (AYukseklik - 24) div 21;

  // nesnenin ad ve ba�l�k de�eri
  _ListeGorunum^.NesneAdi := NesneAdiAl(gntListeGorunum);
  _ListeGorunum^.Baslik := '';

  // uygulamaya mesaj g�nder
  GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
    _ListeGorunum, CO_OLUSTUR, 0, 0);

  // nesneyi g�r�nt�le
  _ListeGorunum^.Goster;

  // nesne adresini geri d�nd�r
  Result := _ListeGorunum;
end;

{==============================================================================
  nesneye ayr�lan kaynaklar� ve nesneyi yok eder
 ==============================================================================}
procedure TListeGorunum.YokEt(AKimlik: TKimlik);
var
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin Kimlik, tip de�erlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(AKimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  if(_ListeGorunum^.FDegerler <> nil) then _ListeGorunum^.FDegerler^.YokEt;
  if(_ListeGorunum^.FDegerDizisi <> nil) then _ListeGorunum^.FDegerDizisi^.YokEt;
  if(_ListeGorunum^.FKolonAdlari <> nil) then _ListeGorunum^.FKolonAdlari^.YokEt;
  if(_ListeGorunum^.FKolonUzunluklari <> nil) then _ListeGorunum^.FKolonUzunluklari^.YokEt;

  YokEt0;
end;

{==============================================================================
  se�ili eleman�n yaz� (text) de�erini geri d�nd�r�r
 ==============================================================================}
function TListeGorunum.SeciliSatirDegeriniAl: string;
var
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  if(FSeciliSiraNo = -1) or (FSeciliSiraNo > FDegerler^.ElemanSayisi) then Exit('');

  Result := _ListeGorunum^.FDegerler^.Eleman[FSeciliSiraNo];
end;

{==============================================================================
  liste g�r�n�m nesnesini g�r�nt�ler
 ==============================================================================}
procedure TListeGorunum.Goster;
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // e�er nesne g�r�n�r de�ilse
  if(_ListeGorunum^.Gorunum = False) then
  begin

    // nesnenin g�r�n�rl���n� aktifle�tir
    _ListeGorunum^.Gorunum := True;

    // nesne ve �st nesneler g�r�n�r ise
    if(_ListeGorunum^.AtaNesneGorunurMu) then
    begin

      // nesnenin sahibi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);

      // pencereyi g�ncelle�tir
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  liste g�r�n�m nesnesini �izer
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

  // nesnenin kimlik, tip de�erlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(Kimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // liste g�r�n�m�n �st nesneye ba�l� olarak koordinatlar�n� al
  _Alan1 := _ListeGorunum^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);
  if(_Pencere = nil) then Exit;

  // d�� kenarl�k
  DikdortgenDoldur(_Pencere, _Alan1.A1, _Alan1.B1, _Alan1.A2, _Alan1.B2, $828790, RENK_BEYAZ);

  _KolonUzunluklari := _ListeGorunum^.FKolonUzunluklari;
  _KolonAdlari := _ListeGorunum^.FKolonAdlari;

  // tan�mlanm�� hi�bir kolon yok ise, ��k
  if(_KolonAdlari^.ElemanSayisi = 0) then Exit;

  // kolon ba�l�k ve de�erleri
  XX := _Alan1.A1 + 1;
  for i := 0 to _KolonUzunluklari^.ElemanSayisi - 1 do
  begin

    XX += _KolonUzunluklari^.Eleman[i];

    // dikey k�lavuz �izgisi
    Cizgi(_Pencere, XX, _Alan1.B1 + 1, XX, _Alan1.B2 - 1, $F0F0F0);

    // ba�l�k dolgusu
    _Alan2.A1 := XX - _KolonUzunluklari^.Eleman[i];
    _Alan2.B1 := _Alan1.B1 + 1;
    _Alan2.A2 := XX - 1;
    _Alan2.B2 := _Alan1.B1 + 1 + 22;
    EgimliDoldur3(_Pencere, _Alan2, $EAECEE, $ABB2B9);

    // ba�l�k
    AlanaYaziYaz(_Pencere, _Alan2, 4, 3, _KolonAdlari^.Eleman[i], RENK_LACIVERT);

    Inc(XX);    // 1 px �izgi kal�nl���
  end;

  // yatay k�lavuz �izgileri
  YY := _Alan1.B1 + 1 + 22;
  YY += 20;
  while YY < _Alan1.B2 do
  begin

    Cizgi(_Pencere, _Alan1.A1 + 1, YY, _Alan1.A2 - 1, YY, $F0F0F0);
    YY += 1 + 20;
  end;

  // liste g�r�n�m nesnesinde g�r�nt�lenecek eleman say�s�
  _ListeGorunum^.FGorunenElemanSayisi := ((_ListeGorunum^.FDisGercekBoyutlar.B2 -
    _ListeGorunum^.FDisGercekBoyutlar.B1) - 24) div 21;

  // liste g�r�n�m kutusunda g�r�nt�lenecek eleman say�s�n�n belirlenmesi
  if(FDegerler^.ElemanSayisi > _ListeGorunum^.FGorunenElemanSayisi) then
    _ElemanSayisi := _ListeGorunum^.FGorunenElemanSayisi + _ListeGorunum^.FGorunenIlkSiraNo
  else _ElemanSayisi := FDegerler^.ElemanSayisi + _ListeGorunum^.FGorunenIlkSiraNo;

  YY := _Alan1.B1 + 1 + 22;
  YY += 20;
  _SatirNo := 0;
  _KolonUzunluklari := _ListeGorunum^.FKolonUzunluklari;

  // liste g�r�n�m de�erlerini yerle�tir
  for _SatirNo := _ListeGorunum^.FGorunenIlkSiraNo to _ElemanSayisi - 1 do
  begin

    // de�eri belirtilen karakter ile b�l�mle
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

        // sat�r verisini boyama ve yazma i�lemi
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
  | ay�rac�yla gelen karakter katar�n� b�l�mler
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
  liste g�r�n�m nesne olaylar�n� i�ler
 ==============================================================================}
procedure TListeGorunum.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _ListeGorunum: PListeGorunum;
  i, j: TISayi4;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _ListeGorunum := PListeGorunum(_ListeGorunum^.NesneTipiniKontrolEt(AKimlik, gntListeGorunum));
  if(_ListeGorunum = nil) then Exit;

  // sol fare tu� bas�m�
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // liste g�r�n�m�n sahibi olan pencere en �stte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_ListeGorunum);

    // en �stte olmamas� durumunda en �ste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // sol tu�a bas�m i�lemi nesnenin olay alan�nda m� ger�ekle�ti ?
    if(_ListeGorunum^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylar�n� yakala
      OlayYakalamayaBasla(_ListeGorunum);

      // se�ilen s�ray� yeniden belirle
      j := (AOlay.Deger2 - 24) div 21;

      // bu de�ere kayd�r�lan de�eri de ekle
      _ListeGorunum^.FSeciliSiraNo := (j + _ListeGorunum^.FGorunenIlkSiraNo);

      // liste g�r�n�m nesnesini yeniden �iz
      _ListeGorunum^.Ciz;

      // uygulamaya mesaj g�nder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end;
  end

  // sol fare tu� b�rak�m i�lemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylar�n� almay� b�rak
    OlayYakalamayiBirak(_ListeGorunum);

    // fare b�rakma i�lemi nesnenin olay alan�nda m� ger�ekle�ti ?
    if(_ListeGorunum^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & b�rakma i�lemi bu nesnede oldu�u i�in
      // nesneye FO_TIKLAMA mesaj� g�nder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;

    // uygulamaya mesaj g�nder
    GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
      _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  // fare hakeret i�lemi
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // e�er nesne yakalanm�� ise
    if(YakalananGorselNesne <> nil) then
    begin

      // fare liste g�r�n�m nesnesinin yukar�s�nda ise
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

      // fare liste g�r�n�m nesnesinin a�a��s�nda ise
      else if(AOlay.Deger2 > _ListeGorunum^.FBoyutlar.B2) then
      begin

        // azami kayd�rma de�eri
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

      // fare liste g�r�n�m kutusunun i�erisinde ise
      else
      begin

        i := (AOlay.Deger2 - 24) div 21;
        _ListeGorunum^.FSeciliSiraNo := i + _ListeGorunum^.FGorunenIlkSiraNo;
      end;

      // liste g�r�n�m nesnesini yeniden �iz
      _ListeGorunum^.Ciz;

      // uygulamaya mesaj g�nder
      GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
        _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
    end

    // nesne yakalanmam�� ise uygulamaya sadece mesaj g�nder
    else GorevListesi[_ListeGorunum^.GorevKimlik]^.OlayEkle1(_ListeGorunum^.GorevKimlik,
      _ListeGorunum, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukar� kayd�rma i�lemi. ilk elemana do�ru
    if(AOlay.Deger1 < 0) then
    begin

      j := _ListeGorunum^.FGorunenIlkSiraNo;
      Dec(j);
      if(j >= 0) then _ListeGorunum^.FGorunenIlkSiraNo := j;
    end

    // listeyi a�a��ya kayd�rma i�lemi. son elemana do�ru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kayd�rma de�eri
      i := _ListeGorunum^.FDegerler^.ElemanSayisi - _ListeGorunum^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      j := _ListeGorunum^.FGorunenIlkSiraNo;
      Inc(j);
      if(j < i) then _ListeGorunum^.FGorunenIlkSiraNo := j;
    end;

    _ListeGorunum^.Ciz;
  end;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
