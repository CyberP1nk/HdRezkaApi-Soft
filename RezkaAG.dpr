program RezkaAG;

uses
  Vcl.Forms,
  UnitWatch in 'UnitWatch.pas' {RezkaForm},
  Vcl.Themes,
  Vcl.Styles,
  ufrmSplash in 'ufrmSplash.pas' {splashADS},
  uThreadSplash in 'uThreadSplash.pas';

{$R *.res}
 var SplashThread: TSplashThread;
begin

  if ParamStr (1) <> '-nosplash' then
   begin
    SplashThread := TSplashThread.Create (False);
    SplashThread.FreeOnTerminate := True;
    SplashThread.Resume;
   end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TRezkaForm, RezkaForm);
  Application.Run;

end.
