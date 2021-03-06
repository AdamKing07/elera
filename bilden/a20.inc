;************************************************************************
;
;       Kodlayan: Fatih KILI�
;       Telif Bilgisi: haklar.txt dosyas�na bak�n�z
;
;       Dosya Ad�: a20.asm
;       Dosya ��levi: a20 adres hatt� i�levlerini i�erir
;
;       G�ncelleme Tarihi: 17/10/2012
;
;************************************************************************

;========================================================================
;
;i�lev  : enable_a20
;tan�m  : adres yolunun 20. bitini aktifle�tirir
;��k��  : yok
;
;========================================================================
align 4
enable_a20:

	;kesmeleri pasifle�tir
	;----------------------------------------------------------------
	cli

	;keyboard kontrolleri pasifle�tir
	;----------------------------------------------------------------
	call	wait_ibf
	mov	al,0xad
	out	0x64,al

	;keyboard kontroller'i oku komutu g�nder
	;----------------------------------------------------------------
	call	wait_ibf
	mov	al,0xd0
	out	0x64,al

	;data'y� oku & sakla
	;----------------------------------------------------------------
	call	wait_obf
	in	al,0x60
	push	eax

	;keyboard kontroller'e yaz komutu g�nder
	;----------------------------------------------------------------
	call	wait_ibf
	mov	al,0xd1
	out	0x64,al

	;okunan data'n�n 1. biti'ni (a20 biti) set et ve data'y� g�nder
	;----------------------------------------------------------------
	call	wait_ibf
	pop	eax
	or	al,10b
	out	0x60,al

	;keyboard kontroller'i aktifle�tir
	;----------------------------------------------------------------
	call	wait_ibf
	mov	al,0xae
	out	0x64,al

	;kontroller'in giri� buffer'�n�n 0 olmas�n� bekle
	;----------------------------------------------------------------
	call	wait_ibf

	;kesmeleri aktifle�tir & ��k
	;----------------------------------------------------------------
	sti
	ret

;========================================================================
;
;i�lev  : wait_ibf
;tan�m  : keyboard kontroller'in giri� buffer'�n�n haz�r olmas�n� bekler
;         (komut g�ndermek i�in)
;��k��  : yok
;
;========================================================================
align 4
wait_ibf:
@@:
	in	al,0x64
	test	al,10b
	jnz	@b
	ret

;========================================================================
;
;i�lev  : wait_obf
;tan�m  : keyboard kontroller'in ��k�� buffer'�n�n haz�r olmas�n� bekler
;         (data okumak i�in)
;��k��  : yok
;
;========================================================================
align 4
wait_obf:
@@:
	in	al,0x64
	test	al,1b
	jz	@b
	ret