; mouse.asm - INT 33h mouse driver routines for unit _mouse
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX.

cpu 8086

segment _TEXT public align=1 use16 class=CODE

global MOUSE_INIT
global MOUSE_SETRANGE320X200
global MOUSE_SHOW
global MOUSE_HIDE
global MOUSE_READ

; function MouseInit: Boolean;
MOUSE_INIT:
        mov ax, 0000h
        int 33h

        cmp ax, 0
        je .no_mouse

        mov al, 1
        ret

.no_mouse:
        xor al, al
        ret

; procedure MouseSetRange320x200;
MOUSE_SETRANGE320X200:
        ; X range
        mov ax, 0007h
        xor cx, cx
        mov dx, 639
        int 33h

        ; Y range
        mov ax, 0008h
        xor cx, cx
        mov dx, 199
        int 33h
        ret

; procedure MouseShow;
MOUSE_SHOW:
        mov ax, 0001h
        int 33h
        ret

; procedure MouseHide;
MOUSE_HIDE:
        mov ax, 0002h
        int 33h
        ret

; procedure MouseRead(var State: TMouseState);
;   TMouseState = record X, Y, Btn: Word end
;   [bp+4] = @State
MOUSE_READ:
        push bp
        mov bp, sp

        mov ax, 0003h
        int 33h

        mov ax, cx
        shr ax, 1               ; mode 13h: driver X is 0..639
        mov cx, bx

        mov bx, [bp+4]
        mov [bx], ax            ; State.X
        mov [bx+2], dx          ; State.Y
        mov [bx+4], cx          ; State.Btn

        pop bp
        ret 2
