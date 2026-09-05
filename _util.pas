unit _util;

interface
  function btwn(n, a, b: Word): Boolean;
  function btwne(n, a, b: Word): Boolean;

  function AnyBtnClc(b: Word; l_prev, r_prev : Byte): Boolean;
  function LBtnRelease(b : Word; prev : Byte): Boolean;
  function RBtnRelease(b : Word; prev : Byte): Boolean;

implementation

  function btwn(n, a, b: Word): Boolean;
    begin
      btwn := (n >= a) AND (n <= b);
    end;

  function btwne(n, a, b: Word): Boolean;
    begin
      btwne := (n > a) AND (n < b);
    end;

  function AnyBtnClc(b: Word; l_prev, r_prev : Byte): Boolean;
    begin
      AnyBtnClc := LBtnRelease(b, l_prev) XOR RBtnRelease(b, r_prev);
    end;

  function LBtnRelease(b : Word; prev : Byte): Boolean;
    begin
      LBtnRelease := ((b and 1) = 0) AND ((prev and 1) <> 0);
    end;

  function RBtnRelease(b : Word; prev : Byte): Boolean;
    begin
      RBtnRelease := ((b and 2) = 0) AND ((prev and 2) <> 0);
    end;

// {$asmmode intel}
// function IsBetweenWord(X, A, B: Word): Boolean; assembler;
// asm
//   mov ax, X
//   cmp ax, A
//   jb  @False    // Jump if Below (unsigned <)
//   cmp ax, B
//   ja  @False    // Jump if Above (unsigned >)
//   mov al, 1     // Result is True
//   ret
// @False:
//   xor al, al    // Result is False
// end;

// {$asmmode intel}
// function IsBetweenByte(X, A, B: Word): Boolean; assembler;
// asm
//   mov ax, X
//   cmp ax, A
//   jb  @False    // Jump if Below (unsigned <)
//   cmp ax, B
//   ja  @False    // Jump if Above (unsigned >)
//   mov al, 1     // Result is True
//   ret
// @False:
//   xor al, al    // Result is False
// end;

end.