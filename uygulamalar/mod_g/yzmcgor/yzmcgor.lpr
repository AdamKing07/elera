program yzmcgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: yzmcgor.lpr
  Program Ýþlevi: programýn yazmaç içeriðini görüntüler

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici;

const
  ProgramAdi: string = 'Program Yazmaç Görüntüleyici';
  Baslik0: string = 'GRV     eax      ebx      ecx      edx      esi      edi      ebp      esp';
  Baslik1: string = '----  -------- -------- -------- -------- -------- -------- -------- --------';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  TSS0: TTSS;
  UstSinirGorevSayisi, CalisanGorevSayisi,
  i: TSayi4;

begin

  Pencere0.Olustur(-1, 5, 55, 630, 300, ptBoyutlandirilabilir, ProgramAdi, $E6EAED);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      Pencere0.Ciz;
    end
    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Gorev0.GorevSayilariniAl(UstSinirGorevSayisi, CalisanGorevSayisi);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 0, Baslik0);
      Pencere0.Tuval.YaziYaz(0, 1*16, Baslik1);

      for i := 1 to UstSinirGorevSayisi do
      begin

        if(Gorev0.GorevYazmacBilgisiAl(i, @TSS0) >= 0) then
        begin

          Pencere0.Tuval.SayiYaz16(00 * 0, (1 + i) * 16, False, 4, i);
          Pencere0.Tuval.SayiYaz16(06 * 8, (1 + i) * 16, False, 8, TSS0.EAX);
          Pencere0.Tuval.SayiYaz16(15 * 8, (1 + i) * 16, False, 8, TSS0.EBX);
          Pencere0.Tuval.SayiYaz16(24 * 8, (1 + i) * 16, False, 8, TSS0.ECX);
          Pencere0.Tuval.SayiYaz16(33 * 8, (1 + i) * 16, False, 8, TSS0.EDX);
          Pencere0.Tuval.SayiYaz16(42 * 8, (1 + i) * 16, False, 8, TSS0.ESI);
          Pencere0.Tuval.SayiYaz16(51 * 8, (1 + i) * 16, False, 8, TSS0.EDI);
          Pencere0.Tuval.SayiYaz16(60 * 8, (1 + i) * 16, False, 8, TSS0.EBP);
          Pencere0.Tuval.SayiYaz16(69 * 8, (1 + i) * 16, False, 8, TSS0.ESP);
        end;
      end;
    end;

  until (1 = 2);
end.
