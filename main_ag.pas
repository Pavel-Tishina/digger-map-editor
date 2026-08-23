program main_ag;

uses
  _ag;

var
  HandleRead : Word;
  GoldImg : ArchiveGraphicFile;


begin
  writeln('START');
  
  GoldImg := ArchiveGraphicFile.Init('\DRAFT\GOLD.CG2'#0);
  GoldImg.GetImg;
  
  writeln('BB');
end.