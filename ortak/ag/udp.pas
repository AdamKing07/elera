{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: udp.pas
  Dosya Ýþlevi: udp protokol yönetim iþlevlerini içerir

  Güncelleme Tarihi: 18/04/2020

 ==============================================================================}
{$mode objfpc}
//{$DEFINE UDP_BILGI}
unit udp;

interface

uses paylasim;

const
  UDP_BASLIK_U = 8;
  UDP_SOZDEBASLIK_U  = 12;

procedure UDPPaketleriniIsle(AUDPBaslik: PUDPPaket);
procedure UDPPaketGonder(AMACAdres: TMACAdres; AKaynakAdres, AHedefAdres: TIPAdres;
  AKaynakPort, AHedefPort: TSayi2; AVeri: Isaretci; AVeriUzunlugu: TISayi4);

implementation

uses genel, saglama, ip, donusum, sistemmesaj, dhcp, iletisim, dns;

{==============================================================================
  udp protokolüne gelen verileri ilgili kaynaklara yönlendirir
 ==============================================================================}
procedure UDPPaketleriniIsle(AUDPBaslik: PUDPPaket);
var
  DNSPacket: PDNSPaket;
  IPAdres: TIPAdres;
  Baglanti: PBaglanti;
  KaynakPort, HedefPort,
  SorguSayisi, DigerSayisi: TSayi2;
  NetBIOSAdi: string;
  _B1: PByte;
  B1, B2, B3: TSayi1;
  _B2: PSayi2;
  _B4: PSayi4;
begin

  {$IFDEF UDP_BILGI}
  SISTEM_MESAJ('-------------------------', []);
  SISTEM_MESAJ('UDP Kaynak Port: %d', [Takas2(AUDPBaslik^.KaynakPort)]);
  SISTEM_MESAJ('UDP Hedef Port: %d', [Takas2(AUDPBaslik^.HedefPort)]);
  SISTEM_MESAJ('UDP Veri Uzunluðu: %d', [Takas2(AUDPBaslik^.Uzunluk)]);
  SISTEM_MESAJ('UDP Saðlama Toplamý: %x', [AUDPBaslik^.SaglamaToplam]);
  //SISTEM_MESAJ('UDP Veri: ' + s, []);
  {$ENDIF}

  KaynakPort := Takas2(AUDPBaslik^.KaynakPort);
  HedefPort := Takas2(AUDPBaslik^.HedefPort);

  // dns port = 53
  if(KaynakPort = 53) then
  begin

    DNSPaketleriniIsle(AUDPBaslik);
  end
  else if(HedefPort = 68) then
  begin

    DHCPPaketleriniIsle(@AUDPBaslik^.Veri);
  end
  else if(KaynakPort = 137) and (HedefPort = 137) then
  begin

    DNSPacket := @AUDPBaslik^.Veri;

    {SISTEM_MESAJ('UDP: NetBios', []);
    SISTEM_MESAJ_S16('-> IslemKimlik: ', Takas2(DNSPacket^.Tanimlayici), 4);
    SISTEM_MESAJ_S16('-> Bayrak: ', Takas2(DNSPacket^.Bayrak), 4);
    SISTEM_MESAJ_S16('-> SorguSayisi: ', Takas2(DNSPacket^.SorguSayisi), 4);
    SISTEM_MESAJ_S16('-> YanitSayisi: ', Takas2(DNSPacket^.YanitSayisi), 4);
    SISTEM_MESAJ_S16('-> YetkiSayisi: ', Takas2(DNSPacket^.YetkiSayisi), 4);
    SISTEM_MESAJ_S16('-> DigerSayisi: ', Takas2(DNSPacket^.DigerSayisi), 4);}

    // sorgu sayýsý ve yanýt sayýsý kontrolü
    SorguSayisi := Takas2(DNSPacket^.SorguSayisi);
    DigerSayisi := Takas2(DNSPacket^.DigerSayisi);

    // SADECE 1 adet sorguya sahip baþlýk deðerlendirilecek
    if(SorguSayisi <> 1) then Exit;
    if(DigerSayisi <> 1) then Exit;

    NetBIOSAdi := '';

    _B1 := @DNSPacket^.Veriler;
    Inc(_B1);    // uzunluðu atla
    while _B1^ <> 0 do
    begin

      B1 := _B1^;
      Inc(_B1);
      B2 := _B1^;
      Inc(_B1);

      B3 := (B1 - Ord('A')) shl 4;
      B3 := (B2 - Ord('A')) or B3;

      NetBIOSAdi := NetBIOSAdi + Char(B3);
    end;

    // sýfýr sonlandýrmayý atla
    Inc(_B1);

    // type ve class deðerini atla
    _B2 := PSayi2(_B1);
    Inc(_B2);
    Inc(_B2);

    // ek bilgiler - additional record
    Inc(_B2);

    SISTEM_MESAJ('NetBios Bilgileri: ', []);
    SISTEM_MESAJ_YAZI('-> Ad: ', NetBIOSAdi);

    SISTEM_MESAJ_S16('-> Tip: ', Takas2(_B2^), 4);
    Inc(_B2);
    SISTEM_MESAJ_S16('-> Sýnýf: ', Takas2(_B2^), 4);
    Inc(_B2);

    _B4 := PSayi4(_B2);
    SISTEM_MESAJ_S16('-> TTL: ', Takas4(_B4^), 8);
    Inc(_B4);

    _B2 := PSayi2(_B4);
    SISTEM_MESAJ_S16('-> Veri Uzunluðu: ', Takas2(_B2^), 4);
    Inc(_B2);

    // isim bayraðý - name flags
    Inc(_B2);

    _B1 := PSayi1(_B2);

    // ip adresi
    IPAdres[0] := _B1^;
    Inc(_B1);
    IPAdres[1] := _B1^;
    Inc(_B1);
    IPAdres[2] := _B1^;
    Inc(_B1);
    IPAdres[3] := _B1^;

    SISTEM_MESAJ_IP('-> IP Adresi: ', IPAdres);
  end
  else
  begin

    {SISTEM_MESAJ('UDP: Bilinmeyen istek', []);
    SISTEM_MESAJ('  -> Kaynak Port: %d', [KaynakPort]);
    SISTEM_MESAJ('  -> Hedef Port: %d', [HedefPort]);}

    Baglanti := Baglanti^.UDPBaglantiAl(HedefPort);
    if(Baglanti = nil) then
    begin

      SISTEM_MESAJ('Eþleþen UDP port bulunamadý: %d', [HedefPort]);
      Exit;
    end
    else
    begin

      B2 := Takas2(AUDPBaslik^.Uzunluk);

      //SISTEM_MESAJ('UDP Veri Uzunluðu: %d', [B2]);

      // 8 byte, udp paket baþlýk uzunluðu
      if(B2 > 8) then Baglanti^.BellegeEkle(@AUDPBaslik^.Veri, B2 - 8);
    end;
  end;
end;

{==============================================================================
  udp protokolü üzerinden veri gönderir
 ==============================================================================}
procedure UDPPaketGonder(AMACAdres: TMACAdres; AKaynakAdres, AHedefAdres: TIPAdres;
  AKaynakPort, AHedefPort: TSayi2; AVeri: Isaretci; AVeriUzunlugu: TISayi4);
var
  UDPBaslik: PUDPPaket;
  SozdeBaslik: TSozdeBaslik;
  SaglamaDeger: TSayi2;
  B1: PSayi1;
begin

  UDPBaslik := GGercekBellek.Ayir(AVeriUzunlugu + UDP_BASLIK_U);

  // udp için ek baþlýk hesaplanýyor
  SozdeBaslik.KaynakIPAdres := AKaynakAdres;
  SozdeBaslik.HedefIPAdres := AHedefAdres;
  SozdeBaslik.Sifir := 0;
  SozdeBaslik.Protokol := PROTOKOL_UDP;
  SozdeBaslik.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_U));

  // udp paketi hazýrlanýyor
  UDPBaslik^.KaynakPort := Takas2(TSayi2(AKaynakPort));
  UDPBaslik^.HedefPort := Takas2(TSayi2(AHedefPort));
  UDPBaslik^.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_U));
  UDPBaslik^.SaglamaToplam := $0000;
  B1 := @UDPBaslik^.Veri;
  Tasi2(PSayi1(AVeri), B1, AVeriUzunlugu);
  SaglamaDeger := SaglamasiniYap(UDPBaslik, AVeriUzunlugu + UDP_BASLIK_U,
    @SozdeBaslik, UDP_SOZDEBASLIK_U);
  UDPBaslik^.SaglamaToplam := Takas2(TSayi2(SaglamaDeger));

  IPPaketGonder(AMACAdres, AKaynakAdres, AHedefAdres, ptUDP, 0, UDPBaslik,
    AVeriUzunlugu + UDP_BASLIK_U);

  GGercekBellek.YokEt(UDPBaslik, AVeriUzunlugu + UDP_BASLIK_U);
end;

end.
