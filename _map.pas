{$MODE OBJFPC}

unit _map;

interface

uses
  draw, _types, _util;

  /// Level ///

type
  Level = class
  public
    _lvl: array[0..14, 0..9] of CellType;

    constructor Init;
    
    procedure SetType(x, y: Byte; t: CellType);
    function GetType(x, y: Byte): CellType;

    // destructor Destroy;

  end;

  /// LevelMap ///

type
  LevelMap = class
  public
    _xpos, _ypos: Word;
    _active, _xm, _ym: Byte;

    _levels: array[0..7] of Level;

    constructor Init(xpos, ypos: Word);

    procedure Draw;
    procedure DrawLvl(n: Byte);
    
    procedure SetType(x, y: Byte; t: CellType);
    procedure SetActive(n: Byte);

    // destructor Destroy;
    
  end;

    

implementation

    /// Level Impl ///

  constructor Level.Init;
  var
    x, y: Byte;

    begin
      for y := 0 to 9 do
        for x := 0 to 14 do
          _lvl[x, y] := CellType.Field;
    end;


  procedure Level.SetType(x, y: Byte; t: CellType);
    begin
      if btwn(x, 0, 15) AND btwn(y, 0, 9) then
        _lvl[x, y] := t;
    end;

  
  function Level.GetType(x, y: Byte): CellType;
    begin
      if btwn(x, 0, 15) AND btwn(y, 0, 9) then
        GetType := _lvl[x, y];

      GetType := CellType.NULL;
    end;

  // destructor Level.Destroy;
  // begin
  //   _lvl := nil;
  //   inherited Destroy;
  // end;



      /// Level Impl ///

    constructor LevelMap.Init(xpos, ypos: Word);
    var
      n, c : Byte;

    begin
      _xpos := xpos;
      _ypos := ypos;

    _active := 0;
    _xm := 16;
    _ym := 11;

    for n := 0 to 7 do
      begin
        _levels[n] := Level.Init;
        if n = _active then
          c := 15
        else
          c := 7;
        

        FilledRectangle(_xpos + (_xm * n), _ypos, _xpos + _xm + (_xm * n), _ypos + _ym, c, 10);
      end;

    end;

    procedure LevelMap.Draw;
    var
      n: Byte;

    begin
      // for n := 0 to 7 do
      //   // !!!
        
        
    end;

    procedure LevelMap.DrawLvl(n: Byte);
    begin
    end;    

    procedure LevelMap.SetType(x, y: Byte; t: CellType);
    begin
    end;

    procedure LevelMap.SetActive(n: Byte);
    begin
    end;

    // destructor LevelMap.Destroy;
    // begin
    // end;

end.