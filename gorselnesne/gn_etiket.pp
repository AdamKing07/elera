{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_etiket.pp
  Dosya İşlevi: etiket (label) nesne yönetim işlevlerini içerir

  Güncelleme Tarihi: 15/05/2020

 ==============================================================================}
{$mode objfpc}
unit gn_etiket;

interface

uses gorselnesne, paylasim, gn_gorselanayapi;

type
  PEtiket = ^TEtiket;
  TEtiket = object(TGorselAnaYapi)
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst: TSayi4; AYaziRenk: TRenk;
      ABaslik: string): PEtiket;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function EtiketCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; ASol, AUst: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne;

{==============================================================================
  etiket (label) nesne kesme çağrılarını yönetir
 ==============================================================================}
function EtiketCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Pencere: PPencere;
  Etiket: PEtiket;
  p1: PShortString;
begin

  case AIslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(ADegiskenler + 00)^, PISayi4(ADegiskenler + 04)^,
        PISayi4(ADegiskenler + 08)^, PRenk(ADegiskenler + 12)^,
        PShortString(PSayi4(ADegiskenler + 16)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      Etiket := PEtiket(Etiket^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Etiket^.Goster;
    end;

    // etiket (label) başlığını değiştir
    $0104:
    begin

      Etiket := PEtiket(Etiket^.NesneAl(PKimlik(ADegiskenler + 00)^));
      p1 := PShortString(PSayi4(ADegiskenler + 04)^ + AktifGorevBellekAdresi);
      Etiket^.Baslik := p1^;

      // etiketin bağlı olduğu pencere nesnesini güncelle
      Pencere := PencereAtaNesnesiniAl(Etiket);
      if not(Pencere = nil) then Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  etiket (label) nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; ASol, AUst: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): TKimlik;
var
  Etiket: PEtiket;
begin

  Etiket := Etiket^.Olustur(AAtaKimlik, ASol, AUst, AYaziRenk, ABaslik);

  if(Etiket = nil) then

    Result := HATA_NESNEOLUSTURMA
  else
  begin

    // FCizimModel = arka plan boyama yok, yazı var
    Etiket^.FCizimModel := 1;

    Result := Etiket^.Kimlik;
  end;
end;

{==============================================================================
  etiket (label) nesnesini oluşturur
 ==============================================================================}
function TEtiket.Olustur(AAtaKimlik: TKimlik; ASol, AUst: TSayi4; AYaziRenk: TRenk;
  ABaslik: string): PEtiket;
var
  Etiket: PEtiket;
  Uzunluk: TSayi4;
begin

  Uzunluk := Length(ABaslik) * 8;
  Etiket := PEtiket(inherited Olustur(gntEtiket, AAtaKimlik, ASol, AUst, Uzunluk,
    16, 1, RENK_BEYAZ, RENK_BEYAZ, AYaziRenk, ABaslik));

  // nesnenin ad değeri
  Etiket^.NesneAdi := NesneAdiAl(gntEtiket);

  // FCizimModel = arka plan boyama yok, yazı var
  Etiket^.FCizimModel := 2;

  Etiket^.FYaziHiza.Yatay := yhSol;
  Etiket^.FYaziHiza.Dikey := dhUst;

  // nesne adresini geri döndür
  Result := Etiket;
end;

{==============================================================================
  etiket (label) nesnesini görüntüler
 ==============================================================================}
procedure TEtiket.Goster;
begin

  inherited Goster;
end;

{==============================================================================
  etiket (label) nesnesini çizer
 ==============================================================================}
procedure TEtiket.Ciz;
var
  Etiket: PEtiket;
  Olay: TOlayKayit;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Etiket := PEtiket(Etiket^.NesneTipiniKontrolEt(Kimlik, gntEtiket));
  if(Etiket = nil) then Exit;

  inherited Ciz;

  Olay.Kimlik := Etiket^.Kimlik;
  Olay.Olay := CO_CIZIM;
  Olay.Deger1 := 0;
  Olay.Deger2 := 0;

  // uygulamaya veya efendi nesneye mesaj gönder
  if not(Etiket^.FEfendiNesneOlayCagriAdresi = nil) then

    Etiket^.FEfendiNesneOlayCagriAdresi(Etiket^.Kimlik, Olay)

  else GorevListesi[Etiket^.GorevKimlik]^.OlayEkle2(Etiket^.GorevKimlik, Olay);
end;

{==============================================================================
  etiket (label) nesne olaylarını işler
 ==============================================================================}
procedure TEtiket.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  Pencere: PPencere;
  Etiket: PEtiket;
begin

  Etiket := PEtiket(Etiket^.NesneTipiniKontrolEt(AKimlik, gntEtiket));
  if(Etiket = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // etiketin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := PencereAtaNesnesiniAl(Etiket);

    // en üstte olmaması durumunda en üste getir
    if(Pencere <> AktifPencere) then Pencere^.EnUsteGetir;

    // fare olaylarını yakala
    OlayYakalamayaBasla(Etiket);

    // etiket nesnesini yeniden çiz
    Etiket^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(Etiket^.FEfendiNesneOlayCagriAdresi = nil) then

      Etiket^.FEfendiNesneOlayCagriAdresi(Etiket^.Kimlik, AOlay)

    else GorevListesi[Etiket^.GorevKimlik]^.OlayEkle2(Etiket^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(Etiket);

    // etiket nesnesini yeniden çiz
    Etiket^.Ciz;

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Etiket^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // yakalama & bırakma işlemi bu nesnede olduğu için
      // uygulamaya veya efendi nesneye FO_TIKLAMA mesajı gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Etiket^.FEfendiNesneOlayCagriAdresi = nil) then

        Etiket^.FEfendiNesneOlayCagriAdresi(Etiket^.Kimlik, AOlay)

      else GorevListesi[Etiket^.GorevKimlik]^.OlayEkle2(Etiket^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(Etiket^.FEfendiNesneOlayCagriAdresi = nil) then

      Etiket^.FEfendiNesneOlayCagriAdresi(Etiket^.Kimlik, AOlay)

    else GorevListesi[Etiket^.GorevKimlik]^.OlayEkle2(Etiket^.GorevKimlik, AOlay);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // etiket nesnesini yeniden çiz
    Etiket^.Ciz;

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(Etiket^.FEfendiNesneOlayCagriAdresi = nil) then

      Etiket^.FEfendiNesneOlayCagriAdresi(Etiket^.Kimlik, AOlay)

    else GorevListesi[Etiket^.GorevKimlik]^.OlayEkle2(Etiket^.GorevKimlik, AOlay);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
