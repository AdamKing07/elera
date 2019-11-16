{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Dosya Adý: macmsg.pp
  Dosya Ýþlevi: çekirdek mesaj makrolarýný içerir

  Güncelleme Tarihi: 09/08/2017

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

  // eðer sistem mesaj servisi baþladýysa mesjý mesaj servisine gönder
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

  // sayýsal deðeri string'e çevir
  ValBuffer := HexToStr(HexVal, True, Digits);

  MsgBuf := Msg + ValBuffer;

  if(GMessage.ServiceStarted) then

    GMessage.Add(MsgBuf)
  else WriteKernelMsg(Msg);
end;

procedure MSG_S(Msg1, Msg2: string);
begin

  // eðer sistem mesaj servisi baþladýysa mesjý mesaj servisine gönder
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

  // mac adres deðerini string'e çevir
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

  // ip adres deðerini string'e çevir
  IpBuffer := IpToStr(IpAddr);

  MsgBuf := Msg + IpBuffer;

  if(GMessage.ServiceStarted) then

    GMessage.Add(MsgBuf)
  else WriteKernelMsg(Msg);
end;

end.
