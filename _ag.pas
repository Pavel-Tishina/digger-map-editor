{$MODE OBJFPC}

unit _ag;

interface

uses
  io, draw, _types;

type
  ArchiveGraphicFile = class
  public
    ver, colors, bg_color, color_bits: Byte;
    xoffset, pixcount, ym, xm: Word;
    palette, data: ByteData;

    constructor Init(file_name: PChar);

    function GetXOffset: Word;
    function GetYM: Word;
    function GetPixelCount: Word;
    function GetTrasperentColor: Byte;
    
    // function GetImg: ImageData;
    function GetImg: ByteData;
    procedure Draw(x, y: Word);

    procedure Debug;

  end;

implementation

        // ArchiveGraphicFile

    constructor ArchiveGraphicFile.Init(file_name: PChar);
        var 
          fileHandle, fpos: Word;
          bytes_4_pal, n, i, _colors, bg_color_number: Byte;
          r_data: ByteData;
          f_size, image_data_size: LongInt;

        begin
          fileHandle := OpenFileRead(file_name);
          f_size := FileSize(fileHandle);

          setLength(r_data, 5);                      // read header data
          FileSeek(fileHandle, 0, 0);
          fpos := ReadFile(fileHandle, @r_data[0], 5);
          
          ver := r_data[0] shr 4;
          colors := r_data[0] and $0F;
          _colors := colors;

          bg_color_number := r_data[1] shr 4;
          xoffset := ((Word(r_data[2]) and $0F) shl 8) or r_data[1];
          pixcount := (Word(r_data[4]) shl 8) or r_data[3];

          xm := xoffset;
          ym := (pixcount div xoffset + 1) - 1;

          if colors <= 2 then                                // read palette
            bytes_4_pal := 1
          else if colors <= 4 then
            bytes_4_pal := 2
          else if colors <= 8 then
            bytes_4_pal := 3
          else
            bytes_4_pal := 4;

          color_bits := bytes_4_pal; //!!
          
          setLength(palette, colors);                       // read palette
          setLength(r_data, bytes_4_pal);
          fpos := ReadFile(fileHandle, @r_data[0], bytes_4_pal);

          i := 0;
          for n := 0 to bytes_4_pal - 1 do
            begin
              palette[i] := r_data[n] shr 4;
              
              i := i + 1;
              _colors := _colors - 1;

              if (_colors <= 0) then
                continue;

              palette[i] := r_data[n] and $0F;
              i := i + 1;
            end;

          bg_color := palette[bg_color_number];

          image_data_size := f_size - 5 - bytes_4_pal;         // read image data
          setLength(data, image_data_size);

          fpos := ReadFile(fileHandle, @data[0], image_data_size);
          
          // Debug;
          CloseFile(fileHandle);
        end;

    function ArchiveGraphicFile.GetYM: Word;
      begin
        GetYM := ym;
      end;

    function ArchiveGraphicFile.GetXOffset: Word;
      begin
        GetXOffset := xoffset;
      end;

    function ArchiveGraphicFile.GetPixelCount: Word;
      begin
        GetPixelCount := pixcount;
      end;

    function ArchiveGraphicFile.GetTrasperentColor: Byte;
      begin
        GetTrasperentColor := bg_color;
      end;

    // function ArchiveGraphicFile.GetImg: ImageData;
    function ArchiveGraphicFile.GetImg: ByteData;
      var
        // _img : ImageData;
        _img : ByteData;
        _l, _c, _cn, _nb : Byte;
        _x, _n, _r, _i: Word;

      begin
        // setLength(_img, xm + 1, ym + 1);
        setLength(_img, pixcount);
        _nb := (1 shl color_bits) - 1;
        _x := 0;

        _n := 0;
        while (_n <= length(data)) do
          begin
            _l := ((data[_n] shr 7) and 1);

            if (_l = 0)
            then
              begin    
                _r := (data[_n] shr color_bits) and ((1 shl (7 - color_bits)) - 1);
              end
            else
              begin
                _r := ((data[_n] and $7F) shl (8 - color_bits)) or (data[_n + 1] shr color_bits);
                _n := _n + 1;
              end;
            
            _c := palette[data[_n] and _nb];

            _i := 1;
            while (_i <= _r) do
              begin
                // if _x >= length(_img) then
                //   break;

                _img[_x] := _c;

                _x := _x + 1;
                _i := _i + 1;
              end;

            
            _n := _n + 1;
          end;

        GetImg := _img;
      end;

    procedure ArchiveGraphicFile.Draw(x, y: Word);
      var 
        _i : Integer;
        _xm, _ym, _ycalc : Word;
        _img : ByteData;
      
      begin
        _img := GetImg;

        _xm := 0;
        _ym := 0;
        _ycalc := LineOffset[y + _ym];
        for _i := 0 to length(_img) - 1 do
          begin
            if (_img[_i] <> bg_color) then
              PutPixelOffset(_ycalc + x + _xm, _img[_i]);

            _xm := _xm + 1;
            if (_xm = xoffset) then
              begin
                _xm := 0;
                _ym := _ym + 1;
                _ycalc := LineOffset[y + _ym];
              end;
          end;

      end;

      procedure ArchiveGraphicFile.Debug;
        var _i : Byte;

        begin
          writeln('Version: ', ver);
          
          writeln('Colors: ', colors);
          writeln('Color bits: ', color_bits);
          writeln('BG Color: ', bg_color);

          writeln('XM: ', xm);
          writeln('YM: ', ym);
          writeln('Pixels : ', pixcount);

          _i := 0;
          while (_i < length(palette)) do
            begin
              writeln('  ', _i, ' : ', palette[_i]);
              _i := _i + 1;
            end;
            
        end;

end.