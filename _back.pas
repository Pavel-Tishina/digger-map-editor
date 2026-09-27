{$MODE OBJFPC}

// Saved screen area under a window.
// The buffer lives in DOS conventional memory (INT 21h / 48h),
// NOT in the near heap: the whole near heap is < 64K and a 166x166
// window background does not fit there (Runtime error 203).
unit _back;

interface

uses
  draw, _types;

type
  TBackGround = class
    _seg : Word;   // DOS memory block segment, 0 = not allocated
    _w   : Word;   // width in pixels
    _h   : Word;   // height in lines

    constructor Create(x1, y1, x2, y2: Word);
    procedure Draw(x, y: Word);
    function IsNull: Boolean;
    destructor Destroy; override;

  end;

implementation

  function DosAlloc(paragraphs: Word): Word; assembler;
    asm
      mov ah, 48h
      mov bx, paragraphs
      int 21h
      jnc @@ok
      xor ax, ax          { error -> 0 }
    @@ok:
    end;

  // // // // // // // //

  procedure DosFree(segm: Word); assembler;
    asm
      push es
      mov ax, segm
      mov es, ax
      mov ah, 49h
      int 21h
      pop es
    end;

  // // // // // // // //

  // copy count bytes: src_seg:src_ofs -> dst_seg:dst_ofs
  procedure FarCopy(src_seg, src_ofs, dst_seg, dst_ofs, count: Word); assembler;
    asm
      push ds
      push es
      push si
      push di

      mov cx, count
      mov di, dst_ofs
      mov si, src_ofs
      mov ax, dst_seg
      mov es, ax
      mov ax, src_seg
      mov ds, ax          { params are SS:BP based - DS may change }

      cld
      rep movsb

      pop di
      pop si
      pop es
      pop ds
    end;

  // // // // // // // //

  constructor TBackGround.Create(x1, y1, x2, y2: Word);
    const
      VIDEO_SEG = $A000;
    var
      _y, _o : Word;
    begin
      // bounds are inclusive
      _w := x2 - x1 + 1;
      _h := y2 - y1 + 1;
      _seg := DosAlloc((LongInt(_w) * _h + 15) shr 4);

      if _seg = 0 then exit;

      _o := 0;
      for _y := y1 to y2 do
        begin
          FarCopy(VIDEO_SEG, LineOffset[_y] + x1, _seg, _o, _w);
          inc(_o, _w);
        end;
    end;

  // // // // // // // //

  procedure TBackGround.Draw(x, y: Word);
    const
      VIDEO_SEG = $A000;
    var
      _y, _o : Word;
    begin
      if _seg = 0 then exit;

      _o := 0;
      for _y := y to y + _h - 1 do
        begin
          FarCopy(_seg, _o, VIDEO_SEG, LineOffset[_y] + x, _w);
          inc(_o, _w);
        end;
    end;

  // // // // // // // //

  function TBackGround.IsNull: Boolean;
    begin
      Result := _seg = 0;
    end;

  // // // // // // // //

  destructor TBackGround.Destroy;
    begin
      if _seg <> 0 then
        DosFree(_seg);
      _seg := 0;
      inherited Destroy;
    end;

end.
