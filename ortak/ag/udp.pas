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
  UDP_BASLIK_UZUNLUGU = 8;
  UDP_SOZDE_UZUNLUGU  = 12;

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
  _DNSPacket: PDNSPaket;
  _IPAdres: TIPAdres;
  _Baglanti: PBaglanti;
  _KaynakPort, _HedefPort,
  _SorguSayisi, _DigerSayisi: TSayi2;
  _NetBIOSAdi: string;
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

  _KaynakPort := Takas2(AUDPBaslik^.KaynakPort);
  _HedefPort := Takas2(AUDPBaslik^.HedefPort);

  // dns port = 53
  if(_KaynakPort = 53) then
  begin

    DNSPaketleriniIsle(AUDPBaslik);
  end
  else if(_HedefPort = 68) then
  begin

    DHCPPaketleriniIsle(@AUDPBaslik^.Veri);
  end
  else if(_KaynakPort = 137) and (_HedefPort = 137) then
  begin

    _DNSPacket := @AUDPBaslik^.Veri;

    {SISTEM_MESAJ('UDP: NetBios', []);
    SISTEM_MESAJ_S16('-> IslemKimlik: ', Takas2(_DNSPacket^.Tanimlayici), 4);
    SISTEM_MESAJ_S16('-> Bayrak: ', Takas2(_DNSPacket^.Bayrak), 4);
    SISTEM_MESAJ_S16('-> SorguSayisi: ', Takas2(_DNSPacket^.SorguSayisi), 4);
    SISTEM_MESAJ_S16('-> YanitSayisi: ', Takas2(_DNSPacket^.YanitSayisi), 4);
    SISTEM_MESAJ_S16('-> YetkiSayisi: ', Takas2(_DNSPacket^.YetkiSayisi), 4);
    SISTEM_MESAJ_S16('-> DigerSayisi: ', Takas2(_DNSPacket^.DigerSayisi), 4);}

    // sorgu sayýsý ve yanýt sayýsý kontrolü
    _SorguSayisi := Takas2(_DNSPacket^.SorguSayisi);
    _DigerSayisi := Takas2(_DNSPacket^.DigerSayisi);

    // SADECE 1 adet sorguya sahip baþlýk deðerlendirilecek
    if(_SorguSayisi <> 1) then Exit;
    if(_DigerSayisi <> 1) then Exit;

    _NetBIOSAdi := '';

    _B1 := @_DNSPacket^.Veriler;
    Inc(_B1);    // uzunluðu atla
    while _B1^ <> 0 do
    begin

      B1 := _B1^;
      Inc(_B1);
      B2 := _B1^;
      Inc(_B1);

      B3 := (B1 - Ord('A')) shl 4;
      B3 := (B2 - Ord('A')) or B3;

      _NetBIOSAdi := _NetBIOSAdi + Char(B3);
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
    SISTEM_MESAJ_YAZI('-> Ad: ', _NetBIOSAdi);

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
    _IPAdres[0] := _B1^;
    Inc(_B1);
    _IPAdres[1] := _B1^;
    Inc(_B1);
    _IPAdres[2] := _B1^;
    Inc(_B1);
    _IPAdres[3] := _B1^;

    SISTEM_MESAJ_IP('-> IP Adresi: ', _IPAdres);
  end
  else
  begin

    {SISTEM_MESAJ('UDP: Bilinmeyen istek', []);
    SISTEM_MESAJ('  -> Kaynak Port: %d', [_KaynakPort]);
    SISTEM_MESAJ('  -> Hedef Port: %d', [_HedefPort]);}

    _Baglanti := _Baglanti^.UDPBaglantiAl(_HedefPort);
    if(_Baglanti = nil) then
    begin

      SISTEM_MESAJ('Eþleþen UDP port bulunamadý: %d', [_HedefPort]);
      Exit;
    end
    else
    begin

      B2 := Takas2(AUDPBaslik^.Uzunluk);

      //SISTEM_MESAJ('UDP Veri Uzunluðu: %d', [B2]);

      // 8 byte, udp paket baþlýk uzunluðu
      if(B2 > 8) then _Baglanti^.BellegeEkle(@AUDPBaslik^.Veri, B2 - 8);
    end;
  end;
end;

{==============================================================================
  udp protokolü üzerinden veri gönderir
 ==============================================================================}
procedure UDPPaketGonder(AMACAdres: TMACAdres; AKaynakAdres, AHedefAdres: TIPAdres;
  AKaynakPort, AHedefPort: TSayi2; AVeri: Isaretci; AVeriUzunlugu: TISayi4);
var
  _UDPBaslik: PUDPPaket;
  _SozdeBaslik: TSozdeBaslik;
  _SaglamaDeger: TSayi2;
  _B1: PSayi1;
begin

  _UDPBaslik := GGercekBellek.Ayir(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);

  // udp için ek baþlýk hesaplanýyor
  _SozdeBaslik.KaynakIPAdres := AKaynakAdres;
  _SozdeBaslik.HedefIPAdres := AHedefAdres;
  _SozdeBaslik.Sifir := 0;
  _SozdeBaslik.Protokol := PROTOKOL_UDP;
  _SozdeBaslik.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU));

  // udp paketi hazýrlanýyor
  _UDPBaslik^.KaynakPort := Takas2(TSayi2(AKaynakPort));
  _UDPBaslik^.HedefPort := Takas2(TSayi2(AHedefPort));
  _UDPBaslik^.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU));
  _UDPBaslik^.SaglamaToplam := $0000;
  _B1 := @_UDPBaslik^.Veri;
  Tasi2(PSayi1(AVeri), _B1, AVeriUzunlugu);
  _SaglamaDeger := SaglamasiniYap(_UDPBaslik, AVeriUzunlugu + UDP_BASLIK_UZUNLUGU,
    @_SozdeBaslik, UDP_SOZDE_UZUNLUGU);
  _UDPBaslik^.SaglamaToplam := Takas2(TSayi2(_SaglamaDeger));

  IPPaketGonder(AMACAdres, AKaynakAdres, AHedefAdres, ptUDP, 0, _UDPBaslik,
    AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);

  GGercekBellek.YokEt(_UDPBaslik, AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);
end;

end.
