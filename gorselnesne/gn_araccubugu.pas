{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_araccubugu.pas
  Dosya İşlevi: araç çubuğu (TToolBar) nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 08/07/2020

 ==============================================================================}
{$mode objfpc}
unit gn_araccubugu;

interface

uses gorselnesne, paylasim, gn_panel, gn_resimdugmesi, sistemmesaj;

const
  AZAMI_DUGME_SAYISI = 50;

type
  PAracCubugu = ^TAracCubugu;
  TAracCubugu = object(TPanel)
  private
    // araç çubuğunda yer alacak düğme listesi
    FDugmeSayisi: TSayi4;
    FDugmeler: array[0..AZAMI_DUGME_SAYISI - 1] of PResimDugmesi;
  public
    function Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne): PAracCubugu;
    procedure YokEt;
    procedure Goster;
    procedure Gizle;
    procedure Boyutlandir;
    procedure Ciz;
    procedure OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    procedure ResimDugmeOlaylariniIsle(AGonderici: PGorselNesne; AOlay: TOlay);
    function DugmeEkle(ADugmeSiraNo: TSayi4): TKimlik;
  end;

function AracCubuguCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaNesne: PGorselNesne): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  araç çubuğu nesne kesme çağrılarını yönetir
 ==============================================================================}
function AracCubuguCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  GorselNesne: PGorselNesne;
  Pencere: PPencere;
  AracCubugu: PAracCubugu;
  p: PKarakterKatari;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:
    begin

      GorselNesne := GorselNesne^.NesneAl(PKimlik(ADegiskenler + 00)^);
      Result := NesneOlustur(GorselNesne);
    end;

    ISLEV_GOSTER:
    begin

      AracCubugu := PAracCubugu(AracCubugu^.NesneAl(PKimlik(ADegiskenler + 00)^));
      AracCubugu^.Goster;
    end;

    // AracCubugu başlığını değiştir
    $0104:
    begin

      AracCubugu := PAracCubugu(AracCubugu^.NesneAl(PKimlik(ADegiskenler + 00)^));
      p := PKarakterKatari(PSayi4(ADegiskenler + 04)^ + CalisanGorevBellekAdresi);
      AracCubugu^.Baslik := p^;

      // araç çubuğunun bağlı olduğu pencere nesnesini güncelle
      Pencere := EnUstPencereNesnesiniAl(AracCubugu);
      if not(Pencere = nil) then Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  araç çubuğu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaNesne: PGorselNesne): TKimlik;
var
  AracCubugu: PAracCubugu;
begin

  AracCubugu := AracCubugu^.Olustur(ktNesne, AAtaNesne);

  if(AracCubugu = nil) then

    Result := HATA_NESNEOLUSTURMA

  else Result := AracCubugu^.Kimlik;
end;

{==============================================================================
  araç çubuğu nesnesini oluşturur
 ==============================================================================}
function TAracCubugu.Olustur(AKullanimTipi: TKullanimTipi; AAtaNesne: PGorselNesne): PAracCubugu;
var
  AracCubugu: PAracCubugu;
  i: TSayi4;
begin

  AracCubugu := PAracCubugu(inherited Olustur(AKullanimTipi, AAtaNesne, 0, 0, 10,
    28, 2, RENK_GUMUS {$F0F0F0}, RENK_BEYAZ {$F0F0F0}, 0, ''));

  // nesnenin ad değeri
  AracCubugu^.NesneTipi := gntAracCubugu;

  AracCubugu^.FTuvalNesne := AAtaNesne^.FTuvalNesne;

  AracCubugu^.AnaOlayCagriAdresi := @OlaylariIsle;

  AracCubugu^.FHiza := hzUst;

  // düğme değerlerinin ilk değerlerle yüklenmesi
  FDugmeSayisi := 0;
  for i := 0 to AZAMI_DUGME_SAYISI - 1 do FDugmeler[i] := nil;

  // nesne adresini geri döndür
  Result := AracCubugu;
end;

{==============================================================================
  araç çubuğu nesnesini yok eder
 ==============================================================================}
procedure TAracCubugu.YokEt;
begin

  inherited YokEt;
end;

{==============================================================================
  araç çubuğu nesnesini görüntüler
 ==============================================================================}
procedure TAracCubugu.Goster;
var
  AracCubugu: PAracCubugu;
  i: TSayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  AracCubugu := PAracCubugu(AracCubugu^.NesneAl(Kimlik));
  if(AracCubugu = nil) then Exit;

  if(AracCubugu^.FDugmeSayisi > 0) then
  begin

    for i := 0 to AracCubugu^.FDugmeSayisi - 1 do
    begin

      if not(AracCubugu^.FDugmeler[i] = nil) then AracCubugu^.FDugmeler[i]^.Goster;
    end;
  end;

  inherited Goster;
end;

{==============================================================================
  araç çubuğu nesnesini gizler
 ==============================================================================}
procedure TAracCubugu.Gizle;
var
  AracCubugu: PAracCubugu;
  i: TSayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  AracCubugu := PAracCubugu(AracCubugu^.NesneAl(Kimlik));
  if(AracCubugu = nil) then Exit;

  if(AracCubugu^.FDugmeSayisi > 0) then
  begin

    for i := 0 to AracCubugu^.FDugmeSayisi - 1 do
    begin

      if not(AracCubugu^.FDugmeler[i] = nil) then AracCubugu^.FDugmeler[i]^.Gizle;
    end;
  end;

  inherited Gizle;
end;

{==============================================================================
  araç çubuğu nesnesini boyutlandırır
 ==============================================================================}
procedure TAracCubugu.Boyutlandir;
begin

  inherited Boyutlandir;
end;

{==============================================================================
  araç çubuğu nesnesini çizer
 ==============================================================================}
procedure TAracCubugu.Ciz;
var
  AracCubugu: PAracCubugu;
  i: Integer;
begin

  AracCubugu := PAracCubugu(AracCubugu^.NesneAl(Kimlik));
  if(AracCubugu = nil) then Exit;

  // öncelikle kendini çiz
  inherited Ciz;

  // daha sonra alt nesne düğmeleri
  if(AracCubugu^.FDugmeSayisi > 0) then
  begin

    for i := 0 to AracCubugu^.FDugmeSayisi - 1 do
    begin

      if not(AracCubugu^.FDugmeler[i] = nil) then AracCubugu^.FDugmeler[i]^.Ciz;
    end;
  end;
end;

{==============================================================================
  araç çubuğu nesne olaylarını işler
 ==============================================================================}
procedure TAracCubugu.OlaylariIsle(AGonderici: PGorselNesne; AOlay: TOlay);
var
  Pencere: PPencere;
  AracCubugu: PAracCubugu;
begin

  AracCubugu := PAracCubugu(AGonderici);

  // farenin sol tuşuna basım işlemi
{  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // araç çubuğunun sahibi olan pencere en üstte mi ? kontrol et
    Pencere := EnUstPencereNesnesiniAl(AracCubugu);

    // en üstte olmaması durumunda en üste getir
    if not(Pencere = nil) and (Pencere <> AktifPencere) then Pencere^.EnUsteGetir(Pencere);

    // fare olaylarını yakala
    OlayYakalamayaBasla(AracCubugu);

    // AracCubugu nesnesini yeniden çiz
    AracCubugu^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(AracCubugu^.OlayCagriAdresi = nil) then
      AracCubugu^.OlayCagriAdresi(AracCubugu, AOlay)
    else GorevListesi[AracCubugu^.GorevKimlik]^.OlayEkle(AracCubugu^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(AracCubugu);

    // AracCubugu nesnesini yeniden çiz
    AracCubugu^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(AracCubugu^.FareNesneOlayAlanindaMi(AracCubugu)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // uygulamaya veya efendi nesneye FO_TIKLAMA mesajı gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(AracCubugu^.OlayCagriAdresi = nil) then
        AracCubugu^.OlayCagriAdresi(AracCubugu, AOlay)
      else GorevListesi[AracCubugu^.GorevKimlik]^.OlayEkle(AracCubugu^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(AracCubugu^.OlayCagriAdresi = nil) then
      AracCubugu^.OlayCagriAdresi(AracCubugu, AOlay)
    else GorevListesi[AracCubugu^.GorevKimlik]^.OlayEkle(AracCubugu^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // AracCubugu nesnesini yeniden çiz
    AracCubugu^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(AracCubugu^.OlayCagriAdresi = nil) then
      AracCubugu^.OlayCagriAdresi(AracCubugu, AOlay)
    else GorevListesi[AracCubugu^.GorevKimlik]^.OlayEkle(AracCubugu^.GorevKimlik, AOlay);
  end;
}
  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := AracCubugu^.FFareImlecTipi;
end;

procedure TAracCubugu.ResimDugmeOlaylariniIsle(AGonderici: PGorselNesne;
  AOlay: TOlay);
var
  AracCubugu: PAracCubugu;
begin

  AracCubugu := PAracCubugu(AracCubugu^.NesneAl(Kimlik));
  if(AracCubugu = nil) then Exit;

  if(AOlay.Olay = FO_TIKLAMA) then
  begin

    if not(AracCubugu^.OlayCagriAdresi = nil) then
      AracCubugu^.OlayCagriAdresi(AracCubugu, AOlay)
    else GorevListesi[AracCubugu^.GorevKimlik]^.OlayEkle(AracCubugu^.GorevKimlik, AOlay);
  end;
end;

function TAracCubugu.DugmeEkle(ADugmeSiraNo: TSayi4): TKimlik;
var
  AracCubugu: PAracCubugu;
  ResimDugmesi: PResimDugmesi;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  AracCubugu := PAracCubugu(AracCubugu^.NesneAl(Kimlik));
  if(AracCubugu = nil) then Exit;

  if(AracCubugu^.FDugmeSayisi > AZAMI_DUGME_SAYISI) then Exit;

  ResimDugmesi := ResimDugmesi^.Olustur(ktBilesen, AracCubugu,
    (FDugmeSayisi * 30) + 4, 1, 24, 24, $10000000 + ADugmeSiraNo, False);
  ResimDugmesi^.FRDOlayGeriDonusumAdresi := @ResimDugmeOlaylariniIsle;

  FDugmeler[FDugmeSayisi] := ResimDugmesi;

  Inc(FDugmeSayisi);

  Result := ResimDugmesi^.Kimlik;
end;

end.
