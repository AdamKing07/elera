{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: eleram.pas
  Program İşlevi: elera işletim sistemi - lazarus programlama dili
    uygulama oluşturma modülü

  Güncelleme Tarihi: 01/04/2020

 ==============================================================================}
unit eleram;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, LazIDEIntf, CompOptsIntf, IDEExternToolIntf, ProjectIntf,
  Controls, IDECommands, Forms;

type
  TGeciciModul = class(TForm)
  end;

  TELERAUygulama = class(TProjectDescriptor)
  public
    constructor Create; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  TELERALDDosyasi = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function CreateSource(const Filename, SourceName,
      ResourceName: string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  TELERATemizlemeDosyasi = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function CreateSource(const Filename, SourceName,
      ResourceName: string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  TELERADerlemeDosyasi = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function CreateSource(const Filename, SourceName,
      ResourceName: string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  TELERAGorselArabirim = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function CreateSource(const Filename: string; const SourceName: string;
      const ResourceName: string): string; override;
    function GetInterfaceUsesSection: string; override;
    function GetInterfaceSource(const Filename: string; const SourceName: string;
      const ResourceName: string): string; override;
    function GetResourceType: TResourceType; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename: string;
      const SourceName: string; const ResourceName : string): string; override;
  end;

procedure Register;

implementation

var
  _ELERAUygulama: TELERAUygulama;
  _ELERALDDosyasi: TELERALDDosyasi;
  _ELERATemizlemeDosyasi: TELERATemizlemeDosyasi;
  _ELERADerlemeDosyasi: TELERADerlemeDosyasi;
  _ELERAGorselArabirim: TELERAGorselArabirim;

procedure Register;
begin

  _ELERAUygulama := TELERAUygulama.Create;
  RegisterProjectDescriptor(_ELERAUygulama);

  _ELERALDDosyasi := TELERALDDosyasi.Create;
  RegisterProjectFileDescriptor(_ELERALDDosyasi);

  _ELERATemizlemeDosyasi := TELERATemizlemeDosyasi.Create;
  RegisterProjectFileDescriptor(_ELERATemizlemeDosyasi);

  _ELERADerlemeDosyasi := TELERADerlemeDosyasi.Create;
  RegisterProjectFileDescriptor(_ELERADerlemeDosyasi);
end;

constructor TELERAUygulama.Create;
begin

  inherited Create;
  Name := 'ELERAUygulama';
end;

function TELERAUygulama.InitProject(AProject: TLazProject): TModalResult;
var
  _AnaSayfa: TLazProjectFile;
  _s: string;
begin

  inherited InitProject(AProject);

  _AnaSayfa := AProject.CreateProjectFile('uygulama1.lpr');
  _AnaSayfa.IsPartOfProject := True;
  AProject.AddFile(_AnaSayfa, False);
  AProject.MainFileID := 0;

  _s := '{  Önemli Not:' + LineEnding +
    LineEnding +
    '    Program dosyalarını, diğer programların bulunduğu elerais\uygulamalar\mod_g ' + LineEnding +
    '    dizininin altında bir klasör altına kaydetmeniz, programın' + LineEnding +
    '    hatasız derlenmesi yönünden faydalı olacaktır.' + LineEnding +
    LineEnding +
    '}' + LineEnding + LineEnding +
    'program uygulama1;' + LineEnding +
    '{==============================================================================' +
    LineEnding +
    LineEnding +
    '  Kodlayan:' + LineEnding +
    '  Telif Bilgisi: haklar.txt dosyasına bakınız' + LineEnding +
    LineEnding +
    '  Program Adı: uygulama1.lpr' + LineEnding +
    '  Program İşlevi:' + LineEnding +
    LineEnding +
    '  Güncelleme Tarihi:' + LineEnding +
    LineEnding +
    ' ==============================================================================}' +
    LineEnding +
    '{$mode objfpc}' + LineEnding + LineEnding +
    'uses gorev, gn_pencere;' + LineEnding +
    LineEnding +
    'const' + LineEnding +
    '  ProgramAdi: string = ''Uygulama1'';' + LineEnding +
    LineEnding +
    'var' + LineEnding +
    '  Gorev0: TGorev;' + LineEnding +
    '  Pencere0: TPencere;' + LineEnding +
    '  OlayKayit: TOlayKayit;' + LineEnding +
    LineEnding +
    'begin' + LineEnding +
    '  Pencere0.Olustur(-1, 100, 100, 300, 200, ptBoyutlandirilabilir, ProgramAdi,' + LineEnding +
    '    RENK_BEYAZ);' + LineEnding +
    '  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir;' + LineEnding +
    LineEnding +
    '  Pencere0.Goster;' + LineEnding +
    LineEnding +
    '  repeat' + LineEnding +
    LineEnding +
    '    Gorev0.OlayBekle(OlayKayit);' + LineEnding +
    '    if(OlayKayit.Olay = FO_TIKLAMA) then' + LineEnding +
    '    begin' + LineEnding +
    LineEnding +
    '    end' + LineEnding +
    '    else if(OlayKayit.Olay = CO_CIZIM) then' + LineEnding +
    '    begin' + LineEnding +
    LineEnding +
    '    end;' + LineEnding +
    '  until (1 = 2);' + LineEnding +
    'end.';

  AProject.MainFile.SetSourceText(_s);

  AProject.Title := 'uygulama1';

  AProject.UseAppBundle := False;
  AProject.UseManifest := False;

  AProject.SessionStorage := pssInProjectInfo;

  AProject.Flags := [pfLRSFilesInOutputDirectory];

  AProject.LazCompilerOptions.OtherUnitFiles := '..\..\rtl_uygulama\linux\units\i386-linux';
  AProject.LazCompilerOptions.IncludePath := '$(ProjOutDir)';
  AProject.LazCompilerOptions.UnitOutputDirectory := 'outlib';
  AProject.LazCompilerOptions.TargetFilename := '..\..\_g\uygulama1.c';
  AProject.LazCompilerOptions.SrcPath := '..\..\rtl_uygulama\linux';

  AProject.LazCompilerOptions.SmartLinkUnit := True;
  AProject.LazCompilerOptions.OptimizationLevel := 0;
  AProject.LazCompilerOptions.TargetOS := 'Linux';
  AProject.LazCompilerOptions.TargetCPU := 'i386';

  AProject.LazCompilerOptions.GenerateDebugInfo := False;
  AProject.LazCompilerOptions.StripSymbols := True;
  AProject.LazCompilerOptions.LinkSmart := True;
  AProject.LazCompilerOptions.Win32GraphicApp := False;
  AProject.LazCompilerOptions.PassLinkerOptions := True;
  AProject.LazCompilerOptions.LinkerOptions := '-Tbagla.ld';

  Result := mrOK;
end;

function TELERAUygulama.CreateStartFiles(AProject: TLazProject): TModalResult;
begin

  Result := inherited CreateStartFiles(AProject);

  if Result <> mrOK then Exit;

  LazarusIDE.DoNewEditorFile(_ELERALDDosyasi, 'bagla.ld', '', [nfCreateDefaultSrc,
    nfIsPartOfProject, nfOpenInEditor]);
  LazarusIDE.DoNewEditorFile(_ELERATemizlemeDosyasi, 'temizle.bat', '', [nfCreateDefaultSrc,
    nfIsPartOfProject, nfOpenInEditor]);
  LazarusIDE.DoNewEditorFile(_ELERADerlemeDosyasi, 'derle.bat', '', [nfCreateDefaultSrc,
    nfIsPartOfProject, nfOpenInEditor]);
end;

function TELERAUygulama.GetLocalizedName: string;
begin

  Result := 'ELERA Uygulaması';
end;

function TELERAUygulama.GetLocalizedDescription: string;
begin

  Result := 'ELERA Uygulaması Oluştur';
end;

constructor TELERALDDosyasi.Create;
begin

  inherited Create;
  Name := 'ELERALDDosyasi';
  DefaultFilename := 'bagla.ld';
  AddToProject := False;
end;

function TELERALDDosyasi.CreateSource(const Filename, SourceName,
  ResourceName: string): string;
var
  _s: string;
begin

  _s := 'OUTPUT_FORMAT("elf32-i386")' + LineEnding +
  LineEnding +
  'SECTIONS' + LineEnding +
  '{' + LineEnding +
  '  .text 0x100:' + LineEnding +
  '  {' + LineEnding +
  '    . = ALIGN(32);' + LineEnding +
  '  }' + LineEnding +
  '  .data :' + LineEnding +
  '  {' + LineEnding +
  '    . = ALIGN(32);' + LineEnding +
  '  }' + LineEnding +
  '  .rodata :' + LineEnding +
  '  {' + LineEnding +
  '    . = ALIGN(32);' + LineEnding +
  '  }' + LineEnding +
  '  .bss :' + LineEnding +
  '  {' + LineEnding +
  '    . = ALIGN(32);' + LineEnding +
  '  }' + LineEnding +
  '}';

  Result:= _s;
end;

function TELERALDDosyasi.GetLocalizedName: string;
begin

  Result := 'ELERA LD Dosyası';
end;

function TELERALDDosyasi.GetLocalizedDescription: string;
begin

  Result := 'ELERA LD Dosyası Oluştur';
end;

constructor TELERATemizlemeDosyasi.Create;
begin

  inherited Create;
  Name := 'ELERATemizlemeDosyasi';
  DefaultFilename := 'temizle.bat';
  AddToProject := False;
end;

function TELERATemizlemeDosyasi.CreateSource(const Filename, SourceName,
  ResourceName: string): string;
var
  _s: string;
begin

  _s := 'del outlib\*.* /Q';
  Result:= _s;
end;

function TELERATemizlemeDosyasi.GetLocalizedName: string;
begin

  Result := 'ELERA Temizleme (bat) Dosyası';
end;

function TELERATemizlemeDosyasi.GetLocalizedDescription: string;
begin

  Result := 'ELERA Temizleme (bat) Dosyası Oluştur';
end;

constructor TELERADerlemeDosyasi.Create;
begin

  inherited Create;
  Name := 'ELERADerlemeDosyasi';
  DefaultFilename := 'derle.bat';
  AddToProject := False;
end;

function TELERADerlemeDosyasi.CreateSource(const Filename, SourceName,
  ResourceName: string): string;
var
  _SL: TStringList;
begin

  _SL := TStringList.Create;

  _SL.Add('@echo off');
  _SL.Add('');
  _SL.Add('PATH=C:\lazarus\fpc\3.0.4\bin\i386-win32');
  _SL.Add('fpc -Tlinux -Pi386 -FUoutlib -Fu..\..\rtl_uygulama\linux\units\i386-linux ' +
    '-Sc -Sg -Si -Sh -CX -Os -Xs -XX -k-Tbagla.ld -o..\..\_g\uygulama1.c uygulama1.lpr');

  _SL.Add('');
  _SL.Add('PATH=C:\lazarus\fpc\3.0.4\bin\x86_64-win64');
  _SL.Add('fpc -Tlinux -Pi386 -FUoutlib -Fu..\..\rtl_uygulama\linux\units\i386-linux ' +
    '-Sc -Sg -Si -Sh -CX -Os -Xs -XX -k-Tbagla.ld -o..\..\_g\uygulama1.c uygulama1.lpr');

  Result:= _SL.Text;

  _SL.Free;
end;

function TELERADerlemeDosyasi.GetLocalizedName: string;
begin

  Result := 'ELERA Derleme (bat) Dosyası';
end;

function TELERADerlemeDosyasi.GetLocalizedDescription: string;
begin

  Result := 'ELERA Derleme (bat) Dosyası Oluştur';
end;

constructor TELERAGorselArabirim.Create;
begin

  inherited Create;

  Name:= 'ELERAGorselArabirim';
  ResourceClass := TGeciciModul;
  UseCreateFormStatements:= True;
end;

function TELERAGorselArabirim.CreateSource(const Filename: string; const SourceName: string;
  const ResourceName: string): string;
begin

  Result:= '';
end;

function TELERAGorselArabirim.GetInterfaceUsesSection: string;
begin

  Result := inherited GetInterfaceUsesSection;
end;

function TELERAGorselArabirim.GetInterfaceSource(const Filename: string; const SourceName: string;
  const ResourceName: string): string;
begin

  Result := '';
end;

function TELERAGorselArabirim.GetResourceType: TResourceType;
begin

  Result := rtRes;
end;

function TELERAGorselArabirim.GetLocalizedName: string;
begin

  Result := 'ELERA Pencere';
end;

function TELERAGorselArabirim.GetLocalizedDescription: string;
begin

  Result := 'ELERA Pencere Nesnesi Oluştur';
end;

function TELERAGorselArabirim.GetImplementationSource(const Filename: string;
  const SourceName: string; const ResourceName : string): string;
begin

  Result := inherited GetImplementationSource(FileName,SourceName,ResourceName);
end;

end.
