unit UMyClient;

interface

uses Classes, Sockets, UChangeInfo, SyncObjs, UMyUtil, SysUtils,UMyNetPcInfo, DateUtils, UModelUtil,
     uDebug, UFileBaseInfo, UMyDebug, uDebugLock;

type

{$Region ' Client 父类信息 ' }

  TPcMsgBase = class( TMsgBase )
  public
    iPcID : string;
  published
    property PcID : string Read iPcID Write iPcID;
  public
    procedure SetPcID( _PcID : string );
  end;

{$EndRegion}

{$Region ' Client 状态信息 ' }

    // Online 父类
  TPcOnlineMsgBase = class( TPcMsgBase )
  public
    iPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
  published
    property PcName : string Read iPcName Write iPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    procedure SetPcName( _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
    procedure Update;override;
  private
    procedure SendConfirmConect;
  end;

    // Pc Online 信息
  TPcOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendBackPcOnline;
  end;

    // Pc 返回 Online 信息
  TPcBackOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // Pc Offline 信息
  TPcOfflineMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SetNetPcOffline;
  end;

    // Pc 信息
  TPcHeartBeatMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

      // 信息工厂
  TPcStatusMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 文件发送信息 ' }

  {$Region ' 接收 根路径 修改 ' }

    // 接收路径 修改父类
  TReceiveRootItemChangeMsg = class( TPcMsgBase )
  public
    iReceiveRootPath : string;
  published
    property ReceiveRootPath : string Read iReceiveRootPath Write iReceiveRootPath;
  public
    procedure SetReceiveRootPath( _ReceiveRootPath : string );
  protected
    function getSendRootItemID : string;
  end;

    // 添加
  TReceiveRootItemAddMsg = class( TReceiveRootItemChangeMsg )
  public
    iAvailableSpace : Int64;
  published
    property AvailableSpace : Int64 Read iAvailableSpace Write iAvailableSpace;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 设置可用空间信息
  TReceiveRootItemSetAvailableSpaceMsg = class( TReceiveRootItemChangeMsg )
  public
    iAvailableSpace : Int64;
  published
    property AvailableSpace : Int64 Read iAvailableSpace Write iAvailableSpace;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 删除
  TReceiveRootItemRemoveMsg = class( TReceiveRootItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 发送 源路径 修改 ' }

    // 父类
  TSendItemChangeMsg = class( TReceiveRootItemChangeMsg )
  public
    iSourcePath : string;
  published
    property SourcePath : string Read iSourcePath Write iSourcePath;
  public
    procedure SetSourcePath( _SourcePath : string );
  end;

    // 添加 Send Item
  TSendItemAddMsg = class( TSendItemChangeMsg )
  public
    iIsFile, iIsZip : Boolean;
  published
    property IsFile : Boolean Read iIsFile Write iIsFile;
    property IsZip : Boolean Read iIsZip Write iIsZip;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsZip( _IsZip : Boolean );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure AddReceiveItem;
    procedure SetReceiveAgain;
    procedure FeedBack;
  end;

    // 添加 Send Item 成功
  TSendItemAddCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 等待发送
  TSendItemWaitingMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  public
    procedure FeedBack;
  end;

    // 等待发送 完成
  TSendItemWaitingCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 删除 Send Item
  TSendItemRemoveMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure FeedBack;
  end;

    // 删除 Send Item 成功
  TSendItemRemoveCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 接收 源路径 修改 ' }

    // 接收方删除
  TReceiveItemRemoveMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 反向连接 ' }

    // 请求反向连接
  TSendItemBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 反向连接 繁忙
  TSendItemBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 反向连接 失败
  TSendItemBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

    // 文件传输 工厂
  TSendFileMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 文件共享信息 ' }

  {$Region ' 共享路径增删 ' }

    // 父类
  TSharePathChangeMsg = class( TPcMsgBase )
  public
    iSharePath : string;
  published
    property SharePath : string Read iSharePath Write iSharePath;
  public
    procedure SetSharePath( _SharePath : string );
  end;

    // 添加
  TSharePathAddMsg = class( TSharePathChangeMsg )
  public
    iIsFile : Boolean;
    iIsNewShare : Boolean;
  published
    property IsFile : Boolean Read iIsFile Write iIsFile;
    property IsNewShare : Boolean Read iIsNewShare Write iIsNewShare;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsNewShare( _IsNewShare : Boolean );
  public
    constructor Create;
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 删除
  TSharePathRemoveMsg = class( TSharePathChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 反向连接 共享下载 ' }

      // 请求反向连接
  TShareDownBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 反向连接 繁忙
  TShareDownBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 反向连接 失败
  TShareDownBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}


      // 文件共享 工厂
  TFileShareMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 注册信息 '}

    // 注册信息
  TActivatePcMsg = class( TPcMsgBase )
  private
    iLicenseStr : string;
  published
    property LicenseStr : string Read iLicenseStr Write iLicenseStr;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure FeedBack;
  end;

    // 注册完成
  TActivatePcCompletedMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 显示注册信息
  TRegisterShowMsg = class( TPcMsgBase )
  public
    iHardCode : string;
    iRegisterEdition : string;
  published
    property HardCode : string Read iHardCode Write iHardCode;
    property RegisterEdition : string Read iRegisterEdition Write iRegisterEdition;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 云信息工厂
  TRegisterMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Advance 网络 Pc 信息 ' }

  TAdvancePcConnMsg = class( TPcMsgBase )
  private
    iConnPcID, iConnPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
  published
    property ConnPcID : string Read iConnPcID Write iConnPcID;
    property ConnPcName : string Read iConnPcName Write iConnPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    procedure SetConnPcInfo( _ConnPcID, _ConnPcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure AddNetworkPc;
    procedure AddPingMsg;
  end;

  TAdvanceConnMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}


{$Region ' Client 接收线程 ' }

    // 接收 服务器信息 的线程
  TClientRevMsgThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  private
    MsgFactoryList : TMsgFactoryList;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure IniMsgFactory;
    function WaitServerMsg: string;
    procedure HandleServerMsg( MsgStr : string );
    procedure ServerLostConn;
  end;

{$EndRegion}

{$Region ' Client 发送线程 ' }

  TClientSendMsgThread = class( TDebugThread )
  public
    MsgLock : TCriticalSection;
    SendMsgList : TStringList; // 发送命令队列
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure AddSendMsg( MsgStr : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextMsg : string;
    procedure SendMsg( MsgStr : string );
  end;

{$EndRegion}

{$Region ' Client 心跳线程 ' }

    // 心跳
  TClientHeartBeatHandle = class
  public
    procedure Update;
  private
    procedure SendHeartBeat;
    procedure SendCloudAvailableSpace;
  end;

{$EndRegion}


    // 客户端定时 Api
  MyClientOnTimerApi = class
  public
    class procedure SendHeartBeat;
  end;

    // 客户端信息
  TMyClient = class
  private
    ClientLock : TCriticalSection;
    ClientSocket : TCustomIpClient;  // 与服务器通信接口
    ClientRevMsgThread : TClientRevMsgThread;  // 接收命令线程
    ClientSendMsgThread : TClientSendMsgThread; // 发送命令线程
  public
    IsRun, IsConnServer : Boolean;
    ServerPcID : string;
    ServerLanIp, ServerLanPort : string;
    ServerInternetIp, ServerInternetPort : string;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public        // 发送命令
    procedure SendMsgToPc( PcID : string; MsgBase : TMsgBase );
    procedure SendMsgToAll( MsgBase : TMsgBase );
  public        // 连接/断开 服务器
    function ConnectServer( TcpSocket : TCustomIpClient ): Boolean;
    procedure AcceptServer( TcpSocket : TCustomIpClient );
    procedure ClientLostConn;  // 结束客户端网络时，调用
    procedure ServerLostConn; // 服务器断开时，调用
  private        // 连接
    function getIsAddClient( TcpSocket : TCustomIpClient ): Boolean;
    procedure AddClient( TcpSocket : TCustomIpClient );
  end;

const
  ThreadCount_ServerMsg : Integer = 2;

  MsgType_PcStatus = 'ps_';
  MsgType_PcStatus_Online = 'ps_ol';
  MsgType_PcStatus_BackOnline = 'ps_bol';
  MsgType_PcStatus_Offline = 'ps_Ofl';
  MsgType_PcStatus_HeartBeat = 'ps_hb';

  MsgType_Register = 'rt_';
  MsgType_Register_ActivatePc = 'rt_ap';
  MsgType_Register_ActivatePcCompeted = 'rt_apc';
  MsgType_Register_RegisterShow = 'rt_rs';

  MsgType_SendFile = 'sf_';
  MsgType_SendFile_AddReceiveRootItem = 'sf_arri';
  MsgType_SendFile_RemoveReceiveRootItem = 'sf_rrri';
  MsgType_SendFile_ReceiveRootItemAvailableSpace = 'sf_rrias';
  MsgType_SendFile_AddSendItem = 'sf_asi';
  MsgType_SendFile_AddSendItemCompleted = 'sf_asic';
  MsgType_SendFile_RemoveSendItem = 'sf_rsi';
  MsgType_SendFile_RemoveSendItemCompleted = 'sf_rsic';
  MsgType_SendFile_WaitingSendItem = 'sf_wsi';
  MsgType_SendFile_WaitingSendItemCompleted = 'sf_wsic';
  MsgType_SendFile_RemoveReceiveItem = 'sf_rri';
  MsgType_SendFile_BackConn = 'sf_bc';
  MsgType_SendFile_BackConnBusy = 'sf_bcc';
  MsgType_SendFile_BackConnError = 'sf_bcr';

  MsgType_SharePath = 'sp_';
  MsgType_SharePath_AddItem = 'sp_ai';
  MsgType_SharePath_RemoveItem = 'sp_ri';
  MsgType_SharePath_DownBackConn = 'sp_dbc';
  MsgType_SharePath_DownBackConnBusy = 'sp_dbcc';
  MsgType_SharePath_DownBackConnError = 'sp_dbcr';
  MsgType_SharePath_ExplorerBackConn = 'sp_ebc';
  MsgType_SharePath_ExplorerBackConnBusy = 'sp_ebcc';
  MsgType_SharePath_ExplorerBackConnError = 'sp_ebcr';
  MsgType_SharePath_PreviewBackConn = 'sp_pbc';
  MsgType_SharePath_PreviewBackConnBusy = 'sp_pbcc';
  MsgType_SharePath_PreviewBackConnError = 'sp_pbcr';
  MsgType_SharePath_SearchBackConn = 'sp_sbc';
  MsgType_SharePath_SearchBackConnBusy = 'sp_sbcc';
  MsgType_SharePath_SearchBackConnError = 'sp_sbcr';

  MsgType_AdvancePc = 'ap_';
var
  MyClient : TMyClient;

implementation

uses UMyServer,  UNetworkFace, UMyMaster, USearchServer, UMyTcp, UMySendApiInfo,
     UNetPcInfoXml, USettingInfo, UMySendDataInfo,USendThread,
     UNetworkControl,
     UMyReceiveDataInfo, UMyReceiveApiInfo,
     UMyShareDownApiInfo, UMyShareApiInfo, UShareDownThread, UMyTimerThread,
     UMyregisterApiInfo;

{ TRevServerMsgThread }

procedure TClientRevMsgThread.HandleServerMsg(MsgStr: string);
var
  i : Integer;
  MsgInfo : TMsgInfo;
  MsgFactory : TMsgFactory;
  MsgBase : TMsgBase;
begin
  DebugLock.Debug( 'HandleRev' );

  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( MsgStr );
  for i := 0 to MsgFactoryList.Count - 1 do
  begin
    MsgFactory := MsgFactoryList[i];
    MsgFactory.SetMsg( MsgInfo.MsgType );
    if MsgFactory.CheckType then
    begin
      MsgBase := MsgFactory.get;
      if MsgBase <> nil then
      begin
        MsgBase.SetMsgStr( MsgInfo.MsgStr );
        MsgBase.Update;
        MsgBase.Free;
      end;
      Break;
    end;
  end;
  MsgInfo.Free;
end;

constructor TClientRevMsgThread.Create( _TcpSocket : TCustomIpClient );
begin
  inherited Create;
  TcpSocket := _TcpSocket;

  MsgFactoryList := TMsgFactoryList.Create;
  IniMsgFactory;
end;

destructor TClientRevMsgThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  MsgFactoryList.Free;
  inherited;
end;

procedure TClientRevMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
      // 等待服务器的信息
    MsgStr := WaitServerMsg;
    if MsgStr = ''  then  // 断开连接
    begin
      ServerLostConn; // 服务器断开事件
      Break;
    end
    else
    begin
      try
        HandleServerMsg( MsgStr );  // 处理接收的命令
      except
        on  E: Exception do
          MyWebDebug.AddItem( 'Client Rev Msg', e.Message );
      end;
    end;
  end;

  inherited;
end;

procedure TClientRevMsgThread.IniMsgFactory;
var
  MsgFactory : TMsgFactory;
begin
    // Pc 状态命令
  MsgFactory := TPcStatusMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // CloudPcInfo
  MsgFactory := TRegisterMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // CloudPcInfo
  MsgFactory := TFileShareMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // Advance
  MsgFactory := TAdvanceConnMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // Network Backup
  MsgFactory := TSendFileMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );
end;

function TClientRevMsgThread.WaitServerMsg: string;
begin
  DebugLock.Debug( 'WaitServerData' );
  Result := MySocketUtil.RevData( TcpSocket, WaitTime_RevClient );
end;

procedure TClientRevMsgThread.ServerLostConn;
begin
  DebugLock.Debug( 'ServerLostConn' );
  MyClient.ServerLostConn;  // 服务器断开事件
end;

{ TMyClient }

constructor TMyClient.Create;
begin
  IsRun := True;
  IsConnServer := False;
  ClientLock := TCriticalSection.Create;
end;

destructor TMyClient.Destroy;
begin
  ClientLock.Free;
  inherited;
end;

function TMyClient.getIsAddClient(TcpSocket: TCustomIpClient): Boolean;
var
  IsServer, IsExistClient : Boolean;
begin
  Result := False;

    // 已结束
  if not IsRun then
    Exit;

    // 获取对方是否 Server
  IsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsServer then
    Exit;

    // 发送是否已连接服务器
  MySocketUtil.SendJsonStr( TcpSocket, 'IsConnServer', IsConnServer );
  if IsConnServer then
    Exit;

    // 是否存在客户端
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );  // 发送本机标识
  IsExistClient := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsExistClient then // 已存在客户端
    Exit;

    // 添加
  AddClient( TcpSocket );

  Result := True;
end;

procedure TMyClient.AcceptServer(TcpSocket: TCustomIpClient);
begin
  if not ConnectServer( TcpSocket ) then
    TcpSocket.Free;
end;

procedure TMyClient.AddClient(TcpSocket: TCustomIpClient);
var
  PcOnlineMsg : TPcOnlineMsg;
begin
    // 设置客户端 Socket
  ClientSocket := TcpSocket;

    // 发送 Pc 标识， 获取 Server 基本信息
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  ServerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanPort := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetPort := MySocketUtil.RevJsonStr( TcpSocket );

    // 发送信息 线程
  ClientSendMsgThread := TClientSendMsgThread.Create( TcpSocket );

    // 接收信息 线程
  ClientRevMsgThread := TClientRevMsgThread.Create( TcpSocket );
  ClientRevMsgThread.Resume;

    // 发送心跳 线程
  MyTimerHandler.AddTimer( HandleType_ClientHeartBeat, 180 );

    // 设置 成为 Master
  NetworkPcApi.BeServer( ServerPcID );

    // 标记已经连接 Server
  IsConnServer := True;

    // 发送上线信息
  PcOnlineMsg := TPcOnlineMsg.Create;
  PcOnlineMsg.SetPcID( PcInfo.PcID );
  PcOnlineMsg.SetPcName( PcInfo.PcName );
  PcOnlineMsg.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  PcOnlineMsg.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );
  SendMsgToAll( PcOnlineMsg );
end;

procedure TMyClient.ClientLostConn;
begin
  if not IsConnServer then
    Exit;

    // 停止接收命令
  IsConnServer := False;

    // 结束网络连接
  ClientSocket.Disconnect;
  ClientRevMsgThread.Free;
  ClientSendMsgThread.Free;
  MyTimerHandler.RemoveTimer( HandleType_ClientHeartBeat );
  ClientSocket.Free;
end;

function TMyClient.ConnectServer(TcpSocket: TCustomIpClient): Boolean;
begin
  ClientLock.Enter;
  Result := getIsAddClient( TcpSocket );
  ClientLock.Leave;
end;

procedure TMyClient.SendMsgToAll(MsgBase: TMsgBase);
var
  MsgStr : string;
  SendClientAllMsg : TSendClientAllMsg;
  SendMsgStr : string;
begin
    // 程序结束
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

  MsgStr := MsgBase.getMsg;

    // 请求服务器 转发所有 Pc
  SendClientAllMsg := TSendClientAllMsg.Create;
  SendClientAllMsg.SetSendMsgStr( MsgStr );

  SendMsgStr := SendClientAllMsg.getMsg;
  ClientSendMsgThread.AddSendMsg( SendMsgStr );

  SendClientAllMsg.Free;

  MsgBase.Free;
end;

procedure TMyClient.SendMsgToPc(PcID: string; MsgBase: TMsgBase);
var
  SendClientMsg : TSendClientMsg;
  MsgStr : string;
begin
    // 程序结束
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

    // 请求服务器 转发 Pc
  SendClientMsg := TSendClientMsg.Create;
  SendClientMsg.SetTargetPcID( PcID );
  SendClientMsg.SetSendMsgBase( MsgBase );

  MsgStr := SendClientMsg.getMsg;
  ClientSendMsgThread.AddSendMsg( MsgStr );

  SendClientMsg.Free;
  MsgBase.Free;
end;

procedure TMyClient.ServerLostConn;
begin
  if not IsConnServer then
    Exit;

    // 重启网络
  MySearchMasterHandler.RestartNetwork;
end;


procedure TMyClient.StopRun;
begin
  IsRun := False;
end;

{ TServerTramitMsgFactory }

constructor TPcStatusMsgFactory.Create;
begin
  inherited Create( MsgType_PcStatus );
end;

function TPcStatusMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_PcStatus_Online then
    Result := TPcOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_BackOnline then
    Result := TPcBackOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_Offline then
    Result := TPcOfflineMsg.Create
  else
  if MsgType = MsgType_PcStatus_HeartBeat then
    Result := TPcHeartBeatMsg.Create
  else
    Result := nil;
end;

{ TPcOnlineMsg }

function TPcOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Online;
end;

procedure TPcOnlineMsg.SendBackPcOnline;
var
  PcBackOnlineMsg : TPcBackOnlineMsg;
begin
    // Back Online Msg
  PcBackOnlineMsg := TPcBackOnlineMsg.Create;
  PcBackOnlineMsg.SetPcID( PcInfo.PcID );
  PcBackOnlineMsg.SetPcName( PcInfo.PcName );
  PcBackOnlineMsg.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  PcBackOnlineMsg.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );

  MyClient.SendMsgToPc( PcID, PcBackOnlineMsg );
end;

procedure TPcOnlineMsg.Update;
begin
  inherited;

    // 发送 本机 online 信息
  SendBackPcOnline;

    // Pc 上线 事件
  NetworkPcApi.PcOnline( PcID );
end;

{ TPcBackOnlineMsg }

function TPcBackOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_BackOnline;
end;

procedure TPcBackOnlineMsg.Update;
begin
  inherited;

    // Pc 上线
  NetworkPcApi.PcOnline( PcID );
end;

{ TPcOfflineMsg }

procedure TPcOfflineMsg.SetNetPcOffline;
begin
  NetworkPcApi.PcOffline( PcID );
end;

function TPcOfflineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Offline;
end;

procedure TPcOfflineMsg.Update;
begin
    // 网络状态
  SetNetPcOffline;
end;

{ TPcOnlineMsgBase }

procedure TPcOnlineMsgBase.SendConfirmConect;
var
  MasterSendConfirmConnectInfo : TMasterSendConfirmConnectInfo;
begin
  MasterSendConfirmConnectInfo := TMasterSendConfirmConnectInfo.Create( PcID );
  MasterSendConfirmConnectInfo.SetSocketInfo( LanIp, LanPort );
  MasterSendConfirmConnectInfo.SetInternetSocket( InternetIp, InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendConfirmConnectInfo );
end;

procedure TPcOnlineMsgBase.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TPcOnlineMsgBase.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TPcOnlineMsgBase.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TPcOnlineMsgBase.Update;
begin
    // 添加 Pc 信息
  NetworkPcApi.AddItem( PcID, PcName );

    // 未完成连接，启动确认连接
  if not MyNetPcInfoReadUtil.ReadIsConnect( PcID ) then
    SendConfirmConect;
end;

{ TPcMsgBase }

procedure TPcMsgBase.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TSendServerMsgThread }

procedure TClientSendMsgThread.AddSendMsg(MsgStr: string);
begin
  MsgLock.Enter;
  SendMsgList.Add( MsgStr );
  MsgLock.Leave;

  Resume;
end;

constructor TClientSendMsgThread.Create( _TcpSocket : TCustomIpClient );
begin
  inherited Create;

  TcpSocket := _TcpSocket;
  MsgLock := TCriticalSection.Create;
  SendMsgList := TStringList.Create;
end;

destructor TClientSendMsgThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  SendMsgList.Free;
  MsgLock.Free;
  inherited;
end;

procedure TClientSendMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
    MsgStr := getNextMsg;
    if MsgStr = '' then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;
    SendMsg( MsgStr );
  end;

  inherited;
end;

function TClientSendMsgThread.getNextMsg: string;
begin
  MsgLock.Enter;
  if SendMsgList.Count > 0 then
  begin
    Result := SendMsgList[0];
    SendMsgList.Delete(0);
  end
  else
    Result := '';
  MsgLock.Leave;
end;

procedure TClientSendMsgThread.SendMsg(MsgStr: string);
begin
  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

{ TPcHeartBeatMsgFactory }

constructor TRegisterMsgFactory.Create;
begin
  inherited Create( MsgType_Register );
end;

function TRegisterMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_Register_ActivatePc then
    Result := TActivatePcMsg.Create
  else
  if MsgType = MsgType_Register_ActivatePcCompeted then
    Result := TActivatePcCompletedMsg.Create
  else
  if MsgType = MsgType_Register_RegisterShow then
    Result := TRegisterShowMsg.Create
  else
    Result := nil;
end;

{ TAdvancePcConnMsg }

procedure TAdvancePcConnMsg.AddNetworkPc;
begin
  NetworkPcApi.AddItem( ConnPcID, ConnPcName );
end;

procedure TAdvancePcConnMsg.AddPingMsg;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
begin
    // 发送 Ping 命令
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( ConnPcID );
  MasterSendInternetPingInfo.SetSocketInfo( LanIp, LanPort );
  MasterSendInternetPingInfo.SetInternetSocket( InternetIp, InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

function TAdvancePcConnMsg.getMsgType: string;
begin
  Result := MsgType_AdvancePc;
end;

procedure TAdvancePcConnMsg.SetConnPcInfo(_ConnPcID, _ConnPcName: string);
begin
  ConnPcID := _ConnPcID;
  ConnPcName := _ConnPcName;
end;

procedure TAdvancePcConnMsg.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TAdvancePcConnMsg.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TAdvancePcConnMsg.Update;
begin
  AddNetworkPc;
  AddPingMsg;
end;

{ TAdvanceConnMsgFactory }

constructor TAdvanceConnMsgFactory.Create;
begin
  inherited Create( MsgType_AdvancePc );
end;

function TAdvanceConnMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_AdvancePc then
    Result := TAdvancePcConnMsg.Create
  else
    Result := nil;
end;

{ TPcBatRegisterMsg }

procedure TActivatePcMsg.FeedBack;
var
  ActivatePcCompletedMsg : TActivatePcCompletedMsg;
begin
  ActivatePcCompletedMsg := TActivatePcCompletedMsg.Create;
  ActivatePcCompletedMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( PcID, ActivatePcCompletedMsg );
end;

function TActivatePcMsg.getMsgType: string;
begin
  Result := MsgType_Register_ActivatePc;
end;

procedure TActivatePcMsg.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcMsg.Update;
begin
  MyRegisterUserApi.SetLicense( LicenseStr );

  FeedBack;
end;

{ TNetworkBackupChangeMsg }

procedure TSendItemChangeMsg.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

{ TNetworkBackupAddMsg }

procedure TSendItemAddMsg.AddReceiveItem;
var
  Params : TReceiveItemAddParams;
begin
  Params.RootPath := ReceiveRootPath;
  Params.OwnerID := PcID;
  Params.SourcePath := SourcePath;
  Params.IsFile := IsFile;
  Params.IsZip := IsZip;

    // 添加 接收 Item
  ReceiveItemAppApi.AddItem( Params );
end;

procedure TSendItemAddMsg.FeedBack;
var
  SendItemAddCompletedMsg : TSendItemAddCompletedMsg;
begin
  SendItemAddCompletedMsg := TSendItemAddCompletedMsg.Create;
  SendItemAddCompletedMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemAddCompletedMsg.SetSourcePath( SourcePath );
  SendItemAddCompletedMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( PcID, SendItemAddCompletedMsg );
end;

function TSendItemAddMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_AddSendItem;
end;

procedure TSendItemAddMsg.SetReceiveAgain;
begin
  ReceiveItemAppApi.SetIsCompleted( ReceiveRootPath, PcID, SourcePath, False );
  ReceiveItemAppApi.SetIsCancel( ReceiveRootPath, PcID, SourcePath, False );
end;

procedure TSendItemAddMsg.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TSendItemAddMsg.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TSendItemAddMsg.Update;
begin
  inherited;

    // 存在根, 添加子路径
  if ReceiveRootInfoReadUtil.ReadIsExist( ReceiveRootPath ) then
  begin
      // 已存在 则不用添加
    if ReceiveItemInfoReadUtil.ReadIsExist( ReceiveRootPath, SourcePath, PcID ) then
      SetReceiveAgain
    else
      AddReceiveItem;
  end;

    // 返回接收结果
  FeedBack;
end;

{ TNetworkBackupRemoveMsg }

procedure TSendItemRemoveMsg.FeedBack;
var
  SendItemRemoveCompletedMsg : TSendItemRemoveCompletedMsg;
begin
  SendItemRemoveCompletedMsg := TSendItemRemoveCompletedMsg.Create;
  SendItemRemoveCompletedMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemRemoveCompletedMsg.SetSourcePath( SourcePath );
  SendItemRemoveCompletedMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( PcID, SendItemRemoveCompletedMsg );
end;

function TSendItemRemoveMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_RemoveSendItem;
end;

procedure TSendItemRemoveMsg.Update;
begin
  inherited;

  ReceiveItemAppApi.SetIsCancel( ReceiveRootPath, PcID, SourcePath, True );

  FeedBack;
end;

{ TNetworkBackupMsgFactory }

constructor TSendFileMsgFactory.Create;
begin
  inherited Create( MsgType_SendFile );
end;

function TSendFileMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_SendFile_AddReceiveRootItem then
    Result := TReceiveRootItemAddMsg.Create
  else
  if MsgType = MsgType_SendFile_RemoveReceiveRootItem then
    Result := TReceiveRootItemRemoveMsg.Create
  else
  if MsgType = MsgType_SendFile_AddSendItem then
    Result := TSendItemAddMsg.Create
  else
  if MsgType = MsgType_SendFile_AddSendItemCompleted then
    Result := TSendItemAddCompletedMsg.Create
  else
  if MsgType = MsgType_SendFile_RemoveSendItem then
    Result := TSendItemRemoveMsg.Create
  else
  if MsgType = MsgType_SendFile_RemoveSendItemCompleted then
    Result := TSendItemRemoveCompletedMsg.Create
  else
  if MsgType = MsgType_SendFile_WaitingSendItem then
    Result := TSendItemWaitingMsg.Create
  else
  if MsgType = MsgType_SendFile_WaitingSendItemCompleted then
    Result := TSendItemWaitingCompletedMsg.Create
  else
  if MsgType = MsgType_SendFile_RemoveReceiveItem then
    Result := TReceiveItemRemoveMsg.Create
  else
  if MsgType = MsgType_SendFile_ReceiveRootItemAvailableSpace then
    Result := TReceiveRootItemSetAvailableSpaceMsg.Create
  else
  if MsgType = MsgType_SendFile_BackConn then
    Result := TSendItemBackConnMsg.Create
  else
  if MsgType = MsgType_SendFile_BackConnBusy then
    Result := TSendItemBackConnBusyMsg.Create
  else
  if MsgType = MsgType_SendFile_BackConnError then
    Result := TSendItemBackConnErrorMsg.Create
  else
    Result := nil;
end;

{ TCloudPathAddMsg }

function TReceiveRootItemAddMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_AddReceiveRootItem;
end;

procedure TReceiveRootItemAddMsg.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TReceiveRootItemAddMsg.Update;
begin
  inherited;

  SendRootItemAppApi.AddNetworkItem( getSendRootItemID, AvailableSpace );
end;

{ TCloudPathRemoveMsg }

function TReceiveRootItemRemoveMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_RemoveReceiveRootItem;
end;

procedure TReceiveRootItemRemoveMsg.Update;
var
  SendRootItemID : string;
begin
  inherited;

    // 本机，不处理
  if PcID = PcInfo.PcID then
    Exit;

  SendRootItemID :=  getSendRootItemID;

    // 如果没有备份，则删除
  if not SendItemInfoReadUtil.ReadExistSend( SendRootItemID ) then
    SendRootItemUserApi.RemoveNetworkItem( SendRootItemID );
end;

{ TPcHeartBeatMsg }

function TPcHeartBeatMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_HeartBeat;
end;

procedure TPcHeartBeatMsg.Update;
begin
  inherited;

end;

{ TCloudPathSetAvailableSpaceMsg }

function TReceiveRootItemSetAvailableSpaceMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_ReceiveRootItemAvailableSpace;
end;

procedure TReceiveRootItemSetAvailableSpaceMsg.SetAvailableSpace(
  _AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TReceiveRootItemSetAvailableSpaceMsg.Update;
begin
  inherited;

      // 本机，不处理
  if PcID = PcInfo.PcID then
    Exit;

  SendRootItemAppApi.SetAvaialbleSpace( getSendRootItemID, AvailableSpace );
end;

{ TReceiveRootPathChangeMsg }

function TReceiveRootItemChangeMsg.getSendRootItemID: string;
begin
  Result := NetworkDesItemUtil.getDesItemID( PcID, ReceiveRootPath );
end;

procedure TReceiveRootItemChangeMsg.SetReceiveRootPath(_ReceiveRootPath: string);
begin
  ReceiveRootPath := _ReceiveRootPath;
end;

{ TSendItemAddCompletedMsg }

function TSendItemAddCompletedMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_AddSendItemCompleted;
end;

procedure TSendItemAddCompletedMsg.Update;
var
  SendRootItemID : string;
begin
  inherited;

  SendRootItemID := getSendRootItemID;

    // 设置 已添加
  SendItemAppApi.SetIsAddToReceive( SendRootItemID, SourcePath, False );

    // 启动 发送
  SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
end;

{ TSendItemRemoveCompletedMsg }

function TSendItemRemoveCompletedMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_RemoveSendItemCompleted;
end;

procedure TSendItemRemoveCompletedMsg.Update;
begin
  inherited;

    // 删除
  SendItemUserApi.RemoveNetworkItem( getSendRootItemID, SourcePath );
end;

{ TSendItemWaitingMsg }

procedure TSendItemWaitingMsg.FeedBack;
var
  SendItemWaitingCompletedMsg : TSendItemWaitingCompletedMsg;
begin
  SendItemWaitingCompletedMsg := TSendItemWaitingCompletedMsg.Create;
  SendItemWaitingCompletedMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemWaitingCompletedMsg.SetSourcePath( SourcePath );
  SendItemWaitingCompletedMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( PcID, SendItemWaitingCompletedMsg );
end;

function TSendItemWaitingMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_WaitingSendItem;
end;

procedure TSendItemWaitingMsg.Update;
begin
  inherited;

    // 设置等待发送
  ReceiveItemAppApi.SetWaitingReceive( ReceiveRootPath, PcID, SourcePath );

    // 返回信息
  FeedBack;
end;

{ TSendItemWaitingCompletedMsg }

function TSendItemWaitingCompletedMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_WaitingSendItemCompleted;
end;

procedure TSendItemWaitingCompletedMsg.Update;
begin
  inherited;

  SendItemUserApi.SendSelectNetworkItem( getSendRootItemID, SourcePath );
end;

{ TReceiveItemRemoveMsg }

function TReceiveItemRemoveMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_RemoveReceiveItem;
end;

procedure TReceiveItemRemoveMsg.Update;
begin
  inherited;

  SendItemAppApi.SetIsReceiveCancel( ReceiveRootPath, SourcePath, True );
end;

{ TSharePathChangeMsg }

procedure TSharePathChangeMsg.SetSharePath(_SharePath: string);
begin
  SharePath := _SharePath;
end;

{ TSharePathAddMsg }

constructor TSharePathAddMsg.Create;
begin
  inherited;
  IsNewShare := False;
end;

function TSharePathAddMsg.getMsgType: string;
begin
  Result := MsgType_SharePath_AddItem;
end;

procedure TSharePathAddMsg.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TSharePathAddMsg.SetIsNewShare(_IsNewShare: Boolean);
begin
  IsNewShare := _IsNewShare;
end;

procedure TSharePathAddMsg.Update;
begin
  inherited;

  if PcID = PcInfo.PcID then  // 本机共享
    IsNewShare := False;
  MyShareShowItemApi.AddItem( PcID, SharePath, IsFile, IsNewShare );
end;

{ TFileShareMsgFactory }

constructor TFileShareMsgFactory.Create;
begin
  inherited Create( MsgType_SharePath );
end;

function TFileShareMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_SharePath_AddItem then
    Result := TSharePathAddMsg.Create
  else
  if MsgType = MsgType_SharePath_RemoveItem then
    Result := TSharePathRemoveMsg.Create
  else
  if MsgType = MsgType_SharePath_DownBackConn then
    Result := TShareDownBackConnMsg.Create
  else
  if MsgType = MsgType_SharePath_DownBackConnBusy then
    Result := TShareDownBackConnBusyMsg.Create
  else
  if MsgType = MsgType_SharePath_DownBackConnError then
    Result := TShareDownBackConnErrorMsg.Create
  else
    Result := nil;
end;

{ TSharePathRemoveMsg }

function TSharePathRemoveMsg.getMsgType: string;
begin
  Result := MsgType_SharePath_RemoveItem;
end;

procedure TSharePathRemoveMsg.Update;
begin
  inherited;

  MyShareShowItemApi.RemoveItem( PcID, SharePath );
end;

{ TRegisterShowMsg }

function TRegisterShowMsg.getMsgType: string;
begin
  Result := MsgType_Register_RegisterShow;
end;

procedure TRegisterShowMsg.SetHardCode(_HardCode: string);
begin
  HardCode := _HardCode;
end;

procedure TRegisterShowMsg.SetRegisterEdition(_RegisterEdition: string);
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowMsg.Update;
begin
  RegisterShowAppApi.AddItem( PcID, HardCode, RegisterEdition );
end;

{ TActivatePcCompletedMsg }

function TActivatePcCompletedMsg.getMsgType: string;
begin
  Result := MsgType_Register_ActivatePcCompeted;
end;

procedure TActivatePcCompletedMsg.Update;
begin
  RegisterActivatePcApi.RemoveItem( PcID );
end;

{ TSendItemBackConnMsg }

function TSendItemBackConnMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_BackConn;
end;

procedure TSendItemBackConnMsg.Update;
begin
  ReceiveItemAppApi.AddBackConn( PcID );
end;

{ TSendItemBackConnBusyMsg }

function TSendItemBackConnBusyMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_BackConnBusy;
end;

procedure TSendItemBackConnBusyMsg.Update;
begin
  MyFileSendConnectHandler.BackConnBusy;
end;

{ TSendItemBackConnErrorMsg }

function TSendItemBackConnErrorMsg.getMsgType: string;
begin
  Result := MsgType_SendFile_BackConnError;
end;

procedure TSendItemBackConnErrorMsg.Update;
begin
  MyFileSendConnectHandler.BackConnError;
end;

{ TShareDownBackConnMsg }

function TShareDownBackConnMsg.getMsgType: string;
begin
  Result := MsgType_SharePath_DownBackConn;
end;

procedure TShareDownBackConnMsg.Update;
begin
  MySharePathApi.AddShareDownBackConn( PcID );
end;

{ TShareDownBackConnBusyMsg }

function TShareDownBackConnBusyMsg.getMsgType: string;
begin
  Result := MsgType_SharePath_DownBackConnBusy;
end;

procedure TShareDownBackConnBusyMsg.Update;
begin
  MyShareDownConnectHandler.BackConnBusy;
end;

{ TShareDownBackConnErrorMsg }

function TShareDownBackConnErrorMsg.getMsgType: string;
begin
  Result := MsgType_SharePath_DownBackConnError;
end;

procedure TShareDownBackConnErrorMsg.Update;
begin
  MyShareDownConnectHandler.BackConnError;
end;

{ TClientHeartBeatHandle }

procedure TClientHeartBeatHandle.SendCloudAvailableSpace;
var
  CloudPathList : TStringList;
  i: Integer;
  CloudPath : string;
  AvailableSpace : Int64;
  CloudPathSetAvailableSpaceMsg : TReceiveRootItemSetAvailableSpaceMsg;
begin
  CloudPathList := ReceiveRootInfoReadUtil.ReadPathList;
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i];
    AvailableSpace := MyHardDisk.getHardDiskFreeSize( CloudPath );

    ReceiveRootItemAppApi.SetAvailableSpace( CloudPath, AvailableSpace );

    CloudPathSetAvailableSpaceMsg := TReceiveRootItemSetAvailableSpaceMsg.Create;
    CloudPathSetAvailableSpaceMsg.SetReceiveRootPath( CloudPath );
    CloudPathSetAvailableSpaceMsg.SetAvailableSpace( AvailableSpace );
    CloudPathSetAvailableSpaceMsg.SetPcID( PcInfo.PcID );
    MyClient.SendMsgToAll( CloudPathSetAvailableSpaceMsg );
  end;
  CloudPathList.Free;
end;

procedure TClientHeartBeatHandle.SendHeartBeat;
var
  PcHeartBeatMsg : TPcHeartBeatMsg;
begin
  PcHeartBeatMsg := TPcHeartBeatMsg.Create;
  PcHeartBeatMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToAll( PcHeartBeatMsg );
end;

procedure TClientHeartBeatHandle.Update;
begin
    // 发送心跳
  SendHeartBeat;

    // 发送可用空间信息
  SendCloudAvailableSpace;
end;

class procedure MyClientOnTimerApi.SendHeartBeat;
var
  ClientHeartBeatHandle : TClientHeartBeatHandle;
begin
    // 已结束
  if not MyClient.IsRun then
    Exit;

  ClientHeartBeatHandle := TClientHeartBeatHandle.Create;
  ClientHeartBeatHandle.Update;
  ClientHeartBeatHandle.Free;
end;

end.

