unit UnitWatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ipwhttp, scControls, Vcl.StdCtrls,
  Vcl.ComCtrls, RegExpr, System.StrUtils, System.IniFiles, System.NetEncoding,
  System.JSON, ShellApi;

type
  TRezkaForm = class(TForm)
    ButtonParse: TButton;
    scListView1: TscListView;
    EditLink: TEdit;
    scLabelLink: TscLabel;
    scLabel1: TscLabel;
    EditSeason: TEdit;
    EditEpisode: TEdit;
    scLabel2: TscLabel;
    scLabel3: TscLabel;
    ButtonGetDirectPlayer: TButton;
    scListView2: TscListView;
    scLabel4: TscLabel;
    scLabel5: TscLabel;
    scListView3: TscListView;
    scButton1: TscButton;
    procedure ButtonParseClick(Sender: TObject);
    procedure ButtonGetDirectPlayerClick(Sender: TObject);
    procedure scListView2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure scButton1Click(Sender: TObject);
  private
    { Private declarations }
    IniF, IniF2: TInifile;
    function pars(s1, s2, st: string): string;
    function DateTimeToUnix(ConvDate: TDateTime): Longint;
    function SubStr(const S: string; StartPoint, EndPoint: Integer): string;
  public
    { Public declarations }
    ctrl_favs, post_id, translator_ID, urllinkedit, streams: string;
    HTTPS: Tipwhttp;
    Reg: TRegExpr;
  end;

var
  RezkaForm: TRezkaForm;
  LI: TlistItem;

implementation

{$R *.dfm}

procedure TRezkaForm.ButtonGetDirectPlayerClick(Sender: TObject);
var
  JSonValue: TJSonValue;
  urlparse, xlink: string;
begin
  IniF.WriteString('ED', 'Ed1', EditLink.Text);
  IniF.WriteString('ED', 'Ed2', EditSeason.Text);
  IniF.WriteString('ED', 'Ed3', EditEpisode.Text);
  HTTPS := Tipwhttp.Create(nil);
  HTTPS.AllowHTTPCompression := true;
  HTTPS.Config
    ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
  HTTPS.Config('CodePage=65001');
  HTTPS.Config('KeepAlive=True');
  try
    scListView2.Clear;
  finally
  end;
  if urllinkedit <> '' then
  begin
    translator_ID := '';
    try
      translator_ID := scListView1.Selected.Caption;

      HTTPS.Accept :=
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
      HTTPS.ContentType := 'application/x-www-form-urlencoded; charset=UTF-8';
      HTTPS.PostData := 'id=' + post_id + '&translator_id=' + translator_ID +
        '&season=' + RezkaForm.EditSeason.Text + '&episode=' +
        RezkaForm.EditEpisode.Text + '&favs=' + ctrl_favs +
        '&action=get_stream';
      HTTPS.POST('https://hdrezka.ag/ajax/get_cdn_series/?t=' +
        inttostr(DateTimeToUnix(now)));

      JSonValue := TJSonObject.ParseJSONValue(HTTPS.TransferredData);
      try
        urlparse := JSonValue.GetValue<string>('url');
      except
        urlparse := StringReplace(streams, '\/\/_\/\/', '//_//',
          [rfReplaceAll]);
      end;
      JSonValue.Free;

      xlink := SubStr(urlparse, 3, Length(urlparse));
      xlink := StringReplace(xlink, '//_//', '', [rfReplaceAll]);
      xlink := StringReplace(xlink, 'JCQjISFAIyFAIyM=', '', [rfReplaceAll]);
      xlink := StringReplace(xlink, 'Xl5eIUAjIyEhIyM=', '', [rfReplaceAll]);
      xlink := StringReplace(xlink, 'IyMjI14hISMjIUBA', '', [rfReplaceAll]);
      xlink := StringReplace(xlink, 'QEBAQEAhIyMhXl5e', '', [rfReplaceAll]);
      xlink := StringReplace(xlink, 'JCQhIUAkJEBeIUAjJCRA', '', [rfReplaceAll]);
      xlink := TnetEncoding.Base64String.Decode(xlink);

      Reg := TRegExpr.Create;
      Reg.Expression := '\[(.*?)\](.*?) [\w]+ (.*?)(,|$)';
      if Reg.Exec(xlink) then
        repeat
          LI := RezkaForm.scListView2.Items.Add;
          LI.Caption := Reg.Match[1];
          LI.SubItems.Add(Reg.Match[2]);
          LI.SubItems.Add(Reg.Match[3]);
        until not Reg.ExecNext;
      Reg.Free;

    except
      ShowMessage('Get the info about translation first!');
    end;
  end
  else
    ShowMessage('Get the info about translation first!');

  HTTPS.Free;
end;

procedure TRezkaForm.ButtonParseClick(Sender: TObject);
var
  NameLog: string;
  i: Integer;
begin
  HTTPS := Tipwhttp.Create(nil);
  HTTPS.AllowHTTPCompression := true;
  HTTPS.Config
    ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
  HTTPS.Config('CodePage=65001');
  HTTPS.Config('KeepAlive=True');
  //

  try
    scListView1.Clear;
  finally
  end;
  if RezkaForm.EditLink.Text <> '' then
  begin
    HTTPS.ResetHeaders;
    Reg := TRegExpr.Create;
    urllinkedit := '';

    Reg.Expression := '((https:|http:)\/\/.*?.html)';
    if Reg.Exec(RezkaForm.EditLink.Text) then
    begin
      repeat
        urllinkedit := Reg.Match[1];
      until not Reg.ExecNext;
    end
    else
      ShowMessage('Bad link!');

    NameLog := FormatDateTime('dd.mm.yyyy"-"hh.nn.ss', now);
    IniF.WriteString('ED', NameLog, urllinkedit);
    HTTPS.Accept :=
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1' +
      #13#10 + 'Accept-Language: en-US,en;q=0.9';
    HTTPS.Get(urllinkedit);

    Reg.Expression := 'data-translator_id="([\d]+)">(.*?)<';
    if Reg.Exec(HTTPS.TransferredData) then
      repeat
        LI := RezkaForm.scListView1.Items.Add;
        LI.Caption := Reg.Match[1];
        LI.SubItems.Add(Reg.Match[2]);

      until not Reg.ExecNext;

    if RezkaForm.scListView1.Items.count = 0 then
    begin
      Reg.Expression :=
        'sof\.tv\.(initCDNSeriesEvents|initCDNMoviesEvents)\([\d]+, ([\d]+),';
      if Reg.Exec(HTTPS.TransferredData) then
        repeat
          LI := RezkaForm.scListView1.Items.Add;
          LI.Caption := Reg.Match[2];
          LI.SubItems.Add('Single translation! Одна озвучка!');

        until not Reg.ExecNext;
    end;
    streams := pars('{"id":"cdnplayer","streams":"', '"',
      HTTPS.TransferredData);
    post_id := pars('name="post_id" id="post_id" value="', '"',
      HTTPS.TransferredData);
    ctrl_favs := pars('<input type="hidden" id="ctrl_favs" value="', '"',
      HTTPS.TransferredData);
    HTTPS.Free;
    Reg.Free;
  end
  else
    ShowMessage('No link insert!');
end;

function TRezkaForm.DateTimeToUnix(ConvDate: TDateTime): Longint;
const
  UnixStartDate: TDateTime = 25569.0;
begin
  result := Round((ConvDate - UnixStartDate) * 86400);
end;

procedure TRezkaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IniF.WriteString('ED', 'Ed1', EditLink.Text);
  IniF.WriteString('ED', 'Ed2', EditSeason.Text);
  IniF.WriteString('ED', 'Ed3', EditEpisode.Text);
end;

procedure TRezkaForm.FormCreate(Sender: TObject);
begin
  IniF := TInifile.Create(ExtractFilePath(Application.ExeName) + 'SeEp.ini');

  // IniF.ReadSections(scListBox1.Items);
  EditLink.Text := IniF.ReadString('ED', 'Ed1', '');
  EditSeason.Text := IniF.ReadString('ED', 'Ed2', '');
  EditEpisode.Text := IniF.ReadString('ED', 'Ed3', '');
end;

function TRezkaForm.pars(s1, s2, st: string): string;
var
  p1: Integer;
begin
  result := '';
  p1 := pos(s1, st);
  if p1 > 0 then
  begin
    p1 := p1 + Length(s1);
    result := Copy(st, p1, posex(s2, st, p1) - p1);
  end;
end;

procedure TRezkaForm.scButton1Click(Sender: TObject);
var
string1: string;
begin
 if RezkaForm.scListView2.Items.count > 0 then
  begin
  string1 := scListView3.Selected.Caption;
   // RezkaForm.scListView3.Items.Add.Caption := scListView2.Selected.SubItems.Text;
    ShellExecute( Handle, 'open', PChar(string1), nil, nil, SW_NORMAL );
  end;

end;

procedure TRezkaForm.scListView2Click(Sender: TObject);
var
  separate: string;

begin
   RezkaForm.scListView3.Items.Clear;
  if RezkaForm.scListView2.Items.count > 0 then
  begin
    RezkaForm.scListView3.Items.Add.Caption := scListView2.Selected.SubItems.Text;
  end;
end;



function TRezkaForm.SubStr(const S: string;
  StartPoint, EndPoint: Integer): string;
begin
  result := Copy(S, StartPoint, EndPoint + 1 - StartPoint);
end;

end.
