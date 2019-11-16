@ECHO OFF

PATH=C:\lazarus\fpc\3.0.2\bin\i386-win32
fpc -Tlinux -Pi386 -FUoutlib -Fu..\..\..\rtl_prog\linux\units\i386-linux -Sc -Sg -Si -Sh -CX -Os -Xs -XX -k-Tekryaz1.ld -o..\..\_t\ekryaz1.c ekryaz1.lpr