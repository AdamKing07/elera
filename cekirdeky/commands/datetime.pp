{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: datetime.pp
  Dosya İşlevi: tarih ve saat bilgisini görüntüler

  Güncelleme Tarihi: 03/12/2017

 ==============================================================================}
{$mode objfpc}
unit datetime;

interface

procedure ShowTime;
procedure ShowDate;

implementation

uses cmos, convert, tmode;

{==============================================================================
  saat bilgisini görüntüler
 ==============================================================================}
procedure ShowTime;
var
  i: LongWord;
  TimeVal: string;
begin

  Write(#10 + '  Saat: ');
  i := GetTime;
  TimeVal := TimeToStr(i);
  Write(TimeVal);
end;

{==============================================================================
  tarih bilgisini görüntüler
 ==============================================================================}
procedure ShowDate;
var
  i: LongWord;
  DateVal: string;
begin

  Write(#10 + '  Tarih: ');
  i := GetDate;
  DateVal := DateToStr(i);
  Write(DateVal);
end;

end.
