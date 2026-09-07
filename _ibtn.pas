{$MODE OBJFPC}

unit _ibtn;

interface

uses
  draw, _types, _util, io, video, _ag;

  /// Level ///

type
  IconButton = class
    const
      _s : Byte = 19;

    var
      _xpos, _ypos : Word;
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
      _xpos := x;
      _ypos := y;
      _t := t;

      if t <> IconButtonType.Cross then
        _img := ArchiveGraphicFile.Init(IconButtonTypeFileName(t));
      
      setLength(_background, 0);
    end;

  procedure IconButton.Click(x, y: Word);
    begin
      if btwn(x, _xpos, _xpos + _s) AND btwn(y, _ypos, _ypos + _s) then
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
    var _x, _y, _ycalc, _i: Word;

    begin
      if (_t <> IconButtonType.Cross) then
        begin

          setLength(_background, (_s + 1) * (_s + 1));
          
          _i := 0;
          for _y := _ypos to _ypos + _s do
            begin
              _ycalc := LineOffset[_y];
              for _x := _xpos to _xpos + _s do
                begin
                  _background[_i] := GetPixelOffset(_ycalc + _x);
                  inc(_i);
                end;
            end;
          
          FilledSquare(_xpos, _ypos, _s, 7, 0);          
          _img.Draw(_xpos + 1, _ypos + 1); // TODO !!!! Hallo! Ich habe an dieser Zeile aufgehört.
        end;
    end;

  procedure IconButton.Hide;
    var _x, _y, _ycalc, _i: Word;
    
    begin
      if (_t <> IconButtonType.Cross) then
        begin
          _i := 0;
          _y := _ypos;
          _x := _xpos;
          _ycalc := LineOffset[_ypos];
          while (_i < length(_background)) do
            begin
              PutPixelOffset(_ycalc + _x, _background[_i]);
              
              if (_x >= _xpos + _s) then
                begin
                  _x := _xpos;
                  inc(_y);
                  _ycalc := LineOffset[_y];
                end
                else
                  inc(_x);

              inc(_i);
            end;
          
            setLength(_background, 0);
        end;
    end;

end.