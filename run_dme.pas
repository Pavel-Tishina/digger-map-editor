{$MODE OBJFPC}
program main;

uses
  design, video, draw, _mouse, io, _grid, _map, _ibtn, _types, _ag, _util, _cell, _font, _fline, _wman;

var
  prev_mouse_lb, prev_mouse_rb, _slvl: Byte;
  _gold_n: ShortInt;
  kkey : Word;
  mouseOldX, mouseOldY : Word;
  Grid_LVL, Grid_OBJ, Grid_L, Grid_R : LevelGrid;
  Map_OBJ : LevelMap;
  LoadBtn, SaveBtn, NewBtn, ExitBtn : IconButton;
  _click_cell_type : CellType;
  _click_lvl_cell : LevelCell;
  Map_NAME : TFileLine;
  WMAN : TWindowsManager;
  _close_window_result : TWindowResult;



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

procedure InitNewMap;
  begin
    Grid_LVL := LevelGrid.Init(2, 27, 15, 10);
    Grid_LVL.Draw;

    Grid_R := LevelGrid.Init(280, 32, 1, 1);
    Grid_R.Draw;
  end;

procedure ExitEditor;
  begin
    SetTextMode;
    CloseApp;
  end;

procedure DrawBackground;
  var o : Word;
  begin
    SetPalette(2, 5, 5, 5);
    SetPalette(3, 10, 10, 10);
    SetPalette(13, 15, 15, 15);
    SetPalette(14, 20, 20, 20);
    
    for o := 0 to 64000 do
      if (o mod 11 = 0) then
        PutPixelOffset(o, 14)
      else if (o mod 9 = 0) then
        PutPixelOffset(o, 13)
      else if (o mod 7 = 0) then
        PutPixelOffset(o, 3)
      else if (o mod 3 = 0) then
        PutPixelOffset(o, 2)
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
  SetNormal;
  DrawBackground;

  InitNewMap;

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

  Map_NAME := TFileLine.Create(6, 5, '');
  Map_NAME.Draw;

  WMAN := TWindowsManager.Create;

  if MouseInit then
    begin
      MouseSetRange320x200;
      MouseShow;
    end;

  repeat
    MouseUpdate;

    if (mouseOldX <> MyMouse.X) OR (mouseOldY <> MyMouse.Y) then
      begin    
        mouseOldX := MyMouse.X;
        mouseOldY := MyMouse.Y;
      end;

    if AnyBtnClc(MyMouse.Btn, prev_mouse_lb, prev_mouse_rb) then
      begin
        MouseHide;

        // LEFT BUTTON CLICK
        if LBtnRelease(MyMouse.Btn, prev_mouse_lb) then
          begin
            
            if ExitBtn.IsClick(MyMouse.X, MyMouse.Y) then        // BUTTONS CLICK
              begin
                ExitEditor;
              end
            else if SaveBtn.IsClick(MyMouse.X, MyMouse.Y) then
              begin
                Map_OBJ.SaveMap(Map_NAME.GetName);
              end
            else if LoadBtn.IsClick(MyMouse.X, MyMouse.Y) then
              begin
                WMAN.GetFileModal.Show;
              end
            else if NewBtn.IsClick(MyMouse.X, MyMouse.Y) then
              begin
                InitNewMap;
              end
            else if Map_NAME.IsClick(MyMouse.X, MyMouse.Y) then // EDIT FILE NAME
              begin
                MouseHide;
                Map_NAME.EditName;
                MouseShow;
              end
            else if Grid_OBJ.IsClick(MyMouse.X, MyMouse.Y) then // CHANGE LEFT BUTTON ELEMENT
              begin
                _click_cell_type := Grid_OBJ.GetClickedCellType(MyMouse.X, MyMouse.Y);

                if ((_click_cell_type <> CellType.Error) and (_click_cell_type <> Grid_L.GetTypeCell(0, 0))) then
                  begin
                    Grid_L.SetTypeCell(0, 0, _click_cell_type);
                    Grid_L.DrawCell(0, 0);
                  end;
              end;

          end;
        
        // RIGHT BUTTON CLICK
        if RBtnRelease(MyMouse.Btn, prev_mouse_rb) then
          begin
            
            if Grid_OBJ.IsClick(MyMouse.X, MyMouse.Y) then // CHANGE RIGHT BUTTON ELEMENT
              begin
                _click_cell_type := Grid_OBJ.GetClickedCellType(MyMouse.X, MyMouse.Y);

                if ((_click_cell_type <> CellType.Error) and (_click_cell_type <> Grid_R.GetTypeCell(0, 0))) then
                  begin
                    Grid_R.SetTypeCell(0, 0, _click_cell_type);
                    Grid_R.DrawCell(0, 0);
                  end;
              end;

          end;

          if Grid_LVL.IsClick(MyMouse.X, MyMouse.Y) then  // PUT OBJECT INTO MAP
            begin
              _click_cell_type := specialize IfElse<CellType>(RBtnRelease(MyMouse.Btn, prev_mouse_rb), Grid_R.GetTypeCell(0, 0), Grid_L.GetTypeCell(0, 0));
              _click_lvl_cell := Grid_LVL.GetClickedCell(MyMouse.X, MyMouse.Y);

              if CheckLevelMapChange(_click_lvl_cell.GetType, _click_cell_type, _gold_n) then
                begin
                  if AddGold(_click_lvl_cell.GetType, _click_cell_type, _gold_n) then
                    inc(_gold_n)
                  else if RemGold(_click_lvl_cell.GetType, _click_cell_type, _gold_n) then
                    dec(_gold_n);

                  Grid_LVL.SetTypeCell(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);
                  Grid_LVL.DrawCell(_click_lvl_cell.X, _click_lvl_cell.Y);

                  Map_OBJ.SetType(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);
                end;
            end
          else if Map_OBJ.IsClick(MyMouse.X, MyMouse.Y) then // CHANGE LEVEL
            begin
              _slvl := Map_OBJ.SelectLevel(MyMouse.X, MyMouse.Y);
              if btwn(_slvl, 0, 7) then
                begin
                  Grid_LVL.SetMap(Map_OBJ.GetLevel(_slvl));
                  Map_OBJ.SetActive(_slvl);
                  Map_OBJ.DrawLvl(_slvl);
                end;
            end;

        prev_mouse_lb := MyMouse.Btn;
        if WMAN.IsAnyModalOpen then
          begin
            MouseShow;
            SetGray;
            
            repeat
              MouseUpdate;

              if (mouseOldX <> MyMouse.X) OR (mouseOldY <> MyMouse.Y) then
                begin
                  mouseOldX := MyMouse.X;
                  mouseOldY := MyMouse.Y;
                end;

              if LBtnRelease(MyMouse.Btn, prev_mouse_lb) then
                begin
                  MouseHide;
                  WMAN.Action(MyMouse.X, MyMouse.Y);
                  MouseShow;
                end;

              prev_mouse_lb := MyMouse.Btn;
              prev_mouse_rb := MyMouse.Btn;

              _close_window_result := WMAN.GetResult;
            until (NOT WMAN.IsAnyModalOpen);

            SetNormal;
            if (_close_window_result.WType = ModalType.FileWindow) AND (length(_close_window_result.S) > 0) then
              begin
                Map_OBJ.LoadMap(_close_window_result.S);
                Map_OBJ.Draw;
                Grid_LVL.SetMap(Map_OBJ.GetLevel(Map_OBJ._active));
                Map_NAME.SetName(_close_window_result.S);
                Map_NAME.Draw;
              end;            
          end;

        MouseShow;
      end;
    
    prev_mouse_lb := MyMouse.Btn;
    prev_mouse_rb := MyMouse.Btn;
    
  until (6 > 7);

end.