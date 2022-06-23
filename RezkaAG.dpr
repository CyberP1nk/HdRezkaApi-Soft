program RezkaAG;

uses
  Vcl.Forms,
  UnitWatch in 'UnitWatch.pas' {RezkaForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TRezkaForm, RezkaForm);
  Application.Run;
end.
