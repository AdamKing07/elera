{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: gn_islevler.pas
  Dosya İşlevi: görsel nesne (visual object) işlevlerini içerir

  Güncelleme Tarihi: 09/04/2020

 ==============================================================================}
{$mode objfpc}
unit gn_islevler;

interface

uses gorselnesne, genel, paylasim, gn_masaustu, gn_pencere, gn_listekutusu, gn_menu,
  gn_defter, gn_listegorunum, gn_karmaliste;

var
  AktifPencere: PPencere;
  YakalananGorselNesne: PGorselNesne;  // farenin, üzerine sol tuş ile basılıp seçildiği nesne

procedure Yukle;
function GorselNesneIslevCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
procedure GorevGorselNesneleriniYokEt(AGorevKimlik: TGorevKimlik);
function GorselNesneBul(A1, B1: TISayi4): PGorselNesne;
function GorselNesneAlanIcerisindeMi(AGorselNesne: PGorselNesne; A1, B1: TISayi4): Boolean;
function PencereAtaNesnesiniAl(AGorselNesne: PGorselNesne): PPencere;
procedure OlayYakalamayaBasla(AOlayNesne: PGorselNesne);
procedure OlayYakalamayiBirak(AOlayNesne: PGorselNesne);

implementation

{==============================================================================
  görsel nesne yükleme işlevlerini gerçekleştirir
 ==============================================================================}
procedure Yukle;
var
  _GNBellekAdresi: Isaretci;
  i: TSayi4;
begin

  GN_UZUNLUK := Align(SizeOf(TPencere), 16);

  // görsel nesneler için bellekte yer tahsis et
  _GNBellekAdresi := GGercekBellek.Ayir(USTSINIR_GORSELNESNE * GN_UZUNLUK);

  // nesneye ait işaretçileri bellek bölgeleriyle eşleştir
  for i := 1 to USTSINIR_GORSELNESNE do
  begin

    GorselNesneListesi[i] := _GNBellekAdresi;

    // nesneyi kullanılmadı olarak işaretle
    GorselNesneListesi[i]^.Kimlik := HATA_KIMLIK;

    _GNBellekAdresi += GN_UZUNLUK;
  end;

  // görsel nesne değişkenlerini ilk değerlerle yükle
  ToplamMasaustu := 0;
  ToplamGNSayisi := 0;
  AktifPencere := nil;
  GAktifMasaustu := nil;
  YakalananGorselNesne := nil;
end;

{==============================================================================
  genel nesne çağrılarını yönetir
 ==============================================================================}
function GorselNesneIslevCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _GorselNesne: PGorselNesne;
  _Kimlik: TKimlik;
  _BellekAdresi: Isaretci;
begin

  // yatay & dikey koordinattaki nesneyi al
  if(IslevNo = 1) then
  begin

    _GorselNesne := GorselNesneBul(PISayi4(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^);
    Result := _GorselNesne^.Kimlik;
  end

  // görsel nesne bilgilerini hedef bellek bölgesine kopyala
  // bilgi: bu işlevin alt yapı çalışması yapılacak
  else if(IslevNo = 2) then
  begin

    _Kimlik := PISayi4(Degiskenler + 00)^;
    if(_Kimlik >= 1) and (_Kimlik <= USTSINIR_GORSELNESNE) then
    begin

      _GorselNesne := GorselNesneListesi[_Kimlik];
      _BellekAdresi := Isaretci(PSayi4(Degiskenler + 04)^ + AktifGorevBellekAdresi);
      Tasi2(_GorselNesne, _BellekAdresi, SizeOf(TGorselNesne));

      Result := 1;
    end else Result := 0;
  end

  // yatay & dikey koordinattaki nesnenin adını al
  else if(IslevNo = 3) then
  begin

    _GorselNesne := GorselNesneBul(PISayi4(Degiskenler + 00)^, PISayi4(Degiskenler + 04)^);
    _BellekAdresi := Isaretci(PSayi4(Degiskenler + 08)^ + AktifGorevBellekAdresi);
    Tasi2(@_GorselNesne^.NesneAdi[0], _BellekAdresi, Length(_GorselNesne^.NesneAdi) + 1);
  end;
end;

{==============================================================================
  çalışan işleme ait pencere ve tüm alt nesneleri yok eder
 ==============================================================================}
procedure GorevGorselNesneleriniYokEt(AGorevKimlik: TGorevKimlik);
var
  _Masaustu: PMasaustu;
  _Pencere: PGorselNesne;
  _MasaustuGNBellekAdresi,
  _PencereGNBellekAdresi: PPGorselNesne;
  _PencereSiraNo, _PencereAltNesneSiraNo, i: TISayi4;
begin

  // geçerli bir masaüstü var mı ?
  _Masaustu := GAktifMasaustu;
  if not(_Masaustu = nil) then
  begin

    // masaüstü nesnesinin alt nesnesi var ise
    if(_Masaustu^.AltNesneSayisi > 0) then
    begin

      // masaüstünün alt nesnelerinin bellek adresini al
      _MasaustuGNBellekAdresi := _Masaustu^.FAltNesneBellekAdresi;

      // masaüstü alt nesnelerini teker teker ara
      for _PencereSiraNo := 0 to _Masaustu^.AltNesneSayisi - 1 do
      begin

        _Pencere := _MasaustuGNBellekAdresi[_PencereSiraNo];

        // aranan pencerenin sahibi olan görev ile araştırılan görev kimliği eşit mi?
        // öyle ise pencere ve alt nesnelerini yok et
        if(_Pencere^.GorevKimlik = AGorevKimlik) then
        begin

          // pencere nesnesinin alt nesnesi var mı?
          if(_Pencere^.AltNesneSayisi > 0) then
          begin

            // pencere nesnesinin alt nesne bellek bölgesine konumlan
            _PencereGNBellekAdresi := _Pencere^.FAltNesneBellekAdresi;
            for _PencereAltNesneSiraNo := 0 to _Pencere^.AltNesneSayisi - 1 do
            begin

              // -> ek kaynak kullanan görsel nesneler - BAŞLANGIÇ

              if(_PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.GorselNesneTipi = gntListeKutusu) then
                PListeKutusu(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.YokEt(
                  PListeKutusu(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.Kimlik)
              else if(_PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.GorselNesneTipi = gntListeGorunum) then
                PListeGorunum(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.YokEt(
                  PListeGorunum(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.Kimlik)
              else if(_PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.GorselNesneTipi = gntMenu) then
                PMenu(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.YokEt(
                  PMenu(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.Kimlik)
              else if(_PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.GorselNesneTipi = gntDefter) then
                PDefter(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.YokEt(
                  PDefter(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.Kimlik)
              else if(_PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.GorselNesneTipi = gntKarmaListe) then
                PKarmaListe(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.YokEt(
                  PKarmaListe(_PencereGNBellekAdresi[_PencereAltNesneSiraNo])^.Kimlik)
              else

              // <- ek kaynak kullanan görsel nesneler - SON

              // aksi durumda sadece nesneyi yok et
              _PencereGNBellekAdresi[_PencereAltNesneSiraNo]^.YokEt0;
            end;

            // pencere nesnesinin alt nesne için ayrılan bellek bloğunu iptal et
            GGercekBellek.YokEt(_Pencere^.FAltNesneBellekAdresi, 4096);
          end;

          // bulunan pencereyi masaüstü listesinden çıkart
          _MasaustuGNBellekAdresi[_PencereSiraNo] := nil;

          // pencereyi yok et
          _Pencere^.YokEt0;

          // masaüstü alt nesne sayısını bir azalt
          i := _Masaustu^.AltNesneSayisi;
          Dec(i);
          _Masaustu^.AltNesneSayisi := i;

          // eğer alt nesne sayısı halen mevcut ise
          // sıralamayı tekrar gözden geçir
          if(_Masaustu^.AltNesneSayisi > 0) then
          begin

            for i := 0 to _Masaustu^.AltNesneSayisi - 1 do
            begin

              if(_MasaustuGNBellekAdresi[i] = nil) then
                _MasaustuGNBellekAdresi[i] := _MasaustuGNBellekAdresi[i + 1];
            end;
          end

          // aksi durumda masaüstü alt nesne bellek bölgesini iptal et
          else GGercekBellek.YokEt(_Masaustu^.FAltNesneBellekAdresi, 4096);

          // masaüstü nesnesini yeniden çiz
          _Masaustu^.Guncelle;

          // bir sonraki döngüye devam etmeden çık
          Exit;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  belirtilen koordinattaki nesneyi bulur
 ==============================================================================}
function GorselNesneBul(A1, B1: TISayi4): PGorselNesne;
var
  _AltNesneGNBellekAdresi: PPGorselNesne;
  _GorselNesne: PGorselNesne;
  _BulunanNesne, _SonBulunanGorselNesne: PGorselNesne;
  i: TISayi4;
begin

  // aktif masaüstü yok ise nil değeri ile çık
  if(GAktifMasaustu = nil) then Exit(nil);

  // masaüstüne bağlı menü mevcut mu? test et
  // NOT: menü işlevi geçici olarak masaüstü nesnesine eklendi. geliştirilecek
  if(GAktifMasaustu^.FBaslatmaMenusu <> nil) then
  begin

    _SonBulunanGorselNesne := GAktifMasaustu^.FBaslatmaMenusu;
    if(_SonBulunanGorselNesne^.Gorunum) then
    begin

      if(GorselNesneAlanIcerisindeMi(_SonBulunanGorselNesne, A1, B1)) then
        Exit(_SonBulunanGorselNesne);
    end;
  end;

  // son bulunan nesne, geçerli masaüstü
  _SonBulunanGorselNesne := GAktifMasaustu;

  // kısır döngüye gir
  while 1 = 1 do
  begin

    if(_SonBulunanGorselNesne^.FAtaNesneMi) and (_SonBulunanGorselNesne^.AltNesneSayisi > 0) then
    begin

      // ata nesne olan görsel nesnenin alt nesne bellek adresi
      _AltNesneGNBellekAdresi := _SonBulunanGorselNesne^.FAltNesneBellekAdresi;

      _BulunanNesne := nil;

      // alt nesnesi olan nesnenin alt nesnelerini ara. sondan başa doğru (3..0 gibi)
      for i := _SonBulunanGorselNesne^.AltNesneSayisi - 1 downto 0 do
      begin

        // görsel nesneyi al
        _GorselNesne := PGorselNesne(_AltNesneGNBellekAdresi[i]);

        // görsel nesne görünür durumda mı ?
        if(_GorselNesne^.Gorunum) then
        begin

          // görsel nesne A1 ve B1 koordinatı içerisinde mi ?
          if(GorselNesneAlanIcerisindeMi(_GorselNesne, A1, B1)) then
          begin

            // bulunan nesne olarak görsel nesneyi kaydet
            _BulunanNesne := _GorselNesne;
            Break;
          end;
        end;
      end;

      if(_BulunanNesne = nil) then Exit(_SonBulunanGorselNesne);

      _SonBulunanGorselNesne := _BulunanNesne;

    end else Exit(_SonBulunanGorselNesne);
  end;
end;

{==============================================================================
  nesnenin yatay & dikey koordinat içerisinde olup olmadığını kontrol eder
 ==============================================================================}
function GorselNesneAlanIcerisindeMi(AGorselNesne: PGorselNesne; A1, B1: TISayi4): Boolean;
var
  _Alan: TAlan;
begin

  // nesnenin üst nesneye bağlı gerçek koordinatlarını al
  _Alan.Sol2 := AGorselNesne^.FDisGercekBoyutlar.Sol2;
  _Alan.Ust2 := AGorselNesne^.FDisGercekBoyutlar.Ust2;
  _Alan.Genislik2 := AGorselNesne^.FDisGercekBoyutlar.Genislik2;
  _Alan.Yukseklik2 := AGorselNesne^.FDisGercekBoyutlar.Yukseklik2;

  // nesnenin A1, B1 koordinatları içerisinde olup olmadığını kontrol et
  Result := False;
  if(_Alan.A1 > A1) then Exit;
  if(_Alan.A2 < A1) then Exit;
  if(_Alan.B1 > B1) then Exit;
  if(_Alan.B2 < B1) then Exit;

  // tüm koşullar sağlanmışsa nesne belirtilen koordinattadır
  Result := True;
end;

{==============================================================================
  nesnenin atası olan pencere nesnesini alır
 ==============================================================================}
function PencereAtaNesnesiniAl(AGorselNesne: PGorselNesne): PPencere;
begin

  // nesnenin ata nesnesi pencere olana kadar ara
  while (AGorselNesne^.GorselNesneTipi <> gntPencere) do
  begin

    AGorselNesne := AGorselNesne^.AtaNesne;
  end;

  Result := PPencere(AGorselNesne);
end;

{==============================================================================
  nesnenin fare olaylarını yakalamasını sağlar
 ==============================================================================}
procedure OlayYakalamayaBasla(AOlayNesne: PGorselNesne);
begin

  // olaylar başka nesne tarafından yakalanmıyorsa, olay nesnesini
  // yakalanan nesne olarak ata
  if(YakalananGorselNesne = nil) then YakalananGorselNesne := AOlayNesne;
end;

{==============================================================================
  fare olayları yakalama işlevi nesne tarafından serbest bırakılır
 ==============================================================================}
procedure OlayYakalamayiBirak(AOlayNesne: PGorselNesne);
begin

  // olay daha önce nesne tarafından yakalanmışsa, nesneyi yakalanan nesne
  // olmaktan çıkar
  if(YakalananGorselNesne = AOlayNesne) then YakalananGorselNesne := nil;
end;

end.
