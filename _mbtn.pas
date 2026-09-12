{$MODE OBJFPC}

unit _mbtn;

interface

uses
  _font, _util, draw;

type
  TModalButton = class
    const
      _ym : Byte = 14;

    var
      _x, _y: Word;
      _xm: Byte;
      _txt: ShortString;

    constructor Create(x, y: Word; txt: ShortString);
    constructor Create(x, y: Word; minx: Byte; txt: ShortString);
    procedure Draw; 
    function IsClick(x, y: Word): Boolean;
  
  end;


implementation

    constructor TModalButton.Create(x, y: Word; txt: ShortString);
      begin
        Create(x, y, 0, txt);
      end;

    constructor TModalButton.Create(x, y: Word; minx: Byte; txt: ShortString);
      begin
        _x := x;
        _y := y;
        _txt := txt;

        _xm := (length(txt) + 1) * 8;

        if _xm < minx then
          _xm := minx;
      end;

    procedure TModalButton.Draw;
      begin
        Rectangle(_x, _y, _x + _xm, _y + _ym, 0);
        FilledRectangle(_x + 1, _y + 1, _x + _xm - 1, _y + _ym - 1, 8, 0);
        DrawString(_x + ((_xm div 2) - (length(_txt) * 4)), _y + 3, _txt);
      end;

    function TModalButton.IsClick(x, y: Word): Boolean;
      begin
        Result := btwn(x, _x, _x + _xm) and btwn(y, _y, _y + _ym);
      end;
 
end.