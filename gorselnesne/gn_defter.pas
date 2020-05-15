{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_defter.pas
  Dosya İşlevi: defter nesnesi (memo) yönetim işlevlerini içerir

  Güncelleme Tarihi: 13/05/2020

  Bilgi: bu görsel nesne 13.05.2020 itibariyle nesnenin program bölümüne eklenen
    40K ve çekirdek bölümüne eklenen 40K bellek kullanmaktadır.
    bu bellek miktarı şu an için gereklidir. ileride yapısallık bağlamında değiştirilebilir.

 ==============================================================================}
{$mode objfpc}
unit gn_defter;

interface

uses gorselnesne, paylasim, gn_kaydirmacubugu;

type
  PDefter = ^TDefter;
  TDefter = object(TGorselNesne)
  private
    FYatayKCubugu, FDikeyKCubugu: PKaydirmaCubugu;
    FYatayKarSay, FDikeyKarSay: TSayi4;     // yatay & dikey karakter sayısı
    procedure YatayDikeyKarakterSayisiniAl;
  public
    FDefterRenk, FYaziRenk: TRenk;
    FYaziBellekAdresi: Isaretci;
    FYaziUzunlugu: TSayi4;
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ADefterRenk, AYaziRenk: TRenk): PDefter;
    procedure YokEt(AKimlik: TKimlik);
    procedure Goster;
    procedure Ciz;
    procedure Temizle;
    procedure YaziEkle(AYaziBellekAdresi: Isaretci);
    procedure YaziEkle(ADeger: string);
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
function DefterCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses gn_islevler, gn_pencere, genel, temelgorselnesne, sistemmesaj;

{==============================================================================
  defter kesme çağrılarını yönetir
 ==============================================================================}
function DefterCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PPencere;
  _Defter: PDefter;
  _Hiza: THiza;
begin

  case IslevNo of
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PRenk(Degiskenler + 20)^, PRenk(Degiskenler + 24)^);

    ISLEV_GOSTER:
    begin

      _Defter := PDefter(_Defter^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Defter^.Goster;
    end;

    // defter nesnesine veri ekle - pchar
    $0100:
    begin

      // nesnenin handle, tip değerlerini denetle.
      _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntDefter));
      if(_Defter <> nil) then
      begin

        _Defter^.YaziEkle(Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi));
        Result := 1;
      end;
    end;

    // defter nesnesine veri ekle - string
    $0200:
    begin

      // nesnenin handle, tip değerlerini denetle.
      _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntDefter));
      if(_Defter <> nil) then
      begin

        _Defter^.YaziEkle(PKarakterKatari(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi)^);
        Result := 1;
      end;
    end;

    // defter nesnesinin içerisindeki verileri sil
    $0300:
    begin

      // nesnenin kimlik, tip değerlerini denetle.
      _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntDefter));
      if(_Defter <> nil) then
      begin

        _Defter^.Temizle;
      end;
    end;

    $0104:
    begin

      _Defter := PDefter(_Defter^.NesneAl(PKimlik(Degiskenler + 00)^));
      _Hiza := PHiza(Degiskenler + 04)^;
      _Defter^.Hiza := _Hiza;

      _Pencere := PPencere(_Defter^.FAtaNesne);
      _Pencere^.Guncelle;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik;
var
  _Defter: PDefter;
begin

  _Defter := _Defter^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ADefterRenk,
    AYaziRenk);

  if(_Defter = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _Defter^.Kimlik;
end;

{==============================================================================
  defter nesnesini oluşturur
 ==============================================================================}
function TDefter.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): PDefter;
var
  _AtaNesne: PGorselNesne;
  _Defter: PDefter;
  _YaziBellekAdresi: Isaretci;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // defter nesnesi için kimlik oluştur
  _Defter := PDefter(Olustur0(gntDefter));
  if(_Defter = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // defter nesnesini ata nesneye ekle
  if(_Defter^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _Defter^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _Defter^.GorevKimlik := CalisanGorev;
  _Defter^.AtaNesne := _AtaNesne;
  _Defter^.Hiza := hzYok;
  _Defter^.FBoyutlar.Sol2 := A1;
  _Defter^.FBoyutlar.Ust2 := B1;
  _Defter^.FBoyutlar.Genislik2 := AGenislik;
  _Defter^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _Defter^.FKalinlik.Sol := 0;
  _Defter^.FKalinlik.Ust := 0;
  _Defter^.FKalinlik.Sag := 0;
  _Defter^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _Defter^.FKenarBosluklari.Sol := 0;
  _Defter^.FKenarBosluklari.Ust := 0;
  _Defter^.FKenarBosluklari.Sag := 0;
  _Defter^.FKenarBosluklari.Alt := 0;

  _Defter^.FAtaNesneMi := False;
  _Defter^.FareGostergeTipi := fitGiris;
  _Defter^.FGorunum := False;
  _Defter^.FDefterRenk := ADefterRenk;
  _Defter^.FYaziRenk := AYaziRenk;

  // defter nesnesinin içeriği için bellek rezerv et
  _YaziBellekAdresi := GGercekBellek.Ayir(4096 * 10);
  _Defter^.FYaziBellekAdresi := _YaziBellekAdresi;

  _Defter^.FYaziUzunlugu := 0;
  _Defter^.FYatayKarSay := 0;
  _Defter^.FDikeyKarSay := 0;

  // nesnenin ad ve başlık değeri
  _Defter^.NesneAdi := NesneAdiAl(gntDefter);
  _Defter^.FBaslik := '';

  _Defter^.FYatayKCubugu := _Defter^.FYatayKCubugu^.Olustur(_Defter^.Kimlik,
    10, 10, 20, 20, yYatay);
  _Defter^.FYatayKCubugu^.FEfendiNesneOlayCagriAdresi := @OlaylariIsle;
  _Defter^.FYatayKCubugu^.FEfendiNesne := _Defter;
  _Defter^.FYatayKCubugu^.DegerleriBelirle(0, 10);

  //SISTEM_MESAJ('Yatay KÇubuk: %d', [_Defter^.FYatayKCubugu^.Kimlik]);

  _Defter^.FDikeyKCubugu := _Defter^.FDikeyKCubugu^.Olustur(_Defter^.Kimlik,
    10, 10, 20, 20, yDikey);
  _Defter^.FDikeyKCubugu^.FEfendiNesneOlayCagriAdresi := @OlaylariIsle;
  _Defter^.FDikeyKCubugu^.FEfendiNesne := _Defter;
  _Defter^.FDikeyKCubugu^.DegerleriBelirle(0, 10);

  //SISTEM_MESAJ('Dikey KÇubuk: %d', [_Defter^.FDikeyKCubugu^.Kimlik]);

  // uygulamaya mesaj gönder
  GorevListesi[_Defter^.GorevKimlik]^.OlayEkle1(_Defter^.GorevKimlik, _Defter,
    CO_OLUSTUR, 0, 0);

  // kimlik değerini geri döndür
  Result := _Defter;
end;

{==============================================================================
  nesne ve nesneye ayrılan kaynakları yok eder
 ==============================================================================}
procedure TDefter.YokEt(AKimlik: TKimlik);
var
  _Defter: PDefter;
begin

  // AtaNesne nesnesinin doğruluğunu kontrol et
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(AKimlik, gntDefter));
  if(_Defter = nil) then Exit;

  if(_Defter^.FYaziBellekAdresi <> nil) then
    GGercekBellek.YokEt(_Defter^.FYaziBellekAdresi, 4096 * 10);

  YokEt0;
end;

{==============================================================================
  defter nesnesini görüntüler
 ==============================================================================}
procedure TDefter.Goster;
var
  _Pencere: PPencere;
  _Defter: PDefter;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(Kimlik, gntDefter));
  if(_Defter = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_Defter^.FGorunum = False) then
  begin

    // defter nesnesinin görünürlüğünü aktifleştir
    _Defter^.FGorunum := True;
    _Defter^.FYatayKCubugu^.FGorunum := True;
    _Defter^.FDikeyKCubugu^.FGorunum := True;

    // defter nesnesi ve üst nesneler görünür durumda mı ?
    if(_Defter^.AtaNesneGorunurMu) then
    begin

      // görünür ise defter nesnesinin ata nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_Defter);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  defter nesnesini çizer
 ==============================================================================}
procedure TDefter.Ciz;
var
  _Pencere: PPencere;
  _Defter: PDefter;
  _Alan: TAlan;
  _A1, _B1: TISayi4;
  _YaziBellekAdresi: PChar;
  _SatirNo: TISayi4;
  _SutunNo: Integer;
  DikeySinir: TSayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _Defter := PDefter(_Defter^.NesneTipiniKontrolEt(Kimlik, gntDefter));
  if(_Defter = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_Defter);
  if(_Pencere = nil) then Exit;

  // defterin üst nesneye bağlı olarak koordinatlarını al
  _Alan := _Defter^.CizimGorselNesneBoyutlariniAl(Kimlik);

  DikeySinir := _Alan.Alt - 16 - 16;   // kaydırma çubuğu ve karakter yüksekliği

  // kenarlık çizgisini çiz
  KenarlikCiz(_Pencere, _Alan, 2);

  // iç dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.Sol + 2, _Alan.Ust + 2, _Alan.Sag - 2, _Alan.Alt - 2,
    _Defter^.FDefterRenk, _Defter^.FDefterRenk);

  // eğer defter nesnesi için bellek ayrıldıysa defter içeriğini nesne içeriğine
  // eklenen bilgilerle doldur
  if(Self.FYaziBellekAdresi <> nil) and (Self.FYaziUzunlugu > 0) then
  begin

    //SISTEM_MESAJ('Yatay Kar Say: %d, Dikey Kar Say: %d', [FYatayKarSay, FDikeyKarSay]);

    // _A1 ve _B1 başlangıç değerleri
    _A1 := _Alan.Sol + 4;
    _B1 := _Alan.Ust + 4;

    // defter içerik bellek bölgesine konumlan
    _YaziBellekAdresi := PChar(Self.FYaziBellekAdresi);

    _SatirNo := 0;
    _SutunNo := 0;

    // bellek içeriği sıfır oluncaya kadar devam et
    while (_YaziBellekAdresi^ <> #0) do
    begin

      // giriş (enter) tuşu olması durumunda herhangi birşey yapma
      if(_YaziBellekAdresi^ = #13) then
      begin

      end

      // satır başı + bir alt satıra geç
      else if(_YaziBellekAdresi^ = #10) then
      begin

        _SutunNo := 0;
        Inc(_SatirNo);
        if(_SatirNo >= _Defter^.FDikeyKCubugu^.MevcutDeger) then
        begin

          if(_SatirNo > _Defter^.FDikeyKCubugu^.MevcutDeger) then _B1 += 16;
          _A1 := _Alan.Sol + 4;
        end;
      end
      else
      begin

        if(_B1 < DikeySinir) then
        begin

          if(_SatirNo >= _Defter^.FDikeyKCubugu^.MevcutDeger) then
          begin

            if(_SutunNo >= _Defter^.FYatayKCubugu^.MevcutDeger) then
            begin

              HarfYaz(_Pencere, _A1, _B1, _YaziBellekAdresi^, _Defter^.FYaziRenk);
              _A1 += 8;
            end;

            Inc(_SutunNo);
          end;
        end;
      end;

      Inc(_YaziBellekAdresi);
    end;
  end;

  _Defter^.FYatayKCubugu^.FBoyutlar.Sol2 := _Defter^.FDisGercekBoyutlar.Sol;
  _Defter^.FYatayKCubugu^.FBoyutlar.Genislik2 := _Defter^.FDisGercekBoyutlar.Sag - _Defter^.FDisGercekBoyutlar.Sol - 16;
  _Defter^.FYatayKCubugu^.FBoyutlar.Ust2 := _Defter^.FDisGercekBoyutlar.Alt - 16;
  _Defter^.FYatayKCubugu^.FBoyutlar.Yukseklik2 := 15;
  _Defter^.FDikeyKCubugu^.FBoyutlar.Sol2 := _Defter^.FDisGercekBoyutlar.Sag - _Defter^.FDisGercekBoyutlar.Sol - 16;
  _Defter^.FDikeyKCubugu^.FBoyutlar.Genislik2 := 15;
  _Defter^.FDikeyKCubugu^.FBoyutlar.Ust2 := _Defter^.FDisGercekBoyutlar.Ust;
  _Defter^.FDikeyKCubugu^.FBoyutlar.Yukseklik2 := _Defter^.FDisGercekBoyutlar.Alt - _Defter^.FDisGercekBoyutlar.Ust - 16;

  _Defter^.FYatayKCubugu^.FDisGercekBoyutlar.Sol := _Defter^.FDisGercekBoyutlar.Sol;
  _Defter^.FYatayKCubugu^.FDisGercekBoyutlar.Sag := _Defter^.FDisGercekBoyutlar.Sag - 15;
  _Defter^.FYatayKCubugu^.FDisGercekBoyutlar.Ust := _Defter^.FDisGercekBoyutlar.Alt - 16;
  _Defter^.FYatayKCubugu^.FDisGercekBoyutlar.Alt := _Defter^.FYatayKCubugu^.FDisGercekBoyutlar.Ust + 14;
  _Defter^.FYatayKCubugu^.Ciz;

  _Defter^.FDikeyKCubugu^.FDisGercekBoyutlar.Sol := _Defter^.FDisGercekBoyutlar.Sag - 16;
  _Defter^.FDikeyKCubugu^.FDisGercekBoyutlar.Sag := _Defter^.FDikeyKCubugu^.FDisGercekBoyutlar.Sol + 14;
  _Defter^.FDikeyKCubugu^.FDisGercekBoyutlar.Ust := _Defter^.FDisGercekBoyutlar.Ust;
  _Defter^.FDikeyKCubugu^.FDisGercekBoyutlar.Alt := _Defter^.FDisGercekBoyutlar.Alt - 15;
  _Defter^.FDikeyKCubugu^.Ciz;
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
  _Uzunluk: TSayi4;
begin

  // karakter katarı için bellek ayrılmış mı ?
  if(Self.FYaziBellekAdresi = nil) then Exit;

  // verinin uzunluğunu al
  _Uzunluk := StrLen(AYaziBellekAdresi);
  if(_Uzunluk = 0) or (_Uzunluk > (4096 * 10)) then Exit;

  //SISTEM_MESAJ('Uzunluk: %d', [_Uzunluk]);

  // karakter katarını hedef bölgeye kopyala
  p := PByte(Self.FYaziBellekAdresi + FYaziUzunlugu);
  Tasi2(AYaziBellekAdresi, p, _Uzunluk);

  // sıfır sonlandırma işaretini ekle
  FYaziUzunlugu += _Uzunluk;
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
  _Uzunluk: TSayi4;
begin

  // karakter katarı için bellek ayrılmış mı ?
  if(FYaziBellekAdresi = nil) then Exit;

  // verinin uzunluğunu al
  _Uzunluk := Length(ADeger);
  if(_Uzunluk = 0) or (_Uzunluk > (4096 * 10)) then Exit;

  // karakter katarını hedef bölgeye kopyala
  p := PByte(TSayi4(FYaziBellekAdresi) + FYaziUzunlugu);
  Tasi2(@ADeger[1], p, _Uzunluk);

  // sıfır sonlandırma işaretini ekle
  FYaziUzunlugu += _Uzunluk;
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

  FYatayKCubugu^.UstDeger := FYatayKarSay;
  FDikeyKCubugu^.UstDeger := FDikeyKarSay;

  //SISTEM_MESAJ(' - Yatay Kar Say: %d, Dikey Kar Say: %d', [FYatayKarSay, FDikeyKarSay]);
end;

{==============================================================================
  defter nesne olaylarını işler
 ==============================================================================}
procedure TDefter.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _NesneTipi: TGorselNesneTipi;
  _Pencere: PPencere;
  _Defter: PDefter;
  _KaydirmaCubugu: PKaydirmaCubugu;
begin

  _NesneTipi := _Defter^.NesneTipiniAl(AKimlik);
  if(_NesneTipi = gntDefter) then

    _Defter := PDefter(_Defter^.NesneAl(AKimlik))
  else if(_NesneTipi = gntKaydirmaCubugu) then
  begin

    _KaydirmaCubugu := PKaydirmaCubugu(_KaydirmaCubugu^.NesneAl(AKimlik));
    _Defter := PDefter(_KaydirmaCubugu^.FEfendiNesne);
  end else Exit;

  if(AOlay.Kimlik = _Defter^.Kimlik) then
  begin

    // sol mouse tuş basımı
    if(AOlay.Olay = FO_SOLTUS_BASILDI) then
    begin

      // defterin sahibi olan pencere en üstte mi ? kontrol et
      _Pencere := PencereAtaNesnesiniAl(_Defter);

      // en üstte olmaması durumunda en üste getir
      if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;
    end;

    // uygulamaya mesaj gönder
    GorevListesi[_Defter^.GorevKimlik]^.OlayEkle1(_Defter^.GorevKimlik, _Defter,
      AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  else if(AOlay.Kimlik = _Defter^.FYatayKCubugu^.Kimlik) then
  begin

    //SISTEM_MESAJ('Yatay Değer: %d', [_Defter^.FYatayKCubugu^.MevcutDeger]);
    _Defter^.Ciz;
  end
  else if(AOlay.Kimlik = _Defter^.FDikeyKCubugu^.Kimlik) then
  begin

    //SISTEM_MESAJ('Dikey Değer: %d', [_Defter^.FDikeyKCubugu^.MevcutDeger]);
    _Defter^.Ciz;
  end else SISTEM_MESAJ('Defter Kimlik: %d', [AOlay.Kimlik]);

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
