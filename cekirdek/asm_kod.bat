@ECHO OFF
PATH=C:\lazarus\fpc\3.0.2\bin\i386-win32
objdump -D cekirdkg.bin > asm_kod.txt

echo cikis dosyasi asm_kod.txt adiyla kaydedildi.
pause