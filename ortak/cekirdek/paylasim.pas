{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: paylasim.pas
  Dosya ��levi: t�m birimler i�in ortak payla��lan i�levleri i�erir

  G�ncelleme Tarihi: 11/07/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit paylasim;

interface

const
  ProjeBaslangicTarihi: string = '30.07.2005';
  SistemAdi: string = 'ELERA ��letim Sistemi - 0.3.7 - R33';
  DerlemeTarihi: string = {$i %DATE%};
  FPCMimari: string = {$i %FPCTARGET%};
  FPCSurum: string = {$i %FPCVERSION%};

var
  { TODO : �nde�er a��l�� ayg�t�. Otomatikle�tirilecek }
  AcilisSurucuAygiti: string = 'disk1';      // disk1:\dizin1
  OnDegerMasaustuProgram: string = 'muyntcs.c';

type
  PProtokolTip = ^TProtokolTip;
  TProtokolTip = (ptBilinmiyor, ptIP, ptARP, ptTCP, ptUDP, ptICMP);

  // ba�lant�y� IP'�n tan�mlay�c�s� olan MAC veya yayin (broadcast) olarak ger�ekle�tir
  PBaglantiTipi = ^TBaglantiTipi;
  TBaglantiTipi = (btIP, btYayin);

const
  // sistemde �al��acak g�rev (program) sabitleri
  USTSINIR_GOREVSAYISI = 32;

  // bu de�er genel video belle�i olacak
  VIDEO_BELLEK_ADRESI = $A0000000;

  // sayfalama sabitleri
  SAYFA_MEVCUT      = 1;
  SAYFA_YAZILABILIR = 2;

  GERCEKBELLEK_DIZINADRESI = $600000;
  GERCEKBELLEK_TABLOADRESI = $610000;

  // se�ici (selector) sabitleri
  SECICI_SISTEM_KOD     = 1;      // se�ici = selector
  SECICI_SISTEM_VERI    = 2;
  SECICI_SISTEM_TSS     = 3;
  SECICI_DENETIM_KOD    = 4;
  SECICI_DENETIM_VERI   = 5;
  SECICI_DENETIM_TSS    = 6;
  SECICI_SISTEM_GRAFIK  = 7;
  AYRILMIS_SECICISAYISI = 8;      // ayr�lm�� se�ici say�s�

  // PIC sabitleri
  PIC1_KOMUT  = $20;
  PIC2_KOMUT  = $A0;
  PIC1_VERI   = PIC1_KOMUT + 1;
  PIC2_VERI   = PIC2_KOMUT + 1;

{==============================================================================
  Data Type     Bytes   Range
  Byte	        1       0..255
  ShortInt	    1       -128..127
  Word	        2       0..65535
  SmallInt	    2       -32767..32768
  LongWord	    4       0..4294967295
  LongInt	      4       -2147483648..2147483647
  Cardinal      4       LongWord
  Integer       4       SmallInt veya LongInt
  QWord	        8       0..18446744073709551615
  Int64	        8       -9223372036854775808 .. 9223372036854775807
 ==============================================================================}
type
  Sayi1 = Byte;
  ISayi1 = ShortInt;
  Sayi2 = Word;
  ISayi2 = SmallInt;
  ISayi4 = LongInt;
  Sayi4 = LongWord;
  Isaretci = Pointer;
  TISayi1 = ISayi1;             // 1 byte'l�k i�aretli say�
  PISayi1 = ^ISayi1;            // 1 byte'l�k i�aretli say�ya i�aret�i
  TSayi1 = Sayi1;               // 1 byte'l�k i�aretsiz say�
  PSayi1 = ^Sayi1;              // 1 byte'l�k i�aretsiz say�ya i�aret�i
  TISayi2 = ISayi2;             // 2 byte'l�k i�aretli say�
  PISayi2 = ^ISayi2;            // 2 byte'l�k i�aretli say�ya i�aret�i
  TSayi2 = Sayi2;               // 2 byte'l�k i�aretsiz say�
  PSayi2 = ^Sayi2;              // 2 byte'l�k i�aretsiz say�ya i�aret�i
  TISayi4 = ISayi4;             // 4 byte'l�k i�aretli say�
  PISayi4 = ^ISayi4;            // 4 byte'l�k i�aretli say�ya i�aret�i
  TSayi4 = Sayi4;               // 4 byte'l�k i�aretsiz say�
  PSayi4 = ^Sayi4;              // 4 byte'l�k i�aretsiz say�ya i�aret�i
  TKarakterKatari = shortstring;
  PKarakterKatari = ^shortstring;
  TRenk = Sayi4;
  PRenk = ^TRenk;
  TTarih = Sayi4;
  TSaat = Sayi4;
  PSaat = ^TSaat;

  HResult = ISayi4;
  PChar = ^Char;
  PByte = ^Byte;
  PShortInt = ^ShortInt;
  PWord = ^Word;
  TKimlik = TISayi4;
  PKimlik = ^TKimlik;
  PSmallInt = ^SmallInt;
  PBoolean = ^Boolean;

type
  PHiza = ^THiza;
  THiza = (hzYok, hzUst, hzSag, hzAlt, hzSol, hzTum);
  THizalar = set of THiza;

type
  TYatayHizalar = (yhSol, yhOrta, yhSag);
  TDikeyHizalar = (dhUst, dhOrta, dhAlt);
  TYaziHiza = record
    Yatay: TYatayHizalar;
    Dikey: TDikeyHizalar;
  end;

const
  SISTEME_AYRILMIS_RAM  = $0A00000;         // �ekirdek i�in ayr�lm�� RAM = 10MB

  BELLEK_HARITA_ADRESI: PByte = PByte($510000);

  // alttaki sat�rlar yeni tasar�m �er�evesinde onaylanacak veya de�i�tirilecek
  GOREV0_ESP        = $510000 - $1000;
  GOREV3_ESP        = $570D00;
  GOREV3_ESP_U      = $2000;           // 2048 byte

  BILDEN_VERIADRESI = $10008;

type
  TTusDurum = (tdYok, tdBasildi, tdBirakildi);

const
  TUS_KONTROL = Chr($C0);
  TUS_ALT     = Chr($C1);
  TUS_DEGISIM = Chr($C2);
  TUS_KBT     = Chr($3A);                           // karakter b�y�tme tu�u (capslock)
  TUS_SYT     = Chr($45);                           // say� yazma tu�u (numlock)
  TUS_KT      = Chr($46);                           // kayd�rma tu�u (scrolllock)

var
  KONTROLTusDurumu: TTusDurum = tdYok;
  ALTTusDurumu    : TTusDurum = tdYok;
  DEGISIMTusDurumu: TTusDurum = tdYok;

  KBTDurum        : Boolean = False;                // karakter b�y�tme tu�u (capslock)
  SYTDurum        : Boolean = False;                // say� yazma tu�u (numlock)
  KTDurum         : Boolean = False;                // kayd�rma tu�u (scrolllock)

const
  // a� protokolleri
  PROTOKOL_ARP  = TSayi2($0608);
  PROTOKOL_IP   = TSayi2($0008);
  PROTOKOL_TCP  = TSayi1($6);
  PROTOKOL_UDP  = TSayi1($11);
  PROTOKOL_ICMP = TSayi1($1);

const
  HATA_YOK                    = TISayi4(0);
  HATA_KIMLIK                 = TISayi4(-1);
  HATA_NESNE                  = TISayi4(-2);
  HATA_ATANESNE               = TISayi4(-3);
  HATA_ALTNESNEBELLEKDOLU     = TISayi4(-4);
  HATA_TUMBELLEKKULLANIMDA    = TISayi4(-5);
  HATA_ISLEV                  = TISayi4(-6);
  HATA_DOSYABULUNAMADI        = TISayi4(-7);
  HATA_BOSGOREVYOK            = TISayi4(-8);
  HATA_BOSKIMLIKYOK           = TISayi4(-9);
  HATA_TUMZAMANLAYICILARDOLU  = TISayi4(-10);
  HATA_NESNEGORUNURDEGIL      = TISayi4(-11);
  HATA_BELLEKOKUMA            = TISayi4(-12);
  HATA_GOREVNO                = TISayi4(-13);
  HATA_ELEMANEKLEME           = TISayi4(-14);
  HATA_DEGERARALIKDISI        = TISayi4(-15);
  HATA_KAYNAKLARKULLANIMDA    = TISayi4(-16);
  HATA_BILINMEYENUZANTI       = TISayi4(-17);
  HATA_NESNEOLUSTURMA         = TISayi4(-18);

var
  // GN_UZUNLUK de�i�keni, g�rsel nesne yap�lar� i�erisinde en uzun yap�l� nesne olan
  // TPencere nesnesinin uzunlu�u al�narak;
  // gn_islevler.Yukle i�levi taraf�ndan 16'n�n katlar� olarak belirlenmi�tir
  GN_UZUNLUK: TISayi4;

const
  // GN_UZUNLUK uzunlu�unda tan�mlanacak toplam g�rsel nesne say�s�
  USTSINIR_GORSELNESNE  = 128; //255;
  USTSINIR_MASAUSTU     = 4;

var
  CekirdekBaslangicAdresi, CekirdekUzunlugu: TSayi4;

  // g�revin ana penceresinin ortalanmas�n� sa�lar
  AnaPencereyiOrtala: Boolean = True;

type
  PAygitSurucusu = ^TAygitSurucusu;
  TAygitSurucusu = record
    AygitAdi: string[30];
    Aciklama: string[50];
    Deger1, Deger2, Deger3: TSayi4;
  end;

type
  PYon = ^TYon;
  TYon = (yYatay, yDikey);

type
  PIslemciBilgisi = ^TIslemciBilgisi;
  TIslemciBilgisi = record
    Satici: string;                   // cpu id = 0
    Ozellik1_EAX, Ozellik1_EDX,
    Ozellik1_ECX: TSayi4;             // cpu id = 1
  end;

type
  PPOlay = ^POlay;
  POlay = ^TOlay;
  TOlay = record
    Kimlik: TKimlik;
    Olay, Deger1, Deger2: TISayi4;
  end;

type
  PELFBaslik = ^TELFBaslik;
  TELFBaslik = packed record
    Tanim: array[0..15] of Char;
    Tip: TSayi2;
    Makine: TSayi2;
    Surum: TSayi4;
    KodBaslangicAdresi: TSayi4;
    BaslikTabloBaslangic: TSayi4;
    BolumTabloBaslangic: TSayi4;
    Mimari: TSayi4;
    BuraninBaslikUzunlugu: TSayi4;
    BaslikTabloUzunlugu: TSayi4;
    ProgramBaslikSayisi: TSayi4;
    BaslikTabloGirisUzunlugu: TSayi4;
    BaslikTabloGirisSayisi: TSayi4;
    UstBilgiTabloGirisiSayisi: TSayi4;
   end;

type
  PMACAdres = ^TMACAdres;
  TMACAdres = array[0..5] of TSayi1;
  PIPAdres = ^TIPAdres;
  TIPAdres = array[0..3] of TSayi1;

type
  PEthernetPaket = ^TEthernetPaket;
  TEthernetPaket = packed record
    HedefMACAdres,
    KaynakMACAdres: TMACAdres;
    PaketTip: TSayi2;
    Veri: Isaretci;
  end;

type
  PARPPaket = ^TARPPaket;
  TARPPaket = packed record
    DonanimTip: TSayi2;           // hardware type
    ProtokolTip: TSayi2;          // protocol type
    DonanimAdresU: TSayi1;        // hardware address length
    ProtokolAdresU: TSayi1;       // protocol address length
    Islem: TSayi2;                // operation
    GonderenMACAdres: TMACAdres;  // sender hardware address
    GonderenIPAdres: TIPAdres;    // sender protocol address
    HedefMACAdres: TMACAdres;     // target hardware address
    HedefIPAdres: TIPAdres;       // target protocol address
  end;

{Not1: [0..3] bit = versiyon Ipv4 = 4
       [4..7] ba�l�k uzunlu�u = ba�l�k uzunlu�u * 4 (ka� tane 4 byte oldu�u)

 Not2: Toplam Uzunluk: Ip uzunlu�u + kendisine eklenen di�er data uzunlu�u }
type
  PIPPaket = ^TIPPaket;
  TIPPaket = packed record
    SurumVeBaslikUzunlugu,            // Not1
    ServisTipi: TSayi1;
    ToplamUzunluk,                    // Not2
    Tanimlayici,                      // tan�mlay�c�
    BayrakVeParcaSiraNo: TSayi2;
    YasamSuresi,
    Protokol: TSayi1;
    BaslikSaglamaToplami: TSayi2;
    KaynakIP,
    HedefIP: TIPAdres;
    Veri: Isaretci;
  end;

const
  TCPBASLIK_UZUNLUGU        = 20; //32;
  SOZDE_TCPBASLIK_UZUNLUGU  = 12;

type
  PTCPPaket = ^TTCPPaket;
  TTCPPaket = packed record
    {SrcIpAddr,
    DestIpAddr: TIPAdres;
    Zero: Byte;
    Protocol: Byte;
    Length: Word;               // tcp header + data}

    YerelPort,
    UzakPort: TSayi2;
    SiraNo,                     // sequence number
    OnayNo: TSayi4;
    BaslikU: TSayi1;            // 11111000 = 111111 = Data Offset, 000 = Reserved
    Bayrak: TSayi1;
    Pencere: TSayi2;
    SaglamaToplam,
    AcilIsaretci: TSayi2;       // urgent pointer
    Secenekler: Isaretci;
  end;

type
  PUDPPaket = ^TUDPPaket;
  TUDPPaket = packed record
    KaynakPort,
    HedefPort,
    Uzunluk,                  // UDP ba�l�k + veri uzunlu�u
    SaglamaToplam: TSayi2;
    Veri: Isaretci;
  end;

type
  PDHCPKayit = ^TDHCPKayit;
  TDHCPKayit = packed record
  	Islem, DonanimTip, DonanimUz,
    RelayIcin: TSayi1;
  	GonderenKimlik: TSayi4;
  	Sure, Bayraklar: Word;
  	IstemciIPAdres, BenimIPAdresim, SunucuIPAdres,
    AgGecidiIPAdres: TIPAdres;
  	IstemciMACAdres: TMACAdres;
  	AYRLDI1: TSayi4;
  	AYRLDI2: TSayi4;
  	AYRLDI3: TSayi2;
  	SunucuEvSahibiAdi: array[0..63] of Char;
  	AcilisDosyaAdi: array[0..127] of Char;
  	SihirliCerez: TSayi4;
  	DigerSecenekler: Isaretci;
  end;

type
  PSozdeBaslik = ^TSozdeBaslik;
  TSozdeBaslik = packed record      // pseudoheader
    KaynakIPAdres: TIPAdres;
    HedefIPAdres: TIPAdres;
    Sifir,
    Protokol: TSayi1;
    Uzunluk: TSayi2;                // udp veya tcp 'nin data ile beraber uzunlu�u
  end;

const
  SURUCUTIP_DISKET  = Byte(1);
  SURUCUTIP_DISK    = Byte(2);

const   // DATTIP = dosya ay�rma tablosu (FAT)
  DATTIP_BELIRSIZ   = Byte($0);
  DATTIP_FAT12      = Byte($1);
  DATTIP_FAT16      = Byte($4);
  DATTIP_FAT32      = Byte($B);
  DATTIP_FAT32LBA   = Byte($C);

type
  // 12 & 16 bitlik boot kay�t yap�s�
  PAcilisKayit1x = ^TAcilisKayit1x;
  TAcilisKayit1x = packed record
    AYRLDI1: array[0..2] of Byte;             // 00..02
    OEMAdi: array[0..7] of Char;              // 03..10
    SektorBasinaByte: Word;                   // 11..12
    ZincirBasinaSektor: Byte;                 // 13..13
    AyrilmisSektor1: Word;                    // 14..15
    DATSayisi: Byte;                          // 16..16
    AzamiDizinGirisi: Word;                   // 17..18
    ToplamSektorSayisi1x: Word;               // 19..20
    MedyaTip: Byte;                           // 21..21
    DATBasinaSektor: Word;                    // 22..23   - SADECE FAT12 / FAT16 i�in
    IzBasinaSektor: Word;                     // 24..25
    KafaSayisi: Word;                         // 26..27
    BolumOncesiSektorSayisi: TSayi4;          // 28..31
    ToplamSektorSayisi32: TSayi4;             // 32..35

    AygitNo: Byte;                            // 36..36
    AYRLDI2: Byte;                            // 37..37
    GenisletilmisAcilisImzasi: Byte;          // 38..38
    SeriNo: TSayi4;                           // 39..42
    Etiket: array[0..10] of Char;             // 43..53
    DosyaSistemEtiket: array[0..7] of Char;   // 54..61
    // a��l�� kodu ve $AA55
  end;

type
  // 32 bitlik boot kay�t yap�s�
  PAcilisKayit32 = ^TAcilisKayit32;
  TAcilisKayit32 = packed record
    AYRLDI1: array[0..2] of Byte;             // 00..02
    OEMAdi: array[0..7] of Char;              // 03..10
    SektorBasinaByte: Word;                   // 11..12
    ZincirBasinaSektor: Byte;                 // 13..13
    AyrilmisSektor1: Word;                    // 14..15
    DATSayisi: Byte;                          // 16..16
    AzamiDizinGirisi: Word;                   // 17..18
    ToplamSektorSayisi1x: Word;               // 19..20
    MedyaTip: Byte;                           // 21..21
    DAT1xBasinaSektor: Word;                  // 22..23   - SADECE FAT12 / FAT16 i�in
    IzBasinaSektor: Word;                     // 24..25
    KafaSayisi: Word;                         // 26..27
    BolumOncesiSektorSayisi: TSayi4;          // 28..31
    ToplamSektorSayisi32: TSayi4;             // 32..35

    DATBasinaSektor: TSayi4;                  // 36..39
    Bayraklar: Word;                          // 40..41
    DATSurum: Word;                           // 42..43
    DizinGirisindekiZincirSayisi: TSayi4;     // 44..47
    DosyaSistemSektorNoBilgi: Word;           // 48..49
    AcilisSektorNo: Word;                     // 50..51
    AyrilmisSektor2: array[0..11] of Byte;    // 52..63
    AygitNo: Byte;                            // 64..64
    Bayraklar2: Byte;                         // 65..65
    Imza: Byte;                               // 66..66
    EtiketKimlik: array[0..3] of Char;        // 67..70
    Etiket: array[0..10] of Char;             // 71..81
    DosyaSistemEtiket: array[0..7] of Char;   // 82..89
    // a��l�� kodu ve $AA55
  end;

type
  PDiskBolum = ^TDiskBolum;
  TDiskBolum = packed record
    Ozellikler: Byte;                             // bit 7 = aktif veya boot edebilir
    CHSIlkSektor: array[0..2] of Byte;
    BolumTipi: Byte;
    CHSSonSektor: array[0..2] of Byte;
    LBAIlkSektor,
    BolumSektorSayisi: TSayi4;
  end;

type
  PGoruntuYapi = ^TGoruntuYapi;
  TGoruntuYapi = record
    Genislik, Yukseklik: TISayi4;
    BellekAdresi: Isaretci;
  end;

type
  PIDEDisk = ^TIDEDisk;
  TIDEDisk = record
    PortNo: TSayi2;
    Kanal: TSayi1;
  end;

type
  TSektorOku = function(AFizikselSurucu: Isaretci; AIlkSektor, ASektorSayisi: TSayi4;
    AHedefBellek: Isaretci): Boolean;

// fiziksel s�r�c� yap�s�
type
  PFizikselSurucu = ^TFizikselSurucu;
  TFizikselSurucu = record
    Mevcut: Boolean;
    Kimlik: TKimlik;
    AygitAdi: string[16];
    KafaSayisi: TSayi2;
    SilindirSayisi: TSayi2;
    IzBasinaSektorSayisi: TSayi2;
    ToplamSektorSayisi: TSayi4;
    SurucuTipi: TSayi1;
    Ozellikler: TSayi1;
    SonIzKonumu: TISayi1;           // floppy s�r�c�s�n�n kafas�n�n bulundu�u son iz (track) no
    MotorDurumu: TSayi1;            // �u an sadece floppy s�r�c�s� i�in
    PortBilgisi: TIDEDisk;
    SektorOku: TSektorOku;
  end;

type
  PDizinGirisi = ^TDizinGirisi;
  TDizinGirisi = record
    IlkSektor: TSayi4;
    ToplamSektor: TSayi4;
    GirdiSayisi: TSayi2;

    // her bir dizin tablosu okundu�unda, o sekt�rde okunan kayd�n s�ra numaras�
    // 0 = ilk kay�t numaras�, 1 = ikinci kay�t, 15 = sekt�rdeki sonuncu kay�t
    DizinTablosuKayitNo: TISayi4;
  end;

type
  PDizinGirdisi = ^TDizinGirdisi;
  TDizinGirdisi = packed record
    DosyaAdi: array[0..7] of Char;
    Uzanti: array[0..2] of Char;
    Ozellikler: TSayi1;
    Kullanilmiyor1: TSayi2;
    OlusturmaSaati: TSayi2;
    OlusturmaTarihi: TSayi2;
    SonErisimTarihi: TSayi2;
    Kullanilmiyor2: TSayi2;
    SonDegisimSaati: TSayi2;
    SonDegisimTarihi: TSayi2;
    BaslangicKumeNo: TSayi2;
    DosyaUzunlugu: TSayi4;
  end;

type
  PDosyaAyirmaTablosu = ^TDosyaAyirmaTablosu;
  TDosyaAyirmaTablosu = record         // dosya ay�rma tablosu (file allocation table)
    IlkSektor: TSayi2;
    ToplamSektor: TSayi2;
    KumeBasinaSektor: TSayi1;
    IlkVeriSektoru: TSayi4;
  end;

type
  PAcilis = ^TAcilis;     // acilis = boot
  TAcilis = record
    DizinGirisi: TDizinGirisi;
    DosyaAyirmaTablosu: TDosyaAyirmaTablosu;
  end;

// mant�ksal s�r�c� yap�s� - sistem i�in
type
  PMantiksalSurucu = ^TMantiksalSurucu;
  TMantiksalSurucu = packed record
    AygitMevcut: Boolean;
    FizikselSurucu: PFizikselSurucu;
    AygitAdi: string[16];
    BolumIlkSektor: TSayi4;
    BolumToplamSektor: TSayi4;
    BolumTipi: TSayi1;
    Acilis: TAcilis;
  end;

// mant�ksal s�r�c� yap�s� - program i�in
type
  PMantiksalSurucu3 = ^TMantiksalSurucu3;
  TMantiksalSurucu3 = packed record
    AygitAdi: string[16];
    SurucuTipi: TSayi1;
    DosyaSistemTipi: TSayi1;
    BolumIlkSektor: TSayi4;
    BolumToplamSektor: TSayi4
  end;

// fiziksel s�r�c� yap�s� - program i�in
type
  PFizikselSurucu3 = ^TFizikselSurucu3;
  TFizikselSurucu3 = packed record
    AygitAdi: string[16];
    SurucuTipi: TSayi1;
    KafaSayisi: TSayi2;
    SilindirSayisi: TSayi2;
    IzBasinaSektorSayisi: TSayi2;
    ToplamSektorSayisi: TSayi4;
  end;

// sistem dosya arama yap�s�
type
  PDosyaArama = ^TDosyaArama;
  TDosyaArama = record
    DosyaAdi: string;                 // 8.3 dosya ad� veya uzun dosya ad�
    DosyaUzunlugu: TSayi4;
    Kimlik: TKimlik;                  // arama kimli�i
    BaslangicKumeNo: TSayi2;          // ge�ici
    Ozellikler: TSayi1;
    OlusturmaSaati: TSayi2;
    OlusturmaTarihi: TSayi2;
    SonErisimTarihi: TSayi2;
    SonDegisimSaati: TSayi2;
    SonDegisimTarihi: TSayi2;
  end;

var
  // fiziksel s�r�c� listesi. en fazla 2 floppy s�r�c�s� + 4 disk s�r�c�s�
  FizikselDepolamaAygitSayisi: TSayi4;
  FizikselDepolamaAygitListesi: array[1..6] of TFizikselSurucu;

  // mant�ksal s�r�c� listesi. en fazla 6 depolama s�r�c�s�
  MantiksalDepolamaAygitSayisi: TISayi4;
  MantiksalDepolamaAygitListesi: array[1..6] of TMantiksalSurucu;

  PDisket1: PFizikselSurucu;
  PDisket2: PFizikselSurucu;

const
  USTSINIR_ARAMAKAYIT = 5;
  USTSINIR_DOSYAKAYIT = 5;

// dosya arama i�levleri i�in gereken yap�
type
  PAramaKayit = ^TAramaKayit;
  TAramaKayit = record
    Kullanilabilir: Boolean;
    MantiksalSurucu: PMantiksalSurucu;
    DizinGirisi: TDizinGirisi;
    Aranan: string;
  end;

// t�m dosya i�levleri i�in gereken yap�
type
  PDosyaKayit = ^TDosyaKayit;
  TDosyaKayit = record
    Kullanilabilir: Boolean;
    MantiksalSurucu: PMantiksalSurucu;
    DosyaAdi: string;
    DATBellekAdresi: Isaretci;    // Dosya Ay�rma Tablosu bellek adresi
    IlkZincirSektor: Word;
    Uzunluk: TISayi4;
    Konum: TSayi4;
    VeriBellekAdresi: Isaretci;
  end;

var
  FileResult: TISayi4;
  // arama i�lem veri yap�lar�
  AramaKayitListesi: array[1..USTSINIR_ARAMAKAYIT] of TAramaKayit;
  // dosya i�lem veri yap�lar�
  DosyaKayitListesi: array[1..USTSINIR_DOSYAKAYIT] of TDosyaKayit;

var
  CalisanGorevSayisi,                     // olu�turulan / �al��an program say�s�
  CalisanGorev: TISayi4;                  // o an �al��an program
  CalisanGorevBellekAdresi: TSayi4;       // o an �al��an program�n y�klendi�i bellek adresi
  GorevDegisimSayisi: TSayi4 = 0;         // �ekirdek ba�lad��� andan itibaren ger�ekle�tirilen g�rev de�i�im say�s�

type
  PAlan = ^TAlan;
  TAlan = record
    Sol, Ust, Sag, Alt: TISayi4;
  end;

type
  TKesmeCagrisi = function(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

type
  PCizgiTipi = ^TCizgiTipi;
  TCizgiTipi = (ctDuz, ctNokta);

type
  PEkranKartBilgisi = ^TEkranKartBilgisi;
  TEkranKartBilgisi = record
    BellekUzunlugu: TSayi2;
    EkranMod: TSayi2;
    YatayCozunurluk, DikeyCozunurluk: TISayi4;
    BellekAdresi: TSayi4;
    PixelBasinaBitSayisi: TSayi1;
    NoktaBasinaByteSayisi: TSayi1;
    SatirdakiByteSayisi: TSayi2;
  end;

type
  TIRQIslevi = procedure;

type
  PKonum = ^TKonum;
  TKonum = record
    Sol, Ust: TISayi4;
  end;

type
  PBoyut = ^TBoyut;
  TBoyut = record
    Genislik, Yukseklik: TISayi4;
  end;

type
  // g�rsel nesnelerin kullan�m tipleri
  // ktTuvalNesne = kendisine ait �izim alan� mevcuttur
  // ktNesne      = tuval nesnenin alt�ndaki nesnedir
  // ktBilesen    = nesnenin alt nesnesi olan ktNesne �zelli�indeki nesnedir
  TKullanimTipi = (ktTuvalNesne, ktNesne, ktBilesen);

type { G�rsel Nesne Tipi }
  TGNTip = (gntTanimsiz, gntMasaustu, gntPencere, gntDugme, gntGucDugmesi, gntListeKutusu,
    gntMenu, gntDefter, gntIslemGostergesi, gntOnayKutusu, gntGirisKutusu, gntDegerDugmesi,
    gntEtiket, gntDurumCubugu, gntSecimDugmesi, gntBaglanti, gntResim, gntListeGorunum,
    gntPanel, gntResimDugmesi, gntKaydirmaCubugu, gntKarmaListe, gntAcilirMenu,
    gntDegerListesi, gntIzgara, gntAracCubugu, gntRenkSecici, gntSayfaKontrol);

type
  THamResim = record
    Genislik, Yukseklik: TSayi4;
    BellekAdresi: Isaretci;
  end;

const
  ISLEV_OLUSTUR     = $0001;
  ISLEV_GOSTER      = $0002;
  ISLEV_GIZLE       = $0003;
  ISLEV_CIZ         = $0004;
  ISLEV_BOYUTLANDIR = $0005;
  ISLEV_YOKET       = $0006;
  ISLEV_AL          = $1000;
  ISLEV_YAZ         = $2000;

type
  PSecimDurumu = ^TSecimDurumu;
  TSecimDurumu = (sdNormal, sdSecili);
  TDugmeDurumu = (ddNormal, ddBasili);
  TFareImlecTipi = (fitOK, fitGiris, fitEl, fitBoyutKBGD, fitBoyutKG,
    fitIslem, fitBekle, fitYasak, fitBoyutBD, fitBoyutKDGB, fitBoyutTum);

const
  // �ekirde�in �retti�i genel olaylar - �ekirdek olay (CO)
  CO_ILKDEGER             = $100;
  CO_CIZIM                = CO_ILKDEGER + 0;
  CO_ZAMANLAYICI          = CO_ILKDEGER + 1;
  CO_OLUSTUR              = CO_ILKDEGER + 2;
  CO_DURUMDEGISTI         = CO_ILKDEGER + 3;
  CO_ODAKKAZANILDI        = CO_ILKDEGER + 4;
  CO_ODAKKAYBEDILDI       = CO_ILKDEGER + 5;
  CO_TUSBASILDI           = CO_ILKDEGER + 6;
  CO_MENUACILDI           = CO_ILKDEGER + 7;        // men�n�n a��lmas�
  CO_MENUKAPATILDI        = CO_ILKDEGER + 8;        // men�n�n kapat�lmas�
  CO_SECIMDEGISTI         = CO_ILKDEGER + 9;        // karma liste nesnesinde se�imin de�i�mesi olay�

  // fare ayg�t�n�n �retti�i olaylar - fare olaylar� (FO)
  FO_ILKDEGER             = $200;
  FO_BILINMIYOR           = FO_ILKDEGER;
  FO_SOLTUS_BASILDI       = FO_ILKDEGER + 2;
  FO_SOLTUS_BIRAKILDI     = FO_ILKDEGER + 2 + 1;
  FO_SAGTUS_BASILDI       = FO_ILKDEGER + 4;
  FO_SAGTUS_BIRAKILDI     = FO_ILKDEGER + 4 + 1;
  FO_ORTATUS_BASILDI      = FO_ILKDEGER + 6;
  FO_ORTATUS_BIRAKILDI    = FO_ILKDEGER + 6 + 1;
  FO_4NCUTUS_BASILDI      = FO_ILKDEGER + 8;
  FO_4NCUTUS_BIRAKILDI    = FO_ILKDEGER + 8 + 1;
  FO_5NCITUS_BASILDI      = FO_ILKDEGER + 10;
  FO_5NCITUS_BIRAKILDI    = FO_ILKDEGER + 10 + 1;
  FO_HAREKET              = FO_ILKDEGER + 122;
  FO_TIKLAMA              = FO_ILKDEGER + 124;
  //FO_CIFTTIKLAMA        = FO_ILKDEGER + 126;
  FO_KAYDIRMA             = FO_ILKDEGER + 128;

  RENK_BEYAZ		              = TRenk($FFFFFF);
  RENK_GUMUS		              = TRenk($C0C0C0);
  RENK_GRI		                = TRenk($808080);
  RENK_SIYAH		              = TRenk($000000);
  RENK_KIRMIZI                = TRenk($FF0000);
  RENK_BORDO		              = TRenk($800000);
  RENK_SARI		                = TRenk($FFFF00);
  RENK_ZEYTINYESILI		        = TRenk($808000);
  RENK_ACIKYESIL              = TRenk($00FF00);
  RENK_YESIL		              = TRenk($008000);
  RENK_ACIKMAVI		            = TRenk($00FFFF);
  RENK_TURKUAZ	              = TRenk($008080);
  RENK_MAVI		                = TRenk($0000FF);
  RENK_LACIVERT	              = TRenk($000080);
  RENK_PEMBE 	                = TRenk($FF00FF);
  RENK_MOR		                = TRenk($800080);

const
  // g�rev �ubu�u i� dolgu rengi
  GOREVCUBUGU_ILKRENK       = $B9C9F9;
  GOREVCUBUGU_SONRENK       = $A1B7F7;

  // d��me dolgu renkleri
  DUGME_NORMAL_ILKRENK      = GOREVCUBUGU_ILKRENK;
  DUGME_NORMAL_SONRENK      = GOREVCUBUGU_SONRENK;
  DUGME_NORMAL_YAZIRENK     = RENK_SIYAH;

  DUGME_BASILI_ILKRENK      = $609FCC;
  DUGME_BASILI_SONRENK      = $2C6187;
  DUGME_BASILI_YAZIRENK     = RENK_BEYAZ;

type
  TGiysiResim = record
    Genislik, Yukseklik: TSayi4;
    BellekAdresi: Isaretci;
  end;

type
  TGiysi = record
    BaslikYukseklik,

    ResimSolUstGenislik,
    ResimUstGenislik,
    ResimSagUstGenislik,

    ResimSolGenislik,
    ResimSolYukseklik,
    ResimSagGenislik,
    ResimSagYukseklik,

    ResimSolAltGenislik,
    ResimSolAltYukseklik,
    ResimAltGenislik,
    ResimAltYukseklik,
    ResimSagAltGenislik,
    ResimSagAltYukseklik,

    AktifBaslikYaziRengi,
    PasifBaslikYaziRengi,
    IcDolguRengi,
    BaslikYaziSol,
    BaslikYaziUst,

    KapatmaDugmesiSol,
    KapatmaDugmesiUst,
    KapatmaDugmesiGenislik,
    KapatmaDugmesiYukseklik,
    BuyutmeDugmesiSol,
    BuyutmeDugmesiUst,
    BuyutmeDugmesiGenislik,
    BuyutmeDugmesiYukseklik,
    KucultmeDugmesiSol,
    KucultmeDugmesiUst,
    KucultmeDugmesiGenislik,
    KucultmeDugmesiYukseklik: TSayi4;

    ResimSolUstA, ResimSolUstP,
    ResimUstA, ResimUstP,
    ResimSagUstA, ResimSagUstP,
    ResimSolA, ResimSolP,
    ResimSagA, ResimSagP,
    ResimSolAltA, ResimSolAltP,
    ResimAltA, ResimAltP,
    ResimSagAltA, ResimSagAltP: TGiysiResim;
  end;

var
  AktifGiysi: TGiysi;

type
  PTSS = ^TTSS;
  TTSS = packed record
    OncekiTSS, A00: TSayi2;     // A(00)yr�ld�
    ESP0: TSayi4;
    SS0, A01: TSayi2;
    ESP1: TSayi4;
    SS1, A02: TSayi2;
    ESP2: TSayi4;
    SS2, A03: TSayi2;
    CR3, EIP, EFLAGS: TSayi4;
    EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI: TSayi4;
    ES, A04: TSayi2;
    CS, A05: TSayi2;
    SS, A06: TSayi2;
    DS, A07: TSayi2;
    FS, A08: TSayi2;
    GS, A09: TSayi2;
    LDT, A10: TSayi2;
    TBit: TSayi2;               // yakalay�c� (trap) bit. hata ay�klama ama�l�
    IOHaritaGAdres: TSayi2;     // IOHarita yap� ba��ndan uzakl�k bellek adresi
    // buraya kadar 104 byte.

    IOHarita: Isaretci;
    // IO port izin haritas� kulan�lacaksa her bir g�rev i�in
    // 65536 / 8 = 8192 byte alan gerekmektedir
  end;

var
  AgYuklendi: Boolean = False;

  SistemSayaci: TSayi4;
  SistemKontrolSayaci: TSayi4 = 0;
  ZamanlayiciSayaci: TSayi4 = 0;
  // g�rev de�i�iminin yap�l�p yap�lmamas� de�i�keni.
  // 0 = g�rev de�i�tirme, 1 = g�rev de�i�tir
  GorevDegisimBayragi: TSayi4 = 0;
  // �oklu g�rev i�leminin ba�lay�p ba�lamad���n� g�steren de�i�ken
  // 0 = ba�lamad�, 1 = ba�lad�
  CokluGorevBasladi: TSayi4 = 0;

  GecerliFareGostegeTipi: TFareImlecTipi;

  ToplamGNSayisi, ToplamMasaustu: TSayi4;

const
  TSS_UZUNLUK = 104 + 8192;   // 104 byte TSS, 8192 byte giri� / ��k�� port izin haritas�

var
  GorevTSSListesi: array[1..USTSINIR_GOREVSAYISI] of PTSS;

type
  PIDTYazmac = ^TIDTYazmac;
  TIDTYazmac = packed record
    Uzunluk: TSayi2;
    Baslangic: TSayi4;
  end;

type
  TGorevDurum = (gdBos, gdOlusturuldu, gdCalisiyor, gdDurduruldu);

type
  PPencereTipi = ^TPencereTipi;
  TPencereTipi = (ptBasliksiz, ptIletisim, ptBoyutlanabilir);

  PPencereDurum = ^TPencereDurum;
  TPencereDurum = (pdNormal, pdKucultuldu, pdBuyutuldu);

type
  // program i�in (API) g�rev yap�s�
  PGorevKayit = ^TGorevKayit;
  TGorevKayit = record
    GorevDurum: TGorevDurum;            // g�rev durumu
    GorevKimlik: TKimlik;               // g�rev kimli�i - s�ra numaras�
    GorevSayaci: TSayi4;                // g�revin ka� kez �al��t���
    BellekBaslangicAdresi: TSayi4;      // g�revin yerle�tirildi�i bellek adresi
    BellekUzunlugu: TSayi4;             // g�rev bellek uzunlu�u
    OlaySayisi: TSayi4;                 // g�rev i�in i�lenmeyi bekleyen olay say�s�
    DosyaAdi: string;                   // program�n y�klendi�i dosya ad�
  end;

type
  // program i�in (API) program yap�s�
  PProgramKayit = ^TProgramKayit;
  TProgramKayit = record
    PencereKimlik: TKimlik;             // pencere kimli�i
    GorevKimlik: TKimlik;               // g�rev kimli�i
    PencereTipi: TPencereTipi;          // pencere tipi
    PencereDurum: TPencereDurum;        // pencere durumu
    DosyaAdi: string;                   // program�n y�klendi�i dosya ad�
  end;

type
  PSistemBilgisi = ^TSistemBilgisi;
  TSistemBilgisi = record
    SistemAdi, DerlemeBilgisi,
    FPCMimari, FPCSurum: string;
    YatayCozunurluk, DikeyCozunurluk: TSayi4;
  end;

type
  PKarakter = ^TKarakter;
  TKarakter = record
    Genislik,                   // karakter geni�li�i
    Yukseklik,                  // karakter y�ksekli�i
    YT,                         // yatay +/- tolerans de�eri
    DT: TISayi1;                // dikey +/- tolerans de�eri
    Adres: Isaretci;            // karakter resim ba�lang�� adresi
  end;

type
  PPCI = ^TPCI;
  TPCI = packed record
    Yol, Aygit,
    Islev, AYRLD0: TSayi1;
    SaticiKimlik, AygitKimlik: TSayi2;
    SinifKod: TSayi4;
  end;

type
  PRGB = ^TRGBRenk;
  TRGBRenk = packed record
    B: TSayi1;
    G: TSayi1;
    R: TSayi1;
    AYRLD: TSayi1;    // ayr�ld�
  end;

type
  PAgBilgisi = ^TAgBilgisi;
  TAgBilgisi = record
    MACAdres: TMACAdres;
    IP4Adres, AltAgMaskesi, AgGecitAdresi,
    DHCPSunucusu, DNSSunucusu: TIPAdres;
    IPKiraSuresi: TSayi4;
  end;

var
  AgBilgisi: TAgBilgisi;

  MakineAdi: string = 'elera-bil';
  IPAdres0: TIPAdres = (0, 0, 0, 0);
  IPAdres255: TIPAdres = (255, 255, 255, 255);
  MACAdres0: TMACAdres = (0, 0, 0, 0, 0, 0);
  MACAdres255: TMACAdres = (255, 255, 255, 255, 255, 255);
  //GenelDNS_IPAdres1: TIPAdres = (208, 67, 220, 220);

procedure BellekDoldur(ABellekAdresi: Isaretci; AUzunluk: TSayi4; ADeger: TSayi1);
procedure Tasi2(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4);
function Karsilastir(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4): TSayi4;
function IPKarsilastir(IP1, IP2: TIPAdres): Boolean;
function IPKarsilastir2(AGonderenIP, ABenimIP: TIPAdres): Boolean;
function NoktaAlanIcindeMi(ANokta: TKonum; AAlan: TAlan): Boolean;

implementation

procedure BellekDoldur(ABellekAdresi: Isaretci; AUzunluk: TSayi4; ADeger: TSayi1); assembler;
asm
  pushad
  mov edi,ABellekAdresi
  mov ecx,AUzunluk
  mov al,ADeger
  cld
  rep stosb
  popad
end;

procedure Tasi2(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4); assembler;
asm
  pushad
  mov esi,AKaynak
  mov edi,AHedef
  mov ecx,AUzunluk
  cld
  rep movsb
  popad
end;

// 0 = e�it, 1 = e�it de�il
function Karsilastir(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4): TSayi4;
var
  Sonuc: TSayi4;
begin
asm
  pushfd
  pushad

  mov esi,AKaynak
  mov edi,AHedef
  mov ecx,AUzunluk
  cld
  repe cmpsb

  popad
  mov Sonuc,0

  je  @@exit

  mov Sonuc,1
@@exit:

  popfd
end;

  Result := Sonuc;
end;

function IPKarsilastir(IP1, IP2: TIPAdres): Boolean;
var
  i: TISayi4;
begin

  Result := False;

  for i := 0 to 3 do if(IP1[i] <> IP2[i]) then Exit;

  Result := True;
end;

// ip adresinin a�a ba�l� bilgisayar olup olmad���n� test eder
// �rn: 192.168.1.1 -> 192.168.1.255
function IPKarsilastir2(AGonderenIP, ABenimIP: TIPAdres): Boolean;
var
  i: TISayi4;
begin

  Result := False;

  for i := 0 to 2 do if(AGonderenIP[i] <> ABenimIP[i]) then Exit;

  if(AGonderenIP[3] <> 255) then Exit;

  Result := True;
end;

function NoktaAlanIcindeMi(ANokta: TKonum; AAlan: TAlan): Boolean;
begin

  Result := False;

  if(ANokta.Sol >= AAlan.Sol) and (ANokta.Sol <= AAlan.Sag) and
    (ANokta.Ust >= AAlan.Ust) and (ANokta.Ust <= AAlan.Alt) then

  Result := True;
end;

end.
