program main_ag;

uses
  _fline, _ibtn, video, _mouse, _util, _types, draw, _windows;

var
  c, prev_mouse_lb, prev_mouse_rb : Byte;
  _exit : Boolean;
  FLINE : TFileLine;
  E_BTN : IconButton;
  mouseOldX, mouseOldY, o : Word;

  YES_NO_MODAL, FILE_MODAL, SIMPLE_MODAL : TModal;

begin
  _exit := false;
  prev_mouse_lb := 0;
  prev_mouse_rb := 0;
  

  SetVideoMode13h;
  SetPalette(1, 5, 5, 5);
  SetPalette(2, 10, 10, 10);
  SetPalette(3, 15, 15, 15);
  SetPalette(14, 20, 20, 20);

  // background
  for o := 0 to 64000 do
    begin
      if (o mod 11 = 0) then
        c := 14
      else if (o mod 9 = 0) then
        c := 3
      else if (o mod 7 = 0) then
        c := 2
      else if (o mod 3 = 0) then
        c := 1
      else
        c := 0;
      
      PutPixelOffset(o, c);
    end;


  mouseOldX := 0;
  mouseOldY := 0;

  MyMouse.X := 0;
  MyMouse.Y := 0;
  MyMouse.Btn := 0;


  E_BTN := IconButton.Init(300, 170, IconButtonType.ExitApp);
  E_BTN.Draw;

  FLINE := TFileLine.Create(5, 5, '');
  FLINE.Draw;

  YES_NO_MODAL := TModal.Create('My First Yes-No', ['Who are you?'], 100, 100, ModalType.YesNoWindow);
  YES_NO_MODAL.Show;

  if MouseInit then
  begin
    MouseSetRange320x200;
    MouseShow;
  end;

  repeat

    MouseUpdate();

    if (mouseOldX <> MyMouse.X) OR (mouseOldY <> MyMouse.Y) then
    begin
      mouseOldX := MyMouse.X;
      mouseOldY := MyMouse.Y;
    end;

    if LBtnRelease(MyMouse.Btn, prev_mouse_lb) then
      begin
        if FLINE.IsClick(MyMouse.X, MyMouse.Y) then
          begin
            MouseHide;
            FLINE.EditName;
            MouseShow;
          end;


        E_BTN.Click(MyMouse.X, MyMouse.Y);
      end;
    
    prev_mouse_lb := MyMouse.Btn;
    prev_mouse_rb := MyMouse.Btn;
  until (6 = 7);


end.