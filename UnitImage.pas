unit UnitImage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw;

type
  TFormImage = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormImage: TFormImage;

implementation

{$R *.dfm}

uses UnitWatch;

procedure TFormImage.FormClick(Sender: TObject);
begin
  FormImage.Close;
end;

procedure TFormImage.FormShow(Sender: TObject);
begin
  WebBrowser1.Navigate(UnitWatch.UrlOfImage);

end;

end.
