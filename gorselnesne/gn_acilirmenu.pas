{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_acilirmenu.pas
  Dosya ��levi: a��l�r men� y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 11/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_acilirmenu;

interface

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi, gn_menu;

type
  PAcilirMenu = ^TAcilirMenu;
  TAcilirMenu = object(TMenu)
  public
    function Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
      ASeciliYaziRenk: TRenk): PAcilirMenu;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Gizle;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function AcilirMenuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;

implementation

uses genel, temelgorselnesne, sistemmesaj, gn_islevler;

{==============================================================================
  a��l�r men� kesme �a�r�lar�n� y�netir
 ==============================================================================}
function AcilirMenuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _AcilirMenu: PAcilirMenu;
  _AElemanAdi: string;
  _AResimSiraNo, i: TISayi4;
begin

  case IslevNo of

    // nesne olu�tur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // a��l�r men�y� g�r�nt�le
    ISLEV_GOSTER:
    begin

      _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntAcilirMenu));
      if(_AcilirMenu <> nil) then _AcilirMenu^.Goster;
    end;

    // a��l�r men�y� gizle
    ISLEV_GIZLE:
    begin

      _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntAcilirMenu));
      if(_AcilirMenu <> nil) then _AcilirMenu^.Gizle;
    end;

    // eleman ekle
    $0100:
    begin

      _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntAcilirMenu));

      _AElemanAdi := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^;
      _AResimSiraNo := PISayi4(Degiskenler + 08)^;

      if(_AcilirMenu <> nil) then
      begin

        _AcilirMenu^.FMenuElemanBaslik^.Ekle(_AElemanAdi);
        _AcilirMenu^.FMenuElemanResim^.Ekle(_AResimSiraNo);

        // men� geni�lik ve y�ksekli�ini yeniden belirle
        {i := (Length(_AElemanAdi) * 8) + 24 + 2;
        if(i > _AcilirMenu^.FBoyutlar.Genislik2) then _AcilirMenu^.FBoyutlar.Genislik2 := i;
        _AcilirMenu^.FBoyutlar.Yukseklik2 := (_AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi *
          _AcilirMenu^.FElemanYukseklik) + 2;}

        Result := 1;
      end else Result := 0;
    end;

    // se�ilen eleman�n s�ra de�erini al
    $0200:
    begin

      _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntAcilirMenu));
      if(_AcilirMenu <> nil) then Result := _AcilirMenu^.FSeciliSiraNo
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  a��l�r men� nesnesini olu�turur
 ==============================================================================}
function NesneOlustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): TKimlik;
var
  _AcilirMenu: PAcilirMenu;
begin

  _AcilirMenu := _AcilirMenu^.Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
      ASeciliYaziRenk);

  if(_AcilirMenu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _AcilirMenu^.Kimlik;
end;

{==============================================================================
  a��l�r men� nesnesini olu�turur
 ==============================================================================}
function TAcilirMenu.Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): PAcilirMenu;
var
  _AcilirMenu: PAcilirMenu;
  _YL: PYaziListesi;
  _SL: PSayiListesi;
begin

  // a��l�r men� nesnesi i�in yer ay�r
  _AcilirMenu := PAcilirMenu(Olustur0(gntAcilirMenu));
  if(_AcilirMenu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // a��l�r nesne de�erlerini ata
  _AcilirMenu^.GorevKimlik := CalisanGorev;
  _AcilirMenu^.AtaNesne := GAktifMasaustu;
  _AcilirMenu^.Hiza := hzYok;
  _AcilirMenu^.FBoyutlar.Sol2 := 0;
  _AcilirMenu^.FBoyutlar.Ust2 := 0;
  _AcilirMenu^.FBoyutlar.Genislik2 := 300;
  _AcilirMenu^.FBoyutlar.Yukseklik2 := (24 * 5) + 2;

  _AcilirMenu^.FElemanYukseklik := 24;

  // kenar kal�nl�klar�
  _AcilirMenu^.FKalinlik.Sol := 0;
  _AcilirMenu^.FKalinlik.Ust := 0;
  _AcilirMenu^.FKalinlik.Sag := 0;
  _AcilirMenu^.FKalinlik.Alt := 0;

  // kenar bo�luklar�
  _AcilirMenu^.FKenarBosluklari.Sol := 0;
  _AcilirMenu^.FKenarBosluklari.Ust := 0;
  _AcilirMenu^.FKenarBosluklari.Sag := 0;
  _AcilirMenu^.FKenarBosluklari.Alt := 0;

  // nesnenin i� ve d�� boyutlar�n� yeniden hesapla
  _AcilirMenu^.IcVeDisBoyutlariYenidenHesapla;

  _AcilirMenu^.FKenarRenk := AKenarRenk;
  _AcilirMenu^.FGovdeRenk := AGovdeRenk;
  _AcilirMenu^.FSecimRenk := ASecimRenk;
  _AcilirMenu^.FNormalYaziRenk := ANormalYaziRenk;
  _AcilirMenu^.FSeciliYaziRenk := ASeciliYaziRenk;

  _AcilirMenu^.FAtaNesneMi := False;
  _AcilirMenu^.FareGostergeTipi := fitOK;
  _AcilirMenu^.Gorunum := False;

  // a��l�r men� �izimi i�in bellekte yer ay�r
  _AcilirMenu^.FCizimBellekAdresi := GGercekBellek.Ayir(_AcilirMenu^.FBoyutlar.Genislik2 *
    _AcilirMenu^.FBoyutlar.Yukseklik2 * 4);
  if(_AcilirMenu^.FCizimBellekAdresi = nil) then
  begin

    // hata olmas� durumunda nesneyi yok et ve i�levden ��k
    _AcilirMenu^.YokEt0;
    Result := nil;
    Exit;
  end;

  _AcilirMenu^.FMenuElemanBaslik := nil;
  _YL := _YL^.Olustur;
  if(_YL <> nil) then _AcilirMenu^.FMenuElemanBaslik := _YL;

  _AcilirMenu^.FMenuElemanResim := nil;
  _SL := _SL^.Olustur;
  if(_SL <> nil) then _AcilirMenu^.FMenuElemanResim := _SL;

  // nesnenin kullanaca�� di�er de�erler
  //_AcilirMenu^.FIlkSiraNo := 0;
  //_AcilirMenu^.FSeciliSiraNo := -1;     // se�ili s�ra yok

  // a��l�r men�de g�r�nt�lenecek eleman say�s�
  _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi := 0;

  // nesnenin ad ve ba�l�k de�eri
  _AcilirMenu^.NesneAdi := NesneAdiAl(gntAcilirMenu);
  _AcilirMenu^.Baslik := '';

  // uygulamaya mesaj g�nder
  GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik, _AcilirMenu,
    CO_OLUSTUR, 0, 0);

  // a��l�r men�y� aktif masa�st�ne ba�la
  //GAktifMasaustu^.FMenu := _AcilirMenu;

  // nesne adresini geri d�nd�r
  Result := _AcilirMenu;
end;

{==============================================================================
  nesne ve nesneye ayr�lan kaynaklar� yok eder
 ==============================================================================}
procedure TAcilirMenu.YokEt(AKimlik: TKimlik);
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin Kimlik, tip de�erlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(AKimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  if(_AcilirMenu^.FMenuElemanBaslik <> nil) then _AcilirMenu^.FMenuElemanBaslik^.YokEt;
  if(_AcilirMenu^.FMenuElemanResim <> nil) then _AcilirMenu^.FMenuElemanResim^.YokEt;

  YokEt0;
end;

{==============================================================================
  a��l�r men� nesnesini g�r�nt�ler
 ==============================================================================}
procedure TAcilirMenu.Goster;
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(Kimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  GAktifMasaustu^.FMenu := _AcilirMenu;

  FBoyutlar.Sol2 := GFareSurucusu.YatayKonum;
  FBoyutlar.Ust2 := GFareSurucusu.DikeyKonum;
  _AcilirMenu^.IcVeDisBoyutlariYenidenHesapla;

  // nesnenin g�r�n�rl���n� aktifle�tir
  _AcilirMenu^.Gorunum := True;

  // daha �nceden se�ilmi� index de�erini kald�r
  _AcilirMenu^.FSeciliSiraNo := -1;
end;

{==============================================================================
  a��l�r men� nesnesini gizler
 ==============================================================================}
procedure TAcilirMenu.Gizle;
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(Kimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  // nesnenin g�r�n�rl���n� pasifle�tir
  _AcilirMenu^.Gorunum := False;
end;

{==============================================================================
  a��l�r men� nesnesini �izer
 ==============================================================================}
procedure TAcilirMenu.Ciz;
var
  _AcilirMenu: PAcilirMenu;
  _YL: PYaziListesi;
  _SL: PSayiListesi;
  _Alan: TAlan;
  _SiraNo, _A1, _B1,
  _MenudekiElemanSayisi: TISayi4;
  s: string;
begin

  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(Kimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  // a��l�r men�n�n �st nesneye ba�l� olarak koordinatlar�n� al
  _Alan := _AcilirMenu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // a��l�r men� i�erisinin boyama i�lemi
  DikdortgenDoldur(_AcilirMenu, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2,
    _AcilirMenu^.FKenarRenk, _AcilirMenu^.FGovdeRenk);

  _YL := _AcilirMenu^.FMenuElemanBaslik;
  _SL := _AcilirMenu^.FMenuElemanResim;

  // nesnenin eleman� var m� ?
  if(_YL^.ElemanSayisi > 0) then
  begin

    // �izim / yaz�m i�in kullan�lacak _A1 & _B1 koordinatlar�
    _A1 := _Alan.A1 + 1;
    _B1 := _Alan.B1 + 1;

    // a��l�r men� kutusunda g�r�nt�lenecek eleman say�s�
    if(_YL^.ElemanSayisi > _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi) then
      _MenudekiElemanSayisi := _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi + _AcilirMenu^.FIlkSiraNo
    else _MenudekiElemanSayisi := _YL^.ElemanSayisi + _AcilirMenu^.FIlkSiraNo;

    // a��l�r men� i�erisini elemanlarla doldurma i�lemi
    for _SiraNo := _AcilirMenu^.FIlkSiraNo to _MenudekiElemanSayisi - 1 do
    begin

      // belirtilen eleman�n karakter katar de�erini al
      s := _YL^.Eleman[_SiraNo];

      // eleman�n se�ili olmas� durumunda se�ili oldu�unu belirt
      // belirtilen s�ra se�ili de�ilse sadece eleman de�erini yaz
      if(_SiraNo = _AcilirMenu^.FSeciliSiraNo) then
      begin

        DikdortgenDoldur(_AcilirMenu, _A1 + 24, _B1, _AcilirMenu^.FBoyutlar.A2 - 3,
          _B1 + 22, _AcilirMenu^.FSecimRenk, _AcilirMenu^.FSecimRenk);

        YaziYaz(_AcilirMenu, _A1 + 26, _B1 + 4, s, _AcilirMenu^.FSeciliYaziRenk);
      end else YaziYaz(_AcilirMenu, _A1 + 26, _B1 + 4, s, _AcilirMenu^.FNormalYaziRenk);

      // a��l�r men� resmini �iz
      KaynaktanResimCiz(_AcilirMenu, _A1, _B1, _SL^.Eleman[_SiraNo]);

      // bir sonraki eleman...
      _B1 += _AcilirMenu^.FElemanYukseklik;
    end;
  end;
end;

{==============================================================================
  a��l�r men� nesne olaylar�n� i�ler
 ==============================================================================}
procedure TAcilirMenu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _AcilirMenu: PAcilirMenu;
begin

  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(AKimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  // sol mouse tu� bas�m�
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sol tu�a bas�m i�lemi nesnenin olay alan�nda m� ger�ekle�ti ?
    if(_AcilirMenu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylar�n� yakala
      OlayYakalamayaBasla(_AcilirMenu);

      // mouse bas�m i�leminin ger�ekle�ti�i index numaras�
      _AcilirMenu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _AcilirMenu^.FElemanYukseklik;

      // popupmenu'y� gizle
      _AcilirMenu^.Gorunum := False;

      // uygulamaya mesaj g�nder
      GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik,
        _AcilirMenu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylar�n� almay� b�rak
    OlayYakalamayiBirak(_AcilirMenu);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // se�ilen eleman�n index numaras�n� belirle
    _AcilirMenu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _AcilirMenu^.FElemanYukseklik;

    // uygulamaya mesaj g�nder
    GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik, _AcilirMenu,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
