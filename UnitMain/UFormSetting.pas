unit UFormSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,IniFiles,FileCtrl,
  Winsock,ShellAPI, ShlObj, UMyUtil, Spin, ToolWin, ImgList,
  RzButton, RzRadChk, Mask, RzEdit, RzSpnEdt, Menus, SyncObjs,
  RzTabs, pngimage, UIconUtil;

type

{$Region ' Form Setting ' }

  TfrmSetting = class(TForm)
    Panel2: TPanel;
    btnApply: TButton;
    btnCancel: TButton;
    btnOK: TButton;
    ilTbRn: TImageList;
    ilLvRemove: TImageList;
    ilTbRnGray: TImageList;
    PcMain: TRzPageControl;
    tsShare: TRzTabSheet;
    tsGenernal: TRzTabSheet;
    plCloudSafeSetting: TPanel;
    pl7: TPanel;
    gb3: TGroupBox;
    lbPcName: TLabel;
    lb5: TLabel;
    img9: TImage;
    edtPcName: TEdit;
    edtPcID: TEdit;
    tsApplication: TRzTabSheet;
    GroupBox1: TGroupBox;
    lvSharePath: TListView;
    Panel1: TPanel;
    Panel6: TPanel;
    Label1: TLabel;
    Image1: TImage;
    tsNetwork: TRzTabSheet;
    plNetworkConn: TPanel;
    GroupBox5: TGroupBox;
    Label2: TLabel;
    cbbNetworkMode: TComboBox;
    pcNetworkConn: TRzPageControl;
    tsLocal: TRzTabSheet;
    tsGroup: TRzTabSheet;
    tsConnPc: TRzTabSheet;
    Label3: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label14: TLabel;
    edtGroupPassword: TEdit;
    cbbGroup: TComboBoxEx;
    LinkLabel2: TLinkLabel;
    Label15: TLabel;
    Label16: TLabel;
    edtConnToPcPort: TEdit;
    Label17: TLabel;
    cbbConnToPc: TComboBoxEx;
    Image2: TImage;
    btnDeleteGroup: TButton;
    btnDeleteConnToPc: TButton;
    FileDialog: TOpenDialog;
    lbConnHint: TLinkLabel;
    ToolBar1: TToolBar;
    tbtnAddFiles: TToolButton;
    tbtnAddFolder: TToolButton;
    tbtnManually: TToolButton;
    tbtnRemove: TToolButton;
    edtPaste: TEdit;
    tsHint: TRzTabSheet;
    Panel4: TPanel;
    GroupBox3: TGroupBox;
    Panel7: TPanel;
    GroupBox4: TGroupBox;
    chkSendedHint: TCheckBox;
    chkReceivingHint: TCheckBox;
    chkReceivedHint: TCheckBox;
    Panel8: TPanel;
    GroupBox6: TGroupBox;
    chkDownShareCompleted: TCheckBox;
    seHintTime: TSpinEdit;
    Label6: TLabel;
    Label9: TLabel;
    chkSendingHint: TCheckBox;
    chkDownloadingShareHint: TCheckBox;
    tsSecurity: TRzTabSheet;
    Panel5: TPanel;
    gbCloudSafe: TGroupBox;
    lbCloudIDNum: TLabel;
    Image8: TImage;
    lbReqCloudIDNum: TLabel;
    lbCloudSafe: TLabel;
    chkIsCloudID: TCheckBox;
    edtCloudIDNum: TEdit;
    Panel3: TPanel;
    GroupBox2: TGroupBox;
    lb1: TLabel;
    lb2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    img8: TImage;
    img1: TImage;
    cbbIP: TComboBox;
    edtPort: TEdit;
    edtInternetIp: TEdit;
    edtInternetPort: TEdit;
    Panel9: TPanel;
    GroupBox7: TGroupBox;
    Image3: TImage;
    chkRunAppStartup: TCheckBox;
    chkShowAppExistDialog: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SettingChange(Sender: TObject);
    procedure chkIsCloudIDClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chkRunAppStartupClick(Sender: TObject);
    procedure chkIsSelectDownloadPathClick(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure btnAddShareClick(Sender: TObject);
    procedure btnDeletedShareClick(Sender: TObject);
    procedure lvSharePathChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure cbbNetworkModeSelect(Sender: TObject);
    procedure edtGroupPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtConnToPcPortKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbbConnToPcSelect(Sender: TObject);
    procedure cbbGroupSelect(Sender: TObject);
    procedure cbbGroupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnDeleteGroupClick(Sender: TObject);
    procedure cbbConnToPcKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnDeleteConnToPcClick(Sender: TObject);
    procedure btnAddFileClick(Sender: TObject);
    procedure tbtnAddFilesClick(Sender: TObject);
    procedure tbtnAddFolderClick(Sender: TObject);
    procedure tbtnRemoveClick(Sender: TObject);
    procedure tbtnManuallyClick(Sender: TObject);
    procedure lvSharePathInsert(Sender: TObject; Item: TListItem);
    procedure Panel1Click(Sender: TObject);
    procedure lvSharePathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure chkSendedHintClick(Sender: TObject);
    procedure chkReceivingHintClick(Sender: TObject);
    procedure chkReceivedHintClick(Sender: TObject);
    procedure chkDownShareCompletedClick(Sender: TObject);
    procedure seHintTimeChange(Sender: TObject);
    procedure tsGenernalClick(Sender: TObject);
    procedure cbbGroupKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbbConnToPcKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    procedure SaveIni;
    procedure LoadIni;
  public
    procedure SetFirstApplySettings;
    procedure SetApplySettings;
    procedure SetCancelSettings;
    procedure ShowResetCloudID;
  private
    procedure BindSettingChange( Wcontrol: TWinControl );
    procedure BindToolbar;
    procedure BindSort;
    procedure BindLvDelete;
    procedure ShowApplyButton;
    procedure AfterApplyClick;
    function BtnAppClick : Boolean;
  public
    procedure ShowNormal;
    procedure ShowSharePath;
    procedure ReloadIpList;
  end;


{$EndRegion}

  TSharePathData = class
  public
    SharePath : string;
  public
    constructor Create( _SharePath : string );
  end;


    // 共享路径 辅助类
  SharePathChangeUtil = class
  public
    class procedure AddPath( Path : string );
    class procedure RemovePath( Path : string );
  end;

    // 网络连接 辅助类
  NetworkConnChangeUtil = class
  public
    class procedure ReseConntPage;
    class procedure ResetGroupShow;
    class procedure ResetConnToPcShow;
  end;

{$Region ' 拖动文件 ' }

  TFrmSettingDropFileHandle = class( TDropFileHandle )
  public
    procedure Update;
  private
    procedure AddSharePath;
  end;

{$EndRegion}

{$Region ' Setting Parent ' }

    // Setting 处理 父类
  TSettingHandle = class
  public
    procedure Update;virtual;
  private       // Gennernal
    procedure SetNetworkInfo;virtual;abstract;
  private       // Network
    procedure SetCloudSafeInfo;virtual;abstract;
  private       // Share
    procedure SetShareInfo;virtual;abstract;
  private       // Hint
    procedure SetHintInfo;virtual;abstract;
  private       // Application
    procedure SetApplicetionInfo;virtual;abstract;
  end;

{$EndRegion}

{$Region ' Setting Ini ' }

    // Setting Ini 处理
  TFormSettingIniHandle = class( TSettingHandle )
  protected
    IniFile : TIniFile;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // Ini 加载
  TFormSettingLoadIni = class( TFormSettingIniHandle )
  private       // Gennernal
    procedure SetNetworkInfo;override;
  private       // Network
    procedure SetCloudSafeInfo;override;
  private       // Share
    procedure SetShareInfo;override;
  private       // Hint
    procedure SetHintInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  end;

    // Ini 保存
  TFormSettingSaveIni = class( TFormSettingIniHandle )
  public
    procedure Update;override;
  private       // Network
    procedure SetNetworkInfo;override;
  private       // Network
    procedure SetCloudSafeInfo;override;
  private       // Cloud
    procedure SetShareInfo;override;
  private       // Hint
    procedure SetHintInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  end;

{$EndRegion}

{$Region ' Setting Change ' }

    // 云路径发生变化
  TCloudPathSettingChangeHandle = class
  protected
    lvSharePath : TListView;
    OldPathList : TStringList;
    NewPathList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  private
    procedure FindOldPathList;
    procedure FindNewPathList;
  end;

    // Apply 云路径
  TCloudPathSettingApplyHandle = class( TCloudPathSettingChangeHandle )
  public
    procedure Update;
  private
    procedure AddCloudPath( Path : string );
    procedure RemoveCloudPath( Path : string );
  end;

    // Cancel 云路径
  TCloudPathSettingCancelHandle = class( TCloudPathSettingChangeHandle )
  public
    procedure Update;
  end;

    // 网络连接发生变化
  TNetworkConnSettingChangeHandle = class
  public
    OldSelectType : string;
    OldSelectValue1, OldSelectValue2 : string;
  public
    NewSelectType : string;
    NewSelectValue1, NewSelectValue2 : string;
  public
    constructor Create;
  end;

    // Apply
  TNetworkConnSettingApplyHandle = class( TNetworkConnSettingChangeHandle )
  public
    procedure Update;
  end;

    // Cancel
  TNetworkConnSettingCancelHandle = class( TNetworkConnSettingChangeHandle )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Setting Apply ' }

      // Click Apply Click
  TCheckApplyClick = class
  private
    ShowErrorStr : string;
  public
    function get : Boolean;
  private
    function CheckComputer: Boolean;
    function CheckCloudID : Boolean;
    function CheckGroup: Boolean;
    function CheckConnToPc : Boolean;
  end;

    // Apply
  TSetApplyHandleBase = class( TSettingHandle )
  private
    IsRestartNetwork : Boolean;
    IsFirstApply : Boolean;
  private       // Gernernal
    procedure SetNetworkInfo;override;
  private       // Network
    procedure SetCloudSafeInfo;override;
  private       // Share
    procedure SetShareInfo;override;
  private       // Hint
    procedure SetHintInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  end;

    // 第一次 Apply
  TSetFirstApplyHandle = class( TSetApplyHandleBase )
  public
    constructor Create;
  end;

    // 第一次之后 Apply
  TSetApplyHandle = class( TSetApplyHandleBase )
  public
    constructor Create;
    procedure Update;override;
  private       // Gernernal
    procedure SetNetworkInfo;override;
  private
    procedure SetShareInfo;override;
  private
    procedure SetCloudSafeInfo;override;
  end;

{$EndRegion}

{$Region ' Setting Cancel ' }

    // Cancel
  TSetCancelHandle = class( TSettingHandle )
  private       // Gernernal
    procedure SetNetworkInfo;override;
  private       // Network
    procedure SetCloudSafeInfo;override;
  private       // Share
    procedure SetShareInfo;override;
  private       // Hint
    procedure SetHintInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  end;

{$EndRegion}

const
  Default_CloudSafe = False;
  Default_CloudIDNum = '';

  Default_RunAppStartup = True;
  Default_ShowDialogBeforeExit = True;

  Default_IsShowSending = True;
  Default_IsShowSendCompelted = True;
  Default_IsShowReceiving = True;
  Default_IsShowReceiveCompleted = True;
  Default_IsShowDownloadingShare = True;
  Default_IsShowDownShareCompelted = True;
  Default_ShowHintTime = 15;


const

    // Computer
  ShowHint_InputComputerName : string = 'Please input Computer Name';
  ShowHint_PortError : string = 'Port number is incorrect. Please Input a number between 1 and 65535';

    // File Encrypt
  ShowHint_InputPassword : string = 'Please input Password';
  ShowHint_PasswordNotMatch : string = 'Password and Retype Password are not matched';
  ShowForm_ResetPassword : string = 'New pre-set password will only take effect for new backup items.' + #10#13 +
                                    'Your previous backup items still use the old encryption password. Are you sure to proceed ?';

    // Cloud ID Num
  ShowHint_InputCloudIDNum : string = 'Please input ID Number';

    // Remote Network
  ShowHint_InputAccountName : string = 'Please input Group Name';
  ShowHint_AccountExist : string = 'Group Name is exist';
  ShowHint_InputDomain : string = 'Please input Domain or Ip';
  ShowHint_ComputerExist : string = 'Computer is exist';

  NbPage_Discription = 0;
  NbPage_Add = 1;


  Split_PmAdvance : string = ' : ';

  LvAdvance_Port = 0;
  LvAdvance_Domain = 1;

  Dns_Parsing : string = 'Parsing';


var
  Default_CloudPathName : string = 'BackupCow.Backup';
  Default_ReceivePathName : string = 'BackupCow.Receive';
  Default_SearchDownPathName : string = 'BackupCow.Download';

var
  frmSetting : TfrmSetting;

implementation

uses USettingInfo, UMyClient, UMyReceiveApiInfo, UMyReceiveFaceInfo, UMyReceiveDataInfo,
     UMyShareFaceInfo, UMyShareDataInfo, UMyShareApiInfo, UMyRegisterApiInfo,
     UMainForm, UMyNetPcInfo, USearchServer, UNetworkFace, UFormUtil,
     UMyUrl, URegisterInfoIO,UNetworkControl, UMainApi,
     UFromEnterGroup;

{$R *.dfm}

procedure TfrmSetting.AfterApplyClick;
begin
    // Cloud ID
  lbReqCloudIDNum.Visible := False;
end;

procedure TfrmSetting.BindLvDelete;
begin
  ListviewUtil.BindRemoveData( lvSharePath );
end;

procedure TfrmSetting.BindSettingChange( Wcontrol: TWinControl );
var
  i : Integer;
  c : TControl;
begin
  for i := 0 to Wcontrol.ControlCount - 1 do
  begin
    c := Wcontrol.Controls[i];
    if c.Tag = -1 then
      Continue;
    if c is TSpinEdit then
      ( c as TSpinEdit ).OnChange := SettingChange
    else
    if c is TEdit then
      ( c as TEdit ).OnChange := SettingChange
    else
    if c is TRzNumericEdit then
      ( c as TRzNumericEdit ).OnChange := SettingChange
    else
    if c is TComboBox then
      ( c as TComboBox ).OnChange := SettingChange
    else
    if c is TTrackBar then
      ( c as TTrackBar ).OnChange := SettingChange
    else
    if c is TRzCheckBox then
      ( c as TRzCheckBox ).OnClick := SettingChange
    else
    if c is TWinControl then
      BindSettingChange( c as TWinControl );
  end;
end;

procedure TfrmSetting.BindSort;
begin

end;

procedure TfrmSetting.BindToolbar;
begin

end;

procedure TfrmSetting.btnAddFileClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;
  for i := 0 to FileDialog.Files.Count - 1 do
    SharePathChangeUtil.AddPath( FileDialog.Files[i] );
  ShowApplyButton;
end;

procedure TfrmSetting.btnAddShareClick(Sender: TObject);
var
  SelectPath : string;
begin
  if not MySelectFolderDialog.Select( 'Select path to share', '', SelectPath, Self.Handle ) then
    Exit;

  SharePathChangeUtil.AddPath( SelectPath );
  ShowApplyButton;
end;

function TfrmSetting.BtnAppClick: Boolean;
var
  CheckApplyClick : TCheckApplyClick;
  IsApply : Boolean;
begin
  Result := False;

  CheckApplyClick := TCheckApplyClick.Create;
  IsApply := CheckApplyClick.get;
  CheckApplyClick.Free;

  if not IsApply then
    Exit;

  btnApply.Enabled := False;

  SetApplySettings;

  SaveIni;

  AfterApplyClick;

    // 更新 云信息
  Result := True;
end;

procedure TfrmSetting.btnApplyClick(Sender: TObject);
begin
  BtnAppClick;
end;

procedure TfrmSetting.btnCancelClick(Sender: TObject);
begin
  frmSetting.Close;

  SetCancelSettings;
end;

procedure TfrmSetting.btnDeleteConnToPcClick(Sender: TObject);
begin
  if cbbConnToPc.ItemsEx.Count = 0 then
  begin
    cbbConnToPc.Text := '';
    edtConnToPcPort.Text := '';
    btnDeleteConnToPc.Visible := False;
    Exit;
  end;

  NetworkModeApi.RemoveConnToPc( cbbConnToPc.Text, edtConnToPcPort.Text );
end;

procedure TfrmSetting.btnDeletedShareClick(Sender: TObject);
var
  i : Integer;
  ItemData : TSharePathData;
begin
  for i := 0 to lvSharePath.Items.Count - 1 do
    if lvSharePath.Items[i].Selected then
    begin
      ItemData := lvSharePath.Items[i].Data;
      SharePathChangeUtil.RemovePath( ItemData.SharePath );
    end;

  ShowApplyButton;
end;

procedure TfrmSetting.btnDeleteGroupClick(Sender: TObject);
begin
  if cbbGroup.ItemsEx.Count = 0 then
  begin
    cbbGroup.Text := '';
    edtGroupPassword.Text := '';
    btnDeleteGroup.Visible := False;
    Exit;
  end;

  NetworkModeApi.RemoveGroup( cbbGroup.Text );
end;

procedure TfrmSetting.btnOKClick(Sender: TObject);
var
  IsCloseSetForm : Boolean;
begin
  IsCloseSetForm := True;

    // Apply Click
  if btnApply.Enabled and not BtnAppClick then
    IsCloseSetForm := False;

    // Close Error
  if IsCloseSetForm then
    frmSetting.Close;
end;

procedure TfrmSetting.cbbConnToPcKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  edtConnToPcPort.Text := '';
  btnDeleteConnToPc.Visible := False;
  ShowApplyButton;
end;

procedure TfrmSetting.cbbConnToPcKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmSetting.cbbConnToPcSelect(Sender: TObject);
begin
  NetworkConnChangeUtil.ResetConnToPcShow;
  ShowApplyButton;
end;

procedure TfrmSetting.cbbGroupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  edtGroupPassword.Text := '';
  btnDeleteGroup.Visible := False;
  ShowApplyButton;
end;

procedure TfrmSetting.cbbGroupKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmSetting.cbbGroupSelect(Sender: TObject);
begin
  NetworkConnChangeUtil.ResetGroupShow;
  ShowApplyButton;
end;

procedure TfrmSetting.cbbNetworkModeSelect(Sender: TObject);
begin
  NetworkConnChangeUtil.ReseConntPage;
  ShowApplyButton;
end;

procedure TfrmSetting.chkDownShareCompletedClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.chkIsCloudIDClick(Sender: TObject);
var
  IsShow : Boolean;
begin
  IsShow := chkIsCloudID.Checked;

  lbCloudIDNum.Enabled := IsShow;
  lbCloudSafe.Enabled := IsShow;
  edtCloudIDNum.Enabled := IsShow;
  lbReqCloudIDNum.Visible := IsShow;

  ShowApplyButton;
end;

procedure TfrmSetting.chkReceivedHintClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.chkReceivingHintClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.chkRunAppStartupClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.chkSendedHintClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.DropFiles(var Msg: TMessage);
var
  FrmSettingDropFileHandle : TFrmSettingDropFileHandle;
begin
  FrmSettingDropFileHandle := TFrmSettingDropFileHandle.Create( Msg );
  FrmSettingDropFileHandle.Update;
  FrmSettingDropFileHandle.Free;

  FormUtil.ForceForegroundWindow( Handle );
end;

procedure TfrmSetting.edtConnToPcPortKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.edtGroupPasswordKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.chkIsSelectDownloadPathClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True); // 设置需要处理文件 WM_DROPFILES 拖放消息

  BindSettingChange( Self );
  BindToolbar;
  BindSort;
  BindLvDelete;

    // 重新加载 Ip 信息
  ReloadIpList;

  pcMain.ActivePage := tsGenernal;
  lvSharePath.SmallImages := MyIcon.getSysIcon;
end;

procedure TfrmSetting.FormDestroy(Sender: TObject);
var
  i : Integer;
  ItemData : TObject;
begin
  for i := 0 to cbbGroup.ItemsEx.Count - 1 do
  begin
    ItemData := cbbGroup.ItemsEx[i].Data;
    ItemData.Free;
  end;

  for i := 0 to cbbConnToPc.ItemsEx.Count - 1 do
  begin
    ItemData := cbbConnToPc.ItemsEx[i].Data;
    ItemData.Free;
  end;
end;

procedure TfrmSetting.FormShow(Sender: TObject);
begin
  btnApply.Enabled := False;
  AfterApplyClick;
end;

procedure TfrmSetting.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.GroupSignup );
end;

procedure TfrmSetting.LoadIni;
var
  FormSettingLoadIni : TFormSettingLoadIni;
begin
  FormSettingLoadIni := TFormSettingLoadIni.Create;
  FormSettingLoadIni.Update;
  FormSettingLoadIni.Free;
end;

procedure TfrmSetting.lvSharePathChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  tbtnRemove.Enabled := lvSharePath.SelCount > 0;
end;

procedure TfrmSetting.lvSharePathInsert(Sender: TObject; Item: TListItem);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.lvSharePathKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDelete( tbtnRemove, Key );
end;

procedure TfrmSetting.Panel1Click(Sender: TObject);
begin
  MyExplore.OpenFolder( MySystemPath.getMyDoc );
end;

procedure TfrmSetting.ReloadIpList;
var
  IpList : TStringList;
  Ip : string;
  i : Integer;
begin
  cbbIP.Clear;
  IpList := MyIpList.get;
  for i := 0 to IpList.Count - 1 do
  begin
    Ip := IpList[i];
    cbbIP.Items.Add( Ip );
  end;
  IpList.Free;
end;

procedure TfrmSetting.SaveIni;
var
  FormSettingSaveIni : TFormSettingSaveIni;
begin
  FormSettingSaveIni := TFormSettingSaveIni.Create;
  FormSettingSaveIni.Update;
  FormSettingSaveIni.Free;
end;

procedure TfrmSetting.seHintTimeChange(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.SetApplySettings;
var
  SetApplyHandle : TSetApplyHandle;
begin
  SetApplyHandle := TSetApplyHandle.Create;
  SetApplyHandle.Update;
  SetApplyHandle.Free;
end;

procedure TfrmSetting.SetCancelSettings;
var
  SetCancelHandle : TSetCancelHandle;
begin
  SetCancelHandle := TSetCancelHandle.Create;
  SetCancelHandle.Update;
  SetCancelHandle.Free;
end;

procedure TfrmSetting.SetFirstApplySettings;
var
  SetFirstApplyHandle : TSetFirstApplyHandle;
begin
  SetFirstApplyHandle := TSetFirstApplyHandle.Create;
  SetFirstApplyHandle.Update;
  SetFirstApplyHandle.Free;
end;

procedure TfrmSetting.SettingChange(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.ShowApplyButton;
begin
  btnApply.Enabled := True;
end;

procedure TfrmSetting.ShowNormal;
begin
  Show;
end;

procedure TfrmSetting.ShowResetCloudID;
begin
  PcMain.ActivePage := tsNetwork;
  Show;
  try
    edtCloudIDNum.SetFocus;
  except
  end;
end;

procedure TfrmSetting.ShowSharePath;
begin
  PcMain.ActivePage := tsShare;
  Show;
end;

procedure TfrmSetting.tbtnAddFilesClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;
  for i := 0 to FileDialog.Files.Count - 1 do
    SharePathChangeUtil.AddPath( FileDialog.Files[i] );
end;

var
  SelectPath_Share : string = '';
procedure TfrmSetting.tbtnAddFolderClick(Sender: TObject);
begin
  if not MySelectFolderDialog.Select( 'Select path to share', '', SelectPath_Share, Self.Handle ) then
    Exit;

  SharePathChangeUtil.AddPath( SelectPath_Share );
end;

procedure TfrmSetting.tbtnManuallyClick(Sender: TObject);
var
  InputPath : string;
begin
  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and ( not FileExists( InputPath ) and not DirectoryExists( InputPath ) ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'File or Folder Name', InputPath ) then
    Exit;

  if not FileExists( InputPath ) and not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist.' );
    Exit;
  end;

  SharePathChangeUtil.AddPath( InputPath );;
end;

procedure TfrmSetting.tbtnRemoveClick(Sender: TObject);
var
  i : Integer;
  ItemData : TSharePathData;
begin
  for i := 0 to lvSharePath.Items.Count - 1 do
    if lvSharePath.Items[i].Selected then
    begin
      ItemData := lvSharePath.Items[i].Data;
      SharePathChangeUtil.RemovePath( ItemData.SharePath );
    end;
  ShowApplyButton;
end;

procedure TfrmSetting.tsGenernalClick(Sender: TObject);
begin

end;

{ TFormSettingLoadIni }

procedure TFormSettingLoadIni.SetApplicetionInfo;
begin
  with frmSetting do
  begin
    chkRunAppStartup.Checked := IniFile.ReadBool( frmSetting.Name, chkRunAppStartup.Name, Default_RunAppStartup );
    chkShowAppExistDialog.Checked := IniFile.ReadBool( frmSetting.Name, chkShowAppExistDialog.Name, Default_ShowDialogBeforeExit );
  end;
end;


procedure TFormSettingLoadIni.SetCloudSafeInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    chkIsCloudID.Checked := IniFile.ReadBool( frmSetting.Name, chkIsCloudID.Name, Default_CloudSafe );

      // 解密
    KeyStr := IniFile.ReadString( frmSetting.Name, edtCloudIDNum.Name, Default_CloudIDNum );
    KeyStr := MyEncrypt.DecodeStr( KeyStr );

    edtCloudIDNum.Text := KeyStr;
  end;
end;

procedure TFormSettingLoadIni.SetHintInfo;
begin
  with frmSetting do
  begin
    chkSendingHint.Checked := IniFile.ReadBool( frmSetting.Name, chkSendingHint.Name, Default_IsShowSending );
    chkSendedHint.Checked := IniFile.ReadBool( frmSetting.Name, chkSendedHint.Name, Default_IsShowSendCompelted );

    chkReceivingHint.Checked := IniFile.ReadBool( frmSetting.Name, chkReceivingHint.Name, Default_IsShowReceiving );
    chkReceivedHint.Checked := IniFile.ReadBool( frmSetting.Name, chkReceivedHint.Name, Default_IsShowReceiveCompleted );

    chkDownloadingShareHint.Checked := IniFile.ReadBool( frmSetting.Name, chkDownloadingShareHint.Name, Default_IsShowDownloadingShare );
    chkDownShareCompleted.Checked := IniFile.ReadBool( frmSetting.Name, chkDownShareCompleted.Name, Default_IsShowDownShareCompelted );

    seHintTime.Value := IniFile.ReadInteger( frmSetting.Name, seHintTime.Name, Default_ShowHintTime );
  end;
end;

procedure TFormSettingLoadIni.SetNetworkInfo;
begin

end;



procedure TFormSettingLoadIni.SetShareInfo;
begin

end;


{ TFormSettingIniHandle }

constructor TFormSettingIniHandle.Create;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
end;

destructor TFormSettingIniHandle.Destroy;
begin
  IniFile.Free;
  inherited;
end;

{ TFormSettingSaveIni }


procedure TFormSettingSaveIni.SetApplicetionInfo;
begin
  try
    with frmSetting do
    begin
      IniFile.WriteBool( frmSetting.Name, chkRunAppStartup.Name, chkRunAppStartup.Checked );
      IniFile.WriteBool( frmSetting.Name, chkShowAppExistDialog.Name, chkShowAppExistDialog.Checked );
    end;
  except
  end;
end;


procedure TFormSettingSaveIni.SetCloudSafeInfo;
var
  KeyStr : string;
begin
  try
    with frmSetting do
    begin
      IniFile.WriteBool( frmSetting.Name, chkIsCloudID.Name, chkIsCloudID.Checked );

        // 加密
      KeyStr := edtCloudIDNum.Text;
      KeyStr := MyEncrypt.EncodeStr( KeyStr );
      IniFile.WriteString( frmSetting.Name, edtCloudIDNum.Name, KeyStr );
    end;
  except
  end;
end;

procedure TFormSettingSaveIni.SetHintInfo;
begin
  try
    with frmSetting do
    begin
      IniFile.WriteBool( frmSetting.Name, chkSendingHint.Name, chkSendingHint.Checked );
      IniFile.WriteBool( frmSetting.Name, chkSendedHint.Name, chkSendedHint.Checked );

      IniFile.WriteBool( frmSetting.Name, chkReceivingHint.Name, chkReceivingHint.Checked );
      IniFile.WriteBool( frmSetting.Name, chkReceivedHint.Name, chkReceivedHint.Checked );

      IniFile.WriteBool( frmSetting.Name, chkDownloadingShareHint.Name, chkDownloadingShareHint.Checked );
      IniFile.WriteBool( frmSetting.Name, chkDownShareCompleted.Name, chkDownShareCompleted.Checked );

      IniFile.WriteInteger( frmSetting.Name, seHintTime.Name, seHintTime.Value );
    end;
  except
  end;
end;

procedure TFormSettingSaveIni.SetNetworkInfo;
begin

end;

procedure TFormSettingSaveIni.SetShareInfo;
begin

end;

procedure TFormSettingSaveIni.Update;
begin
    // 无法写入 Ini
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  inherited;
end;

{ TSetApplyHandle }

procedure TSetApplyHandleBase.SetApplicetionInfo;
var
  IsChangeStartup : Boolean;
begin
  with frmSetting do
  begin
    with ApplicationSettingInfo do
    begin
        // 是否发生变化
      IsChangeStartup := IsRunAppStartUp <> chkRunAppStartup.Checked;

        // 修改值
      IsRunAppStartUp := chkRunAppStartup.Checked;
      IsShowDialogBeforeExist := chkShowAppExistDialog.Checked;
    end;
  end;

    // 改变 开机启动 设置
  if IsChangeStartup and not IsFirstApply then
  begin
      // win 7 需要管理员权限
    if not RunAppStartupUtil.Startup( ApplicationSettingInfo.IsRunAppStartUp ) then
      if not MyAppAdminRunasUtil.StartUp( ApplicationSettingInfo.IsRunAppStartUp ) then // 修改失败, 取消操作
      begin
        ApplicationSettingInfo.IsRunAppStartUp := not ApplicationSettingInfo.IsRunAppStartUp;
        frmSetting.chkRunAppStartup.Checked := ApplicationSettingInfo.IsRunAppStartUp;
      end;
  end;
end;

procedure TSetApplyHandleBase.SetCloudSafeInfo;
begin
  with frmSetting do
  begin
    with CloudSafeSettingInfo do
    begin
      if ( IsCloudSafe <> chkIsCloudID.Checked ) or
         ( CloudIDNum <> edtCloudIDNum.Text )
      then
        IsRestartNetwork := True;

      IsCloudSafe := chkIsCloudID.Checked;
      CloudIDNum := edtCloudIDNum.Text;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetHintInfo;
begin
  with frmSetting do
  begin
    with HintSettingInfo do
    begin
      IsShowSending := chkSendingHint.Checked;
      IsShowSendCompleted := chkSendedHint.Checked;

      IsShowReceiving := chkReceivingHint.Checked;
      IsShowReceiveCompleted := chkReceivedHint.Checked;

      IsShowDownloadingShare := chkDownloadingShareHint.Checked;
      IsShowDownloadShareCompleted := chkDownShareCompleted.Checked;

      ShowHintTime := seHintTime.Value;
    end;
  end;

    // 重设时间
  MyHintAppApi.SetShowHintTime( HintSettingInfo.ShowHintTime );
end;

procedure TSetApplyHandleBase.SetNetworkInfo;
begin

end;

procedure TSetApplyHandleBase.SetShareInfo;
begin

end;

{ TSetApplyHandle }

constructor TSetApplyHandle.Create;
begin
  inherited Create;
  IsFirstApply := False;
end;

procedure TSetApplyHandle.SetCloudSafeInfo;
var
  NetworkConnSettingApplyHandle : TNetworkConnSettingApplyHandle;
begin
  inherited;

  NetworkConnSettingApplyHandle := TNetworkConnSettingApplyHandle.Create;
  NetworkConnSettingApplyHandle.Update;
  NetworkConnSettingApplyHandle.Free;
end;

procedure TSetApplyHandle.SetNetworkInfo;
var
  IsChangePcInfo : Boolean;
  Params : TMyPcInfoSetParams;
begin
  with frmSetting do
  begin
    with PcInfo do
    begin
      IsChangePcInfo := ( PcName <> edtPcName.Text ) or ( LanIp <> cbbIP.Text ) or
                        ( LanPort <> edtPort.Text ) or ( InternetPort <> edtInternetPort.Text );
      IsRestartNetwork := IsChangePcInfo; // Pc 信息变化, 重启网络

        // 没有变化
      if not IsChangePcInfo then
        Exit;

        // 刷新本机信息
      Params.PcID := edtPcID.Text;
      Params.PcName := edtPcName.Text;
      Params.LanIp := cbbIP.Text;
      Params.LanPort := edtPort.Text;
      Params.InternetPort := edtInternetPort.Text;
      MyPcInfoApi.SetItem( Params );
    end;
  end;
end;

procedure TSetApplyHandle.SetShareInfo;
var
  CloudPathSettingApplyHandle : TCloudPathSettingApplyHandle;
begin
  CloudPathSettingApplyHandle := TCloudPathSettingApplyHandle.Create;
  CloudPathSettingApplyHandle.Update;
  CloudPathSettingApplyHandle.Free;
end;

procedure TSetApplyHandle.Update;
begin
  IsRestartNetwork := False;

  inherited;

  if IsRestartNetwork then
    MySearchMasterHandler.RestartNetwork;
end;

{ TSettingHandle }

procedure TSettingHandle.Update;
begin
  SetNetworkInfo;

  SetCloudSafeInfo;

  SetShareInfo;

  SetHintInfo;

  SetApplicetionInfo;
end;

{ TSetCancelHandle }

procedure TSetCancelHandle.SetApplicetionInfo;
begin
  with frmSetting do
  begin
    with ApplicationSettingInfo do
    begin
      chkRunAppStartup.Checked := IsRunAppStartUp;
      chkShowAppExistDialog.Checked := IsShowDialogBeforeExist;
    end;
  end;
end;

procedure TSetCancelHandle.SetCloudSafeInfo;
var
  NetworkConnSettingCancelHandle : TNetworkConnSettingCancelHandle;
begin
  with frmSetting do
  begin
    with CloudSafeSettingInfo do
    begin
      chkIsCloudID.Checked := IsCloudSafe;
      edtCloudIDNum.Text := CloudIDNum;
    end;
  end;

  NetworkConnSettingCancelHandle := TNetworkConnSettingCancelHandle.Create;
  NetworkConnSettingCancelHandle.Update;
  NetworkConnSettingCancelHandle.Free;
end;

procedure TSetCancelHandle.SetHintInfo;
begin
  with frmSetting do
  begin
    with HintSettingInfo do
    begin
      chkSendingHint.Checked := IsShowSending;
      chkSendedHint.Checked := IsShowSendCompleted;

      chkReceivingHint.Checked := IsShowReceiving ;
      chkReceivedHint.Checked := IsShowReceiveCompleted;

      chkDownloadingShareHint.Checked := IsShowDownloadingShare;
      chkDownShareCompleted.Checked := IsShowDownloadShareCompleted;

      seHintTime.Value := ShowHintTime;
    end;
  end;
end;

procedure TSetCancelHandle.SetNetworkInfo;
begin
  with frmSetting do
  begin
    with PcInfo do
    begin
      edtPcName.Text := PcName;
      cbbIP.Text := LanIp;
      edtPort.Text := LanPort;
      edtInternetPort.Text := InternetPort;
    end;
  end;
end;

procedure TSetCancelHandle.SetShareInfo;
var
  CloudPathSettingCancelHandle : TCloudPathSettingCancelHandle;
begin
  CloudPathSettingCancelHandle := TCloudPathSettingCancelHandle.Create;
  CloudPathSettingCancelHandle.Update;
  CloudPathSettingCancelHandle.Free;
end;

{ TCheckApplyClick }

function TCheckApplyClick.CheckCloudID: Boolean;
begin
    // 没有 ID Num
  if not frmSetting.chkIsCloudID.Checked then
  begin
    Result := True;
    Exit;
  end;

    // 没有 输入 ID Num
  if frmSetting.edtCloudIDNum.Text = '' then
  begin
    Result := False;
    ShowErrorStr := ShowHint_InputCloudIDNum;
  end
  else
    Result := True;

      // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsNetwork;
    frmSetting.edtCloudIDNum.SetFocus;
  end;
end;

function TCheckApplyClick.CheckComputer: Boolean;
var
  edtComputerName, edtPort, edtError : TEdit;
  Port : Integer;
begin
  edtComputerName := frmSetting.edtPcName;
  edtPort := frmSetting.edtPort;

  Port := StrToIntDef( edtPort.Text, -1 );

  Result := False;
  if edtComputerName.Text = '' then
  begin
    ShowErrorStr := ShowHint_InputComputerName;
    edtError := edtComputerName;
  end
  else
  if ( Port < 1 ) or ( Port > 65535 ) then
  begin
    ShowErrorStr := ShowHint_PortError;
    edtError := edtPort;
  end
  else
    Result := True;

    // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsGenernal;
    edtError.SetFocus;
  end;
end;

function TCheckApplyClick.CheckConnToPc: Boolean;
begin
  Result := True;
  with frmSetting do
  begin
    if cbbNetworkMode.ItemIndex <> 2 then
      Exit;

    Result := False;
    if cbbConnToPc.Text = '' then
      ShowErrorStr := ShowHint_InputDomain
    else
    if not MyParseHost.IsPortStr( edtConnToPcPort.Text ) then
      ShowErrorStr := ShowHint_PortError
    else
      Result := True;

    if not Result then
      PcMain.ActivePage := tsNetwork;
  end;
end;

function TCheckApplyClick.CheckGroup: Boolean;
begin
  Result := True;
  with frmSetting do
  begin
    if cbbNetworkMode.ItemIndex <> 1 then
      Exit;

    Result := False;
    if cbbGroup.Text = '' then
      ShowErrorStr := ShowHint_InputAccountName
    else
    if edtGroupPassword.Text = '' then
      ShowErrorStr := ShowHint_InputPassword
    else
      Result := True;

    if not Result then
      PcMain.ActivePage := tsNetwork;
  end;
end;

function TCheckApplyClick.get: Boolean;
begin
  if CheckComputer and CheckCloudID and CheckGroup and CheckConnToPc then
    Result := True
  else
  begin
    Result := False;
    MyMessageBox.ShowWarnning( frmSetting.Handle, ShowErrorStr );
  end;
end;

{ TSetFirstApplyHandle }

constructor TSetFirstApplyHandle.Create;
begin
  inherited;
  IsFirstApply := True;
end;

{ TCloudPathSettingChangeHandle }

constructor TCloudPathSettingChangeHandle.Create;
begin
  lvSharePath := frmSetting.lvSharePath;
  FindOldPathList;
  FindNewPathList;
end;

destructor TCloudPathSettingChangeHandle.Destroy;
begin
  OldPathList.Free;
  NewPathList.Free;
  inherited;
end;

procedure TCloudPathSettingChangeHandle.FindNewPathList;
var
  i : Integer;
  ItemData : TSharePathData;
begin
  NewPathList := TStringList.Create;
  for i := 0 to lvSharePath.Items.Count - 1 do
  begin
    ItemData := lvSharePath.Items[i].Data;
    NewPathList.Add( ItemData.SharePath );
  end;
end;

procedure TCloudPathSettingChangeHandle.FindOldPathList;
begin
  OldPathList := SharePathInfoReadUtil.ReadNetworkShareList;
end;

{ TCloudPathSettingApplyHandle }

procedure TCloudPathSettingApplyHandle.AddCloudPath(Path: string);
begin
  MySharePathApi.AddNetworkItem( Path, FileExists( Path ) );
end;

procedure TCloudPathSettingApplyHandle.RemoveCloudPath(Path: string);
begin
  MySharePathApi.RemoveNetworkItem( Path );
end;

procedure TCloudPathSettingApplyHandle.Update;
var
  i : Integer;
  Path : string;
  OldIndex : Integer;
begin
    // 新增的路径
  for i := 0 to NewPathList.Count - 1 do
  begin
    Path := NewPathList[i];
    OldIndex := OldPathList.IndexOf( Path );
    if OldIndex = -1 then // 新增的路径
      AddCloudPath( Path )
    else // 删除已处理路径
      OldPathList.Delete( OldIndex );
  end;

    // 删除的路径
  for i := 0 to OldPathList.Count - 1 do
    RemoveCloudPath( OldPathList[i] );
end;

{ TCloudPathSettingCancelHandle }


procedure TCloudPathSettingCancelHandle.Update;
var
  i : Integer;
  Path : string;
begin
  lvSharePath.Clear;
  for i := 0 to OldPathList.Count - 1 do
  begin
    Path := OldPathList[i];
    SharePathChangeUtil.AddPath( Path );
  end;
end;

{ SharePathChangeUtil }

class procedure SharePathChangeUtil.AddPath(Path: string);
var
  SharePathAddFace : TSharePathAddFace;
begin
  SharePathAddFace := TSharePathAddFace.Create( Path );
  SharePathAddFace.SetIsFile( FileExists( Path ) );
  SharePathAddFace.AddChange;
end;

class procedure SharePathChangeUtil.RemovePath(Path: string);
var
  SharePathRemoveFace : TSharePathRemoveFace;
begin
  SharePathRemoveFace := TSharePathRemoveFace.Create( Path );
  SharePathRemoveFace.AddChange;
end;

{ TNetworkConnSettingChangeHandle }

constructor TNetworkConnSettingChangeHandle.Create;
begin
  OldSelectType := MyNetworkConnInfo.SelectType;
  OldSelectValue1 := MyNetworkConnInfo.SelectValue1;
  OldSelectValue2 := MyNetworkConnInfo.SelectValue2;

  with frmSetting do
  begin
    NewSelectType := cbbNetworkMode.Text;
    if cbbNetworkMode.ItemIndex = 0 then
      NewSelectType := SelectConnType_Local
    else
    if cbbNetworkMode.ItemIndex = 1 then
    begin
      NewSelectType := SelectConnType_Group;
      NewSelectValue1 := cbbGroup.Text;
      NewSelectValue2 := edtGroupPassword.Text;
    end
    else
    if cbbNetworkMode.ItemIndex = 2 then
    begin
      NewSelectType := SelectConnType_ConnPC;
      NewSelectValue1 := cbbConnToPc.Text;
      NewSelectValue2 := edtConnToPcPort.Text;
    end;
  end;
end;


procedure TNetworkConnSettingApplyHandle.Update;
begin
  if NewSelectType = SelectConnType_Local then
  begin
      // 进入局域网
    if OldSelectType <> SelectConnType_Local then
      NetworkModeApi.EnterLan;
  end
  else
  if NewSelectType = SelectConnType_Group then
    NetworkModeApi.JoinAGroup( NewSelectValue1, NewSelectValue2 )
  else
  if NewSelectType = SelectConnType_ConnPC then
    NetworkModeApi.ConnToAPc( NewSelectValue1, NewSelectValue2 );
end;

{ TNetworkConnSettingCancelHandle }

procedure TNetworkConnSettingCancelHandle.Update;
var
  CbbNetworkModeSelectFace : TCbbNetworkModeSelectFace;
begin
  CbbNetworkModeSelectFace := TCbbNetworkModeSelectFace.Create( OldSelectType );
  CbbNetworkModeSelectFace.SetValue( OldSelectValue1, OldSelectValue2 );
  CbbNetworkModeSelectFace.AddChange;
end;

{ NetworkConnChangeUtil }

class procedure NetworkConnChangeUtil.ReseConntPage;
begin
  with frmSetting do
    pcNetworkConn.ActivePageIndex := cbbNetworkMode.ItemIndex;
end;

class procedure NetworkConnChangeUtil.ResetConnToPcShow;
var
  ItemData : TCbbConnToPcItemData;
begin
  with frmSetting do
  begin
    if cbbConnToPc.ItemIndex >= cbbConnToPc.ItemsEx.Count  then
      Exit;

    ItemData := cbbConnToPc.ItemsEx.Items[ cbbConnToPc.ItemIndex ].Data;
    edtConnToPcPort.Text := ItemData.Port;
    btnDeleteConnToPc.Visible := True;
  end;
end;

class procedure NetworkConnChangeUtil.ResetGroupShow;
var
  ItemData : TCbbGroupItemData;
begin
  with frmSetting do
  begin
    if cbbGroup.ItemIndex >= cbbGroup.ItemsEx.Count  then
      Exit;

    ItemData := cbbGroup.ItemsEx.Items[ cbbGroup.ItemIndex ].Data;
    edtGroupPassword.Text := ItemData.Password;
    btnDeleteGroup.Visible := True;
  end;
end;

{ TSharePathData }

constructor TSharePathData.Create(_SharePath: string);
begin
  SharePath := _SharePath;
end;


{ TFrmSettingDropFileHandle }

procedure TFrmSettingDropFileHandle.AddSharePath;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    SharePathChangeUtil.AddPath( FilePathList[i] );
end;

procedure TFrmSettingDropFileHandle.Update;
begin
  if frmSetting.PcMain.ActivePage = frmSetting.tsShare then
    AddSharePath;

  SetForegroundWindow(frmSetting.Handle);
end;

end.
