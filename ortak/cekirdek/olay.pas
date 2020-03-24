{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: olay.pas
  Dosya Ýþlevi: olay yönetim iþlevlerini içerir

  Güncelleme Tarihi: 10/11/2019

 ==============================================================================}
{$mode objfpc}
unit olay;

interface

uses gorselnesne, paylasim, gn_masaustu, gn_pencere, gn_dugme, gn_gucdugme, gn_listekutusu,
  gn_menu, gn_defter, gn_islemgostergesi, gn_onaykutusu, gn_giriskutusu, gn_degerdugmesi,
  gn_etiket, gn_durumcubugu, gn_secimdugme, gn_baglanti, gn_resim, gn_listegorunum,
  gn_panel, gn_resimdugme;

type
  TOlay = object
  private
    SonYatayFareDegeri, SonDikeyFareDegeri: TISayi4;
    SonBasilanFareTusu: TSayi1;
    OdaklanilanGorselNesne: PGorselNesne;     // farenin, üzerinde bulunduðu nesne
    AktifGorselNesne: PGorselNesne;           // farenin, üzerine sol tuþ ile basýlýp seçildiði nesne
  protected
    procedure OlaylariYonlendir(AGorselNesne: PGorselNesne; AOlayKayit: TOlayKayit);
  public
    procedure Yukle;
    function FareOlayiAl: TOlayKayit;
    procedure FareOlaylariniIsle;
    procedure KlavyeOlaylariniIsle(ATus: Char);
  end;

implementation

uses genel, gn_islevler, src_ps2, gorev;

{==============================================================================
  olay deðiþkenlerini ilk deðerlerle yükler
 ==============================================================================}
procedure TOlay.Yukle;
begin

  OdaklanilanGorselNesne := nil;
  YakalananGorselNesne := nil;
  AktifGorselNesne := nil;

  SonBasilanFareTusu := 0;
end;

{==============================================================================
  fare bilgilerini iþleyerek olaya çevirir
 ==============================================================================}
function TOlay.FareOlayiAl: TOlayKayit;
var
  _FareOlay: TFareOlay;
begin

  // fare sürücüsünden fare olaylarýný al
  if(GFareSurucusu.OlaylariAl(@_FareOlay)) then
  begin

    // daha önce fare tuþuna basýlmamýþsa...
    if(SonBasilanFareTusu = 0) then
    begin

      if((_FareOlay.Dugme and 1) = 1) then
      begin

        SonBasilanFareTusu := 1;
        Result.Olay := FO_SOLTUS_BASILDI;
      end
      else if((_FareOlay.Dugme and 2) = 2) then
      begin

        SonBasilanFareTusu := 2;
        Result.Olay := FO_SAGTUS_BASILDI;
      end
      else if((_FareOlay.Dugme and 4) = 4) then
      begin

        SonBasilanFareTusu := 4;
        Result.Olay := FO_ORTATUS_BASILDI;
      end
      else if((_FareOlay.Dugme and 16) = 16) then
      begin

        SonBasilanFareTusu := 16;
        Result.Olay := FO_4NCUTUS_BASILDI;
      end
      else if((_FareOlay.Dugme and 32) = 32) then
      begin

        SonBasilanFareTusu := 32;
        Result.Olay := FO_5NCITUS_BASILDI;
      end
      else if(_FareOlay.Tekerlek <> 0) then
      begin

        Result.Olay := FO_KAYDIRMA;
        Result.Deger1 := _FareOlay.Tekerlek;
      end
      else if(_FareOlay.A1 <> SonYatayFareDegeri) or (_FareOlay.B1 <> SonDikeyFareDegeri) then
      begin

        Result.Olay := FO_HAREKET;
      end
      else Result.Olay := FO_BILINMIYOR;
    end
    else
    // daha önce fare tuþuna basýlmýþsa...
    begin

      if(SonBasilanFareTusu = 1) and ((_FareOlay.Dugme and 1) = 0) then
      begin

        SonBasilanFareTusu := 0;
        Result.Olay := FO_SOLTUS_BIRAKILDI;
      end
      else if(SonBasilanFareTusu = 2) and ((_FareOlay.Dugme and 2) = 0) then
      begin

        SonBasilanFareTusu := 0;
        Result.Olay := FO_SAGTUS_BIRAKILDI;
      end
      else if(SonBasilanFareTusu = 4) and ((_FareOlay.Dugme and 4) = 0) then
      begin

        SonBasilanFareTusu := 0;
        Result.Olay := FO_ORTATUS_BIRAKILDI;
      end
      else if(SonBasilanFareTusu = 16) and ((_FareOlay.Dugme and 16) = 0) then
      begin

        SonBasilanFareTusu := 0;
        Result.Olay := FO_4NCUTUS_BIRAKILDI;
      end
      else if(SonBasilanFareTusu = 32) and ((_FareOlay.Dugme and 32) = 0) then
      begin

        SonBasilanFareTusu := 0;
        Result.Olay := FO_5NCITUS_BIRAKILDI;
      end
      else if(_FareOlay.A1 <> SonYatayFareDegeri) or (_FareOlay.B1 <> SonDikeyFareDegeri) then
      begin

        Result.Olay := FO_HAREKET;
      end
      else Result.Olay := FO_BILINMIYOR;
    end;

    // deðiþenleri bir sonraki durum için güncelle
    SonYatayFareDegeri := _FareOlay.A1;
    SonDikeyFareDegeri := _FareOlay.B1;
  end
  else Result.Olay := FO_BILINMIYOR;
end;

{==============================================================================
  tüm fare olaylarýný iþler, olaylarý ilgili nesnelere yönlendirir
 ==============================================================================}
procedure TOlay.FareOlaylariniIsle;
var
  _GorselNesne: PGorselNesne;
  _OlayKayit, _OlayKayit2: TOlayKayit;
  _Alan: TAlan;
begin

  // fare tarafýndan oluþturulan olayý al
  _OlayKayit := FareOlayiAl;

  // bilinen bir fare olayý var ise ...
  if(_OlayKayit.Olay <> FO_BILINMIYOR) then
  begin

    // farklý olaylar gönderilecek olay deðiþkeni
    _OlayKayit2.Kimlik := _OlayKayit.Kimlik;
    _OlayKayit2.Olay := _OlayKayit.Olay;

    // fare yatay & dikey koordinatýnda bulunan nesneyi al
    // bilgi: yakalanan nesnenin önceliði vardýr
    if(YakalananGorselNesne <> nil) then

      _GorselNesne := YakalananGorselNesne
    else _GorselNesne := GorselNesneBul(GFareSurucusu.YatayKonum, GFareSurucusu.DikeyKonum);

    // farenin bulunduðu noktada görsel nesne var ise ...
    if(_GorselNesne <> nil) then
    begin

      // bulunan nesne bir önceki nesne deðil ise
      if(OdaklanilanGorselNesne <> _GorselNesne) then
      begin

        // daha önceden odaklanan nesne var ise
        if(OdaklanilanGorselNesne <> nil) then
        begin

          // odaklanýlan nesneye odaðý kaybettiðine dair mesaj gönder
          _OlayKayit2.Olay := CO_ODAKKAYBEDILDI;
          OlaylariYonlendir(OdaklanilanGorselNesne, _OlayKayit2);
        end;

        // odak kazanan nesneyi yeniden ata
        OdaklanilanGorselNesne := _GorselNesne;

        // nesneye odak kazandýðýna dair mesaj gönder
        _OlayKayit2.Olay := CO_ODAKKAZANILDI;
        OlaylariYonlendir(OdaklanilanGorselNesne, _OlayKayit2);
      end;

      // güç düðmesi ve ona benzer diðer açýk / kapalý durumda olan görsel nesneleri kapatmak için
      if((_OlayKayit2.Olay = FO_SOLTUS_BASILDI) or (_OlayKayit2.Olay = FO_SAGTUS_BASILDI))
        and (OdaklanilanGorselNesne <> GFareIleBasilanSonGN) then
      begin

        if not(GFareIleBasilanSonGN = nil) and (GFareIleBasilanSonGN^.GorselNesneTipi = gntGucDugme) then
        begin

          _OlayKayit2.Olay := CO_NORMALDURUMAGEC;
          OlaylariYonlendir(GFareIleBasilanSonGN, _OlayKayit2);
        end;

        GFareIleBasilanSonGN := OdaklanilanGorselNesne;
      end;

      // nesnenin üst nesneye baðlý gerçek koordinatlarýný al
      _Alan.Sol2 := _GorselNesne^.FDisGercekBoyutlar.Sol2;
      _Alan.Ust2 := _GorselNesne^.FDisGercekBoyutlar.Ust2;
      _Alan.Genislik2 := _GorselNesne^.FDisGercekBoyutlar.Genislik2;
      _Alan.Yukseklik2 := _GorselNesne^.FDisGercekBoyutlar.Yukseklik2;

      // nesneye yönlendirilecek parametreleri hazýrla
      _OlayKayit.Kimlik := _GorselNesne^.Kimlik;
      if(_OlayKayit.Olay <> FO_KAYDIRMA) then
        _OlayKayit.Deger1 := GFareSurucusu.YatayKonum - _Alan.A1;
      _OlayKayit.Deger2 := GFareSurucusu.DikeyKonum - _Alan.B1;

      // olayý nesneye yönlendir
      OlaylariYonlendir(_GorselNesne, _OlayKayit);
    end;
  end;
end;

{==============================================================================
  tüm klavye olaylarýný iþler, olaylarý ilgili nesnelere yönlendirir
 ==============================================================================}
procedure TOlay.KlavyeOlaylariniIsle(ATus: Char);
var
  _OlayKayit: TOlayKayit;
begin

  // klavyeden basýlan bir tuþ olayý var ise ...
  if(ATus <> #0) then
  begin

    // aktif nesne belirli mi?
    if(AktifGorselNesne <> nil) then
    begin

      // aktif nesne giriþ kutusu nesnesi mi?
      //if(AktifGorselNesne^.GorselNesneTipi = gntGirisKutusu) then
      begin

        // odaklanan nesneye CO_TUSBASILDI mesajý gönder
        _OlayKayit.Deger1 := TISayi4(ATus);
        _OlayKayit.Olay := CO_TUSBASILDI;
        OlaylariYonlendir(AktifGorselNesne, _OlayKayit);
      end;
    end;
  end;
end;

{==============================================================================
  olaylarý nesnelere yönlendirir
 ==============================================================================}
procedure TOlay.OlaylariYonlendir(AGorselNesne: PGorselNesne; AOlayKayit: TOlayKayit);
var
  _Gorev: PGorev;
  _Kimlik: TISayi4;
begin

  _Gorev := GorevListesi[AGorselNesne^.GorevKimlik];

  // görev çalýþmýyorsa nesneye olay gönderme
  if(_Gorev^.FGorevDurum <> gdCalisiyor) then Exit;

  _Kimlik := AGorselNesne^.Kimlik;

  // aktif nesneyi belirle
  if(AOlayKayit.Olay = FO_SOLTUS_BASILDI) then
  begin

    AktifGorselNesne := AGorselNesne;
  end;

  // görsel nesnenin olaylarýnýn ekleneceði kýsým
  case AGorselNesne^.GorselNesneTipi of
    gntMasaustu       : PMasaustu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntPencere        : PPencere(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntDugme          : PDugme(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntGucDugme       : PGucDugme(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntListeKutusu    : PListeKutusu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntMenu           : PMenu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntDefter         : PDefter(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntIslemGostergesi: PIslemGostergesi(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntIsaretKutusu   : POnayKutusu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntGirisKutusu    : PGirisKutusu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntDegerDugmesi   : PDegerDugmesi(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntEtiket         : PEtiket(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntDurumCubugu    : PDurumCubugu(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntSecimDugmesi   : PSecimDugme(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntBaglanti       : PBaglanti(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntResim          : PResim(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntListeGorunum   : PListeGorunum(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntPanel          : PPanel(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
    gntResimDugme     : PResimDugme(AGorselNesne)^.OlaylariIsle(_Kimlik, AOlayKayit);
  end;
end;

end.
