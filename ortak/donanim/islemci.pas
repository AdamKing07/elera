{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: islemci.pas
  Dosya İşlevi: işlemci (cpu) işlevlerini içerir

  Güncelleme Tarihi: 15/09/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit islemci;

interface

uses paylasim;

function IslemciSaticisiniAl: string;
procedure IslemciOzellikleriniAl1(var _EAX, _EDX, _ECX: TSayi4);

implementation

{==============================================================================
  işlemci satıcı bilgisini alır
 ==============================================================================}
function IslemciSaticisiniAl: string;
begin

  asm
    pushad

    xor eax,eax
    cpuid

    mov edi,Result
    mov al,12             // bilgi uzunluğu, string tip
    mov [edi+00],al
    mov [edi+01],ebx
    mov [edi+05],edx
    mov [edi+09],ecx

    popad
  end;
end;

{==============================================================================
  işlemci bilgisi ve özelliklerini döndürür
  https://en.wikipedia.org/wiki/CPUID adresinden ayrıntılı bilgilere bakılabilir.
 ==============================================================================}
procedure IslemciOzellikleriniAl1(var _EAX, _EDX, _ECX: TSayi4);
var
  _reg_eax, _reg_edx,
  _reg_ecx: TSayi4;
begin

  asm
    pushad

    xor eax,eax
    inc eax
    cpuid

    lea edi,_reg_eax;
    mov [edi],eax
    lea edi,_reg_edx;
    mov [edi],edx
    lea edi,_reg_ecx;
    mov [edi],ecx

    popad
  end;

  _EAX := _reg_eax;
  _EDX := _reg_edx;
  _ECX := _reg_ecx;
end;

end.
