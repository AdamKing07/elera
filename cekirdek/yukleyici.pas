{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: yukleyici.pas
  Dosya ��levi: sistem ilk a��l�� y�kleme i�levleri ger�ekle�tirir

  G�ncelleme Tarihi: 27/03/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
//{$DEFINE SRC_SB}
//{$DEFINE SRC_COM}
{$DEFINE AG_YUKLE}
unit yukleyici;

interface

procedure Yukle;
procedure YukleIslevindenOnceCalistir;
procedure YukleIslevindenSonraCalistir;

implementation

uses yonetim, gdt, idt, irq, pic, aygityonetimi, pci, src_klavye, genel, gorev,
  gn_islevler, dosya, sistemmesaj, bolumleme, islemci, paylasim, usb, zamanlayici,
  ag, src_vesa20, src_com, src_sb, bmp, acpi;

{==============================================================================
  �ekirdek �evre donan�m y�kleme i�levlerini ger�ekle�tir
 ==============================================================================}
procedure Yukle;
var
  _Gorev: PGorev;
begin

  CokluGorevBasladi := 0;

  // �ekirdek y�kleme �ncesi i�levleri ger�ekle�tir
  YukleIslevindenOnceCalistir;

  // t�m kesmeleri pasifle�tir
  IRQKesmeleriniDurdur;

  // sistem global tan�mlay�c� tabloyu (GDTRYazmac) ve i�eri�ini y�kle
  gdt.Yukle;

  // kesme yazmac�n� (IDTYazmac) ve i�eri�ini y�kle
  idt.Yukle;

  // pic denetleyicisini ilk de�erlerle y�kle
  pic.Yukle;

  // irq denetleyicisini ilk de�erlerle y�kle
  // Bilgi: bu a�amaya kadar t�m irq istekleri kapal�d�r.
  // bu a�amadan itibaren yap�lacak IRQEtkinlestir, IRQIsleviAta
  // i�levleri belirtilen irq isteklerini devreye sokacakt�r
  irq.Yukle;

  // bu i�lev �oklu g�rev ortam�na girmeden �nce test edilmelidir
  IRQIsleviAta(0, @TekGorevZamanlayiciIslevi);
  IRQEtkinlestir(0);

  // belle�i ilk kullan�m i�in haz�rla
  // �nemli: GGercekBellek.Yukle i�levinin di�er i�levlere zemin haz�rlamas� i�in
  // �ncelikle y�klenmesi gerekmektedir.
  GGercekBellek.Yukle;

  // NOT: SISTEM_MESAJ_'ler buradan itibaren sistem i�erisine y�nlendiriliyor

  //SISTEM_MESAJ_YAZI('+ Sistem mesaj servisi ba�lat�l�yor...');
  GSistemMesaj.Yukle;

  // uygulama de�i�kenlerini ilk de�erlerle y�kle
  _Gorev^.Yukle;

  // �ekirdek de�i�ken / i�levlerini ilk de�erlerle y�kle
  yonetim.Yukle;

  // vesa 2.0 grafik s�r�c�s�n� y�kle
  GEkranKartSurucusu.Yukle;

  // Bilgi: SISTEM_MESAJ_'ler buradan itibaren kullan�labilir

  SISTEM_MESAJ_YAZI('+ ��lemci bilgileri al�n�yor...');
  GIslemciBilgisi.Satici := IslemciSaticisiniAl;
  IslemciOzellikleriniAl1(GIslemciBilgisi.Ozellik1_EAX, GIslemciBilgisi.Ozellik1_EDX,
    GIslemciBilgisi.Ozellik1_ECX);

  SISTEM_MESAJ_YAZI('+ Zamanlay�c� y�kleniyor...');
  GZamanlayici.Yukle;

  // Bilgi: Delay i�levleri buradan itibaren kullan�labilir

  SISTEM_MESAJ_YAZI('+ PCI ayg�tlar� aran�yor...');
  pci.Yukle;

  SISTEM_MESAJ_YAZI('+ ACPI donan�m� y�kleniyor...');
  acpi.Yukle;

  SISTEM_MESAJ_YAZI('+ Klavye ayg�t� y�kleniyor...');
  src_klavye.Yukle;

  SISTEM_MESAJ_YAZI('+ PS2 fare s�r�c�s� y�kleniyor...');
  GFareSurucusu.Yukle;

  SISTEM_MESAJ_YAZI('+ USB ayg�tlar� y�kleniyor...');
  usb.Yukle;

  SISTEM_MESAJ_YAZI('+ Depolama ayg�tlar� y�kleniyor...');
  DepolamaAygitlariniYukle;

  SISTEM_MESAJ_YAZI('+ Mant�ksal s�r�c� atamalar� ger�ekle�tiriliyor...');
  bolumleme.Yukle;

  {$IFDEF SRC_COM}
  SISTEM_MESAJ_YAZI('+ �leti�im (COM) portu y�kleniyor...');
  src_com.Yukle;
  {$ENDIF}

  // sound blaster ses ayg�t�n� y�kle
  {$IFDEF SRC_SB}
  SISTEM_MESAJ_YAZI('+ Ses kart� y�kleniyor...');
  src_sb.Yukle;
  {$ENDIF}

  // a� bile�enlerini y�kle
  {$IFDEF AG_YUKLE}
  ag.Yukle;
  {$ENDIF}

  // olay nesnesini ilk de�erlerini y�kle
  GOlay.Yukle;

  SISTEM_MESAJ_YAZI('+ Sistem i�erisinde kullan�lacak g�rsel olmayan nesneler y�kleniyor.');
  ListeleriIlkDegerlerleYukle;

  SISTEM_MESAJ_YAZI('+ G�rsel nesne i�in bellek i�lemleri yap�l�yor.');
  gn_islevler.Yukle;

  // �ekirdek y�kleme sonras� i�levleri ger�ekle�tir
  YukleIslevindenSonraCalistir;

  // sistem mesajlar�n� g�rmek i�in bekleme s�resi.
  Bekle(50);

  CokluGorevBasladi := 1;
end;

{==============================================================================
  �ekirdek y�kleme �ncesi i�levleri �al��t�r�r.
 ==============================================================================}
procedure YukleIslevindenOnceCalistir;
begin

  SistemSayaci := 0;
  ZamanlayiciSayaci := 0;
end;

{==============================================================================
  �ekirdek y�kleme sonras� i�levleri �al��t�r�r.
 ==============================================================================}
procedure YukleIslevindenSonraCalistir;
begin

  dosya.Yukle;

  // 24 x 24 sistem resimlerini y�kle
  GSistemResimler := BMPDosyasiYukle('disk1:\sistem.bmp');
end;

end.
