unit uThreadSplash;

interface

uses Classes, ufrmSplash;

type
  TSplashThread = class(TThread)
  private
    SplashScreen: TsplashADS;
  public
    procedure Execute; override;
    procedure DisplaySplash;
  end;

implementation

uses Windows;

// ---------------- TSplashThread ------------------- \\

procedure TSplashThread.Execute;
begin
  Synchronize (DisplaySplash);

  Sleep (2000);
  SplashScreen.Release;

  inherited;
end;

procedure TSplashThread.DisplaySplash;
begin
  SplashScreen := TsplashADS.Create (nil);

  SplashScreen.Show;
  SplashScreen.Update;
end;

end.

