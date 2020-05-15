{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_panel.pp
  Dosya İşlevi: panel yönetim işlevlerini içerir

  Güncelleme Tarihi: 15/05/2020

 ==============================================================================}
{$mode objfpc}
unit gn_panel;

interface

uses gorselnesne, paylasim, gn_gorselanayapi;

type
  PPanel = ^TPanel;
  TPanel = object(TGorselAnaYapi)
  public
    function Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
      ACizimModel: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): PPanel;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function PanelCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ACizimModel: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): TKimlik;

implementation

uses genel, gorev, gn_islevler, temelgorselnesne, gn_pencere;

{==============================================================================
    panel kesme çağrılarını yönetir
 ==============================================================================}
function PanelCagriIslevleri(AIslevNo: TSayi4; ADegiskenler: Isaretci): TISayi4;
var
  Pencere: PPencere;
  Panel: PPanel;
  Hiza: THiza;
begin

  case AIslevNo of

    ISLEV_OLUSTUR: Result := NesneOlustur(PKimlik(ADegiskenler + 00)^,
      PISayi4(ADegiskenler + 04)^, PISayi4(ADegiskenler + 08)^, PISayi4(ADegiskenler + 12)^,
      PISayi4(ADegiskenler + 16)^, PSayi4(ADegiskenler + 20)^, PRenk(ADegiskenler + 24)^,
      PRenk(ADegiskenler + 28)^, PRenk(ADegiskenler + 32)^,
      PShortString(PSayi4(ADegiskenler + 36)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      Panel := PPanel(Panel^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Panel^.Goster;
    end;

    $0104:
    begin

      Panel := PPanel(Panel^.NesneAl(PKimlik(ADegiskenler + 00)^));
      Hiza := PHiza(ADegiskenler + 04)^;
      Panel^.Hiza := Hiza;

      Pencere := PPencere(Panel^.FAtaNesne);
      Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  panel nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ACizimModel: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk;
  ABaslik: string): TKimlik;
var
  Panel: PPanel;
begin

  Panel := Panel^.Olustur(AAtaKimlik, ASol, AUst, AGenislik, AYukseklik,
    ACizimModel, AGovdeRenk1, AGovdeRenk2, AYaziRenk, ABaslik);

  if(Panel = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := Panel^.Kimlik;
end;

{==============================================================================
  panel nesnesini oluşturur
 ==============================================================================}
function TPanel.Olustur(AAtaKimlik: TKimlik; ASol, AUst, AGenislik, AYukseklik: TISayi4;
  ACizimModel: TSayi4; AGovdeRenk1, AGovdeRenk2, AYaziRenk: TRenk; ABaslik: string): PPanel;
var
  Panel: PPanel;
begin

  Panel := PPanel(inherited Olustur(gntPanel, AAtaKimlik, ASol, AUst, AGenislik,
    AYukseklik, ACizimModel, AGovdeRenk1, AGovdeRenk2, AYaziRenk, ABaslik));

  // nesnenin ad değeri
  Panel^.NesneAdi := NesneAdiAl(gntPanel);

  // nesne, alt nesne alabilecek yapıda bir ata nesne
  Panel^.FAtaNesneMi := True;

  // nesne adresini geri döndür
  Result := Panel;
end;

{==============================================================================
  panel nesnesini görüntüler
 ==============================================================================}
procedure TPanel.Goster;
begin

  inherited Goster;
end;

{==============================================================================
  panel nesnesini çizer
 ==============================================================================}
procedure TPanel.Ciz;
var
  Panel: PPanel;
  Olay: TOlayKayit;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  Panel := PPanel(Panel^.NesneTipiniKontrolEt(Kimlik, gntPanel));
  if(Panel = nil) then Exit;

  inherited Ciz;

  Olay.Kimlik := Panel^.Kimlik;
  Olay.Olay := CO_CIZIM;
  Olay.Deger1 := 0;
  Olay.Deger2 := 0;

  // uygulamaya veya efendi nesneye mesaj gönder
  if not(Panel^.FEfendiNesneOlayCagriAdresi = nil) then

    Panel^.FEfendiNesneOlayCagriAdresi(Panel^.Kimlik, Olay)

  else GorevListesi[Panel^.GorevKimlik]^.OlayEkle2(Panel^.GorevKimlik, Olay);
end;

{==============================================================================
  panel nesne olaylarını işler
 ==============================================================================}
procedure TPanel.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  Pencere: PPencere;
  Panel: PPanel;
begin

  Panel := PPanel(Panel^.NesneTipiniKontrolEt(AKimlik, gntPanel));
  if(Panel = nil) then Exit;

  // sol tuşa basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // panelin sahibi olan pencere en üstte mi ? kontrol et
    Pencere := PencereAtaNesnesiniAl(Panel);

    // en üstte olmaması durumunda en üste getir
    if(Pencere <> AktifPencere) then Pencere^.EnUsteGetir;

    // sol tuş basım işlemi olay alanında gerçekleştiyse
    if(Panel^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // fare mesajlarını pencere nesnesine yönlendir
      OlayYakalamayaBasla(Panel);

      // uygulamaya veya efendi nesneye mesaj gönder
      if not(Panel^.FEfendiNesneOlayCagriAdresi = nil) then

        Panel^.FEfendiNesneOlayCagriAdresi(Panel^.Kimlik, AOlay)

      else GorevListesi[Panel^.GorevKimlik]^.OlayEkle2(Panel^.GorevKimlik, AOlay);
    end;
  end

  // sol tuş bırakım işlemi
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // mouse mesajlarını yakalamayı bırak
    OlayYakalamayiBirak(Panel);

    // fare bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(Panel^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      // uygulamaya veya efendi nesneye mesaj gönder
      AOlay.Olay := FO_TIKLAMA;
      if not(Panel^.FEfendiNesneOlayCagriAdresi = nil) then

        Panel^.FEfendiNesneOlayCagriAdresi(Panel^.Kimlik, AOlay)

      else GorevListesi[Panel^.GorevKimlik]^.OlayEkle2(Panel^.GorevKimlik, AOlay);
    end;

    // uygulamaya veya efendi nesneye mesaj gönder
    AOlay.Olay := FO_SOLTUS_BIRAKILDI;
    if not(Panel^.FEfendiNesneOlayCagriAdresi = nil) then

      Panel^.FEfendiNesneOlayCagriAdresi(Panel^.Kimlik, AOlay)

    else GorevListesi[Panel^.GorevKimlik]^.OlayEkle2(Panel^.GorevKimlik, AOlay);
  end
  else
  begin

    // uygulamaya veya efendi nesneye mesaj gönder
    if not(Panel^.FEfendiNesneOlayCagriAdresi = nil) then

      Panel^.FEfendiNesneOlayCagriAdresi(Panel^.Kimlik, AOlay)

    else GorevListesi[Panel^.GorevKimlik]^.OlayEkle2(Panel^.GorevKimlik, AOlay);
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
