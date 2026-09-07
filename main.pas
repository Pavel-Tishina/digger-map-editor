{$MODE OBJFPC}
program main;

uses
  video, draw, _mouse, io, _grid, _map, _ibtn, _types, _ag, _util, _cell, _font, _windows;

var
  prev_mouse_lb, prev_mouse_rb, _slvl: Byte;
  _gold_n: ShortInt;
  mouseOldX, mouseOldY : Word;
  Grid_LVL, Grid_OBJ, Grid_L, Grid_R : LevelGrid;
  Map_OBJ : LevelMap;
  LoadBtn, SaveBtn, NewBtn, ExitBtn : IconButton;
  _click_cell_type : CellType;
  _click_lvl_cell : LevelCell;
  ModalButton: TModalButton;


function AddGold(old_type, new_type : CellType; gold_n : ShortInt): Boolean;
  begin
    Result := (old_type <> CellType.Gold) AND (new_type = CellType.Gold) AND (gold_n < 8);
  end;

function RemGold(old_type, new_type : CellType; gold_n : ShortInt): Boolean;
  begin
    Result := (old_type = CellType.Gold) AND (new_type <> CellType.Gold) AND (gold_n > 0);
  end;

function CheckLevelMapChange(old_type, new_type : CellType; gold_n : ShortInt): Boolean;
  begin
    Result := (old_type <> CellType.Error) AND (new_type <> CellType.Error) AND (old_type <> new_type)
      AND (
        (AddGold(old_type, new_type, gold_n) XOR RemGold(old_type, new_type, gold_n))
        XOR ((old_type <> CellType.Gold) and (new_type <> CellType.Gold))
      );
  end;

begin
  _gold_n := 0;
  _slvl := 0;

  mouseOldX := 0;
  mouseOldY := 0;

  MyMouse.X := 0;
  MyMouse.Y := 0;
  MyMouse.Btn := 0;

  SetVideoMode13h;
  SetBackgroundColor(8);

  Grid_LVL := LevelGrid.Init(2, 27, 15, 10);
  Grid_LVL.Draw;

  Grid_OBJ := LevelGrid.Init(300, 27, 1, 6);
  Grid_OBJ.SetTypeCell(0, 0, CellType.Gold);
  Grid_OBJ.SetTypeCell(0, 1, CellType.Gem);
  Grid_OBJ.SetTypeCell(0, 2, CellType.Hole);
  Grid_OBJ.SetTypeCell(0, 3, CellType.TonnelH);
  Grid_OBJ.SetTypeCell(0, 4, CellType.TonnelV);
  Grid_OBJ.SetTypeCell(0, 5, CellType.Field);
  Grid_OBJ.Draw;
  
  Grid_L := LevelGrid.Init(261, 32, 1, 1);
  Grid_L.Draw;

  Grid_R := LevelGrid.Init(280, 32, 1, 1);
  Grid_R.Draw;

  Map_OBJ := LevelMap.Init(189, 2);
  Map_OBJ.Draw;

  LoadBtn := IconButton.Init(113, 2, IconButtonType.Load);
  LoadBtn.Draw;

  SaveBtn := IconButton.Init(137, 2, IconButtonType.Save);
  SaveBtn.Draw;

  NewBtn  := IconButton.Init(161, 2, IconButtonType.NewLvl);
  NewBtn.Draw;

  ExitBtn := IconButton.Init(298, 178, IconButtonType.ExitApp);
  ExitBtn.Draw;

  prev_mouse_lb := 0;
  prev_mouse_rb := 0;

  // FONT := TFont.Create;
  // FONT.DrawString(10, 20, 'HELL 666 # 542 GREETINGS');

  DrawString(10, 20, 'HELL 666 # 542 GREETINGS');

  ModalButton := TModalButton.Create(3, 3, 60, 'WELL');
  ModalButton.Draw;

  //FONT.Draw(5, 5);
  // writeln('BBB');
  // FONT.DrawABC(5, 5);

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

    // Colors test
    // for prev_mouse_rb:= 0 to 15 do
    //   FilledSquare(10 + (10 * prev_mouse_rb), 10, 10, 15, prev_mouse_rb);

    if AnyBtnClc(MyMouse.Btn, prev_mouse_lb, prev_mouse_rb) then
      begin
        MouseHide;

        ExitBtn.Click(MyMouse.X, MyMouse.Y);

        if LBtnRelease(MyMouse.Btn, prev_mouse_lb) then
          begin
            // writeln(MyMouse.X, ',', MyMouse.Y);

            ExitBtn.Click(MyMouse.X, MyMouse.Y);
            // LoadBtn2.Click(MyMouse.X, MyMouse.Y);

            // Tool
            if (Grid_OBJ.Click(MyMouse.X, MyMouse.Y) = true) then
              begin
                _click_cell_type := Grid_OBJ.GetClickedCellType(MyMouse.X, MyMouse.Y);
                // writeln(_click_cell_type);

                if ((_click_cell_type <> CellType.Error) and (_click_cell_type <> Grid_L.GetTypeCell(0, 0))) then
                  begin
                    // writeln('AA');
                    Grid_L.SetTypeCell(0, 0, _click_cell_type);
                    Grid_L.DrawCell(0, 0);
                  end;
              end;

          end;
        
        if RBtnRelease(MyMouse.Btn, prev_mouse_rb) then
          begin
            // writeln(MyMouse.X, ',', MyMouse.Y);
            // ExitBtn.Click(MyMouse.X, MyMouse.Y);

            // Tool
            if (Grid_OBJ.Click(MyMouse.X, MyMouse.Y) = true) then
              begin
                _click_cell_type := Grid_OBJ.GetClickedCellType(MyMouse.X, MyMouse.Y);
                // writeln(_click_cell_type);

                if ((_click_cell_type <> CellType.Error) and (_click_cell_type <> Grid_R.GetTypeCell(0, 0))) then
                  begin
                    // writeln('OO');
                    Grid_R.SetTypeCell(0, 0, _click_cell_type);
                    Grid_R.DrawCell(0, 0);
                  end;
              end;

          end;

          if Grid_LVL.Click(MyMouse.X, MyMouse.Y) then
            begin
              if RBtnRelease(MyMouse.Btn, prev_mouse_rb) then
                _click_cell_type := Grid_R.GetTypeCell(0, 0)
              else
                _click_cell_type := Grid_L.GetTypeCell(0, 0);

              _click_lvl_cell := Grid_LVL.GetClickedCell(MyMouse.X, MyMouse.Y);

              // writeln(_click_cell_type, '=', _click_lvl_cell.GetType, '  ', _click_lvl_cell.X, ',', _click_lvl_cell.Y);

              if (CheckLevelMapChange(_click_lvl_cell.GetType, _click_cell_type, _gold_n)) then
                begin
                  if AddGold(_click_lvl_cell.GetType, _click_cell_type, _gold_n) then
                    _gold_n := _gold_n + 1
                  else if RemGold(_click_lvl_cell.GetType, _click_cell_type, _gold_n) then
                    _gold_n := _gold_n - 1;

                  Grid_LVL.SetTypeCell(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);
                  Grid_LVL.DrawCell(_click_lvl_cell.X, _click_lvl_cell.Y);

                  Map_OBJ.SetType(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);

                  // _gold_n_pre := _gold_n;
                  // writeln(_gold_n, ' ', _click_lvl_cell.GetType, '-', _click_cell_type);
                end;

            end;

          if Map_OBJ.Click(MyMouse.X, MyMouse.Y) then
            begin
              _slvl := Map_OBJ.SelectLevel(MyMouse.X, MyMouse.Y);
              writeln(_slvl);

              if btwn(_slvl, 0, 7) then
                begin
                  Grid_LVL.SetMap(Map_OBJ.GetLevel(_slvl));
                  
                  Map_OBJ.SetActive(_slvl);
                  Map_OBJ.DrawLvl(_slvl);
                end;

            end;

        MouseShow;
      end;
    
    prev_mouse_lb := MyMouse.Btn;
    prev_mouse_rb := MyMouse.Btn;
    
  //until (KeyPressed);
  until (6 > 7);

  SetTextMode;

end.