function _ListeGorunumOlustur(AtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4): TKimlik; assembler;
procedure _ListeGorunumHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _ListeGorunumElemanEkle(AKimlik: TKimlik; ADeger: string); assembler;
function _ListeGorunumSeciliSiraAl(AKimlik: TKimlik): TISayi4; assembler;
procedure _ListeGorunumSeciliYaziAl(AKimlik: TKimlik; AHedefBellek: Isaretci); assembler;
procedure _ListeGorunumTemizle(AKimlik: TKimlik); assembler;
procedure _ListeGorunumBasliklariTemizle(AKimlik: TKimlik); assembler;
procedure _ListeGorunumBaslikEkle(AKimlik: TKimlik; ABaslikDeger: string;
  ABaslikGenisligi: TSayi4); assembler;
