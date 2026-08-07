unit mouse;

{$ASMMODE INTEL}

interface

type
  TMouseState = record
    X: Word;
    Y: Word;
    Btn: Word;
  end;

type
  TCursor = record
    Width : byte;
    Height: byte;
    Mask  : array[0..31,0..31] of byte;
  end;

const
  CursorMaskA: array[0..31] of Word = (

    { AND mask }
    $F800,
    $E000,
    $F000,
    $B800,
    $9C78,
    $0CB4,
    $014A,
    $0285,
    $0495,
    $0849,
    $1031,
    $0F81,
    $0042,
    $0F84,
    $0408,
    $03F0,

    { XOR mask }
    $07FF,
    $1FFF,
    $0FFF,
    $47FF,
    $6387,
    $F34B,
    $FEB5,
    $FD7A,
    $FB6A,
    $F7B6,
    $EFCE,
    $F07E,
    $FFBD,
    $F07B,
    $FBF7,
    $FC0F
  );

var
  MyMouse: TMouseState; // cuz nasty error "Duplicate" identifier "mouse" is here... damned Pascal namespaces

    function MouseInit: Boolean;

    procedure MouseSetRange320x200;
    procedure MouseShow;
    procedure MouseHide;
    // procedure SetMouseCursor;

    procedure MouseUpdate;
    // procedure DrawCursor(X, Y: Word);

implementation

    function MouseInit: Boolean; assembler;
        asm
            mov ax,$0000
            int $33

            cmp ax,0
            je @@no_mouse

            mov al,1
            jmp @@exit

        @@no_mouse:
            xor al,al

        @@exit:
        end;


    procedure MouseSetRange320x200; assembler;
        asm
            { X range }
            mov ax,$0007
            xor cx,cx
            mov dx,639
            int $33

            { Y range }
            mov ax,$0008
            xor cx,cx
            mov dx,199
            int $33
        end;

    
    procedure MouseShow; assembler;
        asm
            mov ax,$0001
            int $33
        end;

    
    procedure MouseHide; assembler;
        asm
            mov ax,0002h
            int 33h
        end;

    
    procedure MouseUpdate; assembler;
        asm
            push ds

            mov ax, seg MyMouse
            mov ds, ax

            mov ax, $0003
            int $33

            mov ax, cx
            shr ax, 1
            mov MyMouse.X, ax
            mov MyMouse.Y, dx
            mov MyMouse.Btn, bx

            pop ds
        end;

    // procedure SetMouseCursor; assembler;
    //     asm
    //         push ds
    //         push es

    //         mov ax, seg CursorMaskA
    //         mov es, ax

    //         mov dx, offset CursorMaskA

    //         mov ax, $0009
    //         xor bx, bx       { hot spot X }
    //         xor cx, cx       { hot spot Y }

    //         int $33

    //         pop es
    //         pop ds
    //     end;

    // procedure SaveCursourBackground(X, Y: Word);
    //     var
    //         i, j: Word;
    //     begin
    //         for j := 0 to 15 do
    //             for i := 0 to 15 do
    //             CursorBack[j, i] := GetPixel(X + i, Y + j);
    //     end;

    // procedure RestoreCursourBackground(X, Y: Word);
    //     var
    //         i, j: Word;
    //     begin
    //         for j := 0 to 15 do
    //             for i := 0 to 15 do
    //             PutPixel(X + i, Y + j, CursorBack[j, i]);
    //             CursorBack[j, i] := GetPixel(X + i, Y + j);
    //     end;

    // procedure DrawCursor(X, Y: Word); assembler;
    //     asm
    //         push ds
    //         push es
    //         push si
    //         push di
    //         push bx
    //         push dx


    //         mov ax,$A000
    //         mov es,ax


    //         mov ax,seg CursorMaskA
    //         mov ds,ax


    //         xor dx,dx              // row = 0


    //     @@Row:

    //         cmp dx,16
    //         jae @@Exit


    //         // VGA line address
    //         mov ax,Y
    //         add ax,dx
    //         mov bx,320
    //         mul bx

    //         add ax,X
    //         mov di,ax


    //         // AND mask
    //         mov si,dx
    //         shl si,1
    //         mov bx,CursorMaskA[si]


    //         // XOR mask
    //         mov si,dx
    //         add si,32              // +16 words
    //         shl si,1
    //         mov bp,CursorMaskA[si]


    //         mov cx,16              // width 


    //     @@Pixel:

    //         // bitmask from left to right

    //         test bx,$8000
    //         jnz @@AndOne

    //         // AND bit = 0
    //         mov byte ptr es:[di],0


    //     @@AndOne:

    //         test bp,$8000
    //         jz @@NoXor

    //         mov byte ptr es:[di],15


    //     @@NoXor:

    //         shl bx,1
    //         shl bp,1

    //         inc di

    //         loop @@Pixel


    //         inc dx
    //         jmp @@Row


    //     @@Exit:

    //         pop dx
    //         pop bx
    //         pop di
    //         pop si
    //         pop es
    //         pop ds
    //     end;

end.