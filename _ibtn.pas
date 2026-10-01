{$MODE OBJFPC}

unit _ibtn;

interface

uses
  draw, _types, _util, io, video, _ag;

type
  IconButton = class(TGUI)
    const
      _s = 19;

    var
      _t : IconButtonType;
      _img : ArchiveGraphicFile;
      _background: ByteData;

    constructor Init(x, y: Word; t: IconButtonType);
    
    procedure Draw;
    procedure Hide;
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
      
      setLength(_background, 0);
    end;
  
  // // // // // // // //

  procedure IconButton.Draw;
    begin
      if (_t <> IconButtonType.Cross) then
        begin
          setLength(_background, (_s + 1) * (_s + 1));
          SaveRect(LineOffset[_y] + _x, _s + 1, _s + 1, @_background[0]);

          FilledSquare(_x, _y, _s, 7, 0);          
          _img.Draw2(_x + 1, _y + 1); // TODO !!!! Hallo! Ich habe an dieser Zeile aufgehört.
        end

      else
        begin
          FilledSquare(_x, _y, _s, 7, 0);
          Line(_x + 2, _y + 2, _xm - 2, _ym - 2, 5);
          Line(_x + 2, _ym - 2, _xm - 2, _y + 2, 5);
        end;

    end;

  procedure IconButton.Hide;
    begin
      if (_t = IconButtonType.Cross) OR (length(_background) = 0) then exit;

      RestoreRect(@_background[0], LineOffset[_y] + _x, _s + 1, _s + 1);
      setLength(_background, 0);
    end;

end.