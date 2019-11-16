{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: src_disket.pas
  Dosya İşlevi: disket aygıt sürücüsü

  Güncelleme Tarihi: 22/10/2019

 ==============================================================================}
{$mode objfpc}
unit src_disket;
 
interface
{

  1.44 kapasiteli sürücünün değerleri

  kafa numarası     : 00..01 = 2
  iz numarası       : 00..79 = 80
  sektör numarası   : 01..18 = 18
  sektör kapasitesi : 512 byte

  2 * 80 * 18 * 512 = 1474560 = 1.44

}
uses paylasim, port;

const
  DISKET_TEMEL          = $3F0;       // base addres
  DISKET_CIKISYAZMAC    = $3F2;       // digital output register
  DISKET_ANADURUMYAZMAC = $3F4;       // main status register
  DISKET_HIZSECIMYAZMAC = $3F4;       // data rate select register
  DISKET_VERI           = $3F5;       // data register
  DISKET_GIRISYAZMAC    = $3F7;       // digital input register
  DISKET_AYARYAZMAC     = $3F7;       // configuration control register

  DMA_BELLEKADRESI      = $8000;      // DMA'nın veri transfer adresi
  DMA_OKU               = $46;        // fdc->mem
  DMA_YAZ               = $48;        // mem->fdc

var
  IRQ6Tetiklendi: Boolean;
  DURUM0, DURUM1, DURUM2: TSayi1;

procedure Yukle;
procedure MotorAc(AFizikselSurucu: PFizikselSurucu);
procedure MotorKapat(AFizikselSurucu: PFizikselSurucu);
procedure DMA2Yukle(Op: Byte);
function DurumOku: TSayi1;
procedure DurumYaz(ADeger: TSayi1);
function Bekle: Boolean;
procedure IRQ6KesmeIslevi;
function Konumlan0(AFizikselSurucu: PFizikselSurucu): Boolean;
function Konumlan(AFizikselSurucu: PFizikselSurucu; AIz, AKafa: TSayi1): Boolean;
procedure DisketSurucuMotorunuKontrolEt;
procedure SektoruAyristir(ASektorNo: TSayi2; var AKafa, AIz, ASektor: TSayi1);
function TekSektorOku(AFizikselSurucu: PFizikselSurucu; ASektorNo: TSayi4): Boolean;
function SektorOku(AFizikselSurucu: Isaretci; AIlkSektor, ASektorSayisi: TSayi4;
  AHedefBellek: Isaretci): Boolean;

implementation

uses irq, zamanlayici, aygityonetimi;

{==============================================================================
  disket sürücü ilk yükleme işlevlerini içerir
 ==============================================================================}
procedure Yukle;
var
  _FizikselSurucu: PFizikselSurucu;
  i, j: TSayi1;
begin

  // CMOS'tan disket sürücü bilgilerini al
  PortYaz1($70, $10);
  i := PortAl1($71);

  PDisket1 := nil;
  PDisket2 := nil;

  // eğer herhangi bir disket sürücüsü var ise
  if(i > 0) then
  begin

  { -----------------------------------
    i = Sürücü Tip = AAAABBBB
    AAAA = birinci sürücü, BBBB = ikinci sürücü
    ===================================
    0	  sürücü yok
    1	  5.25" 320K veya 360K
    2	  5.25" 1.2M
    3	  3.5"  720K
    4	  3.5"  1.44M
    5	  3.5"  2.88M
    ----------------------------------}

    // birincil sürücü (master)
    j := ((i shr 4) and $F);
    if(j > 0) then
    begin

      _FizikselSurucu := FizikselDepolamaAygitiOlustur(SURUCUTIP_DISKET);
      if(_FizikselSurucu <> nil) then
      begin

        _FizikselSurucu^.Ozellikler := j;
        _FizikselSurucu^.SektorOku := @SektorOku;
        _FizikselSurucu^.PortBilgisi.PortNo := $3F0;
        _FizikselSurucu^.PortBilgisi.Kanal := 0;
        _FizikselSurucu^.SonIzKonumu := -1;

        _FizikselSurucu^.SilindirSayisi := 18;
        _FizikselSurucu^.KafaSayisi := 2;
        _FizikselSurucu^.IzBasinaSektorSayisi := 80;
        _FizikselSurucu^.ToplamSektorSayisi := 18 * 2 * 80;

        // disket sürücü motorunu kapat
        _FizikselSurucu^.MotorDurumu := 0;
        MotorKapat(_FizikselSurucu);

        PDisket1 := _FizikselSurucu;
      end;
    end;

    // ikincil sürücü (slave)
    j := (i and $F);
    if(j > 0) then
    begin

      _FizikselSurucu := FizikselDepolamaAygitiOlustur(SURUCUTIP_DISKET);
      if(_FizikselSurucu <> nil) then
      begin

        _FizikselSurucu^.Ozellikler := j;
        _FizikselSurucu^.SektorOku := @SektorOku;
        _FizikselSurucu^.PortBilgisi.PortNo := $3F0;
        _FizikselSurucu^.PortBilgisi.Kanal := 1;
        _FizikselSurucu^.SonIzKonumu := -1;

        _FizikselSurucu^.SilindirSayisi := 18;
        _FizikselSurucu^.KafaSayisi := 2;
        _FizikselSurucu^.IzBasinaSektorSayisi := 80;
        _FizikselSurucu^.ToplamSektorSayisi := 18 * 2 * 80;

        // disket sürücü motorunu kapat
        _FizikselSurucu^.MotorDurumu := 0;
        MotorKapat(_FizikselSurucu);

        PDisket2 := _FizikselSurucu;
      end;
    end;

    // öndeğerler atanıyor
    IRQ6Tetiklendi := False;

    // disket sürücüsü için irq istek kanalını etkinleştir
    IRQIsleviAta(6, @IRQ6KesmeIslevi);
  end;
end;

{==============================================================================
  disket sürücü motorunu çalıştırır
 ==============================================================================}
procedure MotorAc(AFizikselSurucu: PFizikselSurucu);
var
  _Durum: TSayi1;
begin

  _Durum := AFizikselSurucu^.MotorDurumu;

  // eğer motor kapalı ise
  if(_Durum = 0) then
  begin

    AFizikselSurucu^.MotorDurumu := 5;

    // motor'u aç
    if(AFizikselSurucu^.PortBilgisi.Kanal = 0) then

      PortYaz1(DISKET_CIKISYAZMAC, $1C)
    else PortYaz1(DISKET_CIKISYAZMAC, $2D);

    // CCR = 500kbits/s
    PortYaz1(DISKET_AYARYAZMAC, 0);

    //Delay(150);
  end

  // motor zaten açık ise
  else if(_Durum = 5) then
  begin

  end

  // motor kapanıyor durumunda ise
  else
  begin

    AFizikselSurucu^.MotorDurumu := 5;
  end;
end;

{==============================================================================
  disket sürücü motorunu durdurur
 ==============================================================================}
procedure MotorKapat(AFizikselSurucu: PFizikselSurucu);
begin

  // motor'u kapat
  if(AFizikselSurucu^.PortBilgisi.Kanal = 0) then

    PortYaz1(DISKET_CIKISYAZMAC, $C)
  else PortYaz1(DISKET_CIKISYAZMAC, $5);
end;

{==============================================================================
  okuma / yazma işlevi için DMA aygıtını hazırlar
 ==============================================================================}
procedure DMA2Yukle(Op: Byte);
begin

  // 2 nolu DMA kanalını maskele
  PortYaz1($A, 4 + 2);

  // FLIP-FLOP sıfırla
  PortYaz1($C, 0);

  // DMA'nın yapacağı işlevi belirle. oku/yaz. +2 = dma kanalı
  PortYaz1($B, Op + 2);

  // bellek adresini belirle
  PortYaz1(4, (DMA_BELLEKADRESI and $FF));
  PortYaz1(4, ((DMA_BELLEKADRESI shr 8) and $FF));
  PortYaz1($81, ((DMA_BELLEKADRESI shr 16) and $FF));

  // işlem (okuma / yazma) yapılacak veri miktarı. $1FF = 511
  PortYaz1(5, $FF);
  PortYaz1(5, $1);

  // 2 nolu DMA'yı aktifleştir
  PortYaz1($A, 2);
end;

{==============================================================================
  disket sürücü denetleyicisinden bilgi alma işlevi
 ==============================================================================}
function DurumOku: TSayi1;
var
  i: TSayi4;
begin

  for i := 1 to $1000 do
  begin

    if((PortAl1(DISKET_ANADURUMYAZMAC) and $C0) = $C0) then   // MRQ=1, DIO=1
    begin

      Result := PortAl1(DISKET_VERI);
      Exit;
    end;
  end;
end;

{==============================================================================
  disket sürücü denetleyicisine bilgi gönderme işlevi
 ==============================================================================}
procedure DurumYaz(ADeger: TSayi1);
var
  i: TSayi4;
begin

  for i := 1 to $1000 do
  begin

    if((PortAl1(DISKET_ANADURUMYAZMAC) and $C0) = $80) then   // $80 = MRQ=1
    begin

      PortYaz1(DISKET_VERI, ADeger);
      Exit;
    end;
  end;
end;

{==============================================================================
  disket sürücüsü bekleme rutini
 ==============================================================================}
function Bekle: Boolean;
var
  i: TSayi4;
begin

  Bekle := True;

  i := ZamanlayiciSayaci + 150;

  // şart true olduğu müddetçe devam et
  while (i > ZamanlayiciSayaci) do
  begin

    if(IRQ6Tetiklendi) then Exit;
    ElleGorevDegistir;
  end;

  Bekle := False;
end;

{==============================================================================
  IRQ istek çağrılarının yönlendirildiği işlev
 ==============================================================================}
procedure IRQ6KesmeIslevi;
begin

  { TODO : IRQ6KesmeIslevi her iki floppy sürücüsüne göre ayarlanacaktır }
  IRQ6Tetiklendi := True;
end;

{==============================================================================
  disket okuma kafasını başlangıç konumuna (0. sektör) getirir (calibrate)
 ==============================================================================}
function Konumlan0(AFizikselSurucu: PFizikselSurucu): Boolean;
var
  _Iz: TSayi1;
begin

  // irq bayrağını pasifleştir
  IRQ6Tetiklendi := False;

  DurumYaz(7);                                      // Konumlan0
  DurumYaz(AFizikselSurucu^.PortBilgisi.Kanal);     // kafa no (0) + sürücü

  // işlemin bitmesini bekle
  Bekle;

  // işlem sonucunu test et (sensei)
  DurumYaz(8);
  DURUM0 := DurumOku;
  _Iz := DurumOku;

  if(DURUM0 = $20) then
  begin

    if(_Iz = 0) then Exit(True);
  end;

  Result := False;
end;

{==============================================================================
  floppy okuma kafasını belirtilen iz'e (track) konumlandırır
 ==============================================================================}
function Konumlan(AFizikselSurucu: PFizikselSurucu; AIz, AKafa: TSayi1): Boolean;
var
  _Iz: TSayi1;
begin

  //if(MevcutIz = AIz) then Exit(True);

  // irq bayrağını pasifleştir
  IRQ6Tetiklendi := False;

  DurumYaz($F);                                                   // Konumlan
  DurumYaz((AKafa shl 2) or AFizikselSurucu^.PortBilgisi.Kanal);  // kafa no + sürücü
  DurumYaz(AIz);

  // işlemin bitmesini bekle
  Bekle;

  // işlem sonucunu test et (sensei)
  DurumYaz(8);
  DURUM0 := DurumOku;
  _Iz := DurumOku;

  if(DURUM0 = $20) then
  begin

    if(_Iz = AIz) then Exit(True);
  end;

  Result := False;
end;

{==============================================================================
  disket sürücü motorunun otomatik kapanmasını sağlayan rutin
 ==============================================================================}
procedure DisketSurucuMotorunuKontrolEt;
begin

  // birinci floppy sürücüsü
  if(PDisket1 <> nil) then
  begin

    // motor çalışma durumları
    // ======================================
    // 0 = motor kapalı
    // 1..4 = motor kapanma durumunda
    // 5 = motor açık

    if(PDisket1^.MotorDurumu > 0) and (PDisket1^.MotorDurumu < 5) then
    begin

      Dec(PDisket1^.MotorDurumu);
      if(PDisket1^.MotorDurumu = 0) then
      begin

        MotorKapat(PDisket1);
      end;
    end;
  end;

  // ikinci floppy sürücüsü
  if(PDisket2 <> nil) then
  begin

    // motor çalışma durumları
    // ======================================
    // 0 = motor kapalı
    // 1..4 = motor kapanma durumunda
    // 5 = motor açık

    if(PDisket2^.MotorDurumu > 0) and (PDisket2^.MotorDurumu < 5) then
    begin

      Dec(PDisket2^.MotorDurumu);
      if(PDisket2^.MotorDurumu = 0) then
      begin

        MotorKapat(PDisket2);
      end;
    end;
  end;
end;

{==============================================================================
  sektör numarasını kafa, iz, sektör biçimine çevirir
 ==============================================================================}
procedure SektoruAyristir(ASektorNo: TSayi2; var AKafa, AIz, ASektor: TSayi1);
var
  i: TSayi2;
begin

  AIz := (ASektorNo div 36);
  i := (ASektorNo mod 36);
  AKafa := (i div 18);
  ASektor := (i mod 18) + 1;
end;

{==============================================================================
  disketten tek bir sektör okuma işlevini gerçekleştirir
 ==============================================================================}
function TekSektorOku(AFizikselSurucu: PFizikselSurucu; ASektorNo: TSayi4): Boolean;
var
  _Kafa, _Iz, _Sektor: TSayi1;
begin

  Result := False;

  // sektör bilgisini kafa, iz, sektor biçimine çevir
  SektoruAyristir(ASektorNo, _Kafa, _Iz, _Sektor);

  // konumlanacağımız iz şu anki iz ise kalibrasyon, konumlanma işlemi yapma
  if(AFizikselSurucu^.SonIzKonumu <> _Iz) then
  begin

    if(_Iz = 0) then
    begin

      // okuma kafasını başlangıç konumuna getir
      if(Konumlan0(AFizikselSurucu) = False) then Exit;
    end
    else
    begin

      // okuma kafasını belirtilen ize konumlandır
      if(Konumlan(AFizikselSurucu, _Iz, _Kafa) = False) then Exit;
    end;
  end;

  // kafanın konumlandığı izi kaydet
  AFizikselSurucu^.SonIzKonumu := _Iz;

  // DMA2'yi aygıttan okuma için ayarla
  DMA2Yukle(DMA_OKU);

  // IRQ bayrağını pasifleştir
  IRQ6Tetiklendi := False;

  // MFS sektör oku
  DurumYaz($E6);
  DurumYaz((_Kafa shl 2) or AFizikselSurucu^.PortBilgisi.Kanal);
  DurumYaz(_Iz);
  DurumYaz(_Kafa);
  DurumYaz(_Sektor);
  DurumYaz(2);             // sektör uzunluğu = 128 * 2^x. (x=2) = 512
  DurumYaz(18);            // bir izdeki sektör sayısı
  DurumYaz(27);            // GAP3 standart değer = 27
  DurumYaz($FF);           // sektör uzunluğu sıfırdan farklı ise 0xff.

  // işlem sonucunu oku
  DURUM0 := DurumOku;       // DURUM0
  DURUM1 := DurumOku;       // DURUM1
  DURUM2 := DurumOku;       // DURUM2
  DurumOku;                 // İz
  DurumOku;                 // Kafa
  DurumOku;                 // Sektör No
  DurumOku;                 // Sektör Uzunluğu

  if((DURUM0 and $C0) = 0) then Exit(True);

  Result := False;
end;

{==============================================================================
  disket sürücü sektör okuma işlevi
 ==============================================================================}
function SektorOku(AFizikselSurucu: Isaretci; AIlkSektor, ASektorSayisi: TSayi4;
  AHedefBellek: Isaretci): Boolean;
var
  _FizikselSurucu: PFizikselSurucu;
  _BellekAdresi: Isaretci;
  _OkumaSonuc: Boolean;
  _OkunacakSektor, _SektorSayisi, i: TSayi4;
begin

  // sürücü bilgisine konumlan
  _FizikselSurucu := AFizikselSurucu;

  // öndeğer dönüş değeri
  Result := True;

  // hedef bellek bölgesi
  _BellekAdresi := AHedefBellek;

  _OkunacakSektor := AIlkSektor;
  _SektorSayisi := ASektorSayisi;

  // motoru aç
  MotorAc(_FizikselSurucu);

  repeat

    for i := 1 to 3 do
    begin

      // belirtilen sektörü oku
      _OkumaSonuc := TekSektorOku(_FizikselSurucu, _OkunacakSektor);
      if(_OkumaSonuc = True) then Break;
    end;

    if(_OkumaSonuc) then
    begin

      // okunan sektör içeriğini hedef bellek bölgesine kopyala
      Tasi2(Pointer(DMA_BELLEKADRESI), _BellekAdresi, 512);

      // bir sonraki bellek bölgesini belirle
      _BellekAdresi := _BellekAdresi + 512;

      // bir sonraki sektörü belirle
      Inc(_OkunacakSektor);

      // sayacı bir azalt
      Dec(_SektorSayisi);
    end
    else
    begin

      // eğer okuma başarı ile gerçekleşmemişse mevcut iz durumunu değiştir
      // not: bu işlem kalibrasyon için yapılmaktadır.
      _FizikselSurucu^.SonIzKonumu := -1;

      // motoru kapatma konumuna getir
      _FizikselSurucu^.MotorDurumu := 4;
      Result := False;
      Exit;
    end;

  until (_SektorSayisi = 0);

  // motoru kapatma konumuna getir
  _FizikselSurucu^.MotorDurumu := 4;
end;

end.
