{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: baglanti.pas
  Dosya İşlevi: bağlantı (soket) yönetim işlevlerini içerir

  Güncelleme Tarihi: 21/10/2019

 ==============================================================================}
{$mode objfpc}
unit baglanti;

interface

uses paylasim, sistemmesaj;

const
  USTSINIR_AGILETISIM = 64;
  TCP_PENCERE_UZUNLUK = 8192;
  ILK_YERELPORTNO     = 714;

  TCP_BAYRAK_SON      = $01;
  TCP_BAYRAK_ARZ      = $02;    // syn
  TCP_BAYRAK_GONDER   = $08;
  TCP_BAYRAK_KABUL    = $10;    // ack

var
  YerelPortNo: TSayi2;

type
  TBaglantiDurum = (bdYok, bdKapali, bdBaglaniyor, bdBaglandi, bdKapaniyor);

type
  PBaglanti = ^TBaglanti;
  TBaglanti = object
  public
    FKimlik: TKimlik;
    FBaglantiDurum: TBaglantiDurum;
    FProtokol: TProtokolTip;
    FPencere: TSayi2;
    FDiziNo, FOnayNo: TSayi4;
    FHedefMACAdres: TMACAdres;
    FHedefIPAdres: TIPAdres;
    FKaynakPort, FHedefPort: TSayi2;
    FIlkDiziNo: TSayi4;
    FBagli: Boolean;
    FBellek: Pointer;
    FBellekUzunlugu: Integer;
    function Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres; AKaynakPort,
      AHedefPort: TSayi2): PBaglanti;
    function BosBaglantiBul: PBaglanti;
    function Baglan: TISayi4;
    function BagliMi: Boolean;
    function BaglantiyiKes: TISayi4;
    function DiziSiraNumarasiAl: Integer;
    function BaglantiAl(AKaynakPort: TSayi2): PBaglanti;
    procedure BellegeEkle(AKaynakBellek: Isaretci; ABellekUzunlugu: TSayi4);
    function VeriUzunlugu: TISayi4;
    function VeriOku(AHedefBellek: Isaretci): TISayi4;
    procedure VeriYaz(ABellekAdresi: Isaretci; AVeriUzunlugu: TISayi4);
  end;

procedure Yukle;
function YerelPortAl: TSayi2;

implementation

uses gercekbellek, genel, tcp, udp, arp;

{==============================================================================
  bağlantı ana yükleme işlevlerini içerir
 ==============================================================================}
procedure Yukle;
var
  _Baglanti: PBaglanti;
  i: TSayi4;
begin

  // bağlantı bilgilerinin yerleştirilmesi için bellek ayır
  _Baglanti := GGercekBellek.Ayir(SizeOf(TBaglanti) * USTSINIR_AGILETISIM);

  // bellek girişlerini dizi girişleriyle eşleştir
  for i := 1 to USTSINIR_AGILETISIM do
  begin

    AgIletisimListesi[i] := _Baglanti;

    // işlemi boş olarak belirle
    _Baglanti^.FBaglantiDurum := bdYok;
    _Baglanti^.FKimlik := i;

    Inc(_Baglanti);
  end;

  YerelPortNo := ILK_YERELPORTNO;
end;

{==============================================================================
  ağ bağlantısı için bağlantı oluşturur
 ==============================================================================}
function TBaglanti.Olustur(AProtokolTip: TProtokolTip; AHedefIPAdres: TIPAdres;
  AKaynakPort, AHedefPort: TSayi2): PBaglanti;
var
  _Baglanti: PBaglanti;
  _MACAdres: TMACAdres;
begin

  _Baglanti := nil;

  if(AProtokolTip = ptTCP) then
  begin

    // arp tablosundan ip adresinin karşılığı olan mac adresini al
    _MACAdres := MACAdresiAl(AHedefIPAdres);

    _Baglanti := BosBaglantiBul;
    if(_Baglanti <> nil) then
    begin

      _Baglanti^.FBaglantiDurum := bdKapali;
      _Baglanti^.FProtokol := AProtokolTip;
      _Baglanti^.FHedefMACAdres := _MACAdres;
      _Baglanti^.FHedefIPAdres := AHedefIPAdres;
      _Baglanti^.FKaynakPort := AKaynakPort;
      _Baglanti^.FHedefPort := AHedefPort;
      _Baglanti^.FBagli := False;
      _Baglanti^.FPencere := TCP_PENCERE_UZUNLUK;
      //_Baglanti^.FDiziNo := DiziSiraNumarasiAl;
      _Baglanti^.FOnayNo := 0;
      _Baglanti^.FIlkDiziNo := 0;

      FBellekUzunlugu := 0;
      FBellek := GGercekBellek.Ayir(_Baglanti^.FPencere);
    end;
  end
  else if(AProtokolTip = ptUDP) then
  begin

    _Baglanti := BosBaglantiBul;
    if(_Baglanti <> nil) then
    begin

      _Baglanti^.FBaglantiDurum := bdBaglandi;
      _Baglanti^.FProtokol := AProtokolTip;
      _Baglanti^.FHedefIPAdres := AHedefIPAdres;
      _Baglanti^.FKaynakPort := AKaynakPort;
      _Baglanti^.FHedefPort := AHedefPort;
      _Baglanti^.FBagli := False;

      FBellekUzunlugu := 0;
      FBellek := GGercekBellek.Ayir(4095);

      {SISTEM_MESAJ_YAZI('BAGLANTI.PP: Protokol -> UDP');
      SISTEM_MESAJ_S16('UDP Bellek Adresi: ', TSayi4(FBellek), 8);
      SISTEM_MESAJ_IP('Hedef IP: ', AHedefIPAdres);
      SISTEM_MESAJ_S16('Kaynak Port: ', AKaynakPort, 4);
      SISTEM_MESAJ_S16('Hedef Port: ', AHedefPort, 4);}
    end;
  end
  else
  begin

    _Baglanti := BosBaglantiBul;
    if(_Baglanti <> nil) then
    begin

      SISTEM_MESAJ_YAZI('BAGLANTI.PP: Protokol -> ?');
      SISTEM_MESAJ_IP('Hedef IP: ', AHedefIPAdres);
      SISTEM_MESAJ_S16('Hedef Port: ', AHedefPort, 4);
    end;
  end;

  Result := _Baglanti;
end;

{==============================================================================
  kullanılacak boş bağlantı noktası bulur
 ==============================================================================}
function TBaglanti.BosBaglantiBul: PBaglanti;
var
  _Baglanti: PBaglanti;
  i: TSayi4;
begin

  // tüm işlem girişlerini incele
  for i := 1 to USTSINIR_AGILETISIM do
  begin

    _Baglanti := AgIletisimListesi[i];

    // bağlantı durumu boş ise
    if(_Baglanti^.FBaglantiDurum = bdYok) then
    begin

      // bağlantıyı ayır ve çağıran işleve geri dön
      _Baglanti^.FBaglantiDurum := bdKapali;
      Exit(_Baglanti);
    end;
  end;

  Result := nil;
end;

{==============================================================================
  oluşturulan bağlantı üzerinden diğer uçtaki sisteme bağlantı kurar
 ==============================================================================}
function TBaglanti.Baglan: TISayi4;
var
  _TCPBellek: array[0..11] of TSayi1;
begin

  // bağlantı kimliği tanımlanan aralıkta ise...
  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptUDP) then
    begin

      FBagli := True;
      Result := 1;
      Exit;
    end
    else if(FProtokol = ptTCP) then
    begin

      _TCPBellek[0] := 2;
      _TCPBellek[1] := 4;
      _TCPBellek[2] := 5;
      _TCPBellek[3] := $B4;
      _TCPBellek[4] := 1;
      _TCPBellek[5] := 3;
      _TCPBellek[6] := 3;
      _TCPBellek[7] := 8;
      _TCPBellek[8] := 1;
      _TCPBellek[9] := 1;
      _TCPBellek[10] := 4;
      _TCPBellek[11] := 2;

      if(FBaglantiDurum = bdKapali) then
      begin

        FDiziNo := DiziSiraNumarasiAl;
        FOnayNo := 0;

        // ilk paket olan SYN (ARZ) paketi gönderiliyor
        TCPPaketGonder(True, AgBilgisi.IP4Adres, @Self, @_TCPBellek, 12,
          FDiziNo, FOnayNo, TCP_BAYRAK_ARZ, FPencere);

        //Inc(FDiziNo);

        FBaglantiDurum := bdBaglaniyor;
      end;
    end;
  end;

  Result := 0;
end;

{==============================================================================
  bağlantının var olup olmadığını kontrol eder
 ==============================================================================}
function TBaglanti.BagliMi: Boolean;
begin

  // bağlantı kimliği tanımlanan aralıkta ise...
  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptUDP) then

      Result := FBagli
    else if(FProtokol = ptTCP) then
    begin

      if(FBaglantiDurum = bdBaglandi) then
        Result := True
      else Result := False;

    end else Result := False;
  end else Result := False;
end;

{==============================================================================
  bağlantıyı kapatır
 ==============================================================================}
function TBaglanti.BaglantiyiKes: TISayi4;
begin

  // bağlantı kimliği tanımlanan aralıkta ise...
  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptUDP) then
    begin

      FBaglantiDurum := bdKapali;
      FProtokol := ptBilinmiyor;
      FHedefIPAdres := IPAdres0;
      FKaynakPort := 0;
      FHedefPort := 0;
      GGercekBellek.YokEt(FBellek, FBellekUzunlugu);
      FBagli := False;
      Result := 0;
    end
    else if(FProtokol = ptTCP) then
    begin

      if(FBaglantiDurum = bdBaglandi) then
      begin

        TCPPaketGonder(False, AgBilgisi.IP4Adres, @Self, nil, 0, FDiziNo,
          FOnayNo, TCP_BAYRAK_SON + TCP_BAYRAK_KABUL, FPencere);

        Inc(FDiziNo);

        FBaglantiDurum := bdKapaniyor;

        {FBaglantiDurum := ssCreated;
        FProtokol := ptBilinmiyor;
        FHedefIPAdres := IPAdres0;
        FKaynakPort := 0;
        FHedefPort := 0;
        GMem.Destroy(FBellek, FBellekUzunlugu);
        FBagli := False;}
        Result := 0;
      end;
    end;
  end;
end;

function TBaglanti.DiziSiraNumarasiAl: Integer;
begin

  Result := ZamanlayiciSayaci;
end;

{==============================================================================
  kaynak portun sahibi olan bağlantıyı alır
 ==============================================================================}
function TBaglanti.BaglantiAl(AKaynakPort: TSayi2): PBaglanti;
var
  _Baglanti: PBaglanti;
  i: TSayi4;
begin

  // tüm işlem girişlerini incele
  for i := 1 to USTSINIR_AGILETISIM do
  begin

    _Baglanti := AgIletisimListesi[i];
    if not(_Baglanti^.FBaglantiDurum = bdYok) and (_Baglanti^.FKaynakPort = AKaynakPort) then
    begin

      Result := _Baglanti;
      Exit;
    end;
  end;

  Result := nil;
end;

{==============================================================================
  bağlantı kurulan bilgisayardan gelen verileri programın kullanması için belleğe kaydeder
  bilgi: şu aşamada kullanılmamaktadır
 ==============================================================================}
procedure TBaglanti.BellegeEkle(AKaynakBellek: Isaretci; ABellekUzunlugu: TSayi4);
var
  p: PChar;
begin

  p := Self.FBellek + Self.FBellekUzunlugu;
  Tasi2(AKaynakBellek, p, ABellekUzunlugu);
  Inc(Self.FBellekUzunlugu, ABellekUzunlugu);
end;

{==============================================================================
  bağlantı kurulan cihazdan gelip işlenmeyi bekleyen veri miktarını alır
 ==============================================================================}
function TBaglanti.VeriUzunlugu: TISayi4;
begin

  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptUDP) then
    begin

      Result := Self.FBellekUzunlugu;
      Exit;
    end;
  end;

  Result := 0;
end;

{==============================================================================
  bağlantı üzerinden gelen veriyi okuyarak ilgili programa yönlendirir
 ==============================================================================}
function TBaglanti.VeriOku(AHedefBellek: Isaretci): TISayi4;
var
  i: TSayi4;
begin

  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptUDP) then
    begin

      i := Self.FBellekUzunlugu;
      if(i > 0) then
      begin

        Tasi2(Self.FBellek, AHedefBellek, i);
        Result := Self.FBellekUzunlugu;
        Self.FBellekUzunlugu := 0;
        Exit;
      end;
    end;
  end;

  Result := 0;
end;

{==============================================================================
  bağlantı kurulan bilgisayara veri gönderir
 ==============================================================================}
procedure TBaglanti.VeriYaz(ABellekAdresi: Isaretci; AVeriUzunlugu: TISayi4);
begin

  if(FKimlik > 0) and (FKimlik <= USTSINIR_AGILETISIM) then
  begin

    if(FProtokol = ptTCP) then
    begin

      if(FBaglantiDurum = bdBaglandi) then
      begin

        FPencere := $100;
        TCPPaketGonder(False, AgBilgisi.IP4Adres, @Self, ABellekAdresi, AVeriUzunlugu,
          FDiziNo, FOnayNo, TCP_BAYRAK_KABUL or TCP_BAYRAK_GONDER, FPencere);
      end;
    end
    else if(FProtokol = ptUDP) then
    begin

      UDPPaketGonder(AgBilgisi.IP4Adres, FHedefIPAdres, FKaynakPort, FHedefPort,
        ABellekAdresi, AVeriUzunlugu);
    end
  end;
end;

{==============================================================================
  yerel port numarası üretir
 ==============================================================================}
function YerelPortAl: TSayi2;
begin

  Inc(YerelPortNo);
  if(YerelPortNo > 65000) then YerelPortNo := ILK_YERELPORTNO;
  Result := YerelPortNo;
end;

end.
