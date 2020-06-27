program kmodtest;
{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasýna bakýnýz

  Program Adý: kmodtest.lpr
  Program Ýþlevi: ring3 seviyesi korumalý mod test programý

  Güncelleme Tarihi: 22/06/2020

 ==============================================================================}
{$mode objfpc}
{$asmmode intel}
uses n_gorev, gn_pencere, gn_dugme, gn_baglanti;

const
  ProgramAdi: string = 'Korumalý Mod Test (Ring3)';

var
  Gorev: TGorev;
  Pencere: TPencere;
  bagKomutIN, bagKomutCLI,
  bagKomutJMP, bagKomutMOV: TBaglanti;
  OlayKayit: TOlayKayit;

begin

  Pencere.Olustur(-1, 200, 200, 250, 130, ptIletisim, ProgramAdi, RENK_BEYAZ);
  if(Pencere.Kimlik < 0) then Gorev.Sonlandir(-1);

  bagKomutIN.Olustur(Pencere.Kimlik, 18, 10, $000000, $FF0000, 'in al,$1F0');
  bagKomutIN.Goster;
  bagKomutCLI.Olustur(Pencere.Kimlik, 18, 30, $000000, $FF0000, 'cli');
  bagKomutCLI.Goster;
  bagKomutJMP.Olustur(Pencere.Kimlik, 18, 50, $000000, $FF0000, 'jmp 0x8:0');
  bagKomutJMP.Goster;
  bagKomutMOV.Olustur(Pencere.Kimlik, 18, 70, $000000, $FF0000, 'mov esi,[$FFFFFFFF]');
  bagKomutMOV.Goster;

  Pencere.Goster;

  while True do
  begin

    Gorev.OlayBekle(OlayKayit);
    if(OlayKayit.Olay = FO_TIKLAMA) then
    begin

      if(OlayKayit.Kimlik = bagKomutIN.Kimlik) then
      begin
      asm
        mov   dx,$1F0
        in    al,dx
      end;
      end
      else if(OlayKayit.Kimlik = bagKomutCLI.Kimlik) then
      begin
      asm
        cli
      end;
      end
      else if(OlayKayit.Kimlik = bagKomutJMP.Kimlik) then
      begin
      asm
        db  $EA
        dd  0
        dw  8
      end;
      end
      else if(OlayKayit.Kimlik = bagKomutMOV.Kimlik) then
      begin
      asm
        mov   esi,[$FFFFFFFF]
      end;
      end;
    end;
  end;
end.
