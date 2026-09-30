; io.asm - DOS file / directory / keyboard routines for unit io
;
; Target : FPC 3.2.2 i8086-msdos, small memory model (NASM, -f obj)
; Calling: pascal - params pushed left to right, callee pops them,
;          near calls. Result: Byte/Boolean in AL, Word in AX,
;          LongInt in DX:AX. Pointers / PChar / var params are near (DS).

cpu 8086

segment _TEXT public align=1 use16 class=CODE

global IO_CREATEFILE
global IO_OPENFILEREAD
global IO_OPENFILEWRITE
global IO_READFILE
global IO_WRITEFILE
global IO_CLOSEFILE
global IO_CHECKFILEEXIST
global IO_FILESEEK
global IO_FILESIZE
global IO_FINDFIRST
global IO_FINDNEXT
global IO_COUNTLVLFILES
global IO_FINDFILES
global IO_KEYPRESSED
global IO_READKEY
global IO_CLOSEAPP

; ------------------------------------------------------------------
; FILE
; ------------------------------------------------------------------

; function CreateFile(FileName: PChar): Word;
;   [bp+4] = FileName
;   returns handle, $FFFF on error
IO_CREATEFILE:
        push bp
        mov bp, sp

        mov ah, 3Ch
        xor cx, cx              ; a regular file
        mov dx, [bp+4]          ; DS:DX -> ASCIIZ filename
        int 21h
        jnc .ok
        mov ax, 0FFFFh          ; error
.ok:
        pop bp
        ret 2

; function OpenFileRead(FileName: PChar): Word;
;   [bp+4] = FileName
;   returns handle, $FFFF on error
IO_OPENFILEREAD:
        push bp
        mov bp, sp

        mov ah, 3Dh
        xor al, al              ; read only
        mov dx, [bp+4]          ; DS:DX -> ASCIIZ filename
        int 21h
        jnc .ok
        mov ax, 0FFFFh          ; error
.ok:
        pop bp
        ret 2

; function OpenFileWrite(FileName: PChar): Word;
;   [bp+4] = FileName
;   returns handle, $FFFF on error
IO_OPENFILEWRITE:
        push bp
        mov bp, sp

        mov ah, 3Dh
        mov al, 01h             ; open existing file, write only
        mov dx, [bp+4]          ; DS:DX -> ASCIIZ filename
        int 21h
        jnc .ok
        mov ax, 0FFFFh          ; error
.ok:
        pop bp
        ret 2

; function ReadFile(Handle: Word; Buffer: Pointer; Count: Word): Word;
;   [bp+8] = Handle
;   [bp+6] = Buffer
;   [bp+4] = Count
;   returns count of read bytes, $FFFF on error
IO_READFILE:
        push bp
        mov bp, sp

        mov ah, 3Fh
        mov bx, [bp+8]
        mov dx, [bp+6]          ; DS:DX -> buffer
        mov cx, [bp+4]
        int 21h
        jnc .ok
        mov ax, 0FFFFh          ; error
.ok:
        pop bp
        ret 6

; function WriteFile(Handle: Word; Buffer: Pointer; Count: Word): Word;
;   [bp+8] = Handle
;   [bp+6] = Buffer
;   [bp+4] = Count
;   returns count of written bytes, $FFFF on error
IO_WRITEFILE:
        push bp
        mov bp, sp

        mov ah, 40h
        mov bx, [bp+8]
        mov dx, [bp+6]          ; DS:DX -> buffer
        mov cx, [bp+4]
        int 21h
        jnc .ok
        mov ax, 0FFFFh          ; error
.ok:
        pop bp
        ret 6

; function CloseFile(Handle: Word): Boolean;
;   [bp+4] = Handle
IO_CLOSEFILE:
        push bp
        mov bp, sp

        mov ah, 3Eh
        mov bx, [bp+4]
        int 21h
        jc .error
        mov al, 1
        jmp .exit
.error:
        xor al, al
.exit:
        pop bp
        ret 2

; function CheckFileExist(Name: PChar): Boolean;
;   [bp+4] = Name
IO_CHECKFILEEXIST:
        push bp
        mov bp, sp

        mov ah, 3Dh
        xor al, al              ; read only
        mov dx, [bp+4]
        int 21h
        jc .no

        mov bx, ax              ; AX = handle
        mov ah, 3Eh
        int 21h

        mov al, 1
        jmp .exit
.no:
        xor al, al
.exit:
        pop bp
        ret 2

; function FileSeek(Handle: Word; Pos: LongInt; Origin: Byte): LongInt;
;   Origin = 0 - from start of file
;   Origin = 1 - from current position
;   Origin = 2 - from end of file
;   [bp+10] = Handle
;   [bp+8]  = Pos (high word)
;   [bp+6]  = Pos (low word)
;   [bp+4]  = Origin
;   returns new position in DX:AX, -1 on error
IO_FILESEEK:
        push bp
        mov bp, sp

        mov ah, 42h
        mov al, [bp+4]
        mov bx, [bp+10]
        mov dx, [bp+6]
        mov cx, [bp+8]
        int 21h
        jnc .ok
        mov ax, 0FFFFh
        mov dx, 0FFFFh
.ok:
        pop bp
        ret 8

; function FileSize(FileHandle: Word): LongInt;
;   [bp+4] = FileHandle
;   moves the file pointer to the end of the file
;   returns size in DX:AX, 0 on error
IO_FILESIZE:
        push bp
        mov bp, sp

        mov bx, [bp+4]
        mov ax, 4202h
        xor cx, cx
        xor dx, dx
        int 21h
        jnc .ok
        xor ax, ax
        xor dx, dx
.ok:
        pop bp
        ret 2

; ------------------------------------------------------------------
; DIR / FILE LIST
; DTA (43 bytes): +21 attributes, +30 ASCIIZ file name
; ------------------------------------------------------------------

; function FindFirst(Pattern: PChar; var DTA: TDTA): Word;
;   [bp+6] = Pattern
;   [bp+4] = @DTA
;   returns 0 if found, DOS error code otherwise
IO_FINDFIRST:
        push bp
        mov bp, sp

        mov dx, [bp+4]          ; DS:DX -> DTA (small model: DS = SS)
        mov ah, 1Ah             ; set current DTA
        int 21h

        mov ah, 4Eh             ; Find First
        mov dx, [bp+6]          ; DS:DX -> null-terminated pattern
        mov cx, 10h             ; attribute: include dirs (filtered by caller)
        int 21h
        jc .exit
        xor ax, ax
.exit:
        pop bp
        ret 4

; function FindNext(var DTA: TDTA): Word;
;   [bp+4] = @DTA (continues with the current DTA)
;   returns 0 if found, DOS error code otherwise
IO_FINDNEXT:
        mov ah, 4Fh
        int 21h
        jc .exit
        xor ax, ax
.exit:
        ret 2

; internal: set DTA and build search spec Path + '*.DLF'
;   in : SI -> Path (ASCIIZ), DI -> Spec buffer, DX -> DTA buffer
;   out: Spec filled, DTA set, SI/DI/AX destroyed, ES = DS
build_spec:
        mov ah, 1Ah             ; set DTA: DS:DX -> DTA buffer
        int 21h

        push ds
        pop es
        cld
.copy_path:
        lodsb
        stosb
        test al, al
        jnz .copy_path
        dec di                  ; step back over the null

        mov al, '*'
        stosb
        mov al, '.'
        stosb
        mov al, 'D'
        stosb
        mov al, 'L'
        stosb
        mov al, 'F'
        stosb
        xor al, al
        stosb
        ret

; function CountLVLFiles(Path, Spec: PChar; DTA: Pointer): Word;
;   Returns the total number of .DLF files in directory Path.
;   Spec (81 bytes) gets Path + '*.DLF', DTA (43 bytes) becomes current.
;   [bp+8] = Path
;   [bp+6] = Spec
;   [bp+4] = DTA
IO_COUNTLVLFILES:
        push bp
        mov bp, sp
        push si
        push di

        mov si, [bp+8]
        mov di, [bp+6]
        mov dx, [bp+4]
        call build_spec

        ; FindFirst (AH=4Eh): DS:DX -> search spec, CX = attributes ($10 = also dirs)
        mov ah, 4Eh
        mov dx, [bp+6]
        mov cx, 10h
        int 21h
        jnc .have_first

        xor ax, ax              ; no files
        jmp .exit

.have_first:
        xor dx, dx              ; DX = counter
        mov bx, [bp+4]          ; BX -> DTA

.loop:
        test byte [bx+21], 10h  ; skip directories
        jnz .next
        inc dx
.next:
        mov ah, 4Fh             ; FindNext
        int 21h
        jnc .loop

        mov ax, dx
.exit:
        pop di
        pop si
        pop bp
        ret 6

; function FindFiles(Path: PChar; List: Pointer; MaxCount: Word;
;                    Spec: PChar; DTA: Pointer): Word;
;   Scans directory Path for .DLF files and stores their names into List,
;   an array of String[12] (each element 13 bytes).
;   Returns the number of stored names.
;   [bp+12] = Path
;   [bp+10] = List
;   [bp+8]  = MaxCount
;   [bp+6]  = Spec
;   [bp+4]  = DTA
IO_FINDFILES:
        push bp
        mov bp, sp
        push si
        push di

        mov si, [bp+12]
        mov di, [bp+6]
        mov dx, [bp+4]
        call build_spec

        ; FindFirst (AH=4Eh): DS:DX -> search spec, CX = attributes ($10 = also dirs)
        mov ah, 4Eh
        mov dx, [bp+6]
        mov cx, 10h
        int 21h
        jnc .have_first

        xor ax, ax              ; no files
        jmp .exit

.have_first:
        xor dx, dx              ; DX = count of stored names
        mov bx, [bp+10]         ; BX = output pointer (element = String[12])

.loop:
        mov si, [bp+4]          ; SI -> DTA
        test byte [si+21], 10h  ; skip directories
        jnz .next

        cmp dx, [bp+8]          ; buffer full?
        jae .done

        ; measure filename length (DTA+30.., ASCIIZ, max 12)
        add si, 30
        mov di, si
        xor cx, cx
.len_loop:
        cmp byte [di], 0
        je .len_done
        inc di
        inc cx
        cmp cx, 12
        jb .len_loop
.len_done:
        ; store ShortString[12]: length byte + chars
        mov [bx], cl
        mov di, bx
        inc di
        push ds
        pop es
        cld
        rep movsb

        add bx, 13              ; next String[12] element
        inc dx

.next:
        mov ah, 4Fh             ; FindNext
        int 21h
        jnc .loop

.done:
        mov ax, dx
.exit:
        pop di
        pop si
        pop bp
        ret 10

; ------------------------------------------------------------------
; KEYBOARD
; ------------------------------------------------------------------

; function KeyPressed: Boolean;
IO_KEYPRESSED:
        mov ah, 01h
        int 16h
        jz .no_key
        mov al, 1
        ret
.no_key:
        xor al, al
        ret

; function ReadKey: Word;
;   returns the ASCII code only, 0..255
IO_READKEY:
        xor ah, ah
        int 16h
        xor ah, ah
        ret

; ------------------------------------------------------------------
; APP
; ------------------------------------------------------------------

; procedure CloseApp;
IO_CLOSEAPP:
        mov ax, 4C00h
        int 21h
        ret
