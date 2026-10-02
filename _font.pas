{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _font;

interface

uses
  _ag, draw;

  procedure DrawString(x, y : Word; const s : String);

implementation

  const
    _s  : String[66] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?~-+''"\/()[]{}.,:;=_<>#&%^*|@';
    _r  = 8;    // letter size (8x8)
    _xn = 22;   // count letters in line

  var
    _sidx: Byte;
    _index   : array[Char] of Byte;      // char -> symbol number, 0 = no glyph
    _font_file : ArchiveGraphicFile;     // letters are drawn straight from its pixels

  procedure DrawLetter(x, y: Word; c: Char);
    var
      _n : Byte;

    begin
      _n := _index[c];
      if _n = 0 then exit;
      dec(_n);

      // glyph _n: row _n div _xn, column _n mod _xn of the font image
      with _font_file do
        BlitTransparent(@pixels[(_n div _xn) * _r * xm + (_n mod _xn) * _r],
          LineOffset[y] + x, _r, _r, xm, bg_color);
    end;

  procedure DrawString(x, y : Word; const s : String);
    var
      _i : Word;

    begin
      if length(_font_file.pixels) = 0 then exit;   // no font file

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
end.
