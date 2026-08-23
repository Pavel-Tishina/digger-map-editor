unit _util;

interface
  function btwn(n, a, b: Word): Boolean;
  function btwne(n, a, b: Word): Boolean;


implementation

  function btwn(n, a, b: Word): Boolean;
  begin
    btwn := (n >= a) AND (n <= b);
  end;

  function btwne(n, a, b: Word): Boolean;
  begin
    btwne := (n > a) AND (n < b);
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