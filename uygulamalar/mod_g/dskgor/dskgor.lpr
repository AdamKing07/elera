program dskgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dskgor.lpr
  Program Ýþlevi: depolama aygýtý sektör içeriðini görüntüler

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, gn_dugme, gn_etiket, gn_durumcubugu, gn_giriskutusu;

var
  DiskBellek: array[0..511] of TSayi1;

const
  ProgramAdi: string = 'Depolama Aygýtý Ýçerik Görüntüleme';

  DepolamaAygitiBulunamadi: string  = 'Sistemde depolama aygýtý bulunamadý!';
  DepolamaAygitiSeciniz: string  = 'Lütfen bir depolama aygýtý seçiniz!';
  DepolamaAygitiOkumaHatasi: string  = 'Depolama aygýtý okuma hatasý!';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  DurumCubugu0: TDurumCubugu;
  etiSektorNo: TEtiket;
  dugAzalt, dugArtir, dugYenile: TDugme;
  dugDepolamaAygitlari: array[1..6] of TDugme;
  gkAdres: TGirisKutusu;
  OlayKayit: TOlayKayit;
  FizikselDepolamaAygitSayisi, SeciliAygitSiraNo,
  DugmeA1, i: TSayi4;
  AygitOkumaDurumu, ToplamSektor, MevcutSektor: TISayi4;
  FizikselSurucuListesi: array[1..6] of TFizikselSurucu3;
  s: string;

function FizikselDepolamaAygitSayisiAl: TISayi4; assembler;
asm
  mov   eax,$710F
  int   $34
end;

function FizikselDepolamaAygitBilgisiAl(AAygitKimlik: TSayi4;
  AFizikselSurucu3: PFizikselSurucu3): Boolean; assembler;
asm
  push  AFizikselSurucu3
  push  AAygitKimlik
  mov   eax,$720F
  int   $34
  add   esp,8
end;

function FizikselDepolamaVeriOku(AAygitKimlik, ASektorNo, AOkunacakSektor: TSayi4;
  AHedefBellek: Isaretci): TISayi4; assembler;
asm
  push  AHedefBellek
  push  AOkunacakSektor
  push  ASektorNo
  push  AAygitKimlik
  mov   eax,$730F
  int   $34
  add   esp,16
end;

procedure SektorAdresleriniYaz(ASektorNo: TSayi4);
var
  _SektorNo, _B1, i: TSayi4;
begin

  _B1 := 58;
  _SektorNo := ASektorNo * 512;

  for i := 0 to 31 do
  begin

    Pencere0.Tuval.KalemRengi := RENK_SIYAH;
    Pencere0.Tuval.SayiYaz16(0, _B1, True, 8, _SektorNo);
    _SektorNo += 16;
    _B1 += 16;
  end;
end;

procedure SektorSiraDegerleriniYaz;
var
  _A1, _B1, _Deger: TSayi4;
begin

  for  _B1 := 0 to 31 do
  begin

    for _A1 := 0 to 15 do
    begin

      _Deger := DiskBellek[(_B1 * 16) + _A1];
      if((_A1 and 1) = 1) then
      begin

        Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
        Pencere0.Tuval.SayiYaz16(((_A1 * 3) + 11) * 8, (_B1 * 16) + 58, False, 2, _Deger)
      end
      else
      begin

        Pencere0.Tuval.KalemRengi := RENK_MAVI;
        Pencere0.Tuval.SayiYaz16(((_A1 * 3) + 11) * 8, (_B1 * 16) + 58, False, 2, _Deger);
      end;
    end;
  end;
end;

procedure SektorIceriginiYaz;
var
  _A1, _B1: TSayi4;
  _Deger: Char;
begin

  for _B1 := 0 to 31 do
  begin

    for _A1 := 0 to 15 do
    begin

      _Deger := Char(DiskBellek[(_B1 * 16) + _A1]);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.HarfYaz((_A1 + 59) * 8, (_B1 * 16) + 58, _Deger);
    end;
  end;
end;

begin

  // ana form oluþtur
  Pencere0.Olustur(-1, 10, 10, 615, 626, ptBoyutlandirilabilir, ProgramAdi, $D1F0ED);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  // toplam fiziksel sürücü sayýsýný al
  FizikselDepolamaAygitSayisi := FizikselDepolamaAygitSayisiAl;
  if(FizikselDepolamaAygitSayisi > 0) then
  begin

    // fiziksel sürücü bilgilerini al ve düðmeleri oluþtur
    DugmeA1 := 0;
    for i := 1 to FizikselDepolamaAygitSayisi do
    begin

      if(FizikselDepolamaAygitBilgisiAl(i, @FizikselSurucuListesi[i])) then
      begin

        dugDepolamaAygitlari[i].Olustur(Pencere0.Kimlik, DugmeA1, 2, 65, 22,
          FizikselSurucuListesi[i].AygitAdi);
        dugDepolamaAygitlari[i].Etiket := i;
        dugDepolamaAygitlari[i].Goster;
        DugmeA1 += 70;
      end;
    end;
  end;

  // sektör no etiketi
  etiSektorNo.Olustur(Pencere0.Kimlik, 0, 33, $000000, 'Sektör No: ');
  etiSektorNo.Goster;

  // sektör no giriþ kutusu
  gkAdres.Olustur(Pencere0.Kimlik, 90, 30, 120, 22, HexToStr(0, False, 8));
  gkAdres.Goster;

  // sektör no azaltma düðmesi
  dugAzalt.Olustur(Pencere0.Kimlik, 220, 30, 35, 22, ' <');
  dugAzalt.Goster;

  // sektör no artýrma düðmesi
  dugArtir.Olustur(Pencere0.Kimlik, 257, 30, 35, 22, ' >');
  dugArtir.Goster;

  // sektör no yeniden okuma düðmesi
  dugYenile.Olustur(Pencere0.Kimlik, 294, 30, 80, 22, ' Yenile');
  dugYenile.Goster;

  // durum göstergesi
  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Aygýt: - Sektör: - / -');
  DurumCubugu0.Goster;

  // pencereyi görüntüle
  Pencere0.Goster;

  // öndeðer atamalarý
  SeciliAygitSiraNo := 0;
  ToplamSektor := 0;
  MevcutSektor := 0;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      // sektör no giriþte ENTER tuþuna basýlmýþsa...
      if(OlayKayit.Deger1 = 10) then
      begin

        s := gkAdres.IcerikAl;
        MevcutSektor := StrToHex(s);

        // tüm iþlemlerde, eðer disk seçili ise okuma iþlemi yap ve bilgileri güncelle
        if(SeciliAygitSiraNo > 0) then
        begin

          DurumCubugu0.DurumYazisiDegistir('Aygýt: ' +
            FizikselSurucuListesi[SeciliAygitSiraNo].AygitAdi + ' - Sektör: ' +
            HexToStr(FizikselSurucuListesi[SeciliAygitSiraNo].ToplamSektorSayisi, True, 8) + ' / ' +
            HexToStr(MevcutSektor, True, 8));

          AygitOkumaDurumu := FizikselDepolamaVeriOku(SeciliAygitSiraNo,
            MevcutSektor, 1, @DiskBellek);
          Pencere0.Ciz;
        end;
      end;
    end

    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugYenile.Kimlik) then
      begin

        // kod bloðu sonunda okuma iþlevi gerçekleþtirilmektedir
        // bu blok sadece olayý yakalamak içindir
      end

      // bir önceki sektörü okuma düðmesi
      else if(OlayKayit.Kimlik = dugAzalt.Kimlik) then
      begin

        // eðer disk seçili ise
        if(SeciliAygitSiraNo > 0) then
        begin

          Dec(MevcutSektor);
          if(MevcutSektor < 0) then MevcutSektor := 0;
        end;
      end

      // bir sonraki sektörü okuma düðmesi
      else if(OlayKayit.Kimlik = dugArtir.Kimlik) then
      begin

        // eðer disk seçili ise
        if(SeciliAygitSiraNo > 0) then
        begin

          Inc(MevcutSektor);
          if(MevcutSektor > ToplamSektor) then MevcutSektor := ToplamSektor;
        end;
      end
      else
      begin

        // aksi durumda disk seçme düðmesi
        for i := 1 to 6 do
        begin

          if(dugDepolamaAygitlari[i].Kimlik = OlayKayit.Kimlik) then
          begin

            SeciliAygitSiraNo := dugDepolamaAygitlari[i].Etiket;
            ToplamSektor := FizikselSurucuListesi[i].ToplamSektorSayisi;

            MevcutSektor := 0;
            Break;
          end;
        end;
      end;

      // disk seçili ise okuma iþlemi yap ve bilgileri güncelle
      if(SeciliAygitSiraNo > 0) then
      begin

        DurumCubugu0.DurumYazisiDegistir('Aygýt: ' +
          FizikselSurucuListesi[SeciliAygitSiraNo].AygitAdi + ' - Sektör: ' +
          HexToStr(FizikselSurucuListesi[SeciliAygitSiraNo].ToplamSektorSayisi, True, 8) + ' / ' +
          HexToStr(MevcutSektor, True, 8));

        AygitOkumaDurumu := FizikselDepolamaVeriOku(SeciliAygitSiraNo,
          MevcutSektor, 1, @DiskBellek);
        Pencere0.Ciz;
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      if(FizikselDepolamaAygitSayisi = 0) then
      begin

        Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
        Pencere0.Tuval.YaziYaz(0, 58, DepolamaAygitiBulunamadi);
      end
      else
      begin

        Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
        if(SeciliAygitSiraNo = 0) then

          Pencere0.Tuval.YaziYaz(0, 58, DepolamaAygitiSeciniz)
        else if(AygitOkumaDurumu = 0) then

          Pencere0.Tuval.YaziYaz(0, 58, DepolamaAygitiOkumaHatasi)
        else
        begin

          SektorAdresleriniYaz(MevcutSektor);
          SektorSiraDegerleriniYaz;
          SektorIceriginiYaz;
        end;
      end;
    end;

  until (1 = 2);
end.
