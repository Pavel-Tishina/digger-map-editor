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

    function GetPixelOffset(pixel_offset: Word): Byte;

implementation
    const
        VideoSeg : Word = $A000;

    var
        y: Word;

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

    // horizontal span: count pixels from offset, 2 pixels per write
    procedure FillSpan(ofs, count: Word; color: Byte); assembler;
        asm
            push es

            mov ax,VideoSeg
            mov es,ax

            mov di,ofs
            mov cx,count
            mov al,color
            mov ah,al

            cld
            shr cx,1        { words, CF = odd pixel }
            rep stosw       { rep/stos do not change flags }
            adc cx,cx       { cx = 0 -> cx = CF }
            rep stosb

            pop es
        end;

    ////////////////////////////////////////////

    // vertical span: count pixels down from offset
    procedure VSpan(ofs, count: Word; color: Byte); assembler;
        asm
            push es

            mov ax,VideoSeg
            mov es,ax

            mov di,ofs
            mov cx,count
            mov al,color

            jcxz @@done     { loop with cx = 0 would run 65536 times }
        @@next:
            mov es:[di],al
            add di,320
            loop @@next
        @@done:
            pop es
        end;

    ////////////////////////////////////////////

    // makes x1 <= x2 and y1 <= y2
    procedure SortCorners(var x1, y1, x2, y2: Word);
        var
            t: Word;

        begin
            if x1 > x2 then begin t := x1; x1 := x2; x2 := t; end;
            if y1 > y2 then begin t := y1; y1 := y2; y2 := t; end;
        end;

    ////////////////////////////////////////////

    procedure FilledSquare(x, y, s: Word; c, cf: Byte);
        begin
            FilledRectangle(x, y, x + s, y + s, c, cf);
        end;

    ////////////////////////////////////////////

    procedure Rectangle(x1, y1, x2, y2: Word; c: Byte);
        var
            w: Word;

        begin
            SortCorners(x1, y1, x2, y2);
            w := x2 - x1 + 1;

            FillSpan(LineOffset[y1] + x1, w, c);
            if y1 = y2 then exit;
            FillSpan(LineOffset[y2] + x1, w, c);

            VSpan(LineOffset[y1 + 1] + x1, y2 - y1 - 1, c);
            VSpan(LineOffset[y1 + 1] + x2, y2 - y1 - 1, c);
        end;

    ////////////////////////////////////////////

    procedure FilledRectangle(x1, y1, x2, y2: Word; c, cf: Byte);
        var
            w, yy: Word;

        begin
            Rectangle(x1, y1, x2, y2, c);

            SortCorners(x1, y1, x2, y2);
            if (x2 - x1 < 2) or (y2 - y1 < 2) then exit;  // no inner area

            w := x2 - x1 - 1;
            for yy := y1 + 1 to y2 - 1 do
                FillSpan(LineOffset[yy] + x1 + 1, w, cf);
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