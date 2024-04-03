unit ufrmSplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, scControls,
  scExtControls, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TsplashADS = class(TForm)
    Panel1: TPanel;
    scImage1: TscImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  splashADS: TsplashADS;

implementation

{$R *.dfm}


end.
