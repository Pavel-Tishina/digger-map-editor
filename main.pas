program main;

uses
  video, draw, mouse, io;

var
  r, g, b: Integer;
  mouseOldX, mouseOldY: Word;

begin

  mouseOldX := 0;
  mouseOldY := 0;

  MyMouse.X := 0;
  MyMouse.Y := 0;
  MyMouse.Btn := 0;


  SetVideoMode13h;
  PutPixel(100, 100, 12);
  Square(120, 120, 50, 11);
  FilledSquare(20, 20, 50, 11, 4);

  Rectangle(100, 5, 150, 20, 11);
  FilledRectangle(160, 5, 250, 20, 11, 14);

  if MouseInit then
  begin
    MouseSetRange320x200;
    MouseShow;
    // SetMouseCursor;
  end;

  SaveCursorBackground(MyMouse.X, MyMouse.Y);
  DrawCursor(MyMouse.X, MyMouse.Y);

  repeat
    MouseUpdate();

    if (mouseOldX <> MyMouse.X) OR (mouseOldY <> MyMouse.Y) then
    begin
      //  repainting of cursor
      // RestoreCursorBackground(mouseOldX, mouseOldY);
      // SaveCursorBackground(MyMouse.X, MyMouse.Y);
      // DrawCursor(MyMouse.X, MyMouse.Y);
      
      mouseOldX := MyMouse.X;
      mouseOldY := MyMouse.Y;
      
    end;

    
    if (MyMouse.Btn and 1) <> 0 then
    begin      
      if (MyMouse.X > 20) AND (MyMouse.X < 70) AND (MyMouse.Y > 20) AND (MyMouse.Y < 70) then
        break;

    end;
    
  until (KeyPressed);

  SetTextMode;

end.