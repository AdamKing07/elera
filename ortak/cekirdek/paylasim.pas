{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: paylasim.pas
  Dosya İşlevi: tüm birimler için ortak paylaşılan işlevleri içerir

  Güncelleme Tarihi: 03/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit paylasim;

interface

const
  ProjeBaslangicTarihi: string = '30.07.2005';
  {$IFDEF TMODE}
  SistemAdi: PWideChar = 'ELERA Isletim Sistemi - 0.3.4 - R30';
  {$ELSE}
  SistemAdi: PWideChar = 'ELERA İşletim Sistemi - 0.3.4 - R30';
  {$ENDIF}
  DerlemeTarihi: string = {$i %DATE%};
  FPCMimari: string = {$i %FPCTARGET%};
  FPCSurum: string = {$i %FPCVERSION%};

var
  { TODO : öndeğer açılış aygıtı. Otomatikleştirilecek }
  AcilisSurucuAygiti: string = 'disk1';      // disk1:\dizin1
  OnDegerMasaustuProgram: string = 'muyntcs.c';

type
  PProtokolTip = ^TProtokolTip;
  TProtokolTip = (ptBilinmiyor, ptIP, ptARP, ptTCP, ptUDP, ptICMP);

const
  // sistemde çalışacak görev (program) sabitleri
  USTSINIR_GOREVSAYISI = 32;

  // bu değer genel video belleği olacak
  VIDEO_BELLEK_ADRESI = $A0000000;

  // sayfalama sabitleri
  SAYFA_MEVCUT      = 1;
  SAYFA_YAZILABILIR = 2;

  GERCEKBELLEK_DIZINADRESI = $600000;
  GERCEKBELLEK_TABLOADRESI = $610000;

  // seçici (selector) sabitleri
  SECICI_SISTEM_KOD     = 1;      // seçici = selector
  SECICI_SISTEM_VERI    = 2;
  SECICI_SISTEM_TSS     = 3;
  SECICI_DENETIM_KOD    = 4;
  SECICI_DENETIM_VERI   = 5;
  SECICI_DENETIM_TSS    = 6;
  SECICI_SISTEM_GRAFIK  = 7;
  AYRILMIS_SECICISAYISI = 8;      // ayrılmış seçici sayısı

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
  TISayi1 = ISayi1;             // 1 byte'lık işaretli sayı
  PISayi1 = ^ISayi1;            // 1 byte'lık işaretli sayıya işaretçi
  TSayi1 = Sayi1;               // 1 byte'lık işaretsiz sayı
  PSayi1 = ^Sayi1;              // 1 byte'lık işaretsiz sayıya işaretçi
  TISayi2 = ISayi2;             // 2 byte'lık işaretli sayı
  PISayi2 = ^ISayi2;            // 2 byte'lık işaretli sayıya işaretçi
  TSayi2 = Sayi2;               // 2 byte'lık işaretsiz sayı
  PSayi2 = ^Sayi2;              // 2 byte'lık işaretsiz sayıya işaretçi
  TISayi4 = ISayi4;             // 4 byte'lık işaretli sayı
  PISayi4 = ^ISayi4;            // 4 byte'lık işaretli sayıya işaretçi
  TSayi4 = Sayi4;               // 4 byte'lık işaretsiz sayı
  PSayi4 = ^Sayi4;              // 4 byte'lık işaretsiz sayıya işaretçi
  TKarakterKatari = shortstring;
  PKarakterKatari = ^shortstring;
  TRenk = Sayi4;
  PRenk = ^TRenk;
  TTarih = Sayi4;
  TSaat = Sayi4;
  PSaat = ^TSaat;
  TGorevKimlik = TISayi4;

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

const
  SISTEME_AYRILMIS_RAM  = $0A00000;         // çekirdek için ayrılmış RAM = 10MB

  BELLEK_HARITA_ADRESI: PByte = PByte($510000);

  // alttaki satırlar yeni tasarım çerçevesinde onaylanacak veya değiştirilecek
  GOREV0_ESP        = $500000 - $600;
  GOREV0_ESP2       = $500000 - $100;
  GOREV3_ESP        = $500000;
  GOREV3_ESP_U      = $1000;           // 4096 byte
  BILDEN_VERIADRESI = $10008;

type
  TTusDurum = (tdYok, tdBasildi, tdBirakildi);

const
  TUS_KONTROL = Chr($C0);
  TUS_ALT     = Chr($C1);
  TUS_DEGISIM = Chr($C2);

var
  KONTROLTusDurumu: TTusDurum = tdYok;
  ALTTusDurumu    : TTusDurum = tdYok;
  DEGISIMTusDurumu: TTusDurum = tdYok;

const
  // ağ protokolleri
  PROTOKOL_ARP  = TSayi2($0608);
  PROTOKOL_IP   = TSayi2($0008);
  PROTOKOL_TCP  = TSayi1($6);
  PROTOKOL_UDP  = TSayi1($11);
  PROTOKOL_ICMP = TSayi1($1);

const
  ISLEM_BASARILI              = TISayi4(0);
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
  // GN_UZUNLUK değişkeni, görsel nesne yapıları içerisinde en uzun yapılı nesne olan
  // TPencere nesnesinin uzunluğu alınarak;
  // gn_islevler.Yukle işlevi tarafından 16'nın katları olarak belirlenmiştir
  GN_UZUNLUK: TISayi4;

const
  // GN_UZUNLUK uzunluğunda tanımlanacak toplam görsel nesne sayısı
  USTSINIR_GORSELNESNE  = 255;
  USTSINIR_MASAUSTU     = 4;

var
  CekirdekBaslangicAdresi, CekirdekUzunlugu: TSayi4;

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
    Satici: string[13];               // cpu id = 0
    Ozellik1_EAX, Ozellik1_EDX,
    Ozellik1_ECX: TSayi4;             // cpu id = 1
  end;

type
  PPOlayKayit = ^POlayKayit;
  POlayKayit = ^TOlayKayit;
  TOlayKayit = record
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
       [4..7] başlık uzunluğu = başlık uzunluğu * 4 (kaç tane 4 byte olduğu)

 Not2: Toplam Uzunluk: Ip uzunluğu + kendisine eklenen diğer data uzunluğu }
type
  PIPPaket = ^TIPPaket;
  TIPPaket = packed record
    SurumVeBaslikUzunlugu,            // Not1
    ServisTipi: TSayi1;
    ToplamUzunluk,                    // Not2
    Tanimlayici,                      // tanımlayıcı
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
    Uzunluk,                  // UDP başlık + veri uzunluğu
    SaglamaToplam: TSayi2;
    Veri: Isaretci;
  end;

type
  PDNSPaket = ^TDNSPaket;
  TDNSPaket = packed record
  	IslemKimlik,
    Bayrak,
    SorguSayisi,
    YanitSayisi,
    YetkiSayisi,
    DigerSayisi: TSayi2;
    Veriler: Isaretci;
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
    Uzunluk: TSayi2;                // udp veya tcp 'nin data ile beraber uzunluğu
  end;

const
  SURUCUTIP_DISKET  = Byte(1);
  SURUCUTIP_DISK    = Byte(2);

const   // DATTIP = dosya ayırma tablosu (FAT)
  DATTIP_BELIRSIZ   = Byte($0);
  DATTIP_FAT12      = Byte($1);
  DATTIP_FAT16      = Byte($4);
  DATTIP_FAT32      = Byte($B);
  DATTIP_FAT32LBA   = Byte($C);

type
  // 12 & 16 bitlik boot kayıt yapısı
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
    DATBasinaSektor: Word;                    // 22..23   - SADECE FAT12 / FAT16 için
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
    // açılış kodu ve $AA55
  end;

type
  // 32 bitlik boot kayıt yapısı
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
    DAT1xBasinaSektor: Word;                  // 22..23   - SADECE FAT12 / FAT16 için
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
    // açılış kodu ve $AA55
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

// fiziksel sürücü yapısı
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
    SonIzKonumu: TISayi1;           // floppy sürücüsünün kafasının bulunduğu son iz (track) no
    MotorDurumu: TSayi1;            // şu an sadece floppy sürücüsü için
    PortBilgisi: TIDEDisk;
    SektorOku: TSektorOku;
  end;

type
  PDizinGirisi = ^TDizinGirisi;
  TDizinGirisi = record
    IlkSektor: TSayi4;
    ToplamSektor: TSayi4;
    GirdiSayisi: TSayi2;

    // her bir dizin tablosu okunduğunda, o sektörde okunan kaydın sıra numarası
    // 0 = ilk kayıt numarası, 1 = ikinci kayıt, 15 = sektördeki sonuncu kayıt
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
  TDosyaAyirmaTablosu = record         // dosya ayırma tablosu (file allocation table)
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

// mantıksal sürücü yapısı - sistem için
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

// mantıksal sürücü yapısı - program için
type
  PMantiksalSurucu3 = ^TMantiksalSurucu3;
  TMantiksalSurucu3 = packed record
    AygitAdi: string[16];
    SurucuTipi: TSayi1;
    DosyaSistemTipi: TSayi1;
    BolumIlkSektor: TSayi4;
    BolumToplamSektor: TSayi4
  end;

// fiziksel sürücü yapısı - program için
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

// sistem dosya arama yapısı
type
  PDosyaArama = ^TDosyaArama;
  TDosyaArama = record
    DosyaAdi: string;                 // 8.3 dosya adı veya uzun dosya adı
    DosyaUzunlugu: TSayi4;
    Kimlik: TKimlik;                  // arama kimliği
    BaslangicKumeNo: TSayi2;          // geçici
    Ozellikler: TSayi1;
    OlusturmaSaati: TSayi2;
    OlusturmaTarihi: TSayi2;
    SonErisimTarihi: TSayi2;
    SonDegisimSaati: TSayi2;
    SonDegisimTarihi: TSayi2;
  end;

var
  // fiziksel sürücü listesi. en fazla 2 floppy sürücüsü + 4 disk sürücüsü
  FizikselDepolamaAygitSayisi: TSayi4;
  FizikselDepolamaAygitListesi: array[1..6] of TFizikselSurucu;

  // mantıksal sürücü listesi. en fazla 6 depolama sürücüsü
  MantiksalDepolamaAygitSayisi: TISayi4;
  MantiksalDepolamaAygitListesi: array[1..6] of TMantiksalSurucu;

  PDisket1: PFizikselSurucu;
  PDisket2: PFizikselSurucu;

const
  USTSINIR_ARAMAKAYIT = 5;
  USTSINIR_DOSYAKAYIT = 5;

// dosya arama işlevleri için gereken yapı
type
  PAramaKayit = ^TAramaKayit;
  TAramaKayit = record
    Kullanilabilir: Boolean;
    MantiksalSurucu: PMantiksalSurucu;
    DizinGirisi: TDizinGirisi;
    Aranan: string;
  end;

// tüm dosya işlevleri için gereken yapı
type
  PDosyaKayit = ^TDosyaKayit;
  TDosyaKayit = record
    Kullanilabilir: Boolean;
    MantiksalSurucu: PMantiksalSurucu;
    DosyaAdi: string;
    DATBellekAdresi: Isaretci;    // Dosya Ayırma Tablosu bellek adresi
    IlkZincirSektor: Word;
    Uzunluk: TISayi4;
    Konum: TSayi4;
    VeriBellekAdresi: Isaretci;
  end;

var
  FileResult: TISayi4;
  // arama işlem veri yapıları
  AramaKayitListesi: array[1..USTSINIR_ARAMAKAYIT] of TAramaKayit;
  // dosya işlem veri yapıları
  DosyaKayitListesi: array[1..USTSINIR_DOSYAKAYIT] of TDosyaKayit;

var
  CalisanGorevSayisi,                     // oluşturulan / çalışan program sayısı
  CalisanGorev: TISayi4;                    // o an çalışan program
  AktifGorevBellekAdresi: TSayi4;         // o an çalışan programın yüklendiği bellek adresi

type
  PAlan = ^TAlan;
  TAlan = record
  case TISayi4 of
    0: (A1, B1, A2, B2: TISayi4);                       // <- bu yapı ve
    1: (Sol, Ust, Sag, Alt: TISayi4);                   // <- bu yapının mantıksal yaklaşımları aynıdır
    2: (Sol2, Ust2, Genislik2, Yukseklik2: TISayi4);
    3: (Sol3, Ust3, Genislik3, Yukseklik3: TISayi4);    // sağa dayalı değerler (pencere için kullanılan kapatma, büyütme ve küçültme düğmeleri için kullanılmıştır)
  end;

type
  TKesmeCagrisi = function(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

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
  PNokta = ^TNokta;
  TNokta = record
    A1, B1: TISayi4;
  end;

type
  TGorselNesneTipi = (gntMasaustu, gntPencere, gntDugme, gntGucDugme, gntListeKutusu,
    gntMenu, gntDefter, gntIslemGostergesi, gntIsaretKutusu, gntGirisKutusu, gntDegerDugmesi,
    gntEtiket, gntDurumCubugu, gntSecimDugmesi, gntBaglanti, gntResim, gntListeGorunum,
    gntPanel, gntResimDugme, gntKaydirmaCubugu);

const
  ISLEV_OLUSTUR   = $01;
  ISLEV_AL        = $02;
  ISLEV_YAZ       = $04;
  ISLEV_GOSTER    = $08;
  ISLEV_CIZ       = $10;
  ISLEV_GIZLE     = $20;
  ISLEV_YOKET     = $40;

type
  PSecimDurumu = ^TSecimDurumu;
  TSecimDurumu = (sdNormal, sdSecili);
  TDugmeDurumu = (ddNormal, ddBasili);
  TFareImlecTipi = (fitOK, fitGiris, fitEl, fitBoyutKBGD, fitBoyutKG,
    fitIslem, fitBekle, fitYasak, fitBoyutBD, fitBoyutKDGB, fitBoyutTum);

const
  // çekirdeğin ürettiği genel olaylar - çekirdek olay (CO)
  CO_ILKDEGER             = $100;
  CO_CIZIM                = CO_ILKDEGER + 0;
  CO_ZAMANLAYICI          = CO_ILKDEGER + 1;
  CO_OLUSTUR              = CO_ILKDEGER + 2;
  CO_DURUMDEGISTI         = CO_ILKDEGER + 3;
  CO_ODAKKAZANILDI        = CO_ILKDEGER + 4;
  CO_ODAKKAYBEDILDI       = CO_ILKDEGER + 5;
  CO_TUSBASILDI           = CO_ILKDEGER + 6;
  // açık / kapalı durumda olabilen görsel nesnelere (örn: TGucDugme) kapalı ol mesajı
  CO_NORMALDURUMAGEC      = CO_ILKDEGER + 7;

  // fare aygıtının ürettiği olaylar - fare olayları (FO)
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

  RENK_SIYAH		              = TRenk($000000);
  RENK_BORDO		              = TRenk($800000);
  RENK_YESIL		              = TRenk($008000);
  RENK_ZEYTINYESILI		        = TRenk($808000);
  RENK_LACIVERT	              = TRenk($000080);
  RENK_MOR		                = TRenk($800080);
  RENK_TURKUAZ	              = TRenk($008080);
  RENK_GRI		                = TRenk($808080);
  RENK_GUMUS		              = TRenk($C0C0C0);
  RENK_KIRMIZI                = TRenk($FF0000);
  RENK_ACIKYESIL              = TRenk($00FF00);
  RENK_SARI		                = TRenk($FFFF00);
  RENK_MAVI		                = TRenk($0000FF);
  RENK_PEMBE 	                = TRenk($FF00FF);
  RENK_ACIKMAVI		            = TRenk($00FFFF);
  RENK_BEYAZ		              = TRenk($FFFFFF);

type
  PTSS = ^TTSS;
  TTSS = packed record
    OncekiTSS: TSayi2;
    AYRLD00: TSayi2;
    ESP0: TSayi4;
    SS0: TSayi2;
    AYRLD01: TSayi2;
    ESP1: TSayi4;
    SS1: TSayi2;
    AYRLD02: TSayi2;
    ESP2: TSayi4;
    SS2: TSayi2;
    AYRLD03: TSayi2;
    CR3: TSayi4;
    EIP: TSayi4;
    EFLAGS: TSayi4;
    EAX: TSayi4;
    ECX: TSayi4;
    EDX: TSayi4;
    EBX: TSayi4;
    ESP: TSayi4;
    EBP: TSayi4;
    ESI: TSayi4;
    EDI: TSayi4;
    ES: TSayi2;
    AYRLD04: TSayi2;
    CS: TSayi2;
    AYRLD05: TSayi2;
    SS: TSayi2;
    AYRLD06: TSayi2;
    DS: TSayi2;
    AYRLD07: TSayi2;
    FS: TSayi2;
    AYRLD08: TSayi2;
    GS: TSayi2;
    AYRLD09: TSayi2;
    LDT: TSayi2;
    AYRLD10: TSayi2;
    TrapBit: TSayi2;
    IOMap: TSayi2;
  end;    // 104 byte

var
  AgYuklendi: Boolean = False;

  SistemSayaci: TSayi4;
  SistemKontrolSayaci: TSayi4 = 0;
  ZamanlayiciSayaci: TSayi4 = 0;
  // görev değişiminin yapılıp yapılmaması değişkeni.
  // 0 = görev değiştirme, 1 = görev değiştir
  GorevDegisimBayragi: TSayi4 = 0;
  // çoklu görev işleminin başlayıp başlamadığını gösteren değişken
  // 0 = başlamadı, 1 = başladı
  CokluGorevBasladi: TSayi4 = 0;

  GecerliFareGostegeTipi: TFareImlecTipi;

  ToplamGNSayisi, ToplamMasaustu: TSayi4;

var
  GorevTSSListesi: array[1..USTSINIR_GOREVSAYISI] of TTSS;

type
  PIDTYazmac = ^TIDTYazmac;
  TIDTYazmac = packed record
    Uzunluk: TSayi2;
    Baslangic: TSayi4;
  end;

type
  TGorevDurum = (gdBos, gdOlusturuldu, gdCalisiyor, gdDurduruldu);

// program için süreç yapısı
type
  // görev kayıt bilgisi
  PGorevKayit = ^TGorevKayit;
  TGorevKayit = record
    GorevDurum: TGorevDurum;            // görev durumu
    GorevKimlik: TGorevKimlik;          // görev kimlik - sıra numarası
    GorevSayaci: TSayi4;                // görevin kaç kez çalıştığı
    BellekBaslangicAdresi: TSayi4;      // görevin yerleştirildiği bellek adresi
    BellekUzunlugu: TSayi4;             // görev bellek uzunluğu
    OlaySayisi: TSayi4;                 // görev için işlenmeyi bekleyen olay sayısı
    ProgramAdi: string;                 // program ad uzunluğu
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
    Genislik,                   // karakter genişliği
    Yukseklik,                  // karakter yüksekliği
    YT,                         // yatay +/- tolerans değeri
    DT: Byte;                   // dikey +/- tolerans değeri
    Adres: Isaretci;            // karakter resim başlangıç adresi
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
    AYRLD: TSayi1;    // ayrıldı
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
  GenelDNS_IPAdres: TIPAdres = (208, 67, 220, 220);

procedure BellekDoldur(ABellekAdresi: Isaretci; AUzunluk: TSayi4; ADeger: TSayi1);
procedure Tasi2(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4);
function Karsilastir(AKaynak, AHedef: Isaretci; AUzunluk: TSayi4): TSayi4;
function IPKarsilastir(IP1, IP2: TIPAdres): Boolean;
function IPKarsilastir2(AGonderenIP, ABenimIP: TIPAdres): Boolean;
function NoktaAlanIcindeMi(ANokta: TNokta; AAlan: TAlan): Boolean;

implementation

procedure BellekDoldur(ABellekAdresi: Isaretci; AUzunluk: TSayi4; ADeger: TSayi1); assembler;
asm
  pushad
  mov edi,ABellekAdresi
  mov ecx,AUzunluk
  mov al,ADeger
  cld
  rep movsb
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

// 0 = eşit, 1 = eşit değil
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

// ip adresinin ağa bağlı bilgisayar olup olmadığını test eder
// örn: 192.168.1.1 -> 192.168.1.255
function IPKarsilastir2(AGonderenIP, ABenimIP: TIPAdres): Boolean;
var
  i: TISayi4;
begin

  Result := False;

  for i := 0 to 2 do if(AGonderenIP[i] <> ABenimIP[i]) then Exit;

  if(AGonderenIP[3] <> 255) then Exit;

  Result := True;
end;

function NoktaAlanIcindeMi(ANokta: TNokta; AAlan: TAlan): Boolean;
begin

  Result := False;

  if(ANokta.A1 >= AAlan.Sol) and (ANokta.A1 <= AAlan.Sag) and
    (ANokta.B1 >= AAlan.Ust) and (ANokta.B1 <= AAlan.Alt) then

  Result := True;
end;

end.
