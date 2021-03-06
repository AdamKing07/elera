{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: paylasim.pas
  Dosya İşlevi: program arabiriminde kullanılacak sabit değerleri içerir

  Güncelleme Tarihi: 05/08/2020

 ==============================================================================}
{$mode objfpc}
const
  ISLEM_BASARILI              = TISayi4(0);
  HATA_KIMLIK                 = TISayi4(-1);
  HATA_NESNE                  = TISayi4(-2);
  HATA_ATANESNE               = TISayi4(-3);
  HATA_ALTNESNEBELLEKDOLU     = TISayi4(-4);
  HATA_TUMBELLEKKULLANIMDA    = TISayi4(-5);
  HATA_ISLEV                  = TISayi4(-6);
  HATA_DOSYABULUNAMADI        = TISayi4(-7);
  HATA_BOSGOREVYOK            = TISayi4(-8);
  HATA_BOSKIMLIKYOK           = TISayi4(-9);
  HATA_TUMZAMANLAYICILARDOLU  = TISayi4(-10);
  HATA_NESNEGORUNURDEGIL      = TISayi4(-11);
  HATA_BELLEKOKUMA            = TISayi4(-12);
  HATA_GOREVNO                = TISayi4(-13);
  HATA_ELEMANEKLEME           = TISayi4(-14);
  HATA_DEGERARALIKDISI        = TISayi4(-15);
  HATA_KAYNAKLARKULLANIMDA    = TISayi4(-16);
  HATA_BILINMEYENUZANTI       = TISayi4(-17);
  HATA_NESNEOLUSTURMA         = TISayi4(-18);

  // sistem ana çağrıları
  SAC_EKRAN	                  = $01;
  SAC_GNESNE	                = $02;    // görsel nesne
  SAC_OLAY	                  = $03;
  SAC_DOSYA 	                = $04;
  SAC_YAZIM	                  = $05;
  SAC_SAYAC	                  = $06;
  SAC_SISTEM	                = $07;
  SAC_CIZIM 	                = $08;
  SAC_ZAMANLAYICI	            = $09;
  SAC_MESAJ	                  = $0A;
  SAC_BELLEK	                = $0B;
  SAC_GOREV	                  = $0C;
  SAC_PCI		                  = $0D;
  SAC_AG	                    = $0E;
  SAC_FARE	                  = $10;
  SAC_GIYSI                   = $11;
  SAC_ILETISIM                = $12;

  // nesneler
  MASAUSTU                    = $01 shl 8;
  PENCERE                     = $02 shl 8;
  DUGME                       = $03 shl 8;
  GUCDUGMESI                  = $04 shl 8;
  LISTEKUTUSU                 = $05 shl 8;
  MENU                        = $06 shl 8;
  DEFTER                      = $07 shl 8;
  ISLEMGOSTERGESI             = $08 shl 8;
  ONAYKUTUSU                  = $09 shl 8;
  GIRISKUTUSU                 = $0A shl 8;
  DEGERDUGMESI                = $0B shl 8;
  ETIKET                      = $0C shl 8;
  DURUMCUBUGU                 = $0D shl 8;
  SECIMDUGMESI                = $0E shl 8;
  BAGLANTI                    = $0F shl 8;
  RESIM                       = $10 shl 8;
  LISTEGORUNUM                = $11 shl 8;
  PANEL                       = $12 shl 8;
  RESIMDUGMESI                = $13 shl 8;
  KAYDIRMACUBUGU              = $14 shl 8;
  KARMALISTE                  = $15 shl 8;
  ACILIRMENU                  = $16 shl 8;
  DEGERLISTESI                = $17 shl 8;
  IZGARA                      = $18 shl 8;
  ARACCUBUGU                  = $19 shl 8;
  RENKSECICI                  = $1A shl 8;
  SAYFAKONTROL                = $1B shl 8;

  // görsel nesne ana çağrıları
  OLUSTUR                     = $0001 shl 16;
  GOSTER                      = $0002 shl 16;
  GIZLE                       = $0003 shl 16;
  CIZ                         = $0004 shl 16;
  BOYUTLANDIR                 = $0005 shl 16;
  YOKET                       = $0006 shl 16;
  AL                          = $1000 shl 16;
  YAZ                         = $2000 shl 16;

  // yeni sistem çağrılarının tanımlanacağı alan
  
  EKRAN_COZUNURLUGUNUAL       = $00010200 + SAC_EKRAN;

  MASAUSTU_OLUSTUR	          = OLUSTUR + MASAUSTU + SAC_GNESNE;
  MASAUSTU_GOSTER		          = GOSTER + MASAUSTU + SAC_GNESNE;
  MASAUSTU_MEVCUTSAYI         = $01020100 + SAC_GNESNE;
  MASAUSTU_AKTIFLESTIR	      = $01040100 + SAC_GNESNE;

  PENCERE_OLUSTUR	            = OLUSTUR + PENCERE + SAC_GNESNE;
  PENCERE_GOSTER              = GOSTER + PENCERE + SAC_GNESNE;
  PENCERE_GIZLE	              = GIZLE + PENCERE + SAC_GNESNE;
  PENCERE_CIZ		              = CIZ + PENCERE + SAC_GNESNE;
  PENCERE_DRM_NORMAL          = $01800200 + SAC_GNESNE;
  PENCERE_DRM_KUCULT          = $02800200 + SAC_GNESNE;

  DUGME_OLUSTUR 	            = OLUSTUR + DUGME + SAC_GNESNE;
  DUGME_GOSTER		            = GOSTER + DUGME + SAC_GNESNE;
  DUGME_GIZLE	                = GIZLE + DUGME + SAC_GNESNE;
  DUGME_YOKET 	              = YOKET + DUGME + SAC_GNESNE;
  DUGME_HIZALA                = $01040300 + SAC_GNESNE;
  DUGME_BASLIKDEGISTIR        = $02040300 + SAC_GNESNE;

  GUCDUGMESI_OLUSTUR	        = OLUSTUR + GUCDUGMESI + SAC_GNESNE;
  GUCDUGMESI_GOSTER	          = GOSTER + GUCDUGMESI + SAC_GNESNE;
  GUCDUGMESI_GIZLE	          = GIZLE + GUCDUGMESI + SAC_GNESNE;
  GUCDUGMESI_BOYUTLANDIR      = BOYUTLANDIR + GUCDUGMESI + SAC_GNESNE;
  GUCDUGMESI_YOKET 	          = YOKET + GUCDUGMESI + SAC_GNESNE;
  GUCDUGMESI_BASLIKDEGISTIR   = $02040400 + SAC_GNESNE;
  GUCDUGMESI_DURUMYAZ	        = $03040400 + SAC_GNESNE;

  LISTEKUTUSU_OLUSTUR	        = OLUSTUR + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_GOSTER	        = GOSTER + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_GIZLE	          = GIZLE + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_ELEMANEKLE	    = $01000500 + SAC_GNESNE;
  LISTEKUTUSU_TEMIZLE 	      = $03000500 + SAC_GNESNE;
  LISTEKUTUSU_HIZALA          = $01040500 + SAC_GNESNE;
  LISTEKUTUSU_TELEMANSAYISIAL = AL  + $00010000 + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_SECILISIRANOAL  = AL  + $00020000 + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_SECILISIRANOYAZ = YAZ + $00020000 + LISTEKUTUSU + SAC_GNESNE;
  LISTEKUTUSU_SECILIYAZIAL    = AL  + $00030000 + LISTEKUTUSU + SAC_GNESNE;

  MENU_OLUSTUR	              = OLUSTUR + MENU + SAC_GNESNE;
  MENU_GOSTER	                = GOSTER + MENU + SAC_GNESNE;
  MENU_GIZLE	                = GIZLE + MENU + SAC_GNESNE;
  MENU_ELEMANEKLE	            = $01000600 + SAC_GNESNE;
  MENU_SECILISIRANOAL         = $02000600 + SAC_GNESNE;

  DEFTER_OLUSTUR              = OLUSTUR + DEFTER + SAC_GNESNE;
  DEFTER_GOSTER		            = GOSTER + DEFTER + SAC_GNESNE;
  DEFTER_HIZALA               = $01040700 + SAC_GNESNE;
  DEFTER_YAZIEKLEP 	          = $01000700 + SAC_GNESNE;
  DEFTER_YAZIEKLES	          = $02000700 + SAC_GNESNE;
  DEFTER_TEMIZLE              = $03000700 + SAC_GNESNE;

  ISLEMGOSTERGESI_OLUSTUR     = OLUSTUR + ISLEMGOSTERGESI + SAC_GNESNE;
  ISLEMGOSTERGESI_ALTUSTDEGER = $01040800 + SAC_GNESNE;
  ISLEMGOSTERGESI_KONUMBELIRLE= $02040800 + SAC_GNESNE;    // $0104xxxx değer olarak standartlaştırılacak

  ONAYKUTUSU_OLUSTUR          = OLUSTUR + ONAYKUTUSU + SAC_GNESNE;
  ONAYKUTUSU_GOSTER           = GOSTER + ONAYKUTUSU + SAC_GNESNE;

  GIRISKUTUSU_OLUSTUR         = OLUSTUR + GIRISKUTUSU + SAC_GNESNE;
  GIRISKUTUSU_GOSTER          = GOSTER + GIRISKUTUSU + SAC_GNESNE;
  GIRISKUTUSU_ICERIKAL        = $01020A00 + SAC_GNESNE;
  GIRISKUTUSU_HIZALA          = $01040A00 + SAC_GNESNE;
  GIRISKUTUSU_YAZILAMAZ0      = $02040A00 + SAC_GNESNE;
  GIRISKUTUSU_SADECESAYI0     = $03040A00 + SAC_GNESNE;
  GIRISKUTUSU_ICERIKYAZ       = $04040A00 + SAC_GNESNE;

  DEGERDUGMESI_OLUSTUR        = OLUSTUR + DEGERDUGMESI + SAC_GNESNE;
  DEGERDUGMESI_GOSTER         = GOSTER + DEGERDUGMESI + SAC_GNESNE;

  ETIKET_OLUSTUR              = OLUSTUR + ETIKET + SAC_GNESNE;
  ETIKET_GOSTER               = GOSTER + ETIKET + SAC_GNESNE;
  ETIKET_DEGISTIR             = $01040C00 + SAC_GNESNE;

  DURUMCUBUGU_OLUSTUR         = OLUSTUR + DURUMCUBUGU + SAC_GNESNE;
  DURUMCUBUGU_GOSTER          = GOSTER + DURUMCUBUGU + SAC_GNESNE;
  DURUMCUBUGU_YAZIDEGISTIR    = $01040D00 + SAC_GNESNE;

  SECIMDUGMESI_OLUSTUR        = OLUSTUR + SECIMDUGMESI + SAC_GNESNE;
  SECIMDUGMESI_GOSTER         = GOSTER + SECIMDUGMESI + SAC_GNESNE;
  SECIMDUGMESI_DURUMDEGISTIR  = $01040E00 + SAC_GNESNE;

  BAGLANTI_OLUSTUR            = OLUSTUR + BAGLANTI + SAC_GNESNE;
  BAGLANTI_GOSTER             = GOSTER + BAGLANTI + SAC_GNESNE;

  RESIM_OLUSTUR               = OLUSTUR + RESIM + SAC_GNESNE;
  RESIM_GOSTER                = GOSTER + RESIM + SAC_GNESNE;
  RESIM_HIZALA                = $01041000 + SAC_GNESNE;
  RESIM_DEGISTIR              = $02041000 + SAC_GNESNE;
  RESIM_TUVALESIGDIR          = $03041000 + SAC_GNESNE;

  LISTEGORUNUM_OLUSTUR	      = OLUSTUR + LISTEGORUNUM + SAC_GNESNE;
  LISTEGORUNUM_ELEMANEKLE     = $01001100 + SAC_GNESNE;
  LISTEGORUNUM_SECILISIRAAL   = $02001100 + SAC_GNESNE;
  LISTEGORUNUM_TEMIZLE        = $03001100 + SAC_GNESNE;
  LISTEGORUNUM_SECILIYAZIAL   = $04001100 + SAC_GNESNE;
  LISTEGORUNUM_BTEMIZLE       = $05001100 + SAC_GNESNE;    // başlıkları temizle
  LISTEGORUNUM_BASLIKEKLE     = $06001100 + SAC_GNESNE;
  LISTEGORUNUM_HIZALA         = $01041100 + SAC_GNESNE;

  PANEL_OLUSTUR	              = OLUSTUR + PANEL + SAC_GNESNE;
  PANEL_GOSTER                = GOSTER + PANEL + SAC_GNESNE;
  PANEL_HIZALA                = $01041200 + SAC_GNESNE;
  PANEL_BOYUTAL               = $08021200 + SAC_GNESNE;

  RESIMDUGMESI_OLUSTUR 	      = OLUSTUR + RESIMDUGMESI + SAC_GNESNE;
  RESIMDUGMESI_GOSTER		      = GOSTER + RESIMDUGMESI + SAC_GNESNE;
  RESIMDUGMESI_HIZALA         = $01041300 + SAC_GNESNE;

  KAYDIRMACUBUGU_OLUSTUR 	    = OLUSTUR + KAYDIRMACUBUGU + SAC_GNESNE;
  KAYDIRMACUBUGU_GOSTER		    = GOSTER + KAYDIRMACUBUGU + SAC_GNESNE;
  KAYDIRMACUBUGU_HIZALA       = $01041400 + SAC_GNESNE;
  KAYDIRMACUBUGU_ALTUSTDEGER  = $02041400 + SAC_GNESNE;

  KARMALISTE_OLUSTUR	        = OLUSTUR + KARMALISTE + SAC_GNESNE;
  KARMALISTE_GOSTER	          = GOSTER + KARMALISTE + SAC_GNESNE;
  KARMALISTE_ELEMANEKLE	      = $01001500 + SAC_GNESNE;
  KARMALISTE_TEMIZLE 	        = $03001500 + SAC_GNESNE;
  KARMALISTE_SECILIYAZIAL     = $04001500 + SAC_GNESNE;
  KARMALISTE_HIZALA           = $01041500 + SAC_GNESNE;
  KARMALISTE_TOPLAMAL         = $01021500 + SAC_GNESNE;
  KARMALISTE_BASLIKSNYAZ      = $02041500 + SAC_GNESNE;

  ACILIRMENU_OLUSTUR	        = OLUSTUR + ACILIRMENU + SAC_GNESNE;
  ACILIRMENU_GOSTER	          = GOSTER + ACILIRMENU + SAC_GNESNE;
  ACILIRMENU_GIZLE	          = GIZLE + ACILIRMENU + SAC_GNESNE;
  ACILIRMENU_ELEMANEKLE	      = $01001600 + SAC_GNESNE;
  ACILIRMENU_SECILISIRANOAL   = $02001600 + SAC_GNESNE;

  DEGERLISTESI_OLUSTUR	      = OLUSTUR + DEGERLISTESI + SAC_GNESNE;
  DEGERLISTESI_GOSTER	        = GOSTER + DEGERLISTESI + SAC_GNESNE;
  DEGERLISTESI_DEGEREKLE	    = $01001700 + SAC_GNESNE;
  DEGERLISTESI_TEMIZLE 	      = $03001700 + SAC_GNESNE;
  DEGERLISTESI_SECILIYAZIAL   = $04001700 + SAC_GNESNE;
  DEGERLISTESI_BASLIKBELIRLE  = $06001700 + SAC_GNESNE;
  DEGERLISTESI_HIZALA         = $01041700 + SAC_GNESNE;

  IZGARA_OLUSTUR	            = OLUSTUR + IZGARA + SAC_GNESNE;
  IZGARA_GOSTER	              = GOSTER + IZGARA + SAC_GNESNE;
  IZGARA_GIZLE	              = GIZLE + IZGARA + SAC_GNESNE;
  IZGARA_CIZ                  = CIZ + IZGARA + SAC_GNESNE;
  IZGARA_HIZALA               = $01041800 + SAC_GNESNE;
  IZGARA_TEMIZLE 	            = $02041800 + SAC_GNESNE;
  IZGARA_ELEMANEKLE           = $03041800 + SAC_GNESNE;
  IZGARA_SABITHUCRESAYISIYAZ  = $04041800 + SAC_GNESNE;
  IZGARA_HUCRESAYISIYAZ       = $05041800 + SAC_GNESNE;
  IZGARA_HUCREBOYUTUYAZ       = $06041800 + SAC_GNESNE;
  IZGARA_KCUBUGUGORUNUMYAZ    = $07041800 + SAC_GNESNE;
  IZGARA_SECILIHUCREYIYAZ     = $08041800 + SAC_GNESNE;

  ARACCUBUGU_OLUSTUR	        = OLUSTUR + ARACCUBUGU + SAC_GNESNE;
  ARACCUBUGU_GOSTER	          = GOSTER + ARACCUBUGU + SAC_GNESNE;
  ARACCUBUGU_DUGMEEKLE	      = $01040000 + ARACCUBUGU + SAC_GNESNE;

  RENKSECICI_OLUSTUR	        = OLUSTUR + RENKSECICI + SAC_GNESNE;
  RENKSECICI_GOSTER	          = GOSTER + RENKSECICI + SAC_GNESNE;

  SAYFAKONTROL_OLUSTUR	      = OLUSTUR + SAYFAKONTROL + SAC_GNESNE;
  SAYFAKONTROL_GOSTER	        = GOSTER + SAYFAKONTROL + SAC_GNESNE;
  SAYFAKONTROL_GIZLE	        = GIZLE + SAYFAKONTROL + SAC_GNESNE;
  SAYFAKONTROL_SAYFAEKLE      = $01041B00 + SAC_GNESNE;
  SAYFAKONTROL_ETIKETEKLE     = $02041B00 + SAC_GNESNE;

  // görsel nesne çağrı tanımları sonu

  // genel nesne çağrıları
  GORSELNESNE_KIMLIKAL 	      = $0001FF00 + SAC_GNESNE;
  GORSELNESNE_BILGIAL 		    = $0002FF00 + SAC_GNESNE;
  GORSELNESNE_NESNEADIAL		  = $0003FF00 + SAC_GNESNE;

  OLAY_AL		                  = $00000100 + SAC_OLAY;
  OLAY_BEKLE		              = $00000200 + SAC_OLAY;

  DOSYA_ARAMAYABASLA	        = $00000200 + SAC_DOSYA;
  DOSYA_SONRAKINIARA 	        = $00000300 + SAC_DOSYA;
  DOSYA_ARAMASONLANDIR	      = $00000400 + SAC_DOSYA;
  DOSYA_TANIMLA   	          = $00000500 + SAC_DOSYA;
  DOSYA_AC    	              = $00000600 + SAC_DOSYA;
  DOSYA_ISLEMKONTROL 	        = $00000700 + SAC_DOSYA;
  DOSYA_DOSYASONU             = $00000800 + SAC_DOSYA;
  DOSYA_DOSYAUZUNLUGU         = $00000900 + SAC_DOSYA;
  DOSYA_OKU     	            = $00000A00 + SAC_DOSYA;
  DOSYA_KAPAT    	            = $00000B00 + SAC_DOSYA;

  HARF_YAZ		                = $00000100 + SAC_YAZIM;
  YAZI_YAZ		                = $00000200 + SAC_YAZIM;
  SAYI_YAZ16		              = $00000300 + SAC_YAZIM;
  SAAT_YAZ		                = $00000400 + SAC_YAZIM;
  MACADRES_YAZ		            = $00000500 + SAC_YAZIM;
  IPADRES_YAZ		              = $00000600 + SAC_YAZIM;
  SAYI_YAZ10  	              = $00000700 + SAC_YAZIM;

  SAYAC_SAAT_AL		            = $00000100 + SAC_SAYAC;
  SAYAC_TARIH_AL		          = $00000200 + SAC_SAYAC;
  SAYAC_BEKLE                 = $00001000 + SAC_SAYAC;

  SISTEMBILGISI_AL		        = $00000100 + SAC_SISTEM;
  ISLEMCIBILGISI_AL		        = $00000200 + SAC_SISTEM;

  PIXEL_YAZ                   = $00000100 + SAC_CIZIM;
  DIKDORTGEN_CIZ              = $00000200 + SAC_CIZIM;
  CIZGI_CIZ                   = $00000300 + SAC_CIZIM;
  DAIRE_CIZ                   = $00000400 + SAC_CIZIM;

  ZAMANLAYICI_OLUSTUR		      = $00000100 + SAC_ZAMANLAYICI;
  ZAMANLAYICI_BASLAT		      = $00000200 + SAC_ZAMANLAYICI;
  ZAMANLAYICI_DURDUR		      = $00000300 + SAC_ZAMANLAYICI;

  SISTEMMESAJ_TOPLAM	        = $00000100 + SAC_MESAJ;
  SISTEMMESAJ_MESAJAL	        = $00000200 + SAC_MESAJ;
  SISTEMMESAJ_YAZIEKLE        = $00000300 + SAC_MESAJ;
  SISTEMMESAJ_SAYI16EKLE		  = $00000400 + SAC_MESAJ;

  BELLEK_CEKIRDEKBILGISI	    = $00000100 + SAC_BELLEK;
  BELLEK_GENELBILGI	          = $00000200 + SAC_BELLEK;
  BELLEK_ICERIKOKU	          = $00000300 + SAC_BELLEK;

  GOREV_CALISTIR	            = $00000100 + SAC_GOREV;
  GOREV_SONLANDIR             = $00000200 + SAC_GOREV;
  GOREV_SAYISINIAL	          = $00000300 + SAC_GOREV;
  GOREV_BILGISIAL	            = $00000400 + SAC_GOREV;
  GOREV_YAZMACBILGISIAL	      = $00000500 + SAC_GOREV;
  GOREV_CALISANPSAYISINIAL    = $00000600 + SAC_GOREV;
  GOREV_CALISANPBILGISIAL     = $00000700 + SAC_GOREV;
  GOREV_AKTIFPROGRAMIAL       = $00000800 + SAC_GOREV;
  GOREV_KIMLIGIAL             = $00000900 + SAC_GOREV;
  GOREV_ADYAZ                 = $00000A00 + SAC_GOREV;

  PCI_TOPLAMAYGITSAYISI	      = $00000100 + SAC_PCI;
  PCI_AYGITBILGISIAL	        = $00000200 + SAC_PCI;
  PCI_OKU1 	                  = $00000300 + SAC_PCI;
  PCI_OKU2 	                  = $00000400 + SAC_PCI;
  PCI_OKU4	                  = $00000500 + SAC_PCI;
  PCI_YAZ1	                  = $00000600 + SAC_PCI;
  PCI_YAZ2	                  = $00000700 + SAC_PCI;
  PCI_YAZ4	                  = $00000800 + SAC_PCI;

  AG_BILGISIAL                = $00010100 + SAC_AG;
  
  ARP_KAYITSAYISIAL	          = $00010200 + SAC_AG;
  ARP_KAYITBILGISIAL	        = $00020200 + SAC_AG;
 
  FARE_KONUMAL                = $00000100 + SAC_FARE;

  GIYSI_TOPLAMAL              = $00000100 + SAC_GIYSI;
  GIYSI_ADAL                  = $00000200 + SAC_GIYSI;
  GIYSI_AKTIFSIRANOAL         = $00000300 + SAC_GIYSI;
  GIYSI_AKTIFLESTIR           = $00000400 + SAC_GIYSI;

  // tcp / udp ham bağlantı işlevleri
  ILETISIM_BAGLAN             = $00010100 + SAC_ILETISIM;
  ILETISIM_BAGLIMI            = $00020100 + SAC_ILETISIM;
  ILETISIM_VERIUZUNLUGU       = $00030100 + SAC_ILETISIM;
  ILETISIM_VERIOKU            = $00040100 + SAC_ILETISIM;
  ILETISIM_VERIYAZ            = $00050100 + SAC_ILETISIM;
  ILETISIM_BAGKES             = $00060100 + SAC_ILETISIM;

  // dns bağlantı işlevleri
  ILETISIM_DNS_OLUSTUR        = $00010200 + SAC_ILETISIM;
  ILETISIM_DNS_SORGULA        = $00020200 + SAC_ILETISIM;
  ILETISIM_DNS_DURUMAL        = $00030200 + SAC_ILETISIM;
  ILETISIM_DNS_ICERIKAL       = $00040200 + SAC_ILETISIM;
  ILETISIM_DNS_KAPAT          = $00050200 + SAC_ILETISIM;
  ILETISIM_DNS_YOKET          = $00060200 + SAC_ILETISIM;

const
  // çekirdeğin ürettiği genel olaylar - çekirdek olay (CO)
  CO_ILKDEGER             = $100;
  CO_CIZIM                = CO_ILKDEGER + 0;
  CO_ZAMANLAYICI          = CO_ILKDEGER + 1;
  CO_OLUSTUR              = CO_ILKDEGER + 2;
  CO_DURUMDEGISTI         = CO_ILKDEGER + 3;
  CO_ODAKKAZANILDI        = CO_ILKDEGER + 4;
  CO_ODAKKAYBEDILDI       = CO_ILKDEGER + 5;
  CO_TUSBASILDI           = CO_ILKDEGER + 6;
  CO_MENUACILDI           = CO_ILKDEGER + 7;        // menünün açılması
  CO_MENUKAPATILDI        = CO_ILKDEGER + 8;        // menünün kapatılması
  CO_SECIMDEGISTI         = CO_ILKDEGER + 9;        // karma liste nesnesinde seçimin değişmesi olayı

  // fare aygıtının ürettiği olaylar - fare olayları (FO)
  FO_ILKDEGER             = $200;
  FO_BILINMIYOR           = FO_ILKDEGER;
  FO_SOLTUS_BASILDI       = FO_ILKDEGER + 2;
  FO_SOLTUS_BIRAKILDI     = FO_ILKDEGER + 2 + 1;
  FO_SAGTUS_BASILDI       = FO_ILKDEGER + 4;
  FO_SAGTUS_BIRAKILDI     = FO_ILKDEGER + 4 + 1;
  FO_ORTATUS_BASILDI      = FO_ILKDEGER + 6;
  FO_ORTATUS_BIRAKILDI    = FO_ILKDEGER + 6 + 1;
  FO_4NCUTUS_BASILDI      = FO_ILKDEGER + 8;
  FO_4NCUTUS_BIRAKILDI    = FO_ILKDEGER + 8 + 1;
  FO_5NCITUS_BASILDI      = FO_ILKDEGER + 10;
  FO_5NCITUS_BIRAKILDI    = FO_ILKDEGER + 10 + 1;
  FO_HAREKET              = FO_ILKDEGER + 122;
  FO_TIKLAMA              = FO_ILKDEGER + 124;
  //FO_CIFTTIKLAMA        = FO_ILKDEGER + 126;
  FO_KAYDIRMA             = FO_ILKDEGER + 128;

  RENK_SIYAH		              = TRenk($000000);
  RENK_BORDO		              = TRenk($800000);
  RENK_YESIL		              = TRenk($008000);
  RENK_ZEYTINYESILI		        = TRenk($808000);
  RENK_LACIVERT	              = TRenk($000080);
  RENK_MOR		                = TRenk($800080);
  RENK_TURKUAZ	              = TRenk($008080);
  RENK_GRI		                = TRenk($808080);
  RENK_GUMUS		              = TRenk($C0C0C0);
  RENK_KIRMIZI                = TRenk($FF0000);
  RENK_ACIKYESIL              = TRenk($00FF00);
  RENK_SARI		                = TRenk($FFFF00);
  RENK_MAVI		                = TRenk($0000FF);
  RENK_PEMBE 	                = TRenk($FF00FF);
  RENK_ACIKMAVI		            = TRenk($00FFFF);
  RENK_BEYAZ		              = TRenk($FFFFFF);

  PROCESS_STATE_FREE	        = 0;
  PROCESS_STATE_CREATED       = 1;
  PROCESS_STATE_RUNNING       = 2;
  PROCESS_STATE_STOPPED       = 3;
