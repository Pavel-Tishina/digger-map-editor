{$MODE OBJFPC}
{$INLINE ON}

unit _grid;

interface

uses
  _cell, draw, _types, _map;

type
  Cells = array of array of LevelCell;


type
  LevelGrid = class(TGUI)
    const
      _grid_size= 17;

    var
      _xn, _yn: Byte; 
      _offset: Word;
      _cells: Cells;

    constructor Init(xpos, ypos: Word; xc, yc: Byte);

    procedure Clear;
    procedure Draw;
    procedure DrawCell(x, y: Byte);

    function GetTypeCell(x, y: Byte): CellType; inline;
    procedure SetTypeCell(x, y: Byte; t: CellType);

    function GetClickedCell(x, y: Word): LevelCell; inline;

    function GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte; inline;
    
    function GetClickedCellType(x, y: Word): CellType;
    procedure SetClickedCellType(x, y: Word; t : CellType);

    procedure SetMap(lvl: Level);
    function CellXYMatch(x, y: Byte): Boolean; inline;
     
  end;

implementation

    /// /// /// /// /// ///

  constructor LevelGrid.Init(xpos, ypos: Word; xc, yc: Byte);
    var
      X, Y: Byte;
      _calcX, _calcY: Word;

    begin
      _x := xpos;
      _y := ypos;

      _xn := xc - 1;
      _yn := yc - 1;

      // Word(..) keeps the arithmetic 16-bit (an untyped const makes it LongInt/Int64)
      _xm := xpos + Word(xc) * Word(_grid_size);
      _ym := ypos + Word(yc) * Word(_grid_size);

      setLength(_cells, xc, yc);

      _calcY := ypos;
      for Y :=0 to _yn do
      begin
        _calcX := xpos;

        for X :=0 to _xn do
          begin
            _cells[X, Y] := LevelCell.Init(X, Y, _calcX, _calcY, CellType.Field);
            inc(_calcX, _grid_size);
          end;

        inc(_calcY, _grid_size);
      end;
    end;

    /// /// /// /// /// ///

    // x, y are Byte - no need to check the lower bound 0
    function LevelGrid.CellXYMatch(x, y: Byte): Boolean;
      begin
        Result := (x <= _xn) AND (y <= _yn);
      end;

    /// /// /// /// /// ///

  // all cells -> Field, without redraw
  procedure LevelGrid.Clear;
    var
      X, Y: Byte;

    begin
      for Y :=0 to _yn do
        for X :=0 to _xn do
          _cells[X, Y].SetType(CellType.Field);
    end;

    /// /// /// /// /// ///

  procedure LevelGrid.Draw;
    var
      X, Y: Byte;

    begin
      for Y :=0 to _yn do
        for X :=0 to _xn do
          _cells[X, Y].Draw;
    end;

    /// /// /// /// /// ///

  procedure LevelGrid.DrawCell(x, y: Byte);
    begin
      if CellXYMatch(x, y) then
        _cells[x, y].Draw;
    end;

    /// /// /// /// /// ///    

  procedure LevelGrid.SetTypeCell(x, y: Byte; t: CellType);
    begin
      if CellXYMatch(x, y) then
        _cells[x, y].SetType(t);
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetTypeCell(x, y: Byte): CellType;
    begin
      // not IfElse: it would call _cells[x, y].GetType before the bounds check
      if CellXYMatch(x, y) then
        Result := _cells[x, y].GetType
      else
        Result := CellType.Error;
    end;

    /// /// /// /// /// ///

  // cell index by screen coordinate, clamped to 0..lim
  // (must be implemented before GetClickedCell to be inlined there)
  function LevelGrid.GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte;
    var
      _c : Word;

    begin
      if mouse_coord <= start_coord then
        exit(0);

      _c := (mouse_coord - start_coord) div _grid_size;

      if _c > lim then
        Result := lim
      else
        Result := _c;
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetClickedCell(x, y: Word): LevelCell;
    begin
      Result := _cells[GetCellCoord(x, _x, _xn), GetCellCoord(y, _y, _yn)];
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetClickedCellType(x, y: Word): CellType;
    begin
      Result := GetClickedCell(x, y).GetType;
    end;
  
    /// /// /// /// /// ///
  
  procedure LevelGrid.SetClickedCellType(x, y: Word; t : CellType);
    var
      _lvl_cell : LevelCell;

    begin
      _lvl_cell := GetClickedCell(x, y);
      
      if (_lvl_cell.GetType <> CellType.Error) then
        SetTypeCell(_lvl_cell.X, _lvl_cell.Y, t);
    end; 

    /// /// /// /// /// ///

    procedure LevelGrid.SetMap(lvl : Level);
    var
      x, y: Byte;
      t: CellType;
      c: LevelCell;

    begin
      if lvl = nil then exit;

      for y := 0 to 9 do
        for x := 0 to 14 do
          begin
            t := lvl.GetType(x, y);
            c := _cells[x, y];
            if c.GetType <> t then
              begin
                c.SetType(t);
                c.Draw;
              end;
          end;
    end;

end.