{$MODE OBJFPC}

unit _cell; 

interface

uses
    draw, _types, _icons;

type
  LevelCell = class
    const
      _r : Byte = 17;

    var  
      _xi, _yi: Byte;
      _x, _y: Word;
      _t: CellType;

    constructor Init(xi, yi : Byte; x, y: Word; t: CellType);

    procedure Draw;
    procedure SetType(t: CellType);
    function GetType: CellType;

    function X: Word;
    function Y: Word;
  end;

implementation

    constructor LevelCell.Init(xi, yi : Byte; x, y: Word; t: CellType);
      begin
        _x := x;
        _y := y;
        _t := t;

        _xi := xi;
        _yi := yi;
      end;

    procedure LevelCell.Draw;
      begin
        Square(_x, _y, _r, 7);
        FilledSquare(_x + 1, _y + 1, _r - 2, 8, 10);

        if (_t <> CellType.Field) then
          DrawIcon(_x + 2, _y + 2, _t);
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

end.