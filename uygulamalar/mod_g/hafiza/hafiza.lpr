program hafiza;
{==============================================================================

  Kodlayan:
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Program Adı: hafiza.lpr
  Program İşlevi: hafıza güçlendirmek için geliştirilmiş uygulama

  Güncelleme Tarihi: 15/05/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses gorev, gn_pencere, gn_dugme, gn_etiket;

const
  ProgramAdi: string = 'Hafıza';

var
  Gorev0: TGorev;
  Pencere0: TPencere;
  Durum: TEtiket;
  Dugmeler: array[0..15] of TDugme;
  SeciliDugme1, SeciliDugme2: PDugme;
  OlayKayit: TOlayKayit;
  CiftDegerDizisi: array[1..8] of TSayi4;     // her 2 düğmeye dağıtılan tek (eş) değerler
  BulunanCiftSayisi, TiklamaSayisi,
  ToplamTiklamaSayisi, i: TSayi4;

// çift değer dizilerinden bir adet değer geri döndürür
function CiftDegerDegeriAl: TSayi4;
var
  Deger: TSayi4;

  function DegerUret: TSayi4;
  begin
    asm rdtsc end;
  end;
begin

  while True do
  begin

    Deger := DegerUret;
    Deger := (Deger and 7) + 1;

    if(Deger >= 1) and (Deger <= 8) then
    begin

      if(CiftDegerDizisi[Deger] < 2) then
      begin

        Inc(CiftDegerDizisi[Deger]);
        Exit(Deger);
      end;
    end;
  end;
end;

// program ilk değer atamaları
procedure IlkDegerAtamalari;
var
  Sol, Ust,
  i, j, DugmeSayisi: TISayi4;
begin

  ToplamTiklamaSayisi := 0;

  TiklamaSayisi := 0;

  BulunanCiftSayisi := 0;

  Sol := 12;
  Ust := 12;

  for i := 1 to 8 do CiftDegerDizisi[i] := 0;

  DugmeSayisi := 0;
  for i := 0 to 3 do
  for j := 0 to 3 do
  begin

    Dugmeler[DugmeSayisi].Olustur(Pencere0.Kimlik, Sol + i * 76, Ust + j * 76, 74, 74, '?');
    Dugmeler[DugmeSayisi].Etiket := CiftDegerDegeriAl;
    Dugmeler[DugmeSayisi].Goster;

    Inc(DugmeSayisi);
  end;

  Durum.Degistir('Tıklama Sayısı: 0');
end;

// kimliğin karşılığı olan düğmeyi bulur
function DugmeAl(AKimlik: TKimlik): PDugme;
var
  i: TSayi4;
begin

  for i := 0 to 15 do
  begin

    if(Dugmeler[i].Kimlik = AKimlik) then Exit(@Dugmeler[i]);
  end;

  Exit(nil);
end;

begin

  Pencere0.Olustur(-1, 100, 100, 335, 385, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere0.Kimlik < 0) then Gorev0.Sonlandir(-1);

  Durum.Olustur(Pencere0.Kimlik, 92, 330, RENK_LACIVERT, 'Tıklama Sayısı: 0  ');
  Durum.Goster;

  IlkDegerAtamalari;

  Pencere0.Goster;

  repeat

    Gorev0.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      Inc(TiklamaSayisi);
      Inc(ToplamTiklamaSayisi);

      Durum.Degistir('Tıklama Sayısı: ' + IntToStr(ToplamTiklamaSayisi));

      if(TiklamaSayisi = 1) then
      begin

        SeciliDugme1 := DugmeAl(OlayKayit.Kimlik);
        if not(SeciliDugme1 = nil) then SeciliDugme1^.BaslikDegistir(IntToStr(SeciliDugme1^.Etiket));
      end

      else if(TiklamaSayisi = 2) then
      begin

        SeciliDugme2 := DugmeAl(OlayKayit.Kimlik);

        // 1. ve 2. düğme aynı mı?
        if(SeciliDugme1^.Kimlik = SeciliDugme2^.Kimlik) then
        begin

          SeciliDugme1^.BaslikDegistir('?');
        end
        else
        begin

          if(SeciliDugme1^.Etiket = SeciliDugme2^.Etiket) then
          begin

            SeciliDugme2^.BaslikDegistir(IntToStr(SeciliDugme2^.Etiket));

            SeciliDugme1^.Gizle;
            SeciliDugme2^.Gizle;

            Inc(BulunanCiftSayisi);
            if(BulunanCiftSayisi = 8) then
            begin

              for i := 0 to 15 do Dugmeler[i].YokEt;

              // oyunu başa döndür
              IlkDegerAtamalari;
            end;
          end
          else
          begin

            SeciliDugme2^.BaslikDegistir(IntToStr(SeciliDugme2^.Etiket));

            Bekle(35);

            SeciliDugme1^.BaslikDegistir('?');
            SeciliDugme2^.BaslikDegistir('?');
          end;
        end;

        TiklamaSayisi := 0;
      end;
    end;
  until (1 = 2);
end.
