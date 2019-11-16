{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_cizim.pas
  Dosya İşlevi: grafiksel ekrana çizim işlevlerini içerir

  Güncelleme Tarihi: 08/10/2019

 ==============================================================================}
{$mode objfpc}
unit k_cizim;

interface

uses paylasim;

function CizimCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses gorselnesne, genel;

{==============================================================================
  görsel nesne çizim kesmelerini içerir
 ==============================================================================}
function CizimCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Pencere: PGorselNesne;
  _Alan: TAlan;
  _Islev: TSayi4;
  _A1, _B1, _A2, _B2,
  _YariCap: TISayi4;
begin

  // işlev no
  _Islev := (IslevNo and $FF);

  // nesneye nokta (pixel) yazma işlemi
  if(_Islev = 1) then
  begin

    // nesneyi kontrol et
    _Pencere := _Pencere^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntPencere);
    if(_Pencere = nil) then Exit;

    _Alan := _Pencere^.CizimAlaniniAl(_Pencere^.Kimlik);
    _A1 := PISayi4(Degiskenler + 04)^ + _Alan.A1;
    _B1 := PISayi4(Degiskenler + 08)^ + _Alan.B1;

    // belirtilen koordinatı işaretle
    GEkranKartSurucusu.NoktaYaz(_Pencere, _A1, _B1, PRenk(Degiskenler + 12)^, True);

    // başarı kodunu geri döndür
    Result := 1;
  end

  // dikdörtgen çiz
  else if(_Islev = 2) then
  begin

    // nesneyi kontrol et
    _Pencere := _Pencere^.NesneTipiniKontrolEt(PKimlik(Degiskenler + 00)^, gntPencere);
    if(_Pencere = nil) then Exit;

    _Alan := _Pencere^.CizimAlaniniAl(PKimlik(Degiskenler + 00)^);
    _A1 := PISayi4(Degiskenler + 04)^ + _Alan.A1;
    _B1 := PISayi4(Degiskenler + 08)^ + _Alan.B1;
    _A2 := PISayi4(Degiskenler + 12)^ + _A1;
    _B2 := PISayi4(Degiskenler + 16)^ + _B1;

    if(PBoolean(Degiskenler + 24)^) then
    begin

      _Pencere^.DikdortgenDoldur(_Pencere, _A1, _B1, _A2, _B2, PRenk(Degiskenler + 20)^,
        PRenk(Degiskenler + 20)^);

      Result := 1;
    end
    else
    begin

      _Pencere^.Dikdortgen(_Pencere, _A1, _B1, _A2, _B2, PRenk(Degiskenler + 20)^);

      Result := 1;
    end;
  end

  // çizgi çiz
  else if(_Islev = 3) then
  begin

    // nesneyi kontrol et
    _Pencere := _Pencere^.NesneTipiniKontrolEt(PKimlik(Degiskenler)^, gntPencere);
    if(_Pencere = nil) then Exit;

    _Alan := _Pencere^.CizimAlaniniAl(PKimlik(Degiskenler + 00)^);
    _A1 := PISayi4(Degiskenler + 04)^ + _Alan.A1;
    _B1 := PISayi4(Degiskenler + 08)^ + _Alan.B1;
    _A2 := PISayi4(Degiskenler + 12)^ + _Alan.A1;
    _B2 := PISayi4(Degiskenler + 16)^ + _Alan.B1;

    _Pencere^.Cizgi(_Pencere, _A1, _B1, _A2, _B2, PRenk(Degiskenler + 20)^);
  end

  // daire çiz
  else if(_Islev = 4) then
  begin

    // nesneyi kontrol et
    _Pencere := _Pencere^.NesneTipiniKontrolEt(PKimlik(Degiskenler)^, gntPencere);
    if(_Pencere = nil) then Exit;

    _Alan := _Pencere^.CizimAlaniniAl(PKimlik(Degiskenler + 00)^);
    _A1 := PISayi4(Degiskenler + 04)^ + _Alan.A1;
    _B1 := PISayi4(Degiskenler + 08)^ + _Alan.B1;
    _YariCap := PISayi4(Degiskenler + 12)^;

    if(PBoolean(Degiskenler + 20)^) then
    begin

      _Pencere^.DaireDoldur(_Pencere, _A1, _B1, _YariCap, PISayi4(Degiskenler + 16)^);
    end
    else
    begin

      _Pencere^.Daire(_A1, _B1, _YariCap, PISayi4(Degiskenler + 16)^);
    end;
  end

  else Result := HATA_ISLEV;
end;

end.
