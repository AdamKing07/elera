program mustudk;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: mustudk.lpr
  Program Ýþlevi: masaüstü duvar kaðýt yönetim programý

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gn_masaustu, gorev, gn_pencere, gn_dugme, gn_etiket, gn_secimdugme,
  gn_listekutusu;

const
  ProgramAdi: string = 'Masaüstü Duvar Kaðýdý';
  MasaustuRenkleri: array[0..15] of TRenk = (
    $FFFFFF, $C0C0C0, $808080, $000000, $FF0000, $800000, $FFFF00, $808000,
    $00FF00, $008000, $00FFFF, $008080, $0000FF, $000080, $FF00FF, $800080);

var
  DosyaAramaListesi: array[0..15] of TDosyaArama;

var
  Gorev0: TGorev;
  masELERA: TMasaustu;
  Pencere0: TPencere;
  lkDosyaListesi: TListeKutusu;
  etiBilgi: array[0..1] of TEtiket;
  sdRenkler: array[0..15] of TSecimDugme;
  OlayKayit: TOlayKayit;
  i, _A1, _B1: LongInt;

procedure DosyalariListele;
var
  _DosyaArama: TDosyaArama;
  _AramaSonuc, _i, _j: TSayi4;
begin

  lkDosyaListesi.Temizle;

  _j := 0;

  _AramaSonuc := _FindFirst('disk1:\*.*', 0, _DosyaArama);

  while (_AramaSonuc = 0) do
  begin

    _i := Length(_DosyaArama.DosyaAdi);
    if(_i > 4) and (_DosyaArama.DosyaAdi[_i - 3] = '.') and
      (_DosyaArama.DosyaAdi[_i - 2] = 'b') and (_DosyaArama.DosyaAdi[_i - 1] = 'm') and
      (_DosyaArama.DosyaAdi[_i] = 'p') then
    begin

      DosyaAramaListesi[_j] := _DosyaArama;
      lkDosyaListesi.ElemanEkle(DosyaAramaListesi[_j].DosyaAdi);

      Inc(_j);
    end;

    _AramaSonuc := _FindNext(_DosyaArama);
  end;

  _FindClose(_DosyaArama);
end;

begin

  Pencere0.Olustur(-1, 100, 100, 208, 410, ptIletisim, ProgramAdi, $FFFFCC);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  // liste kutusu oluþtur
  lkDosyaListesi.Olustur(Pencere0.Kimlik, 0, 286, 195, 80 + 4);

  DosyalariListele;

  etiBilgi[0].Olustur(Pencere0.Kimlik, 0, 0, $FF0000, 'Masaüstü Renkleri:');
  etiBilgi[0].Goster;

  etiBilgi[1].Olustur(Pencere0.Kimlik, 0, 270, $FF0000, 'Masaüstü Resimleri:');
  etiBilgi[1].Goster;

  _A1 := 12;
  _B1 := 60;
  for i := 1 to 16 do
  begin

    sdRenkler[i - 1].Olustur(Pencere0.Kimlik, _A1, _B1, '');
    sdRenkler[i - 1].Goster;

    _A1 += 50;
    if((i mod 4) = 0) then
    begin

      _A1 := 12;
      _B1 += 60;
    end;
  end;

  // pencereyi görüntüle
  Pencere0.Goster;

  masELERA.AktifMasaustu;

  // ana döngü
  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      // liste kutusuna týklanmasý halinde dosyayý çalýþtýr
      if(OlayKayit.Kimlik = lkDosyaListesi.Kimlik) then
      begin

        i := lkDosyaListesi.SeciliSiraNoAl;
        masELERA.MasaustuResminiDegistir('disk1:\' + DosyaAramaListesi[i].DosyaAdi);
        masELERA.Guncelle;
      end
    end
    else if(OlayKayit.Olay = CO_DURUMDEGISTI) then
    begin

      for i := 0 to 15 do
      begin

        if(sdRenkler[i].Kimlik <> OlayKayit.Kimlik) then
          sdRenkler[i].DurumDegistir(sdNormal)
        else
        begin

          masELERA.MasaustuRenginiDegistir(MasaustuRenkleri[i]);
          masELERA.Guncelle;
        end;
      end;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      _A1 := 0;
      _B1 := 18;
      for i := 1 to 16 do
      begin

        Pencere0.Tuval.Dikdortgen(_A1, _B1, 40, 40, MasaustuRenkleri[i - 1], True);

        _A1 += 50;
        if((i mod 4) = 0) then
        begin

          _A1 := 0;
          _B1 += 60;
        end;
      end;
    end;
  until (1 = 2);
end.
