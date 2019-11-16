{==============================================================================
                     ELERA İşletim Sistemi (yazı modu)

   Genel Bilgiler:
   ----------------------------------------------------------------------------
   Sistem Adı: Elera İşletim Sistemi (eleraos)
   Kodlayan: Fatih KILIÇ

   Teknik Bilgiler
   ----------------------------------------------------------------------------
   + Zaman Paylaşımlı Çokgörevlilik (Pre-emptive multitasking)
   + Statik / Dinamik Bellek Yönetimi
   + Sayfalama (paging)

   Sistem Gereklilikleri
   ----------------------------------------------------------------------------
   İşlemci: 386+
   RAM: 32 MB+

   Sürüm Bilgileri
   ----------------------------------------------------------------------------
   Telif Bilgisi: haklar.txt dosyasına bakınız
   Güncelleme Tarihi: (11-08-2017 - Cuma)

==============================================================================}
program kernelt;
{$mode objfpc}
{$asmmode intel}
{$WARNINGS ON}

uses loader, shared, sysmngr, process, vmm, tmode;

const
  P1: array[0..19] of Byte = ($BA, $3D, $00, $00, $00, $B8, $01, $00, $00, $00,
    $CD, $35, $42, $83, $FA, $5A, $76, $F3, $EB, $EC);
  P2: array[0..17] of Byte = ($B2, $61, $B8, $02, $00, $00, $00,
    $CD, $35, $FE, $C2, $80, $FA, $7A, $76, $F2, $EB, $EE);

var
  p: PProcess;

begin

  // sanal bellek yöneticisini yükle
  vmm.Init;

  // sistem esp değerini belirle
  asm
    cli

    mov eax,PROCESSRING0_ESP
    mov esp,eax

    fninit

    mov eax,PDIR_MEM
    mov cr3,eax

    mov eax,cr0
    and eax,$1FFFFFFF       // ön bellek aktif
    and eax,not $10000      // yazım koruması pasif
    or  eax,$80000001       // sayfalama aktif
    mov cr0,eax
  end;

  // yazı mod bellek adresini sanal belleğe tanımla
  MapMem(VMEM_ADDR, $B8000, 1024, PAGE_PRESENT or PAGE_WRITEABLE);

  // çekirdek çevre donanım yükleme işlevlerini gerçekleştir
  LoadKernelFunctions;

  ClrScr;

  // Execute3 ile sayfalama mekanizmasıyla yeniden yapılandırılan çalıştırılabilir
  // dosya işlemleri tamamlanacak
  //p^.Execute2('disket1:\ekryaz1.c', @P1);
  //p^.Execute3('disket1:\ekryaz2.c', @P2);
  //p^.Execute2('test2', @P2);
  //p^.Execute('test3', @Process3);

  MultitaskingStarted := 1;

  // sistem ana kontrol kısmına geçiş yap
  OSControl;
end.
