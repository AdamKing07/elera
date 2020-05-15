{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_degerdugmesi.pas
  Dosya İşlevi: artırma / eksiltme (updown) düğme yönetim işlevlerini içerir

  Güncelleme Tarihi: 06/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_degerdugmesi;

interface

uses gorselnesne, paylasim;

type
  PDegerDugmesi = ^TDegerDugmesi;
  TDegerDugmesi = object(TGorselNesne)
  private
    FDurum: TDugmeDurumu;
    FUstDugmeyeBasildi: Boolean;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PDegerDugmesi;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
    procedure DugmeleriCiz(AAlan: TAlan; AUstDugmeyeBasildi, AAltDugmeyeBasildi: Boolean);
  end;

function DegerDugmesiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;

implementation

uses genel, gn_pencere, gn_islevler, temelgorselnesne, hamresim2;

{==============================================================================
  artırma / eksiltme (updown) düğme kesme çağrılarını yönetir
 ==============================================================================}
function DegerDugmesiCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _DegerDugmesi: PDegerDugmesi;
begin

  case IslevNo of

    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^);

    ISLEV_GOSTER:
    begin

      _DegerDugmesi := PDegerDugmesi(_DegerDugmesi^.NesneAl(PKimlik(Degiskenler + 00)^));
      _DegerDugmesi^.Goster;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  artırma / eksiltme (updown) düğme nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik;
var
  _DegerDugmesi: PDegerDugmesi;
begin

  _DegerDugmesi := _DegerDugmesi^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik);

  if(_DegerDugmesi = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _DegerDugmesi^.Kimlik;
end;

{==============================================================================
  artırma / eksiltme (updown) düğme nesnesini oluşturur
 ==============================================================================}
function TDegerDugmesi.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): PDegerDugmesi;
var
  _AtaNesne: PGorselNesne;
  _DegerDugmesi: PDegerDugmesi;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // düğme için bellekte yer ayır
  _DegerDugmesi := PDegerDugmesi(Olustur0(gntDegerDugmesi));
  if(_DegerDugmesi = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // düğme nesnesini üst nesneye ekle
  if(_DegerDugmesi^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _DegerDugmesi^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _DegerDugmesi^.GorevKimlik := CalisanGorev;
  _DegerDugmesi^.AtaNesne := _AtaNesne;
  _DegerDugmesi^.Hiza := hzYok;
  _DegerDugmesi^.FBoyutlar.Sol2 := A1;
  _DegerDugmesi^.FBoyutlar.Ust2 := B1;
  _DegerDugmesi^.FBoyutlar.Genislik2 := 17;   //AGenislik;    // öndeğerler. şu aşamada kullanıcı, nesnenin
  _DegerDugmesi^.FBoyutlar.Yukseklik2 := 21;  //AYukseklik;   // genişlik ve yükseklik değerlerini değiştirmeyecek

  // kenar kalınlıkları
  _DegerDugmesi^.FKalinlik.Sol := 0;
  _DegerDugmesi^.FKalinlik.Ust := 0;
  _DegerDugmesi^.FKalinlik.Sag := 0;
  _DegerDugmesi^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _DegerDugmesi^.FKenarBosluklari.Sol := 0;
  _DegerDugmesi^.FKenarBosluklari.Ust := 0;
  _DegerDugmesi^.FKenarBosluklari.Sag := 0;
  _DegerDugmesi^.FKenarBosluklari.Alt := 0;

  _DegerDugmesi^.FAtaNesneMi := False;
  _DegerDugmesi^.FareGostergeTipi := fitOK;
  _DegerDugmesi^.FGorunum := False;
  _DegerDugmesi^.FDurum := ddNormal;

  // nesnenin ad ve başlık değeri
  _DegerDugmesi^.NesneAdi := NesneAdiAl(gntDegerDugmesi);
  _DegerDugmesi^.FBaslik := '';

  // uygulamaya mesaj gönder
  GorevListesi[_DegerDugmesi^.GorevKimlik]^.OlayEkle1(_DegerDugmesi^.GorevKimlik,
    _DegerDugmesi, CO_OLUSTUR, 0, 0);

  // nesne adresini geri döndür
  Result := _DegerDugmesi;
end;

{==============================================================================
  artırma / eksiltme (updown) düğme nesnesini görüntüler
 ==============================================================================}
procedure TDegerDugmesi.Goster;
var
  _Pencere: PPencere;
  _DegerDugmesi: PDegerDugmesi;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _DegerDugmesi := PDegerDugmesi(_DegerDugmesi^.NesneTipiniKontrolEt(Kimlik, gntDegerDugmesi));
  if(_DegerDugmesi = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_DegerDugmesi^.FGorunum = False) then
  begin

    // düğme nesnesinin görünürlüğünü aktifleştir
    _DegerDugmesi^.FGorunum := True;

    // düğme nesnesi ve üst nesneler görünür durumda mı ?
    if(_DegerDugmesi^.AtaNesneGorunurMu) then
    begin

      // görünür ise düğme nesnesinin üst nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_DegerDugmesi);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  artırma / eksiltme (updown) düğme nesnesini çizer
 ==============================================================================}
procedure TDegerDugmesi.Ciz;
var
  _DegerDugmesi: PDegerDugmesi;
  _Alan: TAlan;
begin

  _DegerDugmesi := PDegerDugmesi(_DegerDugmesi^.NesneTipiniKontrolEt(Kimlik, gntDegerDugmesi));
  if(_DegerDugmesi = nil) then Exit;

  // düğmenin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _DegerDugmesi^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // düğmenin normal çizimi
  if(_DegerDugmesi^.FDurum = ddNormal) then
  begin

    DugmeleriCiz(_Alan, False, False);
  end
  else if(_DegerDugmesi^.FDurum = ddBasili) then
  begin

    if(FUstDugmeyeBasildi) then

      DugmeleriCiz(_Alan, True, False)
    else DugmeleriCiz(_Alan, False, True);
  end;

  // uygulamaya mesaj gönder
  GorevListesi[_DegerDugmesi^.GorevKimlik]^.OlayEkle1(_DegerDugmesi^.GorevKimlik,
    _DegerDugmesi, CO_CIZIM, 0, 0);
end;

{==============================================================================
  artırma / eksiltme kontrol düğmelerini çizer
 ==============================================================================}
procedure TDegerDugmesi.DugmeleriCiz(AAlan: TAlan; AUstDugmeyeBasildi, AAltDugmeyeBasildi: Boolean);
var
  _Pencere: PPencere;
  _DegerDugmesi: PDegerDugmesi;
  _Alan: TAlan;
  _Orta, A1, B1, i: TISayi4;
  p1: PSayi1;
begin

  _DegerDugmesi := PDegerDugmesi(_DegerDugmesi^.NesneTipiniKontrolEt(Kimlik, gntDegerDugmesi));
  if(_DegerDugmesi = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_DegerDugmesi);
  if(_Pencere = nil) then Exit;

  _Orta := (AAlan.Alt - AAlan.Ust - 1) div 2;
  _Alan.Sol := AAlan.Sol;
  _Alan.Ust := AAlan.Ust;
  _Alan.Sag := AAlan.Sag;
  _Alan.Alt := AAlan.Ust + _Orta;

  if(AUstDugmeyeBasildi) then
   i := 5
  else i := 4;

  p1 := PByte(@OKUst);
  for B1 := 1 to 4 do
  begin

    for A1 := 1 to 7 do
    begin

      if(p1^ = 1) then
        PixelYaz(_Pencere, _Alan.Sol + i + A1, _Alan.Ust + 2 + B1, RENK_SIYAH);

      Inc(p1);
    end;
  end;

  _Alan.Sol := AAlan.Sol;
  _Alan.Ust := AAlan.Alt - _Orta;
  _Alan.Sag := AAlan.Sag;
  _Alan.Alt := AAlan.Alt;

  if(AAltDugmeyeBasildi) then
    i := 5
  else i := 4;

  p1 := PByte(@OKAlt);
  for B1 := 1 to 4 do
  begin

    for A1 := 1 to 7 do
    begin

      if(p1^ = 1) then
        PixelYaz(_Pencere, _Alan.Sol + i + A1, _Alan.Ust + 2 + B1, RENK_SIYAH);

      Inc(p1);
    end;
  end;
end;

{==============================================================================
  artırma / eksiltme (updown) düğme nesne olaylarını işler
 ==============================================================================}
procedure TDegerDugmesi.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _DegerDugmesi: PDegerDugmesi;
  _Alan: TAlan;
  _Orta: TISayi4;
begin

  _DegerDugmesi := PDegerDugmesi(_DegerDugmesi^.NesneTipiniKontrolEt(AKimlik, gntDegerDugmesi));
  if(_DegerDugmesi = nil) then Exit;

  // farenin sol tuşuna basım işlemi
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // nesnenin sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_DegerDugmesi);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // üst tuşa basılmış mı?
    _Orta := (_DegerDugmesi^.FBoyutlar.Alt - 1) div 2;
    _Alan.Sol := 0;
    _Alan.Ust := 0;
    _Alan.Sag := _DegerDugmesi^.FBoyutlar.Sag;
    _Alan.Alt := _Orta;
    if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _Alan)) then
    begin

      // fare olaylarını yakala
      OlayYakalamayaBasla(_DegerDugmesi);

      // nesnenin durumunu BASILDI olarak belirle
      _DegerDugmesi^.FDurum := ddBasili;
      _DegerDugmesi^.FUstDugmeyeBasildi := True;
    end;

    // alt tuşa basılmış mı?
    if not(_DegerDugmesi^.FUstDugmeyeBasildi) then
    begin

      _Alan.Sol := 0;
      _Alan.Ust := _Orta + 2;
      _Alan.Sag := _DegerDugmesi^.FBoyutlar.Sag;
      _Alan.Alt := _DegerDugmesi^.FBoyutlar.Alt;
      if(NoktaAlanIcerisindeMi(AOlay.Deger1, AOlay.Deger2, _Alan)) then
      begin

        // fare olaylarını yakala
        OlayYakalamayaBasla(_DegerDugmesi);

        // nesnenin durumunu BASILDI olarak belirle
        _DegerDugmesi^.FDurum := ddBasili;
        _DegerDugmesi^.FUstDugmeyeBasildi := False;
      end;
    end;

    // nesneyi yeniden çiz
    _DegerDugmesi^.Ciz;
  end
  else if(AOlay.Olay = FO_SOLTUS_BIRAKILDI) then
  begin

    // farenin tuş bırakma işlemi nesnenin olay alanında mı gerçekleşti ?
    if(_DegerDugmesi^.FareNesneOlayAlanindaMi(AKimlik)) then
    begin

      if(_DegerDugmesi^.FUstDugmeyeBasildi) then

        GorevListesi[_DegerDugmesi^.GorevKimlik]^.OlayEkle1(_DegerDugmesi^.GorevKimlik,
          _DegerDugmesi, FO_TIKLAMA, 0, 0)
      else GorevListesi[_DegerDugmesi^.GorevKimlik]^.OlayEkle1(_DegerDugmesi^.GorevKimlik,
        _DegerDugmesi, FO_TIKLAMA, 1, 0);
    end;

    // FO_SOLTUS_BASILDI değerini buradan almakta. sakın iptal etme!
    _DegerDugmesi^.FUstDugmeyeBasildi := False;

    // nesne düğme durumunu normal duruma çevir
    _DegerDugmesi^.FDurum := ddNormal;

    // nesneyi yeniden çiz
    _DegerDugmesi^.Ciz;

    // fare olaylarını almayı bırak
    OlayYakalamayiBirak(_DegerDugmesi);
  end
  else if(AOlay.Olay = FO_HAREKET) then
  begin

    // eğer nesne yakalanmış ve
    // 1 - fare göstergesi düğmenin içerisindeyse
    // 2 - fare göstergesi düğmenin dışarısındaysa
    // koşula göre düğmenin durumunu yeniden çiz ...
    if(YakalananGorselNesne <> nil) then
    begin

      if(_DegerDugmesi^.FareNesneOlayAlanindaMi(AKimlik)) then

        _DegerDugmesi^.FDurum := ddBasili
      else _DegerDugmesi^.FDurum := ddNormal;
    end;

    // düğme nesnesini yeniden çiz
    _DegerDugmesi^.Ciz;

    {GorevListesi[_DegerDugmesi^.GorevKimlik]^.OlayEkle1(_DegerDugmesi^.GorevKimlik,
      _DegerDugmesi, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);}
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
