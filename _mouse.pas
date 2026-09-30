unit _mouse;

{$ASMMODE INTEL}

interface

type
  TMouseState = record
    X: Word;
    Y: Word;
    Btn: Word;
  end;

var
  MyMouse: TMouseState; // cuz nasty error "Duplicate" identifier "mouse" is here... damned Pascal namespaces

    function MouseInit: Boolean;

    procedure MouseSetRange320x200;
    procedure MouseShow;
    procedure MouseHide;

    procedure MouseUpdate;
    
implementation

    function MouseInit: Boolean; assembler;
        asm
            mov ax,$0000
            int $33

            cmp ax,0
            je @@no_mouse

            mov al,1
            jmp @@exit

        @@no_mouse:
            xor al,al

        @@exit:
        end;


    procedure MouseSetRange320x200; assembler;
        asm
            { X range }
            mov ax,$0007
            xor cx,cx
            mov dx,639
            int $33

            { Y range }
            mov ax,$0008
            xor cx,cx
            mov dx,199
            int $33
        end;

    
    procedure MouseShow; assembler;
        asm
            mov ax,$0001
            int $33
        end;

    
    procedure MouseHide; assembler;
        asm
            mov ax,0002h
            int 33h
        end;

    
    procedure MouseUpdate; assembler;
        asm
            push ds

            mov ax, seg MyMouse
            mov ds, ax

            mov ax, $0003
            int $33

            mov ax, cx
            shr ax, 1
            mov MyMouse.X, ax
            mov MyMouse.Y, dx
            mov MyMouse.Btn, bx

            pop ds
        end;

end.