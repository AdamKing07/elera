{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_menu.pas
  Dosya İşlevi: menü yönetim işlevlerini içerir

  Güncelleme Tarihi: 20/06/2020

 ==============================================================================}
{$mode objfpc}
unit gn_menu;

interface

uses gorselnesne, paylasim, gn_panel, n_yazilistesi, n_sayilistesi;

type
  PMenu = ^TMenu;
  TMenu = object(TPanel)
  public
    // menünün olay işlemesinden sonra olay değerlerini almak isteyen
    // nesne varsa bu değişkene atamasını gerçekleştirmesi gerekmeketdir.
    FMenuOlayGeriDonusAdresi: TOlaylariIsle;

    FMenuBaslikListesi: PYaziListesi;
    FMenuResimListesi: PSayiListesi;

    FElemanYukseklik,                     // her bir elemanın yüksekliği
    FSeciliSiraNo: TISayi4;               // seçili sıra no
    FIlkSiraNo: TISayi4;                  // ilk görünen elemanın sıra numarası

    FSecimRenk, FNormalYaziRenk,
    FSeciliYaziRenk: TRenk;
    function Olustur(AAtaNesne: PGorselNesne; AGNTip: TGNTip; ASol, AUst,
      AGenislik, AYukseklik, AElemanYukseklik: TISayi4; AKenarlikRengi, AGovdeRengi: TRenk): PMenu;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

function MenuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(ASol, AUst, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;

implementation

uses genel, temelgorselnesne, gn_islevler, sistemmesaj;

{==============================================================================
  menü kesme çağrılarını yönetir
 ==============================================================================}
function MenuCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Menu: PMenu;
  AElemanAdi: string;
  AResimSiraNo: TISayi4;
begin

  case AIslevNo of

    // nesne oluştur
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PISayi4(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);

    // menüyü görüntüle
    ISLEV_GOSTER:
    begin

      Menu := PMenu(Menu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntMenu));
      if(Menu <> nil) then Menu^.Goster;
    end;

    // menüyü gizle
    ISLEV_GIZLE:
    begin

      Menu := PMenu(Menu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntMenu));
      if(Menu <> nil) then Menu^.Gizle;
    end;

    // eleman ekle
    $0100:
    begin

      Menu := PMenu(Menu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntMenu));

      AElemanAdi := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi)^;
      AResimSiraNo := PISayi4(ADegiskenler + 08)^;

      if(Menu <> nil) then
      begin

        Menu^.FMenuBaslikListesi^.Ekle(AElemanAdi);
        Menu^.FMenuResimListesi^.Ekle(AResimSiraNo);
        Result := 1;
      end else Result := 0;
    end;

    // seçilen elemanın sıra değerini al
    $0200:
    begin

      Menu := PMenu(Menu^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntMenu));
      if(Menu <> nil) then Result := Menu^.FSeciliSiraNo
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  menü nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(ASol, AUst, AGenislik, AYukseklik, AElemanYukseklik: TISayi4): TKimlik;
var
  Menu: PMenu;
begin

  { TODO : GAktifMasaustu nesnesi ileride değiştirilerek nesnenin sahibi ata nesne olarak atanabilir }
  Menu := Menu^.Olustur(GAktifMasaustu, gntMenu, ASol, AUst, AGenislik, AYukseklik,
    AElemanYukseklik, RENK_GRI, RENK_BEYAZ);

  if(Menu = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := Menu^.Kimlik;
end;

{==============================================================================
  menü nesnesini oluşturur
 ==============================================================================}
function TMenu.Olustur(AAtaNesne: PGorselNesne; AGNTip: TGNTip; ASol, AUst,
  AGenislik, AYukseklik, AElemanYukseklik: TISayi4; AKenarlikRengi, AGovdeRengi: TRenk): PMenu;
var
  Menu: PMenu;
begin

  Menu := PMenu(inherited Olustur(ktTuvalNesne, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik, 2, AKenarlikRengi, AGovdeRengi, 0, ''));

  Menu^.NesneTipi := AGNTip;

  Menu^.Baslik := '';

  Menu^.FTuvalNesne := Menu;

  Menu^.AnaOlayCagriAdresi := @OlaylariIsle;
  Menu^.FMenuOlayGeriDonusAdresi := nil;

  Menu^.FSecimRenk := $7FB3D5;
  Menu^.FNormalYaziRenk := RENK_SIYAH;
  Menu^.FSeciliYaziRenk := RENK_BEYAZ;

  Menu^.FElemanYukseklik := AElemanYukseklik;

  Menu^.FCizimBaslangic.Sol := 0;
  Menu^.FCizimBaslangic.Ust := 0;

  // menü çizimi için bellekte yer ayır
  Menu^.FCizimBellekAdresi := GGercekBellek.Ayir(Menu^.FBoyut.Genislik *
    Menu^.FBoyut.Yukseklik * 4);
  if(Menu^.FCizimBellekAdresi = nil) then
  begin

    // hata olması durumunda nesneyi yok et ve işlevden çık
    Menu^.YokEt;
    Result := nil;
    Exit;
  end;

  Menu^.FMenuBaslikListesi := FMenuBaslikListesi^.Olustur;
  Menu^.FMenuResimListesi := FMenuResimListesi^.Olustur;

  // nesnenin kullanacağı diğer değerler
  Menu^.FIlkSiraNo := 0;
  Menu^.FSeciliSiraNo := -1;     // seçili sıra yok

  // menüde görüntülenecek eleman sayısı
  Menu^.FMenuBaslikListesi^.ElemanSayisi := (AYukseklik + (Menu^.FElemanYukseklik - 1)) div
    Menu^.FElemanYukseklik;

  // nesne adresini geri döndür
  Result := Menu;
end;

{==============================================================================
  nesne ve nesneye ayrılan kaynakları yok eder
 ==============================================================================}
procedure TMenu.YokEt;
var
  Menu: PMenu;
begin

  Menu := PMenu(Menu^.NesneAl(Kimlik));
  if(Menu = nil) then Exit;

  if(Menu^.FMenuBaslikListesi <> nil) then Menu^.FMenuBaslikListesi^.YokEt;
  if(Menu^.FMenuResimListesi <> nil) then Menu^.FMenuResimListesi^.YokEt;

  inherited YokEt;
end;

{==============================================================================
  menü nesnesini görüntüler
 ==============================================================================}
procedure TMenu.Goster;
var
  Menu: PMenu;
begin

  inherited Goster;

  Menu := PMenu(Menu^.NesneAl(Kimlik));
  if(Menu = nil) then Exit;

  GAktifMenu := Menu;

  // daha önceden seçilmiş index değerini kaldır
  Menu^.FSeciliSiraNo := -1;
end;

{==============================================================================
  menü nesnesini gizler
 ==============================================================================}
procedure TMenu.Gizle;
begin

  inherited Gizle;

  GAktifMenu := nil;
end;

{==============================================================================
  menü nesnesini boyutlandırır
 ==============================================================================}
procedure TMenu.Boyutlandir;
begin

end;

{==============================================================================
  menü nesnesini çizer
 ==============================================================================}
procedure TMenu.Ciz;
var
  Menu: PMenu;
  YL: PYaziListesi;
  SL: PSayiListesi;
  Alan: TAlan;
  SiraNo, Sol, Ust, Genislik,
  MenudekiElemanSayisi: TISayi4;
  ResimCiz: Boolean;
  s: string;
begin

  inherited Ciz;

  Menu := PMenu(Menu^.NesneAl(Kimlik));
  if(Menu = nil) then Exit;

  // menü nesnesinin çizim alan koordinatlarını al
  Alan := Menu^.FCizimAlan;

  YL := Menu^.FMenuBaslikListesi;
  SL := Menu^.FMenuResimListesi;

  // nesnenin elemanı var mı ?
  if(YL^.ElemanSayisi > 0) then
  begin

    // ElemanSayisi değerinin 0 olması resim kullanılmayacağını belirtir
    if(SL^.ElemanSayisi = 0) then
      ResimCiz := False
    else ResimCiz := True;

    // çizim / yazım için kullanılacak Sol & Ust koordinatları
    if(ResimCiz) then
    begin

      Sol := Alan.Sol + 30;         // 30 pixel soldan sağa doğru. menü resimleri için
      Genislik := Alan.Sag - 3;
    end
    else
    begin

      Sol := 3;
      Genislik := Alan.Sag - 3;
    end;
    Ust := Alan.Ust + 08;           // 08 = dikey ortalama için

    // menü kutusunda görüntülenecek eleman sayısı
    if(YL^.ElemanSayisi > Menu^.FMenuBaslikListesi^.ElemanSayisi) then
      MenudekiElemanSayisi := Menu^.FMenuBaslikListesi^.ElemanSayisi + Menu^.FIlkSiraNo
    else MenudekiElemanSayisi := YL^.ElemanSayisi + Menu^.FIlkSiraNo;

    // menü içerisini elemanlarla doldurma işlemi
    for SiraNo := Menu^.FIlkSiraNo to MenudekiElemanSayisi - 1 do
    begin

      // belirtilen elemanın karakter katar değerini al
      s := YL^.Eleman[SiraNo];

      // elemanın seçili olması durumunda seçili olduğunu belirt
      // belirtilen sıra seçili değilse sadece eleman değerini yaz
      if(SiraNo = Menu^.FSeciliSiraNo) then
      begin

        Menu^.DikdortgenDoldur(Menu, Sol, Ust - 4, Genislik, Ust + 20, $60A3AE, $60A3AE);

        Menu^.YaziYaz(Menu, Sol + 5, Ust, s, RENK_BEYAZ);
      end else Menu^.YaziYaz(Menu, Sol + 5, Ust, s, RENK_SIYAH);

      if(ResimCiz) then
      begin

        // menü resmini çiz
        case SiraNo of
          0: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          1: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          2: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          3: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          4: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          5: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          6: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          7: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          8: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
          9: KaynaktanResimCiz2(Menu, 4, Ust - 4, SL^.Eleman[SiraNo]);
        end;
      end;

      // bir sonraki eleman...
      Ust += Menu^.FElemanYukseklik;
    end;
  end;
end;

{==============================================================================
  menü nesne olaylarını işler
 ==============================================================================}
procedure TMenu.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Menu: PMenu;
begin

  Menu := PMenu(AGonderici);
  if(Menu = nil) then Exit;

  // sol fare tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Menu^.FareNesneOlayAlanindaMi(Menu)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(Menu);

      // fare basım işleminin gerçekleştiği menü sıra numarası
      Menu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div Menu^.FElemanYukseklik;

      // menüyü gizle
      Menu^.Gorunum := False;

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Menu^.FMenuOlayGeriDonusAdresi = nil) then
        Menu^.FMenuOlayGeriDonusAdresi(Menu, AOlay)
      else GorevListesi[Menu^.GorevKimlik]^.OlayEkle(Menu^.GorevKimlik, AOlay);
    end;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(Menu);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // seçilen elemanın index numarasını belirle
    Menu^.FSeciliSiraNo := (AOlay.Deger2 - 4) div Menu^.FElemanYukseklik;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Menu^.FFareImlecTipi;
end;

end.
