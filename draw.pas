unit draw;

// Low-level routines: asm/draw.asm


interface
    var
        LineOffset: array[0..199] of Word;

    procedure PutPixel(x, y: Word; color: Byte);
    procedure PutPixelOffset(pos: Word; color: Byte); pascal; external name 'DRAW_PUTPIXELOFFSET';
    procedure SetPalette(Color, R, G, B: Byte); pascal; external name 'DRAW_SETPALETTE';
    procedure DelayUS(CXValue, DXValue: Word); pascal; external name 'DRAW_DELAYUS';
    procedure DelayMS(msec: Word);
    procedure Square(x, y, s: Word; c: Byte);
    procedure FilledSquare(x, y, s: Word; c, cf: Byte);
    procedure Rectangle(x1, y1, x2, y2: Word; c: Byte);
    procedure FilledRectangle(x1, y1, x2, y2: Word; c, cf: Byte);
    procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte); pascal; external name 'DRAW_LINE';

    function GetPixelOffset(pixel_offset: Word): Byte; pascal; external name 'DRAW_GETPIXELOFFSET';

implementation

{$L asm/draw.obj}

    var
        y: Word;

    // horizontal span: count pixels from offset, 2 pixels per write
    procedure FillSpan(ofs, count: Word; color: Byte); pascal; external name 'DRAW_FILLSPAN';

    // vertical span: count pixels down from offset
    procedure VSpan(ofs, count: Word; color: Byte); pascal; external name 'DRAW_VSPAN';

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

begin
    for y := 0 to 199 do
        LineOffset[y] := y * 320;
end.
