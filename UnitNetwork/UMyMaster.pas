unit UMyMaster;

interface

uses UChangeInfo, UMyUtil, UMyNetPcInfo, UMyTcp, Sockets, SysUtils, uDebug, classes,
     Generics.Collections, Syncobjs, DateUtils, UMyDebug, uDebugLock;

type

{$Region ' �㲥��Ϣ ���ݽṹ ' }

    // ������ �㲥
  TLanBroadcastMsg = class( TMsgBase )
  private
    iPcID : string;
    iPcName : string;
    iIp, iPort : string;
    iCloudIDNumMD5 : string;
  private
    iBroadcastType : string;
  published
    property PcID : string Read iPcID Write iPcID;
    property PcName : string Read iPcName Write iPcName;
    property LanIp : string Read iIp Write iIp;
    property LanPort : string Read iPort Write iPort;
    property CloudIDNumMD5 : string Read iCloudIDNumMD5 Write iCloudIDNumMD5;
    property BroadcastType : string Read iBroadcastType Write iBroadcastType;
  public
    procedure SetPcID( _PcID : string );
    procedure SetPcName( _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort : string );
    procedure SetCloudIDNumMD5( _CloudIDNumMD5 : string );
    procedure SetBroadcastType( _BroadcastType : string );
  end;

{$EndRegion}


{$Region ' ���� ���ݽṹ ' }

    // ����
  TMasterSendInfo = class
  end;
  TMasterSendList = class( TObjectList<TMasterSendInfo> )end;

    // ��Ϊ�����������ӿͻ���
  TMasterConnClientInfo = class( TMasterSendInfo )
  public
    ClientPcID : string;
  public
    constructor Create( _ClientPcID : string );
  end;

    // ����������Ϣ ����
  TMasterSendConnInfo = class( TMasterSendInfo )
  public
    PcID : string;
    Ip, Port : string;
    SendTime : TDateTime;
  public
    constructor Create( _PcID : string );
    procedure SetSocketInfo( _Ip, _Port : string );
    procedure SetSendTime( _SendTime : TDateTime );
  end;

    // ���� Lan Ping
  TMasterSendLanPingInfo = class( TMasterSendConnInfo )
  end;

    // ���� Internet ��Ϣ
  TMasterSendInternerInfo = class( TMasterSendConnInfo )
  public
    InternetIp, InternetPort : string;
  public
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;

    // ���� Internet Ping
  TMasterSendInternetPingInfo = class( TMasterSendInternerInfo )
  end;

    // ���� ����ȷ��
  TMasterSendConfirmConnectInfo = class( TMasterSendInternerInfo )
  end;

{$EndRegion}

{$Region ' ���� ����� ' }

    // ���ӷ��� ����
  TSendMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // Ping ����
  TSendPingMsgHandle = class( TSendMsgBaseHandle )
  public
    PcID : string;
    IsLanConn : Boolean;
  public
    procedure SetPcID( _PcID : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    function Update: Boolean;  // �˿�����CS�򷵻� True
  private
    procedure SendMyPcInfo;   // ���ͱ�����Ϣ
    procedure RevRemotePcInfo;  // ����Զ����Ϣ
    function ConnectToCS: Boolean; // �Ƿ����̽���CS����
  end;

    // ȷ����������
  TSendConfirmConnectMsgHandle = class( TSendMsgBaseHandle )
  public
    PcID : string;
    IsLanConn : Boolean;
  public
    procedure SetPcID( _PcID : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    procedure Update;
  private
    procedure SendMySocketInfo;
  end;

{$EndRegion}

{$Region ' ���� �����߳� ' }

    // ��������
  TMasterSendHandle = class
  public
    MasterSendInfo : TMasterSendConnInfo;
    PcID : string;
  public
    Ip, Port : string;
    IsLanConn : Boolean;
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
  public
    constructor Create( _MasterSendInfo : TMasterSendConnInfo );
    function Update: Boolean;
    destructor Destroy; override;
  private      // ����
    function ConnToSocket : Boolean;
    function ConnToInternetSocket : Boolean;
    function ConnToPc( ConnIp, ConnPort : string ): Boolean;
  private      // ��¼������Ϣ
    procedure MarkNotConnected;
  private      // ����������Ϣ
    procedure HandleSend;
    procedure HandlePing;
    procedure HandleConfirmConect;
  end;

    // �����߳�
  TMasterSendThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleConnClient( MasterConnClientInfo : TMasterConnClientInfo );
    function HandleSend( MasterSendConnInfo : TMasterSendConnInfo ): Boolean;
  end;
  TMasterSendThreadList = class( TObjectList<TMasterSendThread> )end;

{$EndRegion}

    // �ײ������
  TMyMasterSendHandler = class
  public
    DataLock : TCriticalSection;
    MasterSendList : TMasterSendList;
  public
    IsRun : Boolean;
    ThreadLock : TCriticalSection;
    MasterSendThreadList : TMasterSendThreadList;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    function getIsRuning : Boolean; // �Ƿ��ڷ�������
  public
    procedure AddMasterSend( MasterSendInfo : TMasterSendInfo );
    procedure AddMasterBusySend( MasterSendInfo : TMasterSendConnInfo );
    function getMasterSendInfo : TMasterSendInfo;
    procedure RemoveThread( ThreadID : Cardinal );
  end;


{$Region ' ���� ����� ' }

    // ����㲥����
  TRevBroadcastMsgHandle = class
  private
    BroadcastStr : string;
  private
    LanPcMsgStr : string;
    PcID, PcName : string;
    LanIp, LanPort : string;
    CloudIDNumMD5 : string;
    BroadcastType : string;
  public
    constructor Create( _BroadcastStr : string );
    procedure Update;
  private
    function CheckBroadcastMsg : Boolean;
    procedure FindBroadcastMsg;
    procedure SendLanPing;
    procedure LanSearchHandle;
  private       // ����汾������
    procedure EditionErrorHandle( IsNewEdition : Boolean );
  end;

    // �������� ����
  TReceiveMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // ���� Ping ����
  TReceivePingMsgHandle = class( TReceiveMsgBaseHandle )
  private
    PcID : string;
  public
    function Update: Boolean;  // ������ CS �򷵻� True
  private
    procedure RevRemotePcInfo;  // ����Զ����Ϣ
    procedure SendMyPcInfo;   // ���ͱ�����Ϣ
    function ConnectToCS: Boolean; // ���ӿͻ���
  end;

    // ȷ������ ����
  TReceiveConfirmConnectMsgHandle = class( TReceiveMsgBaseHandle )
  public
    procedure Update;
  private
    procedure RevRemoteSocketInfo;
  end;

    // Advance ����
  TReceiveAdvanceMsgHandle = class( TReceiveMsgBaseHandle )
  public
    function Update: Boolean; // ���ӵ� CS ���� True
  private
    procedure RevRemotePcInfo;
    procedure SendServerInfo;
    function getIsConnectToCS: Boolean;
  end;

{$EndRegion}

{$Region ' ���� �����߳� ' }

    // ������������߳�
  TMasterReceiveThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleReceive;
    procedure HandlePing;
    procedure HandleConfirmConnect;
    procedure HandleAdvanceConn;
  end;
  TMasterReceiveThreadList = class( TObjectList< TMasterReceiveThread > )end;

    // ����㲥���� �߳�
  TMasterReceiveBroadcastThread = class( TDebugThread )
  public
    IsRunning : Boolean;
    MsgLock : TCriticalSection;
    MsgList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddMsg( MsgStr : string );
    function getMsg : string;
    procedure HandleMsg( MsgStr : string );
  end;

{$EndRegion}

  TMyMasterReceiveHandler = class
  public
    IsRun : Boolean;
    ThreadLock : TCriticalSection;
    MasterReceiveThreadList : TMasterReceiveThreadList;
  public
    MasterReceiveBroadcastThread : TMasterReceiveBroadcastThread;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    function getIsRuning : Boolean; // �Ƿ��ڽ�������
  public
    procedure ReceiveConn( TcpSocket : TCustomIpClient );
    procedure RemoveThread( ThreadID : Cardinal );
  public
    procedure ReceiveBroadcast( BroadcastMsg : string );
  end;


const
  ThreadCount_MasterMsg  = 10;

  MsgType_SearchServer_Ping = 'pg';
  MsgType_SearchServer_ConfirmConnect = 'cc';
  MsgType_SearchServer_Advance = 'ad';

  BroadcastType_StartLan = 'StartLan';
  BroadcastType_SearchPc = 'SearchPc';

var
  MyMasterSendHandler : TMyMasterSendHandler;
  MyMasterReceiveHanlder : TMyMasterReceiveHandler;


implementation

uses UFormBroadcast, UNetworkFace, UNetPcInfoXml, USettingInfo, USearchServer, UMyClient,
     UNetworkControl, UMyServer;

{ TMasterSendInfo }

constructor TMasterSendConnInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  SendTime := Now;
end;

procedure TMasterSendConnInfo.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TMasterSendConnInfo.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TMasterSendInternerInfo }

procedure TMasterSendInternerInfo.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

{ TMasterSendHandleThread }

constructor TMasterSendThread.Create;
begin
  inherited Create;
end;

destructor TMasterSendThread.Destroy;
begin
  inherited;
end;

procedure TMasterSendThread.Execute;
var
  MasterSendInfo : TMasterSendInfo;
  MasterSendConnInfo : TMasterSendConnInfo;
begin
  FreeOnTerminate := True;

  while MyMasterSendHandler.IsRun do
  begin
    MasterSendInfo := MyMasterSendHandler.getMasterSendInfo;
    if MasterSendInfo = nil then
      Break;

    try
          // ���ӿͻ�����Ϣ
      if MasterSendInfo is TMasterConnClientInfo then
        HandleConnClient( MasterSendInfo as TMasterConnClientInfo )
      else  // ���ӷ�����Ϣ
      if MasterSendInfo is TMasterSendConnInfo then
      begin
        MasterSendConnInfo := MasterSendInfo as TMasterSendConnInfo;
        if not HandleSend( MasterSendConnInfo ) then // δ�������
          Continue;
      end;
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Master Send Msg', e.Message );
    end;

    MasterSendInfo.Free;
  end;

  MyMasterSendHandler.RemoveThread( ThreadID );

  Terminate;
end;

procedure TMasterSendThread.HandleConnClient(
  MasterConnClientInfo: TMasterConnClientInfo);
var
  ClientPcID : string;
  TcpSocket : TCustomIpClient;
  ClientIp, ClientPort : string;
  MyTcpConn : TMyTcpConn;
  IsSuccessConn : Boolean;
begin
  DebugLock.Debug( 'ConnectClientHandle: ' + MasterConnClientInfo.ClientPcID);

  TcpSocket := TCustomIpClient.Create( nil );

  ClientPcID := MasterConnClientInfo.ClientPcID;
  ClientIp := MyNetPcInfoReadUtil.ReadIp( ClientPcID );
  ClientPort := MyNetPcInfoReadUtil.ReadPort( ClientPcID );

    // ���ӶԷ�
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ClientIp, ClientPort );
  MyTcpConn.SetConnType( ConnType_Client );
  IsSuccessConn := MyTcpConn.Conn and MyServer.ConnectClient( TcpSocket );
  MyTcpConn.Free;

    // δ����
  if not IsSuccessConn then
    TcpSocket.Free;
end;

function TMasterSendThread.HandleSend(MasterSendConnInfo: TMasterSendConnInfo): Boolean;
var
  MasterSendHandle : TMasterSendHandle;
begin
  DebugLock.Debug( 'HandleSend: ' + MasterSendConnInfo.ClassName );

  Result := False;

    // ��æ�ķ�������
  if MasterSendConnInfo.SendTime > Now then
  begin
    Sleep(100);
    MyMasterSendHandler.AddMasterSend( MasterSendConnInfo );
    Exit;
  end;

    // ������
  MasterSendHandle := TMasterSendHandle.Create( MasterSendConnInfo );
  Result := MasterSendHandle.Update;
  MasterSendHandle.Free;

    // ���շ���æ
  if not Result then
    MyMasterSendHandler.AddMasterBusySend( MasterSendConnInfo );
end;

{ TMyMasterSendHandler }

procedure TMyMasterSendHandler.AddMasterBusySend(
  MasterSendInfo: TMasterSendConnInfo);
begin
  if not IsRun then
    Exit;

  DataLock.Enter;
  MasterSendInfo.SetSendTime( IncSecond( Now, 1 ) ); // 1 ���������
  MasterSendList.Add( MasterSendInfo );
  DataLock.Leave;
end;

procedure TMyMasterSendHandler.AddMasterSend(MasterSendInfo: TMasterSendInfo);
var
  RunThread : TMasterSendThread;
begin
  if not IsRun then
    Exit;

  DataLock.Enter;
  MasterSendList.Add( MasterSendInfo );
  DataLock.Leave;

  ThreadLock.Enter;
  if MasterSendThreadList.Count < ThreadCount_MasterMsg then
  begin
    RunThread := TMasterSendThread.Create;
    MasterSendThreadList.Add( RunThread );
    RunThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyMasterSendHandler.Create;
begin
  DataLock := TCriticalSection.Create;
  MasterSendList := TMasterSendList.Create;
  MasterSendList.OwnsObjects := False;

  ThreadLock := TCriticalSection.Create;
  MasterSendThreadList := TMasterSendThreadList.Create;
  MasterSendThreadList.OwnsObjects := False;
  IsRun := True;
end;

destructor TMyMasterSendHandler.Destroy;
begin
  MasterSendThreadList.Free;
  ThreadLock.Free;

  MasterSendList.OwnsObjects := True;
  MasterSendList.Free;
  DataLock.Free;
  inherited;
end;

function TMyMasterSendHandler.getIsRuning: Boolean;
begin
  Result := False;
  if not IsRun then
    Exit;

  ThreadLock.Enter;
  Result := MasterSendThreadList.Count > 0;
  ThreadLock.Leave;
end;

function TMyMasterSendHandler.getMasterSendInfo: TMasterSendInfo;
begin
  DataLock.Enter;
  if MasterSendList.Count > 0 then
  begin
    Result := MasterSendList[0];
    MasterSendList.Delete( 0 );
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TMyMasterSendHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to MasterSendThreadList.Count - 1 do
    if MasterSendThreadList[i].ThreadID = ThreadID then
    begin
      MasterSendThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyMasterSendHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := MasterSendThreadList.Count > 0;
    ThreadLock.Leave;
    if not IsExistThread then
      Break;
    Sleep( 100 );
  end;
end;

{ TMasterSendHandle }

function TMasterSendHandle.ConnToInternetSocket: Boolean;
var
  MasterSendInternerInfo : TMasterSendInternerInfo;
begin
  Result := False;

  if not ( MasterSendInfo is TMasterSendInternerInfo ) then
    Exit;

  IsLanConn := False;
  MasterSendInternerInfo := MasterSendInfo as TMasterSendInternerInfo;
  Result := ConnToPc( MasterSendInternerInfo.InternetIp, MasterSendInternerInfo.InternetPort );
end;

function TMasterSendHandle.ConnToPc(ConnIp, ConnPort: string): Boolean;
var
  MyTcpConn : TMyTcpConn;
begin
  DebugLock.Debug( 'ConnToPc: ' + ConnIp + '  ' + ConnPort );

    // ���ӶԷ�
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ConnIp, ConnPort );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    Result := MySocketUtil.RevJsonStr( TcpSocket ) = MasterSendInfo.PcID;
    MySocketUtil.SendJsonStr( TcpSocket, 'IsSuccess', Result );
    if not Result then
      TcpSocket.Disconnect; // ���Ӵ���
  end
  else
    Result := False;
  MyTcpConn.Free;

    // ���ӳɹ�
  if Result then
  begin
    Ip := ConnIp;
    Port := ConnPort;
  end;
end;

function TMasterSendHandle.ConnToSocket: Boolean;
begin
  IsLanConn := True;
  Result := ConnToPc( MasterSendInfo.Ip, MasterSendInfo.Port );
end;

constructor TMasterSendHandle.Create(_MasterSendInfo: TMasterSendConnInfo);
begin
  MasterSendInfo := _MasterSendInfo;
  PcID := MasterSendInfo.PcID;
  TcpSocket := TCustomIpClient.Create( nil );
  IsDestorySocket := True;
end;

destructor TMasterSendHandle.Destroy;
begin
  if IsDestorySocket then
    TcpSocket.Free;
  inherited;
end;

procedure TMasterSendHandle.HandlePing;
var
  SendPingMsgHandle : TSendPingMsgHandle;
  IsConnectCS : Boolean;
begin
  DebugLock.Debug( 'HandlePing' );

    // ���� �˿���Ϣ
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // ���� ��������
  MySocketUtil.SendJsonStr( TcpSocket, 'MsgType', MsgType_SearchServer_Ping );

    // Ping ����
  SendPingMsgHandle := TSendPingMsgHandle.Create( TcpSocket );
  SendPingMsgHandle.SetPcID( PcID );
  SendPingMsgHandle.SetIsLanConn( IsLanConn );
  IsConnectCS := SendPingMsgHandle.Update;
  SendPingMsgHandle.Free;

    // �˿������� CS�������ͷ�
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterSendHandle.HandleConfirmConect;
var
  SendConfirmConnectMsgHandle : TSendConfirmConnectMsgHandle;
begin
  DebugLock.Debug( 'HandleConfirmConect' );

    // ���� �˿���Ϣ
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // ������������
  MySocketUtil.SendJsonStr( TcpSocket, 'MsgType', MsgType_SearchServer_ConfirmConnect );

    // ������Ϣ ȷ��
  SendConfirmConnectMsgHandle := TSendConfirmConnectMsgHandle.Create( TcpSocket );
  SendConfirmConnectMsgHandle.SetPcID( PcID );
  SendConfirmConnectMsgHandle.SetIsLanConn( IsLanConn );
  SendConfirmConnectMsgHandle.Update;
  SendConfirmConnectMsgHandle.Free;
end;

procedure TMasterSendHandle.HandleSend;
begin
  if ( MasterSendInfo is TMasterSendLanPingInfo ) or
     ( MasterSendInfo is TMasterSendInternetPingInfo )
  then
    HandlePing
  else
  if MasterSendInfo is TMasterSendConfirmConnectInfo then
    HandleConfirmConect;
end;

procedure TMasterSendHandle.MarkNotConnected;
var
  IsMark : Boolean;
  MasterSendInterInfo : TMasterSendInternerInfo;
begin
  IsMark := ( MasterSendInfo is TMasterSendLanPingInfo ) or
            ( MasterSendInfo is TMasterSendInternetPingInfo ) or
            ( MasterSendInfo is TMasterSendConfirmConnectInfo );

  if not IsMark then
    Exit;

    // ������ ��������
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInfo.Ip, MasterSendInfo.Port, False, True );

    // �� Internet
  if not ( MasterSendInfo is TMasterSendInternerInfo ) then
    Exit;
    
    // Internet ��������
  MasterSendInterInfo := MasterSendInfo as TMasterSendInternerInfo;
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInterInfo.InternetIp, MasterSendInterInfo.InternetPort, False, False );
end;

function TMasterSendHandle.Update: Boolean;
var
  IsBusy : Boolean;
begin
  Result := True;

    // �޷�����
  if not ConnToSocket and not ConnToInternetSocket then
  begin
    MarkNotConnected; // ��¼��������
    Exit;
  end;

    // �Ƿ���շ�æ
  IsBusy := MySocketUtil.RevJsonBool( TcpSocket );
  if IsBusy then
  begin
    Result := False; // ��æ
    Exit;
  end;

    // ���Ӻ�Ĵ���
  HandleSend;
end;

{ TPingMsgHandle }

function TSendPingMsgHandle.ConnectToCS: Boolean;
var
  LocalIsServer, LocalIsClient : Boolean;
  RemoteIsServer, RemoteIsClient : Boolean;
  IsConnected : Boolean;
begin
    // ���� ����C/S��Ϣ
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendData( TcpSocket, LocalIsServer );
  MySocketUtil.SendData( TcpSocket, LocalIsClient );

    // ���� Զ��C/S��Ϣ
  RemoteIsServer := MySocketUtil.RevBoolData( TcpSocket );
  RemoteIsClient := MySocketUtil.RevBoolData( TcpSocket );

    // �����Ƿ�����
  Result := False;
  if LocalIsServer and not RemoteIsServer and not RemoteIsClient then
    Result := MyServer.ConnectClient( TcpSocket )
  else
  if RemoteIsServer and not LocalIsServer and not LocalIsClient then
    Result := MyClient.ConnectServer( TcpSocket );
end;

procedure TSendPingMsgHandle.RevRemotePcInfo;
var
  TimeStr : string;
  StartTime : TDateTime;
  RanNum : Integer;
  ClientCount : Integer;
  Params : TMasterInfoAddParams;
begin
    // ������Ϣ
  ClientCount := MySocketUtil.RevIntData( TcpSocket );
  TimeStr := MySocketUtil.RevData( TcpSocket );
  StartTime := MyRegionUtil.ReadLocalTime( TimeStr );
  RanNum := MySocketUtil.RevIntData( TcpSocket );

    // ���� Master ��Ϣ
  Params.PcID := PcID;
  Params.ClientCount := ClientCount;
  Params.StartTime := StartTime;
  Params.RanNum := RanNum;
  MasterInfo.AddItem( Params );
end;

procedure TSendPingMsgHandle.SendMyPcInfo;
var
  SendIp, SendPort : string;
begin
    // ��ȡ��Ϣ
  if IsLanConn then
  begin
    SendIp := PcInfo.LanIp;
    SendPort := PcInfo.LanPort;
  end
  else
  begin
    SendIp := PcInfo.InternetIp;
    SendPort := PcInfo.InternetPort;
  end;

    // ������Ϣ
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );
  MySocketUtil.SendData( TcpSocket, PcInfo.PcName );
  MySocketUtil.SendData( TcpSocket, SendIp );
  MySocketUtil.SendData( TcpSocket, SendPort );
  MySocketUtil.SendData( TcpSocket, IsLanConn );
  MySocketUtil.SendData( TcpSocket, MyServer.ClientCount );
  MySocketUtil.SendData( TcpSocket, MyRegionUtil.ReadRemoteTimeStr( PcInfo.StartTime ) );
  MySocketUtil.SendData( TcpSocket, PcInfo.RanNum );
end;

procedure TSendPingMsgHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TSendPingMsgHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

function TSendPingMsgHandle.Update: Boolean;
begin
  SendMyPcInfo;
  RevRemotePcInfo;
  Result := ConnectToCS;
end;

{ TMasterReceiveThread }

constructor TMasterReceiveThread.Create;
begin
  inherited Create;
end;

destructor TMasterReceiveThread.Destroy;
begin
  inherited;
end;

procedure TMasterReceiveThread.Execute;
begin
  FreeOnTerminate := True;

    // ��������
  try
    HandleReceive;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Master Receive Msg', e.Message );
  end;

    // �˿����� CS ��ɾ���˿�
  if IsDestorySocket then
    TcpSocket.Free;

  MyMasterReceiveHanlder.RemoveThread( ThreadID );

  Terminate;
end;

procedure TMasterReceiveThread.HandleAdvanceConn;
var
  ReceiveAdvanceMsgHandle : TReceiveAdvanceMsgHandle;
  IsConnectCS : Boolean;
begin
  ReceiveAdvanceMsgHandle := TReceiveAdvanceMsgHandle.Create( TcpSocket );
  IsConnectCS := ReceiveAdvanceMsgHandle.Update;
  ReceiveAdvanceMsgHandle.Free;

    // �����ӵ� CS
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterReceiveThread.HandleConfirmConnect;
var
  ReceiveConfirmConnectMsgHandle : TReceiveConfirmConnectMsgHandle;
begin
  ReceiveConfirmConnectMsgHandle := TReceiveConfirmConnectMsgHandle.Create( TcpSocket );
  ReceiveConfirmConnectMsgHandle.Update;
  ReceiveConfirmConnectMsgHandle.Free;
end;


procedure TMasterReceiveThread.HandlePing;
var
  ReceivePingMsgHandle : TReceivePingMsgHandle;
  IsConnectCS : Boolean;
begin
  ReceivePingMsgHandle := TReceivePingMsgHandle.Create( TcpSocket );
  IsConnectCS := ReceivePingMsgHandle.Update;
  ReceivePingMsgHandle.Free;

    // Socket �Ѿ����ӵ� CS�������ͷ�
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterReceiveThread.HandleReceive;
var
  MsgType : string;
begin
  MsgType := MySocketUtil.RevJsonStr( TcpSocket );

  DebugLock.Debug( 'HandleReceive: ' + MsgType );
  if MsgType = MsgType_SearchServer_Ping then
    HandlePing
  else
  if MsgType = MsgType_SearchServer_ConfirmConnect then
    HandleConfirmConnect
  else
  if MsgType = MsgType_SearchServer_Advance then
    HandleAdvanceConn;
end;

procedure TMasterReceiveThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  IsDestorySocket := True;
end;

{ TMyMasterReceiveHandle }

constructor TMyMasterReceiveHandler.Create;
begin
  IsRun := True;
  ThreadLock := TCriticalSection.Create;
  MasterReceiveThreadList := TMasterReceiveThreadList.Create;
  MasterReceiveThreadList.OwnsObjects := False;

  MasterReceiveBroadcastThread := TMasterReceiveBroadcastThread.Create;
end;

destructor TMyMasterReceiveHandler.Destroy;
begin
  MasterReceiveThreadList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyMasterReceiveHandler.getIsRuning: Boolean;
begin
  Result := False;
  if not IsRun then
    Exit;

    // ���ڴ���㲥
  if MasterReceiveBroadcastThread.IsRunning then
  begin
    Result := True;
    Exit;
  end;

    // ���ڴ�����������
  ThreadLock.Enter;
  if MasterReceiveThreadList.Count > 0 then
    Result := True;
  ThreadLock.Leave;
end;

procedure TMyMasterReceiveHandler.ReceiveBroadcast(BroadcastMsg: string);
begin
  if not IsRun then
    Exit;

  MasterReceiveBroadcastThread.AddMsg( BroadcastMsg );
end;

procedure TMyMasterReceiveHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsSuccess, IsBusy : Boolean;
  NewThread : TMasterReceiveThread;
begin
    // �������
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // �ж������Ƿ���ȷ
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  IsSuccess := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsSuccess then  // ���Ӵ���
  begin
    TcpSocket.Free;
    Exit;
  end;

    // ��ȡ�Ƿ�æ�̴߳�������
  ThreadLock.Enter;
  IsBusy := True;
  if MasterReceiveThreadList.Count < ThreadCount_MasterMsg then
  begin
    IsBusy := False;
    NewThread := TMasterReceiveThread.Create;
    MasterReceiveThreadList.Add( NewThread );

    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', False ); // ���ͷǷ�æ
    NewThread.SetTcpSocket( TcpSocket );
    NewThread.Resume;
  end;
  ThreadLock.Leave;

    // ��æ�����
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', True ); // ���ͷ�æ
    TcpSocket.Free;
  end;
end;

procedure TMyMasterReceiveHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to MasterReceiveThreadList.Count - 1 do
    if MasterReceiveThreadList[i].ThreadID = ThreadID then
    begin
      MasterReceiveThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyMasterReceiveHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

  MasterReceiveBroadcastThread.Free;

  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := MasterReceiveThreadList.Count > 0;
    ThreadLock.Leave;

    if not IsExistThread then
      Break;

    Sleep( 100 );
  end;
end;

{ TReceivePingMsgHandle }

function TReceivePingMsgHandle.ConnectToCS: Boolean;
var
  LocalIsServer, LocalIsClient : Boolean;
  RemoteIsServer, RemoteIsClient : Boolean;
  IsConnected : Boolean;
begin
    // ���� Զ��C/S��Ϣ
  RemoteIsServer := MySocketUtil.RevBoolData( TcpSocket );
  RemoteIsClient := MySocketUtil.RevBoolData( TcpSocket );

      // ���� ����C/S��Ϣ
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendData( TcpSocket, LocalIsServer );
  MySocketUtil.SendData( TcpSocket, LocalIsClient );

    // �����Ƿ�����
  Result := False;
  if LocalIsServer and not RemoteIsServer and not RemoteIsClient then
    Result := MyServer.ConnectClient( TcpSocket )
  else
  if RemoteIsServer and not LocalIsServer and not LocalIsClient then
    Result := MyClient.ConnectServer( TcpSocket );
end;

procedure TReceivePingMsgHandle.RevRemotePcInfo;
var
  PcName : string;
  Ip, Port : string;
  IsLanConn : Boolean;
  ClientCount : Integer;
  TimeStr : string;
  StartTime : TDateTime;
  RanNum : Integer;
  Params : TMasterInfoAddParams;
begin
    // ��ȡ��Ϣ
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  Ip := MySocketUtil.RevData( TcpSocket );
  Port := MySocketUtil.RevData( TcpSocket );
  IsLanConn := MySocketUtil.RevBoolData( TcpSocket );
  ClientCount := MySocketUtil.RevIntData( TcpSocket );
  TimeStr := MySocketUtil.RevData( TcpSocket );
  StartTime := MyRegionUtil.ReadLocalTime( TimeStr );
  RanNum := MySocketUtil.RevIntData( TcpSocket );

    // ��� Pc
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // ���� Master ��Ϣ
  Params.PcID := PcID;
  Params.ClientCount := ClientCount;
  Params.StartTime := StartTime;
  Params.RanNum := RanNum;
  MasterInfo.AddItem( Params );

    // ���ñ����ӵ�״̬
  if PcID <> PcInfo.PcID then
  begin
    if IsLanConn then
      MyNetworkStatusApi.SetLanSocketSuccess
    else
      MyNetworkStatusApi.SetInternetSocketSuccess;
  end;
end;

procedure TReceivePingMsgHandle.SendMyPcInfo;
begin
  MySocketUtil.SendData( TcpSocket, MyServer.ClientCount );
  MySocketUtil.SendData( TcpSocket, MyRegionUtil.ReadRemoteTimeStr( PcInfo.StartTime ) );
  MySocketUtil.SendData( TcpSocket, PcInfo.RanNum );
end;

function TReceivePingMsgHandle.Update: Boolean;
begin
  RevRemotePcInfo;
  SendMyPcInfo;
  Result := ConnectToCS;
end;

{ TSendMsgBaseHandle }

constructor TSendMsgBaseHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;


{ TSendOnlineConfirmMsgHandle }

procedure TSendConfirmConnectMsgHandle.SendMySocketInfo;
var
  SendIp, SendPort : string;
begin
    // ��ȡ��Ϣ
  if IsLanConn then
  begin
    SendIp := PcInfo.LanIp;
    SendPort := PcInfo.LanPort;
  end
  else
  begin
    SendIp := PcInfo.InternetIp;
    SendPort := PcInfo.InternetPort;
  end;

    // ������Ϣ
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );
  MySocketUtil.SendData( TcpSocket, PcInfo.PcName );
  MySocketUtil.SendData( TcpSocket, SendIp );
  MySocketUtil.SendData( TcpSocket, SendPort );
  MySocketUtil.SendData( TcpSocket, IsLanConn );
end;

procedure TSendConfirmConnectMsgHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TSendConfirmConnectMsgHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TSendConfirmConnectMsgHandle.Update;
begin
  SendMySocketInfo;
end;

{ TReceiveMsgBaseHandle }

constructor TReceiveMsgBaseHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TReceiveOnlineConfirmMsgHandle }

procedure TReceiveConfirmConnectMsgHandle.RevRemoteSocketInfo;
var
  PcID, PcName : string;
  Ip, Port : string;
  IsLanConn : Boolean;
begin
    // ��ȡ��Ϣ
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  Ip := MySocketUtil.RevData( TcpSocket );
  Port := MySocketUtil.RevData( TcpSocket );
  IsLanConn := MySocketUtil.RevBoolData( TcpSocket );

    // ���� Pc �˿���Ϣ
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // ���ñ����ӵ�״̬
  if PcID <> PcInfo.PcID then
  begin
    if IsLanConn then
      MyNetworkStatusApi.SetLanSocketSuccess
    else
      MyNetworkStatusApi.SetInternetSocketSuccess;
  end;
end;

procedure TReceiveConfirmConnectMsgHandle.Update;
begin
  RevRemoteSocketInfo;
end;

{ TMasterReceiveBroadcastThread }

procedure TMasterReceiveBroadcastThread.AddMsg(MsgStr: string);
begin
  MsgLock.Enter;
  MsgList.Add( MsgStr );
  MsgLock.Leave;

  IsRunning := True;
  Resume;
end;

constructor TMasterReceiveBroadcastThread.Create;
begin
  inherited Create;
  MsgLock := TCriticalSection.Create;
  MsgList := TStringList.Create;
  IsRunning := False;
end;

destructor TMasterReceiveBroadcastThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  MsgList.Free;
  MsgLock.Free;
  inherited;
end;

procedure TMasterReceiveBroadcastThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
    MsgStr := getMsg;
    if MsgStr = '' then
    begin
      if not Terminated then
      begin
        IsRunning := False;
        Suspend;
      end;
      Continue;
    end;

    try
      HandleMsg( MsgStr );
    except
    end;
  end;
  inherited;
end;

function TMasterReceiveBroadcastThread.getMsg: string;
begin
  MsgLock.Enter;
  if MsgList.Count > 0 then
  begin
    Result := MsgList[0];
    MsgList.Delete( 0 );
  end
  else
    Result := '';
  MsgLock.Leave;
end;

procedure TMasterReceiveBroadcastThread.HandleMsg(MsgStr: string);
var
  RevBroadcastMsgHandle : TRevBroadcastMsgHandle;
begin
  RevBroadcastMsgHandle := TRevBroadcastMsgHandle.Create( MsgStr );
  RevBroadcastMsgHandle.Update;
  RevBroadcastMsgHandle.Free;
end;

{ TRevBroadcastMsgHandle }

function TRevBroadcastMsgHandle.CheckBroadcastMsg: Boolean;
var
  MsgInfo : TMsgInfo;
  MsgType, MsgStr : string;
  BroadcastEdition : Integer;
begin
    // �ֽ�㲥��Ϣ
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( BroadcastStr );
  MsgType := MsgInfo.MsgType;
  MsgStr := MsgInfo.MsgStr;
  MsgInfo.Free;

  BroadcastEdition := StrToIntDef( MsgType, -1 );
  LanPcMsgStr := MsgStr;

    // ���� �㲥��Ϣ �汾���Ƿ���ȷ
  Result := BroadcastEdition = ConnEdition_Now;

    // ����汾������
  if not Result and ( BroadcastEdition > 0 ) then
    EditionErrorHandle( BroadcastEdition > ConnEdition_Now );
end;

constructor TRevBroadcastMsgHandle.Create(_BroadcastStr: string);
begin
  BroadcastStr := _BroadcastStr;
end;

procedure TRevBroadcastMsgHandle.EditionErrorHandle( IsNewEdition : Boolean );
var
  LanBroadcastMsg : TLanBroadcastMsg;
begin
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetMsgStr( LanPcMsgStr );
  LanIp := LanBroadcastMsg.LanIp;
  NetworkErrorStatusApi.ShowNoEditionMatch( LanIp, IsNewEdition );
  LanBroadcastMsg.Free;
end;

procedure TRevBroadcastMsgHandle.FindBroadcastMsg;
var
  LanBroadcastMsg : TLanBroadcastMsg;
begin
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetMsgStr( LanPcMsgStr );
  PcID := LanBroadcastMsg.PcID;
  PcName := LanBroadcastMsg.PcName;
  LanIp := LanBroadcastMsg.LanIp;
  LanPort := LanBroadcastMsg.LanPort;
  CloudIDNumMD5 := LanBroadcastMsg.CloudIDNumMD5;
  BroadcastType := LanBroadcastMsg.BroadcastType;
  LanBroadcastMsg.Free;
end;

procedure TRevBroadcastMsgHandle.LanSearchHandle;
begin
    // ����
  if PcInfo.PcID = PcID then
    Exit;

    // �Ƿ�����
  if not MyServer.IsBeServer then
    Exit;

    // ����ͻ���
  if MyServer.ClientCount > 1 then
    Exit;

    // �Ǳ�������
  if MyNetworkConnInfo.SelectType <> SelectConnType_Local then
    Exit;

    // ������ ��������
  if not MyTcpUtil.TestConnect( LanIp, LanPort ) then
  begin
    NetworkStatusApi.SetConnInfo( PcID, LanIp, LanPort, False, True );
    Exit;
  end;

    // ���þ�������Ϣ
  NetworkPcApi.SetSocketInfo( PcID, LanIp, LanPort, True );
  NetworkModeApi.SelectLocalConn( PcID );
  MySearchMasterHandler.RestartNetwork; // ��������
end;

procedure TRevBroadcastMsgHandle.SendLanPing;
var
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( PcID );
  MasterSendLanPingInfo.SetSocketInfo( LanIp, LanPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

procedure TRevBroadcastMsgHandle.Update;
begin
    // �㲥��Ϣ ���Ϸ�
  if not CheckBroadcastMsg then
    Exit;

    // ���� �㲥��Ϣ
  FindBroadcastMsg;

    // ���� ��ͬ
  if CloudIDNumMD5 <> CloudSafeSettingInfo.getCloudIDNumMD5 then
    Exit;

    // ��� Pc ��Ϣ
  NetworkPcApi.AddItem( PcID, PcName );

    // �»����߹㲥�� �� Ping ��Ϣ
  if BroadcastType = BroadcastType_StartLan then
    SendLanPing
  else  // ����δ���ӵķ�����
  if BroadcastType = BroadcastType_SearchPc then
    LanSearchHandle;
end;


{ TReceiveAdvanceMsgHandle }

function TReceiveAdvanceMsgHandle.getIsConnectToCS: Boolean;
begin
  Result := False;

    // ���ͱ����Ƿ������
  MySocketUtil.SendJsonStr( TcpSocket, 'IsBeServer', MyServer.IsBeServer );
  if not MyServer.IsBeServer then
    Exit;

    // ���뵽 Client
  Result := MyServer.ConnectClient( TcpSocket );
end;

procedure TReceiveAdvanceMsgHandle.RevRemotePcInfo;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  AdvancePcConnMsg : TAdvancePcConnMsg;
begin
    // ��ȡ��Ϣ
  PcID := MySocketUtil.RevJsonStr( TcpSocket );
  PcName := MySocketUtil.RevJsonStr( TcpSocket );
  LanIp := MySocketUtil.RevJsonStr( TcpSocket );
  LanPort := MySocketUtil.RevJsonStr( TcpSocket );
  InternetIp := MySocketUtil.RevJsonStr( TcpSocket );
  InternetPort := MySocketUtil.RevJsonStr( TcpSocket );

    // ���͸�Server
  AdvancePcConnMsg := TAdvancePcConnMsg.Create;
  AdvancePcConnMsg.SetPcID( PcInfo.PcID );
  AdvancePcConnMsg.SetConnPcInfo( PcID, PcName );
  AdvancePcConnMsg.SetLanSocket( LanIp, LanPort );
  AdvancePcConnMsg.SetInternetSocket( InternetIp, InternetPort );
  MyClient.SendMsgToPc( MyClient.ServerPcID, AdvancePcConnMsg );
end;

procedure TReceiveAdvanceMsgHandle.SendServerInfo;
var
  MasterName : string;
begin
  MasterName := MyNetPcInfoReadUtil.ReadName( MyClient.ServerPcID );

    // ������Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'ServerPcID', MyClient.ServerPcID );
  MySocketUtil.SendJsonStr( TcpSocket, 'MasterName', MasterName );
  MySocketUtil.SendJsonStr( TcpSocket, 'ServerLanIp', MyClient.ServerLanIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'ServerLanPort', MyClient.ServerLanPort );
  MySocketUtil.SendJsonStr( TcpSocket, 'ServerInternetIp', MyClient.ServerInternetIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'ServerInternetPort', MyClient.ServerInternetPort );
end;

function TReceiveAdvanceMsgHandle.Update: Boolean;
var
  RandomNumber : string;
  CloudIDStr, CloudIDNumMD5 : string;
  CloudIDList : TStringList;
  IsSuccess : Boolean;
  IsConnectServer : Boolean;
begin
  Result := False;

    // ���������Ϣ
  Randomize;
  RandomNumber := IntToStr( Random( 1000000000 ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'RandomNumber', RandomNumber ); // ���������������

  CloudIDStr := MySocketUtil.RevJsonStr( TcpSocket ); // ��� SecurityID
  CloudIDStr := MyEncrypt.DecodeStr( CloudIDStr );
  CloudIDList := MySplitStr.getList( CloudIDStr, CloudIdNumber_Split );
  IsSuccess := False;
  if ( CloudIDList.Count = CloudIdNumber_SplitCount ) and
     ( CloudIDList[ CloudIdNumber_Random ] = RandomNumber ) then
  begin
    CloudIDNumMD5 := CloudIDList[ CloudIdNumber_SecurityID ];
    if CloudIDNumMD5 = CloudIdNumber_Empty then
      CloudIDNumMD5 := '';
    IsSuccess := CloudIDNumMD5 = CloudSafeSettingInfo.getCloudIDNumMD5;
  end;
  CloudIDList.Free;

  MySocketUtil.SendJsonStr( TcpSocket, 'IsSuccess', IsSuccess );
  if not IsSuccess then  // ������ͬ
    Exit;

    // �Ƿ��Ѿ����� Server
  IsConnectServer := MyClient.IsConnServer;
  MySocketUtil.SendJsonStr( TcpSocket, 'IsConnectServer', IsConnectServer );
  if not IsConnectServer then
    Exit;

    // �����Ƿ����� ���ӵ� CS
  if getIsConnectToCS then
  begin
    Result := True;
    Exit;
  end;

    // ���� Server ����Ϣ
  SendServerInfo;

    // ���� Pc ��Ϣ��ת���� Server
  RevRemotePcInfo;
end;

{ TLanBroadcastMsg }

procedure TLanBroadcastMsg.SetBroadcastType(_BroadcastType: string);
begin
  BroadcastType := _BroadcastType;
end;

procedure TLanBroadcastMsg.SetCloudIDNumMD5(_CloudIDNumMD5: string);
begin
  CloudIDNumMD5 := _CloudIDNumMD5;
end;

procedure TLanBroadcastMsg.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TLanBroadcastMsg.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLanBroadcastMsg.SetSocketInfo(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

{ TMasterConnClientInfo }

constructor TMasterConnClientInfo.Create(_ClientPcID: string);
begin
  ClientPcID := _ClientPcID;
end;

end.

