program smsjgor;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: smsjgor.lpr
  Program Ýþlevi: sistem tarafýndan üretilen mesajlarý görüntüleme programý

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
uses n_gorev, gn_pencere, n_zamanlayici, n_sistemmesaj;

const
  ProgramAdi: string = 'Sistem Mesaj Görüntüleyici';

  USTSINIR_MESAJSAYISI = 18;
  FONT_YUKSEKLIGI = 16;
  PENCERE_KULLANILMAYAN_ALAN = 2 + 2 + 18 + 2 + 16;
  PENCERE_YUKSEKLIK = PENCERE_KULLANILMAYAN_ALAN + (USTSINIR_MESAJSAYISI * FONT_YUKSEKLIGI);

var
  Gorev: TGorev;
  Pencere: TPencere;
  SistemMesaj: TSistemMesaj;
  Zamanlayici: TZamanlayici;
  Mesaj: TMesaj;
  OlayKayit: TOlayKayit;
  SistemdekiToplamMesaj, ToplamMesaj,
  IlkMesajNo, i, SatirNo: TSayi4;

begin

  Pencere.Olustur(-1, 100, 20, 600, PENCERE_YUKSEKLIK, ptBoyutlanabilir,
    ProgramAdi, $E2E2E2);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  Pencere.Goster;

  Zamanlayici.Olustur(100);
  Zamanlayici.Baslat;

  ToplamMesaj := 0;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      SistemdekiToplamMesaj := SistemMesaj.Toplam;
      if(SistemdekiToplamMesaj <> ToplamMesaj) then ToplamMesaj := SistemdekiToplamMesaj;

      Pencere.Ciz;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere.Tuval.KalemRengi := $32323E;
      Pencere.Tuval.YaziYaz(0, 0, 'No   Saat     Mesaj');

      if(ToplamMesaj > 0) then
      begin

        if(ToplamMesaj <=  USTSINIR_MESAJSAYISI) then
          IlkMesajNo := 1
        else
          IlkMesajNo := ToplamMesaj-USTSINIR_MESAJSAYISI+1;

        SatirNo := 1;

        for i := IlkMesajNo to ToplamMesaj do
        begin

          SistemMesaj.Al(i, @Mesaj);
          Pencere.Tuval.SayiYaz16(0, SatirNo * 16, True, 2, Mesaj.SiraNo);
          Pencere.Tuval.SaatYaz(5 * 8, SatirNo * 16, Mesaj.Saat);
          Pencere.Tuval.YaziYaz(14 * 8, SatirNo * 16, Mesaj.Mesaj);
          Inc(SatirNo);
        end;
      end;
    end;
  end;
end.
