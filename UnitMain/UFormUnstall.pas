unit UFormUnstall;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, IdHTTP;

type
  TfrmUnstall = class(TForm)
    plEmail: TPanel;
    Label1: TLabel;
    edtEmail: TEdit;
    plButton: TPanel;
    btnUnstall: TButton;
    btnCancel: TButton;
    plReasons: TPanel;
    Panel2: TPanel;
    Label2: TLabel;
    clbReasons: TCheckListBox;
    plSuggestions: TPanel;
    Panel4: TPanel;
    Label3: TLabel;
    mmoSuggestion: TMemo;
    plOthers: TPanel;
    edtOthers: TEdit;
    Label4: TLabel;
    tmrCheckButton: TTimer;
    procedure btnUnstallClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure clbReasonsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrCheckButtonTimer(Sender: TObject);
    procedure mmoSuggestionKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtEmailKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure AddLockFile;
    procedure RemoveLockFile;
  private
    procedure AddCancelFile;
    procedure RemoveCancelFile;
  private
    procedure RunCheck;
    procedure ConfirmUninstall;
    function ReadReasonStr : string;
    procedure MarkHttpUninstall;
  public
    procedure WaitUserRequest;
  end;

const
  HttpUninstallApp_PcID = 'PcID';
  HttpUninstallApp_Reasons = 'Reasons';
  HttpUninstallApp_Suggestions = 'Suggestions';
  HttpUninstallApp_Email = 'Email';

  Split_Reasons = '|';
  Split_Suggestions = '|';
const
  FileName_Lock = 'Uninstall.Lock';
  FileName_Cancel = 'Uninstall.Cancel';

  CheckIndex_Others = 5;
var
  frmUnstall: TfrmUnstall;

implementation

uses UMyUtil, UMyUrl;

{$R *.dfm}

{ TfrmUnstall }

procedure TfrmUnstall.AddCancelFile;
var
  FilePath : string;
  fs : TFileStream;
begin
  FilePath := MyAppDataUtil.get + FileName_Cancel;
  try
    fs := TFileStream.Create( FilePath, fmCreate or fmShareDenyNone );
    fs.Free;
  except
  end;
end;

procedure TfrmUnstall.AddLockFile;
var
  FilePath : string;
  fs : TFileStream;
begin
  FilePath := MyAppDataUtil.get + FileName_Lock;
  try
    fs := TFileStream.Create( FilePath, fmCreate or fmShareDenyNone );
    fs.Free;
  except
  end;
end;

procedure TfrmUnstall.btnCancelClick(Sender: TObject);
begin
  AddCancelFile;
  Close;
end;

procedure TfrmUnstall.btnUnstallClick(Sender: TObject);
begin
    // 输入邮箱格式不正确
  if not MyEmail.IsVaildEmailAddr( edtEmail.Text ) then
  begin
    MyMessageBox.ShowWarnning( 'Email address is invalid' );
    Exit;
  end;

    // 开始卸载
  RemoveCancelFile;
  Close;
  ModalResult := mrOk;

    // 超长
  if Length( edtOthers.Text ) > 90 then
    edtOthers.Text := Copy( edtOthers.Text, 1, 90 );

    // 超长
  if Length( edtEmail.Text ) > 90 then
    edtEmail.Text := Copy( edtEmail.Text, 1, 90 );

    // 超长
  if Length( mmoSuggestion.Text ) > 290 then
    mmoSuggestion.Text := Copy( mmoSuggestion.Text, 1, 290 );
end;

procedure TfrmUnstall.clbReasonsClick(Sender: TObject);
begin
  plOthers.Visible := clbReasons.Checked[ CheckIndex_Others ];
  if plOthers.Visible then
    edtOthers.SetFocus;
  RunCheck;
end;

procedure TfrmUnstall.ConfirmUninstall;
var
  IsReason, IsSuggestion, IsEmail : Boolean;
begin
  IsReason := Trim( ReadReasonStr ) <> '';
  IsSuggestion := Trim( mmoSuggestion.Text ) <> '';
  IsEmail := Trim( edtEmail.Text ) <> '';
  btnUnstall.Enabled := IsReason and IsSuggestion and IsEmail;
end;

procedure TfrmUnstall.edtEmailKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  RunCheck;
end;

procedure TfrmUnstall.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmUnstall.MarkHttpUninstall;
var
  PcID : string;
  Httpparams : TStringlist;
  idhttp : TIdHTTP;
  Str : string;
begin
    // 本机信息
  PcID := MyComputerID.get;

    // 登录并获取在线 Pc 信息
  Httpparams := TStringList.Create;
  Httpparams.Add( HttpUninstallApp_PcID + '=' + PcID );
  Httpparams.Add( HttpUninstallApp_Reasons + '=' + ReadReasonStr );
  Str := StringReplace( mmoSuggestion.Text, #13#10, Split_Suggestions, [rfReplaceAll] );
  Httpparams.Add( HttpUninstallApp_Suggestions + '=' + Str );
  Httpparams.Add( HttpUninstallApp_Email + '=' + edtEmail.Text );

    // 发送 Http
  idhttp := TIdHTTP.Create(nil);
  idhttp.ConnectTimeout := 10000;
  idhttp.ReadTimeout := 10000;
  try
    idhttp.Post( MyUrl.getAppUninstallMark, Httpparams );
  except
  end;
  idhttp.Free;

  Httpparams.free;
end;

procedure TfrmUnstall.mmoSuggestionKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  RunCheck;
end;

function TfrmUnstall.ReadReasonStr: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to clbReasons.Count - 1 do
    if clbReasons.Checked[i] then
    begin
      if Result <> '' then
        Result := Result + Split_Reasons;
      if i = CheckIndex_Others then
        Result := Result + edtOthers.Text
      else
        Result := Result + IntToStr(i);
    end;
end;

procedure TfrmUnstall.RemoveCancelFile;
var
  FilePath : string;
begin
  FilePath := MyAppDataUtil.get + FileName_Cancel;
  try
    DeleteFile( FilePath );
  except
  end;
end;

procedure TfrmUnstall.RemoveLockFile;
var
  FilePath : string;
begin
  FilePath := MyAppDataUtil.get + FileName_Lock;
  try
    DeleteFile( FilePath );
  except
  end;
end;

procedure TfrmUnstall.RunCheck;
begin
  if not tmrCheckButton.Enabled then
    tmrCheckButton.Enabled := True;
end;

procedure TfrmUnstall.tmrCheckButtonTimer(Sender: TObject);
begin
  tmrCheckButton.Enabled := False;
  ConfirmUninstall;
end;

procedure TfrmUnstall.WaitUserRequest;
begin
    // 添加锁文件
  AddLockFile;

    // 等待用户选择
  MarkHttpUninstall;
  if ShowModal = mrOk then  // 确认卸载
    MarkHttpUninstall;  // 记录卸载信息

    // 删除锁文件
  RemoveLockFile;
end;

end.
