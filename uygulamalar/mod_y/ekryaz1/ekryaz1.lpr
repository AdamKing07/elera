program ekryaz1;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: ekryaz1.lpr
  Program Ýþlevi: ekrana yazý yazma test program

  Güncelleme Tarihi: 10/08/2017

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
begin

asm

@@1:

  // ekrana yazý yaz
  mov eax,1
  int $35
  jmp @@1

  // programý sonlandý.
  {mov eax,$0000020C
  int $34}
end;

end.
