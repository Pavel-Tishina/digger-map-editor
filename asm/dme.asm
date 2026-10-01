; dme.asm - editor specific routines for program run_dme
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX.

cpu 8086

VIDEO_SEG equ 0A000h

segment _TEXT public align=1 use16 class=CODE

global DME_DRAWBACKGROUND

PERIOD  equ 693                 ; lcm(11, 9, 7, 3) - the pattern repeats
BUFSIZE equ PERIOD + 1          ; keep SP even

; procedure DrawBackground;
;   dotted background, for every screen offset o = 0..63999:
;     o mod 11 = 0 -> color 14
;     o mod 9  = 0 -> color 13
;     o mod 7  = 0 -> color 3
;     o mod 3  = 0 -> color 2
;     otherwise      color 0 (the screen is black after the mode switch)
;   1) one period of the pattern is built in a stack buffer,
;      remainders are kept in counters, no division:
;      BL = o mod 11, BH = o mod 9, DL = o mod 7, DH = o mod 3
;   2) the period is copied over the screen with rep movsw
DME_DRAWBACKGROUND:
        push bp
        mov bp, sp
        sub sp, BUFSIZE
        push ds
        push es
        push si
        push di

        ; 1) pattern -> SS:[bp-BUFSIZE]
        push ss
        pop es
        lea di, [bp-BUFSIZE]
        mov cx, PERIOD
        xor bx, bx
        xor dx, dx
        cld

.pixel:
        mov al, 14
        test bl, bl
        jz .put
        mov al, 13
        test bh, bh
        jz .put
        mov al, 3
        test dl, dl
        jz .put
        mov al, 2
        test dh, dh
        jz .put
        xor al, al
.put:
        stosb

        inc bl
        cmp bl, 11
        jne .mod9
        xor bl, bl
.mod9:
        inc bh
        cmp bh, 9
        jne .mod7
        xor bh, bh
.mod7:
        inc dl
        cmp dl, 7
        jne .mod3
        xor dl, dl
.mod3:
        inc dh
        cmp dh, 3
        jne .loop
        xor dh, dh
.loop:
        loop .pixel

        ; 2) repeat the period over 64000 bytes of the screen
        push ss
        pop ds                  ; DS:SI -> pattern
        mov ax, VIDEO_SEG
        mov es, ax              ; ES:DI -> screen
        xor di, di
        mov dx, 64000           ; DX = bytes left

.chunk:
        mov cx, PERIOD
        cmp dx, cx
        jae .full
        mov cx, dx              ; last, incomplete period
.full:
        sub dx, cx
        lea si, [bp-BUFSIZE]
        shr cx, 1               ; words, CF = odd byte
        rep movsw
        adc cx, cx
        rep movsb
        test dx, dx
        jnz .chunk

        pop di
        pop si
        pop es
        pop ds
        mov sp, bp
        pop bp
        ret
