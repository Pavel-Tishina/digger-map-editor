{$MODE OBJFPC}

unit _map;

interface

uses
  draw, _types, _util;

  /// Level ///

type
  Level = class
    _lvl: array[0..14, 0..9] of CellType;

    constructor Init;
    
    procedure SetType(x, y: Byte; t: CellType);
    function GetType(x, y: Byte): CellType;
  end;

  /// LevelMap ///

type
  LevelMap = class(TGUI)
    const
      _xm_c   : Byte = 16;
      _ym_c   : Byte = 11;
      _lvl_n  : Byte = 8;

    var
      _active: Byte;
      _levels: array[0..7] of Level;

    constructor Init(xpos, ypos: Word);

    procedure Draw;
    procedure DrawLvl(n: Byte);
    
    procedure SetType(x, y: Byte; t: CellType);
    procedure SetActive(n: Byte);

    function SelectLevel(x, y: Word): Byte;
    
    function GetLevel(n : Byte): Level;
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
      if btwn(x, 0, 15) AND btwn(y, 0, 9) then _lvl[x, y] := t;
    end;

  
  function Level.GetType(x, y: Byte): CellType;
    begin
      Result := specialize IfElse<CellType>(btwn(x, 0, 15) AND btwn(y, 0, 9), _lvl[x, y], CellType.Error);
    end;

      /// Level Impl ///

    constructor LevelMap.Init(xpos, ypos: Word);
    var
      _FN, _FC : Byte;
      _FX : Word;

    begin
      _x := xpos;
      _y := ypos;
      _xm := xpos + (_lvl_n * _xm_c);
      _ym := ypos + _ym_c;

      _active := 0;

      for _FN := 0 to _lvl_n - 1 do
        begin
          _levels[_FN] := Level.Init;
          _FC := specialize IfElse<Byte>(_FN = _active, 15, 7);
        
          _FX := _x + (_xm_c * _FN);
          FilledRectangle(_FX, _y, _FX + _xm_c, _ym, _FC, 10);
        end;

    end;

    procedure LevelMap.Draw;
    var
      __n: Byte;

    begin
      for __n := 0 to 7 do
        DrawLvl(__n);   
    end;

    procedure LevelMap.DrawLvl(n: Byte);
    var
      _FX, _FY : Byte;
      _FCY : Word;
    
    begin
      for _FY := 0 to 9 do
        begin
          _FCY := LineOffset[_y + 1 + _FY];
          
          for _FX := 0 to 14 do
            PutPixelOffset(_FCY + _x + 1 + (_xm_c * n) + _FX, CellTypeMapPixel(_levels[n].GetType(_FX, _FY)));  

        end;
    end;    

    procedure LevelMap.SetType(x, y: Byte; t: CellType);
    begin
      if (_levels[_active].GetType(x, y) <> t) then exit;

      _levels[_active].SetType(x, y, t);
      PutPixelOffset(LineOffset[_y + 1 + y] + _x + 1 + (_xm_c * _active) + x, CellTypeMapPixel(t)); 
    end;

    procedure LevelMap.SetActive(n: Byte);
    begin
      if NOT btwn(n, 0, 7) then exit;

      Rectangle(_x + (_xm_c * _active), _y, _x + (_xm_c * _active) + _xm_c, _ym, 7);
      Rectangle(_x + (_xm_c * n), _y, _x + (_xm_c * n) + _xm_c, _ym, 15);
      _active := n;
    end;

    function LevelMap.SelectLevel(x, y: Word): Byte;
    var
      _FN : Byte;

    begin
      if NOT IsClick(x, y) then exit(255);
        
      for _FN := 0 to 8 do
        if btwn(x, _x, _x + (_xm_c * _FN)) then // i += _xm ?
          begin
            Result := _FN - 1;
            break;
          end;
    end;    

    function LevelMap.GetLevel(n : Byte): Level;
    begin
      Result := specialize IfElse<Level>(btwn(n, 0, 7), _levels[n], Level.Init);
    end;

end.