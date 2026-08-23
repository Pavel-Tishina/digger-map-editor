{$MODE OBJFPC}

unit _ibtn;

interface

uses
  draw, _types, _util, io, video, _ag;

  /// Level ///

type
  IconButton = class
  public
    _s : Byte;
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
      _s := 19;
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
          setLength(_background, _s * _s);
          
          _i := 0;
          for _y := 0 to _img.GetYM do
            begin
              _ycalc := LineOffset[_ypos + 1 + _y];
              for _x := 0 to _img.GetXOffset do
                begin
                  _background[_i] := GetPixelOffset(_ycalc + 1 + _xpos + _x);
                  _i := _i + 1;
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
          _y := 0;
          _x := 0;
          _ycalc := LineOffset[_ypos];
          while (_i < length(_background)) do
            begin
              if (_i >= _img.GetXOffset) then
                begin
                  _x := 0;
                  _y := _y + 1;
                  _ycalc := LineOffset[_ypos + _y];
                end;

              PutPixelOffset(_ycalc + _xpos + _x, _background[_i]);
              _x := _x + 1;
              _i := _i + 1;
            end;
          
            setLength(_background, 0);
        end;
    end;

end.