{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

// Saved screen area under a window.
// The buffer lives in DOS conventional memory (INT 21h / 48h),
// NOT in the near heap: the whole near heap is < 64K and a 166x166
// window background does not fit there (Runtime error 203).
unit _back;

interface

uses
  draw;

const
  VIDEO_SEG = $A000;

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

{$L asm/back.obj}

  // DOS INT 21h / 48h: returns segment of the block, 0 on error
  function DosAlloc(paragraphs: Word): Word; pascal; external name 'BACK_DOSALLOC';

  // DOS INT 21h / 49h
  procedure DosFree(segm: Word); pascal; external name 'BACK_DOSFREE';

  // copy count bytes: src_seg:src_ofs -> dst_seg:dst_ofs
  procedure FarCopy(src_seg, src_ofs, dst_seg, dst_ofs, count: Word); pascal; external name 'BACK_FARCOPY';

  // // // // // // // //

  constructor TBackGround.Create(x1, y1, x2, y2: Word);
    var
      _y, _o : Word;

    begin
      // bounds are inclusive
      _w := x2 - x1 + 1;
      _h := y2 - y1 + 1;
      // 16-bit math is enough: a mode 13h area is at most 64000 bytes
      _seg := DosAlloc((_w * _h + 15) shr 4);

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
