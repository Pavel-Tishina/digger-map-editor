{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
{$INLINE ON}

unit _ag;

interface

uses
  io, draw, _types;

type
  ArchiveGraphicFile = class
  public
    bg_color: Byte;
    pixcount, xm: Word;
    pixels: ByteData;     // decoded image, xm pixels per row, pixcount pixels

    constructor Init(file_name: PChar);

    function GetTrasperentColor: Byte; inline;

    procedure Draw2(x, y: Word);

  private
    procedure Decode(start, size: Word; bits: Byte; const palette: array of Byte);

  end;

implementation

    const
      BUF_SIZE = 2048;    // the largest used file, ABC_V2.CG2, is 1790 bytes

    var
      // one read buffer for all files: a file is decoded right after reading
      _buf: array[0..BUF_SIZE - 1] of Byte;

        // ArchiveGraphicFile

    // file: 5 bytes header, palette (4 bits per color), RLE image data
    //   [0]    low nibble: colors, high nibble: format version
    //   [1..2] low 12 bits: image width, high 4 bits: transparent color
    //   [3..4] pixel count
    constructor ArchiveGraphicFile.Init(file_name: PChar);
        var
          _h, _size : Word;
          _colors, _bits, _n : Byte;
          _palette : array[0..15] of Byte;

        begin
          _h := OpenFileRead(file_name);
          if _h = $FFFF then exit;          // no file: empty image, Draw2 draws nothing

          _size := ReadFile(_h, @_buf, SizeOf(_buf));
          CloseFile(_h);
          if (_size = $FFFF) or (_size < 6) then exit;

          _colors := _buf[0] and $0F;

          xm := Word(_buf[1]) or (Word(_buf[2]) shl 8);
          bg_color := xm shr 12;
          xm := xm and $0FFF;

          pixcount := Word(_buf[3]) or (Word(_buf[4]) shl 8);

          // bits per color index; the palette takes as many bytes
          if _colors <= 2 then
            _bits := 1
          else if _colors <= 4 then
            _bits := 2
          else if _colors <= 8 then
            _bits := 3
          else
            _bits := 4;

          // two colors per byte, high nibble first
          for _n := 0 to 15 do
            if _n < _colors then
              if (_n and 1) = 0 then
                _palette[_n] := _buf[5 + _n shr 1] shr 4
              else
                _palette[_n] := _buf[5 + _n shr 1] and $0F;

          Decode(5 + _bits, _size, _bits, _palette);
        end;

    // unpack RLE data _buf[start..size - 1] into pixels, once - Draw2 only copies them
    //   bit 7 = 0: one byte,  run length in bits 6..bits, color index in the low bits
    //   bit 7 = 1: two bytes, longer run length, color index in the low bits of the 2nd byte
    procedure ArchiveGraphicFile.Decode(start, size: Word; bits: Byte; const palette: array of Byte);
      var
        _c, _nb, _b : Byte;
        _x, _n, _r, _cnt: Word;

      begin
        setLength(pixels, pixcount);
        _nb := (1 shl bits) - 1;
        _x := 0;

        _n := start;
        while (_n < size) do
          begin
            _b := _buf[_n];

            if (_b and $80) = 0 then
              _r := (_b shr bits) and ((1 shl (7 - bits)) - 1)
            else
              begin
                if (_n + 1 >= size) then break;
                inc(_n);
                _r := (Word(_b and $7F) shl (8 - bits)) or (_buf[_n] shr bits);
              end;

            _c := palette[_buf[_n] and _nb];

            if _x < pixcount then
              begin
                _cnt := _r;
                if _cnt > pixcount - _x then
                  _cnt := pixcount - _x;
                FillChar(pixels[_x], _cnt, _c);
              end;

            inc(_x, _r);
            inc(_n);
          end;
      end;

    function ArchiveGraphicFile.GetTrasperentColor: Byte;
      begin
        GetTrasperentColor := bg_color;
      end;

    procedure ArchiveGraphicFile.Draw2(x, y: Word);
      var
        _rows, _rest : Word;

      begin
        if (xm = 0) or (length(pixels) = 0) then exit;

        _rows := pixcount div xm;
        _rest := pixcount mod xm;   // last row may be incomplete

        if _rows > 0 then
          BlitTransparent(@pixels[0], LineOffset[y] + x, xm, _rows, xm, bg_color);

        if _rest > 0 then
          BlitTransparent(@pixels[_rows * xm], LineOffset[y + _rows] + x, _rest, 1, xm, bg_color);
      end;

end.
