unit video;

// Implementation: asm/video.asm

interface

procedure SetVideoMode13h; pascal; external name 'VIDEO_SETVIDEOMODE13H';
procedure SetTextMode; pascal; external name 'VIDEO_SETTEXTMODE';

implementation

{$L asm/video.obj}

end.
