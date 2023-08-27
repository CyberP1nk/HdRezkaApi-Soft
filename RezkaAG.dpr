program RezkaAG;

uses
  Vcl.Forms,
  UnitWatch in 'UnitWatch.pas' {RezkaForm},
  Vcl.Themes,
  Vcl.Styles,
  ufrmSplash in 'ufrmSplash.pas' {splashADS};

{$R *.res}

var
   SplashScreen: TsplashADS;
begin

  SplashScreen := TsplashADS.Create (splashADS);
  SplashScreen.Show;
  SplashScreen.Update;
  SplashScreen.Release;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TRezkaForm, RezkaForm);
  Application.Run;

end.
