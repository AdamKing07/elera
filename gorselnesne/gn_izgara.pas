{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_izgara.pas
  Dosya İşlevi: ızgara nesnesi (TStringGrid) yönetim işlevlerini içerir

  Güncelleme Tarihi: 24/06/2020

 ==============================================================================}
{$mode objfpc}
unit gn_izgara;

interface

uses gorselnesne, paylasim, n_yazilistesi, gn_panel, gn_kaydirmacubugu;

type
  PIzgara = ^TIzgara;
  TIzgara = object(TPanel)
  private
    FYatayKCubugu, FDikeyKCubugu: PKaydirmaCubugu;
    FYatayKCGoster, FDikeyKCGoster: Boolean;
    FSabitSutunSayisi, FSabitSatirSayisi: TSayi4;
    FSutunSayisi, FSatirSayisi,
    FSutunGenislik, FSatirYukseklik: TISayi4;
    FSeciliSatir, FSeciliSutun: TISayi4;  // seçili satır ve sütun
    FGorunenIlkSiraNo: TISayi4;           // ızgara nesnesinde en üstte görüntülenen elemanın sıra değeri
    FGorunenElemanSayisi: TISayi4;        // kullanıcıya nesne içerisinde gösterilen eleman sayısı
    FDegerler: PYaziListesi;              // kolon değerleri
    procedure KaydirmaCubuguOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4): PIzgara;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    function SeciliSatirDegeriniAl: string;
    procedure Bolumle(ABicimlenmisDeger: string; AAyiracDeger: Char;
      ADegerDizisi: PYaziListesi);
    function DegerEkle(ADeger: string): Boolean;
    procedure DegerIceriginiTemizle;
    procedure HucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4);
    procedure SabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4);
    procedure HucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4);
    procedure KaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: Boolean);
    procedure SeciliHucreyiYaz(ASatir, ASutun: TISayi4);
  end;

function IzgaraCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_islevler, gn_pencere, temelgorselnesne, donusum, sistemmesaj;

{==============================================================================
  ızgara nesnesi kesme çağrılarını yönetir
 ==============================================================================}
function IzgaraCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  Izgara: PIzgara;
  Hiza: THiza;
begin

  case AIslevNo of

    // nesne oluştur
    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);
    end;

    ISLEV_GOSTER:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Izgara^.Goster;
    end;

    ISLEV_GIZLE:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Izgara^.Gizle;
    end;

    ISLEV_CIZ:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Izgara^.Ciz;
    end;

    // görsel nesneyi hizala
    $0104:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      Izgara^.FHiza := Hiza;

      Pencere := PPencere(Izgara^.FAtaNesne);
      Pencere^.Guncelle;
    end;

    // değer içeriklerini temizle
    $0204:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.DegerIceriginiTemizle;
    end;

    // değer listesine değer ekle
    $0304:
    begin

      Izgara := PIzgara(Izgara^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(Izgara <> nil) then Result := TISayi4(Izgara^.DegerEkle(
        PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^));
    end;

    // sabit satır ve sutun hücre sayısını belirle
    $0404:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.SabitHucreSayisiYaz(
        PSayi4(ADegiskenler + 04)^, PSayi4(ADegiskenler + 08)^);
    end;

    // hücre sayısını belirle
    $0504:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.HucreSayisiYaz(
        PSayi4(ADegiskenler + 04)^, PSayi4(ADegiskenler + 08)^);
    end;

    // hücre boyutu belirle
    $0604:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.HucreBoyutuYaz(
        PSayi4(ADegiskenler + 04)^, PSayi4(ADegiskenler + 08)^);
    end;

    // kaydırma çubuğu görünüm belirle
    $0704:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.KaydirmaCubuguGorunumYaz(
        PLongBool(ADegiskenler + 04)^, PLongBool(ADegiskenler + 08)^);
    end;

    // seçili hücreyi belirle
    $0804:
    begin

      Izgara := PIzgara(Izgara^.NesneAl(PKimlik(ADegiskenler + 00)^));
      if(Izgara <> nil) then Izgara^.SeciliHucreyiYaz(
        PSayi4(ADegiskenler + 04)^, PSayi4(ADegiskenler + 08)^);
    end;

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  ızgara nesnesi oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  Izgara: PIzgara = nil;
begin

  Izgara := Izgara^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik);
  if(Izgara = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := Izgara^.Kimlik;
end;

{==============================================================================
  ızgara nesnesi oluşturur
 ==============================================================================}
function TIzgara.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PIzgara;
var
  Izgara: PIzgara = nil;
  i: TSayi4;
begin

  Izgara := PIzgara(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik, 2, RENK_GRI, RENK_GRI, 0, ''));

  Izgara^.NesneTipi := gntIzgara;

  Izgara^.Baslik := '';

  Izgara^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  Izgara^.OlayCagriAdresi := @OlaylariIsle;

  Izgara^.FYatayKCGoster := False;
  Izgara^.FDikeyKCGoster := False;

  // yatay kaydırma çubuğu
  Izgara^.FYatayKCubugu := Izgara^.FYatayKCubugu^.Olustur(ktBilesen, Izgara,
    0, AYukseklik - 16, AGenislik - 16, 16, yYatay);
  Izgara^.FYatayKCubugu^.DegerleriBelirle(0, 10);
  Izgara^.FYatayKCubugu^.OlayYonlendirmeAdresi := @KaydirmaCubuguOlaylariniIsle;

  // dikey kaydırma çubuğu
  Izgara^.FDikeyKCubugu := Izgara^.FDikeyKCubugu^.Olustur(ktBilesen, Izgara,
    AGenislik - 16, 0, 16, AYukseklik - 16, yDikey);
  Izgara^.FDikeyKCubugu^.DegerleriBelirle(0, 10);
  Izgara^.FDikeyKCubugu^.OlayYonlendirmeAdresi := @KaydirmaCubuguOlaylariniIsle;

  Izgara^.FDegerler := Izgara^.FDegerler^.Olustur;

  // nesnenin kullanacağı diğer değerler
  Izgara^.FGorunenIlkSiraNo := 0;
  Izgara^.FSeciliSatir := -1;
  Izgara^.FSeciliSutun := -1;

  // ızgara nesnesinde görüntülenecek eleman sayısı
  Izgara^.FGorunenElemanSayisi := (AYukseklik - 24) div 21;

  Izgara^.FSabitSatirSayisi := 1;
  Izgara^.FSabitSutunSayisi := 0;
  Izgara^.FSatirSayisi := 7;
  Izgara^.FSutunSayisi := 7;
  Izgara^.FSatirYukseklik := 18;
  Izgara^.FSutunGenislik := 40;

  // nesne adresini geri döndür
  Result := Izgara;
end;

{==============================================================================
  ızgara nesnesini yok eder
 ==============================================================================}
procedure TIzgara.YokEt;
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  if(Izgara^.FDegerler <> nil) then Izgara^.FDegerler^.YokEt;

  inherited YokEt;
end;

{==============================================================================
  ızgara nesnesini görüntüler
 ==============================================================================}
procedure TIzgara.Goster;
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  if(Izgara^.FYatayKCGoster) then Izgara^.FYatayKCubugu^.Goster;
  if(Izgara^.FDikeyKCGoster) then Izgara^.FDikeyKCubugu^.Goster;

  inherited Goster;
end;

{==============================================================================
  ızgara nesnesini gizler
 ==============================================================================}
procedure TIzgara.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  ızgara nesnesini boyutlandırır
 ==============================================================================}
procedure TIzgara.Boyutlandir;
var
  Izgara: PIzgara;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.Hizala;

  if(Izgara^.FYatayKCGoster) then
  begin

    // yatay kaydırma çubuğunu elle yeniden konumlandır
    Izgara^.FYatayKCubugu^.FKonum.Sol := 0;
    Izgara^.FYatayKCubugu^.FKonum.Ust := Izgara^.FBoyut.Yukseklik - 16;
    Izgara^.FYatayKCubugu^.FBoyut.Genislik := Izgara^.FBoyut.Genislik - 16;
    Izgara^.FYatayKCubugu^.FBoyut.Yukseklik := 16;

    Izgara^.FYatayKCubugu^.FCizimAlan.Sol := 0;
    Izgara^.FYatayKCubugu^.FCizimAlan.Ust := 0;
    Izgara^.FYatayKCubugu^.FCizimAlan.Sag := Izgara^.FYatayKCubugu^.FBoyut.Genislik - 1;
    Izgara^.FYatayKCubugu^.FCizimAlan.Alt := Izgara^.FYatayKCubugu^.FBoyut.Yukseklik - 1;

    Izgara^.FYatayKCubugu^.FCizimBaslangic.Sol := Izgara^.FCizimBaslangic.Sol + Izgara^.FYatayKCubugu^.FKonum.Sol;
    Izgara^.FYatayKCubugu^.FCizimBaslangic.Ust := Izgara^.FCizimBaslangic.Ust + Izgara^.FYatayKCubugu^.FKonum.Ust;
    Izgara^.FYatayKCubugu^.Boyutlandir;
  end;

  if(Izgara^.FDikeyKCGoster) then
  begin

    // dikey kaydırma çubuğunu elle yeniden konumlandır
    Izgara^.FDikeyKCubugu^.FKonum.Sol := Izgara^.FBoyut.Genislik - 16;
    Izgara^.FDikeyKCubugu^.FKonum.Ust := 0;
    Izgara^.FDikeyKCubugu^.FBoyut.Genislik := 16;
    Izgara^.FDikeyKCubugu^.FBoyut.Yukseklik := Izgara^.FBoyut.Yukseklik - 16;

    Izgara^.FDikeyKCubugu^.FCizimAlan.Sol := 0;
    Izgara^.FDikeyKCubugu^.FCizimAlan.Ust := 0;
    Izgara^.FDikeyKCubugu^.FCizimAlan.Sag := Izgara^.FDikeyKCubugu^.FBoyut.Genislik - 1;
    Izgara^.FDikeyKCubugu^.FCizimAlan.Alt := Izgara^.FDikeyKCubugu^.FBoyut.Yukseklik - 1;

    Izgara^.FDikeyKCubugu^.FCizimBaslangic.Sol := Izgara^.FCizimBaslangic.Sol + Izgara^.FDikeyKCubugu^.FKonum.Sol;
    Izgara^.FDikeyKCubugu^.FCizimBaslangic.Ust := Izgara^.FCizimBaslangic.Ust + Izgara^.FDikeyKCubugu^.FKonum.Ust;
    Izgara^.FDikeyKCubugu^.Boyutlandir;
  end;
end;

{==============================================================================
  ızgara nesnesini çizer
 ==============================================================================}
procedure TIzgara.Ciz;
var
  Pencere: PPencere;
  Izgara: PIzgara;
  Alan1, Alan2: TAlan;
  i, j, Sol, Sol2, Ust, Ust2,
  G, Y, SolIlk, UstIlk, UstBaslangic2: TISayi4;
  SolBaslangic2: Integer;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  inherited Ciz;

  // liste kutusunun üst nesneye bağlı olarak koordinatlarını al
  Alan1 := Izgara^.FCizimAlan;

  // ata nesne bir pencere mi?
  Pencere := EnUstPencereNesnesiniAl(Izgara);
  if(Pencere = nil) then Exit;

  // tanımlanmış hiçbir kolon yok ise, çık
  if(FDegerler^.ElemanSayisi = 0) then Exit;

  // yatay üst kolonların çizilmesi
  Sol := Alan1.Sol + 1;
  Ust := Alan1.Ust + 1;

  if(Izgara^.FYatayKCGoster) then
    SolIlk := Izgara^.FYatayKCubugu^.FMevcutDeger
  else SolIlk := 0;

  if(Izgara^.FDikeyKCGoster) then
    UstIlk := Izgara^.FDikeyKCubugu^.FMevcutDeger
  else UstIlk := 0;

  G := Alan1.Sol + 1 + ((FSutunSayisi - SolIlk) * (FSutunGenislik + 1)) - 1;
  Y := Alan1.Ust + 1 + ((FSatirSayisi - UstIlk) * (FSatirYukseklik + 1)) - 1;

  Alan2.Sol := 1;
  Alan2.Ust := 1;

  // veriye göre yapılan döngü
  for i := UstIlk to FSatirSayisi - 1 do
  begin

    for j := SolIlk to FSutunSayisi - 1 do
    begin

      Alan2.Sag := Alan2.Sol + Izgara^.FSutunGenislik - 1;
      Alan2.Alt := Alan2.Ust + Izgara^.FSatirYukseklik - 1;

      if(i < Izgara^.FSabitSatirSayisi) then
        Izgara^.EgimliDoldur3(Izgara, Alan2, $EAECEE, $ABB2B9)
      else if(j < Izgara^.FSabitSutunSayisi) then
        Izgara^.EgimliDoldur3(Izgara, Alan2, $EAECEE, $ABB2B9)

      else if(Izgara^.FSeciliSatir = i) and (Izgara^.FSeciliSutun = j) then
        Izgara^.DikdortgenDoldur(Izgara, Alan2, RENK_KIRMIZI, RENK_BEYAZ)
      else Izgara^.DikdortgenDoldur(Izgara, Alan2, RENK_BEYAZ, RENK_BEYAZ);

      // başlık
      Izgara^.AlanaYaziYaz(Izgara, Alan2, 4, 3, FDegerler^.Eleman[(i * (Izgara^.FSutunSayisi)) + j],
        RENK_LACIVERT);

      Alan2.Sol += Izgara^.FSutunGenislik + 1;
    end;

    Alan2.Sol := 1;
    Alan2.Ust += Izgara^.FSatirYukseklik + 1;
  end;

  // kaydırma çubuklarını en son çiz
  if(Izgara^.FYatayKCGoster) then Izgara^.FYatayKCubugu^.Ciz;
  if(Izgara^.FDikeyKCGoster) then Izgara^.FDikeyKCubugu^.Ciz;
end;

{==============================================================================
  ızgara nesnesi olaylarını işler
 ==============================================================================}
procedure TIzgara.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere = nil;
  Izgara: PIzgara = nil;
  i, j: TISayi4;
begin

  Izgara := PIzgara(AGonderici);

  // sol fare tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // ızgara nesnesinin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(Izgara);

    // en üstte olmaması durumunda en üste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Izgara^.FareNesneOlayAlanindaMi(Izgara)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(Izgara);

      // seçili sütün ve satır değerini yeniden belirle
      i := (AOlay.Deger1 + (Izgara^.FYatayKCubugu^.FMevcutDeger * Izgara^.FSutunGenislik)) div Izgara^.FSutunGenislik;
      j := (AOlay.Deger2 + (Izgara^.FDikeyKCubugu^.FMevcutDeger * Izgara^.FSatirYukseklik)) div Izgara^.FSatirYukseklik;
      if(i > 0) and (j > 0) then
      begin

        Izgara^.FSeciliSutun := i;
        Izgara^.FSeciliSatir := j;
      end;

      //SISTEM_MESAJ('DegerListesi^.FSeciliSutun: %d', [Izgara^.FSeciliSutun]);
      //SISTEM_MESAJ('DegerListesi^.FSeciliSatir: %d', [Izgara^.FSeciliSatir]);

      // ızgara nesnesini yeniden çiz
      Izgara^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(Izgara^.OlayYonlendirmeAdresi = nil) then
        Izgara^.OlayYonlendirmeAdresi(Izgara, AOlay)
      else GorevListesi[Izgara^.GorevKimlik]^.OlayEkle(Izgara^.GorevKimlik, AOlay);
    end;
  end

  // sol fare tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(Izgara);

    // fare bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Izgara^.FareNesneOlayAlanindaMi(Izgara)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Izgara^.OlayYonlendirmeAdresi = nil) then
        Izgara^.OlayYonlendirmeAdresi(Izgara, AOlay)
      else GorevListesi[Izgara^.GorevKimlik]^.OlayEkle(Izgara^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(Izgara^.OlayYonlendirmeAdresi = nil) then
      Izgara^.OlayYonlendirmeAdresi(Izgara, AOlay)
    else GorevListesi[Izgara^.GorevKimlik]^.OlayEkle(Izgara^.GorevKimlik, AOlay);
  end

  // fare hakeret işlemi
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ise
    if(YakalananGorselNesne <> nil) then
    begin

      // fare ızgara nesnesinin yukarısında ise
      if(AOlay.Deger2 < 0) then
      begin

        j := Izgara^.FGorunenIlkSiraNo;
        Dec(j);
        if(j >= 0) then
        begin

          Izgara^.FGorunenIlkSiraNo := j;
          Izgara^.FSeciliSutun := j;
        end;
      end

      // fare ızgara nesnesinin aşağısında ise
      else if(AOlay.Deger2 > Izgara^.FBoyut.Yukseklik) then
      begin

        // azami kaydırma değeri
        {i := Izgara^.FKolonAdlari^.ElemanSayisi - Izgara^.FGorunenElemanSayisi;
        if(i < 0) then i := 0;

        j := Izgara^.FGorunenIlkSiraNo;
        Inc(j);
        if(j < i) then
        begin

          Izgara^.FGorunenIlkSiraNo := j;
          i := (AOlay.Deger2 - 24) div 21;
          Izgara^.FSeciliSutun := i + Izgara^.FGorunenIlkSiraNo;
        end}
      end

      // fare ızgara nesnesinin içerisinde ise
      else
      begin

        i := (AOlay.Deger2 - 24) div 21;
        Izgara^.FSeciliSutun := i + Izgara^.FGorunenIlkSiraNo;
      end;

      // ızgara nesnesini yeniden çiz
      Izgara^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(Izgara^.OlayYonlendirmeAdresi = nil) then
        Izgara^.OlayYonlendirmeAdresi(Izgara, AOlay)
      else GorevListesi[Izgara^.GorevKimlik]^.OlayEkle(Izgara^.GorevKimlik, AOlay);
    end

    // nesne yakalanmamış ise uygulamaya sadece mesaj gönder
    else
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(Izgara^.OlayYonlendirmeAdresi = nil) then
        Izgara^.OlayYonlendirmeAdresi(Izgara, AOlay)
      else GorevListesi[Izgara^.GorevKimlik]^.OlayEkle(Izgara^.GorevKimlik, AOlay);
    end;
  end

  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukarı kaydırma işlemi. ilk elemana doğru
    if(AOlay.Deger1 < 0) then
    begin

      j := Izgara^.FGorunenIlkSiraNo;
      Dec(j);
      if(j >= 0) then Izgara^.FGorunenIlkSiraNo := j;
    end

    // listeyi aşağıya kaydırma işlemi. son elemana doğru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kaydırma değeri
      i := Izgara^.FDegerler^.ElemanSayisi - Izgara^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      j := Izgara^.FGorunenIlkSiraNo;
      Inc(j);
      if(j < i) then Izgara^.FGorunenIlkSiraNo := j;
    end;

    Izgara^.Ciz;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Izgara^.FFareImlecTipi;
end;

procedure TIzgara.KaydirmaCubuguOlaylariniIsle(AGonderici: PGorselNesne;
  AOlay: TOlay);
var
  Izgara: PIzgara;
  KaydirmaCubugu: PKaydirmaCubugu;
begin

  KaydirmaCubugu := PKaydirmaCubugu(AGonderici);
  if(KaydirmaCubugu = nil) then Exit;

  Izgara := PIzgara(KaydirmaCubugu^.AtaNesne);

  if(AOlay.Olay = FO_TIKLAMA) then Izgara^.Ciz;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Izgara^.FFareImlecTipi;
end;

procedure TIzgara.HucreSayisiYaz(ASatirSayisi, ASutunSayisi: TSayi4);
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSatirSayisi := ASatirSayisi;
  Izgara^.FSutunSayisi := ASutunSayisi;
end;

procedure TIzgara.HucreBoyutuYaz(ASatirYukseklik, ASutunGenislik: TSayi4);
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSatirYukseklik := ASatirYukseklik;
  Izgara^.FSutunGenislik := ASutunGenislik;
end;

procedure TIzgara.SabitHucreSayisiYaz(ASabitSatirSayisi, ASabitSutunSayisi: TSayi4);
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSabitSatirSayisi := ASabitSatirSayisi;
  Izgara^.FSabitSutunSayisi := ASabitSutunSayisi;
end;

procedure TIzgara.KaydirmaCubuguGorunumYaz(AYatayKCGoster, ADikeyKCGoster: Boolean);
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FYatayKCGoster := AYatayKCGoster;
  Izgara^.FDikeyKCGoster := ADikeyKCGoster;
end;

procedure TIzgara.SeciliHucreyiYaz(ASatir, ASutun: TISayi4);
var
  Izgara: PIzgara = nil;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSeciliSatir := ASatir;
  Izgara^.FSeciliSutun := ASutun;
end;

{==============================================================================
  seçili elemanın yazı (text) değerini geri döndürür
 ==============================================================================}
function TIzgara.SeciliSatirDegeriniAl: string;
var
  Izgara: PIzgara = nil;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Izgara := PIzgara(Izgara^.NesneTipiniKontrolEt(Kimlik, gntIzgara));
  if(Izgara = nil) then Exit;

  if(FSeciliSutun = -1) or (FSeciliSutun > FDegerler^.ElemanSayisi) then Exit('');

  Result := Izgara^.FDegerler^.Eleman[FSeciliSutun];
end;

{==============================================================================
  | ayıracıyla gelen karakter katarını bölümler
 ==============================================================================}
procedure TIzgara.Bolumle(ABicimlenmisDeger: string; AAyiracDeger: Char;
  ADegerDizisi: PYaziListesi);
var
  Uzunluk, i: TISayi4;
  s: string;
begin

  ADegerDizisi^.Temizle;

  Uzunluk := Length(ABicimlenmisDeger);
  if(Uzunluk > 0) then
  begin

    i := 1;
    s := '';
    while i <= Uzunluk do
    begin

      if(ABicimlenmisDeger[i] = AAyiracDeger) or (i = Uzunluk) then
      begin

        if(i = Uzunluk) then s += ABicimlenmisDeger[i];

        if(Length(s) > 0) then
        begin

          ADegerDizisi^.Ekle(s);
          s := '';
        end;
      end else s += ABicimlenmisDeger[i];

      Inc(i);
    end;
  end;
end;

function TIzgara.DegerEkle(ADeger: string): Boolean;
var
  Izgara: PIzgara = nil;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FDegerler^.Ekle(ADeger);

  Result := True;
end;

procedure TIzgara.DegerIceriginiTemizle;
var
  Izgara: PIzgara = nil;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FDegerler^.Temizle;
  Izgara^.FGorunenIlkSiraNo := 0;
  Izgara^.FSeciliSutun := -1;

  Izgara^.Ciz;
end;

end.
