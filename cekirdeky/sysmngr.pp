{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: sysmngr.pp
  Dosya İşlevi: sistem ana yönetim / kontrol kısmı

  Güncelleme Tarihi: 11/08/2017

 ==============================================================================}
{$asmmode intel}
{$mode objfpc}
unit sysmngr;

interface

uses process, shared, files;

type
  PRMInfo = ^TRMInfo;
  TRMInfo = packed record
    VideoMemSize: Word;
    VideoMode: Word;
    VideoResX: Word;
    VideoResY: Word;
    VideoLfbAddr: LongWord;
    VideoBpp: Byte;
    VideoBpsl: Word;
    KernelWorkMode: Word;
    KernelStartAddr: LongWord;
    KernelSize: LongWord;
  end;

const
  CMD_UNKNOWN = -1;
  CMD_HELP = CMD_UNKNOWN + 1;
  CMD_SYSTEM = CMD_HELP + 1;
  CMD_MIB = CMD_SYSTEM + 1;
  CMD_BELDOK = CMD_MIB + 1;
  CMD_DISKGOR = CMD_BELDOK + 1;
  CMD_DATE = CMD_DISKGOR + 1;
  CMD_TIME = CMD_DATE + 1;
  CMD_GDTR = CMD_TIME + 1;
  CMD_LIST = CMD_GDTR + 1;
  CMD_LIST2 = CMD_LIST + 1;
  CMD_TEST1 = CMD_LIST2 + 1;
  CMD_TEST2 = CMD_TEST1 + 1;

const
  CommandsCount = 12;
  Commands: array[0..CommandsCount - 1] of string = (
    'yardim', 'sistem', 'mib', 'beldok', 'diskgor',
    'tarih', 'saat', 'gdtr', 'listele', 'listele2', 'test1', 'test2');

  CommandDescs: array[0..CommandsCount - 1] of string = (
    ' - su an calisan komut.',
    ' - sistem hakkinda bilgi verir.',
    ' - merkezi islem birimi hakkinda bilgi verir.',
    ' - bellek icerigini goruntuler.',
    ' - disk icerigini goruntuler.',
    ' - saat bilgisini goruntuler.',
    ' - tarih bilgisini goruntuler.',
    ' - GDTR degerlerini listeler.',
    ' - dosya ve dizinleri listeler. (disk)',
    ' - dosya ve dizinleri listeler. (disket)',
    ' - test amacli komut - 1.',
    ' - test amacli komut - 2.');
  CommandPrompt: string = #10 + 'Komut: > ';

var
  PPoint: PChar;
  Params: Pointer;
  Key, Key1: Char;
  CmdIndex, i: LongInt;
  CommandBuffer: array[0..255] of Char;
  CommandBufferSize: Word;
  Buffer: array[0..512] of Char;
  KeyState: TKeyState;

procedure OSControl;
function CheckCommand: LongInt;
procedure ShowHelp;
procedure MIBInfo;
procedure ShowMemory;
procedure ShowStorage;
procedure ShowGdtr;
procedure List;
procedure List2;
procedure test1;
procedure test2;
procedure ShowMemContent(Mem: PByte);
procedure ShowStorageContent(SectorNum: LongWord; Mem: PByte);
procedure InitKernelDefaults;

implementation

uses gdt, gvars, tmode, convert, drv_keyb, drv_ps2, drv_sb, vmm, datetime, sistem;

{==============================================================================
  sistem ana kontrol kısmı
 ==============================================================================}
procedure OSControl;
begin

  CommandBufferSize := 0;

  for i := 0 to 255 do CommandBuffer[i] := #0;

  Write(CommandPrompt);

  repeat

    KeyState := GetKey(Key);
    if(KeyState = ksPressed) then
    begin

      if(Key = #10) then
      begin

        if(CommandBufferSize > 0) then
        begin

          CmdIndex := CheckCommand;
          case CmdIndex of
            CMD_UNKNOWN:
            begin

              Write(#10 + 'Bilinmeyen komut!');
            end;
            CMD_HELP: ShowHelp;
            CMD_SYSTEM: SysInfo;
            CMD_MIB: MIBInfo;
            CMD_BELDOK: ShowMemory;
            CMD_DISKGOR: ShowStorage;
            CMD_DATE: ShowDate;
            CMD_TIME: ShowTime;
            CMD_GDTR: ShowGdtr;
            CMD_LIST: List;
            CMD_LIST2: List2;
            CMD_TEST1: test1;
            CMD_TEST2: test2;
          end;

          CommandBufferSize := 0;
          for i := 0 to 255 do CommandBuffer[i] := #0;

          WriteChar(#10);
          Write(CommandPrompt);
        end;
      end
      else if(Key <> #0) then
      begin

        if(CommandBufferSize < 255) then
        begin

          CommandBuffer[CommandBufferSize] := Key;
          CommandBuffer[CommandBufferSize + 1] := #0;
          Inc(CommandBufferSize);
          WriteChar(Key);
        end;
      end;
    end;

  until 1 = 0;
end;

{==============================================================================
  kullanıcı tarafından girilen komutların yorumlandığı bölüm
 ==============================================================================}
function CheckCommand: LongInt;
var
  i, j, CmdLen1: LongInt;
  Found: Boolean;
begin

  if(CommandBufferSize = 0) then

    Result := -1
  else
  begin

    for i := 0 to CommandsCount - 1 do
    begin

      CmdLen1 := Length(Commands[i]);
      if(CmdLen1 = CommandBufferSize) then
      begin

        Found := True;
        for j := 1 to CmdLen1 do
        begin

          if(CommandBuffer[j - 1] <> Commands[i][j]) then
          begin

            Found := False;
            Break;
          end;
        end;

        if(Found) then
        begin

          Result := i;
          Exit;
        end;
      end;
    end;
  end;
  Result := -1;
end;

{==============================================================================
  yardım komutu
 ==============================================================================}
procedure ShowHelp;
var
  i: Integer;
begin

  for i := 0 to CommandsCount - 1 do
  begin

    WriteChar(#10);
    Write('     ');
    Write(Commands[i]);
    Write(CommandDescs[i]);
  end;

  WriteChar(#10);
end;

{==============================================================================
  işlemci bilgisi komutu
 ==============================================================================}
procedure MIBInfo;
begin

  Write(#10 + 'Islemci: ');
  Write(GCPUInfo.CPUName);
end;

{==============================================================================
  bellek içerik görüntüleme komutu
 ==============================================================================}
procedure ShowMemory;
const
  sBellekDokum1: string = #10 + 'Adres (Hex)  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16';
  sBellekDokum2: string = #10 + '-----------  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ';
var
  c: Char;
  KeyState: TKeyState;
  Mem: Integer;
  ExitProgram: Boolean;
begin

  ExitProgram := False;

  Mem := $10000;

  ClrScr;
  Write(sBellekDokum1);
  Write(sBellekDokum2);
  ShowMemContent(PByte(Mem));

  repeat

    KeyState := GetKey(c);
    if(KeyState = ksPressed) then
    begin

      if(c = #110) then
      begin

        Mem := Mem + 512;
        ClrScr;
        Write(sBellekDokum1);
        Write(sBellekDokum2);
        ShowMemContent(PByte(Mem));
      end
      else if(c = #120) then
      begin

        Mem := Mem - 512;
        ClrScr;
        Write(sBellekDokum1);
        Write(sBellekDokum2);
        ShowMemContent(PByte(Mem));
      end else if(c = #27) then ExitProgram := True;
    end;
  until ExitProgram;
end;

{==============================================================================
  depolama aygıtı içerik görüntüleme komutu
 ==============================================================================}
procedure ShowStorage;
const
  sBellekDokum1: string = #10 + 'Adres (Hex)  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16';
  sBellekDokum2: string = #10 + '-----------  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ';
var
  c: Char;
  KeyState: TKeyState;
  SecNum: Integer;
  ExitProgram: Boolean;
  p: PPDriver;
begin

  // 2. depolama aygıtı. (ilk disk)
  { TODO : Kullanıcı aygıt seçimi eklenecek }
  p := @PStorageDrvList[1];
  if(p <> nil) then
  begin

    ExitProgram := False;

    SecNum := 0;
    p^.ReadSector(p, SecNum, 1, @Buffer);
    ClrScr;
    Write(sBellekDokum1);
    Write(sBellekDokum2);
    ShowStorageContent(SecNum, @Buffer);

    repeat

      KeyState := GetKey(c);
      if(KeyState = ksPressed) then
      begin

        if(c = #110) then
        begin

          Inc(SecNum);
          p^.ReadSector(p, SecNum, 1, @Buffer);
          ClrScr;
          Write(sBellekDokum1);
          Write(sBellekDokum2);
          ShowStorageContent(SecNum, @Buffer);
        end
        else if(c = #120) then
        begin

          Dec(SecNum);
          p^.ReadSector(p, SecNum, 1, @Buffer);
          ClrScr;
          Write(sBellekDokum1);
          Write(sBellekDokum2);
          ShowStorageContent(SecNum, @Buffer);
        end else if(c = #27) then ExitProgram := True;
      end;
    until ExitProgram;
  end else Write('Disk aygiti yok!');
end;

{==============================================================================
  gdtr bilgisini görüntüleme komutu
 ==============================================================================}
procedure ShowGdtr;
var
  i, Val: Integer;
  GDTREntry: TGDTREntry;
  Addr1: string;
begin

  Write(#10 + 'GDTR Yazmac Bilgileri: ');
  Write(#10 + '---------------------: ');

  Write(#10 + 'GDTR Limit: ');
  Addr1 := HexToStr(Integer(Gdtr.Limit + 1), True, 2);
  Write(Addr1);
  Write(#10 + 'GDTR Baslangic Adresi: ');
  Addr1 := HexToStr(Integer(Gdtr.Base), True, 8);
  Write(Addr1);

  for i := 0 to 3 do
  begin

    GDTREntry := GDTREntries[i]^;

    Write(#10#10 + 'Sira: ');
    Addr1 := HexToStr(i, True, 2);
    Write(Addr1);

    Write(#10 + 'Limit: ');
    Val := GDTREntry.Gran and $F;
    Val := (Val shl 16) or GDTREntry.LimitLow;
    Addr1 := HexToStr(Val, True, 8);
    Write(Addr1);

    Write(#10 + 'Temel Adres: ');
    Val := (GDTREntry.BaseHigh shl 24) or (GDTREntry.BaseMiddle shl 16) or
      GDTREntry.BaseLow;
    Addr1 := HexToStr(Val, True, 8);
    Write(Addr1);
  end;
end;

{==============================================================================
  dosya / dizin listeleme komutu
 ==============================================================================}
procedure List;
var
  R: LongInt;
  S: TSearchRec;
  TotalFiles: Integer;
  p: PProcess;
begin

  { TODO : Sadece ilk diskin dosya / dizin içeriği görüntülenmektedir. Geliştirilecek }

  TotalFiles := 0;

  R := FindFirst('disk1:\*.*', 0, S);

  while (R = 0) do
  begin

    Write(#10 + '  ' + S.FileName);
    R := FindNext(S);

    Inc(TotalFiles);
  end;
  FindClose(S);

  Write(#10#10 + '  Toplam Dizin / Dosya: ' + IntToStr(TotalFiles));
end;

{==============================================================================
  dosya / dizin listeleme komutu
 ==============================================================================}
procedure List2;
var
  R: LongInt;
  S: TSearchRec;
  TotalFiles: Integer;
  p: PProcess;
begin

  { TODO : Sadece ilk diskin dosya / dizin içeriği görüntülenmektedir. Geliştirilecek }

  TotalFiles := 0;

  R := FindFirst('disket1:\*.*', 0, S);

  while (R = 0) do
  begin

    Write(#10 + '  ' + S.FileName);
    R := FindNext(S);

    Inc(TotalFiles);
  end;
  FindClose(S);

  Write(#10#10 + '  Toplam Dizin / Dosya: ' + IntToStr(TotalFiles));
end;

{==============================================================================
  bellek içeriğini ekrana görüntüler
 ==============================================================================}
procedure ShowMemContent(Mem: PByte);
var
  x, y: Integer;
  Val: Byte;
  Val1: Char;
  MemBuffer, MemBuffer1: PByte;
  MemBuffer2: PChar;
  Addr1: string;
begin

  MemBuffer := PByte(Mem);

  for y := 0 to 15 do
  begin

    WriteChar(#10);
    Addr1 := HexToStr(Integer(MemBuffer), True, 8);
    Write(Addr1);
    WriteChar(' ');
    WriteChar(' ');
    WriteChar(' ');

    MemBuffer1 := MemBuffer;
    for x := 0 to 15 do
    begin

      Val := MemBuffer1^;
      Addr1 := HexToStr(Val, False, 2);
      Write(Addr1);
      WriteChar(' ');
      Inc(MemBuffer1);
    end;

    MemBuffer2 := PChar(MemBuffer);
    for x := 0 to 15 do
    begin

      Val1 := MemBuffer2^;
      if(Val1 in ['a'..'z', 'A'..'Z']) then
        WriteChar(Val1)
      else WriteChar(' ');
      Inc(MemBuffer2);
    end;
    MemBuffer := PByte(MemBuffer2);
  end;

  WriteChar(#10);
end;

{==============================================================================
  depolama aygıtı içeriğini ekrana görüntüler
 ==============================================================================}
procedure ShowStorageContent(SectorNum: LongWord; Mem: PByte);
var
  x, y, SNum: Integer;
  Val: Byte;
  Val1: Char;
  MemBuffer, MemBuffer1: PByte;
  MemBuffer2: PChar;
  Addr1: string;
begin

  MemBuffer := PByte(Mem);

  SNum := SectorNum * 512;

  for y := 0 to 15 do
  begin

    WriteChar(#10);
    Addr1 := HexToStr(Integer(SNum + (y * 16)), True, 8);
    Write(Addr1);
    WriteChar(' ');
    WriteChar(' ');
    WriteChar(' ');

    MemBuffer1 := MemBuffer;
    for x := 0 to 15 do
    begin

      Val := MemBuffer1^;
      Addr1 := HexToStr(Val, False, 2);
      Write(Addr1);
      WriteChar(' ');
      Inc(MemBuffer1);
    end;

    MemBuffer2 := PChar(MemBuffer);
    for x := 0 to 15 do
    begin

      Val1 := MemBuffer2^;
      if(Val1 in ['a'..'z', 'A'..'Z']) then
        WriteChar(Val1)
      else WriteChar(' ');
      Inc(MemBuffer2);
    end;
    MemBuffer := PByte(MemBuffer2);
  end;

  WriteChar(#10);
end;

procedure test1;
var
  MouseKeyEvents: TMouseKeyEvents;
begin

  ClrScr;

  GotoXY(10, 8);

  Write('Cikis yapmak icin fareyi en sag noktaya yaklastiriniz!');

  repeat

    GMouseDriver.GetEvents(@MouseKeyEvents);
    GotoXY(10, 10);
    Write('Yatay (X):');
    Write(IntToStr(MouseKeyEvents.X));
    GotoXY(10, 11);
    Write('Dikey (Y):');
    Write(IntToStr(MouseKeyEvents.Y));
    GotoXY(10, 12);
    Write('Dugmeler :');
    Write(IntToStr(MouseKeyEvents.Buttons));
    GotoXY(10, 13);
    Write('Kaydirma :');
    Write(IntToStr(MouseKeyEvents.ScrollVal));

  until MouseKeyEvents.X = 79;
end;

procedure test2;
var
  p: PProcess;
begin

  PlaySoundFile;

  Exit;

  p^.Execute('disk2:\ekryaz1.c', nil);

  repeat

  until CreatedProcess = 1;

  Write(#10#10 + 'Program sonlandirildi...');

{  Write(#10 + 'Basla');
  Delay(200);
  Write(#10 + 'Bitti');

  Write(#10 + 'Basla');
  Delay(1000);
  Write(#10 + 'Bitti'); }

{Write(OsVer);

  asm
    mov eax,2
    int $35
  end;}

  //Write(#10 + 'Sayac: ' + IntToStr(TestVal7));
end;

{==============================================================================
  sistem işlev, bellek rezervasyonu, değişkenlerini yükler
 ==============================================================================}
procedure InitKernelDefaults;
var
  Process: PProcess;
  RMInfo: PRMInfo;
begin

  RMInfo := PRMInfo(BILDEN_DATA_ADDR);

  // kernel bilgilerini al
  KernelStartAddr := RMInfo^.KernelStartAddr;
  KernelSize := RMInfo^.KernelSize;

  // zamanlayıcı sayacını sıfırla
  TimerCounter := 0;

  // sistem sayacını sıfırla
  OsCounter := 0;

  // TSS'nin içeriğini sıfırla
  FillByte(TSSArr[1], SizeOf(TTSS), 0);

  // TSS içeriğini doldur
  TSSArr[1].CR3 := PDIR_MEM or 7;
  TSSArr[1].EIP := LongWord(@OSControl);
  TSSArr[1].EFLAGS := $202;
  TSSArr[1].ESP := KERNEL_ESP;
  TSSArr[1].CS := SELOS_CODE;
  TSSArr[1].DS := SELOS_DATA;
  TSSArr[1].ES := SELOS_DATA;
  TSSArr[1].SS := SELOS_DATA;
  TSSArr[1].SS0 := SELOS_DATA;
  TSSArr[1].FS := SELOS_DATA;
  TSSArr[1].GS := SELOS_DATA;

  // not: sistem için CS ve DS selektörleri bilden programı tarafından
  // oluşturuldu. tekrar oluşturmaya gerek yok

  // sistem için TSS selektörünü oluştur
  // access = p, dpl0 0, 1, 0, 0 (non_busy), 1
  // gran = g = 0, 0, 0, avl = 1, limit (4 bit)
  SetGDTEntry(3, LongWord(@TSSArr[1]), SizeOf(TTSS), $89, $10);

  // ilk tss'yi yükle
  // not : tss'nin yükleme işlevi görev geçişini gerçekleştirmez. sadece
  // tss'yi meşgul olarak ayarlar.
  asm
    mov   ax,3*8
    ltr   ax
  end;

  // sistem proses değerlerini set et
  ArrProcesses[1]^.TaskCounter := 0;
  ArrProcesses[1]^.LoadedMemAddr := KernelStartAddr;
  ArrProcesses[1]^.MemSize := KernelSize;
  ArrProcesses[1]^.EvCount := 0;
  ArrProcesses[1]^.EvBuffer := nil;

  // sistem proses adı (dosya adı)
  case RMInfo^.KernelWorkMode of
    1: ArrProcesses[1]^.FName := 'kernelg.bin';
    2: ArrProcesses[1]^.FName := 'kernelt.bin';
    3: ArrProcesses[1]^.FName := 'kernela.bin';
  end;

  // sistem proses'i çalışıyor olarak işaretle
  Process := ArrProcesses[1];
  Process^.SetState(1, psRunning);

  // çalışan ve oluşturulan proses değerlerini belirle
  CreatedProcess := 1;
  RunningProcess := CreatedProcess;
end;

end.
