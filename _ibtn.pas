{$MODE OBJFPC}

unit _ibtn;

interface

uses
  draw, _types, _util, io, video, _ag;

type
  IconButton = class(TGUI)
    const
      _s : Byte = 19;

    var
      _t : IconButtonType;
      _img : ArchiveGraphicFile;
      _background: ByteData;

    constructor Init(x, y: Word; t: IconButtonType);

    procedure Click(x, y: Word);
    
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

  procedure IconButton.Click(x, y: Word);
    begin
      if IsClick(x, y) then
        case _t of
          IconButtonType.Cross,
          IconButtonType.ExitApp:
            begin
              SetTextMode;
              CloseApp;
            end;

          IconButtonType.Load:
            begin
              if (length(_background) = 0) then 
                begin
                  writeln('start draw');
                  Draw;
                  writeln('end draw');
                end

               else
                begin
                  writeln('start hide');
                  Hide;
                  writeln('end hide');
                end;

            end;
            
        end;
    end;


  procedure IconButton.Draw;
    var _fx, _fy, _ycalc, _i: Word;

    begin
      if (_t <> IconButtonType.Cross) then
        begin

          setLength(_background, (_s + 1) * (_s + 1));
          
          _i := 0;
          for _fy := _y to _ym do
            for _fx := _x to _xm do
              begin
                _background[_i] := GetPixelOffset(LineOffset[_fy] + _fx);
                inc(_i);
              end;

          
          FilledSquare(_x, _y, _s, 7, 0);          
          _img.Draw(_x + 1, _y + 1); // TODO !!!! Hallo! Ich habe an dieser Zeile aufgehört.
        end

      else
        begin
          FilledSquare(_x, _y, _s, 7, 0);
          Line(_x + 2, _y + 2, _xm - 2, _ym - 2, 5);
          Line(_x + 2, _ym - 2, _xm - 2, _y + 2, 5);
        end;

    end;

  procedure IconButton.Hide;
    var _fx, _fy, _ycalc, _i: Word;
    
    begin
      if (_t = IconButtonType.Cross) then
        exit;

      // if (_t <> IconButtonType.Cross) then
      //   begin
          _i := 0;
          _fy := _y;
          _fx := _x;
          _ycalc := LineOffset[_y];
          while (_i < length(_background)) do
            begin
              PutPixelOffset(_ycalc + _fx, _background[_i]);
              
              if (_fx >= _xm) then
                begin
                  _fx := _x;
                  inc(_fy);
                  _ycalc := LineOffset[_fy];
                end
                else
                  inc(_fx);

              inc(_i);
            end;
          
            setLength(_background, 0);
        // end;
    end;

end.