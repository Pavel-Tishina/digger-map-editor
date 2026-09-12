{$MODE OBJFPC}

unit _flist;

interface

uses
  io, draw, _types, _util, _font, _fscl, _fline;

type
  TFileArray = array of TFileLine;          

TFileList = class
    const
      _files_frame : Byte = 10;   // files in frame 
      _elem_btw    : Byte = 16;   // from Y to Y diff elements
      _scroll_x    : Byte = 116;  // margin scroll from left
    
    var
      _x, _y, _xm, _ym : Word;
      _files : array of ShortString[12];
      _lines : TFileArray;
      _scroll : TFileScroll;
      _s : ShortInt;  // position line
      _p : Byte;      // position index

    constructor Create(x, y: Word);
    procedure Draw;
    procedure DrawList;

    procedure SelectFile(x, y: Word);
    procedure RefreshList;

    function IsClick(x, y: Word): Boolean;
    function GetSelected: ShortString[12];

    procedure Action(x, y: Word);

    function X: Word;
    function Y: Word;
    function XM: Word;
    function YM: Word;
  end;

implementation

  constructor TFileListObj.Create(x, y: Word);
    var
      __n, __x, __y : Word;
      __l : Byte;
    begin
      __n := CountLVLFiles('\MAPS\'#0);
      
      if __n > 0 then
        begin
          _x := x;
          _y := y;

          setLength(_files, __n);
          FindFiles('\MAPS\'#0, @_files, __n);

          _s := 0;
          if __n > _max_files then
            begin
              _xm := _x + _scroll_xm + 22;
              __l := _max_files;
              _scroll := TFileScroll.Create(_x + _scroll_xm, _y);
              // _scroll.Draw;
            end;
          else
            begin
              _xm := _x + _scroll_xm;
              __l := __n;
            end;

          setLength(_f_lines, __l);

          __y := _y;
          for __n := 0 to __l - 1 do
            begin
              _f_lines[__n] := TFileLine.Create(_x, __y, _files[__n]);
              // _f_lines[__n].Draw;
              inc(__y, _elem_btw);
            end;
        end

      else
        _s := -1;
      
      _p := 0;
    end;

  // // // // // // // //

  procedure TFileListObj.Draw;
    begin
      if (_s > 0) then
        begin
          DrawList;

          if (length(_files) > _files_frame) then
            scroll.Draw;
        end;
    end;

  // // // // // // // //

  procedure TFileListObj.DrawList;
    var
      __i : Byte;
    begin
      for __i := 0 to length(_f_lines) - 1 do
        _f_lines[__i].Draw;

      _f_lines[0].Select(true);
    end;

  // // // // // // // //

  procedure TFileListObj.SelectFile(x, y: Word);
    var
      __i : Byte;

    begin
      if btwn(x, _x, _xm) then
        for __i := 0 to length(_f_lines) - 1 do
          if _f_lines.IsClick(x, y) then
            begin
              _f_lines[_s].Select(false);
              _f_lines[__i].Select(true);
              _s := __i;
              break;
            end;
    end;

  // // // // // // // //

  procedure TFileListObj.RefreshList(inx: Byte);
    var
      __i : Byte;
      __j : Word;

    begin
      __j := inx * _files_frame;
      for __i := 0 to length(_f_lines) - 1 do
        begin
          _f_lines[__i].Hide;
          if __j < length(_files) then
            begin
              _f_lines[__i].SetName(_files[__j]);
              _f_lines[__i].Draw;
              inc(__j);
            end;
        end;
    
      _f_lines[0].Select(true);
      _p := inx;
    end;

  // // // // // // // //

  function TFileListObj.IsClick(x, y: Word): Boolean;
    begin
      Result := btwn(x, _x, _xm) and btwn(y, _y, _ym);
    end;

  // // // // // // // //

  function TFileListObj.GetSelected: ShortString[12];
    begin
      Result := _f_lines[_s].GetName;
    end;

  // // // // // // // //

  procedure Action(x, y: Word);
    var
      __i : ShortInt;
    begin

      if IsClick(x, y) then
        begin

          if _scroll.IsClick(x, y) then
            begin
              __i := _scroll.Action(x, y);
              if (__i > 0) and (__i <> _p) then
                RefreshList(__i);

            end

            else
              SelectFile(x, y);

        end;
    end;

  // // // // // // // //

  function X: Word;
    begin
      Result := _x;
    end;

  function Y: Word;
    begin
      Result := _y;
    end;

  function XM: Word;
    begin
      Result := _xm;
    end;

  function YM: Word;
    begin
      Result := _ym;
    end;


end.