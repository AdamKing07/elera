function _FindFirst(const AAramaSuzgec: string; ADosyaOzellik: TSayi2;
  var ADosyaArama: TDosyaArama): TISayi4;
function _FindNext(var ADosyaArama: TDosyaArama): TISayi4;
function _FindClose(var ADosyaArama: TDosyaArama): TISayi4;
procedure _AssignFile(out ADosyaKimlik: TKimlik; const ADosyaAdi: string);
procedure _Reset(ADosyaKimlik: TKimlik);
function _IOResult: TISayi4;
function _EOF(ADosyaKimlik: TKimlik): Boolean;
function _FileSize(ADosyaKimlik: TKimlik): TISayi4;
procedure _FileRead(ADosyaKimlik: TKimlik; AHedefBellek: Isaretci);
procedure _CloseFile(ADosyaKimlik: TKimlik);