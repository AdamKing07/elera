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
    FSutunSayisi, FSatirSayisi: TSayi4;
    FSeciliSiraNo: TISayi4;               // seçili sıra değeri
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
  end;

function IzgaraCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_islevler, gn_pencere, temelgorselnesne;

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
    $0200:
    begin

      DegerListesi := PIzgara(DegerListesi^.NesneTipiniKontrolEt(
        PKimlik(ADegiskenler + 00)^, gntIzgara));
      if(DegerListesi <> nil) then Result := DegerListesi^.FSeciliSiraNo;
    end;

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
      if(DegerListesi <> nil) then Result := DegerListesi^.FSeciliSiraNo;
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
begin

  DegerListesi := PIzgara(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik, 2, $828790, RENK_BEYAZ, 0, ''));

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
  DegerListesi^.FSeciliSiraNo := -1;

  // ızgara nesnesinde görüntülenecek eleman sayısı
  DegerListesi^.FGorunenElemanSayisi := (AYukseklik - 24) div 21;

  DegerListesi^.FSutunSayisi := 5;
  DegerListesi^.FSatirSayisi := 5;

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
  ElemanSayisi, SatirNo, i, j,
  Sol, Ust, DegerSayisi: TISayi4;
  s: string;
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
{  if(KolonAdlari^.ElemanSayisi = 0) then Exit;

  // kolon başlık ve değerleri
  Sol := Alan1.Sol + 1;
  for i := 0 to KolonUzunluklari^.ElemanSayisi - 1 do
  begin

    Sol += KolonUzunluklari^.Eleman[i];

    // dikey kılavuz çizgisi
    Izgara^.Cizgi(Izgara, Sol, Alan1.Ust + 1, Sol, Alan1.Alt - 1, $F0F0F0);

    // başlık dolgusu
    Alan2.Sol := Sol - KolonUzunluklari^.Eleman[i];
    Alan2.Ust := Alan1.Ust + 1;
    Alan2.Sag := Sol - 1;
    Alan2.Alt := Alan1.Ust + 1 + 22;
    Izgara^.EgimliDoldur3(Izgara, Alan2, $EAECEE, $ABB2B9);

    // başlık
    Izgara^.AlanaYaziYaz(Izgara, Alan2, 4, 3, KolonAdlari^.Eleman[i], RENK_LACIVERT);

    Inc(Sol);    // 1 px çizgi kalınlığı
  end;

  // yatay kılavuz çizgileri
  Ust := Alan1.Ust + 1 + 22;
  Ust += 20;
  while Ust < Alan1.Alt do
  begin

    Izgara^.Cizgi(Izgara, Alan1.Sol + 1, Ust, Alan1.Sag - 1, Ust, $F0F0F0);
    Ust += 1 + 20;
  end;

  // ızgara nesnesinde görüntülenecek eleman sayısı
  Izgara^.FGorunenElemanSayisi := ((Izgara^.FCizimAlan.Alt -
    Izgara^.FCizimAlan.Ust) - 24) div 21;

  // ızgara nesnesinde görüntülenecek eleman sayısının belirlenmesi
  if(FDegerler^.ElemanSayisi > Izgara^.FGorunenElemanSayisi) then
    ElemanSayisi := Izgara^.FGorunenElemanSayisi + Izgara^.FGorunenIlkSiraNo
  else ElemanSayisi := FDegerler^.ElemanSayisi + Izgara^.FGorunenIlkSiraNo;

  Ust := Alan1.Ust + 1 + 22;
  Ust += 20;
  SatirNo := 0;
  KolonUzunluklari := Izgara^.FKolonUzunluklari;

  // ızgara nesnesi değerlerini yerleştir
  for SatirNo := Izgara^.FGorunenIlkSiraNo to ElemanSayisi - 1 do
  begin

    // değeri belirtilen karakter ile bölümle
    Bolumle(FDegerler^.Eleman[SatirNo], '|', FDegerDizisi);

    Sol := Alan1.Sol + 1;
    if(FDegerDizisi^.ElemanSayisi > 0) then
    begin

      if(FDegerDizisi^.ElemanSayisi > 1) then
        DegerSayisi := 2
      else DegerSayisi := 1;

      for j := 0 to DegerSayisi - 1 do
      begin

        s := FDegerDizisi^.Eleman[j];
        Alan2.Sol := Sol + 1;
        Alan2.Ust := Ust - 20 + 1;
        Alan2.Sag := Sol + KolonUzunluklari^.Eleman[j] - 1;
        Alan2.Alt := Ust - 1;

        // satır verisini boyama ve yazma işlemi
        if(SatirNo = Izgara^.FSeciliSiraNo) then
        begin

          Izgara^.DikdortgenDoldur(Izgara, Alan2.Sol - 1, Alan2.Ust - 1,
            Alan2.Sag, Alan2.Alt, $3EC5FF, $3EC5FF);
        end
        else
        begin

          Izgara^.DikdortgenDoldur(Izgara, Alan2.Sol - 1, Alan2.Ust - 1,
            Alan2.Sag, Alan2.Alt, RENK_BEYAZ, RENK_BEYAZ);
        end;

        Izgara^.AlanaYaziYaz(Izgara, Alan2, 2, 2, s, RENK_SIYAH);

        Sol += 1 + KolonUzunluklari^.Eleman[j];
      end;
    end;

    Ust += 1 + 20;
  end;
}
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

      // seçilen sırayı yeniden belirle
      j := (AOlay.Deger2 - 24) div 21;

      // bu değere kaydırılan değeri de ekle
      DegerListesi^.FSeciliSiraNo := (j + DegerListesi^.FGorunenIlkSiraNo);

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
          DegerListesi^.FSeciliSiraNo := j;
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
          DegerListesi^.FSeciliSiraNo := i + DegerListesi^.FGorunenIlkSiraNo;
        end}
      end

      // fare ızgara nesnesinin içerisinde ise
      else
      begin

        i := (AOlay.Deger2 - 24) div 21;
        DegerListesi^.FSeciliSiraNo := i + DegerListesi^.FGorunenIlkSiraNo;
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

  if(FSeciliSiraNo = -1) or (FSeciliSiraNo > FDegerler^.ElemanSayisi) then Exit('');

  Result := DegerListesi^.FDegerler^.Eleman[FSeciliSiraNo];
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
  DegerListesi^.FSeciliSiraNo := -1;

  DegerListesi^.Ciz;
end;

end.
