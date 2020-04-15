{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: ip.pas
  Dosya İşlevi: ip paket yönetim işlevlerini içerir

  Güncelleme Tarihi: 30/03/2020

 ==============================================================================}
{$mode objfpc}
unit ip;

interface

uses paylasim, genel, saglama, ag, sistemmesaj;

const
  IP_BASLIKU = 20;

procedure IPPaketleriniIsle(AIPPaket: PIPPaket; AIPPaketUzunluk: TISayi4);
procedure IPPaketGonder(AHedefMACAdres: TMACAdres; AKaynakAdres, AHedefAdres: TIPAdres;
  AProtokolTip: TProtokolTip; ABayrakVeParcaSiraNo: TSayi2; AVeri: Isaretci;
  AVeriUzunlugu: TSayi2);

implementation

uses donusum, icmp, udp, tcp, iletisim;

var
  GIPTanimlayici: TSayi2 = $BABA;

// sisteme gelen tüm ip paketlerini işler
procedure IPPaketleriniIsle(AIPPaket: PIPPaket; AIPPaketUzunluk: TISayi4);
begin

  // sadece aygıta gelen ve yayın olarak gelen ip adreslerini işle
  if((IPKarsilastir(AIPPaket^.HedefIP, AgBilgisi.IP4Adres)) or
    (IPKarsilastir2(AIPPaket^.HedefIP, AgBilgisi.IP4Adres)) or
    (IPKarsilastir(AIPPaket^.HedefIP, IPAdres255))) then
  begin

    // icmp protokolü
    if(AIPPaket^.Protokol = PROTOKOL_ICMP) then

      ICMPPaketleriniIsle(@AIPPaket^.Veri, AIPPaketUzunluk - IP_BASLIKU, AIPPaket^.KaynakIP)

    // tcp protokolü
    else if(AIPPaket^.Protokol = PROTOKOL_TCP) then

      TCPPaketleriniIsle(AIPPaket)

    // udp protokolü
    else if(AIPPaket^.Protokol = PROTOKOL_UDP) then

      UDPPaketleriniIsle(PUDPPaket(@AIPPaket^.Veri));
  end
  else
  begin

    SISTEM_MESAJ('IP.PAS: bilinmeyen IP paketi:', []);
    SISTEM_MESAJ_IP('  -> Hedef IP adresi: ', AIPPaket^.HedefIP);
    SISTEM_MESAJ('  -> Hedef protokol: %d', [AIPPaket^.Protokol]);
  end;
end;

// ip protokolü üzerinden paket gönderim işlevlerini gerçekleştirir
procedure IPPaketGonder(AHedefMACAdres: TMACAdres; AKaynakAdres, AHedefAdres: TIPAdres;
  AProtokolTip: TProtokolTip; ABayrakVeParcaSiraNo: TSayi2; AVeri: Isaretci;
  AVeriUzunlugu: TSayi2);
var
  _IPPaket: PIPPaket;
  _Veri: PByte;
  SaglamaToplam: TSayi2;
begin

  // paket için bellek bölgesi oluştur
  _IPPaket := GGercekBellek.Ayir(AVeriUzunlugu + IP_BASLIKU);

  // ip paketi hazırlanıyor
  _IPPaket^.SurumVeBaslikUzunlugu := $45;     // 4 = ip4; 5 * 4 = ip başlık uzunluğu
  _IPPaket^.ServisTipi := $00;
  _IPPaket^.ToplamUzunluk := Takas2(AVeriUzunlugu + IP_BASLIKU);
  _IPPaket^.Tanimlayici := Takas2(GIPTanimlayici);
  // BayrakVeParcaSiraNo: $4000 = tcp / http, $0000 = dns
  _IPPaket^.BayrakVeParcaSiraNo := Takas2(ABayrakVeParcaSiraNo);
  _IPPaket^.YasamSuresi := $80;
  case AProtokolTip of
    ptICMP: _IPPaket^.Protokol := PROTOKOL_ICMP;
    ptTCP : _IPPaket^.Protokol := PROTOKOL_TCP;
    ptUDP : _IPPaket^.Protokol := PROTOKOL_UDP;
  end;
  _IPPaket^.KaynakIP := AKaynakAdres;
  _IPPaket^.HedefIP := AHedefAdres;

  // sağlama öncesi BaslikSaglamaToplami değeri sıfırlanıyor
  _IPPaket^.BaslikSaglamaToplami := $0000;
  SaglamaToplam := SaglamasiniYap(_IPPaket, IP_BASLIKU, nil, 0);
  _IPPaket^.BaslikSaglamaToplami := Takas2(SaglamaToplam);

  Inc(GIPTanimlayici);

  _Veri := @_IPPaket^.Veri;
  Tasi2(AVeri, _Veri, AVeriUzunlugu);

  // paketi donanıma (ethernet) gönder
  AgKartinaVeriGonder(AHedefMACAdres, ptIP, _IPPaket, AVeriUzunlugu + IP_BASLIKU);

  GGercekBellek.YokEt(_IPPaket, AVeriUzunlugu + IP_BASLIKU);
end;

end.
