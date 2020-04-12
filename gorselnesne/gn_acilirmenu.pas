{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: gn_acilirmenu.pas
  Dosya Ýþlevi: açýlýr menü yönetim iþlevlerini içerir

  Güncelleme Tarihi: 11/04/2020

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
  açýlýr menü kesme çaðrýlarýný yönetir
 ==============================================================================}
function AcilirMenuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _AcilirMenu: PAcilirMenu;
  _AElemanAdi: string;
  _AResimSiraNo, i: TISayi4;
begin

  case IslevNo of

    // nesne oluþtur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // açýlýr menüyü görüntüle
    ISLEV_GOSTER:
    begin

      _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^,
        gntAcilirMenu));
      if(_AcilirMenu <> nil) then _AcilirMenu^.Goster;
    end;

    // açýlýr menüyü gizle
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

        // menü geniþlik ve yüksekliðini yeniden belirle
        {i := (Length(_AElemanAdi) * 8) + 24 + 2;
        if(i > _AcilirMenu^.FBoyutlar.Genislik2) then _AcilirMenu^.FBoyutlar.Genislik2 := i;
        _AcilirMenu^.FBoyutlar.Yukseklik2 := (_AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi *
          _AcilirMenu^.FElemanYukseklik) + 2;}

        Result := 1;
      end else Result := 0;
    end;

    // seçilen elemanýn sýra deðerini al
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
  açýlýr menü nesnesini oluþturur
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
  açýlýr menü nesnesini oluþturur
 ==============================================================================}
function TAcilirMenu.Olustur(AKenarRenk, AGovdeRenk, ASecimRenk, ANormalYaziRenk,
  ASeciliYaziRenk: TRenk): PAcilirMenu;
var
  _AcilirMenu: PAcilirMenu;
  _YL: PYaziListesi;
  _SL: PSayiListesi;
begin

  // açýlýr menü nesnesi için yer ayýr
  _AcilirMenu := PAcilirMenu(Olustur0(gntAcilirMenu));
  if(_AcilirMenu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // açýlýr nesne deðerlerini ata
  _AcilirMenu^.GorevKimlik := CalisanGorev;
  _AcilirMenu^.AtaNesne := GAktifMasaustu;
  _AcilirMenu^.Hiza := hzYok;
  _AcilirMenu^.FBoyutlar.Sol2 := 0;
  _AcilirMenu^.FBoyutlar.Ust2 := 0;
  _AcilirMenu^.FBoyutlar.Genislik2 := 300;
  _AcilirMenu^.FBoyutlar.Yukseklik2 := (24 * 5) + 2;

  _AcilirMenu^.FElemanYukseklik := 24;

  // kenar kalýnlýklarý
  _AcilirMenu^.FKalinlik.Sol := 0;
  _AcilirMenu^.FKalinlik.Ust := 0;
  _AcilirMenu^.FKalinlik.Sag := 0;
  _AcilirMenu^.FKalinlik.Alt := 0;

  // kenar boþluklarý
  _AcilirMenu^.FKenarBosluklari.Sol := 0;
  _AcilirMenu^.FKenarBosluklari.Ust := 0;
  _AcilirMenu^.FKenarBosluklari.Sag := 0;
  _AcilirMenu^.FKenarBosluklari.Alt := 0;

  // nesnenin iç ve dýþ boyutlarýný yeniden hesapla
  _AcilirMenu^.IcVeDisBoyutlariYenidenHesapla;

  _AcilirMenu^.FKenarRenk := AKenarRenk;
  _AcilirMenu^.FGovdeRenk := AGovdeRenk;
  _AcilirMenu^.FSecimRenk := ASecimRenk;
  _AcilirMenu^.FNormalYaziRenk := ANormalYaziRenk;
  _AcilirMenu^.FSeciliYaziRenk := ASeciliYaziRenk;

  _AcilirMenu^.FAtaNesneMi := False;
  _AcilirMenu^.FareGostergeTipi := fitOK;
  _AcilirMenu^.Gorunum := False;

  // açýlýr menü çizimi için bellekte yer ayýr
  _AcilirMenu^.FCizimBellekAdresi := GGercekBellek.Ayir(_AcilirMenu^.FBoyutlar.Genislik2 *
    _AcilirMenu^.FBoyutlar.Yukseklik2 * 4);
  if(_AcilirMenu^.FCizimBellekAdresi = nil) then
  begin

    // hata olmasý durumunda nesneyi yok et ve iþlevden çýk
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

  // nesnenin kullanacaðý diðer deðerler
  //_AcilirMenu^.FIlkSiraNo := 0;
  //_AcilirMenu^.FSeciliSiraNo := -1;     // seçili sýra yok

  // açýlýr menüde görüntülenecek eleman sayýsý
  _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi := 0;

  // nesnenin ad ve baþlýk deðeri
  _AcilirMenu^.NesneAdi := NesneAdiAl(gntAcilirMenu);
  _AcilirMenu^.Baslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik, _AcilirMenu,
    CO_OLUSTUR, 0, 0);

  // açýlýr menüyü aktif masaüstüne baðla
  //GAktifMasaustu^.FMenu := _AcilirMenu;

  // nesne adresini geri döndür
  Result := _AcilirMenu;
end;

{==============================================================================
  nesne ve nesneye ayrýlan kaynaklarý yok eder
 ==============================================================================}
procedure TAcilirMenu.YokEt(AKimlik: TKimlik);
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin Kimlik, tip deðerlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(AKimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  if(_AcilirMenu^.FMenuElemanBaslik <> nil) then _AcilirMenu^.FMenuElemanBaslik^.YokEt;
  if(_AcilirMenu^.FMenuElemanResim <> nil) then _AcilirMenu^.FMenuElemanResim^.YokEt;

  YokEt0;
end;

{==============================================================================
  açýlýr menü nesnesini görüntüler
 ==============================================================================}
procedure TAcilirMenu.Goster;
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(Kimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  GAktifMasaustu^.FMenu := _AcilirMenu;

  FBoyutlar.Sol2 := GFareSurucusu.YatayKonum;
  FBoyutlar.Ust2 := GFareSurucusu.DikeyKonum;
  _AcilirMenu^.IcVeDisBoyutlariYenidenHesapla;

  // nesnenin görünürlüðünü aktifleþtir
  _AcilirMenu^.Gorunum := True;

  // daha önceden seçilmiþ index deðerini kaldýr
  _AcilirMenu^.FSeciliSiraNo := -1;
end;

{==============================================================================
  açýlýr menü nesnesini gizler
 ==============================================================================}
procedure TAcilirMenu.Gizle;
var
  _AcilirMenu: PAcilirMenu;
begin

  // nesnenin kimlik, tip deðerlerini denetle.
  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(Kimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  // nesnenin görünürlüðünü pasifleþtir
  _AcilirMenu^.Gorunum := False;
end;

{==============================================================================
  açýlýr menü nesnesini çizer
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

  // açýlýr menünün üst nesneye baðlý olarak koordinatlarýný al
  _Alan := _AcilirMenu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // açýlýr menü içerisinin boyama iþlemi
  DikdortgenDoldur(_AcilirMenu, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2,
    _AcilirMenu^.FKenarRenk, _AcilirMenu^.FGovdeRenk);

  _YL := _AcilirMenu^.FMenuElemanBaslik;
  _SL := _AcilirMenu^.FMenuElemanResim;

  // nesnenin elemaný var mý ?
  if(_YL^.ElemanSayisi > 0) then
  begin

    // çizim / yazým için kullanýlacak _A1 & _B1 koordinatlarý
    _A1 := _Alan.A1 + 1;
    _B1 := _Alan.B1 + 1;

    // açýlýr menü kutusunda görüntülenecek eleman sayýsý
    if(_YL^.ElemanSayisi > _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi) then
      _MenudekiElemanSayisi := _AcilirMenu^.FMenuElemanBaslik^.ElemanSayisi + _AcilirMenu^.FIlkSiraNo
    else _MenudekiElemanSayisi := _YL^.ElemanSayisi + _AcilirMenu^.FIlkSiraNo;

    // açýlýr menü içerisini elemanlarla doldurma iþlemi
    for _SiraNo := _AcilirMenu^.FIlkSiraNo to _MenudekiElemanSayisi - 1 do
    begin

      // belirtilen elemanýn karakter katar deðerini al
      s := _YL^.Eleman[_SiraNo];

      // elemanýn seçili olmasý durumunda seçili olduðunu belirt
      // belirtilen sýra seçili deðilse sadece eleman deðerini yaz
      if(_SiraNo = _AcilirMenu^.FSeciliSiraNo) then
      begin

        DikdortgenDoldur(_AcilirMenu, _A1 + 24, _B1, _AcilirMenu^.FBoyutlar.A2 - 3,
          _B1 + 22, _AcilirMenu^.FSecimRenk, _AcilirMenu^.FSecimRenk);

        YaziYaz(_AcilirMenu, _A1 + 26, _B1 + 4, s, _AcilirMenu^.FSeciliYaziRenk);
      end else YaziYaz(_AcilirMenu, _A1 + 26, _B1 + 4, s, _AcilirMenu^.FNormalYaziRenk);

      // açýlýr menü resmini çiz
      KaynaktanResimCiz(_AcilirMenu, _A1, _B1, _SL^.Eleman[_SiraNo]);

      // bir sonraki eleman...
      _B1 += _AcilirMenu^.FElemanYukseklik;
    end;
  end;
end;

{==============================================================================
  açýlýr menü nesne olaylarýný iþler
 ==============================================================================}
procedure TAcilirMenu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _AcilirMenu: PAcilirMenu;
begin

  _AcilirMenu := PAcilirMenu(_AcilirMenu^.NesneTipiniKontrolEt(AKimlik, gntAcilirMenu));
  if(_AcilirMenu = nil) then Exit;

  // sol mouse tuþ basýmý
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sol tuþa basým iþlemi nesnenin olay alanýnda mý gerçekleþti ?
    if(_AcilirMenu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare olaylarýný yakala
      OlayYakalamayaBasla(_AcilirMenu);

      // mouse basým iþleminin gerçekleþtiði index numarasý
      _AcilirMenu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _AcilirMenu^.FElemanYukseklik;

      // popupmenu'yü gizle
      _AcilirMenu^.Gorunum := False;

      // uygulamaya mesaj gönder
      GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik,
        _AcilirMenu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarýný almayý býrak
    OlayYakalamayiBirak(_AcilirMenu);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // seçilen elemanýn index numarasýný belirle
    _AcilirMenu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _AcilirMenu^.FElemanYukseklik;

    // uygulamaya mesaj gönder
    GorevListesi[_AcilirMenu^.GorevKimlik]^.OlayEkle1(_AcilirMenu^.GorevKimlik, _AcilirMenu,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
