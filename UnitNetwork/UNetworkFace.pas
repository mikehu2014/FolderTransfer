unit UNetworkFace;

interface

uses UChangeInfo, ComCtrls, ExtCtrls, ListActns, SysUtils, UMyUtil, Math, RzStatus, Classes,
     VirtualTrees, Graphics, Generics.Collections, UModelUtil, VCLTee.Series, ValEdit, SyncObjs,
     DateUtils, uDebug, Menus, StdCtrls, RzTabs;

type

{$Region ' StatusBar ������� '}

  TSbMyStatusChangeInfo = class( TChangeInfo )
  protected
    SbMyStatus : TRzGlyphStatus;
  public
    procedure Update;override;
  end;

    // δ����
  TSbMyStatusNotConnInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

    // ��������
  TSbMyStatusConningInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

    // ������
  TSbMyStatusConnInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Settting ���� ' }

    // ��������ʱ ��ȡ���� InternetIp Ȼ�� ӳ�䵽 Settings ����
  TInternetSocketChangeInfo = class( TFaceChangeInfo )
  public
    InternetIp : string;
  public
    constructor Create( _InternetIp: string );
    procedure Update;override;
  end;

    // ��¼ Account ��������
  TStandardError = class( TFaceChangeInfo )
  private
    AccountName : string;
  public
    constructor Create( _AccountName : string );
  end;

    // �������
  TStandardPasswordError = class( TStandardError )
  public
    procedure Update;override;
  end;

    // �ʺŲ�����
  TStandardAccountError = class( TStandardError )
  private
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;override;
  end;

    // Dns Error
  TAdvanceDnsError = class( TFaceChangeInfo )
  private
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
    procedure Update;override;
  end;

      // SecurityID Error
  TAdvanceSecurityIDError = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Pm Network ���� ' }

  TPmNetworkOpenChangeInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  TPmNetworkCloseChangeInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  TPmNetworkReturnLocalNetwork = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Network Conn ����'}

    // �޸� ����
  TPlNetworkConnChangeInfo = class( TFaceChangeInfo )
  protected
    plNetworkNotConn : TPanel;
    pcNetworkWarnning : TRzPageControl;
    pcRemoteWarnning : TRzPageControl;
  public
    procedure Update;override;
  end;

     // ��ʾ û������ Pc
  TPlNetworkNotPcShowInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

     // ��ʾ �����˾ɰ汾 Pc
  TPlNetworkPcOldEditionShowInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

     // ��ʾ �������°汾 Pc
  TPlNetworkPcNewEditionShowInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

   // Group ������
  TPlNetworkGroupNotExist = class( TPlNetworkConnChangeInfo )
  private
    GroupName : string;
  public
    procedure SetGroupName( _GroupName : string );
  protected
    procedure Update;override;
  end;

    // Group �������
  TPlNetworkGroupPasswordError = class( TPlNetworkConnChangeInfo )
  private
    GroupName : string;
  public
    procedure SetGroupName( _GroupName : string );
  protected
    procedure Update;override;
  end;

    // ���� Pc ��Ip ����
  TPlNetworkConnPcIpError = class( TPlNetworkConnChangeInfo )
  private
    Domain, Port : string;
  public
    procedure SetConnPcInfo( _Domain, _Port : string );
  protected
    procedure Update;override;
  end;

    // ���� Pc ���޷�����
  TPlNetworkConnPcError = class( TPlNetworkConnChangeInfo )
  private
    Domain, Port : string;
  public
    procedure SetConnPcInfo( _Domain, _Port : string );
  protected
    procedure Update;override;
  end;

    // ���� Pc ��SecurityID ����
  TPlNetworkConnPcSecurityNumberError = class( TPlNetworkConnChangeInfo )
  private
    Domain, Port : string;
  public
    procedure SetConnPcInfo( _Domain, _Port : string );
  protected
    procedure Update;override;
  end;

    // ����ʱ
  TPlNetworkConnRemainInfo = class( TFaceChangeInfo )
  public
    ShowTime : Integer;
  public
    constructor Create( _ShowTime : Integer );
    procedure Update;override;
  end;

    // ���������ȴ�
  TPlNetworkConnHideInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

    // ����û��Pc����ʾ
  TPlNetworkNoPcHideInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Conn �汾���� ' }

    // ���ݽṹ
  TConnEditonData = class
  public
    Ip : string;
  public
    constructor Create( _Ip : string );
  end;

    // ����
  TConnEditionChangeFace = class( TFaceChangeInfo )
  public
    LvComputer : TListView;
  protected
    procedure Update;override;
  end;

    // �޸�
  TConnEditionWriteFace = class( TConnEditionChangeFace )
  protected
    Ip : string;
  protected
    ItemIndex : Integer;
    ConnItem : TListItem;
    ItemData : TConnEditonData;
  public
    constructor Create( _Ip : string );
  protected
    function FindConnItem : Boolean;
  end;

    // ���
  TConnEditionAddFace = class( TConnEditionWriteFace )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // ɾ��
  TConnEditionRemoveFace = class( TConnEditionWriteFace )
  protected
    procedure Update;override;
  end;

    // ���
  TConnEditionClearFace = class( TConnEditionChangeFace )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Remote Group ���� ' }

  {$Region ' Popmenu ' }

    // ����
  TPmGroupChangeFace = class( TFaceChangeInfo )
  protected
    PmNetwork : TPopupMenu;
  protected
    procedure Update;override;
  end;

    // �޸�
  TPmGroupWriteFace = class( TPmGroupChangeFace )
  public
    GroupName : string;
  public
    GroupIndex : Integer;
    InseartIndex : Integer;
  public
    constructor Create( _GroupName : string );
  protected
    function FindNetworkGroupNode : Boolean;
  end;

    // ���
  TPmGroupAddFace = class( TPmGroupWriteFace )
  protected
    procedure Update;override;
  end;


    // ɾ��
  TPmGroupRemoveFace = class( TPmGroupWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' SelectForm ' }

  TCbbGroupItemData = class
  public
    GroupName : string;
    Password : string;
  public
    constructor Create( _GroupName : string );
    procedure SetPassword( _Password : string );
  end;

    // ����
  TCbbGroupChangeFace = class( TFaceChangeInfo )
  protected
    CbbGroup : TComboBoxEx;
  protected
    procedure Update;override;
  end;

    // �޸�
  TCbbGroupWriteFace = class( TCbbGroupChangeFace )
  public
    GroupName : string;
  public
    GroupIndex : Integer;
    ItemData : TCbbGroupItemData;
  public
    constructor Create( _GroupName : string );
  protected
    function FindNetworkGroupNode : Boolean;
  end;

    // ���
  TCbbGroupAddFace = class( TCbbGroupWriteFace )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;

     // ���
  TCbbGroupSetPasswordFace = class( TCbbGroupWriteFace )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;

    // ѡ��
  TCbbGroupSelectFace = class( TCbbGroupWriteFace )
  protected
    procedure Update;override;
  end;


    // ɾ��
  TCbbGroupRemoveFace = class( TCbbGroupWriteFace )
  protected
    procedure Update;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' Conn to Pc ���� ' }

  {$Region ' Popmenu ' }

    // ����
  TPmPcConnChangeFace = class( TFaceChangeInfo )
  protected
    PmNetwork : TPopupMenu;
  protected
    procedure Update;override;
  end;

    // �޸�
  TPmPcConnWriteFace = class( TPmPcConnChangeFace )
  public
    Domain, Port : string;
    ShowConnPcStr : string;
  public
    ConnPcIndex : Integer;
    InseartIndex : Integer;
  public
    constructor Create( _Domain, _Port : string );
  protected
    function FindNetworkPcConnNode : Boolean;
  end;

    // ���
  TPmPcConnAddFace = class( TPmPcConnWriteFace )
  protected
    procedure Update;override;
  end;


    // ɾ��
  TPmPcConnRemoveFace = class( TPmPcConnWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' SelectForm ' }

  TCbbConnToPcItemData = class
  public
    Ip, Port : string;
  public
    constructor Create( _Ip, _Port : string );
  end;

    // ����
  TCbbConnToPcChangeFace = class( TFaceChangeInfo )
  protected
    CbbConnToPc : TComboBoxEx;
  protected
    procedure Update;override;
  end;

    // �޸�
  TCbbConnToPcWriteFace = class( TCbbConnToPcChangeFace )
  public
    Ip, Port : string;
  public
    ConnToPcIndex : Integer;
    ItemData : TCbbConnToPcItemData;
  public
    constructor Create( _Ip, _Port : string );
  protected
    function FindNetworkConnToPcNode : Boolean;
  end;

    // ���
  TCbbConnToPcAddFace = class( TCbbConnToPcWriteFace )
  public
    procedure Update;override;
  end;

        // ѡ��
  TCbbConnToPcSelectFace = class( TCbbConnToPcWriteFace )
  protected
    procedure Update;override;
  end;


    // ɾ��
  TCbbConnToPcRemoveFace = class( TCbbConnToPcWriteFace )
  protected
    procedure Update;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' Select Network Mode ' }

  TNetworkModeSelectFace = class( TFaceChangeInfo )
  public
    SelectType : string;
    SelectValue1, SelectValue2 : string;
  public
    constructor Create( _SelectType : string );
    procedure SetValue( _SelectValue1, _SelectValue2 : string );
  end;


  TPmNetworkModeSelectFace = class( TNetworkModeSelectFace )
  public
    PmNetwork : TPopupMenu;
  protected
    procedure Update;override;
  end;

  TCbbNetworkModeSelectFace = class( TNetworkModeSelectFace )
  public
    CbbNetwork : TCombobox;
  protected
    procedure Update;override;
  private
    procedure SetGroupSelect;
    procedure SetConnToPcSelect;
  private
    procedure LanStatuBar;
    procedure GroupStatusbar;
    procedure ConnToPcStatusBar;
  end;

      // ˢ�� ��ȫ
  TSbNetworkSecuritySetFace = class( TFaceChangeInfo )
  public
    IsSecurity : Boolean;
  public
    procedure SetIsSecurity( _IsSecurity : Boolean );
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' Network Status ���� ' }

  {$Region ' ���ݽṹ ' }

    // ���ݽṹ
  TNetworkStatusData = record
  public
    PcID, PcName : WideString;
    Ip, Port : WideString;
    IsConnect, IsLanConn : boolean;
    IsOnline, IsServer : boolean;
  public
    ClientCount : Integer;
  end;
  PNetworkStatusData = ^TNetworkStatusData;

  {$EndRegion}

  {$Region ' ���/ɾ�� ' }

      // ����
  TNetworkStatusChangeFace = class( TFaceChangeInfo )
  public
    VstNetworkStatus : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // �޸�
  TNetworkStatusWriteFace = class( TNetworkStatusChangeFace )
  public
    PcID : string;
  protected
    NetworkStatusNode : PVirtualNode;
    NetworkStatusData : PNetworkStatusData;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetworkStatusNode : Boolean;
  protected
    procedure RefreshNode;
  end;

      // ���
  TNetworkStatusAddFace = class( TNetworkStatusWriteFace )
  public
    PcName : string;
  public
    Ip, Port : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // ɾ��
  TNetworkStatusRemoveFace = class( TNetworkStatusWriteFace )
  protected
    procedure Update;override;
  end;

    // ���
  TNetworkStatusClearFace = class( TNetworkStatusChangeFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

      // �޸�
  TNetworkStatusSetConnectInfoFace = class( TNetworkStatusWriteFace )
  public
    Ip, Port : string;
    IsConnect, IsLanConn : boolean;
  public
    procedure SetConnectInfo( _Ip, _Port : string; _IsConnect, _IsLanConn : boolean );
  protected
    procedure Update;override;
  private
    procedure AddConnect;
    procedure AddNotConnect;
  end;

      // �޸�
  TNetworkStatusSetIsOnlineFace = class( TNetworkStatusWriteFace )
  public
    IsOnline : boolean;
  public
    procedure SetIsOnline( _IsOnline : boolean );
  protected
    procedure Update;override;
  end;


    // �޸�
  TNetworkStatusSetIsServerFace = class( TNetworkStatusWriteFace )
  public
    IsServer : boolean;
  public
    procedure SetIsServer( _IsServer : boolean );
  protected
    procedure Update;override;
  end;





  {$EndRegion}

{$EndRegion}

{$Region ' MyPc Network Status ���� ' }

  TMyPcStatusData = class
  public
    IsShowError : Boolean;
    ErrorIndex : Integer;
  public
    constructor Create;
  end;

  TMyPcStatusChangeFace = class( TFaceChangeInfo )
  public
    LvMyStatus : TListView;
  protected
    procedure Update;override;
  protected
    function getIsExistItem( ItemIndex : Integer ): Boolean;
    procedure SetShowStr( li : TListItem; ShowStr : string );
    procedure SetShowIcon( li : TListItem; IconIndex : Integer );
  end;

  {$Region ' ����ģʽ ' }

  TMyPcStatusNetworkModeSetFace = class( TMyPcStatusChangeFace )
  public
    NetworkModeShow : string;
    DetailShow : string;
  public
    constructor Create( _NetworkModeShow : string );
    procedure SetDetailShow( _DetailShow : string );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �㲥��Ϣ �޸� ' }

  TMyPcStatusBroadcastChangeFace = class( TMyPcStatusChangeFace )
  protected
    LiBroadcastPort : TListItem;
    LiBroadcastRev : TListItem;
    ItemData : TMyPcStatusData;
  protected
    function FindBroadcastItem : Boolean;
  end;

    // �㲥 �ò���
  TMyPcStatusBroadcastDisableFace = class( TMyPcStatusBroadcastChangeFace )
  protected
    procedure Update;override;
  end;

    // �㲥 �˿�
  TMyPcStatusBroadcastSetPortFace = class( TMyPcStatusBroadcastChangeFace )
  private
    BroadcastPort : string;
    ErrorStr : string;
  public
    constructor Create( _BroadcastPort : string );
    procedure SetErrorStr( _ErrorStr : string );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Lan ��Ϣ ' }

  TMyPcStatusLanChangeFace = class( TMyPcStatusChangeFace )
  protected
    LiLanIp, LiLanPort : TListItem;
    LiLanAccept : TListItem;
    ItemData : TMyPcStatusData;
  protected
    function FindLanItem : Boolean;
  end;

    // Lan �˿�
  TMyPcStatusLanSetSocketFace = class( TMyPcStatusLanChangeFace )
  private
    LanIp, LanPort : string;
  public
    constructor Create( _LanIp, _LanPort : string );
  protected
    procedure Update;override;
  end;

    // Lan ���ճɹ�
  TMyPcStatusLanSuccessFace = class( TMyPcStatusLanChangeFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Internet ��Ϣ ' }

  TMyPcStatusInternetChangeFace = class( TMyPcStatusChangeFace )
  protected
    LiInternetIp, LiInternetPort : TListItem;
    LiInternetAccept : TListItem;
    ItemData : TMyPcStatusData;
  protected
    function FindInternetItem : Boolean;
  end;

    // Internet �˿�
  TMyPcStatusInternetSetSocketFace = class( TMyPcStatusInternetChangeFace )
  private
    InternetIp, InternetPort : string;
  public
    constructor Create( _InternetIp, _InternetPort : string );
  protected
    procedure Update;override;
  end;

    // Internet ���ճɹ�
  TMyPcStatusInternetSuccessFace = class( TMyPcStatusInternetChangeFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

    {$Region ' Upnp ��Ϣ ' }

  TMyPcStatusUpnpChangeFace = class( TMyPcStatusChangeFace )
  protected
    LiUpnpServer, LiUpnpPortMap : TListItem;
  protected
    function FindUpnpItem : Boolean;
  end;

    // �Ƿ����ӳ����豸
  TMyPcStatusUpnpServerFace = class( TMyPcStatusUpnpChangeFace )
  private
    IsExist : Boolean;
    ControlUrl : string;
  public
    constructor Create( _IsExist : Boolean; _ControlUrl : string );
  protected
    procedure Update;override;
  end;

    // �Ƿ�ӳ��ɹ�
  TMyPcStatusUpnpPortMapFace = class( TMyPcStatusUpnpChangeFace )
  private
    IsCompleted : Boolean;
  public
    constructor Create( _IsCompleted : Boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ������Ϣ ���� ' }

      // �޸� Pc ��Ϣ
  TMyPcInfoRaadFace = class( TFaceChangeInfo )
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort, _InternetPort : string );
  protected
    procedure Update;override;
  end;

    // ���� ������ Ip
  TMyPcInfoSetLanIpFace = class( TFaceChangeInfo )
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
  protected
    procedure Update;override;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetLanPortFace = class( TFaceChangeInfo )
  public
    LanPort : string;
  public
    constructor Create( _LanPort : string );
  protected
    procedure Update;override;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetInternetPortFace = class( TFaceChangeInfo )
  public
    InternetPort : string;
  public
    constructor Create( _InternetPort : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  ShowStr_NetworkMode = 'Network Mode: ';

const
  MyPcStatusItem_NetworkMode = 0;

  MyPcStatusItem_BroadcastPort = 2;
  MyPcStatusItem_BroadcastRev = 3;

  MyPcStatusItem_LanIp = 5;
  MyPcStatusItem_LanPort = 6;
  MyPcStatusItem_LanAccept = 7;

  MyPcStatusItem_InternetIp = 9;
  MyPcStatusItem_InternetPort = 10;
  MyPcStatusItem_InternetAccept = 11;

  MyPcStatusItem_UpnpServer = 13;
  MyPcStatusItem_UpnpPortMap = 14;

  MyPcStatusShow_Disable = 'N/A';
  MyPcStatusShow_WaitBroadcast = 'have not receive any broadcast message from other computers';
  MyPcStatusShow_WaitLan = 'have not accept any connections from other LAN computers';
  MyPcStatusShow_WaitInternet = 'have not accept any connections from other Internet computers';
  MyPcStatusShow_Success = 'Success';
  MyPcStatusShow_Failure = 'Failure';

  MyPcStatusIcon_Warnning = 2;
  MyPcStatusIcon_Error = 3;
  MyPcStatusIcon_Success = 4;
  MyPcStatusIcon_LAN = 5;
  MyPcStatusIcon_Group = 6;
  MyPcStatusIcon_ConnToPc = 7;

  MyNetworkModeShow_LAN = 'LAN';
  MyNetworkModeShow_Group = 'Group';
  MyNetworkModeShow_ConnToPc = 'Connect to pc';

  MyNetworTag_Error = 1;

  ErrorIndex_BroadcasetNA = 0;
  ErrorIndex_BroadcasetNotReceive = 1;
  ErrorIndex_LanNotAccept = 2;
  ErrorIndex_InternetNotAccept = 3;

const
  GroupNotExist_ShowStr = 'Group "%s" does not exist.';
  GroupPasswordError_ShowStr = 'Group "%s" password is incorrect.';
  ConnPcIpError_ShowStr = 'Can not parse "%s" to ip address.';
  ConnPcNotConn_ShowStr = 'Remote computer "%s" cannot connect.';
  ConnPcSecurityIDError_ShowStr = 'Your Security ID Number and %s Security ID Number are not matched';

var
  GroupError_Name : string = '';
  ConnPcError_Domain : string = '';
  ConnPcError_Port : string = '';


const
  PcName_MyComputer = ' (MyComputer)';
  PcStatus_Unknown = 'Unknown';

  SbMyStatus_NotConn = 'Not Connected';
  SbMyStatus_Conning = 'Connecting';
  SbMyStatus_Conn = 'Connected';

  SbMyStatusIcon_NotConn = 6;
  SbMyStatusIcon_Conn = 7;

  LvRegister_PcID = 0;
  LvRetister_Edition = 1;


  PlNetworkConn_ShowRemain : string = 'It will connect again after %s or you can ';

  DomainParse_NotFind = '%s(not found)';

const
  GroupName_After = '';
  ComputerName_After = '';

const
  SplitStr_ConnPc = ':';

var
  Network_LocalPcID : string;
  MyNetworkFace : TMyChildFaceChange;

implementation

uses UMainForm, UFormUtil, UFormSetting, UFormRegister, UNetworkControl,
     UNetworkStatus, UFormEditionNotMatch,
     UFromEnterGroup, UFormConnPc;


{ TSbMyStatusNotConnInfo }

procedure TSbMyStatusNotConnInfo.Update;
begin
  inherited;

  SbMyStatus.Caption := SbMyStatus_NotConn;
  SbMyStatus.ImageIndex := SbMyStatusIcon_NotConn;
  SbMyStatus.Tag := 0;
end;

{ TSbMyStatusConningInfo }

procedure TSbMyStatusConningInfo.Update;
var
  t : Integer;
  ShowStr : string;
  i, DotLen, ShowIcon : Integer;
begin
  inherited;

  SbMyStatus.Tag := SbMyStatus.Tag + 1;
  t := SbMyStatus.Tag;

  if ( t mod 2 ) = 0 then
    ShowIcon := SbMyStatusIcon_NotConn
  else
    ShowIcon := SbMyStatusIcon_Conn;

  ShowStr := SbMyStatus_Conning;
  DotLen := t mod 4;
  for i := 0 to DotLen - 1 do
    ShowStr := ShowStr + '.';

  SbMyStatus.Caption := ShowStr;
  SbMyStatus.ImageIndex := ShowIcon;
end;

{ TSbMyStatusConnInfo }

procedure TSbMyStatusConnInfo.Update;
begin
  inherited;

  SbMyStatus.Caption := SbMyStatus_Conn;
  SbMyStatus.ImageIndex := SbMyStatusIcon_Conn;
  SbMyStatus.Tag := 0;
end;

{ TSbMyStatusChangeInfo }

procedure TSbMyStatusChangeInfo.Update;
begin
  SbMyStatus := frmMainForm.sbMyStatus;
end;

{ TInternetSocketChangeInfo }

constructor TInternetSocketChangeInfo.Create(_InternetIp: string);
begin
  InternetIp := _InternetIp;
end;

procedure TInternetSocketChangeInfo.Update;
begin
  frmSetting.edtInternetIp.Text := InternetIp;
end;

{ TPmNetworkOpenChangeInfo }

procedure TPmNetworkOpenChangeInfo.Update;
begin
  frmMainForm.tbtnBackupNetwork.Enabled := True;
end;

{ TPmNetworkCloseChangeInfo }

procedure TPmNetworkCloseChangeInfo.Update;
begin
  frmMainForm.tbtnBackupNetwork.Enabled := False;
end;

{ TStandardPasswordError }

procedure TStandardPasswordError.Update;
begin
  frmJoinGroup.ShowResetPassword( AccountName );
end;

{ TStandardAccountError }

procedure TStandardAccountError.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TStandardAccountError.Update;
begin
  frmJoinGroup.ShowGroupNotExist( AccountName, Password );
end;

{ TStandardError }

constructor TStandardError.Create(_AccountName: string);
begin
  AccountName := _AccountName;
end;

{ TAdvanceDnsError }

constructor TAdvanceDnsError.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TAdvanceDnsError.Update;
begin
  frmConnComputer.ShowDnsError( Domain, Port );
end;

{ TPlNetworkConnHideInfo }

procedure TPlNetworkConnHideInfo.Update;
begin
  inherited;

  plNetworkNotConn.Visible := False;
end;

{ TPlNetworkConnRemainInfo }

constructor TPlNetworkConnRemainInfo.Create(_ShowTime: Integer);
begin
  ShowTime := _ShowTime;
end;

procedure TPlNetworkConnRemainInfo.Update;
var
  ShowTimeStr : string;
begin
  inherited;

  ShowTimeStr := TimeTypeUtil.getSecondShowStr( ShowTime );
  frmMainForm.lbNetworkConn.Caption := Format( PlNetworkConn_ShowRemain, [ ShowTimeStr ] );
  frmMainForm.lbIpErrorTime.Caption := Format( PlNetworkConn_ShowRemain, [ ShowTimeStr ] );
end;

{ TPlNetworkConnChangeInfo }

procedure TPlNetworkConnChangeInfo.Update;
begin
  plNetworkNotConn := frmMainForm.plNetworkNotConn;
  pcNetworkWarnning := frmMainForm.PcNetworkConn;
  pcRemoteWarnning := frmMainForm.PcRemoteWarinning;
end;

{ TPmNetworkReturnLocalNetwork }

procedure TPmNetworkReturnLocalNetwork.Update;
begin
  NetworkModeApi.SelectLocalNetwork;
  NetworkModeApi.RestartNetwork;
end;

{ TNetworkGroupChangeFace }

procedure TPmGroupChangeFace.Update;
begin
  PmNetwork := frmMainForm.PmNetwork;
end;

{ TNetworkGroupWriteFace }

constructor TPmGroupWriteFace.Create( _GroupName : string );
begin
  GroupName := _GroupName;
end;


function TPmGroupWriteFace.FindNetworkGroupNode : Boolean;
var
  i : Integer;
  SplitCount : Integer;
begin
  SplitCount := 0;

  Result := False;
  for i := 0 to PmNetwork.Items.Count - 1 do
  begin
    if PmNetwork.Items[i].Caption = '-' then
      Inc( SplitCount );
    if SplitCount = 0 then // Local Network
      Continue;
    if SplitCount = 2 then // ConnToPc
    begin
      InseartIndex := i; // ��ӵ�λ��
      Break;
    end;

      // �ҵ���
    if PmNetwork.Items[i].Caption = GroupName then
    begin
      GroupIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TNetworkGroupAddFace }

procedure TPmGroupAddFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if FindNetworkGroupNode then
    Exit;

  mi := TMenuItem.Create(nil);
  mi.Caption := GroupName + GroupName_After;
  mi.ImageIndex := -1;
  mi.OnClick := NetworkModeApi.PmSelectGroupFace;
  pmNetwork.Items.Insert( InseartIndex, mi );
end;

{ TNetworkGroupRemoveFace }

procedure TPmGroupRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;

  mi := PmNetwork.Items[ GroupIndex ];
  PmNetwork.Items.Delete( GroupIndex );
  mi.Free;
end;


{ TNetworkPcConnChangeFace }

procedure TPmPcConnChangeFace.Update;
begin
  PmNetwork := frmMainForm.PmNetwork;
end;

{ TNetworkPcConnWriteFace }

constructor TPmPcConnWriteFace.Create( _Domain, _Port : string );
begin
  Domain := _Domain;
  Port := _Port;
  ShowConnPcStr := Domain + SplitStr_ConnPc + Port;
end;


function TPmPcConnWriteFace.FindNetworkPcConnNode : Boolean;
var
  i : Integer;
  SplitCount : Integer;
begin
  SplitCount := 0;

  Result := False;
  for i := 0 to PmNetwork.Items.Count - 1 do
  begin
    if PmNetwork.Items[i].Caption = '-' then
      Inc( SplitCount );
    if SplitCount <= 1 then // Local Or Group Network
      Continue;
    if SplitCount = 3 then // End
    begin
      InseartIndex := i; // ��ӵ�λ��
      Break;
    end;

      // �ҵ���
    if PmNetwork.Items[i].Caption = ShowConnPcStr then
    begin
      ConnPcIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TNetworkPcConnAddFace }

procedure TPmPcConnAddFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if FindNetworkPcConnNode then
    Exit;

  mi := TMenuItem.Create(nil);
  mi.Caption := ShowConnPcStr + ComputerName_After;
  mi.ImageIndex := -1;
  mi.OnClick := NetworkModeApi.PmSelectConnToPcFace;
  pmNetwork.Items.Insert( InseartIndex, mi );
end;

{ TNetworkPcConnRemoveFace }

procedure TPmPcConnRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if not FindNetworkPcConnNode then
    Exit;

  mi := PmNetwork.Items[ ConnPcIndex ];
  PmNetwork.Items.Delete( ConnPcIndex );
  mi.Free;
end;

{ TNetworkModeSelectFace }


procedure TPmNetworkModeSelectFace.Update;
var
  i : Integer;
  SplitCount : Integer;
  IsSelected : Boolean;
begin
  PmNetwork := frmMainForm.PmNetwork;

  SplitCount := 0;
  for i := 0 to PmNetwork.Items.Count - 1 do
  begin
    if PmNetwork.Items[i].Caption = '-' then
      Inc( SplitCount );

      // Local Network
    if SplitCount = 0 then
      IsSelected := SelectType = SelectConnType_Local
    else
    if SplitCount = 1 then // Group Network
      IsSelected := ( SelectType = SelectConnType_Group ) and ( PmNetwork.Items[i].Caption = SelectValue1 )
    else
    if SplitCount = 2 then
      IsSelected := ( SelectType = SelectConnType_ConnPC ) and
                    ( PmNetwork.Items[i].Caption = SelectValue1 + SplitStr_ConnPc + SelectValue2 )
    else
      Break;

    if IsSelected then
      PmNetwork.Items[i].ImageIndex := 3
    else
      PmNetwork.Items[i].ImageIndex := -1;
  end;
end;

{ TNetworkModeSelectFace }

constructor TNetworkModeSelectFace.Create(_SelectType: string);
begin
  SelectType := _SelectType;
end;

procedure TNetworkModeSelectFace.SetValue(_SelectValue1, _SelectValue2: string);
begin
  SelectValue1 := _SelectValue1;
  SelectValue2 := _SelectValue2;
end;

{ TCbbGroupItemData }

constructor TCbbGroupItemData.Create(_GroupName: string);
begin
  GroupName := _GroupName;
end;

procedure TCbbGroupItemData.SetPassword(_Password: string);
begin
  Password := _Password;
end;

{ TCbbGroupChangeFace }

procedure TCbbGroupChangeFace.Update;
begin
  CbbGroup := frmSetting.cbbGroup;
end;

{ TCbbGroupWriteFace }

constructor TCbbGroupWriteFace.Create(_GroupName: string);
begin
  GroupName := _GroupName;
end;

function TCbbGroupWriteFace.FindNetworkGroupNode: Boolean;
var
  SelectData : TCbbGroupItemData;
  i: Integer;
begin
  Result := False;

  for i := 0 to CbbGroup.ItemsEx.Count - 1 do
  begin
    SelectData := CbbGroup.ItemsEx.Items[i].Data;
    if SelectData.GroupName = GroupName then
    begin
      ItemData := SelectData;
      Result := True;
      GroupIndex := i;
      Break;
    end;
  end;
end;

{ TCbbGroupAddFace }

procedure TCbbGroupAddFace.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TCbbGroupAddFace.Update;
var
  GroupItem : TComboExItem;
begin
  inherited;
  if not FindNetworkGroupNode then
  begin
    GroupItem := CbbGroup.ItemsEx.Add;
    GroupItem.Caption := GroupName;
    GroupItem.ImageIndex := 4;
    ItemData := TCbbGroupItemData.Create( GroupName );
    GroupItem.Data := ItemData;
  end;
  ItemData.SetPassword( password );
end;

{ TCbbGroupRemoveFace }

procedure TCbbGroupRemoveFace.Update;
var
  NewIndex : Integer;
begin
  inherited;
  if not FindNetworkGroupNode then
    Exit;
  CbbGroup.ItemsEx.Delete( GroupIndex );
  ItemData.Free;

  if GroupIndex >= CbbGroup.ItemsEx.Count then
    NewIndex := GroupIndex - 1
  else
    NewIndex := GroupIndex;

  if ( NewIndex <= -1 ) or ( NewIndex >= CbbGroup.ItemsEx.Count ) then
    Exit;

  CbbGroup.ItemIndex := NewIndex;
  NetworkConnChangeUtil.ResetGroupShow;
end;

{ TCbbConnToPcItemData }

constructor TCbbConnToPcItemData.Create(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TCbbConnToPcChangeFace }

procedure TCbbConnToPcChangeFace.Update;
begin
  CbbConnToPc := frmSetting.cbbConnToPc;
end;

{ TCbbConnToPcWriteFace }

constructor TCbbConnToPcWriteFace.Create(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

function TCbbConnToPcWriteFace.FindNetworkConnToPcNode: Boolean;
var
  SelectData : TCbbConnToPcItemData;
  i: Integer;
begin
  Result := False;

  for i := 0 to CbbConnToPc.ItemsEx.Count - 1 do
  begin
    SelectData := CbbConnToPc.ItemsEx.Items[i].Data;
    if ( SelectData.Ip = Ip ) and ( SelectData.Port = Port ) then
    begin
      ItemData := SelectData;
      Result := True;
      ConnToPcIndex := i;
      Break;
    end;
  end;
end;

{ TCbbConnToPcAddFace }

procedure TCbbConnToPcAddFace.Update;
var
  ConnToPcItem : TComboExItem;
begin
  inherited;

  if FindNetworkConnToPcNode then
    Exit;

  ConnToPcItem := CbbConnToPc.ItemsEx.Add;
  ConnToPcItem.Caption := Ip;
  ConnToPcItem.ImageIndex := 5;
  ItemData := TCbbConnToPcItemData.Create( Ip, Port );
  ConnToPcItem.Data := ItemData;
end;

{ TCbbConnToPcRemoveFace }

procedure TCbbConnToPcRemoveFace.Update;
var
  NewIndex : Integer;
begin
  inherited;

  if not FindNetworkConnToPcNode then
    Exit;

  CbbConnToPc.ItemsEx.Delete( ConnToPcIndex );
  ItemData.Free;

  if ConnToPcIndex >= CbbConnToPc.ItemsEx.Count then
    NewIndex := ConnToPcIndex - 1
  else
    NewIndex := ConnToPcIndex;

  if ( NewIndex <= -1 ) or ( NewIndex >= CbbConnToPc.ItemsEx.Count ) then
    Exit;

  CbbConnToPc.ItemIndex := NewIndex;
end;

{ TCbbGroupSetPasswordFace }

procedure TCbbGroupSetPasswordFace.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TCbbGroupSetPasswordFace.Update;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;

  ItemData.SetPassword( Password );
end;

{ TCbbNetworkModeSelectFace }

procedure TCbbNetworkModeSelectFace.ConnToPcStatusBar;
begin
  with frmMainForm.sbNetworkMode do
  begin
    Caption := 'Connect: ' + SelectValue1;
    ImageIndex := NetworkModeIcon_Remote;
  end;

  frmMainForm.tbtnBackupNetwork.Caption := ShowStr_NetworkMode + Format( 'Computer ( %s )', [SelectValue1] );
end;

procedure TCbbNetworkModeSelectFace.GroupStatusbar;
begin
  with frmMainForm.sbNetworkMode do
  begin
    Caption := 'Group: ' + SelectValue1;
    ImageIndex := NetworkModeIcon_Remote;
  end;

  frmMainForm.tbtnBackupNetwork.Caption := ShowStr_NetworkMode + Format( 'Group ( %s )', [SelectValue1] );
end;

procedure TCbbNetworkModeSelectFace.LanStatuBar;
var
  ShowStr : string;
begin
  with frmMainForm.sbNetworkMode do
  begin
    Caption := 'Local Network';
    ImageIndex := NetworkModeIcon_LAN;
  end;

  frmMainForm.tbtnBackupNetwork.Caption := ShowStr_NetworkMode + 'Local Network';
end;

procedure TCbbNetworkModeSelectFace.SetConnToPcSelect;
var
  CbbConnToPcSelectFace : TCbbConnToPcSelectFace;
begin
  CbbConnToPcSelectFace := TCbbConnToPcSelectFace.Create( SelectValue1, SelectValue2 );
  CbbConnToPcSelectFace.Update;
  CbbConnToPcSelectFace.Free;
end;

procedure TCbbNetworkModeSelectFace.SetGroupSelect;
var
  CbbGroupSelectFace : TCbbGroupSelectFace;
begin
  CbbGroupSelectFace := TCbbGroupSelectFace.Create( SelectValue1 );
  CbbGroupSelectFace.Update;
  CbbGroupSelectFace.Free;
end;

procedure TCbbNetworkModeSelectFace.Update;
begin
  CbbNetwork := frmSetting.cbbNetworkMode;
  if SelectType = SelectConnType_Local then
  begin
    CbbNetwork.ItemIndex := 0;
    LanStatuBar;
  end
  else
  if SelectType = SelectConnType_Group then
  begin
    CbbNetwork.ItemIndex := 1;
    SetGroupSelect;
    GroupStatusbar;
  end
  else
  if SelectType = SelectConnType_ConnPC then
  begin
    CbbNetwork.ItemIndex := 2;
    SetConnToPcSelect;
    ConnToPcStatusBar;
  end;
  NetworkConnChangeUtil.ReseConntPage;
end;

{ TCbbGroupSelectFace }

procedure TCbbGroupSelectFace.Update;
begin
  inherited;
  if not FindNetworkGroupNode then
    Exit;
  CbbGroup.ItemIndex := GroupIndex;
  NetworkConnChangeUtil.ResetGroupShow;
end;

{ TCbbPcConnSelectFace }

procedure TCbbConnToPcSelectFace.Update;
begin
  inherited;
  if not FindNetworkConnToPcNode then
    Exit;
  CbbConnToPc.ItemIndex := ConnToPcIndex;
  NetworkConnChangeUtil.ResetConnToPcShow;
end;

{ TNetworkStatusChangeFace }

procedure TNetworkStatusChangeFace.Update;
begin
  VstNetworkStatus := frmNeworkStatus.VstNetworkStatus;
end;

{ TNetworkStatusWriteFace }

constructor TNetworkStatusWriteFace.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TNetworkStatusWriteFace.FindNetworkStatusNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkStatusData;
begin
  Result := False;
  SelectNode := VstNetworkStatus.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstNetworkStatus.GetNodeData( SelectNode );
    if ( SelectData.PcID = PcID ) then
    begin
      Result := True;
      NetworkStatusNode := SelectNode;
      NetworkStatusData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TNetworkStatusWriteFace.RefreshNode;
begin
  VstNetworkStatus.RepaintNode( NetworkStatusNode );
end;

{ TNetworkStatusAddFace }

procedure TNetworkStatusAddFace.SetPcName( _PcName : string );
begin
  PcName := _PcName;
end;

procedure TNetworkStatusAddFace.Update;
begin
  inherited;

  if FindNetworkStatusNode then
    Exit;

  NetworkStatusNode := VstNetworkStatus.AddChild( VstNetworkStatus.RootNode );
  NetworkStatusData := VstNetworkStatus.GetNodeData( NetworkStatusNode );
  NetworkStatusData.PcID := PcID;
  NetworkStatusData.PcName := PcName;
  NetworkStatusData.Ip := '';
  NetworkStatusData.Port := '';
  NetworkStatusData.IsConnect := False;
  NetworkStatusData.IsOnline := False;
  NetworkStatusData.IsServer := False;
end;

{ TNetworkStatusRemoveFace }

procedure TNetworkStatusRemoveFace.Update;
begin
  inherited;

  if not FindNetworkStatusNode then
    Exit;

  VstNetworkStatus.DeleteNode( NetworkStatusNode );
end;


{ TNetworkStatusSetConnectInfoFace }

procedure TNetworkStatusSetConnectInfoFace.AddConnect;
begin
    // ɾ�����������
  VstNetworkStatus.DeleteChildren( NetworkStatusNode );

    // ��ʾ��ȷ������
  NetworkStatusData.Ip := Ip;
  NetworkStatusData.Port := Port;
  NetworkStatusData.IsConnect := True;
  NetworkStatusData.IsLanConn := IsLanConn;
  RefreshNode;
end;

procedure TNetworkStatusSetConnectInfoFace.AddNotConnect;
var
  IsExistNotConn : Boolean;
  ChildNode, SelectNode : PVirtualNode;
  ChildData, SelectData : PNetworkStatusData;
begin
    // ��ǰ�ڵ��Ƿ��Ѵ��ڶ˿���Ϣ
  IsExistNotConn := ( NetworkStatusData.Ip <> '' ) and
                    ( ( NetworkStatusData.Ip <> Ip ) or ( NetworkStatusData.Port <> Port ) );

    // Ѱ�ұ仯�Ľڵ�
  if not IsExistNotConn then
    SelectNode := NetworkStatusNode
  else
  begin
    SelectNode := nil;
    ChildNode := NetworkStatusNode.FirstChild;
    while Assigned( ChildNode ) do
    begin
      ChildData := VstNetworkStatus.GetNodeData( ChildNode );
      if ( ChildData.Ip = Ip ) and ( ChildData.Port = Port ) then
      begin
        SelectNode := ChildNode;
        Break;
      end;
      ChildNode := ChildNode.NextSibling;
    end;
    if not Assigned( SelectNode ) then
      SelectNode := VstNetworkStatus.AddChild( NetworkStatusNode );
    VstNetworkStatus.Expanded[ NetworkStatusNode ] := True;
  end;

    // ˢ�½ڵ�����
  SelectData := VstNetworkStatus.GetNodeData( SelectNode );
  SelectData.Ip := Ip;
  SelectData.Port := Port;
  SelectData.IsConnect := IsConnect;
  SelectData.IsLanConn := IsLanConn;
  VstNetworkStatus.RepaintNode( SelectNode );
end;

procedure TNetworkStatusSetConnectInfoFace.SetConnectInfo( _Ip, _Port : string; _IsConnect,
  _IsLanConn : boolean );
begin
  Ip := _Ip;
  Port := _Port;
  IsConnect := _IsConnect;
  IsLanConn := _IsLanConn;
end;

procedure TNetworkStatusSetConnectInfoFace.Update;
begin
  inherited;

  if not FindNetworkStatusNode then
    Exit;

    // �����ӹ�
  if NetworkStatusData.IsConnect then
    Exit;

    // ��֧
  if not IsConnect then
    AddNotConnect
  else
    AddConnect;
end;

{ TNetworkStatusSetIsOnlineFace }

procedure TNetworkStatusSetIsOnlineFace.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TNetworkStatusSetIsOnlineFace.Update;
begin
  inherited;

  if not FindNetworkStatusNode then
    Exit;

  NetworkStatusData.IsOnline := IsOnline;

    // ����
  if not IsOnline then
  begin
    NetworkStatusData.IsConnect := False;
    NetworkStatusData.Ip := '';
    NetworkStatusData.Port := '';
    NetworkStatusData.IsServer := False;
  end;

  RefreshNode;
end;

{ TNetworkStatusSetIsServerFace }

procedure TNetworkStatusSetIsServerFace.SetIsServer( _IsServer : boolean );
begin
  IsServer := _IsServer;
end;

procedure TNetworkStatusSetIsServerFace.Update;
begin
  inherited;

  if not FindNetworkStatusNode then
    Exit;
  NetworkStatusData.IsServer := IsServer;
  RefreshNode;
end;



{ TMyPcInfoRaadFace }

constructor TMyPcInfoRaadFace.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TMyPcInfoRaadFace.SetSocketInfo(_LanIp, _LanPort,
  _InternetPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoRaadFace.Update;
var
  i: Integer;
begin
  with frmSetting do
  begin
    edtPcID.Text := PcID;
    edtPcName.Text := PcName;
    edtPort.Text := LanPort;
    edtInternetPort.Text := InternetPort;

    for i := 0 to cbbIP.Items.Count - 1 do
      if cbbIP.Items[i] = LanIp then
      begin
        cbbIP.ItemIndex := i;
        Break;
      end;
  end;
end;

{ TMyPcInfoSetLanPortFace }

constructor TMyPcInfoSetLanPortFace.Create(_LanPort: string);
begin
  LanPort := _LanPort;
end;

procedure TMyPcInfoSetLanPortFace.Update;
begin
  frmSetting.edtPort.Text := LanPort;
end;

{ TMyPcInfoSetInternetPortFace }

constructor TMyPcInfoSetInternetPortFace.Create(_InternetPort: string);
begin
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetInternetPortFace.Update;
begin
  frmSetting.edtInternetPort.Text := InternetPort;
end;

{ TMyPcInfoSetLanIpHandle }

constructor TMyPcInfoSetLanIpFace.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetLanIpFace.Update;
var
  i  : Integer;
begin
  inherited;

  with frmSetting do
  begin
      // ���¼��� Ip ��Ϣ
    ReloadIpList;

      // ѡ�� Ip
    for i := 0 to cbbIP.Items.Count - 1 do
      if cbbIP.Items[i] = LanIp then
      begin
        cbbIP.ItemIndex := i;
        Break;
      end;
  end;
end;

{ TMyPcNetworkStatusChangeFace }

function TMyPcStatusChangeFace.getIsExistItem(ItemIndex: Integer): Boolean;
begin
  Result := LvMyStatus.Items.Count > ItemIndex;
end;

procedure TMyPcStatusChangeFace.SetShowIcon(li: TListItem; IconIndex: Integer);
begin
  li.SubItemImages[0] := IconIndex;
end;

procedure TMyPcStatusChangeFace.SetShowStr(li: TListItem; ShowStr: string);
begin
  li.SubItems[0] := ShowStr;
end;

procedure TMyPcStatusChangeFace.Update;
begin
  LvMyStatus := frmNeworkStatus.LvMyNetworkStatus;
end;

{ TMyPcStatusBroadcastChangeFace }

function TMyPcStatusBroadcastChangeFace.FindBroadcastItem: Boolean;
begin
  Result := getIsExistItem( MyPcStatusItem_BroadcastPort ) and
            getIsExistItem( MyPcStatusItem_BroadcastRev );

  if not Result then
    Exit;

  LiBroadcastPort := LvMyStatus.Items[ MyPcStatusItem_BroadcastPort ];
  LiBroadcastRev := LvMyStatus.Items[ MyPcStatusItem_BroadcastRev ];
  ItemData := LiBroadcastRev.Data;
end;


{ TMyPcStatusBroadcastDisableFace }

procedure TMyPcStatusBroadcastDisableFace.Update;
begin
  inherited;

  if not FindBroadcastItem then
    Exit;

  ItemData.IsShowError := True;
  ItemData.ErrorIndex := ErrorIndex_BroadcasetNA;

  SetShowStr( LiBroadcastPort, MyPcStatusShow_Disable );
  SetShowStr( LiBroadcastRev, MyPcStatusShow_Disable );
  SetShowIcon( LiBroadcastRev, MyPcStatusIcon_Success );
end;

{ TMyPcStatusBroadcastSetPortFace }

constructor TMyPcStatusBroadcastSetPortFace.Create(_BroadcastPort: string);
begin
  BroadcastPort := _BroadcastPort;
end;

procedure TMyPcStatusBroadcastSetPortFace.SetErrorStr(_ErrorStr: string);
begin
  ErrorStr := _ErrorStr;
end;

procedure TMyPcStatusBroadcastSetPortFace.Update;
var
  IsError : Boolean;
  ShowStr : string;
  ShowIcon : Integer;
begin
  inherited;

  if not FindBroadcastItem then
    Exit;

  IsError := ErrorStr <> '';
  ItemData.IsShowError := IsError;
  if IsError then
  begin
    ShowStr := ErrorStr;
    ShowIcon := MyPcStatusIcon_Error;
    ItemData.ErrorIndex := ErrorIndex_BroadcasetNotReceive;
  end
  else
  begin
    ShowStr := MyPcStatusShow_Success;
    ShowIcon := MyPcStatusIcon_Success;
  end;

  SetShowStr( LiBroadcastPort, BroadcastPort );
  SetShowStr( LiBroadcastRev, ShowStr );
  SetShowIcon( LiBroadcastRev, ShowIcon );
end;

{ TMyPcStatusLanSetSocketFace }

constructor TMyPcStatusLanSetSocketFace.Create(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TMyPcStatusLanSetSocketFace.Update;
begin
  inherited;

  if not FindLanItem then
    Exit;

  ItemData.IsShowError := True;
  ItemData.ErrorIndex := ErrorIndex_LanNotAccept;

  SetShowStr( LiLanIp, LanIp );
  SetShowStr( LiLanPort, LanPort );
  SetShowStr( LiLanAccept, MyPcStatusShow_WaitLan );
  SetShowIcon( LiLanAccept, MyPcStatusIcon_Warnning );
end;

{ TMyPcStatusLanChangeFace }

function TMyPcStatusLanChangeFace.FindLanItem: Boolean;
begin
  Result := getIsExistItem( MyPcStatusItem_LanIp ) and
            getIsExistItem( MyPcStatusItem_LanPort ) and
            getIsExistItem( MyPcStatusItem_LanAccept );

  if not Result then
    Exit;

  LiLanIp := LvMyStatus.Items[ MyPcStatusItem_LanIp ];
  LiLanPort := LvMyStatus.Items[ MyPcStatusItem_LanPort ];
  LiLanAccept := LvMyStatus.Items[ MyPcStatusItem_LanAccept ];
  ItemData := LiLanAccept.Data;
end;

{ TMyPcStatusLanSuccessFace }

procedure TMyPcStatusLanSuccessFace.Update;
begin
  inherited;

  if not FindLanItem then
    Exit;

  ItemData.IsShowError := False;

  SetShowStr( LiLanAccept, MyPcStatusShow_Success );
  SetShowIcon( LiLanAccept, MyPcStatusIcon_Success );
end;

{ TMyPcStatusInternetChangeFace }

function TMyPcStatusInternetChangeFace.FindInternetItem: Boolean;
begin
  Result := getIsExistItem( MyPcStatusItem_InternetIp ) and
            getIsExistItem( MyPcStatusItem_InternetPort ) and
            getIsExistItem( MyPcStatusItem_InternetAccept );

  if not Result then
    Exit;

  LiInternetIp := LvMyStatus.Items[ MyPcStatusItem_InternetIp ];
  LiInternetPort := LvMyStatus.Items[ MyPcStatusItem_InternetPort ];
  LiInternetAccept := LvMyStatus.Items[ MyPcStatusItem_InternetAccept ];
  ItemData := LiInternetAccept.Data;
end;

{ TMyPcStatusInternetSetSocketFace }

constructor TMyPcStatusInternetSetSocketFace.Create(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TMyPcStatusInternetSetSocketFace.Update;
begin
  inherited;

  if not FindInternetItem then
    Exit;

  ItemData.IsShowError := True;
  ItemData.ErrorIndex := ErrorIndex_InternetNotAccept;

  SetShowStr( LiInternetIp, InternetIp );
  SetShowStr( LiInternetPort, InternetPort );
  SetShowStr( LiInternetAccept, MyPcStatusShow_WaitInternet );
  SetShowIcon( LiInternetAccept, MyPcStatusIcon_Warnning );
end;

{ TMyPcStatusInternetSuccessFace }

procedure TMyPcStatusInternetSuccessFace.Update;
begin
  inherited;

  if not FindInternetItem then
    Exit;

  ItemData.IsShowError := False;

  SetShowStr( LiInternetAccept, MyPcStatusShow_Success );
  SetShowIcon( LiInternetAccept, MyPcStatusIcon_Success );
end;

{ TMyPcStatusNetworkModeSetFace }

constructor TMyPcStatusNetworkModeSetFace.Create(_NetworkModeShow: string);
begin
  NetworkModeShow := _NetworkModeShow;
end;

procedure TMyPcStatusNetworkModeSetFace.SetDetailShow(_DetailShow: string);
begin
  DetailShow := _DetailShow;
end;

procedure TMyPcStatusNetworkModeSetFace.Update;
var
  LiNeworkMode : TListItem;
  ShowStr : string;
  ShowIcon : Integer;
begin
  inherited;

  if not getIsExistItem( MyPcStatusItem_NetworkMode ) then
    Exit;

  if NetworkModeShow = MyNetworkModeShow_LAN then
  begin
    ShowStr := NetworkModeShow;
    ShowIcon := MyPcStatusIcon_LAN;
  end
  else
  if NetworkModeShow = MyNetworkModeShow_Group then
  begin
    ShowStr := NetworkModeShow + ': ' + DetailShow;
    ShowIcon := MyPcStatusIcon_Group;
  end
  else
  if NetworkModeShow = MyNetworkModeShow_ConnToPc then
  begin
    ShowStr := NetworkModeShow + ': ' + DetailShow;
    ShowIcon := MyPcStatusIcon_ConnToPc;
  end;

  LiNeworkMode := LvMyStatus.Items[ MyPcStatusItem_NetworkMode ];
  SetShowStr( LiNeworkMode, ShowStr );
  SetShowIcon( LiNeworkMode, ShowIcon );
end;

{ TMyPcStatusData }

constructor TMyPcStatusData.Create;
begin
  IsShowError := False;
end;

{ TPlNetworkNotPcShowInfo }

procedure TPlNetworkNotPcShowInfo.Update;
begin
  inherited;

    // ����ʾ�޷�����
  if plNetworkNotConn.Visible then
    Exit;

  frmMainForm.PcNetworkConn.ActivePage := frmMainForm.tsNoPc;
  plNetworkNotConn.Visible := True;
end;

{ TNetworkStatusClearFace }

procedure TNetworkStatusClearFace.Update;
begin
  inherited;
  VstNetworkStatus.Clear;
end;

{ TPlNetworkGroupNotExist }

procedure TPlNetworkGroupNotExist.SetGroupName(_GroupName: string);
begin
  GroupName := _GroupName;
end;

procedure TPlNetworkGroupNotExist.Update;
begin
  inherited;

  pcNetworkWarnning.ActivePage := frmMainForm.tsCannotConn;
  pcRemoteWarnning.ActivePage := frmMainForm.tsGroupNotEixst;
  frmMainForm.lbGroupNotExist.Caption := Format( GroupNotExist_ShowStr, [GroupName] );
  GroupError_Name := GroupName;
  plNetworkNotConn.Visible := True;
end;

{ TPlNetworkGroupPasswordError }

procedure TPlNetworkGroupPasswordError.SetGroupName(_GroupName: string);
begin
  GroupName := _GroupName;
end;

procedure TPlNetworkGroupPasswordError.Update;
begin
  inherited;

  pcNetworkWarnning.ActivePage := frmMainForm.tsCannotConn;
  pcRemoteWarnning.ActivePage := frmMainForm.tsGroupPasswordError;
  frmMainForm.lbGroupPassword.Caption := Format( GroupPasswordError_ShowStr, [GroupName] );
  GroupError_Name := GroupName;
  plNetworkNotConn.Visible := True;
end;

{ TPlNetworkConnPcIpError }

procedure TPlNetworkConnPcIpError.SetConnPcInfo(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TPlNetworkConnPcIpError.Update;
begin
  inherited;

  pcNetworkWarnning.ActivePage := frmMainForm.tsCannotConn;
  pcRemoteWarnning.ActivePage := frmMainForm.tsIpError;
  frmMainForm.lbIpError.Caption := Format( ConnPcIpError_ShowStr, [Domain] );
  ConnPcError_Domain := Domain;
  ConnPcError_Port := Port;
  plNetworkNotConn.Visible := True;
end;

{ TPlNetworkConnPcSecurityNumberError }

procedure TPlNetworkConnPcSecurityNumberError.SetConnPcInfo(_Domain,
  _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TPlNetworkConnPcSecurityNumberError.Update;
begin
  inherited;

  pcNetworkWarnning.ActivePage := frmMainForm.tsCannotConn;
  pcRemoteWarnning.ActivePage := frmMainForm.tsSecurityIDError;
  frmMainForm.lbConnPcSecurityID.Caption := Format( ConnPcSecurityIDError_ShowStr, [Domain + ':' + Port] );
  ConnPcError_Domain := Domain;
  ConnPcError_Port := Port;
  plNetworkNotConn.Visible := True;
end;

{ TPlNetworkConnShowInfo }

procedure TPlNetworkConnPcError.SetConnPcInfo(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TPlNetworkConnPcError.Update;
begin
  inherited;

  if plNetworkNotConn.Visible then
    Exit;

  pcNetworkWarnning.ActivePage := frmMainForm.tsCannotConn;
  pcRemoteWarnning.ActivePage := frmMainForm.tsNotConnPc;
  frmMainForm.lbNotConnPcTitle.Caption := Format( ConnPcNotConn_ShowStr, [Domain + ':' + Port] );
  ConnPcError_Domain := Domain;
  ConnPcError_Port := Port;
  plNetworkNotConn.Visible := True;
end;

{ TAdvanceSecurityIDError }

procedure TAdvanceSecurityIDError.Update;
begin
  frmSetting.ShowResetCloudID;
end;

{ TSbNetworkSecuritySetFace }

procedure TSbNetworkSecuritySetFace.SetIsSecurity(_IsSecurity: Boolean);
begin
  IsSecurity := _IsSecurity;
end;

procedure TSbNetworkSecuritySetFace.Update;
var
  sbNetwork : TRzGlyphStatus;
  ShowStr, SecurityStr : string;
  p : Integer;
begin
  sbNetwork := frmMainForm.sbNetworkMode;
  ShowStr := sbNetwork.Caption;
  SecurityStr := ' ( Security )';

  if IsSecurity then
  begin
    if Pos( SecurityStr, ShowStr ) <= 0 then
      ShowStr := ShowStr + SecurityStr;
  end
  else
  begin
    p := Pos( SecurityStr, ShowStr );
    if p > 0 then
      ShowStr := Copy( ShowStr, 1, p - 1 );
  end;

  sbNetwork.Caption := ShowStr;
end;

{ TPlNetworkPcEditonNotMatchShowInfo }

procedure TPlNetworkPcOldEditionShowInfo.Update;
begin
  inherited;

  frmMainForm.PcNetworkConn.ActivePage := frmMainForm.tsNoEdition;
  frmMainForm.pcEditionNotMatch.ActivePage := frmMainForm.tsNewEdition;
  plNetworkNotConn.Visible := True;
end;

{ TConnEditonData }

constructor TConnEditonData.Create(_Ip: string);
begin
  Ip := _Ip;
end;

{ TConnEditionChangeFace }

procedure TConnEditionChangeFace.Update;
begin
  LvComputer := frmEditonNotMatch.lvComputer;
end;

{ TConnEditionWriteFace }

constructor TConnEditionWriteFace.Create(_Ip: string);
begin
  Ip := _Ip;
end;

function TConnEditionWriteFace.FindConnItem: Boolean;
var
  i: Integer;
  SelectData : TConnEditonData;
begin
  Result := False;
  for i := 0 to LvComputer.Items.Count - 1 do
  begin
    SelectData := LvComputer.Items[i].Data;
    if SelectData.Ip = Ip then
    begin
      Result := True;
      ItemIndex := i;
      ConnItem := LvComputer.Items[i];
      ItemData := SelectData;
      Break;
    end;
  end;
end;

{ TConnEditionAddFace }

procedure TConnEditionAddFace.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TConnEditionAddFace.Update;
begin
  inherited;

  if FindConnItem then
    Exit;

  ConnItem := LvComputer.Items.Add;
  ConnItem.Caption := Ip;
  ConnItem.SubItems.Add( PcName );
  ConnItem.ImageIndex := 1;

  ItemData := TConnEditonData.Create( Ip );
  ConnItem.Data := ItemData;
end;

{ TConnEditionRemoveFace }

procedure TConnEditionRemoveFace.Update;
begin
  inherited;
  if not FindConnItem then
    Exit;
  LvComputer.Items.Delete( ItemIndex );

  if LvComputer.Items.Count > 0 then
    Exit;

    // ȫ�����������ɹ�
  if frmMainForm.plNetworkNotConn.Visible and
     ( frmMainForm.PcNetworkConn.ActivePage = frmMainForm.tsNoEdition )
  then
    frmMainForm.plNetworkNotConn.Visible := False;
end;

{ TConnEditionClearFace }

procedure TConnEditionClearFace.Update;
begin
  inherited;
  LvComputer.Clear;
end;

{ TPlNetworkPcNewEditionShowInfo }

procedure TPlNetworkPcNewEditionShowInfo.Update;
begin
  inherited;

  frmMainForm.PcNetworkConn.ActivePage := frmMainForm.tsNoEdition;
  frmMainForm.pcEditionNotMatch.ActivePage := frmMainForm.tsOldEdition;
  plNetworkNotConn.Visible := True;
end;


{ TPlNetworkNoPcHideInfo }

procedure TPlNetworkNoPcHideInfo.Update;
begin
  inherited;

    // �����ذ汾
  if frmMainForm.PcNetworkConn.ActivePage = frmMainForm.tsNoEdition then
    Exit;

  plNetworkNotConn.Visible := False;
end;

{ TMyPcStatusUpnpChangeFace }

function TMyPcStatusUpnpChangeFace.FindUpnpItem: Boolean;
begin
  Result := getIsExistItem( MyPcStatusItem_UpnpServer ) and
            getIsExistItem( MyPcStatusItem_UpnpPortMap );

  LiUpnpServer := LvMyStatus.Items[ MyPcStatusItem_UpnpServer ];
  LiUpnpPortMap := LvMyStatus.Items[ MyPcStatusItem_UpnpPortMap ];
end;

{ TMyPcStatusUpnpServerFace }

constructor TMyPcStatusUpnpServerFace.Create(_IsExist: Boolean;
  _ControlUrl: string);
begin
  IsExist := _IsExist;
  ControlUrl := _ControlUrl;
end;

procedure TMyPcStatusUpnpServerFace.Update;
var
  ShowStr : string;
begin
  inherited;

    // �Ҳ��� Item
  if not FindUpnpItem then
    Exit;

    // ��ʾ Upnp ��������Ϣ
  if IsExist then
    ShowStr := 'Yes. Control Url: ' + ControlUrl
  else
    ShowStr := 'No.';

    // ������ʾ
  SetShowStr( LiUpnpServer, ShowStr );
end;

{ TMyPcStatusUpnpPortMapFace }

constructor TMyPcStatusUpnpPortMapFace.Create(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TMyPcStatusUpnpPortMapFace.Update;
var
  ShowStr : string;
begin
  inherited;

    // �Ҳ��� Item
  if not FindUpnpItem then
    Exit;

    // ��ʾ״̬
  if IsCompleted then
    ShowStr := MyPcStatusShow_Success
  else
    ShowStr := MyPcStatusShow_Failure;

    // ����
  SetShowStr( LiUpnpPortMap, ShowStr );
end;


end.
