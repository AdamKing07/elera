;************************************************************************
;                                                                       *
;       Kodlayan: Fatih KILI�                                           *
;       Telif Bilgisi: haklar.txt dosyas�na bak�n�z                     *
;                                                                       *
;       Dosya Ad�: elera1.asm                                           *
;       Dosya ��levi: yaz� tabanl� �ekirdek i�levlerini y�netir         *
;       Not: kodlar fasm ile derlenmi�tir                               *
;                                                                       *
;       Kodlama Tarihi: 27/01/2017                                      *
;       G�ncelleme Tarihi: 01/02/2017                                   *
;                                                                       *
;************************************************************************
use32
org     0x100000
jmp     start

include 'C:\fasmw17164\include\win32ax.inc'

start:

        ; kesme ve irq isteklerini durdur
        ;----------------------------------------------------------------
        cli

        mov     al,0xff
        out     0x21,al
        out     0xa1,al

        ; yazma�lar� ayarla
        ;----------------------------------------------------------------
        mov     eax,16
        mov     ds,ax
        mov     es,ax
        mov     ss,ax
        mov     fs,ax
        mov     gs,ax
        mov     esp,0xFFFFF0

        ; pic ayg�t�n� y�kle
        ;----------------------------------------------------------------
        stdcall pic_init

        ; kesme haritas�n� y�kle
        ;----------------------------------------------------------------
        lidt    pword [idtr]


        sti
        jmp   os_control

;************************************************************************
;       sistemin ana kontrol k�sm�                                      *
;************************************************************************
align 32
os_control:

        ; ekran� sil ve kurs�r� ayarla
        ;----------------------------------------------------------------
        stdcall prepare_screen

        ; komut sat�r�n� g�r�nt�le
        ;----------------------------------------------------------------
        stdcall write_text, str_prompt

.get_key:

        ; klavye belle�inde veri var m�?
        ;----------------------------------------------------------------
        mov     ecx,[keyb_buffer_len]
        cmp     ecx,0
        jz      .get_key

        ; klavye belle�inde bas�lan tu� de�erini al
        ;----------------------------------------------------------------
        call    get_key
        or      al,al
        jz      .get_key

        ; e�er tu� enter tu�u de�ilse
        ;----------------------------------------------------------------
        cmp     al,10
        jne     .write_screen

        ; bas�lan tu� enter! komutun en sonuna sonland�rma (0) ekle
        ;----------------------------------------------------------------
        mov     al,0
        mov     edi,[command_len]
        mov     [edi+command],al

        ; komut uzunlu�unu al
        ;----------------------------------------------------------------
        stdcall get_length, command

        ; e�er uzunluk 0 ise bir sonraki iste�i bekle
        ;----------------------------------------------------------------
        cmp     ecx,0
        je      .cmd_completed

        ; komutun s�ra (index) de�erini al
        ;----------------------------------------------------------------
        stdcall check_command, command, ecx
        cmp     ecx,1
        je      .cmd_yardim
        cmp     ecx,2
        je      .cmd_sistem
        cmp     ecx,3
        je      .cmd_islemci

.cmd_unknown:
        stdcall write_text, str_cmd_unknown
        jmp     .clear_cmd_buf

.cmd_yardim:
        stdcall cmd_yardim
        jmp     .clear_cmd_buf

.cmd_sistem:
        stdcall cmd_sistem
        jmp     .clear_cmd_buf

.cmd_islemci:
        stdcall cmd_islemci
        jmp     .clear_cmd_buf

        ; girilen komutu s�f�rla
        ;----------------------------------------------------------------
.clear_cmd_buf:
        xor     eax,eax
        mov     [command_len],eax

        mov     ecx,256/4
        mov     edi,command
        cld
        rep     stosd

.cmd_completed:

        ; yeni komut sat�r�n� haz�rla
        ;----------------------------------------------------------------
        stdcall write_char, dword 13
        stdcall write_text, str_prompt
        jmp     .get_key

.write_screen:

        ; bas�lan tu� de�erini belle�e kaydet
        ;----------------------------------------------------------------
        mov     edi,[command_len]
        mov     [edi+command],al
        inc     edi
        mov     [command_len],edi

        ; bas�lan tu� de�erini ekrana yaz
        ;----------------------------------------------------------------
        stdcall write_char, eax
        jmp     .get_key

;========================================================================
; i�lev: prepare_screen
; tan�m: ekran� temizler ve imle�i 0,0 noktas�na konumland�r�r
; giri�: yok
; ��k��: yok
; not  : renk ayarlar�n� temizlemez
;========================================================================
proc prepare_screen stdcall uses eax ecx edi

        ; ekran� sil
        ;----------------------------------------------------------------
        mov     edi,0xb8000
        mov     eax,0x0F200F20
        mov     ecx,(80*25*2) / 4
        cld
        rep     stosd

        ; imle�i ayarla
        ;----------------------------------------------------------------
        xor     edi,edi
        mov     [col],edi
        mov     [row],edi
        stdcall update_cursor
        ret
endp

;========================================================================
; i�lev: update_cursor
; tan�m: imleci yeniden konumland�r�r
; giri�: yok
; ��k��: yok
;========================================================================
align 4
proc update_cursor stdcall uses eax ebx edx

        mov     eax,[row]
        mov     ebx,80
        imul    ebx
        mov     ebx,eax
        add     ebx,[col]

        mov     dx,0x3d4
        mov     al,0xf
        out     dx,al

        mov     dx,0x3d5
        mov     al,bl
        out     dx,al

        mov     dx,0x3d4
        mov     al,0xe
        out     dx,al

        mov     dx,0x3d5
        mov     al,bh
        out     dx,al
        ret
endp

;========================================================================
; i�lev: check_command
; tan�m: komut sat�r�ndan g�nderilen komutlar� sorgular
; giri�: yok
; ��k��: ecx = komut s�ras� (index) veya ecx = -1 = komut bulunamad�
;========================================================================
align 4
commands_count  dd      3       ; toplam komut say�s�

commands:
; string t�r�nde veri yap�lar�
cmd1    db      6,"yardim"
times 16-($-cmd1) db 0
cmd2    db      6,"sistem"
times 16-($-cmd2) db 0
cmd3    db      3,"mib"
times 16-($-cmd3) db 0

align 4
proc check_command stdcall uses eax ebx edx esi edi, \
     @cmd:DWORD, @cmd_len:DWORD
     local @idx:DWORD

        ; sorgulanacak ger�ek komut s�ras� (index)
        mov     ecx,0

.check_cmd:
        ; sorgulanacak komutu kaydet
        ;----------------------------------------------------------------
        mov     [@idx],ecx

        ; komut uzunlu�unu kar��la�t�r
        ;----------------------------------------------------------------
        mov     edx,[@cmd_len]
        mov     edi,ecx
        shl     edi,4
        add     edi,commands
        movzx   ecx,byte[edi]
        cmp     ecx,edx
        jne     .next_cmd

        ; komut katar�n� kar��la�t�r
        ;----------------------------------------------------------------
        inc     edi             ; komut uzunluk byte'� atlan�yor
        mov     esi,[@cmd]
        cld
        repe    cmpsb
        je      .success

.next_cmd:
        ; bir sonraki komuta ge�i� yap
        ;----------------------------------------------------------------
        mov     ecx,[@idx]
        inc     ecx
        cmp     ecx,[commands_count]
        jae     .cmd_not_found
        jmp     .check_cmd

.cmd_not_found:

        mov     ecx,-1
        ret

.success:
        mov     ecx,[@idx]
        inc     ecx
        ret
endp

;========================================================================
; i�lev: cmd_yardim
; tan�m: �ekirdek (kernel) yard�m komutu
; giri�: yok
; ��k��: yok
;========================================================================
align 4
str_yardim0     db      13,"Yardim Komutu:",0
align 4
str_yardim1     db      13,"1. yardim: su an calisan komut.",0
align 4
str_yardim2     db      13,"2. sistem: sistem hakkinda bilgi verir.",0
align 4
str_yardim3     db      13,"3. mib: merkezi islem birimi hakkinda bilgi verir.",0
align 4
proc cmd_yardim stdcall

        stdcall write_text, str_yardim0
        stdcall write_text, str_yardim1
        stdcall write_text, str_yardim2
        stdcall write_text, str_yardim3
        ret
endp

;========================================================================
; i�lev: cmd_sistem
; tan�m: �ekirdek (kernel) sistem komutu
; giri�: yok
; ��k��: yok
;========================================================================
align 4
str_sistem      db      13,"Isletim Sistemi:  ELERA Isletim Sistemi",0
align 4
proc cmd_sistem stdcall

        stdcall write_text, str_sistem
        ret
endp

;========================================================================
; i�lev: cmd_islemci
; tan�m: �ekirdek (kernel) i�lemci komutu
; giri�: yok
; ��k��: yok
;========================================================================
align 4
str_islemci     db      13,"Islemci: AAAABBBBCCCC",0
align 4
proc cmd_islemci stdcall uses eax ebx ecx edx

        xor     eax,eax
        cpuid

        mov     edi,str_islemci+10
        mov     [edi+0],ebx
        mov     [edi+4],edx
        mov     [edi+8],ecx

        stdcall write_text, str_islemci
        ret
endp

;========================================================================
; i�lev: get_key
; tan�m: klavye belle�inden bas�lan tu� de�erini al�r
; giri�: yok
; ��k��: yok
;========================================================================
align 4
get_key:

        cli
        mov     ecx,[keyb_buffer_len]
        cmp     ecx,0
        ja      .get
        mov     al,0
        sti
        ret

.get:
        mov     al,[keyb_buffer]
        push    eax

        ; TODO - de�erin 0 olmas� durumuna g�re kodlar yeniden tasarlanacak
        mov     ecx,[keyb_buffer_len]
        dec     ecx
        mov     [keyb_buffer_len],ecx
        cmp     ecx,0
        ja      .exit

        mov     edi,keyb_buffer
        mov     esi,edi
        inc     esi
        cld
        rep     movsb

.exit:
        pop     eax
        sti
        ret

;========================================================================
; i�lev: write_text
; tan�m: text modunda ekrana karakter katar� yazar
; giri�: yok
; ��k��: yok
;========================================================================
align 4
proc write_text stdcall uses eax esi, \
     @buffer:DWORD

        mov     esi,[@buffer]
@@:
        mov     al,[esi]
        test    al,al
        jz      .done
        stdcall write_char, eax

        inc     esi
        jmp     @b
.done:
        ret
endp

;========================================================================
; i�lev: write_char
; tan�m: text modunda ekrana karakter yazar
; giri�: yok
; ��k��: yok
; not  : karakter renk de�eri g�zard� edilmi�tir
;========================================================================
align 4
proc write_char stdcall uses eax ebx ecx edx esi edi, \
     @char:DWORD

@@:
        mov     eax,[@char]
        cmp     al,13
        je      .inc_cursor

        mov     ebx,[row]
        mov     eax,80*2
        imul    ebx
        mov     edi,eax
        mov     ebx,[col]
        shl     ebx,1
        add     edi,ebx
        add     edi,0xb8000

        mov     eax,[@char]
        mov     [edi],al

        mov     edi,[col]
        inc     edi
        mov     [col],edi
        cmp     edi,79
        jb      .col_ok

.inc_cursor:
        xor     edi,edi
        mov     [col],edi

        mov     edi,[row]
        inc     edi
        mov     [row],edi
        cmp     edi,25
        jb      .col_ok

        mov     esi,0xb8000
        mov     edi,esi
        add     esi,80*2
        mov     ecx,(24*80*2) / 4
        cld
        rep     movsd

        mov     edi,0xb8000+(24*80*2)
        mov     ecx,(80*2) / 4
        mov     eax,0x0E200E20
        cld
        rep     stosd

        mov     [col],0
        mov     [row],24

.col_ok:

        stdcall update_cursor
        ret
endp

;========================================================================
; i�lev: get_length
; tan�m: belirtilen katar'�n (string) uzunlu�unu al�r
; giri�: yok
; ��k��: ecx = byte olarak katar'�n uzunlu�u
;========================================================================
align 4
proc get_length stdcall uses eax esi, \
     @str:DWORD

        mov     esi,[@str]

        ;sayac� s�f�rla
        ;----------------------------------------------------------------
        xor     ecx,ecx
@@:
        mov     al,[esi]
        or      al,al
        jz      @f

        ;sayac� bir art�r ve bir sonraki bellek adresine konumlan
        ;----------------------------------------------------------------
        inc     esi
        inc     ecx
        jmp     @b
@@:
        ret
endp

;========================================================================
; i�lev: pic_init
; tan�m: pic ayg�t�n� yeniden programlar
; giri�: yok
; ��k��: yok
;========================================================================
align 4
proc pic_init stdcall uses eax

        ; ICW1 - her iki pic kontrolc�s�ne init kodu g�nder
        mov     al,0x11
        out     0x20,al
        out     0xa0,al

        ; ICW2 - pic1 : irq0-irq7 -> int 0x20-0x27, pic2 : irq8-irq15 -> int 0x28-0x30
        mov     al,0x20
        out     0x21,al
        mov     al,0x28
        out     0xa1,al

        ; ICW3 - irq2 (bit 2=1) slave, slave id is 2. bit 1=1
        mov     al,4
        out     0x21,al
        mov     al,2
        out     0xa1,al

        ; ICW4 - her iki pic kontrolc�s� 8086/8088 modunda
        mov     al,1
        out     0x21,al
        out     0xa1,al
        ret
endp

;************************************************************************
;       kesme tablosu                                                   *
;************************************************************************
align 32
idtr:
        dw      (0x35 * 8) - 1
        dd      idtr_entries

align 4
idtr_entries:
        ; isr 0
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 1
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 2
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 3
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 4
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 5
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 6
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 7
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 8
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 9
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 10
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 11
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 12
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 13
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 14
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 15
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 16
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 17
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 18
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 19
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 20
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 21
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 22
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 23
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 24
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 25
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 26
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 27
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 28
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 29
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 30
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; isr 31
        dw      (isr_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (isr_handler shr 16) and 0xffff

        ; irq 0
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 1
        dw      (keyboard_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (keyboard_handler shr 16) and 0xffff

        ; irq 2
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 3
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 4
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 5
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 6
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 7
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 8
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 9
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 10
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 11
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 12
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 13
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 14
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

        ; irq 15
        dw      (irq_handler and 0xffff)
        dw      0x8
        db      0
        db      0x8e
        dw      (irq_handler shr 16) and 0xffff

;========================================================================
; i�lev: isr_handler
; tan�m: genel kesme (servis) rutini
; giri�: yok
; ��k��: yok
;========================================================================
align 4
isr_handler:

        cli
        push    eax edx

        mov     al,0x20
        mov     dx,0x20
        out     dx,al

        pop     edx eax
        sti
        iretd

;========================================================================
; i�lev: irq_handler
; tan�m: genel kesme (interrupt) rutini
; giri�: yok
; ��k��: yok
;========================================================================
align 4
irq_handler:

        cli
        push    eax edx

        mov     al,0x20
        mov     dx,0x20
        out     dx,al

        pop     edx eax
        sti
        iretd

;========================================================================
; i�lev: keyboard_handler
; tan�m: klavye kesme rutini
; giri�: yok
; ��k��: yok
;========================================================================
align 4
keyboard_handler:

        cli
        pushad

        ; b�rak�lan tu�lar da (0x80) eklenecek
        ;----------------------------------------------------------------
        in     al,0x60
        test   al,0x80
        jnz    .eoi

        ; klavye belle�ini test et
        ;----------------------------------------------------------------
        mov     ecx,[keyb_buffer_len]
        inc     ecx
        cmp     ecx,256
        ja      .eoi
        mov     [keyb_buffer_len],ecx

        ; klavye ayg�t�ndan al�nan de�eri kod kar��l���n� tablodan al
        ;----------------------------------------------------------------
        movzx   esi,al
        add     esi,key_table
        mov     al,[esi]

        ; klavye bellek girdi de�erini g�ncelle
        ;----------------------------------------------------------------
        mov     edi,ecx
        dec     edi
        mov     [edi+keyb_buffer],al

        ; end of interrupt
        ;----------------------------------------------------------------
.eoi:
        mov     al,0x20
        out     0x20,al

        popad
        sti
        iretd

;========================================================================
; klavye scan kod - ascii kod tablosu
;========================================================================
;http://www.computer-engineering.org/ps2keyboard/scancodes1.html
KEY_BACKSPACE   equ     8
KEY_TAB         equ     9
KEY_ENTER       equ     10
KEY_ESC         equ     27
align 4
key_table:
        db      0, KEY_ESC
        db      "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="
        db      KEY_BACKSPACE
        db      KEY_TAB
        db      "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]"
        db      KEY_ENTER
        db      0       ; Ctrl
        db      "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'", "`"
        db      0       ; Left Shift
        db      "\", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/"
        db      0       ; Right Shift
        db      "*"
        db      0       ; Alt
        db      " "
        db      0       ; Caps Lock
        db      33, 34, 0, 0, 0, 0, 0, 0, 0, 0          ; F1 - F10 - ge�ici de�er
        db      0       ; Num Lock
        db      0       ; Scrool Lock
        db      0       ; Home Key
        db      0       ; Up Arrow
        db      0       ; Page Up
        db      "-"
        db      120     ; Left Arrow - ge�ici de�er
        db      0
        db      110     ; Right Arrow - ge�ici de�er
        db      "+"
        db      0       ; End Key
        db      0       ; Down Arrow
        db      0       ; Page Down
        db      0       ; Insert Key
        db      0       ; Delete Key
        db      0, 0, 0
        db      0       ; F11
        db      0       ; F12
times 39 db 0

;========================================================================
; genel de�i�kenler
;========================================================================
align 4
keyb_buffer_len         dd      0
keyb_buffer:            times 256 db 0
str_prompt              db      "Komut: > ",0
align 4
col                     dd      0
row                     dd      0
command_len             dd      0
command:                times 256 db 0
str_cmd_unknown db      13,"Bilinmeyen komut!",0