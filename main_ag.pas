program main_ag;

uses
  _ag;

var
  HandleRead : Word;
  GoldImg : ArchiveGraphicFile;


begin
  writeln('START');
  
  GoldImg := ArchiveGraphicFile.Init('\DRAFT\ABC_V2.CG2'#0);
  // GoldImg := ArchiveGraphicFile.Init('\DRAFT\LOAD.CG2'#0);
  GoldImg.Debug;
  GoldImg.GetImg;
  
  // writeln('BB');
end.