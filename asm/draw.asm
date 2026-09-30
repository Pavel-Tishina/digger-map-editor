; draw.asm - VGA mode 13h drawing routines for unit draw
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX.
;          Byte params take a whole stack word (value in the low byte).

cpu 8086

VIDEO_SEG equ 0A000h

segment _TEXT public align=1 use16 class=CODE

global DRAW_PUTPIXELOFFSET
global DRAW_GETPIXELOFFSET
global DRAW_SETPALETTE
global DRAW_DELAYUS
global DRAW_FILLSPAN
global DRAW_VSPAN
global DRAW_LINE

; procedure PutPixelOffset(pos: Word; color: Byte);
;   [bp+6] = pos
;   [bp+4] = color
DRAW_PUTPIXELOFFSET:
        push bp
        mov bp, sp
        push es

        mov ax, VIDEO_SEG
        mov es, ax

        mov bx, [bp+6]
        mov al, [bp+4]
        mov [es:bx], al

        pop es
        pop bp
        ret 4

; function GetPixelOffset(pixel_offset: Word): Byte;
;   [bp+4] = pixel_offset
DRAW_GETPIXELOFFSET:
        push bp
        mov bp, sp
        push es

        mov ax, VIDEO_SEG
        mov es, ax

        mov bx, [bp+4]
        mov al, [es:bx]

        pop es
        pop bp
        ret 2

; procedure SetPalette(Color, R, G, B: Byte);
;   [bp+10] = Color
;   [bp+8]  = R
;   [bp+6]  = G
;   [bp+4]  = B
DRAW_SETPALETTE:
        push bp
        mov bp, sp

        mov dx, 3C8h
        mov al, [bp+10]
        out dx, al

        inc dx                  ; DX = 3C9h

        mov al, [bp+8]
        out dx, al
        mov al, [bp+6]
        out dx, al
        mov al, [bp+4]
        out dx, al

        pop bp
        ret 8

; procedure DelayUS(CXValue, DXValue: Word);
;   [bp+6] = CXValue
;   [bp+4] = DXValue
DRAW_DELAYUS:
        push bp
        mov bp, sp

        mov ah, 86h
        mov cx, [bp+6]
        mov dx, [bp+4]
        int 15h

        pop bp
        ret 4

; procedure FillSpan(ofs, count: Word; color: Byte);
;   horizontal span: count pixels from offset, 2 pixels per write
;   [bp+8] = ofs
;   [bp+6] = count
;   [bp+4] = color
DRAW_FILLSPAN:
        push bp
        mov bp, sp
        push es
        push di

        mov ax, VIDEO_SEG
        mov es, ax

        mov di, [bp+8]
        mov cx, [bp+6]
        mov al, [bp+4]
        mov ah, al

        cld
        shr cx, 1               ; words, CF = odd pixel
        rep stosw               ; rep/stos do not change flags
        adc cx, cx              ; cx = 0 -> cx = CF
        rep stosb

        pop di
        pop es
        pop bp
        ret 6

; procedure VSpan(ofs, count: Word; color: Byte);
;   vertical span: count pixels down from offset
;   [bp+8] = ofs
;   [bp+6] = count
;   [bp+4] = color
DRAW_VSPAN:
        push bp
        mov bp, sp
        push es
        push di

        mov ax, VIDEO_SEG
        mov es, ax

        mov di, [bp+8]
        mov cx, [bp+6]
        mov al, [bp+4]

        jcxz .done              ; loop with cx = 0 would run 65536 times
.next:
        mov [es:di], al
        add di, 320
        loop .next
.done:
        pop di
        pop es
        pop bp
        ret 6

; procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);
;   Bresenham, all octants
;   [bp+12] = X1
;   [bp+10] = Y1
;   [bp+8]  = X2
;   [bp+6]  = Y2
;   [bp+4]  = Color
;
;   locals          registers
;   [bp-2] = DX     SI = X
;   [bp-4] = DY     DI = Y
;   [bp-6] = SX     DX = Err
;   [bp-8] = SY     AX = E2
%define L_DX  word [bp-2]
%define L_DY  word [bp-4]
%define L_SX  word [bp-6]
%define L_SY  word [bp-8]

DRAW_LINE:
        push bp
        mov bp, sp
        sub sp, 8
        push es
        push si
        push di

        mov ax, VIDEO_SEG
        mov es, ax

        mov si, [bp+12]         ; X = X1
        mov di, [bp+10]         ; Y = Y1

        ; DX = abs(X2 - X1), SX = direction X
        mov ax, [bp+8]
        sub ax, si
        mov cx, 1
        test ax, ax
        jge .dx_positive
        neg ax
        neg cx
.dx_positive:
        mov L_DX, ax
        mov L_SX, cx

        ; DY = -abs(Y2 - Y1), SY = direction Y
        mov ax, [bp+6]
        sub ax, di
        mov cx, 1
        test ax, ax
        jl .dy_negative         ; already -abs(...)
        neg ax
        jmp .dy_done
.dy_negative:
        neg cx
.dy_done:
        mov L_DY, ax
        mov L_SY, cx

        ; Err = DX + DY
        mov dx, L_DX
        add dx, ax

.loop:
        ; PutPixel(X, Y): offset = Y * 320 + X = (Y shl 8) + (Y shl 6) + X
        mov bx, di
        mov cl, 6
        shl bx, cl
        mov ax, bx
        shl ax, 1
        shl ax, 1
        add bx, ax
        add bx, si
        mov al, [bp+4]
        mov [es:bx], al

        ; if X = X2 and Y = Y2 -> end
        cmp si, [bp+8]
        jne .continue
        cmp di, [bp+6]
        je .done

.continue:
        ; E2 = 2 * Err
        mov ax, dx
        add ax, ax

        ; if E2 >= DY then Err += DY; X += SX
        cmp ax, L_DY
        jl .skip_x
        add dx, L_DY
        add si, L_SX
.skip_x:
        ; if E2 <= DX then Err += DX; Y += SY
        cmp ax, L_DX
        jg .skip_y
        add dx, L_DX
        add di, L_SY
.skip_y:
        jmp .loop

.done:
        pop di
        pop si
        pop es
        mov sp, bp
        pop bp
        ret 10
