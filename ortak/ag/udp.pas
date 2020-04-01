{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: udp.pas
  Dosya ��levi: udp protokol y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 15/10/2019

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
procedure UDPPaketGonder(AKaynakAdres, AHedefAdres: TIPAdres; AKaynakPort, AHedefPort: TSayi2;
  AVeri: Isaretci; AVeriUzunlugu: TISayi4);

implementation

uses genel, saglama, ip, donusum, sistemmesaj, dhcp;

{==============================================================================
  udp protokol�ne gelen verileri ilgili kaynaklara y�nlendirir
 ==============================================================================}
procedure UDPPaketleriniIsle(AUDPBaslik: PUDPPaket);
var
  _DNSPacket: PDNSPaket;
  _IPAdres: TIPAdres;
  _KaynakPort, _HedefPort,
  _SorguSayisi, _YanitSayisi, _DigerSayisi: TSayi2;
  _DNSAdres, _NetBIOSAdi: string;
  _DNSBolum: TSayi4;
  _B1: PByte;
  _B1Uzunluk, B1, B2, B3, i: TSayi1;
  _B2: PSayi2;
  _B4: PSayi4;
begin

  {$IFDEF UDP_BILGI}
  SISTEM_MESAJ_YAZI('-------------------------');
  SISTEM_MESAJ_S16('UDP Kaynak Port: ', Takas2(TSayi2(AUDPBaslik^.KaynakPort)), 4);
  SISTEM_MESAJ_S16('UDP Hedef Port: ', Takas2(TSayi2(AUDPBaslik^.HedefPort)), 4);
  SISTEM_MESAJ_S16('UDP Veri Uzunlu�u: ', AUDPBaslik^.Uzunluk, 4);
  SISTEM_MESAJ_S16('UDP Sa�lama Toplam�: ', AUDPBaslik^.SaglamaToplam, 8);
  //SISTEM_MESAJ_YAZI('UDP Veri: ' + s);
  {$ENDIF}

  _KaynakPort := Takas2(TSayi2(AUDPBaslik^.KaynakPort));
  _HedefPort := Takas2(TSayi2(AUDPBaslik^.HedefPort));

  // dns port = 53
  { TODO : bu i�lev dns.pas dosyas�na al�nacak. }
  if(_KaynakPort = 53) then
  begin

    _DNSPacket := @AUDPBaslik^.Veri;

    // sorgu say�s� ve yan�t say�s� kontrol�
    _SorguSayisi := Takas2(_DNSPacket^.SorguSayisi);
    _YanitSayisi := Takas2(_DNSPacket^.YanitSayisi);
    //SISTEM_MESAJ_S16('SorguSayisi: ', TSayi4(_SorguSayisi), 4);
    //SISTEM_MESAJ_S16('YanitSayisi: ', TSayi4(_YanitSayisi), 4);

    if(_SorguSayisi <> 1) then Exit;
    if(_YanitSayisi = 0) then Exit;

    // �rnek dns adres verisi: [6]google[3]com[0]
    // bilgi: [] aras�ndaki veri say�sal byte t�r�nde veridir.

    // dns sorgu adresinin al�nmas�
    _DNSBolum := 0;        // dns adresindeki her bir b�l�m
    _DNSAdres := '';

    _B1 := @_DNSPacket^.Veriler;
    while _B1^ <> 0 do
    begin

      if(_DNSBolum > 0) then _DNSAdres := _DNSAdres + '.';

      _B1Uzunluk := _B1^;     // kayd�n uzunlu�u
      Inc(_B1);
      i := 0;
      while i < _B1Uzunluk do
      begin

        _DNSAdres := _DNSAdres + Char(_B1^);
        Inc(_B1);
        Inc(i);
        Inc(_DNSBolum);
      end;
    end;
    Inc(_B1);

    SISTEM_MESAJ_YAZI('DNS Bilgileri: ');
    SISTEM_MESAJ_YAZI('DNS Ad: ', _DNSAdres);

    _B2 := PSayi2(_B1);
    Inc(_B2);
    Inc(_B2);
    Inc(_B2);

    SISTEM_MESAJ_S16('Tip: ', Takas2(_B2^), 4);
    Inc(_B2);
    SISTEM_MESAJ_S16('S�n�f: ', Takas2(_B2^), 4);
    Inc(_B2);

    _B4 := PSayi4(_B2);
    SISTEM_MESAJ_S16('Ya�am �mr�: ', Takas4(_B4^), 8);
    Inc(_B4);

    _B2 := PSayi2(_B4);
    SISTEM_MESAJ_S16('Veri Uzunlu�u: ', Takas2(_B2^), 4);
    Inc(_B2);

    _B1 := PSayi1(_B2);

    _IPAdres[0] := _B1^;
    Inc(_B1);
    _IPAdres[1] := _B1^;
    Inc(_B1);
    _IPAdres[2] := _B1^;
    Inc(_B1);
    _IPAdres[3] := _B1^;

    SISTEM_MESAJ_IP('IP Adresi: ', _IPAdres);
  end
  else if(_HedefPort = 68) then
  begin

    DHCPPaketleriniIsle(@AUDPBaslik^.Veri);
  end
  else if(_KaynakPort = 137) and (_HedefPort = 137) then
  begin

    _DNSPacket := @AUDPBaslik^.Veri;

    {SISTEM_MESAJ_YAZI('UDP: NetBios');
    SISTEM_MESAJ_S16('-> IslemKimlik: ', Takas2(_DNSPacket^.IslemKimlik), 4);
    SISTEM_MESAJ_S16('-> Bayrak: ', Takas2(_DNSPacket^.Bayrak), 4);
    SISTEM_MESAJ_S16('-> SorguSayisi: ', Takas2(_DNSPacket^.SorguSayisi), 4);
    SISTEM_MESAJ_S16('-> YanitSayisi: ', Takas2(_DNSPacket^.YanitSayisi), 4);
    SISTEM_MESAJ_S16('-> YetkiSayisi: ', Takas2(_DNSPacket^.YetkiSayisi), 4);
    SISTEM_MESAJ_S16('-> DigerSayisi: ', Takas2(_DNSPacket^.DigerSayisi), 4);}

    // sorgu say�s� ve yan�t say�s� kontrol�
    _SorguSayisi := Takas2(_DNSPacket^.SorguSayisi);
    _DigerSayisi := Takas2(_DNSPacket^.DigerSayisi);

    // SADECE 1 adet sorguya sahip ba�l�k de�erlendirilecek
    if(_SorguSayisi <> 1) then Exit;
    if(_DigerSayisi <> 1) then Exit;

    _NetBIOSAdi := '';

    _B1 := @_DNSPacket^.Veriler;
    Inc(_B1);    // uzunlu�u atla
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

    // s�f�r sonland�rmay� atla
    Inc(_B1);

    // type ve class de�erini atla
    _B2 := PSayi2(_B1);
    Inc(_B2);
    Inc(_B2);

    // ek bilgiler - additional record
    Inc(_B2);

    SISTEM_MESAJ_YAZI('NetBios Bilgileri: ');
    SISTEM_MESAJ_YAZI('-> Ad: ', _NetBIOSAdi);

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

    SISTEM_MESAJ_YAZI('UDP: Bilinmeyen istek');
    SISTEM_MESAJ_S16('-> Kaynak Port:', _KaynakPort, 8);
    SISTEM_MESAJ_S16('-> Hedef Port:', _HedefPort, 8);
  end;

  {Sock := Sock^.GetSocket(Takas2(Word(UdpPacket^.DestPort)));
  if(Sock = nil) then
  begin

    SISTEM_MESAJ_YAZI('E�le�en port bulunamad�!');
    Exit;
  end
  else
  begin

    DataLen := Takas2(Word(UdpPacket^.Length));

    SISTEM_MESAJ_S16('UDP Data Len ', DataLen, 4);

    // 8 byte, udp paket ba�l�k uzunlu�u
    if(DataLen > 8) then Sock^.BellegeEkle(@UdpPacket^.Data, DataLen - 8);
  end;}
end;

{==============================================================================
  udp protokol� �zerinden veri g�nderir
 ==============================================================================}
procedure UDPPaketGonder(AKaynakAdres, AHedefAdres: TIPAdres; AKaynakPort, AHedefPort: TSayi2;
  AVeri: Isaretci; AVeriUzunlugu: TISayi4);
var
  _UDPBaslik: PUDPPaket;
  _SozdeBaslik: TSozdeBaslik;
  _SaglamaDeger: TSayi2;
  _B1: PSayi1;
begin

  { TODO mesaj g�ndermeden �nce hedef makinenin mac adresi arp yoluyla al�nacak }

  _UDPBaslik := GGercekBellek.Ayir(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);

  // udp i�in ek ba�l�k hesaplan�yor
  _SozdeBaslik.KaynakIPAdres := AKaynakAdres;
  _SozdeBaslik.HedefIPAdres := AHedefAdres;
  _SozdeBaslik.Sifir := 0;
  _SozdeBaslik.Protokol := PROTOKOL_UDP;
  _SozdeBaslik.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU));

  // udp paketi haz�rlan�yor
  { TODO : kaynak port numaras� almak i�in i�lev yaz�lacak }
  _UDPBaslik^.KaynakPort := Takas2(TSayi2(AKaynakPort));
  _UDPBaslik^.HedefPort := Takas2(TSayi2(AHedefPort));
  _UDPBaslik^.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + UDP_BASLIK_UZUNLUGU));
  _UDPBaslik^.SaglamaToplam := $0000;
  _B1 := @_UDPBaslik^.Veri;
  Tasi2(PSayi1(AVeri), _B1, AVeriUzunlugu);
  _SaglamaDeger := SaglamasiniYap(_UDPBaslik, AVeriUzunlugu + UDP_BASLIK_UZUNLUGU,
    @_SozdeBaslik, UDP_SOZDE_UZUNLUGU);
  _UDPBaslik^.SaglamaToplam := Takas2(TSayi2(_SaglamaDeger));

  IPPaketGonder(MACAdres255, AKaynakAdres, AHedefAdres, ptUDP, 0, _UDPBaslik,
    AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);

  GGercekBellek.YokEt(_UDPBaslik, AVeriUzunlugu + UDP_BASLIK_UZUNLUGU);
end;

end.
