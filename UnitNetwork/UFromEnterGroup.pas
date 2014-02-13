unit UFromEnterGroup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, RzTabs, IdHTTP;

type
  TfrmJoinGroup = class(TForm)
    PcMain: TRzPageControl;
    tsJoinGroup: TRzTabSheet;
    tsSignupGroup: TRzTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    edtGroupName: TEdit;
    edtPassword: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Label4: TLabel;
    Label5: TLabel;
    edtSignName: TEdit;
    edtSignEmail: TEdit;
    btnSignOK: TButton;
    btnSignCancel: TButton;
    Label6: TLabel;
    edtSignPassword: TEdit;
    Label7: TLabel;
    edtSignPassword2: TEdit;
    Panel1: TPanel;
    Label3: TLabel;
    lkCreateGroup: TLinkLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lkCreateGroupLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel2LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure btnSignOKClick(Sender: TObject);
    procedure edtGroupNameKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtPasswordKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSignPassword2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure PcMainPageChange(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowJobaGroup;
    procedure ShowSignUpGroup( GroupName : string );
    procedure ShowResetPassword( GroupName : string );
    procedure ShowGroupNotExist( GroupName, Password : string );
  end;

    // 注册 一个 Group
  TSignupGroupHandle = class
  public
    GroupName, Password : string;
    Email : string;
  public
    constructor Create( _GroupName, _Password : string );
    procedure SetEmail( _Email : string );
    procedure Update;
  end;

const
  ShowHint_InputEmail = 'Please input email adress';
  ShowHint_EmailInvalid = 'Email address is invalid';
  ShowHint_GroupNameExist = 'Group name "%s" is exist.';
  ShowHint_Completed = 'You have successfully signed up a remote network group account.';

  Signup_Exist = 'exist';
  Signup_Completed = 'completed';

  HttpSinup_GroupName = 'groupname';
  HttpSinup_Email = 'email';
  HttpSinup_Password = 'password';

var
  ShowHint_RunApp : string  = 'Please also run Backup Cow program on other computers and join the network group "%s".';

var
  frmJoinGroup: TfrmJoinGroup;

implementation

uses UMyUtil, UFormSetting, UNetworkControl, UMyUrl;

{$R *.dfm}

procedure TfrmJoinGroup.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmJoinGroup.btnOKClick(Sender: TObject);
var
  GroupName, Password : string;
  ErrorStr : string;
begin
  GroupName := edtGroupName.Text;
  Password := edtPassword.Text;

    // 判断 输入信息
  ErrorStr := '';
  if GroupName = '' then
    ErrorStr := ShowHint_InputComputerName
  else
  if Password = '' then
    ErrorStr := ShowHint_InputPassword;

    // 输入信息 出错
  if ErrorStr <> '' then
  begin
    MyMessageBox.ShowWarnning( Self.Handle, ErrorStr );
    Exit;
  end;

    // Join
  NetworkModeApi.JoinAGroup( GroupName, Password );

  Close;
end;

procedure TfrmJoinGroup.btnSignOKClick(Sender: TObject);
var
  GroupName, Email, Password : string;
  ErrorStr : string;
  SignupGroupHandle : TSignupGroupHandle;
begin
  GroupName := edtSignName.Text;
  Email := edtSignEmail.Text;
  Password := edtSignPassword.Text;

    // 判断 输入信息
  ErrorStr := '';
  if GroupName = '' then
    ErrorStr := ShowHint_InputAccountName
  else
  if Email = '' then
    ErrorStr := ShowHint_InputEmail
  else
  if not MyEmail.IsVaildEmailAddr( Email ) then
    ErrorStr := ShowHint_EmailInvalid
  else
  if Password = '' then
    ErrorStr := ShowHint_InputPassword
  else
  if Password <> edtSignPassword2.Text then
    ErrorStr := ShowHint_PasswordNotMatch;

    // 输入信息 出错
  if ErrorStr <> '' then
  begin
    MyMessageBox.ShowWarnning( Self.Handle, ErrorStr );
    Exit;
  end;

    // 注册
  SignupGroupHandle := TSignupGroupHandle.Create( GroupName, Password );
  SignupGroupHandle.SetEmail( Email );
  SignupGroupHandle.Update;
  SignupGroupHandle.Free;
end;

procedure TfrmJoinGroup.edtGroupNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmJoinGroup.edtPasswordKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnOK.Click;
end;

procedure TfrmJoinGroup.edtSignPassword2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnSignOK.Click;
end;

procedure TfrmJoinGroup.FormCreate(Sender: TObject);
begin
  PcMain.ActivePage := tsJoinGroup;
end;

procedure TfrmJoinGroup.ShowGroupNotExist(GroupName, Password: string);
begin
  PcMain.ActivePage := tsJoinGroup;
  edtGroupName.Text := GroupName;
  edtPassword.Text := Password;
  Show;
end;

procedure TfrmJoinGroup.ShowJobaGroup;
begin
  PcMain.ActivePage := tsJoinGroup;
  edtGroupName.Clear;
  edtPassword.Clear;
  Show;
end;

procedure TfrmJoinGroup.Label3Click(Sender: TObject);
begin
  PcMain.ActivePage := tsSignupGroup;
end;

procedure TfrmJoinGroup.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.GroupForgetPassword );
end;

procedure TfrmJoinGroup.LinkLabel2LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.GroupInstruction );
end;

procedure TfrmJoinGroup.lkCreateGroupLinkClick(Sender: TObject;
  const Link: string; LinkType: TSysLinkType);
begin
  PcMain.ActivePage := tsSignupGroup;
end;

procedure TfrmJoinGroup.PcMainPageChange(Sender: TObject);
begin
  if PcMain.ActivePage = tsSignupGroup then
    Self.Caption := 'Sign Up a Group'
  else
    Self.Caption := 'Join a Group';
end;

procedure TfrmJoinGroup.ShowResetPassword(GroupName: string);
begin
  PcMain.ActivePage := tsJoinGroup;
  edtGroupName.Text := GroupName;
  edtPassword.Clear;
  Show;
end;

procedure TfrmJoinGroup.ShowSignUpGroup(GroupName: string);
begin
  edtSignName.Text := GroupName;
  PcMain.ActivePage := tsSignupGroup;
  Show;
  try
    if GroupName <> '' then
      edtSignEmail.SetFocus
    else
      edtSignName.SetFocus;
  except
  end;
end;

{ TSingupGroupHandle }

constructor TSignupGroupHandle.Create(_GroupName, _Password: string);
begin
  GroupName := _GroupName;
  Password := _Password;
end;

procedure TSignupGroupHandle.SetEmail(_Email: string);
begin
  Email := _Email;
end;

procedure TSignupGroupHandle.Update;
var
  Params : TStringList;
  SignupHttp : TIdHTTP;
  SignupResult, ShowStr : string;
begin
  frmJoinGroup.btnSignOK.Enabled := False;
  Application.ProcessMessages;

    // 注册 参数
  Params := TStringList.Create;
  Params.Add( HttpSinup_GroupName + '=' + GroupName );
  Params.Add( HttpSinup_Email + '=' + Email );
  Params.Add( HttpSinup_Password + '=' + Password );

    // Http 注册
  SignupHttp := TIdHTTP.Create( nil );
  SignupHttp.ConnectTimeout := 30000;
  SignupHttp.ReadTimeout := 30000;
  try
    SignupResult := SignupHttp.Post( MyUrl.GroupSignupHandle, Params );
  except
  end;
  SignupHttp.Free;

  Params.Free;

    // 注册结果
  if SignupResult = Signup_Exist then // Group 已存在
  begin
    ShowStr := Format( ShowHint_GroupNameExist, [GroupName] );
    MyMessageBox.ShowWarnning( frmJoinGroup.Handle, ShowStr );
  end
  else
  if SignupResult = Signup_Completed then  // 注册成功
  begin
    ShowStr := ShowHint_Completed;
    ShowStr := ShowStr + #13#10 + Format( ShowHint_RunApp, [GroupName] );
    MyMessageBox.ShowOk( frmJoinGroup.Handle, ShowStr );
    with frmJoinGroup do
    begin
      edtGroupName.Text := GroupName;
      edtPassword.Text := Password;
      PcMain.ActivePage := tsJoinGroup;
      btnOK.Click;
    end;
  end;

  frmJoinGroup.btnSignOK.Enabled := True;
end;

end.
