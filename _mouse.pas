unit _mouse;

// Implementation: asm/mouse.asm

interface

type
  TMouseState = record
    X: Word;
    Y: Word;
    Btn: Word;
  end;

var
  MyMouse: TMouseState; // cuz nasty error "Duplicate" identifier "mouse" is here... damned Pascal namespaces

    function MouseInit: Boolean; pascal; external name 'MOUSE_INIT';

    procedure MouseSetRange320x200; pascal; external name 'MOUSE_SETRANGE320X200';
    procedure MouseShow; pascal; external name 'MOUSE_SHOW';
    procedure MouseHide; pascal; external name 'MOUSE_HIDE';

    procedure MouseUpdate;

implementation

{$L asm/mouse.obj}

    procedure MouseRead(var State: TMouseState); pascal; external name 'MOUSE_READ';

    procedure MouseUpdate;
        begin
            MouseRead(MyMouse);
        end;

end.
