{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: pci.pas
  Dosya İşlevi: pci yönetim işlevlerini içerir

  Güncelleme Tarihi: 10/10/2019

  Kaynaklar: http://wiki.osdev.org/PCI

 ==============================================================================}
{$mode objfpc}
unit pci;

interface

uses paylasim;

const
  PCI_ADRES = $CF8;
  PCI_VERI  = $CFC;

  USTSINIR_PCI_AYGIT = 170;     // 4096 / (SizeOf(TPCI) = 24) = 170

var
  ToplamPCIAygitSayisi: TISayi4;
  PCIAygitBellekAdresi: array[0..USTSINIR_PCI_AYGIT - 1] of PPCI;

procedure Yukle;
function PCIOku1(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi1;
function PCIOku2(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi2;
function PCIOku4(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi4;
procedure PCIYaz1(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi1);
procedure PCIYaz2(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi2);
procedure PCIYaz4(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi4);

implementation

uses gercekbellek, aygityonetimi, genel, port;

{==============================================================================
  sistemde mevcut pci aygıtlarının ana yükleme işlevlerini içerir
 ==============================================================================}
procedure Yukle;
var
  _PCI: PPCI;
  _BellekAdresi, _PCIAygitBellekAdresi: Isaretci;
  _Yol, _Aygit, _Islev, i, j: TSayi4;
begin

  // mevcut aygıt sayısını sıfırla
  ToplamPCIAygitSayisi := 0;

  // pci aygıtları için bellek talep et (1 blok = 4K)
  _PCIAygitBellekAdresi := GGercekBellek.Ayir(4096);

  // bellek girişlerini pci yapılarıyla eşleştir
  _BellekAdresi := _PCIAygitBellekAdresi;
  for i := 0 to USTSINIR_PCI_AYGIT - 1 do
  begin

    PCIAygitBellekAdresi[i] := _BellekAdresi;
    _BellekAdresi += SizeOf(TPCI);
  end;

  // yol / aygıt / işlev girişlerini sorgula
  for _Yol := 0 to 255 do
  begin

    for _Aygit := 0 to 31 do
    begin

      for _Islev := 0 to 7 do
      begin

        // satıcı / aygıt bilgilerini al
        j := PCIOku4(_Yol, _Aygit, _Islev, 0);
        if((j and $FFFF) <> 0) and ((j and $FFFF) <> $FFFF) then
        begin

          // eğer azami aygıt sayısı aşılmamışsa
          if(ToplamPCIAygitSayisi <= USTSINIR_PCI_AYGIT) then
          begin

            _PCI := PCIAygitBellekAdresi[ToplamPCIAygitSayisi];

            // yol / aygıt / işlev bilgilerini kaydet
            _PCI^.Yol := _Yol;
            _PCI^.Aygit := _Aygit;
            _PCI^.Islev := _Islev;

            // satıcı / aygıt bilgilerini kaydet
            _PCI^.SaticiKimlik := j and $FFFF;
            _PCI^.AygitKimlik := ((j shr 16) and $FFFF);

            // aygıtın türünü al
            j := PCIOku4(_Yol, _Aygit, _Islev, 8);
            _PCI^.SinifKod := (j and $FFFFFF00);

            // başlık (header) tipi
            j := PCIOku1(_Yol, _Aygit, _Islev, $E);
            j := (j and $FF);

            // aygıtı, yüklenecek aygıt listesine ekle
            AygitiSistemeKaydet(PCIAygitBellekAdresi[ToplamPCIAygitSayisi]);

            // aygıt sayısını artır
            Inc(ToplamPCIAygitSayisi);

            // eğer aygıt çok fonksiyonlu değil ise bir sonraki aygıta geç
            if(_Islev = 0) then
            begin

              if((j and $80) = 0) then Break;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{==============================================================================
  belirtilen aygıtın sıra değerinden 1 byte değer okur
 ==============================================================================}
function PCIOku1(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi1;
var
  _Deger: TSayi4;
begin

  //  ASiraNo = bit 2..7, AIslev = bit 8..10
  //  AAygit = bit 11..15, AYol = bit 16..31
  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) + (AIslev shl 8) +
    (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  Result := PortAl1(PCI_VERI)
end;

{==============================================================================
  belirtilen aygıtın sıra değerinden 2 byte değer okur
 ==============================================================================}
function PCIOku2(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi2;
var
  _Deger: TSayi4;
begin

  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) +
    (AIslev shl 8) + (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  Result := PortAl2(PCI_VERI)
end;

{==============================================================================
  belirtilen aygıtın sıra değerinden 4 byte değer okur
 ==============================================================================}
function PCIOku4(AYol, AAygit, AIslev, ASiraNo: TSayi1): TSayi4;
var
  _Deger: TSayi4;
begin

  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) +
    (AIslev shl 8) + (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  Result := PortAl4(PCI_VERI)
end;

{==============================================================================
  belirtilen aygıtın sıra değerine 1 byte değer yazar
 ==============================================================================}
procedure PCIYaz1(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi1);
var
  _Deger: TSayi4;
begin

  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) +
    (AIslev shl 8) + (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  PortYaz1(PCI_VERI, ADeger)
end;

{==============================================================================
  belirtilen aygıtın sıra değerine 2 byte değer yazar
 ==============================================================================}
procedure PCIYaz2(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi2);
var
  _Deger: TSayi4;
begin

  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) +
    (AIslev shl 8) + (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  PortYaz2(PCI_VERI, ADeger)
end;

{==============================================================================
  belirtilen aygıtın sıra değerine 4 byte değer yazar
 ==============================================================================}
procedure PCIYaz4(AYol, AAygit, AIslev, ASiraNo: TSayi1; ADeger: TSayi4);
var
  _Deger: TSayi4;
begin

  _Deger := $80000000 + (AYol shl 16) + (AAygit shl 11) +
    (AIslev shl 8) + (ASiraNo and $FC);

  PortYaz4(PCI_ADRES, _Deger);
  PortYaz4(PCI_VERI, ADeger)
end;

end.
