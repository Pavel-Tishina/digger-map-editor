{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _mbtn;

interface

uses
  _font, _util, draw, _types;

type
  TModalButton = object(TGUI)
    _txt: String[16];   // not ShortString: 256 bytes

    procedure Init(x, y: Word; minx: Byte; const txt: ShortString);
    procedure Draw;

  end;


implementation

    procedure TModalButton.Init(x, y: Word; minx: Byte; const txt: ShortString);
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
        DrawString(_x + Word(_xm - _x) div 2 - length(_txt) * 4, _y + 3, _txt);
      end;
 
end.