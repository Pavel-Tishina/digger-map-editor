unit draw;

{$ASMMODE INTEL}

interface

    procedure PutPixel(x, y: Word; color: Byte);
    procedure PutPixelOffset(pos: Word; color: Byte);
    procedure SetPalette(Color, R, G, B: Byte);
    procedure DelayUS(CXValue, DXValue: Word);
    procedure DelayMS(msec: Word);
    procedure Square(x, y, s: Word; c: Byte);
    procedure FilledSquare(x, y, s: Word; c, cf: Byte);
    procedure Rectangle(x1, y1, x2, y2: Word; c: Byte);
    procedure FilledRectangle(x1, y1, x2, y2: Word; c, cf: Byte);

    function GetPixel(x, y: Word): Byte;

    procedure SaveCursorBackground(X, Y: Word);
    procedure RestoreCursorBackground(X, Y: Word);

implementation

    var
        VideoSeg : Word = $A000;
        LineOffset: array[0..199] of Word;
        y: Word;
        CursorBack: array[0..15, 0..15] of Byte;


    // procedure PutPixel(x, y: Word; color: Byte); assembler;
    //     asm
    //         push bp
    //         mov bp,sp

    //         push es
    //         push di

    //         mov ax,[bp+6]     { y }
    //         mov bx,320
    //         mul bx

    //         add ax,[bp+4]     { x }

    //         mov di,ax

    //         mov ax,VideoSeg
    //         mov es,ax

    //         mov ax,[bp+8]     { color }
    //         mov es:[di],al

    //         pop di
    //         pop es
    //         pop bp

    //     end;

    ////////////////////////////////////////////

    procedure PutPixelOffset(pos: Word; color: Byte); assembler;
        asm
            push es

            mov ax,VideoSeg
            mov es,ax

            mov di,pos
            mov al,color

            mov es:[di],al

            pop es
        end;

    ////////////////////////////////////////////    

    procedure SetPalette(Color, R, G, B: Byte); assembler;
        asm
            mov dx,3C8h

            mov al,Color
            out dx,al

            inc dx          { DX = 3C9h }

            mov al,R
            out dx,al

            mov al,G
            out dx,al

            mov al,B
            out dx,al
        end;

    ////////////////////////////////////////////

    procedure DelayUS(CXValue, DXValue: Word); assembler;
        asm
            mov ah,$86

            mov cx,CXValue
            mov dx,DXValue

            int $15
        end;

    ////////////////////////////////////////////

    procedure DelayMS(msec: Word);
        begin
            DelayUS($0000, msec * 1000);
        end;

    ////////////////////////////////////////////

    procedure PutPixel(x, y: Word; color: Byte);
        begin
            PutPixelOffset(LineOffset[y] + x, color)
        end;
    
    ////////////////////////////////////////////

    procedure Square(x, y, s: Word; c: Byte);
        var
            n, yy1, yy2, i : Word;

        begin        
            n := s div 2;
        
            for i:= 0 to n do
            begin            
                yy1 := LineOffset[y + i];
                yy2 := LineOffset[y + s - i];

                PutPixelOffset(LineOffset[y] + x + i, c);
                PutPixelOffset(LineOffset[y] + x + s - i, c);
            
                if i > 0 then
                begin
            
                    PutPixelOffset(yy1 + x, c);
                    PutPixelOffset(yy1 + x + s, c);

                    PutPixelOffset(yy2 + x, c);
                    PutPixelOffset(yy2 + x + s, c);
                end;
            
                PutPixelOffset(LineOffset[y + s] + x + i, c);
                PutPixelOffset(LineOffset[y + s] + x + s - i, c);
            end;
        end;

    ////////////////////////////////////////////

    procedure FilledSquare(x, y, s: Word; c, cf: Byte);
        var 
            i: Word;

        begin
            Square(x, y, s, c);
            for i := 1 to s - 1 do
                Square(x + i, y + i, s - i - 1, cf);
        end;

    ////////////////////////////////////////////

    procedure Rectangle(x1, y1, x2, y2: Word; c: Byte);
        var
            n, i : Word;

        begin
            n := abs(x1 - x2) div 2;        
            for i:= 0 to n do
            begin
                PutPixelOffset(LineOffset[y1] + x1 + i, c);
                PutPixelOffset(LineOffset[y1] + x2 - i, c);
                PutPixelOffset(LineOffset[y2] + x1 + i, c);
                PutPixelOffset(LineOffset[y2] + x2 - i, c);
            end;

            n := abs(y1 - y2) div 2;        
            for i:= 0 to n do
            begin
                PutPixelOffset(LineOffset[y1 + i] + x1, c);
                PutPixelOffset(LineOffset[y1 + i] + x2, c);
                PutPixelOffset(LineOffset[y2 - i] + x1, c);
                PutPixelOffset(LineOffset[y2 - i] + x2, c);
            end;
        end;

    ////////////////////////////////////////////

    procedure FilledRectangle(x1, y1, x2, y2: Word; c, cf: Byte);
        var 
            i: Word;

        begin
            Rectangle(x1, y1, x2, y2, c);
            for i := 1 to (abs(y1 - y2) div 2) do
                Rectangle(x1 + i, y1 + i, x2 - i, y2 - i, cf);
        end;

    ////////////////////////////////////////////

    function GetPixel(X, Y: Word): Byte; assembler;
        asm
            push ds

            mov ax, seg LineOffset
            mov ds, ax

            mov bx, Y
            shl bx, 1
            mov si, bx
            mov bx, LineOffset[si]

            add bx, X

            mov ax, VideoSeg
            mov ds, ax

            mov si, bx
            mov al, [si]

            pop ds
        end;

    ////////////////////////////////////////////

    procedure SaveCursorBackground(X, Y: Word); assembler;
        asm
            push ds
            push es

            mov ax, VideoSeg
            mov ds, ax

            mov ax, seg CursorBack
            mov es, ax

            xor dx, dx                // Row = 0

        @@NextRow:

            mov bx, Y
            add bx, dx
            shl bx, 1

            mov si, LineOffset[bx]
            add si, X

            mov di, dx
            // shl di, 4                 // Row * 16
            mov si, dx
            shl si,1
            shl si,1
            shl si,1
            shl si,1

            mov cx, 16
            rep movsb

            inc dx
            cmp dx, 16
            jb @@NextRow

            pop es
            pop ds
        end;

    ////////////////////////////////////////////

    procedure RestoreCursorBackground(X, Y: Word); assembler;
        asm
            push ds
            push es

            mov ax, seg CursorBack
            mov ds, ax

            mov ax, VideoSeg
            mov es, ax

            xor dx, dx

        @@NextRow:

            mov si, dx
            // shl si, 4                 // Row * 16
            mov si, dx
            shl si,1
            shl si,1
            shl si,1
            shl si,1

            mov bx, Y
            add bx, dx
            shl bx, 1

            mov di, LineOffset[bx]
            add di, X

            mov cx, 16
            rep movsb

            inc dx
            cmp dx, 16
            jb @@NextRow

            pop es
            pop ds
        end;

    ////////////////////////////////////////////

begin
    for y := 0 to 199 do
        LineOffset[y] := y * 320;
end.