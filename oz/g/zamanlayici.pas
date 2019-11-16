{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: zamanlayici.pas
  Dosya ��levi: zamanlay�c� y�netim i�levlerini i�erir

  G�ncelleme Tarihi: 19/10/2019

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
unit zamanlayici;

interface

uses paylasim, port;

const
  AZAMI_ZAMANLAYICI_SAYISI = 32;

type
  TZamanlayiciDurum = (zdBos, zdCalisiyor, zdDurduruldu);

type
  PZamanlayici = ^TZamanlayici;
  TZamanlayici = object
  private
    FZamanlayiciDurum: TZamanlayiciDurum;
    FKimlik: TKimlik;
    FGorevKimlik: TKimlik;
    FTetiklemeSuresi, FGeriSayimSayaci: TSayi4;
  public
    procedure Yukle;
    function Olustur(AMiliSaniye: TISayi4): PZamanlayici;
    function BosZamanlayiciBul: PZamanlayici;
    procedure YokEt;
    property Durum: TZamanlayiciDurum read FZamanlayiciDurum write FZamanlayiciDurum;
    property Kimlik: TKimlik read FKimlik;
    property GorevKimlik: TKimlik read FGorevKimlik write FGorevKimlik;
    property TetiklemeSuresi: TSayi4 read FTetiklemeSuresi write FTetiklemeSuresi;
    property GeriSayimSayaci: TSayi4 read FGeriSayimSayaci write FGeriSayimSayaci;
  end;

var
  ZamanlayiciYapiBellekAdresi: Isaretci;
  OlusturulanZamanlayiciSayisi: TSayi4 = 0;
  ZamanlayiciListesi: array[1..AZAMI_ZAMANLAYICI_SAYISI] of PZamanlayici;

procedure ZamanlayicilariKontrolEt;
procedure ZamanlayicilariYokEt(AGorevKimlik: TGorevKimlik);
procedure Bekle(AMilisaniye: TSayi4);
procedure TekGorevZamanlayiciIslevi;
procedure OtomatikGorevDegistir;
procedure ElleGorevDegistir;

implementation

uses genel, gorev, src_disket, arp, idt, irq, pit;

{==============================================================================
  zamanlay�c� nesnelerinin ana y�kleme i�levlerini i�erir
 ==============================================================================}
procedure TZamanlayici.Yukle;
var
  _Zamanlayici: PZamanlayici;
  _BellekAdresi: Isaretci;
  _ZamanlayiciU, i: TSayi4;
begin

  // kesmeleri durdur
  cli;

  IRQPasiflestir(0);

  // IRQ0 giri� noktas�n� yeniden belirle
  KesmeGirisiBelirle($20, @OtomatikGorevDegistir, SECICI_SISTEM_KOD, $8E);   // IRQ0

  // saat vuru� frekans�n� d�zenle. 100 tick = 1 saniye
  ZamanlayiciFrekansiniDegistir(100);

  _ZamanlayiciU := SizeOf(TZamanlayici);

  //SISTEM_MESAJ_S10('Zamanlay�c� Yap� Uzunlu�u: ', _ZamanlayiciU);

  // uygulamalar i�in zamanlay�c� bilgilerinin yerle�tirilece�i bellek olu�tur
  ZamanlayiciYapiBellekAdresi := GGercekBellek.Ayir(AZAMI_ZAMANLAYICI_SAYISI * _ZamanlayiciU);

  // bellek giri�lerini zamanlay�c� yap�lar�yla e�le�tir
  _BellekAdresi := ZamanlayiciYapiBellekAdresi;
  for i := 1 to AZAMI_ZAMANLAYICI_SAYISI do
  begin

    _Zamanlayici := _BellekAdresi;
    ZamanlayiciListesi[i] := _Zamanlayici;

    _Zamanlayici^.FZamanlayiciDurum := zdBos;
    _Zamanlayici^.FKimlik := i;

    _BellekAdresi += _ZamanlayiciU;
  end;

  // �al��an zamanlay�c� say�s�n� s�f�rla
  OlusturulanZamanlayiciSayisi := 0;

  // IRQ0'� etkinle�tir
  IRQEtkinlestir(0);

  // kesmeleri aktifle�tir
  sti;
end;

{==============================================================================
  zamanlay�c� nesnesi olu�turur
 ==============================================================================}
function TZamanlayici.Olustur(AMiliSaniye: TISayi4): PZamanlayici;
var
  _Zamanlayici: PZamanlayici;
begin

  // bo� bir zamanlay�c� nesnesi bul
  _Zamanlayici := BosZamanlayiciBul;
  if(_Zamanlayici <> nil) then
  begin

    //SISTEM_MESAJ_S10('Zamanlay�c� kimlik: ', _Zamanlayici^.FKimlik);

    _Zamanlayici^.FGorevKimlik := AktifGorev;
    _Zamanlayici^.FTetiklemeSuresi := AMiliSaniye;
    _Zamanlayici^.FGeriSayimSayaci := AMiliSaniye;

    Inc(OlusturulanZamanlayiciSayisi);

    Exit(_Zamanlayici);
  end;

  // geri d�n�� de�eri
  Result := nil;
end;

{==============================================================================
  bo� zamanlay�c� bulur
 ==============================================================================}
function TZamanlayici.BosZamanlayiciBul: PZamanlayici;
var
  i: TSayi4;
begin

  // t�m zamanlay�c� nesnelerini ara
  for i := 1 to AZAMI_ZAMANLAYICI_SAYISI do
  begin

    // zamanlay�c� nesnesinin durumu bo� ise
    if(ZamanlayiciListesi[i]^.FZamanlayiciDurum = zdBos) then
    begin

      // durduruldu olarak i�aretle ve �a��ran i�leve geri d�n
      ZamanlayiciListesi[i]^.FZamanlayiciDurum := zdDurduruldu;
      Result := ZamanlayiciListesi[i];
      Exit;
    end;
  end;

  Result := nil;
end;

{==============================================================================
  zamanlay�c� nesnesini yok eder.
 ==============================================================================}
procedure TZamanlayici.YokEt;
begin

  // e�er zamanlay�c� nesnesinin durumu bo� de�il ise
  if(FZamanlayiciDurum <> zdBos) then
  begin

    // bo� olarak i�aretle
    FZamanlayiciDurum := zdBos;

    // zamanlay�c� nesnesini bir azalt
    Dec(OlusturulanZamanlayiciSayisi);
  end;
end;

{==============================================================================
  zamanlay�c�lar� tetikler (IRQ00 taraf�ndan �a�r�l�r)
 ==============================================================================}
procedure ZamanlayicilariKontrolEt;
var
  _Gorev: PGorev;
  _OlayKayit: TOlayKayit;
  _GeriSayimSayaci, i: TISayi4;
begin

  // zamanlay�c� nesnesi yok ise ��k
  if(OlusturulanZamanlayiciSayisi = 0) then Exit;

  // t�m zamanlay�c� nesnelerini denetle
  for i := 1 to AZAMI_ZAMANLAYICI_SAYISI do
  begin

    // e�er �al���yorsa
    if(ZamanlayiciListesi[i]^.FZamanlayiciDurum = zdCalisiyor) then
    begin

      // zamanlay�c� sayac�n� 1 azalt
      _GeriSayimSayaci := ZamanlayiciListesi[i]^.GeriSayimSayaci;
      Dec(_GeriSayimSayaci);
      ZamanlayiciListesi[i]^.GeriSayimSayaci := _GeriSayimSayaci;

      // saya� 0 de�erini bulmu�sa
      if(_GeriSayimSayaci = 0) then
      begin

        // yeni say�m i�in geri say�m de�erini yeniden y�kle
        ZamanlayiciListesi[i]^.GeriSayimSayaci := ZamanlayiciListesi[i]^.TetiklemeSuresi;

        _OlayKayit.Kimlik := i;
        _OlayKayit.Olay := CO_ZAMANLAYICI;
        _OlayKayit.Deger1 := 0;
        _OlayKayit.Deger2 := 0;

        _Gorev := GorevListesi[ZamanlayiciListesi[i]^.GorevKimlik];
        _Gorev^.OlayEkle2(_Gorev^.GorevKimlik, _OlayKayit);
      end;
    end;
  end;
end;

{==============================================================================
  bir s�re�e ait t�m zamanlay�c� nesnelerini yok eder.
 ==============================================================================}
procedure ZamanlayicilariYokEt(AGorevKimlik: TGorevKimlik);
var
  _Zamanlayici: PZamanlayici;
  i: TISayi4;
begin

  // t�m zamanlay�c� nesnelerini ara
  for i := 1 to AZAMI_ZAMANLAYICI_SAYISI do
  begin

    _Zamanlayici := ZamanlayiciListesi[i];

    // zamanlay�c� nesnesi aranan i�leme mi ait
    if(_Zamanlayici^.GorevKimlik = AGorevKimlik) then
    begin

      // nesneyi yok et
      _Zamanlayici^.YokEt;
    end;
  end;
end;

{==============================================================================
  milisaniye cinsinden bekleme i�lemi yapar
  100 milisaniye = 1 saniye
 ==============================================================================}
procedure Bekle(AMilisaniye: TSayi4);
var
  _Sayac: TSayi4;
begin

  // AMilisaniye * 100 saniye bekle
  _Sayac := ZamanlayiciSayaci + AMilisaniye;
  while (_Sayac > ZamanlayiciSayaci) do ElleGorevDegistir;
end;

{==============================================================================
  tek g�revli ortamda (�oklu ortama ge�meden �nce) �al��an zamanlay�c� i�levi
 ==============================================================================}
procedure TekGorevZamanlayiciIslevi;
begin

  { TODO : �al��abilirli�i test edilecek }
  Inc(ZamanlayiciSayaci);
end;

{==============================================================================
  donan�m taraf�ndan g�rev de�i�tirme i�levlerini yerine getirir.
 ==============================================================================}
procedure OtomatikGorevDegistir; nostackframe; assembler;
asm

  cli

  // de�i�ime u�rayacak yazma�lar� sakla
  pushad
  pushfd

  // �al��an g�revin DS yazmac�n� sakla
  // not : ds = es = ss = fs = gs oldu�u i�in tek yazmac�n saklanmas� yeterlidir.
  mov   ax,ds
  push  eax

  // yazma�lar� sistem yazma�lar�na ayarla
  mov   ax,SECICI_SISTEM_VERI
  mov   ds,ax
  mov   es,ax

  // zamanlay�c� sayac�n� art�r.
  mov ecx,ZamanlayiciSayaci
  inc ecx
  mov ZamanlayiciSayaci,ecx

  mov eax,GorevDegisimBayragi
  cmp eax,0
  je  @@cik

  mov   eax,CokluGorevBasladi
  cmp   eax,1
  je    @@kontrol1

@@cik:
  // �al��an proses'in segment yazma�lar�n� eski konumuna geri d�nd�r
  pop   eax
  mov   ds,ax
  mov   es,ax

  mov   al,$20
  out   PIC1_KOMUT,al

  // genel yazma�lar� geri y�kle ve kesmeden ��k
  popfd
  popad
  sti
  iretd

@@kontrol1:

  // rutin i�lev kontrollerinin ger�ekle�tirildi�i k�s�m

  // uygulamalar taraf�ndan olu�turulan zamanlay�c� nesnelerini denetle
  call  ZamanlayicilariKontrolEt

  // her 1 saniyede kontrol edilecek dahili i�levler
  mov edx,0
  mov eax,ZamanlayiciSayaci
  mov ecx,100
  div ecx
  cmp edx,0
  jg  @@yenigorev

  // ARP tablosunu g��ncelle
  call  ARPTablosunuGuncelle

  // disket s�r�c� motorunun aktifli�ini kontrol eder, gerekirse motoru kapat�r
  call  DisketSurucuMotorunuKontrolEt

@@yenigorev:

  // tek bir g�rev �al���yorsa g�rev de�i�ikli�i yapma, ��k
  mov ecx,CalisanGorevSayisi
  cmp ecx,1
  je  @@cik

  // ge�i� yap�lacak bir sonraki g�revi bul
  call  CalistirilacakBirSonrakiGoreviBul
  mov AktifGorev,eax

  // aktif g�revin bellek ba�lang�� adresini al
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov eax,[esi + TGorev.FBellekBaslangicAdresi]
  mov AktifGorevBellekAdresi,eax

  // g�rev de�i�iklik sayac�n� bir art�r
  mov eax,[esi + TGorev.FGorevSayaci]
  inc eax
  mov [esi + TGorev.FGorevSayaci],eax

  // g�revin devredilece�i TSS giri�ini belirle
  mov   ecx,AktifGorev
  cmp   ecx,1
  je    @@TSS_SIS

@@TSS_UYG:      // uygulamaya ge�i� yap
  imul  ecx,3 * 8
  add ecx,(AYRILMIS_SECICISAYISI * 8)
//  add   ecx,3             // DPL3 - uygulama (aktifle�tirilecek)
  mov   @@SECICI,cx
  jmp   @@son

@@TSS_SIS:
  imul  ecx,3 * 8           // DPL0 - sistem
  add ecx,(AYRILMIS_SECICISAYISI * 8)
  mov   @@SECICI,cx

@@son:

  // �al��an g�revin se�ici (selector) yazma�lar�n� eski konumuna geri d�nd�r
  pop   eax
  mov   ds,ax
  mov   es,ax

  // EOI - kesme sonu
  mov   al,$20
  out   PIC1_KOMUT,al

  // �al��an g�revin genel yazma�lar�n� eski konumuna geri d�nd�r
  popfd
  popad

  sti

// i�lemi belirtilen proses'e devret
@@JMPKOD: db  $EA
@@ADRES:  dd  0       // donan�m destekli g�rev de�i�imlerinde ADRES (offset) g�zard� edilir
@@SECICI: dw  0
  iretd
end;

{==============================================================================
  yaz�l�m taraf�ndan g�rev de�i�tirme i�levlerini yerine getirir.
 ==============================================================================}
procedure ElleGorevDegistir; nostackframe; assembler;
asm
  int $20
  ret

  // alttaki kodlar iptal edilebilir mi? test edilecek - 10.11.2019
  cli
  pushad
  pushfd

  mov   eax,CokluGorevBasladi
  cmp   eax,1
  je    @@kontrol1

  // genel yazma�lar� geri y�kle ve i�levden ��k
  popfd
  popad
  sti
  ret

@@kontrol1:

  mov ecx,CalisanGorevSayisi
  cmp ecx,1
  jne @@yenigorev

  popfd
  popad
  sti
  ret

@@yenigorev:

  call  CalistirilacakBirSonrakiGoreviBul
  mov AktifGorev,eax

  // aktif g�revin bellek ba�lang�� adresini al
  mov eax,AktifGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov eax,[esi + TGorev.FBellekBaslangicAdresi]
  mov AktifGorevBellekAdresi,eax

  // g�rev de�i�iklik sayac�n� bir art�r
  mov eax,AktifGorev
  dec eax
  shl eax,2
  mov esi,GorevListesi[eax]
  mov eax,[esi + TGorev.FGorevSayaci]
  inc eax
  mov [esi + TGorev.FGorevSayaci],eax

  cmp   AktifGorev,1
  je    @@TSS_SIS

@@TSS_UYG:
  mov   eax,AktifGorev
  imul  eax,3 * 8
  add eax,(AYRILMIS_SECICISAYISI * 8)
//  add   eax,3
  mov   @@SECICI,ax
  jmp   @@son

@@TSS_SIS:
  mov   eax,AktifGorev
  imul  eax,3 * 8
  add eax,(AYRILMIS_SECICISAYISI * 8)
  mov   @@SECICI,ax

@@son:
  popfd
  popad

@@JMPKOD: db  $EA
@@ADRES:  dd  0
@@SECICI: dw  0
  sti
  ret
end;

end.
