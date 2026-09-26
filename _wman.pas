{$MODE OBJFPC}

// WINDOWS MANAGER
unit _wman;

interface

uses
  io, draw, _types, _util, _font, _windows;

type
  TWindowsManager = class
    const
      _file_w_x      : Byte = 82;
      _file_w_y      : Byte = 20;
      
      _rewrite_w_x   : Byte = 70;
      _rewrite_w_y   : Byte = 100;
      _rewrite_w_t   : ShortString = 'File already exist!';
      _rewrite_w_txt : ShortString = 'Would you like to rewrite it?';

      _not_sav_w_x   : Byte = 70;
      _not_sav_w_y   : Byte = 100;
      _not_sav_w_t   : ShortString = 'Map changes not saved!';
      _not_sav_w_txt : ShortString = 'Would you like to save it before exit?';

      _no_space_w_x   : Byte = 70;
      _no_space_w_y   : Byte = 100;
      _no_space_w_t   : ShortString = 'No Free disk-space!';
      _no_space_w_txt : ShortString = 'We can not save a file...';

      
    var
      _modals  : array of TModal;
      _result  : TWindowResult;
      _file_modal_id    : Byte; 
      _rewrite_modal_id : Byte;
      _not_sav_modal_id : Byte;
      _no_space_modal_id : Byte;

    constructor Create;

    procedure SetResult(result_obj: TWindowResult); 
    // procedure DoAfterCloseAction;

    procedure AddModal(modal: TModal);
    function GetFreeId: Byte;
  
    function AddRewriteAlertModal: Byte;
    function AddChangesNotSavedModal: Byte;
    function AddFileListModal: Byte;
    function AddNoSpaceModal: Byte;

    function FindModalById(id: Byte): TModal;
    function IsAnyModalOpen: Boolean;
    function IdModalExist(id: Byte): Boolean;

    function FindFileModal: TModal;
    function FindRewriteModal: TModal;
    function FindNotSaveModal: TModal;
    function FindNoSpaceModal: TModal;
  
  end;


implementation

    constructor TWindowsManager.Create;
      begin
        Randomize;
        // try late init windows =)
        _file_modal_id     := 0; 
        _rewrite_modal_id  := 0;
        _not_sav_modal_id  := 0;
        _no_space_modal_id := 0;

        AddFileListModal;
        AddChangesNotSavedModal;
        AddRewriteAlertModal;
        AddNoSpaceModal;

        // _file_modal_id     := 1; 
        // _rewrite_modal_id  := 2;
        // _not_sav_modal_id  := 3;
        // _no_space_modal_id := 4;
        // setLength(_modals, 4);
        // _modals[0]

      end;

    // // // // // // // // // //

    procedure TWindowsManager.SetResult(result_obj: TWindowResult);
      begin
        if length(_modals) > 0 then
          _result := result_obj;
      end;

    // // // // // // // // // //

    function TWindowsManager.IdModalExist(id: Byte): Boolean;
      var _i : Byte;
      begin
        if length(_modals) = 0 then exit(False);

        for _i := 0 to length(_modals) - 1 do
          if _modals[_i].GetId = id then exit(True);

        exit(false);
      end;

    // // // // // // // // // //

    function TWindowsManager.GetFreeId: Byte;
      var _id : Byte;
      begin
        if length(_modals) = 0 then exit(Random(256));

        repeat
          _id := Random(256);
        until (IdModalExist(_id) = True);

        Result := _id;
      end;

    // // // // // // // // // //

    procedure TWindowsManager.AddModal(modal: TModal);
      var _s : Byte;
      begin
        if IdModalExist(modal.GetId) = True then exit;

        _s := length(_modals);
        setLength(_modals, _s + 1);
        _modals[_s] := modal;
      end;
    
    // // // // // // // // // //

    function TWindowsManager.AddRewriteAlertModal: Byte;
      begin
        if _rewrite_modal_id <> 0 then exit(_rewrite_modal_id);

        _rewrite_modal_id := GetFreeId;
        
        AddModal(
          TModal.Create(
            _rewrite_w_t,
            [_rewrite_w_txt],
            _rewrite_w_x,
            _rewrite_w_y,
            ModalType.YesNoWindow,
            _rewrite_modal_id
          )
        );

        Result := _rewrite_modal_id;
      end;

    // // // // // // // // // //

    function TWindowsManager.AddChangesNotSavedModal: Byte;
      begin
        if _not_sav_modal_id <> 0 then exit(_not_sav_modal_id);
        _not_sav_modal_id := GetFreeId;
        
        AddModal(
          TModal.Create(
            _not_sav_w_t,
            [_not_sav_w_txt],
            _not_sav_w_x,
            _not_sav_w_y,
            ModalType.YesNoWindow,
            _not_sav_modal_id
          )
        );

      Result := _not_sav_modal_id;
    end;

    // // // // // // // // // //

    function TWindowsManager.AddNoSpaceModal: Byte;
      begin
        if _no_space_modal_id <> 0 then exit(_no_space_modal_id);
        _no_space_modal_id := GetFreeId;
        
        AddModal(
          TModal.Create(
            _no_space_w_t,
            [_no_space_w_txt],
            _no_space_w_x,
            _no_space_w_y,
            ModalType.SimpleWindow,
            _no_space_modal_id
          )
        );
      
      Result := _no_space_modal_id;
    end;

    // // // // // // // // // //

    function TWindowsManager.AddFileListModal: Byte;
      begin
        if _file_modal_id <> 0 then exit(_file_modal_id);
        _file_modal_id := GetFreeId;
        
        AddModal(
          TModal.Create(
            _no_space_w_t,
            [_no_space_w_txt],
            _no_space_w_x,
            _no_space_w_y,
            ModalType.SimpleWindow,
            _file_modal_id
          )
        );

      Result := _file_modal_id;
    end;

    // // // // // // // // // //

    function TWindowsManager.FindModalById(id: Byte): TModal;
      var _i : Byte;

      begin
        if (length(_modals) = 0) OR (NOT IdModalExist(id)) then
          exit(TModal.Create('ERROR', [''], _no_space_w_x, _no_space_w_y, ModalType.SimpleWindow, 0));

        for _i := 0 to length(_modals) - 1 do
          if _modals[_i].GetId = id then exit(_modals[_i]); 

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

    function TWindowsManager.FindFileModal: TModal;
      begin
        Result := FindModalById(specialize IfElse<Byte>(_file_modal_id <> 0, _file_modal_id, AddFileListModal));
      end;

    // // // // // // // // // //

    function TWindowsManager.FindRewriteModal: TModal;
      begin
        Result := FindModalById(specialize IfElse<Byte>(_rewrite_modal_id <> 0, _rewrite_modal_id, AddRewriteAlertModal));
      end;

    // // // // // // // // // //

    function TWindowsManager.FindNotSaveModal: TModal;
      begin
        Result := FindModalById(specialize IfElse<Byte>(_not_sav_modal_id <> 0, _not_sav_modal_id, AddChangesNotSavedModal));
      end;

    // // // // // // // // // //

    function TWindowsManager.FindNoSpaceModal: TModal;
      begin
        Result := FindModalById(specialize IfElse<Byte>(_no_space_modal_id <> 0, _no_space_modal_id, AddNoSpaceModal));
      end;

    // // // // // // // // // //

end.