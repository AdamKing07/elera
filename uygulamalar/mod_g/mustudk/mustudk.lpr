program mustudk;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: mustudk.lpr
  Program Ýþlevi: masaüstü duvar kaðýt yönetim programý

  Güncelleme Tarihi: 14/06/2020

 ==============================================================================}
{$mode objfpc}
uses gn_masaustu, n_gorev, gn_pencere, gn_dugme, gn_etiket, gn_secimdugmesi,
  gn_listekutusu;

const
  ProgramAdi: string = 'Masaüstü Duvar Kaðýdý';
  MasaustuRenkleri: array[0..15] of TRenk = (
    $FFFFFF, $C0C0C0, $808080, $000000, $FF0000, $800000, $FFFF00, $808000,
    $00FF00, $008000, $00FFFF, $008080, $0000FF, $000080, $FF00FF, $800080);

var
  DosyaAramaListesi: array[0..15] of TDosyaArama;

var
  Gorev: TGorev;
  masELERA: TMasaustu;
  Pencere: TPencere;
  lkDosyaListesi: TListeKutusu;
  etiBilgi: array[0..1] of TEtiket;
  sdRenkler: array[0..15] of TSecimDugmesi;
  OlayKayit: TOlayKayit;
  Sol, Ust, i: TISayi4;

procedure DosyalariListele;
var
  DosyaArama: TDosyaArama;
  AramaSonuc, i, j: TSayi4;
begin

  lkDosyaListesi.Temizle;

  j := 0;

  AramaSonuc := _FindFirst('disk1:\*.*', 0, DosyaArama);

  while (AramaSonuc = 0) do
  begin

    i := Length(DosyaArama.DosyaAdi);
    if(i > 4) and (DosyaArama.DosyaAdi[i - 3] = '.') and
      (DosyaArama.DosyaAdi[i - 2] = 'b') and (DosyaArama.DosyaAdi[i - 1] = 'm') and
      (DosyaArama.DosyaAdi[i] = 'p') then
    begin

      DosyaAramaListesi[j] := DosyaArama;
      lkDosyaListesi.ElemanEkle(DosyaAramaListesi[j].DosyaAdi);

      Inc(j);
    end;

    AramaSonuc := _FindNext(DosyaArama);
  end;

  _FindClose(DosyaArama);
end;

begin

  Pencere.Olustur(-1, 100, 100, 208, 395, ptIletisim, ProgramAdi, $FFFFCC);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  // liste kutusu oluþtur
  lkDosyaListesi.Olustur(Pencere.Kimlik, 5, 286, 195, 100);
  lkDosyaListesi.Goster;

  DosyalariListele;

  etiBilgi[0].Olustur(Pencere.Kimlik, 5, 0, $FF0000, 'Masaüstü Renkleri:');
  etiBilgi[0].Goster;

  etiBilgi[1].Olustur(Pencere.Kimlik, 5, 270, $FF0000, 'Masaüstü Resimleri:');
  etiBilgi[1].Goster;

  Sol := 17;
  Ust := 60;
  for i := 1 to 16 do
  begin

    sdRenkler[i - 1].Olustur(Pencere.Kimlik, Sol, Ust, '');
    sdRenkler[i - 1].Goster;

    Sol += 50;
    if((i mod 4) = 0) then
    begin

      Sol := 17;
      Ust += 60;
    end;
  end;

  // pencereyi görüntüle
  Pencere.Goster;

  masELERA.AktifMasaustu;

  // ana döngü
  while True do
  begin

    Gorev.OlayBekle(OlayKayit);

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

      Sol := 5;
      Ust := 18;
      for i := 1 to 16 do
      begin

        Pencere.Tuval.Dikdortgen(Sol, Ust, 40, 40, MasaustuRenkleri[i - 1], True);

        Sol += 50;
        if((i mod 4) = 0) then
        begin

          Sol := 5;
          Ust += 60;
        end;
      end;
    end;
  end;
end.
