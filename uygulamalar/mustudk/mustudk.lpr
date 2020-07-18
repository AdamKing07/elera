program mustudk;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: mustudk.lpr
  Program ��levi: masa�st� duvar ka��t y�netim program�

  G�ncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
uses gn_masaustu, n_gorev, gn_pencere, gn_dugme, gn_etiket, gn_secimdugmesi,
  gn_listekutusu, gn_renksecici, n_genel;

const
  ProgramAdi: string = 'Masa�st� Duvar Ka��d�';

var
  DosyaAramaListesi: array[0..15] of TDosyaArama;

var
  Genel: TGenel;
  Gorev: TGorev;
  masELERA: TMasaustu;
  Pencere: TPencere;
  lkDosyaListesi: TListeKutusu;
  etiBilgi: array[0..1] of TEtiket;
  RenkSecici: TRenkSecici;
  OlayKayit: TOlayKayit;
  i: TISayi4;

procedure DosyalariListele;
var
  DosyaArama: TDosyaArama;
  AramaSonuc, i, j: TSayi4;
begin

  lkDosyaListesi.Temizle;

  j := 0;

  AramaSonuc := Genel._FindFirst('disk1:\*.*', 0, DosyaArama);

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

    AramaSonuc := Genel._FindNext(DosyaArama);
  end;

  Genel._FindClose(DosyaArama);
end;

begin

  Pencere.Olustur(-1, 100, 100, 200, 190, ptIletisim, ProgramAdi, $F9FAF9);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  etiBilgi[0].Olustur(Pencere.Kimlik, 5, 0, $FF0000, 'Masa�st� Renkleri:');
  etiBilgi[0].Goster;

  RenkSecici.Olustur(Pencere.Kimlik, 5, 21, 190, 32);
  RenkSecici.Goster;

  etiBilgi[1].Olustur(Pencere.Kimlik, 5, 60, $FF0000, 'Masa�st� Resimleri:');
  etiBilgi[1].Goster;

  // liste kutusu olu�tur
  lkDosyaListesi.Olustur(Pencere.Kimlik, 5, 76, 190, 107);
  lkDosyaListesi.Goster;

  DosyalariListele;

  // pencereyi g�r�nt�le
  Pencere.Goster;

  masELERA.AktifMasaustu;

  // ana d�ng�
  while True do
  begin

    Gorev.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      // liste kutusuna t�klanmas� halinde dosyay� �al��t�r
      if(OlayKayit.Kimlik = lkDosyaListesi.Kimlik) then
      begin

        i := lkDosyaListesi.SeciliSiraNoAl;
        masELERA.MasaustuResminiDegistir('disk1:\' + DosyaAramaListesi[i].DosyaAdi);
        masELERA.Guncelle;
      end
      else if(OlayKayit.Kimlik = RenkSecici.Kimlik) then
      begin

        masELERA.MasaustuRenginiDegistir(OlayKayit.Deger1);
        masELERA.Guncelle;
      end;
    end
  end;
end.
