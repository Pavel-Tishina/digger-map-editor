program main;

uses
  video, draw, _mouse, io, _grid, _map, _ibtn, _types, _ag;

var
  prev_mouse_lb, prev_mouse_rb : Byte;
  r, g, b : Integer;
  mouseOldX, mouseOldY : Word;
  Grid_LVL, Grid_OBJ, Grid_L, Grid_R : LevelGrid;
  Map_OBJ : LevelMap;
  LoadBtn, SaveBtn, NewBtn, ExitBtn, LoadBtn2 : IconButton;
  GoldImg : ArchiveGraphicFile;

begin

  mouseOldX := 0;
  mouseOldY := 0;

  MyMouse.X := 0;
  MyMouse.Y := 0;
  MyMouse.Btn := 0;


  SetVideoMode13h;
  SetBackgroundColor(8);

  Grid_LVL := LevelGrid.Init(2, 27, 15, 10);
  Grid_LVL.Draw;

  Grid_OBJ := LevelGrid.Init(300, 27, 1, 5);
  Grid_OBJ.Draw;
  
  Grid_L := LevelGrid.Init(261, 32, 1, 1);
  Grid_L.Draw;

  Grid_R := LevelGrid.Init(280, 32, 1, 1);
  Grid_R.Draw;

  Map_OBJ := LevelMap.Init(189, 2);

  LoadBtn := IconButton.Init(113, 2, IconButtonType.Load);
  LoadBtn.Draw;

  SaveBtn := IconButton.Init(137, 2, IconButtonType.Save);
  SaveBtn.Draw;

  NewBtn  := IconButton.Init(161, 2, IconButtonType.NewLvl);
  NewBtn.Draw;

  ExitBtn := IconButton.Init(298, 178, IconButtonType.ExitApp);
  ExitBtn.Draw;

  GoldImg := ArchiveGraphicFile.Init('\DRAFT\GOLD.CG2'#0);
  GoldImg.Draw(200, 150);

  LoadBtn2 := IconButton.Init(150, 150, IconButtonType.Load);
  LoadBtn2.Draw;

  if MouseInit then
  begin
    MouseSetRange320x200;
    MouseShow;
    // SetMouseCursor;
  end;

  // SaveCursorBackground(MyMouse.X, MyMouse.Y);
  // DrawCursor(MyMouse.X, MyMouse.Y);

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


    if ((MyMouse.Btn and 1) = 0) AND ((prev_mouse_lb and 1) <> 0) then
    begin
      ExitBtn.Click(MyMouse.X, MyMouse.Y);
      LoadBtn2.Click(MyMouse.X, MyMouse.Y);
    end;

    prev_mouse_lb := MyMouse.Btn;
    
  //until (KeyPressed);
  until (6 > 7);

  SetTextMode;

end.