{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}
program main;

uses
  design, video, draw, _mouse, io, _grid, _map, _ibtn, _types, _util, _cell, _fline, _windows;

const
  // untyped constants: a typed ShortString constant takes 256 bytes in the exe
  _file_w_x      = 82;
  _file_w_y      = 20;

  _window_x      = 65;
  _window_y      = 70;

  _not_sav_w_t   = 'Map changes not saved!';
  _not_sav_w_txt1 = 'Would you like to save it';
  _not_sav_w_txt2 = 'before the exit?';

var
  prev_mouse_lb, prev_mouse_rb, _slvl: Byte;
  _gold_n: ShortInt;
  Grid_LVL, Grid_OBJ, Grid_L, Grid_R : LevelGrid;
  Map_OBJ : LevelMap;
  LoadBtn, SaveBtn, NewBtn, ExitBtn : IconButton;
  Map_NAME : TFileLine;
  FileModal, NotSaveModal : TModal;

  _click_cell_type : CellType;
  _click_lvl_cell : LevelCell;
  _close_window_result : TWindowResult;
  _map_change, _remind_draw : Boolean;
  _dialog_shown : Boolean;   // the click was handled by a modal window

  _bg_c_changer : Byte = 0;
  _col_inx, _col_inx2: Integer;
  _r9, _g9, _b9 : Byte;
  _r11, _g11, _b11 : Byte;
  
  _r2, _g2, _b2 : Byte;
  _r3, _g3, _b3 : Byte;
  _r13, _g13, _b13 : Byte;
  _r14, _g14, _b14 : Byte;
  
  _ic2_3, _ic9, _ic11 : ShortInt;


// can a map cell change old_type -> new_type? counts the gold, at most 8
function ChangeCell(old_type, new_type : CellType): Boolean;
  begin
    Result := false;
    if (old_type = CellType.Error) OR (new_type = CellType.Error) OR (old_type = new_type) then exit;

    if new_type = CellType.Gold then
      begin
        if _gold_n >= 8 then exit;
        inc(_gold_n);
      end
    else if old_type = CellType.Gold then
      begin
        if _gold_n <= 0 then exit;
        dec(_gold_n);
      end;

    Result := true;
  end;

// the object column cell under the mouse becomes the tool of a mouse button
procedure PickTool(var tool : LevelGrid);   // var: objects are values, not references
  var
    _t : CellType;

  begin
    _t := Grid_OBJ.GetClickedCellType(MyMouse.X, MyMouse.Y);

    if (_t <> CellType.Error) and (_t <> tool.GetTypeCell(0, 0)) then
      begin
        tool.SetTypeCell(0, 0, _t);
        tool.DrawCell(0, 0);
      end;
  end;

// the objects are static, Init-ed once at start; "New" only clears them
procedure InitNewMap;
  begin
    Grid_LVL.Clear;
    Grid_LVL.Draw;

    Map_OBJ.Clear;
    Map_OBJ.Draw;

    Map_NAME.SetName('');
    _gold_n := 0;
    _map_change := false;
  end;

procedure ExitEditor;
  begin
    SetTextMode;
    CloseApp;
  end;

{$L asm/dme.obj}

// dotted background: asm/dme.asm
procedure DrawBackground; pascal; external name 'DME_DRAWBACKGROUND';

procedure DontForgetSaveMap;
  begin
    if _remind_draw = _map_change then exit;
    
    Square(137, 2, 19, specialize IfElse<Byte>(_map_change, 5, 7));
    if _map_change then
      begin
        Line(137, 2, 141, 2, 9);
        Line(137, 21, 141, 21, 9);

        Line(152, 2, 156, 2, 9);
        Line(152, 21, 156, 21, 9);

        Line(137, 2, 137, 6, 9);
        Line(137, 17, 137, 21, 9);

        Line(156, 2, 156, 6, 9);
        Line(156, 17, 156, 21, 9);

        PutPixelOffset(LineOffset[2] + 146, 9);
        PutPixelOffset(LineOffset[21] + 146, 9);
        PutPixelOffset(LineOffset[11] + 137, 9);
        PutPixelOffset(LineOffset[11] + 156, 9);
      end;

    _remind_draw := _map_change;
  end;

procedure DontForgetSetNameBeforeSave;
  begin
    if length(Map_NAME.GetName) <= 4 then Map_NAME.EditName;
    Map_OBJ.SaveMap(Map_NAME.GetName);
  end;

procedure BackgroundColorMagic;
  begin
    inc(_col_inx2);

    if (_col_inx2 < 1000) then exit;
    
    _col_inx2 := 0;
    if (((_r2 = 5) AND (_g2 = 5) AND (_b2 = 5)) OR ((_r2 = 10) AND (_g2 = 10) AND (_b2 = 10))) then _ic2_3 := - _ic2_3;

      inc(_bg_c_changer);
      case _bg_c_changer of
        1 : inc(_r2, _ic2_3); 
        2 : inc(_g2, _ic2_3);
        3 : inc(_b2, _ic2_3);
        4 : dec(_r3, _ic2_3);
        5 : dec(_g3, _ic2_3);
        6 : dec(_b3, _ic2_3);
        7 : inc(_r13, _ic2_3);
        8 : inc(_g13, _ic2_3);
        9 : inc(_b13, _ic2_3);
        10 : dec(_r14, _ic2_3);
        11 : dec(_g14, _ic2_3);
        12 : dec(_b14, _ic2_3);
        else _bg_c_changer := 0;
      end;

      if btwn(_bg_c_changer, 1, 3) then
        SetPalette(2, _r2, _g2, _b2)
      else if btwn(_bg_c_changer, 4, 6) then
        SetPalette(3, _r3, _g3, _b3)
      else if btwn(_bg_c_changer, 7, 9) then
        SetPalette(13, _r13, _g13, _b13)
      else if btwn(_bg_c_changer, 10, 12) then
        SetPalette(14, _r14, _g14, _b14);

  end;

procedure ColorMagic;
  begin
    BackgroundColorMagic;

    inc(_col_inx);
    if (NOT _map_change) OR (_col_inx < 3000) then exit;

    _col_inx := 0;
    if ((_r9 = 0) AND (_g9 = 0) AND (_b9 = 0))
        OR ((_r9 = 63) AND (_g9 = 63) AND (_b9 = 63))
     then
      begin
        _ic9 := -_ic9;
        _ic11 := -_ic11;
      end;
      
      inc(_r9, _ic9);
      inc(_r11, _ic11);
      inc(_g9, _ic9);
      inc(_g11, _ic11);
      inc(_b9, _ic9);
      inc(_b11, _ic11);

    SetPalette(9, _r9, _g9, _b9);
    SetPalette(5, _r11, _g11, _b11);
  end;

begin
  // _bg_c_changer := true;
  
  _ic9 := -1;
  _ic11 := 1;
  _ic2_3 := -1;
  
  _r2 := 5;
  _g2 := 5;
  _b2 := 5;

  _r3 := 10;
  _g3 := 10;
  _b3 := 10;

  _r13 := 15;
  _g13 := 15;
  _b13 := 15;

  _r14 := 20;
  _g14 := 20;
  _b14 := 20;

  _r9 := 0;
  _g9 := 0;
  _b9 := 0;
  
  _r11 := 63;
  _g11 := 63;
  _b11 := 63;
  _col_inx := 0;
  _col_inx2 := 0;

  _gold_n := 0;
  _slvl := 0;
  _map_change := false;
  _remind_draw := false;

  MyMouse.X := 0;
  MyMouse.Y := 0;
  MyMouse.Btn := 0;

  SetVideoMode13h;
  SetNormal;
  DrawBackground;

  // before InitNewMap: it clears and draws them
  Map_NAME.Init(6, 5, '');
  Grid_LVL.Init(2, 27, 15, 10, true);
  Map_OBJ.Init(189, 2);

  InitNewMap;

  Grid_L.Init(261, 32, 1, 1);
  Grid_R.Init(280, 32, 1, 1);
  Grid_OBJ.Init(300, 27, 1, 6);

  LoadBtn.Init(113, 2, IconButtonType.Load);
  SaveBtn.Init(137, 2, IconButtonType.Save);
  NewBtn.Init(161, 2, IconButtonType.NewLvl);
  ExitBtn.Init(298, 178, IconButtonType.ExitApp);

  FileModal.Init('', [], _file_w_x, _file_w_y, ModalType.FileWindow);
  NotSaveModal.Init(_not_sav_w_t, [_not_sav_w_txt1, _not_sav_w_txt2], _window_x, _window_y, ModalType.YesNoWindow);

  Grid_OBJ.SetTypeCell(0, 0, CellType.Gold);
  Grid_OBJ.SetTypeCell(0, 1, CellType.Gem);
  Grid_OBJ.SetTypeCell(0, 2, CellType.Hole);
  Grid_OBJ.SetTypeCell(0, 3, CellType.TonnelH);
  Grid_OBJ.SetTypeCell(0, 4, CellType.TonnelV);
  Grid_OBJ.SetTypeCell(0, 5, CellType.Field);
  Grid_OBJ.Draw;
  
  Grid_L.Draw;
  Grid_R.Draw;

  LoadBtn.Draw;
  SaveBtn.Draw;
  NewBtn.Draw;
  ExitBtn.Draw;

  prev_mouse_lb := 0;
  prev_mouse_rb := 0;

  Map_NAME.Draw;

  if MouseInit then
    begin
      MouseSetRange320x200;
      MouseShow;
    end;

  repeat
    MouseRead(MyMouse);

    if AnyBtnClc(MyMouse.Btn, prev_mouse_lb, prev_mouse_rb) then
      begin
        MouseHide;
        _dialog_shown := false;

        // LEFT BUTTON CLICK
        if LBtnRelease(MyMouse.Btn, prev_mouse_lb) then
          begin

            // BUTTONS CLICK
            if ExitBtn.IsClick(MyMouse.X, MyMouse.Y) then        // Click Exit
              begin
                if NOT _map_change then ExitEditor;

                NotSaveModal.Show;
                if NotSaveModal.WaitResult(MyMouse.X, MyMouse.Y).B then // YES - save before exit
                    DontForgetSetNameBeforeSave;
            
                ExitEditor;
              end
            else if SaveBtn.IsClick(MyMouse.X, MyMouse.Y) then    // Click Save
              begin
                DontForgetSetNameBeforeSave;
                _map_change := false;
              end
            else if LoadBtn.IsClick(MyMouse.X, MyMouse.Y) then    // Click Load
              begin
                FileModal.Show;
                // WaitResult leaves the last click inside the window in MyMouse
                _close_window_result := FileModal.WaitResult(MyMouse.X, MyMouse.Y);
                _dialog_shown := true;
                if length(_close_window_result.S) > 4 then
                  begin
                    Map_OBJ.LoadMap(_close_window_result.S);
                    Map_OBJ.Draw;
                    Grid_LVL.SetMap(Map_OBJ.GetLevel(Map_OBJ._active));
                    Map_NAME.SetName(_close_window_result.S);
                    Map_NAME.Draw;
                    _map_change := false;
                  end;
              end
            else if NewBtn.IsClick(MyMouse.X, MyMouse.Y) then   // Click New
              begin
                InitNewMap;
              end
            else if Map_NAME.IsClick(MyMouse.X, MyMouse.Y) then // EDIT FILE NAME (mouse is hidden)
              Map_NAME.EditName
            else if Grid_OBJ.IsClick(MyMouse.X, MyMouse.Y) then // CHANGE LEFT BUTTON ELEMENT
              PickTool(Grid_L);

          end;
        
        // RIGHT BUTTON CLICK
        if RBtnRelease(MyMouse.Btn, prev_mouse_rb) AND Grid_OBJ.IsClick(MyMouse.X, MyMouse.Y) then
          PickTool(Grid_R);  // CHANGE RIGHT BUTTON ELEMENT

        // the click that closed a window must not reach the map under it
        if _dialog_shown then
          // nothing
        else if Grid_LVL.IsClick(MyMouse.X, MyMouse.Y) then  // PUT OBJECT INTO MAP
          begin
            _click_cell_type := specialize IfElse<CellType>(RBtnRelease(MyMouse.Btn, prev_mouse_rb), Grid_R.GetTypeCell(0, 0), Grid_L.GetTypeCell(0, 0));
            _click_lvl_cell := Grid_LVL.GetClickedCell(MyMouse.X, MyMouse.Y);

            if ChangeCell(_click_lvl_cell.GetType, _click_cell_type) then
              begin
                Grid_LVL.SetTypeCell(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);
                Grid_LVL.DrawCell(_click_lvl_cell.X, _click_lvl_cell.Y);

                Map_OBJ.SetType(_click_lvl_cell.X, _click_lvl_cell.Y, _click_cell_type);
                _map_change := true;
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
                _gold_n := Map_OBJ.CalcGold(_slvl);
              end;
          end;

        DontForgetSaveMap;
        MouseShow;
      end;
    
    prev_mouse_lb := MyMouse.Btn;
    prev_mouse_rb := MyMouse.Btn;
    ColorMagic;
  until (6 > 7);

end.