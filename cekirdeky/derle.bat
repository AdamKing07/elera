@ECHO OFF

PATH=C:\lazarus\fpc\3.0.4\bin\i386-win32

fpc -Fu..\rtl_kernel\linux\units\i386-linux;..\shared;..\shared\core;..\shared\hardware;..\shared\drivers\network;..\shared\proto;..\shared\ints;..\shared\font;..\shared\drivers\graphic;..\shared\others;..\shared\cursors;..\shared\drivers\mouse;..\shared\drivers;..\shared\fs;..\shared\objects;..\shared\fformat;..\shared\usb;..\vobjects -FUoutlib -okernelt.bin -Mobjfpc -Sc -Sg -Si -Sh -Rintel -Tlinux -Pi386 -CX -XX -k-Tkernelt.ld kernelt.lpr

pause