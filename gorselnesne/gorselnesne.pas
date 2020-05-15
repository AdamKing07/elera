{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: gorselnesne.pas
  Dosya ��levi: t�m g�rsel nesnelerin ana nesnesi.

  G�ncelleme Tarihi: 03/05/2020

 ==============================================================================}
{$mode objfpc}
unit gorselnesne;

interface

uses paylasim, temelgorselnesne;

type
  TOlaylariIsle = procedure(AKimlik: TKimlik; AOlay: TOlayKayit) of object;

type
  PPGorselNesne = ^PGorselNesne;
  PGorselNesne = ^TGorselNesne;
  TGorselNesne = object(TTemelGorselNesne)
  public
    FAtaNesneMi: Boolean;                       // nesne alt nesne i�erebilecek bir ata nesne mi
    FAtaNesne: PGorselNesne;                    // nesnenin atas�
    FAltNesneBellekAdresi: PPGorselNesne;       // ata nesnenin alt nesneleri yerle�tirece�i bellek adresi
    FCizimBellekAdresi: Isaretci;
    FCizimBellekUzunlugu: TSayi4;
    FEfendiNesne: PGorselNesne;                 // ortak �al��an nesneler i�in nesnenin sahibi olan efendi nesne
    FEfendiNesneOlayCagriAdresi: TOlaylariIsle;
    FEtiket: TSayi4;                            // nesneyi kullanacak program�n kullan�m� i�in
    function Olustur0(AGorselNesneTipi: TGorselNesneTipi): PGorselNesne;
    function YokEt0: Boolean;
    function NesneTipiniKontrolEt(AKimlik: TKimlik; AGorselNesneTipi: TGorselNesneTipi): PGorselNesne;
    function NesneTipiniAl(AKimlik: TKimlik): TGorselNesneTipi;
    function NesneyiAl(AKimlik: TKimlik): PGorselNesne;
    function AtaNesneyiAl(AKimlik: TKimlik): PGorselNesne;
    function AtaNesneyeEkle(AAtaNesne: PGorselNesne): Boolean;
    function CizimGorselNesneBoyutlariniAl(AKimlik: TKimlik): TAlan;
    procedure IcVeDisBoyutlariYenidenHesapla;
    function CizimAlaniniAl(AKimlik: TKimlik): TAlan;
    function AtaNesneGorunurMu: Boolean;
    function NesneAl(AKimlik: TKimlik): PGorselNesne;
    function FareNesneOlayAlanindaMi(AKimlik: TKimlik): Boolean;
    function NoktaAlanIcerisindeMi(NoktaA1, NoktaB1: TISayi4;
      AAlan: TAlan): Boolean;
    property AtaNesne: PGorselNesne read FAtaNesne write FAtaNesne;

    // kernel i�in �a�r�lar (for kernel)
    procedure PixelYaz(APencere: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk);
    procedure YaziYaz(APencere: PGorselNesne; A1, B1: TISayi4; AYazi: string; ARenk: TRenk);
    procedure YaziYaz(APencere: PGorselNesne; AYaziHiza: TYaziHiza;
      AAlan: TAlan; AYazi: string; ARenk: TRenk);
    procedure AlanaYaziYaz(APencere: PGorselNesne; Nokta4: TAlan;
      A1, B1: TISayi4; AKarakterDizi: string; ARenk: TRenk);
    procedure SayiYaz16(APencere: PGorselNesne; A1, B1: TISayi4; AOnEkYaz: LongBool; AHaneSayisi,
      ADeger: TISayi4; ARenk: TRenk);
    procedure SaatYaz(APencere: PGorselNesne; A1, B1: TISayi4; ASaat: TSaat; ARenk: TRenk);
    procedure HarfYaz(APencere: PGorselNesne; A1, B1: TISayi4; AKarakter: Char; ARenk: TRenk);
    procedure SayiYaz10(APencere: PGorselNesne; A1, B1: TISayi4;
      ASayi: TISayi4; ARenk: TRenk);
    procedure MACAdresiYaz(APencere: PGorselNesne; A1, B1: TISayi4;
      AMACAdres: TMACAdres; ARenk: TRenk);
    procedure IPAdresiYaz(APencere: PGorselNesne; A1, B1: TSayi4; AIPAdres: TIPAdres;
      ARenk: TRenk);
    procedure Dikdortgen(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4;
      ACizgiRengi: TRenk);
    procedure DikdortgenDoldur(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4; ACizgiRengi, ADolguRengi: TRenk);
    procedure DikdortgenDoldur(APencere: PGorselNesne; AAlan: TAlan;
      ACizgiRengi, ADolguRengi: TRenk);
    procedure Doldur4(APencere: PGorselNesne; Nokta4: TAlan; A1, B1, A2, B2: TISayi4;
      ACizgiRengi, ADolguRengi: TRenk);
    procedure BMPGoruntusuCiz(AGorselNesneTipi: TGorselNesneTipi; AKimlik: TKimlik;
      AGoruntuYapi: TGoruntuYapi);
    procedure Cizgi(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4; ACizgiRengi: TRenk);
    procedure Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk);
    procedure DaireDoldur(APencere: PGorselNesne; A1, B1, AYariCap: TISayi4;
      ARenk: TRenk);
    procedure YatayCizgi(APencere: PGorselNesne; A1, B1, A2: TISayi4;
      ARenk: TRenk);
    procedure DikeyCizgi(APencere: PGorselNesne; A1, B1, B2: TISayi4;
      ARenk: TRenk);
    procedure EgimliDoldur(APencere: PGorselNesne; Alan: TAlan;
      ARenk1, ARenk2: TRenk);
    procedure EgimliDoldur2(APencere: PGorselNesne; Alan: TAlan;
      ARenk1, ARenk2: TRenk);
    procedure EgimliDoldur3(APencere: PGorselNesne; Alan: TAlan; ARenk1, ARenk2: TRenk);
    procedure KenarlikCiz(APencere: PGorselNesne; AAlan: TAlan; AKalinlik: TSayi4);
    procedure HamResimCiz(AGorselNesne: PGorselNesne; A1, B1: TSayi4;
      AHamResimBellekAdresi: Isaretci);
    procedure KaynaktanResimCiz(AGorselNesne: PGorselNesne; A1, B1: TSayi4;
      ASiraNo: TSayi4);

    // program i�in �a�r�lar (for program)
    procedure Kesme_YaziYaz(A1, B1: TISayi4; AKarakterDizi: string; ARenk: TRenk);
    procedure Kesme_SayiYaz16(A1, B1: TISayi4; AOnEkYaz: LongBool;
      AHaneSayisi, ADeger: TISayi4; ARenk: TRenk);
    procedure Kesme_SaatYaz(A1, B1: TISayi4; ASaat: TSaat; ARenk: TRenk);
  end;

implementation

uses genel, genel8x16, donusum, bmp, gn_islevler, sistemmesaj, gn_pencere;

{==============================================================================
  g�rsel nesne nesnesini olu�turur
 ==============================================================================}
function TGorselNesne.Olustur0(AGorselNesneTipi: TGorselNesneTipi): PGorselNesne;
var
  _TemelGorselNesne: PTemelGorselNesne;
  _i: TISayi4;
begin

  // t�m nesneleri ara
  for _i := 1 to USTSINIR_GORSELNESNE do
  begin

    _TemelGorselNesne := GorselNesneListesi[_i];

    // e�er nesne kullan�lmam�� ise ...
    if(_TemelGorselNesne^.Kimlik = HATA_KIMLIK) then
    begin

      // nesne i�eri�ini s�f�rla
      FillByte(_TemelGorselNesne^, GN_UZUNLUK, 0);

      // kimlik de�erine s�ra no de�erini ver
      _TemelGorselNesne^.Kimlik := _i;
      _TemelGorselNesne^.GorselNesneTipi := AGorselNesneTipi;

      PGorselNesne(_TemelGorselNesne)^.FEfendiNesneOlayCagriAdresi := nil;

      //SISTEM_MESAJ_S10('TTemelGorselNesne yap� uzunlu�u: ', SizeOf(TTemelGorselNesne));
      //SISTEM_MESAJ_S10('TGorselNesne yap� uzunlu�u: ', SizeOf(TGorselNesne));

      // geri d�necek de�er
      Result := PGorselNesne(_TemelGorselNesne);

      // olu�turulmu� nesne say�s�n� 1 art�r ve ��k
      Inc(ToplamGNSayisi);

      Exit;
    end;
  end;

  Result := nil;
end;

{==============================================================================
  g�rsel nesneyi yok eder
 ==============================================================================}
function TGorselNesne.YokEt0: Boolean;
begin

  // e�er nesne istenen aral�kta ise yok et
  if(Kimlik > 0) and (Kimlik <= USTSINIR_GORSELNESNE) then
  begin

    Kimlik := HATA_KIMLIK;
    Dec(ToplamGNSayisi);
    Result := True;
  end else Result := False;
end;

{==============================================================================
  nesnenin nesne tipini kontrol eder
 ==============================================================================}
function TGorselNesne.NesneTipiniKontrolEt(AKimlik: TKimlik; AGorselNesneTipi: TGorselNesneTipi): PGorselNesne;
var
  _GorselNesne: PGorselNesne;
begin

  // nesne istenen say� aral���nda ise
  if(AKimlik > 0) and (AKimlik <= USTSINIR_GORSELNESNE) then
  begin

    _GorselNesne := GorselNesneListesi[AKimlik];

    // nesne olu�turulmu� mu ?
    if(_GorselNesne^.Kimlik <> 0) then
    begin

      // nesne tipini kontrol et
      if(_GorselNesne^.GorselNesneTipi = AGorselNesneTipi) then
        Exit(_GorselNesne);
    end;
  end;

  Result := nil;
end;

{==============================================================================
  nesnenin tipini al
 ==============================================================================}
function TGorselNesne.NesneTipiniAl(AKimlik: TKimlik): TGorselNesneTipi;
var
  _GorselNesne: PGorselNesne;
begin

  // nesne istenen say� aral���nda ise
  if(AKimlik > 0) and (AKimlik <= USTSINIR_GORSELNESNE) then
  begin

    _GorselNesne := GorselNesneListesi[AKimlik];

    // nesne olu�turulmu� mu ?
    if(_GorselNesne^.Kimlik <> 0) then
    begin

      // nesne tipini kontrol et
      Exit(_GorselNesne^.GorselNesneTipi);
    end;
  end;

  Result := gntTanimsiz;
end;

{==============================================================================
  nesneyi kimli�inden nesneyi al
 ==============================================================================}
function TGorselNesne.NesneyiAl(AKimlik: TKimlik): PGorselNesne;
begin

  // nesne istenen say� aral���nda ise
  if(AKimlik > 0) and (AKimlik <= USTSINIR_GORSELNESNE) then

    Result := PGorselNesne(GorselNesneListesi[AKimlik])

  else Result := nil;
end;

{==============================================================================
  nesnenin ba�l� oldu�u ata nesneyi al�r
 ==============================================================================}
function TGorselNesne.AtaNesneyiAl(AKimlik: TKimlik): PGorselNesne;
var
  _GorselNesne: PGorselNesne;
begin

  // nesne istenen say� aral���nda ise
  if(AKimlik > 0) and (AKimlik <= USTSINIR_GORSELNESNE) then
  begin

    _GorselNesne := GorselNesneListesi[AKimlik];

    while (_GorselNesne <> nil) do
    begin

      if(_GorselNesne^.FAtaNesneMi) then Exit(_GorselNesne);
      _GorselNesne := _GorselNesne^.AtaNesne;
    end;
  end;

  Result := nil;
end;

{==============================================================================
  nesneyi ata nesnesine alt nesne olarak ekler
 ==============================================================================}
function TGorselNesne.AtaNesneyeEkle(AAtaNesne: PGorselNesne): Boolean;
var
  _AltNesneBellekAdresi: PPGorselNesne;
  _i: TISayi4;
begin

  // ata nesnenin alt nesneleri i�in bellek olu�turulmu� mu ?
  if(AAtaNesne^.FAltNesneBellekAdresi= nil) then
  begin

    // ata nesne i�in bellek olu�tur
    _AltNesneBellekAdresi := GGercekBellek.Ayir(4096);
    AAtaNesne^.FAltNesneBellekAdresi := _AltNesneBellekAdresi;
  end;

  // alt nesne toplam nesne say�s� a��lmam��sa ...
  if(AAtaNesne^.AltNesneSayisi < 1024) then
  begin

    // �st nesnenin bellek adresini al
    _AltNesneBellekAdresi := AAtaNesne^.FAltNesneBellekAdresi;

    // nesneyi �st nesneye kaydet
    _AltNesneBellekAdresi[AAtaNesne^.AltNesneSayisi] := @Self;

    // �st nesnenin nesne says�n� 1 art�r
    _i := AAtaNesne^.AltNesneSayisi;
    Inc(_i);
    AAtaNesne^.AltNesneSayisi := _i;
    Result := True;
  end else Result := False;
end;

{==============================================================================
  nesnenin pencereye (0, 0) bazl� olarak) ba�l� ger�ek koordinatlar�n� al�r
 ==============================================================================}
function TGorselNesne.CizimGorselNesneBoyutlariniAl(AKimlik: TKimlik): TAlan;
var
  _Pencere: PPencere;
  _GorselNesne: PGorselNesne;
begin

  // talepte bulunan nesnenin kimlik de�erini kontrol et
  _GorselNesne := GorselNesneListesi[AKimlik];

  if((Self.GorselNesneTipi = gntMasaustu) or (Self.GorselNesneTipi = gntPencere) or
    (Self.GorselNesneTipi = gntMenu) or (Self.GorselNesneTipi = gntAcilirMenu)) then
  begin

    // geni�lik ve y�kseklik de�erleri al�n�yor
    Result.Sag := _GorselNesne^.FDisGercekBoyutlar.Sag - _GorselNesne^.FDisGercekBoyutlar.Sol;
    Result.Alt := _GorselNesne^.FDisGercekBoyutlar.Alt - _GorselNesne^.FDisGercekBoyutlar.Ust;
    Result.Sol := 0;
    Result.Ust := 0;
  end
  else
  begin

    _Pencere := PencereAtaNesnesiniAl(_GorselNesne);

    Result.Sol := _GorselNesne^.FDisGercekBoyutlar.Sol - _Pencere^.FDisGercekBoyutlar.Sol;
    Result.Ust := _GorselNesne^.FDisGercekBoyutlar.Ust - _Pencere^.FDisGercekBoyutlar.Ust;
    Result.Sag := _GorselNesne^.FDisGercekBoyutlar.Sag - _Pencere^.FDisGercekBoyutlar.Sol;
    Result.Alt := _GorselNesne^.FDisGercekBoyutlar.Alt - _Pencere^.FDisGercekBoyutlar.Ust;
  end;
end;

{==============================================================================
  g�rsel nesnenin ger�ek ekran de�erlerine ba�l� boyutlar�n� yeniden hesaplar
 ==============================================================================}
procedure TGorselNesne.IcVeDisBoyutlariYenidenHesapla;
var
  _AtaNesne, _GorselNesne, _AtaNesne2, _GorselNesne2: PGorselNesne;
  _AltNesneler, _AltNesneler2: PPGorselNesne;
  i, j: Integer;

  procedure Hizala(AAtaNesne, AGorselNesne: PGorselNesne);
  begin

    if(AGorselNesne^.Hiza = hzYok) then
    begin

      // nesne ger�ek d�� koordinatlar
      AGorselNesne^.FDisGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol2 + AGorselNesne^.FBoyutlar.Sol2;
      AGorselNesne^.FDisGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust2 + AGorselNesne^.FBoyutlar.Ust2;
      AGorselNesne^.FDisGercekBoyutlar.Sag := AGorselNesne^.FDisGercekBoyutlar.Sol + (AGorselNesne^.FBoyutlar.Genislik2 - 1);
      AGorselNesne^.FDisGercekBoyutlar.Alt := AGorselNesne^.FDisGercekBoyutlar.Ust + (AGorselNesne^.FBoyutlar.Yukseklik2 - 1);

      // nesne ger�ek i� koordinatlar
      AGorselNesne^.FIcGercekBoyutlar.Sol := AGorselNesne^.FDisGercekBoyutlar.Sol + (AGorselNesne^.FKalinlik.Sol + AGorselNesne^.FKenarBosluklari.Sol);
      AGorselNesne^.FIcGercekBoyutlar.Ust := AGorselNesne^.FDisGercekBoyutlar.Ust + (AGorselNesne^.FKalinlik.Ust + AGorselNesne^.FKenarBosluklari.Ust);
      AGorselNesne^.FIcGercekBoyutlar.Sag := AGorselNesne^.FDisGercekBoyutlar.Sag - (AGorselNesne^.FKalinlik.Sag + AGorselNesne^.FKenarBosluklari.Sag);
      AGorselNesne^.FIcGercekBoyutlar.Alt := AGorselNesne^.FDisGercekBoyutlar.Alt - (AGorselNesne^.FKalinlik.Alt + AGorselNesne^.FKenarBosluklari.Alt);
    end
    else
    begin

      if(AGorselNesne^.Hiza = hzUst) then
      begin

        // nesne ger�ek d�� koordinatlar
        AGorselNesne^.FDisGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol;
        AGorselNesne^.FDisGercekBoyutlar.Sag := AAtaNesne^.FIcGercekBoyutlar.Sag;
        AGorselNesne^.FDisGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust;
        AGorselNesne^.FDisGercekBoyutlar.Alt := AGorselNesne^.FDisGercekBoyutlar.Ust + AGorselNesne^.FBoyutlar.Yukseklik2;

        AAtaNesne^.FIcGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust + AGorselNesne^.FBoyutlar.Yukseklik2;
      end
      else if(AGorselNesne^.Hiza = hzSag) then
      begin

        // nesne ger�ek d�� koordinatlar
        AGorselNesne^.FDisGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust;
        AGorselNesne^.FDisGercekBoyutlar.Alt := AAtaNesne^.FIcGercekBoyutlar.Alt;
        AGorselNesne^.FDisGercekBoyutlar.Sag := AAtaNesne^.FIcGercekBoyutlar.Sag;
        AGorselNesne^.FDisGercekBoyutlar.Sol := AGorselNesne^.FDisGercekBoyutlar.Sag - AGorselNesne^.FBoyutlar.Genislik2;

        AAtaNesne^.FIcGercekBoyutlar.Sag := AAtaNesne^.FIcGercekBoyutlar.Sag - AGorselNesne^.FBoyutlar.Genislik2;
      end
      else if(AGorselNesne^.Hiza = hzAlt) then
      begin

        // nesne ger�ek d�� koordinatlar
        AGorselNesne^.FDisGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol;
        AGorselNesne^.FDisGercekBoyutlar.Sag := AAtaNesne^.FIcGercekBoyutlar.Sag;
        AGorselNesne^.FDisGercekBoyutlar.Alt := AAtaNesne^.FIcGercekBoyutlar.Alt;
        AGorselNesne^.FDisGercekBoyutlar.Ust := AGorselNesne^.FDisGercekBoyutlar.Alt - AGorselNesne^.FBoyutlar.Yukseklik2;

        AAtaNesne^.FIcGercekBoyutlar.Alt := AAtaNesne^.FIcGercekBoyutlar.Alt - AGorselNesne^.FBoyutlar.Yukseklik2;
      end
      else if(AGorselNesne^.Hiza = hzSol) then
      begin

        // nesne ger�ek d�� koordinatlar
        AGorselNesne^.FDisGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust;
        AGorselNesne^.FDisGercekBoyutlar.Alt := AAtaNesne^.FIcGercekBoyutlar.Alt;
        AGorselNesne^.FDisGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol;
        AGorselNesne^.FDisGercekBoyutlar.Sag := AGorselNesne^.FDisGercekBoyutlar.Sol + AGorselNesne^.FBoyutlar.Genislik2;

        AAtaNesne^.FIcGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol + AGorselNesne^.FBoyutlar.Genislik2;
      end
      else if(AGorselNesne^.Hiza = hzTum) then
      begin

        // nesne ger�ek d�� koordinatlar
        AGorselNesne^.FDisGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sol;
        AGorselNesne^.FDisGercekBoyutlar.Sag := AAtaNesne^.FIcGercekBoyutlar.Sag;
        AGorselNesne^.FDisGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Ust;
        AGorselNesne^.FDisGercekBoyutlar.Alt := AAtaNesne^.FIcGercekBoyutlar.Alt;

        // yatay ve dikey de�erler e�itleniyor
        AAtaNesne^.FIcGercekBoyutlar.Sol := AAtaNesne^.FIcGercekBoyutlar.Sag;
        AAtaNesne^.FIcGercekBoyutlar.Ust := AAtaNesne^.FIcGercekBoyutlar.Alt;
      end;

      { TODO : nesne i� kal�nl�klar� ve di�er de�erleri de hesaplamaya eklenecektir }
      AGorselNesne^.FIcGercekBoyutlar.Sol := AGorselNesne^.FDisGercekBoyutlar.Sol;
      AGorselNesne^.FIcGercekBoyutlar.Sag := AGorselNesne^.FDisGercekBoyutlar.Sag;
      AGorselNesne^.FIcGercekBoyutlar.Ust := AGorselNesne^.FDisGercekBoyutlar.Ust;
      AGorselNesne^.FIcGercekBoyutlar.Alt := AGorselNesne^.FDisGercekBoyutlar.Alt;
    end;
  end;
begin

  if(Self.GorselNesneTipi = gntMasaustu) then
  begin

    // nesne ger�ek d�� koordinatlar
    Self.FDisGercekBoyutlar.Sol := Self.FBoyutlar.Sol2;
    Self.FDisGercekBoyutlar.Ust := Self.FBoyutlar.Ust2;
    Self.FDisGercekBoyutlar.Sag := Self.FDisGercekBoyutlar.Sol + (Self.FBoyutlar.Genislik2 - 1);
    Self.FDisGercekBoyutlar.Alt := Self.FDisGercekBoyutlar.Ust + (Self.FBoyutlar.Yukseklik2 - 1);

    // nesne ger�ek i� koordinatlar
    Self.FIcGercekBoyutlar.Sol := Self.FDisGercekBoyutlar.Sol + (Self.FKalinlik.Sol + Self.FKenarBosluklari.Sol);
    Self.FIcGercekBoyutlar.Ust := Self.FDisGercekBoyutlar.Ust + (Self.FKalinlik.Ust + Self.FKenarBosluklari.Ust);
    Self.FIcGercekBoyutlar.Sag := Self.FDisGercekBoyutlar.Sag - (Self.FKalinlik.Sag + Self.FKenarBosluklari.Sag);
    Self.FIcGercekBoyutlar.Alt := Self.FDisGercekBoyutlar.Alt - (Self.FKalinlik.Alt + Self.FKenarBosluklari.Alt);
    Exit;
  end
  else if(Self.GorselNesneTipi = gntMenu) or (Self.GorselNesneTipi = gntAcilirMenu) then
  begin

    // nesne ger�ek d�� koordinatlar
    Self.FDisGercekBoyutlar.Sol := Self.FBoyutlar.Sol2;
    Self.FDisGercekBoyutlar.Ust := Self.FBoyutlar.Ust2;
    Self.FDisGercekBoyutlar.Sag := Self.FDisGercekBoyutlar.Sol + (Self.FBoyutlar.Genislik2 - 1);
    Self.FDisGercekBoyutlar.Alt := Self.FDisGercekBoyutlar.Ust + (Self.FBoyutlar.Yukseklik2 - 1);

    // nesne ger�ek i� koordinatlar
    Self.FIcGercekBoyutlar.Sol := Self.FDisGercekBoyutlar.Sol + (Self.FKalinlik.Sol + Self.FKenarBosluklari.Sol);
    Self.FIcGercekBoyutlar.Ust := Self.FDisGercekBoyutlar.Ust + (Self.FKalinlik.Ust + Self.FKenarBosluklari.Ust);
    Self.FIcGercekBoyutlar.Sag := Self.FDisGercekBoyutlar.Sag - (Self.FKalinlik.Sag + Self.FKenarBosluklari.Sag);
    Self.FIcGercekBoyutlar.Alt := Self.FDisGercekBoyutlar.Alt - (Self.FKalinlik.Alt + Self.FKenarBosluklari.Alt);
    Exit;
  end
  else if(Self.GorselNesneTipi = gntPencere) then
  begin

    _GorselNesne := @Self;

    // pencere - nesne ger�ek d�� koordinatlar
    _GorselNesne^.FDisGercekBoyutlar.Sol := _GorselNesne^.FBoyutlar.Sol2;
    _GorselNesne^.FDisGercekBoyutlar.Ust := _GorselNesne^.FBoyutlar.Ust2;
    _GorselNesne^.FDisGercekBoyutlar.Sag := _GorselNesne^.FDisGercekBoyutlar.Sol + (_GorselNesne^.FBoyutlar.Genislik2 - 1);
    _GorselNesne^.FDisGercekBoyutlar.Alt := _GorselNesne^.FDisGercekBoyutlar.Ust + (_GorselNesne^.FBoyutlar.Yukseklik2 - 1);

    // pencere - nesne ger�ek i� koordinatlar
    _GorselNesne^.FIcGercekBoyutlar.Sol := _GorselNesne^.FDisGercekBoyutlar.Sol + (_GorselNesne^.FKalinlik.Sol + _GorselNesne^.FKenarBosluklari.Sol);
    _GorselNesne^.FIcGercekBoyutlar.Ust := _GorselNesne^.FDisGercekBoyutlar.Ust + (_GorselNesne^.FKalinlik.Ust + _GorselNesne^.FKenarBosluklari.Ust);
    _GorselNesne^.FIcGercekBoyutlar.Sag := _GorselNesne^.FDisGercekBoyutlar.Sag - (_GorselNesne^.FKalinlik.Sag + _GorselNesne^.FKenarBosluklari.Sag);
    _GorselNesne^.FIcGercekBoyutlar.Alt := _GorselNesne^.FDisGercekBoyutlar.Alt - (_GorselNesne^.FKalinlik.Alt + _GorselNesne^.FKenarBosluklari.Alt);

    // pencere nesnesinin alt nesnelerinin bellek b�lgesine konumlan
    _AltNesneler := _GorselNesne^.FAltNesneBellekAdresi;
    if(_GorselNesne^.AltNesneSayisi > 0) then
    begin

      _AtaNesne := _GorselNesne;

      // ilk olu�turulan alt nesneden son olu�turulan alt nesneye do�ru
      // pencerenin alt nesnelerini �iz
      for i := 0 to _AtaNesne^.AltNesneSayisi - 1 do
      begin

        _GorselNesne := _AltNesneler[i];
        if(_GorselNesne^.FGorunum) then
        begin

          Hizala(_AtaNesne, _GorselNesne);

          if(_GorselNesne^.GorselNesneTipi = gntPanel) and (_GorselNesne^.AltNesneSayisi > 0) then
          begin

            _AtaNesne2 := _GorselNesne;
            _AltNesneler2 := _AtaNesne2^.FAltNesneBellekAdresi;

            // ilk olu�turulan alt nesneden son olu�turulan alt nesneye do�ru
            // pencerenin alt nesnelerini �iz
            for j := 0 to _AtaNesne2^.AltNesneSayisi - 1 do
            begin

              _GorselNesne2 := _AltNesneler2[j];
              if(_GorselNesne2^.FGorunum) then
              begin

                Hizala(_AtaNesne2, _GorselNesne2);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  nesnenin �izilebilir alan�n�n koordinatlar�n� al�r
 ==============================================================================}
function TGorselNesne.CizimAlaniniAl(AKimlik: TKimlik): TAlan;
var
  _GorselNesne: PGorselNesne;
begin

  _GorselNesne := GorselNesneListesi[AKimlik];

  // nesnenin �st nesneye ba�l� koordinatlar�n� al
  Result := CizimGorselNesneBoyutlariniAl(AKimlik);

  // nesne koordinatlar�na nesnenin kal�nl�k de�erlerini ekle
  Result.Sol += _GorselNesne^.FKalinlik.Sol;
  Result.Ust += _GorselNesne^.FKalinlik.Ust;
  Result.Sag -= _GorselNesne^.FKalinlik.Sag;
  Result.Alt -= _GorselNesne^.FKalinlik.Alt;
end;

{==============================================================================
  belirtilen nesneden itibaren masa�st�ne kadar t�m nesnelerin g�r�n�rl���n�
  kontrol eder. (nesnenin kendisi de dahil)
 ==============================================================================}
function TGorselNesne.AtaNesneGorunurMu: Boolean;
var
  _GorselNesne: PGorselNesne;
begin

  _GorselNesne := @Self;

  repeat

    // nesne g�r�n�r durumdaysa AtaNesne nesnesini al
    if(_GorselNesne^.FGorunum) then

      _GorselNesne := _GorselNesne^.AtaNesne
    else
    begin

      // aksi durumda ��k
      Result := False;
      Exit;
    end;

    // t�m nesneler test edildiyse olumlu yan�t ile geri d�n
    if(_GorselNesne = nil) then Exit(True);

  until (True = False);
end;

{==============================================================================
  nesne kimlik de�erinden nesnenin bellek b�lgesini geri d�nd�r�r
 ==============================================================================}
function TGorselNesne.NesneAl(AKimlik: TKimlik): PGorselNesne;
begin

  Result := GorselNesneListesi[AKimlik];
end;

{==============================================================================
  fare g�stergesinin nesnenin olay alan�n�n i�erisinde olup
  olmad���n� kontrol eder
 ==============================================================================}
function TGorselNesne.FareNesneOlayAlanindaMi(AKimlik: TKimlik): Boolean;
var
  _GorselNesne: PGorselNesne;
  _Alan: TAlan;
begin

  _GorselNesne := GorselNesneListesi[AKimlik];

  // nesnenin �st nesneye ba�l� ger�ek koordinatlar�n� al
  _Alan.Sol2 := _GorselNesne^.FDisGercekBoyutlar.Sol2;
  _Alan.Ust2 := _GorselNesne^.FDisGercekBoyutlar.Ust2;
  _Alan.Genislik2 := _GorselNesne^.FDisGercekBoyutlar.Genislik2;
  _Alan.Yukseklik2 := _GorselNesne^.FDisGercekBoyutlar.Yukseklik2;

  // �nde�er d�n�� de�eri
  Result := False;

  // fare belirtilen koordinatlar i�erisinde mi ?
  if(_Alan.Sol > GFareSurucusu.YatayKonum) then Exit;
  if(_Alan.Sag < GFareSurucusu.YatayKonum) then Exit;
  if(_Alan.Ust > GFareSurucusu.DikeyKonum) then Exit;
  if(_Alan.Alt < GFareSurucusu.DikeyKonum) then Exit;

  Result := True;
end;

{==============================================================================
  X, Y koordinat�n�n Rect alan� i�erisinde olup olmad���n� test eder
 ==============================================================================}
function TGorselNesne.NoktaAlanIcerisindeMi(NoktaA1, NoktaB1: TISayi4;
  AAlan: TAlan): Boolean;
begin

  Result := False;

  // fare belirtilen koordinatlar i�erisinde mi ?
  if(NoktaA1 < AAlan.Sol) then Exit;
  if(NoktaA1 > AAlan.Sag) then Exit;
  if(NoktaB1 < AAlan.Ust) then Exit;
  if(NoktaB1 > AAlan.Alt) then Exit;

  Result := True;
end;

{==============================================================================
  grafiksel koordinattaki pixeli i�aretler (boyar)
 ==============================================================================}
procedure TGorselNesne.PixelYaz(APencere: PGorselNesne; A1, B1: TISayi4; ARenk: TRenk);
begin

  GEkranKartSurucusu.NoktaYaz(APencere, A1, B1, ARenk, True);
end;

{==============================================================================
  grafiksel ekrana karakter yazar
 ==============================================================================}
procedure TGorselNesne.HarfYaz(APencere: PGorselNesne; A1, B1: TISayi4;
  AKarakter: Char; ARenk: TRenk);
var
  _Karakter: TKarakter;
  _Genislik, _Yukseklik: TISayi4;
  _KarakterAdres: PByte;
  _i, _j: TISayi4;
begin

  // karakterler 0..255 aral���ndad�r.
	_Karakter := KarakterListesi[Byte(AKarakter)];

  // e�er karakter bo�luk veya �izim gerektirmeyen karakter ise ��k
  if(_Karakter.Yukseklik = 0) or (_Karakter.Genislik = 0) then Exit;

  // karakterin A1 de�erine yatay tolerans koordinat�n� ekle
  A1 += _Karakter.YT;

  // karakterin B1 de�erine dikey tolerans koordinat�n� ekle
  B1 += _Karakter.DT;

  // karakterin geni�lik ve y�kseklik de�erlerini hesapla
  _Genislik := A1 + _Karakter.Genislik;
  _Yukseklik := B1 + _Karakter.Yukseklik;

  // karakterin pixel haritas�n�n bellek adresine konumlan
  _KarakterAdres := _Karakter.Adres;

  for _j := B1 to _Yukseklik - 1 do
  begin

		for _i := A1 to _Genislik - 1 do
    begin

      // ilgili pixeli belirtilen renkle i�aretle (boya)
			if(_KarakterAdres^ = 1) then GEkranKartSurucusu.NoktaYaz(APencere, _i, _j,
        ARenk, True);

      // bir sonraki pixele konumlan
      Inc(_KarakterAdres)
    end;
  end;
end;

{==============================================================================
  grafiksel ekrana karakter katar� yazar
 ==============================================================================}
procedure TGorselNesne.Kesme_YaziYaz(A1, B1: TISayi4; AKarakterDizi: string;
  ARenk: TRenk);
var
  _Rect: TAlan;
begin

  _Rect := CizimAlaniniAl(Kimlik);
  YaziYaz(FAtaNesne, _Rect.Sol + A1, _Rect.Ust + B1, AKarakterDizi, ARenk);
end;

{==============================================================================
  grafiksel ekrana yaz� yazar
 ==============================================================================}
procedure TGorselNesne.YaziYaz(APencere: PGorselNesne; A1, B1: TISayi4; AYazi: string;
  ARenk: TRenk);
var
  _i, _j, _YaziUz: TISayi4;
begin

  // karakter katar�n�n uzunlu�unu al
  _YaziUz := Length(AYazi);
  if(_YaziUz = 0) then Exit;

  _j := A1;
  for _i := 1 to _YaziUz do
  begin

    // karakteri yaz
    HarfYaz(APencere, _j, B1, AYazi[_i], ARenk);

    // karakter geni�li�ini geni�lik de�erine ekle
    _j += 8;
  end;
end;

{==============================================================================
  grafiksel ekrana hizalayarak yaz� yazar
 ==============================================================================}
procedure TGorselNesne.YaziYaz(APencere: PGorselNesne; AYaziHiza: TYaziHiza;
  AAlan: TAlan; AYazi: string; ARenk: TRenk);
var
  i, j, A1, B1: TISayi4;
begin

  // karakter katar�n�n uzunlu�unu al
  j := Length(AYazi);
  if(j = 0) then Exit;

  if(AYaziHiza.Yatay = yhSag) then
    A1 := AAlan.Sag - (j * 8)
  else if(AYaziHiza.Yatay = yhOrta) then
    A1 := AAlan.Sol + ((AAlan.Sag - AAlan.Sol) div 2) - ((j * 8) div 2)
  else //if(AYaziHiza.Yatay = yhSol) then
    A1 := AAlan.Sol;

  if(AYaziHiza.Dikey = dhAlt) then
    B1 := AAlan.Alt - 16
  else if(AYaziHiza.Dikey = dhOrta) then
    B1 := AAlan.Ust + ((AAlan.Alt - AAlan.Ust) div 2) - (16 div 2)
  else //if(AYaziHiza.Dikey = dhUst) then
    B1 := AAlan.Ust;

  for i := 1 to j do
  begin

    // karakteri yaz
    HarfYaz(APencere, A1, B1, AYazi[i], ARenk);

    // karakter geni�li�ini geni�lik de�erine ekle
    A1 += 8;
  end;
end;

{==============================================================================
  dikd�rtgensel (4 nokta) grafiksel ekrana karakter katar� yazar
 ==============================================================================}
// �nemli bilgi: �u a�amada �oklu sat�r i�levi olmad��� i�in Y1 -> Y2 kontrol� YAPILMAMAKTADIR
procedure TGorselNesne.AlanaYaziYaz(APencere: PGorselNesne; Nokta4: TAlan;
  A1, B1: TISayi4; AKarakterDizi: string; ARenk: TRenk);
var
  _KarakterDiziUz, _i,
  _A1, _B1: TISayi4;
begin

  {
      Nokta4.Sol:Nokta4.Ust = sol �st k��e (�rn: 100, 100)
      Nokta4.Sag:Nokta4.Alt = sa� alt k��e (�rn: 200, 200)
      A1 = �izim Nokta4.Sol'den ka� pixel uzakl�ktan ba�layacak (�rn: 10 = 110)
      B1 = �izim Nokta4.Ust'den ka� pixel uzakl�ktan ba�layacak (�rn: 12 = 112)
  }

  // karakter katar�n�n uzunlu�unu al
  _KarakterDiziUz := Length(AKarakterDizi);
  if(_KarakterDiziUz = 0) then Exit;

  _A1 := Nokta4.Sol + A1;
  _B1 := Nokta4.Ust + B1;

  if(_A1 >= Nokta4.Sag) then Exit;
  if(_B1 >= Nokta4.Alt) then Exit;

  for _i := 1 to _KarakterDiziUz do
  begin

    if((_A1 + 8) >= Nokta4.Sag) then Break;

    // karakteri yaz
    HarfYaz(APencere, _A1, _B1, AKarakterDizi[_i], ARenk);

    // karakter geni�li�ini x de�erine ekle
    _A1 += 8;
  end;
end;

{==============================================================================
  grafiksel ekrana integer say� yazar
 ==============================================================================}
procedure TGorselNesne.SayiYaz10(APencere: PGorselNesne; A1, B1: TISayi4;
  ASayi: TISayi4; ARenk: TRenk);
var
  _Deger: array[0..11] of Char;
begin

  // desimal de�eri string de�ere �evir
  _Deger := IntToStr(ASayi);

  // say�sal de�eri ekrana yaz
  YaziYaz(APencere, A1, B1, _Deger, ARenk);
end;

{==============================================================================
  grafiksel ekrana 16l� tabanda say� yazar
 ==============================================================================}
procedure TGorselNesne.Kesme_SayiYaz16(A1, B1: TISayi4; AOnEkYaz: LongBool;
  AHaneSayisi, ADeger: TISayi4; ARenk: TRenk);
var
  _Deger: string[10];
  _Alan: TAlan;
begin

  // hexadesimal de�eri string de�ere �evir
  if(AOnEkYaz) then
    _Deger := '0x' + hexStr(ADeger, AHaneSayisi)
  else _Deger := hexStr(ADeger, AHaneSayisi);

  _Alan := CizimAlaniniAl(Kimlik);

  // say�sal de�eri ekrana yaz
  YaziYaz(FAtaNesne, _Alan.Sol + A1, _Alan.Ust + B1, _Deger, ARenk);
end;

{==============================================================================
  grafiksel ekrana hexadesimal say� yazar
 ==============================================================================}
procedure TGorselNesne.SayiYaz16(APencere: PGorselNesne; A1, B1: TISayi4; AOnEkYaz: LongBool;
  AHaneSayisi, ADeger: TISayi4; ARenk: TRenk);
var
  _Deger: string[10];
begin

  // hexadesimal de�eri string de�ere �evir
  if(AOnEkYaz) then
    _Deger := '0x' + hexStr(ADeger, AHaneSayisi)
  else _Deger := hexStr(ADeger, AHaneSayisi);

  // say�sal de�eri ekrana yaz
  YaziYaz(APencere, A1, B1, _Deger, ARenk);
end;

{==============================================================================
  grafiksel ekrana belirtilen saat de�erini yazar
 ==============================================================================}
procedure TGorselNesne.Kesme_SaatYaz(A1, B1: TISayi4; ASaat: TSaat; ARenk: TRenk);
var
  _Saat: string[8];
  _Alan: TAlan;
begin

  // saat de�erini karakter katar�na �evir
  _Saat := TimeToStr(ASaat);

  _Alan := CizimAlaniniAl(Kimlik);

  // saat de�erini belirtilen koordinatlara yaz
  YaziYaz(FAtaNesne, _Alan.Sol + A1, _Alan.Ust + B1, _Saat, ARenk);
end;

{==============================================================================
  grafiksel ekrana belirtilen saat de�erini yazar
 ==============================================================================}
procedure TGorselNesne.SaatYaz(APencere: PGorselNesne; A1, B1: TISayi4;
  ASaat: TSaat; ARenk: TRenk);
var
  _Saat: string[8];
begin

  // saat de�erini karakter katar�na �evir
  _Saat := TimeToStr(ASaat);

  // saat de�erini belirtilen koordinatlara yaz
  YaziYaz(APencere, A1, B1, _Saat, ARenk);
end;

{==============================================================================
  grafiksel ekrana mac adres de�erini yazar
 ==============================================================================}
procedure TGorselNesne.MACAdresiYaz(APencere: PGorselNesne; A1, B1: TISayi4;
  AMACAdres: TMACAdres; ARenk: TRenk);
var
  _MACAdres: string[17];
begin

  // MAC adres de�erini karakter katar�na �evir
  _MACAdres := MacToStr(AMACAdres);

  // MAC adres de�erini belirtilen koordinatlara yaz
  YaziYaz(APencere, A1, B1, _MACAdres, ARenk);
end;

{==============================================================================
  grafiksel ekrana ip adres de�erini yazar
 ==============================================================================}
procedure TGorselNesne.IPAdresiYaz(APencere: PGorselNesne; A1, B1: TSayi4;
  AIPAdres: TIPAdres; ARenk: TRenk);
var
  _IPAdres: string[15];
begin

  // IP adres de�erini karakter katar�na �evir
  _IPAdres := IpToStr(AIPAdres);

  // ip adres de�erini belirtilen koordinatlara yaz
  YaziYaz(APencere, A1, B1, _IPAdres, ARenk);
end;

{==============================================================================
  nesneye belirtilen renkte dikd�rtgen �izer
 ==============================================================================}
procedure TGorselNesne.Dikdortgen(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4;
  ACizgiRengi: TRenk);
begin

  // �st yatay �izgiyi �iz
  YatayCizgi(APencere, A1, B1, A2, ACizgiRengi);

  // sol dikey �izgiyi �iz
  DikeyCizgi(APencere, A1, B1, B2, ACizgiRengi);

  // alt yatay �izgiyi �iz
  YatayCizgi(APencere, A2, B2, A1, ACizgiRengi);

  // sa� dikey �izgiyi �iz
  DikeyCizgi(APencere, A2, B2, B1, ACizgiRengi);
end;

{==============================================================================
  nesnenin dikd�rtgensel olarak s�n�rland�r�lm�� alan�na belirtilen renkte i�i
  doldurulmu� dikd�rtgen �izer. (not: test edilecek)
 ==============================================================================}
procedure TGorselNesne.Doldur4(APencere: PGorselNesne; Nokta4: TAlan; A1, B1, A2, B2: TISayi4;
  ACizgiRengi, ADolguRengi: TRenk);
var
  _i, _j, _A1, _B1, _A2, _B2: TISayi4;
begin

  // �izim koordinatlar�n�n�n s�n�rlar�n i�erisinde olup olmad���n� kontrol et
  if(A1 < Nokta4.Sol) then
    _A1 := Nokta4.Sol
  else _A1 := A1;

  if(B1 < Nokta4.Ust) then
    _B1 := Nokta4.Ust
  else _B1 := B1;

  if(A2 > Nokta4.Sag) then
    _A2 := Nokta4.Sag
  else _A2 := A2;

  if(B2 > Nokta4.Alt) then
    _B2 := Nokta4.Alt
  else _B2 := B2;

  // d�� kenarl�k
  Dikdortgen(APencere, _A1, _B1, _A2, _B2, ACizgiRengi);

  // i� kenarl�k
  Inc(_A1);
  Inc(_B1);
  Dec(_A2);
  Dec(_B2);

  for _j := _B1 to _B2 do
  begin

    for _i := _A1 to _A2 do
    begin

      GEkranKartSurucusu.NoktaYaz(@Self, _i, _j, ADolguRengi, True);
    end;

  end;
end;

{==============================================================================
  nesneye belirtilen renkte i�i doldurulmu� dikd�rtgen �izer
 ==============================================================================}
procedure TGorselNesne.DikdortgenDoldur(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4;
  ACizgiRengi, ADolguRengi: TRenk);
var
  _Alan: TAlan;
begin

  _Alan.Sol := A1;
  _Alan.Ust := B1;
  _Alan.Sag := A2;
  _Alan.Alt := B2;
  DikdortgenDoldur(APencere, _Alan, ACizgiRengi, ADolguRengi);
end;

{==============================================================================
  nesneye belirtilen renkte i�i doldurulmu� dikd�rtgen �izer
 ==============================================================================}
procedure TGorselNesne.DikdortgenDoldur(APencere: PGorselNesne; AAlan: TAlan;
  ACizgiRengi, ADolguRengi: TRenk);
var
  _i, _j, _A1, _B1, _A2, _B2: TISayi4;
begin

  // d�� kenarl�k
  _A1 := AAlan.Sol;
  _B1 := AAlan.Ust;
  _A2 := AAlan.Sag;
  _B2 := AAlan.Alt;
  Dikdortgen(APencere, _A1, _B1, _A2, _B2, ACizgiRengi);

  // i� kenarl�k
  Inc(_A1);
  Inc(_B1);
  Dec(_A2);
  Dec(_B2);

  for _j := _B1 to _B2 do
  begin

    for _i := _A1 to _A2 do
    begin

      GEkranKartSurucusu.NoktaYaz(APencere, _i, _j, ADolguRengi, True);
    end;
  end;
end;

procedure TGorselNesne.BMPGoruntusuCiz(AGorselNesneTipi: TGorselNesneTipi; AKimlik: TKimlik;
  AGoruntuYapi: TGoruntuYapi);
begin

  ResimCiz(AGorselNesneTipi, AKimlik, AGoruntuYapi);
end;

{==============================================================================
  nesneye belirtilen renkte �izgi �izer
 ==============================================================================}
// https://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm
// procedure drawLine (bitmap : TBitmap; xStart, yStart, xEnd, yEnd : integer; color : TAlphaColor);
procedure TGorselNesne.Cizgi(APencere: PGorselNesne; A1, B1, A2, B2: TISayi4;
  ACizgiRengi: TRenk);
// Bresenham's Line Algorithm.  Byte, March 1988, pp. 249-253.
// Modified from http://www.efg2.com/Lab/Library/Delphi/Graphics/Bresenham.txt and tested.
var
  a, b: TISayi4;          // displacements in x and y
  d: TISayi4;             // decision variable
  diag_inc: TISayi4;      // d's increment for diagonal steps
  dx_diag: TISayi4;       // diagonal x step for next pixel
  dx_nondiag: TISayi4;    // nondiagonal x step for next pixel
  dy_diag: TISayi4;       // diagonal y step for next pixel
  dy_nondiag: TISayi4;    // nondiagonal y step for next pixel
  i: TISayi4;             // loop index
  nondiag_inc: TISayi4;   // d's increment for nondiagonal steps
  swap: TISayi4;          // temporary variable for swap
  x,y: TISayi4;           // current x and y coordinates
begin

  x := A1;                // line starting point}
  y := B1;

  // Determine drawing direction and step to the next pixel.
  a := A2 - A1;           // difference in x dimension
  b := B2 - B1;           // difference in y dimension

  // Determine whether end point lies to right or left of start point.
  if a < 0 then           // drawing towards smaller x values?
  begin

    a := -a;              // make 'a' positive
    dx_diag := -1
  end else dx_diag := 1;

  // Determine whether end point lies above or below start point.
  if b < 0 then           // drawing towards smaller x values?
  begin

    b := -b;              // make 'a' positive
    dy_diag := -1
  end else dy_diag := 1;

  // Identify octant containing end point.
  if a < b then
  begin

    swap := a;
    a := b;
    b := swap;
    dx_nondiag := 0;
    dy_nondiag := dy_diag
  end
  else
  begin

    dx_nondiag := dx_diag;
    dy_nondiag := 0
  end;

  d := b + b - a;         // initial value for d is 2*b - a
  nondiag_inc := b + b;   // set initial d increment values
  diag_inc := b + b - a - a;

  for i := 0 to a do
  begin                   // draw the a+1 pixels

    //drawPixel (bitmap, x, y, color);
    GEkranKartSurucusu.NoktaYaz(APencere, x, y, ACizgiRengi, True);
    if d < 0 then         // is midpoint above the line?
    begin                 // step nondiagonally

      x := x + dx_nondiag;
      y := y + dy_nondiag;
      d := d + nondiag_inc// update decision variable
    end
    else
    begin                 // midpoint is above the line; step diagonally}

      x := x + dx_diag;
      y := y + dy_diag;
      d := d + diag_inc
    end;
  end;
end;

{==============================================================================
  nesneye daire �ekli �izer
 ==============================================================================}
procedure TGorselNesne.Daire(A1, B1, AYariCap: TISayi4; ARenk: TRenk);
var
  _A1, _B1, _YariCap: TISayi4;
begin

  _A1 :=0;
  _B1 :=AYariCap;
  _YariCap := 1 - AYariCap;

  while _A1 < _B1 do
  begin

    if _YariCap < 0 then

      _YariCap :=_YariCap + 2 *_A1 + 3
    else
    begin

      _YariCap :=_YariCap + 2 *_A1 - 2 *_B1 + 5;
      dec(_B1);
    end;

    GEkranKartSurucusu.NoktaYaz(@Self, A1 + _A1, B1 - _B1, ARenk, True); // Top
    GEkranKartSurucusu.NoktaYaz(@Self, A1 - _A1, B1 - _B1, ARenk, True);
    GEkranKartSurucusu.NoktaYaz(@Self, A1 + _B1, B1 - _A1, ARenk, True); // Upper middle
    GEkranKartSurucusu.NoktaYaz(@Self, A1 - _B1, B1 - _A1, ARenk, True);
    GEkranKartSurucusu.NoktaYaz(@Self, A1 + _B1, B1 + _A1, ARenk, True); // Lower middle
    GEkranKartSurucusu.NoktaYaz(@Self, A1 - _B1, B1 + _A1, ARenk, True);
    GEkranKartSurucusu.NoktaYaz(@Self, A1 + _A1, B1 + _B1, ARenk, True); // Bottom
    GEkranKartSurucusu.NoktaYaz(@Self, A1 - _A1, B1 + _B1, ARenk, True);
    Inc(_A1);
  end;
end;

{==============================================================================
  nesneye i�i boyal� daire �ekli �izer
 ==============================================================================}
procedure TGorselNesne.DaireDoldur(APencere: PGorselNesne; A1, B1, AYariCap: TISayi4;
  ARenk: TRenk);
var
  _A1, _B1, _YariCap, _DX: TISayi4;
begin

  if AYariCap = 0 then AYariCap := 1;

  _YariCap := AYariCap * AYariCap;

  for _A1 := AYariCap downto 0 do
  begin

    _B1 := round(sqrt(_YariCap - _A1 * _A1));
    _DX := A1 - _A1;
    Cizgi(APencere, _DX - 1, B1 - _B1, _DX - 1, B1 + _B1, ARenk);
    _DX := A1 + _A1;
    Cizgi(APencere, _DX, B1 - _B1, _DX, B1 + _B1, ARenk);
  end;
end;

{==============================================================================
  nesneye belirtilen renkte yatay �izgi �izer
 ==============================================================================}
procedure TGorselNesne.YatayCizgi(APencere: PGorselNesne; A1, B1, A2: TISayi4;
  ARenk: TRenk);
var
  _i: TISayi4;
begin

  // e�er A1 > A2 ise A2 ile A1 de�erlerini yer de�i�tir.
  if(A1 > A2) then
  begin

    _i := A2;
    A2 := A1;
    A1 := _i;
  end;

  // pixel'in nesneye ait olup olmad���n� kontrol ederek i�aretleme yap
  for _i := A1 to A2 do GEkranKartSurucusu.NoktaYaz(APencere, _i, B1, ARenk, True);
end;

{==============================================================================
  nesneye belirtilen renkte dikey �izgi �izer
 ==============================================================================}
procedure TGorselNesne.DikeyCizgi(APencere: PGorselNesne; A1, B1, B2: TISayi4;
  ARenk: TRenk);
var
  _i: TISayi4;
begin

  // e�er B1 > B2 ise B2 ile B1 de�erlerini yer de�i�tir.
  if(B1 > B2) then
  begin

    _i := B2;
    B2 := B1;
    B1 := _i;
  end;

  // pixel'in nesneye ait olup olmad���n� kontrol ederek i�aretleme yap
  for _i := B1 to B2 do GEkranKartSurucusu.NoktaYaz(APencere, A1, _i, ARenk, True);
end;

// yukar�dan a�a��ya e�imli doldurma i�lemi
procedure TGorselNesne.EgimliDoldur(APencere: PGorselNesne; Alan: TAlan;
  ARenk1, ARenk2: TRenk);
var
  _Renk: TRenk;
  _A1, _B1: TISayi4;

  function Gradient: TRenk;
  var
    D: Double;
    CAR, CAG, CAB, CBR, CBG, CBB: Byte;
  begin

    D := _B1 / (Alan.Alt - Alan.Ust + 1);
    RedGreenBlue(ARenk1, CAR, CAG, CAB);
    RedGreenBlue(ARenk2, CBR, CBG, CBB);

    Result := RGBToColor(Round((CAR + D * (CBR - CAR))),
      Round((CAG + D * (CBG - CAG))),
      Round((CAB + D * (CBB - CAB))));
  end;
begin

  for _A1 := 0 to Alan.Sag - Alan.Sol do
  begin

    for _B1 := 0 to Alan.Alt - Alan.Ust do
    begin

      _Renk := Gradient;
      //PixelYaz(APencere, Alan.Sol + _A1, Alan.Ust + _B1, _Renk);
      PixelYaz(APencere, Alan.Sol + _A1, Alan.Ust + _B1, _Renk);
    end;
  end;
end;

// soldan sa�a e�imli doldurma i�lemi
procedure TGorselNesne.EgimliDoldur2(APencere: PGorselNesne; Alan: TAlan;
  ARenk1, ARenk2: TRenk);
var
  _Renk: TRenk;
  _A1, _B1: TISayi4;

  function Gradient: TRenk;
  var
    D, DX, DY, P: Double;
    CAR, CAG, CAB, CBR, CBG, CBB: Byte;
  begin

    DX := ((Alan.Sag - Alan.Sol) / 2) - _A1;
    DY := ((Alan.Alt - Alan.Ust) / 2) - _B1;

    D := Sqrt(DX * DX + DY * DY);
    P := D / 255;

    //if(D < 128) then begin
    RedGreenBlue(ARenk1, CAR, CAG, CAB);
    RedGreenBlue(ARenk2, CBR, CBG, CBB);

    Result := RGBToColor(Round((CAR + P * (CBR - CAR))),
      Round((CAG + P * (CBG - CAG))),
      Round((CAB + P * (CBB - CAB))));

    //end else Result := clBlack;
  end;
begin

  for _A1 := 0 to Alan.Sag - Alan.Sol do
  begin

    for _B1 := 0 to Alan.Alt - Alan.Ust do
    begin

      _Renk := Gradient;
      PixelYaz(APencere, Alan.Sol + _A1, Alan.Ust + _B1, _Renk);
    end;
  end;
end;

// dikey olarak; 1. renkten 2. renge �stten ortaya kadar; 2. renkten 1. renge ortadan alta kadar
procedure TGorselNesne.EgimliDoldur3(APencere: PGorselNesne; Alan: TAlan;
  ARenk1, ARenk2: TRenk);
var
  _Alan: TAlan;
  _Renk: TRenk;
  _A1, _B1: TISayi4;
  _Renk1, _Renk2: TRenk;

  function Gradient: TRenk;
  var
    D: Double;
    CAR, CAG, CAB, CBR, CBG, CBB: Byte;
  begin

    D := _B1 / (_Alan.Alt - _Alan.Ust + 1);
    RedGreenBlue(_Renk1, CAR, CAG, CAB);
    RedGreenBlue(_Renk2, CBR, CBG, CBB);

    Result := RGBToColor(Round((CAR + D * (CBR - CAR))),
      Round((CAG + D * (CBG - CAG))),
      Round((CAB + D * (CBB - CAB))));
  end;
begin

  _Renk1 := ARenk1;
  _Renk2 := ARenk2;
  _Alan.Sol := Alan.Sol;
  _Alan.Sag := Alan.Sag;
  _Alan.Ust := Alan.Ust;
  _Alan.Alt := Alan.Ust + ((Alan.Alt - Alan.Ust) div 2);

  for _A1 := 0 to _Alan.Sag - _Alan.Sol do
  begin

    for _B1 := 0 to _Alan.Alt - _Alan.Ust do
    begin

      _Renk := Gradient;
      //PixelYaz(APencere, Alan.Sol + _A1, Alan.Ust + _B1, _Renk);
      PixelYaz(APencere, _Alan.Sol + _A1, _Alan.Ust + _B1, _Renk);
    end;
  end;

  _Renk1 := ARenk2;
  _Renk2 := ARenk1;
  _Alan.Sol := Alan.Sol;
  _Alan.Sag := Alan.Sag;
  _Alan.Ust := Alan.Ust + ((Alan.Alt - Alan.Ust) div 2);
  _Alan.Alt := Alan.Alt;

  for _A1 := 0 to _Alan.Sag - _Alan.Sol do
  begin

    for _B1 := 0 to _Alan.Alt - _Alan.Ust do
    begin

      _Renk := Gradient;
      //PixelYaz(APencere, Alan.Sol + _A1, Alan.Ust + _B1, _Renk);
      PixelYaz(APencere, _Alan.Sol + _A1, _Alan.Ust + _B1, _Renk);
    end;
  end;
end;

procedure TGorselNesne.KenarlikCiz(APencere: PGorselNesne; AAlan: TAlan; AKalinlik: TSayi4);
var
  _i: TISayi4;
begin

  if(AKalinlik > 0) then
  begin

    // ilk �st ve sol �izgiyi �iz
    YatayCizgi(APencere, AAlan.Sol, AAlan.Ust, AAlan.Sag-1, $808080);
    DikeyCizgi(APencere, AAlan.Sol, AAlan.Ust, AAlan.Alt-1, $808080);

    // ilk alt ve sa� �izgiyi �iz
    YatayCizgi(APencere, AAlan.Sag, AAlan.Alt, AAlan.Sol, $EFEFEF);
    DikeyCizgi(APencere, AAlan.Sag, AAlan.Alt, AAlan.Ust, $EFEFEF);

    if(AKalinlik > 1) then
    begin

      for _i := 1 to AKalinlik - 1 do
      begin

        // i�e do�ru di�er �st ve sol �izgiyi �iz
        YatayCizgi(APencere, AAlan.Sol + _i, AAlan.Ust + _i, AAlan.Sag - _i - 1, $404040);
        DikeyCizgi(APencere, AAlan.Sol + _i, AAlan.Ust + _i, AAlan.Alt - _i - 1, $404040);

        // i�e do�ru di�er alt ve sa� �izgiyi �iz
        YatayCizgi(APencere, AAlan.Sag - _i, AAlan.Alt - _i, AAlan.Sol + _i, $D4D0C8);
        DikeyCizgi(APencere, AAlan.Sag - _i, AAlan.Alt - _i, AAlan.Ust + _i, $D4D0C8);
      end;
    end;
  end;
end;

// g�rsel nesneye ham resim �izer
procedure TGorselNesne.HamResimCiz(AGorselNesne: PGorselNesne; A1, B1: TSayi4;
  AHamResimBellekAdresi: Isaretci);
var
  _A1, _B1, _Renk: TSayi4;
  _BaslatMenuResimAdresi: PSayi4;
begin

  _BaslatMenuResimAdresi := AHamResimBellekAdresi;

  for _B1 := 1 to 24 do
  begin

    for _A1 := 1 to 24 do
    begin

      // yeni �izilecek cursor'�n bitmap b�lgesine konumlan
      _Renk := _BaslatMenuResimAdresi^;

      PixelYaz(AGorselNesne, A1 + (_A1 - 1), B1 + (_B1 - 1), _Renk);

      Inc(_BaslatMenuResimAdresi);
    end;
  end;
end;

// g�rsel nesneye sistem kaynak resimlerinden resim �izer
procedure TGorselNesne.KaynaktanResimCiz(AGorselNesne: PGorselNesne; A1, B1: TSayi4;
  ASiraNo: TSayi4);
var
  _A1, _B1, _Renk: TSayi4;
  _BaslatMenuResimAdresi: PSayi4;
begin

  _BaslatMenuResimAdresi := GSistemResimler.BellekAdresi + (ASiraNo * 24 * 24 * 4);

  for _B1 := 1 to 24 do
  begin

    for _A1 := 1 to 24 do
    begin

      // yeni �izilecek cursor'�n bitmap b�lgesine konumlan
      _Renk := _BaslatMenuResimAdresi^;

      PixelYaz(AGorselNesne, A1 + (_A1 - 1), B1 + (_B1 - 1), _Renk);

      Inc(_BaslatMenuResimAdresi);
    end;
  end;
end;

end.
