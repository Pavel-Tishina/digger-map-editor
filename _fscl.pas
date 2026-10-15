{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

// File-List scroller object
// Used in FileList object.
// It contains up- and down-button and not clicable scroller line
unit _fscl;

interface

uses
  draw, _types, _util;

type
  TFileScroll = object(TGUI)
    const
      _s_line         = 4;
      _l_line         = 12;
      _files_window_m = 10;
      _scroll_ym      = 144;

    var
      _show         : Boolean;
      _files_pos_inx: Word;
      _pages        : Word;            // pages of _files_window_m files
      _cube_ym      : Byte;
      _pre_inx      : Word; 

    procedure Init(x, y, files: Word);
    function CubeY(inx: Word): Byte;

    function IsUpClick(y: Word): Boolean;
    function IsDownClick(y: Word): Boolean;
    
    procedure Draw;
    procedure CubeReDraw;
    function Action(x, y: Word): ShortInt;
    function GetScrollLengthYM(posY : Byte): Byte;

    procedure DrawScrollButton(scrolling: ScrollType);
    procedure DrawScrollButtonArrow(scrolling: ScrollType);
    procedure DrawScrollButtonArrows;
    procedure DrawScrollLine;
  end;


implementation

  procedure TFileScroll.Init(x, y, files: Word);
    begin
      _show := files > _files_window_m;

      if files <= _files_window_m then 
        exit;

      _x := x;
      _y := y;
      _xm := x + _l_line;
      _ym := y + _scroll_ym + _l_line;

      _files_pos_inx := 0;
      _pre_inx := 0;

      _pages := (files div _files_window_m) + 1;
      _cube_ym := _scroll_ym div _pages;
      
        
      if _cube_ym <= 1 then
        _cube_ym := 2;


    end;

  // // // // // // // // //

  // top of the scroll cube for page inx (integer math: Real needs an 8087)
  function TFileScroll.CubeY(inx: Word): Byte;
    begin
      Result := _y + _l_line + (Word(_scroll_ym) * inx) div _pages;
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

  procedure TFileScroll.DrawScrollButton(scrolling: ScrollType);
    var
      __y : Word;
      _d  : Byte;
    begin
      __y := _y + specialize IfElse<Byte>(scrolling = ScrollType.UP, _scroll_ym, 0);

      Rectangle(_x, __y, _x + _l_line, __y + _l_line, 7);
      // gray marks in the middle of the sides: top and left, then bottom and right
      _d := 0;
      repeat
        Line(_x + _s_line, __y + _d, _x + _s_line + _s_line, __y + _d, 8);
        Line(_x + _d, __y + _s_line, _x + _d, __y + _s_line + _s_line, 8);
        inc(_d, _l_line);
      until _d > _l_line;
    end;

  // // // // // // // // //

  // the down button is the up one mirrored: rows go up from _ym instead of down from _y
  procedure TFileScroll.DrawScrollButtonArrow(scrolling: ScrollType);
    const
      // arrow rectangles: x1, row1, x2, row2; rows are counted from the button's outer edge
      ARROW: array[0..2, 0..3] of Byte = ((5, 4, 7, 7), (4, 7, 8, 8), (3, 9, 9, 10));

    var
      _i : Byte;

    // screen y of the row r of the button
    function RowY(r: Byte): Word;
      begin
        if scrolling = ScrollType.UP then
          Result := _y + r
        else
          Result := _ym - r;
      end;

    begin
      FilledRectangle(_x + 1, RowY(1), _x + _l_line - 1, RowY(_l_line - 1), 8, 8);

      if specialize IfElse<Boolean>(scrolling = ScrollType.UP, _files_pos_inx > 0, _files_pos_inx < _pages - 1) then
        for _i := 0 to High(ARROW) do
          Rectangle(_x + ARROW[_i, 0], RowY(ARROW[_i, 1]), _x + ARROW[_i, 2], RowY(ARROW[_i, 3]), 7);
    end;

  procedure TFileScroll.DrawScrollButtonArrows;
    begin
      DrawScrollButtonArrow(ScrollType.UP);
      DrawScrollButtonArrow(ScrollType.DOWN);
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
      _ys := CubeY(_pre_inx);
      FilledRectangle(_x + _s_line + 1, _ys, _xm - _s_line - 1, GetScrollLengthYM(_ys),  0, 0);

      _ys := CubeY(_files_pos_inx);
      FilledRectangle(_x + _s_line + 1, _ys, _xm - _s_line - 1, GetScrollLengthYM(_ys),  8, 8);
    end;

  // // // // // // // // //

  procedure TFileScroll.Draw;
    begin
      if _show then
        begin
          DrawScrollButton(ScrollType.DOWN);
          DrawScrollButton(ScrollType.UP);
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