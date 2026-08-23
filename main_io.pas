program main_io;

uses
  io;

var
  FileName: PChar;
  HandleRead, HandleWrite, BytesOp, i: Word;
  Buffer : array[0..511] of Byte;
  size: LongInt;

const
  FileError: Word = $FFFF;

begin
  writeln('START');
  
  if CheckFileExist('_TEST_R.ABC'#0) then
  begin
    writeln('exist');
    HandleRead := OpenFileRead('_TEST_R.ABC'#0);

    if HandleRead <> FileError 
    then
      begin
        size := FileSize(HandleRead);
        writeln('File size: ', size);
        writeln('open read ok');
        FileSeek(HandleRead, 0, 0);
        FillChar(Buffer, SizeOf(Buffer), 0);
        BytesOp := ReadFile(HandleRead, @Buffer, SizeOf(Buffer));
        writeln('read bytes: ', BytesOp);

        if BytesOp > 0
          then
            begin
              for i := 0 to BytesOp - 1 do
                write(chr(Buffer[i]));
            end

          else
            begin
              writeln('File is empty');
            end;

        CloseFile(HandleRead);
        writeln('CLose');
      end
    
    else
      begin
        writeln('File not found');
      end;

  end;

  if CheckFileExist('_TEST_W.ABC'#0) then
    begin
      writeln('exist W');
      HandleWrite := OpenFileWrite('_TEST_W.ABC'#0);

      if HandleWrite <> FileError 
      then
        begin
          writeln('open write ok');
          // FillChar(Buffer, SizeOf(Buffer), 0);
          BytesOp := WriteFile(HandleRead, @Buffer, SizeOf(Buffer));
          writeln('read bytes: ', BytesOp);

          if BytesOp > 0
            then
              begin
                for i := 0 to BytesOp - 1 do
                  write(chr(Buffer[i]));
              end

            else
              begin
                writeln('Buffer is empty');
              end;

          CloseFile(HandleWrite);
          writeln('CLose');
        end
      
      else
        begin
          writeln('File not found');
        end;

    end;

  
  writeln('BB');
end.