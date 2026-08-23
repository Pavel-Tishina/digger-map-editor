{$MODE OBJFPC}

unit _cell; 

interface

uses
    draw, _types;

type
  LevelCell = class
  public
    _r: Byte;
    _x, _y: Word;
    _t: CellType;

    constructor Init(x, y: Word; t: CellType);
    // destructor Done;

    procedure Draw;
    procedure SetType(t: CellType);

  end;

    

implementation

    constructor LevelCell.Init(x, y: Word; t: CellType);
      begin
        _r := 17;
        _x := x;
        _y := y;
        _t := t;
      end;

    // destructor Done;
    //   begin
    //   end;

    procedure LevelCell.Draw;
      begin
        // GetCellTypeBitmap
        
        Square(_x, _y, _r, 7);
        FilledSquare(_x + 1, _y + 1, _r - 2, 8, 10);
        
      end;

    procedure LevelCell.SetType(t: CellType);
      begin
        _t := t;
      end;

end.