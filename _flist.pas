{$MODE OBJFPC}

unit _flist;

interface

uses
  io, draw, _types, _util, _font, _fscl, _fline;

type
  TFileArray = array of TFileLine;          

TFileListObj = class(TGUI)
    const
      _files_frame : Byte = 10;   // files in frame 
      _elem_btw    : Byte = 16;   // from Y to Y diff elements
      _scroll_xm   : Byte = 116;  // margin scroll from left
    
    var
      _files : array of ShortString;
      _f_lines : TFileArray;
      _scroll : TFileScroll;
      _s : ShortInt;  // position line
      _p : Byte;      // position index

    constructor Create(x, y: Word);
    procedure Draw;
    procedure DrawList;

    procedure SelectFile(x, y: Word);
    // procedure RefreshList;

    function GetSelected: ShortString;

    procedure Action(x, y: Word);
   
    procedure RefreshList(inx: Byte);
  end;

implementation

  constructor TFileListObj.Create(x, y: Word);
    var
      __n, __x, __y : Word;
      __l : Byte;
    begin
      __n := CountLVLFiles('\MAPS\'#0);

      if __n = 0 then
        begin
          _s := -1;
          exit;
        end;

      _x := x;
      _y := y;

      setLength(_files, __n);
      FindFiles('\MAPS\'#0, @_files, __n);

      _s := 0;
      if __n > _files_frame then
        begin
          _xm := _x + _scroll_xm + 22;
          __l := _files_frame;
          _scroll := TFileScroll.Create(_x + _scroll_xm, _y, __n);
          // _scroll.Draw;
        end
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
      
      _p := 0;
    end;

  // // // // // // // //

  procedure TFileListObj.Draw;
    begin
      if (_s > 0) then
        begin
          DrawList;

          if (length(_files) > _files_frame) then
            _scroll.Draw;
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
          if _f_lines[__i].IsClick(x, y) then
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

  function TFileListObj.GetSelected: ShortString;
    begin
      Result := _f_lines[_s].GetName;
    end;

  // // // // // // // //

  procedure TFileListObj.Action(x, y: Word);
    var
      __i : ShortInt;
    begin

      if NOT IsClick(x, y) then
        exit;

      if _scroll.IsClick(x, y) then
        begin
          __i := _scroll.Action(x, y);
          if (__i > 0) and (__i <> _p) then
            RefreshList(__i);
        end
      else
        SelectFile(x, y);

    end;


end.