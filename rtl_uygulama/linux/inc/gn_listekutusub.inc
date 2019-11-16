function _ListeKutusuOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik,
  AYukseklik: TISayi4): TKimlik; assembler;
procedure _ListeKutusuHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _ListeKutusuElemanEkle(AKimlik: TKimlik; AElemanAdi: string); assembler;
procedure _ListeKutusuTemizle(AKimlik: TKimlik); assembler;
function _ListeKutusuSeciliSiraNoAl(AKimlik: TKimlik): TISayi4; assembler;
procedure _ListeKutusuSeciliSiraYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
