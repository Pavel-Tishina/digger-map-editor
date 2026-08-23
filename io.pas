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