unit UMyMaster;

interface

uses UChangeInfo, UMyUtil, UMyNetPcInfo, UMyTcp, Sockets, SysUtils, uDebug, classes,
     Generics.Collections, Syncobjs, DateUtils, UMyDebug, uDebugLock;

type

{$Region ' 广播信息 数据结构 ' }

    // 局域网 广播
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


{$Region ' 发送 数据结构 ' }

    // 父类
  TMasterSendInfo = class
  end;
  TMasterSendList = class( TObjectList<TMasterSendInfo> )end;

    // 成为服务器，连接客户端
  TMasterConnClientInfo = class( TMasterSendInfo )
  public
    ClientPcID : string;
  public
    constructor Create( _ClientPcID : string );
  end;

    // 发送连接信息 父类
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

    // 发送 Lan Ping
  TMasterSendLanPingInfo = class( TMasterSendConnInfo )
  end;

    // 发送 Internet 信息
  TMasterSendInternerInfo = class( TMasterSendConnInfo )
  public
    InternetIp, InternetPort : string;
  public
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;

    // 发送 Internet Ping
  TMasterSendInternetPingInfo = class( TMasterSendInternerInfo )
  end;

    // 发送 上线确认
  TMasterSendConfirmConnectInfo = class( TMasterSendInternerInfo )
  end;

{$EndRegion}

{$Region ' 发送 命令处理 ' }

    // 连接发送 父类
  TSendMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // Ping 命令
  TSendPingMsgHandle = class( TSendMsgBaseHandle )
  public
    PcID : string;
    IsLanConn : Boolean;
  public
    procedure SetPcID( _PcID : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    function Update: Boolean;  // 端口用作CS则返回 True
  private
    procedure SendMyPcInfo;   // 发送本机信息
    procedure RevRemotePcInfo;  // 接收远程信息
    function ConnectToCS: Boolean; // 是否立刻进行CS连接
  end;

    // 确认连接命令
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

{$Region ' 发送 处理线程 ' }

    // 处理连接
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
  private      // 连接
    function ConnToSocket : Boolean;
    function ConnToInternetSocket : Boolean;
    function ConnToPc( ConnIp, ConnPort : string ): Boolean;
  private      // 记录连接信息
    procedure MarkNotConnected;
  private      // 处理命令信息
    procedure HandleSend;
    procedure HandlePing;
    procedure HandleConfirmConect;
  end;

    // 发送线程
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

    // 底层命令发送
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
    function getIsRuning : Boolean; // 是否在发送命令
  public
    procedure AddMasterSend( MasterSendInfo : TMasterSendInfo );
    procedure AddMasterBusySend( MasterSendInfo : TMasterSendConnInfo );
    function getMasterSendInfo : TMasterSendInfo;
    procedure RemoveThread( ThreadID : Cardinal );
  end;


{$Region ' 接收 命令处理 ' }

    // 处理广播命令
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
  private       // 程序版本不兼容
    procedure EditionErrorHandle( IsNewEdition : Boolean );
  end;

    // 接收命令 父类
  TReceiveMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // 接收 Ping 命令
  TReceivePingMsgHandle = class( TReceiveMsgBaseHandle )
  private
    PcID : string;
  public
    function Update: Boolean;  // 已连接 CS 则返回 True
  private
    procedure RevRemotePcInfo;  // 接收远程信息
    procedure SendMyPcInfo;   // 发送本机信息
    function ConnectToCS: Boolean; // 连接客户端
  end;

    // 确认连接 命令
  TReceiveConfirmConnectMsgHandle = class( TReceiveMsgBaseHandle )
  public
    procedure Update;
  private
    procedure RevRemoteSocketInfo;
  end;

    // Advance 连接
  TReceiveAdvanceMsgHandle = class( TReceiveMsgBaseHandle )
  public
    function Update: Boolean; // 连接到 CS 返回 True
  private
    procedure RevRemotePcInfo;
    procedure SendServerInfo;
    function getIsConnectToCS: Boolean;
  end;

{$EndRegion}

{$Region ' 接收 处理线程 ' }

    // 处理接收命令线程
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

    // 处理广播命令 线程
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
    function getIsRuning : Boolean; // 是否在接收命令
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
          // 连接客户端信息
      if MasterSendInfo is TMasterConnClientInfo then
        HandleConnClient( MasterSendInfo as TMasterConnClientInfo )
      else  // 连接发送信息
      if MasterSendInfo is TMasterSendConnInfo then
      begin
        MasterSendConnInfo := MasterSendInfo as TMasterSendConnInfo;
        if not HandleSend( MasterSendConnInfo ) then // 未处理完成
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

    // 连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ClientIp, ClientPort );
  MyTcpConn.SetConnType( ConnType_Client );
  IsSuccessConn := MyTcpConn.Conn and MyServer.ConnectClient( TcpSocket );
  MyTcpConn.Free;

    // 未连接
  if not IsSuccessConn then
    TcpSocket.Free;
end;

function TMasterSendThread.HandleSend(MasterSendConnInfo: TMasterSendConnInfo): Boolean;
var
  MasterSendHandle : TMasterSendHandle;
begin
  DebugLock.Debug( 'HandleSend: ' + MasterSendConnInfo.ClassName );

  Result := False;

    // 繁忙的发送命令
  if MasterSendConnInfo.SendTime > Now then
  begin
    Sleep(100);
    MyMasterSendHandler.AddMasterSend( MasterSendConnInfo );
    Exit;
  end;

    // 处理发送
  MasterSendHandle := TMasterSendHandle.Create( MasterSendConnInfo );
  Result := MasterSendHandle.Update;
  MasterSendHandle.Free;

    // 接收方繁忙
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
  MasterSendInfo.SetSendTime( IncSecond( Now, 1 ) ); // 1 秒后再连接
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

    // 连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ConnIp, ConnPort );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    Result := MySocketUtil.RevJsonStr( TcpSocket ) = MasterSendInfo.PcID;
    MySocketUtil.SendJsonStr( TcpSocket, 'IsSuccess', Result );
    if not Result then
      TcpSocket.Disconnect; // 连接错误
  end
  else
    Result := False;
  MyTcpConn.Free;

    // 连接成功
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

    // 设置 端口信息
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 发送 请求命令
  MySocketUtil.SendJsonStr( TcpSocket, 'MsgType', MsgType_SearchServer_Ping );

    // Ping 命令
  SendPingMsgHandle := TSendPingMsgHandle.Create( TcpSocket );
  SendPingMsgHandle.SetPcID( PcID );
  SendPingMsgHandle.SetIsLanConn( IsLanConn );
  IsConnectCS := SendPingMsgHandle.Update;
  SendPingMsgHandle.Free;

    // 端口已用作 CS，不用释放
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterSendHandle.HandleConfirmConect;
var
  SendConfirmConnectMsgHandle : TSendConfirmConnectMsgHandle;
begin
  DebugLock.Debug( 'HandleConfirmConect' );

    // 设置 端口信息
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 发送请求命令
  MySocketUtil.SendJsonStr( TcpSocket, 'MsgType', MsgType_SearchServer_ConfirmConnect );

    // 网络信息 确认
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

    // 局域网 不能连接
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInfo.Ip, MasterSendInfo.Port, False, True );

    // 非 Internet
  if not ( MasterSendInfo is TMasterSendInternerInfo ) then
    Exit;
    
    // Internet 不能连接
  MasterSendInterInfo := MasterSendInfo as TMasterSendInternerInfo;
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInterInfo.InternetIp, MasterSendInterInfo.InternetPort, False, False );
end;

function TMasterSendHandle.Update: Boolean;
var
  IsBusy : Boolean;
begin
  Result := True;

    // 无法连接
  if not ConnToSocket and not ConnToInternetSocket then
  begin
    MarkNotConnected; // 记录不能连接
    Exit;
  end;

    // 是否接收繁忙
  IsBusy := MySocketUtil.RevJsonBool( TcpSocket );
  if IsBusy then
  begin
    Result := False; // 繁忙
    Exit;
  end;

    // 连接后的处理
  HandleSend;
end;

{ TPingMsgHandle }

function TSendPingMsgHandle.ConnectToCS: Boolean;
var
  LocalIsServer, LocalIsClient : Boolean;
  RemoteIsServer, RemoteIsClient : Boolean;
  IsConnected : Boolean;
begin
    // 发送 本地C/S信息
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendData( TcpSocket, LocalIsServer );
  MySocketUtil.SendData( TcpSocket, LocalIsClient );

    // 接收 远程C/S信息
  RemoteIsServer := MySocketUtil.RevBoolData( TcpSocket );
  RemoteIsClient := MySocketUtil.RevBoolData( TcpSocket );

    // 本机是服务器
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
    // 接收信息
  ClientCount := MySocketUtil.RevIntData( TcpSocket );
  TimeStr := MySocketUtil.RevData( TcpSocket );
  StartTime := MyRegionUtil.ReadLocalTime( TimeStr );
  RanNum := MySocketUtil.RevIntData( TcpSocket );

    // 设置 Master 信息
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
    // 提取信息
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

    // 发送信息
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

    // 处理命令
  try
    HandleReceive;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Master Receive Msg', e.Message );
  end;

    // 端口用作 CS 则不删除端口
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

    // 已连接到 CS
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

    // Socket 已经连接到 CS，不用释放
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

    // 正在处理广播
  if MasterReceiveBroadcastThread.IsRunning then
  begin
    Result := True;
    Exit;
  end;

    // 正在处理链接命令
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
    // 程序结束
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // 判断连接是否正确
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  IsSuccess := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsSuccess then  // 连接错误
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 获取非繁忙线程处理连接
  ThreadLock.Enter;
  IsBusy := True;
  if MasterReceiveThreadList.Count < ThreadCount_MasterMsg then
  begin
    IsBusy := False;
    NewThread := TMasterReceiveThread.Create;
    MasterReceiveThreadList.Add( NewThread );

    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', False ); // 发送非繁忙
    NewThread.SetTcpSocket( TcpSocket );
    NewThread.Resume;
  end;
  ThreadLock.Leave;

    // 繁忙则结束
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', True ); // 发送繁忙
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
    // 接收 远程C/S信息
  RemoteIsServer := MySocketUtil.RevBoolData( TcpSocket );
  RemoteIsClient := MySocketUtil.RevBoolData( TcpSocket );

      // 发送 本地C/S信息
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendData( TcpSocket, LocalIsServer );
  MySocketUtil.SendData( TcpSocket, LocalIsClient );

    // 本机是服务器
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
    // 获取信息
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  Ip := MySocketUtil.RevData( TcpSocket );
  Port := MySocketUtil.RevData( TcpSocket );
  IsLanConn := MySocketUtil.RevBoolData( TcpSocket );
  ClientCount := MySocketUtil.RevIntData( TcpSocket );
  TimeStr := MySocketUtil.RevData( TcpSocket );
  StartTime := MyRegionUtil.ReadLocalTime( TimeStr );
  RanNum := MySocketUtil.RevIntData( TcpSocket );

    // 添加 Pc
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 设置 Master 信息
  Params.PcID := PcID;
  Params.ClientCount := ClientCount;
  Params.StartTime := StartTime;
  Params.RanNum := RanNum;
  MasterInfo.AddItem( Params );

    // 设置被连接的状态
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
    // 提取信息
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

    // 发送信息
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
    // 获取信息
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  Ip := MySocketUtil.RevData( TcpSocket );
  Port := MySocketUtil.RevData( TcpSocket );
  IsLanConn := MySocketUtil.RevBoolData( TcpSocket );

    // 设置 Pc 端口信息
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 设置被连接的状态
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
    // 分解广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( BroadcastStr );
  MsgType := MsgInfo.MsgType;
  MsgStr := MsgInfo.MsgStr;
  MsgInfo.Free;

  BroadcastEdition := StrToIntDef( MsgType, -1 );
  LanPcMsgStr := MsgStr;

    // 返回 广播信息 版本号是否正确
  Result := BroadcastEdition = ConnEdition_Now;

    // 程序版本不兼容
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
    // 本机
  if PcInfo.PcID = PcID then
    Exit;

    // 非服务器
  if not MyServer.IsBeServer then
    Exit;

    // 多个客户端
  if MyServer.ClientCount > 1 then
    Exit;

    // 非本地网络
  if MyNetworkConnInfo.SelectType <> SelectConnType_Local then
    Exit;

    // 局域网 不能连接
  if not MyTcpUtil.TestConnect( LanIp, LanPort ) then
  begin
    NetworkStatusApi.SetConnInfo( PcID, LanIp, LanPort, False, True );
    Exit;
  end;

    // 设置局域网信息
  NetworkPcApi.SetSocketInfo( PcID, LanIp, LanPort, True );
  NetworkModeApi.SelectLocalConn( PcID );
  MySearchMasterHandler.RestartNetwork; // 重启网络
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
    // 广播信息 不合法
  if not CheckBroadcastMsg then
    Exit;

    // 解释 广播信息
  FindBroadcastMsg;

    // 子网 不同
  if CloudIDNumMD5 <> CloudSafeSettingInfo.getCloudIDNumMD5 then
    Exit;

    // 添加 Pc 信息
  NetworkPcApi.AddItem( PcID, PcName );

    // 新机上线广播， 发 Ping 信息
  if BroadcastType = BroadcastType_StartLan then
    SendLanPing
  else  // 搜索未连接的服务器
  if BroadcastType = BroadcastType_SearchPc then
    LanSearchHandle;
end;


{ TReceiveAdvanceMsgHandle }

function TReceiveAdvanceMsgHandle.getIsConnectToCS: Boolean;
begin
  Result := False;

    // 发送本机是否服务器
  MySocketUtil.SendJsonStr( TcpSocket, 'IsBeServer', MyServer.IsBeServer );
  if not MyServer.IsBeServer then
    Exit;

    // 加入到 Client
  Result := MyServer.ConnectClient( TcpSocket );
end;

procedure TReceiveAdvanceMsgHandle.RevRemotePcInfo;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  AdvancePcConnMsg : TAdvancePcConnMsg;
begin
    // 获取信息
  PcID := MySocketUtil.RevJsonStr( TcpSocket );
  PcName := MySocketUtil.RevJsonStr( TcpSocket );
  LanIp := MySocketUtil.RevJsonStr( TcpSocket );
  LanPort := MySocketUtil.RevJsonStr( TcpSocket );
  InternetIp := MySocketUtil.RevJsonStr( TcpSocket );
  InternetPort := MySocketUtil.RevJsonStr( TcpSocket );

    // 发送给Server
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

    // 发送信息
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

    // 检测子网信息
  Randomize;
  RandomNumber := IntToStr( Random( 1000000000 ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'RandomNumber', RandomNumber ); // 产生随机数并发送

  CloudIDStr := MySocketUtil.RevJsonStr( TcpSocket ); // 检测 SecurityID
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
  if not IsSuccess then  // 子网不同
    Exit;

    // 是否已经连接 Server
  IsConnectServer := MyClient.IsConnServer;
  MySocketUtil.SendJsonStr( TcpSocket, 'IsConnectServer', IsConnectServer );
  if not IsConnectServer then
    Exit;

    // 本机是服务器 连接到 CS
  if getIsConnectToCS then
  begin
    Result := True;
    Exit;
  end;

    // 发送 Server 的信息
  SendServerInfo;

    // 接收 Pc 信息，转发给 Server
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

