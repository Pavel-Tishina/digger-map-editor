{$MODE OBJFPC}

unit _windows;

interface

uses
  _ag, _types, _font, _util, draw, _ibtn, _mbtn;

type
  TFileList = record
    name: String[12];
    size: LongInt;
  end;

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

      _file_list_m  : Byte = 10;
      _file_list_xm : Byte = 164;
      _file_list_ym : Byte = 168;

    var
      // _xw1, _yw1, _xw2, _yw2: Word;
      _buttons: array of TModalButton;
      _sys_btns: array of IconButton;
      _files_list: TFileList;
      _wtype: ModalType;
      _bkg_area: ImageData;

    _title: String;
    _text: array of String;

    constructor Create(
      title: String; 
      text: array of String; 
      x1, y1, x2, y2: Word; 
      wtype: ModalType;
      buttons: array of TModalButton; 
      aShow: Boolean
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

    function WhatBtnClick(x, y: Word): Byte;
    function IsShown: Boolean;
    
  end;

implementation

    procedure TModal.InitElements(wtype: ModalType);
      var
        _xx, _yy : Word;

      begin
        _xx := (_xw2 - _xw1) div 4;
        _yy := _yw2 - 14 - _btns_bm;

        case wtype of
          ModalType.FileWindow:
            begin
              _files_list := TFileList.Create(_xm1 + _file_list_m, _ym1 + _file_list_m);
              setLength(_sys_btns, 2);
              _sys_btns[0] := IconButton.Init(_xm2 - _file_list_m, _ym1 + _file_list_m, IconButtonType.Cross);
              _sys_btns[1] := IconButton.Init(_xm2 - _file_list_m, _ym2 - _file_list_m, IconButtonType.Load);
            end;

          ModalType.YesNoWindow:
            begin
              setLength(_buttons, 2);
              _buttons[0] := TModalButton.Create(_xw1 + _xx, _yy, 32, 'YES');
              _buttons[1] := TModalButton.Create(_xw2 - _xx, _yy, 32, 'NO');
            end;

          ModalType.SimpleWindow:
            begin
              setLength(_buttons, 1);
              _buttons[0] := TModalButton.Create((_xw2 - _xw1) div 2, _yy, 32, 'OKAY');
            end;
        end;
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      x1, y1: Word; 
      wtype: ModalType
    );
      begin
        Create('', '', x1, y1, 0, 0, wtype, [], false);
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      title: String; 
      text: array of String; 
      x1, y1: Word; 
      wtype: ModalType
    );
      begin
        Create(title, text, x1, y1, 0, 0, wtype, [], false);
      end;

    // // // // // // // // // // //

    constructor TModal.Create(
      title: String; text: array of String; 
      x1, y1, x2, y2: Word; 
      wtype: ModalType;
      buttons: array of TModalButton; 
      aShow: Boolean
    );
      var
        _max_xl, _max_yl, _n : Word;
        _i : Word;

      begin
        _title := title;
        setLength(_text, length(text));
        for _i := 0 to length(text) - 1 do
          _text[_i] := text[_i];
        _wtype := wtype;

        _x := x1; 
        _y := y1;


        if wtype <> ModalType.FileWindow then
          _max_xl := x1 + length(title) * 8 + (_title_lm * 2)
        else
          _max_xl := x1 + _file_list_xm;


        for _i := 0 to length(text) - 1 do
          begin
            _n := x1 + length(text[_i]) * 8 + (_title_lm * 2);
            if _n > _max_xl then
              _max_xl := _n;
          end;


        if wtype = ModalType.FileWindow then
          _ym := _y + _file_list_ym
        
        else if (x2 = 0) AND (y2 = 0) then
          begin
            _xm := _max_xl;
            _max_yl := y1 + _txt_tm + (length(text) * _txt_btwm) + _btns_bm + 14;
            _ym := _max_yl;
          end
        else
          begin
            if _max_xl > x2 then
              _xm := _max_xl
            else
              _xm := x2;

            _max_yl := y1 + _txt_tm + (length(text) * _txt_btwm) + _txt_bm + 10 + _btns_bm + 14;
            if _max_yl > y2 then
              _ym := _max_yl
            else
              _ym := y2;
          end;


        if length(buttons) > 0 then
          begin
            setLength(_buttons, length(buttons));
            for _i := 0 to length(buttons) - 1 do
              _buttons[_i] := buttons[_i];
          end
        else
          InitButtons(wtype);

        if aShow then
          Show;
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

    function TModal.WhatFileNameChoosed(x, y: Word): ShortString[12];
      var
        _i : Byte;

      begin
        Result := '';


        if IsClick(x, y) AND NOT _sys_btns[0].IsClick(x, y) then
          begin
            _files_list.Action(); // not completed
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
        _xi, _yi: Word;

      begin
        for _yi := _y to _ym do
          for _xi := _x to _xm do
            PutPixelOffset(LineOffset[_yi] + _xi, _bkg_area[_xi - _xm, _yi - _ym]);

        setLength(_bkg_area, 0);
      end;

     // // // // // // // // // // //

    procedure TModal.Show;
      var
        _xi, _yi: Word;
        _i: Byte;

      begin
        setLength(_bkg_area, _xm - _x + 1, _ym - _y + 1);

        for _yi := _y to _ym do
          for _xi := _x to _xm do
            _bkg_area[_xi - _x, _yi - _y] := GetPixelOffset(LineOffset[_yi] + _xi);

        FilledRectangle(_x, _y, _xm, _ym, 0, 8);

        _xi := (((_xm - _x) div 2) - ((length(_title) * 8) div 2));
        _yi := _ym + _title_tm;
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

      end;
    
     // // // // // // // // // // //

    function WindowAction(x, y: Word): TWindowResult;
      begin
      end; 
     
end.