unit USendThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp, UFolderCompare, UMyDebug,
     uDebugLock, Zip;

type

{$Region ' 数据结构 ' }

    // 扫描信息
  TSendJobInfo = class
  public
    SendPath : string; // 发送路径
    DesItemID : string;  // 目标信息
  public
    constructor Create( _SendPath : string );
    procedure SetDesItemID( _DesItemID : string );
  end;
  TSendJobList = class( TObjectList<TSendJobInfo> )end;

    // 本地备份 扫描信息
  TLocalScanPathInfo = class( TSendJobInfo )
  end;

    // 网络备份 扫描信息
  TNetworkScanPathInfo = class( TSendJobInfo )
  end;

{$EndRegion}

{$Region ' 发送 扫描 ' }

    // 寻找 备份目录信息
  TBackupFolderFindHandle = class( TLocalFolderFindHandle )
  public
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
    function IsFolderFilter( FolderPath : string ): Boolean;override;
  end;

    // 备份目录 比较算法
  TBackupFolderScanHandle = class( TFolderScanHandle )
  public
    DesItemID, SourcePath : string;
  public
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected
    procedure FindSourceFileInfo;override;
  protected
    function CheckNextScan : Boolean;override;
  end;

    // 备份文件 比较算法
  TBackupFileScanHandle = class( TFileScanHandle )
  protected
    function FindSourceFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 发送 操作 ' }

    // 续传处理
  TBackupContinuesHandle = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    DesItemID, SourcePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetSourceFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;virtual;
  protected
    function getIsSourceChange : Boolean;
    function getIsDesChange : Boolean;virtual;abstract;
    function FileCopy: Boolean;virtual;abstract;
    procedure RemoveContinusInfo;
  end;

    // 处理扫描结果
  TBackupResultHandle = class
  public
    ScanResultInfo : TScanResultInfo;
    SourceFilePath : string;
    DesItemID, SourcePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;virtual;
  protected         // 添加
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
  protected         // 删除
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // 压缩
    procedure SourceFileAddZip;virtual;
  private           // 写日志
    procedure LogSendCompleted;
    procedure LogSendIncompleted;
  end;

    // 处理扫描结果
  TBackupFileHandle = class
  public
    DesItemID, SourcePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure IniHandle;virtual;
    procedure Handle( ScanResultInfo : TScanResultInfo );virtual;abstract;
    procedure CompletedHandle;virtual;
  end;

      // 备份试用版限制
  TSendFileFreeLimitReader = class
  private
    IsFreeLimit : Boolean;
    FileCount : Integer;
    FreeLimitType : string;
  public
    constructor Create;
    procedure SetFileCount( _FileCount : Integer );
    procedure IniHandle;
    function AddResult( ScanResultInfo : TScanResultInfo ): Boolean;
    function getFreeLimitType : string;
  end;

      // 是否取消备份
  TSendFileCancelReader = class
  private
    DesItemID, SourcePath : string;
  private
    ScanTime : TDateTime;
    SleepCount : Integer;
  public
    constructor Create;
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    function getIsRun : Boolean;virtual;
  end;

    // 备份路径处理
  TSendHandle = class
  public
    ScanPathInfo : TSendJobInfo;
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public   // 文件扫描结果
    TotalCount, TotalCompletedCount : Integer;
    TotalSize, TotalCompletedSize : Int64;
  public   // 文件变化信息
    ScanResultList : TScanResultList;
  private
    FreeLimitType : string; // 是否收到免费版限制
  public
    constructor Create;
    procedure SetScanPathInfo( _ScanPathInfo : TSendJobInfo );
    procedure Update;virtual;
    destructor Destroy; override;
  protected       // 备份前检测
    function getDesItemIsBackup: Boolean;virtual;abstract;
    function getSourcePathIsBackup : Boolean;
  protected       // 扫描
    procedure ContinuesHandle; // 续传
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace; virtual;
    function getContinuesHandle : TBackupContinuesHandle;virtual;abstract;
    function getFileScanHandle : TBackupFileScanHandle;virtual;abstract;
    function getFolderScanHandle : TBackupFolderScanHandle;virtual;abstract;
    function getIsScanCompleted : Boolean;virtual;
  protected       // 备份
    procedure BackupFileHandle;
    function getBackupFileHandle: TBackupFileHandle;virtual;abstract;
    function getRefreshSpeedInfo : TRefreshSpeedInfo;virtual;
    function getSendFileCancelReader : TSendFileCancelReader;virtual;
    function getIsBackupNext : Boolean;virtual; // 是否继续备份操作
  protected       // 备份完成
    function getIsBackupCompleted : Boolean;
    procedure SetBackupCompleted;virtual;abstract;
    procedure FreeLimitWarinningCheck;
  end;


{$EndRegion}


{$Region ' 本地发送 扫描 ' }

    // 本地备份目录 比较
  TLocalBackupFolderScanHandle = class( TBackupFolderScanHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // 本地文件
  TLocalBackupFileScanHandle = class( TBackupFileScanHandle )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 本地发送 复制 ' }

    // 备份复制
  TBackupFileCopyHandle = class( TFileCopyHandle )
  protected
    DesItemID, SourcePath : string;
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
  protected
    procedure RefreshCompletedSpace;override;
    function CheckNextCopy : Boolean;override; // 检测是否继续复制
  protected
    procedure MarkContinusCopy;override; // 续传
    procedure DesWriteSpaceLack;override; // 空间不足
    procedure ReadFileError;override;  // 读文件出错
    procedure WriteFileError;override; // 写文件出错
  end;

{$Endregion}

{$Region ' 本地发送 操作 ' }

    // 本地文件 续传
  TLocalBackupContinuesHandle = class( TBackupContinuesHandle )
  private
    DesFilePath : string;
  public
    procedure Update;override;
  public
    function getIsDesChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

    // 结果处理
  TLocalBackupResultHandle = class( TBackupResultHandle )
  public
    SavePath : string;
    DesFilePath : string; // 目标路径
  public
    procedure SetSavePath( _SavePath : string );
    procedure Update;override;
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  end;

    // 备份
  TLocalBackupFileHandle = class( TBackupFileHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
  end;

    // 备份路径处理
  TLocalSendHandle = class( TSendHandle )
  private
    SavePath : string;
  public
    procedure Update;override;
  protected       // 备份前检测
    function getDesItemIsBackup: Boolean;override;
  protected       // 扫描
    function getContinuesHandle : TBackupContinuesHandle;override;
    function getFileScanHandle : TBackupFileScanHandle;override;
    function getFolderScanHandle : TBackupFolderScanHandle;override;
  protected       // 备份
    function getBackupFileHandle: TBackupFileHandle;override;
  protected       // 备份完成
    procedure SetBackupCompleted;override;
  end;

{$EndRegion}


{$Region ' 网络发送 扫描 ' }

    // 网络目录
  TNetworkFolderScanHandle = class( TBackupFolderScanHandle )
  public
    TcpSocket : TCustomIpClient;
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;override;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // 网络文件
  TNetworkFileScanHandle = class( TBackupFileScanHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 网络发送 复制 ' }

    // 发送备份文件
  TNetworkBackupFileSendHandle = class( TNetworkFileSendHandle )
  protected
    DesItemID, SourcePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
  protected
    function CheckNextSend : Boolean;override;
    procedure RefreshCompletedSpace;override;
    procedure AddSpeedSpace( Space : Integer );override;
    function getLimitBlockSize : Int64;override;
  protected
    procedure RevFileLackSpaceHandle;override;  // 缺小空间
    procedure MarkContinusSend;override; // 续传
    procedure ReadFileError;override;  // 读文件出错
    procedure WriteFileError;override; // 写文件出错
    procedure LostConnectError;override; // 断开连接
    procedure SendFileError;override; // 发送文件失败
  end;

    // 发送压缩文件
  TNetworkBackupFileSendZipHandle = class( TNetworkBackupFileSendHandle )
  private
    ZipStream : TMemoryStream;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
  protected
    function CreateReadStream : Boolean;override;
  protected
    procedure MarkContinusSend;override; // 续传
    procedure ReadFileError;override;  // 读文件出错
    procedure WriteFileError;override; // 写文件出错
  end;

{$EndRegion}

{$Region ' 网络发送 操作 ' }

    // 网络文件 续传
  TNetworkSendContinuesHandle = class( TBackupContinuesHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    function getIsDesChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

    // 备份文件结果处理
  TNetworkSendResultHandle = class( TBackupResultHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // 压缩
    procedure SourceFileAddZip;override;
  private
    procedure SendFileReq( FileReq : string );
    procedure LogZipFile( ZipName : string; IsCompleted : Boolean );
  end;

     // 压缩发送文件
  TCompressSendFileHandle = class
  private
    DesItemID, SourcePath : string;
  private
    ZipStream : TMemoryStream;
    ZipFile : TZipFile;
  private
    IsCreated : Boolean;
    TotalSize, ZipSize : Int64;
    ZipCount : Integer;
  public
    constructor Create( _DesItemID, _SourcePath : string );
    function AddZipFile( ScanResultInfo : TScanResultInfo ): TScanResultInfo;
    function getLastSendFile: TScanResultInfo;
    destructor Destroy; override;
  private
    function CreateZip: Boolean;
    function AddFile( FilePath : string ): Boolean;
    function getZipResultInfo : TScanResultAddZipInfo;
    procedure DestoryZip;
  end;

    // 发送文件线程
  TSendFileThread = class( TDebugThread )
  public
    ScanResultInfo : TScanResultInfo;
    IsRun, IsLostConn : Boolean;
    DesItemID, SourcePath : string;
    TcpSocket : TCustomIpClient;
    RefreshSpeedInfo: TRefreshSpeedInfo;
  public
    constructor Create;
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure AddScanResultInfo( _ScanResultInfo : TScanResultInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure WaitToSend;
    procedure SendFile;
  end;
  TSendFileThreadList = class( TObjectList<TSendFileThread> )end;

    // 结果处理
  TNetworkBackupFileHandle = class( TBackupFileHandle )
  private
    IsFile, IsExitJob : Boolean;
    TcpSocket : TCustomIpClient;
    CompressFileHandle : TCompressSendFileHandle;
    SendFileThreadList : TSendFileThreadList;
    IsFreeLimit : Boolean;
  private
    HeartTime : TDateTime;
  public
    constructor Create;
    procedure SetBackupInfo( _IsFile, _IsExistJob : Boolean );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure IniHandle;override;
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure CompletedHandle;override;
    destructor Destroy; override;
  private
    function getNewConnect : TCustomIpClient;
    procedure SendFile( ScanResultInfo : TScanResultInfo );
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
    procedure CheckHeartBeat;
  end;

    // 发送取消器
  TNetworkSendFileCancelReader = class( TSendFileCancelReader )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function getIsRun : Boolean;override;
  end;

    // 备份路径处理
  TNetworkSendHandle = class( TSendHandle )
  public
    TcpSocket : TCustomIpClient;
    HeartBeatHelper : THeatBeatHelper;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected       // 备份前检测
    function getDesItemIsBackup: Boolean;override;
  protected       // 扫描
    function getContinuesHandle : TBackupContinuesHandle;override;
    function getFileScanHandle : TBackupFileScanHandle;override;
    function getFolderScanHandle : TBackupFolderScanHandle;override;
    function getIsScanCompleted : Boolean;override;
    procedure ResetSourcePathSpace;override;
  protected       // 备份
    function getBackupFileHandle: TBackupFileHandle;override;
    function getRefreshSpeedInfo : TRefreshSpeedInfo;override;
    function getSendFileCancelReader : TSendFileCancelReader;override;
  protected       // 备份完成
    procedure SetBackupCompleted;override;
  end;

{$EndRegion}


    // 已连接的 Socket
  TSendFileSocketInfo = class
  public
    DesPcID : string;
    TcpSocket : TCustomIpClient;
    LastTime : TDateTime;
  public
    constructor Create( _DesPcID : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    procedure CloseSocket;
  end;
  TSendFileSocketList = class( TObjectList<TSendFileSocketInfo> )end;

    // 处理连接
  TMyFileSendConnectHandler = class
  private
    SocketLock : TCriticalSection;
    SendFileSocketList : TSendFileSocketList;
  private
    DesItemID, SourcePath : string;
  private
    IsConnSuccess, IsConnError, IsConnBusy : Boolean;
    BackConnSocket : TCustomIpClient;
  public       // 获取反向连接
    constructor Create;
    function getSendPcConn( _DesItemID, _SourcePath : string ) : TCustomIpClient;
    procedure AddLastConn( LastDesItemID : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh;
    procedure StopRun;
    destructor Destroy; override;
  public       // 远程结果
    procedure AddBackConn( TcpSocket : TCustomIpClient );
    procedure BackConnBusy;
    procedure BackConnError;
  private      // 等待
    function getConnect : TCustomIpClient;
    function getLastConnect : TCustomIpClient;
    function getBackConnect : TCustomIpClient;
    procedure WaitBackConn;
  end;

    // 源目录 扫描
    // 目标目录 复制/删除
  TFileSendHandleThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // 扫描
    procedure SendFileHandle( ScanPathInfo : TSendJobInfo );
    procedure StopScan( ScanPathInfo : TSendJobInfo );
  end;

    // 本地备份 源路径 扫描和复制
  TMyFileSendHandler = class
  public
    IsSendRun : Boolean;  // 是否继续发送
    IsRun : Boolean;  // 是否程序结束
  private
    ThreadLock : TCriticalSection;
    SendJobList : TSendJobList;
    IsCreateThread : Boolean;
    FileSendHandleThread : TFileSendHandleThread;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public       // 读取状态信息
    function getIsRun : Boolean;
    function getIsSending : Boolean;
  public
    procedure AddScanJob( ScanJobInfo : TSendJobInfo );
    function getSendJob : TSendJobInfo;
  end;

const
  Name_TempSendZip = 'ft_send_zip_temp.bczip';

var
    // 发送文件线程
  MyFileSendHandler : TMyFileSendHandler;
  MyFileSendConnectHandler : TMyFileSendConnectHandler;  // 反向连接线程

implementation

uses UMySendApiInfo, UMySendDataInfo, UMyNetPcInfo, UMySendEventInfo, UMyReceiveApiInfo,
     UMyRegisterDataInfo, UMyRegisterApiInfo, UMainFormThread, UNetworkControl;

{ TFileCopyHandle }

function TBackupFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

    // 1 秒钟 检测一次  是否备份中断
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );

  Result := Result and inherited;

    // 可能已经 Disable
  Result := Result and MyFileSendHandler.getIsRun;
end;

procedure TBackupFileCopyHandle.DesWriteSpaceLack;
begin
  SendRootItemAppApi.setIsLackSpace( DesItemID, True );
end;

procedure TBackupFileCopyHandle.MarkContinusCopy;
var
  Params : TSendContinusAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.FileTime := FileTime;
  Params.Position := Position;
  SendContinusAppApi.AddItem( Params );
end;

procedure TBackupFileCopyHandle.ReadFileError;
var
  Params : TSendErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := Position;
  SendErrorAppApi.ReadFileError( Params );
end;

procedure TBackupFileCopyHandle.RefreshCompletedSpace;
begin
    // 刷新速度
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // 设置 刷新备份速度
    SendItemAppApi.SetSpeed( DesItemID, SourcePath, RefreshSpeedInfo.LastSpeed );
  end;

    // 设置 已完成空间
  SendItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TBackupFileCopyHandle.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupFileCopyHandle.WriteFileError;
var
  Params : TSendErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := Position;
  SendErrorAppApi.WriteFileError( Params );
end;

{ TLocalBackupSourceScanThread }

procedure TFileSendHandleThread.StopScan(ScanPathInfo: TSendJobInfo);
begin
  SendItemAppApi.SetStopBackup( ScanPathInfo.DesItemID, ScanPathInfo.SendPath );
  ScanPathInfo.Free;
end;

constructor TFileSendHandleThread.Create;
begin
  inherited Create;
end;

destructor TFileSendHandleThread.Destroy;
begin
  inherited;
end;

procedure TFileSendHandleThread.Execute;
var
  ScanPathInfo : TSendJobInfo;
begin
  FreeOnTerminate := True;

  // 开始备份
  SendItemAppApi.BackupStart;

  MyFileSendHandler.IsSendRun := True;

  while MyFileSendHandler.IsRun do
  begin
    ScanPathInfo := MyFileSendHandler.getSendJob;
    if ScanPathInfo = nil then
      Break;

    try
        // 扫描路径
      SendFileHandle( ScanPathInfo );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Send File Error', e.Message );
    end;

      // 停止扫描
    StopScan( ScanPathInfo );
  end;

    // 结束备份
  if not MyFileSendHandler.IsSendRun then
    SendItemAppApi.BackupPause
  else
    SendItemAppApi.BackupStop;

    // 程序结束
  if not MyFileSendHandler.IsRun then
    MyFileSendHandler.IsCreateThread := False;

  Terminate;
end;

procedure TFileSendHandleThread.SendFileHandle(ScanPathInfo: TSendJobInfo);
var
  SendHandle : TSendHandle;
begin
  DebugLock.Debug( 'SendFileHandle' );

  if ScanPathInfo is TLocalScanPathInfo then
    SendHandle := TLocalSendHandle.Create
  else
  if ScanPathInfo is TNetworkScanPathInfo then
    SendHandle := TNetworkSendHandle.Create;
  SendHandle.SetScanPathInfo( ScanPathInfo );
  SendHandle.Update;
  SendHandle.Free;
end;

{ TScanPathInfo }

constructor TSendJobInfo.Create(_SendPath: string);
begin
  SendPath := _SendPath;
end;

{ TMyLocalBackupSourceScanner }

procedure TMyFileSendHandler.AddScanJob(
  ScanJobInfo: TSendJobInfo);
begin
  if not IsRun then
    Exit;

  ThreadLock.Enter;

  SendJobList.Add( ScanJobInfo );

  if not IsCreateThread then
  begin
    IsCreateThread := True;
    FileSendHandleThread := TFileSendHandleThread.Create;
    FileSendHandleThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyFileSendHandler.Create;
begin
  IsSendRun := True;
  IsRun := True;

  ThreadLock := TCriticalSection.Create;
  SendJobList := TSendJobList.Create;
  SendJobList.OwnsObjects := False;
  IsCreateThread := False;
end;

destructor TMyFileSendHandler.Destroy;
begin
  SendJobList.OwnsObjects := True;
  SendJobList.Free;
  ThreadLock.Free;

  inherited;
end;

function TMyFileSendHandler.getIsRun: Boolean;
begin
  Result := IsSendRun and IsRun;
end;

function TMyFileSendHandler.getIsSending: Boolean;
begin
  Result := False;
  if not IsRun then
    Exit;
  Result := IsCreateThread;
end;

function TMyFileSendHandler.getSendJob: TSendJobInfo;
begin
  ThreadLock.Enter;
  if SendJobList.Count > 0 then
  begin
    Result := SendJobList[0];
    SendJobList.Delete(0);
  end
  else
  begin
    Result := nil;
    IsCreateThread := False;
  end;
  ThreadLock.Leave;
end;

procedure TMyFileSendHandler.StopScan;
begin
  IsRun := False;

  while IsCreateThread do
    Sleep( 100 );
end;

{ TScanPathHandle }

function TLocalSendHandle.getBackupFileHandle: TBackupFileHandle;
var
  LocalBackupFileHandle : TLocalBackupFileHandle;
begin
  LocalBackupFileHandle := TLocalBackupFileHandle.Create;
  LocalBackupFileHandle.SetSavePath( SavePath );
  Result := LocalBackupFileHandle;
end;

function TLocalSendHandle.getContinuesHandle: TBackupContinuesHandle;
begin
  Result := TLocalBackupContinuesHandle.Create;
end;

function TLocalSendHandle.getDesItemIsBackup: Boolean;
begin
    // 设置不缺小空间
  SendRootItemAppApi.SetIsLackSpace( DesItemID, False );

    // 是否存在磁盘
  Result := MyHardDisk.getPathDriverExist( DesItemID );
  SendRootItemAppApi.SetIsExist( DesItemID, Result );
  if not Result then
    Exit;

    // 创建保存目录
  if FileExists( SourcePath ) then
    ForceDirectories( ExtractFileDir( SavePath ) )
  else
    ForceDirectories( SavePath );


    // 是否可写
  Result := MyFilePath.getIsModify( DesItemID );
  SendRootItemAppApi.SetIsWrite( DesItemID, Result );
  if not Result then
    Exit;
end;

function TLocalSendHandle.getFileScanHandle: TBackupFileScanHandle;
var
  LocalFileScanHandle : TLocalBackupFileScanHandle;
begin
  LocalFileScanHandle := TLocalBackupFileScanHandle.Create;
  LocalFileScanHandle.SetSavePath( SavePath );
  Result := LocalFileScanHandle;
end;

function TLocalSendHandle.getFolderScanHandle: TBackupFolderScanHandle;
var
  LocalFolderScanHandle : TLocalBackupFolderScanHandle;
begin
  LocalFolderScanHandle := TLocalBackupFolderScanHandle.Create;
  LocalFolderScanHandle.SetSavePath( SavePath );
  Result := LocalFolderScanHandle;
end;

procedure TLocalSendHandle.SetBackupCompleted;
begin
  SendItemAppApi.SetLocalBackupCompleted( DesItemID, SourcePath );
end;

procedure TLocalSendHandle.Update;
begin
  SavePath := SendItemInfoReadUtil.ReadLocalSavePath( DesItemID, SourcePath );

  inherited;
end;

procedure TSendJobInfo.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

{ TFolderCompareHandle }

function TBackupFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited and MyFileSendHandler.getIsRun;

    // 1 秒钟 检测一次
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // 显示扫描文件数
    SendItemAppApi.SetScaningCount( DesItemID, SourcePath, FileCount );

      // 检查是否中断备份
    Result := Result and SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );

      // 检测正常重置检测时间
    if Result then
      ScanTime := Now;
  end;
end;

procedure TBackupFolderScanHandle.FindSourceFileInfo;
var
  LocalSourceFolderFindHandle : TBackupFolderFindHandle;
begin
  LocalSourceFolderFindHandle := TBackupFolderFindHandle.Create;
  LocalSourceFolderFindHandle.SetFolderPath( SourceFolderPath );
  LocalSourceFolderFindHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalSourceFolderFindHandle.SetSleepCount( SleepCount );
  LocalSourceFolderFindHandle.SetScanFile( SourceFileHash );
  LocalSourceFolderFindHandle.SetScanFolder( SourceFolderHash );
  LocalSourceFolderFindHandle.Update;
  SleepCount := LocalSourceFolderFindHandle.SleepCount;
  LocalSourceFolderFindHandle.Free
end;

procedure TBackupFolderScanHandle.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;


procedure TBackupFolderScanHandle.SetItemInfo(_DesItemID,
  _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

{ TFileScanHandle }

function TBackupFileScanHandle.FindSourceFileInfo: Boolean;
var
  LocalFileFindHandle : TLocalFileFindHandle;
begin
  LocalFileFindHandle := TLocalFileFindHandle.Create( SourceFilePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  SourceFileSize := LocalFileFindHandle.getFileSize;
  SourceFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;


{ TLocalFolderScanHandle }

procedure TLocalBackupFolderScanHandle.FindDesFileInfo;
var
  DesFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // 本地目录路径信息
  DesFolderPath := MyFilePath.getReceivePath( SourcePath, SourceFolderPath, SavePath );

    // 扫描
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( DesFolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( DesFileHash );
  LocalFolderFindHandle.SetScanFolder( DesFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;
end;

function TLocalBackupFolderScanHandle.getScanHandle( SourceFolderName : string ): TFolderScanHandle;
var
  LocalFolderScanHandle : TLocalBackupFolderScanHandle;
begin
  LocalFolderScanHandle := TLocalBackupFolderScanHandle.Create;
  LocalFolderScanHandle.SetItemInfo( DesItemID, SourcePath );
  LocalFolderScanHandle.SetSavePath( SavePath );
  LocalFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  Result := LocalFolderScanHandle;
end;

procedure TLocalBackupFolderScanHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLocalFileScanHandle }

function TLocalBackupFileScanHandle.FindDesFileInfo: Boolean;
var
  DesFilePath : string;
  LocalFileFindHandle : TLocalFileFindHandle;
begin
  DesFilePath := SavePath;

  LocalFileFindHandle := TLocalFileFindHandle.Create( DesFilePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  DesFileSize := LocalFileFindHandle.getFileSize;
  DesFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;

procedure TLocalBackupFileScanHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLocalBackupResultHandle }


procedure TLocalBackupResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

procedure TLocalBackupResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFilePath );
end;

procedure TLocalBackupResultHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TLocalBackupResultHandle.SourceFileAdd;
var
  FileCopyHandle : TBackupFileCopyHandle;
begin
  FileCopyHandle := TBackupFileCopyHandle.Create( SourceFilePath, DesFilePath );
  FileCopyHandle.SetItemInfo( DesItemID, SourcePath );
  FileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

procedure TLocalBackupResultHandle.SourceFolderAdd;
begin
  ForceDirectories( DesFilePath );
end;

procedure TLocalBackupResultHandle.Update;
begin
  DesFilePath := MyFilePath.getReceivePath( SourcePath, SourceFilePath, SavePath );

  inherited;
end;

{ TNetworkFolderScanHandle }

function TNetworkFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
  if Result then // 定时发送心跳
    HeatBeatHelper.CheckHeartBeat;
end;

procedure TNetworkFolderScanHandle.FindDesFileInfo;
var
  NetworkFolderFindDeepHandle : TNetworkFolderFindDeepHandle;
begin
    // 已读取
  if IsDesReaded then
    Exit;

     // 搜索目录信息
  NetworkFolderFindDeepHandle := TNetworkFolderFindDeepHandle.Create;
  NetworkFolderFindDeepHandle.SetFolderPath( SourceFolderPath );
  NetworkFolderFindDeepHandle.SetScanFile( DesFileHash );
  NetworkFolderFindDeepHandle.SetScanFolder( DesFolderHash );
  NetworkFolderFindDeepHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindDeepHandle.Update;
  NetworkFolderFindDeepHandle.Free;
end;

function TNetworkFolderScanHandle.getScanHandle( SourceFolderName : string ): TFolderScanHandle;
var
  ChildFolderInfo : TScanFolderInfo;
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
begin
    // 创建处理对象
  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  NetworkFolderScanHandle.SetTcpSocket( TcpSocket );
  NetworkFolderScanHandle.SetHeatBeatHelper( HeatBeatHelper );
  Result := NetworkFolderScanHandle;

    // 不存在子目录
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // 添加子目录信息
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  NetworkFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // 子目录未读取
  if not ChildFolderInfo.IsReaded then
    Exit;

    // 子目录信息
  NetworkFolderScanHandle.DesFolderHash.Free;
  NetworkFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // 子文件信息
  NetworkFolderScanHandle.DesFileHash.Free;
  NetworkFolderScanHandle.DesFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

procedure TNetworkFolderScanHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

procedure TNetworkFolderScanHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TNetworkBackupHandle }

constructor TNetworkSendHandle.Create;
begin
  inherited;

    // 定时心跳
  HeartBeatHelper := THeatBeatHelper.Create( nil );
end;

destructor TNetworkSendHandle.Destroy;
begin
  HeartBeatHelper.Free;

  inherited;
end;

function TNetworkSendHandle.getBackupFileHandle: TBackupFileHandle;
var
  NetworkBackupFileHandle : TNetworkBackupFileHandle;
begin
  NetworkBackupFileHandle := TNetworkBackupFileHandle.Create;
  NetworkBackupFileHandle.SetBackupInfo( IsFile, ScanResultList.Count > 0 );
  NetworkBackupFileHandle.SetTcpSocket( TcpSocket );
  Result := NetworkBackupFileHandle;
end;

function TNetworkSendHandle.getContinuesHandle: TBackupContinuesHandle;
var
  NetworkSendContiunsHandle : TNetworkSendContinuesHandle;
begin
  NetworkSendContiunsHandle := TNetworkSendContinuesHandle.Create;
  NetworkSendContiunsHandle.SetTcpSocket( TcpSocket );
  Result := NetworkSendContiunsHandle;
end;

function TNetworkSendHandle.getDesItemIsBackup: Boolean;
var
  CloudConnResult : string;
  IsDesExist, IsDesWrite, IsCancel : Boolean;
begin
  Result := False;

    // 读取访问结果
  CloudConnResult := MySocketUtil.RevJsonStr( TcpSocket );

    // 设置 可连接
  SendRootItemAppApi.SetIsConnected( DesItemID, True );

      // 设置 非缺少空间
  SendRootItemAppApi.SetIsLackSpace( DesItemID, False );

    // 是否存在云路径
  IsDesExist := CloudConnResult <> ReceiveConnResult_NotExist;
  SendRootItemAppApi.SetIsExist( DesItemID, IsDesExist );

    // 已经接收取消
  IsCancel := CloudConnResult = ReceiveConnResult_Cancel;
  SendItemAppApi.SetIsReceiveCancel( DesItemID, SourcePath, IsCancel );

    // 云路径是否可写
  IsDesWrite := CloudConnResult <> ReceiveConnResult_CannotWrite;
  SendRootItemAppApi.SetIsWrite( DesItemID, IsDesWrite );

    // 是否返回正常
  Result := CloudConnResult = ReceiveConnResult_OK;
end;

function TNetworkSendHandle.getFileScanHandle: TBackupFileScanHandle;
var
  NetworkFileScanHandle : TNetworkFileScanHandle;
begin
  NetworkFileScanHandle := TNetworkFileScanHandle.Create;
  NetworkFileScanHandle.SetTcpSocket( TcpSocket );
  Result := NetworkFileScanHandle;
end;

function TNetworkSendHandle.getFolderScanHandle: TBackupFolderScanHandle;
var
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
begin
  HeartBeatHelper.TcpSocket := TcpSocket;

  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetTcpSocket( TcpSocket );
  NetworkFolderScanHandle.SetHeatBeatHelper( HeartBeatHelper );
  Result := NetworkFolderScanHandle;
end;

function TNetworkSendHandle.getIsScanCompleted: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

function TNetworkSendHandle.getRefreshSpeedInfo: TRefreshSpeedInfo;
var
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
  IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
  LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;

  Result := TRefreshSpeedInfo.Create;
  Result.SetLimitInfo( IsLimited, LimitSpeed );
end;

function TNetworkSendHandle.getSendFileCancelReader: TSendFileCancelReader;
var
  NetworkSendFileCancelReader : TNetworkSendFileCancelReader;
begin
  NetworkSendFileCancelReader := TNetworkSendFileCancelReader.Create;
  NetworkSendFileCancelReader.SetTcpSocket( TcpSocket );
  Result := NetworkSendFileCancelReader;
end;

procedure TNetworkSendHandle.ResetSourcePathSpace;
begin
  inherited;

    // 设置空间信息
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_SetSpace );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalCount', IntToStr( TotalCount ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalSize', IntToStr( TotalSize ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalCompletedSize', IntToStr( TotalCompletedSize ) );
end;

procedure TNetworkSendHandle.SetBackupCompleted;
begin
    // 通知接收方已完成
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_SetCompleted );

    // 设置备份完成时间
  SendItemAppApi.SetLastBackupTime( DesItemID, SourcePath, Now );

    // 设置已完成
  SendItemAppApi.SetNetworkBackupCompleted( DesItemID, SourcePath );
end;

procedure TNetworkSendHandle.Update;
begin
    // 获取连接
  TcpSocket := MyFileSendConnectHandler.getSendPcConn( DesItemID, SourcePath );
  if not Assigned( TcpSocket ) then // 连接失败
    Exit;

  inherited;

    // 发送结束
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_End );

    // 回收连接
  MyFileSendConnectHandler.AddLastConn( DesItemID, TcpSocket );
end;

{ TNetworkFileScanHandle }

function TNetworkFileScanHandle.FindDesFileInfo: Boolean;
var
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create( SourceFilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  Result := NetworkFileFindHandle.getIsExist;
  DesFileSize := NetworkFileFindHandle.getFileSize;
  DesFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Free;
end;

procedure TNetworkFileScanHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TLocalSourceFolderFindHandle }

function TBackupFolderFindHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := True;

    // 不在包含列表中
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TBackupFolderFindHandle.IsFolderFilter(
  FolderPath: string): Boolean;
begin
  Result := True;

    // 不在包含列表中
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

procedure TBackupFolderFindHandle.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

{ TNetworkBackupFileSendHandle }

procedure TNetworkBackupFileSendHandle.AddSpeedSpace(Space: Integer);
var
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
    // 添加到总速度
  MyRefreshSpeedHandler.AddUpload( Space );

    // 刷新速度， 1秒钟刷新一次
  if RefreshSpeedInfo.AddCompleted( Space ) then
  begin
      // 设置 刷新备份速度
    SendItemAppApi.SetSpeed( DesItemID, SourcePath, RefreshSpeedInfo.LastSpeed );

      // 重新获取限制空间信息
    IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
    LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;
    RefreshSpeedInfo.SetLimitInfo( IsLimited, LimitSpeed );
  end;
end;

function TNetworkBackupFileSendHandle.CheckNextSend: Boolean;
begin
  Result := True;

    // 1 秒钟 检测一次， 检查是否中断备份
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );

  Result := Result and inherited and MyFileSendHandler.getIsRun;
end;

function TNetworkBackupFileSendHandle.getLimitBlockSize: Int64;
begin
  if RefreshSpeedInfo.IsLimited then
    Result := RefreshSpeedInfo.LimitSpeed - RefreshSpeedInfo.Speed
  else
    Result := inherited;
end;

procedure TNetworkBackupFileSendHandle.LostConnectError;
var
  Params : TSendErrorAddParams;
begin
    // 发送信息
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.LostConnectError( Params );

    // 设置 重新发送
  SendItemAppApi.SetIsLostConn( DesItemID, SourcePath, True );
end;

procedure TNetworkBackupFileSendHandle.MarkContinusSend;
var
  Params : TSendContinusAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.FileTime := FileTime;
  Params.Position := FilePos;
  SendContinusAppApi.AddItem( Params );
end;

procedure TNetworkBackupFileSendHandle.ReadFileError;
var
  Params : TSendErrorAddParams;
begin
    // 显示界面 Item
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.ReadFileError( Params );
end;

procedure TNetworkBackupFileSendHandle.RefreshCompletedSpace;
begin
  SendItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TNetworkBackupFileSendHandle.RevFileLackSpaceHandle;
begin
  SendRootItemAppApi.SetIsLackSpace( DesItemID, True );
end;

procedure TNetworkBackupFileSendHandle.SendFileError;
var
  Params : TSendErrorAddParams;
begin
    // 发送信息
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.SendFileError( Params );

    // 设置 重新发送
  SendItemAppApi.SetIsLostConn( DesItemID, SourcePath, True );
end;

procedure TNetworkBackupFileSendHandle.SetItemInfo(_DesItemID,
  _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TNetworkBackupFileSendHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

procedure TNetworkBackupFileSendHandle.WriteFileError;
var
  Params : TSendErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.WriteFileError( Params );
end;

{ TNetworkBackupResultHandle }

procedure TNetworkSendResultHandle.DesFileRemove;
begin
  SendFileReq( FileReq_RemoveFile );
end;

procedure TNetworkSendResultHandle.DesFolderRemove;
begin
  SendFileReq( FileReq_RemoveFolder );
end;

procedure TNetworkSendResultHandle.LogZipFile(ZipName: string;
  IsCompleted: Boolean);
var
  LogFilePath : string;
  Params : TSendLogAddParams;
begin
  LogFilePath := MyFilePath.getPath( SourcePath ) + ZipName;

  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := LogFilePath;
  Params.SendTime := Now;
  if IsCompleted then
    SendLogApi.AddCompleted( Params )
  else
    SendLogApi.AddIncompleted( Params );
end;

procedure TNetworkSendResultHandle.SendFileReq(FileReq: string);
begin
    // 发送给 目标Pc 处理
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq );
  MySocketUtil.SendJsonStr( TcpSocket, 'SourceFilePath', SourceFilePath );
end;

procedure TNetworkSendResultHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkSendResultHandle.SourceFileAdd;
var
  NetworkBackupFileSendHandle : TNetworkBackupFileSendHandle;
  IsSendCompleted : Boolean;
begin
    // 发送请求
  SendFileReq( FileReq_AddFile );

    // 发送文件
  NetworkBackupFileSendHandle := TNetworkBackupFileSendHandle.Create( SourceFilePath );
  NetworkBackupFileSendHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkBackupFileSendHandle.SetTcpSocket( TcpSocket );
  NetworkBackupFileSendHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  IsSendCompleted := NetworkBackupFileSendHandle.Update;
  NetworkBackupFileSendHandle.Free;

    // 写 Log
  if IsSendCompleted then
    LogSendCompleted
  else
    LogSendIncompleted;
end;

procedure TNetworkSendResultHandle.SourceFileAddZip;
var
  ScanResultAddZipInfo : TScanResultAddZipInfo;
  ZipStream : TMemoryStream;
  TempFilePath : string;
  NetworkBackupFileSendZipHandle : TNetworkBackupFileSendZipHandle;
  FilePathList : TStringList;
  IsSendCompleted : Boolean;
  i: Integer;
  ZipSize, DelZipSize : Int64;
begin
    // 提取信息
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;
  ZipSize := ZipStream.Size;

      // 压缩文件
  FilePathList := MyZipUtil.getPathList( ZipStream );

    // 压缩发送路径
  TempFilePath := MyFilePath.getPath( SourcePath ) + Name_TempSendZip;

    // 发送给 目标Pc 处理
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ZipFile );
  MySocketUtil.SendJsonStr( TcpSocket, 'ZipPath', TempFilePath );

    // 发送压缩文件
  NetworkBackupFileSendZipHandle := TNetworkBackupFileSendZipHandle.Create( TempFilePath );
  NetworkBackupFileSendZipHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkBackupFileSendZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  NetworkBackupFileSendZipHandle.SetTcpSocket( TcpSocket );
  NetworkBackupFileSendZipHandle.SetZipStream( ZipStream );
  IsSendCompleted := NetworkBackupFileSendZipHandle.Update;
  NetworkBackupFileSendZipHandle.Free;

    // 等待解压结束
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );

    // 刷新已完成空间信息
  if IsSendCompleted then
  begin
    DelZipSize := ScanResultAddZipInfo.TotalSize - ZipSize;
    SendItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, DelZipSize );
  end;

  ScanResultAddZipInfo.Free;

    // 写 log
  for i := 0 to FilePathList.Count - 1 do
    LogZipFile( FilePathList[i], IsSendCompleted );

  FilePathList.Free;
end;

procedure TNetworkSendResultHandle.SourceFolderAdd;
begin
  SendFileReq( FileReq_AddFolder );
end;


{ TBackupHandle }

procedure TSendHandle.BackupFileHandle;
var
  SendFileCancelReader : TSendFileCancelReader;
  SendFileFreeLimitReader : TSendFileFreeLimitReader;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  BackupHandle : TBackupFileHandle;
  i : Integer;
  ScanResultInfo : TScanResultInfo;
begin
  DebugLock.Debug( 'BackupFileHandle' );

    // 显示开始发送文件
  SendItemAppApi.SetStartBackup( DesItemID, SourcePath );

    // 取消检测器
  SendFileCancelReader := getSendFileCancelReader;
  SendFileCancelReader.SetItemInfo( DesItemID, SourcePath );

    // 免费版限制
  SendFileFreeLimitReader := TSendFileFreeLimitReader.Create;
  SendFileFreeLimitReader.SetFileCount( TotalCompletedCount );
  SendFileFreeLimitReader.IniHandle;

    // 速度控制
  RefreshSpeedInfo := getRefreshSpeedInfo;

    // 备份处理
  BackupHandle := getBackupFileHandle;
  BackupHandle.SetItemInfo( DesItemID, SourcePath );
  BackupHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  BackupHandle.IniHandle;

    // 处理扫描路径结果
  for i := 0 to ScanResultList.Count - 1 do
  begin
      // 是否取消备份
    if not SendFileCancelReader.getIsRun then
      Break;

      // 免费版检测
    if not SendFileFreeLimitReader.AddResult( ScanResultList[i] ) then
    begin
      FreeLimitType := SendFileFreeLimitReader.getFreeLimitType;
      if FreeLimitType = FreeLimitType_FileCount then  // 超出文件数限制，停止发送
        Break;
      Continue;
    end;

      // 处理备份结果
    BackupHandle.Handle( ScanResultList[i] );
  end;

    // 完整发送 或者 因为免费版而结束
  if ( i = ScanResultList.Count ) or SendFileCancelReader.getIsRun then
    BackupHandle.CompletedHandle;

  BackupHandle.Free;
  RefreshSpeedInfo.Free;
  SendFileFreeLimitReader.Free;
  SendFileCancelReader.Free;
end;

procedure TSendHandle.ContinuesHandle;
var
  SendFileCancelReader : TSendFileCancelReader;
  BackupContinuesList : TSendContinusList;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  i : Integer;
  ContinuesInfo : TSendContinusInfo;
  BackupContinuesHandle : TBackupContinuesHandle;
begin
    // 清空上次失败的发送
  SendErrorAppApi.ClearItem( DesItemID, SourcePath );

    // 发送取消器
  SendFileCancelReader := getSendFileCancelReader;
  SendFileCancelReader.SetItemInfo( DesItemID, SourcePath );

    // 读取续传信息
  BackupContinuesList := SendItemInfoReadUtil.ReadContinuesList( DesItemID, SourcePath );
  if BackupContinuesList.Count > 0 then
    SendItemAppApi.SetStartBackup( DesItemID, SourcePath );
  RefreshSpeedInfo := getRefreshSpeedInfo;
  for i := 0 to BackupContinuesList.Count - 1 do
  begin
    if not SendFileCancelReader.getIsRun then // 是否取消发送
      Break;

    ContinuesInfo := BackupContinuesList[i];
    DebugLock.Debug( 'ContinuesHandle: ' + ContinuesInfo.FilePath );

    BackupContinuesHandle := getContinuesHandle;
    BackupContinuesHandle.SetSourceFilePath( ContinuesInfo.FilePath );
    BackupContinuesHandle.SetSpaceInfo( ContinuesInfo.FileSize, ContinuesInfo.Position );
    BackupContinuesHandle.SetFileTime( ContinuesInfo.FileTime );
    BackupContinuesHandle.SetItemInfo( DesItemID, SourcePath );
    BackupContinuesHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
    BackupContinuesHandle.Update;
    BackupContinuesHandle.Free;
  end;
  RefreshSpeedInfo.Free;
  BackupContinuesList.Free;

  SendFileCancelReader.Free;
end;

constructor TSendHandle.Create;
begin
  ScanResultList := TScanResultList.Create;
  FreeLimitType := '';
end;

destructor TSendHandle.Destroy;
begin
  ScanResultList.Free;
  inherited;
end;

procedure TSendHandle.FreeLimitWarinningCheck;
begin
    // 非免费版
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

    // 试用限制
  if FreeLimitType = FreeLimitType_FileSize then
    RegisterLimitApi.ShowSendSizeError
  else
  if FreeLimitType = FreeLimitType_FileCount then
    RegisterLimitApi.ShowSendCountError;
end;

function TSendHandle.getIsBackupCompleted: Boolean;
begin
  Result := SendItemInfoReadUtil.ReadIsCompletedSpace( DesItemID, SourcePath );
end;

function TSendHandle.getIsBackupNext: Boolean;
begin
  Result := True;
end;

function TSendHandle.getRefreshSpeedInfo: TRefreshSpeedInfo;
begin
  Result := TRefreshSpeedInfo.Create;
end;

function TSendHandle.getIsScanCompleted: Boolean;
begin
  Result := MyFileSendHandler.getIsRun;
end;

function TSendHandle.getSendFileCancelReader: TSendFileCancelReader;
begin
  Result := TSendFileCancelReader.Create;
end;

function TSendHandle.getSourcePathIsBackup: Boolean;
begin
    // 备份路径是否被删除
  Result := SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
  if not Result then
    Exit;

    // 磁盘路径是否存在
  Result := MyFilePath.getIsExist( SourcePath );
  SendItemAppApi.SetIsExist( DesItemID, SourcePath, Result );
end;

procedure TSendHandle.ResetSourcePathSpace;
var
  Params : TBackupSetSpaceParams;
begin
    // 重设 源路径空间
  Params.DesItemID := DesItemID;
  Params.BackupPath := SourcePath;
  Params.FileCount := TotalCount;
  Params.FileSpace := TotalSize;
  Params.CompletedSpce := TotalCompletedSize;
  SendItemAppApi.SetSpaceInfo( Params );
end;

procedure TSendHandle.ScanFileHandle;
var
  LocalSourceFileScanHandle : TBackupFileScanHandle;
begin
  LocalSourceFileScanHandle := getFileScanHandle;
  LocalSourceFileScanHandle.SetSourceFilePath( SourcePath );
  LocalSourceFileScanHandle.SetResultList( ScanResultList );
  LocalSourceFileScanHandle.Update;
  TotalSize := LocalSourceFileScanHandle.SourceFileSize;
  TotalCount := 1;
  TotalCompletedCount := LocalSourceFileScanHandle.CompletedCount;
  TotalCompletedSize := LocalSourceFileScanHandle.CompletedSize;
  LocalSourceFileScanHandle.Free;
end;

procedure TSendHandle.ScanFolderHandle;
var
  IncludeFilterList : TFileFilterList;  // 包含过滤器
  ExcludeFilterList : TFileFilterList;  // 排除过滤器
  LocalSourceFolderScanHandle : TBackupFolderScanHandle;
begin
  IncludeFilterList := SendItemInfoReadUtil.ReadIncludeFilter( DesItemID, SourcePath );
  ExcludeFilterList := SendItemInfoReadUtil.ReadExcludeFilter( DesItemID, SourcePath );

  LocalSourceFolderScanHandle := getFolderScanHandle;
  LocalSourceFolderScanHandle.SetSourceFolderPath( SourcePath );
  LocalSourceFolderScanHandle.SetItemInfo( DesItemID, SourcePath );
  LocalSourceFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalSourceFolderScanHandle.SetResultList( ScanResultList );
  LocalSourceFolderScanHandle.SetIsSupportDeleted( True );
  LocalSourceFolderScanHandle.Update;
  TotalSize := LocalSourceFolderScanHandle.FileSize;
  TotalCount := LocalSourceFolderScanHandle.FileCount;
  TotalCompletedCount := LocalSourceFolderScanHandle.CompletedCount;
  TotalCompletedSize := LocalSourceFolderScanHandle.CompletedSize;
  LocalSourceFolderScanHandle.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

procedure TSendHandle.ScanPathHandle;
begin
  DebugLock.Debug( 'ScanPathHandle' );

    // 设置 正在
  SendItemAppApi.SetAnalyzeBackup( DesItemID, SourcePath );

    // 路径是文件或目录
  IsFile := SendItemInfoReadUtil.ReadIsFile( DesItemID, SourcePath );

    // 文件/目录 扫描
  if IsFile then
    ScanFileHandle
  else
    ScanFolderHandle;

      // 扫描完成
  if getIsScanCompleted then
    ResetSourcePathSpace; // 重设路径空间信息
end;

procedure TSendHandle.SetScanPathInfo(_ScanPathInfo: TSendJobInfo);
begin
  ScanPathInfo := _ScanPathInfo;
  SourcePath := ScanPathInfo.SendPath;
  DesItemID := ScanPathInfo.DesItemID;
end;

procedure TSendHandle.Update;
begin
    // 程序结束或停止
  if not MyFileSendHandler.getIsRun then
    Exit;

    // 目标路径不能发送
  if not getDesItemIsBackup then
    Exit;

    // 源路径不能发送
  if not getSourcePathIsBackup then
    Exit;

    // 续传
  ContinuesHandle;

    // 扫描路径
  ScanPathHandle;

    // 备份路径
  BackupFileHandle;

    // 设置 备份完成
  if getIsScanCompleted and getIsBackupCompleted then
    SetBackupCompleted;

    // 检测是否收到免费版限制
  FreeLimitWarinningCheck;
end;

{ TBackupResultHandle }

procedure TBackupResultHandle.LogSendCompleted;
var
  Prams : TSendLogAddParams;
begin
  Prams.SendRootItemID := DesItemID;
  Prams.SourcePath := SourcePath;
  Prams.FilePath := SourceFilePath;
  Prams.SendTime := Now;
  SendLogApi.AddCompleted( Prams );
end;

procedure TBackupResultHandle.LogSendIncompleted;
var
  Prams : TSendLogAddParams;
begin
  Prams.SendRootItemID := DesItemID;
  Prams.SourcePath := SourcePath;
  Prams.FilePath := SourceFilePath;
  SendLogApi.AddIncompleted( Prams );
end;

procedure TBackupResultHandle.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupResultHandle.SetScanResultInfo(
  _ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  SourceFilePath := ScanResultInfo.SourceFilePath;
end;

procedure TBackupResultHandle.SetSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TBackupResultHandle.SourceFileAddZip;
begin

end;

procedure TBackupResultHandle.Update;
begin
  try
    DebugLock.Debug( ScanResultInfo.ClassName + ':  ' + ScanResultInfo.SourceFilePath );

      // 文件操作
    if ScanResultInfo is TScanResultAddFileInfo then
      SourceFileAdd
    else
    if ScanResultInfo is TScanResultAddFolderInfo then
      SourceFolderAdd
    else
    if ScanResultInfo is TScanResultRemoveFileInfo then
      DesFileRemove
    else
    if ScanResultInfo is TScanResultRemoveFolderInfo then
      DesFolderRemove
    else
    if ScanResultInfo is TScanResultAddZipInfo then
      SourceFileAddZip;
  except
  end;
end;

{ TBackupContinuesHandle }

function TBackupContinuesHandle.getIsSourceChange: Boolean;
begin
  Result := True;
  if not FileExists( FilePath ) then
    Exit;
  if MyFileInfo.getFileSize( FilePath ) <> FileSize then
    Exit;
  if not MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( FilePath ), FileTime ) then
    Exit;
  Result := False;
end;

procedure TBackupContinuesHandle.RemoveContinusInfo;
begin
  SendContinusAppApi.RemoveItem( DesItemID, SourcePath, FilePath );
end;

procedure TBackupContinuesHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TBackupContinuesHandle.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupContinuesHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TBackupContinuesHandle.SetSourceFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupContinuesHandle.SetSpaceInfo(_FileSize,
  _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TBackupContinuesHandle.Update;
begin
    // 源文件发生变化
  if getIsSourceChange then
    Exit;

    // 目标文件发生变化
  if getIsDesChange then
    Exit;

    // 文件复制
  if FileCopy then
    RemoveContinusInfo;  // 删除续传记录
end;

{ TLocalBackupContinuesHandle }

function TLocalBackupContinuesHandle.FileCopy: Boolean;
var
  FileCopyHandle : TBackupFileCopyHandle;
begin
  FileCopyHandle := TBackupFileCopyHandle.Create( FilePath, DesFilePath );
  FileCopyHandle.SetPosition( Position );
  FileCopyHandle.SetItemInfo( DesItemID, SourcePath );
  FileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  Result := FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

function TLocalBackupContinuesHandle.getIsDesChange: Boolean;
begin
  Result := MyFileInfo.getFileSize( DesFilePath ) <> Position;
end;

procedure TLocalBackupContinuesHandle.Update;
var
  SavePath : string;
begin
  SavePath := SendItemInfoReadUtil.ReadLocalSavePath( DesItemID, SourcePath );
  DesFilePath := MyFilePath.getReceivePath( SourcePath, FilePath, SavePath );

  inherited;
end;

{ TNetworkBackupContinuesHandle }

function TNetworkSendContinuesHandle.FileCopy: Boolean;
var
  NetworkBackupFileSendHandle : TNetworkBackupFileSendHandle;
begin
    // 初始化 发送
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ContinuesAdd );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FilePath );

    // 发送文件
  NetworkBackupFileSendHandle := TNetworkBackupFileSendHandle.Create( FilePath );
  NetworkBackupFileSendHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkBackupFileSendHandle.SetFilePos( Position );
  NetworkBackupFileSendHandle.SetTcpSocket( TcpSocket );
  NetworkBackupFileSendHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  Result := NetworkBackupFileSendHandle.Update;
  NetworkBackupFileSendHandle.Free;
end;

function TNetworkSendContinuesHandle.getIsDesChange: Boolean;
var
  DesIsExist : Boolean;
  DesFileSize : Int64;
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create( FilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  DesIsExist := NetworkFileFindHandle.getIsExist;
  DesFileSize := NetworkFileFindHandle.getFileSize;
  NetworkFileFindHandle.Free;

  Result := not DesIsExist or ( Position <> DesFileSize );
end;

procedure TNetworkSendContinuesHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TCompressFileHandle }

function TCompressSendFileHandle.AddFile(FilePath: string): Boolean;
var
  ZipName : string;
  fs : TFileStream;
  NewZipInfo : TZipHeader;
begin
  Result := False;

    // 文件不存在
  if not FileExists( FilePath ) then
    Exit;

  try    // 创建读取文件流
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;
  end;

    // 提取压缩文件信息
  ZipName := ExtractRelativePath( MyFilePath.getPath( SourcePath ), FilePath );
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );
  try
      // 添加压缩文件
    ZipFile.Add( fs, NewZipInfo );
    fs.Free; // 关闭文件流

      // 读取 Zip 信息
    NewZipInfo := ZipFile.FileInfos[ ZipFile.FileCount - 1 ];

      // 添加统计信息
    TotalSize := TotalSize + NewZipInfo.UncompressedSize;
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    Result := True;
  except
  end;
end;

function TCompressSendFileHandle.AddZipFile(ScanResultInfo : TScanResultInfo): TScanResultInfo;
var
  SourceFileSize : Int64;
begin
  Result := ScanResultInfo;

    // 非发送文件
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // 只压缩小于 128 KB 的文件
  SourceFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // 先创建压缩文件
  if not IsCreated then
  begin
    if not CreateZip then  // 创建文件失败
      Exit;
  end;

    // 添加压缩文件失败
  if not AddFile( ScanResultInfo.SourceFilePath ) then
    Exit;

    // 超过 1000 个文件 或者 10MB ，立刻发送压缩文件
  if ( ZipCount >= 1000 ) or ( ZipSize >= 10 * Size_MB ) then
  begin
    DestoryZip;
    Result := getZipResultInfo;
    Exit;
  end;

    // 返回空
  Result := nil;
end;

constructor TCompressSendFileHandle.Create( _DesItemID,_SourcePath : string );
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
  IsCreated := False;
end;

function TCompressSendFileHandle.CreateZip: Boolean;
begin
  Result := False;

  try
    ZipStream := TMemoryStream.Create;
    ZipFile := TZipFile.Create;
    ZipFile.Open( ZipStream, zmWrite );
    IsCreated := True;
    TotalSize := 0;
    ZipSize := 0;
    ZipCount := 0;
    Result := True;
  except
  end;
end;

procedure TCompressSendFileHandle.DestoryZip;
begin
    // 关闭压缩文件
  try
    IsCreated := False;
    ZipFile.Close;
    ZipFile.Free;
  except
  end;
end;

destructor TCompressSendFileHandle.Destroy;
begin
  if IsCreated then
  begin
    DestoryZip;
    ZipStream.Free;
  end;
  inherited;
end;

function TCompressSendFileHandle.getZipResultInfo: TScanResultAddZipInfo;
begin
  Result := TScanResultAddZipInfo.Create( SourcePath );
  Result.SetZipStream( ZipStream );
  Result.SetTotalSize( TotalSize );
end;

function TCompressSendFileHandle.getLastSendFile: TScanResultInfo;
begin
  if IsCreated then
  begin
    DestoryZip;
    Result := getZipResultInfo;
  end
  else
    Result := nil;
end;

{ TNetworkBackupFileSendZipHandle }

function TNetworkBackupFileSendZipHandle.CreateReadStream: Boolean;
begin
  ReadStream := ZipStream;
  Result := True;
end;

procedure TNetworkBackupFileSendZipHandle.MarkContinusSend;
begin

end;

procedure TNetworkBackupFileSendZipHandle.ReadFileError;
begin

end;

procedure TNetworkBackupFileSendZipHandle.SetZipStream(
  _ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

procedure TNetworkBackupFileSendZipHandle.WriteFileError;
begin

end;

{ TMyFileSendBackConnHandler }

procedure TMyFileSendConnectHandler.AddBackConn(TcpSocket: TCustomIpClient);
begin
  BackConnSocket := TcpSocket;
  IsConnSuccess := True;
end;

procedure TMyFileSendConnectHandler.AddLastConn(LastDesItemID: string;
  TcpSocket: TCustomIpClient);
var
  SendFileSocketInfo : TSendFileSocketInfo;
  DesPcID : string;
begin
    // 连接已断开
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

  SocketLock.Enter;
  try
      // 不允许超过10个连接
    if SendFileSocketList.Count >= 10 then  
    begin
      SendFileSocketList[0].CloseSocket;
      SendFileSocketList.Delete( 0 );
    end;
      // 添加旧连接
    DesPcID := NetworkDesItemUtil.getPcID( LastDesItemID );
    SendFileSocketInfo := TSendFileSocketInfo.Create( DesPcID );
    SendFileSocketInfo.SetTcpSocket( TcpSocket );
    SendFileSocketList.Add( SendFileSocketInfo );
  except
  end;
  SocketLock.Leave;
end;

procedure TMyFileSendConnectHandler.BackConnBusy;
begin
  IsConnBusy := True;
end;

procedure TMyFileSendConnectHandler.BackConnError;
begin
  IsConnError := True;
end;

constructor TMyFileSendConnectHandler.Create;
begin
  SocketLock := TCriticalSection.Create;
  SendFileSocketList := TSendFileSocketList.Create;
end;

destructor TMyFileSendConnectHandler.Destroy;
begin
  SendFileSocketList.Free;
  SocketLock.Free;
  inherited;
end;

function TMyFileSendConnectHandler.getSendPcConn( _DesItemID, _SourcePath : string ): TCustomIpClient;
var
  ReceiveRootPath : string;
begin
  SocketLock.Enter;

  DesItemID := _DesItemID;
  SourcePath := _SourcePath;

  try
    Result := getConnect;  // 获取连接

      // 发送初始化信息
    if Assigned( Result ) then
    begin
      ReceiveRootPath := NetworkDesItemUtil.getCloudPath( DesItemID );
      MySocketUtil.SendJsonStr( Result, 'ReceiveRootPath', ReceiveRootPath );
      MySocketUtil.SendJsonStr( Result, 'SourcePath', SourcePath );
      MySocketUtil.SendJsonStr( Result, 'PcID', PcInfo.PcID );
    end;
  except
    Result := nil;
  end;

  SocketLock.Leave;
end;

procedure TMyFileSendConnectHandler.LastConnRefresh;
var
  i: Integer;
begin
  SocketLock.Enter;
  try
    for i := SendFileSocketList.Count - 1 downto 0 do
    begin
        // 超过三分钟，删除
      if MinutesBetween( Now, SendFileSocketList[i].LastTime ) >= 3 then
      begin
          // 关闭端口
        SendFileSocketList[i].CloseSocket;
          // 删除
        SendFileSocketList.Delete( i );
        Continue;
      end;
        // 发送心跳
      MySocketUtil.SendData( SendFileSocketList[i].TcpSocket, FileReq_HeartBeat );
    end;
  except
  end;
  SocketLock.Leave;
end;


procedure TMyFileSendConnectHandler.StopRun;
var
  i: Integer;
begin
  SocketLock.Enter;
  try
    for i := 0 to SendFileSocketList.Count - 1 do
      SendFileSocketList[i].CloseSocket;
  except
  end;
  SocketLock.Leave;
end;

function TMyFileSendConnectHandler.getBackConnect: TCustomIpClient;
begin
    // 等待结果
  WaitBackConn;

    // 返回结果
  if IsConnSuccess then
    Result := BackConnSocket
  else
    Result := nil;
end;

function TMyFileSendConnectHandler.getConnect: TCustomIpClient;
var
  DesPcID, ReceiveRootPath : string;
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
  IsConnected, IsDesBusy : Boolean;
  TcpSocket : TCustomIpClient;
begin
  Result := nil;

    // 获取以前已连接的端口
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // 提取 Pc 信息
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // Pc 离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
    Exit;

    // 本机无法连接对方
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( DesPcID ) then
  begin
    Result := getBackConnect; // 反向连接
    Exit;
  end;

    // 连接 目标 Pc
  TcpSocket := TCustomIpClient.Create( nil );
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_ReceiveFile );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  IsConnected := MyTcpConn.Conn;
  MyTcpConn.Free;

    // 使用反向连接
  if not IsConnected then
  begin
    TcpSocket.Free;
    NetworkPcApi.SetCanConnectTo( DesPcID, False ); // 设置无法连接
    Result := getBackConnect; // 反向连接
    Exit;
  end;

    // 是否接收繁忙
  IsDesBusy := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsDesBusy then
  begin
    TcpSocket.Free;
    SendItemAppApi.SetIsDesBusy( DesItemID, SourcePath, True );
    Exit;
  end;

  Result := TcpSocket;
end;

function TMyFileSendConnectHandler.getLastConnect: TCustomIpClient;
var
  i: Integer;
  SendFileSocketInfo : TSendFileSocketInfo;
  LastSocket : TCustomIpClient;
  FileReq : string;
begin
  Result := nil;

    // 寻找上次端口
  LastSocket := nil;
  for i := 0 to SendFileSocketList.Count - 1 do
  begin
    SendFileSocketInfo := SendFileSocketList[i];
    if SendFileSocketInfo.DesPcID = NetworkDesItemUtil.getPcID( DesItemID ) then
    begin
      LastSocket := SendFileSocketInfo.TcpSocket;
      SendFileSocketList.Delete( i );
      Break;
    end;
  end;

    // 不存在
  if not Assigned( LastSocket ) then
    Exit;

    // 判断端口是否正常
  MySocketUtil.SendData( LastSocket, FileReq_New );
  FileReq := MySocketUtil.RevJsonStr( LastSocket );
  if FileReq <> FileReq_New then  // 端口异常
  begin
    LastSocket.Free;
    Result := getLastConnect; // 再拿一次
    Exit;
  end;

    // 返回上次端口
  Result := LastSocket;
end;

procedure TMyFileSendConnectHandler.WaitBackConn;
var
  ReceivePcID : string;
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // 发送请求
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

    // 对方不能连接本机
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( ReceivePcID ) then
  begin
    SendRootItemAppApi.SetIsConnected( DesItemID, False );
    Exit;
  end;

      // 初始化结果信息
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // 请求反向连接
  NetworkBackConnEvent.AddItem( ReceivePcID );

    // 等待接收方连接
  StartTime := Now;
  while MyFileSendHandler.getIsRun and
        ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // 目标 Pc 繁忙
  if IsConnBusy then
  begin
    SendItemAppApi.SetIsDesBusy( DesItemID, SourcePath, True );
    Exit;
  end;

    // 无法连接
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( ReceivePcID, False ); // 设置无法连接
    SendRootItemAppApi.SetIsConnected( DesItemID, False );
    Exit;
  end;
end;

{ TBackupFileHandle }

procedure TBackupFileHandle.CompletedHandle;
begin

end;

procedure TBackupFileHandle.IniHandle;
begin

end;

procedure TBackupFileHandle.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupFileHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

{ TLocalBackupFileHandle }

procedure TLocalBackupFileHandle.Handle(ScanResultInfo: TScanResultInfo);
var
  LocalBackupResultHandle : TLocalBackupResultHandle;
begin
      // 执行
  LocalBackupResultHandle := TLocalBackupResultHandle.Create;
  LocalBackupResultHandle.SetScanResultInfo( ScanResultInfo );
  LocalBackupResultHandle.SetItemInfo( DesItemID, SourcePath );
  LocalBackupResultHandle.SetSavePath( SavePath );
  LocalBackupResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  LocalBackupResultHandle.Update;
  LocalBackupResultHandle.Free;
end;

procedure TLocalBackupFileHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TNetworkBackupFileHandle }

procedure TNetworkBackupFileHandle.CheckHeartBeat;
begin
  if SecondsBetween( Now, HeartTime ) < 10 then
    Exit;

  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_HeartBeat );

  HeartTime := Now;
end;

procedure TNetworkBackupFileHandle.CompletedHandle;
var
  ScanResultInfo : TScanResultInfo;
  i: Integer;
  IsFind : Boolean;
begin
    // 发送最后的压缩文件
  ScanResultInfo := CompressFileHandle.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    SendFile( ScanResultInfo );

    // 等待线程结束
  while MyFileSendHandler.getIsRun do
  begin
    IsFind := False;
    for i := 0 to SendFileThreadList.Count - 1 do
      if SendFileThreadList[i].IsRun and not SendFileThreadList[i].IsLostConn then
      begin
        IsFind := True;
        Break;
      end;
    if not IsFind then
      Break;
    Sleep( 100 );
    CheckHeartBeat;
  end;
end;

constructor TNetworkBackupFileHandle.Create;
begin
  inherited;
  SendFileThreadList := TSendFileThreadList.Create;
  HeartTime := Now;
end;

destructor TNetworkBackupFileHandle.Destroy;
begin
  CompressFileHandle.Free;
  SendFileThreadList.Free;
  inherited;
end;

function TNetworkBackupFileHandle.getNewConnect: TCustomIpClient;
var
  NewSocket : TCustomIpClient;
  CloudConnResult : string;
begin
  Result := nil;

  NewSocket := MyFileSendConnectHandler.getSendPcConn( DesItemID, SourcePath );
  if not Assigned( NewSocket ) then
    Exit;

    // 读取访问结果
  CloudConnResult := MySocketUtil.RevData( NewSocket );

  if CloudConnResult = ReceiveConnResult_OK then
    Result := NewSocket
  else
    NewSocket.Free;
end;

procedure TNetworkBackupFileHandle.Handle(ScanResultInfo: TScanResultInfo);
begin
    // 获取下一个Job
  if not IsFile then
    ScanResultInfo := CompressFileHandle.AddZipFile( ScanResultInfo );

    // 跳过这个 Job
  if ScanResultInfo = nil then
  begin
    CheckHeartBeat; // 定时发心跳
    Exit;
  end;

    // 发送文件
  if ( ScanResultInfo is TScanResultAddFileInfo ) or
     ( ScanResultInfo is TScanResultAddZipInfo )
  then
    SendFile( ScanResultInfo )  // 寻找线程发送
  else
    HandleNow( ScanResultInfo ); // 立刻处理
end;

procedure TNetworkBackupFileHandle.HandleNow(ScanResultInfo: TScanResultInfo);
var
  NetworkSendResultHandle : TNetworkSendResultHandle;
begin
    // 处理结果
  NetworkSendResultHandle := TNetworkSendResultHandle.Create;
  NetworkSendResultHandle.SetTcpSocket( TcpSocket );
  NetworkSendResultHandle.SetScanResultInfo( ScanResultInfo );
  NetworkSendResultHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkSendResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  NetworkSendResultHandle.Update;
  NetworkSendResultHandle.Free;
end;


procedure TNetworkBackupFileHandle.IniHandle;
var
  DesPcID : string;
  i : Integer;
  NewSocket : TCustomIpClient;
  SendFileThread : TSendFileThread;
begin
    // 创建压缩器
  CompressFileHandle := TCompressSendFileHandle.Create( DesItemID, SourcePath );

    // 单个文件或没Job则不用再创建线程
  if IsFile or not IsExitJob then
    Exit;

    // 互联网 Pc 不用多线程
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  if not MyNetPcInfoReadUtil.ReadIsLanPc( DesPcID ) then
    Exit;
  Exit;
  for i := 1 to 3 do
  begin
    NewSocket := getNewConnect;
    if not Assigned( NewSocket ) then
      Continue;
    SendFileThread := TSendFileThread.Create;
    SendFileThread.SetItemInfo( DesItemID, SourcePath );
    SendFileThread.SetTcpSocket( NewSocket );
    SendFileThread.SetRefreshSpeedInfo( RefreshSpeedInfo );
    SendFileThread.Resume;
    SendFileThreadList.Add( SendFileThread );
  end;
end;

procedure TNetworkBackupFileHandle.SendFile(ScanResultInfo: TScanResultInfo);
var
  IsFindThread : Boolean;
  i : Integer;
begin
  try
      // 寻找空闲的线程
    IsFindThread := False;
    for i := 0 to SendFileThreadList.Count - 1 do
      if not SendFileThreadList[i].IsRun and not SendFileThreadList[i].IsLostConn then  // 线程空闲，且没有断开连接
      begin
        SendFileThreadList[i].AddScanResultInfo( ScanResultInfo );
        IsFindThread := True;
        Break;
      end;

      // 没有找到线程，则当前线程处理
    if not IsFindThread then
      HandleNow( ScanResultInfo );
  except
  end;
end;

procedure TNetworkBackupFileHandle.SetBackupInfo(_IsFile, _IsExistJob: Boolean);
begin
  IsFile := _IsFile;
  IsExitJob := _IsExistJob;
end;

procedure TNetworkBackupFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TSendFileThread }

procedure TSendFileThread.AddScanResultInfo(_ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  IsRun := True;
end;

constructor TSendFileThread.Create;
begin
  inherited Create;
  IsRun := False;
  IsLostConn := False;
end;

destructor TSendFileThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TSendFileThread.Execute;
begin
  while not Terminated and not IsLostConn do
  begin
    WaitToSend;
    if Terminated or not IsRun then
      Break;
    SendFile;
    if not IsLostConn then
      IsRun := False;
  end;

    // 发送结束标记
  MySocketUtil.SendData( TcpSocket, FileReq_End );

    // 回收端口
  MyFileSendConnectHandler.AddLastConn( DesItemID, TcpSocket );

  inherited;
end;

procedure TSendFileThread.SendFile;
var
  NetworkSendResultHandle : TNetworkSendResultHandle;
begin
    // 处理结果
  NetworkSendResultHandle := TNetworkSendResultHandle.Create;
  NetworkSendResultHandle.SetTcpSocket( TcpSocket );
  NetworkSendResultHandle.SetScanResultInfo( ScanResultInfo );
  NetworkSendResultHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkSendResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  NetworkSendResultHandle.Update;
  NetworkSendResultHandle.Free;

    // 可能在文件发送过程中，已断开连接
  IsLostConn := not TcpSocket.Connected;
end;

procedure TSendFileThread.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TSendFileThread.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TSendFileThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TSendFileThread.WaitToSend;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'Wait To Send' );

  StartTime := Now;
  while not IsRun and not Terminated and MyFileSendHandler.getIsRun do
  begin
    Sleep( 100 );
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 秒发送一次心跳
      Continue;
      // 发送心跳，可能对方已经断开连接，则结束线程
    if not MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat ) then
    begin
      TcpSocket.Disconnect;
      IsLostConn := True;
      Break;
    end;
    StartTime := Now;
  end;
end;

{ TSendFileSocketInfo }

procedure TSendFileSocketInfo.CloseSocket;
begin
  try
    MySocketUtil.SendData( TcpSocket, FileReq_End );
    TcpSocket.Free;
  except
  end;
end;

constructor TSendFileSocketInfo.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
  LastTime := Now;
end;

procedure TSendFileSocketInfo.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TBackupFreeLimitReader }

function TSendFileFreeLimitReader.AddResult(
  ScanResultInfo: TScanResultInfo): Boolean;
var
  SendFileSize : Int64;
begin
  Result := True;

    // 非免费版
  if not IsFreeLimit then
    Exit;

    // 非发送文件
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // 可以免费发送三次
  if MySendItem_SendCount <= 3 then
    Exit;

  Result := False;

    // 统计总发送文件数
  Inc( FileCount );
  if RegisterLimitApi.ReadIsCountLimt( FileCount )  then
  begin
    FreeLimitType := FreeLimitType_FileCount;
    Exit;
  end;

    // 文件发送空间
  SendFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if RegisterLimitApi.ReadIsSizeLimit( SendFileSize ) then
  begin
    FreeLimitType := FreeLimitType_FileSize;
    Exit;
  end;

  Result := True;
end;

constructor TSendFileFreeLimitReader.Create;
begin
  FreeLimitType := '';
end;

function TSendFileFreeLimitReader.getFreeLimitType: string;
begin
  Result := FreeLimitType;
end;

procedure TSendFileFreeLimitReader.IniHandle;
begin
  IsFreeLimit := MyRegisterInfo.IsFreeLimit;
end;

procedure TSendFileFreeLimitReader.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

{ TBackupCancelReader }

constructor TSendFileCancelReader.Create;
begin
  ScanTime := Now;
  SleepCount := 0;
end;

function TSendFileCancelReader.getIsRun: Boolean;
begin
  Result := MyFileSendHandler.getIsRun;

    // 是否需要暂停一下
  Inc( SleepCount );
  if SleepCount >= 10 then
  begin
    SleepCount := 0;
    Sleep(1);
  end;

    // 是否已经结束
  if SecondsBetween( Now, ScanTime ) >= 1 then  // 检测 BackupItem 删除
  begin
    Result := Result and SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
    ScanTime := Now;
  end;
end;

procedure TSendFileCancelReader.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

{ TNetworkSendFileCancelReader }

function TNetworkSendFileCancelReader.getIsRun: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

procedure TNetworkSendFileCancelReader.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

end.


