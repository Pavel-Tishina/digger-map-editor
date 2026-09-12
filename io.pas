unit io;

{$ASMMODE INTEL}

interface

    // FILE
    function CreateFile(FileName: PChar): Word;
    
    function OpenFileRead(FileName: PChar): Word;
    function OpenFileWrite(FileName: PChar): Word;

    function ReadFile(Handle: Word; Buffer: Pointer; Count: Word): Word;
    function WriteFile(Handle: Word; Buffer: Pointer; Count: Word): Word;
    function CloseFile(Handle: Word): Boolean;
    
    function CheckFileExist(Name: PChar): Boolean;

    function FileSeek(Handle: Word; Pos: LongInt; Origin: Byte): LongInt;
    function FileSize(FileHandle: Word): LongInt;

    // DIR / FILE LIST
    // Scans directory Path (e.g. '\DRAFT\') for files with the .PIC extension
    // and stores their names into the caller buffer List, which must be an
    // array of String[12] (each element 13 bytes). Returns the number of
    // stored names.
    function FindFiles(Path: PChar; List: Pointer; MaxCount: Word): Word;

    // Returns the total number of .PIC files in directory Path.
    function CountLVLFiles(Path: PChar): Word;

    // KEYBOARD
    function KeyPressed: Boolean;
    function ReadKey: Word;

    // APP
    procedure CloseApp;

implementation

    function CreateFile(FileName: PChar): Word; assembler;
        asm
            mov ah, 3Ch
            xor cx, cx          { a regular file }

            // lds dx, FileName  { lds doesn't work inline }
            mov dx, FileName    { DS:DX -> ASCIIZ filename } 

            int 21h

            jnc @@ok

            mov ax, $FFFF       { error }

        @@ok:
        end;

    ////////////////////////////////////////////

    function OpenFileWrite(FileName: PChar): Word; assembler;
        asm 
            mov ah, 3Dh 
            mov al, 01h          { Open existing file, write only } 
            // lds dx, FileName  { DS:DX -> ASCIIZ filename } 
            mov dx, FileName     { DS:DX -> ASCIIZ filename } 
            
            int 21h
            
            jnc @@OK             { CF=0 -> success } 
            
            mov ax, $FFFF        { error } 
            
        @@OK:
            
        end;

    ////////////////////////////////////////////

    function OpenFileRead(FileName: PChar): Word; assembler;
        asm
            mov ah, 3Dh
            xor al, al           { Read Only }

            // lds dx, FileName  { DS:DX -> имя файла }
            mov dx, FileName     { DS:DX -> ASCIIZ filename } 

            int 21h

            jc @@error          { Если ошибка }
                                { AX уже содержит Handle }
            jmp @@exit

        @@error:
            mov ax, $FFFF        { Handle = -1 }

        @@exit:
        end;

    ////////////////////////////////////////////

    function WriteFile(Handle: Word; Buffer: Pointer; Count: Word): Word; assembler;
        asm
            mov ah,40h

            mov bx,Handle
            mov cx,Count

            les dx,Buffer

            int 21h

            jc @@error

            { AX = already keep count of writed bytes }
            jmp @@exit

        @@error:
                mov ax,$FFFF

        @@exit:
        end;

    ////////////////////////////////////////////

    function ReadFile(Handle: Word; Buffer: Pointer; Count: Word): Word; assembler;
        asm
            push ds

            mov ah,3Fh

            mov bx,Handle
            mov cx,Count

            mov dx,Buffer

            int $21

            pop ds

            jc @@error

            jmp @@exit

        @@error:
            mov ax,$FFFF

        @@exit:
        end;

    ////////////////////////////////////////////

    function CloseFile(Handle: Word): Boolean; assembler;
        asm
            mov ah,3Eh

            mov bx,Handle

            int 21h

            jc @@error

            mov al,1
            jmp @@exit

        @@error:
            xor al,al

        @@exit:
        end;

    ////////////////////////////////////////////

    function CheckFileExist(Name: PChar): Boolean; assembler;
        asm
            mov ah,3Dh
            xor al,al          { read only }

            mov dx,Name

            int 21h

            jc @@no

            mov bx,ax           { AX = handle }

            mov ah,3Eh
            int 21h


            mov al,1
            jmp @@exit


        @@no:
            xor al,al


        @@exit:
        end;

    ////////////////////////////////////////////

    // Origin = 0 - from start of file
    // Origin = 1 - from current position
    // Origin = 2 - from end of file
    function FileSeek(Handle: Word; Pos: LongInt; Origin: Byte): LongInt; assembler;
        asm
            mov ah,42h

            mov al,Origin

            mov bx,Handle

            mov dx,word ptr Pos
            mov cx,word ptr Pos+2

            int 21h

            jc @@error

            { result DX:AX is already LongInt }
            jmp @@exit

        @@error:
            mov ax,$FFFF
            mov dx,$FFFF

        @@exit:
        end;
        
        ////////////////////////////////////////////

    function FileSize(FileHandle: Word): LongInt; assembler;
        asm
            mov bx, FileHandle
            mov ax, $4202
            xor cx, cx
            xor dx, dx
            int $21
            jc @error
            jmp @exit

        @error:
            xor ax, ax
            xor dx, dx

        @exit:
        end;

    ////////////////////////////////////////////

    var
        DTA_Buf: array[0..42] of Byte;
        SearchSpec: array[0..80] of Byte;

    function CountLVLFiles(Path: PChar): Word; assembler;
        asm
            { Set DTA (AH=1Ah): DS:DX -> DTA_Buf }
            mov ah, 1Ah
            mov dx, offset DTA_Buf
            int 21h

            { build search spec: Path + '*.PIC' }
            mov si, Path
            mov di, offset SearchSpec
            push ds
            pop es
            cld
        @@CopyPath:
            mov al, [si]
            inc si
            mov [di], al
            inc di
            test al, al
            jnz @@CopyPath
            dec di                      { step back over the null }

            mov byte ptr [di], '*'
            inc di
            mov byte ptr [di], '.'
            inc di
            mov byte ptr [di], 'L'
            inc di
            mov byte ptr [di], 'V'
            inc di
            mov byte ptr [di], 'L'
            inc di
            mov byte ptr [di], 0

            { FindFirst (AH=4Eh): DS:DX -> search spec, CX = attributes ($10 = also dirs) }
            mov ah, 4Eh
            mov dx, offset SearchSpec
            mov cx, $10
            int 21h
            jnc @@HaveFirst

            xor ax, ax                      { no files }
            jmp @@Exit

        @@HaveFirst:
            xor dx, dx                      { DX = counter }

        @@Loop:
            { skip directories via the attribute byte at DTA+21 }
            test byte ptr [DTA_Buf + 21], $10
            jnz @@Next
            inc dx

        @@Next:
            mov ah, 4Fh                     { FindNext }
            int 21h
            jnc @@Loop

            mov ax, dx

        @@Exit:
        end;

    function FindFiles(Path: PChar; List: Pointer; MaxCount: Word): Word; assembler;
        asm
            { Set DTA (AH=1Ah): DS:DX -> DTA_Buf }
            mov ah, 1Ah
            mov dx, offset DTA_Buf
            int 21h

            { build search spec: Path + '*.PIC' }
            mov si, Path
            mov di, offset SearchSpec
            push ds
            pop es
            cld
        @@CopyPath:
            mov al, [si]
            inc si
            mov [di], al
            inc di
            test al, al
            jnz @@CopyPath
            dec di                      { step back over the null }

            mov byte ptr [di], '*'
            inc di
            mov byte ptr [di], '.'
            inc di
            mov byte ptr [di], 'L'
            inc di
            mov byte ptr [di], 'V'
            inc di
            mov byte ptr [di], 'L'
            inc di
            mov byte ptr [di], 0

            { FindFirst (AH=4Eh): DS:DX -> search spec, CX = attributes ($10 = also dirs) }
            mov ah, 4Eh
            mov dx, offset SearchSpec
            mov cx, $10
            int 21h
            jnc @@HaveFirst

            xor ax, ax                      { no files }
            jmp @@Exit

        @@HaveFirst:
            xor dx, dx                      { DX = count of stored names }
            mov bx, List                    { BX = output pointer (element = String[12]) }

        @@Loop:
            { skip directories: DTA+21 holds the found file attributes }
            test byte ptr [DTA_Buf + 21], $10
            jnz @@Next

            cmp dx, MaxCount                { buffer full? }
            jae @@Done

            { measure filename length (DTA+30.., ASCIIZ, max 12) }
            mov si, offset DTA_Buf + 30
            xor cx, cx
        @@LenLoop:
            cmp byte ptr [si], 0
            je @@LenDone
            inc si
            inc cx
            cmp cx, 12
            jb @@LenLoop
        @@LenDone:
            { store ShortString[12]: length byte + chars }
            mov byte ptr [bx], cl
            mov di, bx
            inc di
            mov si, offset DTA_Buf + 30     { reset source to filename start }
            push ds
            pop es
            cld
            rep movsb

            add bx, 13                      { next String[12] element }
            inc dx                          { count++ }

        @@Next:
            mov ah, 4Fh                     { FindNext }
            int 21h
            jnc @@Loop

        @@Done:
            mov ax, dx

        @@Exit:
        end;

    ////////////////////////////////////////////

    function KeyPressed: Boolean; assembler;
        asm
            mov ah,01h
            int 16h

            jz @@NoKey

            mov al,1
            jmp @@Exit

        @@NoKey:
            xor al,al

        @@Exit:
        end;

    ////////////////////////////////////////////

    function ReadKey: Word; assembler;
        asm
            xor ah,ah
            int 16h
            { AX already has a result}
        end;

    ////////////////////////////////////////////

    procedure CloseApp; assembler;
        asm
            mov ax, 4c00h
            int 21h
        end;    

    ////////////////////////////////////////////

end.