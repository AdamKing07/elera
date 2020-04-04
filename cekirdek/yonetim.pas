{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: yonetim.pas
  Dosya Ýþlevi: sistem ana yönetim / kontrol kýsmý

  Güncelleme Tarihi: 01/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit yonetim;

interface

uses paylasim;

type
  // gerçek moddan gelen veri yapýsý
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
procedure SistemDenetcisiOlustur;
procedure SistemCalismasiniDenetle;

implementation

uses gdt, gorev, src_klavye, genel, ag, dhcp, baglanti, zamanlayici, dns, arp,
  sistemmesaj, src_vesa20, acpi;

{==============================================================================
  sistem ilk yükleme iþlevlerini gerçekleþtirir
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

  // çekirdek bilgilerini al
  CekirdekBaslangicAdresi := _GMBilgi^.CekirdekBaslangicAdresi;
  CekirdekUzunlugu := _GMBilgi^.CekirdekKodUzunluk;

  // zamanlayýcý sayacýný sýfýrla
  ZamanlayiciSayaci := 0;

  // sistem sayacýný sýfýrla
  SistemSayaci := 0;

  // öndeðer fare göstergesini belirle
  GecerliFareGostegeTipi := fitBekle;

  // çekirdeðin kullanacaðý TSS'nin içeriðini sýfýrla
  FillByte(GorevTSSListesi[1], SizeOf(TTSS), 0);

  // TSS içeriðini doldur
  //GorevTSSListesi[1].CR3 := GERCEKBELLEK_DIZINADRESI;
  GorevTSSListesi[1].EIP := TSayi4(@SistemAnaKontrol);
  GorevTSSListesi[1].EFLAGS := $202;
  GorevTSSListesi[1].ESP := GOREV0_ESP;
  GorevTSSListesi[1].CS := SECICI_SISTEM_KOD * 8;
  GorevTSSListesi[1].DS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1].ES := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1].SS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1].FS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1].GS := SECICI_SISTEM_VERI * 8;
  GorevTSSListesi[1].SS0 := SECICI_SISTEM_VERI * 8;

  // not: sistem için CS ve DS seçicileri bilden programý tarafýndan
  // oluþturuldu. tekrar oluþturmaya gerek yok

  // sistem için TSS selektörünü oluþtur
  // access = p, dpl0 0, 1, 0, 0 (non_busy), 1
  // gran = g = 0, 0, 0, avl = 1, limit (4 bit)
  GDTRGirdisiEkle(SECICI_SISTEM_TSS, TSayi4(@GorevTSSListesi[1]),
    SizeOf(TTSS) - 1, $89, $10);

  // sistem görev deðerlerini belirle
  GorevListesi[1]^.GorevSayaci := 0;
  GorevListesi[1]^.BellekBaslangicAdresi := CekirdekBaslangicAdresi;
  GorevListesi[1]^.BellekUzunlugu := CekirdekUzunlugu;
  GorevListesi[1]^.OlaySayisi := 0;
  GorevListesi[1]^.EvBuffer := nil;

  // sistem görev adý (dosya adý)
  case _GMBilgi^.CekirdekCalismaModu of
    1: GorevListesi[1]^.FProgramAdi := 'cekirdkg.bin';
    2: GorevListesi[1]^.FProgramAdi := 'cekirdky.bin';
    3: GorevListesi[1]^.FProgramAdi := 'cekirdka.bin';
  end;

  // sistem görevini çalýþýyor olarak iþaretle
  _Gorev := GorevListesi[1];
  _Gorev^.DurumDegistir(1, gdCalisiyor);

  // çalýþan ve oluþturulan görev deðerlerini belirle
  CalisanGorevSayisi := 1;
  CalisanGorev := CalisanGorevSayisi;

  // ilk TSS'yi yükle
  // not : tss'nin yükleme iþlevi görev geçiþini gerçekleþtirmez. sadece
  // TSS'yi meþgul olarak ayarlar.
  asm
    mov   ax, SECICI_SISTEM_TSS * 8;
    ltr   ax
  end;

  // ana çekirdeðin iþleyiþini takip eden sistem denetçisini oluþtur
  SistemDenetcisiOlustur;
end;

{==============================================================================
  sistem ana kontrol kýsmý
 ==============================================================================}
procedure SistemAnaKontrol;
var
  _Gorev: PGorev;
  _YerelPort: TSayi2;
  _Tus: Char;
  _Baglanti: PBaglanti;
  _HedefAdres: TIPAdres;
  _TusDurum: TTusDurum;
  s: string;
begin

  _HedefAdres[0] := 193;
  _HedefAdres[1] := 1;
  _HedefAdres[2] := 1;
  _HedefAdres[3] := 11;

  if(CalisanGorevSayisi = 1) then
  repeat

    _Gorev^.Calistir(AcilisSurucuAygiti + ':\' + OnDegerMasaustuProgram);
    ElleGorevDegistir;
  until CalisanGorevSayisi > 1;

  KONTROLTusDurumu := tdYok;
  ALTTusDurumu := tdYok;
  DEGISIMTusDurumu := tdYok;

  // sistem için DHCP sunucusundan IP adresi al
  if(AgYuklendi) then DHCPSunucuKesfet;

  repeat

    // sistem sayacýný artýr
    Inc(SistemSayaci);

    // klavyeden basýlan tuþu al
    _TusDurum := KlavyedenTusAl(_Tus);
    if(_TusDurum = tdBasildi) and (_Tus <> #0) then
    begin

      if(KONTROLTusDurumu = tdBasildi) then
      begin

        // DHCP sunucusundan IP adresi al
        // bilgi: agbilgi.c programýnýn seçeneðine baðlýdýr
        if(_Tus = '2') then
        begin

          DHCPSunucuKesfet;
        end
        // test amaçlý
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
        else if(_Tus = '4') then
        begin

          _Gorev^.Calistir('disk1:\kmodtest.c');
          //ARPIstegiGonder(arpIstek, @MACAdres0, @_HedefAdres);
        end
        // test amaçlý
        else if(_Tus = '5') then
        begin

          _YerelPort := YerelPortAl;
          _Baglanti := _Baglanti^.Olustur(ptTCP, _HedefAdres, _YerelPort, 80);
          _Baglanti^.Baglan;
        end
        // test amaçlý
        else if(_Tus = '6') then
        begin

          s := 'GET / HTTP/1.1' + #13#10;
          s += 'Host: 193.1.1.11' + #13#10#13#10;
          //s += 'Connection: Close' + #13#10#13#10;

          _Baglanti^.Yaz(@s[1], Length(s));
        end
        else if(_Tus = '7') then
        begin

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

        // klavye olaylarýný iþle
        GOlay.KlavyeOlaylariniIsle(_Tus);
      end;
    end;

    if(AgYuklendi) then AgKartiVeriAlmaIslevi;

    // mouse olaylarýný iþle
    GOlay.FareOlaylariniIsle;

    GEkranKartSurucusu.EkranBelleginiGuncelle;

  until (1 = 2);
end;

procedure SistemDenetcisiOlustur;
var
  _Gorev: PGorev;
begin

  {GDTRGirdisiEkle(SECICI_DENETIM_KOD, 0, $FFFFFFFF, $FA, $CF);                  // DPL 3
  GDTRGirdisiEkle(SECICI_DENETIM_VERI, 0, $FFFFFFFF, $F2, $CF);
  GDTRGirdisiEkle(SECICI_DENETIM_TSS, TSayi4(@GorevTSSListesi[2]), SizeOf(TTSS) - 1, $E9, $10);}

  GDTRGirdisiEkle(SECICI_DENETIM_KOD, 0, $FFFFFFFF, $9A, $DF);
  GDTRGirdisiEkle(SECICI_DENETIM_VERI, 0, $FFFFFFFF, $92, $DF);
  GDTRGirdisiEkle(SECICI_DENETIM_TSS, TSayi4(@GorevTSSListesi[2]), SizeOf(TTSS) - 1, $89, $10);

  // çekirdeðin kullanacaðý TSS'nin içeriðini sýfýrla
  FillByte(GorevTSSListesi[2], SizeOf(TTSS), 0);

  GorevTSSListesi[2].EIP := TSayi4(@SistemCalismasiniDenetle);    // DPL 0
  GorevTSSListesi[2].EFLAGS := $202;
  GorevTSSListesi[2].ESP := $4000000 - $100;
  GorevTSSListesi[2].CS := SECICI_DENETIM_KOD * 8;
  GorevTSSListesi[2].DS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].ES := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].SS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].FS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].GS := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].SS0 := SECICI_DENETIM_VERI * 8;
  GorevTSSListesi[2].ESP0 := $4000000 - $100;

  {GorevTSSListesi[2].EIP := TSayi4(@SistemCalismasiniDenetle);  // DPL 3
  GorevTSSListesi[2].EFLAGS := $202;
  GorevTSSListesi[2].ESP := $4000000 - $400;
  GorevTSSListesi[2].CS := (SECICI_DENETIM_KOD * 8) + 3;
  GorevTSSListesi[2].DS := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].ES := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].SS := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].FS := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].GS := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].SS0 := (SECICI_DENETIM_VERI * 8) + 3;
  GorevTSSListesi[2].ESP0 := $4000000;}

  // sistem görev deðerlerini belirle
  GorevListesi[2]^.GorevSayaci := 0;
  GorevListesi[2]^.BellekBaslangicAdresi := 0;
  GorevListesi[2]^.BellekUzunlugu := $FFFFFFFF;
  GorevListesi[2]^.OlaySayisi := 0;
  GorevListesi[2]^.EvBuffer := nil;

  // sistem görev adý (dosya adý)
  GorevListesi[2]^.FProgramAdi := 'denetci.???';

  // sistem görevini çalýþýyor olarak iþaretle
  _Gorev := GorevListesi[2];
  _Gorev^.DurumDegistir(2, gdCalisiyor);

  // çalýþan ve oluþturulan görev deðerlerini belirle
  CalisanGorevSayisi := 2;
end;

procedure SistemCalismasiniDenetle;
begin

  asm
  @@1:

    mov eax,SistemKontrolSayaci
    inc eax
    mov SistemKontrolSayaci,eax
  jmp @@1
  end;
end;

end.
