{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_defter.pas
  Dosya İşlevi: defter nesnesi (memo) yönetim işlevlerini içerir

  Güncelleme Tarihi: 20/06/2020

  Bilgi: bu görsel nesne 13.05.2020 tarih itibariyle nesnenin program bölümüne eklenen
    40K ve çekirdek bölümüne eklenen 40K bellek kullanmaktadır.
    bu bellek miktarı şu an için gereklidir. ileride yapısallık bağlamında değiştirilebilir.

 ==============================================================================}
{$mode objfpc}
unit gn_defter;

interface

uses gorselnesne, paylasim, gn_panel, gn_kaydirmacubugu;

type
  PDefter = ^TDefter;
  TDefter = object(TPanel)
  private
    FYatayKCubugu, FDikeyKCubugu: PKaydirmaCubugu;
    // yatay & dikey karakter sayısı
    FYatayKarSay, FDikeyKarSay: TSayi4;
    FYaziBellekAdresi: Isaretci;
    FYaziUzunlugu: TSayi4;
    procedure YatayDikeyKarakterSayisiniAl;
    procedure KaydirmaCubuguOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
      ASol, AUst, AGenislik, AYukseklik: TISayi4; ADefterRenk, AYaziRenk: TRenk): PDefter;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure Temizle;
    procedure YaziEkle(AYaziBellekAdresi: Isaretci);
    procedure YaziEkle(ADeger: string);
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
  end;

function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
function DefterCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;

implementation

uses gn_pencere, genel, temelgorselnesne;

{==============================================================================
  defter kesme çağrılarını yönetir
 ==============================================================================}
function DefterCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  Defter: PDefter;
  Hiza: THiza;
begin

  case AIslevNo of
    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^, PISayi4(ADegiskenler + 16)^,
        PRenk(ADegiskenler + 20)^, PRenk(ADegiskenler + 24)^);
    end;

    ISLEV_GOSTER:
    begin

      Defter := PDefter(Defter^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Defter^.Goster;
    end;

    // defter nesnesine veri ekle - pchar
    $0100:
    begin

      // nesnenin handle, tip değerlerini denetle.
      Defter := PDefter(Defter^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntDefter));
      if(Defter <> nil) then
      begin

        Defter^.YaziEkle(Isaretci(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi));
        Result := 1;
      end;
    end;

    // defter nesnesine veri ekle - string
    $0200:
    begin

      // nesnenin handle, tip değerlerini denetle.
      Defter := PDefter(Defter^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntDefter));
      if(Defter <> nil) then
      begin

        Defter^.YaziEkle(PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi)^);
        Result := 1;
      end;
    end;

    // defter nesnesinin içerisindeki verileri sil
    $0300:
    begin

      // nesnenin kimlik, tip değerlerini denetle.
      Defter := PDefter(Defter^.NesneTipiniKontrolEt(PKimlik(ADegiskenler + 00)^, gntDefter));
      if(Defter <> nil) then
      begin

        Defter^.Temizle;
      end;
    end;

    $0104:
    begin

      Defter := PDefter(Defter^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      Defter^.FHiza := Hiza;

      Pencere := PPencere(Defter^.FAtaNesne);
      Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
var
  Defter: PDefter;
begin

  Defter := Defter^.Olustur(ktNesne, AAtaNesne, ASol, AUst, AGenislik, AYukseklik,
    ADefterRenk, AYaziRenk);

  if(Defter = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := Defter^.Kimlik;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function TDefter.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne;
  ASol, AUst, AGenislik, AYukseklik: TISayi4; ADefterRenk, AYaziRenk: TRenk): PDefter;
var
  Defter: PDefter;
  YaziBellekAdresi: Isaretci;
begin

  Defter := PDefter(inherited Olustur(AKullanimTipi, AAtaNesne, ASol, AUst,
    AGenislik, AYukseklik, 2, ADefterRenk, ADefterRenk, 0, ''));

  Defter^.NesneTipi := gntDefter;

  Defter^.Baslik := '';

  Defter^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  Defter^.AnaOlayCagriAdresi := @OlaylariIsle;

  Defter^.FFareImlecTipi := fitGiris;

  // yatay kaydırma çubuğu
  Defter^.FYatayKCubugu := Defter^.FYatayKCubugu^.Olustur(ktBilesen, Defter,
    0, AYukseklik - 16, AGenislik - 16, 16, yYatay);
  Defter^.FYatayKCubugu^.DegerleriBelirle(0, 10);
  Defter^.FYatayKCubugu^.FKCOlayGeriDonusumAdresi := @KaydirmaCubuguOlaylariniIsle;

  // dikey kaydırma çubuğu
  Defter^.FDikeyKCubugu := Defter^.FDikeyKCubugu^.Olustur(ktBilesen, Defter,
    AGenislik - 16, 0, 16, AYukseklik - 16, yDikey);
  Defter^.FDikeyKCubugu^.DegerleriBelirle(0, 10);
  Defter^.FDikeyKCubugu^.FKCOlayGeriDonusumAdresi := @KaydirmaCubuguOlaylariniIsle;

  // defter nesnesinin içeriği için bellek ayır
  YaziBellekAdresi := GGercekBellek.Ayir(4096 * 10);
  Defter^.FYaziBellekAdresi := YaziBellekAdresi;

  Defter^.FYaziUzunlugu := 0;
  Defter^.FYatayKarSay := 0;
  Defter^.FDikeyKarSay := 0;

  Defter^.FYaziRenk := AYaziRenk;

  // kimlik adresini geri döndür
  Result := Defter;
end;

{==============================================================================
  defter nesnesini yok eder
 ==============================================================================}
procedure TDefter.YokEt(AKimlik: TKimlik);
var
  Defter: PDefter;
begin

  // AtaNesne nesnesinin doğruluğunu kontrol et
  Defter := PDefter(Defter^.NesneAl(AKimlik));
  if(Defter = nil) then Exit;

  if(Defter^.FYaziBellekAdresi <> nil) then
    GGercekBellek.YokEt(Defter^.FYaziBellekAdresi, 4096 * 10);

  inherited YokEt;
end;

{==============================================================================
  defter nesnesini görüntüler
 ==============================================================================}
procedure TDefter.Goster;
var
  Defter: PDefter;
begin

  Defter := PDefter(Defter^.NesneAl(Kimlik));
  if(Defter = nil) then Exit;

  Defter^.FYatayKCubugu^.Goster;
  Defter^.FDikeyKCubugu^.Goster;

  inherited Goster;
end;

{==============================================================================
  defter nesnesini gizler
 ==============================================================================}
procedure TDefter.Gizle;
begin

  inherited Gizle;
end;

{==============================================================================
  defter nesnesini boyulandırır
 ==============================================================================}
procedure TDefter.Boyutlandir;
var
  Defter: PDefter;
begin

  Defter := PDefter(Defter^.NesneAl(Kimlik));
  if(Defter = nil) then Exit;

  Defter^.Hizala;

  // yatay kaydırma çubuğunu elle yeniden konumlandır
  Defter^.FYatayKCubugu^.FKonum.Sol := 0;
  Defter^.FYatayKCubugu^.FKonum.Ust := Defter^.FBoyut.Yukseklik - 16;
  Defter^.FYatayKCubugu^.FBoyut.Genislik := Defter^.FBoyut.Genislik - 16;
  Defter^.FYatayKCubugu^.FBoyut.Yukseklik := 16;

  Defter^.FYatayKCubugu^.FCizimAlan.Sol := 0;
  Defter^.FYatayKCubugu^.FCizimAlan.Ust := 0;
  Defter^.FYatayKCubugu^.FCizimAlan.Sag := Defter^.FYatayKCubugu^.FBoyut.Genislik - 1;
  Defter^.FYatayKCubugu^.FCizimAlan.Alt := Defter^.FYatayKCubugu^.FBoyut.Yukseklik - 1;

  Defter^.FYatayKCubugu^.FCizimBaslangic.Sol := Defter^.FCizimBaslangic.Sol + Defter^.FYatayKCubugu^.FKonum.Sol;
  Defter^.FYatayKCubugu^.FCizimBaslangic.Ust := Defter^.FCizimBaslangic.Ust + Defter^.FYatayKCubugu^.FKonum.Ust;
  Defter^.FYatayKCubugu^.Boyutlandir;

  // dikey kaydırma çubuğunu elle yeniden konumlandır
  Defter^.FDikeyKCubugu^.FKonum.Sol := Defter^.FBoyut.Genislik - 16;
  Defter^.FDikeyKCubugu^.FKonum.Ust := 0;
  Defter^.FDikeyKCubugu^.FBoyut.Genislik := 16;
  Defter^.FDikeyKCubugu^.FBoyut.Yukseklik := Defter^.FBoyut.Yukseklik - 16;

  Defter^.FDikeyKCubugu^.FCizimAlan.Sol := 0;
  Defter^.FDikeyKCubugu^.FCizimAlan.Ust := 0;
  Defter^.FDikeyKCubugu^.FCizimAlan.Sag := Defter^.FDikeyKCubugu^.FBoyut.Genislik - 1;
  Defter^.FDikeyKCubugu^.FCizimAlan.Alt := Defter^.FDikeyKCubugu^.FBoyut.Yukseklik - 1;

  Defter^.FDikeyKCubugu^.FCizimBaslangic.Sol := Defter^.FCizimBaslangic.Sol + Defter^.FDikeyKCubugu^.FKonum.Sol;
  Defter^.FDikeyKCubugu^.FCizimBaslangic.Ust := Defter^.FCizimBaslangic.Ust + Defter^.FDikeyKCubugu^.FKonum.Ust;
  Defter^.FDikeyKCubugu^.Boyutlandir;
end;

{==============================================================================
  defter nesnesini çizer
 ==============================================================================}
procedure TDefter.Ciz;
var
  Pencere: PPencere;
  Defter: PDefter;
  Alan: TAlan;
  Sol, Ust: TISayi4;
  YaziBellekAdresi: PChar;
  SatirNo: TISayi4;
  SutunNo: Integer;
  DikeySinir: TSayi4;
begin

  Defter := PDefter(Defter^.NesneAl(Kimlik));
  if(Defter = nil) then Exit;

  inherited Ciz;

  // defter nesnesinin çizim alan koordinatlarını al
  Alan := Defter^.FCizimAlan;

  // kaydırma çubuğu ve karakter yüksekliği
  DikeySinir := Alan.Alt - 16 - 16;

  // eğer defter nesnesi için bellek ayrıldıysa defter içeriğini nesne içeriğine
  // eklenen bilgilerle doldur
  if(Defter^.FYaziBellekAdresi <> nil) and (Defter^.FYaziUzunlugu > 0) then
  begin

    // Sol ve Ust başlangıç değerleri
    Sol := Alan.Sol + 4;
    Ust := Alan.Ust + 4;

    // defter içerik bellek bölgesine konumlan
    YaziBellekAdresi := PChar(Defter^.FYaziBellekAdresi);

    SatirNo := 0;
    SutunNo := 0;

    // bellek içeriği sıfır oluncaya kadar devam et
    while (YaziBellekAdresi^ <> #0) do
    begin

      // giriş (enter) tuşu olması durumunda herhangi birşey yapma
      if(YaziBellekAdresi^ = #13) then
      begin

      end

      // satır başı + bir alt satıra geç
      else if(YaziBellekAdresi^ = #10) then
      begin

        SutunNo := 0;
        Inc(SatirNo);
        if(SatirNo >= Defter^.FDikeyKCubugu^.FMevcutDeger) then
        begin

          if(SatirNo > Defter^.FDikeyKCubugu^.FMevcutDeger) then Ust += 16;
          Sol := Alan.Sol + 4;
        end;
      end
      else
      begin

        if(Ust < DikeySinir) then
        begin

          if(SatirNo >= Defter^.FDikeyKCubugu^.FMevcutDeger) then
          begin

            if(SutunNo >= Defter^.FYatayKCubugu^.FMevcutDeger) then
            begin

              HarfYaz(Defter, Sol, Ust, YaziBellekAdresi^, Defter^.FYaziRenk);
              Sol += 8;
            end;

            Inc(SutunNo);
          end;
        end;
      end;

      Inc(YaziBellekAdresi);
    end;
  end;

  // kaydırma çubuklarını en son çiz
  Defter^.FYatayKCubugu^.Ciz;
  Defter^.FDikeyKCubugu^.Ciz;
end;

{==============================================================================
  defter nesnesinin içeriğindeki verileri siler
 ==============================================================================}
procedure TDefter.Temizle;
begin

  Self.FYaziUzunlugu := 0;

  BellekDoldur(Self.FYaziBellekAdresi, 4096 * 10, 0);

  YatayDikeyKarakterSayisiniAl;

  Ciz;
end;

{==============================================================================
  defter nesnesine karakter katarı ekler - pchar
 ==============================================================================}
procedure TDefter.YaziEkle(AYaziBellekAdresi: Isaretci);
var
  p: PSayi1;
  Uzunluk: TSayi4;
begin

  // karakter katarı için bellek ayrılmış mı ?
  if(Self.FYaziBellekAdresi = nil) then Exit;

  // verinin uzunluğunu al
  Uzunluk := StrLen(AYaziBellekAdresi);
  if(Uzunluk = 0) or (Uzunluk > (4096 * 10)) then Exit;

  // karakter katarını hedef bölgeye kopyala
  p := PByte(Self.FYaziBellekAdresi + FYaziUzunlugu);
  Tasi2(AYaziBellekAdresi, p, Uzunluk);

  // sıfır sonlandırma işaretini ekle
  FYaziUzunlugu += Uzunluk;
  p := PByte(Self.FYaziBellekAdresi + FYaziUzunlugu);
  p^ := 0;

  YatayDikeyKarakterSayisiniAl;

  Ciz;
end;

{==============================================================================
  defter nesnesine karakter katarı ekler - string
 ==============================================================================}
procedure TDefter.YaziEkle(ADeger: string);
var
  p: PSayi1;
  Uzunluk: TSayi4;
begin

  // karakter katarı için bellek ayrılmış mı ?
  if(FYaziBellekAdresi = nil) then Exit;

  // verinin uzunluğunu al
  Uzunluk := Length(ADeger);
  if(Uzunluk = 0) or (Uzunluk > (4096 * 10)) then Exit;

  // karakter katarını hedef bölgeye kopyala
  p := PByte(TSayi4(FYaziBellekAdresi) + FYaziUzunlugu);
  Tasi2(@ADeger[1], p, Uzunluk);

  // sıfır sonlandırma işaretini ekle
  FYaziUzunlugu += Uzunluk;
  p := PByte(TSayi4(FYaziBellekAdresi) + FYaziUzunlugu);
  p^ := 0;

  YatayDikeyKarakterSayisiniAl;

  Ciz;
end;

procedure TDefter.YatayDikeyKarakterSayisiniAl;
var
  p: PChar;
  i: TSayi4;
begin

  FYatayKarSay := 0;
  FDikeyKarSay := 0;

  if(FYaziUzunlugu = 0) then Exit;

  p := PChar(FYaziBellekAdresi);
  i := 0;
  while p^ <> #0 do
  begin

    if(p^ = #10) then
    begin

      Inc(FDikeyKarSay);
      if(i > FYatayKarSay) then FYatayKarSay := i;
      i := 0;
    end else Inc(i);

    Inc(p);
  end;

  FYatayKCubugu^.FUstDeger := FYatayKarSay;
  FDikeyKCubugu^.FUstDeger := FDikeyKarSay;
end;

{==============================================================================
  defter nesne olaylarını işler
 ==============================================================================}
procedure TDefter.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Defter: PDefter;
begin

  Defter := PDefter(AGonderici);
  if(Defter = nil) then Exit;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Defter^.FFareImlecTipi;
end;

{==============================================================================
  defter nesnesine bağlı kaydırma çubuğu olaylarını işler
 ==============================================================================}
procedure TDefter.KaydirmaCubuguOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Defter: PDefter;
  KaydirmaCubugu: PKaydirmaCubugu;
begin

  KaydirmaCubugu := PKaydirmaCubugu(AGonderici);
  if(KaydirmaCubugu = nil) then Exit;

  Defter := PDefter(KaydirmaCubugu^.AtaNesne);

  if(AOlay.Olay = FO_TIKLAMA) then Defter^.Ciz;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := Defter^.FFareImlecTipi;
end;

end.
