{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
{$INLINE ON}

// Level Grid object.
// Area for placed object of level 
unit _grid;

interface

uses
  _cell, _types, _map, _util;

type
  LevelGrid = object(TGUI)
    const
      _grid_size= 17;

    var
      _xn, _yn: Byte;
      _cells: array[0..14, 0..9] of LevelCell;
      // join neighbouring tonnel cells: only the level grid, not the object column / tools
      _tonnels: Boolean;

    procedure Init(xpos, ypos: Word; xc, yc: Byte; tonnels: Boolean = false);

    procedure Clear;
    procedure Draw;
    procedure DrawCell(x, y: Byte);

    // not inline: every inlined copy adds code
    function GetTypeCell(x, y: Byte): CellType;
    procedure SetTypeCell(x, y: Byte; t: CellType);

    function GetClickedCell(x, y: Word): LevelCell;

    function GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte;

    function GetClickedCellType(x, y: Word): CellType;

    procedure SetMap(lvl: PLevel);
    function CellXYMatch(x, y: Byte): Boolean; inline;

    function TonnelsOf(x, y: Byte): TonnelSet;
    procedure UpdateTonnels(x, y: Byte; redraw: Boolean);

  end;

implementation

  const
    // neighbour cell offset by the direction
    TONNEL_DX: array[TonnelDirection.Nord..TonnelDirection.East] of ShortInt = (0, -1, 0, 1);
    TONNEL_DY: array[TonnelDirection.Nord..TonnelDirection.East] of ShortInt = (-1, 0, 1, 0);
    // directions to the same type neighbour that is parallel, not joined
    TONNEL_PARALLEL: array[CellType] of TonnelSet = (
      [], [], [], [],                                   // Field, Gold, Gem, Hole
      [TonnelDirection.Nord, TonnelDirection.South],    // TonnelH
      [TonnelDirection.West, TonnelDirection.East],     // TonnelV
      []);                                              // Error

    /// /// /// /// /// ///

  procedure LevelGrid.Init(xpos, ypos: Word; xc, yc: Byte; tonnels: Boolean = false);
    var
      X, Y: Byte;
      _calcX, _calcY: Word;

    begin
      _x := xpos;
      _y := ypos;
      _tonnels := tonnels;

      _xn := xc - 1;
      _yn := yc - 1;

      // Word(..) keeps the arithmetic 16-bit (an untyped const makes it LongInt/Int64)
      _xm := xpos + Word(xc) * Word(_grid_size);
      _ym := ypos + Word(yc) * Word(_grid_size);

      _calcY := ypos;
      for Y :=0 to _yn do
      begin
        _calcX := xpos;

        for X :=0 to _xn do
          begin
            _cells[X, Y].Init(X, Y, _calcX, _calcY, CellType.Field);
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
          begin
            _cells[X, Y].SetType(CellType.Field);
            _cells[X, Y]._tonnel := [];
          end;
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
    var
      _t : CellType;
      _td : TonnelDirection;

    begin
      if NOT CellXYMatch(x, y) then exit;
      
      _t := _cells[x, y].GetType;
      _cells[x, y].SetType(t);

      // TonnelH <-> TonnelV changes the joins too: parallel tonnels are not joined
      if (NOT _tonnels) OR (_t = t) then exit;

      // the cell itself is drawn by the caller (DrawCell)
      _cells[x, y]._tonnel := TonnelsOf(x, y);
      for _td := TonnelDirection.Nord to TonnelDirection.East do
        UpdateTonnels(Byte(x + TONNEL_DX[_td]), Byte(y + TONNEL_DY[_td]), false);
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetTypeCell(x, y: Byte): CellType;
    begin
      if CellXYMatch(x, y) then
        Result := _cells[x, y].GetType
      else
        Result := CellType.Error;
    end;

    /// /// /// /// /// ///

  // cell index by screen coordinate, clamped to 0..lim
  function LevelGrid.GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte;
    var
      _c : Word;

    begin
      if mouse_coord <= start_coord then exit(0);

      _c := Word(mouse_coord - start_coord) div _grid_size;
      Result := specialize IfElse<Byte>(_c > lim, lim, _c);
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
  
  
    procedure LevelGrid.SetMap(lvl : PLevel);
      var
        x, y: Byte;
        t: CellType;
        changed: array[0..14, 0..9] of Boolean;

      begin
        if lvl = nil then exit;

        for y := 0 to 9 do
          for x := 0 to 14 do
            begin
              t := lvl^.GetType(x, y);
              changed[x, y] := _cells[x, y].GetType <> t;
              _cells[x, y].SetType(t);
            end;

        // tonnels only after all the types: they depend on the neighbours
        for y := 0 to 9 do
          for x := 0 to 14 do
            UpdateTonnels(x, y, changed[x, y]);
      end;

    /// /// /// /// /// ///

    // Parallel tonnels side by side are not joined: TonnelV | TonnelV, TonnelH over TonnelH
    function LevelGrid.TonnelsOf(x, y: Byte): TonnelSet;
      var
        t, nt: CellType;
        td: TonnelDirection;

      begin
        Result := [];
        t := GetTypeCell(x, y);
        if NOT (_tonnels AND IsItTonnelCell(t)) then exit;

        for td := TonnelDirection.Nord to TonnelDirection.East do
          begin
            // Byte(..): 0 - 1 -> 255, it is out of the grid
            nt := GetTypeCell(Byte(x + TONNEL_DX[td]), Byte(y + TONNEL_DY[td]));
            if IsItTonnelCell(nt) AND NOT ((t = nt) AND (td in TONNEL_PARALLEL[t])) then
              Include(Result, td);
          end;
      end;

    /// /// /// /// /// ///

    // recalculates the cell tonnels, redraws the cell if they are changed or redraw is set
    procedure LevelGrid.UpdateTonnels(x, y: Byte; redraw: Boolean);
      var
        ts: TonnelSet;

      begin
        if NOT CellXYMatch(x, y) then exit;

        ts := TonnelsOf(x, y);
        if redraw OR (ts <> _cells[x, y]._tonnel) then
          begin
            _cells[x, y]._tonnel := ts;
            _cells[x, y].Draw;
          end;
      end;

    /// /// /// /// /// ///    


end.
