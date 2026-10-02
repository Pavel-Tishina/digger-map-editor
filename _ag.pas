{$MODE OBJFPC}
{$INLINE ON}

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
    pixels: ByteData;     // decoded image, xm pixels per row, pixcount pixels

    constructor Init(file_name: PChar);

    function GetXOffset: Word; inline;
    function GetYM: Word; inline;
    function GetPixelCount: Word; inline;
    function GetTrasperentColor: Byte; inline;
    
    function GetImg2: ImageData;
    // function GetImg: ByteData;
    // procedure Draw(x, y: Word);
    procedure Draw2(x, y: Word);

    procedure Debug;

  private
    procedure Decode;

  end;

implementation

        // ArchiveGraphicFile

    constructor ArchiveGraphicFile.Init(file_name: PChar);
        var 
          fileHandle : Word;
          bytes_4_pal, n, i, _colors, bg_color_number: Byte;
          r_data: ByteData;
          f_size, image_data_size: LongInt;

        begin
          fileHandle := OpenFileRead(file_name);
          f_size := FileSize(fileHandle);

          setLength(r_data, 5);                      // read header data
          FileSeek(fileHandle, 0, 0);
          ReadFile(fileHandle, @r_data[0], 5);
          
          ver := r_data[0] shr 4;
          colors := r_data[0] and $0F;
          _colors := colors;

          // REFACTOR THIS!!!!!
          xoffset := Word(r_data[1]) or (Word(r_data[2]) shl 8);
          bg_color_number := xoffset shr 12;
          xoffset := xoffset and $0FFF;

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
          ReadFile(fileHandle, @r_data[0], bytes_4_pal);

          i := 0;
          for n := 0 to bytes_4_pal - 1 do
            begin
              palette[i] := r_data[n] shr 4;
              
              inc(i);
              _colors := _colors - 1;

              if (_colors <= 0) then
                continue;

              palette[i] := r_data[n] and $0F;
              inc(i)
            end;

          bg_color := bg_color_number;

          image_data_size := f_size - 5 - bytes_4_pal;         // read image data
          setLength(data, image_data_size);

          ReadFile(fileHandle, @data[0], image_data_size);
          
          CloseFile(fileHandle);

          Decode;
        end;

    // unpack RLE data into pixels, once - Draw2 only copies them
    procedure ArchiveGraphicFile.Decode;
      var
        _l, _c, _nb : Byte;
        _x, _n, _r, _i: Word;

      begin
        setLength(pixels, pixcount);
        _nb := (1 shl color_bits) - 1;
        _x := 0;

        _n := 0;
        while (_n < length(data)) do
          begin
            _l := ((data[_n] shr 7) and 1);

            if (_l = 0) then
              _r := (data[_n] shr color_bits) and ((1 shl (7 - color_bits)) - 1)
            else
              begin
                if (_n + 1 >= length(data)) then break;
                _r := ((data[_n] and $7F) shl (8 - color_bits)) or (data[_n + 1] shr color_bits);
                inc(_n);
              end;
            
            _c := palette[data[_n] and _nb];

            _i := 1;
            while (_i <= _r) do
              begin
                if (_x < pixcount) then
                  pixels[_x] := _c;

                inc(_x);
                inc(_i);
              end;

            inc(_n);
          end;
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

    function ArchiveGraphicFile.GetImg2: ImageData;
      var
        _img : ImageData;
        _l, _c, _nb : Byte;
        _x, _y, _n, _r, _i: Word;

      begin
        setLength(_img, xm + 1, ym + 1);
        _nb := (1 shl color_bits) - 1;
        _x := 0;
        _y := 0;
        _n := 0;


        while (_n < length(data)) do
          begin
            _l := ((data[_n] shr 7) and 1);

            if (_l = 0) then
              begin    
                _r := (data[_n] shr color_bits) and ((1 shl (7 - color_bits)) - 1);
              end
            else
              begin
                if (_n + 1 >= length(data)) then break;
                _r := ((data[_n] and $7F) shl (8 - color_bits)) or (data[_n + 1] shr color_bits);
                inc(_n);
              end;
            
            _c := palette[data[_n] and _nb];

            _i := 1;
            while (_i <= _r) do
              begin
                if (_x >= xm) then
                  begin
                    _x := 0;
                    inc(_y);
                  end;

                if (_y <= ym) then
                  _img[_x, _y] := _c;

                inc(_x);
                inc(_i);
              end;

            inc(_n);
          end;

        Result := _img;
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
              inc(_i);
            end;
            
        end;

end.