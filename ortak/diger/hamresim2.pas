{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: hamresim2.pas
  Dosya İşlevi: tek bir renk (siyah) değerleriyle kodlanmış, biçimlendirilmemiş
    ham resimleri içerir

  Güncelleme Tarihi: 02/04/2020

 ==============================================================================}
{$mode objfpc}
unit hamresim2;

interface

uses paylasim;

const
  OKUst: array[1..4, 1..7] of Byte = (
    (0, 0, 0, 1, 0, 0, 0),
    (0, 0, 1, 1, 1, 0, 0),
    (0, 1, 1, 1, 1, 1, 0),
    (1, 1, 1, 1, 1, 1, 1));

  OKAlt: array[1..4, 1..7] of Byte = (
    (1, 1, 1, 1, 1, 1, 1),
    (0, 1, 1, 1, 1, 1, 0),
    (0, 0, 1, 1, 1, 0, 0),
    (0, 0, 0, 1, 0, 0, 0));

  OKSag: array[1..7, 1..4] of Byte = (
    (1, 0, 0, 0),
    (1, 1, 0, 0),
    (1, 1, 1, 0),
    (1, 1, 1, 1),
    (1, 1, 1, 0),
    (1, 1, 0, 0),
    (1, 0, 0, 0));

  OKSol: array[1..7, 1..4] of Byte = (
    (0, 0, 0, 1),
    (0, 0, 1, 1),
    (0, 1, 1, 1),
    (1, 1, 1, 1),
    (0, 1, 1, 1),
    (0, 0, 1, 1),
    (0, 0, 0, 1));

implementation

end.
