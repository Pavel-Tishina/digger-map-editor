{$MODE OBJFPC}
unit _types;

interface

type
  ImageData = array of array of Byte;

type
  ByteData = array of Byte;

type
  CellType = (Field, Gold, Gem, Hole, TonnelH, TonnelV, NULL);

type
  IconButtonType = (Load, Save, NewLvl, ExitApp, Cross);
  
  function CellTypeChar(AType: CellType): Char;
  function IconButtonTypeFileName(AType: IconButtonType): PChar;

// type
//   TLetterBitmap = record
//     bitmap: array[0..7][0..7] of Byte;
//   end;

// type
//   TFont = record
//     transpColor: Byte;
//     symbolColor: Byte;
//     shadowColor: Byte;
//     bitmaps: array [0..57] of TLetterBitmap;
//   end;

// type
//   TCFGRecord = record
//     length, colors: Byte;
//   end;

// type
//   TCGF = record
//     ver: Byte;
//     colors: Byte;
//     transpColor: Byte;
//     offset: Word;
//     pixels: Word;
//     records: array of TCFGRecord;
//   end;


implementation

  function CellTypeChar(AType: CellType): Char;
    begin
      case AType of
        Field:   CellTypeChar := Chr(20);
        Gold:    CellTypeChar := 'B';
        Gem:     CellTypeChar := 'C';
        Hole:    CellTypeChar := 'S';
        TonnelH: CellTypeChar := 'H';
        TonnelV: CellTypeChar := 'V';
        NULL:    CellTypeChar := Chr(0);
      end;
    end;

  // function IconButtonTypeFileName(AType: IconButtonType): PChar;
  //   begin
  //     case AType of
  //       Load:    IconButtonTypeFileName := '\DRAFT\LOAD.CG2'#0;
  //       Save:    IconButtonTypeFileName := '\DRAFT\SAVE.CG2'#0; 
  //       NewLvl:  IconButtonTypeFileName := '\DRAFT\NEW.CG2'#0;
  //       ExitApp: IconButtonTypeFileName := '\DRAFT\EXIT.CG2'#0;
  //       Cross:   IconButtonTypeFileName := ''#0;
  //     end;
  //   end;

  function IconButtonTypeFileName(AType: IconButtonType): PChar;
    const
      C_MAP : array[IconButtonType] of PChar = ('\DRAFT\LOAD.CG2'#0, '\DRAFT\SAVE.CG2'#0, '\DRAFT\NEW.CG2'#0, '\DRAFT\EXIT.CG2'#0, ''#0);
    begin
       Result := C_MAP[AType]; 
    end;

end.