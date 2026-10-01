unit design;


interface

uses draw;

  procedure SetNormal;
  procedure SetGray;


implementation

  type
    // (color index, R, G, B), R/G/B are VGA DAC values 0..63
    TPalette = array of array[0..3] of Byte;

  const
    // Normal Mode
    _normal_palette : TPalette = (
      (0, 0, 0, 0),           // 0
      (1, 0, 0, 42),          // 1
      (2, 5, 5, 5),           // 2
      (3, 10, 10, 10),        // 3
      (4, 42, 0, 0),          // 4
      (5, 42, 0, 42),         // 5
      (6, 42, 21, 0),         // 6
      (7, 42, 42, 42),        // 7
      (8, 21, 21, 21),        // 8
      (9, 21, 21, 63),        // 9
      (10, 21, 63, 21),       // 10
      (11, 21, 63, 63),       // 11
      (12, 63, 21, 21),       // 12
      (13, 15, 15, 15),       // 13
      (14, 20, 20, 20),       // 14
      (15, 63, 63, 63)        // 15
    );

    // Gray Mode (Window Open), only the changed colors
    _gray_palette : TPalette = (
      (0, 0, 0, 0),           // 0 *
      (1, 32, 10, 32),        // 1
      (5, 16, 32, 32),        // 5
      (6, 42, 21, 0),         // 6*
      (7, 32, 32, 32),        // 7*
      (8, 14, 14, 14),        // 8*
      (10, 32, 50, 50),       // 10
      (11, 50, 32, 32),       // 11
      (12, 63, 21, 21),       // 12 *
      (2, 5, 5, 5),           // 2
      (3, 10, 10, 10),        // 3
      (13, 15, 15, 15),       // 13
      (14, 20, 20, 20)        // 14
    );

    procedure SetColors(const palette: TPalette);
      var _i : Byte;

      begin
        for _i := 0 to High(palette) do
          SetPalette(palette[_i, 0], palette[_i, 1], palette[_i, 2], palette[_i, 3]);
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