{$MODE OBJFPC}

unit _grid;  

interface

uses
  _cell, draw, _types, _util, _map;

type
  Cells = array of array of LevelCell;


type
  LevelGrid = class
    const
      _grid_size: Byte = 17;

    var
      _xn, _yn: Byte; 
      _offset, _x, _y: Word;
      _cells: Cells;

    constructor Init(xpos, ypos: Word; xc, yc: Byte);
    // destructor Done;

    procedure Draw;
    procedure DrawCell(x, y: Byte);

    function GetTypeCell(x, y: Byte): CellType;
    procedure SetTypeCell(x, y: Byte; t: CellType);

    function Click(x, y: Word): Boolean;
    function GetClickedCell(x, y: Word): LevelCell;

    function GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte;
    
    function GetClickedCellType(x, y: Word): CellType;
    procedure SetClickedCellType(x, y: Word; t : CellType);

    procedure SetMap(lvl: Level);
     
  end;

implementation

    /// /// /// /// /// ///

  constructor LevelGrid.Init(xpos, ypos: Word; xc, yc: Byte);
    var
      X, Y: Byte;
      _calcY: Word;

    begin
      _x := xpos;
      _y := ypos;

      _xn := xc - 1;
      _yn := yc - 1;

      // _cells := [0.. _xn, 0.._yn] of LevelCell;

      setLength(_cells, xc, yc);


      for Y :=0 to _yn do
      begin
        _calcY := ypos + (_grid_size * Y);
       
        for X :=0 to _xn do
          _cells[X, Y] := LevelCell.Init(X, Y, xpos + (_grid_size * X), _calcY, CellType.Field);

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
      if btwn(x, 0, _xn) AND btwn(y, 0, _yn) then
        _cells[x, y].Draw;
    end;

    /// /// /// /// /// ///    

  procedure LevelGrid.SetTypeCell(x, y: Byte; t: CellType);
    begin
      if btwn(x, 0, _xn) AND btwn(y, 0, _yn) then
        _cells[x, y].SetType(t);
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetTypeCell(x, y: Byte): CellType;
    begin
      if btwn(x, 0, _xn) AND btwn(y, 0, _yn) then
        Result := _cells[x, y].GetType
      else
        Result := CellType.Error;
    end;

    /// /// /// /// /// ///    

  function LevelGrid.Click(x, y: Word): Boolean;
    begin
      Click := (btwn(x, _x, _x + Word((_xn + 1) * _grid_size))) AND (btwn(y, _y, _y + Word((_yn + 1) * _grid_size)));
    end;

    /// /// /// /// /// ///

  function LevelGrid.GetClickedCell(x, y: Word): LevelCell;
    var _xxx, _yyy: Byte;

    begin
      if (Click(x, y) = true) then
        begin
          _xxx := GetCellCoord(x, _x, _xn);
          _yyy := GetCellCoord(y, _y, _yn);
          GetClickedCell := _cells[_xxx, _yyy];

        end
      else
        GetClickedCell := LevelCell.Init(0, 0, 0, 0, CellType.Error); // HOW TO DO NULL?
    end;  

    /// /// /// /// /// ///

  function LevelGrid.GetClickedCellType(x, y: Word): CellType;
    var
      _lvl_cell : LevelCell;      

    begin
      _lvl_cell := GetClickedCell(x, y);

      if (_lvl_cell.GetType <> CellType.Error) then
        GetClickedCellType := _lvl_cell.GetType;
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

  function LevelGrid.GetCellCoord(mouse_coord, start_coord: Word; lim : Byte): Byte;
    var
      _i : Byte;
      _c : Word;
    
    begin
      _c := start_coord;
      for _i := 0 to lim do
        begin
          if (btwn(mouse_coord, _c, _c + _grid_size) = true) then
            break;
          
          inc(_c, _grid_size);
        end;

        Result := _i;
    end;

    /// /// /// /// /// ///

    procedure LevelGrid.SetMap(lvl : Level);
    var
      x, y: Byte;

    begin
      for y := 0 to 9 do
        for x := 0 to 14 do
          if _cells[x, y].GetType <> lvl.GetType(x, y) then
            begin
              _cells[x, y].SetType(lvl.GetType(x, y));
              _cells[x, y].Draw;
            end;
    end;

end.