unit video;

{$ASMMODE INTEL}

interface

procedure SetVideoMode13h;
procedure SetTextMode;
procedure WaitKey;

implementation


procedure SetVideoMode13h; assembler;
asm
    mov ax,$0013
    int $10
end;


procedure SetTextMode; assembler;
asm
    mov ax,$0003
    int $10
end;

// move it to IO.PAS
procedure WaitKey; assembler;
asm
    mov ah,$00
    int $16
end;


end.