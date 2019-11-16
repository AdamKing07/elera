{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: tcp.pas
  Dosya Ýþlevi: tcp katmaný veri iletiþimini gerçekleþtirir

  Güncelleme Tarihi: 17/10/2019

 ==============================================================================}
{$mode objfpc}
//{$DEFINE TCP_BILGI}
unit tcp;

interface

uses paylasim, baglanti;

procedure TCPPaketleriniIsle(ATCPBaslik: PTCPBaslik);
procedure TCPPaketGonder(ABaslikEkle: Boolean; AKaynakIPAdres: TIPAdres;
  ABaglanti: PBaglanti; AVeriBellekAdresi: Isaretci; AVeriUzunlugu: TISayi4;
  ADiziNo, AOnayNo: TSayi4; ABayrak: TSayi1; APencere: TSayi2);

implementation

uses genel, donusum, saglama, ip, sistemmesaj;

procedure TCPPaketleriniIsle(ATCPBaslik: PTCPBaslik);
var
  _Baglanti: PBaglanti;
  _KaynakPort, _HedefPort: TSayi2;
  _DiziNo, _OnayNo: TSayi4;
begin

  {$IFDEF TCP_BILGI}
  SISTEM_MESAJ_YAZI('-------------------------');
  SISTEM_MESAJ_S10('TCP: Kaynak Port: ', Takas2(TSayi2(ATCPBaslik^.KaynakPort)));
  SISTEM_MESAJ_S10('TCP: Hedef Port: ', Takas2(TSayi2(ATCPBaslik^.HedefPort)));
  SISTEM_MESAJ_S10('TCP: Bayrak: ', ATCPBaslik^.Bayrak);
  {$ENDIF}

  _KaynakPort := Takas2(ATCPBaslik^.KaynakPort);
  if(_KaynakPort = 1871) then
  begin

    _HedefPort := Takas2(ATCPBaslik^.HedefPort);
    _Baglanti := _Baglanti^.BaglantiAl(_HedefPort);
    if(_Baglanti = nil) then
    begin

      SISTEM_MESAJ_S10('TCP: Eþleþen port bulunamadý: ', _HedefPort);
      Exit;
    end
    else
    begin

      if(_Baglanti^.FBaglantiDurum = bdBaglaniyor) then
      begin

        if(ATCPBaslik^.Bayrak = (TCP_BAYRAK_ARZ or TCP_BAYRAK_KABUL)) then
        begin

          // gelen deðerin ACK deðeri benim SEQ,
          // gelen deðerin SEQ deðeri benim ACK deðerimdir
          _DiziNo := Takas4(ATCPBaslik^.OnayNo);
          _Baglanti^.FDiziNo := _DiziNo;

          _OnayNo := Takas4(ATCPBaslik^.DiziNo);
          Inc(_OnayNo);
          _Baglanti^.FOnayNo := _OnayNo;

          TCPPaketGonder(False, AgBilgisi.IP4Adres, @_Baglanti, nil, 0, _DiziNo,
            _OnayNo, TCP_BAYRAK_KABUL, _Baglanti^.FPencere);

          _Baglanti^.FBaglantiDurum := bdBaglandi;
        end;
      end
      else if(_Baglanti^.FBaglantiDurum = bdBaglandi) then
      begin

        // gönderilen veriden sonra sunucudan gelen PSH + ACK'e verilen cevap
        if((ATCPBaslik^.Bayrak and (TCP_BAYRAK_GONDER or TCP_BAYRAK_KABUL)) = (TCP_BAYRAK_GONDER or TCP_BAYRAK_KABUL)) then
        begin

          _DiziNo := Takas4(ATCPBaslik^.OnayNo);
          _Baglanti^.FDiziNo := _DiziNo;

          _OnayNo := Takas4(ATCPBaslik^.DiziNo);
          Inc(_OnayNo);
          _Baglanti^.FOnayNo := _OnayNo;

          TCPPaketGonder(False, AgBilgisi.IP4Adres, @_Baglanti, nil, 0, _DiziNo,
            _OnayNo, TCP_BAYRAK_KABUL, _Baglanti^.FPencere);

          //_Baglanti^.FBaglantiDurum := bdBaglandi;
        end
        else if(_Baglanti^.FBaglantiDurum = bdKapaniyor) then
        begin

          if((ATCPBaslik^.Bayrak and TCP_BAYRAK_KABUL) = TCP_BAYRAK_KABUL) then
          begin

            _DiziNo := Takas4(ATCPBaslik^.OnayNo);
            _Baglanti^.FDiziNo := _DiziNo;

            _OnayNo := Takas4(ATCPBaslik^.DiziNo);
            //Inc(_DiziNo);
            _Baglanti^.FOnayNo := _OnayNo;

            TCPPaketGonder(False, AgBilgisi.IP4Adres, @_Baglanti, nil, 0, _DiziNo,
              _OnayNo, TCP_BAYRAK_SON or TCP_BAYRAK_KABUL, _Baglanti^.FPencere);

            _Baglanti^.FProtokol := ptBilinmiyor;
            _Baglanti^.FHedefIPAdres := IPAdres0;
            _Baglanti^.FKaynakPort := 0;
            _Baglanti^.FHedefPort := 0;

            GGercekBellek.YokEt(_Baglanti^.FBellek, _Baglanti^.FBellekUzunlugu);
            _Baglanti^.FBagli := False;
            _Baglanti^.FBaglantiDurum := bdYok;
          end;
        end
        else
        begin

          {SetLength(s, 50);
          s := 'Flag: ';

          if((ATCPBaslik^.Bayrak and TCP_BAYRAK_KABUL) = TCP_BAYRAK_KABUL) then s := s + 'ACK';
          if((ATCPBaslik^.Bayrak and TCP_BAYRAK_SON) = TCP_BAYRAK_SON) then s := s + 'FIN';
          if((ATCPBaslik^.Bayrak and TCP_BAYRAK_ARZ) = TCP_BAYRAK_ARZ) then s := s + 'SYN';
          if((ATCPBaslik^.Bayrak and TCP_BAYRAK_GONDER) = TCP_BAYRAK_GONDER) then s := s + 'PSH';}

          //SISTEM_MESAJ_S10('TCP Onay -> SrcPort: ', Takas2(ATCPBaslik^.KaynakPort));
          //SISTEM_MESAJ_S10('TCP Onay -> DestPort: ', Takas2(ATCPBaslik^.HedefPort));
          //SISTEM_MESAJ_YAZI(s);
          SISTEM_MESAJ_S16('Bayrak: ', ATCPBaslik^.Bayrak, 2);
          SISTEM_MESAJ_S10('TCP: Onay -> DiziNo: ', Takas4(ATCPBaslik^.DiziNo));
          SISTEM_MESAJ_S10('TCP: Onay -> OnayNo: ', Takas4(ATCPBaslik^.OnayNo));
        end;
      end;

      // 8 byte, udp paket baþlýk uzunluðu
      //if(DataLen > 8) then _Baglanti^.BellegeEkle(@UdpPacket^.Data, DataLen - 8);
    end;
  end;
end;

// ABaslikEkle = tcp baþlýðýnýn sonuna eklenen 12 bytlýk verinin olup olmadýðýdýr
procedure TCPPaketGonder(ABaslikEkle: Boolean; AKaynakIPAdres: TIPAdres;
  ABaglanti: PBaglanti; AVeriBellekAdresi: Isaretci; AVeriUzunlugu: TISayi4;
  ADiziNo, AOnayNo: TSayi4; ABayrak: TSayi1; APencere: TSayi2);
var
  _TCPBaslik: PTCPBaslik;
  _SozdeBaslik: TSozdeBaslik;
  _Saglama: TSayi2;
  _BaslikUzunlugu: TSayi1;
  _p: PByte;
begin

  { TODO mesaj göndermeden önce hedef makinenin mac adresi arp yoluyla alýnacak }

  _TCPBaslik := GGercekBellek.Ayir(TCPBASLIK_UZUNLUGU + AVeriUzunlugu);

  // tcp için ek baþlýk hesaplanýyor
  _SozdeBaslik.KaynakIPAdres := AKaynakIPAdres;
  _SozdeBaslik.HedefIPAdres := ABaglanti^.FHedefIPAdres;
  _SozdeBaslik.Sifir := 0;
  _SozdeBaslik.Protokol := PROTOKOL_TCP;
  _SozdeBaslik.Uzunluk := Takas2(TSayi2(AVeriUzunlugu + TCPBASLIK_UZUNLUGU));

  // tcp paketi hazýrlanýyor
  { TODO : kaynak port numarasý almak için iþlev yazýlacak }
  if(ABaslikEkle) then
    _BaslikUzunlugu := (((20 + AVeriUzunlugu) shr 2) shl 4)
  else _BaslikUzunlugu := ((20 shr 2) shl 4);
  _TCPBaslik^.KaynakPort := Takas2(TSayi2(ABaglanti^.FKaynakPort));
  _TCPBaslik^.HedefPort := Takas2(TSayi2(ABaglanti^.FHedefPort));
  _TCPBaslik^.DiziNo := Takas4(TSayi4(ADiziNo));
  _TCPBaslik^.OnayNo := Takas4(TSayi4(AOnayNo));
  _TCPBaslik^.VeriKarsilik := _BaslikUzunlugu;     // üst 4 bit = _BaslikUzunlugu * 4 = baþlýk uzunluðu;
  _TCPBaslik^.Bayrak := ABayrak; // and $3F;
  _TCPBaslik^.Pencere := Takas2(APencere);
  _TCPBaslik^.SaglamaToplam := 0;
  _TCPBaslik^.AcilIsaretci := 0;
  if(AVeriUzunlugu > 0) then
  begin

    _p := @_TCPBaslik^.Secenekler;
    Tasi2(PByte(AVeriBellekAdresi), _p, AVeriUzunlugu);
  end;

  _Saglama := SaglamasiniYap(_TCPBaslik, TCPBASLIK_UZUNLUGU + AVeriUzunlugu,
    @_SozdeBaslik, SOZDE_TCPBASLIK_UZUNLUGU);
  _TCPBaslik^.SaglamaToplam := Takas2(TSayi2(_Saglama));

  IPPaketGonder(ABaglanti^.FHedefMACAdres, AKaynakIPAdres, ABaglanti^.FHedefIPAdres,
    ptTCP, $4000, _TCPBaslik, TCPBASLIK_UZUNLUGU + AVeriUzunlugu);

  GGercekBellek.YokEt(_TCPBaslik, TCPBASLIK_UZUNLUGU + AVeriUzunlugu);
end;

end.
