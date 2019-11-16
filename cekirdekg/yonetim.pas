{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: yonetim.pas
  Dosya ��levi: sistem ana y�netim / kontrol k�sm�

  G�ncelleme Tarihi: 08/11/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit yonetim;

interface

uses paylasim;

type
  // ger�ek moddan gelen veri yap�s�
  PGMBilgi = ^TGMBilgi;
  TGMBilgi = packed record
    VideoBellekUzunlugu: TSayi2;
    VideoEkranMod: TSayi2;
    VideoYatayCozunurluk: TSayi2;
    VideoDikeyCozunurluk: TSayi2;
    VideoBellekAdresi: TSayi4;
    VideoPixelBasinaBitSayisi: TSayi1;
    VideoSatirdakiByteSayisi: TSayi2;
    // CekirdekCalismaModu: 1 = pascal grafik, 2 = pascal text, 3 = assembly
    CekirdekCalismaModu: TSayi2;
    CekirdekBaslangicAdresi: TSayi4;
    CekirdekKodUzunluk: TSayi4;
  end;

procedure Yukle;
procedure SistemAnaKontrol;

implementation

uses gdt, gorev, src_klavye, genel, ag, dhcp, baglanti, zamanlayici, dns, arp;

{==============================================================================
  sistem ilk y�kleme i�levlerini ger�ekle�tirir
 ==============================================================================}
procedure Yukle;
var
  _Gorev: PGorev;
  _GMBilgi: PGMBilgi;
begin

  _GMBilgi := PGMBilgi(BILDEN_VERIADRESI);

  // video bilgilerini al
  GEkranKartSurucusu.KartBilgisi.BellekUzunlugu := _GMBilgi^.VideoBellekUzunlugu;
  GEkranKartSurucusu.KartBilgisi.EkranMod := _GMBilgi^.VideoEkranMod;
  GEkranKartSurucusu.KartBilgisi.YatayCozunurluk := _GMBilgi^.VideoYatayCozunurluk;
  GEkranKartSurucusu.KartBilgisi.DikeyCozunurluk := _GMBilgi^.VideoDikeyCozunurluk;
  GEkranKartSurucusu.KartBilgisi.BellekAdresi := _GMBilgi^.VideoBellekAdresi; //VIDEO_MEM_ADDR;
  GEkranKartSurucusu.KartBilgisi.PixelBasinaBitSayisi := _GMBilgi^.VideoPixelBasinaBitSayisi;
  GEkranKartSurucusu.KartBilgisi.NoktaBasinaByteSayisi := (_GMBilgi^.VideoPixelBasinaBitSayisi div 8);
  GEkranKartSurucusu.KartBilgisi.SatirdakiByteSayisi := _GMBilgi^.VideoSatirdakiByteSayisi;

  // �ekirdek bilgilerini al
  CekirdekBaslangicAdresi := _GMBilgi^.CekirdekBaslangicAdresi;
  CekirdekUzunlugu := _GMBilgi^.CekirdekKodUzunluk;

  // zamanlay�c� sayac�n� s�f�rla
  ZamanlayiciSayaci := 0;

  // sistem sayac�n� s�f�rla
  SistemSayaci := 0;

  // �nde�er fare g�stergesini belirle
  GecerliFareGostegeTipi := fitBekle;

  // �ekirde�in kullanaca�� TSS'nin i�eri�ini s�f�rla
  FillByte(GorevTSSListesi[1], SizeOf(TTSS), 0);

  // TSS i�eri�ini doldur
  //GorevTSSListesi[1].CR3 := GERCEKBELLEK_DIZINADRESI;
  GorevTSSListesi[1].EIP := TSayi4(@SistemAnaKontrol);
  GorevTSSListesi[1].EFLAGS := $202;
  GorevTSSListesi[1].ESP := GOREV0_ESP;
  GorevTSSListesi[1].CS := SECICI_SISTEM_KOD;
  GorevTSSListesi[1].DS := SECICI_SISTEM_VERI;
  GorevTSSListesi[1].ES := SECICI_SISTEM_VERI;
  GorevTSSListesi[1].SS := SECICI_SISTEM_VERI;
  GorevTSSListesi[1].FS := SECICI_SISTEM_VERI;
  GorevTSSListesi[1].GS := SECICI_SISTEM_VERI;
  GorevTSSListesi[1].SS0 := SECICI_SISTEM_VERI;

  // not: sistem i�in CS ve DS se�icileri bilden program� taraf�ndan
  // olu�turuldu. tekrar olu�turmaya gerek yok

  // sistem i�in TSS selekt�r�n� olu�tur
  // access = p, dpl0 0, 1, 0, 0 (non_busy), 1
  // gran = g = 0, 0, 0, avl = 1, limit (4 bit)
  GDTRGirdisiEkle((SECICI_SISTEM_VERI div 8) + 1, TSayi4(@GorevTSSListesi[1]),
    SizeOf(TTSS) - 1, $89, $10);

  // ilk TSS'yi y�kle
  // not : tss'nin y�kleme i�levi g�rev ge�i�ini ger�ekle�tirmez. sadece
  // TSS'yi me�gul olarak ayarlar.
  asm
    mov   ax, SECICI_SISTEM_VERI + 8;
    ltr   ax
  end;

  // sistem g�rev de�erlerini belirle
  GorevListesi[1]^.GorevSayaci := 0;
  GorevListesi[1]^.BellekBaslangicAdresi := CekirdekBaslangicAdresi;
  GorevListesi[1]^.BellekUzunlugu := CekirdekUzunlugu;
  GorevListesi[1]^.OlaySayisi := 0;
  GorevListesi[1]^.EvBuffer := nil;

  // sistem g�rev ad� (dosya ad�)
  case _GMBilgi^.CekirdekCalismaModu of
    1: GorevListesi[1]^.FProgramAdi := 'cekirdkg.bin';
    2: GorevListesi[1]^.FProgramAdi := 'cekirdky.bin';
    3: GorevListesi[1]^.FProgramAdi := 'cekirdka.bin';
  end;

  // sistem g�revini �al���yor olarak i�aretle
  _Gorev := GorevListesi[1];
  _Gorev^.DurumDegistir(1, gdCalisiyor);

  // �al��an ve olu�turulan g�rev de�erlerini belirle
  CalisanGorevSayisi := 1;
  AktifGorev := CalisanGorevSayisi;
end;

{==============================================================================
  sistem ana kontrol k�sm�
 ==============================================================================}
procedure SistemAnaKontrol;
var
  _Gorev: PGorev;
  _YerelPort: TSayi2;
  _Tus: Char;
  _Baglanti: PBaglanti;
  _IPAdres1: TIPAdres;
  _TusDurum: TTusDurum;
  s: string;
begin

  if(CalisanGorevSayisi = 1) then
  repeat

    _Gorev^.Calistir(AcilisSurucuAygiti + ':\' + OnDegerMasaustuProgram);
    ElleGorevDegistir;
  until CalisanGorevSayisi > 1;

  KONTROLTusDurumu := tdYok;
  ALTTusDurumu := tdYok;
  DEGISIMTusDurumu := tdYok;

  // sistem i�in DHCP sunucusundan IP adresi al
  if(AgYuklendi) then DHCPSunucuKesfet;

  repeat

    // sistem sayac�n� art�r
    Inc(SistemSayaci);

    // klavyeden bas�lan tu�u al
    _TusDurum := KlavyedenTusAl(_Tus);
    if(_TusDurum = tdBasildi) and (_Tus <> #0) then
    begin

      if(KONTROLTusDurumu = tdBasildi) then
      begin

        // DHCP sunucusundan IP adresi al
        // bilgi: agbilgi.c program�n�n se�ene�ine ba�l�d�r
        if(_Tus = '2') then
        begin

          DHCPSunucuKesfet;
        end
        // test ama�l�
        else if(_Tus = '3') then
        begin

          //DNSIstegiGonder;
          //_Gorev^.Calistir('disk1:\resimgor.c');
          _Gorev^.Calistir('disk1:\arpbilgi.c');
          {i := FindFirst('disk1:\kaynak\*.*', 0, AramaKaydi);
          while i = 0 do
          begin

            SISTEM_MESAJ_YAZI('Dosya: ' + AramaKaydi.DosyaAdi);
            i := FindNext(AramaKaydi);
          end;
          FindClose(AramaKaydi);}
        end
        // test ama�l�
        else if(_Tus = '4') then
        begin

          _IPAdres1[0] := 192;
          _IPAdres1[1] := 168;
          _IPAdres1[2] := 1;
          _IPAdres1[3] := 4;
          ARPIstegiGonder(arpIstek, @MACAdres0, @_IPAdres1);
          //_Gorev^.Calistir('disk1:\resimgor.c');
        end
        // test ama�l�
        else if(_Tus = '5') then
        begin

          _IPAdres1[0] := 192;
          _IPAdres1[1] := 168;
          _IPAdres1[2] := 1;
          _IPAdres1[3] := 4;
          _YerelPort := YerelPortAl;
          _Baglanti := _Baglanti^.Olustur(ptTCP, _IPAdres1, _YerelPort, 1871);
          _Baglanti^.Baglan;
        end
        // test ama�l�
        else if(_Tus = '6') then
        begin

          s := 'GET / HTTP/1.1' + #13#10;
          s += 'Host: 192.168.1.4' + #13#10#13#10;
          //s += 'Connection: Close' + #13#10#13#10;

          //s := 'TCP ba�lant� i�lemi tamam' + #13#10;

          //s := 'merhaba, naslsn.';

          _Baglanti^.VeriYaz(@s[1], Length(s));
        end
        else if(_Tus = '7') then
        begin

          _IPAdres1[0] := 192;
          _IPAdres1[1] := 168;
          _IPAdres1[2] := 1;
          _IPAdres1[3] := 4;
          _Baglanti^.BaglantiyiKes;
        end
        else if(_Tus = 'd') then
        begin

          _Gorev^.Calistir('disk1:\dsyyntcs.c');
        end
        else if(_Tus = 'g') then
        begin

          _Gorev^.Calistir('disk1:\grvyntcs.c');
        end
        else if(_Tus = 'm') then
        begin

          _Gorev^.Calistir('disk1:\smsjgor.c');
        end
      end
      else
      begin

        // klavye olaylar�n� i�le
        GOlay.KlavyeOlaylariniIsle(_Tus);
      end;
    end;

    if(AgYuklendi) then AgKartiVeriAlmaIslevi;

    // mouse olaylar�n� i�le
    GOlay.FareOlaylariniIsle;

    GEkranKartSurucusu.EkranBelleginiGuncelle;

  until (1 = 2);
end;

end.
