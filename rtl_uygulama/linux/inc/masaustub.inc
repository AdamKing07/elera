function _MasaustuOlustur(AMasaustuAdi: string): TKimlik;
function _MasaustuGoster(AKimlik: TKimlik): TKimlik;
function _MevcutMasaustuSayisi: TSayi4;
function _AktifMasaustu: TKimlik;
function _MasaustuAktiflestir(AKimlik: TKimlik): Boolean;
procedure _MasaustuGuncelle(AKimlik: TKimlik);
procedure _MasaustuRenginiDegistir(AKimlik: TKimlik; ARenk: TRenk);
procedure _MasaustuResminiDegistir(AKimlik: TKimlik; ADosyaTamYol: string);
