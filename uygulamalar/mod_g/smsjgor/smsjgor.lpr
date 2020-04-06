program smsjgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: smsjgor.lpr
  Program Ýþlevi: sistem tarafýndan üretilen mesajlarý görüntüleme programý

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, zamanlayici, sistemmesaj;

const
  ProgramAdi: string = 'Sistem Mesaj Görüntüleyici';

  USTSINIR_MESAJSAYISI = 18;
  FONT_YUKSEKLIGI = 16;
  PENCERE_KULLANILMAYAN_ALAN = 2 + 2 + 18 + 2 + 16;
  PENCERE_YUKSEKLIK = PENCERE_KULLANILMAYAN_ALAN + (USTSINIR_MESAJSAYISI * FONT_YUKSEKLIGI);

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  SistemMesaj0: TSistemMesaj;
  Zamanlayici0: TZamanlayici;
  Mesaj0: TMesaj;
  OlayKayit: TOlayKayit;
  SistemdekiToplamMesaj, ToplamMesaj,
  IlkMesajNo, i, SatirNo: TSayi4;

begin

  Pencere0.Olustur(-1, 100, 20, 600, PENCERE_YUKSEKLIK, ptBoyutlandirilabilir, ProgramAdi,
    $E2E2E2);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  ToplamMesaj := 0;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      SistemdekiToplamMesaj := SistemMesaj0.Toplam;
      if(SistemdekiToplamMesaj <> ToplamMesaj) then ToplamMesaj := SistemdekiToplamMesaj;

      Pencere0.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := $32323E;
      Pencere0.Tuval.YaziYaz(0, 0, 'No   Saat     Mesaj');

      if(ToplamMesaj > 0) then
      begin

        if(ToplamMesaj <=  USTSINIR_MESAJSAYISI) then
          IlkMesajNo := 1
        else
          IlkMesajNo := ToplamMesaj-USTSINIR_MESAJSAYISI+1;

        SatirNo := 1;

        for i := IlkMesajNo to ToplamMesaj do
        begin

          SistemMesaj0.Al(i, @Mesaj0);
          Pencere0.Tuval.SayiYaz16(0, SatirNo * 16, True, 2, Mesaj0.SiraNo);
          Pencere0.Tuval.SaatYaz(5 * 8, SatirNo * 16, Mesaj0.Saat);
          Pencere0.Tuval.YaziYaz(14 * 8, SatirNo * 16, Mesaj0.Mesaj);
          Inc(SatirNo);
        end;
      end;
    end;

  until (1 = 2);
end.
