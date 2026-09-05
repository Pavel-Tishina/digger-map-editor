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

    function Click(x, y: Word): Boolean;
    function SelectLevel(x, y: Word): Byte;
    
    function GetLevel(n : Byte): Level;

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
        GetType := _lvl[x, y]
      else
        GetType := CellType.Error;
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
      for n := 0 to 7 do
        DrawLvl(n);
        
    end;

    procedure LevelMap.DrawLvl(n: Byte);
    var
      x, y : Byte;
      _coord : Word;
    
    begin
      for y := 0 to 9 do
        begin
          _coord := LineOffset[_ypos + 1 + y];
          
          for x := 0 to 14 do
            PutPixelOffset(_coord + _xpos + 1 + (_xm * n) + x, CellTypeMapPixel(_levels[n].GetType(x, y)));  

        end;
    end;    

    procedure LevelMap.SetType(x, y: Byte; t: CellType);
    begin
      if (btwn(x, 0, 14) AND btwn(y, 0, 9) AND (_levels[_active].GetType(x, y) <> t)) then
        begin
          _levels[_active].SetType(x, y, t);
          PutPixelOffset(LineOffset[_ypos + 1 + y] + _xpos + 1 + (_xm * _active) + x, CellTypeMapPixel(t));
        end; 
    end;

    procedure LevelMap.SetActive(n: Byte);
    begin
      if btwn(n, 0, 7) then
        begin
          Rectangle(_xpos + (_xm * _active), _ypos, _xpos + (_xm * _active) + _xm, _ypos + _ym, 7);
          Rectangle(_xpos + (_xm * n), _ypos, _xpos + (_xm * n) + _xm, _ypos + _ym, 15);
          _active := n;
        end;
    end;

    function LevelMap.Click(x, y: Word): Boolean;
    begin
      Click := btwn(x, _xpos, _xpos + (_xm * 8)) and btwn(y, _ypos, _ypos + _ym);
    end;

    function LevelMap.SelectLevel(x, y: Word): Byte;
    var
      n, i : Byte;

    begin
      if Click(x, y) then
        begin
          for n := 0 to 8 do
            if btwn(x, _xpos, _xpos + (_xm * n)) then // i += _xm ?
              begin
                Result := n - 1;
                break;
              end;    
        end

        else
          Result := 255;
    end;    

    function LevelMap.GetLevel(n : Byte): Level;
    begin
      if btwn(n, 0, 7) then
        GetLevel := _levels[n]
      else
        GetLevel := Level.Init;
    end;

end.