{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_menu.pas
  Dosya İşlevi: menü yönetim işlevlerini içerir

  Güncelleme Tarihi: 11/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_menu;

interface

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi;

type
  PMenu = ^TMenu;
  TMenu = object(TGorselNesne)
  private
    FElemanYukseklik,                     // her bir elemanın yüksekliği
    FSeciliSiraNo: TISayi4;               // seçili sıra no
    FIlkSiraNo: TISayi4;                  // ilk görünen elemanın sıra numarası
    FMenuElemanBaslik: PYaziListesi;      // menü eleman başlıkları
    FMenuElemanResim: PSayiListesi;       // menü eleman resim sıra numaraları
  public
    function Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): PMenu;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Gizle;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function MenuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;

implementation

uses genel, temelgorselnesne;

{==============================================================================
  menü kesme çağrılarını yönetir
 ==============================================================================}
function MenuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Menu: PMenu;
  _AElemanAdi: string;
  _AResimSiraNo: TISayi4;
begin

  case IslevNo of

    // nesne oluştur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    // menüyü görüntüle
    ISLEV_GOSTER:
    begin

      _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntMenu));
      if(_Menu <> nil) then _Menu^.Goster;
    end;

    // menüyü gizle
    ISLEV_GIZLE:
    begin

      _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntMenu));
      if(_Menu <> nil) then _Menu^.Gizle;
    end;

    // eleman ekle
    $0100:
    begin

      _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntMenu));

      _AElemanAdi := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^;
      _AResimSiraNo := PISayi4(Degiskenler + 08)^;

      if(_Menu <> nil) then
      begin

        _Menu^.FMenuElemanBaslik^.Ekle(_AElemanAdi);
        _Menu^.FMenuElemanResim^.Ekle(_AResimSiraNo);
        Result := 1;
      end else Result := 0;
    end;

    // seçilen elemanın sıra değerini al
    $0200:
    begin

      _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntMenu));
      if(_Menu <> nil) then Result := _Menu^.FSeciliSiraNo
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  menü nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
var
  _Menu: PMenu;
begin

  _Menu := _Menu^.Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik);

  if(_Menu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Menu^.Kimlik;
end;

{==============================================================================
  menü nesnesini oluşturur
 ==============================================================================}
function TMenu.Olustur(A1, B1, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): PMenu;
var
  _Menu: PMenu;
  _YL: PYaziListesi;
  _SL: PSayiListesi;
begin

  // masaüstüne bağlı menü var ise çık
  if not(GAktifMasaustu^.FBaslatmaMenusu = nil) then Exit(nil);

  // menü nesnesi için yer ayır
  _Menu := PMenu(Olustur0(gntMenu));
  if(_Menu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Menu^.GorevKimlik := AktifGorev;
  _Menu^.AtaNesne := GAktifMasaustu;
  _Menu^.Hiza := hzYok;
  _Menu^.FBoyutlar.Sol2 := A1;
  _Menu^.FBoyutlar.Ust2 := B1;
  _Menu^.FBoyutlar.Genislik2 := AGenislik;
  _Menu^.FBoyutlar.Yukseklik2 := AYukseklik;

  _Menu^.FElemanYukseklik := AElemanYukseklik;

  // kenar kalınlıkları
  _Menu^.FKalinlik.Sol := 0;
  _Menu^.FKalinlik.Ust := 0;
  _Menu^.FKalinlik.Sag := 0;
  _Menu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Menu^.FKenarBosluklari.Sol := 0;
  _Menu^.FKenarBosluklari.Ust := 0;
  _Menu^.FKenarBosluklari.Sag := 0;
  _Menu^.FKenarBosluklari.Alt := 0;

  // nesnenin iç ve dış boyutlarını yeniden hesapla
  _Menu^.IcVeDisBoyutlariYenidenHesapla;

  _Menu^.FAtaNesneMi := False;
  _Menu^.FareGostergeTipi := fitOK;
  _Menu^.Gorunum := False;

  // menü çizimi için bellekte yer ayır
  _Menu^.FCizimBellekAdresi := GGercekBellek.Ayir(_Menu^.FBoyutlar.Genislik2 *
    _Menu^.FBoyutlar.Yukseklik2 * 4);
  if(_Menu^.FCizimBellekAdresi = nil) then
  begin

    // hata olması durumunda nesneyi yok et ve işlevden çık
    _Menu^.YokEt0;
    Result := nil;
    Exit;
  end;

  _Menu^.FMenuElemanBaslik := nil;
  _YL := _YL^.Olustur;
  if(_YL <> nil) then _Menu^.FMenuElemanBaslik := _YL;

  _Menu^.FMenuElemanResim := nil;
  _SL := _SL^.Olustur;
  if(_SL <> nil) then _Menu^.FMenuElemanResim := _SL;

  // nesnenin kullanacağı diğer değerler
  _Menu^.FIlkSiraNo := 0;
  _Menu^.FSeciliSiraNo := -1;     // seçili sıra yok

  // menüde görüntülenecek eleman sayısı
  _Menu^.FMenuElemanBaslik^.ElemanSayisi := (AYukseklik + (_Menu^.FElemanYukseklik - 1)) div
    _Menu^.FElemanYukseklik;

  // nesnenin ad ve başlık değeri
  _Menu^.NesneAdi := NesneAdiAl(gntMenu);
  _Menu^.Baslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_Menu^.GorevKimlik]^.OlayEkle1(_Menu^.GorevKimlik, _Menu,
    CO_OLUSTUR, 0, 0);

  // menüyü aktif masaüstüne bağla
  GAktifMasaustu^.FBaslatmaMenusu := _Menu;

  // nesne adresini geri döndür
  Result := _Menu;
end;

{==============================================================================
  nesne ve nesneye ayrılan kaynakları yok eder
 ==============================================================================}
procedure TMenu.YokEt(AKimlik: TKimlik);
var
  _Menu: PMenu;
begin

  // nesnenin Kimlik, tip değerlerini denetle.
  _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(AKimlik, gntMenu));
  if(_Menu = nil) then Exit;

  if(_Menu^.FMenuElemanBaslik <> nil) then _Menu^.FMenuElemanBaslik^.YokEt;
  if(_Menu^.FMenuElemanResim <> nil) then _Menu^.FMenuElemanResim^.YokEt;

  YokEt0;
end;

{==============================================================================
  menü nesnesini görüntüler
 ==============================================================================}
procedure TMenu.Goster;
var
  _Menu: PMenu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(Kimlik, gntMenu));
  if(_Menu = nil) then Exit;

  // nesnenin görünürlüğünü aktifleştir
  _Menu^.Gorunum := True;

  // daha önceden seçilmiş index değerini kaldır
  _Menu^.FSeciliSiraNo := -1;
end;

{==============================================================================
  menü nesnesini gizler
 ==============================================================================}
procedure TMenu.Gizle;
var
  _Menu: PMenu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(Kimlik, gntMenu));
  if(_Menu = nil) then Exit;

  // nesnenin görünürlüğünü pasifleştir
  _Menu^.Gorunum := False;
end;

{==============================================================================
  menü nesnesini çizer
 ==============================================================================}
procedure TMenu.Ciz;
var
  _Menu: PMenu;
  _YL: PYaziListesi;
  _SL: PSayiListesi;
  _Alan: TAlan;
  _SiraNo, _A1, _B1,
  _MenudekiElemanSayisi: TISayi4;
  s: string;
begin

  _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(Kimlik, gntMenu));
  if(_Menu = nil) then Exit;

  // menünün üst nesneye bağlı olarak koordinatlarını al
  _Alan := _Menu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // dış kenarlık
  Dikdortgen(_Menu, _Alan.A1, _Alan.B1, _Alan.A2, _Alan.B2, $97D5DB);

  // iç dolgu rengi
  DikdortgenDoldur(_Menu, _Alan.A1 + 1, _Alan.B1 + 1, _Alan.A2 - 1, _Alan.B2 - 1,
    RENK_BEYAZ, RENK_BEYAZ);

  _YL := _Menu^.FMenuElemanBaslik;
  _SL := _Menu^.FMenuElemanResim;

  // nesnenin elemanı var mı ?
  if(_YL^.ElemanSayisi > 0) then
  begin

    // çizim / yazım için kullanılacak _A1 & _B1 koordinatları
    _A1 := _Alan.A1 + 30;   // 30 pixel soldan sağa doğru. menü resimleri için
    _B1 := _Alan.B1 + 08;   // 08 = dikey ortalama için

    // menü kutusunda görüntülenecek eleman sayısı
    if(_YL^.ElemanSayisi > _Menu^.FMenuElemanBaslik^.ElemanSayisi) then
      _MenudekiElemanSayisi := _Menu^.FMenuElemanBaslik^.ElemanSayisi + _Menu^.FIlkSiraNo
    else _MenudekiElemanSayisi := _YL^.ElemanSayisi + _Menu^.FIlkSiraNo;

    // menü içerisini elemanlarla doldurma işlemi
    for _SiraNo := _Menu^.FIlkSiraNo to _MenudekiElemanSayisi - 1 do
    begin

      // belirtilen elemanın karakter katar değerini al
      s := _YL^.Eleman[_SiraNo];

      // elemanın seçili olması durumunda seçili olduğunu belirt
      // belirtilen sıra seçili değilse sadece eleman değerini yaz
      if(_SiraNo = _Menu^.FSeciliSiraNo) then
      begin

        DikdortgenDoldur(_Menu, _A1, _B1 - 4, _A1 + _Menu^.FBoyutlar.A2 - 34, _B1 + 20,
          $60A3AE, $60A3AE);

        YaziYaz(_Menu, _A1 + 5, _B1, s, RENK_BEYAZ);
      end else YaziYaz(_Menu, _A1 + 5, _B1, s, RENK_SIYAH);

      // menü resmini çiz
      case _SiraNo of
        0: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        1: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        2: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        3: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        4: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        5: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        6: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        7: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        8: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
        9: KaynaktanResimCiz(_Menu, 4, _B1 - 4, _SL^.Eleman[_SiraNo]);
      end;

      // bir sonraki eleman...
      _B1 += _Menu^.FElemanYukseklik;
    end;
  end;
end;

{==============================================================================
  menü nesne olaylarını işler
 ==============================================================================}
procedure TMenu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Menu: PMenu;
begin

  _Menu := PMenu(_Menu^.NesneTipiniKontrolEt(AKimlik, gntMenu));
  if(_Menu = nil) then Exit;

  // sol mouse tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_Menu^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // mouse basım işleminin gerçekleştiği index numarası
      _Menu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _Menu^.FElemanYukseklik;

      // popupmenu'yü gizle
      _Menu^.Gorunum := False;

      // uygulamaya mesaj gönder
      GorevListesi[_Menu^.GorevKimlik]^.OlayEkle1(_Menu^.GorevKimlik,
        _Menu, FO_TIKLAMA, AOlay.Deger1, AOlay.Deger2);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // seçilen elemanın index numarasını belirle
    _Menu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div _Menu^.FElemanYukseklik;

    // uygulamaya mesaj gönder
    GorevListesi[_Menu^.GorevKimlik]^.OlayEkle1(_Menu^.GorevKimlik, _Menu,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
