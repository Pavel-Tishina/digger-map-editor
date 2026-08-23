unit gui;

{$ASMMODE INTEL}

interface

// procedure PutPixel;
procedure PutPixelOffset;
procedure Rectangle;
procedure DrawRect;

implementation

// procedure PutPixel(x, y: Word; color: Byte); assembler;
// asm
//     push bp
//     mov bp,sp

//     ; offset = y*320 + x

//     mov ax,[bp+6]       ; y
//     mov bx,ax

//     shl ax,6            ; y*64
//     shl bx,8            ; y*256
//     add ax,bx           ; y*320

//     add ax,[bp+4]       ; + x

//     mov di,ax

//     mov ax,$A000
//     mov es,ax

//     mov al,[bp+8]       ; color
//     mov es:[di],al

//     pop bp
// end;

procedure PutPixelOffset(offset: Word; color: Byte);
assembler;
asm
    mov di,offset
    mov al,color
    stosb
end;

procedure Rectangle(x1, y1, x2, y2: Word; color: Byte); assembler;
asm
    push bp
    mov  bp,sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    { стек:
      [bp+4]  = x1
      [bp+6]  = y1
      [bp+8]  = x2
      [bp+10] = y2
      [bp+12] = color
    }

    { ---------- верхняя линия ---------- }

    mov si,[bp+4]      { x=x1 }

@@TopLoop:

    mov ax,si
    mov bx,[bp+6]
    mov dl,[bp+12]

    push dx
    push bx
    push ax
    call PutPixel
    add sp,6

    inc si
    cmp si,[bp+8]
    jbe @@TopLoop


    { ---------- нижняя линия ---------- }


    mov si,[bp+4]

@@BottomLoop:

    mov ax,si
    mov bx,[bp+10]
    mov dl,[bp+12]

    push dx
    push bx
    push ax
    call PutPixel
    add sp,6

    inc si
    cmp si,[bp+8]
    jbe @@BottomLoop


    { ---------- левая ---------- }

    mov si,[bp+6]

@@LeftLoop:

    mov ax,[bp+4]
    mov bx,si
    mov dl,[bp+12]

    push dx
    push bx
    push ax
    call PutPixel
    add sp,6

    inc si
    cmp si,[bp+10]
    jbe @@LeftLoop


    { ---------- правая ---------- }

    mov si,[bp+6]

@@RightLoop:

    mov ax,[bp+8]
    mov bx,si
    mov dl,[bp+12]

    push dx
    push bx
    push ax
    call PutPixel
    add sp,6

    inc si
    cmp si,[bp+10]
    jbe @@RightLoop


    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
end;

procedure DrawRect(x1,y1,x2,y2: Word; color: Byte);
assembler;
asm
    push bp
    mov bp,sp

    push si
    push di
    push bx
    push dx


    mov ax,$A000
    mov es,ax


    ;
    ; вычисляем ширину
    ;

    mov cx,[bp+8]       ; x2
    sub cx,[bp+4]       ; x2-x1
    inc cx              ; width


    ;
    ; вычисляем начальный offset
    ; y1*320+x1
    ;

    mov ax,[bp+6]       ; y1
    mov bx,ax

    shl ax,6
    shl bx,8

    add ax,bx
    add ax,[bp+4]


    mov di,ax           ; начало строки


    ;
    ; высота
    ;

    mov dx,[bp+10]      ; y2
    sub dx,[bp+6]
    inc dx


row_loop:

    push cx
    mov al,[bp+12]


    rep stosb           ; рисуем строку


    pop cx


    ;
    ; следующий ряд
    ;
    
    add di,320
    sub di,cx


    dec dx
    jnz row_loop


    pop dx
    pop bx
    pop di
    pop si

    pop bp
end;


end.