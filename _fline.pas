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
      _inside_marging   = 2;
      _x_line           = 99;
      _h_line           = 5;
      _v_line           = 12;
      _name_ext         = '.DLF';

      var
        _file_name : TFileName12;

    constructor Create(x, y: Word; const file_name: ShortString);
    procedure Draw;
    procedure Draw(edit: Boolean);
    procedure Hide;
    procedure Select(isSelect: Boolean);
    procedure SetName(const f_name: ShortString);
    procedure EditName;
    function GetName: ShortString;

  end;

implementation

  function ValidLetter(k: Word): Boolean;
    begin
      Result := btwn(k, 48, 57) OR btwn(k, 65, 90) OR btwn(k, 97, 122) OR (pos(chr(k), _letters) > 0);
    end;

  // // // TFileLine // // //

  constructor TFileLine.Create(x, y: Word; const file_name: ShortString);
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

  procedure TFileLine.SetName(const f_name: ShortString);
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
      _fy, _o, _oe: Word;

    begin
      Rectangle(_x, _y, _x + _h_line, _ym, 7);
      Line(_x + _h_line, _y + 1, _x + _h_line, _ym - 1, 8);

      Rectangle(_xm - _h_line, _y, _xm, _ym, 7);
      Line(_xm - _h_line, _y + 1, _xm - _h_line, _ym - 1, 8);

      FilledRectangle(_x + 1, _y + 1, _xm - 1, _ym - 1, 8, 8);

      // edit mode: black dot on every screen offset divisible by 6,
      // one division per line instead of one per pixel
      if edit then
        for _fy := _y + 1 to _ym - 1 do
          begin
            _o  := LineOffset[_fy] + _x + 1;
            _oe := LineOffset[_fy] + _xm - 1;
            inc(_o, (6 - _o mod 6) mod 6);
            while _o <= _oe do
              begin
                PutPixelOffset(_o, 0);
                inc(_o, 6);
              end;
          end;

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
        SetName(_name_ext);
      
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
                SetName(_s + _name_ext);
                Draw(true);
              end
            else if ValidLetter(_k) AND (_l < 12) then
              begin
                _s := copy(_file_name, 0, _l - 4) + chr(_k);
                SetName(_s + _name_ext);
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