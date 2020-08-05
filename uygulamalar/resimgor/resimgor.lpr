program resimgor;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: resimgor.lpr
  Program ��levi: resim g�r�nt�leyici program

  G�ncelleme Tarihi: 15/07/2020

 ==============================================================================}
{$mode objfpc}
uses gn_masaustu, n_gorev, gn_pencere, gn_dugme, gn_etiket, gn_listekutusu,
  gn_resim, gn_durumcubugu, n_genel;

const
  ProgramAdi: string = 'Resim G�r�nt�leyici';

var
  DosyaAramaListesi: array[0..20] of TDosyaArama;

var
  Genel: TGenel;
  Gorev: TGorev;
  Pencere: TPencere;
  lkDosyaListesi: TListeKutusu;
  DurumCubugu: TDurumCubugu;
  Resim: TResim;
  Olay: TOlay;
  i: TISayi4;
  GoruntulenecekDosya: string;

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
    if(i > 4) and (DosyaArama.DosyaAdi[i - 3] = '.') and (DosyaArama.DosyaAdi[i - 2] = 'b') and
      (DosyaArama.DosyaAdi[i - 1] = 'm') and (DosyaArama.DosyaAdi[i] = 'p') then
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

  Pencere.Olustur(-1, 50, 50, 400, 300, ptBoyutlanabilir, ProgramAdi, $C0C4C3);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  DurumCubugu.Olustur(Pencere.Kimlik, 0, 0, 10, 22, 'Dosya: -');
  DurumCubugu.Goster;

  // liste kutusu olu�tur
  lkDosyaListesi.Olustur(Pencere.Kimlik, 0, 0, 100, 52);
  lkDosyaListesi.Hizala(hzSol);
  lkDosyaListesi.Goster;

  Resim.Olustur(Pencere.Kimlik, 0, 60, 490, 420, '');
  Resim.Hizala(hzTum);
  Resim.TuvaleSigdir(True);
  Resim.Goster;

  DosyalariListele;

  // pencereyi g�r�nt�le
  Pencere.Goster;

  if(ParamCount > 0) then
  begin

    GoruntulenecekDosya := ParamStr1(1);
    Resim.Degistir(GoruntulenecekDosya);
    DurumCubugu.DurumYazisiDegistir('Dosya: ' + GoruntulenecekDosya);
  end;

  // ana d�ng�
  while True do
  begin

    Gorev.OlayBekle(Olay);

    if(Olay.Olay = FO_TIKLAMA) then
    begin

      // liste kutusuna t�klanmas� halinde dosyay� �al��t�r
      if(Olay.Kimlik = lkDosyaListesi.Kimlik) then
      begin

        i := lkDosyaListesi.SeciliSiraNoAl;
        GoruntulenecekDosya := 'disk1:\' + DosyaAramaListesi[i].DosyaAdi;
        Resim.Degistir(GoruntulenecekDosya);
        DurumCubugu.DurumYazisiDegistir('Dosya: ' + GoruntulenecekDosya);
      end
    end;
  end;
end.
