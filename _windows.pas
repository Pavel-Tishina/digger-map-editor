{$MODE OBJFPC}

unit _windows;

interface

uses
  _ag, _types, _font, _util, draw, _ibtn, _mbtn, io, _flist;

type
  TModal = class(TGUI)
    const
      _title_tm : Byte = 5;   // title top marging
      _title_lm : Byte = 5;   // title left-right marging
      _txt_tm   : Byte = 20;  // text top marging
      _txt_lm   : Byte = 5;   // text l-r marging
      _txt_btwm : Byte = 10;  // text between lines marging
      _txt_bm   : Byte = 5;   // Text bottom marging (to buttons)
      _btns_btwm: Byte = 12;
      _btns_bm  : Byte = 5;

      _file_marging : Byte = 5;
      _file_btn_m   : Byte = 24;
      _file_list_xm : Byte = 165;
      _file_list_ym : Byte = 165;

    var
      _buttons: array of TModalButton;
      _sys_btns: array of IconButton;
      _files_list: TFileListObj;
      _wtype: ModalType;
      _bkg_area: ImageData;

      _title: String;
      _text: array of String;
      _close_after : Boolean;

    constructor Create(
      title: String; 
      text: array of String; 
      x1, y1, x2, y2: Word; 
      wtype: ModalType
    );

    constructor Create(
      title: String; 
      text: array of String; 
      x1, y1: Word; 
      wtype: ModalType
    );

    constructor Create(
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
  end;

implementation

    procedure TModal.InitElements(wtype: ModalType);
      const
        _OKAY   : ShortString = 'OKAY';
        _YES    : ShortString = 'YES';
        _NO     : ShortString = 'NO';
        _btn_x  : Byte = 38;

      var
        _xx, _yy : Word;

      begin
        _xx := (_xm - _x) div 4;
        _yy := _ym - 14 - _btns_bm;

        case wtype of

          ModalType.FileWindow:
            begin
              _files_list := TFileListObj.Create(_x + _file_marging, _y + _file_marging);
              setLength(_sys_btns, 2);
              _sys_btns[0] := IconButton.Init(_xm - _file_btn_m, _y + _file_marging, IconButtonType.Cross);
              _sys_btns[1] := IconButton.Init(_xm - _file_btn_m, _ym - _file_btn_m, IconButtonType.Load);
            end;

          ModalType.YesNoWindow:
            begin
              // writeln(_x, ' ', _xm);
              setLength(_buttons, 2);

              _buttons[0] := TModalButton.Create(_x + _xx - (_btn_x div 2), _yy, _btn_x, _YES);
              _buttons[1] := TModalButton.Create(_xm - _xx - (_btn_x div 2), _yy, _btn_x, _NO);
              
              if _xm < _xx then
                _xm := _xx;

            end;

          ModalType.SimpleWindow:
            begin
              setLength(_buttons, 1);
              _buttons[0] := TModalButton.Create((_xm - _x) div 2, _yy, _btn_x, _OKAY);
            end;

        end;
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      x1, y1: Word; 
      wtype: ModalType
    );
      begin
        Create('', [''], x1, y1, 0, 0, wtype);
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      title: String; 
      text: array of String; 
      x1, y1: Word; 
      wtype: ModalType
    );
      begin
        Create(title, text, x1, y1, 0, 0, wtype);
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      title: String; text: array of String; 
      x1, y1, x2, y2: Word; 
      wtype: ModalType
    );
      var
        _max_xl, _max_yl, _n : Word;
        _i : Word;

      begin
        _close_after := false;
        _title := title;
        setLength(_text, length(text));
        for _i := 0 to length(text) - 1 do
          _text[_i] := text[_i];
        _wtype := wtype;

        _x := x1; 
        _y := y1;

        _max_xl := specialize IfElse<Word>(
          wtype <> ModalType.FileWindow,
          x1 + length(title) * 8 + (_title_lm * 2),
          x1 + _file_list_xm
        );

        for _i := 1 to length(text) do
          begin
            _n := x1 + (length(text[_i]) * 8) + (_title_lm * 2);
            if _n > _max_xl then
              _max_xl := _n;
          end;


        if wtype = ModalType.FileWindow then
          begin
            _xm := _x + _file_list_xm;
            _ym := _y + _file_list_ym;
          end
        
        else if (x2 = 0) AND (y2 = 0) then
          begin
            _xm := _max_xl;
            _max_yl := y1 + _txt_tm + (length(text) * _txt_btwm) + _btns_bm + 14;
            _ym := _max_yl;
          end
        else
          begin
            _xm := specialize IfElse<Word>(_max_xl > x2, _max_xl, x2);
            _max_yl := y1 + _txt_tm + (length(text) * _txt_btwm) + _txt_bm + 10 + _btns_bm + 14;
            _ym := specialize IfElse<Word>(_max_yl > y2, _max_yl, y2);
          end;


        InitElements(wtype);
      end;

    // // // // // // // // // // //

    function TModal.WhatBtnClick(x, y: Word): Byte;
      var
        _i : Byte;

      begin
        if NOT IsClick(x, y) then exit(255);

        for _i := 0 to length(_buttons) - 1 do
          if _buttons[_i].IsClick(x, y) then
            exit(_i);
      end;

    // // // // // // // // // // //

    function TModal.WhatFileNameChoosed(x, y: Word): ShortString;
      begin
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
        Result := length(_bkg_area) > 0;
      end;

     // // // // // // // // // // //

    procedure TModal.Hide;
      var
        _xi, _yi, _yc: Word;

      begin
        for _yi := _y to _ym do
          begin
            _yc := _yi - _y;
            for _xi := _x to _xm do
              PutPixelOffset(LineOffset[_yi] + _xi, _bkg_area[_xi - _x, _yc]);
          end;

        setLength(_bkg_area, 0);
      end;

     // // // // // // // // // // //

    procedure TModal.Show;
      var
        _xi, _yi, _yc: Word;
        _i: Byte;

      begin
        setLength(_bkg_area, (_xm - _x) + 1, (_ym - _y) + 1);

        // !!!!!
        for _yi := _y to _ym do
          begin
            _yc := _yi - _y;
            for _xi := _x to _xm do
              _bkg_area[_xi - _x, _yc] := GetPixelOffset(LineOffset[_yi] + _xi);
          end;

        FilledRectangle(_x, _y, _xm, _ym, 0, 8);

        if _wtype <> ModalType.FileWindow then
          begin
            _xi := (((_xm - _x) div 2) - ((length(_title) * 8) div 2));
            _yi := _y + _title_tm;
            DrawString(_x + _xi, _yi, _title);
            Line(_x + _xi + 1, _yi + 9, _xm - _xi, _yi + 9, 6);
            Line(_x + _xi, _yi + 10, _xm - _xi, _yi + 10, 12);

            _xi := _x + _txt_lm;
            _yi := _y + _txt_tm;

            for _i := 0 to length(_text) - 1 do
              begin
                DrawString(_xi, _yi, _text[_i]);
                inc(_yi, _txt_btwm);
              end;
            
            for _i := 0 to length(_buttons) - 1 do
              _buttons[_i].Draw;
          end
        else
          begin
            _files_list.Draw;

            for _i := 0 to length(_sys_btns) - 1 do
              _sys_btns[_i].Draw;
          end;

        
      end;
    
     // // // // // // // // // // //

    function TModal.WindowAction(x, y: Word): TWindowResult;
      var
        _r  : TWindowResult;
        _selected_name : ShortString;

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
              _r.S := specialize IfElse<ShortString>(_close_after AND (length(_selected_name) > 0), _selected_name, '');
              if _close_after then
                begin
                  Hide;
                  _close_after := false;
                end;
            end;

          ModalType.YesNoWindow:
            begin
              _r.Kind := rtBoolean;
              _r.B := WhatBtnClick(x, y) = 0;
              Hide;
            end;
          
          ModalType.SimpleWindow:
            begin
              _r.Kind := rtBoolean;
              _r.B := False;
              Hide;
            end;
        end;

        Result := _r;
      end; 
     
end.