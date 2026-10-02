{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
{$INLINE ON}

unit _map;

interface

uses
  draw, _types, _util, io;

  /// Level ///

type
  Level = class
    _lvl: array[0..14, 0..9] of CellType;

    constructor Init;
    procedure Clear;
    
    procedure SetType(x, y: Byte; t: CellType);
    function GetType(x, y: Byte): CellType;
  end;

  /// LevelMap ///

type
  LevelMap = class(TGUI)
    const
      _xm_c   = 16;
      _ym_c   = 11;
      _lvl_n  = 8;
      _dir = '\MAPS\';

    var
      _active: Byte;
      _levels: array[0..7] of Level;

    constructor Init(xpos, ypos: Word);
    procedure Clear;

    procedure Draw;
    procedure DrawFrames;
    procedure DrawLvl(n: Byte);
    
    procedure SetType(x, y: Byte; t: CellType);
    procedure SetActive(n: Byte);

    function SelectLevel(x, y: Word): Byte;
    
    function GetLevel(n : Byte): Level;

    procedure LoadMap(const f: String);
    procedure SaveMap(const f: String);

    function CalcGold(n: Word): ShortInt;
  end;

    
implementation

  function CheckXYLvl(x, y: Byte): Boolean;
    begin
      Result := btwn(x, 0, 14) AND btwn(y, 0, 9);
    end;

    /// Level Impl ///

  constructor Level.Init;
    begin
      Clear;
    end;

  procedure Level.Clear;
    var
      x, y: Byte;

    begin
      for y := 0 to 9 do
        for x := 0 to 14 do
          _lvl[x, y] := CellType.Field;
    end;


  procedure Level.SetType(x, y: Byte; t: CellType);
    begin
      if CheckXYLvl(x, y) then _lvl[x, y] := t;
    end;

  
  function Level.GetType(x, y: Byte): CellType;
    begin
      if CheckXYLvl(x, y) then
        Result := _lvl[x, y]
      else
        Result := CellType.Error;
    end;

      /// Level Impl ///

    constructor LevelMap.Init(xpos, ypos: Word);
      var
        _FN : Byte;

      begin
        _x := xpos;
        _y := ypos;
        _xm := xpos + (_lvl_n * _xm_c);
        _ym := ypos + _ym_c;

        _active := 0;

        for _FN := 0 to _lvl_n - 1 do
          _levels[_FN] := Level.Init;

        DrawFrames;
      end;

    // // // // // // // // // //

    // empty map, first level active - the objects are reused, not recreated
    procedure LevelMap.Clear;
      var
        _FN : Byte;

      begin
        for _FN := 0 to _lvl_n - 1 do
          _levels[_FN].Clear;

        _active := 0;
        DrawFrames;
      end;

    // // // // // // // // // //

    procedure LevelMap.DrawFrames;
      var
        _FN, _FC : Byte;
        _FX : Word;

      begin
        for _FN := 0 to _lvl_n - 1 do
          begin
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
        _buf : array[0..9, 0..14] of Byte;   // 15 x 10 thumbnail, [y, x]
      
      begin
        for _FY := 0 to 9 do
          for _FX := 0 to 14 do
            _buf[_FY, _FX] := CellTypeMapPixel(_levels[n]._lvl[_FX, _FY]);

        RestoreRect(@_buf, LineOffset[_y + 1] + _x + 1 + (_xm_c * n), 15, 10);
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

        Result := Word(x - _x) div _xm_c;
        if Result >= _lvl_n then Result := _lvl_n - 1;
      end;

    // // // // // // // // // //

    function LevelMap.GetLevel(n : Byte): Level;
      begin
        // nil for a wrong n: a new Level here was never freed
        Result := specialize IfElse<Level>(btwn(n, 0, 7), _levels[n], nil);
      end;

    // // // // // // // // // //

    procedure LevelMap.LoadMap(const f: String);
      var 
        _lvl_i, _xl, _yl: Byte;
        _content: array[0..1201] of Char;
        _h, _i, _l, _start : Word;
        _path : String[40];
      begin
        _path := _dir + f + #0;
        _h := OpenFileRead(@_path[1]);
        if _h = $FFFF then exit;

        _l := ReadFile(_h, @_content, SizeOf(_content));
        CloseFile(_h);

        if (_l = 0) OR (_l > SizeOf(_content)) then exit; // $FFFF - read error

        // skip 2-byte header (#1, #2) written by SaveMap
        _start := specialize IfElse<Word>((_l >= 2) AND (_content[0] = Chr(1)) AND (_content[1] = Chr(2)), 2, 0);
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

    procedure LevelMap.SaveMap(const f: String);
      var 
        _lvl_i, _xl, _yl: Byte;
        _content: array[0..1201] of Char;
        _h, _i : Word;
        _path : String[40];
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

        _path := _dir + f + #0;
        _h := CreateFile(@_path[1]);
        if _h = $FFFF then exit;

        WriteFile(_h, @_content, SizeOf(_content));
        CloseFile(_h);
      end;

    // // // // // // // // // //

    function LevelMap.CalcGold(n: Word): ShortInt;
      var
        _xl, _yl: Byte;

      begin
        if NOT btwn(n, 0, 7) then exit(0);
        
        Result := 0;
        for _yl := 0 to 9 do
          for _xl := 0 to 14 do
            if _levels[n].GetType(_xl, _yl) = CellType.Gold then
              inc(Result);
      end;

end.