unit draw;

{$ASMMODE INTEL}


interface
    var
        LineOffset: array[0..199] of Word;

    procedure PutPixel(x, y: Word; color: Byte);
    procedure PutPixelOffset(pos: Word; color: Byte);
    procedure SetPalette(Color, R, G, B: Byte);
    procedure DelayUS(CXValue, DXValue: Word);
    procedure DelayMS(msec: Word);
    procedure Square(x, y, s: Word; c: Byte);
    procedure FilledSquare(x, y, s: Word; c, cf: Byte);
    procedure Rectangle(x1, y1, x2, y2: Word; c: Byte);
    procedure FilledRectangle(x1, y1, x2, y2: Word; c, cf: Byte);
    procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);

    procedure SetBackgroundColor(c: Byte);

    function GetPixel(x, y: Word): Byte;
    function GetPixelOffset(pixel_offset: Word): Byte;

    procedure SaveCursorBackground(X, Y: Word);
    procedure RestoreCursorBackground(X, Y: Word);

implementation

    var
        VideoSeg : Word = $A000;
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

    function GetPixelOffset(pixel_offset: Word): Byte; assembler;
        asm
            push ds

            mov ax, VideoSeg
            mov ds, ax

            mov bx, pixel_offset
            mov al, [bx]

            pop ds
        end;

    ////////////////////////////////////////////

    // procedure SetBackgroundColor(c: Byte); assembler;
    //     asm
    //         mov ax, VideoSeg    // The offset to video memory
    //         mov es, ax          // We load it to ES through AX, becouse immediate operation is not allowed on ES
    //         mov ax, 0           // 0 will put it in top left corner. To put it in top right corner load with 320, in the middle of the screen 32010.
    //         mov di, ax          // load Destination Index register with ax value (the coords to put the pixel)
    //         // mov dl, [c]      // Dark Grey color.
    //         mov dl, 8           // Dark Grey color.
    //         mov [es:di], dl     // And we put the pixel
    //     end;    


    ////////////////////////////////////////////

    procedure SetBackgroundColor(c: Byte);
        var x, y: Word;

        begin
            for y := 0 to 199 do
                for x := 0 to 319 do
                    PutPixelOffset(LineOffset[y] + x, c);
                    // Line(0, y, 319, y, c);

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

    procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);
        var
            X, Y   : Integer;
            DX, DY : Integer;
            SX, SY : Integer;
            Err    : Integer;
            E2     : Integer;
        begin
            asm
                push ds
                push es
                push bx
                push cx
                push dx
                push si
                push di

                // ------------------------------------------------
                // X = X1
                // Y = Y1
                // ------------------------------------------------

                mov ax, X1
                mov X, ax

                mov ax, Y1
                mov Y, ax

                // ------------------------------------------------
                // DX = abs(X2-X1)
                // SX = direction X
                // ------------------------------------------------

                mov ax, X2
                sub ax, X1

                cmp ax, 0
                jge @@DXPositive

                neg ax
                mov DX, ax

                mov SX, -1
                jmp @@CalcDY

            @@DXPositive:
                mov DX, ax

                mov SX, 1


            @@CalcDY:

                // ------------------------------------------------
                // DY = -abs(Y2-Y1)
                // SY = direction Y
                // ------------------------------------------------

                mov ax, Y2
                sub ax, Y1

                cmp ax, 0
                jge @@DYPositive

                neg ax
                neg ax                  // DY = -abs(...)
                mov DY, ax

                mov SY, -1
                jmp @@CalcError

            @@DYPositive:
                neg ax                  // DY = -abs(...)
                mov DY, ax

                mov SY, 1


            @@CalcError:

                // Err = DX + DY
                mov ax, DX
                add ax, DY
                mov Err, ax


            @@Loop:

                // ------------------------------------------------
                // PutPixel(X,Y)
                // ------------------------------------------------

                mov bx, Y

                // bx = Y * 2
                // i8086: can it shl bx,1? Yep.
                shl bx, 1

                mov di, LineOffset[bx]
                add di, X

                mov ax, $A000
                mov es, ax

                mov al, Color
                mov es:[di], al


                // ------------------------------------------------
                // if X == X2 and Y == Y2 -> end
                // ------------------------------------------------

                mov ax, X
                cmp ax, X2
                jne @@Continue

                mov ax, Y
                cmp ax, Y2
                je @@Done


            @@Continue:

                // E2 = 2 * Err

                mov ax, Err
                add ax, ax
                mov E2, ax


                // ------------------------------------------------
                // if E2 >= DY
                // ------------------------------------------------

                mov ax, E2
                cmp ax, DY
                jl @@SkipX

                mov ax, Err
                add ax, DY
                mov Err, ax

                mov ax, X
                add ax, SX
                mov X, ax


            @@SkipX:

                // ------------------------------------------------
                // if E2 <= DX
                // ------------------------------------------------

                mov ax, E2
                cmp ax, DX
                jg @@SkipY

                mov ax, Err
                add ax, DX
                mov Err, ax

                mov ax, Y
                add ax, SY
                mov Y, ax


            @@SkipY:

                jmp @@Loop


            @@Done:

                pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop es
                pop ds
            end;
        end;

    ////////////////////////////////////////////

begin
    for y := 0 to 199 do
        LineOffset[y] := y * 320;
end.