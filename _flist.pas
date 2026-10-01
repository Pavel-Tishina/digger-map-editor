{$MODE OBJFPC}

unit _flist;

interface

uses
  io, draw, _types, _util, _font, _fscl, _fline;

type
  TFileArray = array of TFileLine;          

TFileListObj = class(TGUI)
    const
      _files_frame = 10;   // files in frame 
      _elem_btw    = 16;   // from Y to Y diff elements
      _scroll_xm   = 105;  // margin scroll from left
    
    var
      _files : ListOfFileNames;
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
      __n, __y : Word;
      __l : Byte;
    begin
      // one call: FindFiles2 counts and lists the files itself
      _files := FindFiles2('\MAPS\');
      __n := length(_files);

      if __n = 0 then
        begin
          _s := -1;
          exit;
        end;

      _x := x;
      _y := y;

      _s := 0;
      if __n > _files_frame then
        begin
          _xm := _x + _scroll_xm + 22;
          __l := _files_frame;
          _scroll := TFileScroll.Create(_x + _scroll_xm, _y, __n);
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
          inc(__y, _elem_btw);
        end;
      
      _ym := __y;

      _p := 0;
    end;

  // // // // // // // //

  procedure TFileListObj.Draw;
    begin
      if (_s >= 0) then
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

      // the list lives between window openings - keep the real selection
      _f_lines[_s].Select(true);
    end;

  // // // // // // // //

  procedure TFileListObj.SelectFile(x, y: Word);
    var
      __i : Byte;
      __p : Word;

    begin
      if NOT btwn(x, _x, _xm) then
        exit;

      __p := _p * _files_frame;
      for __i := 0 to length(_f_lines) - 1 do
        if _f_lines[__i].IsClick(x, y) and (__p + __i < length(_files)) and (__i <> _s) then
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
          // writeln(__i, ' ', __j, ' ', length(_files), ' ', _files[__j]);
          if __j < length(_files) then
            begin
              _f_lines[__i].SetName(_files[__j]);
              _f_lines[__i].Draw;
              inc(__j);
            end;
        end;
    
      _f_lines[_s].Select(false);
      _f_lines[0].Select(true);
      _s := 0;
      _p := inx;
    end;

  // // // // // // // //

  function TFileListObj.GetSelected: ShortString;
    begin
      if _s < 0 then exit('');

      Result := _f_lines[_s].GetName;
    end;

  // // // // // // // //

  procedure TFileListObj.Action(x, y: Word);
    var
      __i : ShortInt;
    begin

      if (_s < 0) OR NOT IsClick(x, y) then
        exit;

      // _scroll is created only when files don't fit in one frame
      if (_scroll <> nil) and _scroll.IsClick(x, y) then
        begin
          __i := _scroll.Action(x, y);
          // writeln(__i, '  ', _p, ' = ', (__i >= 0) and (__i <> _p));
          if (__i >= 0) and (__i <> _p) then
            RefreshList(__i);
        end
      else
        SelectFile(x, y);

    end;


end.