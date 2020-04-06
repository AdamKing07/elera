program dsyyntcs;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: dsyyntcs.lpr
  Program ��levi: dosya y�neticisi

  G�ncelleme Tarihi: 03/11/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, gn_dugme, gn_listegorunum, gn_durumcubugu, gn_panel;

const
  ProgramAdi: string = 'Dosya Y�neticisi';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Panel0: TPanel;
  DurumCubugu0: TDurumCubugu;
  lgDosyaListesi: TListeGorunum;
  dugSuruculer: array[1..6] of TDugme;
  OlayKayit: TOlayKayit;
  MantiksalSurucuListesi: array[1..6] of TMantiksalSurucu3;
  MantiksalDepolamaAygitSayisi, i, _DugmeA1, _DosyaSayisi: LongInt;
  GecerliSurucu, SeciliYazi, s: string;

function MantiksalDepolamaAygitSayisiAl: TISayi4; assembler;
asm
  mov   eax,$010F
  int   $34
end;

function MantiksalDepolamaAygitBilgisiAl(AAygitKimlik: TSayi4;
  AMantiksalSurucu3: PMantiksalSurucu3): Boolean; assembler;
asm
  push  AMantiksalSurucu3
  push  AAygitKimlik
  mov   eax,$020F
  int   $34
  add   esp,8
end;

procedure DosyalariListele;
var
  _DosyaArama: TDosyaArama;
  _AramaSonuc: TSayi4;
  _SonDegisimTarihi, _SonDegisimSaati: TSayi2;
  _TarihDizi: array[0..2] of TSayi2;
  _SaatDizi: array[0..2] of TSayi1;
  _Tarih, _Saat, _GirdiTip: string;
begin

  if(GecerliSurucu <> '') then
  begin

    lgDosyaListesi.Temizle;

    _DosyaSayisi := 0;

    _AramaSonuc := _FindFirst(GecerliSurucu + ':\*.*', 0, _DosyaArama);

    while (_AramaSonuc = 0) do
    begin

      _SonDegisimTarihi := _DosyaArama.SonDegisimTarihi;
      _TarihDizi[0] := _SonDegisimTarihi and 31;
      _TarihDizi[1] := (_SonDegisimTarihi shr 5) and 15;
      _TarihDizi[2] := ((_SonDegisimTarihi shr 9) and 127) + 1980;
      _Tarih := DateToStr(_TarihDizi, False);

      _SonDegisimSaati := _DosyaArama.SonDegisimSaati;
      _SaatDizi[2] := (_SonDegisimSaati and 31) * 2;
      _SaatDizi[1] := (_SonDegisimSaati shr 5) and 63;
      _SaatDizi[0] := (_SonDegisimSaati shr 11) and 31;
      _Saat := TimeToStr(_SaatDizi);

      if((_DosyaArama.Ozellikler and $10) = $10) then
        _GirdiTip := 'Dizin'
      else _GirdiTip := 'Dosya';

      lgDosyaListesi.ElemanEkle(_DosyaArama.DosyaAdi + '|' + _Tarih + ' ' + _Saat + '|' +
        _GirdiTip + '|' + IntToStr1(_DosyaArama.DosyaUzunlugu));

      Inc(_DosyaSayisi);

      _AramaSonuc := _FindNext(_DosyaArama);
    end;
    _FindClose(_DosyaArama);

    DurumCubugu0.DurumYazisiDegistir('Toplam Dosya: ' + IntToStr1(_DosyaSayisi));

    Pencere0.Ciz;
  end;
end;

begin

  Pencere0.Olustur(-1, 20, 20, 510, 325, ptBoyutlandirilabilir, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Panel0.Olustur(Pencere0.Kimlik, 0, 0, 100, 45, 0, 0, 0, 0, '');
  Panel0.Hizala(hzUst);
  Panel0.Goster;

  // yerel de�i�kenleri s�f�rla
  for i := 1 to 6 do
  begin

    FillByte(MantiksalSurucuListesi[i], SizeOf(TMantiksalSurucu3), 0);
  end;

  // ge�erli s�r�c� atamas�
  GecerliSurucu := '';

  // her mant�ksal s�r�c� i�in bir adet d��me olu�tur
  MantiksalDepolamaAygitSayisi := MantiksalDepolamaAygitSayisiAl;
  if(MantiksalDepolamaAygitSayisi > 0) then
  begin

    _DugmeA1 := 2;
    for i := 1 to MantiksalDepolamaAygitSayisi do
    begin

      if(MantiksalDepolamaAygitBilgisiAl(i, @MantiksalSurucuListesi[i])) then
      begin

        dugSuruculer[i].Olustur(Panel0.Kimlik, _DugmeA1, 2, 65, 22, MantiksalSurucuListesi[i].AygitAdi);
        dugSuruculer[i].Goster;
        _DugmeA1 += 70;
      end;
    end;
  end;

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 20, 'Toplam Dosya: -');
  DurumCubugu0.Goster;

  // liste g�r�n�m nesnesi olu�tur
  lgDosyaListesi.Olustur(Pencere0.Kimlik, 2, 47, 496, 300 - 73);
  lgDosyaListesi.Hizala(hzTum);

  // liste g�r�n�m ba�l�klar�n� ekle
  lgDosyaListesi.BaslikEkle('Dosya Ad�', 150);
  lgDosyaListesi.BaslikEkle('Tarih / Saat', 165);
  lgDosyaListesi.BaslikEkle('Tip', 80);
  lgDosyaListesi.BaslikEkle('Boyut', 80);

  // pencereyi g�r�nt�le
  Pencere0.Goster;

  // ana d�ng�
  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = Pencere0.Kimlik) then
      begin

      end

      // liste kutusuna t�klanmas� halinde dosyay� �al��t�r
      else if(OlayKayit.Kimlik = lgDosyaListesi.Kimlik) then
      begin

        SeciliYazi := lgDosyaListesi.SeciliYaziAl;

        // dosya bilgisinden dosya ad ve uzant� bilgisini al
        i := Pos('|', SeciliYazi);
        if(i > 0) then
          s := Copy(SeciliYazi, 1, i - 1)
        else s := SeciliYazi;

        Gorev0.Calistir(GecerliSurucu + ':\' + s);
      end
      else

      // aksi durumda hangi d��meye t�kland� ?
      begin

        // bul.
        for i := 1 to 6 do
        begin

          if(dugSuruculer[i].Kimlik = OlayKayit.Kimlik) then
          begin

            GecerliSurucu := MantiksalSurucuListesi[i].AygitAdi;
            Break;
          end;
        end;

        DosyalariListele;
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_MAVI;

      if(GecerliSurucu = '') then

        Pencere0.Tuval.YaziYaz(2, 30, 'Aktif S�r�c�: Yok')
      else Pencere0.Tuval.YaziYaz(2, 30, 'Aktif S�r�c�: ' + GecerliSurucu);
    end;

  until (1 = 2);
end.
