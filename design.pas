unit design;


interface

uses draw;

  procedure SetNormal;
  procedure SetNormal2;
  procedure SetGray;


implementation

  type
    TPalette = array[0..15, 0..2] of Byte;

  const
    // Normal Mode
    _normal_palette : TPalette = (
      (0, 0, 0),       // 0
      (0, 0, 170),     // 1
      (0, 170, 0),       // 2
      (0, 170, 170),       // 3
      (170, 0, 0),       // 4
      (170, 0, 170),      // 5
      (170, 85, 0),      // 6
      (170, 170, 170),    // 7
      (85, 85, 85),    // 8
      (85, 85, 255),       // 9
      (85, 255, 85),     // 10
      (85, 255, 255),     // 11
      (255, 85, 85),     // 12
      (255, 85, 255),       // 13
      (255, 255, 85),       // 14
      (255, 255, 255)     // 15
    );

        _normal_palette2 : TPalette = (
      (0, 0, 0),       // 0
      (0, 38, 255),     // 1
      (0, 170, 0),       // 2
      (0, 170, 170),       // 3
      (170, 0, 0),       // 4
      (127, 0, 0),      // 5
      (255, 0, 0),      // 6
      (160, 160, 160),    // 7
      (78, 78, 78),    // 8
      (85, 85, 255),       // 9
      (0, 25, 85),     // 10
      (182, 255, 0),     // 11
      (255, 106, 0),     // 12
      (255, 85, 255),       // 13
      (255, 255, 85),       // 14
      (255, 255, 255)     // 15
    );


    // Gray Mode (Window Open)
    // _gray_palette : TPalette = (
    //   (0, 0, 0),       // 0 *
    //   (32, 10, 32),     // 1
    //   (0, 0, 0),       // 2
    //   (0, 0, 0),       // 3
    //   (0, 0, 0),       // 4
    //   (16, 32, 32),      // 5
    //   (64, 0, 0),      // 6 *
    //   (32, 32, 32),    // 7 *
    //   (16, 16, 16),    // 8 *
    //   (0, 0, 0),       // 9
    //   (32, 50, 50),     // 10
    //   (50, 32, 32),     // 11
    //   (64, 27, 0),     // 12 *
    //   (0, 0, 0),       // 13
    //   (0, 0, 0),       // 14
    //   (40, 40, 40)     // 15
    // );

    // Gray Mode (Window Open)
    _gray_palette : TPalette = (
      (0, 0, 0),       // 0 *
      (32, 10, 32),     // 1
      (0, 0, 0),       // 2
      (0, 0, 0),       // 3
      (0, 0, 0),       // 4
      (16, 32, 32),      // 5
      (170, 85, 0),      // 6 *
      (160, 160, 160),    // 7*
      (78, 78, 78),    // 8*
      (0, 0, 0),       // 9
      (32, 50, 50),     // 10
      (50, 32, 32),     // 11
      (255, 85, 85),     // 12 *
      (0, 0, 0),       // 13
      (0, 0, 0),       // 14
      (255, 255, 255)     // 15
    );

    procedure SetColors(palette: TPalette);
      var _i : Byte;

      begin
        for _i := 0 to 15 do begin
          SetPalette(_i, palette[_i, 0], palette[_i, 1], palette[_i, 2]);
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