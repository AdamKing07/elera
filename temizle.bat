@echo bilden dizini temizleniyor...
del bilden\bilden.bin /Q

@echo çekirdek dizinleri temizleniyor...
cd cekirdek
call temizle.bat
cd..

@echo uygulamalar dizini temizleniyor...
cd uygulamalar\mod_g
call temizle.bat
cd..
del _g\*.* /Q
cd..

@echo rtl dizini temizleniyor...
rmdir .\rtl_cekirdek\linux\units /S /Q
rmdir .\rtl_uygulama\linux\units /S /Q

@echo vbox dizini temizleniyor...
cd vbox
del elera.vbox-prev /Q
rmdir Logs /S /Q
cd..

@echo vmware dizini temizleniyor...
cd vmware
del *.log /Q
cd..

@echo widgets dizini temizleniyor...
cd widgets
rmdir lib /S /Q

pause
