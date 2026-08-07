unit video;

{$ASMMODE INTEL}

interface

procedure SetVideoMode13h;
procedure SetTextMode;
// procedure DrawLineTest;
// procedure PutPixelTest;
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

// procedure PutPixelTest; assembler;
// asm
//     push es
//     push di

//     mov ax,$A000
//     mov es,ax


//     xor di,di       { offset 0,0 }

//     mov al,15       { white }
//     mov byte ptr es:[di],al


//     pop di
//     pop es
// end;


// { Bresenham: (0,0) -> (319,199), color=15 }

// procedure DrawLineTest; assembler;
// asm
//     push es
//     push ax
//     push bx
//     push cx
//     push dx
//     push si
//     push di


//     mov ax,$A000
//     mov es,ax


//     xor bx,bx       { x = 0 }
//     xor dx,dx       { y = 0 }


//     mov si,159      { error = dx/2 }


// @@draw:

//     { offset = y*320+x }
    
//     mov di,dx       { di = y }

//     shl di,1
//     shl di,1
//     shl di,1
//     shl di,1
//     shl di,1
//     shl di,1       { y*64 }


//     mov ax,dx

//     shl ax,1
//     shl ax,1
//     shl ax,1
//     shl ax,1
//     shl ax,1
//     shl ax,1
//     shl ax,1
//     shl ax,1       { y*256 }


//     add di,ax
//     add di,bx


//     mov al,15
//     mov byte ptr es:[di],al


//     cmp bx,319
//     je @@exit


//     inc bx


//     sub si,199

//     jns @@no_y


//     inc dx
//     add si,319


// @@no_y:

//     jmp @@draw


// @@exit:

//     pop di
//     pop si
//     pop dx
//     pop cx
//     pop bx
//     pop ax
//     pop es

// end;


// move it to IO.PAS
procedure WaitKey; assembler;
asm
    mov ah,$00
    int $16
end;


end.