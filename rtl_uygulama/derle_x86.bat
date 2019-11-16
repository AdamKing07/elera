rmdir linux\units /s /q

SET PATHBIN=C:\lazarus\fpc\3.0.4\bin\i386-win32\
SET PATH=%PATHBIN%
%PATHBIN%make.exe OS_TARGET=linux CPU_TARGET=i386

@pause