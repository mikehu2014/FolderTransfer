unit UReceiveThread;

interface

uses classes, Sockets, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, Syncobjs,
     UMyDebug, uDebugLock, Zip, uDebug;

type

    // ���� �����ļ�
  TSendFileReceiveHandle = class( TNetworkFileReceiveHandle )
  private
    ReceiveRootPath : string;
    SourcePath, OwnerID : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetReceiveRootPath( _ReceiveRootPath : string );
    procedure SetReceiveItemInfo( _SourcePath, _OwnerID : string );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
  protected
    function CheckNextReceive : Boolean;override;
    procedure RefreshCompletedSpace;override;
    procedure AddSpeedSpace( Space : Integer );override; // ˢ���ٶ���Ϣ
  end;

    // ���� ѹ���ļ�
  TSendFileReceiveZipHandle = class( TSendFileReceiveHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    function CreateWriteStream : Boolean;override;
  protected
    procedure LastRefreshCompletedSpace;override;
  end;

    // �����ļ�����
  TReceiveFileHandle = class
  public
    FileReq : string;
    ReceiveFilePath : string;
  public
    TcpSocket : TCustomIpClient;
  public
    ReceiveRootPath, SavePath : string;
    SourcePath, OwnerID : string;
    IsZip : Boolean;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    constructor Create( _FileReq : string );
    procedure SetReceiveFilePath( _ReceiveFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetReceiveRootPath( _ReceiveRootPath : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetReceiveItemInfo( _SourcePath, _OwnerID : string );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
    procedure Update;
  private       // ��ȡ
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadDeepFolder;
  private       // �޸�
    procedure AddFile;
    procedure AddFolder;
    procedure RemoveFile;
    procedure ContinuesAddFile;
  private       // ѹ��
    procedure ZipFile;
  end;

    // �ٶ���Ϣ
  TReceiveSpeedInfo = class
  public
    ReceiveRootPath, SourcePath, OwnerPcID : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
    ReceiveCount : Integer;
  public
    constructor Create( _ReceiveRootPath, _SourcePath, _OwnerPcID : string );
    destructor Destroy; override;
  end;
  TReceiveSpeedList = class( TObjectList< TReceiveSpeedInfo > )end;

    // �����ٶȴ�����
  TReceiveSpeedHandler = class
  public
    SpeedLock : TCriticalSection;
    ReceiveSpeedList : TReceiveSpeedList;
  public
    constructor Create;
    destructor Destroy; override;
  public      // ��ȡ/ɾ�� �ٶȿ�����
    function getSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID : string ): TRefreshSpeedInfo;
    procedure RemoveSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID : string );
  end;

    // �����㷨
  TReceiveFileRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
  private
    ReceiveRootPath, SourcePath, OwnerPcID : string;
    SavePath : string;
    IsZip : Boolean;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure ReadBaseInfo;  // ��ȡ������Ϣ
    function SendAccessResult: Boolean;  // ���ͷ��ʽ��
    procedure HandleRequest;  // �����������
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure SetReceiveSpace; // ���ÿռ���Ϣ
  private
    procedure HandleReq( FileReq, FilePath : string );
  end;

    // ���� ��·��
  TReceiveRootRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure HandleRevcFile;
    function WaitNextRevc: Boolean;
  end;

    // ���ļ������߳�
  TReceiveFileHandleThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  private
    SendPcID : string;
    IsConnnected : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetSendPcID( _SendPcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ConnToSendPc : Boolean; // ������Ҫ���͵�Pc
    procedure HandleRequest; // ��������
  end;
  TReceiveFileHandleThreadList = class( TObjectList< TReceiveFileHandleThread > )end;


    // ���ļ�����
  TMyReceiveFileHandler = class
  public
    IsRun, IsReceiveRun : Boolean;
  public
    ThreadLock : TCriticalSection;
    ReceiveFileThreadList : TReceiveFileHandleThreadList;
  public
    constructor Create;
    function getIsRun : Boolean;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure ReceiveConn( TcpSocket : TCustomIpClient );
    procedure ReceiveBackConn( SendPcID : string );
    procedure RemoveThread( ThreadID : Cardinal );
  end;

const
  ThreadCount_Receive = 30;

const
  HandleType_ReceiveFile = 'ReceiveFile';
  HandleType_BackConn = 'BackConn';

var
  MyReceiveFileHandler : TMyReceiveFileHandler;
  ReceiveSpeedHandler : TReceiveSpeedHandler;

implementation

uses UMyReceiveDataInfo, UMyReceiveApiInfo, UMyNetPcInfo, UMyReceiveEventInfo, UMainFormThread;

{ TCloudBackupThread }

procedure TReceiveFileHandleThread.HandleRequest;
var
  ReceiveRootRequestHandle : TReceiveRootRequestHandle;
begin
  ReceiveRootRequestHandle := TReceiveRootRequestHandle.Create( TcpSocket );
  ReceiveRootRequestHandle.Update;
  ReceiveRootRequestHandle.Free;
end;

function TReceiveFileHandleThread.ConnToSendPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
begin
  DebugLock.Debug( 'ConnToSendPc' );

  Result := False;

  TcpSocket := TCustomIpClient.Create( nil );

    // ��ȡ Pc Socket ��Ϣ
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( SendPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( SendPcID );

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_SendFile );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ����ʧ��
  if not Result then
    ReceiveBackConnEvent.ConnError( SendPcID );
end;

constructor TReceiveFileHandleThread.Create;
begin
  inherited Create;
end;

destructor TReceiveFileHandleThread.Destroy;
begin
  inherited;
end;

procedure TReceiveFileHandleThread.Execute;
begin
  FreeOnTerminate := True;

  MyReceiveFileHandler.IsReceiveRun := True;

  try
      // ���û�����ӣ���������
    if IsConnnected or ConnToSendPc then
      HandleRequest; // ������ɨ��
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Receive File Error', e.Message );
  end;

    // �Ͽ�����
  TcpSocket.Disconnect;
  TcpSocket.Free;

    // ɾ���̼߳�¼
  MyReceiveFileHandler.RemoveThread( ThreadID );

  Terminate;
end;

procedure TReceiveFileHandleThread.SetSendPcID(_SendPcID: string);
begin
  SendPcID := _SendPcID;
  IsConnnected := False;
end;

procedure TReceiveFileHandleThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  IsConnnected := True;
end;

{ TMyCloudBackupHandler }

constructor TMyReceiveFileHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  ReceiveFileThreadList := TReceiveFileHandleThreadList.Create;
  ReceiveFileThreadList.OwnsObjects := False;

  IsRun := True;
  IsReceiveRun := True;
end;

destructor TMyReceiveFileHandler.Destroy;
begin
  ReceiveFileThreadList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyReceiveFileHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsReceiveRun;
end;

procedure TMyReceiveFileHandler.ReceiveBackConn(SendPcID: string);
var
  IsBusy : Boolean;
  ReceiveThread : TReceiveFileHandleThread;
begin
    // �������
  if not IsRun then
    Exit;

    // ���������߳�
  ThreadLock.Enter;
  IsBusy := True;
  if ReceiveFileThreadList.Count < ThreadCount_Receive then
  begin
    IsBusy := False;
    ReceiveThread := TReceiveFileHandleThread.Create;
    ReceiveFileThreadList.Add( ReceiveThread );

    ReceiveThread.SetSendPcID( SendPcID );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // ��æ
  if IsBusy then
    ReceiveBackConnEvent.ConnBusy( SendPcID );
end;

procedure TMyReceiveFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
  ReceiveThread : TReceiveFileHandleThread;
begin
    // �������
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // Ѱ�ҹ�����߳�
  ThreadLock.Enter;
  IsBusy := True;
  if ReceiveFileThreadList.Count < ThreadCount_Receive then
  begin
    IsBusy := False;
    ReceiveThread := TReceiveFileHandleThread.Create;
    ReceiveFileThreadList.Add( ReceiveThread );

    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', False );    // �����Ƿ�æ
    ReceiveThread.SetTcpSocket( TcpSocket );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // ֪ͨ�Է���æ
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', True ); // �����Ƿ�æ
    TcpSocket.Free;
  end;
end;

procedure TMyReceiveFileHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to ReceiveFileThreadList.Count - 1 do
    if ReceiveFileThreadList[i].ThreadID = ThreadID then
    begin
      ReceiveFileThreadList.Delete(i);
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyReceiveFileHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := ReceiveFileThreadList.Count > 0;
    ThreadLock.Leave;

    if not IsExistThread then
      Break;

    Sleep( 100 );
  end;
end;

{ TCloudBackupHandle }

constructor TReceiveFileRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

function TReceiveFileRequestHandle.getIsOtherReq(FileReq: string): Boolean;
begin
  Result := True;

    // ���ÿռ���Ϣ
  if FileReq = FileReq_SetSpace then
    SetReceiveSpace
  else  // ���� �������
  if FileReq = FileReq_SetCompleted then
  begin
    ReceiveItemAppApi.SetReceiveTime( ReceiveRootPath, OwnerPcID, SourcePath, Now );
    ReceiveItemAppApi.SetCompletedReceive( ReceiveRootPath, OwnerPcID, SourcePath );
  end
  else   // ����
  if FileReq = FileReq_HeartBeat then
  else
    Result := False;
end;

procedure TReceiveFileRequestHandle.HandleReq(FileReq, FilePath: string);
var
  ReceiveFilePath : string;
  ReceiveFileHandle : TReceiveFileHandle;
begin
  DebugLock.Debug( 'HandleReq: ' + FileReq + '  ' + FilePath );

    // �����ļ�·��
  ReceiveFilePath := MyFilePath.getReceivePath( SourcePath, FilePath, SavePath );

    // ����������Ϣ
  ReceiveFileHandle := TReceiveFileHandle.Create( FileReq );
  ReceiveFileHandle.SetReceiveFilePath( ReceiveFilePath );
  ReceiveFileHandle.SetTcpSocket( TcpSocket );
  ReceiveFileHandle.SetReceiveRootPath( ReceiveRootPath );
  ReceiveFileHandle.SetReceiveItemInfo( SourcePath, OwnerPcID );
  ReceiveFileHandle.SetSavePath( SavePath );
  ReceiveFileHandle.SetIsZip( IsZip );
  ReceiveFileHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ReceiveFileHandle.Update;
  ReceiveFileHandle.Free;
end;

procedure TReceiveFileRequestHandle.HandleRequest;
var
  FileReq, FilePath, ReceiveFilePath : string;
  ReceiveFileHandle : TReceiveFileHandle;
begin
  DebugLock.Debug( 'HandleRequest' );

    // ��ʼ���� ״̬
  ReceiveItemAppApi.SetStartReceive( ReceiveRootPath, OwnerPcID, SourcePath );

    // ��ȡ�Ƿ�ѹ������
  IsZip := ReceiveItemInfoReadUtil.ReadIsZip( ReceiveRootPath, SourcePath, OwnerPcID );

    // ѭ������
  RefreshSpeedInfo := ReceiveSpeedHandler.getSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID );
  while True do
  begin
        // �ѶϿ�����
    if not TcpSocket.Connected then
      Break;

      // ���շ���������
    if not MyReceiveFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // ��ȡ ��������
    FileReq := MySocketUtil.RevJsonStr( TcpSocket );
    if FileReq = FileReq_End then   // �������
      Break;

      // �����ѶϿ�
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // ������ļ���Ϣ
    if getIsOtherReq( FileReq ) then
      Continue;

      // ��ȡ �����ļ�
    FilePath := MySocketUtil.RevJsonStr( TcpSocket );

      // ���ʳ���
    if Pos( SourcePath, FilePath ) <= 0 then
      Break;

      // ����������Ϣ
    HandleReq( FileReq, FilePath );
  end;
  ReceiveSpeedHandler.RemoveSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID );

    // ֹͣ���� ״̬
  ReceiveItemAppApi.SetStopReceive( ReceiveRootPath, OwnerPcID, SourcePath );
end;

procedure TReceiveFileRequestHandle.ReadBaseInfo;
begin
  DebugLock.Debug( 'ReadBaseInfo' );

    // ����Ŀ¼
  ReceiveRootPath := MySocketUtil.RevJsonStr( TcpSocket );
  SourcePath := MySocketUtil.RevJsonStr( TcpSocket );
  OwnerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  SavePath := ReceiveItemInfoReadUtil.ReadSavePath( ReceiveRootPath, SourcePath, OwnerPcID );
  if SavePath = '' then
    Exit;
  if ReceiveItemInfoReadUtil.ReadIsFile( ReceiveRootPath, SourcePath, OwnerPcID ) then
    ForceDirectories( ExtractFileDir( SavePath ) )
  else
    ForceDirectories( SavePath );
end;

function TReceiveFileRequestHandle.SendAccessResult: Boolean;
var
  AccessResult : string;
begin
  DebugLock.Debug( 'SendAccessResult' );

    // ���ͷ��ʽ��
   Result := False;
  if not ReceiveRootInfoReadUtil.ReadIsExist( ReceiveRootPath ) then
    AccessResult := ReceiveConnResult_NotExist
  else
  if not ReceiveItemInfoReadUtil.ReadIsExist( ReceiveRootPath, SourcePath, OwnerPcID ) then
    AccessResult := ReceiveConnResult_Cancel
  else
  if not MyHardDisk.getPathDriverExist( ReceiveRootPath ) then
  begin
    AccessResult := ReceiveConnResult_NotExist;
    ReceiveRootItemAppApi.SetIsExist( ReceiveRootPath, False );
  end
  else
  if not MyFilePath.getIsModify( ReceiveRootPath ) then
  begin
    AccessResult := ReceiveConnResult_CannotWrite;
    ReceiveRootItemAppApi.SetIsWrite( ReceiveRootPath, False );
  end
  else
  begin
    Result := True;
    AccessResult := ReceiveConnResult_OK;
  end;
  MySocketUtil.SendJsonStr( TcpSocket, 'AccessResult', AccessResult );
end;

procedure TReceiveFileRequestHandle.SetReceiveSpace;
var
  FileCount : Integer;
  ItemSize, CompletedSpace : Int64;
  Params : TReceiveItemSetSpaceParams;
begin
  FileCount := MySocketUtil.RevJsonInt( TcpSocket );
  ItemSize := MySocketUtil.RevJsonInt64( TcpSocket );
  CompletedSpace := MySocketUtil.RevJsonInt64( TcpSocket );

  Params.RootPath := ReceiveRootPath;
  Params.SourcePath := SourcePath;
  Params.OwnerID := OwnerPcID;
  Params.FileCount := FileCount;
  Params.FileSize := ItemSize;
  Params.CompletedSpace := CompletedSpace;

  ReceiveItemAppApi.SetSpaceInfo( Params );
end;

procedure TReceiveFileRequestHandle.Update;
begin
    // ��ȡ Ҫ�������Ϣ
  ReadBaseInfo;

    // ���ͷ��ʽ��, ���ʳ����쳣�����
  if not SendAccessResult then
    Exit;

    // ����������
  HandleRequest;
end;

{ TNetworkBackupFileReceiveHandle }

procedure TSendFileReceiveHandle.AddSpeedSpace(Space: Integer);
begin
  MyRefreshSpeedHandler.AddDownload( Space );
end;

function TSendFileReceiveHandle.CheckNextReceive: Boolean;
begin
  Result := True;

    // 1 ���� ���һ��ɾ��
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := ReceiveItemInfoReadUtil.ReadIsExist( ReceiveRootPath, SourcePath, OwnerID );

  Result := Result and inherited and MyReceiveFileHandler.getIsRun;
end;

{ TCloudFileHandle }

procedure TReceiveFileHandle.AddFile;
var
  CloudFileReceiveHandle : TSendFileReceiveHandle;
  ZipFile : TZipFile;
begin
  CloudFileReceiveHandle := TSendFileReceiveHandle.Create( ReceiveFilePath );
  CloudFileReceiveHandle.SetTcpSocket( TcpSocket );
  CloudFileReceiveHandle.SetReceiveRootPath( ReceiveRootPath );
  CloudFileReceiveHandle.SetReceiveItemInfo( SourcePath, OwnerID );
  CloudFileReceiveHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  CloudFileReceiveHandle.Update;
  CloudFileReceiveHandle.Free;

    // �ǽ�ѹ�ļ�
  if not IsZip then
    Exit;

    // ��ѹ
  ZipFile := TZipFile.Create;
  ZipFile.ExtractZipFile( ReceiveFilePath, ReceiveRootPath );
  ZipFile.Free;

    // ɾ��ѹ���ļ�
  SysUtils.DeleteFile( ReceiveFilePath );
end;

procedure TReceiveFileHandle.AddFolder;
begin
  ForceDirectories( ReceiveFilePath );
end;

procedure TReceiveFileHandle.ContinuesAddFile;
var
  CloudFileReceiveHandle : TSendFileReceiveHandle;
begin
  CloudFileReceiveHandle := TSendFileReceiveHandle.Create( ReceiveFilePath );
  CloudFileReceiveHandle.SetTcpSocket( TcpSocket );
  CloudFileReceiveHandle.SetReceiveRootPath( ReceiveRootPath );
  CloudFileReceiveHandle.SetReceiveItemInfo( SourcePath, OwnerID );
  CloudFileReceiveHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  CloudFileReceiveHandle.Update;
  CloudFileReceiveHandle.Free;
end;

constructor TReceiveFileHandle.Create(_FileReq: string);
begin
  FileReq := _FileReq;
end;

procedure TReceiveFileHandle.ReadDeepFolder;
var
  NetworkChildFolderAccessFindHandle : TNetworkFolderAccessFindDeepHandle;
begin
  NetworkChildFolderAccessFindHandle := TNetworkFolderAccessFindDeepHandle.Create;
  NetworkChildFolderAccessFindHandle.SetFolderPath( ReceiveFilePath );
  NetworkChildFolderAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkChildFolderAccessFindHandle.Update;
  NetworkChildFolderAccessFindHandle.Free;
end;

procedure TReceiveFileHandle.ReadFile;
var
  NetworkFileAccessFindHandle : TNetworkFileAccessFindHandle;
begin
  NetworkFileAccessFindHandle := TNetworkFileAccessFindHandle.Create( ReceiveFilePath );
  NetworkFileAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileAccessFindHandle.Update;
  NetworkFileAccessFindHandle.Free;
end;

procedure TReceiveFileHandle.ReadFolder;
var
  NetworkFolderAccessFindHandle : TNetworkFolderAccessFindHandle;
begin
  NetworkFolderAccessFindHandle := TNetworkFolderAccessFindHandle.Create;
  NetworkFolderAccessFindHandle.SetFolderPath( ReceiveFilePath );
  NetworkFolderAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderAccessFindHandle.Update;
  NetworkFolderAccessFindHandle.Free;
end;

procedure TReceiveFileHandle.RemoveFile;
begin
  SysUtils.DeleteFile( ReceiveFilePath );
end;

procedure TReceiveFileHandle.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveFileHandle.SetReceiveFilePath(_ReceiveFilePath: string);
begin
  ReceiveFilePath := _ReceiveFilePath;
end;

procedure TReceiveFileHandle.SetReceiveItemInfo(_SourcePath, _OwnerID: string);
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;

procedure TReceiveFileHandle.SetReceiveRootPath(_ReceiveRootPath: string);
begin
  ReceiveRootPath := _ReceiveRootPath;
end;

procedure TReceiveFileHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

procedure TReceiveFileHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TReceiveFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TReceiveFileHandle.Update;
begin
  if FileReq = FileReq_ReadFile then
    ReadFile
  else
  if FileReq = FileReq_ReadFolder then
    ReadFolder
  else
  if FileReq = FileReq_AddFile then
    AddFile
  else
  if FileReq = FileReq_AddFolder then
    AddFolder
  else
  if FileReq = FileReq_RemoveFile then
    RemoveFile
  else
  if FileReq = FileReq_ContinuesAdd then
    ContinuesAddFile
  else
  if FileReq = FileReq_ZipFile then
    ZipFile
  else
  if FileReq = FileReq_ReadFolderDeep then
    ReadDeepFolder;
end;


procedure TReceiveFileHandle.ZipFile;
var
  SendFileReceiveZipHandle : TSendFileReceiveZipHandle;
begin
    // ����ѹ���ļ�
  SendFileReceiveZipHandle := TSendFileReceiveZipHandle.Create( ReceiveFilePath );
  SendFileReceiveZipHandle.SetTcpSocket( TcpSocket );
  SendFileReceiveZipHandle.SetReceiveRootPath( ReceiveRootPath );
  SendFileReceiveZipHandle.SetReceiveItemInfo( SourcePath, OwnerID );
  SendFileReceiveZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  SendFileReceiveZipHandle.SetSavePath( SavePath );
  SendFileReceiveZipHandle.Update;
  SendFileReceiveZipHandle.Free;

    // ���ͽ�ѹ���
  if TcpSocket.Connected then
    MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_New );
end;


procedure TSendFileReceiveHandle.RefreshCompletedSpace;
begin
    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
      // ˢ���ٶ�
    ReceiveItemAppApi.SetSpeedInfo( ReceiveRootPath, OwnerID, SourcePath, RefreshSpeedInfo.LastSpeed );
  end;

    // �������ɿռ�
  ReceiveItemAppApi.AddCompletedSpace( ReceiveRootPath, OwnerID, SourcePath, AddCompletedSpace );

  AddCompletedSpace := 0;
end;

procedure TSendFileReceiveHandle.SetReceiveItemInfo(_SourcePath,
  _OwnerID: string);
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;

procedure TSendFileReceiveHandle.SetReceiveRootPath(_ReceiveRootPath: string);
begin
  ReceiveRootPath := _ReceiveRootPath;
end;

procedure TSendFileReceiveHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

{ TSendFileReceiveZipHandle }

function TSendFileReceiveZipHandle.CreateWriteStream: Boolean;
begin
  WriteStream := TMemoryStream.Create;
  Result := True;
end;

procedure TSendFileReceiveZipHandle.LastRefreshCompletedSpace;
var
  ZipFile : TZipFile;
  FileName, FilePath : string;
  FileDate : TDateTime;
  i: Integer;
  StartTime : TDateTime;
begin
  inherited;

    // �����ѶϿ�
  if not TcpSocket.Connected then
    Exit;

    // ��ѹ�ļ�
  StartTime := Now;
  ZipFile := TZipFile.Create;
  try
    WriteStream.Position := 0;
    ZipFile.Open( WriteStream, zmRead );
    try
      for i := 0 to ZipFile.FileCount - 1 do
      begin
        try
          ZipFile.Extract( i, SavePath );
          FileName := ZipFile.FileInfo[i].FileName;
          FileName := StringReplace( FileName, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getPath( SavePath ) + FileName;
          FileDate := FileDateToDateTime( ZipFile.FileInfo[i].ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );
        except
        end;
          // ��ѹʱ����ܹ�������ʱ��������
        HeartBeatReceiver.CheckSend( TcpSocket, StartTime );
      end;
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;
end;

procedure TSendFileReceiveZipHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TReceiveSpeedInfo }

constructor TReceiveSpeedInfo.Create(_ReceiveRootPath, _SourcePath,
  _OwnerPcID: string);
begin
  ReceiveRootPath := _ReceiveRootPath;
  SourcePath := _SourcePath;
  OwnerPcID := _OwnerPcID;
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  ReceiveCount := 1;
end;

destructor TReceiveSpeedInfo.Destroy;
begin
  RefreshSpeedInfo.Free;
  inherited;
end;

{ TReceiveSpeedHandler }

constructor TReceiveSpeedHandler.Create;
begin
  SpeedLock := TCriticalSection.Create;
  ReceiveSpeedList := TReceiveSpeedList.Create;
end;

destructor TReceiveSpeedHandler.Destroy;
begin
  ReceiveSpeedList.Free;
  SpeedLock.Free;
  inherited;
end;

function TReceiveSpeedHandler.getSpeedInfo(ReceiveRootPath, SourcePath,
  OwnerPcID: string): TRefreshSpeedInfo;
var
  i: Integer;
  IsFind : Boolean;
  ReceiveSpeedInfo : TReceiveSpeedInfo;
begin
  SpeedLock.Enter;
  IsFind := False;
  for i := 0 to ReceiveSpeedList.Count - 1 do
    if ( ReceiveSpeedList[i].ReceiveRootPath = ReceiveRootPath ) and
       ( ReceiveSpeedList[i].SourcePath = SourcePath ) and
       ( ReceiveSpeedList[i].OwnerPcID = OwnerPcID )
    then
    begin
      ReceiveSpeedList[i].ReceiveCount := ReceiveSpeedList[i].ReceiveCount + 1;
      Result := ReceiveSpeedList[i].RefreshSpeedInfo;
      IsFind := True;
      Break;
    end;
  if not IsFind then
  begin
    ReceiveSpeedInfo := TReceiveSpeedInfo.Create( ReceiveRootPath, SourcePath, OwnerPcID );
    ReceiveSpeedList.Add( ReceiveSpeedInfo );
    Result := ReceiveSpeedInfo.RefreshSpeedInfo;
  end;
  SpeedLock.Leave;
end;

procedure TReceiveSpeedHandler.RemoveSpeedInfo(ReceiveRootPath, SourcePath,
  OwnerPcID: string);
var
  i: Integer;
begin
  SpeedLock.Enter;
  for i := 0 to ReceiveSpeedList.Count - 1 do
    if ( ReceiveSpeedList[i].ReceiveRootPath = ReceiveRootPath ) and
       ( ReceiveSpeedList[i].SourcePath = SourcePath ) and
       ( ReceiveSpeedList[i].OwnerPcID = OwnerPcID )
    then
    begin
      ReceiveSpeedList[i].ReceiveCount := ReceiveSpeedList[i].ReceiveCount - 1;
      if ReceiveSpeedList[i].ReceiveCount <= 0 then
        ReceiveSpeedList.Delete( i );
      Break;
    end;
  SpeedLock.Leave;
end;

{ TReceiveRootRequestHandle }

constructor TReceiveRootRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TReceiveRootRequestHandle.HandleRevcFile;
var
  ReceiveFileRequestHandle : TReceiveFileRequestHandle;
begin
  ReceiveFileRequestHandle := TReceiveFileRequestHandle.Create( TcpSocket );
  ReceiveFileRequestHandle.Update;
  ReceiveFileRequestHandle.Free;
end;

procedure TReceiveRootRequestHandle.Update;
begin
  while True do
  begin
    HandleRevcFile;

    if not WaitNextRevc then
      Break;
  end;
end;

function TReceiveRootRequestHandle.WaitNextRevc: Boolean;
var
  FileReq : string;
  StartTime : TDateTime;
  Num : Integer;
begin
  Result := False;

    // �ȴ���һ�ε�����
  Num := 0;
  while TcpSocket.Connected and MyReceiveFileHandler.getIsRun do
  begin
      // ��ȡ �������ͣ��ȴ�һ��
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // ����
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // ֻ����ʼ���
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_New );  // ���ؿ�ʼ���
      Result := True;
      Break;
    end;

      // ����
    if FileReq = FileReq_End then
      Break;

      // 60��û������, ����
    if Num > 60 then
      Break;

      // ����
    inc( Num );
  end;
end;


end.
