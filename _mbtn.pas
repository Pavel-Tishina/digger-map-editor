{$MODE OBJFPC}

unit _mbtn;

interface

uses
  _font, _util, draw, _types;

type
  TModalButton = class(TGUI)
    _txt: ShortString;

    constructor Create(x, y: Word; txt: ShortString);
    constructor Create(x, y: Word; minx: Byte; txt: ShortString);
    procedure Draw;

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
        _ym := y + 14;
        _txt := txt;

        _xm := (length(txt) + 1) * 8;
        _xm := _x + (specialize IfElse<Word>(_xm < minx, minx, _xm));
      end;

    procedure TModalButton.Draw;
      begin
        Rectangle(_x, _y, _xm, _ym, 0);
        FilledRectangle(_x + 1, _y + 1, _xm - 1, _ym - 1, 8, 0);
        DrawString(_x + ((_xm - _x) div 2) - (length(_txt) * 4), _y + 3, _txt);
      end;
 
end.