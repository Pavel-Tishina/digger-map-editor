{$MODE OBJFPC}

unit _map;

interface

uses
  draw, _types, _util, io;

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
      _dir : ShortString = '\MAPS\';

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
    function GetLevel: Level;

    procedure LoadMap(f: String);
    procedure SaveMap(f: String);
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
      if btwn(x, 0, 14) AND btwn(y, 0, 9) then _lvl[x, y] := t;
    end;

  
  function Level.GetType(x, y: Byte): CellType;
    begin
      Result := specialize IfElse<CellType>(btwn(x, 0, 14) AND btwn(y, 0, 9), _lvl[x, y], CellType.Error);
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

    // // // // // // // // // //

    procedure LevelMap.Draw;
      var
        __n: Byte;

      begin
        for __n := 0 to 7 do
          DrawLvl(__n);   
      end;

    // // // // // // // // // //

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

    // // // // // // // // // //

    procedure LevelMap.SetType(x, y: Byte; t: CellType);
      begin
        if (_levels[_active].GetType(x, y) = t) then exit;

        _levels[_active].SetType(x, y, t);
        PutPixelOffset(LineOffset[_y + 1 + y] + _x + 1 + (_xm_c * _active) + x, CellTypeMapPixel(t)); 
      end;

    // // // // // // // // // //

    procedure LevelMap.SetActive(n: Byte);
      begin
        if NOT btwn(n, 0, 7) then exit;

        Rectangle(_x + (_xm_c * _active), _y, _x + (_xm_c * _active) + _xm_c, _ym, 7);
        Rectangle(_x + (_xm_c * n), _y, _x + (_xm_c * n) + _xm_c, _ym, 15);
        _active := n;
      end;

    // // // // // // // // // //

    function LevelMap.SelectLevel(x, y: Word): Byte;
      begin
        if NOT IsClick(x, y) then exit(255);

        Result := (x - _x) div _xm_c;
        if Result >= _lvl_n then Result := _lvl_n - 1;
      end;

    // // // // // // // // // //

    function LevelMap.GetLevel(n : Byte): Level;
      begin
        if btwn(n, 0, 7) then
          Result := _levels[n]
        else
          Result := Level.Init;
      end;

    // // // // // // // // // //

    function LevelMap.GetLevel: Level;
      begin
        Result := GetLevel(_active);
      end;

    // // // // // // // // // //

    procedure LevelMap.LoadMap(f: String);
      var 
        _lvl_i, _xl, _yl: Byte;
        _content: array[0..1201] of Char;
        _h, _i, _l, _start : Word;
      begin
        f := _dir + f + #0;
        _h := OpenFileRead(@f[1]);
        if _h = $FFFF then exit;

        _l := ReadFile(_h, @_content, SizeOf(_content));
        CloseFile(_h);

        if (_l = 0) OR (_l > SizeOf(_content)) then exit; // $FFFF - read error

        // skip 2-byte header (#1, #2) written by SaveMap
        if (_l >= 2) AND (_content[0] = Chr(1)) AND (_content[1] = Chr(2)) then
          _start := 2
        else
          _start := 0;

        _lvl_i := 0;
        _yl := 0;
        _xl := 0;

        for _i := _start to _l - 1 do
          begin
            if _lvl_i >= _lvl_n then break;

            _levels[_lvl_i].SetType(_xl, _yl, CharToCellType(_content[_i]));

            if (_xl >= 14) then
              begin
                
                if (_yl >= 9) then
                  begin
                    inc(_lvl_i);
                    _yl := 0;
                  end
                else
                  inc(_yl);

                _xl := 0;
              end
            else
              inc(_xl);
            
          end;
        
        Draw;
      end;

    // // // // // // // // // //

    procedure LevelMap.SaveMap(f: String);
      var 
        _lvl_i, _xl, _yl: Byte;
        _content: array[0..1201] of Char;
        _h, _i : Word;
      begin
        
        _content[0] := Chr(1);
        _content[1] := Chr(2);
        _i := 2;
        for _lvl_i := 0 to 7 do
          for _yl := 0 to 9 do
            for _xl := 0 to 14 do
              begin
                _content[_i] := CellTypeChar(_levels[_lvl_i].GetType(_xl, _yl));
                inc(_i);
              end; 

        f := _dir + f + #0;
        _h := CreateFile(@f[1]);
        if _h = $FFFF then exit;

        WriteFile(_h, @_content, SizeOf(_content));
        CloseFile(_h);
      end;

    // // // // // // // // // //

end.