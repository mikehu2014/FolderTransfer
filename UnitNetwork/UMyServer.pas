unit UMyServer;

interface

uses Classes, Sockets, UChangeInfo, Generics.Collections, SyncObjs, UModelUtil, SysUtils, UMyDebug, math,
     uDebugLock;

type

{$Region ' Clinet 转发命令 ' }

    // 父类
  TSendClientMsgBase = class( TMsgBase )
  public
    iSendMsgStr : string;
  published
    property SendMsgStr : string Read iSendMsgStr Write iSendMsgStr;
  public
    procedure SetSendMsgBase( MsgBase : TMsgBase );
    procedure SetSendMsgStr( _SendMsgStr : string );
  end;

    // 发给 指定 Client
  TSendClientMsg = class( TSendClientMsgBase )
  public
    iTargetPcID : string;
  published
    property TargetPcID : string Read iTargetPcID Write iTargetPcID;
  public
    function getMsgType : string;override;
    procedure SetTargetPcID( _TargetPcID : string );
    procedure Update;override;
  end;

    // 发给 所有 Client
  TSendClientAllMsg = class( TSendClientMsgBase )
  public
    function getMsgType : string;override;
    procedure Update;override;
  end;

  TClientSendMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 命令 接收线程 ' }

    // 服务器 接收 客户端信息 的线程
  TServerRevMsgThread = class( TDebugThread )
  private
    ClientPcID : string;
    TcpSocket : TCustomIpClient;
  public
    MsgFactoryList : TMsgFactoryList;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetClientPcID( _ClientPcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure ServerLostConn; // 服务器断开连接
  public
    procedure RevMsg( MsgStr : string );  // 接收命令
    procedure SendMsg( MsgStr : string ); // 发送命令
  private
    procedure IniMsgFactory;
  end;
  TServerRevMsgThreadPair = TPair< string , TServerRevMsgThread >;
  TServerRevMsgThreadHash = class(TObjectDictionary< string, TServerRevMsgThread >);

{$EndRegion}

    // 服务器端
  TMyServer = class
  public
    IsRun : Boolean;
    IsBeServer : Boolean; // 是否成为服务器
    ClientCount : Integer; // 客户端数
  private      // 接收 客户端命令 线程
    ClientListLock : TCriticalSection;
    ServerRevMsgThreadHash : TServerRevMsgThreadHash;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure BeServer; // 成为服务器时调用
    function ConnectClient( TcpSocket : TCustomIpClient ): Boolean;   // 客户端的连接
    procedure AcceptClient( TcpSocket : TCustomIpClient );
    procedure ClientLostConn( ClientPcID : string );  // 客户端离线
    procedure ServerLostConn;  // 服务器主动断开
  private
    function getIsAddClient( TcpSocket : TCustomIpClient ): Boolean;
    procedure AddClient( TcpSocket : TCustomIpClient );
  end;

const
  MsgType_SendClientMsg : string = 'SendClientMsg';
  MsgType_SendClientMsg_SendPc : string = 'SendClientMsg_SendPc';
  MsgType_SendClientMsg_SendAll : string = 'SendClientMsg_SendAll';

var
  MyServer : TMyServer; // 服务器端

implementation

uses UMyClient, UMyNetPcInfo, UMyTcp;

{ TClientRevThread }

constructor TServerRevMsgThread.Create(_TcpSocket : TCustomIpClient);
begin
  inherited Create;
  TcpSocket := _TcpSocket;
  MsgFactoryList := TMsgFactoryList.Create;
  IniMsgFactory;
end;

destructor TServerRevMsgThread.Destroy;
begin
  MsgFactoryList.Free;
  TcpSocket.Free;
  inherited;
end;

procedure TServerRevMsgThread.Execute;
var
  MsgStr : string;
begin
  FreeOnTerminate := True;

  while not Terminated do
  begin
    MsgStr := MySocketUtil.RevData( TcpSocket, WaitTime_RevClient );
    if MsgStr = '' then // 客户端断开连接
      Break;

    try
      RevMsg( MsgStr );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Server Rev Msg', e.Message );
    end;
  end;

  MyServer.ClientLostConn( ClientPcID );

  Terminate;
end;

procedure TServerRevMsgThread.IniMsgFactory;
var
  MsgFactory : TMsgFactory;
begin
  MsgFactory := TClientSendMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );
end;

procedure TServerRevMsgThread.ServerLostConn;
begin
  TcpSocket.Disconnect;
end;

procedure TServerRevMsgThread.RevMsg(MsgStr: string);
var
  i : Integer;
  MsgInfo : TMsgInfo;
  MsgFactory : TMsgFactory;
  MsgBase : TMsgBase;
begin
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

procedure TServerRevMsgThread.SendMsg(MsgStr: string);
begin
  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TServerRevMsgThread.SetClientPcID(_ClientPcID: string);
begin
  ClientPcID := _ClientPcID;
end;

{ TMyServer }

function TMyServer.ConnectClient(TcpSocket: TCustomIpClient): Boolean;
begin
  ClientListLock.Enter;
  Result := getIsAddClient( TcpSocket );
  ClientListLock.Leave;
end;

procedure TMyServer.AcceptClient(TcpSocket: TCustomIpClient);
begin
  if not ConnectClient( TcpSocket ) then
    TcpSocket.Free;
end;

procedure TMyServer.AddClient(TcpSocket: TCustomIpClient);
var
  ClientPcID : string;
  NewRevThread : TServerRevMsgThread;
begin
    // 接收 Pc ID
  ClientPcID := MySocketUtil.RevJsonStr( TcpSocket );

    // 发送服务器端口信息
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanIp', PcInfo.LanIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanPort', PcInfo.LanPort );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetIp', PcInfo.InternetIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetPort', PcInfo.InternetPort );

    // 创建 接收线程
  NewRevThread := TServerRevMsgThread.Create( TcpSocket );
  NewRevThread.SetClientPcID( ClientPcID );
  NewRevThread.Resume;

    //  添加 集合中
  ServerRevMsgThreadHash.AddOrSetValue( ClientPcID, NewRevThread );
  ClientCount := ClientCount + 1;
end;

procedure TMyServer.BeServer;
begin
  IsBeServer := True;
  ClientCount := 0;
end;

procedure TMyServer.ClientLostConn(ClientPcID: string);
var
  PcOfflineMsg : TPcOfflineMsg;
  SendClientAllMsg : TSendClientAllMsg;
begin
  if not IsRun then
    Exit;

    // 删除接收线程
  ClientListLock.Enter;
  if ServerRevMsgThreadHash.ContainsKey( ClientPcID ) then
  begin
    ServerRevMsgThreadHash.Remove( ClientPcID );
    if ClientCount > 0 then
      ClientCount := ClientCount - 1;
  end;
  ClientListLock.Leave;

    // 服务器已断开
  if not IsBeServer then
    Exit;

    // 通知其他客户端，Pc下线信息
  PcOfflineMsg := TPcOfflineMsg.Create;
  PcOfflineMsg.SetPcID( ClientPcID );

  SendClientAllMsg := TSendClientAllMsg.Create;
  SendClientAllMsg.SetSendMsgBase( PcOfflineMsg );
  SendClientAllMsg.Update;
  SendClientAllMsg.Free;

  PcOfflineMsg.Free;
end;

constructor TMyServer.Create;
begin
  inherited Create;

  ClientListLock := TCriticalSection.Create;
  ServerRevMsgThreadHash := TServerRevMsgThreadHash.Create;

  IsRun := True;
  IsBeServer := False;
  ClientCount := 0;
end;

destructor TMyServer.Destroy;
begin
  ServerRevMsgThreadHash.Free;
  ClientListLock.Free;

  inherited;
end;

function TMyServer.getIsAddClient(TcpSocket: TCustomIpClient): Boolean;
var
  ClientPcID : string;
  IsConnectServer, IsExistClient : Boolean;
begin
  Result := False;

    // 已结束
  if not IsRun then
    Exit;

    // 发送本机是否服务器
  MySocketUtil.SendJsonStr( TcpSocket, 'IsBeServer', IsBeServer );
  if not IsBeServer then  // 本机不是服务器
    Exit;

    // 获取对方是否已经连接服务器
  IsConnectServer := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsConnectServer then  // 对方已经连接服务器
    Exit;

    // 是否已存在客户端
  ClientPcID := MySocketUtil.RevJsonStr( TcpSocket );  // 接收 Pc ID
  IsExistClient := ServerRevMsgThreadHash.ContainsKey( ClientPcID );  // 判断
  MySocketUtil.SendJsonStr( TcpSocket, 'IsExistClient', IsExistClient ); // 发送
  if IsExistClient then  // 已存在则结束
    Exit;

    // 连接成功
  AddClient( TcpSocket );

  Result := True;
end;

procedure TMyServer.ServerLostConn;
var
  p : TServerRevMsgThreadPair;
  IsExistClient : Boolean;
begin
  IsBeServer := False;

    // 断开所有连接
  ClientListLock.Enter;
  for p in ServerRevMsgThreadHash do
    p.Value.ServerLostConn;
  ClientListLock.Leave;

    // 等待所有网络连接断开
  while True do
  begin
    ClientListLock.Enter;
    IsExistClient := ServerRevMsgThreadHash.Count > 0;
    ClientListLock.Leave;
    if not IsExistClient then
      Break;
    Sleep( 100 );
  end;

  ClientCount := 0;
end;

procedure TMyServer.StopRun;
begin
  IsRun := False;
end;


{ TSendClientMsg }

function TSendClientMsg.getMsgType: string;
begin
  Result := MsgType_SendClientMsg_SendPc;
end;

procedure TSendClientMsg.SetTargetPcID(_TargetPcID: string);
begin
  TargetPcID := _TargetPcID;
end;

procedure TSendClientMsg.Update;
var
  RevThreadHash : TServerRevMsgThreadHash;
begin
  MyServer.ClientListLock.Enter;
  RevThreadHash := MyServer.ServerRevMsgThreadHash;
  if RevThreadHash.ContainsKey( TargetPcID ) then
    RevThreadHash[ TargetPcID ].SendMsg( SendMsgStr );
  MyServer.ClientListLock.Leave;
end;

{ TClientSendMsgFactory }

constructor TClientSendMsgFactory.Create;
begin
  inherited Create( MsgType_SendClientMsg );
end;

function TClientSendMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_SendClientMsg_SendPc then
    Result := TSendClientMsg.Create
  else
  if MsgType = MsgType_SendClientMsg_SendAll then
    Result := TSendClientAllMsg.Create
  else
    Result := nil;
end;

{ TSendClientMsgBase }

procedure TSendClientMsgBase.SetSendMsgBase(MsgBase: TMsgBase);
begin
  SendMsgStr := MsgBase.getMsg;
end;

procedure TSendClientMsgBase.SetSendMsgStr(_SendMsgStr: string);
begin
  SendMsgStr := _SendMsgStr;
end;

{ TSendClientAllMsg }

function TSendClientAllMsg.getMsgType: string;
begin
  Result := MsgType_SendClientMsg_SendAll;
end;

procedure TSendClientAllMsg.Update;
var
  RevThreadHash : TServerRevMsgThreadHash;
  p : TServerRevMsgThreadPair;
begin
  MyServer.ClientListLock.Enter;
  RevThreadHash := MyServer.ServerRevMsgThreadHash;
  for p in RevThreadHash do
    p.Value.SendMsg( SendMsgStr );
  MyServer.ClientListLock.Leave;
end;


end.

