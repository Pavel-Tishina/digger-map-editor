{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _flist;

interface

uses
  io, _types, _util, _fscl, _fline;

type
TFileListObj = object(TGUI)
    const
      _files_frame = 10;   // files in frame 
      _elem_btw    = 16;   // from Y to Y diff elements
      _scroll_xm   = 105;  // margin scroll from left
    
    var
      _files : PFileNames;
      _n_files : Word;
      _f_lines : array[0.._files_frame - 1] of TFileLine;
      _n_lines : Byte;
      _scroll : TFileScroll;   // used only when _n_files > _files_frame
      _s : ShortInt;  // position line
      _p : Byte;      // position index

    procedure Init(x, y: Word);
    procedure Draw;
    procedure DrawList;

    procedure SelectFile(x, y: Word);

    function GetSelected: ShortString;

    procedure Action(x, y: Word);
   
    procedure RefreshList(inx: Byte);
  end;

implementation

  procedure TFileListObj.Init(x, y: Word);
    var
      __n, __y : Word;
      __l : Byte;
    begin
      _n_files := FindFiles('\MAPS\', _files);
      __n := _n_files;

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
          _scroll.Init(_x + _scroll_xm, _y, __n);
        end
      else
        begin
          _xm := _x + _scroll_xm;
          __l := __n;
        end;

      _n_lines := __l;

      __y := _y;
      for __n := 0 to __l - 1 do
        begin
          _f_lines[__n].Init(_x, __y, _files^[__n]);
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

          if (_n_files > _files_frame) then
            _scroll.Draw;
        end;
    end;

  // // // // // // // //

  procedure TFileListObj.DrawList;
    var
      __i : Byte;
    begin
      for __i := 0 to _n_lines - 1 do
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
      for __i := 0 to _n_lines - 1 do
        if _f_lines[__i].IsClick(x, y) and (__p + __i < _n_files) and (__i <> _s) then
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
      for __i := 0 to _n_lines - 1 do
        begin
          _f_lines[__i].Hide;
          if __j < _n_files then
            begin
              _f_lines[__i].SetName(_files^[__j]);
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
      if (_n_files > _files_frame) and _scroll.IsClick(x, y) then
        begin
          __i := _scroll.Action(x, y);
          if (__i >= 0) and (__i <> _p) then
            RefreshList(__i);
        end
      else
        SelectFile(x, y);

    end;


end.