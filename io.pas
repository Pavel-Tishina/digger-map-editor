{$IMPLICITEXCEPTIONS OFF}
unit io;

{$MODE OBJFPC}

interface

uses
  _types;

    // FILE
    function CreateFile(FileName: PChar): Word; pascal; external name 'IO_CREATEFILE';
    
    function OpenFileRead(FileName: PChar): Word; pascal; external name 'IO_OPENFILEREAD';

    function ReadFile(Handle: Word; Buffer: Pointer; Count: Word): Word; pascal; external name 'IO_READFILE';
    function WriteFile(Handle: Word; Buffer: Pointer; Count: Word): Word; pascal; external name 'IO_WRITEFILE';
    function CloseFile(Handle: Word): Boolean; pascal; external name 'IO_CLOSEFILE';

    // DIR / FILE LIST
    // Names of the .DLF files in directory Path (e.g. '\MAPS\')
    // List gets GetMem memory (nil if no files), returns the number of names
    function FindFiles(Path: PChar; var List: PFileNames): Word;

    // KEYBOARD
    // waits for a key, returns the ASCII code only
    function ReadKey: Word; pascal; external name 'IO_READKEY';

    // APP
    procedure CloseApp; pascal; external name 'IO_CLOSEAPP';

implementation

// Low-level routines: asm/io.asm
{$L asm/io.obj}

    var
        DTA_Buf: array[0..42] of Byte;      // DOS writes a 43-byte DTA
        SearchSpec: array[0..80] of Byte;   // Path + '*.DLF'

    // List = nil: only count the files
    function AsmFindFiles(Path: PChar; List: Pointer; MaxCount: Word; Spec: PChar; DTA: Pointer): Word; pascal; external name 'IO_FINDFILES';

    ////////////////////////////////////////////

    function FindFiles(Path: PChar; var List: PFileNames): Word;
      begin
        List := nil;
        Result := AsmFindFiles(Path, nil, 0, @SearchSpec[0], @DTA_Buf[0]);
        if Result = 0 then exit;

        GetMem(List, Result * SizeOf(TFileName12));
        // a file may vanish between the two scans
        Result := AsmFindFiles(Path, List, Result, @SearchSpec[0], @DTA_Buf[0]);
      end;

    ////////////////////////////////////////////

end.
