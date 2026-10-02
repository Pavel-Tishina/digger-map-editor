{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
{$INLINE ON}
{$PACKENUM 1}   // enums in 1 byte, not 4: Level is 152 bytes instead of 602
unit _types;

interface

uses
  _util;

type
  TFileName12 = String[12];               // DOS 8.3 name, 13 bytes instead of 256
  ListOfFileNames = array of TFileName12;

type
  ByteData = array of Byte;

type
  ScrollType = (UP, DOWN);

type
  CellType = (Field, Gold, Gem, Hole, TonnelH, TonnelV, Error);

type
  IconButtonType = (Load, Save, NewLvl, ExitApp, Cross);

type
  ModalType = (FileWindow, YesNoWindow);

type
  TResultType = (rtBoolean, rtShortString);

  TWindowResult = packed record
    case Kind: TResultType of
      rtBoolean:     (B: Boolean);
      rtShortString: (S: TFileName12);
    end;

TGUI = class
  _x, _y, _xm, _ym: Word;

  // not virtual: no descendant overrides it.
  // IsClick is not inline - it is called in many places, +1.9K of code
  function IsClick(x, y: Word): Boolean;
end;
  

  function CellTypeChar(AType: CellType): Char;
  function CellTypeMapPixel(AType: CellType): Byte;
  function CharToCellType(c: Char): CellType;
  function IconButtonTypeFileName(AType: IconButtonType): PChar;

implementation
  const
    CELL_TYPE_CHAR : array[CellType] of Char = (' ', 'B', 'C', 'S', 'H', 'V', Chr(0));
    CELL_TYPE_MAP_PIXEL : array[CellType] of Byte = (10, 12, 2, 0, 0, 0, 15);
    ICON_BTN_FILE : array[IconButtonType] of PChar = ('\DRAFT\LOAD.CG2'#0, '\DRAFT\SAVE.CG2'#0, '\DRAFT\NEW.CG2'#0, '\DRAFT\EXIT.CG2'#0, ''#0);

  function CellTypeChar(AType: CellType): Char;
    begin
      Result := CELL_TYPE_CHAR[AType];
    end;

  function CellTypeMapPixel(AType: CellType): Byte;
    begin
      Result := CELL_TYPE_MAP_PIXEL[AType];
    end;

  function CharToCellType(c: Char): CellType;
    var
      _t: CellType;
    begin
      for _t := Low(CellType) to High(CellType) do
        if CELL_TYPE_CHAR[_t] = c then
          exit(_t);

      Result := CellType.Error;
    end;

  function IconButtonTypeFileName(AType: IconButtonType): PChar;
    begin
      Result := ICON_BTN_FILE[AType]; 
    end;

  // // // // // // // // // // // //
  // TGUI

  function TGUI.IsClick(x, y: Word): Boolean;
    begin
      Result := btwn(x, _x, _xm) and btwn(y, _y, _ym);
    end;

end.