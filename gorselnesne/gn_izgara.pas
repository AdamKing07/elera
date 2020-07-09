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

uses gorselnesne, paylasim, n_yazilistesi, n_sayilistesi, gn_panel, gn_kaydirmacubugu;

type
  PIzgara = ^TIzgara;

  { TIzgara }

  TIzgara = object(TPanel)
  private
    FYatayKCubugu, FDikeyKCubugu: PKaydirmaCubugu;
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
      DegerDizisi: PYaziListesi);
    function DegerEkle(ADeger: string): Boolean;
    procedure DegerIceriginiTemizle;
    procedure HucreSayisiBelirle(ASatirSayisi, ASutunSayisi: TSayi4);
    procedure HucreBoyutuBelirle(ASutunGenislik, ASatirYukseklik: TSayi4);
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
  DegerListesi: PIzgara;
  Hiza: THiza;
  p: PKarakterKatari;
  Kolon1Ad, Kolon2Ad: string;
  KolonU: TISayi4;
begin

  case AIslevNo of

    // nesne oluştur
    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^);
    end;

    // değer listesine değer ekle
    $0100:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then Result := TISayi4(DegerListesi^.DegerEkle(
        PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^));
    end;

    // seçilen sıra değerini al
    {$0200:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then Result := DegerListesi^.FSeciliSutun;
    end;}

    // liste içeriğini temizle
    $0300:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then
      begin

        // içeriği temizle, değerleri ön değerlere çek
        DegerListesi^.DegerIceriginiTemizle;
      end;
    end;

    // seçilen yazı (text) değerini geri döndür
    $0400:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then Result := DegerListesi^.FSeciliSutun;
      p := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
      p^ := DegerListesi^.SeciliSatirDegeriniAl;
    end;

    // liste görüntüleyicisinin başlıklarını sil
    $0500:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then
      begin

        //DegerListesi^.FKolonAdlari^.Temizle;
        //DegerListesi^.FKolonUzunluklari^.Temizle;
        Result := 1;
      end;
    end;

    // liste görüntüleyicisine kolon ekle
    $0600:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then
      begin

        Kolon1Ad := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^;
        Kolon2Ad := PKarakterKatari(PSayi4(ADegiskenler + 08)^ + CalisanGorevBellekAdresi)^;
        KolonU := PISayi4(ADegiskenler + 12)^;
        //Result := TISayi4(DegerListesi^.BaslikEkle(Kolon1Ad, Kolon2Ad, KolonU));
      end;
    end;

    // değer listesi nesnesini hizala
    $0104:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      DegerListesi^.FHiza := Hiza;

      Pencere := PPencere(DegerListesi^.FAtaNesne);
      Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  ızgara nesnesi oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  DegerListesi: PIzgara;
begin

  DegerListesi := DegerListesi^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik);
  if(DegerListesi = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := DegerListesi^.Kimlik;
end;

{==============================================================================
  ızgara nesnesi oluşturur
 ==============================================================================}
function TIzgara.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4): PIzgara;
var
  DegerListesi: PIzgara;
  i: TSayi4;
begin

  DegerListesi := PIzgara(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik, 2, RENK_BEYAZ, RENK_BEYAZ, 0, ''));

  DegerListesi^.NesneTipi := gntIzgara;

  DegerListesi^.Baslik := '';

  DegerListesi^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  DegerListesi^.AnaOlayCagriAdresi := @OlaylariIsle;

  // yatay kaydırma çubuğu
  DegerListesi^.FYatayKCubugu := DegerListesi^.FYatayKCubugu^.Olustur(ktBilesen, DegerListesi,
    0, AYukseklik - 16, AGenislik - 16, 16, yYatay);
  DegerListesi^.FYatayKCubugu^.DegerleriBelirle(0, 10);
  DegerListesi^.FYatayKCubugu^.FKCOlayGeriDonusumAdresi := @KaydirmaCubuguOlaylariniIsle;

  // dikey kaydırma çubuğu
  DegerListesi^.FDikeyKCubugu := DegerListesi^.FDikeyKCubugu^.Olustur(ktBilesen, DegerListesi,
    AGenislik - 16, 0, 16, AYukseklik - 16, yDikey);
  DegerListesi^.FDikeyKCubugu^.DegerleriBelirle(0, 10);
  DegerListesi^.FDikeyKCubugu^.FKCOlayGeriDonusumAdresi := @KaydirmaCubuguOlaylariniIsle;

  DegerListesi^.FDegerler := DegerListesi^.FDegerler^.Olustur;

  // nesnenin kullanacağı diğer değerler
  DegerListesi^.FGorunenIlkSiraNo := 0;
  DegerListesi^.FSeciliSatir := -1;
  DegerListesi^.FSeciliSutun := -1;

  // ızgara nesnesinde görüntülenecek eleman sayısı
  DegerListesi^.FGorunenElemanSayisi := (AYukseklik - 24) div 21;

  DegerListesi^.FSutunSayisi := 0;
  DegerListesi^.FSatirSayisi := 0;
  DegerListesi^.FSutunGenislik := 30;
  DegerListesi^.FSatirYukseklik := 24;

  // nesne adresini geri döndür
  Result := DegerListesi;
end;

{==============================================================================
  ızgara nesnesini yok eder
 ==============================================================================}
procedure TIzgara.YokEt;
var
  DegerListesi: PIzgara;
begin

  DegerListesi := PIzgara(DegerListesi^.NesneAl(Kimlik));
  if(DegerListesi = nil) then Exit;

  if(DegerListesi^.FDegerler <> nil) then DegerListesi^.FDegerler^.YokEt;

  inherited YokEt;
end;

{==============================================================================
  ızgara nesnesini görüntüler
 ==============================================================================}
procedure TIzgara.Goster;
var
  Izgara: PIzgara;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FYatayKCubugu^.Goster;
  Izgara^.FDikeyKCubugu^.Goster;

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

  SolIlk := Izgara^.FYatayKCubugu^.FMevcutDeger;
  UstIlk := Izgara^.FDikeyKCubugu^.FMevcutDeger;

  G := Alan1.Sol + 1 + ((FSutunSayisi - SolIlk) * (FSutunGenislik + 1)) - 1;
  Y := Alan1.Ust + 1 + ((FSatirSayisi - UstIlk) * (FSatirYukseklik + 1)) - 1;

  if(UstIlk = 0) then
  begin

    for i := SolIlk to FSutunSayisi - 1 do
    begin

      // kolon içeriğinin boyanması
      Alan2.Sol := Sol;
      Alan2.Ust := Ust;
      Alan2.Sag := Sol + Izgara^.FSutunGenislik;
      Alan2.Alt := Ust + Izgara^.FSatirYukseklik;
      Izgara^.EgimliDoldur3(Izgara, Alan2, $EAECEE, $ABB2B9);

      // kolon içerik değerleri
      Izgara^.AlanaYaziYaz(Izgara, Alan2, 4, 3, FDegerler^.Eleman[i], RENK_LACIVERT);

      Sol += Izgara^.FSutunGenislik;      // 1 px çizgi kalınlığı

      // dikey kılavuz çizgisi
      Izgara^.Cizgi(Izgara, ctDuz, Sol, Ust, Sol, Y, $F0F0F0);

      Sol += 1;
    end;
  end
  else
  begin

    for i := SolIlk to FSutunSayisi - 1 do
    begin

      Sol += Izgara^.FSutunGenislik;      // 1 px çizgi kalınlığı

      // dikey kılavuz çizgisi
      Izgara^.Cizgi(Izgara, ctDuz, Sol, Ust, Sol, Y, $F0F0F0);

      Sol += 1;
    end;
  end;

  // dikey üst kolonların çizilmesi
  Sol := Alan1.Sol + 1;

  // ilk çizim başlangıç noktası
  if(UstIlk = 0) then
    Ust := Alan1.Ust + 1 + Izgara^.FSatirYukseklik
  else Ust := Alan1.Ust; // + 1;

  if(SolIlk = 0) then
  begin

    // ilk çizim başlangıç noktası
    if(UstIlk = 0) then Izgara^.Cizgi(Izgara, ctDuz, Sol, Ust, G, Ust, $F0F0F0);

    for i := UstIlk to FSatirSayisi - 1 do
    begin

      if(i > 0) then
      begin

        Ust += 1;

        // başlık dolgusu
        Alan2.Sol := Sol;
        Alan2.Ust := Ust;
        Alan2.Sag := Alan1.Sol + Izgara^.FSutunGenislik;
        Alan2.Alt := Ust + Izgara^.FSatirYukseklik;
        Izgara^.EgimliDoldur3(Izgara, Alan2, $EAECEE, $ABB2B9);

        // başlık
        Izgara^.AlanaYaziYaz(Izgara, Alan2, 4, 3, FDegerler^.Eleman[i *
          (Izgara^.FSutunSayisi)], RENK_LACIVERT);

        Ust += Izgara^.FSatirYukseklik;

        // yatay kılavuz çizgisi
        Izgara^.Cizgi(Izgara, ctDuz, Sol, Ust, G, Ust, $F0F0F0);
      end;
    end;
  end
  else
  begin

    for i := UstIlk to FSatirSayisi - 1 do
    begin

      // yatay kılavuz çizgisi
      Izgara^.Cizgi(Izgara, ctDuz, Sol, Ust, G, Ust, $F0F0F0);

      Ust += Izgara^.FSatirYukseklik + 1;
    end;
  end;

  // yatay & dikey değerlerin yazılması
  if(SolIlk = 0) then
    Sol := Alan1.Sol + 1 + Izgara^.FSutunGenislik + 1
  else Sol := Alan1.Sol + 1;

  if(UstIlk = 0) then
    Ust := Alan1.Ust + 1 + Izgara^.FSatirYukseklik + 1
  else Ust := Alan1.Ust + 1;

  Sol2 := Sol;
  Ust2 := Ust;

  if(SolIlk = 0) then
    SolBaslangic2 := 1
  else SolBaslangic2 := SolIlk;

  if(UstIlk = 0) then
    UstBaslangic2 := 1
  else UstBaslangic2 := UstIlk;

  // veriye göre yapılan döngü
  for i := UstBaslangic2 to FSatirSayisi - 1 do
  begin

    for j := SolBaslangic2 to FSutunSayisi - 1 do
    begin

      // başlık dolgusu
      Alan2.Sol := Sol2;
      Alan2.Ust := Ust2;
      Alan2.Sag := Sol2 + Izgara^.FSutunGenislik - 1;
      Alan2.Alt := Ust2 + Izgara^.FSatirYukseklik - 1;

      if(Izgara^.FSeciliSatir = i) and (Izgara^.FSeciliSutun = j) then
        Izgara^.DikdortgenDoldur(Izgara, Alan2, RENK_KIRMIZI, RENK_BEYAZ)
      else Izgara^.DikdortgenDoldur(Izgara, Alan2, RENK_BEYAZ, RENK_BEYAZ);

      // başlık
      Izgara^.AlanaYaziYaz(Izgara, Alan2, 4, 3, FDegerler^.Eleman[(i * (Izgara^.FSutunSayisi)) + j],
        RENK_LACIVERT);

      Sol2 += Izgara^.FSutunGenislik + 1;
    end;

    Sol2 := Sol;

    Ust2 += Izgara^.FSatirYukseklik + 1;
  end;

  // kaydırma çubuklarını en son çiz
  Izgara^.FYatayKCubugu^.Ciz;
  Izgara^.FDikeyKCubugu^.Ciz;
end;

{==============================================================================
  ızgara nesnesi olaylarını işler
 ==============================================================================}
procedure TIzgara.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
  DegerListesi: PIzgara;
  i, j: TISayi4;
begin

  DegerListesi := PIzgara(AGonderici);

  // sol fare tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // ızgara nesnesinin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(DegerListesi);

    // en üstte olmaması durumunda en üste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // sol tuşa basım işlemi nesnenin olay alanında mı gerçekleşti ?
    if(DegerListesi^.FareNesneOlayAlanindaMi(DegerListesi)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(DegerListesi);

      // seçili sütün ve satır değerini yeniden belirle
      i := (AOlay.Deger1 + (DegerListesi^.FYatayKCubugu^.FMevcutDeger * DegerListesi^.FSutunGenislik)) div DegerListesi^.FSutunGenislik;
      j := (AOlay.Deger2 + (DegerListesi^.FDikeyKCubugu^.FMevcutDeger * DegerListesi^.FSatirYukseklik)) div DegerListesi^.FSatirYukseklik;
      if(i > 0) and (j > 0) then
      begin

        DegerListesi^.FSeciliSutun := i;
        DegerListesi^.FSeciliSatir := j;
      end;

      //SISTEM_MESAJ('DegerListesi^.FSeciliSutun: %d', [DegerListesi^.FSeciliSutun]);
      //SISTEM_MESAJ('DegerListesi^.FSeciliSatir: %d', [DegerListesi^.FSeciliSatir]);

      // ızgara nesnesini yeniden çiz
      DegerListesi^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(DegerListesi^.OlayCagriAdresi = nil) then
        DegerListesi^.OlayCagriAdresi(DegerListesi, AOlay)
      else GorevListesi[DegerListesi^.GorevKimlik]^.OlayEkle(DegerListesi^.GorevKimlik, AOlay);
    end;
  end

  // sol fare tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(DegerListesi);

    // fare bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(DegerListesi^.FareNesneOlayAlanindaMi(DegerListesi)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // nesneye FO_TIKLAMA mesajı gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(DegerListesi^.OlayCagriAdresi = nil) then
        DegerListesi^.OlayCagriAdresi(DegerListesi, AOlay)
      else GorevListesi[DegerListesi^.GorevKimlik]^.OlayEkle(DegerListesi^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(DegerListesi^.OlayCagriAdresi = nil) then
      DegerListesi^.OlayCagriAdresi(DegerListesi, AOlay)
    else GorevListesi[DegerListesi^.GorevKimlik]^.OlayEkle(DegerListesi^.GorevKimlik, AOlay);
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

        j := DegerListesi^.FGorunenIlkSiraNo;
        Dec(j);
        if(j >= 0) then
        begin

          DegerListesi^.FGorunenIlkSiraNo := j;
          DegerListesi^.FSeciliSutun := j;
        end;
      end

      // fare ızgara nesnesinin aşağısında ise
      else if(AOlay.Deger2 > DegerListesi^.FBoyut.Yukseklik) then
      begin

        // azami kaydırma değeri
        {i := DegerListesi^.FKolonAdlari^.ElemanSayisi - DegerListesi^.FGorunenElemanSayisi;
        if(i < 0) then i := 0;

        j := DegerListesi^.FGorunenIlkSiraNo;
        Inc(j);
        if(j < i) then
        begin

          DegerListesi^.FGorunenIlkSiraNo := j;
          i := (AOlay.Deger2 - 24) div 21;
          DegerListesi^.FSeciliSutun := i + DegerListesi^.FGorunenIlkSiraNo;
        end}
      end

      // fare ızgara nesnesinin içerisinde ise
      else
      begin

        i := (AOlay.Deger2 - 24) div 21;
        DegerListesi^.FSeciliSutun := i + DegerListesi^.FGorunenIlkSiraNo;
      end;

      // ızgara nesnesini yeniden çiz
      DegerListesi^.Ciz;

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(DegerListesi^.OlayCagriAdresi = nil) then
        DegerListesi^.OlayCagriAdresi(DegerListesi, AOlay)
      else GorevListesi[DegerListesi^.GorevKimlik]^.OlayEkle(DegerListesi^.GorevKimlik, AOlay);
    end

    // nesne yakalanmamış ise uygulamaya sadece mesaj gönder
    else
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(DegerListesi^.OlayCagriAdresi = nil) then
        DegerListesi^.OlayCagriAdresi(DegerListesi, AOlay)
      else GorevListesi[DegerListesi^.GorevKimlik]^.OlayEkle(DegerListesi^.GorevKimlik, AOlay);
    end;
  end

  else if(AOlay.Olay = FO_KAYDIRMA) then
  begin

    // listeyi yukarı kaydırma işlemi. ilk elemana doğru
    if(AOlay.Deger1 < 0) then
    begin

      j := DegerListesi^.FGorunenIlkSiraNo;
      Dec(j);
      if(j >= 0) then DegerListesi^.FGorunenIlkSiraNo := j;
    end

    // listeyi aşağıya kaydırma işlemi. son elemana doğru
    else if(AOlay.Deger1 > 0) then
    begin

      // azami kaydırma değeri
      i := DegerListesi^.FDegerler^.ElemanSayisi - DegerListesi^.FGorunenElemanSayisi;
      if(i < 0) then i := 0;

      j := DegerListesi^.FGorunenIlkSiraNo;
      Inc(j);
      if(j < i) then DegerListesi^.FGorunenIlkSiraNo := j;
    end;

    DegerListesi^.Ciz;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := DegerListesi^.FFareImlecTipi;
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

procedure TIzgara.HucreSayisiBelirle(ASatirSayisi, ASutunSayisi: TSayi4);
var
  Izgara: PIzgara;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSatirSayisi := ASatirSayisi;
  Izgara^.FSutunSayisi := ASutunSayisi;
end;

procedure TIzgara.HucreBoyutuBelirle(ASutunGenislik, ASatirYukseklik: TSayi4);
var
  Izgara: PIzgara;
begin

  Izgara := PIzgara(Izgara^.NesneAl(Kimlik));
  if(Izgara = nil) then Exit;

  Izgara^.FSutunGenislik := ASutunGenislik;
  Izgara^.FSatirYukseklik := ASatirYukseklik;
end;

{==============================================================================
  seçili elemanın yazı (text) değerini geri döndürür
 ==============================================================================}
function TIzgara.SeciliSatirDegeriniAl: string;
var
  DegerListesi: PIzgara;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(Kimlik, gntIzgara));
  if(DegerListesi = nil) then Exit;

  if(FSeciliSutun = -1) or (FSeciliSutun > FDegerler^.ElemanSayisi) then Exit('');

  Result := DegerListesi^.FDegerler^.Eleman[FSeciliSutun];
end;

{==============================================================================
  | ayıracıyla gelen karakter katarını bölümler
 ==============================================================================}
procedure TIzgara.Bolumle(ABicimlenmisDeger: string; AAyiracDeger: Char;
  DegerDizisi: PYaziListesi);
var
  Uzunluk, i: TISayi4;
  s: string;
begin

  DegerDizisi^.Temizle;

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

          DegerDizisi^.Ekle(s);
          s := '';
        end;
      end else s += ABicimlenmisDeger[i];

      Inc(i);
    end;
  end;
end;

function TIzgara.DegerEkle(ADeger: string): Boolean;
var
  DegerListesi: PIzgara;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  DegerListesi := PIzgara(DegerListesi^.NesneAl(Kimlik));
  if(DegerListesi = nil) then Exit;

  DegerListesi^.FDegerler^.Ekle(ADeger);

  Result := True;
end;

procedure TIzgara.DegerIceriginiTemizle;
var
  DegerListesi: PIzgara;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  DegerListesi := PIzgara(DegerListesi^.NesneAl(Kimlik));
  if(DegerListesi = nil) then Exit;

  DegerListesi^.FDegerler^.Temizle;
  DegerListesi^.FGorunenIlkSiraNo := 0;
  DegerListesi^.FSeciliSutun := -1;

  DegerListesi^.Ciz;
end;

end.
