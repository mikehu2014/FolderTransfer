unit UMainFormFace;

interface

uses UChangeInfo;

type

{$Region ' Status Bar 界面更新 ' }

    // 父类
  TStatusBarChangeInfo = class( TFaceChangeInfo )
  public
    ShowStr : string;
  public
    constructor Create( _ShowStr : string );
  end;

    // Backup Cow 模式
  TModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // 网络模式
  TNetworkModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // 上传速度
  TUpSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // 下载速度
  TDownSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // 同步时间
  TSyncTimeChangeInfo = class( TStatusBarChangeInfo )
  private
    HintStr : string;
  public
    procedure SetHintStr( _HintStr : string );
    procedure Update;override;
  end;

    // 版本号
  TEditionChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // 网络 连接状态
  TNetStatusChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' TrayIcon 显示 '}

  TShowTrayHintStr = class( TChangeInfo )
  public
    TitleStr : string;
    ContentStr : string;
  public
    constructor Create( _TitleStr, _ContentStr : string );
    procedure Update;override;
  end;

  TShowSendFileBtnFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Hint 显示 ' }

  TShowHintWriteFace = class( TFaceChangeInfo )
  public
    FileName, Destination : string;
    HintType : string;
    IsFile : Boolean;
  public
    constructor Create( _FileName, _Destination : string );
    procedure SetHintType( _HintType : string );
    procedure SetIsFile( _IsFile : Boolean );
  protected
    procedure Update;override;
  end;

  TShowHintTimeSetFace = class( TFaceChangeInfo )
  public
    ShowHintTime : Integer;
  public
    constructor Create( _ShowHintTime : Integer );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Tool Bar 显示 ' }

  TShowNewReceiveFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  TShowNewShareFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  HintType_Sending = 'Sending';
  HintType_SendCompleted = 'SendCompeted';

  HintType_Receiving = 'Receiving';
  HintType_ReceiveCompelted = 'ReceiveCompleted';

  HintType_DownloadSharing = 'DownloadSharing';
  HintType_DownShareCompleted = 'DownloadSharedCompleted';

var
  MyMainFormFace : TMyChildFaceChange;

implementation

uses UMainForm, UFormFreeEdition, UFormHint;

{ TStatusBarChangeInfo }

constructor TStatusBarChangeInfo.Create(_ShowStr: string);
begin
  ShowStr := _ShowStr;
end;

{ TModeChangeInfo }

procedure TModeChangeInfo.Update;
begin
end;

{ TNetworkModeChangeInfo }

procedure TNetworkModeChangeInfo.Update;
begin
  frmMainForm.sbNetworkMode.Caption := ShowStr;
end;

{ TUpSpeedChangeInfo }

procedure TUpSpeedChangeInfo.Update;
begin
  frmMainForm.sbUpSpeed.Caption := ShowStr;
end;

{ TDownSpeedChangeInfo }

procedure TDownSpeedChangeInfo.Update;
begin
  frmMainForm.sbDownSpeed.Caption := ShowStr;
end;

{ TSyncTimeChangeInfo }

procedure TSyncTimeChangeInfo.SetHintStr(_HintStr: string);
begin
  HintStr := _HintStr;
end;

procedure TSyncTimeChangeInfo.Update;
begin

end;

{ TEditionChangeInfo }

procedure TEditionChangeInfo.Update;
begin
  frmMainForm.sbEdition.Caption := ShowStr;
end;

{ TNetStatusChangeInfo }

procedure TNetStatusChangeInfo.Update;
begin
  frmMainForm.sbMyStatus.Caption := ShowStr;
end;

{ TShowTrayHintStr }

constructor TShowTrayHintStr.Create(_TitleStr, _ContentStr: string);
begin
  TitleStr := _TitleStr;
  ContentStr := _ContentStr;
end;

procedure TShowTrayHintStr.Update;
begin
  with frmMainForm do
  begin
    tiApp.BalloonTitle := TitleStr;
    tiApp.BalloonHint := ContentStr;
    tiApp.ShowBalloonHint;
  end;
end;

{ TShowHintWriteFace }

constructor TShowHintWriteFace.Create(_FileName, _Destination: string);
begin
  FileName := _FileName;
  Destination := _Destination;
end;

procedure TShowHintWriteFace.SetHintType(_HintType: string);
begin
  HintType := _HintType;
end;

procedure TShowHintWriteFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShowHintWriteFace.Update;
var
  Params : TShowHintParams;
begin
  Params.FileName := FileName;
  Params.Destination := Destination;
  Params.IsFile := IsFile;

  if App_IsExit then
  else
  if HintType = HintType_ReceiveCompelted then
    frmHint.ShowReceiveCompelted( Params )
  else
  if not frmMainForm.getIsShowHint then
    Exit
  else
  if HintType = HintType_Sending then
    frmHint.ShowSending( Params )
  else
  if HintType = HintType_SendCompleted then
    frmHint.ShowSendCompleted( Params )
  else
  if HintType = HintType_Receiving then
    frmHint.ShowReceiving( Params )
  else
  if HintType = HintType_DownloadSharing then
    frmHint.ShowDownloadingShare( Params )
  else
  if HintType = HintType_DownShareCompleted then
    frmHint.ShowDownShareCompleted( Params )
end;

{ TShowHintTimeSetFace }

constructor TShowHintTimeSetFace.Create(_ShowHintTime: Integer);
begin
  ShowHintTime := _ShowHintTime;
end;

procedure TShowHintTimeSetFace.Update;
begin
  frmHint.tmrClose.Interval := ShowHintTime * 1000;
end;

{ TShowSendFileBtnFace }

procedure TShowSendFileBtnFace.Update;
begin
  frmMainForm.tbtnSendAdd.Enabled := True;
  frmMainForm.tbtnSendPcFilter.Enabled := True;
end;

{ TShowNewReceiveFace }

procedure TShowNewReceiveFace.Update;
begin
  if frmMainForm.PcMain.ActivePageIndex <> MainPage_FileReceive then
    frmMainForm.tbtnFileReceive.ImageIndex := Icon_ReceiveNew;
end;

{ TShowNewSendFace }

procedure TShowNewShareFace.Update;
begin
  if frmMainForm.PcMain.ActivePageIndex <> MainPage_FileShare then
    frmMainForm.tbtnFileSharePage.ImageIndex := Icon_ShareNew;
end;

end.
