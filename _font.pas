{$MODE OBJFPC}

unit _font;

interface

uses
  _ag, _types, draw;

  procedure DrawString(x, y : Word; const s : String);

implementation

  const
    _s  : String[66] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?~-+''"\/()[]{}.,:;=_<>#&%^*|@';
    _r  = 8;    // letter size (8x8)
    _xn = 21;   // count letters in line
    _yn = 2;    // count lines

  type
    TGlyph = array[0.._r - 1, 0.._r - 1] of Byte;   // [y, x]

  var
    _x, _y: Word;
    _cf, _sidx, _xl, _yl: Byte;
    _symbols : array[1..66] of TGlyph;   // static: 4224 bytes, no heap
    _index   : array[Char] of Byte;      // char -> symbol number, 0 = no glyph
    _full_img : ImageData;
    _font_file : ArchiveGraphicFile;

  procedure LoadLetter(n: Byte; xp, yp : Word; const img: ImageData);
    var
      _x, _y : Byte;

    begin
      for _y := 0 to _r - 1 do
        for _x := 0 to _r - 1 do
          _symbols[n, _y, _x] := img[xp + _x, yp + _y];
    end;

  procedure DrawLetter(x, y: Word; c: Char);
    begin
      if _index[c] = 0 then exit;

      // TGlyph is [y, x]: 8 rows of 8 bytes
      BlitTransparent(@_symbols[_index[c]], LineOffset[y] + x, _r, _r, _r, _cf);
    end;

  procedure DrawString(x, y : Word; const s : String);
    var
      _i : Word;

    begin
      for _i := 1 to Length(s) do
        if s[_i] <> ' ' then
          DrawLetter(x + ((_i - 1) * _r), y, s[_i]);
    end;

begin
  FillChar(_index, SizeOf(_index), 0);
  for _sidx := 1 to Length(_s) do
    begin
      _index[_s[_sidx]] := _sidx;
      _index[LowerCase(_s[_sidx])] := _sidx;   // lower case -> same glyph
    end;

  _font_file := ArchiveGraphicFile.Init('\DRAFT\ABC_V2.CG2'#0);

  _cf := _font_file.GetTrasperentColor;
  _full_img := _font_file.GetImg2;

  _sidx := 1;
  _y := 0;
  for _yl := 0 to _yn do
    begin
      _x := 0;

      for _xl := 0 to _xn do
        begin
          LoadLetter(_sidx, _x, _y, _full_img);

          inc(_x, _r);
          inc(_sidx);
        end;
      inc(_y, _r);
    end;

  // font image and packed file data are not needed anymore
  _full_img := nil;
  _font_file.Free;
end.
