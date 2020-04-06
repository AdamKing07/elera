program pcibil;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: pcibil.lpr
  Program Ýþlevi: pci aygýtlarý hakkýnda bilgi verir

  Güncelleme Tarihi: 26/10/2019

 ==============================================================================}
{$mode objfpc}
uses gorev, gn_pencere, gn_dugme, gn_degerdugmesi;

const
  ProgramAdi: string = 'PCI Aygýt Bilgileri';

type
  TPCISinif = record
    SinifKod: TSayi4;
    SinifAdi: string;
  end;

var
  PCISinifListesi: array[0..139] of TPCISinif = (
    (SinifKod: $000000; SinifAdi: 'Old No-VGA combatible device'),
    (SinifKod: $000100; SinifAdi: 'Old VGA combatible device'),
    (SinifKod: $010000; SinifAdi: 'SCSI bus controller'),
    (SinifKod: $01018a; SinifAdi: 'IDE controller'),
    (SinifKod: $010185; SinifAdi: 'IDE Mass Storage'),
    (SinifKod: $010200; SinifAdi: 'Floppy disk controller'),
    (SinifKod: $010300; SinifAdi: 'IPI bus controller'),
    (SinifKod: $010400; SinifAdi: 'RAID controller'),
    (SinifKod: $010520; SinifAdi: 'ATA controller with single DMA'),
    (SinifKod: $010530; SinifAdi: 'ATA controller with chained DMA'),
    (SinifKod: $010600; SinifAdi: 'Serial ATA Direct Port Access (DPA)'),
    (SinifKod: $010601; SinifAdi: 'SATA Mass Storage'),
    (SinifKod: $018000; SinifAdi: 'Other mass storage controller'),
    (SinifKod: $020000; SinifAdi: 'Ethernet controller'),
    (SinifKod: $020100; SinifAdi: 'Token Ring controller'),
    (SinifKod: $020200; SinifAdi: 'FDDI controller'),
    (SinifKod: $020300; SinifAdi: 'ATM controller'),
    (SinifKod: $020400; SinifAdi: 'ISDN controller'),
    (SinifKod: $020500; SinifAdi: 'WorldFip controller'),
    (SinifKod: $020600; SinifAdi: 'PICMG 2.14 Multi Computing'),
    (SinifKod: $028000; SinifAdi: 'Other network controller'),
    (SinifKod: $030000; SinifAdi: 'VGA-compatible controller'),
    (SinifKod: $030001; SinifAdi: '8514-compatible controller'),
    (SinifKod: $030100; SinifAdi: 'XGA controller'),
    (SinifKod: $030200; SinifAdi: '3D controller'),
    (SinifKod: $038000; SinifAdi: 'Other display controller'),
    (SinifKod: $040000; SinifAdi: 'Video device'),
    (SinifKod: $040100; SinifAdi: 'Audio device'),
    (SinifKod: $040200; SinifAdi: 'Computer telephony device'),
    (SinifKod: $040300; SinifAdi: 'Multimedia'),
    (SinifKod: $048000; SinifAdi: 'Other multimedia device'),
    (SinifKod: $050000; SinifAdi: 'RAM'),
    (SinifKod: $050100; SinifAdi: 'Flash'),
    (SinifKod: $058000; SinifAdi: 'Other memory controller'),
    (SinifKod: $060000; SinifAdi: 'Host bridge'),
    (SinifKod: $060100; SinifAdi: 'ISA bridge'),
    (SinifKod: $060200; SinifAdi: 'EISA bridge'),
    (SinifKod: $060300; SinifAdi: 'MCA bridge'),
    (SinifKod: $060400; SinifAdi: 'PCI-to-PCI bridge'),
    (SinifKod: $060401; SinifAdi: 'Subtractive Decode PCI-to-PCI bridge'),
    (SinifKod: $060500; SinifAdi: 'PCMCIA bridge'),
    (SinifKod: $060600; SinifAdi: 'NuBus bridge'),
    (SinifKod: $060700; SinifAdi: 'CardBus bridge'),
    (SinifKod: $060800; SinifAdi: 'RACEway bridge'),
    (SinifKod: $060940; SinifAdi: 'Semi-transparent PCI-to-PCI bridge (pri)'),
    (SinifKod: $060980; SinifAdi: 'Semi-transparent PCI-to-PCI bridge (sec)'),
    (SinifKod: $060a00; SinifAdi: 'InfiniBand-to-PCI host bridge'),
    (SinifKod: $068000; SinifAdi: 'Other bridge device'),
    (SinifKod: $070000; SinifAdi: 'Generic XT-compatible serial controller'),
    (SinifKod: $070001; SinifAdi: '16450-compatible serial controller'),
    (SinifKod: $070002; SinifAdi: '16550-compatible serial controller'),
    (SinifKod: $070003; SinifAdi: '16650-compatible serial controller'),
    (SinifKod: $070004; SinifAdi: '16750-compatible serial controller'),
    (SinifKod: $070005; SinifAdi: '16850-compatible serial controller'),
    (SinifKod: $070006; SinifAdi: '16950-compatible serial controller'),
    (SinifKod: $070100; SinifAdi: 'Parallel port'),
    (SinifKod: $070101; SinifAdi: 'Bidirectional parallel port'),
    (SinifKod: $070102; SinifAdi: 'ECP 1.X compliant parallel port'),
    (SinifKod: $070103; SinifAdi: 'IEEE1284 controller'),
    (SinifKod: $0701fe; SinifAdi: 'IEEE1284 target device (not a controller)'),
    (SinifKod: $070200; SinifAdi: 'Multiport serial controller'),
    (SinifKod: $070300; SinifAdi: 'Generic modem'),
    (SinifKod: $070301; SinifAdi: 'Hayes compatible modem (16450)'),
    (SinifKod: $070302; SinifAdi: 'GPIB (IEEE 488.1/2) controller'),
    (SinifKod: $070303; SinifAdi: 'Smart Card'),
    (SinifKod: $070304; SinifAdi: 'Hayes compatible modem (16550)'),
    (SinifKod: $070400; SinifAdi: 'Hayes compatible modem (16650)'),
    (SinifKod: $070500; SinifAdi: 'Hayes compatible modem (16750)'),
    (SinifKod: $078000; SinifAdi: 'Other communications device'),
    (SinifKod: $080000; SinifAdi: 'Generic 8259 PIC'),
    (SinifKod: $080001; SinifAdi: 'ISA PIC'),
    (SinifKod: $080002; SinifAdi: 'EISA PIC'),
    (SinifKod: $080010; SinifAdi: 'I/O APIC interrupt controller'),
    (SinifKod: $080020; SinifAdi: 'I/O(x) APIC interrupt controller'),
    (SinifKod: $080100; SinifAdi: 'Generic 8237 DMA controller'),
    (SinifKod: $080101; SinifAdi: 'ISA DMA controller'),
    (SinifKod: $080102; SinifAdi: 'EISA DMA controller'),
    (SinifKod: $080200; SinifAdi: 'Generic 8254 system timer'),
    (SinifKod: $080201; SinifAdi: 'ISA system timer'),
    (SinifKod: $080202; SinifAdi: 'EISA system timers'),
    (SinifKod: $080300; SinifAdi: 'Generic RTC controller'),
    (SinifKod: $080301; SinifAdi: 'ISA RTC controller'),
    (SinifKod: $080400; SinifAdi: 'Generic PCI Hot-Plug controller'),
    (SinifKod: $080501; SinifAdi: 'Base Peripheral'),
    (SinifKod: $088000; SinifAdi: 'Other system peripheral'),
    (SinifKod: $090000; SinifAdi: 'Keyboard controller'),
    (SinifKod: $090100; SinifAdi: 'Digitizer (pen)'),
    (SinifKod: $090200; SinifAdi: 'Mouse controller'),
    (SinifKod: $090300; SinifAdi: 'Scanner controller'),
    (SinifKod: $090400; SinifAdi: 'Gameport controller (generic)'),
    (SinifKod: $090410; SinifAdi: 'Gameport controller (legacy)'),
    (SinifKod: $098000; SinifAdi: 'Other input controller'),
    (SinifKod: $0a0000; SinifAdi: 'Generic docking station'),
    (SinifKod: $0a8000; SinifAdi: 'Other type of docking station'),
    (SinifKod: $0b0000; SinifAdi: '386'),
    (SinifKod: $0b0100; SinifAdi: '486'),
    (SinifKod: $0b0200; SinifAdi: 'Pentium'),
    (SinifKod: $0b1000; SinifAdi: 'Alpha'),
    (SinifKod: $0b2000; SinifAdi: 'PowerPC'),
    (SinifKod: $0b3000; SinifAdi: 'MIPS'),
    (SinifKod: $0b4000; SinifAdi: 'Co-processor'),
    (SinifKod: $0c0000; SinifAdi: 'IEEE 1394 (FireWire)'),
    (SinifKod: $0c0010; SinifAdi: 'IEEE 1394 (FireWire) OHCI'),
    (SinifKod: $0c0100; SinifAdi: 'ACCESS.bus'),
    (SinifKod: $0c0200; SinifAdi: 'SSA'),
    (SinifKod: $0c0300; SinifAdi: 'USB Controller (UHCI)'),
    (SinifKod: $0c0310; SinifAdi: 'USB Controller (OHCI)'),
    (SinifKod: $0c0320; SinifAdi: 'USB Controller (EHCI)'),
    (SinifKod: $0c0380; SinifAdi: 'USB Controller'),
    (SinifKod: $0c03fe; SinifAdi: 'USB Device'),
    (SinifKod: $0c0400; SinifAdi: 'Fibre Channel'),
    (SinifKod: $0c0500; SinifAdi: 'SMBus'),
    (SinifKod: $0c0600; SinifAdi: 'InfiniBand'),
    (SinifKod: $0c0700; SinifAdi: 'IPMI SMIC Interface'),
    (SinifKod: $0c0701; SinifAdi: 'IPMI Kybd Controller Style Interface'),
    (SinifKod: $0c0702; SinifAdi: 'IPMI Block Transfer Interfac'),
    (SinifKod: $0c0800; SinifAdi: 'SERCOS Interface Standard (IEC 61491)'),
    (SinifKod: $0c0900; SinifAdi: 'CANbus'),
    (SinifKod: $0d0000; SinifAdi: 'iRDA compatible controller'),
    (SinifKod: $0d0100; SinifAdi: 'Consumer IR controller'),
    (SinifKod: $0d1000; SinifAdi: 'RF controller'),
    (SinifKod: $0d1100; SinifAdi: 'Bluetooth'),
    (SinifKod: $0d1200; SinifAdi: 'Broadband'),
    (SinifKod: $0d2000; SinifAdi: 'Ethernet (802.11a - 5 GHz)'),
    (SinifKod: $0d2100; SinifAdi: 'Ethernet (802.11b - 2.4 GHz)'),
    (SinifKod: $0d8000; SinifAdi: 'Other type of wireless controller'),
    (SinifKod: $0e0000; SinifAdi: 'Intelligent I/O (I2O) Architecture Spec 1.0'),
    (SinifKod: $0e0000; SinifAdi: 'Message FIFO at offset $40'),
    (SinifKod: $0f0100; SinifAdi: 'Satellite TV'),
    (SinifKod: $0f0200; SinifAdi: 'Satellite Audio'),
    (SinifKod: $0f0300; SinifAdi: 'Satellite Voice'),
    (SinifKod: $0f0400; SinifAdi: 'Satellite Data'),
    (SinifKod: $100000; SinifAdi: 'Network and computing en/decryption'),
    (SinifKod: $101000; SinifAdi: 'Entertainment en/decryption'),
    (SinifKod: $108000; SinifAdi: 'Other en/decryption'),
    (SinifKod: $110000; SinifAdi: 'DPIO modules'),
    (SinifKod: $110100; SinifAdi: 'Performance counters'),
    (SinifKod: $111000; SinifAdi: 'Communications synchronization plus time and frequency test/measurement'),
    (SinifKod: $112000; SinifAdi: 'Management card'),
    (SinifKod: $118000; SinifAdi: 'Other data acquisition/signal processing controllers'));

type
  TSatici = record
    SaticiKimlik: TSayi2;
    SaticiAdi: string;
  end;

var
  PCISaticiListesi: array[0..12] of TSatici = (
    (SaticiKimlik: $1000; SaticiAdi: 'LSI Logic / Symbios Logic'),
    (SaticiKimlik: $1022; SaticiAdi: 'Advanced Micro Devices'),
    (SaticiKimlik: $104c; SaticiAdi: 'Texas Instruments'),
    (SaticiKimlik: $106b; SaticiAdi: 'Apple Inc'),
    (SaticiKimlik: $109e; SaticiAdi: 'Brooktree Corporation'),
    (SaticiKimlik: $10de; SaticiAdi: 'nVidia Corporation'),
    (SaticiKimlik: $10ec; SaticiAdi: 'Realtek Semiconductor Co.Ltd'),
    (SaticiKimlik: $1217; SaticiAdi: 'O2 Micro, Inc'),
    (SaticiKimlik: $1274; SaticiAdi: 'Ensoniq'),
    (SaticiKimlik: $15ad; SaticiAdi: 'VMware'),
    (SaticiKimlik: $168c; SaticiAdi: 'Atheros Communications Inc'),
    (SaticiKimlik: $8086; SaticiAdi: 'Intel Corporation'),
    (SaticiKimlik: $80ee; SaticiAdi: 'InnoTek Systemberatung GmbH'));

type
  TPCIAygit = record
    SaticiKimlik,
    AygitKimlik: TSayi2;
    AygitAdi: string;
  end;

var
  PCIAygitListesi: array[0..65] of TPCIAygit = (
    (SaticiKimlik: $1000; AygitKimlik: $0030; AygitAdi: '53c1030 PCI-X Fusion-MPT Dual Ultra320 SCSI'),
    (SaticiKimlik: $1022; AygitKimlik: $1100; AygitAdi: 'K8 [Athlon64/Opteron] HyperTransport Technology Configuration'),
    (SaticiKimlik: $1022; AygitKimlik: $1101; AygitAdi: 'K8 [Athlon64/Opteron] Address Map'),
    (SaticiKimlik: $1022; AygitKimlik: $1102; AygitAdi: 'K8 [Athlon64/Opteron] DRAM Controller'),
    (SaticiKimlik: $1022; AygitKimlik: $1103; AygitAdi: 'K8 [Athlon64/Opteron] Miscellaneous Control'),
    (SaticiKimlik: $1022; AygitKimlik: $2000; AygitAdi: 'Am79C970/1/2/3/5/6 PCnet LANCE PCI Ethernet Controller'),
    (SaticiKimlik: $104c; AygitKimlik: $8024; AygitAdi: 'TSB43AB23 IEEE-1394a-2000 Controller (PHY/Link)'),
    (SaticiKimlik: $106b; AygitKimlik: $003f; AygitAdi: 'KeyLargo/Intrepid USB'),
    (SaticiKimlik: $109e; AygitKimlik: $036e; AygitAdi: 'Bt878 Video Capture'),
    (SaticiKimlik: $109e; AygitKimlik: $0878; AygitAdi: 'Bt878 Audio Capture'),
    (SaticiKimlik: $10de; AygitKimlik: $01d3; AygitAdi: 'G72 [GeForce 7300 SE/7200 GS]'),
    (SaticiKimlik: $10de; AygitKimlik: $0441; AygitAdi: 'MCP65 LPC Bridge'),
    (SaticiKimlik: $10de; AygitKimlik: $0444; AygitAdi: 'MCP65 Memory Controller'),
    (SaticiKimlik: $10de; AygitKimlik: $0445; AygitAdi: 'MCP65 Memory Controller'),
    (SaticiKimlik: $10de; AygitKimlik: $0446; AygitAdi: 'MCP65 SMBus'),
    (SaticiKimlik: $10de; AygitKimlik: $0448; AygitAdi: 'MCP65 IDE'),
    (SaticiKimlik: $10de; AygitKimlik: $0449; AygitAdi: 'MCP65 PCI bridge'),
    (SaticiKimlik: $10de; AygitKimlik: $044a; AygitAdi: 'MCP65 High Definition Audio'),
    (SaticiKimlik: $10de; AygitKimlik: $0450; AygitAdi: 'MCP65 Ethernet'),
    (SaticiKimlik: $10de; AygitKimlik: $0454; AygitAdi: 'MCP65 USB Controller'),
    (SaticiKimlik: $10de; AygitKimlik: $0455; AygitAdi: 'MCP65 USB Controller'),
    (SaticiKimlik: $10de; AygitKimlik: $0458; AygitAdi: 'MCP65 PCI Express bridge'),
    (SaticiKimlik: $10de; AygitKimlik: $045d; AygitAdi: 'MCP65 SATA Controller'),
    (SaticiKimlik: $10ec; AygitKimlik: $8139; AygitAdi: 'RTL-8139/8139C/8139C+'),
    (SaticiKimlik: $10ec; AygitKimlik: $8168; AygitAdi: 'RTL8111/8168B PCI Express Gigabit Ethernet controller'),
    (SaticiKimlik: $1217; AygitKimlik: $00f7; AygitAdi: '1394 Open Host Controller Interface'),
    (SaticiKimlik: $1217; AygitKimlik: $7120; AygitAdi: 'Integrated MMC/SD Controller'),
    (SaticiKimlik: $1217; AygitKimlik: $7130; AygitAdi: 'Integrated MS/xD Controller'),
    (SaticiKimlik: $1217; AygitKimlik: $7136; AygitAdi: 'OZ711SP1 Memory CardBus Controller'),
    (SaticiKimlik: $1274; AygitKimlik: $1371; AygitAdi: 'ES1371 [AudioPCI-97]'),
    (SaticiKimlik: $15ad; AygitKimlik: $0405; AygitAdi: 'SVGA II Adapter'),
    (SaticiKimlik: $15ad; AygitKimlik: $0740; AygitAdi: 'Virtual Machine Communication Interface'),
    (SaticiKimlik: $15ad; AygitKimlik: $0770; AygitAdi: 'USB2 EHCI Controller'),
    (SaticiKimlik: $15ad; AygitKimlik: $0790; AygitAdi: 'PCI bridge'),
    (SaticiKimlik: $15ad; AygitKimlik: $07a0; AygitAdi: 'PCI Express Root Port'),
    (SaticiKimlik: $168c; AygitKimlik: $011c; AygitAdi: 'AR5001 Wireless Network Adapter'),
    (SaticiKimlik: $8086; AygitKimlik: $100f; AygitAdi: '82545EM Gigabit Ethernet Controller (Copper)'),
    (SaticiKimlik: $8086; AygitKimlik: $1237; AygitAdi: '82441FX PCI & Memory Controller (PMC)'),
    (SaticiKimlik: $8086; AygitKimlik: $2415; AygitAdi: '82801AA AC97 Audio Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2448; AygitAdi: '82801 Mobile PCI Bridge'),
    (SaticiKimlik: $8086; AygitKimlik: $265c; AygitAdi: '82801FB/FBM/FR/FW/FRW (ICH6 Family) USB2 EHCI Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2815; AygitAdi: '82801HEM (ICH8M) LPC Interface Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2829; AygitAdi: '82801HBM/HEM (ICH8M/ICH8M-E) SATA AHCI Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2830; AygitAdi: '82801H (ICH8 Family) USB UHCI Controller #1'),
    (SaticiKimlik: $8086; AygitKimlik: $2831; AygitAdi: '82801H (ICH8 Family) USB UHCI Controller #2'),
    (SaticiKimlik: $8086; AygitKimlik: $2832; AygitAdi: '82801H (ICH8 Family) USB UHCI Controller #3'),
    (SaticiKimlik: $8086; AygitKimlik: $2834; AygitAdi: '82801H (ICH8 Family) USB UHCI Controller #4'),
    (SaticiKimlik: $8086; AygitKimlik: $2835; AygitAdi: '82801H (ICH8 Family) USB UHCI Controller #5'),
    (SaticiKimlik: $8086; AygitKimlik: $2836; AygitAdi: '82801H (ICH8 Family) USB2 EHCI Controller #1'),
    (SaticiKimlik: $8086; AygitKimlik: $283a; AygitAdi: '82801H (ICH8 Family) USB2 EHCI Controller #2'),
    (SaticiKimlik: $8086; AygitKimlik: $283e; AygitAdi: '82801H (ICH8 Family) SMBus Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $283f; AygitAdi: '82801H (ICH8 Family) PCI Express Port 1'),
    (SaticiKimlik: $8086; AygitKimlik: $2843; AygitAdi: '82801H (ICH8 Family) PCI Express Port 3'),
    (SaticiKimlik: $8086; AygitKimlik: $284b; AygitAdi: '82801H (ICH8 Family) HD Audio Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2850; AygitAdi: '82801HBM/HEM (ICH8M/ICH8M-E) IDE Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $2a00; AygitAdi: 'Mobile PM965/GM965/GL960 Memory Controller Hub'),
    (SaticiKimlik: $8086; AygitKimlik: $2a03; AygitAdi: 'Mobile GM965/GL960 Integrated Graphics Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $7000; AygitAdi: '82371SB PIIX3 PCI-to-ISA Bridge (Triton II)'),
    (SaticiKimlik: $8086; AygitKimlik: $7110; AygitAdi: '82371AB/EB/MB PIIX4 ISA'),
    (SaticiKimlik: $8086; AygitKimlik: $7111; AygitAdi: '82371AB/EB/MB PIIX4/4E/4M IDE Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $7112; AygitAdi: '82371AB/EB/MB PIIX4 USB'),
    (SaticiKimlik: $8086; AygitKimlik: $7113; AygitAdi: '82371AB/EB/MB PIIX4/4E/4M Power Management Controller'),
    (SaticiKimlik: $8086; AygitKimlik: $7190; AygitAdi: '440BX/ZX/DX - 82443BX/ZX/DX Host bridge'),
    (SaticiKimlik: $8086; AygitKimlik: $7191; AygitAdi: '440BX/ZX/DX - 82443BX/ZX/DX AGP bridge'),
    (SaticiKimlik: $80ee; AygitKimlik: $cafe; AygitAdi: 'VirtualBox Guest Service'),
    (SaticiKimlik: $80ee; AygitKimlik: $beef; AygitAdi: 'VirtualBox Graphics Adapter'));

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  DegerDugmesi0: TDegerDugmesi;
  ToplamPCIAygitSayisi: Word;
  AygitSiraNo: TSayi4;
  PCIAygitBilgisi: TPCIAygitBilgisi;
  OlayKayit: TOlayKayit;
  Deger32: TSayi4;
  Deger8: TSayi1;
  i, k: TSayi4;
  _TemelAdres: LongWord;
  _SinifKod, _SaticiKimlik, _AygitAdi: string;

function PCISinifAdiAl(ASinifKodu: TSayi4): string;
var
  _SinifKod, i: TSayi4;
begin

  _SinifKod := (ASinifKodu shr 8) and $FFFFFF;

  for i := 0 to 139 do
  begin

    if(_SinifKod = PCISinifListesi[i].SinifKod) then
      Exit(PCISinifListesi[i].SinifAdi);
  end;

  Result := 'Bilinmeyen Aygýt Tipi';
end;

function PCISaticiAdiAl(ASaticiKimlik: TSayi2): string;
var
  i: TSayi4;
begin

  for i := 0 to 12 do
  begin

    if(PCISaticiListesi[i].SaticiKimlik = ASaticiKimlik) then
      Exit(PCISaticiListesi[i].SaticiAdi);
  end;

  Result := 'Bilinmeyen Satýcý';
end;

function PCIAygitAdiAl(ASaticiKimlik, AAygitKimlik: TSayi2): string;
var
  i: TSayi4;
begin

  for i := 0 to 65 do
  begin

    if(PCIAygitListesi[i].SaticiKimlik = ASaticiKimlik) and
      (PCIAygitListesi[i].AygitKimlik = AAygitKimlik) then
        Exit(PCIAygitListesi[i].AygitAdi);
  end;

  Result := 'Bilinmeyen Aygýt';
end;

begin

  Pencere0.Olustur(-1, 50, 10, 500, 450, ptBoyutlandirilabilir, ProgramAdi, $FFE0CC);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  AygitSiraNo := 0;

  ToplamPCIAygitSayisi := ToplamPCIAygitSayisiAl;
  if(ToplamPCIAygitSayisi > 0) then PCIAygitBilgisiAl(AygitSiraNo, @PCIAygitBilgisi);

  Pencere0.Tuval.KalemRengi := RENK_SIYAH;
  Pencere0.Tuval.YaziYaz(8 * 8, 5, 'Toplam Aygýt:');
  Pencere0.Tuval.KalemRengi := RENK_MAVI;
  Pencere0.Tuval.SayiYaz10(22 * 8, 5, ToplamPCIAygitSayisi);

  Pencere0.Tuval.KalemRengi := RENK_SIYAH;
  Pencere0.Tuval.YaziYaz(25 * 8, 5, 'Mevcut Aygýt:');
  Pencere0.Tuval.KalemRengi := RENK_MAVI;
  Pencere0.Tuval.SayiYaz10(39 * 8, 5, AygitSiraNo + 1);

  DegerDugmesi0.Olustur(Pencere0.Kimlik, 335, 0, 17, 22);
  DegerDugmesi0.Goster;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = DegerDugmesi0.Kimlik) then
      begin

        if(OlayKayit.Deger1 = 0) then
        begin

          if(AygitSiraNo + 1 < ToplamPCIAygitSayisi) then
          begin

            Inc(AygitSiraNo);
            PCIAygitBilgisiAl(AygitSiraNo, @PCIAygitBilgisi);
            Pencere0.Ciz;
          end;
        end
        else if(OlayKayit.Deger1 = 1) then
        begin

          if(AygitSiraNo - 1 >= 0) then
          begin

            Dec(AygitSiraNo);
            PCIAygitBilgisiAl(AygitSiraNo, @PCIAygitBilgisi);
            Pencere0.Ciz;
          end;
        end;
      end;
    end

    else if(OlayKayit.Olay = CO_CIZIM) then
    begin

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(8 * 8, 5, 'Toplam Aygýt:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz10(22 * 8, 5, ToplamPCIAygitSayisi);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(25 * 8, 5, 'Mevcut Aygýt:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz10(39 * 8, 5, AygitSiraNo + 1);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 2 * 16, 'Yol  :');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(7 * 8, 2 * 16, True, 2, PCIAygitBilgisi.Yol);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(19 * 8, 2 * 16, 'Aygýt:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(26 * 8, 2 * 16, True, 2, PCIAygitBilgisi.Aygit);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(38 * 8, 2 * 16, 'Ýþlev :');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(46 * 8, 2 * 16, True, 2, PCIAygitBilgisi.Islev);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, 4);
      PCIAygitBilgisi.Komut := (Deger32 and $FFFF);
      PCIAygitBilgisi.Durum := ((Deger32 shr 16) and $FFFF);

      Deger8 := PCIOku1(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, 8);
      PCIAygitBilgisi.RevizyonKimlik := Deger8;

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 3 * 16, 'Komut:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(7 * 8, 3 * 16, True, 4, PCIAygitBilgisi.Komut);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(19 * 8, 3 * 16, 'Durum:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(26 * 8, 3 * 16, True, 4, PCIAygitBilgisi.Durum);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(38 * 8, 3 * 16, 'Reviz.:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(46 * 8, 3 * 16, True, 2, PCIAygitBilgisi.RevizyonKimlik);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 5 * 16, 'Sýnýf :');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(8 * 8, 5 * 16, True, 6, (PCIAygitBilgisi.SinifKod shr 8) and $FFFFFF);
      Pencere0.Tuval.HarfYaz(16 * 8, 5 * 16, '-');
      _SinifKod := PCISinifAdiAl(PCIAygitBilgisi.SinifKod);
      Pencere0.Tuval.YaziYaz(18 * 8, 5 * 16, _SinifKod);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 6 * 16, 'Satýcý:');
      Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
      Pencere0.Tuval.SayiYaz16(8 * 8, 6 * 16, True, 4, PCIAygitBilgisi.SaticiKimlik);
      Pencere0.Tuval.HarfYaz(15 * 8, 6 * 16, '-');
      _SaticiKimlik := PCISaticiAdiAl(PCIAygitBilgisi.SaticiKimlik);
      Pencere0.Tuval.YaziYaz(17 * 8, 6 * 16, _SaticiKimlik);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 7 * 16, 'Aygýt :');
      Pencere0.Tuval.KalemRengi := RENK_KIRMIZI;
      Pencere0.Tuval.SayiYaz16(8 * 8, 7 * 16, True, 4, PCIAygitBilgisi.AygitKimlik);
      Pencere0.Tuval.HarfYaz(15 * 8, 7 * 16, '-');
      _AygitAdi := PCIAygitAdiAl(PCIAygitBilgisi.SaticiKimlik, PCIAygitBilgisi.AygitKimlik);
      Pencere0.Tuval.YaziYaz(17 * 8, 7 * 16, _AygitAdi);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $C);
      PCIAygitBilgisi.OnbellekHatUzunluk := (Deger32 and $FF);
      PCIAygitBilgisi.GecikmeSuresi := ((Deger32 shr 8) and $FF);
      PCIAygitBilgisi.BaslikTip := ((Deger32 shr 16) and $FF);
      PCIAygitBilgisi.Bist := ((Deger32 shr 24) and $FF);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 9 * 16, 'Önbellek Hat Uz:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(17 * 8, 9 * 16, True, 2, PCIAygitBilgisi.OnbellekHatUzunluk);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(28 * 8, 9 * 16, 'Gecikme Süre.:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(43 * 8, 9 * 16, True, 2, PCIAygitBilgisi.GecikmeSuresi);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 10 * 16, 'Baþlýk Tipi    :');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(17 * 8, 10 * 16, True, 2, PCIAygitBilgisi.BaslikTip);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(28 * 8, 10 * 16, 'BIST         :');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(43 * 8, 10 * 16, True, 2, PCIAygitBilgisi.Bist);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $2C);
      PCIAygitBilgisi.AltSistemSaticiKimlik := (Deger32 and $FFFF);
      PCIAygitBilgisi.AltSistemKimlik := ((Deger32 shr 16) and $FFFF);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 11 * 16, 'AltSis.Sat.Kim.:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(17 * 8, 11 * 16, True, 4, PCIAygitBilgisi.AltSistemSaticiKimlik);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(28 * 8, 11 * 16, 'Alt.Sis.Kiml.:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(43 * 8, 11 * 16, True, 4, PCIAygitBilgisi.AltSistemKimlik);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $3C);
      PCIAygitBilgisi.KesmeNo := (Deger32 and $FF);
      PCIAygitBilgisi.KesmePin := ((Deger32 shr 8) and $FF);
      PCIAygitBilgisi.EnDusukImtiyaz := ((Deger32 shr 16) and $FF);
      PCIAygitBilgisi.AzamiGecikme := ((Deger32 shr 24) and $FF);

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 13 * 16, 'Kesme No:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(10 * 8, 13 * 16, True, 2, PCIAygitBilgisi.KesmeNo);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(28 * 8, 13 * 16, 'Kesm.Pin');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(37 * 8, 13 * 16, True, 2, PCIAygitBilgisi.KesmePin);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 14 * 16, 'EnDüþ.Ýmt');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(10 * 8, 14 * 16, True, 2, PCIAygitBilgisi.EnDusukImtiyaz);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(28 * 8, 14 * 16, 'Azam.Gec');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(37 * 8, 14 * 16, True, 2, PCIAygitBilgisi.AzamiGecikme);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $28);
      PCIAygitBilgisi.KartYolCISIsaretci := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $30);
      PCIAygitBilgisi.GenisletilmisROMTemelAdres := Deger32;

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 16 * 16, 'KartYol CIS Ýþaretçi:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(22 * 8, 16 * 16, True, 8, PCIAygitBilgisi.KartYolCISIsaretci);
      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 17 * 16, 'Genþl.ROM Tml.Adres:');
      Pencere0.Tuval.KalemRengi := RENK_MAVI;
      Pencere0.Tuval.SayiYaz16(21 * 8, 17 * 16, True, 8, PCIAygitBilgisi.GenisletilmisROMTemelAdres);

      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $10);
      PCIAygitBilgisi.TemelAdres[0] := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $14);
      PCIAygitBilgisi.TemelAdres[1] := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $18);
      PCIAygitBilgisi.TemelAdres[2] := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $1C);
      PCIAygitBilgisi.TemelAdres[3] := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $20);
      PCIAygitBilgisi.TemelAdres[4] := Deger32;
      Deger32 := PCIOku4(PCIAygitBilgisi.Yol, PCIAygitBilgisi.Aygit, PCIAygitBilgisi.Islev, $24);
      PCIAygitBilgisi.TemelAdres[5] := Deger32;

      Pencere0.Tuval.KalemRengi := RENK_SIYAH;
      Pencere0.Tuval.YaziYaz(0, 19 * 16, 'Kaynaklar:');

      k := 20;
      for i := 0 to 5 do
      begin

        Pencere0.Tuval.KalemRengi := RENK_MAVI;
        if((PCIAygitBilgisi.TemelAdres[i] and 1) = 1) then
        begin

          _TemelAdres := (PCIAygitBilgisi.TemelAdres[i] and (not 3));
          if(_TemelAdres > 0) then
          begin

            Pencere0.Tuval.SayiYaz16(5 * 8, k * 16, True, 8, _TemelAdres);
            Pencere0.Tuval.YaziYaz(16 * 8, k * 16, '- IO');
            Inc(k);
          end;
        end
        else
        begin

          _TemelAdres := (PCIAygitBilgisi.TemelAdres[i] and (not 15));
          if(_TemelAdres > 0) then
          begin

            Pencere0.Tuval.SayiYaz16(5 * 8, k * 16, True, 8, _TemelAdres);
            Pencere0.Tuval.YaziYaz(16 * 8, k * 16, '- MEM');
            Inc(k);
          end;
        end;
      end;
    end;

  until (1 = 2);
end.
