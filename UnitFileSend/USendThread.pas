unit USendThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp, UFolderCompare, UMyDebug,
     uDebugLock, Zip;

type

{$Region ' ���ݽṹ ' }

    // ɨ����Ϣ
  TSendJobInfo = class
  public
    SendPath : string; // ����·��
    DesItemID : string;  // Ŀ����Ϣ
  public
    constructor Create( _SendPath : string );
    procedure SetDesItemID( _DesItemID : string );
  end;
  TSendJobList = class( TObjectList<TSendJobInfo> )end;

    // ���ر��� ɨ����Ϣ
  TLocalScanPathInfo = class( TSendJobInfo )
  end;

    // ���籸�� ɨ����Ϣ
  TNetworkScanPathInfo = class( TSendJobInfo )
  end;

{$EndRegion}

{$Region ' ���� ɨ�� ' }

    // Ѱ�� ����Ŀ¼��Ϣ
  TBackupFolderFindHandle = class( TLocalFolderFindHandle )
  public
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
    function IsFolderFilter( FolderPath : string ): Boolean;override;
  end;

    // ����Ŀ¼ �Ƚ��㷨
  TBackupFolderScanHandle = class( TFolderScanHandle )
  public
    DesItemID, SourcePath : string;
  public
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected
    procedure FindSourceFileInfo;override;
  protected
    function CheckNextScan : Boolean;override;
  end;

    // �����ļ� �Ƚ��㷨
  TBackupFileScanHandle = class( TFileScanHandle )
  protected
    function FindSourceFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���� ���� ' }

    // ��������
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

    // ����ɨ����
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
  protected         // ���
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
  protected         // ɾ��
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // ѹ��
    procedure SourceFileAddZip;virtual;
  private           // д��־
    procedure LogSendCompleted;
    procedure LogSendIncompleted;
  end;

    // ����ɨ����
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

      // �������ð�����
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

      // �Ƿ�ȡ������
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

    // ����·������
  TSendHandle = class
  public
    ScanPathInfo : TSendJobInfo;
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public   // �ļ�ɨ����
    TotalCount, TotalCompletedCount : Integer;
    TotalSize, TotalCompletedSize : Int64;
  public   // �ļ��仯��Ϣ
    ScanResultList : TScanResultList;
  private
    FreeLimitType : string; // �Ƿ��յ���Ѱ�����
  public
    constructor Create;
    procedure SetScanPathInfo( _ScanPathInfo : TSendJobInfo );
    procedure Update;virtual;
    destructor Destroy; override;
  protected       // ����ǰ���
    function getDesItemIsBackup: Boolean;virtual;abstract;
    function getSourcePathIsBackup : Boolean;
  protected       // ɨ��
    procedure ContinuesHandle; // ����
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace; virtual;
    function getContinuesHandle : TBackupContinuesHandle;virtual;abstract;
    function getFileScanHandle : TBackupFileScanHandle;virtual;abstract;
    function getFolderScanHandle : TBackupFolderScanHandle;virtual;abstract;
    function getIsScanCompleted : Boolean;virtual;
  protected       // ����
    procedure BackupFileHandle;
    function getBackupFileHandle: TBackupFileHandle;virtual;abstract;
    function getRefreshSpeedInfo : TRefreshSpeedInfo;virtual;
    function getSendFileCancelReader : TSendFileCancelReader;virtual;
    function getIsBackupNext : Boolean;virtual; // �Ƿ�������ݲ���
  protected       // �������
    function getIsBackupCompleted : Boolean;
    procedure SetBackupCompleted;virtual;abstract;
    procedure FreeLimitWarinningCheck;
  end;


{$EndRegion}


{$Region ' ���ط��� ɨ�� ' }

    // ���ر���Ŀ¼ �Ƚ�
  TLocalBackupFolderScanHandle = class( TBackupFolderScanHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // �����ļ�
  TLocalBackupFileScanHandle = class( TBackupFileScanHandle )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���ط��� ���� ' }

    // ���ݸ���
  TBackupFileCopyHandle = class( TFileCopyHandle )
  protected
    DesItemID, SourcePath : string;
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
  protected
    procedure RefreshCompletedSpace;override;
    function CheckNextCopy : Boolean;override; // ����Ƿ��������
  protected
    procedure MarkContinusCopy;override; // ����
    procedure DesWriteSpaceLack;override; // �ռ䲻��
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
  end;

{$Endregion}

{$Region ' ���ط��� ���� ' }

    // �����ļ� ����
  TLocalBackupContinuesHandle = class( TBackupContinuesHandle )
  private
    DesFilePath : string;
  public
    procedure Update;override;
  public
    function getIsDesChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

    // �������
  TLocalBackupResultHandle = class( TBackupResultHandle )
  public
    SavePath : string;
    DesFilePath : string; // Ŀ��·��
  public
    procedure SetSavePath( _SavePath : string );
    procedure Update;override;
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  end;

    // ����
  TLocalBackupFileHandle = class( TBackupFileHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
  end;

    // ����·������
  TLocalSendHandle = class( TSendHandle )
  private
    SavePath : string;
  public
    procedure Update;override;
  protected       // ����ǰ���
    function getDesItemIsBackup: Boolean;override;
  protected       // ɨ��
    function getContinuesHandle : TBackupContinuesHandle;override;
    function getFileScanHandle : TBackupFileScanHandle;override;
    function getFolderScanHandle : TBackupFolderScanHandle;override;
  protected       // ����
    function getBackupFileHandle: TBackupFileHandle;override;
  protected       // �������
    procedure SetBackupCompleted;override;
  end;

{$EndRegion}


{$Region ' ���緢�� ɨ�� ' }

    // ����Ŀ¼
  TNetworkFolderScanHandle = class( TBackupFolderScanHandle )
  public
    TcpSocket : TCustomIpClient;
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // �����ļ�
  TNetworkFileScanHandle = class( TBackupFileScanHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���緢�� ���� ' }

    // ���ͱ����ļ�
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
    procedure RevFileLackSpaceHandle;override;  // ȱС�ռ�
    procedure MarkContinusSend;override; // ����
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
    procedure LostConnectError;override; // �Ͽ�����
    procedure SendFileError;override; // �����ļ�ʧ��
  end;

    // ����ѹ���ļ�
  TNetworkBackupFileSendZipHandle = class( TNetworkBackupFileSendHandle )
  private
    ZipStream : TMemoryStream;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
  protected
    function CreateReadStream : Boolean;override;
  protected
    procedure MarkContinusSend;override; // ����
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
  end;

{$EndRegion}

{$Region ' ���緢�� ���� ' }

    // �����ļ� ����
  TNetworkSendContinuesHandle = class( TBackupContinuesHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    function getIsDesChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

    // �����ļ��������
  TNetworkSendResultHandle = class( TBackupResultHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // ѹ��
    procedure SourceFileAddZip;override;
  private
    procedure SendFileReq( FileReq : string );
    procedure LogZipFile( ZipName : string; IsCompleted : Boolean );
  end;

     // ѹ�������ļ�
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

    // �����ļ��߳�
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

    // �������
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

    // ����ȡ����
  TNetworkSendFileCancelReader = class( TSendFileCancelReader )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function getIsRun : Boolean;override;
  end;

    // ����·������
  TNetworkSendHandle = class( TSendHandle )
  public
    TcpSocket : TCustomIpClient;
    HeartBeatHelper : THeatBeatHelper;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected       // ����ǰ���
    function getDesItemIsBackup: Boolean;override;
  protected       // ɨ��
    function getContinuesHandle : TBackupContinuesHandle;override;
    function getFileScanHandle : TBackupFileScanHandle;override;
    function getFolderScanHandle : TBackupFolderScanHandle;override;
    function getIsScanCompleted : Boolean;override;
    procedure ResetSourcePathSpace;override;
  protected       // ����
    function getBackupFileHandle: TBackupFileHandle;override;
    function getRefreshSpeedInfo : TRefreshSpeedInfo;override;
    function getSendFileCancelReader : TSendFileCancelReader;override;
  protected       // �������
    procedure SetBackupCompleted;override;
  end;

{$EndRegion}


    // �����ӵ� Socket
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

    // ��������
  TMyFileSendConnectHandler = class
  private
    SocketLock : TCriticalSection;
    SendFileSocketList : TSendFileSocketList;
  private
    DesItemID, SourcePath : string;
  private
    IsConnSuccess, IsConnError, IsConnBusy : Boolean;
    BackConnSocket : TCustomIpClient;
  public       // ��ȡ��������
    constructor Create;
    function getSendPcConn( _DesItemID, _SourcePath : string ) : TCustomIpClient;
    procedure AddLastConn( LastDesItemID : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh;
    procedure StopRun;
    destructor Destroy; override;
  public       // Զ�̽��
    procedure AddBackConn( TcpSocket : TCustomIpClient );
    procedure BackConnBusy;
    procedure BackConnError;
  private      // �ȴ�
    function getConnect : TCustomIpClient;
    function getLastConnect : TCustomIpClient;
    function getBackConnect : TCustomIpClient;
    procedure WaitBackConn;
  end;

    // ԴĿ¼ ɨ��
    // Ŀ��Ŀ¼ ����/ɾ��
  TFileSendHandleThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // ɨ��
    procedure SendFileHandle( ScanPathInfo : TSendJobInfo );
    procedure StopScan( ScanPathInfo : TSendJobInfo );
  end;

    // ���ر��� Դ·�� ɨ��͸���
  TMyFileSendHandler = class
  public
    IsSendRun : Boolean;  // �Ƿ��������
    IsRun : Boolean;  // �Ƿ�������
  private
    ThreadLock : TCriticalSection;
    SendJobList : TSendJobList;
    IsCreateThread : Boolean;
    FileSendHandleThread : TFileSendHandleThread;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public       // ��ȡ״̬��Ϣ
    function getIsRun : Boolean;
    function getIsSending : Boolean;
  public
    procedure AddScanJob( ScanJobInfo : TSendJobInfo );
    function getSendJob : TSendJobInfo;
  end;

const
  Name_TempSendZip = 'ft_send_zip_temp.bczip';

var
    // �����ļ��߳�
  MyFileSendHandler : TMyFileSendHandler;
  MyFileSendConnectHandler : TMyFileSendConnectHandler;  // ���������߳�

implementation

uses UMySendApiInfo, UMySendDataInfo, UMyNetPcInfo, UMySendEventInfo, UMyReceiveApiInfo,
     UMyRegisterDataInfo, UMyRegisterApiInfo, UMainFormThread, UNetworkControl;

{ TFileCopyHandle }

function TBackupFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

    // 1 ���� ���һ��  �Ƿ񱸷��ж�
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );

  Result := Result and inherited;

    // �����Ѿ� Disable
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
    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // ���� ˢ�±����ٶ�
    SendItemAppApi.SetSpeed( DesItemID, SourcePath, RefreshSpeedInfo.LastSpeed );
  end;

    // ���� ����ɿռ�
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

  // ��ʼ����
  SendItemAppApi.BackupStart;

  MyFileSendHandler.IsSendRun := True;

  while MyFileSendHandler.IsRun do
  begin
    ScanPathInfo := MyFileSendHandler.getSendJob;
    if ScanPathInfo = nil then
      Break;

    try
        // ɨ��·��
      SendFileHandle( ScanPathInfo );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Send File Error', e.Message );
    end;

      // ֹͣɨ��
    StopScan( ScanPathInfo );
  end;

    // ��������
  if not MyFileSendHandler.IsSendRun then
    SendItemAppApi.BackupPause
  else
    SendItemAppApi.BackupStop;

    // �������
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
    // ���ò�ȱС�ռ�
  SendRootItemAppApi.SetIsLackSpace( DesItemID, False );

    // �Ƿ���ڴ���
  Result := MyHardDisk.getPathDriverExist( DesItemID );
  SendRootItemAppApi.SetIsExist( DesItemID, Result );
  if not Result then
    Exit;

    // ��������Ŀ¼
  if FileExists( SourcePath ) then
    ForceDirectories( ExtractFileDir( SavePath ) )
  else
    ForceDirectories( SavePath );


    // �Ƿ��д
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

    // 1 ���� ���һ��
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // ��ʾɨ���ļ���
    SendItemAppApi.SetScaningCount( DesItemID, SourcePath, FileCount );

      // ����Ƿ��жϱ���
    Result := Result and SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );

      // ����������ü��ʱ��
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
    // ����Ŀ¼·����Ϣ
  DesFolderPath := MyFilePath.getReceivePath( SourcePath, SourceFolderPath, SavePath );

    // ɨ��
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
  if Result then // ��ʱ��������
    HeatBeatHelper.CheckHeartBeat;
end;

procedure TNetworkFolderScanHandle.FindDesFileInfo;
var
  NetworkFolderFindDeepHandle : TNetworkFolderFindDeepHandle;
begin
    // �Ѷ�ȡ
  if IsDesReaded then
    Exit;

     // ����Ŀ¼��Ϣ
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
    // �����������
  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  NetworkFolderScanHandle.SetTcpSocket( TcpSocket );
  NetworkFolderScanHandle.SetHeatBeatHelper( HeatBeatHelper );
  Result := NetworkFolderScanHandle;

    // ��������Ŀ¼
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // �����Ŀ¼��Ϣ
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  NetworkFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // ��Ŀ¼δ��ȡ
  if not ChildFolderInfo.IsReaded then
    Exit;

    // ��Ŀ¼��Ϣ
  NetworkFolderScanHandle.DesFolderHash.Free;
  NetworkFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // ���ļ���Ϣ
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

    // ��ʱ����
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

    // ��ȡ���ʽ��
  CloudConnResult := MySocketUtil.RevJsonStr( TcpSocket );

    // ���� ������
  SendRootItemAppApi.SetIsConnected( DesItemID, True );

      // ���� ��ȱ�ٿռ�
  SendRootItemAppApi.SetIsLackSpace( DesItemID, False );

    // �Ƿ������·��
  IsDesExist := CloudConnResult <> ReceiveConnResult_NotExist;
  SendRootItemAppApi.SetIsExist( DesItemID, IsDesExist );

    // �Ѿ�����ȡ��
  IsCancel := CloudConnResult = ReceiveConnResult_Cancel;
  SendItemAppApi.SetIsReceiveCancel( DesItemID, SourcePath, IsCancel );

    // ��·���Ƿ��д
  IsDesWrite := CloudConnResult <> ReceiveConnResult_CannotWrite;
  SendRootItemAppApi.SetIsWrite( DesItemID, IsDesWrite );

    // �Ƿ񷵻�����
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

    // ���ÿռ���Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_SetSpace );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalCount', IntToStr( TotalCount ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalSize', IntToStr( TotalSize ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'TotalCompletedSize', IntToStr( TotalCompletedSize ) );
end;

procedure TNetworkSendHandle.SetBackupCompleted;
begin
    // ֪ͨ���շ������
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_SetCompleted );

    // ���ñ������ʱ��
  SendItemAppApi.SetLastBackupTime( DesItemID, SourcePath, Now );

    // ���������
  SendItemAppApi.SetNetworkBackupCompleted( DesItemID, SourcePath );
end;

procedure TNetworkSendHandle.Update;
begin
    // ��ȡ����
  TcpSocket := MyFileSendConnectHandler.getSendPcConn( DesItemID, SourcePath );
  if not Assigned( TcpSocket ) then // ����ʧ��
    Exit;

  inherited;

    // ���ͽ���
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_End );

    // ��������
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

    // ���ڰ����б���
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TBackupFolderFindHandle.IsFolderFilter(
  FolderPath: string): Boolean;
begin
  Result := True;

    // ���ڰ����б���
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // ���ų��б���
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
    // ��ӵ����ٶ�
  MyRefreshSpeedHandler.AddUpload( Space );

    // ˢ���ٶȣ� 1����ˢ��һ��
  if RefreshSpeedInfo.AddCompleted( Space ) then
  begin
      // ���� ˢ�±����ٶ�
    SendItemAppApi.SetSpeed( DesItemID, SourcePath, RefreshSpeedInfo.LastSpeed );

      // ���»�ȡ���ƿռ���Ϣ
    IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
    LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;
    RefreshSpeedInfo.SetLimitInfo( IsLimited, LimitSpeed );
  end;
end;

function TNetworkBackupFileSendHandle.CheckNextSend: Boolean;
begin
  Result := True;

    // 1 ���� ���һ�Σ� ����Ƿ��жϱ���
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
    // ������Ϣ
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.LostConnectError( Params );

    // ���� ���·���
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
    // ��ʾ���� Item
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
    // ������Ϣ
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := SendFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  SendErrorAppApi.SendFileError( Params );

    // ���� ���·���
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
    // ���͸� Ŀ��Pc ����
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
    // ��������
  SendFileReq( FileReq_AddFile );

    // �����ļ�
  NetworkBackupFileSendHandle := TNetworkBackupFileSendHandle.Create( SourceFilePath );
  NetworkBackupFileSendHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkBackupFileSendHandle.SetTcpSocket( TcpSocket );
  NetworkBackupFileSendHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  IsSendCompleted := NetworkBackupFileSendHandle.Update;
  NetworkBackupFileSendHandle.Free;

    // д Log
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
    // ��ȡ��Ϣ
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;
  ZipSize := ZipStream.Size;

      // ѹ���ļ�
  FilePathList := MyZipUtil.getPathList( ZipStream );

    // ѹ������·��
  TempFilePath := MyFilePath.getPath( SourcePath ) + Name_TempSendZip;

    // ���͸� Ŀ��Pc ����
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ZipFile );
  MySocketUtil.SendJsonStr( TcpSocket, 'ZipPath', TempFilePath );

    // ����ѹ���ļ�
  NetworkBackupFileSendZipHandle := TNetworkBackupFileSendZipHandle.Create( TempFilePath );
  NetworkBackupFileSendZipHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkBackupFileSendZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  NetworkBackupFileSendZipHandle.SetTcpSocket( TcpSocket );
  NetworkBackupFileSendZipHandle.SetZipStream( ZipStream );
  IsSendCompleted := NetworkBackupFileSendZipHandle.Update;
  NetworkBackupFileSendZipHandle.Free;

    // �ȴ���ѹ����
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );

    // ˢ������ɿռ���Ϣ
  if IsSendCompleted then
  begin
    DelZipSize := ScanResultAddZipInfo.TotalSize - ZipSize;
    SendItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, DelZipSize );
  end;

  ScanResultAddZipInfo.Free;

    // д log
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

    // ��ʾ��ʼ�����ļ�
  SendItemAppApi.SetStartBackup( DesItemID, SourcePath );

    // ȡ�������
  SendFileCancelReader := getSendFileCancelReader;
  SendFileCancelReader.SetItemInfo( DesItemID, SourcePath );

    // ��Ѱ�����
  SendFileFreeLimitReader := TSendFileFreeLimitReader.Create;
  SendFileFreeLimitReader.SetFileCount( TotalCompletedCount );
  SendFileFreeLimitReader.IniHandle;

    // �ٶȿ���
  RefreshSpeedInfo := getRefreshSpeedInfo;

    // ���ݴ���
  BackupHandle := getBackupFileHandle;
  BackupHandle.SetItemInfo( DesItemID, SourcePath );
  BackupHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  BackupHandle.IniHandle;

    // ����ɨ��·�����
  for i := 0 to ScanResultList.Count - 1 do
  begin
      // �Ƿ�ȡ������
    if not SendFileCancelReader.getIsRun then
      Break;

      // ��Ѱ���
    if not SendFileFreeLimitReader.AddResult( ScanResultList[i] ) then
    begin
      FreeLimitType := SendFileFreeLimitReader.getFreeLimitType;
      if FreeLimitType = FreeLimitType_FileCount then  // �����ļ������ƣ�ֹͣ����
        Break;
      Continue;
    end;

      // �����ݽ��
    BackupHandle.Handle( ScanResultList[i] );
  end;

    // �������� ���� ��Ϊ��Ѱ������
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
    // ����ϴ�ʧ�ܵķ���
  SendErrorAppApi.ClearItem( DesItemID, SourcePath );

    // ����ȡ����
  SendFileCancelReader := getSendFileCancelReader;
  SendFileCancelReader.SetItemInfo( DesItemID, SourcePath );

    // ��ȡ������Ϣ
  BackupContinuesList := SendItemInfoReadUtil.ReadContinuesList( DesItemID, SourcePath );
  if BackupContinuesList.Count > 0 then
    SendItemAppApi.SetStartBackup( DesItemID, SourcePath );
  RefreshSpeedInfo := getRefreshSpeedInfo;
  for i := 0 to BackupContinuesList.Count - 1 do
  begin
    if not SendFileCancelReader.getIsRun then // �Ƿ�ȡ������
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
    // ����Ѱ�
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

    // ��������
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
    // ����·���Ƿ�ɾ��
  Result := SendItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
  if not Result then
    Exit;

    // ����·���Ƿ����
  Result := MyFilePath.getIsExist( SourcePath );
  SendItemAppApi.SetIsExist( DesItemID, SourcePath, Result );
end;

procedure TSendHandle.ResetSourcePathSpace;
var
  Params : TBackupSetSpaceParams;
begin
    // ���� Դ·���ռ�
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
  IncludeFilterList : TFileFilterList;  // ����������
  ExcludeFilterList : TFileFilterList;  // �ų�������
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

    // ���� ����
  SendItemAppApi.SetAnalyzeBackup( DesItemID, SourcePath );

    // ·�����ļ���Ŀ¼
  IsFile := SendItemInfoReadUtil.ReadIsFile( DesItemID, SourcePath );

    // �ļ�/Ŀ¼ ɨ��
  if IsFile then
    ScanFileHandle
  else
    ScanFolderHandle;

      // ɨ�����
  if getIsScanCompleted then
    ResetSourcePathSpace; // ����·���ռ���Ϣ
end;

procedure TSendHandle.SetScanPathInfo(_ScanPathInfo: TSendJobInfo);
begin
  ScanPathInfo := _ScanPathInfo;
  SourcePath := ScanPathInfo.SendPath;
  DesItemID := ScanPathInfo.DesItemID;
end;

procedure TSendHandle.Update;
begin
    // ���������ֹͣ
  if not MyFileSendHandler.getIsRun then
    Exit;

    // Ŀ��·�����ܷ���
  if not getDesItemIsBackup then
    Exit;

    // Դ·�����ܷ���
  if not getSourcePathIsBackup then
    Exit;

    // ����
  ContinuesHandle;

    // ɨ��·��
  ScanPathHandle;

    // ����·��
  BackupFileHandle;

    // ���� �������
  if getIsScanCompleted and getIsBackupCompleted then
    SetBackupCompleted;

    // ����Ƿ��յ���Ѱ�����
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

      // �ļ�����
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
    // Դ�ļ������仯
  if getIsSourceChange then
    Exit;

    // Ŀ���ļ������仯
  if getIsDesChange then
    Exit;

    // �ļ�����
  if FileCopy then
    RemoveContinusInfo;  // ɾ��������¼
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
    // ��ʼ�� ����
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ContinuesAdd );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FilePath );

    // �����ļ�
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

    // �ļ�������
  if not FileExists( FilePath ) then
    Exit;

  try    // ������ȡ�ļ���
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;
  end;

    // ��ȡѹ���ļ���Ϣ
  ZipName := ExtractRelativePath( MyFilePath.getPath( SourcePath ), FilePath );
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );
  try
      // ���ѹ���ļ�
    ZipFile.Add( fs, NewZipInfo );
    fs.Free; // �ر��ļ���

      // ��ȡ Zip ��Ϣ
    NewZipInfo := ZipFile.FileInfos[ ZipFile.FileCount - 1 ];

      // ���ͳ����Ϣ
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

    // �Ƿ����ļ�
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // ֻѹ��С�� 128 KB ���ļ�
  SourceFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // �ȴ���ѹ���ļ�
  if not IsCreated then
  begin
    if not CreateZip then  // �����ļ�ʧ��
      Exit;
  end;

    // ���ѹ���ļ�ʧ��
  if not AddFile( ScanResultInfo.SourceFilePath ) then
    Exit;

    // ���� 1000 ���ļ� ���� 10MB �����̷���ѹ���ļ�
  if ( ZipCount >= 1000 ) or ( ZipSize >= 10 * Size_MB ) then
  begin
    DestoryZip;
    Result := getZipResultInfo;
    Exit;
  end;

    // ���ؿ�
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
    // �ر�ѹ���ļ�
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
    // �����ѶϿ�
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

  SocketLock.Enter;
  try
      // ��������10������
    if SendFileSocketList.Count >= 10 then  
    begin
      SendFileSocketList[0].CloseSocket;
      SendFileSocketList.Delete( 0 );
    end;
      // ��Ӿ�����
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
    Result := getConnect;  // ��ȡ����

      // ���ͳ�ʼ����Ϣ
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
        // ���������ӣ�ɾ��
      if MinutesBetween( Now, SendFileSocketList[i].LastTime ) >= 3 then
      begin
          // �رն˿�
        SendFileSocketList[i].CloseSocket;
          // ɾ��
        SendFileSocketList.Delete( i );
        Continue;
      end;
        // ��������
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
    // �ȴ����
  WaitBackConn;

    // ���ؽ��
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

    // ��ȡ��ǰ�����ӵĶ˿�
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // ��ȡ Pc ��Ϣ
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // Pc ����
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
    Exit;

    // �����޷����ӶԷ�
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( DesPcID ) then
  begin
    Result := getBackConnect; // ��������
    Exit;
  end;

    // ���� Ŀ�� Pc
  TcpSocket := TCustomIpClient.Create( nil );
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_ReceiveFile );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  IsConnected := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ʹ�÷�������
  if not IsConnected then
  begin
    TcpSocket.Free;
    NetworkPcApi.SetCanConnectTo( DesPcID, False ); // �����޷�����
    Result := getBackConnect; // ��������
    Exit;
  end;

    // �Ƿ���շ�æ
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

    // Ѱ���ϴζ˿�
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

    // ������
  if not Assigned( LastSocket ) then
    Exit;

    // �ж϶˿��Ƿ�����
  MySocketUtil.SendData( LastSocket, FileReq_New );
  FileReq := MySocketUtil.RevJsonStr( LastSocket );
  if FileReq <> FileReq_New then  // �˿��쳣
  begin
    LastSocket.Free;
    Result := getLastConnect; // ����һ��
    Exit;
  end;

    // �����ϴζ˿�
  Result := LastSocket;
end;

procedure TMyFileSendConnectHandler.WaitBackConn;
var
  ReceivePcID : string;
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // ��������
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

    // �Է��������ӱ���
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( ReceivePcID ) then
  begin
    SendRootItemAppApi.SetIsConnected( DesItemID, False );
    Exit;
  end;

      // ��ʼ�������Ϣ
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // ����������
  NetworkBackConnEvent.AddItem( ReceivePcID );

    // �ȴ����շ�����
  StartTime := Now;
  while MyFileSendHandler.getIsRun and
        ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // Ŀ�� Pc ��æ
  if IsConnBusy then
  begin
    SendItemAppApi.SetIsDesBusy( DesItemID, SourcePath, True );
    Exit;
  end;

    // �޷�����
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( ReceivePcID, False ); // �����޷�����
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
      // ִ��
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
    // ��������ѹ���ļ�
  ScanResultInfo := CompressFileHandle.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    SendFile( ScanResultInfo );

    // �ȴ��߳̽���
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

    // ��ȡ���ʽ��
  CloudConnResult := MySocketUtil.RevData( NewSocket );

  if CloudConnResult = ReceiveConnResult_OK then
    Result := NewSocket
  else
    NewSocket.Free;
end;

procedure TNetworkBackupFileHandle.Handle(ScanResultInfo: TScanResultInfo);
begin
    // ��ȡ��һ��Job
  if not IsFile then
    ScanResultInfo := CompressFileHandle.AddZipFile( ScanResultInfo );

    // ������� Job
  if ScanResultInfo = nil then
  begin
    CheckHeartBeat; // ��ʱ������
    Exit;
  end;

    // �����ļ�
  if ( ScanResultInfo is TScanResultAddFileInfo ) or
     ( ScanResultInfo is TScanResultAddZipInfo )
  then
    SendFile( ScanResultInfo )  // Ѱ���̷߳���
  else
    HandleNow( ScanResultInfo ); // ���̴���
end;

procedure TNetworkBackupFileHandle.HandleNow(ScanResultInfo: TScanResultInfo);
var
  NetworkSendResultHandle : TNetworkSendResultHandle;
begin
    // ������
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
    // ����ѹ����
  CompressFileHandle := TCompressSendFileHandle.Create( DesItemID, SourcePath );

    // �����ļ���ûJob�����ٴ����߳�
  if IsFile or not IsExitJob then
    Exit;

    // ������ Pc ���ö��߳�
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
      // Ѱ�ҿ��е��߳�
    IsFindThread := False;
    for i := 0 to SendFileThreadList.Count - 1 do
      if not SendFileThreadList[i].IsRun and not SendFileThreadList[i].IsLostConn then  // �߳̿��У���û�жϿ�����
      begin
        SendFileThreadList[i].AddScanResultInfo( ScanResultInfo );
        IsFindThread := True;
        Break;
      end;

      // û���ҵ��̣߳���ǰ�̴߳���
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

    // ���ͽ������
  MySocketUtil.SendData( TcpSocket, FileReq_End );

    // ���ն˿�
  MyFileSendConnectHandler.AddLastConn( DesItemID, TcpSocket );

  inherited;
end;

procedure TSendFileThread.SendFile;
var
  NetworkSendResultHandle : TNetworkSendResultHandle;
begin
    // ������
  NetworkSendResultHandle := TNetworkSendResultHandle.Create;
  NetworkSendResultHandle.SetTcpSocket( TcpSocket );
  NetworkSendResultHandle.SetScanResultInfo( ScanResultInfo );
  NetworkSendResultHandle.SetItemInfo( DesItemID, SourcePath );
  NetworkSendResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  NetworkSendResultHandle.Update;
  NetworkSendResultHandle.Free;

    // �������ļ����͹����У��ѶϿ�����
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
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 �뷢��һ������
      Continue;
      // �������������ܶԷ��Ѿ��Ͽ����ӣ�������߳�
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

    // ����Ѱ�
  if not IsFreeLimit then
    Exit;

    // �Ƿ����ļ�
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // ������ѷ�������
  if MySendItem_SendCount <= 3 then
    Exit;

  Result := False;

    // ͳ���ܷ����ļ���
  Inc( FileCount );
  if RegisterLimitApi.ReadIsCountLimt( FileCount )  then
  begin
    FreeLimitType := FreeLimitType_FileCount;
    Exit;
  end;

    // �ļ����Ϳռ�
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

    // �Ƿ���Ҫ��ͣһ��
  Inc( SleepCount );
  if SleepCount >= 10 then
  begin
    SleepCount := 0;
    Sleep(1);
  end;

    // �Ƿ��Ѿ�����
  if SecondsBetween( Now, ScanTime ) >= 1 then  // ��� BackupItem ɾ��
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


