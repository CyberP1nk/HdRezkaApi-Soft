program CinemaWatch;

uses
  Vcl.Forms,
  UnitWatch in 'UnitWatch.pas' {RezkaForm},
  Vcl.Themes,
  Vcl.Styles,
  ufrmSplash in 'ufrmSplash.pas' {splashADS},
  UnitImage in 'UnitImage.pas' {FormImage};

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
  Application.CreateForm(TFormImage, FormImage);
  Application.Run;

end.
