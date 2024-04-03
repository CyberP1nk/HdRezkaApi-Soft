unit UnitWatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ipwhttp, scControls, Vcl.StdCtrls,
  Vcl.ComCtrls, System.RegularExpressions, System.StrUtils, System.IniFiles,
  System.NetEncoding,
  System.JSON, ShellApi, ClipBrd, Vcl.ExtCtrls, Vcl.Mask, SysUtils,
  Vcl.OleCtrls;

type
  TRezkaForm = class(TForm)
    scLabel5: TscLabel;
    scPageControl1: TscPageControl;
    scTabSheet2: TscTabSheet;
    Panel2GetResolution: TPanel;
    scListViewResolution: TscListView;
    Panel4: TPanel;
    scListViewSE: TscListView;
    scTabSheet4: TscTabSheet;
    Panel6GetLast: TPanel;
    scListViewTop: TscListView;
    ButtonGetLast: TButton;
    ButtonCopyLinkTop: TButton;
    scTabSheet5: TscTabSheet;
    Panel7Proxies: TPanel;
    EditProxiesIP: TEdit;
    EnableProxiesBox: TCheckBox;
    ProxyTypeBox: TComboBox;
    ButtonCheckProxies: TButton;
    scSpinEditTimeOut: TscSpinEdit;
    Button1stTop: TButton;
    ComboBoxCinemaType: TComboBox;
    ComboBoxType: TComboBox;
    LabeledEditStatus: TLabeledEdit;
    scButtonCopyLink: TscButton;
    scButtonOpenBrowser: TscButton;
    scListViewTranslations: TscListView;
    ButtonParse: TButton;
    scTabSheet1: TscTabSheet;
    Panel1: TPanel;
    Memo1: TMemo;
    Note: TscTabSheet;
    MemoNote: TMemo;
    EditSearch: TEdit;
    ButtonSearch: TButton;
    procedure ButtonParseClick(Sender: TObject);
    procedure scButtonOpenBrowserClick(Sender: TObject);
    procedure scButtonCopyLinkClick(Sender: TObject);
    procedure ButtonGetLastClick(Sender: TObject);
    procedure ButtonCopyLinkTopClick(Sender: TObject);
    procedure ButtonCheckProxiesClick(Sender: TObject);
    procedure EnableProxiesBoxClick(Sender: TObject);
    procedure ButtonSearchClick(Sender: TObject);

    procedure Button1stTopClick(Sender: TObject);

    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBoxCinemaTypeChange(Sender: TObject);
    procedure ComboBoxTypeChange(Sender: TObject);
    procedure scListViewSESelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);

    procedure scListViewTopSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure scListViewSearchSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);

  private
    { Private declarations }
    IniF: TInifile;
    Reg: TRegEx;

    topurl, ctrl_favs, post_id, translator_ID, urllinkedit, streams,
      response: string;
    match: TMatch;
    function pars(s1, s2, st: string): string;
    function URLGO(url, method, data: string): string;
    function DateTimeToUnix(ConvDate: TDateTime): Longint;
    function SubStr(const S: string; StartPoint, EndPoint: integer): string;
    function CountOccurences(const SubText: string; const Text: string)
      : integer;
    Function regexParse(const searchableValue: string): string;
    procedure savedata(url, sep, sse: string);
    procedure AddTranslationToListView(listView: TscListView;
      const translation: string);
  public
    { Public declarations }

  end;

var
  RezkaForm: TRezkaForm;
  UrlOfImage: string;

implementation

{$R *.dfm}

uses UnitImage;

procedure TRezkaForm.ButtonGetLastClick(Sender: TObject);
begin
  ButtonGetLast.Enabled := False;
  ButtonGetLast.Caption := 'Processing';
  scListViewTop.Clear;
  if ComboBoxCinemaType.ItemIndex <> 0 then
    topurl := 'https://rezka.ag/' + ComboBoxCinemaType.Text + '/' +
      ComboBoxType.Text + '/'
  else
    topurl := 'https://rezka.ag/?filter=watching';

  regexParse(URLGO(topurl, 'GET', ''));
  ButtonGetLast.Enabled := true;
  ButtonGetLast.Caption := 'Get Last';
end;

procedure TRezkaForm.ButtonCopyLinkTopClick(Sender: TObject);
begin
  if scListViewTop.Selected <> nil then
    Clipboard.AsText := scListViewTop.Selected.Caption
  else
    ShowMessage('No item selected!');
end;

procedure TRezkaForm.ButtonCheckProxiesClick(Sender: TObject);
begin
  ButtonCheckProxies.Enabled := False;
  ButtonCheckProxies.Caption := 'Checking';

  if pos('rezka.ag', URLGO('https://rezka.ag/', 'GET', '')) > 0 then
    ShowMessage('Success!')
  else
    ShowMessage('No Response!');

  ButtonCheckProxies.Enabled := true;
  ButtonCheckProxies.Caption := 'Check Proxies';
end;

procedure TRezkaForm.ButtonSearchClick(Sender: TObject);
begin
  ButtonSearch.Enabled := False;
  ButtonSearch.Caption := 'Processing';
  scListViewTop.Clear;
  regexParse(URLGO('https://rezka.ag/search/?do=search&subaction=search&q=' +
    StringReplace(EditSearch.Text, ' ', '+', [rfReplaceAll]), 'GET', ''));
  ButtonSearch.Enabled := true;
  ButtonSearch.Caption := 'Search';
end;

procedure TRezkaForm.Button1stTopClick(Sender: TObject);
begin
  if scListViewTop.Selected <> nil then
  begin
    response := scListViewTop.Selected.Caption;
    scPageControl1.ActivePage := scTabSheet2;
  end
  else
    ShowMessage('No item selected!');
end;

procedure TRezkaForm.AddTranslationToListView(listView: TscListView;
  const translation: string);
begin
  with listView.Items.Add do
  begin
    Caption := translation;
    SubItems.Add('Single translation!');
  end;
end;

procedure TRezkaForm.ButtonParseClick(Sender: TObject);
var
  HTTPdata: string;
begin

  urllinkedit := '';

  scListViewSE.Clear;
  scListViewResolution.Clear;
  scListViewSE.Enabled := False;
  scListViewTranslations.Clear;

  ButtonParse.Enabled := False;
  ButtonParse.Caption := 'Processing';

  if response <> '' then
  begin

    Reg := TRegEx.Create('((https:|http:)\/\/.*?.html)',
      [roIgnoreCase, roMultiline]);
    match := Reg.match(response);
    while match.Success do
    begin
      urllinkedit := match.Groups.Item[1].Value;
      match := match.NextMatch;
    end;
    HTTPdata := URLGO(urllinkedit, 'GET', '');
    if pos('rezka.ag', HTTPdata) > 0 then
    begin
      Reg := TRegEx.Create
        ('data-translator_id="([\d]+)(">|" data-camrip="[\d]+" data-ads="[\d]+" data-director="[\d]+" data-cdn_quality="">)(.*?)<',
        [roIgnoreCase, roMultiline]);
      match := Reg.match(HTTPdata);
      while match.Success do
      begin
        with scListViewTranslations.Items.Add do
        begin
          Caption := match.Groups.Item[1].Value;
          SubItems.Add(match.Groups.Item[3].Value);
        end;
        match := match.NextMatch;
      end;

      Reg := TRegEx.Create
        ('data-season_id="([\d]+)" data-episode_id="([\d]+)">',
        [roIgnoreCase, roMultiline]);
      match := Reg.match(HTTPdata);
      while match.Success do
      begin
        with scListViewSE.Items.Add do
        begin
          Caption := match.Groups.Item[1].Value;
          SubItems.Add(match.Groups.Item[2].Value);
        end;
        { LabeledEditMaxSeries.Text := 'S:' + match.Groups.Item[1].Value + '|' +
          'E:' + match.Groups.Item[2].Value; }
        match := match.NextMatch;
      end;
      //if scListViewTranslations.Items.count = 0 then
      if scListViewSE.Items.count = 0 then
      begin
        Reg := TRegEx.Create
          ('sof\.tv\.(initCDNSeriesEvents|initCDNMoviesEvents)\([\d]+, ([\d]+),',
          [roIgnoreCase, roMultiline]);
        match := Reg.match(HTTPdata);
        while match.Success do
        begin
          AddTranslationToListView(scListViewTranslations,
            match.Groups.Item[2].Value);
          AddTranslationToListView(scListViewSE, match.Groups.Item[2].Value);
          match := match.NextMatch;
        end;
      end;
      streams := pars('{"id":"cdnplayer","streams":"', '"', HTTPdata);
      post_id := pars('name="post_id" id="post_id" value="', '"', HTTPdata);
      ctrl_favs := pars('<input type="hidden" id="ctrl_favs" value="', '"',
        HTTPdata);
      scListViewTranslations.Selected := scListViewTranslations.Items[0];

      scListViewTranslations.Selected.Focused := true;

      scListViewTranslations.Selected.MakeVisible(False);
      scListViewSE.Selected := scListViewSE.Items[0];

      scListViewSE.Selected.Focused := true;

      scListViewSE.Selected.MakeVisible(False);
    end
    else
      ShowMessage('Bad connection!');
  end
  else
    ShowMessage('No link insert!');
  scListViewSE.Enabled := true;
  ButtonParse.Enabled := true;
  ButtonParse.Caption := 'Get translation';
end;

procedure TRezkaForm.ComboBoxCinemaTypeChange(Sender: TObject);
var
  TempOptions: TStringList;
begin
  ComboBoxType.Items.Clear;
  ComboBoxType.Text := 'Cinema Type';

  TempOptions := TStringList.Create;

  case ComboBoxCinemaType.ItemIndex of
    0:
      begin
        ComboBoxType.Enabled := False;
        ComboBoxType.Text := 'Last Top';
      end;
    1:
      begin
        ComboBoxType.Enabled := Enabled;
        ComboBoxType.Text := 'western';
        TempOptions.AddStrings(['western', 'family', 'fantasy', 'biographical',
          'arthouse', 'action', 'military', 'detective', 'crime', 'adventures',
          'drama', 'sport', 'fiction', 'comedy', 'melodrama', 'thriller',
          'horror', 'musical', 'historical', 'documentary', 'erotic', 'kids',
          'travel', 'cognitive', 'theatre', 'concert', 'standup', 'short',
          'russian', 'ukrainian', 'foreign']);
      end;
    2:
      begin
        ComboBoxType.Enabled := Enabled;
        ComboBoxType.Text := 'military';
        TempOptions.AddStrings(['military', 'action', 'arthouse', 'thriller',
          'horror', 'adventures', 'family', 'fiction', 'fantasy', 'drama',
          'melodrama', 'sport', 'comedy', 'detective', 'crime', 'historical',
          'biographical', 'western', 'documentary', 'musical', 'realtv',
          'telecasts', 'standup', 'erotic', 'russian', 'ukrainian', 'foreign']);
      end;
    3:
      begin
        ComboBoxType.Enabled := Enabled;
        ComboBoxType.Text := 'fiction';
        TempOptions.AddStrings(['fiction', 'fantasy', 'action', 'biographical',
          'comedy', 'western', 'military', 'drama', 'melodrama', 'arthouse',
          'detective', 'crime', 'thriller', 'historical', 'documentary',
          'erotic', 'fairytale', 'family', 'horror', 'adventures', 'sport',
          'cognitive', 'musical', 'anime', 'kids', 'adult', 'multseries',
          'short', 'full-length', 'soyzmyltfilm', 'russian', 'ukrainian',
          'foreign']);
      end;
    4:
      begin
        ComboBoxType.Enabled := Enabled;
        ComboBoxType.Text := 'military';
        TempOptions.AddStrings(['military', 'drama', 'detective', 'thriller',
          'comedy', 'fiction', 'fantasy', 'adventures', 'romance', 'historical',
          'horror', 'mystery', 'musical', 'erotic', 'action', 'fighting',
          'samurai', 'sport', 'educational', 'everyday', 'parody', 'school',
          'kids', 'fairytale', 'kodomo', 'shoujoai', 'shoujo', 'shounen',
          'shounenai', 'ecchi', 'mahoushoujo', 'mecha']);
      end;
  end;

  TempOptions.Sorted := true;
  ComboBoxType.Items.Assign(TempOptions);

  TempOptions.Free;

end;

procedure TRezkaForm.ComboBoxTypeChange(Sender: TObject);
begin
  if ComboBoxCinemaType.ItemIndex <> 0 then
    topurl := 'https://rezka.ag/' + ComboBoxCinemaType.Text + '/' +
      ComboBoxType.Text + '/'
  else
    topurl := 'https://rezka.ag/?filter=watching';
end;

function TRezkaForm.CountOccurences(const SubText, Text: string): integer;
begin
  Result := pos(SubText, Text);
  if Result > 0 then
    Result := (Length(Text) - Length(StringReplace(Text, SubText, '',
      [rfReplaceAll]))) div Length(SubText);
end;

procedure TRezkaForm.EnableProxiesBoxClick(Sender: TObject);
begin
  if EnableProxiesBox.Enabled = true then
    ButtonCheckProxies.Enabled := true
  else
    ButtonCheckProxies.Enabled := False;
end;

function TRezkaForm.DateTimeToUnix(ConvDate: TDateTime): Longint;
const
  UnixStartDate: TDateTime = 25569.0;
begin
  Result := Round((ConvDate - UnixStartDate) * 86400);
end;

procedure TRezkaForm.FormDestroy(Sender: TObject);
begin
  IniF := TInifile.Create(ExtractFilePath(Application.ExeName) +
    'settings.ini');
  IniF.WriteString('Settings', 'Link', response);
  IniF.WriteString('MemoNote', 'Memo', MemoNote.Lines.Text);

  IniF.WriteString('Settings', 'ProxiesIP', EditProxiesIP.Text);
  IniF.WriteBool('Settings', 'ProxiesOn', EnableProxiesBox.Checked);
  IniF.WriteInteger('Settings', 'ProxyType', ProxyTypeBox.ItemIndex);
  IniF.WriteInteger('Settings', 'TimeOut', trunc(scSpinEditTimeOut.Value));
  FreeAndNil(IniF);
end;

procedure TRezkaForm.FormShow(Sender: TObject);
var
  IniF: TInifile;
  TS: TStringList;
begin
  if not FileExists('settings.ini') then
  begin
    TS := TStringList.Create;
    TS.SaveToFile(ExtractFilePath(Application.ExeName) + 'settings.ini');
    FreeAndNil(TS);
  end;

  IniF := TInifile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');
  response := IniF.ReadString('Settings', 'Link', '');
  MemoNote.Lines.Text := IniF.ReadString('MemoNote', 'Memo', '');
  EnableProxiesBox.Checked := IniF.ReadBool('Settings', 'ProxiesOn', False);
  EditProxiesIP.Text := IniF.ReadString('Settings', 'ProxiesIP', '');
  ProxyTypeBox.ItemIndex := IniF.ReadInteger('Settings', 'ProxyType', 0);
  scSpinEditTimeOut.Value := IniF.ReadInteger('Settings', 'TimeOut', 15);
  FreeAndNil(IniF);
end;

function TRezkaForm.pars(s1, s2, st: string): string;
var
  p1: integer;
begin
  Result := '';
  p1 := pos(s1, st);
  if p1 > 0 then
  begin
    p1 := p1 + Length(s1);
    Result := Copy(st, p1, posex(s2, st, p1) - p1);
  end;
end;

function TRezkaForm.regexParse(const searchableValue: string): string;
begin
  Reg := TRegEx.Create
    ('<img src="([\d\w\s\.\/\:\-\\]+)" height="[\d]+" width="[\d]+" alt="[\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+" \/> <span class="[\w ]+">'
    + '<i class="[\w]+">[\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+<\/i><i class="[\w]+"><\/i><\/span> (<span class="info">[\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+<\/span> |)'
    + '<i class="i-sprt play"><\/i> <\/a> <i class="[\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+" data-id="[\d]+" data-full="[\d]+"><b>[\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+'
    + '<\/b><\/i> <\/div> <div class="b-content__inline_item-link"> <a href="([\d\w\s\.\/\:\-\\]+)">([\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+)<\/a> <div>([\d\s\w\А-Я\.\а-я\/\\\[\]\,\(\)\-\:]+)<\/',
    [roIgnoreCase, roMultiline]);
  match := Reg.match(searchableValue);
  while match.Success do
  begin
    with scListViewTop.Items.Add do
    begin
      Caption := match.Groups.Item[3].Value;
      SubItems.Add(match.Groups.Item[4].Value);
      SubItems.Add(match.Groups.Item[5].Value);
      SubItems.Add(match.Groups.Item[1].Value);
    end;
    match := match.NextMatch;
  end;
end;

procedure TRezkaForm.savedata(url, sep, sse: string);
var
  NameLog: string;
begin
  NameLog := FormatDateTime('dd.mm.yyyy"-"hh.nn.ss', now);
  IniF := TInifile.Create(ExtractFilePath(Application.ExeName) +
    'settings.ini');
  IniF.WriteString('ED', NameLog, urllinkedit + '|S:' +
    scListViewSE.Selected.Caption + '|E:' +
    scListViewSE.Selected.SubItems.Text);
  FreeAndNil(IniF);
end;

procedure TRezkaForm.scButtonOpenBrowserClick(Sender: TObject);
begin
  if (scListViewResolution.Selected <> nil) and (scListViewSE.Selected <> nil)
  then
  begin
    savedata(urllinkedit, scListViewSE.Selected.Caption,
      scListViewSE.Selected.SubItems.Text);
    ShellExecute(Handle, 'open',
      PChar(scListViewResolution.Selected.SubItems.Text), nil, nil, SW_NORMAL);
  end
  else
    ShowMessage('No item selected!');
end;

procedure TRezkaForm.scButtonCopyLinkClick(Sender: TObject);
begin
  if (scListViewResolution.Selected <> nil) and (scListViewSE.Selected <> nil)
  then
  begin
    savedata(urllinkedit, scListViewSE.Selected.Caption,
      scListViewSE.Selected.SubItems.Text);
    Clipboard.AsText := scListViewResolution.Selected.SubItems.Text;
  end
  else
    ShowMessage('No item selected!');
end;

function TRezkaForm.SubStr(const S: string;
  StartPoint, EndPoint: integer): string;
begin
  Result := Copy(S, StartPoint, EndPoint + 1 - StartPoint);
end;

function TRezkaForm.URLGO(url, method, data: string): string;
var
  HTTPS: Tipwhttp;
  resultcount, get1, get2, fProxyStr: string;
begin
  HTTPS := Tipwhttp.Create(nil);
  try
    HTTPS.AllowHTTPCompression := true;
    HTTPS.Config
      ('UserAgent=Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0');
    HTTPS.Config('CodePage=65001');
    HTTPS.Config('KeepAlive=True');
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
    HTTPS.Accept :=
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    HTTPS.OtherHeaders := 'DNT: 1' + #13#10 + 'Upgrade-Insecure-Requests: 1' +
      #13#10 + 'Accept-Language: en-US,en;q=0.9'+#13#10+'X-Requested-With: XMLHttpRequest'+#13#10+'Origin: https://rezka.ag'+#13#10+'DNT: 1';
    HTTPS.ContentType := 'application/x-www-form-urlencoded; charset=UTF-8';
    if Length(method) < 4 then
    begin
      HTTPS.Get(url);
      Result := HTTPS.TransferredData;
    end
    else
    begin
      HTTPS.PostData := data;
      HTTPS.POST(url);
      Result := HTTPS.TransferredData;
    end;
  finally
    HTTPS.Free;
  end;

end;

procedure TRezkaForm.scListViewSearchSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if scListViewTop.Selected <> nil then
  begin
    UrlOfImage := scListViewTop.Selected.SubItems[2];
    FormImage.Show;
  end;
end;

procedure TRezkaForm.scListViewSESelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  urlparse, xlink: string;
  patterns: array of string;
  pattern: string;
  response: string;
  JSonValue: TJSonvalue;
begin
  scListViewResolution.Clear;
  if (scListViewSE.Selected <> nil) and
    (Length(scListViewSE.Selected.Caption) > 0) then
  begin
    if (scListViewTranslations.Selected <> nil) then
    begin
      if (Length(scListViewSE.Selected.Caption) > 0) then
      begin
        LabeledEditStatus.Text := 'Processing';

        translator_ID := '';
        translator_ID := scListViewTranslations.Selected.Caption;
        response := URLGO('https://hdrezka.ag/ajax/get_cdn_series/?t=' +
          inttostr(DateTimeToUnix(now)), 'POST',
          'id=' + post_id + '&translator_id=' + translator_ID + '&season=' +
          scListViewSE.Selected.Caption + '&episode=' +
          Trim(scListViewSE.Selected.SubItems.Text) + '&favs=' + ctrl_favs +
          '&action=get_stream');
        JSonValue := TJSonObject.ParseJSONValue(response);
        try

          if Assigned(JSonValue) and (JSonValue is TJSonObject) then
          begin
            if JSonValue.TryGetValue<string>('url', response) then
            begin
              urlparse := JSonValue.GetValue<string>('url');
            end
            else
            begin
              urlparse := StringReplace(streams, '\/\/_\/\/', '//_//',
                [rfReplaceAll]);
            end;
          end;

        finally
          JSonValue.Free
        end;

        if Length(urlparse) > 6 then
        begin
          xlink := SubStr(urlparse, 3, Length(urlparse));
          xlink := StringReplace(xlink, '//_//', '', [rfReplaceAll]);
          SetLength(patterns, 6);
          patterns[0] := 'JCQjISFAIyFAIyM=';
          patterns[1] := 'Xl5eIUAjIyEhIyM=';
          patterns[2] := 'IyMjI14hISMjIUBA';
          patterns[3] := 'QEBAQEAhIyMhXl5e';
          patterns[4] := 'JCQhIUAkJEBeIUAjJCRA';
          for pattern in patterns do
            xlink := StringReplace(xlink, pattern, '', [rfReplaceAll]);
          xlink := TNetEncoding.Base64.Decode(xlink);

          Reg := TRegEx.Create('\[(.*?)\](.*?) [\w]+ (.*?)(,|$)',
            [roIgnoreCase, roMultiline]);
          match := Reg.match(xlink);
          while match.Success do
          begin
            with scListViewResolution.Items.Add do
            begin
              Caption := match.Groups.Item[1].Value;
              SubItems.Add(match.Groups.Item[2].Value);
              SubItems.Add(match.Groups.Item[3].Value);
            end;
            match := match.NextMatch;
          end;
          scListViewResolution.Selected := scListViewResolution.Items[0];
          scListViewResolution.Selected.Focused := true;
          scListViewResolution.Selected.MakeVisible(False);
        end
        else
          ShowMessage('Possible IP or Restricted region!');
        LabeledEditStatus.Text := 'Press Watch';
      end
      else
        LabeledEditStatus.Text := 'Select Episode!';
    end
    else
    begin
      LabeledEditStatus.Text := 'Translation row!';
      ShowMessage('Translation row selected required!');
      scListViewTranslations.Selected := scListViewTranslations.Items[0];
      scListViewTranslations.Selected.Focused := true;
      scListViewTranslations.Selected.MakeVisible(False);
    end;
  end
  else
    LabeledEditStatus.Text := 'Get link!';

end;

procedure TRezkaForm.scListViewTopSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if FormImage.Visible then
  begin
    FormImage.Close;
  end;
  if scListViewTop.Selected <> nil then
  begin
    UrlOfImage := scListViewTop.Selected.SubItems[2];
    FormImage.Show;
  end;
end;

end.
