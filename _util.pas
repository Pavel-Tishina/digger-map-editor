{$MODE OBJFPC}
{$INLINE ON}

unit _util;

interface
  function btwn(n, a, b: Word): Boolean; inline;

  function AnyBtnClc(b: Word; l_prev, r_prev : Byte): Boolean; inline;
  function LBtnRelease(b : Word; prev : Byte): Boolean; inline;
  function RBtnRelease(b : Word; prev : Byte): Boolean; inline;

  function UpCase(c: Char): Char;

  generic function IfElse<T>(b: Boolean; _if, _else: T): T; inline;

implementation

  function btwn(n, a, b: Word): Boolean;
    begin
      btwn := (n >= a) AND (n <= b);
    end;

  function LBtnRelease(b : Word; prev : Byte): Boolean;
    begin
      LBtnRelease := ((b and 1) = 0) AND ((prev and 1) <> 0);
    end;

  function RBtnRelease(b : Word; prev : Byte): Boolean;
    begin
      RBtnRelease := ((b and 2) = 0) AND ((prev and 2) <> 0);
    end;

  function AnyBtnClc(b: Word; l_prev, r_prev : Byte): Boolean;
    begin
      AnyBtnClc := LBtnRelease(b, l_prev) XOR RBtnRelease(b, r_prev);
    end;

  function UpCase(c: Char): Char;
    var 
      _c : Byte;
    begin
      _c := ord(c);

      if btwn(_c, 97, 122) then
        dec(_c, 32);

      Result := chr(_c);
    end;  

  generic function IfElse<T>(b: Boolean; _if, _else: T): T;
    begin
      if b then
        Result := _if
      else
        Result := _else;
    end;

end.