{$MODE OBJFPC}

// WINDOWS MANAGER
unit _wman;

interface

uses
  io, draw, _types, _util, _font, _windows, design;

type
  TWindowsManager = class
    const
      _file_w_x      : Byte = 82;
      _file_w_y      : Byte = 20;
      
      _rewrite_w_x   : Byte = 65;
      _rewrite_w_y   : Byte = 70;
      _rewrite_w_t   : ShortString = 'File already exist!';
      _rewrite_w_txt : ShortString = 'Would you like to rewrite it?';

      _not_sav_w_x   : Byte = 65;
      _not_sav_w_y   : Byte = 70;
      _not_sav_w_t   : ShortString = 'Map changes not saved!';
      _not_sav_w_txt : array [1..2] of ShortString = ('Would you like to save it',  'before the exit?');

      _no_space_w_x   : Byte = 65;
      _no_space_w_y   : Byte = 70;
      _no_space_w_t   : ShortString = 'No Free disk-space!';
      _no_space_w_txt : ShortString = 'We can not save a file...';
      
    var
      _modals  : array of TModal;
      _result  : TWindowResult;
      _success_close: Boolean;
      _active_window  : ShortInt;

    constructor Create;

    procedure SetResult(result_obj: TWindowResult);
    function GetResult: TWindowResult;
  
    function IsAnyModalOpen: Boolean;
  
    function GetFileModal: TModal;
    function GetRewriteModal: TModal;
    function GetNotSaveModal: TModal;
    function GetNoSpaceModal: TModal;

    procedure FindActiveWindow;
    procedure Action(x, y: Word);
  end;


implementation

    constructor TWindowsManager.Create;
      begin
        _success_close := false;
        _active_window := -1;

        setLength(_modals, 5);
        
        // ERROR
        _modals[0] := TModal.Create(
          'ERROR', 
          ['ERROR'], 
          _no_space_w_x, 
          _no_space_w_y, 
          _no_space_w_x + 50, 
          0, 
          ModalType.SimpleWindow
        );

        // FILE REWRITE
        _modals[1] := TModal.Create(
            _rewrite_w_t,
            [_rewrite_w_txt],
            _rewrite_w_x,
            _rewrite_w_y,
            ModalType.YesNoWindow
          );

        // Changes not saved
        _modals[2] := TModal.Create(
            _not_sav_w_t,
            _not_sav_w_txt,
            _not_sav_w_x,
            _not_sav_w_y,
            ModalType.YesNoWindow
          );

        // No free space
        _modals[3] := TModal.Create(
            _no_space_w_t,
            [_no_space_w_txt],
            _no_space_w_x,
            _no_space_w_y,
            ModalType.SimpleWindow
          );
        
        // File list
        _modals[4] := TModal.Create(
            _file_w_x,
            _file_w_y,
            ModalType.FileWindow
          );

      end;

    // // // // // // // // // //

    procedure TWindowsManager.SetResult(result_obj: TWindowResult);
      begin
        if length(_modals) > 0 then
          _result := result_obj;
      end;

    // // // // // // // // // //

    function TWindowsManager.GetResult: TWindowResult;
      begin
        Result := _result;
      end;

    // // // // // // // // // //

    function TWindowsManager.IsAnyModalOpen: Boolean;
      var _i : Byte;
      
      begin
        if length(_modals) = 0 then exit(False);

        for _i := 0 to length(_modals) - 1 do
          if _modals[_i].IsShown then exit(True);

        Result := false;
      end;

    // // // // // // // // // //

    function TWindowsManager.GetFileModal: TModal;
      begin
        Result := _modals[4];
      end;

    // // // // // // // // // //

    function TWindowsManager.GetRewriteModal: TModal;
      begin
        Result := _modals[1];
      end;

    // // // // // // // // // //

    function TWindowsManager.GetNotSaveModal: TModal;
      begin
        Result := _modals[2];
      end;

    // // // // // // // // // //

    function TWindowsManager.GetNoSpaceModal: TModal;
      begin
        Result := _modals[3];
      end;

    // // // // // // // // // //

    procedure TWindowsManager.FindActiveWindow;
      var _i : Byte;
      begin
        if length(_modals) = 0 then
          begin
            _active_window := -1;
            exit;
          end;

        for _i := 0 to length(_modals) - 1 do
          if _modals[_i].IsShown then
            begin
              _active_window := _i;
              exit;
            end;

        _active_window := -1;
      end;

    // // // // // // // // // //

    procedure TWindowsManager.Action(x, y: Word);
      var 
        _m : TModal;
        _r : TWindowResult;

      begin
        if (_active_window < 0) then FindActiveWindow;

        if (_active_window >= 0) then
          begin
            _m := _modals[_active_window];
            if (not _m.IsClick(x, y)) then exit;
            
            _r := _m.WindowAction(x, y);
            _success_close := specialize IfElse<Boolean>(_m.GetType = ModalType.FileWindow, length(_r.S) > 4, _r.B);

            if _success_close then
              SetResult(_r);

            // window hides itself in WindowAction (on success or not)
            if not _m.IsShown then
              _active_window := -1;

          end;
      end;

    // // // // // // // // // //

end.