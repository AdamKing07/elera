{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: k_gorselnesne.pas
  Dosya İşlevi: görsel nesne işlevlerini içerir

  Güncelleme Tarihi: 09/11/2019

 ==============================================================================}
{$mode objfpc}
unit k_gorselnesne;

interface

uses paylasim, gn_masaustu, gn_pencere, gn_dugme, gn_gucdugme, gn_listekutusu,
  gn_menu, gn_defter, gn_islemgostergesi, gn_onaykutusu, gn_giriskutusu, gn_degerdugmesi,
  gn_etiket, gn_durumcubugu, gn_secimdugme, gn_baglanti, gn_resim, gn_listegorunum,
  gn_panel, gn_resimdugme;

const
  MEVCUT_GN_SAYISI = 19;    // görsel nesne sayısı

var
  GorselNesneListesi: array[1..MEVCUT_GN_SAYISI] of TKesmeCagrisi = (
    @MasaustuCagriIslevleri, @PencereCagriIslevleri, @DugmeCagriIslevleri,
    @GucDugmeCagriIslevleri, @ListeKutusuCagriIslevleri, @MenuCagriIslevleri,
    @DefterCagriIslevleri, @IslemGostergesiCagriIslevleri, @IsaretKutusuCagriIslevleri,
    @GirisKutusuCagriIslevleri, @DegerDugmesiCagriIslevleri, @EtiketCagriIslevleri,
    @DurumCubuguCagriIslevleri, @SecimDugmeCagriIslevleri, @BaglantiCagriIslevleri,
    @ResimCagriIslevleri, @ListeGorunumCagriIslevleri, @PanelCagriIslevleri,
    @ResimDugmeCagriIslevleri);

function GorselNesneCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;

implementation

uses gn_islevler;

{==============================================================================
  görsel nesne kesme çağrılarını yönetir
 ==============================================================================}
function GorselNesneCagriIslevleri(IslevNo: TSayi4; Degiskenler: Isaretci): TISayi4;
var
  _Islev: TSayi4;
begin

  _Islev := (IslevNo and $FF);

  if(_Islev >= 1) and (_Islev <= MEVCUT_GN_SAYISI) then

    Result := GorselNesneListesi[_Islev](((IslevNo shr 8) and $FFFF), Degiskenler)
  else if(_Islev = $FF) then
  begin

    Result := GorselNesneIslevCagriIslevleri((IslevNo shr 8) and $FFFF, Degiskenler);
  end

  else Result := HATA_NESNE;
end;

end.
