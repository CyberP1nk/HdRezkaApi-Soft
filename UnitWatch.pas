unit UnitWatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ipwhttp, scControls, Vcl.StdCtrls,
  Vcl.ComCtrls, RegExpr, System.StrUtils, System.IniFiles, System.NetEncoding,
  System.JSON, ShellApi, ClipBrd, Vcl.ExtCtrls, Vcl.Mask;

type
  TRezkaForm = class(TForm)
    scLabel5: TscLabel;
    scPageControl1: TscPageControl;
    scTabSheet1: TscTabSheet;
    Panel1: TPanel;
    scTabSheet2: TscTabSheet;
    Panel2: TPanel;
    EditLink: TEdit;
    scLabelLink: TscLabel;
    ButtonParse: TButton;
    scListView1: TscListView;
    scLabel1: TscLabel;
    ButtonGetDirectPlayer: TButton;
    scListView2: TscListView;
    scTabSheet3: TscTabSheet;
    Panel3: TPanel;
    scButton1: TscButton;
    scButton2: TscButton;
    Panel4: TPanel;
    Memo1: TMemo;
    scLabel7: TscLabel;
    Panel5: TPanel;
    scListView3: TscListView;
    scLabel6: TscLabel;
    scListView4: TscListView;
    scTabSheet4: TscTabSheet;
    Panel6: TPanel;
    scListView5: TscListView;
    Button1: TButton;
    Button2: TButton;
    scTabSheet5: TscTabSheet;
    Panel7: TPanel;
    EditProxiesIP: TEdit;
    EnableProxiesBox: TCheckBox;
    ProxyTypeBox: TComboBox;
    Button3: TButton;
    scSpinEditTimeOut: TscSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    scTabSheet6: TscTabSheet;
    Panel8: TPanel;
    scListView6: TscListView;
    Button4: TButton;
    Button5: TButton;
    EditSearch: TEdit;
    Label4: TLabel;
    Button6: TButton;
    Button7: TButton;
    procedure ButtonParseClick(Sender: TObject);
    procedure ButtonGetDirectPlayerClick(Sender: TObject);
    procedure scListView2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetProxy;
    procedure scButton1Click(Sender: TObject);
    procedure scButton2Click(Sender: TObject);
    procedure scListView1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure EnableProxiesBoxClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  private
    { Private declarations }
    IniF, IniF2: TInifile;
    function pars(s1, s2, st: string): string;
    function DateTimeToUnix(ConvDate: TDateTime): Longint;
    function SubStr(const S: string; StartPoint, EndPoint: Integer): string;
    function CountOccurences(const SubText: string; const Text: string)
      : Integer;
  public
    { Public declarations }
    ctrl_favs, post_id, translator_ID, urllinkedit, streams: string;
    HTTPS: Tipwhttp;
    Reg: TRegExpr;
  end;

var
  RezkaForm: TRezkaForm;
  LI: TListItem;
  NameLog: string;

implementation

{$R *.dfm}

procedure TRezkaForm.Button1Click(Sender: TObject);
begin
  Button1.Enabled := False;
  Button1.Caption := 'Processing';
  try
    scListView5.Clear;
    HTTPS := Tipwhttp.Create(nil);
    HTTPS.AllowHTTPCompression := true;
    HTTPS.Config
      ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
    HTTPS.Config('CodePage=65001');
    HTTPS.Config('KeepAlive=True');
    SetProxy();
    HTTPS.Accept :=
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1' +
      #13#10 + 'Accept-Language: en-US,en;q=0.9';
    HTTPS.Get('https://rezka.ag/?filter=watching');
    Reg := TRegExpr.Create;
    Reg.Expression :=
      '<div class="b-content__inline_item-link"> <a href="([\d\w\s\.\/\:\-\\]+)">([\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+)</';
    if Reg.Exec(HTTPS.TransferredData) then
      repeat
        LI := RezkaForm.scListView5.Items.Add;
        LI.Caption := Reg.Match[1];
        LI.SubItems.Add(Reg.Match[2]);
      until not Reg.ExecNext;
    Reg.Free;
    HTTPS.Free;
    //
  except

  end;
  Button1.Enabled := true;
  Button1.Caption := 'Get Last';
end;

procedure TRezkaForm.Button2Click(Sender: TObject);
begin
  if RezkaForm.scListView5.Items.count > 0 then
  begin
    Clipboard.AsText := scListView5.Selected.Caption;
  end
  else
    ShowMessage('Bad link!');
end;

procedure TRezkaForm.Button3Click(Sender: TObject);
var
  fProxyStr: string;
begin

  HTTPS := Tipwhttp.Create(nil);
  HTTPS.AllowHTTPCompression := true;
  HTTPS.Config
    ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
  HTTPS.Config('CodePage=65001');
  HTTPS.Config('KeepAlive=True');
  SetProxy();

  HTTPS.Accept :=
    'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
  HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1' +
    #13#10 + 'Accept-Language: en-US,en;q=0.9';
  HTTPS.Get('https://rezka.ag/');
  if pos('rezka.ag', HTTPS.TransferredHeaders) > 0 then
    ShowMessage('Success!')
  else
    ShowMessage('No Response!');

  HTTPS.Free;
end;

procedure TRezkaForm.Button4Click(Sender: TObject);
begin
  Button4.Enabled := False;
  Button4.Caption := 'Processing';
  try
    scListView6.Clear;
    HTTPS := Tipwhttp.Create(nil);
    HTTPS.AllowHTTPCompression := true;
    HTTPS.Config
      ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
    HTTPS.Config('CodePage=65001');
    HTTPS.Config('KeepAlive=True');
    SetProxy();
    HTTPS.Accept :=
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1' +
      #13#10 + 'Accept-Language: en-US,en;q=0.9';
    HTTPS.Get('https://rezka.ag/search/?do=search&subaction=search&q=' +
      StringReplace(EditSearch.Text, ' ', '+', [rfReplaceAll]));
    Reg := TRegExpr.Create;
    Reg.Expression :=
      '<div class="b-content__inline_item-link"> <a href="([\d\w\s\.\/\:\-\\]+)">([\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+)</';
    if Reg.Exec(HTTPS.TransferredData) then
      repeat
        LI := RezkaForm.scListView6.Items.Add;
        LI.Caption := Reg.Match[1];
        LI.SubItems.Add(Reg.Match[2]);
      until not Reg.ExecNext;
    Reg.Free;
    HTTPS.Free;
    //
  except

  end;
  Button4.Enabled := true;
  Button4.Caption := 'Search';
end;

procedure TRezkaForm.Button5Click(Sender: TObject);
begin
  if RezkaForm.scListView6.Items.count > 0 then
  begin
    Clipboard.AsText := scListView6.Selected.Caption;
  end
  else
    ShowMessage('Bad link!');
end;

procedure TRezkaForm.Button6Click(Sender: TObject);
begin

  if RezkaForm.scListView5.Items.count > 0 then
  begin
    EditLink.Text := scListView5.Selected.Caption;
    scPageControl1.ActivePage := scTabSheet1;
  end
  else
    ShowMessage('Bad link!');

end;

procedure TRezkaForm.Button7Click(Sender: TObject);
begin
  if RezkaForm.scListView6.Items.count > 0 then
  begin
    EditLink.Text := scListView6.Selected.Caption;
    scPageControl1.ActivePage := scTabSheet1;
  end
  else
    ShowMessage('Bad link!');

end;

procedure TRezkaForm.ButtonGetDirectPlayerClick(Sender: TObject);
var
  JSonValue: TJSonValue;
  urlparse, xlink: string;
begin
  ButtonGetDirectPlayer.Enabled := False;
  ButtonGetDirectPlayer.Caption := 'Processing';
  RezkaForm.scListView3.Items.Clear;
  IniF.WriteString('ED', 'Ed1', EditLink.Text);

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
      SetProxy();
      HTTPS.Accept :=
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
      HTTPS.ContentType := 'application/x-www-form-urlencoded; charset=UTF-8';
      HTTPS.PostData := 'id=' + post_id + '&translator_id=' + translator_ID +
        '&season=' + scListView4.Selected.Caption + '&episode=' +
      { RezkaForm.EditEpisode.Text } scListView4.Selected.SubItems.Text +
        '&favs=' + ctrl_favs + '&action=get_stream';
      // scListView4listView.SelectedItems(0).SubItems(1).Text
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

  ButtonGetDirectPlayer.Enabled := true;
  ButtonGetDirectPlayer.Caption := 'Get resolution';
  HTTPS.Free;
end;

procedure TRezkaForm.ButtonParseClick(Sender: TObject);
var
  NameLog: string;
  i: Integer;

  lowseason, highseason: string;

begin
  Memo1.Text := '';
  scListView4.Clear;
  scListView2.Clear;
  scListView3.Clear;
  ButtonParse.Enabled := False;
  ButtonParse.Caption := 'Processing';
  scTabSheet2.Enabled := False;
  scTabSheet3.Enabled := False;
  scTabSheet2.TabVisible := False;
  scTabSheet3.TabVisible := False;
  HTTPS := Tipwhttp.Create(nil);
  HTTPS.AllowHTTPCompression := true;
  HTTPS.Config
    ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
  HTTPS.Config('CodePage=65001');
  HTTPS.Config('KeepAlive=True');
  //
  SetProxy();
  try
    scListView1.Clear;

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

        HTTPS.Accept :=
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
        HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1'
          + #13#10 + 'Accept-Language: en-US,en;q=0.9';
        HTTPS.Get(urllinkedit);
        if pos('rezka.ag', HTTPS.TransferredHeaders) > 0 then
        begin

          Reg.Expression := 'data-translator_id="([\d]+)">(.*?)<';
          if Reg.Exec(HTTPS.TransferredData) then
            repeat
              LI := RezkaForm.scListView1.Items.Add;
              LI.Caption := Reg.Match[1];
              LI.SubItems.Add(Reg.Match[2]);

            until not Reg.ExecNext;
          Reg.Expression :=
            'data-season_id="([\d]+)" data-episode_id="([\d]+)">[\d\s\w\А-Я\а-я]+<\/li><\/ul><\/div>';
          if Reg.Exec(HTTPS.TransferredData) then
            repeat
              Memo1.Text := 'S:' + Reg.Match[1] + '|' + 'E:' + Reg.Match[2];
            until not Reg.ExecNext;
          lowseason := '';
          Reg.Expression :=
            'data-season_id="([\d]+)" data-episode_id="([\d]+)">[\d\s\w\А-Я\а-я]+<\/li>';
          if Reg.Exec(HTTPS.TransferredData) then
            lowseason := Reg.Match[1];
          highseason := '';
          Reg.Expression :=
            'data-season_id="([\d]+)" data-episode_id="([\d]+)">[\d\s\w\А-Я\а-я]+<\/li><\/ul><\/div>';
          if Reg.Exec(HTTPS.TransferredData) then
          begin
            Memo1.Text := 'S:' + Reg.Match[1] + '|' + 'E:' + Reg.Match[2];
            highseason := Reg.Match[1];
          end;
          try
            if StrToInt(highseason) > 0 then
            begin
              for i := (StrToInt(lowseason)) to StrToInt(highseason) do
              begin
                Reg.Expression := 'data-season_id="' + inttostr(i) +
                  '" data-episode_id="([\d]+)"';
                if Reg.Exec(HTTPS.TransferredData) then
                  repeat
                    LI := RezkaForm.scListView4.Items.Add;
                    LI.Caption := inttostr(i);
                    LI.SubItems.Add(Reg.Match[1]);
                  until not Reg.ExecNext;
              end;
            end;
          except

          end;
          if RezkaForm.scListView1.Items.count = 0 then
          begin
            Reg.Expression :=
              'sof\.tv\.(initCDNSeriesEvents|initCDNMoviesEvents)\([\d]+, ([\d]+),';
            if Reg.Exec(HTTPS.TransferredData) then
              repeat
                LI := RezkaForm.scListView1.Items.Add;
                LI.Caption := Reg.Match[2];
                LI.SubItems.Add('Single translation!');
                LI := RezkaForm.scListView4.Items.Add;
                LI.Caption := Reg.Match[2];
                LI.SubItems.Add('Single translation!');
              until not Reg.ExecNext;
          end;
          streams := pars('{"id":"cdnplayer","streams":"', '"',
            HTTPS.TransferredData);
          post_id := pars('name="post_id" id="post_id" value="', '"',
            HTTPS.TransferredData);
          ctrl_favs := pars('<input type="hidden" id="ctrl_favs" value="', '"',
            HTTPS.TransferredData);
          ButtonParse.Enabled := true;
          ButtonParse.Caption := 'Get translation';
          HTTPS.Free;
          Reg.Free;
        end
        else
          ShowMessage('Bad connection!');
      end
      else
        ShowMessage('No link insert!');
    end
    else
      ShowMessage('Bad link!');
  finally
    ButtonParse.Enabled := true;
    ButtonParse.Caption := 'Get translation';
  end;

end;

function TRezkaForm.CountOccurences(const SubText, Text: string): Integer;
begin
  Result := pos(SubText, Text);
  if Result > 0 then
    Result := (Length(Text) - Length(StringReplace(Text, SubText, '',
      [rfReplaceAll]))) div Length(SubText);
end;

procedure TRezkaForm.EnableProxiesBoxClick(Sender: TObject);
begin
  if EnableProxiesBox.Enabled = true then
    Button3.Enabled := true
  else
    Button3.Enabled := False;
end;

function TRezkaForm.DateTimeToUnix(ConvDate: TDateTime): Longint;
const
  UnixStartDate: TDateTime = 25569.0;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
end;

procedure TRezkaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IniF.WriteString('ED', 'Ed1', EditLink.Text);

  IniF.WriteString('PX', 'p1', EditProxiesIP.Text);
  IniF.WriteBool('PX', 'e1', EnableProxiesBox.Checked);
  IniF.WriteInteger('PX', 'p2', ProxyTypeBox.ItemIndex);
  IniF.WriteInteger('PX', 'sp1', trunc(scSpinEditTimeOut.Value));

end;

procedure TRezkaForm.FormCreate(Sender: TObject);
begin
  IniF := TInifile.Create(ExtractFilePath(Application.ExeName) + 'SeEp.ini');
  scTabSheet2.Enabled := False;
  scTabSheet3.Enabled := False;
  scTabSheet2.TabVisible := False;
  scTabSheet3.TabVisible := False;
  EditLink.Text := IniF.ReadString('ED', 'Ed1', '');
  EnableProxiesBox.Checked := IniF.ReadBool('PX', 'e1', False);
  EditProxiesIP.Text := IniF.ReadString('PX', 'p1', '');
  ProxyTypeBox.ItemIndex := IniF.ReadInteger('PX', 'p2', 0);
  scSpinEditTimeOut.Value := IniF.ReadInteger('PX', 'sp1', 15);

end;

function TRezkaForm.pars(s1, s2, st: string): string;
var
  p1: Integer;
begin
  Result := '';
  p1 := pos(s1, st);
  if p1 > 0 then
  begin
    p1 := p1 + Length(s1);
    Result := Copy(st, p1, posex(s2, st, p1) - p1);
  end;
end;

procedure TRezkaForm.scButton1Click(Sender: TObject);
var
  string1: string;
begin

  if (RezkaForm.scListView3.Items.count > 0) then
  begin
    try
      string1 := scListView3.Selected.Caption;
      NameLog := FormatDateTime('dd.mm.yyyy"-"hh.nn.ss', now);
      IniF.WriteString('ED', NameLog, urllinkedit + '|S:' +
        scListView4.Selected.Caption + '|E:' +
        scListView4.Selected.SubItems.Text);
      // RezkaForm.scListView3.Items.Add.Caption := scListView2.Selected.SubItems.Text;
      ShellExecute(Handle, 'open', PChar(string1), nil, nil, SW_NORMAL);

    except
      ShowMessage('Link not selected!');
    end;

  end
  else
    ShowMessage('Bad link!');

end;

procedure TRezkaForm.scButton2Click(Sender: TObject);
begin
  if RezkaForm.scListView3.Items.count > 0 then
  begin
    try
      Clipboard.AsText := scListView3.Selected.Caption;
      NameLog := FormatDateTime('dd.mm.yyyy"-"hh.nn.ss', now);
      IniF.WriteString('ED', NameLog, urllinkedit + '|S:' +
        scListView4.Selected.Caption + '|E:' +
        scListView4.Selected.SubItems.Text);
    except
      ShowMessage('Link not selected!');
    end;
  end
  else
    ShowMessage('Bad link!');
end;

procedure TRezkaForm.scListView1Click(Sender: TObject);
begin
  if RezkaForm.scListView1.Items.count > 0 then
  begin
    scTabSheet2.Enabled := true;
    scTabSheet2.TabVisible := true;
  end;
end;

procedure TRezkaForm.scListView2Click(Sender: TObject);
var
  separate: string;

begin
  RezkaForm.scListView3.Items.Clear;
  if RezkaForm.scListView2.Items.count > 0 then
  begin
    scTabSheet3.Enabled := true;
    scTabSheet3.TabVisible := true;
    RezkaForm.scListView3.Items.Add.Caption :=
      scListView2.Selected.SubItems.Text;
  end;
end;

procedure TRezkaForm.SetProxy;
var
  resultcount, get1, get2, fProxyStr: string;
begin
  if EnableProxiesBox.Checked = true then
  begin
    HTTPS.Timeout := trunc(scSpinEditTimeOut.Value);
    HTTPS.FirewallType := TipwhttpFirewallTypes((ProxyTypeBox.ItemIndex) + 1);
    fProxyStr := EditProxiesIP.Text;

    resultcount := inttostr(CountOccurences(':', fProxyStr));
    if pos('3', resultcount) = 0 then
    begin
      HTTPS.FirewallHost := Copy(fProxyStr, 1, pos(':', fProxyStr) - 1);
      HTTPS.FirewallPort := StrToInt(Copy(fProxyStr, pos(':', fProxyStr) + 1,
        Length(fProxyStr)));
    end
    else
    begin
      HTTPS.FirewallHost := Copy(fProxyStr, 1, pos(':', fProxyStr) - 1);
      get1 := Copy(fProxyStr, pos(':', fProxyStr) + 1, Length(fProxyStr));
      HTTPS.FirewallPort := StrToInt(Copy(get1, 1, pos(':', get1) - 1));
      get2 := Copy(get1, pos(':', get1) + 1, Length(get1));
      HTTPS.FirewallUser := Copy(get2, 1, pos(':', get2) - 1);
      HTTPS.FirewallPassword := Copy(get2, pos(':', get2) + 1, Length(get2));
    end;
  end;
end;

function TRezkaForm.SubStr(const S: string;
  StartPoint, EndPoint: Integer): string;
begin
  Result := Copy(S, StartPoint, EndPoint + 1 - StartPoint);
end;

end.
