{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
{$INLINE ON}

unit _cell; 

interface

uses
    draw, _types, _icons;

type
  LevelCell = object
    const
      _r = 17;
      _tm = 5;
      _tr = 7;

    var  
      _xi, _yi: Byte;
      _x, _y: Word;
      _t: CellType;
      _tonnel : TonnelSet;

    procedure Init(xi, yi : Byte; x, y: Word; t: CellType);

    procedure Draw;
    procedure DrawTonnels;
    procedure AddTonnel(td : TonnelDirection);
    procedure DelTonnel(td : TonnelDirection);

    procedure AddOrDelTonnel(td : TonnelDirection; isItAdd: Boolean);
    
    procedure SetType(t: CellType); inline;
    function GetType: CellType; inline;

    function X: Word; inline;
    function Y: Word; inline;
  end;

  function IsItTonnelCell(t: CellType): Boolean;

implementation
    const
      // tonnel rectangle in the cell: x1, y1, x2, y2,
      // inside the grid lines (0, _r): from 1 to _r - 1, the lines are shared with the neighbour cells
      TONNEL_RECT: array[TonnelDirection.Nord..TonnelDirection.East, 0..3] of Byte = (
        (LevelCell._tm, 1, LevelCell._tm + LevelCell._tr, LevelCell._tr),                         // Nord
        (1, LevelCell._tm, LevelCell._tr, LevelCell._tm + LevelCell._tr),                         // West
        (LevelCell._tm, LevelCell._r - LevelCell._tr, LevelCell._tm + LevelCell._tr, LevelCell._r - 1), // South
        (LevelCell._r - LevelCell._tr, LevelCell._tm, LevelCell._r - 1, LevelCell._tm + LevelCell._tr)  // East
      );

    function IsItTonnelCell(t: CellType): Boolean;
      begin
        Result := (t = CellType.Hole) OR (t = CellType.TonnelH) OR (t = CellType.TonnelV);
      end;

    procedure LevelCell.Init(xi, yi : Byte; x, y: Word; t: CellType);
      begin
        _x := x;
        _y := y;
        _t := t;

        _xi := xi;
        _yi := yi;
        _tonnel := [];
      end;

    procedure LevelCell.DrawTonnels;
      var
        _tj : TonnelDirection;
      
      begin
        // _tonnel is [] for not tonnel cells: LevelGrid keeps it so
        // table, not case: one FilledRectangle call instead of four
        for _tj := TonnelDirection.Nord to TonnelDirection.East do
          if _tj in _tonnel then
            FilledRectangle(_x + TONNEL_RECT[_tj, 0], _y + TONNEL_RECT[_tj, 1],
                            _x + TONNEL_RECT[_tj, 2], _y + TONNEL_RECT[_tj, 3], 0, 0);
      end;

    procedure LevelCell.Draw;
      begin
        Square(_x, _y, _r, 7);
        FilledSquare(_x + 1, _y + 1, _r - 2, 8, 10);

        if (_t <> CellType.Field) then
          DrawIcon(_x + 2, _y + 2, _t);
        
        DrawTonnels;
      end;

    procedure LevelCell.SetType(t: CellType);
      begin
        _t := t;
      end;

    function LevelCell.GetType: CellType;
      begin
        GetType := _t;
      end;

    function LevelCell.X: Word;
      begin
        X := _xi;
      end;

    function LevelCell.Y: Word;
      begin
        Y := _yi;
      end;

    procedure LevelCell.AddTonnel(td : TonnelDirection);
      begin
        if td <> TonnelDirection.None then
          Include(_tonnel, td);
      end;

    procedure LevelCell.DelTonnel(td : TonnelDirection);
      begin
        if td <> TonnelDirection.None then
          Exclude(_tonnel, td);
      end;

    procedure LevelCell.AddOrDelTonnel(td : TonnelDirection; isItAdd: Boolean);
      begin
        if isItAdd then
          AddTonnel(td)
        else
          DelTonnel(td);
      end;
    

end.