; back.asm - DOS memory and far copy routines for unit _back
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX.

cpu 8086

segment _TEXT public align=1 use16 class=CODE

global BACK_DOSALLOC
global BACK_DOSFREE
global BACK_FARCOPY

; function DosAlloc(paragraphs: Word): Word;
;   [bp+4] = paragraphs
;   returns segment of the block, 0 on error
BACK_DOSALLOC:
        push bp
        mov bp, sp

        mov ah, 48h
        mov bx, [bp+4]
        int 21h
        jnc .ok
        xor ax, ax              ; error -> 0
.ok:
        pop bp
        ret 2

; procedure DosFree(segm: Word);
;   [bp+4] = segm
BACK_DOSFREE:
        push bp
        mov bp, sp
        push es

        mov ax, [bp+4]
        mov es, ax
        mov ah, 49h
        int 21h

        pop es
        pop bp
        ret 2

; procedure FarCopy(src_seg, src_ofs, dst_seg, dst_ofs, count: Word);
;   copy count bytes: src_seg:src_ofs -> dst_seg:dst_ofs
;   [bp+12] = src_seg
;   [bp+10] = src_ofs
;   [bp+8]  = dst_seg
;   [bp+6]  = dst_ofs
;   [bp+4]  = count
BACK_FARCOPY:
        push bp
        mov bp, sp
        push ds
        push es
        push si
        push di

        mov cx, [bp+4]
        mov di, [bp+6]
        mov si, [bp+10]
        mov ax, [bp+8]
        mov es, ax
        mov ax, [bp+12]
        mov ds, ax              ; params are SS:BP based - DS may change

        cld
        shr cx, 1               ; count in words, CF = odd byte
        rep movsw               ; rep/movs do not change flags
        adc cx, cx              ; cx = 0 -> cx = CF
        rep movsb               ; last odd byte, if any

        pop di
        pop si
        pop es
        pop ds
        pop bp
        ret 10
