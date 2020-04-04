{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: idt.pas
  Dosya İşlevi: kesme servis rutinlerini (isr) içerir

  Güncelleme Tarihi: 04/04/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit idt;
 
interface

uses paylasim;

const
  USTSINIR_IDT = $35;

type
  PYazmaclar0 = ^TYazmaclar0;
  TYazmaclar0 = packed record
    DS, ES, SS, FS, GS,
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: TSayi4;
    ISRNo, EIP, CS, EFLAGS, OrjESP: TSayi4;
  end;

type
  PYazmaclar1 = ^TYazmaclar1;
  TYazmaclar1 = packed record
    DS, ES, SS, FS, GS,
    EDI, ESI, EBP, ESP, EBX, EDX, ECX, EAX: TSayi4;
    ISRNo, HataKodu, EIP, CS, EFLAGS, OrjESP: TSayi4;
  end;

type
  PIDTGirdisi = ^TIDTGirdisi;
  TIDTGirdisi = packed record
    BaslangicAdresi00_15: TSayi2;
    Secici: TSayi2;
    Sifir: TSayi1;
    Bayrak: TSayi1;
    BaslangicAdresi16_31: TSayi2;
  end;

var
  IDTYazmac: TIDTYazmac;
  IDTGirdiListesi: array[0..$34] of TIDTGirdisi;

procedure Yukle;
procedure KesmeGirisiBelirle(AGirdiNo: TSayi4; ABaslangicAdresi: Isaretci;
  ASecici: TSayi2; ABayrak: TSayi1);
procedure KesmeIslevi00;
procedure KesmeIslevi01;
procedure KesmeIslevi02;
procedure KesmeIslevi03;
procedure KesmeIslevi04;
procedure KesmeIslevi05;
procedure KesmeIslevi06;
procedure KesmeIslevi07;
procedure KesmeIslevi08;
procedure KesmeIslevi09;
procedure KesmeIslevi0A;
procedure KesmeIslevi0B;
procedure KesmeIslevi0C;
procedure KesmeIslevi0D;
procedure KesmeIslevi0E;
procedure KesmeIslevi0F;
procedure KesmeIslevi10;
procedure KesmeIslevi11;
procedure KesmeIslevi12;
procedure KesmeIslevi13;
procedure KesmeIslevi14;
procedure KesmeIslevi15;
procedure KesmeIslevi16;
procedure KesmeIslevi17;
procedure KesmeIslevi18;
procedure KesmeIslevi19;
procedure KesmeIslevi1A;
procedure KesmeIslevi1B;
procedure KesmeIslevi1C;
procedure KesmeIslevi1D;
procedure KesmeIslevi1E;
procedure KesmeIslevi1F;
procedure KesmeIslevi30;
procedure KesmeIslevi31;
procedure KesmeIslevi32;
procedure KesmeIslevi33;
procedure KesmeIslevi35;
procedure YazmacDurumunuGoruntule1(AYazmaclar0: PYazmaclar0);
procedure YazmacDurumunuGoruntule2(AYazmaclar1: PYazmaclar1);

implementation

uses genel, kesme34, gorev, yonetim;

{==============================================================================
  kesme girişlerini belirler ve IDTYazmac'ı yükler
 ==============================================================================}
procedure Yukle;
begin

  // IDTYazmac yazmacının limit ve ilk giriş noktasını belirle
  IDTYazmac.Uzunluk := (SizeOf(TIDTGirdisi) * USTSINIR_IDT) - 1;    // limit = limit - 1
  IDTYazmac.Baslangic := TSayi4(@IDTGirdiListesi);                  // base address (32 bit)

  // istisnalar - exceptions
  // %10001110 = 1 = mevcut, 00 = DPL0, 0, 1 = 32 bit kod, 110 - kesme kapısı
  KesmeGirisiBelirle($00, @KesmeIslevi00, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($01, @KesmeIslevi01, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($02, @KesmeIslevi02, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($03, @KesmeIslevi03, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($04, @KesmeIslevi04, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($05, @KesmeIslevi05, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($06, @KesmeIslevi06, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($07, @KesmeIslevi07, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($08, @KesmeIslevi08, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($09, @KesmeIslevi09, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0A, @KesmeIslevi0A, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0B, @KesmeIslevi0B, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0C, @KesmeIslevi0C, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0D, @KesmeIslevi0D, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0E, @KesmeIslevi0E, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($0F, @KesmeIslevi0F, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($10, @KesmeIslevi10, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($11, @KesmeIslevi11, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($12, @KesmeIslevi12, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($13, @KesmeIslevi13, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($14, @KesmeIslevi14, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($15, @KesmeIslevi15, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($16, @KesmeIslevi16, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($17, @KesmeIslevi17, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($18, @KesmeIslevi18, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($19, @KesmeIslevi19, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1A, @KesmeIslevi1A, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1B, @KesmeIslevi1B, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1C, @KesmeIslevi1C, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1D, @KesmeIslevi1D, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1E, @KesmeIslevi1E, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($1F, @KesmeIslevi1F, SECICI_SISTEM_KOD * 8, %10001110);

  // yazılım kesmeleri
  KesmeGirisiBelirle($30, @KesmeIslevi30, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($31, @KesmeIslevi31, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($32, @KesmeIslevi32, SECICI_SISTEM_KOD * 8, %10001110);
  KesmeGirisiBelirle($33, @KesmeIslevi33, SECICI_SISTEM_KOD * 8, %10001110);

  // sistem ana kesmesi
  // %11101110 = 1 = mevcut, 11 = DPL3, 0, 1 = 32 bit kod, 110 - kesme kapısı
  KesmeGirisiBelirle($34, @Kesme34CagriIslevleri, SECICI_SISTEM_KOD * 8, %11101110);

  // IDTYazmac'ı yükle
  asm
    lidt  [IDTYazmac]
  end;
end;

{==============================================================================
  IDT giriş noktalarını belirler
 ==============================================================================}
procedure KesmeGirisiBelirle(AGirdiNo: TSayi4; ABaslangicAdresi: Isaretci;
  ASecici: TSayi2; ABayrak: TSayi1);
var
  _BaslangicAdresi: TSayi4;
begin
{
      +-----------------------------------------------------+
      |31                    16|15                        00|  bit değerleri 00-31
      +------------------------+----------------------------+
      |   Seçici (selector)    | BaslangicAdresi 15..00     |
      +------------------------+----------------------------+

      +------------------------------+---------+------+-----+
      |63                          48|47     43|    37|   32|
      +------------------------------+-+-+-+-+-+------+-----+
      |       Başlangıç: 31-16       |P|DPL|0|D|110000|     |  bit değerleri 32-63
      +------------------------------+-+-+-+-+|+------+--|--+
                        D = 1 = 32 bit kod  <-+          +-> kullanılmıyor
}

  _BaslangicAdresi := TSayi4(ABaslangicAdresi);

  // temel bellek adresi (ABaslangicAdresi) - IDT: 15..00
  IDTGirdiListesi[AGirdiNo].BaslangicAdresi00_15 := (_BaslangicAdresi and $FFFF);

  // temel bellek adresi (ABaslangicAdresi) - IDT: 63..48
  IDTGirdiListesi[AGirdiNo].BaslangicAdresi16_31 := (_BaslangicAdresi shr 16) and $FFFF;

  // seçici - IDT: 31..16
  IDTGirdiListesi[AGirdiNo].Secici := ASecici;

  // 000 kullanılmıyor - IDT: 39..32
  IDTGirdiListesi[AGirdiNo].Sifir := 0;

  // P, DPL, S, TYPE - IDT: 47..40
  IDTGirdiListesi[AGirdiNo].Bayrak := ABayrak;
end;

{==============================================================================
  içsel kesmeler (exceptions) - int00..int1F
 ==============================================================================}

{==============================================================================
  KesmeIslevi00
 ==============================================================================}
procedure KesmeIslevi00; nostackframe; assembler;

  // not : sistemin stabilizasyonu için ileride yeniden yazılacak
asm

  // tüm kesmeleri durdur
  cli

  // hata kodunu yığına at
  push  dword $00

  // tüm genel yazmaçları yığına at
  pushad

  // segment yazmaçlarını yığına at
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax

  // ds ve es yazmaçlarını sistem yazmaçlarına ayarla
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  // tüm bilgileri ekrana dök
  mov eax,esp
  call  YazmacDurumunuGoruntule1

  // EOI - kesme sonu, bir sonraki kesmeden devam et mesajı
  mov   al,$20
  out   PIC1_KOMUT,al

  // saklanan ds yazmacını yığından al ve eski konumuna geri getir
  pop   eax
  mov   ds,ax
  mov   es,ax

  // es, ss, fs, gs yazmacı yığından alınıyor
  add   esp,4 * 4

  // genel yazmaçlar yığından alınıyor
  popad

  // hata kodu yığından alınıyor
  add   esp,4

  // kesmeleri aktifleştir ve çık
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi01
 ==============================================================================}
procedure KesmeIslevi01; nostackframe; assembler;
asm
  cli
  push  dword $01
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi02
 ==============================================================================}
procedure KesmeIslevi02; nostackframe; assembler;
asm
  cli
  push  dword $02
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi03
 ==============================================================================}
procedure KesmeIslevi03; nostackframe; assembler;
asm
  cli
  push  dword $03
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi04
 ==============================================================================}
procedure KesmeIslevi04; nostackframe; assembler;
asm
  cli
  push  dword $04
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi05
 ==============================================================================}
procedure KesmeIslevi05; nostackframe; assembler;
asm
  cli
  push  dword $05
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi06
 ==============================================================================}
procedure KesmeIslevi06; nostackframe; assembler;
asm
  cli
  push  dword $06
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

// programı sonlandır
  mov eax,CalisanGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov eax,12
  mov edx,[esi+TGorev.FGorevKimlik]
  call  [esi+TGorev.Sonlandir]

@@loop:
  jmp @@loop

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi07
 ==============================================================================}
procedure KesmeIslevi07; nostackframe; assembler;
asm
  cli
  pushad
  pushfd
  xor   eax,eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  { TODO : yapılandırılacak }
  clts

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  popfd
  popad
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi08
 ==============================================================================}
procedure KesmeIslevi08; nostackframe; assembler;
asm
  cli
  push  dword $08
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule2

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4     //IsrNum + ErrCode
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi09
 ==============================================================================}
procedure KesmeIslevi09; nostackframe; assembler;
asm
  cli
  push  dword $09
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi0A - Invalid TSS
 ==============================================================================}
procedure KesmeIslevi0A; nostackframe; assembler;
asm
  cli
  push  dword $0A
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

// programı sonlandır
  mov eax,CalisanGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov ecx,$A
  mov edx,[esi+TGorev.FGorevKimlik]
  //mov edx,CalisanGorev
  mov eax,TGorev.Sonlandir
  call eax

  mov eax,SistemAnaKontrol
  jmp eax

  mov eax,esp
  call  YazmacDurumunuGoruntule2

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi0B
 ==============================================================================}
procedure KesmeIslevi0B; nostackframe; assembler;
asm
  cli
  push  dword $0B
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule2

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi0C - Stack Exception
 ==============================================================================}
procedure KesmeIslevi0C; nostackframe; assembler;
asm
  cli
  push  dword $0C
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

// programı sonlandır
  mov eax,CalisanGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov ecx,$C
  mov edx,[esi+TGorev.FGorevKimlik]
  //mov edx,CalisanGorev
  mov eax,TGorev.Sonlandir
  call eax

  mov eax,SistemAnaKontrol
  jmp eax

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi0D - General Protection Exception
 ==============================================================================}
procedure KesmeIslevi0D; nostackframe; assembler;
asm
  cli

  push  dword $0D
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

// programı sonlandır
  mov eax,CalisanGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov ecx,$D
  mov edx,[esi+TGorev.FGorevKimlik]
  //mov edx,CalisanGorev
  mov eax,TGorev.Sonlandir
  call eax

  mov eax,SistemAnaKontrol
  jmp eax

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4*4
  popad
  add   esp,2*4
  sti
  iretd
//end;
end;

{==============================================================================
  KesmeIslevi0E
 ==============================================================================}
procedure KesmeIslevi0E; nostackframe; assembler;
asm
  cli
  push  dword $0E
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule2

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi0F
 ==============================================================================}
procedure KesmeIslevi0F; nostackframe; assembler;
asm
  cli
  push  dword $0F
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi10
 ==============================================================================}
procedure KesmeIslevi10; nostackframe; assembler;
asm
  cli
  push  dword $10
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi11
 ==============================================================================}
procedure KesmeIslevi11; nostackframe; assembler;
asm
  cli
  push  dword $11
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule2

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,2 * 4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi12
 ==============================================================================}
procedure KesmeIslevi12; nostackframe; assembler;
asm
  cli
  push  dword $12
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi13
 ==============================================================================}
procedure KesmeIslevi13; nostackframe; assembler;
asm
  cli
  push  dword $13
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi14
 ==============================================================================}
procedure KesmeIslevi14; nostackframe; assembler;
asm
  cli
  push  dword $14
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi15
 ==============================================================================}
procedure KesmeIslevi15; nostackframe; assembler;
asm
  cli
  push  dword $15
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi16
 ==============================================================================}
procedure KesmeIslevi16; nostackframe; assembler;
asm
  cli
  push  dword $16
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi17
 ==============================================================================}
procedure KesmeIslevi17; nostackframe; assembler;
asm
  cli
  push  dword $17
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi18
 ==============================================================================}
procedure KesmeIslevi18; nostackframe; assembler;
asm
  cli
  push  dword $18
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi19
 ==============================================================================}
procedure KesmeIslevi19; nostackframe; assembler;
asm
  cli
  push  dword $19
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1A
 ==============================================================================}
procedure KesmeIslevi1A; nostackframe; assembler;
asm
  cli
  push  dword $1A
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1B
 ==============================================================================}
procedure KesmeIslevi1B; nostackframe; assembler;
asm
  cli
  push  dword $1B
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1C
 ==============================================================================}
procedure KesmeIslevi1C; nostackframe; assembler;
asm
  cli
  push  dword $1C
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1D
 ==============================================================================}
procedure KesmeIslevi1D; nostackframe; assembler;
asm
  cli
  push  dword $1D
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1E
 ==============================================================================}
procedure KesmeIslevi1E; nostackframe; assembler;
asm
  cli
  push  dword $1E
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi1F
 ==============================================================================}
procedure KesmeIslevi1F; nostackframe; assembler;
asm
  cli
  push  dword $1F
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  mov   al,$20
  out   PIC1_KOMUT,al
  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  yazılım kesmeleri - int30..int34
 ==============================================================================}

{==============================================================================
  KesmeIslevi30
 ==============================================================================}
procedure KesmeIslevi30; nostackframe; assembler;
asm
  cli
  push  dword $30
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi31
 ==============================================================================}
procedure KesmeIslevi31; nostackframe; assembler;
asm
  cli
  push  dword $31
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi32
 ==============================================================================}
procedure KesmeIslevi32; nostackframe; assembler;
asm
  cli
  push  dword $32
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

{==============================================================================
  KesmeIslevi33
 ==============================================================================}
procedure KesmeIslevi33; nostackframe; assembler;
asm
  cli
  push  dword $33
  pushad
  xor   eax,eax
  mov   ax,gs
  push  eax
  mov   ax,fs
  push  eax
  mov   ax,ss
  push  eax
  mov   ax,es
  push  eax
  mov   ax,ds
  push  eax
  mov   ax,SECICI_SISTEM_VERI * 8
  mov   ds,ax
  mov   es,ax

  mov eax,esp
  call  YazmacDurumunuGoruntule1

  pop   eax
  mov   ds,ax
  mov   es,ax
  add   esp,4 * 4
  popad
  add   esp,4
  sti
  iretd
end;

var
  YaziModGorevYigini: Isaretci;

procedure KesmeIslevi35; nostackframe; assembler;
asm

  // tüm yazmaçları yığına (stack) at
  pushad

  // istekte bulunan proses'in data segmentini sakla
  mov   bx,ds
  push  ebx

  // selektörler'i sistem selektörlerine ayarla
  mov   bx,SECICI_SISTEM_VERI * 8
  mov   ds,bx
  mov   es,bx

  // uygulamanın yığına sürdüğü parametre adresine konumlan
{  mov   ebp,[esp+12+4]          // orijinal esp (ring0)
  mov   ebp,[ebp+12]            // ring3 esp
  add   ebp,AktifGorevBellekAdresi  // + ring3 base adres
  mov   YaziModGorevYigini,ebp}

  // eax = işlev çağrı numarası
{  mov ecx,eax
  and ecx,$FF
  cmp ecx,0
  jne @@0
  call  HataliCagriIslevi
  jmp @@done
@@0:

  cmp ecx,USTSINIR_KESMESAYISI
  jbe @@1
  call  HataliCagriIslevi
  jmp @@done
@@1:

  shr eax,8
  and eax,$FFFFFFFF
  mov edx,YaziModGorevYigini

  // uygulamanın istediği işlevi çağır
  call  dword ptr @@Funcs[ecx*4]
  jmp @@done

@@Funcs:
  dd  {00} 0, ScreenFuncs, ObjectFuncs, EventFuncs, FileFuncs
  dd  {05} WriteFuncs, CounterFuncs, SystemFuncs, DrawFuncs, TimerFuncs
  dd  {10} SysMsgFuncs, MemoryFuncs, ProcessFuncs, PciFuncs, NetworkFuncs
  dd  {15} StorageFuncs, MouseFuncs, TModeFuncs, SocketFuncs, OtherFuncs}

@@done:

  // geri dönüş değerini yığındaki eax'e yerleştir
  //mov   [esp+28+4],eax

  cmp eax,1
  jne @@22
  mov edi,VIDEO_BELLEK_ADRESI
  mov al,dl
  mov [edi],al
  jmp @@55

@@22:
  cmp eax,2
  jne @@33
  mov edi,VIDEO_BELLEK_ADRESI+8
  mov al,dl
  mov [edi],al
  jmp @@55

@@33:

@@55:
  // istekte bulunan proses'in data segmentini eski konumuna döndür
  pop   ebx
  mov   ds,bx
  mov   es,bx

  // yazmaçları yığından (stack) geri al
  popad

  // istekte bulunan uygulamaya geri dön
  iretd
end;

{==============================================================================
  hata kodu döndürmeyen içsel kesme yazılım kesmeleri için genel rutin
 ==============================================================================}
procedure YazmacDurumunuGoruntule1(AYazmaclar0: PYazmaclar0);
begin

  // istisna ile ilgili bilgileri yazacağımız alanı temizle.
  GAktifMasaustu^.DikdortgenDoldur(nil, 0, 0, 16 * 8, 18 * 16,
    RENK_KIRMIZI, RENK_KIRMIZI);

  // istisnayı oluşturan görev
  GAktifMasaustu^.YaziYaz(nil, 0, 0 * 16, 'GRV :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 0, True, 8, CalisanGorev, RENK_BEYAZ);

  // istisna numarası (int)
  GAktifMasaustu^.YaziYaz(nil, 0, 1 * 16, 'KESME :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 8 * 8, 1 * 16, True, 8, AYazmaclar0^.ISRNo, RENK_BEYAZ);

  // eip
  GAktifMasaustu^.YaziYaz(nil, 0, 2 * 16, 'EIP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 2 * 16, True, 8, AYazmaclar0^.EIP, RENK_BEYAZ);

  // cs
  GAktifMasaustu^.YaziYaz(nil, 0, 3 * 16, 'CS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 3 * 16, True, 8, AYazmaclar0^.CS, RENK_BEYAZ);

  // ds
  GAktifMasaustu^.YaziYaz(nil, 0, 4 * 16, 'DS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 4 * 16, True, 8, AYazmaclar0^.DS, RENK_BEYAZ);

  // es
  GAktifMasaustu^.YaziYaz(nil, 0, 5 * 16, 'ES  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 5 * 16, True, 8, AYazmaclar0^.ES, RENK_BEYAZ);

  // ss
  GAktifMasaustu^.YaziYaz(nil, 0, 6 * 16, 'SS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 6 * 16, True, 8, AYazmaclar0^.SS, RENK_BEYAZ);

  // fs
  GAktifMasaustu^.YaziYaz(nil, 0, 7 * 16, 'FS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 7 * 16, True, 8, AYazmaclar0^.FS, RENK_BEYAZ);

  // gs
  GAktifMasaustu^.YaziYaz(nil, 0, 8 * 16, 'GS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 8 * 16, True, 8, AYazmaclar0^.GS, RENK_BEYAZ);

  // eax
  GAktifMasaustu^.YaziYaz(nil, 0, 9 * 16, 'EAX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 9 * 16, True, 8, AYazmaclar0^.EAX, RENK_BEYAZ);

  // ebx
  GAktifMasaustu^.YaziYaz(nil, 0, 10 * 16, 'EBX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 10 * 16, True, 8, AYazmaclar0^.EBX, RENK_BEYAZ);

  // ecx
  GAktifMasaustu^.YaziYaz(nil, 0, 11 * 16, 'ECX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 11 * 16, True, 8, AYazmaclar0^.ECX, RENK_BEYAZ);

  // edx
  GAktifMasaustu^.YaziYaz(nil, 0, 12 * 16, 'EDX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 12 * 16, True, 8, AYazmaclar0^.EDX, RENK_BEYAZ);

  // esi
  GAktifMasaustu^.YaziYaz(nil, 0, 13 * 16, 'ESI :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 13 * 16, True, 8, AYazmaclar0^.ESI, RENK_BEYAZ);

  // edi
  GAktifMasaustu^.YaziYaz(nil, 0, 14 * 16, 'EDI :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 14 * 16, True, 8, AYazmaclar0^.EDI, RENK_BEYAZ);

  // ebp
  GAktifMasaustu^.YaziYaz(nil, 0, 15 * 16, 'EBP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 15 * 16, True, 8, AYazmaclar0^.EBP, RENK_BEYAZ);

  // esp
  GAktifMasaustu^.YaziYaz(nil, 0, 16 * 16, 'ESP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 16 * 16, True, 8, AYazmaclar0^.ESP, RENK_BEYAZ);

  // eflags
  GAktifMasaustu^.YaziYaz(nil, 0, 17 * 16, 'EFLG:', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 17 * 16, True, 8, AYazmaclar0^.EFLAGS, RENK_BEYAZ);

  // sonsuz döngüye gir. ta ki yeniden programlanana kadar
  repeat until 1 = 2;
end;

{==============================================================================
  hata kodu döndüren içsel kesme yazılım kesmeleri için genel rutin
 ==============================================================================}
procedure YazmacDurumunuGoruntule2(AYazmaclar1: PYazmaclar1);
begin

  GAktifMasaustu^.DikdortgenDoldur(nil, 0, 0, 16 * 8, 19 * 16,
    RENK_KIRMIZI, RENK_KIRMIZI);

  GAktifMasaustu^.YaziYaz(nil, 0, 0 * 16, 'GRV :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 0, True, 8, CalisanGorev, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 1 * 16, 'KESME :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 8 * 8, 1 * 16, True, 8, AYazmaclar1^.ISRNo, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 2 * 16, 'ERR :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 2 * 16, True, 8, AYazmaclar1^.HataKodu, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 3 * 16, 'EIP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 3 * 16, True, 8, AYazmaclar1^.EIP, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 4 * 16, 'CS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 4 * 16, True, 8, AYazmaclar1^.CS, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 5 * 16, 'DS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 5 * 16, True, 8, AYazmaclar1^.DS, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 6 * 16, 'ES  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 6 * 16, True, 8, AYazmaclar1^.ES, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 7 * 16, 'SS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 7 * 16, True, 8, AYazmaclar1^.SS, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 8 * 16, 'FS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 8 * 16, True, 8, AYazmaclar1^.FS, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 9 * 16, 'GS  :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 9 * 16, True, 8, AYazmaclar1^.GS, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 10 * 16, 'EAX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 10 * 16, True, 8, AYazmaclar1^.EAX, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 11 * 16, 'EBX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 11 * 16, True, 8, AYazmaclar1^.EBX, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 12 * 16, 'ECX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 12 * 16, True, 8, AYazmaclar1^.ECX, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 13 * 16, 'EDX :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 13 * 16, True, 8, AYazmaclar1^.EDX, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 14 * 16, 'ESI :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 14 * 16, True, 8, AYazmaclar1^.ESI, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 15 * 16, 'EDI :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 15 * 16, True, 8, AYazmaclar1^.EDI, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 16 * 16, 'EBP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 16 * 16, True, 8, AYazmaclar1^.EBP, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 17 * 16, 'ESP :', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 17 * 16, True, 8, AYazmaclar1^.ESP, RENK_BEYAZ);

  GAktifMasaustu^.YaziYaz(nil, 0, 18 * 16, 'EFLG:', RENK_BEYAZ);
  GAktifMasaustu^.SayiYaz16(nil, 6 * 8, 18 * 16, True, 8, AYazmaclar1^.EFLAGS, RENK_BEYAZ);

  repeat until 1 = 2;
end;

end.
