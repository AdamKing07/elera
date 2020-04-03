{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2000 by Marco van de Voort
    member of the Free Pascal development team.

    System unit for Linux.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ These things are set in the makefile, }
{ But you can override them here.}
{ If you use an aout system, set the conditional AOUT}
{ $Define AOUT}

unit system;

{*****************************************************************************}
                                    interface
{*****************************************************************************}
{$define FPC_IS_SYSTEM}
{$define HAS_CMDLINE}
{$define USE_NOTHREADMANAGER}

{$i osdefs.inc}

{$I sysunixh.inc}
{$i elerah.inc}
type
  PHiza = ^THiza;
  THiza = (hzYok, hzUst, hzSag, hzAlt, hzSol, hzTum);
  THizalar = set of THiza;

type
  PSecimDurumu = ^TSecimDurumu;
  TSecimDurumu = (sdNormal, sdSecili);

function get_cmdline:Pchar; 
property cmdline:Pchar read get_cmdline;

function HexToStr(Val: LongInt; WritePrefix: LongBool; DivNum: LongInt): string;
function TimeToStr(Buffer: array of Byte): string;
function DateToStr(Buffer: array of Word; GunAdiEkle: Boolean): string;
function StrToHex(Val: string): LongWord;
function UpperCase(s: string): string;
procedure StrPasEx(Src, Dest: Pointer);
function StrPasEx(ASrc: PChar): string;
function ParamCount: LongInt;
function ParamStr(Index: LongInt): string;
function ParamStr1(Index: LongInt): string;
function IntToStr1(Val: LongInt): string;

{$if defined(CPUARM) or defined(CPUM68K) or (defined(CPUSPARC) and defined(VER2_6))}

{$define fpc_softfpu_interface}
{$i softfpu.pp}
{$undef fpc_softfpu_interface}

{$endif defined(CPUARM) or defined(CPUM68K) or (defined(CPUSPARC) and defined(VER2_6))}

{ program �a�r� ba�l�k bilgileri }

  {$i inc/consts.inc}

  {$i inc/ekranb.inc}
  {$i inc/gorselnesneb.inc}
  {$i inc/masaustub.inc}
  {$i inc/gn_pencereb.inc}
  {$i inc/gn_panelb.inc}
  {$i inc/gn_resimdugmeb.inc}
  {$i inc/gn_dugmeb.inc}
  {$i inc/gn_gucdugmeb.inc}
  {$i inc/gn_defterb.inc}
  {$i inc/gn_listekutusub.inc}
  {$i inc/listegorunumh.inc}
  {$i inc/gn_menub.inc}
  {$i inc/gn_islemgostergesib.inc}
  {$i inc/gn_onaykutusub.inc}
  {$i inc/gn_giriskutusub.inc}
  {$i inc/gn_degerdugmesib.inc}
  {$i inc/gn_etiketb.inc}
  {$i inc/gn_durumcubugub.inc}
  {$i inc/gn_secimdugmeb.inc}
  {$i inc/gn_baglantib.inc}
  {$i inc/gn_kaydirmacubugub.inc}
  {$i inc/olayb.inc}
  {$i inc/dosyab.inc}
  {$i inc/yazimb.inc}
  {$i inc/counterh.inc}
  {$i inc/sistemb.inc}
  {$i inc/cizimb.inc}
  {$i inc/sistemmesajb.inc}
//  {$i inc/memoryh.inc}
  {$i inc/gorevb.inc}
  {$i inc/pcib.inc}
  {$i inc/fareb.inc}
  
{*****************************************************************************}
                                 implementation
{*****************************************************************************}

const
  HexVal: PChar = ('0123456789ABCDEF');

{$asmmode intel}
procedure MoveEx(Src, Dest: Pointer; Size: LongInt); assembler;
asm

  pushad
  mov esi,Src
  mov edi,Dest
  mov ecx,Size
  cld
  rep movsb
  popad
end;
{$asmmode att}

{==============================================================================
  saat de�erini string de�ere d�n��t�r�r
 ==============================================================================}
function TimeToStr(Buffer: array of Byte): string;
begin

  // array[0] = saat
  // array[1] = dakika
  // array[2] = saniye
  SetLength(Result, 8);

  // saat de�erini string'e �evir
  if(Buffer[0] > 9) then
    Result := IntToStr1(Buffer[0])
  else Result := '0' + IntToStr1(Buffer[0]);
  Result += ':';

  // dakika de�erini string'e �evir
  if(Buffer[1] > 9) then
    Result += IntToStr1(Buffer[1])
  else Result += '0' + IntToStr1(Buffer[1]);
  Result += ':';

  // saniye de�erini string'e �evir
  if(Buffer[2] > 9) then
    Result += IntToStr1(Buffer[2])
  else Result += '0' + IntToStr1(Buffer[2]);
end;

{==============================================================================
  saat de�erini string de�ere d�n��t�r�r
 ==============================================================================}
function DateToStr(Buffer: array of Word; GunAdiEkle: Boolean): string;
const
  Gunler: array[0..6] of string = ('Pz', 'Pt', 'Sa', '�a', 'Pe', 'Cu', 'Ct');
begin

  // array[0] = g�n
  // array[1] = ay
  // array[2] = y�l
  // array[3] = haftan�n g�n�
  if(GunAdiEkle) then
    SetLength(Result, 13)
  else SetLength(Result, 10);

  // g�n de�erini string'e �evir
  if(Buffer[0] > 9) then
    Result := IntToStr1(Buffer[0])
  else Result := '0' + IntToStr1(Buffer[0]);
  Result += '.';

  // ay de�erini string'e �evir
  if(Buffer[1] > 9) then
    Result += IntToStr1(Buffer[1])
  else Result += '0' + IntToStr1(Buffer[1]);

  if(GunAdiEkle) then
  begin

    Result += '.';
    Result += IntToStr1(Buffer[2]) + ' ';
    Result += Gunler[Buffer[3]];
  end
  else
  begin

    Result += '.';
    Result += IntToStr1(Buffer[2]);
  end;
end;

{==============================================================================
  hexadesimal say� de�erini string de�ere d�n��t�r�r
 ==============================================================================}
function HexToStr(Val: LongInt; WritePrefix: LongBool; DivNum: LongInt): string;
var
  i: Byte;
  p: PChar;
begin

  p := @Result;

  // e�er �n ek varsa ekle ve yerle�tirilecek say�sal de�erin
  // en sonuna konumlan
  if(WritePrefix) then
  begin

    SetLength(Result, DivNum + 2);
    p[1] := '0';
    p[2] := 'x';
    Inc(p, DivNum + 2);
  end
  else
  begin

    SetLength(Result, DivNum);
    Inc(p, DivNum);
  end;

  // say�sal de�eri sondan ba�a do�ru belle�e yerle�tir
  for i := 0 to DivNum - 1 do
  begin

    p^ := HexVal[(Val shr (i * 4) and $F)];
    Dec(p);
  end;
end;

{==============================================================================
  string de�eri hexadesimal say� de�erine d�n��t�r�r
 ==============================================================================}
function StrToHex(Val: string): LongWord;
var
  i: LongInt;
  s: string;
begin

  Result := 0;
  if(Length(Val) > 0) then
  begin

    s := UpperCase(Val);
    for i := 1 to Length(s) do
    begin

      Result := Result shl 4;
      case s[i] of
        '0'..'9': begin Result := Result + Ord(s[i]) - 48 end;
        'A'..'F': begin Result := Result + Ord(s[i]) - 55 end;
      end;
    end;
  end;
end;

{==============================================================================
  string de�eri b�y�k harfe �evirir
 ==============================================================================}
function UpperCase(s: string): string;
var
  i: Integer;
  C: Char;
begin

  if(Length(s) > 0) then
  begin

    Result := '';
    for i := 1 to Length(s) do
    begin

      C := s[i];
    	if(C in [#97..#122]) then
        Result := Result + Char(Byte(C) - 32)
      else Result := Result + C;
    end;
  end else Result := '';
end;

{ program �a�r� kod bilgileri }

				 {$asmmode intel}
				 {$I elera.inc}

				 {$i inc/ekran.inc}
         {$i inc/gorselnesne.inc}
				 {$i inc/masaustu.inc}
				 {$i inc/gn_pencere.inc}
         {$i inc/gn_panel.inc}
         {$i inc/gn_resimdugme.inc}
				 {$i inc/gn_dugme.inc}
				 {$i inc/gn_gucdugme.inc}
         {$i inc/gn_defter.inc}
				 {$i inc/gn_listekutusu.inc}
         {$i inc/listegorunum.inc}
				 {$i inc/gn_menu.inc}
				 {$i inc/gn_islemgostergesi.inc}
				 {$i inc/gn_onaykutusu.inc}
         {$i inc/gn_giriskutusu.inc}
         {$i inc/gn_degerdugmesi.inc}
         {$i inc/gn_etiket.inc}
         {$i inc/gn_durumcubugu.inc}
         {$i inc/gn_secimdugme.inc}
         {$i inc/gn_baglanti.inc}
         {$i inc/gn_kaydirmacubugu.inc}
				 {$i inc/olay.inc}
				 {$i inc/dosya.inc}
				 {$i inc/yazim.inc}
				 {$i inc/counter.inc}
         {$i inc/sistem.inc}
				 {$i inc/cizim.inc}
				 {$i inc/sistemmesaj.inc}
//				 {$i inc/memory.inc}
				 {$i inc/gorev.inc}
				 {$i inc/pci.inc}
				 {$i inc/fare.inc}

				 {$asmmode att}
				 
{$if defined(CPUI386) and not defined(FPC_USE_LIBC)}
var
  sysenter_supported: LongInt = 0;
{$endif}

const calculated_cmdline:Pchar=nil;

{$if defined(CPUARM) or defined(CPUM68K) or (defined(CPUSPARC) and defined(VER2_6))}

{$define fpc_softfpu_implementation}
{$i softfpu.pp}
{$undef fpc_softfpu_implementation}

{ we get these functions and types from the softfpu code }
{$define FPC_SYSTEM_HAS_float64}
{$define FPC_SYSTEM_HAS_float32}
{$define FPC_SYSTEM_HAS_flag}
{$define FPC_SYSTEM_HAS_extractFloat64Frac0}
{$define FPC_SYSTEM_HAS_extractFloat64Frac1}
{$define FPC_SYSTEM_HAS_extractFloat64Exp}
{$define FPC_SYSTEM_HAS_extractFloat64Sign}
{$define FPC_SYSTEM_HAS_ExtractFloat32Frac}
{$define FPC_SYSTEM_HAS_extractFloat32Exp}
{$define FPC_SYSTEM_HAS_extractFloat32Sign}

{$endif defined(CPUARM) or defined(CPUM68K) or (defined(CPUSPARC) and defined(VER2_6))}

{$I system.inc}

{$ifdef android}
{$I sysandroid.inc}
{$endif android}

{*****************************************************************************
                       Misc. System Dependent Functions
*****************************************************************************}

{$if defined(CPUARM) and defined(FPC_ABI_EABI)}
procedure haltproc(e:longint);cdecl;external name '_haltproc_eabi';
{$else}
procedure haltproc(e:longint);cdecl;external name '_haltproc';
{$endif}

{$ifdef FPC_USE_LIBC}
function  FpPrCtl(options : cInt; const args : ptruint) : cint; cdecl; external clib name 'prctl';
{$endif}

procedure System_exit;
begin
  haltproc(ExitCode);
End;

{function BackPos(c:char; const s: shortstring): integer;
var
 i: integer;
Begin
  for i:=length(s) downto 0 do
    if s[i] = c then break;
  if i=0 then
    BackPos := 0
  else
    BackPos := i;
end;}


 { variable where full path and filename and executable is stored }
 { is setup by the startup of the system unit.                    }
var
 execpathstr : shortstring;

function ParamCount: LongInt;
begin

  Result := PLongWord(0)^;
end;

function ParamStr(Index: LongInt): string;
var
  i, j: LongInt;
  p: PChar;
begin

  i := ParamCount;

  Result := '';
  if(Index < 0) or (Index > i) then Exit;

  if(Index = 0) then
  begin

    Result := StrPasEx(Pointer(4));
    //Exit;
  end;

  {j := 0;
  p := PChar(4);

  while not(Index = j) do
  begin

    while (p^ <> #0) do begin Inc(p); end;

    Inc(p);
    Inc(j);
  end;

  Result := StrPasEx(p);}
end;

function ParamStr1(Index: LongInt): string;
var
  i, j: LongInt;
  p: PChar;
begin

  i := ParamCount;

  Result := '';
  if(Index < 0) or (Index > i) then Exit;

  if(Index = 0) then
  begin

    Result := StrPasEx(PChar(4));
    Exit;
  end;

  j := 0;
  p := PChar(4);

  while not(Index = j) do
  begin

    while (p^ <> #0) do begin Inc(p); end;

    Inc(p);
    Inc(j);
  end;

  Result := StrPasEx(p);
end;

{==============================================================================
  desimal say� de�erini string de�ere d�n��t�r�r
 ==============================================================================}
function IntToStr1(Val: LongInt): string;
var
	p: PChar;
  Buf: array[0..11] of Char;
  Minus: Boolean;
  Digit: LongInt;
  Value: LongInt;
begin

  // 32 bit maximum say� = 4294967295 - on hane

  // hane say�s�n� s�f�rla
  Digit := 0;

  // de�erlerin yerle�tirilece�i belle�in en son k�sm�na konumlan
  p := @Buf[11];

  // say�sal de�er negatif mi ? pozitif mi ?
	if (Val < 0) then
	begin

		Value := -Val;
		Minus := True;
	end
	else
	begin

		Value := Val;
		Minus := False;
	end;

  // say�sal de�eri �evir
	repeat

		p^ := Char((Value mod 10) + Byte('0'));
		Value := Value div 10;
    Inc(Digit);
		Dec(p);
	until (Value = 0);

  // say�sal de�er negatif ise - i�aretini de ekle
	if(Minus) then
	begin

		PChar(p)^ := '-';
    Inc(Digit);
	end;

  // de�eri hedef b�lgeye kopyala
  MoveEx(@Buf[11-Digit+1], @Result[1], Digit);
  SetLength(Result, Digit);
end;


procedure StrPasEx(Src, Dest: Pointer);
var
  p, p2: PChar;
  i: Byte;
begin

  i := 0;
  p := Src;
  p2 := PChar(Dest);
  while (p^ <> #0) do
  begin

    Inc(i);
    p2^ := p^;
    Inc(p);
    Inc(p2);
  end;
  PByte(Dest)^ := i;
end;

function StrPasEx(ASrc: PChar): string;
var
  Src, Dest: PChar;
  i: Byte;
begin

  i := 0;
  Src := ASrc;
  Dest := @Result[1];

  while (Src^ <> #0) do
  begin

    Dest^ := Src^;
    Inc(Src);
    Inc(Dest);
    Inc(i);
  end;
  SetLength(Result, i);
end;

Procedure Randomize;
Begin
  //randseed:=longint(Fptime(nil));
End;

{*****************************************************************************
                                    cmdline
*****************************************************************************}

procedure SetupCmdLine;
var
  bufsize,
  len,j,
  size,i : longint;
  found  : boolean;
  buf    : pchar;

  procedure AddBuf;
  begin
    reallocmem(calculated_cmdline,size+bufsize);
    move(buf^,calculated_cmdline[size],bufsize);
    inc(size,bufsize);
    bufsize:=0;
  end;

begin
  if argc<=0 then
    exit;
  GetMem(buf,ARG_MAX);
  size:=0;
  bufsize:=0;
  i:=0;
  while (i<argc) do
   begin
     len:=strlen(argv[i]);
     if len>ARG_MAX-2 then
      len:=ARG_MAX-2;
     found:=false;
     for j:=1 to len do
      if argv[i][j]=' ' then
       begin
         found:=true;
         break;
       end;
     found:=found or (len=0); // also quote if len=0, bug 19114
     if bufsize+len>=ARG_MAX-2 then
      AddBuf;
     if found then
      begin
        buf[bufsize]:='"';
        inc(bufsize);
      end;
     if len>0 then
       begin
         move(argv[i]^,buf[bufsize],len);
         inc(bufsize,len);
       end;
     if found then
      begin
        buf[bufsize]:='"';
        inc(bufsize);
      end;
     if i<argc-1 then
      buf[bufsize]:=' '
     else
      buf[bufsize]:=#0;
     inc(bufsize);
     inc(i);
   end;
  AddBuf;
  FreeMem(buf,ARG_MAX);
end;

function get_cmdline:Pchar;

begin
  if calculated_cmdline=nil then
    setupcmdline;
  get_cmdline:=calculated_cmdline;
end;

{*****************************************************************************
                         SystemUnit Initialization
*****************************************************************************}

function  reenable_signal(sig : longint) : boolean;
var
  e : TSigSet;
  i,j : byte;
  olderrno: cint;
begin
  fillchar(e,sizeof(e),#0);
  { set is 1 based PM }
  dec(sig);
  i:=sig mod (sizeof(cuLong) * 8);
  j:=sig div (sizeof(cuLong) * 8);
  e[j]:=1 shl i;
  { this routine is called from a signal handler, so must not change errno }
  olderrno:=geterrno;
  fpsigprocmask(SIG_UNBLOCK,@e,nil);
  reenable_signal:=geterrno=0;
  seterrno(olderrno);
end;

// signal handler is arch dependant due to processorexception to language
// exception translation

{$i sighnd.inc}

procedure InstallDefaultSignalHandler(signum: longint; out oldact: SigActionRec); public name '_FPC_INSTALLDEFAULTSIGHANDLER';
var
  act: SigActionRec;
begin
  { Initialize the sigaction structure }
  { all flags and information set to zero }
  FillChar(act, sizeof(SigActionRec),0);
  { initialize handler                    }
  act.sa_handler := SigActionHandler(@SignalToRunError);
  act.sa_flags:=SA_SIGINFO;
  FpSigAction(signum,@act,@oldact);
end;

var
  oldsigfpe: SigActionRec; public name '_FPC_OLDSIGFPE';
  oldsigsegv: SigActionRec; public name '_FPC_OLDSIGSEGV';
  oldsigbus: SigActionRec; public name '_FPC_OLDSIGBUS';
  oldsigill: SigActionRec; public name '_FPC_OLDSIGILL';

Procedure InstallSignals;
begin
  InstallDefaultSignalHandler(SIGFPE,oldsigfpe);
  InstallDefaultSignalHandler(SIGSEGV,oldsigsegv);
  InstallDefaultSignalHandler(SIGBUS,oldsigbus);
  InstallDefaultSignalHandler(SIGILL,oldsigill);
end;

procedure SysInitStdIO;
begin
  OpenStdIO(Input,fmInput,StdInputHandle);
  OpenStdIO(Output,fmOutput,StdOutputHandle);
  OpenStdIO(ErrOutput,fmOutput,StdErrorHandle);
  OpenStdIO(StdOut,fmOutput,StdOutputHandle);
  OpenStdIO(StdErr,fmOutput,StdErrorHandle);
end;

Procedure RestoreOldSignalHandlers;
begin
  FpSigAction(SIGFPE,@oldsigfpe,nil);
  FpSigAction(SIGSEGV,@oldsigsegv,nil);
  FpSigAction(SIGBUS,@oldsigbus,nil);
  FpSigAction(SIGILL,@oldsigill,nil);
end;


procedure SysInitExecPath;
var
  i    : longint;
begin
  execpathstr[0]:=#0;
  i:=Fpreadlink('/proc/self/exe',@execpathstr[1],high(execpathstr));
  { it must also be an absolute filename, linux 2.0 points to a memory
    location so this will skip that }
  if (i>0) and (execpathstr[1]='/') then
     execpathstr[0]:=char(i);
end;

function GetProcessID: SizeUInt;
begin
 GetProcessID := SizeUInt (fpGetPID);
end;

{$ifdef FPC_USE_LIBC}
{$ifdef HAS_UGETRLIMIT}
    { there is no ugetrlimit libc call, just map it to the getrlimit call in these cases }
function FpUGetRLimit(resource : cInt; rlim : PRLimit) : cInt; cdecl; external clib name 'getrlimit';
{$endif}
{$endif}

function CheckInitialStkLen(stklen : SizeUInt) : SizeUInt;
var
  limits : TRLimit;
  success : boolean;
begin
  success := false;
  fillchar(limits, sizeof(limits), 0);
  {$ifdef has_ugetrlimit}
  success := fpugetrlimit(RLIMIT_STACK, @limits)=0;
  {$endif}
  {$ifndef NO_SYSCALL_GETRLIMIT}
  if (not success) then
    success := fpgetrlimit(RLIMIT_STACK, @limits)=0;
  {$endif}
  if (success) and (limits.rlim_cur < stklen) then
    result := limits.rlim_cur
  else
    result := stklen;
end;

var
  initialstkptr : Pointer;external name '__stkptr';
begin
{$if defined(i386) and not defined(FPC_USE_LIBC)}
  InitSyscallIntf;
{$endif}

{$ifndef FPUNONE}
{$if defined(cpupowerpc)}
  // some PPC kernels set the exception bits FE0/FE1 in the MSR to zero,
  // disabling all FPU exceptions. Enable them again.
  fpprctl(PR_SET_FPEXC, PR_FP_EXC_PRECISE);
{$endif}
{$endif}
  IsConsole := TRUE;
  StackLength := CheckInitialStkLen(initialStkLen);
  StackBottom := initialstkptr - StackLength;
  { Set up signals handlers (may be needed by init code to test cpu features) }
  InstallSignals;
{$if defined(cpui386) or defined(cpuarm)}
  fpc_cpucodeinit;
{$endif cpui386}

  { Setup heap }
  InitHeap;
  SysInitExceptions;
  initunicodestringmanager;
  { Setup stdin, stdout and stderr }
  SysInitStdIO;
  { Arguments }
  SysInitExecPath;
  { Reset IO Error }
  InOutRes:=0;
  { threading }
  InitSystemThreads;
  { restore original signal handlers in case this is a library }
  if IsLibrary then
    RestoreOldSignalHandlers;
end.
