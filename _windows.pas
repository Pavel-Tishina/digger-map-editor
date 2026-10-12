{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _windows;

interface

uses
  _types, _font, _util, draw, _ibtn, _mbtn, _flist, _back, design, _mouse;

type
  TModal = object(TGUI)
    const
      _title_tm = 5;   // title top marging
      _title_lm = 5;   // title left-right marging
      _txt_tm   = 20;  // text top marging
      _txt_lm   = 5;   // text l-r marging
      _txt_btwm = 10;  // text between lines marging
      _btns_bm  = 5;

      _file_marging = 5;
      _file_btn_m   = 24;
      _file_list_xm = 165;
      _file_list_ym = 165;

    var
      _buttons: array[0..1] of TModalButton;   // YesNoWindow: YES, NO
      _sys_btns: array[0..1] of IconButton;    // FileWindow: close, load
      _files_list: TFileListObj;
      _wtype: ModalType;
      _bkg_area: TBackGround;                  // IsNull = the window is hidden

      _title: String[40];             // not String: 256 bytes each
      _text: array[0..1] of String[40];
      _n_text: Byte;
      _close_after : Boolean;

    // the size is calculated from the title and text (FileWindow: fixed size)
    procedure Init(
      const title: String; 
      const text: array of String; 
      x1, y1: Word; 
      wtype: ModalType
    );

    procedure InitElements(wtype: ModalType);
    procedure Show;
    procedure Hide;

    function IsShown: Boolean;
    
    function WhatBtnClick(x, y: Word): Byte;
    function WhatFileNameChoosed(x, y: Word): ShortString;

    function WindowAction(x, y: Word): TWindowResult;
    function WaitResult(x, y: Word): TWindowResult; // Click Me!!

  end;

implementation

    procedure TModal.InitElements(wtype: ModalType);
      const
        _YES    = 'YES';
        _NO     = 'NO';
        _btn_x  = 38;

      var
        _xx, _yy : Word;

      begin
        _xx := Word(_xm - _x) div 4;
        _yy := _ym - 14 - _btns_bm;

        case wtype of

          ModalType.FileWindow:
            begin
              _files_list.Init(_x + _file_marging, _y + _file_marging);
              _sys_btns[0].Init(_xm - _file_btn_m, _y + _file_marging, IconButtonType.Cross);
              _sys_btns[1].Init(_xm - _file_btn_m, _ym - _file_btn_m, IconButtonType.Load);
            end;

          ModalType.YesNoWindow:
            begin
              _buttons[0].Init(_x + _xx - (_btn_x div 2), _yy, _btn_x, _YES);
              _buttons[1].Init(_xm - _xx - (_btn_x div 2), _yy, _btn_x, _NO);
            end;

        end;
      end;

    // // // // // // // // // // //

    procedure TModal.Init(
      const title: String; 
      const text: array of String; 
      x1, y1: Word; 
      wtype: ModalType
    );
      var
        _n : Word;
        _i : Integer;   // signed: high(text) = -1 for an empty text

      begin
        _close_after := false;
        _title := title;
        _n_text := 0;
        for _i := 0 to high(text) do
          if _n_text <= high(_text) then
            begin
              _text[_n_text] := text[_i];
              inc(_n_text);
            end;
        _wtype := wtype;

        _x := x1; 
        _y := y1;

        if wtype = ModalType.FileWindow then
          begin
            _xm := _x + _file_list_xm;
            _ym := _y + _file_list_ym;
          end
        else
          begin
            // the widest of the title and the text lines
            _xm := x1 + length(title) * 8 + (_title_lm * 2);
            for _i := 0 to high(text) do
              begin
                _n := x1 + (length(text[_i]) * 8) + (_title_lm * 2);
                if _n > _xm then
                  _xm := _n;
              end;

            _ym := y1 + _txt_tm + (length(text) * _txt_btwm) + _btns_bm + 14;
          end;

        InitElements(wtype);
      end;

    // // // // // // // // // // //

    function TModal.WhatBtnClick(x, y: Word): Byte;
      var
        _i : Byte;

      begin
        Result := 255;
        if NOT IsClick(x, y) then exit(255);

        for _i := 0 to high(_buttons) do
          if _buttons[_i].IsClick(x, y) then
            exit(_i);
      end;

    // // // // // // // // // // //

    function TModal.WhatFileNameChoosed(x, y: Word): ShortString;
      begin
        Result := '';
        if NOT IsClick(x, y)  then
          exit('');

        _files_list.Action(x, y); // not completed
        
        if _sys_btns[0].IsClick(x, y) then // CLOSE
          begin
            _close_after := true;
            exit('');
          end
        else if _sys_btns[1].IsClick(x, y) then // LOAD
          begin
            _close_after := true;
            exit(_files_list.GetSelected);
          end;

      end;

     // // // // // // // // // // //

    function TModal.IsShown: Boolean;
      begin
        Result := NOT _bkg_area.IsNull;
      end;

     // // // // // // // // // // //

    procedure TModal.Hide;
      begin
        if _bkg_area.IsNull then exit;

        _bkg_area.Draw(_x, _y);
        _bkg_area.Done;
      end;

     // // // // // // // // // // //

    procedure TModal.Show;
      var
        _xi, _yi: Word;
        _i: Byte;

      begin
        if NOT _bkg_area.IsNull then exit; // already shown

        _bkg_area.Init(_x, _y, _xm, _ym);
        if _bkg_area.IsNull then exit; // no free DOS memory - can't restore, don't draw

        FilledRectangle(_x, _y, _xm, _ym, 0, 8);

        if _wtype <> ModalType.FileWindow then
          begin
            _xi := Word(_xm - _x) div 2 - length(_title) * 4;
            _yi := _y + _title_tm;
            DrawString(_x + _xi, _yi, _title);
            Line(_x + _xi + 1, _yi + 9, _xm - _xi, _yi + 9, 6);
            Line(_x + _xi, _yi + 10, _xm - _xi, _yi + 10, 12);

            _xi := _x + _txt_lm;
            _yi := _y + _txt_tm;

            for _i := 1 to _n_text do
              begin
                DrawString(_xi, _yi, _text[_i - 1]);
                inc(_yi, _txt_btwm);
              end;
            
            for _i := 0 to high(_buttons) do
              _buttons[_i].Draw;
          end
        else
          begin
            _files_list.Draw;

            for _i := 0 to high(_sys_btns) do
              _sys_btns[_i].Draw;
          end;
        
      end;

    // // // // // // // // // // //

    function TModal.WindowAction(x, y: Word): TWindowResult;
      var
        _r  : TWindowResult;
        _selected_name : ShortString;
        _btn : Byte;

      begin
        if NOT IsShown then
          begin
            _r.Kind := rtBoolean;
            _r.B := false;
            exit(_r);
          end;

        case _wtype of
          ModalType.FileWindow: 
            begin
              _selected_name := WhatFileNameChoosed(x, y);
              _r.Kind := rtShortString;
              if _close_after then
                _r.S := _selected_name
              else
                _r.S := '';
              if _close_after then
                begin
                  Hide;
                  _close_after := false;
                end;
            end;

          ModalType.YesNoWindow:
            begin
              _btn := WhatBtnClick(x, y);
              _r.Kind := rtBoolean;
              _r.B := _btn = 0;
              if _btn <> 255 then
                Hide;
            end;
        end;
        
        Result := _r;
      end;

  function TModal.WaitResult(x, y: Word): TWindowResult;
    var
      _r  : TWindowResult;
      _pre_lb : Byte;

      begin
        SetGray;

        FillChar(_r, SizeOf(_r), 0);

        MyMouse.X := x;
        MyMouse.Y := y;
        MyMouse.Btn := 0;
        _pre_lb := 0;

        MouseShow;
        repeat
          MouseRead(MyMouse);
          
          if LBtnRelease(MyMouse.Btn, _pre_lb) AND IsClick(MyMouse.X, MyMouse.Y) then
            begin
              MouseHide;
              _r := WindowAction(MyMouse.X, MyMouse.Y);
              MouseShow;
            end;

          _pre_lb := MyMouse.Btn;
        until (NOT IsShown);

        SetNormal;
        Result := _r;
        
      end;

     
end.