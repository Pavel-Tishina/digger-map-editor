{$MODE OBJFPC}

unit _fline;

interface

uses
  io, draw, _types, _util, _font;

const
  _letters        : ShortString = '-_+![]()';

type
  TFileLine = class(TGUI)
    const
      _inside_marging   : Byte = 2;
      _x_line           : Byte = 99;
      _h_line           : Byte = 5;
      _v_line           : Byte = 12;
      _text             : ShortString = '.PIC';

      var
        _file_name : ShortString;

    constructor Create(x, y: Word; file_name: ShortString);
    procedure Draw;
    procedure Draw(edit: Boolean);
    procedure Hide;
    procedure Select(isSelect: Boolean);
    procedure SetName(f_name: ShortString);
    procedure EditName;
    function GetName: ShortString;

  end;

implementation

  function ValidLetter(k: Word): Boolean;
    begin
      Result := btwn(k, 48, 57) OR btwn(k, 65, 90) OR btwn(k, 97, 122) OR (pos(chr(k), _letters) > 0);
    end;

  // // // TFileLine // // //

  constructor TFileLine.Create(x, y: Word; file_name: ShortString);
    begin
      _x := x;
      _y := y;
      _xm := x + _x_line;
      _ym := y + _v_line;
      _file_name := file_name;
    end;

  // // // // // // // // //  

  function TFileLine.GetName: ShortString;
    begin
      Result := _file_name;
    end;

  // // // // // // // // //

  procedure TFileLine.SetName(f_name: ShortString);
    begin
      _file_name := f_name;
    end;

  // // // // // // // // //

  procedure TFileLine.Draw;
    begin
      Draw(false);
    end;

  // // // // // // // // //

  procedure TFileLine.Draw(edit: Boolean);
    var
      _fx, _fy, _coord: Word;
      _c : Byte;

    begin
      Rectangle(_x, _y, _x + _h_line, _ym, 7);
      Line(_x + _h_line, _y + 1, _x + _h_line, _ym - 1, 8);

      Rectangle(_xm - _h_line, _y, _xm, _ym, 7);
      Line(_xm - _h_line, _y + 1, _xm - _h_line, _ym - 1, 8);

      if edit then
        begin
          for _fy := _y + 1 to _ym - 1 do
            for _fx := _x + 1 to _xm - 1 do
              begin 
                _coord := LineOffset[_fy] + _fx;
                _c := specialize IfElse<Byte>((_coord mod 6 = 0), 0, 8);

                PutPixelOffset(_coord, _c);
              end;
        end
      else
        FilledRectangle(_x + 1, _y + 1, _xm - 1, _ym - 1, 8, 8);
        // FilledRectangle(_x, _y, _xm, _ym, 8, 8);

      DrawString(_x + _inside_marging, _y + _inside_marging, _file_name);
    end;

  // // // // // // // // //

  procedure TFileLine.Hide;
    begin
      FilledRectangle(_x, _y, _x + _x_line, _y + _v_line, 8, 8);
    end;

  // // // // // // // // //

  procedure TFileLine.Select(isSelect: Boolean);
    begin
      if isSelect then
        Rectangle(_x, _y, _x + _x_line, _y + _v_line, 15)
      else
        begin
          // Draw;
          Rectangle(_x, _y, _xm, _ym, 7);
          Line(_x + _h_line, _y, _xm - _h_line, _y, 8);
          Line(_x + _h_line, _ym, _xm - _h_line, _ym, 8);
        end;
    end;

  // // // // // // // // //  
  
  procedure TFileLine.EditName;
    var
      _s : ShortString;
      _l : Byte;
      _k : Word;
      _e : Boolean;

    begin
      if length(_file_name) = 0 then
        SetName('.PIC');
      
      Draw(true);
      _e := True;
      repeat
        if KeyPressed then
          begin
            _l := length(_file_name);
            _k := ReadKey;
            if (_k = 8) AND (_l > 4) then
              begin
                _s := copy(_file_name, 0, _l - 5);
                SetName(_s + '.PIC');
                Draw(true);
              end
            else if ValidLetter(_k) AND (_l < 12) then
              begin
                _s := copy(_file_name, 0, _l - 4) + chr(_k);
                SetName(_s + '.PIC');
                Draw(true);
              end
            else if ((_k = 10) OR (_k = 13) OR (_k = 27)) AND (_l > 4) then
              begin
                Draw;
                _e := False;
              end;
          end;

      until (NOT _e);
    end;

  // // // // // // // // //  

end.