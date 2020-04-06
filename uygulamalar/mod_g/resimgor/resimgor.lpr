program resimgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: resimgor.lpr
  Program Ýþlevi: resim görüntüleyici program

  Güncelleme Tarihi: 08/11/2019

 ==============================================================================}
{$mode objfpc}
uses gn_masaustu, gorev, gn_pencere, gn_dugme, gn_etiket, gn_secimdugme,
  gn_listekutusu, gn_resim, gn_durumcubugu;

const
  ProgramAdi: string = 'Resim Görüntüleyici';

var
  DosyaAramaListesi: array[0..20] of TDosyaArama;

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  lkDosyaListesi: TListeKutusu;
  DurumCubugu0: TDurumCubugu;
  Resim0: TResim;
  OlayKayit: TOlayKayit;
  i: LongInt;
  GoruntulenecekDosya: string;

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
    if(_i > 4) and (_DosyaArama.DosyaAdi[_i - 3] = '.') and (_DosyaArama.DosyaAdi[_i - 2] = 'b') and
      (_DosyaArama.DosyaAdi[_i - 1] = 'm') and (_DosyaArama.DosyaAdi[_i] = 'p') then
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

  Pencere0.Olustur(-1, 50, 50, 400, 300, ptBoyutlandirilabilir, ProgramAdi, $C0C4C3);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 10, 22, 'Dosya: -');
  DurumCubugu0.Goster;

  // liste kutusu oluþtur
  lkDosyaListesi.Olustur(Pencere0.Kimlik, 0, 0, 100, 52);
  lkDosyaListesi.Hizala(hzSol);

  Resim0.Olustur(Pencere0.Kimlik, 0, 60, 490, 420, '');
  Resim0.Hizala(hzTum);
  Resim0.TuvaleSigdir(True);
  Resim0.Goster;

  DosyalariListele;

  // pencereyi görüntüle
  Pencere0.Goster;

  if(ParamCount > 0) then
  begin

    GoruntulenecekDosya := ParamStr1(1);
    Resim0.Degistir(GoruntulenecekDosya);
    DurumCubugu0.DurumYazisiDegistir('Dosya: ' + GoruntulenecekDosya);
  end;

  // ana döngü
  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      // liste kutusuna týklanmasý halinde dosyayý çalýþtýr
      if(OlayKayit.Kimlik = lkDosyaListesi.Kimlik) then
      begin

        i := lkDosyaListesi.SeciliSiraNoAl;
        GoruntulenecekDosya := 'disk1:\' + DosyaAramaListesi[i].DosyaAdi;
        Resim0.Degistir(GoruntulenecekDosya);
        DurumCubugu0.DurumYazisiDegistir('Dosya: ' + GoruntulenecekDosya);
      end
    end;
  until (1 = 2);
end.
