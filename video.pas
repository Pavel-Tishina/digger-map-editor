unit video;

// Implementation: asm/video.asm

interface

procedure SetVideoMode13h; pascal; external name 'VIDEO_SETVIDEOMODE13H';
procedure SetTextMode; pascal; external name 'VIDEO_SETTEXTMODE';
// move it to IO.PAS
procedure WaitKey; pascal; external name 'VIDEO_WAITKEY';

implementation

{$L asm/video.obj}

end.
