{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: udp.pas
  Dosya ��levi: udp protokol y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 18/04/2020

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
  udp protokol�ne gelen verileri ilgili kaynaklara y�nlendirir
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
  SISTEM_MESAJ('UDP Veri Uzunlu�u: %d', [Takas2(AUDPBaslik^.Uzunluk)]);
  SISTEM_MESAJ('UDP Sa�lama Toplam�: %x', [AUDPBaslik^.SaglamaToplam]);
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

    // sorgu say�s� ve yan�t say�s� kontrol�
    SorguSayisi := Takas2(DNSPacket^.SorguSayisi);
    DigerSayisi := Takas2(DNSPacket^.DigerSayisi);

    // SADECE 1 adet sorguya sahip ba�l�k de�erlendirilecek
    if(SorguSayisi <> 1) then Exit;
    if(DigerSayisi <> 1) then Exit;

    NetBIOSAdi := '';

    _B1 := @DNSPacket^.Veriler;
    Inc(_B1);    // uzunlu�u atla
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

    // s�f�r sonland�rmay� atla
    Inc(_B1);

    // type ve class de�erini atla
    _B2 := PSayi2(_B1);
    Inc(_B2);
    Inc(_B2);

    // ek bilgiler - additional record
    Inc(_B2);

    SISTEM_MESAJ('NetBios Bilgileri: ', []);
    SISTEM_MESAJ_YAZI('-> Ad: ', NetBIOSAdi);

    SISTEM_MESAJ_S16('-> Tip: ', Takas2(_B2^), 4);
    Inc(_B2);
    SISTEM_MESAJ_S16('-> S�n�f: ', Takas2(_B2^), 4);
    Inc(_B2);

    _B4 := PSayi4(_B2);
    SISTEM_MESAJ_S16('-> TTL: ', Takas4(_B4^), 8);
    Inc(_B4);

    _B2 := PSayi2(_B4);
    SISTEM_MESAJ_S16('-> Veri Uzunlu�u: ', Takas2(_B2^), 4);
    Inc(_B2);

    // isim bayra�� - name flags
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

      SISTEM_MESAJ('E�le�en UDP port bulunamad�: %d', [HedefPort]);
      Exit;
    end
    else
    begin

      B2 := Takas2(AUDPBaslik^.Uzunluk);

      //SISTEM_MESAJ('UDP Veri Uzunlu�u: %d', [B2]);

      // 8 byte, udp paket ba�l�k uzunlu�u
      if(B2 > 8) then Baglanti^.BellegeEkle(@AUDPBaslik^.Veri, B2 - 8);
    end;
  end;
end;

{==============================================================================
  udp protokol� �zerinden veri g�nderir
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

  // udp i�in ek ba�l�k hesaplan�yor
  SozdeBaslik.KaynakIPAdres := AKaynakAdres;
  SozdeBaslik.HedefIPAdres := AHedefAdres;
  SozdeBaslik.Sifir := 0;
  SozdeBaslik.Protokol := PROTOKOL_UDP;
  SozdeBaslik.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_U));

  // udp paketi haz�rlan�yor
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
