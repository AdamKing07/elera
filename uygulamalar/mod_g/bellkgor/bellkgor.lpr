program bellkgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: bellkgor.lpr
  Program Ýþlevi: bellek içerik görüntüleme programý

  Güncelleme Tarihi: 25/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_giriskutusu, gn_durumcubugu, elera;

const
  ProgramAdi: string = 'Bellek Ýçerik Görüntüleyici';
  MEVCUTBELLEKADRESI = $10000;

var
  Pencere0: TPencere;
  DurumCubugu0: TDurumCubugu;
  _ToplamRAMBlok, AyrilmisRAMBlok,
  _KullanilanRAMBlok, _BosRAMBlok,
  _BlokUzunlugu, _ToplamRAMUzunlugu,
  _MevcutBellekAdresi: TSayi4;
  _VeriBellek: array[0..1023] of TSayi1;

var
  Gorev0: TGorev;
  OlayKayit: TOlayKayit;
  gkAdres: TGirisKutusu;
  dugArtir, dugAzalt,
  dugYenile: TDugme;
  s: string;

procedure BellekAdresiniYaz(ABellekAdresi: TSayi4);
var
  _ABellekAdresi, i, _B1: TSayi4;
begin

  _B1 := 32;
  _ABellekAdresi := ABellekAdresi;

  for i := 0 to 31 do
  begin

    Pencere0.Tuval.KalemRengi := RENK_SIYAH;
    Pencere0.Tuval.SayiYaz16(0, _B1, True, 8, _ABellekAdresi);
    _ABellekAdresi += 16;
    _B1 += 16;
  end;
end;

procedure BellekIcerigini16TabanliYaz;
var
  _A1, _B1: TSayi4;
  _Deger: TSayi1;
begin

  for _B1 := 0 to 31 do
  begin

    for _A1 := 0 to 15 do
    begin

      _Deger := _VeriBellek[(_B1 * 16) + _A1];
      if((_A1 and 1) = 1) then
      begin

        Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
        // (_A1 * 3) = 2 hex + 1 boþ deðer
        // + 11 = 10 hex + 1 boþ deðer
        Pencere0.Tuval.SayiYaz16(((_A1 * 3) + 11) * 8, (_B1 * 16) + 32, False, 2, _Deger)
      end
      else
      begin

        Pencere0.Tuval.KalemRengi := RENK_MAVI;
        Pencere0.Tuval.SayiYaz16(((_A1 * 3) + 11) * 8, (_B1 * 16) + 32, False, 2, _Deger);
      end;
    end;
  end;
end;

procedure BellekIceriginiKarakterOlarakYaz;
var
  _A1, _B1: TSayi4;
  _Deger: Char;
begin

  for _B1 := 0 to 31 do
  begin

    for _A1 := 0 to 15 do
    begin

      _Deger := Char(_VeriBellek[(_B1 * 16) + _A1]);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.HarfYaz((_A1 + 59) * 8, (_B1 * 16) + 32, _Deger);
    end;
  end;
end;

begin

  Pencere0.Olustur(-1, 5, 5, 615, 600, ptBoyutlandirilabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Bellek Adresi: ' +
    HexToStr(MEVCUTBELLEKADRESI, True, 8));
  DurumCubugu0.Goster;

  Pencere0.Tuval.YaziYaz(0, 7, 'Adres[16lý]:');

  gkAdres.Olustur(Pencere0.Kimlik, 110, 3, 120, 22, HexToStr(MEVCUTBELLEKADRESI,
    False, 8));
  gkAdres.SadeceRakam := True;
  gkAdres.Goster;

  dugAzalt.Olustur(Pencere0.Kimlik, 238, 3, 35, 22, ' <');
  dugAzalt.Goster;

  dugArtir.Olustur(Pencere0.Kimlik, 275, 3, 35, 22, ' >');
  dugArtir.Goster;

  dugYenile.Olustur(Pencere0.Kimlik, 312, 3, 80, 22, ' Yenile');
  dugYenile.Goster;

  GenelBellekBilgisiAl(@_ToplamRAMBlok, @AyrilmisRAMBlok, @_KullanilanRAMBlok,
    @_BosRAMBlok, @_BlokUzunlugu);

  _ToplamRAMUzunlugu := _ToplamRAMBlok * _BlokUzunlugu;

  _MevcutBellekAdresi := MEVCUTBELLEKADRESI;

  Pencere0.Goster;

  BellekIcerikOku(Isaretci(_MevcutBellekAdresi), @_VeriBellek[0], 512);

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      if(OlayKayit.Deger1 = 10) then
      begin

        s := gkAdres.IcerikAl;
        _MevcutBellekAdresi := StrToHex(s);

        DurumCubugu0.DurumYazisiDegistir('Bellek Adresi: ' +
          HexToStr(_MevcutBellekAdresi, True, 8));

        BellekIcerikOku(Isaretci(_MevcutBellekAdresi), @_VeriBellek[0], 512);

        Pencere0.Ciz;
      end;
    end
    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugArtir.Kimlik) then
      begin

        if(_MevcutBellekAdresi + 512 > _ToplamRAMUzunlugu) then
          _MevcutBellekAdresi := _ToplamRAMUzunlugu - 512
        else _MevcutBellekAdresi := _MevcutBellekAdresi + 512;
      end
      else if(OlayKayit.Kimlik = dugAzalt.Kimlik) then
      begin

        if(_MevcutBellekAdresi - 512 < 0) then
          _MevcutBellekAdresi := 0
        else _MevcutBellekAdresi := _MevcutBellekAdresi - 512;
      end;

      DurumCubugu0.DurumYazisiDegistir('Bellek Adresi: ' +
        HexToStr(_MevcutBellekAdresi, True, 8));

      BellekIcerikOku(Pointer(_MevcutBellekAdresi), @_VeriBellek[0], 512);

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 7, 'Adres[16lý]:');

      BellekAdresiniYaz(_MevcutBellekAdresi);
      BellekIcerigini16TabanliYaz;
      BellekIceriginiKarakterOlarakYaz;
    end;

  until (1 = 2);
end.
