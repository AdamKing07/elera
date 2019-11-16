{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: loader.pp
  Dosya Ýþlevi: sistem ilk açýlýþ yükleme iþlevleri gerçekleþtirir

  Güncelleme Tarihi: 11/08/2017

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
//{$DEFINE NETWORK_ON}
{$DEFINE SOUND_ON}
//{$DEFINE COMM_ON}
unit loader;

interface

var
  PPoint: PChar;
  Params: Pointer;
  Key, Key1: Char;
  CmdIndex, i: LongInt;
  CommandBuffer: array[0..255] of Char;
  CommandBufferSize: Word;
  Buffer: array[0..512] of Char;

procedure LoadKernelFunctions;
procedure RunBeforeKernel;
procedure RunAfterKernel;

implementation

uses pic, gdt, idt, irq, gvars, process, sysmngr, macmsg, cpu, pci, drv_keyb,
  devman, partman, timer, shared, files, tmode, drv_sb, vmm;

{==============================================================================
  çekirdek çevre donaným yükleme iþlevlerini gerçekleþtir
 ==============================================================================}
procedure LoadKernelFunctions;
var
  p: PProcess;
begin

  // çekirdek yükleme öncesi iþlevleri gerçekleþtir
  RunBeforeKernel;

  // tüm kesmeleri pasifleþtir
  DisableIRQs;

  // sistem global tanýmlayýcý tabloyu (GDTR) ve içeriðini yükle
  InitGDT;

  // kesme yazmacýný (IDTR) ve içeriðini yükle
  InitIDT;

  // pic denetleyicisini ilk deðerlerle yükle
  PicInit;

  // irq denetleyicisini ilk deðerlerle yükle
  // Bilgi: bu aþamaya kadar tüm irq istekleri kapalýdýr.
  // bu aþamadan itibaren yapýlacak EnableIRQ, SetIrqHandler
  // iþlevleri belirtilen irq isteklerini devreye sokacaktýr
  IrqInit;

  // belleði ilk kullaným için hazýrla
  // Önemli: Mem.Init iþlevinin diðer iþlevlere zemin hazýrlamasý için
  // öncelikle yüklenmesi gerekmektedir.
  GMem.Init;

  // uygulama deðiþkenlerini ilk deðerlerle yükle
  p^.Init;

  // kernel deðiþken/iþlevlerini ilk deðerlerle yükle
  InitKernelDefaults;

  // yazý (text) mode ortamýný ilk deðerlerle yükle
  tmode.Init;

  // Bilgi: MSG_X'ler buradan itibaren kullanýlabilir

  MSG_S(#10 + '+ Sistem yukleniyor...');

  MSG_S('+ Islemci bilgileri aliniyor...');
  GCPUInfo.CPUName := GetCPUVendor;
  GetCpuInfo(GCPUInfo.CpuInfo1, GCPUInfo.CpuInfo2, GCPUInfo.CpuInfo3);

  MSG_S('+ Zamanlayici yukleniyor...');
  GTimers.Init;

  // Bilgi: Delay iþlevleri buradan itibaren kullanýlabilir

  MSG_S('+ PCI aygitlari araniyor...');
  InitPci;

  MSG_S('+ Klavye aygiti yukleniyor...');
  KeyboardInit;

  MSG_S('+ PS2 fare surucusu yukleniyor...');
  GMouseDriver.Init;

  MSG_S('+ USB aygitlari yukleniyor...');
  //usb.Init;

  MSG_S('+ Depolama aygitlari yukleniyor...');
  InitStorageDrivers;

  MSG_S('+ Mantiksal surucu atamalari gerceklestiriliyor...');
  MapLogicalStorageDrivers;

  {$IFDEF COMM_ON}
  MSG_S('+ Iletisim (com port) portu yükleniyor...');
  InitCom;
  {$ENDIF}

  // sound blaster ses aygýtýný yükle
  {$IFDEF SOUND_ON}
  MSG_S('+ Ses karti yukleniyor...');
  InitSB;
  {$ENDIF}

  {$IFDEF NETWORK_ON}
  // not: InitPci yüklendikten sonra yüklenmelidir
  MSG_S('+ Ethernet aygitlari yukleniyor...');
  InitEthDevices;

  // not: InitEthDevices iþlevi yüklendikten sonra yüklenmelidir
  if(NetworkInitialized) then
  begin

    MSG_S('+ ARP protokolu yükleniyor...');
    ArpInit;
  end;
  {$ENDIF}

  // NOT: MSG_X'ler buradan itibaren sistem içerisine yönlendiriliyor

  //MSG_S('+ Sistem mesaj servisi baþlatýlýyor...');
  {Message.Init;

  // olay ilk deðerlerini yükle
  SysEvent.Init;

  MSG_S('+ Görsel nesne için bellek iþlemleri yapýlýyor.');
  InitObjects; }

  // çekirdek yükleme sonrasý iþlevleri gerçekleþtir
  RunAfterKernel;

  // sistem mesajlarýný görmek için bekleme süresi.
  //Delay(100);
end;

{==============================================================================
  kernel yükleme öncesi iþlevleri çalýþtýrýr.
 ==============================================================================}
procedure RunBeforeKernel;
begin

  OsCounter := 0;
end;

{==============================================================================
  kernel yükleme sonrasý iþlevleri çalýþtýrýr.
 ==============================================================================}
procedure RunAfterKernel;
begin

  InitFileVariables;
end;

end.
