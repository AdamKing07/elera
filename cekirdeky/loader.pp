{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: loader.pp
  Dosya ��levi: sistem ilk a��l�� y�kleme i�levleri ger�ekle�tirir

  G�ncelleme Tarihi: 11/08/2017

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
  �ekirdek �evre donan�m y�kleme i�levlerini ger�ekle�tir
 ==============================================================================}
procedure LoadKernelFunctions;
var
  p: PProcess;
begin

  // �ekirdek y�kleme �ncesi i�levleri ger�ekle�tir
  RunBeforeKernel;

  // t�m kesmeleri pasifle�tir
  DisableIRQs;

  // sistem global tan�mlay�c� tabloyu (GDTR) ve i�eri�ini y�kle
  InitGDT;

  // kesme yazmac�n� (IDTR) ve i�eri�ini y�kle
  InitIDT;

  // pic denetleyicisini ilk de�erlerle y�kle
  PicInit;

  // irq denetleyicisini ilk de�erlerle y�kle
  // Bilgi: bu a�amaya kadar t�m irq istekleri kapal�d�r.
  // bu a�amadan itibaren yap�lacak EnableIRQ, SetIrqHandler
  // i�levleri belirtilen irq isteklerini devreye sokacakt�r
  IrqInit;

  // belle�i ilk kullan�m i�in haz�rla
  // �nemli: Mem.Init i�levinin di�er i�levlere zemin haz�rlamas� i�in
  // �ncelikle y�klenmesi gerekmektedir.
  GMem.Init;

  // uygulama de�i�kenlerini ilk de�erlerle y�kle
  p^.Init;

  // kernel de�i�ken/i�levlerini ilk de�erlerle y�kle
  InitKernelDefaults;

  // yaz� (text) mode ortam�n� ilk de�erlerle y�kle
  tmode.Init;

  // Bilgi: MSG_X'ler buradan itibaren kullan�labilir

  MSG_S(#10 + '+ Sistem yukleniyor...');

  MSG_S('+ Islemci bilgileri aliniyor...');
  GCPUInfo.CPUName := GetCPUVendor;
  GetCpuInfo(GCPUInfo.CpuInfo1, GCPUInfo.CpuInfo2, GCPUInfo.CpuInfo3);

  MSG_S('+ Zamanlayici yukleniyor...');
  GTimers.Init;

  // Bilgi: Delay i�levleri buradan itibaren kullan�labilir

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
  MSG_S('+ Iletisim (com port) portu y�kleniyor...');
  InitCom;
  {$ENDIF}

  // sound blaster ses ayg�t�n� y�kle
  {$IFDEF SOUND_ON}
  MSG_S('+ Ses karti yukleniyor...');
  InitSB;
  {$ENDIF}

  {$IFDEF NETWORK_ON}
  // not: InitPci y�klendikten sonra y�klenmelidir
  MSG_S('+ Ethernet aygitlari yukleniyor...');
  InitEthDevices;

  // not: InitEthDevices i�levi y�klendikten sonra y�klenmelidir
  if(NetworkInitialized) then
  begin

    MSG_S('+ ARP protokolu y�kleniyor...');
    ArpInit;
  end;
  {$ENDIF}

  // NOT: MSG_X'ler buradan itibaren sistem i�erisine y�nlendiriliyor

  //MSG_S('+ Sistem mesaj servisi ba�lat�l�yor...');
  {Message.Init;

  // olay ilk de�erlerini y�kle
  SysEvent.Init;

  MSG_S('+ G�rsel nesne i�in bellek i�lemleri yap�l�yor.');
  InitObjects; }

  // �ekirdek y�kleme sonras� i�levleri ger�ekle�tir
  RunAfterKernel;

  // sistem mesajlar�n� g�rmek i�in bekleme s�resi.
  //Delay(100);
end;

{==============================================================================
  kernel y�kleme �ncesi i�levleri �al��t�r�r.
 ==============================================================================}
procedure RunBeforeKernel;
begin

  OsCounter := 0;
end;

{==============================================================================
  kernel y�kleme sonras� i�levleri �al��t�r�r.
 ==============================================================================}
procedure RunAfterKernel;
begin

  InitFileVariables;
end;

end.
