{$MODE OBJFPC}

unit _cell; 

interface

uses
    draw, _types, _icons;

type
  LevelCell = class
  public
    _r, _xi, _yi: Byte;
    _x, _y: Word;
    _t: CellType;
    _d: Boolean;

    constructor Init(xi, yi : Byte; x, y: Word; t: CellType);
    // destructor Done;

    procedure Draw;
    procedure SetType(t: CellType);
    function GetType: CellType;

    function X: Word;
    function Y: Word;

    procedure SetDisable(d : Boolean); // HUH? I Need this?
    function IsDisable: Boolean; // HUH? I Need this?

  end;

    

implementation

    constructor LevelCell.Init(xi, yi : Byte; x, y: Word; t: CellType);
      begin
        _r := 17;
        _x := x;
        _y := y;
        _t := t;

        _xi := xi;
        _yi := yi;
      end;

    // destructor Done;
    //   begin
    //   end;

    procedure LevelCell.Draw;
      // var _i : Byte;
      begin
        Square(_x, _y, _r, 7);
        FilledSquare(_x + 1, _y + 1, _r - 2, 8, 10);

        if (_t <> CellType.Field) then
          DrawIcon(_x + 2, _y + 2, _t);

        if (_d) then
          begin
            Line(_x + 2, _y + 2, _x + _r - 2, _y + _r - 2, 0);
            Line(_x + _r - 2, _y + 2, _x + 2, _y + _r - 2, 0);
          end;
          // for _i := 0 to 2 do
          //   begin
          //       // LineOffset(LineOffset[_y + 2] + _x + 2 + _i, LineOffset[_y + _r - 2] + (_x + _r - 2) + _i, 5);
          //       // LineOffset(LineOffset[_y + _r - 2] + (_x + _r - 2) - _i, LineOffset[_y + 2] + _x + 2 - _i, 5);

          //     Line(_x + 2 + _i,  _y + 2 + _i,  _x + _r - 2 - _i,  _y + _r - 2 - _i, 5);
          //     Line(_x + _r - 2 - _i, _y + 2 + _i, _x - 2 + _i, _y + _r - 2 - _i, 5);
          //   end; 
        
      end;

    procedure LevelCell.SetType(t: CellType);
      begin
        _t := t;
      end;

    procedure LevelCell.SetDisable(d: Boolean);
      begin
        _d := d;
      end;

    function LevelCell.IsDisable: Boolean;
      begin
        IsDisable := _d;
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