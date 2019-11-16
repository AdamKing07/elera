{==============================================================================

  Kodlayan: Fatih KILI�
  Telif Bilgisi: haklar.txt dosyas�na bak�n�z

  Dosya Ad�: macmsg.pp
  Dosya ��levi: �ekirdek mesaj makrolar�n� i�erir

  G�ncelleme Tarihi: 09/08/2017

 ==============================================================================}
{$mode objfpc}
unit macmsg;

interface

uses shared;

procedure MSG_S(Msg: string);
procedure MSG_S(Msg1, Msg2: string);
procedure MSG_SH(Msg: string; HexVal, Digits: LongInt);
procedure MSG_MAC(Msg: string; MacAddr: TMacAddr);
procedure MSG_IP(Msg: string; IpAddr: TIpAddr);

implementation

uses gvars, convert, tmode;

var
  MsgBuf: string;

{==============================================================================
  string mesaj makrosu
 ==============================================================================}
procedure MSG_S(Msg: string);
begin

  // e�er sistem mesaj servisi ba�lad�ysa mesj� mesaj servisine g�nder
  if(GMessage.ServiceStarted) then

    GMessage.Add(Msg)
  else WriteKernelMsg(Msg);
end;

{==============================================================================
  string/hexadesimal mesaj makrosu
 ==============================================================================}
procedure MSG_SH(Msg: string; HexVal, Digits: Integer);
var
  ValBuffer: string[10];
  i: Integer;
begin

  // say�sal de�eri string'e �evir
  ValBuffer := HexToStr(HexVal, True, Digits);

  MsgBuf := Msg + ValBuffer;

  if(GMessage.ServiceStarted) then

    GMessage.Add(MsgBuf)
  else WriteKernelMsg(Msg);
end;

procedure MSG_S(Msg1, Msg2: string);
begin

  // e�er sistem mesaj servisi ba�lad�ysa mesj� mesaj servisine g�nder
  if(GMessage.ServiceStarted) then
  begin

    GMessage.Add(Msg1);
    GMessage.Add(Msg2);
  end
  else
  begin

    WriteKernelMsg(Msg1);
    WriteKernelMsg(Msg2);
  end;
end;

{==============================================================================
  string/mac adres mesaj makrosu
 ==============================================================================}
procedure MSG_MAC(Msg: string; MacAddr: TMacAddr);
var
  MacBuffer: string[17];
  i: Integer;
begin

  // mac adres de�erini string'e �evir
  MacBuffer := MacToStr(MacAddr);

  MsgBuf := Msg + MacBuffer;

  if(GMessage.ServiceStarted) then

    GMessage.Add(MsgBuf)
  else WriteKernelMsg(Msg);
end;

{==============================================================================
  string/mac adres mesaj makrosu
 ==============================================================================}
procedure MSG_IP(Msg: string; IpAddr: TIpAddr);
var
  IpBuffer: string[15];
  i: Integer;
begin

  // ip adres de�erini string'e �evir
  IpBuffer := IpToStr(IpAddr);

  MsgBuf := Msg + IpBuffer;

  if(GMessage.ServiceStarted) then

    GMessage.Add(MsgBuf)
  else WriteKernelMsg(Msg);
end;

end.
