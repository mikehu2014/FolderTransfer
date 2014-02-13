unit UReceiveThread;

interface

uses classes, Sockets, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, Syncobjs,
     UMyDebug, uDebugLock, Zip, uDebug;

type

    // 接收 发送文件
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
    procedure AddSpeedSpace( Space : Integer );override; // 刷新速度信息
  end;

    // 接收 压缩文件
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

    // 接收文件处理
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
  private       // 读取
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadDeepFolder;
  private       // 修改
    procedure AddFile;
    procedure AddFolder;
    procedure RemoveFile;
    procedure ContinuesAddFile;
  private       // 压缩
    procedure ZipFile;
  end;

    // 速度信息
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

    // 接收速度处理器
  TReceiveSpeedHandler = class
  public
    SpeedLock : TCriticalSection;
    ReceiveSpeedList : TReceiveSpeedList;
  public
    constructor Create;
    destructor Destroy; override;
  public      // 获取/删除 速度控制器
    function getSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID : string ): TRefreshSpeedInfo;
    procedure RemoveSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID : string );
  end;

    // 备份算法
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
    procedure ReadBaseInfo;  // 读取请求信息
    function SendAccessResult: Boolean;  // 发送访问结果
    procedure HandleRequest;  // 处理各种请求
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure SetReceiveSpace; // 设置空间信息
  private
    procedure HandleReq( FileReq, FilePath : string );
  end;

    // 接收 根路径
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

    // 云文件处理线程
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
    function ConnToSendPc : Boolean; // 连接需要发送的Pc
    procedure HandleRequest; // 处理请求
  end;
  TReceiveFileHandleThreadList = class( TObjectList< TReceiveFileHandleThread > )end;


    // 云文件处理
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

    // 提取 Pc Socket 信息
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( SendPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( SendPcID );

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_SendFile );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // 连接失败
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
      // 如果没有连接，则先连接
    if IsConnnected or ConnToSendPc then
      HandleRequest; // 处理备份扫描
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Receive File Error', e.Message );
  end;

    // 断开连接
  TcpSocket.Disconnect;
  TcpSocket.Free;

    // 删除线程记录
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
    // 程序结束
  if not IsRun then
    Exit;

    // 创建接收线程
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

    // 繁忙
  if IsBusy then
    ReceiveBackConnEvent.ConnBusy( SendPcID );
end;

procedure TMyReceiveFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
  ReceiveThread : TReceiveFileHandleThread;
begin
    // 程序结束
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // 寻找挂起的线程
  ThreadLock.Enter;
  IsBusy := True;
  if ReceiveFileThreadList.Count < ThreadCount_Receive then
  begin
    IsBusy := False;
    ReceiveThread := TReceiveFileHandleThread.Create;
    ReceiveFileThreadList.Add( ReceiveThread );

    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', False );    // 发送是否繁忙
    ReceiveThread.SetTcpSocket( TcpSocket );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // 通知对方繁忙
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, 'IsBusy', True ); // 发送是否繁忙
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

    // 设置空间信息
  if FileReq = FileReq_SetSpace then
    SetReceiveSpace
  else  // 设置 接收完成
  if FileReq = FileReq_SetCompleted then
  begin
    ReceiveItemAppApi.SetReceiveTime( ReceiveRootPath, OwnerPcID, SourcePath, Now );
    ReceiveItemAppApi.SetCompletedReceive( ReceiveRootPath, OwnerPcID, SourcePath );
  end
  else   // 心跳
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

    // 接收文件路径
  ReceiveFilePath := MyFilePath.getReceivePath( SourcePath, FilePath, SavePath );

    // 处理请求信息
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

    // 开始接收 状态
  ReceiveItemAppApi.SetStartReceive( ReceiveRootPath, OwnerPcID, SourcePath );

    // 读取是否压缩发送
  IsZip := ReceiveItemInfoReadUtil.ReadIsZip( ReceiveRootPath, SourcePath, OwnerPcID );

    // 循环访问
  RefreshSpeedInfo := ReceiveSpeedHandler.getSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID );
  while True do
  begin
        // 已断开连接
    if not TcpSocket.Connected then
      Break;

      // 接收方结束程序
    if not MyReceiveFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 读取 请求类型
    FileReq := MySocketUtil.RevJsonStr( TcpSocket );
    if FileReq = FileReq_End then   // 结束标记
      Break;

      // 连接已断开
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 处理非文件信息
    if getIsOtherReq( FileReq ) then
      Continue;

      // 读取 请求文件
    FilePath := MySocketUtil.RevJsonStr( TcpSocket );

      // 访问出错
    if Pos( SourcePath, FilePath ) <= 0 then
      Break;

      // 处理请求信息
    HandleReq( FileReq, FilePath );
  end;
  ReceiveSpeedHandler.RemoveSpeedInfo( ReceiveRootPath, SourcePath, OwnerPcID );

    // 停止接收 状态
  ReceiveItemAppApi.SetStopReceive( ReceiveRootPath, OwnerPcID, SourcePath );
end;

procedure TReceiveFileRequestHandle.ReadBaseInfo;
begin
  DebugLock.Debug( 'ReadBaseInfo' );

    // 接收目录
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

    // 发送访问结果
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
    // 获取 要处理的信息
  ReadBaseInfo;

    // 发送访问结果, 访问出现异常则结束
  if not SendAccessResult then
    Exit;

    // 处理请求结果
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

    // 1 秒钟 检测一次删除
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

    // 非解压文件
  if not IsZip then
    Exit;

    // 解压
  ZipFile := TZipFile.Create;
  ZipFile.ExtractZipFile( ReceiveFilePath, ReceiveRootPath );
  ZipFile.Free;

    // 删除压缩文件
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
    // 接收压缩文件
  SendFileReceiveZipHandle := TSendFileReceiveZipHandle.Create( ReceiveFilePath );
  SendFileReceiveZipHandle.SetTcpSocket( TcpSocket );
  SendFileReceiveZipHandle.SetReceiveRootPath( ReceiveRootPath );
  SendFileReceiveZipHandle.SetReceiveItemInfo( SourcePath, OwnerID );
  SendFileReceiveZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  SendFileReceiveZipHandle.SetSavePath( SavePath );
  SendFileReceiveZipHandle.Update;
  SendFileReceiveZipHandle.Free;

    // 发送解压完成
  if TcpSocket.Connected then
    MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_New );
end;


procedure TSendFileReceiveHandle.RefreshCompletedSpace;
begin
    // 刷新速度
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
      // 刷新速度
    ReceiveItemAppApi.SetSpeedInfo( ReceiveRootPath, OwnerID, SourcePath, RefreshSpeedInfo.LastSpeed );
  end;

    // 添加已完成空间
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

    // 连接已断开
  if not TcpSocket.Connected then
    Exit;

    // 解压文件
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
          // 解压时间可能过长，定时发送心跳
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

    // 等待下一次的连接
  Num := 0;
  while TcpSocket.Connected and MyReceiveFileHandler.getIsRun do
  begin
      // 读取 请求类型，等待一秒
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // 心跳
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // 只允许开始标记
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_New );  // 返回开始标记
      Result := True;
      Break;
    end;

      // 结束
    if FileReq = FileReq_End then
      Break;

      // 60秒没有心跳, 结束
    if Num > 60 then
      Break;

      // 增加
    inc( Num );
  end;
end;


end.
