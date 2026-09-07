{$MODE OBJFPC}
unit _types;

interface

type
  ImageData = array of array of Byte;

type
  ByteData = array of Byte;

type
  CellType = (Field, Gold, Gem, Hole, TonnelH, TonnelV, Error);

type
  IconButtonType = (Load, Save, NewLvl, ExitApp, Cross);

type
  ModalType = (FileWindow, ChoiseWindow, YesNoWindow, SimpleWindow);
  
  function CellTypeChar(AType: CellType): Char;
  function CellTypeMapPixel(AType: CellType): Byte;
  function IconButtonTypeFileName(AType: IconButtonType): PChar;

implementation
  const
    CELL_TYPE_CHAR : array[CellType] of Char = (Chr(20), 'B', 'C', 'S', 'H', 'V', Chr(0));
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

  function IconButtonTypeFileName(AType: IconButtonType): PChar;
    begin
      Result := ICON_BTN_FILE[AType]; 
    end;

end.