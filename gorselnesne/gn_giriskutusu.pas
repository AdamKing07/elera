{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_giriskutusu.pas
  Dosya İşlevi: düzenleme kutusu (edit) yönetim işlevlerini içerir

  Güncelleme Tarihi: 07/11/2019

 ==============================================================================}
{$mode objfpc}
unit gn_giriskutusu;

interface

uses gorselnesne, paylasim;

type
  PGirisKutusu = ^TGirisKutusu;
  TGirisKutusu = object(TGorselNesne)
  private
    FYazilamaz: Boolean;
    FSadeceRakam: Boolean;
  public
    function Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
      ABaslik: string): PGirisKutusu;
    procedure Goster;
    procedure Ciz;
    procedure OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
  end;

function GirisKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;

implementation

uses gn_islevler, gn_pencere, genel, temelgorselnesne;

{==============================================================================
  düzenleme kutusu kesme çağrılarını yönetir
 ==============================================================================}
function GirisKutusuCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _GirisKutusu: PGirisKutusu;
  p1: PShortString;
  p2: PLongBool;
begin

  case IslevNo of
    ISLEV_OLUSTUR:

      Result := NesneOlustur(PKimlik(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^,
        PISayi4(Degiskenler + 08)^, PISayi4(Degiskenler + 12)^, PISayi4(Degiskenler + 16)^,
        PShortString(PSayi4(Degiskenler + 20)^ + AktifGorevBellekAdresi)^);

    ISLEV_GOSTER:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      _GirisKutusu^.Goster;
    end;

    // düzenleme kutusundaki veriyi programa gönder
    $0102:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      p1^ := _GirisKutusu^.Baslik;
    end;

    // düzenleme kutusunun salt okunur özelliğini değiştir
    $0204:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p2 := PLongBool(Degiskenler + 04);
      _GirisKutusu^.FYazilamaz := p2^;
      _GirisKutusu^.Ciz;
    end;

    // düzenleme kutusunun sayısal (numeric) değer özelliğini değiştir
    $0304:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p2 := PLongBool(Degiskenler + 04);
      _GirisKutusu^.FSadeceRakam := p2^;
    end;

    // düzenleme kutusundaki veriyi değiştir
    $0404:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      _GirisKutusu^.Baslik := p1^;
      _GirisKutusu^.Ciz;
    end

    else Result := HATA_ISLEV;
  end;
end;

{==============================================================================
  düzenleme kutusu nesnesini oluşturur
 ==============================================================================}
function NesneOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): TKimlik;
var
  _GirisKutusu: PGirisKutusu;
begin

  _GirisKutusu := _GirisKutusu^.Olustur(AAtaKimlik, A1, B1, AGenislik, AYukseklik, ABaslik);

  if(_GirisKutusu = nil) then

    Result := HATA_NESNEOLUSTURMA
  else Result := _GirisKutusu^.Kimlik;
end;

{==============================================================================
  düzenleme kutusu nesnesini oluşturur
 ==============================================================================}
function TGirisKutusu.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): PGirisKutusu;
var
  _AtaNesne: PGorselNesne;
  _GirisKutusu: PGirisKutusu;
begin

  // nesnenin bağlanacağı ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // düzenleme kutusu nesnesi için Kimlik oluştur
  _GirisKutusu := PGirisKutusu(Olustur0(gntGirisKutusu));
  if(_GirisKutusu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // düzenleme kutusu nesnesini AtaNesne nesnesine ekle
  if(_GirisKutusu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olması durumunda nesneyi yok et ve hata koduyla işlevden çık
    _GirisKutusu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne değerlerini ata
  _GirisKutusu^.GorevKimlik := AktifGorev;
  _GirisKutusu^.AtaNesne := _AtaNesne;
  _GirisKutusu^.Hiza := hzYok;
  _GirisKutusu^.FBoyutlar.Sol2 := A1;
  _GirisKutusu^.FBoyutlar.Ust2 := B1;
  _GirisKutusu^.FBoyutlar.Genislik2 := AGenislik;
  _GirisKutusu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kalınlıkları
  _GirisKutusu^.FKalinlik.Sol := 0;
  _GirisKutusu^.FKalinlik.Ust := 0;
  _GirisKutusu^.FKalinlik.Sag := 0;
  _GirisKutusu^.FKalinlik.Alt := 0;

  // kenar boşlukları
  _GirisKutusu^.FKenarBosluklari.Sol := 0;
  _GirisKutusu^.FKenarBosluklari.Ust := 0;
  _GirisKutusu^.FKenarBosluklari.Sag := 0;
  _GirisKutusu^.FKenarBosluklari.Alt := 0;

  _GirisKutusu^.FAtaNesneMi := False;
  _GirisKutusu^.FareGostergeTipi := fitGiris;
  _GirisKutusu^.Gorunum := False;
  _GirisKutusu^.FYazilamaz := False;
  _GirisKutusu^.FSadeceRakam := False;

  // nesnenin ad ve başlık değeri
  _GirisKutusu^.NesneAdi := NesneAdiAl(gntGirisKutusu);
  _GirisKutusu^.Baslik := ABaslik;

  // uygulamaya mesaj gönder
  GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
    _GirisKutusu, CO_OLUSTUR, 0, 0);

  // kimlik değerini geri döndür
  Result := _GirisKutusu;
end;

{==============================================================================
  düzenleme kutusu nesnesini görüntüler
 ==============================================================================}
procedure TGirisKutusu.Goster;
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneTipiniKontrolEt(Kimlik, gntGirisKutusu));
  if(_GirisKutusu = nil) then Exit;

  // nesne görünür durumda mı ?
  if(_GirisKutusu^.Gorunum = False) then
  begin

    // düzenleme kutusu nesnesinin görünürlüğünü aktifleştir
    _GirisKutusu^.Gorunum := True;

    // düzenleme kutusu nesnesi ve üst nesneler görünür durumda mı ?
    if(_GirisKutusu^.AtaNesneGorunurMu) then
    begin

      // görünür ise düzenleme kutusu nesnesinin ata nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  düzenleme kutusu nesnesini çizer
 ==============================================================================}
procedure TGirisKutusu.Ciz;
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
  _Alan: TAlan;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneTipiniKontrolEt(Kimlik, gntGirisKutusu));
  if(_GirisKutusu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);
  if(_Pencere = nil) then Exit;

  // giriş kutusunun üst nesneye bağlı olarak koordinatlarını al
  _Alan := _GirisKutusu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarlık çiz
  KenarlikCiz(_Pencere, _Alan, 1);

  // iç dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.A1 + 1, _Alan.B1 + 1, _Alan.A2 - 1, _Alan.B2 - 1,
    RENK_BEYAZ, RENK_BEYAZ);

  // nesnenin içerik değeri. #255 = klavye kursörü
  if(FYazilamaz) then

    YaziYaz(_Pencere, _Alan.A1+4, _Alan.B1+5, _GirisKutusu^.Baslik, RENK_SIYAH)
  else YaziYaz(_Pencere, _Alan.A1+4, _Alan.B1+5, _GirisKutusu^.Baslik + #255, RENK_SIYAH);
end;

{==============================================================================
  düzenleme kutusu nesne olaylarını işler
 ==============================================================================}
procedure TGirisKutusu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
  C: Char;
  s: string;
  _Tus: TISayi4;
begin

  // nesnenin kimlik, tip değerlerini denetle.
  _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneTipiniKontrolEt(AKimlik, gntGirisKutusu));
  if(_GirisKutusu = nil) then Exit;

  // fare sol tuş basımı
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // düzenleme kutusunun sahibi olan pencere en üstte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);

    // en üstte olmaması durumunda en üste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // uygulamaya mesaj gönder
    GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
      _GirisKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end

  // klavye tuş basımı
  else if(AOlay.Olay = CO_TUSBASILDI) then
  begin

    _Tus := (AOlay.Deger1 and $FF);

    if not(FYazilamaz) then
    begin

      C := Char(_Tus);

      // enter tuşu
      if(C = #10) then
      begin

        // enter tuşuna basılma mesajını nesneye gönder
        GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
          _GirisKutusu, AOlay.Olay, _Tus, AOlay.Deger2);
      end
      // geri silme tuşu
      else if(C = #8) then
      begin

        s := _GirisKutusu^.Baslik;
        if(Length(s) = 1) then

          s := ''
        else
        begin

          s := Copy(s, 1, Length(s) - 1);
        end;
        _GirisKutusu^.Baslik := s;

        GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
          _GirisKutusu, AOlay.Olay, _Tus, AOlay.Deger2);
      end
      else
      begin

        if(FSadeceRakam) then
        begin

          if(C in ['0'..'9']) then
          begin

            _GirisKutusu^.Baslik := _GirisKutusu^.Baslik + C;
            GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
              _GirisKutusu, AOlay.Olay, _Tus, AOlay.Deger2);
          end;
        end
        else
        begin

          _GirisKutusu^.Baslik := _GirisKutusu^.Baslik + C;
          GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
            _GirisKutusu, AOlay.Olay, _Tus, AOlay.Deger2);
        end;
      end;

      Ciz;
    end;
  end;

  // geçerli fare göstergesini güncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
