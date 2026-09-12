{$MODE OBJFPC}

unit _fscl;

interface

uses
  io, draw, _types, _util, _font;


  TFileScroll = class
    const
      _s_line         : Byte = 4;
      _l_line         : Byte = 12;
      _inside_marging : Byte = 2;
      _scroll_xm      : Byte = 4;
      _files_window_m : Byte = 10;
      _ym             : Byte = 148;

    var
      _show         : Boolean;
      _x, _y, _files: Word;
      _files_pos_inx: Byte;
      _files_idexes : array of array of Word;
      _cube_y       : array of Real;
      _cube_ym      : Byte;
      _pre_inx      : Byte; 

    constructor Create(x, y, files: Word);

    function IsClick(x, y: Word): Boolean;
    function IsUpClick(y: Word): Boolean;
    function IsDownClick(y: Word): Boolean;
    
    procedure Draw;
    procedure CubeReDraw;
    function Action(x, y: Word): ShortInt;
  end;


implementation

  constructor TFileScroll.Create(x, y, files: Word);
    var
      _i, _j, _c : Byte;
      _n  : Word;
      _r  : Real;

    begin
      _show := files > _files_window_m;

      if files > _files_window_m then
        begin
          _x := x;
          _y := y;
          _files := files;
          _files_pos_inx := 0;
          _pre_inx := 0;

          _n := (files div _files_window_m) + 1;
          setLength(_files_idexes, _n, _files_window_m);
          setLength(_cube_y, _n);
          _c := (_ym div _n) + 1;
          _r := _ym / _n;
          _cube_ym := rnd((_ym / files) * _n);
          if _cube_ym <= 1
             _cube_ym := 2;


          for _i := 0 to length(_files_idexes) - 1 do
            begin
              _cube_y[_i] := _y + _l_line + (_r * _i);
              _n := _i * _files_window_m;
              
              for _j := 0 to _files_window_m - 1 do
                _files_idexes[_i, _i] := _n + _j;
            end;
        end;
    end;

  // // // // // // // // //

  function TFileScroll.IsClick(x, y: Word): Boolean;
    begin
      Result := _show and btwn(x, _x, _x + _l_line) and btwn(y, _y, _y + _ym);
    end;

  // // // // // // // // //

  function TFileScroll.IsUpClick(y: Word): Boolean;
    begin
      Result := (_files_pos_inx > 0) and btwn(y, _y, _y + _l_line);
    end;

  // // // // // // // // //

  function TFileScroll.IsDownClick(y: Word): Boolean;
    begin
      Result := (_files_pos_inx  < length(_files_idexes) - 1) and btwn(y, _y, _y + _l_line);
    end;

  // // // // // // // // // 

  procedure DrawScrollButton(isUp: Boolean);
    var
      __y : Byte;
    begin
      if isUp then
        __y := _ym
      else
        __y := 0;

      Rectangle(_x, _y + __y, _x + _l_line, _y + __y + _l_line, 7);
      Line(_x + _s_line, _y + __y, _x + _s_line + _s_line, _y + __y, 8);
      Line(_x + _s_line, _y + __y + _l_line, _x + _s_line + _s_line, _y + __y + _l_line, 8);
      Line(_x, _y + __y + _s_line, _x, _y + __y + _s_line + _s_line, 8);
      Line(_x + _l_line, _y + __y + _s_line, _x + _l_line, _y + __y + _s_line + _s_line, 8);
    end;

  // // // // // // // // //    

  procedure DrawScrollButtonArrow(isUp: Boolean);
    var
      _q, _i : Short;
      __x, __y : Word;

    begin
      if (isUp = True) and (_files_pos_inx > 0) then
        begin
          Rectangle(_x + 6, _y + 4, _x + 7, _y + 7, 7);
          Rectangle(_x + 5, _y + 7, _x + 8, _y + 8, 7);
          Rectangle(_x + 4, _y + 9, _x + 9, _y + 10, 7);
        end 
      else if (isUp = False) and (_files_pos_inx < length(_files_idexes) - 1) then
        begin
          __y := _y + _ym + _l_line;
          Rectangle(_x + 6, __y - 4, _x + 7, __y - 7, 7);
          Rectangle(_x + 5, __y - 7, _x + 8, __y - 8, 7);
          Rectangle(_x + 4, __y - 9, _x + 9, __y - 10, 7);            
        end;
    end;

  // // // // // // // // //

  procedure DrawScrollLine;
    begin
      FilledRectangle(_x + _s_line, _y + _l_line, _x + _s_line * 2, _y + _l_line + _ym, 0);
    end;

  // // // // // // // // //


  procedure TFileScroll.CubeReDraw;
    var
      __y : Byte;
    begin
      __y := rnd(_cube_y[_pre_inx]);
      Rectangle(_x + _s_line + 1, __y, _x + _s_line + 2, __y + _cube_ym,  0);

      __y := rnd(_cube_y[_files_pos_inx]);
      Rectangle(_x + _s_line + 1, __y, _x + _s_line + 2, __y + _cube_ym,  8);
    end;

  // // // // // // // // //

  procedure TFileScroll.Draw;
    begin
      if _show then
        begin
          DrawScrollButton(false);
          DrawScrollButtonArrow(false);
          DrawScrollButton(true);
          DrawScrollButtonArrow(true);

          DrawScrollLine;
          CubeReDraw;
        end;
    end;

  // // // // // // // // //

  function TFileScroll.Action(x, y: Word): ShortInt;
    var
      _empty : array of Word;
    begin
      if _show and IsClick(x, y) and (IsUpClick(y) or IsDownClick(y)) then
        begin
          if IsUpClick(y) then
            begin
              dec(_files_pos_inx);
              CubeReDraw;
            end;

          if IsDownClick(y) then
            begin
              inc(_files_pos_inx);
              CubeReDraw;
            end;  
            _pre_inx := _files_pos_inx;

            Result := _files_pos_inx;
        end
      
      else
        Result := -1;
    end;

  // // // // // // // // //


end.