program dnssorgu;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: dnssorgu.lpr
  Program ��levi: dns adres sorgulama program�

  G�ncelleme Tarihi: 19/04/2020

 ==============================================================================}
{$mode objfpc}

uses gorev, gn_pencere, gn_etiket, gn_giriskutusu, gn_dugme, gn_defter, n_dns,
  zamanlayici, gn_durumcubugu;

const
  ProgramAdi: string = 'DNS Sorgu';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  etDNSAdi: TEtiket;
  gkDNSAdi: TGirisKutusu;
  dugSorgula: TDugme;
  defSonuc: TDefter;
  DurumCubugu0: TDurumCubugu;
  Zamanlayici0: TZamanlayici;
  OlayKayit: TOlayKayit;
  DNS: TDNS;
  DNSAdresSorgu, DNSAdresYanit: string;
  DNSDurum: TDNSDurum;
  DNSKimlik: TKimlik;
  _DNSPaket: PDNSPaket;
  _VeriBellek: array[0..1023] of TSayi1;
  _SorguSayisi, _YanitSayisi: TSayi2;
  _DNSBolum: TSayi4;
  _B1: PByte;
  _B1Uzunluk, i: TSayi1;
  _B2: PSayi2;
  _B4: PSayi4;
  _IPAdres: TIPAdres;

procedure Sorgula;
begin

  DNSAdresSorgu := gkDNSAdi.IcerikAl;

  defSonuc.Temizle;
  gkDNSAdi.IcerikYaz('');

  if(DNSKimlik = -1) then DNS.Olustur;

  DNSKimlik := DNS.Kimlik;

  if not(DNSKimlik = -1) then
  begin

    if(Length(DNSAdresSorgu) = 0) then
    begin

      defSonuc.Temizle;
      defSonuc.YaziEkle('Hata: DNS adres alan� bo�...')
    end
    else
    begin

      defSonuc.Temizle;
      defSonuc.YaziEkle('Sorgulanan Adres: ' + DNSAdresSorgu + #13#10#13#10);

      DurumCubugu0.DurumYazisiDegistir('Adres sorgulan�yor...');
      DNS.Sorgula(DNSAdresSorgu);
    end;
  end;
end;

begin

  DNSAdresSorgu := 'lazarus-ide.org';

  DNSKimlik := -1;

  Pencere0.Olustur(-1, 100, 100, 370, 280, ptIletisim, ProgramAdi, RENK_BEYAZ);

  DurumCubugu0.Olustur(Pencere0.Kimlik, 0, 0, 100, 18, 'Beklemede.');
  DurumCubugu0.Goster;

  etDNSAdi.Olustur(Pencere0.Kimlik, 10, 10, RENK_SIYAH, 'DNS Adres:');
  etDNSAdi.Goster;

  gkDNSAdi.Olustur(Pencere0.Kimlik, 96, 5, 186, 22, DNSAdresSorgu);
  gkDNSAdi.Goster;

  dugSorgula.Olustur(Pencere0.Kimlik, 286, 6, 62, 22, 'Sorgula');
  dugSorgula.Goster;

  defSonuc.Olustur(Pencere0.Kimlik, 10, 32, 340, 194, $369090, RENK_BEYAZ);
  defSonuc.Goster;

  Pencere0.Goster;

  Zamanlayici0.Olustur(100);
  Zamanlayici0.Baslat;

  repeat

    Gorev0.OlayBekle(OlayKayit);

    if(OlayKayit.Olay = CO_ZAMANLAYICI) then
    begin

      if not(DNS.Kimlik = -1) then
      begin

        DNSDurum := DNS.DurumAl;
        if(DNSDurum = ddSorgulandi) then
        begin

          DNS.IcerikAl(@_VeriBellek[0]);

          // ilk 4 byte dns yan�t verisinin uzunlu�unu i�erir
          _DNSPaket := PDNSPaket(@_VeriBellek[4]);

          // sorgu say�s� ve yan�t say�s� kontrol�
          _SorguSayisi := Takas2(_DNSPaket^.SorguSayisi);
          _YanitSayisi := Takas2(_DNSPaket^.YanitSayisi);
          //SISTEM_MESAJ_S16('SorguSayisi: ', TSayi4(_SorguSayisi), 4);
          //SISTEM_MESAJ_S16('YanitSayisi: ', TSayi4(_YanitSayisi), 4);

          // tek bir sorgudan farkl� veya yan�t�n olmamas� durumunda ��k�� yap
          if(_SorguSayisi <> 1) or (_YanitSayisi = 0) then
          begin

            DNS.Kapat;

            defSonuc.YaziEkle('Hata: adres ��z�mlenemiyor!');

            DurumCubugu0.DurumYazisiDegistir('Beklemede.');

            Exit;
          end;

          // �rnek dns adres verisi: [6]google[3]com[0]
          // bilgi: [] aras�ndaki veri say�sal byte t�r�nde veridir.

          // dns sorgu adresinin al�nmas�
          _DNSBolum := 0;        // dns adresindeki her bir b�l�m
          DNSAdresYanit := '';

          _B1 := @_DNSPaket^.Veriler;
          while _B1^ <> 0 do
          begin

            if(_DNSBolum > 0) then DNSAdresYanit := DNSAdresYanit + '.';

            _B1Uzunluk := _B1^;     // kayd�n uzunlu�u
            Inc(_B1);
            i := 0;
            while i < _B1Uzunluk do
            begin

              DNSAdresYanit := DNSAdresYanit + Char(_B1^);
              Inc(_B1);
              Inc(i);
              Inc(_DNSBolum);
            end;
          end;
          Inc(_B1);

          defSonuc.YaziEkle('Yan�t Bilgileri:' + #13#10);
          defSonuc.YaziEkle('DNS Ad�: ' + DNSAdresYanit + #13#10);

          _B2 := PSayi2(_B1);
          Inc(_B2);
          Inc(_B2);
          Inc(_B2);

          defSonuc.YaziEkle('Tip: ' + IntToStr(Takas2(_B2^)) + #13#10);
          Inc(_B2);
          defSonuc.YaziEkle('S�n�f: ' + IntToStr(Takas2(_B2^)) + #13#10);
          Inc(_B2);

          _B4 := PSayi4(_B2);
          defSonuc.YaziEkle('Ya�am �mr�: ' + IntToStr(Takas4(_B4^)) + #13#10);
          Inc(_B4);

          _B2 := PSayi2(_B4);
          //SISTEM_MESAJ_S16('Veri Uzunlu�u: ', Takas2(_B2^), 4);
          Inc(_B2);

          _B1 := PSayi1(_B2);

          _IPAdres[0] := _B1^;
          Inc(_B1);
          _IPAdres[1] := _B1^;
          Inc(_B1);
          _IPAdres[2] := _B1^;
          Inc(_B1);
          _IPAdres[3] := _B1^;

          defSonuc.YaziEkle('IP Adresi: ' + IPToStr(_IPAdres));

          DurumCubugu0.DurumYazisiDegistir('Beklemede.');

          DNS.Kapat;
        end;
      end;
    end
    else if(OlayKayit.Olay = CO_TUSBASILDI) then
    begin

      if(OlayKayit.Deger1 = 10) then Sorgula;
    end
    else if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = dugSorgula.Kimlik) then Sorgula;
    end;
  until (1 = 2);

  // program kapan�rken bu i�lev �al��t�r�lacak
  DNS.YokEt;
end.
