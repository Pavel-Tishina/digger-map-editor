{$MODE OBJFPC}

unit _grid;  

interface

uses
  _cell, draw, _types, _util;

type
  Cells = array of array of LevelCell;


type
  LevelGrid = class
  public
    _grid_size, _xn, _yn, _xc, _yc: Byte; 
    _offset, _x, _y: Word;
    _cells: Cells;

    constructor Init(xpos, ypos: Word; xc, yc: Byte);
    // destructor Done;

    procedure Draw;
    procedure DrawCell(x, y: Byte);

    procedure SetTypeCell(x, y: Byte; t: CellType);

     
  end;

implementation

    /// /// /// /// /// ///

  constructor LevelGrid.Init(xpos, ypos: Word; xc, yc: Byte);
    var
      X, Y: Byte;
      _calcY: Word;

    begin
      // _offset := LineOffset[ypos] + xpos;
      _grid_size := 17;
      _x := xpos;
      _y := ypos;

      _xn := xc - 1;
      _yn := yc - 1;

      // _cells := [0.. _xn, 0.._yn] of LevelCell;

      setLength(_cells, _xn + 1, _yn + 1);


      for Y :=0 to _yn do
      begin
        _calcY := ypos + (_grid_size * Y);
       
        for X :=0 to _xn do
          // _cells[X, Y] := LevelCell.Init(LineOffset[_yoffset] + (xpos + (_grid_size * X)) , X, Y, 0);
          _cells[X, Y] := LevelCell.Init(xpos + (_grid_size * X), _calcY, CellType.Field);
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

end.