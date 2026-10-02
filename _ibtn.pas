{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _ibtn;

interface

uses
  draw, _types, _ag;

type
  IconButton = class(TGUI)
    const
      _s = 19;

    var
      _t : IconButtonType;
      _img : ArchiveGraphicFile;

    constructor Init(x, y: Word; t: IconButtonType);
    
    procedure Draw;
  end;


implementation

  constructor IconButton.Init(x, y: Word; t: IconButtonType);
    begin
      _x := x;
      _y := y;
      _xm := x + _s;
      _ym := y + _s;
      _t := t;

      if t <> IconButtonType.Cross then
        _img := ArchiveGraphicFile.Init(IconButtonTypeFileName(t));
    end;
  
  // // // // // // // //

  procedure IconButton.Draw;
    begin
      FilledSquare(_x, _y, _s, 7, 0);

      if (_t <> IconButtonType.Cross) then
        _img.Draw2(_x + 1, _y + 1)
      else
        begin
          Line(_x + 2, _y + 2, _xm - 2, _ym - 2, 5);
          Line(_x + 2, _ym - 2, _xm - 2, _y + 2, 5);
        end;
    end;

end.