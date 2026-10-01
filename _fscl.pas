{$MODE OBJFPC}

unit _fscl;

interface

uses
  io, draw, _types, _util, _font;

type
  TFileScroll = class(TGUI)
    const
      _s_line         = 4;
      _l_line         = 12;
      _inside_marging = 2;
      _scroll_xm      = 4;
      _files_window_m = 10;
      _scroll_ym      = 144;

    var
      _show         : Boolean;
      _files        : Word;
      _files_pos_inx: Word;
      _pages        : Word;            // pages of _files_window_m files
      _cube_y       : array of Word;   // integer math: Real needs an 8087
      _cube_ym      : Byte;
      _pre_inx      : Word; 

    constructor Create(x, y, files: Word);

    function IsUpClick(y: Word): Boolean;
    function IsDownClick(y: Word): Boolean;
    
    procedure Draw;
    procedure CubeReDraw;
    function Action(x, y: Word): ShortInt;
    function GetScrollLengthYM(posY : Byte): Byte;

    procedure DrawScrollButton(isUp: Boolean);
    procedure DrawScrollButtonArrow(isUp: Boolean);
    procedure DrawScrollButtonArrows;
    procedure DrawScrollLine;
  end;


implementation

  constructor TFileScroll.Create(x, y, files: Word);
    var
      _i : Byte;

    begin
      _show := files > _files_window_m;

      if files <= _files_window_m then 
        exit;

      _x := x;
      _y := y;
      _xm := x + _l_line;
      _ym := y + _scroll_ym + _l_line;

      _files := files;
      _files_pos_inx := 0;
      _pre_inx := 0;

      _pages := (files div _files_window_m) + 1;
      setLength(_cube_y, _pages);
      _cube_ym := _scroll_ym div _pages;
      
        
      if _cube_ym <= 1 then
        _cube_ym := 2;

      // = trunc(_y + _l_line + _scroll_ym / _pages * _i)
      for _i := 0 to _pages - 1 do
        _cube_y[_i] := _y + _l_line + (Word(_scroll_ym) * _i) div _pages;

    end;

  // // // // // // // // //

  function TFileScroll.IsUpClick(y: Word): Boolean;
    begin
      Result := (_files_pos_inx > 0) and btwn(y, _y, _y + _l_line);
    end;

  // // // // // // // // //

  function TFileScroll.IsDownClick(y: Word): Boolean;
    begin
      Result := (_files_pos_inx < _pages - 1) and btwn(y, _ym - _l_line, _ym);
    end;

  // // // // // // // // // 

  procedure TFileScroll.DrawScrollButton(isUp: Boolean);
    var
      __y : Byte;
    begin
      __y := specialize IfElse<Byte>(isUp, _scroll_ym, 0);

      Rectangle(_x, _y + __y, _x + _l_line, _y + __y + _l_line, 7);
      Line(_x + _s_line, _y + __y, _x + _s_line + _s_line, _y + __y, 8);
      Line(_x + _s_line, _y + __y + _l_line, _x + _s_line + _s_line, _y + __y + _l_line, 8);
      Line(_x, _y + __y + _s_line, _x, _y + __y + _s_line + _s_line, 8);
      Line(_x + _l_line, _y + __y + _s_line, _x + _l_line, _y + __y + _s_line + _s_line, 8);
    end;

  // // // // // // // // //

  procedure TFileScroll.DrawScrollButtonArrow(isUp: Boolean);
    var __y : Word;

    begin
      if (isUp = True) then
        begin
          FilledSquare(_x + 1, _y + 1, _l_line - 2, 8, 8);
          if (_files_pos_inx > 0) then
            begin
              Rectangle(_x + 5, _y + 4, _x + 7, _y + 7, 7);
              Rectangle(_x + 4, _y + 7, _x + 8, _y + 8, 7);
              Rectangle(_x + 3, _y + 9, _x + 9, _y + 10, 7);
            end;
        end
      else if (isUp = False) then
        begin
          FilledSquare(_x + 1, _ym - _l_line + 1, _l_line - 2, 8, 8);
          if (_files_pos_inx < _pages - 1) then
            begin
              __y := _y + _scroll_ym + _l_line;
              Rectangle(_x + 5, __y - 4, _x + 7, __y - 7, 7);
              Rectangle(_x + 4, __y - 7, _x + 8, __y - 8, 7);
              Rectangle(_x + 3, __y - 9, _x + 9, __y - 10, 7);            
            end;
        end;
    end;

  procedure TFileScroll.DrawScrollButtonArrows;
    begin
      DrawScrollButtonArrow(true);
      DrawScrollButtonArrow(false);
    end;

  // // // // // // // // //

  procedure TFileScroll.DrawScrollLine;
    begin
      FilledRectangle(_x + _s_line, _y + _l_line + 1, _xm - _s_line, _ym - _l_line - 1, 0, 0);
    end;

  // // // // // // // // //

  function TFileScroll.GetScrollLengthYM(posY : Byte): Byte;
    var
      _v1, _v2 : Byte;
    begin
      _v1 := posY + _cube_ym;
      _v2 := _ym - _l_line;
      Result := specialize IfElse<Byte>(_v1 < _v2, _v1, _v2);
    end;

  // // // // // // // // //

  procedure TFileScroll.CubeReDraw;
    var
      _ys : Byte;
    begin
      _ys := _cube_y[_pre_inx];
      FilledRectangle(_x + _s_line + 1, _ys, _xm - _s_line - 1, GetScrollLengthYM(_ys),  0, 0);

      _ys := _cube_y[_files_pos_inx];
      FilledRectangle(_x + _s_line + 1, _ys, _xm - _s_line - 1, GetScrollLengthYM(_ys),  8, 8);
    end;

  // // // // // // // // //

  procedure TFileScroll.Draw;
    begin
      if _show then
        begin
          DrawScrollButton(false);
          DrawScrollButton(true);
          DrawScrollButtonArrows;

          DrawScrollLine;
          CubeReDraw;
        end;
    end;

  // // // // // // // // //

  function TFileScroll.Action(x, y: Word): ShortInt;
    begin
      if _show and IsClick(x, y) and (IsUpClick(y) or IsDownClick(y)) then
        begin
          if IsUpClick(y) then
            begin
              dec(_files_pos_inx);
              CubeReDraw;
              if (_pre_inx <> _files_pos_inx) and (_files_pos_inx <= 0) then
                DrawScrollButtonArrows;
            end;

          if IsDownClick(y) then
            begin
              inc(_files_pos_inx);
              CubeReDraw;
              if (_pre_inx <> _files_pos_inx) and (_files_pos_inx >= _pages - 1) then
                DrawScrollButtonArrows;
            end;

            _pre_inx := _files_pos_inx;
            exit(_files_pos_inx);
        end
      
      else
        exit(-1);
    end;

  // // // // // // // // //


end.