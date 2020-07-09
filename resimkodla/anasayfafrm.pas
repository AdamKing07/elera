unit anasayfafrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls;

type

  { TfrmAnaSayfa }

  TfrmAnaSayfa = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ScrollBox1: TScrollBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  frmAnaSayfa: TfrmAnaSayfa;

implementation

{$R *.lfm}

Function FlipColor(Const AValue:TColor):TColor;
Type F = Record L,M,H,A:Byte; End;
Var
  J:Byte;
Begin
  Result := AValue;
   J := F(Result).L; F(Result).L:= F(Result).H; F(Result).H:=J;
end;

procedure TfrmAnaSayfa.Button1Click(Sender: TObject);
var
  Sol, Ust: Integer;
  s: string;
  Renk: LongWord;
begin

  Memo1.Clear;

  for Ust := 0 to Image1.Height - 1 do
  begin

    for Sol := 0 to Image1.Width - 1 do
    begin

      Renk := FlipColor(Image1.Canvas.Pixels[Sol, Ust]);
      if(CheckBox1.Checked) and (Renk = $FF0000) then Renk := $FFFFFFFF;

      if(Sol = 0) then
        s := Format('($%.8x', [Renk])
      else s += Format(', $%.8x', [Renk]);
    end;

    if(Ust = Image1.Height - 1) then
      s += '));'
    else s += '),';

    Memo1.Lines.Add(s);
  end;
end;

procedure TfrmAnaSayfa.Button2Click(Sender: TObject);
var
  x, y: Integer;
  ColorA, ColorB, Color1: TColor;

  function Gradient(x, y: Integer): TColor;
  var
    d, dx, dy, p: Extended;
    CAR, CAG, CAB, CBR, CBG, CBB: Byte;

  begin

    dx := (Image2.Width / 2) - x;
    dy := (Image2.Height / 2) - y;

    d:= Sqrt(dx*dx+dy*dy);
    p := d/255;

    //if(d < 128) then begin
    RedGreenBlue(ColorA, CAR, CAG, CAB);
    RedGreenBlue(ColorB, CBR, CBG, CBB);

    Result := RGBToColor(Round((CAR + p * (CBR - CAR))),
      Round((CAG + p * (CBG - CAG))),
      Round((CAB + p * (CBB - CAB))));

    //end else Result := clBlack;
  end;
begin

  ColorA := clWhite; // RGBToColor(254, 140, 0);
  ColorB := clRed; //(248, 54, 0);

  for x := 0 to Image2.Width - 1 do
  begin

    for y := 0 to Image2.Height - 1 do
    begin

      Color1 := Gradient(x, y);
      Image2.Canvas.Pixels[x, y] := Color1;
    end;
  end;
end;

procedure TfrmAnaSayfa.Button3Click(Sender: TObject);
begin

  if(OpenDialog1.Execute) then
  begin

    Image1.Picture.LoadFromFile(OpenDialog1.FileName);

  end;
end;

end.

