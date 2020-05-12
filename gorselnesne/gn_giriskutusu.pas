{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gn_giriskutusu.pas
  Dosya ��levi: d�zenleme kutusu (edit) y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 12/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_giriskutusu;

interface

uses gorselnesne, paylasim, gn_dugme;

type
  PGirisKutusu = ^TGirisKutusu;
  TGirisKutusu = object(TGorselNesne)
  private
    FSilDugmesi: PDugme;
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

uses gn_islevler, gn_pencere, genel, temelgorselnesne, sistemmesaj;

{==============================================================================
  d�zenleme kutusu kesme �a�r�lar�n� y�netir
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

    // d�zenleme kutusundaki veriyi programa g�nder
    $0102:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p1 := PShortString(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      p1^ := _GirisKutusu^.Baslik;
    end;

    // d�zenleme kutusunun salt okunur �zelli�ini de�i�tir
    $0204:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p2 := PLongBool(Degiskenler + 04);
      _GirisKutusu^.FYazilamaz := p2^;
      _GirisKutusu^.Ciz;
    end;

    // d�zenleme kutusunun say�sal (numeric) de�er �zelli�ini de�i�tir
    $0304:
    begin

      _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(PKimlik(Degiskenler + 00)^));
      p2 := PLongBool(Degiskenler + 04);
      _GirisKutusu^.FSadeceRakam := p2^;
    end;

    // d�zenleme kutusundaki veriyi de�i�tir
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
  d�zenleme kutusu nesnesini olu�turur
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
  d�zenleme kutusu nesnesini olu�turur
 ==============================================================================}
function TGirisKutusu.Olustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ABaslik: string): PGirisKutusu;
var
  _AtaNesne: PGorselNesne;
  _GirisKutusu: PGirisKutusu;
begin

  // nesnenin ba�lanaca�� ata nesneyi al
  _AtaNesne := PGorselNesne(_AtaNesne^.AtaNesneyiAl(AAtaKimlik));
  if(_AtaNesne = nil) then Exit;

  // d�zenleme kutusu nesnesi i�in Kimlik olu�tur
  _GirisKutusu := PGirisKutusu(Olustur0(gntGirisKutusu));
  if(_GirisKutusu = nil) then
  begin

    Result := nil;
    Exit;
  end;

  // d�zenleme kutusu nesnesini AtaNesne nesnesine ekle
  if(_GirisKutusu^.AtaNesneyeEkle(_AtaNesne) = False) then
  begin

    // hata olmas� durumunda nesneyi yok et ve hata koduyla i�levden ��k
    _GirisKutusu^.YokEt0;
    Result := nil;
    Exit;
  end;

  // nesne de�erlerini ata
  _GirisKutusu^.GorevKimlik := CalisanGorev;
  _GirisKutusu^.AtaNesne := _AtaNesne;
  _GirisKutusu^.Hiza := hzYok;
  _GirisKutusu^.FBoyutlar.Sol2 := A1;
  _GirisKutusu^.FBoyutlar.Ust2 := B1;
  _GirisKutusu^.FBoyutlar.Genislik2 := AGenislik;
  _GirisKutusu^.FBoyutlar.Yukseklik2 := AYukseklik;

  // kenar kal�nl�klar�
  _GirisKutusu^.FKalinlik.Sol := 0;
  _GirisKutusu^.FKalinlik.Ust := 0;
  _GirisKutusu^.FKalinlik.Sag := 0;
  _GirisKutusu^.FKalinlik.Alt := 0;

  // kenar bo�luklar�
  _GirisKutusu^.FKenarBosluklari.Sol := 0;
  _GirisKutusu^.FKenarBosluklari.Ust := 0;
  _GirisKutusu^.FKenarBosluklari.Sag := 0;
  _GirisKutusu^.FKenarBosluklari.Alt := 0;

  _GirisKutusu^.FAtaNesneMi := False;
  _GirisKutusu^.FareGostergeTipi := fitGiris;
  _GirisKutusu^.Gorunum := False;
  _GirisKutusu^.FYazilamaz := False;
  _GirisKutusu^.FSadeceRakam := False;

  // nesnenin ad ve ba�l�k de�eri
  _GirisKutusu^.NesneAdi := NesneAdiAl(gntGirisKutusu);
  _GirisKutusu^.Baslik := ABaslik;
  _GirisKutusu^.FEfendiNesneOlayCagriAdresi := @OlaylariIsle;

  _GirisKutusu^.FSilDugmesi := _GirisKutusu^.FSilDugmesi^.Olustur(_GirisKutusu^.Kimlik,
    10, 10, 20, 20, 'x');
  _GirisKutusu^.FSilDugmesi^.RenkBelirle(RENK_BEYAZ, RENK_SIYAH);
  _GirisKutusu^.FSilDugmesi^.FEfendiNesneOlayCagriAdresi := @OlaylariIsle;
  _GirisKutusu^.FSilDugmesi^.FEfendiNesne := _GirisKutusu;

  // uygulamaya mesaj g�nder
  GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
    _GirisKutusu, CO_OLUSTUR, 0, 0);

  // kimlik de�erini geri d�nd�r
  Result := _GirisKutusu;
end;

{==============================================================================
  d�zenleme kutusu nesnesini g�r�nt�ler
 ==============================================================================}
procedure TGirisKutusu.Goster;
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneTipiniKontrolEt(Kimlik, gntGirisKutusu));
  if(_GirisKutusu = nil) then Exit;

  // nesne g�r�n�r durumda m� ?
  if(_GirisKutusu^.Gorunum = False) then
  begin

    // d�zenleme kutusu nesnesinin g�r�n�rl���n� aktifle�tir
    _GirisKutusu^.Gorunum := True;
    _GirisKutusu^.FSilDugmesi^.Gorunum := True;

    // d�zenleme kutusu nesnesi ve �st nesneler g�r�n�r durumda m� ?
    if(_GirisKutusu^.AtaNesneGorunurMu) then
    begin

      // g�r�n�r ise d�zenleme kutusu nesnesinin ata nesnesi olan pencere nesnesini al
      _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);

      // pencere nesnesini yenile
      _Pencere^.Guncelle;
    end;
  end;
end;

{==============================================================================
  d�zenleme kutusu nesnesini �izer
 ==============================================================================}
procedure TGirisKutusu.Ciz;
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
  _Alan: TAlan;
begin

  // nesnenin kimlik, tip de�erlerini denetle.
  _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneTipiniKontrolEt(Kimlik, gntGirisKutusu));
  if(_GirisKutusu = nil) then Exit;

  // ata nesne bir pencere mi?
  _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);
  if(_Pencere = nil) then Exit;

  // giri� kutusunun �st nesneye ba�l� olarak koordinatlar�n� al
  _Alan := _GirisKutusu^.CizimGorselNesneBoyutlariniAl(Kimlik);

  // kenarl�k �iz
  KenarlikCiz(_Pencere, _Alan, 1);

  // i� dolgu rengi
  DikdortgenDoldur(_Pencere, _Alan.A1 + 1, _Alan.B1 + 1, _Alan.A2 - 1, _Alan.B2 - 1,
    RENK_BEYAZ, RENK_BEYAZ);

  // nesnenin i�erik de�eri. #255 = klavye kurs�r�
  if(FYazilamaz) then

    YaziYaz(_Pencere, _Alan.A1+4, _Alan.B1+5, _GirisKutusu^.Baslik, RENK_SIYAH)
  else YaziYaz(_Pencere, _Alan.A1+4, _Alan.B1+5, _GirisKutusu^.Baslik + #255, RENK_SIYAH);

  // nesne i�ine nesne eklendi�inde:
  // 1 - eklenecek nesne i�in �izim alan� tahsis edilecek
  // 2 - nesnenin eklenece�i �st nesnenin �izim alan� s�n�rland�r�lacak
  _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.A1 := _GirisKutusu^.FDisGercekBoyutlar.A2 - 20;
  _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.B1 := _GirisKutusu^.FDisGercekBoyutlar.B1 + 1;
  _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.A2 := _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.A1 + 19;
  _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.B2 := _GirisKutusu^.FSilDugmesi^.FDisGercekBoyutlar.B1 + 19;

  _GirisKutusu^.FSilDugmesi^.Ciz;
end;

{==============================================================================
  d�zenleme kutusu nesne olaylar�n� i�ler
 ==============================================================================}
procedure TGirisKutusu.OlaylariIsle(AKimlik: TKimlik; AOlay: TOlayKayit);
var
  _Pencere: PPencere;
  _GirisKutusu: PGirisKutusu;
  C: Char;
  s: string;
  _Tus: TISayi4;
  _NesneTipi: TGorselNesneTipi;
  _Dugme: PDugme;
begin

  _NesneTipi := _GirisKutusu^.NesneTipiAl(AKimlik);
  if(_NesneTipi = gntGirisKutusu) then

    _GirisKutusu := PGirisKutusu(_GirisKutusu^.NesneAl(AKimlik))
  else if(_NesneTipi = gntDugme) then
  begin

    _Dugme := PDugme(_Dugme^.NesneAl(AKimlik));
    _GirisKutusu := PGirisKutusu(_Dugme^.FEfendiNesne);
  end else Exit;

  // fare sol tu� bas�m�
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    // d�zenleme kutusunun sahibi olan pencere en �stte mi ? kontrol et
    _Pencere := PencereAtaNesnesiniAl(_GirisKutusu);

    // en �stte olmamas� durumunda en �ste getir
    if(_Pencere <> AktifPencere) then _Pencere^.EnUsteGetir;

    // uygulamaya mesaj g�nder
    GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
      _GirisKutusu, AOlay.Olay, AOlay.Deger1, AOlay.Deger2);
  end
  // silme d��mesine t�klama ger�ekle�tirildi�inde
  else if(AOlay.Olay = FO_TIKLAMA) and (AOlay.Kimlik = _Dugme^.Kimlik) then
  begin

    _GirisKutusu^.Baslik := '';
    _GirisKutusu^.Ciz;
  end
  // klavye tu� bas�m�
  else if(_NesneTipi = gntGirisKutusu) and (AOlay.Olay = CO_TUSBASILDI) then
  begin

    _Tus := (AOlay.Deger1 and $FF);

    if not(FYazilamaz) then
    begin

      C := Char(_Tus);

      // enter tu�u
      if(C = #10) then
      begin

        // enter tu�una bas�lma mesaj�n� nesneye g�nder
        GorevListesi[_GirisKutusu^.GorevKimlik]^.OlayEkle1(_GirisKutusu^.GorevKimlik,
          _GirisKutusu, AOlay.Olay, _Tus, AOlay.Deger2);
      end
      // geri silme tu�u
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

          if(C in ['0'..'9', 'A'..'F', 'a'..'f']) then
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

  // ge�erli fare g�stergesini g�ncelle
  GecerliFareGostegeTipi := FareGostergeTipi;
end;

end.
