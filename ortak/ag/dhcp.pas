{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: dhcp.pas
  Dosya Ýþlevi: DHCP protokol istemci iþlevlerini yönetir

  Güncelleme Tarihi: 27/10/2019

  Bilgi: sadece kullanýlan sabit, deðiþken ve iþlevler türkçeye çevrilmiþtir

 ==============================================================================}
{$mode objfpc}
unit dhcp;

interface

uses paylasim;

const
  DHCP_SUNUCU_PORT                        = Byte(67);
  DHCP_ISTEMCI_PORT                       = Byte(68);

	DHCP_ACILIS_ISTEK                       = Byte(1);
	DHCP_ACILIS_YANIT                       = Byte(2);

  // DHCP message types
  DHCP_UNKNOWN                            = Byte(0);
  DHCP_KESIF                              = Byte(1);
  DHCP_OFFER                              = Byte(2);
  DHCP_ISTEK                              = Byte(3);
  DHCP_DECLINE                            = Byte(4);
  DHCP_ACK                                = Byte(5);
  DHCP_NAK                                = Byte(6);
  DHCP_RELEASE                            = Byte(7);
  DHCP_INFORM                             = Byte(8);
  DHCP_LEASE_QUERY                        = Byte(10);
  DHCP_LEASE_UNASSIGNED                   = Byte(11);
  DHCP_LEASE_UNKNOWN                      = Byte(12);
  DHCP_LEASE_ACTIVE                       = Byte(13);

  DHCP_OPTION_PAD                         = Byte(0);
  DHCP_SECENEK_ALTAG_MASKESI              = Byte(1);
  DHCP_OPTION_TIME_OFFSET                 = Byte(2);   // deprecated
  DHCP_SECENEK_YONLENDIRICI               = Byte(3);
  DHCP_OPTION_TIME_SERVER                 = Byte(4);
  DHCP_OPTION_NAME_SERVER                 = Byte(5);
  DHCP_SECENEK_DNS                        = Byte(6);
  DHCP_OPTION_LOG_SERVER                  = Byte(7);
  DHCP_OPTION_QUOTE_SERVER                = Byte(8);
  DHCP_OPTION_LPR_SERVER                  = Byte(9);
  DHCP_OPTION_IMPRESS_SERVER              = Byte(10);
  DHCP_OPTION_RESOURCE_LOCATION_SERVER    = Byte(11);
  DHCP_SECENEK_EVSAHIBI_AD                = Byte(12);
  DHCP_OPTION_BOOT_FILE_SIZE              = Byte(13);
  DHCP_OPTION_MERIT_DUMP_FILE             = Byte(14);
  DHCP_SECENEK_ALAN_ADI                   = Byte(15);
  DHCP_OPTION_SWAP_SERVER                 = Byte(16);
  DHCP_OPTION_ROOT_PATH                   = Byte(17);
  DHCP_OPTION_EXTENSION_PATH              = Byte(18);
  DHCP_OPTION_IP_FWD_CONTROL              = Byte(19);
  DHCP_OPTION_NL_SRC_ROUTING              = Byte(20);
  DHCP_OPTION_POLICY_FILTER               = Byte(21);
  DHCP_OPTION_MAX_DG_REASSEMBLY_SIZE      = Byte(22);
  DHCP_OPTION_DEFAULT_IP_TTL              = Byte(23);
  DHCP_OPTION_PATH_MTU_AGING_TIMEOUT      = Byte(24);
  DHCP_OPTION_PATH_MTU_PLATEAU_TABLE      = Byte(25);
  DHCP_OPTION_INTERFACE_MTU               = Byte(26);
  DHCP_OPTION_ALL_SUBNETS_LOCAL           = Byte(27);
  DHCP_OPTION_BCAST_ADDRESS               = Byte(28);
  DHCP_OPTION_PERFORM_MASK_DISCOVERY      = Byte(29);
  DHCP_OPTION_MASK_SUPPLIER               = Byte(30);
  DHCP_SECENEK_YONLENDIRICI_KESIF_UYGULA  = Byte(31);
  DHCP_OPTION_ROUTER_SOLICIT_ADDRESS      = Byte(32);
  DHCP_SECENEK_SABIT_YONLENDIRME_TABLOSU  = Byte(33);
  DHCP_OPTION_TRAILER_ENCAP               = Byte(34);
  DHCP_OPTION_ARP_CACHE_TIMEOUT           = Byte(35);
  DHCP_OPTION_ETHERNET_ENCAP              = Byte(36);
  DHCP_OPTION_DEFAULT_TCP_TTL             = Byte(37);
  DHCP_OPTION_TCP_KEEPALIVE_INTERVAL      = Byte(38);
  DHCP_OPTION_TCP_KEEPALIVE_GARBAGE       = Byte(39);
  DHCP_OPTION_NIS_DOMAIN                  = Byte(40);
  DHCP_OPTION_NIS_SERVERS                 = Byte(41);
  DHCP_OPTION_NTP_SERVERS                 = Byte(42);
  DHCP_SECENEK_SATICI_OZEL_BILGI          = Byte(43);
  DHCP_SECENEK_NETBIOS_TCP_NS_ILE         = Byte(44);
  DHCP_OPTION_NETBIOS_OVER_TCP_DG_DS      = Byte(45);
  DHCP_SECENEK_NETBIOS_TCP_DUGUM_TIP_ILE  = Byte(46);
  DHCP_SECENEK_NETBIOS_TCP_KAPSAM_ILE     = Byte(47);
  DHCP_OPTION_XWINDOW_FONT_SERVER         = Byte(48);
  DHCP_OPTION_XWINDOW_SYSTEM_DISP_MGR     = Byte(49);
  DHCP_SECENEK_ISTEK_IP_ADRES             = Byte(50);
  DHCP_SECENEK_IP_KIRALAMA_SURESI         = Byte(51);
  DHCP_OPTION_OVERLOAD                    = Byte(52);
  DHCP_SECENEK_MESAJ_TIP                  = Byte(53);
  DHCP_OPTION_SERVER_IDENTIFIER           = Byte(54);
  DHCP_SECENEK_DEGISKEN_ISTEK_LISTESI     = Byte(55);
  DHCP_OPTION_MESSAGE                     = Byte(56);
  DHCP_OPTION_MAX_DHCP_MSG_SIZE           = Byte(57);
  DHCP_OPTION_RENEW_TIME_VALUE            = Byte(58);
  DHCP_OPTION_REBIND_TIME_VALUE           = Byte(59);
  DHCP_OPTION_CLASS_ID                    = Byte(60);
  DHCP_OPTION_CLIENT_ID                   = Byte(61);
  DHCP_OPTION_NETWARE_IP_DOMAIN_NAME      = Byte(62);
  DHCP_OPTION_NETWARE_IP_INFO             = Byte(63);
  DHCP_OPTION_NIS_PLUS_DOMAIN             = Byte(64);
  DHCP_OPTION_NIS_PLUS_SERVERS            = Byte(65);
  DHCP_OPTION_TFTP_SERVER_NAME            = Byte(66);
  DHCP_OPTION_BOOTFILE_NAME               = Byte(67);
  DHCP_OPTION_MOBILE_IP_HA                = Byte(68);
  DHCP_OPTION_SMTP_SERVER                 = Byte(69);
  DHCP_OPTION_POP_SERVER                  = Byte(70);
  DHCP_OPTION_NNTP_SERVER                 = Byte(71);
  DHCP_OPTION_DEFAULT_WWW_SERVER          = Byte(72);
  DHCP_OPTION_DEFAULT_FINGER_SERVER       = Byte(73);
  DHCP_OPTION_DEFAULT_IRC_SERVER          = Byte(74);
  DHCP_OPTION_STREETTALK_SERVER           = Byte(75);
  DHCP_OPTION_STREETTALK_DA_SERVER        = Byte(76);
  DHCP_OPTION_USER_CLASS_INFO             = Byte(77);
  DHCP_OPTION_SLP_DIRECTORY_AGENT         = Byte(78);
  DHCP_OPTION_SLP_SERVICE_SCOPE           = Byte(79);
  DHCP_OPTION_RAPID_COMMIT                = Byte(80);
  DHCP_OPTION_CLIENT_FQDN                 = Byte(81);
  DHCP_OPTION_82                          = Byte(82);
  DHCP_OPTION_STORAGE_NS                  = Byte(83);
  // ignoring option 84 (removed / unassigned)
  DHCP_OPTION_NDS_SERVERS                 = Byte(85);
  DHCP_OPTION_NDS_TREE_NAME               = Byte(86);
  DHCP_OPTION_NDS_CONTEXT                 = Byte(87);
  DHCP_OPTION_BCMCS_DN_LIST               = Byte(88);
  DHCP_OPTION_BCMCS_ADDR_LIST             = Byte(89);
  DHCP_OPTION_AUTH                        = Byte(90);
  DHCP_OPTION_CLIENT_LAST_XTIME           = Byte(91);
  DHCP_OPTION_ASSOCIATE_IP                = Byte(92);
  DHCP_OPTION_CLIENT_SYSARCH_TYPE         = Byte(93);
  DHCP_OPTION_CLIENT_NW_INTERFACE_ID      = Byte(94);
  DHCP_OPTION_LDAP                        = Byte(95);
  // ignoring 96 (removed / unassigned)
  DHCP_OPTION_CLIENT_MACHINE_ID           = Byte(97);
  DHCP_OPTION_OPENGROUP_USER_AUTH         = Byte(98);
  DHCP_OPTION_GEOCONF_CIVIC               = Byte(99);
  DHCP_OPTION_IEEE_1003_1_TZ              = Byte(100);
  DHCP_OPTION_REF_TZ_DB                   = Byte(101);
  // ignoring 102 to 111 & 115 (removed / unassigned)
  DHCP_OPTION_NETINFO_PARENT_SERVER_ADDR  = Byte(112);
  DHCP_OPTION_NETINFO_PARENT_SERVER_TAG   = Byte(113);
  DHCP_OPTION_URL                         = Byte(114);
  DHCP_SECENEK_OTO_AYAR                   = Byte(116);
  DHCP_OPTION_NAME_SERVICE_SEARCH         = Byte(117);
  DHCP_OPTION_SUBNET_SELECTION            = Byte(118);
  DHCP_OPTION_DNS_DOMAIN_SEARCH_LIST      = Byte(119);
  DHCP_OPTION_SIP_SERVERS                 = Byte(120);
  DHCP_SECENEK_SINIFDISI_YONLENDIRME      = Byte(121);
  DHCP_OPTION_CCC                         = Byte(122);
  DHCP_OPTION_GEOCONF                     = Byte(123);
  DHCP_OPTION_VENDOR_ID_VENDOR_CLASS      = Byte(124);
  DHCP_OPTION_VENDOR_ID_VENDOR_SPECIFIC   = Byte(125);
  // ignoring 126, 127 (removed / unassigned)
  // options 128 - 135 arent officially assigned to PXE
  DHCP_OPTION_TFTP_SERVER                 = Byte(128);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_129     = Byte(129);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_130     = Byte(130);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_131     = Byte(131);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_132     = Byte(132);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_133     = Byte(133);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_134     = Byte(134);
  DHCP_OPTION_PXE_VENDOR_SPECIFIC_135     = Byte(135);
  DHCP_OPTION_PANA_AUTH_AGENT             = Byte(136);
  DHCP_OPTION_LOST_SERVER                 = Byte(137);
  DHCP_OPTION_CAPWAP_AC_ADDRESS           = Byte(138);
  DHCP_OPTION_IPV4_ADDRESS_MOS            = Byte(139);
  DHCP_OPTION_IPV4_FQDN_MOS               = Byte(140);
  DHCP_OPTION_SIP_UA_CONFIG_DOMAIN        = Byte(141);
  DHCP_OPTION_IPV4_ADDRESS_ANDSF          = Byte(142);
  DHCP_OPTION_GEOLOC                      = Byte(144);
  DHCP_OPTION_FORCERENEW_NONCE_CAP        = Byte(145);
  DHCP_OPTION_RDNSS_SELECTION             = Byte(146);
  // ignoring options 143, 147 - 149 (removed / unassigned)
  // option 150 is also assigned as Etherboot, GRUB configuration path name
  DHCP_OPTION_TFTP_SERVER_ADDRESS         = Byte(150);
  DHCP_OPTION_STATUS_CODE                 = Byte(151);
  DHCP_OPTION_BASE_TIME                   = Byte(152);
  DHCP_OPTION_START_TIME_OF_STATE         = Byte(153);
  DHCP_OPTION_QUERY_START_TIME            = Byte(154);
  DHCP_OPTION_QUERY_END_TIME              = Byte(155);
  DHCP_OPTION_DHCP_STATE                  = Byte(156);
  DHCP_OPTION_DATA_SOURCE                 = Byte(157);
  DHCP_OPTION_PCP_SERVER                  = Byte(158);
  // ignoring options 159 - 174 (removed / unassigned)
  // ignoring options 175 - 177 (tentatively assigned)
  // ignoring options 178 - 207 (removed / unassigned)
  DHCP_OPTION_PXELINUX_MAGIC              = Byte(208);  // deprecated
  DHCP_OPTION_CONFIG_FILE                 = Byte(209);
  DHCP_OPTION_PATH_PREFIX                 = Byte(210);
  DHCP_OPTION_REBOOT_TIME                 = Byte(211);
  DHCP_OPTION_6RD                         = Byte(212);
  DHCP_OPTION_V4_ACCESS_DOMAIN            = Byte(213);
  // ignoring options 214 - 219 (removed / unassigned)
  DHCP_OPTION_SUBNET_ALLOCATION           = Byte(220);
  DHCP_OPTION_VSS                         = Byte(221);
  // ignoring options 222 - 254 (removed / unassigned)
  DHCP_SECENEK_SON                        = Byte(255);

  DHCP_SIHIRLI_CEREZ    = TSayi4($63538263);
  DHCP_GONDEREN_KIMLIK  = TSayi4($3903F328);

type
  PDHCPMesaj = ^TDHCPMesaj;
  TDHCPMesaj = packed record
    MesajTip: TSayi1;
    Uzunluk: TSayi1;
    Mesaj: Isaretci;
  end;

procedure DHCPSunucuKesfet;
procedure DHCPIpAdresIste(AIstenenIPAdresi: TIPAdres);
procedure DHCPPaketleriniIsle(ADHCPKayit: PDHCPKayit);

implementation

uses genel, baglanti, donusum;

// aðda DHCP sunucusunun mevcut olup olmadýðýna dair mesaj yayýnlar
procedure DHCPSunucuKesfet;
var
  _Baglanti: PBaglanti;
  _DHCPKayit: PDHCPKayit;
  _p: PSayi1;
begin

  _DHCPKayit := GGercekBellek.Ayir(4095);

	_DHCPKayit^.Islem := DHCP_ACILIS_ISTEK;
	_DHCPKayit^.DonanimTip := 1;		    // ethernet
	_DHCPKayit^.DonanimUz := 6;		      // mac uzunluðu
	_DHCPKayit^.RelayIcin := 0;
	_DHCPKayit^.GonderenKimlik := DHCP_GONDEREN_KIMLIK;
	_DHCPKayit^.Sure := 0;
	_DHCPKayit^.Bayraklar := 0;
	_DHCPKayit^.IstemciIPAdres := IPAdres0;
	_DHCPKayit^.BenimIPAdresim := IPAdres0;
	_DHCPKayit^.SunucuIPAdres := IPAdres0;
	_DHCPKayit^.AgGecidiIPAdres := IPAdres0;
	_DHCPKayit^.IstemciMACAdres := AgBilgisi.MACAdres;
	_DHCPKayit^.AYRLDI1 := 0;
	_DHCPKayit^.AYRLDI2 := 0;
	_DHCPKayit^.AYRLDI3 := 0;
  FillChar(_DHCPKayit^.SunucuEvSahibiAdi, 64, #0);
  FillChar(_DHCPKayit^.AcilisDosyaAdi, 128, #0);
	_DHCPKayit^.SihirliCerez := DHCP_SIHIRLI_CEREZ;
  _p := @_DHCPKayit^.DigerSecenekler;

  // 3 byte
  _p^ := DHCP_SECENEK_MESAJ_TIP;
  Inc(_p);
  _p^ := 1;
  Inc(_p);
  _p^ := DHCP_KESIF;
  Inc(_p);

  // 3 byte
  _p^ := DHCP_SECENEK_OTO_AYAR;
  Inc(_p);
  _p^ := 1;
  Inc(_p);
  _p^ := 1;
  Inc(_p);

  // parametre istek listesi - 13 byte
  _p^ := DHCP_SECENEK_DEGISKEN_ISTEK_LISTESI;
  Inc(_p);
  _p^ := DHCP_SECENEK_EVSAHIBI_AD;
  Inc(_p);
  _p^ := DHCP_SECENEK_ALTAG_MASKESI;
  Inc(_p);
  _p^ := DHCP_SECENEK_ALAN_ADI;
  Inc(_p);
  _p^ := DHCP_SECENEK_YONLENDIRICI;
  Inc(_p);
  _p^ := DHCP_SECENEK_ALAN_ADI;
  Inc(_p);
  _p^ := DHCP_SECENEK_NETBIOS_TCP_NS_ILE;
  Inc(_p);
  _p^ := DHCP_SECENEK_NETBIOS_TCP_DUGUM_TIP_ILE;
  Inc(_p);
  _p^ := DHCP_SECENEK_NETBIOS_TCP_KAPSAM_ILE;
  Inc(_p);
  _p^ := DHCP_SECENEK_YONLENDIRICI_KESIF_UYGULA;
  Inc(_p);
  _p^ := DHCP_SECENEK_SABIT_YONLENDIRME_TABLOSU;
  Inc(_p);
  _p^ := DHCP_SECENEK_SINIFDISI_YONLENDIRME;
  Inc(_p);
  _p^ := DHCP_SECENEK_SATICI_OZEL_BILGI;
  Inc(_p);

  _p^ := DHCP_SECENEK_SON;

  _Baglanti := GBaglanti^.Olustur(ptUDP, IPAdres255, DHCP_ISTEMCI_PORT,
    DHCP_SUNUCU_PORT);

  _Baglanti^.Yaz(@_DHCPKayit[0], 240 + 20);

  _Baglanti^.BaglantiyiKes;

  GGercekBellek.YokEt(_DHCPKayit, 4095);
end;

// DHCP sunucusundan IP adres isteði gerçekleþtirir
procedure DHCPIpAdresIste(AIstenenIPAdresi: TIPAdres);
var
  _Baglanti: PBaglanti;
  _DHCPKayit: PDHCPKayit;
  _IPAdres: PIPAdres;
  _MakineAdiUz: TSayi1;
  _p1: PSayi1;
  _p4: PSayi4;
  _p: PChar;
begin

  _DHCPKayit := GGercekBellek.Ayir(4095);

	_DHCPKayit^.Islem := DHCP_ACILIS_ISTEK;
	_DHCPKayit^.DonanimTip := 1;		  // ethernet
	_DHCPKayit^.DonanimUz := 6;		    // mac uzunluðu
	_DHCPKayit^.RelayIcin := 0;
	_DHCPKayit^.GonderenKimlik := DHCP_GONDEREN_KIMLIK;
	_DHCPKayit^.Sure := 0;
	_DHCPKayit^.Bayraklar := 0;
	_DHCPKayit^.IstemciIPAdres := IPAdres0;
	_DHCPKayit^.BenimIPAdresim := IPAdres0;
	_DHCPKayit^.SunucuIPAdres := IPAdres0;
	_DHCPKayit^.AgGecidiIPAdres := IPAdres0;
	_DHCPKayit^.IstemciMACAdres := AgBilgisi.MACAdres;
	_DHCPKayit^.AYRLDI1 := 0;
	_DHCPKayit^.AYRLDI2 := 0;
	_DHCPKayit^.AYRLDI3 := 0;
  FillChar(_DHCPKayit^.SunucuEvSahibiAdi, 64, #0);
  FillChar(_DHCPKayit^.AcilisDosyaAdi, 128, #0);
	_DHCPKayit^.SihirliCerez := DHCP_SIHIRLI_CEREZ;
  _p1 := @_DHCPKayit^.DigerSecenekler;

  // mesaj tipi - 3 byte
  _p1^ := DHCP_SECENEK_MESAJ_TIP;
  Inc(_p1);
  _p1^ := 1;
  Inc(_p1);
  _p1^ := DHCP_ISTEK;
  Inc(_p1);

  // bilgisayar adý tanýmý - 2 + MakineAdi byte
  _MakineAdiUz := Length(MakineAdi);
  _p1^ := DHCP_SECENEK_EVSAHIBI_AD;
  Inc(_p1);
  PByte(_p1)^ := _MakineAdiUz;
  Inc(_p1);
  _p := Pointer(_p1);
  Tasi2(@MakineAdi[1], _p, _MakineAdiUz);
  Inc(_p, _MakineAdiUz);
  _p1 := Pointer(_p);

  // kiralama süresi - 6
  _p1^ := DHCP_SECENEK_IP_KIRALAMA_SURESI;
  Inc(_p1);
  _p1^ := 4;
  Inc(_p1);
  _p4 := Pointer(_p1);
  _p4^ := $FFFFFFFF;   // süresiz
  Inc(_p4);
  _p1 := Pointer(_p4);

  // istenen ip adresi - 6 byte
  _p1^ := DHCP_SECENEK_ISTEK_IP_ADRES;
  Inc(_p1);
  _p1^ := 4;
  Inc(_p1);
  _IPAdres := Pointer(_p1);
  _IPAdres^ := AIstenenIPAdresi;
  Inc(_IPAdres);
  _p1 := Pointer(_IPAdres);

  // parametre istek listesi - 13 byte
  _p1^ := DHCP_SECENEK_DEGISKEN_ISTEK_LISTESI;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_EVSAHIBI_AD;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_ALTAG_MASKESI;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_ALAN_ADI;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_YONLENDIRICI;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_ALAN_ADI;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_NETBIOS_TCP_NS_ILE;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_NETBIOS_TCP_DUGUM_TIP_ILE;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_NETBIOS_TCP_KAPSAM_ILE;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_YONLENDIRICI_KESIF_UYGULA;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_SABIT_YONLENDIRME_TABLOSU;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_SINIFDISI_YONLENDIRME;
  Inc(_p1);
  _p1^ := DHCP_SECENEK_SATICI_OZEL_BILGI;
  Inc(_p1);

  _p1^ := DHCP_SECENEK_SON;

  _Baglanti := GBaglanti^.Olustur(ptUDP, IPAdres0, DHCP_ISTEMCI_PORT, DHCP_SUNUCU_PORT);

  _Baglanti^.Yaz(@_DHCPKayit[0], 240 + 31 + _MakineAdiUz);

  _Baglanti^.BaglantiyiKes;

  GGercekBellek.YokEt(_DHCPKayit, 4095);
end;

// gelen DHCP paketlerini iþler
procedure DHCPPaketleriniIsle(ADHCPKayit: PDHCPKayit);
var
  _DHCPMesaj: PDHCPMesaj;
  _IPAdres: TIPAdres;
  _MesajTip, _Uzunluk: TSayi1;
  _p: PSayi1;
begin

  // alýnan SihirliCerez deðeri gönderdiðimiz deðer mi?
  if(ADHCPKayit^.SihirliCerez = DHCP_SIHIRLI_CEREZ) then
  begin

    // alýnan GonderenKimlik deðeri gönderdiðimiz deðer mi?
    if(ADHCPKayit^.GonderenKimlik = DHCP_GONDEREN_KIMLIK) then
    begin

      // alýnan mesaj bir yanýt _IPAdresý?
      if(ADHCPKayit^.Islem = DHCP_ACILIS_YANIT) then
      begin

        // seçenek olarak alýnan yapýyý döngü içerisinde irdele
        _DHCPMesaj := @ADHCPKayit^.DigerSecenekler;
        _MesajTip := _DHCPMesaj^.MesajTip;
        _Uzunluk := _DHCPMesaj^.Uzunluk;

        // seçeneðin sonuna gelinceye kadar tü_IPAdres seçenekleri iþleme al
        while _MesajTip <> DHCP_SECENEK_SON do
        begin

          if(_MesajTip = DHCP_SECENEK_ALTAG_MASKESI) and (_Uzunluk = 4) then

            AgBilgisi.AltAgMaskesi := PIPAdres(@_DHCPMesaj^.Mesaj)^
          else if(_MesajTip = DHCP_SECENEK_YONLENDIRICI) and (_Uzunluk = 4) then
          begin

            AgBilgisi.AgGecitAdresi := PIPAdres(@_DHCPMesaj^.Mesaj)^;
          end
          else if(_MesajTip = DHCP_SECENEK_DNS) and (_Uzunluk = 4) then
          begin

            AgBilgisi.DNSSunucusu := PIPAdres(@_DHCPMesaj^.Mesaj)^
          end
          else if(_MesajTip = DHCP_SECENEK_IP_KIRALAMA_SURESI) then
          begin

            AgBilgisi.IPKiraSuresi := Takas4(PLongWord(@_DHCPMesaj^.Mesaj)^);
          end
          else if(_MesajTip = DHCP_SECENEK_MESAJ_TIP) then
          begin

            if(PByte(@_DHCPMesaj^.Mesaj)^ = DHCP_ACK) then
            begin

              _IPAdres := ADHCPKayit^.BenimIPAdresim;
              AgBilgisi.IP4Adres := _IPAdres;
            end
            else if(PByte(@_DHCPMesaj^.Mesaj)^ = DHCP_OFFER) then
            begin

              _IPAdres := ADHCPKayit^.BenimIPAdresim;
              DHCPIpAdresIste(_IPAdres);
            end;
          end
          else if(_MesajTip = DHCP_OPTION_SERVER_IDENTIFIER) and (_Uzunluk = 4) then
          begin

            AgBilgisi.DHCPSunucusu := PIPAdres(@_DHCPMesaj^.Mesaj)^;
          end;

          // bir sonraki seçeneðe konumlan
          _p := Pointer(_DHCPMesaj);
          Inc(_p, _Uzunluk + 2);
          _DHCPMesaj := Pointer(_p);
          _MesajTip := _DHCPMesaj^.MesajTip;
          _Uzunluk := _DHCPMesaj^.Uzunluk;
        end;
      end;
    end;
  end;
end;

end.
