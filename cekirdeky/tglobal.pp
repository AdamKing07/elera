unit tglobal;

interface

var
  GeneralVal: array[0..10] of Char;

function GetLength(s: PChar): LongInt;

implementation

uses screen, convert;

function GetLength(s: PChar): LongInt;
var
  i: Word;
begin

  i := 0;
  while (s[i] <> #0) do
  begin

    Inc(i);
  end;
  Result := i;
end;

end.
