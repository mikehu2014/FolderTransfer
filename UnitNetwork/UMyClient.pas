unit UMyClient;

interface

uses Classes, Sockets, UChangeInfo, SyncObjs, UMyUtil, SysUtils,UMyNetPcInfo, DateUtils, UModelUtil,
     uDebug, UFileBaseInfo, UMyDebug, uDebugLock;

type

{$Region ' Client ������Ϣ ' }

  TPcMsgBase = class( TMsgBase )
  public
    iPcID : string;
  published
    property PcID : string Read iPcID Write iPcID;
  public
    procedure SetPcID( _PcID : string );
  end;

{$EndRegion}

{$Region ' Client ״̬��Ϣ ' }

    // Online ����
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

    // Pc Online ��Ϣ
  TPcOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendBackPcOnline;
  end;

    // Pc ���� Online ��Ϣ
  TPcBackOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // Pc Offline ��Ϣ
  TPcOfflineMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SetNetPcOffline;
  end;

    // Pc ��Ϣ
  TPcHeartBeatMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

      // ��Ϣ����
  TPcStatusMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client �ļ�������Ϣ ' }

  {$Region ' ���� ��·�� �޸� ' }

    // ����·�� �޸ĸ���
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

    // ����
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

    // ���ÿ��ÿռ���Ϣ
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

    // ɾ��
  TReceiveRootItemRemoveMsg = class( TReceiveRootItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' ���� Դ·�� �޸� ' }

    // ����
  TSendItemChangeMsg = class( TReceiveRootItemChangeMsg )
  public
    iSourcePath : string;
  published
    property SourcePath : string Read iSourcePath Write iSourcePath;
  public
    procedure SetSourcePath( _SourcePath : string );
  end;

    // ���� Send Item
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

    // ���� Send Item �ɹ�
  TSendItemAddCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �ȴ�����
  TSendItemWaitingMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  public
    procedure FeedBack;
  end;

    // �ȴ����� ���
  TSendItemWaitingCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ɾ�� Send Item
  TSendItemRemoveMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure FeedBack;
  end;

    // ɾ�� Send Item �ɹ�
  TSendItemRemoveCompletedMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' ���� Դ·�� �޸� ' }

    // ���շ�ɾ��
  TReceiveItemRemoveMsg = class( TSendItemChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' �������� ' }

    // ����������
  TSendItemBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ��æ
  TSendItemBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ʧ��
  TSendItemBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

    // �ļ����� ����
  TSendFileMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client �ļ�������Ϣ ' }

  {$Region ' ����·����ɾ ' }

    // ����
  TSharePathChangeMsg = class( TPcMsgBase )
  public
    iSharePath : string;
  published
    property SharePath : string Read iSharePath Write iSharePath;
  public
    procedure SetSharePath( _SharePath : string );
  end;

    // ����
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

    // ɾ��
  TSharePathRemoveMsg = class( TSharePathChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' �������� �������� ' }

      // ����������
  TShareDownBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ��æ
  TShareDownBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ʧ��
  TShareDownBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}


      // �ļ����� ����
  TFileShareMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client ע����Ϣ '}

    // ע����Ϣ
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

    // ע�����
  TActivatePcCompletedMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ��ʾע����Ϣ
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

    // ����Ϣ����
  TRegisterMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Advance ���� Pc ��Ϣ ' }

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


{$Region ' Client �����߳� ' }

    // ���� ��������Ϣ ���߳�
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

{$Region ' Client �����߳� ' }

  TClientSendMsgThread = class( TDebugThread )
  public
    MsgLock : TCriticalSection;
    SendMsgList : TStringList; // �����������
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

{$Region ' Client �����߳� ' }

    // ����
  TClientHeartBeatHandle = class
  public
    procedure Update;
  private
    procedure SendHeartBeat;
    procedure SendCloudAvailableSpace;
  end;

{$EndRegion}


    // �ͻ��˶�ʱ Api
  MyClientOnTimerApi = class
  public
    class procedure SendHeartBeat;
  end;

    // �ͻ�����Ϣ
  TMyClient = class
  private
    ClientLock : TCriticalSection;
    ClientSocket : TCustomIpClient;  // �������ͨ�Žӿ�
    ClientRevMsgThread : TClientRevMsgThread;  // ���������߳�
    ClientSendMsgThread : TClientSendMsgThread; // ���������߳�
  public
    IsRun, IsConnServer : Boolean;
    ServerPcID : string;
    ServerLanIp, ServerLanPort : string;
    ServerInternetIp, ServerInternetPort : string;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public        // ��������
    procedure SendMsgToPc( PcID : string; MsgBase : TMsgBase );
    procedure SendMsgToAll( MsgBase : TMsgBase );
  public        // ����/�Ͽ� ������
    function ConnectServer( TcpSocket : TCustomIpClient ): Boolean;
    procedure AcceptServer( TcpSocket : TCustomIpClient );
    procedure ClientLostConn;  // �����ͻ�������ʱ������
    procedure ServerLostConn; // �������Ͽ�ʱ������
  private        // ����
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
      // �ȴ�����������Ϣ
    MsgStr := WaitServerMsg;
    if MsgStr = ''  then  // �Ͽ�����
    begin
      ServerLostConn; // �������Ͽ��¼�
      Break;
    end
    else
    begin
      try
        HandleServerMsg( MsgStr );  // �������յ�����
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
    // Pc ״̬����
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
  MyClient.ServerLostConn;  // �������Ͽ��¼�
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

    // �ѽ���
  if not IsRun then
    Exit;

    // ��ȡ�Է��Ƿ� Server
  IsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsServer then
    Exit;

    // �����Ƿ������ӷ�����
  MySocketUtil.SendJsonStr( TcpSocket, 'IsConnServer', IsConnServer );
  if IsConnServer then
    Exit;

    // �Ƿ���ڿͻ���
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );  // ���ͱ�����ʶ
  IsExistClient := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsExistClient then // �Ѵ��ڿͻ���
    Exit;

    // ����
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
    // ���ÿͻ��� Socket
  ClientSocket := TcpSocket;

    // ���� Pc ��ʶ�� ��ȡ Server ������Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'PcID', PcInfo.PcID );
  ServerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerLanPort := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetIp := MySocketUtil.RevJsonStr( TcpSocket );
  ServerInternetPort := MySocketUtil.RevJsonStr( TcpSocket );

    // ������Ϣ �߳�
  ClientSendMsgThread := TClientSendMsgThread.Create( TcpSocket );

    // ������Ϣ �߳�
  ClientRevMsgThread := TClientRevMsgThread.Create( TcpSocket );
  ClientRevMsgThread.Resume;

    // �������� �߳�
  MyTimerHandler.AddTimer( HandleType_ClientHeartBeat, 180 );

    // ���� ��Ϊ Master
  NetworkPcApi.BeServer( ServerPcID );

    // ����Ѿ����� Server
  IsConnServer := True;

    // ����������Ϣ
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

    // ֹͣ��������
  IsConnServer := False;

    // ������������
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
    // �������
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

  MsgStr := MsgBase.getMsg;

    // ��������� ת������ Pc
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
    // �������
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

    // ��������� ת�� Pc
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

    // ��������
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

    // ���� ���� online ��Ϣ
  SendBackPcOnline;

    // Pc ���� �¼�
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

    // Pc ����
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
    // ����״̬
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
    // ���� Pc ��Ϣ
  NetworkPcApi.AddItem( PcID, PcName );

    // δ������ӣ�����ȷ������
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
    // ���� Ping ����
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

    // ���� ���� Item
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

    // ���ڸ�, ������·��
  if ReceiveRootInfoReadUtil.ReadIsExist( ReceiveRootPath ) then
  begin
      // �Ѵ��� ��������
    if ReceiveItemInfoReadUtil.ReadIsExist( ReceiveRootPath, SourcePath, PcID ) then
      SetReceiveAgain
    else
      AddReceiveItem;
  end;

    // ���ؽ��ս��
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

    // ������������
  if PcID = PcInfo.PcID then
    Exit;

  SendRootItemID :=  getSendRootItemID;

    // ���û�б��ݣ���ɾ��
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

      // ������������
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

    // ���� ������
  SendItemAppApi.SetIsAddToReceive( SendRootItemID, SourcePath, False );

    // ���� ����
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

    // ɾ��
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

    // ���õȴ�����
  ReceiveItemAppApi.SetWaitingReceive( ReceiveRootPath, PcID, SourcePath );

    // ������Ϣ
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

  if PcID = PcInfo.PcID then  // ��������
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
    // ��������
  SendHeartBeat;

    // ���Ϳ��ÿռ���Ϣ
  SendCloudAvailableSpace;
end;

class procedure MyClientOnTimerApi.SendHeartBeat;
var
  ClientHeartBeatHandle : TClientHeartBeatHandle;
begin
    // �ѽ���
  if not MyClient.IsRun then
    Exit;

  ClientHeartBeatHandle := TClientHeartBeatHandle.Create;
  ClientHeartBeatHandle.Update;
  ClientHeartBeatHandle.Free;
end;

end.
