program defter;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: defter.lpr
  Program Ýþlevi: metin düzenleme programý

  Güncelleme Tarihi: 22/06/2020

  Bilgi: çekirdek tarafýndan defter.c programýna bilgileri iþlemesi için
    Isaretci(4)^ adresinde 4096 * 10 byte yer tahsis edilmiþtir.

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, gn_durumcubugu, gn_etiket, gn_giriskutusu, gn_dugme,
  gn_defter, gn_panel;

const
  ProgramAdi: string = 'Dijital Defter';
  DOSYA_BELLEK_KAPASITESI = Integer(4096 * 10);

var
  Gorev: TGorev;
  Pencere: TPencere;
  Panel: TPanel;
  DurumCubugu: TDurumCubugu;
  Defter0: TDefter;
  etiDosyaAdi: TEtiket;
  gkDosyaAdi: TGirisKutusu;
  dugYukle: TDugme;
  OlayKayit: TOlayKayit;
  DosyaKimlik: TKimlik;
  DosyaUzunluk: TSayi4;
  DosyaAdi: string;
  DosyaBellek: PChar;

procedure BellekTemizle;
var
  i: TSayi4;
  p: PChar;
begin

  p := DosyaBellek;
  for i := 0 to DOSYA_BELLEK_KAPASITESI - 1 do p[i] := #0;
end;

procedure DosyaAc;
var
  s: string;
begin

  BellekTemizle;

  Defter0.Temizle;

  _AssignFile(DosyaKimlik, DosyaAdi);
  _Reset(DosyaKimlik);

  DosyaUzunluk := _FileSize(DosyaKimlik);

  if(DosyaUzunluk <= DOSYA_BELLEK_KAPASITESI) then
  begin

    //_IOResult;

    //_EOF(DosyaKimlik);

    _FileRead(DosyaKimlik, DosyaBellek);
  end;

  _CloseFile(DosyaKimlik);

  if(DosyaUzunluk > DOSYA_BELLEK_KAPASITESI) then
  begin

    Defter0.YaziEkle('Hata: dosya boyutu en fazla ' + IntToStr(DOSYA_BELLEK_KAPASITESI) +
      ' byte olmalýdýr.' + #0);

    s := 'Dosya: -';

    DurumCubugu.DurumYazisiDegistir(s);
  end
  else if(DosyaAdi <> '') then
  begin

    Defter0.YaziEkle(DosyaBellek);

    s := 'Dosya: ' + DosyaAdi + ', ' + IntToStr(DosyaUzunluk) + ' byte';

    DurumCubugu.DurumYazisiDegistir(s);
  end;
end;

begin

  Pencere.Olustur(-1, 10, 10, 400 + 10, 300 + 85, ptBoyutlandirilabilir, ProgramAdi,
    RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Panel.Olustur(Pencere.Kimlik, 0, 0, 100, 32, 2, RENK_GRI, $E0EEFA, 0, '');
  Panel.Hizala(hzUst);
  Panel.Goster;

  etiDosyaAdi.Olustur(Panel.Kimlik, 2, 9, $000000, 'Dosya Adý:');
  etiDosyaAdi.Goster;

  gkDosyaAdi.Olustur(Panel.Kimlik, 11 * 8, 6, 27 * 8, 22, '');
  gkDosyaAdi.IcerikYaz('disk1:\haklar.txt');
  gkDosyaAdi.Goster;

  dugYukle.Olustur(Panel.Kimlik, 39 * 8, 5, 60, 22, 'Yükle');
  dugYukle.Goster;

  DurumCubugu.Olustur(Pencere.Kimlik, 0, 0, 100, 18, '');
  DurumCubugu.Goster;

  Defter0.Olustur(Pencere.Kimlik, 0, 0, 10, 10, RENK_BEYAZ, RENK_SIYAH);
  Defter0.Hizala(hzTum);
  Defter0.Goster;

  Pencere.Goster;

  // programa tahsis edilmiþ bellek adresini al
  DosyaBellek := PChar(Isaretci(4)^);

  DosyaAdi := '';

  if(ParamCount > 0) then
  begin

    DosyaAdi := ParamStr1(1);

    gkDosyaAdi.IcerikYaz(DosyaAdi);

    DosyaAc;
  end;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_SOLTUS_BASILDI) then
    begin

      if(OlayKayit.Olay = dugYukle.Kimlik) then
      begin

        DosyaAdi := gkDosyaAdi.IcerikAl;

        gkDosyaAdi.IcerikYaz(DosyaAdi);

        DosyaAc;
      end;
    end;
  end;
end.
