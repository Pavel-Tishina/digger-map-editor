unit design;


interface

uses draw;

  procedure SetNormal;
  procedure SetNormal2;
  procedure SetGray;


implementation

  type
    // TPalette = array[0..15, 0..3] of Byte;
    TPalette = array of array[0..3] of Byte;

  const
    // Normal Mode
    _normal_palette : TPalette = (
      (0, 0, 0, 0),           // 0
      (1, 0, 0, 170),         // 1
      (2, 0, 170, 0),         // 2
      (3, 0, 170, 170),       // 3
      (4, 170, 0, 0),         // 4
      (5, 170, 0, 170),       // 5
      (6, 170, 85, 0),        // 6
      (7, 170, 170, 170),     // 7
      (8, 85, 85, 85),        // 8
      (9, 85, 85, 255),       // 9
      (10, 85, 255, 85),      // 10
      (11, 85, 255, 255),     // 11
      (12, 255, 85, 85),      // 12
      (13, 255, 85, 255),     // 13
      (14, 255, 255, 85),     // 14
      (15, 255, 255, 255)     // 15
    );

    _normal_palette2 : TPalette = (
      (0, 0, 0, 0),       // 0
      (1 ,0, 38, 255),     // 1
      (2, 0, 170, 0),       // 2
      (3, 0, 170, 170),       // 3
      (4, 170, 0, 0),       // 4
      (5, 127, 0, 0),      // 5
      (6, 255, 0, 0),      // 6
      (7, 160, 160, 160),    // 7
      (8, 78, 78, 78),    // 8
      (9, 85, 85, 255),       // 9
      (10, 0, 25, 85),     // 10
      (11, 182, 255, 0),     // 11
      (12, 255, 106, 0),     // 12
      (13, 255, 85, 255),       // 13
      (14, 255, 255, 85),       // 14
      (15, 255, 255, 255)     // 15
    );

    // Gray Mode (Window Open)
    _gray_palette : TPalette = (
      (0, 0, 0, 0),         // 0 *
      (1, 32, 10, 32),      // 1
      (5, 16, 32, 32),      // 5
      (6, 170, 85, 0),      // 6*
      (7, 160, 160, 160),   // 7*
      (8, 78, 78, 78),      // 8*
      (10, 32, 50, 50),     // 10
      (11, 50, 32, 32),     // 11
      (12, 255, 85, 85),    // 12 *
      (15, 255, 255, 255)   // 15
    );

    procedure SetColors(palette: TPalette);
      var _i : Byte;

      begin
        for _i := 0 to 15 do begin
          SetPalette(palette[_i, 0], palette[_i, 1], palette[_i, 2], palette[_i, 3]);
        end;
      end;

    procedure SetNormal;
      begin
        SetColors(_normal_palette);
      end;

    procedure SetNormal2;
      begin
        SetColors(_normal_palette2);
      end;


    procedure SetGray;
      begin
        SetColors(_gray_palette);
      end;

end.