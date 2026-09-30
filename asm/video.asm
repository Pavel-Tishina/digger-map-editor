; video.asm - BIOS video / keyboard routines for unit video
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX.

cpu 8086

segment _TEXT public align=1 use16 class=CODE

global VIDEO_SETVIDEOMODE13H
global VIDEO_SETTEXTMODE
global VIDEO_WAITKEY

; procedure SetVideoMode13h;
VIDEO_SETVIDEOMODE13H:
        mov ax, 0013h
        int 10h
        ret

; procedure SetTextMode;
VIDEO_SETTEXTMODE:
        mov ax, 0003h
        int 10h
        ret

; procedure WaitKey;
VIDEO_WAITKEY:
        mov ah, 00h
        int 16h
        ret
