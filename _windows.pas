{$MODE OBJFPC}

unit _windows;

interface

uses
  _ag, _types, _font, _util, draw;

type
  TModalButton = class
    const
      _ym : Byte = 14;

    var
      _x, _y: Word;
      _xm: Byte;
      _txt: ShortString;

    constructor Create(x, y: Word; txt: ShortString);
    constructor Create(x, y: Word; minx: Byte; txt: ShortString);
    procedure Draw; 
    function IsClick(x, y: Word): Boolean;
  
  end;

// type
//   TModal = class
//     _tm, _lm, _txtm: Byte;
//     _xw1, _yw1, _xw2, _yw2: Word;
//     _buttons: array of TModalButtons;
//     _wtype: ModalType;
//     _bkg_area: ImageData;

//     _title: String;
//     _text: array of String;

//     constructor Create(
//       title: String; text: array of String; 
//       x1, y1, x2, y2: Word; 
//       wtype: ModalType, 
//       buttons: array of TModalButtons; 
//       show: Boolean
//     );
    
//     procedure Show;
//     procedure Hide;

//     function IsClick(x, y: Word): Boolean;
//     function WhatBtnClick(x, y: Word): Byte;
    
//   end;

implementation

    constructor TModalButton.Create(x, y: Word; txt: ShortString);
      begin
        Create(x, y, 0, txt);
      end;

    constructor TModalButton.Create(x, y: Word; minx: Byte; txt: ShortString);
      begin
        _x := x;
        _y := y;
        _txt := txt;

        _xm := (length(txt) + 1) * 8;

        if _xm < minx then
          _xm := minx;

      end;

    procedure TModalButton.Draw;
      begin
        Rectangle(_x, _y, _x + _xm, _y + _ym, 7);
        FilledRectangle(_x + 1, _y + 1, _x + _xm - 1, _y + _ym - 1, 8, 0);
        DrawString(_x + ((_xm div 2) - (length(_txt) * 4)), _y + 3, _txt);
      end;

    function TModalButton.IsClick(x, y: Word): Boolean;
      begin
        Result := btwn(x, _x, _x + _xm) and btwn(y, _y, _y + _ym);
      end;

end.