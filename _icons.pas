{$IMPLICITEXCEPTIONS OFF}
{$MODE OBJFPC}

unit _icons;

interface

uses
  _ag, _types;

var
  _gold, _hole, _gem, _th, _tv : ArchiveGraphicFile;

  procedure DrawIcon(x, y : Word; t : CellType);

implementation

  // tooooo maaaannny wuuuurrdddzzzzzz!! coooppiii paaaastttaaaa everyveeeeereeee! I tired of print this!!! Refactor to compact variant!
  procedure DrawIcon(x, y : Word; t : CellType);
    begin
      case t of
        Gold:    _gold.Draw2(x, y);
        Hole:    _hole.Draw2(x, y);
        Gem:     _gem.Draw2(x, y);
        TonnelH: _th.Draw2(x, y);
        TonnelV: _tv.Draw2(x, y);
      end;
    end;

begin
  _gold := ArchiveGraphicFile.Init('\DRAFT\GOLD.CG2'#0);
  _hole := ArchiveGraphicFile.Init('\DRAFT\HOLE.CG2'#0);
  _gem := ArchiveGraphicFile.Init('\DRAFT\GEM.CG2'#0);
  _th := ArchiveGraphicFile.Init('\DRAFT\TH.CG2'#0);
  _tv := ArchiveGraphicFile.Init('\DRAFT\TV.CG2'#0);
end.
