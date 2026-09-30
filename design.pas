unit design;


interface

uses draw;

  procedure SetNormal;
  procedure SetGray;


implementation

  type
    TPalette = array of array[0..3] of Byte;

  const
    // Normal Mode
    _normal_palette : TPalette = (
      (0, 0, 0, 0),           // 0
      (1, 0, 0, 170),         // 1
      (2, 5, 5, 5),           // 2
      (3, 10, 10, 10),        // 3
      (4, 170, 0, 0),         // 4
      (5, 170, 0, 170),       // 5
      (6, 170, 85, 0),        // 6
      (7, 170, 170, 170),     // 7
      (8, 85, 85, 85),        // 8
      (9, 85, 85, 255),       // 9
      (10, 85, 255, 85),      // 10
      (11, 85, 255, 255),     // 11
      (12, 255, 85, 85),      // 12
      (13, 15, 15, 15),       // 13
      (14, 20, 20, 20),       // 14
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
      (12, 255, 85, 85),     // 12 *
      (2, 5, 5, 5),
      (3, 10, 10, 10),
      (13, 15, 15, 15),
      (14, 20, 20, 20)
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

    procedure SetGray;
      begin
        SetColors(_gray_palette);
      end;

end.