program ekryaz1;
{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Program Ad�: ekryaz1.lpr
  Program ��levi: ekrana yaz� yazma test program

  G�ncelleme Tarihi: 10/08/2017

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
begin

asm

@@1:

  // ekrana yaz� yaz
  mov eax,1
  int $35
  jmp @@1

  // program� sonland�.
  {mov eax,$0000020C
  int $34}
end;

end.
