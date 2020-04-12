function _DefterOlustur(AAtaKimlik: TKimlik; A1, B1, AGenislik, AYukseklik: TISayi4;
  ADefterRenk, AYaziRenk: TRenk): TKimlik; assembler;
procedure _DefterHizala(AKimlik: TKimlik; AHiza: THiza); assembler;
procedure _DefterGoster(AKimlik: TKimlik); assembler;
procedure _DefterYaziEklePChar(AKimlik: TKimlik; ABellekAdresi: PChar); assembler;
procedure _DefterYaziEkleStr(AKimlik: TKimlik; ADeger: string); assembler;
procedure _DefterTemizle(AKimlik: TKimlik); assembler;
