{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: dns.pas
  Dosya İşlevi: dns protokol istemci işlevlerini yönetir

  Güncelleme Tarihi: 15/10/2019

 ==============================================================================}
{$mode objfpc}
unit dns;

interface

uses paylasim;

const
  DNS_KAYNAK_PORT = 153;
  DNS_HEDEF_PORT  = 53;

procedure DNSIstegiGonder;

implementation

uses genel, baglanti, donusum;

const
  // sorgulanacak DNS adresi
  DNSAdresi: string = 'turkiye.gov.tr';

// DNS isteği gönder
procedure DNSIstegiGonder;
var
  _Baglanti: PBaglanti;
  _DNSPacket: PDNSPaket;
  _B1, _ParcaUzunlukBellek: PSayi1;
  _B2: PSayi2;
  _K: Char;
  i, DNSAdresUzunluk, _ToplamUzunluk: TSayi4;
  _ParcaUzunluk: TSayi1;
begin

  _DNSPacket := GGercekBellek.Ayir(4095);

  // 12 bytelık veri
	_DNSPacket^.IslemKimlik := Takas2(TSayi2($1010));
  _DNSPacket^.Bayrak := Takas2(TSayi2($0100));        // standard sorgu, recursion
  _DNSPacket^.SorguSayisi := Takas2(TSayi2(1));       // 1 sorgu
  _DNSPacket^.YanitSayisi := Takas2(TSayi2(0));
  _DNSPacket^.YetkiSayisi := Takas2(TSayi2(0));
  _DNSPacket^.DigerSayisi := Takas2(TSayi2(0));

  _B1 := @_DNSPacket^.Veriler;
  _ParcaUzunlukBellek := _B1;     // 1 bytelık verinin uzunluğunun adresi
  Inc(_B1);
  _ParcaUzunluk := 0;
  _ToplamUzunluk := 0;

  DNSAdresUzunluk := Length(DNSAdresi);
  for i := 1 to DNSAdresUzunluk do
  begin

    _K := DNSAdresi[i];

    if(_K = '.') then
    begin

      _ParcaUzunlukBellek^ := _ParcaUzunluk;
      _ParcaUzunlukBellek := _B1;
      _ToplamUzunluk += _ParcaUzunluk + 1;
      Inc(_B1);
      _ParcaUzunluk := 0;
    end
    else
    begin

      PChar(_B1)^ := _K;
      Inc(_B1);
      Inc(_ParcaUzunluk);
    end;
  end;
  _ParcaUzunlukBellek^ := _ParcaUzunluk;
  _ToplamUzunluk += _ParcaUzunluk + 1;

  _B1^ := 0;        // sıfır sonlandırma
  Inc(_ToplamUzunluk);

  Inc(_B1);
  _B2 := Isaretci(_B1);
  _B2^ := Takas2(TSayi2($0001));
  Inc(_B2);
  _B2^ := Takas2(TSayi2($0001));

  _Baglanti := GBaglanti^.Olustur(ptUDP, AgBilgisi.DNSSunucusu, DNS_KAYNAK_PORT,
    DNS_HEDEF_PORT);

  _Baglanti^.Yaz(@_DNSPacket[0], 12 + _ToplamUzunluk + 4);

  _Baglanti^.BaglantiyiKes;

  GGercekBellek.YokEt(_DNSPacket, 4095);
end;

end.
