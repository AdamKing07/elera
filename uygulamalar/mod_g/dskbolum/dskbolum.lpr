program dskbolum;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: dskbolum.lpr
  Program Ýþlevi: sistemdeki mantýksal sürücü bilgisini verir

  Güncelleme Tarihi: 08/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, gn_dugme;

var
  Pencere0: TPencere;
  dugDepolama: array[1..6] of TDugme;

const
  ProgramAdi: string = 'Depolama Aygýtý Bölüm Bilgisi';

  DepolamaAygitiBulunamadi: string  = 'Sistemde depolama aygýtý bulunamadý!';
  DepolamaAygitiSeciniz: string  = 'Lütfen bir depolama aygýtý seçiniz!';

var
  Gorev0: TGorev;
  OlayKayit: TOlayKayit;
  DiskSayisi, SeciliDisk,
  DugmeA1, i: TISayi4;
  MantiksalSurucuListesi: array[1..6] of TMantiksalSurucu3;

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

procedure AygitBilgileriniYaz(ASiraNo: TSayi4);
var
  MantiksalSurucu3: PMantiksalSurucu3;
begin

  MantiksalSurucu3 := @MantiksalSurucuListesi[ASiraNo];

  // sürücü tipi
  Pencere0.Tuval.KalemRengi := RENK_SIYAH;
  Pencere0.Tuval.YaziYaz(0, 2 * 16, 'Sürücü Tipi  :');
  if(MantiksalSurucu3^.SurucuTipi = SURUCUTIP_DISKET) then
    Pencere0.Tuval.YaziYaz(15 * 8, 2 * 16, 'Disket Sürücüsü')
  else if(MantiksalSurucu3^.SurucuTipi = SURUCUTIP_DISK) then
    Pencere0.Tuval.YaziYaz(15 * 8, 2 * 16, 'Disk Sürücüsü');

    // sürücü dosya sistemi
    Pencere0.Tuval.YaziYaz(0, 3 * 16, 'Dosya Sistemi:');
    if(MantiksalSurucu3^.DosyaSistemTipi = DATTIP_FAT12) then
      Pencere0.Tuval.YaziYaz(15 * 8, 3 * 16, 'FAT12')
    else if(MantiksalSurucu3^.DosyaSistemTipi = DATTIP_FAT16) then
      Pencere0.Tuval.YaziYaz(15 * 8, 3 * 16, 'FAT16')
    else if(MantiksalSurucu3^.DosyaSistemTipi = DATTIP_FAT32) then
      Pencere0.Tuval.YaziYaz(15 * 8, 3 * 16, 'FAT32')
    else if(MantiksalSurucu3^.DosyaSistemTipi = DATTIP_FAT32LBA) then
      Pencere0.Tuval.YaziYaz(15 * 8, 3 * 16, 'FAT32+LBA');

  // ilk sektör
  Pencere0.Tuval.YaziYaz(0, 4 * 16, 'Ýlk Sektör   :');
  Pencere0.Tuval.SayiYaz16(15 * 8, 4 * 16, False, 8, MantiksalSurucu3^.BolumIlkSektor);

  // toplam sektör
  Pencere0.Tuval.YaziYaz(0, 5 * 16, 'Toplam Sektör:');
  Pencere0.Tuval.SayiYaz16(15 * 8, 5 * 16, False, 8, MantiksalSurucu3^.BolumToplamSektor);
end;

begin

  Pencere0.Olustur(-1, 50, 50, 310, 95, ptBoyutlandirilabilir, ProgramAdi, $EEF0D1);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  DiskSayisi := MantiksalDepolamaAygitSayisiAl;
  if(DiskSayisi > 0) then
  begin

    DugmeA1 := 2;
    for i := 1 to DiskSayisi do
    begin

      if(MantiksalDepolamaAygitBilgisiAl(i, @MantiksalSurucuListesi[i])) then
      begin

        dugDepolama[i].Olustur(Pencere0.Kimlik, DugmeA1, 2, 65, 22,
          MantiksalSurucuListesi[i].AygitAdi);
        dugDepolama[i].Etiket := i;
        dugDepolama[i].Goster;
        DugmeA1 += 70;
      end else dugDepolama[i].Etiket := 0;
    end;
  end;

  Pencere0.Goster;

  SeciliDisk := 0;

  while True do
  begin

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      for i := 1 to 6 do
      begin

        if(dugDepolama[i].Kimlik = OlayKayit.Kimlik) then
        begin

          SeciliDisk := dugDepolama[i].Etiket;
          Break;
        end;
      end;

      Pencere0.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      if(DiskSayisi = 0) then
      begin

        Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
        Pencere0.Tuval.YaziYaz(0, 0 * 16, DepolamaAygitiBulunamadi);
      end
      else
      begin

        if(SeciliDisk = 0) then
        begin

          Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
          Pencere0.Tuval.YaziYaz(0, 2 * 16, DepolamaAygitiSeciniz);
        end
        else
        begin

          AygitBilgileriniYaz(SeciliDisk);
        end;
      end;
    end;
  end;
end.
