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
        if ((NOT IsItTonnelCell(_t)) OR (_tonnel = [])) then exit;

        // inside the grid lines (_x, _x + _r): from +1 to _r - 1,
        // the lines are shared with the neighbour cells
        for _tj in _tonnel do
          case _tj of
            TonnelDirection.Nord : FilledRectangle(_x + _tm, _y + 1, _x + _tm + _tr, _y + _tr, 0, 0);
            TonnelDirection.West : FilledRectangle(_x + 1, _y + _tm, _x + _tr, _y + _tm + _tr, 0, 0);
            TonnelDirection.East : FilledRectangle(_x + _r - _tr, _y + _tm, _x + _r - 1, _y + _tm + _tr, 0, 0);
            TonnelDirection.South : FilledRectangle(_x + _tm, _y + _r - _tr, _x + _tm + _tr, _y + _r - 1, 0, 0);
          end;
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