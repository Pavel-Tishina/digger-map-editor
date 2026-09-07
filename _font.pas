{$MODE OBJFPC}

unit _font;

interface

uses
  _ag, _types, draw;

  procedure DrawString(x, y : Word; s : String);

implementation

  const
    _s : String[66] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?~-+''"\/()[]{}.,:;=_<>#&%^*|@';
    _r : Byte = 8;
    _xn : Byte = 21;
    _yn : Byte = 2;

  var
    _x, _y: Word;
    _cf, _sidx, _xl, _yl: Byte;
    _symbols : array[1..66] of ImageData;
    _full_img : ImageData;
    _font_file : ArchiveGraphicFile;

  function LoadLetter(xp, yp : Word; img: ImageData): ImageData;
    var
      _img_out : ImageData;
      _x, _y : Word;

    begin
      setLength(_img_out, _r, _r);
      
      for _y := 0 to _r - 1 do
        for _x := 0 to _r - 1 do
          _img_out[_x, _y] := img[xp + _x, yp + _y];

      Result := _img_out;
    end;

  procedure DrawLetter(x, y : Word; c : Char);
    var
      _n, _x, _y : Byte;

    begin
      if (pos(c, _s) > 0) then
        begin
          for _n := 1 to Length(_s) do
            if _s[_n] = c then
              break;

          for _y := 0 to _r - 1 do
            for _x := 0 to _r - 1 do
              if _symbols[_n, _x, _y] <> _cf then
                PutPixelOffset(LineOffset[y + _y] + x + _x, _symbols[_n, _x, _y]);
        end;
    end;

  procedure DrawString(x, y : Word; s : String);
    var
      _i : Word;

    begin
      for _i := 1 to Length(s) do
        if s[_i] <> ' ' then
          DrawLetter(x + ((_i - 1) * _r), y, s[_i]);
    end;

begin
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
          _symbols[_sidx] := LoadLetter(_x, _y, _full_img);
              
          inc(_x, _r);
          inc(_sidx);
        end;
      inc(_y, _r);
    end;

  _full_img := nil;
end.