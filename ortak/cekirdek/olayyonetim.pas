{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: olay.pas
  Dosya ��levi: olay y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 20/06/2020

 ==============================================================================}
{$mode objfpc}
unit olayyonetim;

interface

uses gorselnesne, paylasim, gn_menu, gn_acilirmenu, sistemmesaj;

type
  TOlayYonetim = object
  private
    FSonYatayFareDegeri, FSonDikeyFareDegeri: TISayi4;
    FSonBasilanFareTusu: TSayi1;
    FOdaklanilanGorselNesne: PGorselNesne;     // farenin, �zerinde bulundu�u nesne
    FAktifGorselNesne: PGorselNesne;           // farenin, �zerine sol tu� ile bas�l�p se�ildi�i nesne
  protected
    procedure OlaylariYonlendir(AGorselNesne: PGorselNesne; AOlay: TOlay);
  public
    procedure Yukle;
    function FareOlayiAl: TOlay;
    procedure FareOlaylariniIsle;
    procedure KlavyeOlaylariniIsle(ATus: Char);
  end;

implementation

uses genel, gn_islevler, src_ps2, gorev;

{==============================================================================
  olay de�i�kenlerini ilk de�erlerle y�kler
 ==============================================================================}
procedure TOlayYonetim.Yukle;
begin

  FOdaklanilanGorselNesne := nil;
  YakalananGorselNesne := nil;
  FAktifGorselNesne := nil;

  FSonBasilanFareTusu := 0;
end;

{==============================================================================
  fare bilgilerini i�leyerek olaya �evirir
 ==============================================================================}
function TOlayYonetim.FareOlayiAl: TOlay;
var
  FareOlay: TFareOlay;
begin

  // fare s�r�c�s�nden fare olaylar�n� al
  if(GFareSurucusu.OlaylariAl(@FareOlay)) then
  begin

    // daha �nce fare tu�una bas�lmam��sa...
    if(FSonBasilanFareTusu = 0) then
    begin

      if((FareOlay.Dugme and 1) = 1) then
      begin

        FSonBasilanFareTusu := 1;
        Result.Olay := FO_SOLTUS_BASILDI;
      end
      else if((FareOlay.Dugme and 2) = 2) then
      begin

        FSonBasilanFareTusu := 2;
        Result.Olay := FO_SAGTUS_BASILDI;
      end
      else if((FareOlay.Dugme and 4) = 4) then
      begin

        FSonBasilanFareTusu := 4;
        Result.Olay := FO_ORTATUS_BASILDI;
      end
      else if((FareOlay.Dugme and 16) = 16) then
      begin

        FSonBasilanFareTusu := 16;
        Result.Olay := FO_4NCUTUS_BASILDI;
      end
      else if((FareOlay.Dugme and 32) = 32) then
      begin

        FSonBasilanFareTusu := 32;
        Result.Olay := FO_5NCITUS_BASILDI;
      end
      else if(FareOlay.Tekerlek <> 0) then
      begin

        Result.Olay := FO_KAYDIRMA;
        Result.Deger1 := FareOlay.Tekerlek;
      end
      else if(FareOlay.Yatay <> FSonYatayFareDegeri) or (FareOlay.Dikey <> FSonDikeyFareDegeri) then
      begin

        Result.Olay := FO_HAREKET;
      end
      else Result.Olay := FO_BILINMIYOR;
    end
    else
    // daha �nce fare tu�una bas�lm��sa...
    begin

      if(FSonBasilanFareTusu = 1) and ((FareOlay.Dugme and 1) = 0) then
      begin

        FSonBasilanFareTusu := 0;
        Result.Olay := FO_SOLTUS_BIRAKILDI;
      end
      else if(FSonBasilanFareTusu = 2) and ((FareOlay.Dugme and 2) = 0) then
      begin

        FSonBasilanFareTusu := 0;
        Result.Olay := FO_SAGTUS_BIRAKILDI;
      end
      else if(FSonBasilanFareTusu = 4) and ((FareOlay.Dugme and 4) = 0) then
      begin

        FSonBasilanFareTusu := 0;
        Result.Olay := FO_ORTATUS_BIRAKILDI;
      end
      else if(FSonBasilanFareTusu = 16) and ((FareOlay.Dugme and 16) = 0) then
      begin

        FSonBasilanFareTusu := 0;
        Result.Olay := FO_4NCUTUS_BIRAKILDI;
      end
      else if(FSonBasilanFareTusu = 32) and ((FareOlay.Dugme and 32) = 0) then
      begin

        FSonBasilanFareTusu := 0;
        Result.Olay := FO_5NCITUS_BIRAKILDI;
      end
      else if(FareOlay.Yatay <> FSonYatayFareDegeri) or (FareOlay.Dikey <> FSonDikeyFareDegeri) then
      begin

        Result.Olay := FO_HAREKET;
      end
      else Result.Olay := FO_BILINMIYOR;
    end;

    // de�i�enleri bir sonraki durum i�in g�ncelle
    FSonYatayFareDegeri := FareOlay.Yatay;
    FSonDikeyFareDegeri := FareOlay.Dikey;

  end else Result.Olay := FO_BILINMIYOR;
end;

{==============================================================================
  t�m fare olaylar�n� i�ler, olaylar� ilgili nesnelere y�nlendirir
 ==============================================================================}
procedure TOlayYonetim.FareOlaylariniIsle;
var
  GorselNesne: PGorselNesne;
  Olay, Olay2: TOlay;
  Alan: TAlan;
  Konum: TKonum;
begin

  // fare taraf�ndan olu�turulan olay� al
  Olay := FareOlayiAl;

  // bilinen bir fare olay� var ise ...
  if(Olay.Olay <> FO_BILINMIYOR) then
  begin

    // farkl� olaylar g�nderilecek olay de�i�keni
    Olay2.Kimlik := Olay.Kimlik;
    Olay2.Olay := Olay.Olay;

    Konum.Sol := GFareSurucusu.YatayKonum;
    Konum.Ust := GFareSurucusu.DikeyKonum;

    // fare yatay & dikey koordinat�nda bulunan nesneyi al
    // bilgi: yakalanan nesnenin �nceli�i vard�r
    if(YakalananGorselNesne <> nil) then
      GorselNesne := YakalananGorselNesne
    else GorselNesne := GorselNesneBul(Konum);

    // farenin bulundu�u noktada g�rsel nesne var ise ...
    if(GorselNesne <> nil) then
    begin

      // bulunan nesne bir �nceki nesne de�il ise
      if(FOdaklanilanGorselNesne <> GorselNesne) then
      begin

        // daha �nceden odaklanan nesne var ise
        if(FOdaklanilanGorselNesne <> nil) then
        begin

          // odaklan�lan nesneye oda�� kaybetti�ine dair mesaj g�nder
          Olay2.Olay := CO_ODAKKAYBEDILDI;
          OlaylariYonlendir(FOdaklanilanGorselNesne, Olay2);
        end;

        // odak kazanan nesneyi yeniden ata
        FOdaklanilanGorselNesne := GorselNesne;

        // nesneye odak kazand���na dair mesaj g�nder
        Olay2.Olay := CO_ODAKKAZANILDI;
        OlaylariYonlendir(FOdaklanilanGorselNesne, Olay2);
      end;

      // g�� d��mesi ve ona benzer di�er a��k / kapal� durumda olan g�rsel nesneleri kapatmak i�in
      if((Olay2.Olay = FO_SOLTUS_BASILDI) or (Olay2.Olay = FO_SAGTUS_BASILDI))
        and (FOdaklanilanGorselNesne <> GFareIleBasilanSonGN) then
      begin

        if not(GFareIleBasilanSonGN = nil) and (GFareIleBasilanSonGN^.NesneTipi = gntGucDugmesi) then
        begin

          Olay2.Olay := CO_NORMALDURUMAGEC;
          OlaylariYonlendir(GFareIleBasilanSonGN, Olay2);
        end;

        GFareIleBasilanSonGN := FOdaklanilanGorselNesne;
      end;

      // nesneye y�nlendirilecek parametreleri haz�rla
      Olay.Kimlik := GorselNesne^.Kimlik;
      if(Olay.Olay <> FO_KAYDIRMA) then
        Olay.Deger1 := GFareSurucusu.YatayKonum - Alan.Sol;
      Olay.Deger2 := GFareSurucusu.DikeyKonum - Alan.Ust;

      Olay.Deger1 := Konum.Sol;
      Olay.Deger2 := Konum.Ust;

{      SISTEM_MESAJ('Yatay: %d', [Olay.Deger1]);
      SISTEM_MESAJ('Dikey: %d', [Olay.Deger2]);
      SISTEM_MESAJ_YAZI('G�rsel Nesne: ', GorselNesne^.NesneAdi);
      SISTEM_MESAJ('Sol: %d', [GorselNesne^.FKonum.Sol]);
      SISTEM_MESAJ('�st: %d', [GorselNesne^.FKonum.Ust]);
      SISTEM_MESAJ('Geni�lik: %d', [GorselNesne^.FBoyut.Genislik]);
      SISTEM_MESAJ('Y�kseklik: %d', [GorselNesne^.FBoyut.Yukseklik]);
}
      // olay� nesneye y�nlendir
      OlaylariYonlendir(GorselNesne, Olay);
    end;
  end;
end;

{==============================================================================
  t�m klavye olaylar�n� i�ler, olaylar� ilgili nesnelere y�nlendirir
 ==============================================================================}
procedure TOlayYonetim.KlavyeOlaylariniIsle(ATus: Char);
var
  Olay: TOlay;
begin

  // klavyeden bas�lan bir tu� olay� var ise ...
  if(ATus <> #0) then
  begin

    // aktif nesne belirli mi?
    if(FAktifGorselNesne <> nil) then
    begin

      // aktif nesne giri� kutusu nesnesi mi?
      //if(FAktifGorselNesne^.GorselNesneTipi = gntGirisKutusu) then
      begin

        // odaklanan nesneye CO_TUSBASILDI mesaj� g�nder
        Olay.Deger1 := TISayi4(ATus);
        Olay.Olay := CO_TUSBASILDI;
        OlaylariYonlendir(FAktifGorselNesne, Olay);
      end;
    end;
  end;
end;

{==============================================================================
  olaylar� nesnelere y�nlendirir
 ==============================================================================}
procedure TOlayYonetim.OlaylariYonlendir(AGorselNesne: PGorselNesne; AOlay: TOlay);
var
  Gorev: PGorev;
begin

  Gorev := GorevListesi[AGorselNesne^.GorevKimlik];

  // g�rev �al��m�yorsa nesneye olay g�nderme
  if(Gorev^.FGorevDurum <> gdCalisiyor) then Exit;

  // aktif nesneyi belirle
  if(AOlay.Olay = FO_SOLTUS_BASILDI) then
  begin

    FAktifGorselNesne := AGorselNesne;
  end;

  if not(AGorselNesne^.AnaOlayCagriAdresi = nil) then
    AGorselNesne^.AnaOlayCagriAdresi(AGorselNesne, AOlay);

  // tu� bas�m� esnas�nda a��k bir men� var ise kapat�lacak
  if(AOlay.Olay = FO_SOLTUS_BASILDI) or (AOlay.Olay = FO_SAGTUS_BASILDI) then
  begin

    if not(GAktifMenu = nil) then
    begin

      if(GAktifMenu^.NesneTipi = gntMenu) then PMenu(GAktifMenu)^.Gizle
      else if(GAktifMenu^.NesneTipi = gntAcilirMenu) then PAcilirMenu(GAktifMenu)^.Gizle
    end;
  end;
end;

end.
