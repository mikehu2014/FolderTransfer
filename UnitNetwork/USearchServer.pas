unit USearchServer;

interface

uses classes, UMyNetPcInfo, UModelUtil, Sockets, UMyTcp, SysUtils, DateUtils, Generics.Collections,
     IdHTTP, UMyUrl, SyncObjs, UPortMap, UFormBroadcast, UMyDebug, uDebugLock;

type

{$Region ' �������� ���� ' }

    // ������· ����
  TSearchServerRun = class
  public
    procedure Update;virtual;abstract;
    function getRunNetworkStatus : string;virtual;
  end;

  {$Region ' ������ ' }

    // ��ʱ ����δ���ӵ� Pc
  TLanSearchPcThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SearchPcHandle;
  end;

    // ���� ������ �ķ�����
  TLanSearchServer = class( TSearchServerRun )
  private
    BindSocketReuslt : string;
    LanSearchPcThread : TLanSearchPcThread;
  private
    SearchPcID : string;
  public
    constructor Create;
    procedure SetSearchPcID( _SearchPcID : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure SendBroadcast;
    procedure ConnectSearchPc;
  end;

  {$EndRegion}

  {$Region ' Group ���� ' }

    // Standard Pc Info
  TStandardPcInfo = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
    InternetIp, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;
  TStandardPcPair = TPair< string , TStandardPcInfo >;
  TStandardPcHash = class(TStringDictionary< TStandardPcInfo >);

      // ���͹�˾������
  TFindStandardNetworkHttp = class
  private
    CompanyName, Password : string;
    Cmd : string;
  public
    constructor Create( _CompanyName, _Password : string );
    procedure SetCmd( _Cmd : string );
    function get : string;
  end;

    // ��ʱ�������������
    // ��ʱ�����Ƿ����δ���ӵĵ�¼Pc
  TStandardHearBeatThread = class( TDebugThread )
  private
    AccountName, Password : string;
    LastServerNumber : Integer;
  public
    constructor Create;
    procedure SetAccountInfo( _AccountName, _Password : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SendHeartBeat;
    procedure CheckAccountPc;
  end;

    // �ҵ� һ�� Standard Pc
  TStandardPcAddHanlde = class
  private
    StandardPcInfo : TStandardPcInfo;
  public
    constructor Create( _StandardPcInfo : TStandardPcInfo );
    procedure Update;
  end;

    // ���� Account Name �ķ�����
  TGroupSearchServer = class( TSearchServerRun )
  private
    GroupName, Password : string;
  private
    StandardPcMsg : string;
    StandardPcHash : TStandardPcHash;
  private
    RunNetworkStatus : string;
    StandardHearBetThread : TStandardHearBeatThread;
  public
    constructor Create;
    procedure SetGroupInfo( _GroupName, _Password : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    function LoginAccount : Boolean;
    procedure FindStandardPcHash;
    procedure PingStandardPcHash;
    procedure LogoutAccount;
  private
    procedure PasswordError;
    procedure AccountNameNotExit;
  public
    function getRunNetworkStatus : string;override;
  end;

  {$EndRegion}

  {$Region ' ֱ������ ' }

    // ��ʱ �������� ����ָ�� Pc
  TRestartConnectToPcThread = class( TDebugThread )
  private
    StartTime : TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure RunRestart;
    procedure ShowRemainTime;
  end;

    // ���� Internet Pc �ķ�����
  TConnToPcSearchServer = class( TSearchServerRun )
  private
    Domain : string;
    Ip, Port : string;
  private
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
    RestartConnectToPcThread : TRestartConnectToPcThread;
  private
    ServerPcID, ServerPcName : string;
    ServerLanIp, ServerLanPort : string;
    ServerInternetIp, ServerInternetPort : string;
  private
    RunNetworkStatus : string;
  public
    constructor Create;
    procedure SetConnPcInfo( _Domain, _Port : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure PingMyPc;
    function FindIp: Boolean;
    function ConnTargetPc : Boolean;
    function CheckCloudIDNumber : Boolean;
    function getIsConnectToCS : Boolean;
    procedure NotConnServer;
    procedure RevServerPcInfo;
    procedure SendMyPcInfo;
    procedure WaitServerNotify;
  private
    procedure CloudIDNumberError;
    procedure WaitToConn( WaitTime : Integer );
  public
    function getRunNetworkStatus : string;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ���� Master �߳� ' }

    // ���ӷ���������
  TConnServerHandle = class
  private
    ServerIp, ServerPort : string;
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _ServerIp, _ServerPort : string );
    procedure Update;
  end;

    // ȷ��������Ϣû�г�ͻ�� ��ͻ���޸�
  TConfirmNetworkInfoHandle = class
  private
    PortMapping : TPortMapping;
  public
    constructor Create( _PortMapping : TPortMapping );
    procedure Upate;
  private
    procedure ConfirmLanIp;
    procedure ConfirmLanPort;
    procedure ConfirmInternetIp;
    procedure ConfirmInternetPort;
    procedure ConfirmInternetPortMap;
  private      // ��ȡ Internet Ip �Ĳ�ͬ���
    function FindRouterInternetIp: string;
    function FindWebInternetIp: string;
  end;

    // ��������������
  TSearchServerRunCreate = class
  public
    function get : TSearchServerRun;
  public
    function getLan : TLanSearchServer;
    function getGroup : TGroupSearchServer;
    function getConnToPc : TConnToPcSearchServer;
  end;

      // ��ʱ�� Api
  MySearchMasterTimerApi = class
  public
    class procedure CheckRestartNetwork;
    class procedure MakePortMapping;
    class procedure RefreshConnecting;
  end;

    // ���� ������
  TMasterThread = class( TDebugThread )
  private
    PortMapping : TPortMapping;
    SearchServerRun : TSearchServerRun; // ��������
    RunNetworkStatus : string; // ��������״̬
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure ResetNetworkPc;
    procedure RunNetwork;
    procedure WaitPingMsg;
    procedure BeServer;
    procedure WaitServerNotify;
    function ConnServer: Boolean;
    procedure StopNetwork;
  private
    procedure WaitMaster( WaitTime : Integer );
  end;

    // ��������������
  TMySearchMasterHandler = class
  public
    IsRun, IsConnecting : Boolean;
    MasterThread : TMasterThread;
  public
    constructor Create;
    procedure StartRun;
    procedure StopRun;
  public
    function getIsRun : Boolean;
    procedure RestartNetwork;
  end;

{$EndRegion}

const
  WaitTime_Ping = 5;
  WaitTime_ServerNofity = 20;
  WaitTime_AdvanceBusy = 5;
  WaitTime_AdvanceNotServer = 5;

const
  RunNetworkStatus_OK = 'OK';
  RunNetworkStatus_GroupNotExist = 'GroupNotExist';
  RunNetworkStatus_GroupPassowrdError = 'GroupPassowrdError';
  RunNetworkStatus_IpError = 'IpError';
  RunNetworkStatus_NotConn = 'NotConn';
  RunNetworkStatus_SecurityError = 'SecurityError';

const
  MsgType_Ping : string = 'Ping';
  MsgType_BackPing : string = 'BackPing';

    // Standard Network Http ��������
  Cmd_Login = 'login';
  Cmd_HeartBeat = 'heartbeat';
  Cmd_ReadLoginNumber = 'readloginnumber';
  Cmd_AddServerNumber = 'addservernumber';
  Cmd_ReadServerNumber = 'readservernumber';
  Cmd_Logout = 'logout';

    // Standard Network Http ����
  HttpReq_CompanyName = 'CompanyName';
  HttpReq_Password = 'Password';
  HttpReq_PcID = 'PcID';
  HttpReq_PcName = 'PcName';
  HttpReq_LanIp = 'LanIp';
  HttpReq_LanPort = 'LanPort';
  HttpReq_InternetIp = 'InternetIp';
  HttpReq_InternetPort = 'InternetPort';
  HttpReq_CloudIDNumber = 'CloudIDNumber';

    // Login ���
  LoginResult_ConnError = 'ConnError';
  LoginResult_CompanyNotFind = 'CompanyNotFind';
  LoginResult_PasswordError = 'PasswordError';
  LoginResult_OK = 'OK';

    // Resutl Split
  Split_Result = '<Result/>';
  Split_Pc = '<Pc/>';
  Split_PcPro = '<PcPro/>';

  PcProCount = 6;
  PcPro_PcID = 0;
  PcPro_PcName = 1;
  PcPro_LanIp = 2;
  PcPro_LanPort = 3;
  PcPro_InternetIp = 4;
  PcPro_InternetPort = 5;

  ShowForm_CompanyNameError : string = 'Account name "%s" does not exist.';
  ShowForm_PasswordError : string = 'Password is incorrect.Please input password again.';
  ShowForm_ParseError : string = 'Can not parse "%s" to ip address.';


  WaitTime_PortMap = 10; // ����

  AdvanceMsg_NotServer = 'NotServer'; // �Ƿ�����

const
  CloudIdNumber_Empty = '<Empty>';
  CloudIdNumber_Split = '<Split>';
  CloudIdNumber_SplitCount = 3;
  CloudIdNumber_Random = 0;
  CloudIdNumber_SecurityID = 1;
  CloudIdNumber_DateTime = 2;

var
  MySearchMasterHandler : TMySearchMasterHandler;

implementation

uses UNetworkControl, UNetworkFace, UMyUtil, UMyMaster, UMyClient, UMyServer,
     USettingInfo, uDebug, UNetPcInfoXml, UChangeInfo, UMyShareApiInfo,
     USendThread, UReceiveThread, UShareDownThread, UShareThread, UMyTimerThread;

{ TSearchServerThread }

procedure TMasterThread.BeServer;
var
  ActivatePcList : TStringList;
  i: Integer;
  MasterConnClientInfo : TMasterConnClientInfo;
begin
  if RunNetworkStatus <> RunNetworkStatus_OK then
    Exit;

    // �������, ��������
    // ������ Server
    // ������ �Ƚ�ֵ���
  if not MySearchMasterHandler.getIsRun or
     MyClient.IsConnServer or
     ( MasterInfo.MaxPcID <> PcInfo.PcID )
  then
    Exit;

    // ��Ϊ������
  MyServer.BeServer;

    // ֪ͨ�Ѽ����Pc ���� Master
  ActivatePcList := MyNetPcInfoReadUtil.ReadActivatePcList;
  for i := 0 to ActivatePcList.Count - 1 do
  begin
    MasterConnClientInfo := TMasterConnClientInfo.Create( ActivatePcList[i] );
    MyMasterSendHandler.AddMasterSend( MasterConnClientInfo );
  end;
  if ActivatePcList.Count <= 1 then // ֻ�б���������ʾû������ Pc
    NetworkErrorStatusApi.ShowNoPc;
  ActivatePcList.Free;
end;

function TMasterThread.ConnServer: Boolean;
var
  ServerPcID, ServerIp, ServerPort : string;
  ConnServerHandle : TConnServerHandle;
begin
  Result := False;

    // ����
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // �������������
  if RunNetworkStatus <> RunNetworkStatus_OK then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetNotConnected;
    Exit;
  end;

    // ���δ���ӣ�������
  if not MyClient.IsConnServer then
  begin
      // ��ȡ Master ��Ϣ
    ServerPcID := MasterInfo.MaxPcID;
    ServerIp := MyNetPcInfoReadUtil.ReadIp( ServerPcID );
    ServerPort := MyNetPcInfoReadUtil.ReadPort( ServerPcID );

      // ���� Master
    ConnServerHandle := TConnServerHandle.Create( ServerIp, ServerPort );
    ConnServerHandle.Update;
    ConnServerHandle.Free;
  end;

    // ���ӳɹ�����ʾ������
  if MyClient.IsConnServer then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetConnected;
    MyShareShowRootItemApi.CheckExistShare; // ����Ƿ���ڹ���
  end;

    // ���ӵĹ����жϿ�����
  if not MySearchMasterHandler.getIsRun then
    Result := False;
end;

constructor TMasterThread.Create;
begin
  inherited Create;
end;

procedure TMasterThread.StopNetwork;
begin
    // �������еĴ���
  MyFileSendHandler.IsSendRun := False;
  MyReceiveFileHandler.IsReceiveRun := False;
  MyShareDownHandler.IsDownRun := False;
  MyShareFileHandler.IsShareRun := False;

    // �Ͽ��ͻ�������
  MyClient.ClientLostConn;

    // �Ͽ�����������
  MyServer.ServerLostConn;

    // ֹͣ��ʱ��������
  MyTimerHandler.RemoveTimer( HandleType_RestartNetwork );

    // ֹͣ��������
  SearchServerRun.Free;

    // ֹͣ�����˿�
  MyListener.StopListen;

    // ֹͣ�˿�ӳ��
  MyTimerHandler.RemoveTimer( HandleType_PortMapping );
  PortMapping.RemoveMapping( PcInfo.InternetPort );
  PortMapping.Free;

    // ��ʾδ����
  NetworkConnStatusShowApi.SetNotConnected;
end;

destructor TMasterThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TMasterThread.Execute;
var
  IsConnectedServer : Boolean;
begin
  while not Terminated do
  begin
      // �������� Pc ��Ϣ
    ResetNetworkPc;

      // ��ʱˢ�� Connecting
    MyTimerHandler.AddTimer( HandleType_RefreshConnecting, 1 );

    try   // ��������
      RunNetwork;
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Run Network', e.Message );
    end;

      // �ȴ� ������ Pc ������Ϣ
    WaitPingMsg;

      // ��Ϊ������
    BeServer;

      // �ȴ� Server ֪ͨ
    WaitServerNotify;

      // ���ӷ�����
    IsConnectedServer := ConnServer;

      // ɾ����ʱˢ��
    MyTimerHandler.RemoveTimer( HandleType_RefreshConnecting );

      // ���ӷ������ɹ�, �����߳�
    if IsConnectedServer then
      Suspend;

    try   // ֹͣ��������
      StopNetwork;
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Stop Network', e.Message );
    end;

  end;
  inherited;
end;

procedure TMasterThread.RunNetwork;
var
  ConfirmNetworkInfoHandle : TConfirmNetworkInfoHandle;
  SearchServerRunCreate : TSearchServerRunCreate;
  IsRemoteCompleted : Boolean;
begin
  DebugLock.Debug( 'Run Network' );

    // ��������
  MySearchMasterHandler.IsConnecting := True;

    // ��ʾ��������
  NetworkConnStatusShowApi.SetConnecting;

    // ���Ըı�����״̬
  NetworkConnStatusShowApi.SetCanChangeNetwork;

    // �˿�ӳ��
  PortMapping := TPortMapping.Create;
  ConfirmNetworkInfoHandle := TConfirmNetworkInfoHandle.Create( PortMapping );
  ConfirmNetworkInfoHandle.Upate;
  ConfirmNetworkInfoHandle.Free;
  PortMapping.AddMapping( PcInfo.LanIp, PcInfo.InternetPort );
  MyTimerHandler.AddTimer( HandleType_PortMapping, 600 );

    // ��ʼ����
  MyListener.StartListenLan( PcInfo.LanPort );
  MyListener.StartListenInternet( PcInfo.InternetPort );

    // ��ʾ��Ϣ���ҵ�״̬
  MyNetworkStatusApi.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  MyNetworkStatusApi.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );

    // ��������
  SearchServerRunCreate := TSearchServerRunCreate.Create;
  SearchServerRun := SearchServerRunCreate.get;
  SearchServerRunCreate.Free;
  SearchServerRun.Update;
  RunNetworkStatus := SearchServerRun.getRunNetworkStatus;

    // ��ʱ�����޷����ӵ�����, ʮ����
  if PcInfo.LanIp = '127.0.0.1' then
    MyTimerHandler.AddTimer( HandleType_RestartNetwork, 10 )
  else
    MyTimerHandler.AddTimer( HandleType_RestartNetwork, 600 );
end;

procedure TMasterThread.ResetNetworkPc;
var
  NetworkPcResetHandle : TNetworkPcResetHandle;
begin
    // ���� Pc ��Ϣ
  NetworkPcResetHandle := TNetworkPcResetHandle.Create;
  NetworkPcResetHandle.Update;
  NetworkPcResetHandle.Free;

    // ���� Master ��Ϣ
  MasterInfo.ResetMasterPc;
end;

procedure TMasterThread.WaitMaster(WaitTime: Integer);
var
  StartTime : TDateTime;
begin
  if RunNetworkStatus <> RunNetworkStatus_OK then
    Exit;

  StartTime := Now;
  while MySearchMasterHandler.getIsRun and not MyClient.IsConnServer do
  begin
      // �ȴ�ʱ��������� û�з��� �� ��������
    if ( SecondsBetween( Now, StartTime ) >= WaitTime ) and
       not MyMasterSendHandler.getIsRuning and
       not MyMasterReceiveHanlder.getIsRuning
    then
      Break;

    Sleep( 100 );
  end;
end;

procedure TMasterThread.WaitPingMsg;
begin
    // �ȴ� ���������� Pc ������Ϣ
  WaitMaster( WaitTime_Ping );
end;

procedure TMasterThread.WaitServerNotify;
begin
    // �ȴ� Master ����
  WaitMaster( WaitTime_ServerNofity );
end;


{ TLanSearchServer }

procedure TLanSearchServer.ConnectSearchPc;
var
  SearchPcName, SearchIp, SearchPort : string;
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  if SearchPcID = '' then
    Exit;

   // ��ȡ Pc ��Ϣ
  SearchPcName := MyNetPcInfoReadUtil.ReadName( SearchPcID );
  SearchIp := MyNetPcInfoReadUtil.ReadIp( SearchPcID );
  SearchPort := MyNetPcInfoReadUtil.ReadPort( SearchPcID );

  if ( SearchIp = '' ) or ( SearchPort = '' ) then
    Exit;

    // ��� Pc ��Ϣ
  NetworkPcApi.AddItem( SearchPcID, SearchPcName );

    // ���� Ping
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( SearchPcID );
  MasterSendLanPingInfo.SetSocketInfo( SearchIp, SearchPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

constructor TLanSearchServer.Create;
begin
    // ���� �㲥
  BindSocketReuslt := frmBroadcast.BindBroadcastSocket;
  frmBroadcast.OnRevMsgEvent := MyMasterReceiveHanlder.ReceiveBroadcast;

    // ��ʱ�����߳�
  LanSearchPcThread := TLanSearchPcThread.Create;
  LanSearchPcThread.Resume;
end;

destructor TLanSearchServer.Destroy;
begin
  LanSearchPcThread.Free;
  frmBroadcast.OnRevMsgEvent := nil;
  frmBroadcast.CloseBroadcastSocket; // �ع㲥
  inherited;
end;

procedure TLanSearchServer.SendBroadcast;
var
  CloudIDNumMD5 : string;
  LanBroadcastMsg : TLanBroadcastMsg;
  MsgInfo : TMsgInfo;
  MsgType, MsgStr, Msg : string;
begin
  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // ��ȡ �㲥��Ϣ
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_StartLan );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // �㲥��Ϣ�İ汾
  MsgType := IntToStr( ConnEdition_Now );

    // ��װ �㲥��Ϣ
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // ���� �㲥��Ϣ
  frmBroadcast.SendMsg( Msg );
end;

procedure TLanSearchServer.SetSearchPcID(_SearchPcID: string);
begin
  SearchPcID := _SearchPcID;
end;

procedure TLanSearchServer.Update;
begin
  DebugLock.Debug( 'Lan Search Server' );

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.LanConnections;
  MyNetworkStatusApi.SetBroadcastPort( IntToStr( UdpPort_Broadcast ), BindSocketReuslt );

    // ���͹㲥��Ϣ
  SendBroadcast;

    // ��������� Pc
  ConnectSearchPc;
end;

{ TStandSearchServer }

procedure TGroupSearchServer.AccountNameNotExit;
var
  ErrorStr : string;
  StandardAccountError : TStandardAccountError;
begin
  RunNetworkStatus := RunNetworkStatus_GroupNotExist;

    // ��ʾ��ʾ��
  ErrorStr := Format( ShowForm_CompanyNameError, [GroupName] );
  MyMessageBox.ShowError( ErrorStr );

    // ����������Ϣ
  NetworkModeApi.AccountNotExist( GroupName, Password );

    // ��������ʾ
  NetworkErrorStatusApi.ShowGroupNotExist( GroupName );
end;

constructor TGroupSearchServer.Create;
begin
  StandardPcHash := TStandardPcHash.Create;
  StandardHearBetThread := TStandardHearBeatThread.Create;
end;

destructor TGroupSearchServer.Destroy;
begin
  StandardHearBetThread.Free;
  StandardPcHash.Free;
  LogoutAccount; // Logout
  inherited;
end;

procedure TGroupSearchServer.FindStandardPcHash;
var
  PcStrList : TStringList;
  PcProStrList : TStringList;
  i : Integer;
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  StandardPcInfo : TStandardPcInfo;
begin
  PcStrList := MySplitStr.getList( StandardPcMsg, Split_Pc );
  for i := 0 to PcStrList.Count - 1 do
  begin
    PcProStrList := MySplitStr.getList( PcStrList[i], Split_PcPro );
    if PcProStrList.Count >= PcProCount then
    begin
      PcID := PcProStrList[ PcPro_PcID ];
      PcName := PcProStrList[ PcPro_PcName ];
      LanIp := PcProStrList[ PcPro_LanIp ];
      LanPort := PcProStrList[ PcPro_LanPort ];
      InternetIp := PcProStrList[ PcPro_InternetIp ];
      InternetPort := PcProStrList[ PcPro_InternetPort ];

      StandardPcInfo := TStandardPcInfo.Create( PcID, PcName );
      StandardPcInfo.SetLanSocket( LanIp, LanPort );
      StandardPcInfo.SetInternetSocket( InternetIp, InternetPort );

      StandardPcHash.AddOrSetValue( PcID, StandardPcInfo );
    end;
    PcProStrList.Free;
  end;
  PcStrList.Free;
end;

function TGroupSearchServer.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus;
end;

function TGroupSearchServer.LoginAccount: Boolean;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
  HttpStr, HttpResult : string;
  HttpStrList : TStringList;
begin
  Result := False;

    // ��¼
  DebugLock.Debug( 'Login Group' );
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( GroupName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Login );
  HttpStr := FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;

    // �Ƿ��¼Զ������ʧ��
  RunNetworkStatus := RunNetworkStatus_OK;

    // �������� �Ͽ�
  if HttpStr = LoginResult_ConnError then
  else  // �ʺŲ�����
  if HttpStr = LoginResult_CompanyNotFind then
    AccountNameNotExit
  else   // �������
  if HttpStr = LoginResult_PasswordError then
    PasswordError
  else
  begin   // ��¼�ɹ�
    HttpStrList := MySplitStr.getList( HttpStr, Split_Result );
    if HttpStrList.Count > 0 then
      HttpResult := HttpStrList[0];
    if HttpResult = LoginResult_OK then
    begin
      if HttpStrList.Count > 1 then
        StandardPcMsg := HttpStrList[1];
      Result := True;
    end;
    HttpStrList.Free;
  end;
end;

procedure TGroupSearchServer.LogoutAccount;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // Logout
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( GroupName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Logout );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TGroupSearchServer.PasswordError;
var
  StandardPasswordError : TStandardPasswordError;
begin
  RunNetworkStatus := RunNetworkStatus_GroupPassowrdError;

    // ��ʾ��ʾ��
  MyMessageBox.ShowError( ShowForm_PasswordError );

    // ������д Group ��Ϣ
  NetworkModeApi.PasswordError( GroupName );

    // ��������ʾ
  NetworkErrorStatusApi.ShowGroupPasswordError( GroupName );
end;

procedure TGroupSearchServer.PingStandardPcHash;
var
  p : TStandardPcPair;
  StandardPcAddHanlde : TStandardPcAddHanlde;
begin
  DebugLock.Debug( 'Ping Group Pc' );
  for p in StandardPcHash do
  begin
    StandardPcAddHanlde := TStandardPcAddHanlde.Create( p.Value );
    StandardPcAddHanlde.Update;
    StandardPcAddHanlde.Free;
  end;
end;

procedure TGroupSearchServer.SetGroupInfo(_GroupName, _Password: string);
begin
  GroupName := _GroupName;
  Password := _Password;
end;

procedure TGroupSearchServer.Update;
begin
  DebugLock.Debug( 'Group Search Server' );

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.GroupConnections( GroupName );
  MyNetworkStatusApi.SetBroadcastDisable;

    // ��¼ Group �Ƿ�ɹ�
  if LoginAccount then
  begin
    FindStandardPcHash;
    PingStandardPcHash;
    StandardHearBetThread.SetAccountInfo( GroupName, Password );
    StandardHearBetThread.Resume;
  end;
end;

{ TAdvanceSearchServer }

function TConnToPcSearchServer.CheckCloudIDNumber: Boolean;
var
  RandomNumber : string;
  CloudIdStr : string;
begin
    // ��ȡ�Է����͵������
  RandomNumber := MySocketUtil.RevJsonStr( TcpSocket );

    // ��ȡ������ Security ID
  CloudIdStr := CloudSafeSettingInfo.getCloudIDNumMD5;
  if CloudIdStr = '' then  // ��ֵ���������ַ�����
    CloudIdStr := CloudIdNumber_Empty;

    // ��Ϻͼ���
  CloudIdStr := RandomNumber + CloudIdNumber_Split + CloudIdStr;
  CloudIdStr := CloudIdStr + CloudIdNumber_Split + MyRegionUtil.ReadRemoteTimeStr( Now );
  CloudIdStr := MyEncrypt.EncodeStr( CloudIdStr );

    // ���� ID
  MySocketUtil.SendJsonStr( TcpSocket, 'CloudIdStr', CloudIdStr );

    // �����Ƿ����ӳɹ�
  Result := MySocketUtil.RevJsonBool( TcpSocket );
end;

procedure TConnToPcSearchServer.CloudIDNumberError;
var
  ShowError : string;
begin
    // ��ʾ����
  ShowError := 'Your Security ID Number and %s Security ID Number are not matched';
  ShowError := Format( ShowError, [Domain + ':' + Port] );
  MyMessageBox.ShowError( ShowError );

    // �������� Cloud ID
  NetworkModeApi.CloudIDError;

    // ��������ʾ
  NetworkErrorStatusApi.ShowSecurityError( Domain, Port );
end;

function TConnToPcSearchServer.ConnTargetPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  ConnPcID : string;
  IsBusy : Boolean;
  i: Integer;
begin
  DebugLock.Debug( 'Connect to Target Pc' );

  Result := False;
  IsBusy := False;

    // ���� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( Ip, Port );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    ConnPcID := MySocketUtil.RevJsonStr( TcpSocket );
    MySocketUtil.SendJsonStr( TcpSocket, 'IsSuccess', True );
    IsBusy := MySocketUtil.RevJsonBool( TcpSocket );
    if not IsBusy then
    begin
      MySocketUtil.SendJsonStr( TcpSocket, 'MsgType', MsgType_SearchServer_Advance );
      Result := True;
    end;
  end;
  MyTcpConn.Free;

    // Զ�̷�æ, 1 ���������
  if IsBusy then
  begin
    WaitToConn( WaitTime_AdvanceBusy );
    if MySearchMasterHandler.getIsRun then
      Result := ConnTargetPc;
  end;

    // Ŀ�� Pc ����
  if not Result then
  begin
    NetworkErrorStatusApi.ShowCannotConn( Domain, Port );  // ��ʾ �޷�����
    RestartConnectToPcThread.RunRestart;  // ������ʱ����
  end;
end;

constructor TConnToPcSearchServer.Create;
begin
  TcpSocket := TCustomIpClient.Create(nil);
  IsDestorySocket := True;
  RestartConnectToPcThread := TRestartConnectToPcThread.Create;
end;

destructor TConnToPcSearchServer.Destroy;
begin
  RestartConnectToPcThread.Free;
  if IsDestorySocket then
    TcpSocket.Free;
  inherited;
end;

function TConnToPcSearchServer.FindIp: Boolean;
var
  AdvanceDnsError : TAdvanceDnsError;
  ErrorStr : string;
begin
  DebugLock.Debug( 'Find Ip' );

  Result := True;
  if MyParseHost.IsIpStr( Domain ) then
  begin
    Ip := Domain;
    Exit;
  end;

  if MyParseHost.HostToIP( Domain, Ip ) then
    Exit;

    // ��������ʧ��
  NetworkErrorStatusApi.ShowIpError( Domain, Port ); // ��ʾʧ����Ϣ
  RestartConnectToPcThread.RunRestart;  // ��ʱ��������
  Result := False;
end;

function TConnToPcSearchServer.getIsConnectToCS: Boolean;
var
  RemoteIsServer : Boolean;
begin
  Result := False;

    // ���նԷ��Ƿ������
  RemoteIsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not RemoteIsServer then
    Exit;

    // ����
  Result := MyClient.ConnectServer( TcpSocket );
end;

function TConnToPcSearchServer.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus;
end;

procedure TConnToPcSearchServer.NotConnServer;
var
  ConnToPcSearchServer : TConnToPcSearchServer;
begin
  DebugLock.Debug( 'Target Pc No Server' );

    // 5 ���������
  WaitToConn( WaitTime_AdvanceNotServer );

    // �������
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // ������һ��
  ConnToPcSearchServer := TConnToPcSearchServer.Create;
  ConnToPcSearchServer.SetConnPcInfo( Domain, Port );
  ConnToPcSearchServer.Update;
  ConnToPcSearchServer.Free;
end;

procedure TConnToPcSearchServer.PingMyPc;
var
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( PcInfo.PcID );
  MasterSendLanPingInfo.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

procedure TConnToPcSearchServer.RevServerPcInfo;
begin
    // ��ȡ��Ϣ
  ServerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  ServerPcName := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanPort := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetPort := MySocketUtil.RevJsonStr( TcpSocket );

    // ��ӷ�������Ϣ
  NetworkPcApi.AddItem( ServerPcID, ServerPcName );
end;

procedure TConnToPcSearchServer.SendMyPcInfo;
begin
    // ������Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  MySocketUtil.SendJsonStr( TcpSocket, 'PcName', PcInfo.PcName );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanIp', PcInfo.LanIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanPort', PcInfo.LanPort );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetIp', PcInfo.InternetIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetPort', PcInfo.InternetPort );
end;

procedure TConnToPcSearchServer.SetConnPcInfo(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TConnToPcSearchServer.Update;
var
  IsConnectServer : Boolean;
begin
  DebugLock.Debug( 'Connect to pc Search Server' );

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.ConnToPcConnections( Domain + ':' + Port );
  MyNetworkStatusApi.SetBroadcastDisable;

    // Ĭ�ϳɹ�
  RunNetworkStatus := RunNetworkStatus_OK;

    // Ip ���ʹ���
  if not FindIp then
  begin
    RunNetworkStatus := RunNetworkStatus_IpError;
    Exit;
  end;

    // ���ӱ���
  PingMyPc;

    // �޷�����Զ�� Pc
  if not ConnTargetPc then
  begin
    RunNetworkStatus := RunNetworkStatus_NotConn;
    Exit;
  end;

    // ����Ƿ�ͬһ����
  if not CheckCloudIDNumber then
  begin
    RunNetworkStatus := RunNetworkStatus_SecurityError;
    CloudIDNumberError; // ������ͬ������
    Exit;
  end;

    // Ŀ���Ƿ������ӷ�����
  IsConnectServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsConnectServer then
  begin
    NotConnServer;  // �ȴ� 5 �������
    Exit;
  end;

    // ֱ�����ӵ�������
  if getIsConnectToCS then
  begin
    IsDestorySocket := False; // �˿������� CS
    Exit;
  end;

    // ���շ�������Ϣ
  RevServerPcInfo;

    // ���ͱ�����Ϣ���������������
  SendMyPcInfo;

    // �ȴ����������ӣ����������û�����ӣ����������ӷ�����
  WaitServerNotify;
end;

procedure TConnToPcSearchServer.WaitServerNotify;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
  StartTime : TDateTime;
begin
  StartTime := Now;
  while MySearchMasterHandler.getIsRun and not MyClient.IsConnServer do
  begin
      // �ȴ�ʱ�����
    if SecondsBetween( Now, StartTime ) >= WaitTime_ServerNofity then
      Break;

    Sleep( 100 );
  end;

    // ������� �� �����ӷ�����
  if not MySearchMasterHandler.getIsRun or MyClient.IsConnServer then
    Exit;

    // ���� Ping ����
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( ServerPcID );
  MasterSendInternetPingInfo.SetSocketInfo( ServerLanIp, ServerLanPort );
  MasterSendInternetPingInfo.SetInternetSocket( ServerInternetIp, ServerInternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

procedure TConnToPcSearchServer.WaitToConn(WaitTime: Integer);
var
  StartTime : TDateTime;
begin
  StartTime := Now;
  while MySearchMasterHandler.getIsRun do
  begin
      // �ȴ�ʱ�����
    if SecondsBetween( Now, StartTime ) >= WaitTime then
      Break;

    Sleep( 100 );
  end;
end;

{ TConnServerHandle }

constructor TConnServerHandle.Create(_ServerIp, _ServerPort: string);
begin
  ServerIp := _ServerIp;
  ServerPort := _ServerPort;
end;

procedure TConnServerHandle.Update;
var
  MyTcpConn : TMyTcpConn;
  IsConnectServer : Boolean;
begin
    // �����˿�
  TcpSocket := TCustomIpClient.Create( nil );

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ServerIp, ServerPort );
  MyTcpConn.SetConnType( ConnType_Server );
  IsConnectServer := MyTcpConn.Conn and MyClient.ConnectServer( TcpSocket );
  MyTcpConn.Free;

    // ����ʧ��
  if not IsConnectServer then
    TcpSocket.Free;
end;

{ TStandardPcInfo }

constructor TStandardPcInfo.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TStandardPcInfo.SetInternetSocket(_InternetIp, _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TStandardPcInfo.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

{ TFindStandardNetworkHttp }

constructor TFindStandardNetworkHttp.Create(_CompanyName, _Password: string);
begin
  CompanyName := _CompanyName;
  Password := _Password;
end;

function TFindStandardNetworkHttp.get: string;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  CloudIDNumber : string;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
    // ������Ϣ
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LanIp := PcInfo.LanIP;
  LanPort := PcInfo.LanPort;
  InternetIp := PcInfo.InternetIp;
  InternetPort := PcInfo.InternetPort;
  CloudIDNumber := CloudSafeSettingInfo.getCloudIDNumMD5;
  CloudIDNumber := MyEncrypt.EncodeMD5String( CloudIDNumber );

    // ��¼����ȡ���� Pc ��Ϣ
  params := TStringList.Create;
  params.Add( HttpReq_CompanyName + '=' + CompanyName );
  params.Add( HttpReq_Password + '=' + Password );
  params.Add( HttpReq_PcID + '=' + PcID );
  params.Add( HttpReq_PcName + '=' + PcName );
  params.Add( HttpReq_LanIp + '=' + LanIp );
  params.Add( HttpReq_LanPort + '=' + LanPort );
  params.Add( HttpReq_InternetIp + '=' + InternetIp );
  params.Add( HttpReq_InternetPort + '=' + InternetPort );
  params.Add( HttpReq_CloudIDNumber + '=' + CloudIDNumber );

  idhttp := TIdHTTP.Create(nil);
  idhttp.ConnectTimeout := 30000;
  idhttp.ReadTimeout := 30000;
  try
    Result := idhttp.Post( MyUrl.getGroupPcList + '?cmd=' + Cmd, params );
  except
    Result := LoginResult_ConnError;
  end;
  idhttp.Free;

  params.free;
end;

procedure TFindStandardNetworkHttp.SetCmd(_Cmd: string);
begin
  Cmd := _Cmd;
end;

{ TStandardHearBetThread }

procedure TStandardHearBeatThread.CheckAccountPc;
var
  Cmd : string;
  ServerNumber : Integer;
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // ���� �� Server
  if not MyServer.IsBeServer then
    Exit;

    // ���пͻ�������
  if MyServer.ClientCount > 1 then
    Exit;

    // �Ƿ��һ��
  if LastServerNumber = -1 then
    Cmd := Cmd_AddServerNumber
  else
    Cmd := Cmd_ReadServerNumber;

    // Login Number
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd );
  ServerNumber := StrToIntDef( FindStandardNetworkHttp.get, 0 );
  FindStandardNetworkHttp.Free;

    // ��һ��
  if LastServerNumber = -1 then
  begin
    LastServerNumber := ServerNumber;
    Exit;
  end;

    // ���ϴ�����ͬ
  if LastServerNumber = ServerNumber then
    Exit;

    // ��������
  MySearchMasterHandler.RestartNetwork;
end;

constructor TStandardHearBeatThread.Create;
begin
  inherited Create;
  LastServerNumber := -1;
end;

destructor TStandardHearBeatThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TStandardHearBeatThread.Execute;
var
  StartHearBeat, StartCheckAccount : TDateTime;
begin
  StartHearBeat := Now;
  StartCheckAccount := 0;
  while not Terminated do
  begin
      // 5 ���� ����һ������
    if MinutesBetween( Now, StartHearBeat ) >= 5 then
    begin
      SendHeartBeat;
      StartHearBeat := Now;
    end;
      // 20 ���� ���һ���ʺ�
    if ( SecondsBetween( Now, StartCheckAccount ) >= 20 ) or
       ( LastServerNumber = -1 ) then
    begin
      CheckAccountPc;
      StartCheckAccount := Now;
    end;
    if Terminated then
      Break;
    Sleep(100);
  end;
  inherited;
end;

procedure TStandardHearBeatThread.SendHeartBeat;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // ����
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_HeartBeat );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TStandardHearBeatThread.SetAccountInfo(_AccountName,
  _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;

{ TStandardPcAddHanlde }

constructor TStandardPcAddHanlde.Create(_StandardPcInfo: TStandardPcInfo);
begin
  StandardPcInfo := _StandardPcInfo;
end;

procedure TStandardPcAddHanlde.Update;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
begin
    // ��� Pc ��Ϣ
  NetworkPcApi.AddItem( StandardPcInfo.PcID, StandardPcInfo.PcName );

    // Ping Pc
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( StandardPcInfo.PcID );
  MasterSendInternetPingInfo.SetSocketInfo( StandardPcInfo.LanIp, StandardPcInfo.LanPort );
  MasterSendInternetPingInfo.SetInternetSocket( StandardPcInfo.InternetIp, StandardPcInfo.InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

{ TRestartNetworkThread }

constructor TRestartConnectToPcThread.Create;
begin
  inherited Create;
end;

destructor TRestartConnectToPcThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TRestartConnectToPcThread.Execute;
var
  LastShowTime : TDateTime;
begin
  while not Terminated do
  begin
    LastShowTime := Now;
    while ( not Terminated ) and ( SecondsBetween( Now, LastShowTime ) < 1 ) do
      Sleep(100);
    if Terminated then
      Break;
    ShowRemainTime;
  end;

  inherited;
end;

procedure TRestartConnectToPcThread.RunRestart;
begin
    // ��ʾ �޷�����
//  NetworkErrorStatusApi.ShowCannotConn(  );

    // ��ʼʱ��
  StartTime := Now;

    // ��ʾʣ��ʱ��
  ShowRemainTime;

    // �����߳�
  Resume;
end;

procedure TRestartConnectToPcThread.ShowRemainTime;
var
  RemainTime : Integer;
begin
    // ����ʣ��ʱ��
  RemainTime := 300 - SecondsBetween( Now, StartTime );

    // ��ʾʣ��ʱ��
  NetworkErrorStatusApi.ShowConnAgainRemain( RemainTime );

    // ��������
  if RemainTime <= 0 then
    MySearchMasterHandler.RestartNetwork;
end;

{ TMySearchMasterHandler }

constructor TMySearchMasterHandler.Create;
begin
  MasterThread := TMasterThread.Create;
  IsRun := True;
end;

function TMySearchMasterHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsConnecting;
end;

procedure TMySearchMasterHandler.RestartNetwork;
begin
  if not IsRun then
    Exit;

    // �������Ӵ�����Ϣ
  NetworkErrorStatusApi.HideError;

    // ��ʱ���ܸı�����
  NetworkConnStatusShowApi.SetNotChangeNetwork;

    // ��������
  IsConnecting := False;
  MasterThread.Resume;
end;

procedure TMySearchMasterHandler.StartRun;
begin
  MasterThread.Resume;
end;

procedure TMySearchMasterHandler.StopRun;
begin
  IsRun := False;
  MasterThread.Free;
end;

{ TSearchServerRunCreate }

function TSearchServerRunCreate.get: TSearchServerRun;
var
  SelectType : string;
begin
  SelectType := MyNetworkConnInfo.SelectType;

    // �����Ƿ����ӳɹ�
  if SelectType = SelectConnType_Group then
    Result := getGroup
  else
  if SelectType = SelectConnType_ConnPC then
    Result := getConnToPc
  else
    Result := getLan;
end;

function TSearchServerRunCreate.getConnToPc: TConnToPcSearchServer;
var
  Domain, Port : string;
begin
  Domain := MyNetworkConnInfo.SelectValue1;
  Port := MyNetworkConnInfo.SelectValue2;

  Result := TConnToPcSearchServer.Create;
  Result.SetConnPcInfo( Domain, Port );
end;

function TSearchServerRunCreate.getGroup: TGroupSearchServer;
var
  GroupName, Password : string;
begin
  GroupName := MyNetworkConnInfo.SelectValue1;
  Password := NetworkGroupInfoReadUtil.ReadPassword( GroupName );

  Result := TGroupSearchServer.Create;
  Result.SetGroupInfo( GroupName, Password );
end;

function TSearchServerRunCreate.getLan: TLanSearchServer;
var
  ConnSearchPcID : string;
begin
  ConnSearchPcID := MyNetworkConnInfo.SelectValue1;

  Result := TLanSearchServer.Create;
  Result.SetSearchPcID( ConnSearchPcID );
end;

{ TConfirmNetworkInfoHandle }

procedure TConfirmNetworkInfoHandle.ConfirmInternetIp;
var
  InternetIp : string;
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
  InternetIp := '';

     // ��·�� ��ȡ Internet IP
  if PortMapping.IsPortMapable then
    InternetIp := FindRouterInternetIp;

    // ����վ ��ȡ Internet Ip
  if InternetIp = '' then
    InternetIp := FindWebInternetIp;

    // û���ҵ� InternetIp, ���� LanIp ����
  if InternetIp = '' then
    InternetIp := PcInfo.LanIp;

    // ���� Internet Ip ��Ϣ
  MyPcInfoApi.SetInternetIp( InternetIp );
end;

procedure TConfirmNetworkInfoHandle.ConfirmInternetPort;
var
  Port : Integer;
  i: Integer;
begin
  Port := StrToIntDef( PcInfo.InternetPort, 26954 );
  for i := 0 to 10000 do
  begin
      // �˿ڿ��������
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // �˿ںŲ���ͬ, ����˿ں�
  if PcInfo.InternetPort <> IntToStr( Port ) then
    MyPcInfoApi.SetInternetPort( IntToStr( Port ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmInternetPortMap;
var
  InternetPort, i : Integer;
  IsPortMap : Boolean;
begin
    // ��ʾ״̬
  MyNetworkStatusApi.SetIsExistUpnp( PortMapping.IsPortMapable, PortMapping.controlurl );

    // ���ɶ˿�ӳ��
  if not PortMapping.IsPortMapable then
    Exit;

    // ���ӳ��˿��Ƿ�ռ��
  IsPortMap := False;
  InternetPort := StrToIntDef( PcInfo.InternetPort, 26954 );
  for i := 0 to 100 do
  begin
      // �˿�ӳ��ɹ�
    if PortMapping.AddMapping( PcInfo.LanIp, IntToStr( InternetPort ) ) then
    begin
      IsPortMap := True;
      Break;
    end;

      // ����˿ڱ�ռ����ʹ����һ���˿�
    inc( InternetPort );
  end;

    // ���ö˿�ӳ���Ƿ�ɹ�
  MyNetworkStatusApi.SetIsPortMapCompleted( IsPortMap );

    // �������µĶ˿�
  if PcInfo.InternetPort <> IntToStr( InternetPort ) then
    MyPcInfoApi.SetInternetPort( IntToStr( InternetPort ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmLanIp;
var
  IpList : TStringList;
  TemLanIp : string;
begin
  IpList := MyIpList.get;
  if IpList.IndexOf( PcInfo.RealLanIp ) < 0 then  // ���õ� Ip ������
  begin
    if IpList.Count > 0 then
      MyPcInfoApi.SetTempLanIp( IpList[0] ); // ���� ��ʱ�� Lan Ip
  end
  else
  if PcInfo.RealLanIp <> PcInfo.LanIp then  // ֮ǰ���ù���ʱ Ip
    MyPcInfoApi.SetTempLanIp( PcInfo.RealLanIp ); // Ip ���ø�λ
  IpList.Free;
end;

procedure TConfirmNetworkInfoHandle.ConfirmLanPort;
var
  Port : Integer;
  i: Integer;
begin
  Port := StrToIntDef( PcInfo.LanPort, 8585 );
  for i := 0 to 10000 do
  begin
      // �˿ڿ��������
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // �˿ںŲ���ͬ, ����˿ں�
  if PcInfo.LanPort <> IntToStr( Port ) then
    MyPcInfoApi.SetLanPort( IntToStr( Port ) );
end;

constructor TConfirmNetworkInfoHandle.Create(_PortMapping: TPortMapping);
begin
  PortMapping := _PortMapping;
end;

function TConfirmNetworkInfoHandle.FindRouterInternetIp: string;
var
  i: Integer;
begin
    // ���ܻ�ȡʧ�ܣ���ȡ 5 ��
  for i := 1 to 5 do
  begin
    Result := PortMapping.getInternetIp;
    if Result <> '' then
      Break;
    Sleep(100);
  end;
end;

function TConfirmNetworkInfoHandle.FindWebInternetIp: string;
var
  getIpHttp : TIdHTTP;
  httpStr : string;
  HttpList : TStringList;
  i: Integer;
  IsFind : Boolean;
begin
  Result := '';

    // ������Ϊ����ԭ���ȡʧ�ܣ� ��ȡ 5 ��
  for i := 1 to 5 do
  begin
    getIpHttp := TIdHTTP.Create(nil);
    getIpHttp.ConnectTimeout := 20000;
    getIpHttp.ReadTimeout := 20000;
    try
      httpStr := getIpHttp.Get( MyUrl.getIp );

      HttpList := TStringList.Create;
      HttpList.Text := httpStr;
      Result := HttpList[0];
      HttpList.Free;

      IsFind := True;
    except
      IsFind := False;
    end;
    getIpHttp.Free;

      // �ɹ���ȡ Ip
    if IsFind then
      Break;

    Sleep(100);
  end;
end;

procedure TConfirmNetworkInfoHandle.Upate;
begin
    // �������˿���Ϣ
  ConfirmLanIp;
  ConfirmLanPort;

    // �������˿���Ϣ
  ConfirmInternetIp;
  ConfirmInternetPort;
  ConfirmInternetPortMap;
end;

{ TLanSearchPcThread }

constructor TLanSearchPcThread.Create;
begin
  inherited Create;
end;

destructor TLanSearchPcThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TLanSearchPcThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
      // 20 ���� ���һ������
    StartTime := Now;
    while not Terminated and ( SecondsBetween( Now, StartTime ) < 20 ) do
      Sleep(100);
    if Terminated then
      Break;
    SearchPcHandle;
  end;
  inherited;
end;

procedure TLanSearchPcThread.SearchPcHandle;
var
  CloudIDNumMD5 : string;
  LanBroadcastMsg : TLanBroadcastMsg;
  MsgInfo : TMsgInfo;
  MsgType, MsgStr, Msg : string;
begin
    // ���Ƿ�����
  if not MyServer.IsBeServer then
    Exit;

  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // ��ȡ �㲥��Ϣ
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_SearchPc );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // �㲥��Ϣ�İ汾
  MsgType := IntToStr( ConnEdition_Now );

    // ��װ �㲥��Ϣ
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // ���� �㲥��Ϣ
  frmBroadcast.SendMsg( Msg );
end;

{ MySearchMasterTimerApi }

class procedure MySearchMasterTimerApi.CheckRestartNetwork;
begin
  if not MySearchMasterHandler.IsRun then
    Exit;

    // �Ƿ�����
  if not MyServer.IsBeServer then
    Exit;

    // �ж���ͻ���
  if MyServer.ClientCount > 1 then
    Exit;

    // ��������
  MySearchMasterHandler.RestartNetwork;
end;

class procedure MySearchMasterTimerApi.MakePortMapping;
begin
  if not MySearchMasterHandler.IsRun then
    Exit;

  try
    MySearchMasterHandler.MasterThread.PortMapping.AddMapping( PcInfo.LanIp, PcInfo.InternetPort );
  except
  end;
end;

class procedure MySearchMasterTimerApi.RefreshConnecting;
begin
  NetworkConnStatusShowApi.SetConnecting; // ��ʾ��������
end;

function TSearchServerRun.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus_OK;
end;

end.

