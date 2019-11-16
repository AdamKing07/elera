{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: fat32.pas
  Dosya İşlevi: fat32 dosya sistem yönetim işlevlerini yönetir

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
unit fat32;

interface

uses paylasim;

procedure AssignFile(var ADosyaKimlik: TKimlik; const ADosyaAdi: string);
procedure Reset(ADosyaKimlik: TKimlik);
function EOF(ADosyaKimlik: TKimlik): Boolean;
function FileSize(ADosyaKimlik: TKimlik): TISayi4;
procedure Read(ADosyaKimlik: TKimlik; AHedefBellek: Isaretci);
procedure CloseFile(ADosyaKimlik: TKimlik);
function FindFirst(const AAramaSuzgec: string; ADosyaOzellik: TSayi2;
  var ADosyaArama: TDosyaArama): TISayi4;
function FindNext(var ADosyaArama: TDosyaArama): TISayi4;
function FindClose(var ADosyaArama: TDosyaArama): TISayi4;
function DizinGirdisiOku(ADizinGirisi: PDizinGirisi; AAranacakDeger: string;
  var ADosyaArama: TDosyaArama): TSayi1;
procedure DosyaParcalariniBirlestir(WCArray: Isaretci);
procedure DosyaParcasiniBasaEkle(AEklenecekVeri, AHedefBellek: Isaretci);

implementation

uses genel, donusum, gercekbellek;

var
  DizinBellekAdresi: array[0..511] of TSayi1;
  UzunDosyaAdi: array[0..514] of Char;

{==============================================================================
  dosyalar ile ilgili işlem yapmadan önce tanım işlevlerini gerçekleştirir
 ==============================================================================}
procedure AssignFile(var ADosyaKimlik: TKimlik; const ADosyaAdi: string);
begin
end;

{==============================================================================
  dosyayı okumadan önce ön hazırlık işlevlerini gerçekleştirir
 ==============================================================================}
procedure Reset(ADosyaKimlik: TKimlik);
begin
end;

{==============================================================================
  dosya okuma işleminde dosyanın sonuna gelinip gelinmediğini belirtir
 ==============================================================================}
function EOF(ADosyaKimlik: TKimlik): Boolean;
begin

  Result := True;
end;

{==============================================================================
  dosya uzunluğunu geri döndürür
 ==============================================================================}
function FileSize(ADosyaKimlik: TKimlik): TISayi4;
begin

  Result := 0;
end;

{==============================================================================
  dosya okuma işlemini gerçekleştirir
 ==============================================================================}
procedure Read(ADosyaKimlik: TKimlik; AHedefBellek: Isaretci);
var
  _MantiksalSurucu: PMantiksalSurucu;
  _DosyaKayit: PDosyaKayit;
  _DATBellekAdresi: Isaretci;
  _OkunacakSektorSayisi, _i: TSayi2;
  _ZincirBasinaSektor, _OkunacakVeri,
  _KopyalanacakVeriUzunlugu,
  _YeniDATSiraNo, _Zincir: TISayi4;
  _OkumaSonuc: Boolean;
begin

  // işlem yapılan dosyayla ilgili bellek bölgesine konumlan
  _DosyaKayit := @DosyaKayitListesi[ADosyaKimlik];

  // üzerinde işlem yapılacak sürücü
  _MantiksalSurucu := _DosyaKayit^.MantiksalSurucu;

  // FAT tablosu için bellekte yer ayır
  _DATBellekAdresi := GGercekBellek.Ayir(
    _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.ToplamSektor * 512);

  // depolama aygıtının ilk FAT kopyasının tümünü belleğe yükle
  _MantiksalSurucu^.FizikselSurucu^.SektorOku(_MantiksalSurucu^.FizikselSurucu,
    _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.IlkSektor,
    _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.ToplamSektor, _DATBellekAdresi);

  _OkunacakVeri := _DosyaKayit^.Uzunluk;

  _Zincir := _DosyaKayit^.IlkZincirSektor;

  _ZincirBasinaSektor := _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.KumeBasinaSektor;

  _OkumaSonuc := False;

  repeat

    // okunacak byte'ı sektör sayısına çevir
    if(_OkunacakVeri >= (_ZincirBasinaSektor * 512)) then
    begin

      _OkunacakSektorSayisi := _ZincirBasinaSektor;
      _KopyalanacakVeriUzunlugu := _ZincirBasinaSektor * 512;
      _OkunacakVeri -= (_ZincirBasinaSektor * 512);
    end
    else
    begin

      _OkunacakSektorSayisi := (_OkunacakVeri div 512) + 1;
      _KopyalanacakVeriUzunlugu := _OkunacakVeri;
      _OkunacakVeri := 0;
    end;

    // okunacak cluster numarası
    _i := (_Zincir - 2) * _ZincirBasinaSektor;
    _i += _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.IlkVeriSektoru;

    // sektörü belleğe oku
    _MantiksalSurucu^.FizikselSurucu^.SektorOku(_MantiksalSurucu^.FizikselSurucu,
      _i, _OkunacakSektorSayisi, AHedefBellek);

    // okunacak bilginin yerleştirileceğ_i bir sonraki adresi belirle
    AHedefBellek += _KopyalanacakVeriUzunlugu;

    // cluster değerini 4 ile çarp ve bir sonraki cluster değerini al
    _YeniDATSiraNo := (_Zincir * 4) + TSayi4(_DATBellekAdresi);
    _Zincir := PSayi4(_YeniDATSiraNo)^;

  // eğer 0xfff8..0xffff aralığındaysa bu dosyanın en son cluster'idir
  until (_Zincir = $FFFFFFF) or (_OkunacakVeri = 0) or (_OkumaSonuc);

  GGercekBellek.YokEt(_DATBellekAdresi,
    _MantiksalSurucu^.Acilis.DosyaAyirmaTablosu.ToplamSektor * 512);
end;

{==============================================================================
  dosya üzerinde yapılan işlemi sonlandırır
 ==============================================================================}
procedure CloseFile(ADosyaKimlik: TKimlik);
begin
end;

{==============================================================================
  dosya arama işlevini başlatır
 ==============================================================================}
function FindFirst(const AAramaSuzgec: string; ADosyaOzellik: TSayi2;
 var ADosyaArama: TDosyaArama): TISayi4;
var
  _DizinGirisi: PDizinGirisi;
begin

  UzunDosyaAdi[0] := #0;
  UzunDosyaAdi[1] := #0;

  _DizinGirisi := @AramaKayitListesi[ADosyaArama.Kimlik].DizinGirisi;
  AramaKayitListesi[ADosyaArama.Kimlik].Aranan := AAramaSuzgec;
  Result := DizinGirdisiOku(_DizinGirisi, AAramaSuzgec, ADosyaArama);
end;

{==============================================================================
  dosya arama işlemine devam eder
 ==============================================================================}
function FindNext(var ADosyaArama: TDosyaArama): TISayi4;
var
  _DizinGirisi: PDizinGirisi;
  Aranan: string;
begin

  _DizinGirisi := @AramaKayitListesi[ADosyaArama.Kimlik].DizinGirisi;
  Aranan := AramaKayitListesi[ADosyaArama.Kimlik].Aranan;
  Result := DizinGirdisiOku(_DizinGirisi, Aranan, ADosyaArama);
end;

{==============================================================================
  dosya arama işlemini sonlandırır
 ==============================================================================}
function FindClose(var ADosyaArama: TDosyaArama): TISayi4;
begin

  Result := 0;
end;

{==============================================================================
  dizin girişinden ilgili bilgileri alır
 ==============================================================================}
function DizinGirdisiOku(ADizinGirisi: PDizinGirisi; AAranacakDeger: string;
 var ADosyaArama: TDosyaArama): TSayi1;
var
  _MantiksalSurucu: PMantiksalSurucu;
  _DizinGirdisi: PDizinGirdisi;
  _TumGirislerOkundu, _NormalDosyaAdiBulundu,
  _UzunDosyaAdiBulundu: Boolean;
  _DosyaUzunlugu: TSayi4;
  _BaslangicZinciri: TSayi2;
begin

  ADosyaArama.DosyaAdi := '';

  // ilk değer atamaları
  _TumGirislerOkundu := False;

  // aramanın yapılacağı sürücü
  _MantiksalSurucu := AramaKayitListesi[ADosyaArama.Kimlik].MantiksalSurucu;

  _NormalDosyaAdiBulundu := False;
  _UzunDosyaAdiBulundu := False;

  // aramaya başla
  repeat

    if(ADizinGirisi^.DizinTablosuKayitNo = -1) then
    begin

      ADizinGirisi^.DizinTablosuKayitNo := 0;

      // bir sonraki dizin girişini oku
      _MantiksalSurucu^.FizikselSurucu^.SektorOku(_MantiksalSurucu^.FizikselSurucu,
        ADizinGirisi^.IlkSektor, 1, @DizinBellekAdresi);
      Inc(ADizinGirisi^.IlkSektor);
    end;

    // tüm girişler okunmadı ise
    if not(_TumGirislerOkundu) then
    begin

      // dosya giriş tablosuna konumlan
      _DizinGirdisi := PDizinGirdisi(@DizinBellekAdresi);
      Inc(_DizinGirdisi, ADizinGirisi^.DizinTablosuKayitNo);

      // dosya girişinin ilk karakteri #0 ise girişler okunmuş demektir
      if(_DizinGirdisi^.DosyaAdi[0] = #0) then
      begin

        Result := 1;
        _TumGirislerOkundu := True;
      end

      // dosya uzun ada sahip bir dosya ise, girişi incele
      else if(_DizinGirdisi^.Ozellikler = $F) then
      begin

        // ilk uzun dosya girişi ise cluster değerini al
        if not(_UzunDosyaAdiBulundu) then
        begin

          _DosyaUzunlugu := _DizinGirdisi^.DosyaUzunlugu;
          _BaslangicZinciri := _DizinGirdisi^.BaslangicKumeNo;
        end;

        // 1 sektördeki toplam kayıt sayısı: 512 / 32 = 16
        Inc(ADizinGirisi^.DizinTablosuKayitNo);
        if(ADizinGirisi^.DizinTablosuKayitNo = 16) then
          ADizinGirisi^.DizinTablosuKayitNo := -1;

        //if((PByte(_DizinGirdisi)^ and $40) = $40) then

        DosyaParcalariniBirlestir(Isaretci(_DizinGirdisi));

        if(_DizinGirdisi^.DosyaAdi[0] = Chr(1)) then
        begin

          _UzunDosyaAdiBulundu := True;
        end;
      end

      // giriş bir volume label ise bir sonraki girişe bak
      else if(_DizinGirdisi^.Ozellikler = 8) then
      begin

        Inc(ADizinGirisi^.DizinTablosuKayitNo);
        if(ADizinGirisi^.DizinTablosuKayitNo = 16) then ADizinGirisi^.DizinTablosuKayitNo := -1;
      end
      else
      begin

        _DosyaUzunlugu := _DizinGirdisi^.DosyaUzunlugu;
        _BaslangicZinciri := _DizinGirdisi^.BaslangicKumeNo;
        _NormalDosyaAdiBulundu := True;
      end;

      if(_NormalDosyaAdiBulundu) then
      begin

        // uzun dosya adının olması durumunda uzun dosya adı, aksi durumda
        // dosya adını 8 + 3 dosya.uz biçimine çevir
        if(_UzunDosyaAdiBulundu) then
        begin

          ADosyaArama.DosyaAdi := WideChar2String(@UzunDosyaAdi);

          UzunDosyaAdi[0] := #0;
          UzunDosyaAdi[1] := #0;

          ADosyaArama.Ozellikler := _DizinGirdisi^.Ozellikler;
          ADosyaArama.OlusturmaSaati := _DizinGirdisi^.OlusturmaSaati;
          ADosyaArama.OlusturmaTarihi := _DizinGirdisi^.OlusturmaTarihi;
          ADosyaArama.SonErisimTarihi := _DizinGirdisi^.SonErisimTarihi;
          ADosyaArama.SonDegisimSaati := _DizinGirdisi^.SonDegisimSaati;
          ADosyaArama.SonDegisimTarihi := _DizinGirdisi^.SonDegisimTarihi;

          _UzunDosyaAdiBulundu := False;
        end
        else
        begin

          ADosyaArama.Ozellikler := _DizinGirdisi^.Ozellikler;
          ADosyaArama.OlusturmaSaati := _DizinGirdisi^.OlusturmaSaati;
          ADosyaArama.OlusturmaTarihi := _DizinGirdisi^.OlusturmaTarihi;
          ADosyaArama.SonErisimTarihi := _DizinGirdisi^.SonErisimTarihi;
          ADosyaArama.SonDegisimSaati := _DizinGirdisi^.SonDegisimSaati;
          ADosyaArama.SonDegisimTarihi := _DizinGirdisi^.SonDegisimTarihi;

          ADosyaArama.DosyaAdi := HamDosyaAdiniDosyaAdinaCevir(_DizinGirdisi);
        end;

        // dosya uzunluğu ve cluster başlangıcını geri dönüş değerine ekle
        ADosyaArama.DosyaUzunlugu := _DosyaUzunlugu;
        ADosyaArama.BaslangicKumeNo := _BaslangicZinciri;

        Inc(ADizinGirisi^.DizinTablosuKayitNo);
        if(ADizinGirisi^.DizinTablosuKayitNo = 16) then ADizinGirisi^.DizinTablosuKayitNo := -1;

        Result := 0;
        _TumGirislerOkundu := True;
      end
    end;
  until _TumGirislerOkundu;
end;

// fat32 dosya sistemindeki widechar türündeki dosya parçalarını birleştirir
procedure DosyaParcalariniBirlestir(WCArray: Isaretci);
var
  _BellekU, _i: TISayi4;
  _p: PChar;
  _Kar1, _Kar2: Char;
  _Bellek: array[0..27] of Char;     // azami bellek: 13 * 2 = 26 karakter + 2 byte #0 karakter
  _Tamamlandi: Boolean;
begin

  _Tamamlandi := False;

  // 1. parça - (5 (widechar) * 2 = 10 byte)
  _BellekU := 0;
  _p := PChar(WCArray + 1);
  for _i := 0 to 4 do
  begin

    _Kar1 := _p^;
    Inc(_p);
    _Kar2 := _p^;
    Inc(_p);

    if(_Kar1 <> #0) or (_Kar2 <> #0) then
    begin

      _Bellek[_BellekU + 0] := _Kar1;
      _Bellek[_BellekU + 1] := _Kar2;
      Inc(_BellekU, 2);
    end
    else
    begin

      _Tamamlandi := True;
      Break;
    end;
  end;

  // 2. parça - (6 (widechar) * 2 = 12 byte)
  if not(_Tamamlandi) then
  begin

    _p := PChar(WCArray + 14);
    for _i := 0 to 5 do
    begin

      _Kar1 := _p^;
      Inc(_p);
      _Kar2 := _p^;
      Inc(_p);

      if(_Kar1 <> #0) or (_Kar2 <> #0) then
      begin

        _Bellek[_BellekU + 0] := _Kar1;
        _Bellek[_BellekU + 1] := _Kar2;
        Inc(_BellekU, 2);
      end
      else
      begin

        _Tamamlandi := True;
        Break;
      end;
    end;
  end;

  // 3. parça - (2 (widechar) * 2 = 4 byte)
  if not(_Tamamlandi) then
  begin

    _p := PChar(WCArray + 28);
    for _i := 0 to 1 do
    begin

      _Kar1 := _p^;
      Inc(_p);
      _Kar2 := _p^;
      Inc(_p);

      if(_Kar1 <> #0) or (_Kar2 <> #0) then
      begin

        _Bellek[_BellekU + 0] := _Kar1;
        _Bellek[_BellekU + 1] := _Kar2;
        Inc(_BellekU, 2);
      end
      else
      begin

        _Tamamlandi := True;
        Break;
      end;
    end;
  end;

  // çift 0 sonlandırma
  _Bellek[_BellekU + 0] := #0;
  _Bellek[_BellekU + 1] := #0;
  Inc(_BellekU, 2);

  // parçayı bir önceki parçaların önüne ekle
  DosyaParcasiniBasaEkle(@_Bellek[0], @UzunDosyaAdi[0]);
end;

// dosya ad parçasını diğer parçaların önüne ekler
// AEklenecekVeri = başa eklenecek bellek bölgesi
// AHedefBellek = verilerin birleştirileceği bellek bölgesi
procedure DosyaParcasiniBasaEkle(AEklenecekVeri, AHedefBellek: Isaretci);
var
  _p1, _p2: PChar;
  _Kar1, _Kar2: Char;
  _Bellek: array[0..511] of Char;    // azami dosya ad uzunluğu
  _BellekSiraNo, _Bellek2SiraNo, i: TISayi4;
begin

  // 1. hedef bellek bölgesinde mevcut verileri yedekle
  _p1 := PChar(AHedefBellek);

  _Kar1 := _p1^;
  Inc(_p1);
  _Kar2 := _p1^;
  Inc(_p1);

  _BellekSiraNo := 0;
  while (_Kar1 <> #0) or (_Kar2 <> #0) do
  begin

    _Bellek[_BellekSiraNo] := _Kar1;
    Inc(_BellekSiraNo);
    _Bellek[_BellekSiraNo] := _Kar2;
    Inc(_BellekSiraNo);

    _Kar1 := _p1^;
    Inc(_p1);
    _Kar2 := _p1^;
    Inc(_p1);
  end;

  // 2. başa eklenecek verileri yükle
  _p1 := PChar(AEklenecekVeri);

  _Kar1 := _p1^;
  Inc(_p1);
  _Kar2 := _p1^;
  Inc(_p1);

  _p2 := PChar(AHedefBellek);
  _Bellek2SiraNo := 0;
  while (_Kar1 <> #0) or (_Kar2 <> #0) do
  begin

    _p2^ := _Kar1;
    Inc(_p2);
    Inc(_Bellek2SiraNo);

    _p2^ := _Kar2;
    Inc(_p2);
    Inc(_Bellek2SiraNo);

    _Kar1 := _p1^;
    Inc(_p1);
    _Kar2 := _p1^;
    Inc(_p1);
  end;

  // yedeklenmiş veriyi sona ekle
  if(_BellekSiraNo > 0) then
  begin

    for i := 0 to _BellekSiraNo - 1 do
    begin

      _Kar1 := _Bellek[i];
      _p2^ := _Kar1;

      Inc(_p2);
      Inc(_Bellek2SiraNo);
    end;
  end;

  // çift sonlandırma işareti
  _p2^ := #0;
  Inc(_p2);
  _p2^ := #0;
end;

end.
