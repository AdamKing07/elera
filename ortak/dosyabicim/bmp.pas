{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: bmp.pas
  Dosya İşlevi: bmp dosya işlevlerini içerir

  Güncelleme Tarihi: 08/11/2019

  Not-1: şu an itibariyle sadece 24 bitlik resim görüntüleme desteği vardır
  Not-2: tüm renkler 32 bitlik değerlerle işlenmektedir

 ==============================================================================}
{$mode objfpc}
unit bmp;

interface

uses dosya, gercekbellek, genel, paylasim, gn_pencere;

type
  PRGBRenk = ^TRGBRenk;
  TRGBRenk = packed record
    R, G, B: TSayi1;
  end;

  PBMPBicim = ^TBMPBicim;
  TBMPBicim = packed record
    Tip: TSayi2;	                  // dosya tipi "BM".
    Uzunluk: TSayi4;	              // dosya uzunluğu
    Ayrilmis: TSayi4;	              // ayrıldı = 0
    VeriAdres: TSayi4;	            // data (resim) başlangıç adresi
    BaslikUzunlugu: TSayi4;	        // başlık uzunluğu = 40
    Genislik: TSayi4;	              // resmin pixel olarak genişliği
    Yukseklik: TSayi4;	            // resmin pixel olarak yüksekliğğ
    PlanSayisi: TSayi2;	            // plan sayısı = 1
    PixelBasinaBitSayisi: TSayi2;	  // pixel başına bit sayısı 24, 32
    Sikistirma: TSayi4;	            // sıkıştırma = 0
    ResimBoyutu: TSayi4;	          // resmin byte olarak uzunluğu
    MetreBasinaYatayNokta: TSayi4;  // metre başına yatay pixel
    MetreBasinaDikeyNokta: TSayi4;  // metre başına düşey pixel
    KullanilanRenkSayisi: TSayi4;	  // kullanılan renk sayısı
    OnemliRenkSayisi: TSayi4;       // önemli renk sayısı
  end;

function BMPDosyasiYukle(ADosyaTamYol: string): TGoruntuYapi;
procedure ResimCiz(AGorselNesneTipi: TGorselNesneTipi; AKimlik: TKimlik;
  AGoruntuYapi: TGoruntuYapi);

implementation

uses gn_masaustu, gn_resim, islevler, gn_islevler;

// bmp biçimindeki dosyayı resim olarak belleğe yükler
function BMPDosyasiYukle(ADosyaTamYol: string): TGoruntuYapi;
var
  _DosyaBellek: Isaretci;
  _DosyaUzunlugu: TISayi4;
  _DosyaKimlik: TKimlik;
  _DosyaTamYol, _DosyaUzantisi,
  _Surucu, _Dizin, _DosyaAdi: string;
  _BMPBicim: PBMPBicim;
  _GoruntuYapi: TGoruntuYapi;
  _SatirdakiByteSayisi, _Satir,
  _A1, _B1, i: TISayi4;
  _PRenk: PRGBRenk;
  _Renk: TRenk;
  _HedefBellek: ^TRenk;
begin

  Result.BellekAdresi := nil;

  // dosyayı sürücü + dizin + dosya parçalarına ayır
  DosyaYolunuParcala(ADosyaTamYol, _Surucu, _Dizin, _DosyaAdi);

  // dosya adının uzunluğunu al
  _DosyaUzunlugu := Length(_DosyaAdi);

  // dosya uzantısını al
  i := Pos('.', _DosyaAdi);
  if(i > 0) then
    _DosyaUzantisi := Copy(_DosyaAdi, i + 1, _DosyaUzunlugu - i)
  else _DosyaUzantisi := '';

  if(_DosyaUzantisi = 'bmp') then
  begin

    _DosyaTamYol := _Surucu + ':\' + _DosyaAdi;

    AssignFile(_DosyaKimlik, _DosyaTamYol);
    Reset(_DosyaKimlik);
    if(IOResult = 0) then
    begin

      // dosya uzunluğunu al
      _DosyaUzunlugu := FileSize(_DosyaKimlik);

      // dosyanın belleğe _B1üklenmesi için bellekte yer ayır
      _DosyaBellek := GGercekBellek.Ayir(_DosyaUzunlugu);
      if(_DosyaBellek = nil) then
      begin

        // dosyayı kapat
        CloseFile(_DosyaKimlik);
        Exit;
      end;

      // dosyayı hedef adrese kopyala
      Read(_DosyaKimlik, _DosyaBellek);

      // dosyayı kapat
      CloseFile(_DosyaKimlik);

      _BMPBicim := _DosyaBellek;
      _GoruntuYapi.Genislik := _BMPBicim^.Genislik;
      _GoruntuYapi.Yukseklik := _BMPBicim^.Yukseklik;

      _GoruntuYapi.BellekAdresi := GGercekBellek.Ayir(_GoruntuYapi.Genislik *
        _GoruntuYapi.Yukseklik * 4);
      if(_GoruntuYapi.BellekAdresi = nil) then Exit;

      // resim dosyasındaki her bir satırdaki byte sayısı
      _SatirdakiByteSayisi := (_GoruntuYapi.Genislik * 3 + 3) and $FFFFFFFC;

      _Satir := -1;

      for _B1 := _GoruntuYapi.Yukseklik - 1 downto 0 do
      begin

        _HedefBellek := _GoruntuYapi.BellekAdresi + (_B1 * (_GoruntuYapi.Genislik * 4));

        Inc(_Satir);
        _PRenk := _DosyaBellek + _BMPBicim^.VeriAdres + (_SatirdakiByteSayisi * _Satir);

        for _A1 := 0 to _GoruntuYapi.Genislik - 1 do
        begin

          _Renk := (_PRenk^.B shl 16) + (_PRenk^.G shl 8) + (_PRenk^.R);
          _HedefBellek^ := _Renk;
          Inc(_PRenk);
          Inc(_HedefBellek);
        end;
      end;

      // dosyanın açıldığı belleği serbest bırak
      GGercekBellek.YokEt(_DosyaBellek, _DosyaUzunlugu);

      Result := _GoruntuYapi;
    end;
  end;
end;

// bmp biçiminde belleğe yüklenmiş resmi görsel nesneye çizer
procedure ResimCiz(AGorselNesneTipi: TGorselNesneTipi; AKimlik: TKimlik;
  AGoruntuYapi: TGoruntuYapi);
var
  _Masaustu: PMasaustu;
  _Pencere: PPencere;
  _Resim: PResim;
  _Renk, __Renk: ^TRenk;
  _Alan: TAlan;
  _Yukseklik, _Genislik, _SatirdakiByteSayisi,
  _TuvalA1, _TuvalB1: TISayi4;
  _YatayArtis, _DikeyArtis, _A1: Double;
begin

  if(AGorselNesneTipi = gntMasaustu) then
  begin

    _Masaustu := PMasaustu(_Masaustu^.NesneTipiniKontrolEt(AKimlik, AGorselNesneTipi));
    if(_Masaustu = nil) then Exit;

    _Alan := _Masaustu^.CizimGorselNesneBoyutlariniAl(AKimlik);

    _Genislik := AGoruntuYapi.Genislik;
    _SatirdakiByteSayisi := _Genislik * 4;
    if(_Genislik > _Alan.Genislik2) then _Genislik := _Alan.Genislik2;
    _Yukseklik := AGoruntuYapi.Yukseklik;
    if(_Yukseklik > _Alan.Yukseklik2) then _Yukseklik := _Alan.Yukseklik2;

    for _TuvalB1 := 0 to _Yukseklik - 1 do
    begin

      _Renk := (_TuvalB1 * _SatirdakiByteSayisi) + AGoruntuYapi.BellekAdresi;

      for _TuvalA1 := 0 to _Genislik - 1 do
      begin

        GEkranKartSurucusu.NoktaYaz(_Masaustu, _Alan.Sol + _TuvalA1, _Alan.Ust + _TuvalB1,
          _Renk^, True);
        Inc(_Renk);
      end;
    end;
  end
  else if(AGorselNesneTipi = gntResim) then
  begin

    _Resim := PResim(_Resim^.NesneTipiniKontrolEt(AKimlik, AGorselNesneTipi));
    if(_Resim = nil) then Exit;

    // ata nesne kontrolü. ata nesne pencere değilse çık
    _Pencere := PencereAtaNesnesiniAl(_Resim);
    if(_Pencere = nil) then Exit;

    _Alan := _Resim^.CizimGorselNesneBoyutlariniAl(AKimlik);

    if(_Resim^.FTuvaleSigdir) then
    begin

      _Genislik := AGoruntuYapi.Genislik;
      _SatirdakiByteSayisi := _Genislik * 4;
      _Yukseklik := AGoruntuYapi.Yukseklik;
      _YatayArtis := _Genislik / (_Alan.Sag - _Alan.Sol);
      _DikeyArtis := _Yukseklik / (_Alan.Alt - _Alan.Ust);
    end
    else
    begin

      _Genislik := AGoruntuYapi.Genislik;
      _SatirdakiByteSayisi := _Genislik * 4;
      if(_Genislik > _Alan.Genislik2) then _Genislik := _Alan.Genislik2;
      _Yukseklik := AGoruntuYapi.Yukseklik;
      if(_Yukseklik > _Alan.Yukseklik2) then _Yukseklik := _Alan.Yukseklik2;
      _YatayArtis := 1.0;
      _DikeyArtis := 1.0;
    end;

    for _TuvalB1 := 0 to _Yukseklik - 1 do
    begin

      _Renk := (Round((_TuvalB1 * _DikeyArtis)) * _SatirdakiByteSayisi) + AGoruntuYapi.BellekAdresi;

      _A1 := 0.0;
      for _TuvalA1 := 0 to _Genislik - 1 do
      begin

        _A1 := _A1 + _YatayArtis;
        __Renk := _Renk;
        Inc(__Renk, Round(_A1));

        GEkranKartSurucusu.NoktaYaz(_Pencere, _Alan.Sol + _TuvalA1, _Alan.Ust + _TuvalB1,
          __Renk^, True);
      end;
    end;
  end;
end;

end.
