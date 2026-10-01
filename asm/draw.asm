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
global DRAW_BLITTRANSPARENT
global DRAW_SAVERECT
global DRAW_RESTORERECT

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

; procedure BlitTransparent(src: Pointer; dst_ofs, w, h, stride: Word; key: Byte);
;   copies a w x h sprite from DS:src (rows are stride bytes apart)
;   to the screen at dst_ofs, pixels equal to key are skipped
;   [bp+14] = src
;   [bp+12] = dst_ofs
;   [bp+10] = w
;   [bp+8]  = h
;   [bp+6]  = stride
;   [bp+4]  = key
DRAW_BLITTRANSPARENT:
        push bp
        mov bp, sp
        push es
        push si
        push di

        mov ax, VIDEO_SEG
        mov es, ax

        mov si, [bp+14]
        mov di, [bp+12]
        mov dx, [bp+8]          ; DX = rows left
        mov ah, [bp+4]          ; AH = transparent color
        cmp word [bp+10], 0
        je .done
        cld

.row:
        test dx, dx
        jz .done
        mov bx, si
        add bx, [bp+6]          ; BX = next source row
        mov cx, [bp+10]
.pixel:
        lodsb
        cmp al, ah
        je .skip
        stosb
        loop .pixel
        jmp .row_end
.skip:
        inc di
        loop .pixel
.row_end:
        mov si, bx
        add di, 320
        sub di, [bp+10]         ; next screen row
        dec dx
        jmp .row

.done:
        pop di
        pop si
        pop es
        pop bp
        ret 12

; procedure SaveRect(ofs, w, h: Word; buf: Pointer);
;   copies a w x h screen area at ofs into DS:buf (w * h bytes)
;   [bp+10] = ofs
;   [bp+8]  = w
;   [bp+6]  = h
;   [bp+4]  = buf
DRAW_SAVERECT:
        push bp
        mov bp, sp
        push ds
        push es
        push si
        push di

        mov ax, ds
        mov es, ax              ; ES:DI -> buffer
        mov di, [bp+4]
        mov si, [bp+10]
        mov bx, [bp+8]          ; BX = w
        mov dx, [bp+6]          ; DX = h
        mov ax, VIDEO_SEG
        mov ds, ax              ; DS:SI -> screen, params are SS:BP based
        cld

.row:
        test dx, dx
        jz .done
        mov cx, bx
        shr cx, 1               ; words, CF = odd byte
        rep movsw
        adc cx, cx
        rep movsb
        add si, 320
        sub si, bx
        dec dx
        jmp .row

.done:
        pop di
        pop si
        pop es
        pop ds
        pop bp
        ret 8

; procedure RestoreRect(buf: Pointer; ofs, w, h: Word);
;   copies w * h bytes from DS:buf to a w x h screen area at ofs
;   [bp+10] = buf
;   [bp+8]  = ofs
;   [bp+6]  = w
;   [bp+4]  = h
DRAW_RESTORERECT:
        push bp
        mov bp, sp
        push es
        push si
        push di

        mov ax, VIDEO_SEG
        mov es, ax              ; ES:DI -> screen
        mov si, [bp+10]
        mov di, [bp+8]
        mov bx, [bp+6]          ; BX = w
        mov dx, [bp+4]          ; DX = h
        cld

.row:
        test dx, dx
        jz .done
        mov cx, bx
        shr cx, 1               ; words, CF = odd byte
        rep movsw
        adc cx, cx
        rep movsb
        add di, 320
        sub di, bx
        dec dx
        jmp .row

.done:
        pop di
        pop si
        pop es
        pop bp
        ret 8

; procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);
;   Bresenham, all octants
;   horizontal and vertical lines use fast paths
;   [bp+12] = X1
;   [bp+10] = Y1
;   [bp+8]  = X2
;   [bp+6]  = Y2
;   [bp+4]  = Color
;
;   locals                  registers
;   [bp-2] = DX             DI = screen offset of (X, Y)
;   [bp-4] = DY             DX = Err
;   [bp-6] = SX (+-1)       CX = pixels left
;   [bp-8] = SY (+-320)     BX = E2, AL = Color
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
        cld

        ; DI = Y1 * 320 + X1 = (Y1 shl 8) + (Y1 shl 6) + X1
        mov di, [bp+10]
        mov cl, 6
        shl di, cl
        mov ax, di
        shl ax, 1
        shl ax, 1
        add di, ax
        add di, [bp+12]

        ; DX = abs(X2 - X1), SX = direction X
        mov ax, [bp+8]
        sub ax, [bp+12]
        mov cx, 1
        test ax, ax
        jge .dx_positive
        neg ax
        neg cx
.dx_positive:
        mov L_DX, ax
        mov L_SX, cx

        ; DY = -abs(Y2 - Y1), SY = direction Y (one screen row)
        mov ax, [bp+6]
        sub ax, [bp+10]
        mov cx, 320
        test ax, ax
        jl .dy_negative         ; already -abs(...)
        neg ax
        jmp .dy_done
.dy_negative:
        neg cx
.dy_done:
        mov L_DY, ax
        mov L_SY, cx

        test ax, ax
        jnz .not_horizontal

        ; horizontal (or a single point): DX + 1 pixels from the leftmost end
        mov cx, L_DX
        cmp L_SX, 0
        jg .h_fill
        sub di, cx
.h_fill:
        inc cx
        mov al, [bp+4]
        rep stosb
        jmp .done

.not_horizontal:
        cmp L_DX, 0
        jne .general

        ; vertical: -DY + 1 pixels
        mov cx, ax
        neg cx
        inc cx
        mov bx, L_SY
        mov al, [bp+4]
.v_next:
        mov [es:di], al
        add di, bx
        loop .v_next
        jmp .done

.general:
        ; pixels = max(DX, -DY) + 1
        mov cx, ax
        neg cx
        cmp cx, L_DX
        jge .count_ok
        mov cx, L_DX
.count_ok:
        inc cx

        ; Err = DX + DY
        mov dx, L_DX
        add dx, ax

        mov al, [bp+4]
.loop:
        mov [es:di], al
        dec cx
        jz .done

        ; E2 = 2 * Err
        mov bx, dx
        add bx, bx

        ; if E2 >= DY then Err += DY; X += SX
        cmp bx, L_DY
        jl .skip_x
        add dx, L_DY
        add di, L_SX
.skip_x:
        ; if E2 <= DX then Err += DX; Y += SY
        cmp bx, L_DX
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
