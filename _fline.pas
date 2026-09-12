{$MODE OBJFPC}

unit _fline;

interface

uses
  io, draw, _types, _util, _font;

  TFileLine = class
    const
      _inside_marging : Byte = 2;
      _x_line         : Byte = 99;
      _h_line         : Byte = 5;
      _v_line         : Byte = 14;

    var
      _x, _y : Word;
      _file_name : ShortString[12];

    constructor Create(x, y: Word; file_name: ShortString[12]);
    procedure Draw;
    procedure Hide;
    procedure Select(isSelect: Boolean);
    procedure SetName(f_name: ShortString[12]);
    function GetName: ShortString[12];
    function IsClick(x, y: Word): Boolean;

  end;

implementation

  // // // TFileLine // // //

  constructor TFileLine.Create(x, y: Word; file_name: ShortString[12]);
    begin
      _x := x;
      _y := y;
      _file_name := file_name;
    end;

  // // // // // // // // //

  function TFileLine.IsClick(x, y: Word): Boolean;
    begin
      Result := btwn(x, _x, _x + _x_line) and btwn(y, _y, _y + _v_line);
    end;

  // // // // // // // // //  

  function TFileLine.GetName: ShortInt[12];
    begin
      Result := _file_name;
    end;

  // // // // // // // // //

  procedure TFileLine.SetName(f_name: ShortInt[12]);
    begin
      _file_name := f_name;
    end;

  // // // // // // // // //  

  procedure TFileLine.Draw;
    begin
      Rectangle(_x, _y, _x + _h_line, _y + _v_line, 7);
      Line(_x + _h_line, _y + 1, _x + _h_line, _y + _v_line - 1, 8);

      Rectangle(_x + _x_line, _y, _x + _x_line - _h_line, _y + _v_line, 7);
      Line(_x + _x_line - _h_line, _y + 1, _x + _x_line - _h_line, _y + _v_line - 1, 8);

      DrawString(_x + _inside_marging, _y + _inside_marging, _file_name);
    end;

  // // // // // // // // //

  procedure TFileLine.Hide;
    begin
      FilledRectangle(_x, _y, _x + _x_line, _y + _l_line, 7);
    end;

  // // // // // // // // //

  procedure TFileLine.Select(isSelect: Boolean);
    begin
      if isSelect then
        Rectangle(_x, _y, _x + _x_line, _y + _l_line, 15)
      else
        Draw;
    end;

  // // // // // // // // //  

end.