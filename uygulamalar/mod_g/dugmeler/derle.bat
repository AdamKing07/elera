@echo off

PATH=C:\lazarus\fpc\3.0.4\bin\x86_64-win64
fpc -Tlinux -Pi386 -FUoutlib -Fu..\..\..\rtl_uygulama\linux\units\i386-linux -Sc -Sg -Si -Sh -CX -Os -Xs -XX -k-Tbagla.ld -o..\..\_g\dugmeler.c dugmeler.lpr
