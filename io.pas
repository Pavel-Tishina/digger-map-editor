unit io;

{$MODE OBJFPC}

interface

uses
  _types;

    // FILE
    function CreateFile(FileName: PChar): Word; pascal; external name 'IO_CREATEFILE';
    
    function OpenFileRead(FileName: PChar): Word; pascal; external name 'IO_OPENFILEREAD';
    function OpenFileWrite(FileName: PChar): Word; pascal; external name 'IO_OPENFILEWRITE';

    function ReadFile(Handle: Word; Buffer: Pointer; Count: Word): Word; pascal; external name 'IO_READFILE';
    function WriteFile(Handle: Word; Buffer: Pointer; Count: Word): Word; pascal; external name 'IO_WRITEFILE';
    function CloseFile(Handle: Word): Boolean; pascal; external name 'IO_CLOSEFILE';
    
    function CheckFileExist(Name: PChar): Boolean; pascal; external name 'IO_CHECKFILEEXIST';

    // Origin = 0 - from start of file
    // Origin = 1 - from current position
    // Origin = 2 - from end of file
    function FileSeek(Handle: Word; Pos: LongInt; Origin: Byte): LongInt; pascal; external name 'IO_FILESEEK';
    function FileSize(FileHandle: Word): LongInt; pascal; external name 'IO_FILESIZE';

    // DIR / FILE LIST
    // Scans directory Path (e.g. '\DRAFT\') for files with the .DLF extension
    // and stores their names into the caller buffer List, which must be an
    // array of String[12] (each element 13 bytes). Returns the number of
    // stored names.
    function FindFiles(Path: PChar; List: Pointer; MaxCount: Word): Word; // TODO: Delete it?

    function FindFiles2(const Path: ShortString): ListOfFileNames;

    // Returns the total number of .DLF files in directory Path.
    function CountLVLFiles(Path: PChar): Word;

    // KEYBOARD
    function KeyPressed: Boolean; pascal; external name 'IO_KEYPRESSED';
    function ReadKey: Word; pascal; external name 'IO_READKEY';

    // APP
    procedure CloseApp; pascal; external name 'IO_CLOSEAPP';

implementation

// Low-level routines: asm/io.asm
{$L asm/io.obj}

    const
        DTA_SIZE = 43;      // DOS writes a 43-byte DTA
    
    type
        TDTA = array[0..DTA_SIZE - 1] of Byte;

    var
        DTA_Buf: array[0..42] of Byte;
        SearchSpec: array[0..80] of Byte;
        DirSpec: array[0..80] of Byte;

    // return 0 if a file is found, DOS error code otherwise
    function FindFirst(Pattern: PChar; var DTA: TDTA): Word; pascal; external name 'IO_FINDFIRST';
    function FindNext(var DTA: TDTA): Word; pascal; external name 'IO_FINDNEXT';

    // Spec gets Path + '*.DLF', DTA becomes the current DOS DTA
    function AsmCountLVLFiles(Path, Spec: PChar; DTA: Pointer): Word; pascal; external name 'IO_COUNTLVLFILES';
    function AsmFindFiles(Path: PChar; List: Pointer; MaxCount: Word; Spec: PChar; DTA: Pointer): Word; pascal; external name 'IO_FINDFILES';

    ////////////////////////////////////////////

    function ExtractName(const DTA: TDTA): string;
      var
        _i: Byte;
        _s: string;
    
      begin
        _s := '';
        for _i := 30 to 42 do      // filename (13 bytes, ASCIIZ, space padded)
          begin
            if (DTA[_i] = 0) or (DTA[_i] = 32) then Break;

            _s := _s + Chr(DTA[_i]);
          end;
        ExtractName := _s;
      end;

    ////////////////////////////////////////////

    function CountLVLFiles(Path: PChar): Word;
        begin
            Result := AsmCountLVLFiles(Path, @SearchSpec[0], @DTA_Buf[0]);
        end;

    ////////////////////////////////////////////

    function FindFiles(Path: PChar; List: Pointer; MaxCount: Word): Word;
        begin
            Result := AsmFindFiles(Path, List, MaxCount, @SearchSpec[0], @DTA_Buf[0]);
        end;

    ////////////////////////////////////////////

    function FindFiles2(const Path: ShortString): ListOfFileNames;
      var
        _n, _i : Word;
        _arr : ListOfFileNames;
        DTA: TDTA;
        Err: Word;

      begin
        // copy Path into a DS-resident, null-terminated buffer
        for _i := 1 to length(Path) do
          DirSpec[_i - 1] := Ord(Path[_i]);
        DirSpec[length(Path)] := 0;

        _n := CountLVLFiles(@DirSpec[0]);   // fills SearchSpec with Path+'*.DLF'
        setLength(_arr, _n);

        if _n <= 0 then
          exit(_arr);

        _i := 0;
        Err := FindFirst(@SearchSpec[0], DTA);
        if Err = 0 then
          begin
            repeat
              // skip directories (attribute byte at DTA+21)
              if (DTA[21] and $10) = 0 then
                begin
                  _arr[_i] := ExtractName(DTA);
                  inc(_i);
                end;
              Err := FindNext(DTA);
            until (Err <> 0) or (_i >= _n);
          end;
        
        Result := _arr;
      end;

    ////////////////////////////////////////////

end.