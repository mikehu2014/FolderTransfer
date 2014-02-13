unit UMyServer;

interface

uses Classes, Sockets, UChangeInfo, Generics.Collections, SyncObjs, UModelUtil, SysUtils, UMyDebug, math,
     uDebugLock;

type

{$Region ' Clinet ת������ ' }

    // ����
  TSendClientMsgBase = class( TMsgBase )
  public
    iSendMsgStr : string;
  published
    property SendMsgStr : string Read iSendMsgStr Write iSendMsgStr;
  public
    procedure SetSendMsgBase( MsgBase : TMsgBase );
    procedure SetSendMsgStr( _SendMsgStr : string );
  end;

    // ���� ָ�� Client
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

    // ���� ���� Client
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

{$Region ' Client ���� �����߳� ' }

    // ������ ���� �ͻ�����Ϣ ���߳�
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
    procedure ServerLostConn; // �������Ͽ�����
  public
    procedure RevMsg( MsgStr : string );  // ��������
    procedure SendMsg( MsgStr : string ); // ��������
  private
    procedure IniMsgFactory;
  end;
  TServerRevMsgThreadPair = TPair< string , TServerRevMsgThread >;
  TServerRevMsgThreadHash = class(TObjectDictionary< string, TServerRevMsgThread >);

{$EndRegion}

    // ��������
  TMyServer = class
  public
    IsRun : Boolean;
    IsBeServer : Boolean; // �Ƿ��Ϊ������
    ClientCount : Integer; // �ͻ�����
  private      // ���� �ͻ������� �߳�
    ClientListLock : TCriticalSection;
    ServerRevMsgThreadHash : TServerRevMsgThreadHash;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure BeServer; // ��Ϊ������ʱ����
    function ConnectClient( TcpSocket : TCustomIpClient ): Boolean;   // �ͻ��˵�����
    procedure AcceptClient( TcpSocket : TCustomIpClient );
    procedure ClientLostConn( ClientPcID : string );  // �ͻ�������
    procedure ServerLostConn;  // �����������Ͽ�
  private
    function getIsAddClient( TcpSocket : TCustomIpClient ): Boolean;
    procedure AddClient( TcpSocket : TCustomIpClient );
  end;

const
  MsgType_SendClientMsg : string = 'SendClientMsg';
  MsgType_SendClientMsg_SendPc : string = 'SendClientMsg_SendPc';
  MsgType_SendClientMsg_SendAll : string = 'SendClientMsg_SendAll';

var
  MyServer : TMyServer; // ��������

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
    if MsgStr = '' then // �ͻ��˶Ͽ�����
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
    // ���� Pc ID
  ClientPcID := MySocketUtil.RevJsonStr( TcpSocket );

    // ���ͷ������˿���Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanIp', PcInfo.LanIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'LanPort', PcInfo.LanPort );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetIp', PcInfo.InternetIp );
  MySocketUtil.SendJsonStr( TcpSocket, 'InternetPort', PcInfo.InternetPort );

    // ���� �����߳�
  NewRevThread := TServerRevMsgThread.Create( TcpSocket );
  NewRevThread.SetClientPcID( ClientPcID );
  NewRevThread.Resume;

    //  ��� ������
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

    // ɾ�������߳�
  ClientListLock.Enter;
  if ServerRevMsgThreadHash.ContainsKey( ClientPcID ) then
  begin
    ServerRevMsgThreadHash.Remove( ClientPcID );
    if ClientCount > 0 then
      ClientCount := ClientCount - 1;
  end;
  ClientListLock.Leave;

    // �������ѶϿ�
  if not IsBeServer then
    Exit;

    // ֪ͨ�����ͻ��ˣ�Pc������Ϣ
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

    // �ѽ���
  if not IsRun then
    Exit;

    // ���ͱ����Ƿ������
  MySocketUtil.SendJsonStr( TcpSocket, 'IsBeServer', IsBeServer );
  if not IsBeServer then  // �������Ƿ�����
    Exit;

    // ��ȡ�Է��Ƿ��Ѿ����ӷ�����
  IsConnectServer := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsConnectServer then  // �Է��Ѿ����ӷ�����
    Exit;

    // �Ƿ��Ѵ��ڿͻ���
  ClientPcID := MySocketUtil.RevJsonStr( TcpSocket );  // ���� Pc ID
  IsExistClient := ServerRevMsgThreadHash.ContainsKey( ClientPcID );  // �ж�
  MySocketUtil.SendJsonStr( TcpSocket, 'IsExistClient', IsExistClient ); // ����
  if IsExistClient then  // �Ѵ��������
    Exit;

    // ���ӳɹ�
  AddClient( TcpSocket );

  Result := True;
end;

procedure TMyServer.ServerLostConn;
var
  p : TServerRevMsgThreadPair;
  IsExistClient : Boolean;
begin
  IsBeServer := False;

    // �Ͽ���������
  ClientListLock.Enter;
  for p in ServerRevMsgThreadHash do
    p.Value.ServerLostConn;
  ClientListLock.Leave;

    // �ȴ������������ӶϿ�
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

