unit UShareDownThread;

interface

uses Classes, Generics.Collections, SyncObjs, UFolderCompare, UMyUtil,
     SysUtils, DateUtils, sockets, UMyTcp, UModelUtil, UMyDebug, Math, uDebugLock, zip;

type

{$Region ' ���ݽṹ ' }

    // �ָ�ɨ����Ϣ
  TShareDownJobInfo = class
  public
    SharePath, OwnerID : string;
    IsFile : Boolean;
  public
    constructor Create( _SharePath, _OwnerID : string );
    procedure SetIsFile( _IsFile : Boolean );
  end;
  TShareDownJobList = class( TObjectList< TShareDownJobInfo > );

    // �ָ�����Ŀ¼ ɨ����Ϣ
  TShareDownScanLocalInfo = class( TShareDownJobInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ
  TShareDownScanNetworkInfo = class( TShareDownJobInfo )
  end;

    // �������
  TShareDownScanExplorerInfo = class( TShareDownJobInfo )
  public
    IsSearch : Boolean;
  public
    procedure SetIsSearch( _IsSearch : Boolean );
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ ���
  TShareDownScanLocalExplorerInfo = class( TShareDownScanExplorerInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ ���
  TShareDownScanNetworkExplorerInfo = class( TShareDownScanExplorerInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ ����
  TShareDownScanNetworSearchInfo = class( TShareDownJobInfo )
  public
    SearchName : string;
  public
    procedure SetSearchName( _SearchName : string );
  end;

    // Ԥ������
  TShareDownScanNetworkPreviewInfo = class( TShareDownJobInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ��ͼƬ
  TShareDownScanNetworkPreviewPictureInfo = class( TShareDownScanNetworkPreviewInfo )
  public
    PreviewWidth, PreviewHeight : Integer;
  public
    procedure SetPreviewSize( _PreviewWidth, _PreviewHeight : Integer );
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ�� Doc
  TShareDownScanNetworkPreviewWordInfo = class( TShareDownScanNetworkPreviewInfo )
  end;

      // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ�� Excel
  TShareDownScanNetworkPreviewExcelInfo = class( TShareDownScanNetworkPreviewInfo )
  end;

      // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ�� Zip
  TShareDownScanNetworkPreviewZipInfo = class( TShareDownScanNetworkPreviewInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ�� Exe
  TShareDownScanNetworkPreviewExeInfo = class( TShareDownScanNetworkPreviewInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ���ĵ�
  TShareDownScanNetworkPreviewTextInfo = class( TShareDownScanNetworkPreviewInfo )
  end;

    // �ָ�����Ŀ¼ ɨ����Ϣ Ԥ������
  TShareDownScanNetworkPreviewMusicInfo = class( TShareDownScanNetworkPreviewInfo )
  end;


{$EndRegion}

{$Region ' �������� ɨ�� ' }

    // ����Ŀ��Ŀ¼ �Ƚ��㷨
  TLocalDesFolderScanHandle = class( TFolderScanHandle )
  protected
    SharePath, OwnerID : string;
    SavePath : string;
  public
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure FindDesFileInfo;override;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;override;
  end;

    // ����Ŀ���ļ� �Ƚ��㷨
  TLocalDesFileScanHandle = class( TFileScanHandle )
  protected
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' �������� ���� ' }

    // ��������
  TShareDownContinuesHandle = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    SharePath, OwnerID : string;
    SavePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    SaveFilePath : string;
  public
    procedure SetSourceFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;virtual;
  protected
    function getIsSourceChange : Boolean; virtual;abstract;
    function getIsDesChange : Boolean;
    function FileCopy: Boolean;virtual;abstract;
    procedure RemoveContinusInfo;
  end;

      // �ָ��������
  TShareDownResultHandle = class
  public
    ScanResultInfo : TScanResultInfo;
    SourceFilePath : string;
    SharePath, OwnerID : string;  // ����Դ������Ŀ��
    SavePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    SaveFilePath : string;
  public
    procedure SetScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;
  protected         // ���
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
  protected         // ɾ��
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // ��ȡѹ����
    procedure SourceFileGetZip;virtual;abstract;
  private           // д��־
    procedure LogShareDownCompleted;
    procedure LogShareDownIncompleted;
  end;

    // ����ɨ����
  TShareDownFileHandle = class
  protected
    SharePath, OwnerID : string;  // ����Դ������Ŀ��
    SavePath : string;  // �ָ�·��
  protected
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Handle( ScanResultInfo : TScanResultInfo );virtual;abstract;
    procedure IniHandle;virtual;
    procedure LastCompleted;virtual;
  end;

    // �Ƿ�ȡ������
  TShareDownCancelReader = class
  private
    SharePath, OwnerID : string;
  private
    ScanTime : TDateTime;
    SleepCount : Integer;
  public
    constructor Create;
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    function getIsRun : Boolean;virtual;
  end;

    // ���ð�����
  TShareDownFreeLimitReader = class
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


    // ����·������
  TShareDownHandle = class
  public
    RestoreScanInfo : TShareDownJobInfo;
    SharePath, OwnerID : string;  // ����Դ������Ŀ��
    SavePath : string;  // �ָ�·��
    IsFile : Boolean; // �Ƿ��ļ�
  public   // �ļ�ɨ����
    TotalCount, TotalCompletedCount : Integer;
    TotalSize, TotalCompletedSize : Int64;
    FreeLimitType : string;
  public   // �ļ��仯��Ϣ
    ScanResultList : TScanResultList;
  public
    constructor Create;
    procedure SetRestoreScanInfo( _RestoreScanInfo : TShareDownJobInfo );
    procedure Update;virtual;
    destructor Destroy; override;
  private       // �ָ�ǰ���
    function getRestoreFromIsBackup: Boolean;virtual;abstract;
    function getSavePathIsBackup : Boolean;
  private       // ɨ��
    procedure ContinuesHandle; // ����
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetRestorePathSpace;
    function getContinuesHandle : TShareDownContinuesHandle;virtual;abstract;
    function getRestoreFileHandle : TLocalDesFileScanHandle;virtual;abstract;
    function getRestoreFolderHandle : TLocalDesFolderScanHandle;virtual;abstract;
    function getIsScanCompleted : Boolean;virtual;
  private       // �ָ�
    procedure ResetStartRestoreFile;
    procedure RestoreFileHandle;
    function getShareDownFileHandle : TShareDownFileHandle;virtual;abstract;
    function getShareDownCancelReader : TShareDownCancelReader;virtual;
  private       // �ָ����
    function getIsRestoreCompleted : Boolean;
    procedure SetRestoreStop;
    procedure SetRestoreCompleted;
    procedure FreeLimitShowCheck;
  end;

{$EndRegion}


{$Region ' ���ع������� ɨ�� ' }

    // ����Ŀ¼ �ָ�
  TLocalFolderRestoreScanHandle = class( TLocalDesFolderScanHandle )
  protected       // Ŀ���ļ���Ϣ
    procedure FindSourceFileInfo;override;
  protected
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // �����ļ� �ָ�
  TLocalFileRestoreScanHandle = class( TLocalDesFileScanHandle )
  protected       // Ŀ���ļ���Ϣ
    function FindSourceFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���ع������� ���� ' }

    // �����ļ�
  TShareFileCopyHandle = class( TFileCopyHandle )
  private
    SharePath, OwnerID : string;
  public
    procedure SetItemInfo( _SharePath, _OwnerID : string );
  protected
    function CheckNextCopy : Boolean;override; // ����Ƿ��������
    procedure RefreshCompletedSpace;override;
  protected
    procedure DesWriteSpaceLack;override;  // �ռ䲻��
    procedure MarkContinusCopy;override;  // ����
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
  end;

{$EndRegion}

{$Region ' ���ع������� ���� ' }

    // �����ļ� ����
  TLocalShareDownContinuesHandle = class( TShareDownContinuesHandle )
  public
    function getIsSourceChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

      // �������
  TLocalRestoreResultHandle = class( TShareDownResultHandle )
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // ��ȡѹ����
    procedure SourceFileGetZip;override;
  end;

    // ������
  TLocalShareDownFileHandle = class( TShareDownFileHandle )
  public
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
  end;

    // ���ػָ�����
  TLocalRestoreHandle = class( TShareDownHandle )
  protected       // �ָ�ǰ���
    function getRestoreFromIsBackup: Boolean;override;
  protected       // ɨ�账��
    function getContinuesHandle : TShareDownContinuesHandle;override;
    function getRestoreFileHandle : TLocalDesFileScanHandle;override;
    function getRestoreFolderHandle : TLocalDesFolderScanHandle;override;
  protected       // �������
    function getShareDownFileHandle : TShareDownFileHandle;override;
  end;

{$EndRegion}


{$Region ' ���繲�� ɨ�� ' }

    // ����Ŀ¼ �ָ�
  TNetworkFolderRestoreScanHandle = class( TLocalDesFolderScanHandle )
  public
    TcpSocket : TCustomIpClient;
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected       // Ŀ���ļ���Ϣ
    procedure FindSourceFileInfo;override;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;override;
  end;

    // �����ļ� �ָ�
  TNetworkFileRestoreScanHandle = class( TLocalDesFileScanHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected       // Ŀ���ļ���Ϣ
    function FindSourceFileInfo: Boolean;override;
  end;


{$EndRegion}

{$Region ' ���繲�� ���� ' }

    // ���ջָ��ļ�
  TNetworkFileRestoreReceiveHandle = class( TNetworkFileReceiveHandle )
  protected
    SharePath, OwnerID : string;
    ShareFilePath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetShareFilePath( _ShareFilePath : string );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
  protected
    function CheckNextReceive : Boolean;override; // ����Ƿ��������
    procedure RefreshCompletedSpace;override;
    procedure AddSpeedSpace( Space : Integer );override;
    function getLimitBlockSize : Int64;override;
  protected
    procedure RevFileLackSpaceHandle;override; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusRev;override; // �����Ĵ���
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
    procedure LostConnectError;override; //�Ͽ����ӳ���
    procedure ReceiveFileError;override; // �����ļ�����
  end;

    // ���� ѹ���ļ�
  TNetworkFileRestoreReceiveZipHandle = class( TNetworkFileRestoreReceiveHandle )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    function CreateWriteStream : Boolean;override;
  protected
    procedure LastRefreshCompletedSpace;override;
    procedure LogCompleted( ZipName : string );
  end;

{$EndRegion}

{$Region ' ���繲�� ���� ' }

    // ��������
  TNetworkShareDownContinuesHandle = class( TShareDownContinuesHandle )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    function getIsSourceChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

      // �������
  TNetworkRestoreResultHandle = class( TShareDownResultHandle )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // ��ȡѹ����
    procedure SourceFileGetZip;override;
  end;

    // ���߳�����
  TShareDownThread = class( TDebugThread )
  private
    IsRun: Boolean;
    SharePath, OwnerID : string;
    SavePath : string;
    TcpSocket : TCustomIpClient;
    RefreshSpeedInfo: TRefreshSpeedInfo;
  private
    SocketLock : TCriticalSection;
    ScanResultInfo : TScanResultInfo;
  public
    IsLostConn : Boolean;
  public
    constructor Create;
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    destructor Destroy; override;
  public
    procedure AddScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SendZip( FilePath : string );
    procedure getErrorList( ErrorList : TStringList );
  protected
    procedure Execute; override;
  private
    procedure WaitToDown;
    procedure DownloadFile;
  end;
  TShareDownThreadList = class( TObjectList<TShareDownThread> )end;


    // ������
  TNetworkShareDownFileHandle = class( TShareDownFileHandle )
  private
    TcpSocket : TCustomIpClient;
    HeartTime : TDateTime;
    IsFile, IsExistJob : Boolean;
  private
    ZipThreadIndex : Integer;
    ZipCount, ZipSize : Integer;
    ShareDownThreadList : TShareDownThreadList;
    IsExistThread : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetDownInfo( _IsFile, _IsExistJob : Boolean );
    procedure IniHandle;override;
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure LastCompleted;override;
    destructor Destroy; override;
  private
    procedure ZipFile( ScanResultInfo : TScanResultInfo );
    procedure DownloadFile( ScanResultInfo : TScanResultInfo );
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
    procedure DownZipNow;
  private
    function FindZipThread: Boolean;
    procedure DownloadZip;
    function getNewConnect : TCustomIpClient;
    procedure CheckHeartBeat;
    procedure HandleZipError;
  end;

    // ��������ȡ��
  TNetworkShareDownCancelReader = class( TShareDownCancelReader )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function getIsRun : Boolean;override;
  end;

     // ����·������
  TNetworkShareDownHandle = class( TShareDownHandle )
  protected
    TcpSocket : TCustomIpClient;
    HeatBeatHelper : THeatBeatHelper;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected       // �ָ�ǰ���
    function getRestoreFromIsBackup: Boolean;override;
  protected       // ɨ�账��
    function getContinuesHandle : TShareDownContinuesHandle;override;
    function getRestoreFileHandle : TLocalDesFileScanHandle;override;
    function getRestoreFolderHandle : TLocalDesFolderScanHandle;override;
    function getIsScanCompleted : Boolean;override;
  protected       // �������
    function getShareDownFileHandle : TShareDownFileHandle;override;
    function getShareDownCancelReader : TShareDownCancelReader;override;
  end;

{$EndRegion}


{$Region ' ����Ŀ¼ ��� ' }

  TShareFolderExplorerHandle = class
  public
    ShareScanInfo : TShareDownJobInfo;
    SharePath, OwnerID : string;
    IsSearch : Boolean;
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    constructor Create;
    procedure SetShareScanInfo( _ShareScanInfo : TShareDownJobInfo );
    procedure Update;
    destructor Destroy; override;
  protected
    procedure FindScanResult;virtual;abstract;
    procedure ShowScanResult;
  end;

    // ���ع��� �����Ϣ
  TLocalShareFolderExplorerHandle = class( TShareFolderExplorerHandle )
  protected
    procedure FindScanResult;override;
  end;

    // ���繲�� �����Ϣ
  TNetworkShareFolderExplorerBaseHandle = class( TShareFolderExplorerHandle )
  public
    TcpSocket : TCustomIpClient;
  protected
    procedure FindScanResult;override;
  private
    procedure ScanNetworkFolder;
  end;

{$EndRegion}

{$Region ' ����Ŀ¼ ���� ' }

    // ���������������
  TNetworkShareSearchHandle = class( TNetworkFolderSearchHandle )
  public
    SharePath : string;
  public
    procedure SetSharePath( _SharePath : string );
  protected
    procedure HandleResultHash;override;
    function getIsStop : Boolean; override;
  end;

    // �����ļ�����
  TShareFileSearchHandle = class
  private
    ShareSearchScanInfo : TShareDownScanNetworSearchInfo;
    SharePath, OwnerID : string;
    SearchName : string;
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetShareSearchScanInfo( _ShareSearchScanInfo : TShareDownScanNetworSearchInfo );
    procedure Update;virtual;
  private
    procedure SearchFolder;
  end;

{$EndRegion}

{$Region ' �����ļ� Ԥ�� ' }

  {$Region ' Ԥ���ļ����� ' }

    // Ԥ���ļ� ����
  TNetworkShareFilePreviewReceiveHandle = class( TNetworkFileReceiveHandle )
  private
    PreviewStream : TStream;
  protected
    function getIsEnoughSapce : Boolean;override;
    function CreateWriteStream : Boolean;override;
    procedure LastRefreshCompletedSpace;override;
    procedure ResetFileTime;override;
  protected
    procedure ShowPreviewFile;virtual;abstract;
  end;

     // Ԥ���ļ� ���� ͼƬ
  TNetworkShareFilePreviewPictureReceiveHandle = class( TNetworkShareFilePreviewReceiveHandle )
  protected
    procedure ShowPreviewFile;override;
  end;

    // Ԥ���ļ� ���� �ı�
  TNetworkShareFilePreviewTextReceiveHandle = class( TNetworkShareFilePreviewReceiveHandle )
  protected
    procedure ShowPreviewFile;override;
  end;

    // Ԥ���ļ� ���� Exe
  TNetworkShareFilePreviewExeReceiveHandle = class( TNetworkShareFilePreviewReceiveHandle )
  private
    ExeText : string;
  public
    procedure SetExeText( _ExeText : string );
  protected
    function CreateWriteStream : Boolean;override;
    procedure ShowPreviewFile;override;
  end;

  {$EndRegion}


    // Ԥ���ļ�����
  TShareFilePreviewHandle = class
  public
    ShareScanInfo : TShareDownJobInfo;
    SharePath, OwnerID : string;
  public
    procedure SetShareScanInfo( _ShareScanInfo : TShareDownJobInfo );
  end;

    // ����Ԥ���ļ�����
  TNetworkShareFilePreviewHandle = class( TShareFilePreviewHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure Update;virtual;
  private
    procedure Preview;
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewZip;
    procedure PreviewExe;
    procedure PreviewText;
    procedure PreviewMusic;
  end;

{$EndRegion}


{$Region ' ������ ' }

    // �ָ������֧
  TRestoreHandleScan = class
  public
    RestoreScanInfo : TShareDownJobInfo;
  public
    constructor Create( _RestoreScanInfo : TShareDownJobInfo );
    procedure Update;
  private
    procedure LocalRestore;
    procedure NetworkRestore;
    procedure LocalRestoreExplorer;
    procedure NetworkRestoreExplorer;
    procedure NetworkRestorePreview;
    procedure NetworkRestoreSearch;
  end;

  TMyShareDownBaseHandler = class;

    // ����ָ��߳�
  TShareDownHandleBaseThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleScan( RestoreScanInfo : TShareDownJobInfo );
    function getIsRun : Boolean;
    procedure RemoveThreadCreate;
    function getRestoreScan : TShareDownJobInfo;
  protected
    procedure StartScanHandle;virtual;
    procedure StopScan( RestoreScanInfo : TShareDownJobInfo );virtual;
    procedure StopScanHandle;virtual;
    function getHandler : TMyShareDownBaseHandler;virtual;abstract;
  end;

    // �߳̿�����
  TMyShareDownBaseHandler = class
  public
    IsRun : Boolean;
  private
    ThreadLock : TCriticalSection;
    ShareDownScanList : TShareDownJobList;
    IsCreateThread : Boolean;
    ShareDownBaseHandleThread : TShareDownHandleBaseThread;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure AddShareDownJob( ShareDownJobInfo : TShareDownJobInfo );
    function getShareDownJob : TShareDownJobInfo;
  protected
    function CreateThread : TShareDownHandleBaseThread;virtual;abstract;
  end;

{$EndRegion}

{$Region ' �������� ' }

    // ���������ӵ� Socket
  TShareDownSocketInfo = class
  public
    OwnerID : string;
    TcpSocket : TCustomIpClient;
    LastTime : TDateTime;
  public
    constructor Create( _OwnerID : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    procedure CloseSocket;
  end;
  TShareDownSocketList = class( TObjectList<TShareDownSocketInfo> )end;

    // ��������
  TMyShareDownConnectHandler = class
  private
    ConnectLock : TCriticalSection;
    ShareDownSocketList : TShareDownSocketList; // ������ʷ����
  private
    SharePath, OwnerID : string;
    ShareConn : string;
  private
    IsConnSuccess, IsConnError, IsConnBusy : Boolean;
    BackConnSocket : TCustomIpClient;
  public       // ��ȡ��������
    constructor Create;
    function getShareConn( _SharePath, _OwnerID, _ShareConn : string ) : TCustomIpClient;
    procedure AddLastConn( LastOwnerID : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh; // ����
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
  private
    procedure HandleBusy;
    procedure HandleNotConn;
    function getIsHandlerRun : Boolean;
  end;

    // ���������߳�
  TShareDownHandleThread = class( TShareDownHandleBaseThread )
  protected
    procedure StartScanHandle;override;
    procedure StopScan( RestoreScanInfo : TShareDownJobInfo );override;
    procedure StopScanHandle;override;
  protected
    function getHandler : TMyShareDownBaseHandler;override;
  end;

    // �����ļ����� ������
  TMyShareDownHandler = class( TMyShareDownBaseHandler )
  public
    IsDownRun : Boolean;
  public
    function getIsRun : Boolean;
  protected
    function CreateThread : TShareDownHandleBaseThread;override;
  end;

{$EndRegion}

{$Region ' ������� ' }

    // ��������߳�
  TShareDownExplorerThread = class( TShareDownHandleBaseThread )
  protected
    procedure StartScanHandle;override;
    procedure StopScanHandle;override;
  protected
    function getHandler : TMyShareDownBaseHandler;override;
  end;

    // �����ļ���� ������
  TMyShareExplorerHandler = class( TMyShareDownBaseHandler )
  protected
    function CreateThread : TShareDownHandleBaseThread;override;
  end;

{$EndRegion}

{$Region ' ����Ԥ�� ' }

  TShareDownPreviewThread = class( TShareDownHandleBaseThread )
  protected
    procedure StartScanHandle;override;
    procedure StopScanHandle;override;
  protected
    function getHandler : TMyShareDownBaseHandler;override;
  end;

    // Ԥ����Ϣ
  TMySharePreviewHandler = class( TMyShareDownBaseHandler )
  protected
    function CreateThread : TShareDownHandleBaseThread;override;
  end;

{$EndRegion}

{$Region ' �������� ' }

  TShareDownSearchThread = class( TShareDownHandleBaseThread )
  protected
    procedure StartScanHandle;override;
    procedure StopScanHandle;override;
  protected
    function getHandler : TMyShareDownBaseHandler;override;
  end;

    // Ԥ����Ϣ
  TMyShareSearchHandler = class( TMyShareDownBaseHandler )
  public
    IsSearchRun : Boolean;
  public
    function getIsRun : Boolean;
  protected
    function CreateThread : TShareDownHandleBaseThread;override;
  end;

{$EndRegion}


const
  FreeLimitType_FileSize = 'FileSize';
  FreeLimitType_FileCount = 'FileCount';

  ShareConnect_Down = 'Down';
  ShareConnect_Explorer = 'Explorer';
  ShareConnect_Preview = 'Preview';
  ShareConnect_Search = 'Search';

const
  SocketType_New = 0;
  SocketType_Used = 1;

const
  Name_TempShareDownZip = 'ft_sharedown_zip_temp.bczip';

var
  MyShareDownHandler : TMyShareDownHandler;
  MyShareExplorerHandler : TMyShareExplorerHandler;
  MySharePreviewHandler : TMySharePreviewHandler;
  MyShareSearchHandler : TMyShareSearchHandler;

  MyShareDownConnectHandler : TMyShareDownConnectHandler;

implementation

uses UMyShareDownApiInfo, UMyNetPcInfo,  UMyShareDownDataInfo, UMyShareApiInfo, UNetworkControl,
     UMyRegisterDataInfo, UMyRegisterApiInfo, UMyShareDownEventInfo, UMainFormThread, UMyShareDownFaceInfo,
     UMySharedownXmlInfo;

{ TRestoreScanInfo }

constructor TShareDownJobInfo.Create(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownJobInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

{ TRestoreHandleThread }

constructor TShareDownHandleBaseThread.Create;
begin
  inherited Create;
end;

destructor TShareDownHandleBaseThread.Destroy;
begin
  inherited;
end;

procedure TShareDownHandleBaseThread.Execute;
var
  RestoreScanInfo : TShareDownJobInfo;
begin
  FreeOnTerminate := True;

    // ��ʼ�ָ�
  StartScanHandle;

  while getIsRun do
  begin
    RestoreScanInfo := getRestoreScan;
    if RestoreScanInfo = nil then
      Break;

    try
        // ��������
      HandleScan( RestoreScanInfo );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Share Down File Error', e.Message );
    end;

    StopScan( RestoreScanInfo );
  end;

    // ֹͣ�ָ�
  StopScanHandle;

    // ��������
  if not getIsRun then
    RemoveThreadCreate;

  Terminate;
end;

function TShareDownHandleBaseThread.getIsRun: Boolean;
begin
  Result := getHandler.IsRun;
end;

function TShareDownHandleBaseThread.getRestoreScan: TShareDownJobInfo;
begin
  Result := getHandler.getShareDownJob;
end;

procedure TShareDownHandleBaseThread.HandleScan(RestoreScanInfo: TShareDownJobInfo);
var
  RestoreHandleScan : TRestoreHandleScan;
begin
  DebugLock.Debug( 'HandleScan' );

  RestoreHandleScan := TRestoreHandleScan.Create( RestoreScanInfo );
  RestoreHandleScan.Update;
  RestoreHandleScan.Free;
end;

procedure TShareDownHandleBaseThread.RemoveThreadCreate;
begin
  getHandler.IsCreateThread := False;
end;

procedure TShareDownHandleBaseThread.StartScanHandle;
begin

end;

procedure TShareDownHandleBaseThread.StopScan(
  RestoreScanInfo: TShareDownJobInfo);
begin
  RestoreScanInfo.Free;
end;

procedure TShareDownHandleBaseThread.StopScanHandle;
begin

end;

{ TLocalRestoreHandle }

function TLocalRestoreHandle.getContinuesHandle: TShareDownContinuesHandle;
begin
  Result := TLocalShareDownContinuesHandle.Create;
end;

function TLocalRestoreHandle.getRestoreFileHandle: TLocalDesFileScanHandle;
begin
  Result := TLocalFileRestoreScanHandle.Create;
end;

function TLocalRestoreHandle.getRestoreFolderHandle: TLocalDesFolderScanHandle;
begin
  Result := TLocalFolderRestoreScanHandle.Create;
end;

function TLocalRestoreHandle.getRestoreFromIsBackup: Boolean;
begin
  Result := ShareDownInfoReadUtil.ReadIsExist( SharePath, OwnerID );
  if not Result then // ��ɾ���ָ�����
    Exit;

    // ����Ŀ��·���Ƿ����
  Result := MyFilePath.getIsExist( SharePath );
end;

function TLocalRestoreHandle.getShareDownFileHandle: TShareDownFileHandle;
begin
  Result := TLocalShareDownFileHandle.Create;
end;

{ TLocalSourceFolderScanHandle }

function TLocalDesFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited and MyShareDownHandler.getIsRun;

    // 1 ���� ���һ��
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // ��ʾɨ���ļ���
    ShareDownAppApi.SetScaningCount( SharePath, OwnerID, FileCount );

      // ����Ƿ��жϱ���
    Result := Result and ShareDownInfoReadUtil.ReadIsExist( SharePath, OwnerID );

      // ����������ü��ʱ��
    if Result then
      ScanTime := Now;
  end;
end;

procedure TLocalDesFolderScanHandle.FindDesFileInfo;
var
  DesFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // ��ȡĿ���ļ�·��
  DesFolderPath := MyFilePath.getReceivePath( SharePath, SourceFolderPath, SavePath );

    // ɨ��Ŀ���ļ�
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( DesFolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( DesFileHash );
  LocalFolderFindHandle.SetScanFolder( DesFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;
end;

{ TLocalSourceFileScanHandle }

function TLocalDesFileScanHandle.FindDesFileInfo: Boolean;
var
  LocalFileFindHandle : TLocalFileFindHandle;
begin
  LocalFileFindHandle := TLocalFileFindHandle.Create( SavePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  DesFileSize := LocalFileFindHandle.getFileSize;
  DesFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;

procedure TLocalDesFolderScanHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TLocalDesFolderScanHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TLocalDesFileScanHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLocalFolderRestoreScanHandle }

procedure TLocalFolderRestoreScanHandle.FindSourceFileInfo;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( SourceFolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( SourceFileHash );
  LocalFolderFindHandle.SetScanFolder( SourceFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;
end;

function TLocalFolderRestoreScanHandle.getScanHandle( SourceFolderName : string ): TFolderScanHandle;
var
  ScanHandle : TLocalFolderRestoreScanHandle;
begin
  ScanHandle := TLocalFolderRestoreScanHandle.Create;
  ScanHandle.SetItemInfo( SharePath, OwnerID );
  ScanHandle.SetSavePath( SavePath );
  Result := ScanHandle;
end;


{ TLocalFileRestoreScanHandle }

function TLocalFileRestoreScanHandle.FindSourceFileInfo: Boolean;
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

{ TLocalRestoreResultHandle }

procedure TLocalRestoreResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( SaveFilePath );
end;

procedure TLocalRestoreResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( SaveFilePath );
end;

procedure TLocalRestoreResultHandle.SourceFileAdd;
var
  RestoreFileCopyHandle : TShareFileCopyHandle;
begin
  RestoreFileCopyHandle := TShareFileCopyHandle.Create( SourceFilePath, SaveFilePath );
  RestoreFileCopyHandle.SetItemInfo( SharePath, OwnerID );
  RestoreFileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  RestoreFileCopyHandle.Update;
  RestoreFileCopyHandle.Free;
end;

procedure TLocalRestoreResultHandle.SourceFileGetZip;
begin

end;

procedure TLocalRestoreResultHandle.SourceFolderAdd;
begin
  ForceDirectories( SaveFilePath );
end;

{ TRestoreFileCopyHandle }

function TShareFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

    // 1 ���� ���һ��  �Ƿ񱸷��ж�
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := ShareDownInfoReadUtil.ReadIsExist( SharePath, OwnerID );

  Result := Result and inherited;
  Result := Result and MyShareDownHandler.getIsRun;
end;

procedure TShareFileCopyHandle.DesWriteSpaceLack;
begin
  ShareDownAppApi.SetIsLackSpace( SharePath, OwnerID, True );
end;

procedure TShareFileCopyHandle.MarkContinusCopy;
var
  Params : TShareDownContinusAddParams;
begin
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.FileTime := FileTime;
  Params.Position := Position;
  ShareDownContinusApi.AddItem( Params );
end;


procedure TShareFileCopyHandle.ReadFileError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := Position;
  ShareDownErrorApi.ReadFileError( Params );
end;

procedure TShareFileCopyHandle.RefreshCompletedSpace;
begin
    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // ���� ˢ�±����ٶ�
    ShareDownAppApi.SetSpeed( SharePath, OwnerID, RefreshSpeedInfo.LastSpeed );
  end;

    // ���� ����ɿռ�
  ShareDownAppApi.AddCompletedSpace( SharePath, OwnerID, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TShareFileCopyHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;


procedure TShareFileCopyHandle.WriteFileError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := SourceFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := Position;
  ShareDownErrorApi.WriteFileError( Params );
end;

function TMyShareDownHandler.CreateThread: TShareDownHandleBaseThread;
begin
  Result := TShareDownHandleThread.Create;
end;

function TMyShareDownHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsDownRun;
end;

{ TNetworkBackupHandle }

constructor TNetworkShareDownHandle.Create;
begin
  inherited;

  HeatBeatHelper := THeatBeatHelper.Create( nil );
end;

destructor TNetworkShareDownHandle.Destroy;
begin
  HeatBeatHelper.Free;

  inherited;
end;

function TNetworkShareDownHandle.getContinuesHandle: TShareDownContinuesHandle;
var
  ContinuesHandle : TNetworkShareDownContinuesHandle;
begin
  ContinuesHandle := TNetworkShareDownContinuesHandle.Create;
  ContinuesHandle.SetTcpSocket( TcpSocket );
  Result := ContinuesHandle;
end;

function TNetworkShareDownHandle.getIsScanCompleted: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

function TNetworkShareDownHandle.getRestoreFileHandle: TLocalDesFileScanHandle;
var
  NetworkFileRestoreScanHandle : TNetworkFileRestoreScanHandle;
begin
  NetworkFileRestoreScanHandle := TNetworkFileRestoreScanHandle.Create;
  NetworkFileRestoreScanHandle.SetTcpSocket( TcpSocket );
  Result := NetworkFileRestoreScanHandle;
end;

function TNetworkShareDownHandle.getRestoreFolderHandle: TLocalDesFolderScanHandle;
var
  NetworkFolderRestoreScanHandle : TNetworkFolderRestoreScanHandle;
begin
  HeatBeatHelper.TcpSocket := TcpSocket;

  NetworkFolderRestoreScanHandle := TNetworkFolderRestoreScanHandle.Create;
  NetworkFolderRestoreScanHandle.SetTcpSocket( TcpSocket );
  NetworkFolderRestoreScanHandle.SetHeatBeatHelper( HeatBeatHelper );
  Result := NetworkFolderRestoreScanHandle;
end;

function TNetworkShareDownHandle.getRestoreFromIsBackup: Boolean;
var
  ShareConnResult : string;
  IsShareExist : Boolean;
begin
    // ��ȡ���ʽ��
  ShareConnResult := MySocketUtil.RevData( TcpSocket );

    // ���� ��������
  ShareDownAppApi.SetIsConnect( SharePath, OwnerID, True );

    // ���� ��ȱ�ٿռ�
  ShareDownAppApi.SetIsLackSpace( SharePath, OwnerID, False );

    // ���� �Ƿ� �ɻָ�
  IsShareExist := ShareConnResult <> ShareConnResult_NotExist;
  ShareDownAppApi.SetIsExist( SharePath, OwnerID, IsShareExist );

    // �Ƿ񷵻�����
  Result := ShareConnResult = ShareConnResult_OK;
end;

function TNetworkShareDownHandle.getShareDownCancelReader: TShareDownCancelReader;
var
  NetworkShareDownCancelReader : TNetworkShareDownCancelReader;
begin
  NetworkShareDownCancelReader := TNetworkShareDownCancelReader.Create;
  NetworkShareDownCancelReader.SetTcpSocket( TcpSocket );
  Result := NetworkShareDownCancelReader;
end;

function TNetworkShareDownHandle.getShareDownFileHandle: TShareDownFileHandle;
var
  NetworkShareDownFileHandle : TNetworkShareDownFileHandle;
begin
  NetworkShareDownFileHandle := TNetworkShareDownFileHandle.Create;
  NetworkShareDownFileHandle.SetTcpSocket( TcpSocket );
  NetworkShareDownFileHandle.SetDownInfo( IsFile, ScanResultList.Count > 0 );
  Result := NetworkShareDownFileHandle;
end;

procedure TNetworkShareDownHandle.Update;
begin
  TcpSocket := MyShareDownConnectHandler.getShareConn( SharePath, OwnerID, ShareConnect_Down );
  if not Assigned( TcpSocket ) then // �޷�����
    Exit;

  inherited;

    // ����ѭ��
  TcpSocket.Sendln( FileReq_End );

    // ���ն˿�
  MyShareDownConnectHandler.AddLastConn( OwnerID, TcpSocket );
end;

{ TNetworkFolderRestoreScanHandle }

function TNetworkFolderRestoreScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
  if Result then
    HeatBeatHelper.CheckHeartBeat;
end;

procedure TNetworkFolderRestoreScanHandle.FindSourceFileInfo;
var
  NetworkFolderFindDeepHandle : TNetworkFolderFindDeepHandle;
begin
    // Ŀ¼
  if IsDesReaded then
    Exit;

  NetworkFolderFindDeepHandle := TNetworkFolderFindDeepHandle.Create;
  NetworkFolderFindDeepHandle.SetFolderPath( SourceFolderPath );
  NetworkFolderFindDeepHandle.SetScanFile( SourceFileHash );
  NetworkFolderFindDeepHandle.SetScanFolder( SourceFolderHash );
  NetworkFolderFindDeepHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindDeepHandle.Update;
  NetworkFolderFindDeepHandle.Free;
end;

function TNetworkFolderRestoreScanHandle.getScanHandle( SourceFolderName : string ): TFolderScanHandle;
var
  NetworkFolderRestoreScanHandle : TNetworkFolderRestoreScanHandle;
  ChildFolderInfo : TScanFolderInfo;
begin
  NetworkFolderRestoreScanHandle := TNetworkFolderRestoreScanHandle.Create;
  NetworkFolderRestoreScanHandle.SetItemInfo( SharePath, OwnerID );
  NetworkFolderRestoreScanHandle.SetSavePath( SavePath );
  NetworkFolderRestoreScanHandle.SetTcpSocket( TcpSocket );
  NetworkFolderRestoreScanHandle.SetHeatBeatHelper( HeatBeatHelper );
  Result := NetworkFolderRestoreScanHandle;

    // �����Ŀ¼��Ϣ
  ChildFolderInfo := SourceFolderHash[ SourceFolderName ];
  NetworkFolderRestoreScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // ��Ŀ¼δ��ȡ
  if not ChildFolderInfo.IsReaded then
    Exit;

    // ��Ŀ¼��Ϣ
  NetworkFolderRestoreScanHandle.SourceFolderHash.Free;
  NetworkFolderRestoreScanHandle.SourceFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // ���ļ���Ϣ
  NetworkFolderRestoreScanHandle.SourceFileHash.Free;
  NetworkFolderRestoreScanHandle.SourceFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

procedure TNetworkFolderRestoreScanHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

procedure TNetworkFolderRestoreScanHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TNetworkFileRestoreScanHandle }

function TNetworkFileRestoreScanHandle.FindSourceFileInfo: Boolean;
var
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create( SourceFilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  Result := NetworkFileFindHandle.getIsExist;
  SourceFileSize := NetworkFileFindHandle.getFileSize;
  SourceFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Update;
  NetworkFileFindHandle.Free;
end;

procedure TNetworkFileRestoreScanHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TNetworkRestoreResultHandle }

procedure TNetworkRestoreResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( SaveFilePath );
end;

procedure TNetworkRestoreResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( SaveFilePath );
end;

procedure TNetworkRestoreResultHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkRestoreResultHandle.SourceFileAdd;
var
  NetworkFileRestoreReceiveHandle : TNetworkFileRestoreReceiveHandle;
  IsShareDownCompleted : Boolean;
begin
    // ���������ļ�
  MySocketUtil.SendString( TcpSocket, FileReq_GetFile );
  MySocketUtil.SendString( TcpSocket, SourceFilePath );

    // �����ļ�
  NetworkFileRestoreReceiveHandle := TNetworkFileRestoreReceiveHandle.Create( SaveFilePath );
  NetworkFileRestoreReceiveHandle.SetItemInfo( SharePath, OwnerID );
  NetworkFileRestoreReceiveHandle.SetShareFilePath( SourceFilePath );
  NetworkFileRestoreReceiveHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  NetworkFileRestoreReceiveHandle.SetTcpSocket( TcpSocket );
  IsShareDownCompleted := NetworkFileRestoreReceiveHandle.Update;
  NetworkFileRestoreReceiveHandle.Free;

    // д��־
  if IsShareDownCompleted then
    LogShareDownCompleted
  else
    LogShareDownIncompleted;
end;

procedure TNetworkRestoreResultHandle.SourceFileGetZip;
var
  NetworkFileRestoreReceiveZipHandle : TNetworkFileRestoreReceiveZipHandle;
begin
    // ���������ļ�
  MySocketUtil.SendString( TcpSocket, FileReq_GetZip );
  MySocketUtil.SendString( TcpSocket, SourceFilePath );

    // �����ļ�
  NetworkFileRestoreReceiveZipHandle := TNetworkFileRestoreReceiveZipHandle.Create( SaveFilePath );
  NetworkFileRestoreReceiveZipHandle.SetItemInfo( SharePath, OwnerID );
  NetworkFileRestoreReceiveZipHandle.SetSavePath( SavePath );
  NetworkFileRestoreReceiveZipHandle.SetShareFilePath( SourceFilePath );
  NetworkFileRestoreReceiveZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  NetworkFileRestoreReceiveZipHandle.SetTcpSocket( TcpSocket );
  NetworkFileRestoreReceiveZipHandle.Update;
  NetworkFileRestoreReceiveZipHandle.Free;

    // ���ͽ�ѹ���
  if TcpSocket.Connected then
    MySocketUtil.SendData( TcpSocket, FileReq_New );

  ScanResultInfo.Free;
end;

procedure TNetworkRestoreResultHandle.SourceFolderAdd;
begin
  ForceDirectories( SaveFilePath );
end;


{ TNetworkFileRestoreReceiveHandle }

procedure TNetworkFileRestoreReceiveHandle.AddSpeedSpace(Space: Integer);
var
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
  MyRefreshSpeedHandler.AddDownload( Space );

    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( Space ) then
  begin
        // ���� ˢ�±����ٶ�
    ShareDownAppApi.SetSpeed( SharePath, OwnerID, RefreshSpeedInfo.LastSpeed );

      // ���»�ȡ���ƿռ���Ϣ
    IsLimited := RestoreSpeedInfoReadUtil.getIsLimit;
    LimitSpeed := RestoreSpeedInfoReadUtil.getLimitSpeed;
    RefreshSpeedInfo.SetLimitInfo( IsLimited, LimitSpeed );
  end;
end;

function TNetworkFileRestoreReceiveHandle.CheckNextReceive: Boolean;
begin
  Result := True;

    // 1 ���� ˢ��һ�ν���
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := ShareDownInfoReadUtil.ReadIsExist( SharePath, OwnerID );

  Result := Result and inherited and MyShareDownHandler.getIsRun;
end;

function TNetworkFileRestoreReceiveHandle.getLimitBlockSize: Int64;
begin
  if RestoreSpeedInfoReadUtil.getIsLimit then
    Result := RestoreSpeedInfoReadUtil.getLimitSpeed
  else
    Result := inherited;
end;


procedure TNetworkFileRestoreReceiveHandle.LostConnectError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := ShareFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  ShareDownErrorApi.LostConnectError( Params );

    // ���öϿ����ӣ���������
  ShareDownAppApi.SetIsLostConn( SharePath, OwnerID, True );
end;

procedure TNetworkFileRestoreReceiveHandle.MarkContinusRev;
var
  Params : TShareDownContinusAddParams;
begin
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := ShareFilePath;
  Params.FileSize := FileSize;
  Params.FileTime := FileTime;
  Params.Position := FilePos;
  ShareDownContinusApi.AddItem( Params );

    // ���öϿ����ӣ���������
  ShareDownAppApi.SetIsLostConn( SharePath, OwnerID, True );
end;


procedure TNetworkFileRestoreReceiveHandle.ReadFileError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := ShareFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  ShareDownErrorApi.ReadFileError( Params );
end;

procedure TNetworkFileRestoreReceiveHandle.ReceiveFileError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := ShareFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  ShareDownErrorApi.ReceiveFileError( Params );

    // ���öϿ����ӣ���������
  ShareDownAppApi.SetIsLostConn( SharePath, OwnerID, True );
end;

procedure TNetworkFileRestoreReceiveHandle.RefreshCompletedSpace;
begin
  ShareDownAppApi.AddCompletedSpace( SharePath, OwnerID, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TNetworkFileRestoreReceiveHandle.RevFileLackSpaceHandle;
begin
  ShareDownAppApi.SetIsLackSpace( SharePath, OwnerID, True );
end;

procedure TNetworkFileRestoreReceiveHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TNetworkFileRestoreReceiveHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

procedure TNetworkFileRestoreReceiveHandle.SetShareFilePath(
  _ShareFilePath: string);
begin
  ShareFilePath := _ShareFilePath;
end;

procedure TNetworkFileRestoreReceiveHandle.WriteFileError;
var
  Params : TShareDownErrorAddParams;
begin
      // ��ʾ����ʧ����Ϣ
  Params.SharePath := SharePath;
  Params.OwnerID := OwnerID;
  Params.FilePath := ShareFilePath;
  Params.FileSize := FileSize;
  Params.CompletedSize := FilePos;
  ShareDownErrorApi.WriteFileError( Params );
end;

{ TLocalRestoreExplorerHandle }

procedure TLocalShareFolderExplorerHandle.FindScanResult;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( SharePath );
  LocalFolderFindHandle.SetSleepCount( 0 );
  LocalFolderFindHandle.SetScanFile( ScanFileHash );
  LocalFolderFindHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindHandle.Update;
  LocalFolderFindHandle.Free;
end;

{ TRestoreHandleScan }

constructor TRestoreHandleScan.Create(_RestoreScanInfo: TShareDownJobInfo);
begin
  RestoreScanInfo := _RestoreScanInfo;
end;

procedure TRestoreHandleScan.LocalRestore;
var
  LocalRestoreHandle : TLocalRestoreHandle;
begin
  LocalRestoreHandle := TLocalRestoreHandle.Create;
  LocalRestoreHandle.SetRestoreScanInfo( RestoreScanInfo );
  LocalRestoreHandle.Update;
  LocalRestoreHandle.Free;
end;

procedure TRestoreHandleScan.LocalRestoreExplorer;
var
  LocalShareFolderExplorerHandle : TLocalShareFolderExplorerHandle;
begin
  LocalShareFolderExplorerHandle := TLocalShareFolderExplorerHandle.Create;
  LocalShareFolderExplorerHandle.SetShareScanInfo( RestoreScanInfo );
  LocalShareFolderExplorerHandle.Update;
  LocalShareFolderExplorerHandle.Free;
end;

procedure TRestoreHandleScan.NetworkRestore;
var
  NetworkShareDownHandle : TNetworkShareDownHandle;
begin
  NetworkShareDownHandle := TNetworkShareDownHandle.Create;
  NetworkShareDownHandle.SetRestoreScanInfo( RestoreScanInfo );
  NetworkShareDownHandle.Update;
  NetworkShareDownHandle.Free;
end;

procedure TRestoreHandleScan.NetworkRestoreExplorer;
var
  NetworkShareFolderExplorerHandle : TNetworkShareFolderExplorerBaseHandle;
begin
  NetworkShareFolderExplorerHandle := TNetworkShareFolderExplorerBaseHandle.Create;
  NetworkShareFolderExplorerHandle.SetShareScanInfo( RestoreScanInfo );
  NetworkShareFolderExplorerHandle.Update;
  NetworkShareFolderExplorerHandle.Free;
end;

procedure TRestoreHandleScan.NetworkRestorePreview;
var
  NetworkShareFilePreviewHandle : TNetworkShareFilePreviewHandle;
begin
  NetworkShareFilePreviewHandle := TNetworkShareFilePreviewHandle.Create;
  NetworkShareFilePreviewHandle.SetShareScanInfo( RestoreScanInfo );
  NetworkShareFilePreviewHandle.Update;
  NetworkShareFilePreviewHandle.Free;
end;

procedure TRestoreHandleScan.NetworkRestoreSearch;
var
  ShareFileSearchHandle : TShareFileSearchHandle;
begin
  ShareFileSearchHandle := TShareFileSearchHandle.Create;
  ShareFileSearchHandle.SetShareSearchScanInfo( RestoreScanInfo as TShareDownScanNetworSearchInfo );
  ShareFileSearchHandle.Update;
  ShareFileSearchHandle.Free;
end;

procedure TRestoreHandleScan.Update;
begin
  if RestoreScanInfo is TShareDownScanLocalInfo then
    LocalRestore
  else
  if RestoreScanInfo is TShareDownScanNetworkInfo then
    NetworkRestore
  else
  if RestoreScanInfo is TShareDownScanLocalExplorerInfo then
    LocalRestoreExplorer
  else
  if RestoreScanInfo is TShareDownScanNetworkExplorerInfo then
    NetworkRestoreExplorer
  else
  if RestoreScanInfo is TShareDownScanNetworkPreviewInfo then
    NetworkRestorePreview
  else
  if RestoreScanInfo is TShareDownScanNetworSearchInfo then
    NetworkRestoreSearch;
end;

{ TNetworkRestoreExplorerHandle }

procedure TNetworkShareFolderExplorerBaseHandle.FindScanResult;
var
  ShareConnResult : string;
begin
    // ����
  TcpSocket := MyShareDownConnectHandler.getShareConn( SharePath, OwnerID, ShareConnect_Explorer );
  if not Assigned( TcpSocket ) then
    Exit;

    // ��ȡ���ʽ��
  ShareConnResult := MySocketUtil.RevData( TcpSocket );

    // ���ӳɹ�
  if ShareConnResult = ShareConnResult_OK then
    ScanNetworkFolder;

    // ��������
  MySocketUtil.SendString( TcpSocket, FileReq_End );

    // ���ն˿�
  MyShareDownConnectHandler.AddLastConn( OwnerID, TcpSocket );
end;

procedure TNetworkShareFolderExplorerBaseHandle.ScanNetworkFolder;
var
  NetworkRestoreFindScanHandle : TNetworkFolderFindHandle;
begin
  NetworkRestoreFindScanHandle := TNetworkFolderFindHandle.Create;
  NetworkRestoreFindScanHandle.SetFolderPath( SharePath );
  NetworkRestoreFindScanHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreFindScanHandle.SetScanFile( ScanFileHash );
  NetworkRestoreFindScanHandle.SetScanFolder( ScanFolderHash );
  NetworkRestoreFindScanHandle.Update;
  NetworkRestoreFindScanHandle.Free;
end;

{ TRestoreHandle }

procedure TShareDownHandle.ContinuesHandle;
var
  ShareDownCancelReader : TShareDownCancelReader;
  ShareDownContinusList : TShareDownContinusList;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  i : Integer;
  ContinuesInfo : TShareDownContinusInfo;
  ShareDownContinuesHandle : TShareDownContinuesHandle;
begin
  DebugLock.Debug( 'ContinuesHandle' );

    // ȡ��������
  ShareDownCancelReader := getShareDownCancelReader;
  ShareDownCancelReader.SetItemInfo( SharePath, OwnerID );

    // ����
  ShareDownContinusList := ShareDownInfoReadUtil.ReadContinuesList( SharePath, OwnerID );
  if ShareDownContinusList.Count > 0 then
    ShareDownAppApi.SetStartRestore( SharePath, OwnerID );
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  for i := 0 to ShareDownContinusList.Count - 1 do
  begin
    if not ShareDownCancelReader.getIsRun then
      Break;

    ContinuesInfo := ShareDownContinusList[i];
    ShareDownContinuesHandle := getContinuesHandle;
    ShareDownContinuesHandle.SetSourceFilePath( ContinuesInfo.FilePath );
    ShareDownContinuesHandle.SetSpaceInfo( ContinuesInfo.FileSize, ContinuesInfo.Position );
    ShareDownContinuesHandle.SetFileTime( ContinuesInfo.FileTime );
    ShareDownContinuesHandle.SetItemInfo( SharePath, OwnerID );
    ShareDownContinuesHandle.SetSavePath( SavePath );
    ShareDownContinuesHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
    ShareDownContinuesHandle.Update;
    ShareDownContinuesHandle.Free;
  end;
  RefreshSpeedInfo.Free;
  ShareDownContinusList.Free;
  ShareDownCancelReader.Free;
end;


constructor TShareDownHandle.Create;
begin
  ScanResultList := TScanResultList.Create;
  FreeLimitType := '';
end;

destructor TShareDownHandle.Destroy;
begin
  ScanResultList.Free;
  inherited;
end;

procedure TShareDownHandle.FreeLimitShowCheck;
begin
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

  if FreeLimitType = FreeLimitType_FileSize then
    RegisterLimitApi.ShowShareDownSizeError
  else
  if FreeLimitType = FreeLimitType_FileCount then
    RegisterLimitApi.ShowShareDownCountError;
end;

function TShareDownHandle.getIsRestoreCompleted: Boolean;
begin
  Result := ShareDownInfoReadUtil.ReadIsCompleted( SharePath, OwnerID );
end;

function TShareDownHandle.getIsScanCompleted: Boolean;
begin
  Result := MyShareDownHandler.getIsRun;
end;

function TShareDownHandle.getSavePathIsBackup: Boolean;
var
  ParentPath : string;
begin
  Result := False;

    // ���� ��ȱС�ռ�
  ShareDownAppApi.SetIsLackSpace( SharePath, OwnerID, False );

    // ��ȡ����·��
  SavePath := ShareDownInfoReadUtil.ReadSavePath( SharePath, OwnerID );
  if SavePath = '' then // ��ȡ��
    Exit;

    // ����Ŀ¼
  if IsFile then
    ParentPath := ExtractFileDir( SavePath )
  else
    ParentPath := SavePath;
  ForceDirectories( ParentPath );

    // ����·���Ƿ��д
  Result := MyFilePath.getIsModify( ParentPath );
  ShareDownAppApi.SetIsWrite( SharePath, OwnerID, Result );
end;

function TShareDownHandle.getShareDownCancelReader: TShareDownCancelReader;
begin
  Result := TShareDownCancelReader.Create;
end;

procedure TShareDownHandle.ResetRestorePathSpace;
var
  Params : TShareDownSetSpaceParams;
begin
  Params.RestorePath := SharePath;
  Params.OwnerPcID := OwnerID;
  Params.FileCount := TotalCount;
  Params.FileSize := TotalSize;
  Params.CompletedSize := TotalCompletedSize;
  ShareDownAppApi.SetSpaceInfo( Params );
end;


procedure TShareDownHandle.ResetStartRestoreFile;
begin
  ShareDownAppApi.SetStartRestore( SharePath, OwnerID );
end;

procedure TShareDownHandle.RestoreFileHandle;
var
  ShareDownFreeLimitReader : TShareDownFreeLimitReader;
  ShareDownCancelReader : TShareDownCancelReader;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  i : Integer;
  ScanTime : TDateTime;
  ShareDownFileHandle : TShareDownFileHandle;
begin
  DebugLock.Debug( 'RestoreFileHandle' );

    // ��Ѱ�����
  ShareDownFreeLimitReader := TShareDownFreeLimitReader.Create;
  ShareDownFreeLimitReader.SetFileCount( TotalCompletedCount );
  ShareDownFreeLimitReader.IniHandle;

    // ����ȡ�������
  ShareDownCancelReader := getShareDownCancelReader;
  ShareDownCancelReader.SetItemInfo( SharePath, OwnerID );

    // �ٶȿ�����
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;

    // ���ش�����
  ShareDownFileHandle := getShareDownFileHandle;
  ShareDownFileHandle.SetItemInfo( SharePath, OwnerID );
  ShareDownFileHandle.SetSavePath( SavePath );
  ShareDownFileHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ShareDownFileHandle.IniHandle;

  for i := 0 to ScanResultList.Count - 1 do
  begin
      // ȡ������
    if not ShareDownCancelReader.getIsRun then
      Break;
    if not ShareDownFreeLimitReader.AddResult( ScanResultList[i] ) then
    begin
      FreeLimitType := ShareDownFreeLimitReader.getFreeLimitType;
      if FreeLimitType = FreeLimitType_FileCount then // �����ļ���
        Break;
      Continue;
    end;

    ShareDownFileHandle.Handle( ScanResultList[i] );
  end;

    // ����ˢ��
  if ( i = ScanResultList.Count ) or ShareDownCancelReader.getIsRun then
    ShareDownFileHandle.LastCompleted;

  ShareDownFileHandle.Free;
  RefreshSpeedInfo.Free;
  ShareDownCancelReader.Free;
  ShareDownFreeLimitReader.Free;
end;

procedure TShareDownHandle.ScanFileHandle;
var
  LocalDesFileScanHandle : TLocalDesFileScanHandle;
begin
  LocalDesFileScanHandle := getRestoreFileHandle;
  LocalDesFileScanHandle.SetSourceFilePath( SharePath );
  LocalDesFileScanHandle.SetSavePath( SavePath );
  LocalDesFileScanHandle.SetResultList( ScanResultList );
  LocalDesFileScanHandle.Update;
  TotalCount := 1;
  TotalSize := LocalDesFileScanHandle.SourceFileSize;
  TotalCompletedCount := LocalDesFileScanHandle.CompletedCount;
  TotalCompletedSize := LocalDesFileScanHandle.CompletedSize;
  LocalDesFileScanHandle.Free;
end;

procedure TShareDownHandle.ScanFolderHandle;
var
  LocalDesFolderScanHandle : TLocalDesFolderScanHandle;
begin
  LocalDesFolderScanHandle := getRestoreFolderHandle;
  LocalDesFolderScanHandle.SetSourceFolderPath( SharePath );
  LocalDesFolderScanHandle.SetItemInfo( SharePath, OwnerID );
  LocalDesFolderScanHandle.SetSavePath( SavePath );
  LocalDesFolderScanHandle.SetResultList( ScanResultList );
  LocalDesFolderScanHandle.SetIsSupportDeleted( False );
  LocalDesFolderScanHandle.Update;
  TotalCount := LocalDesFolderScanHandle.FileCount;
  TotalSize := LocalDesFolderScanHandle.FileSize;
  TotalCompletedCount := LocalDesFolderScanHandle.CompletedCount;
  TotalCompletedSize := LocalDesFolderScanHandle.CompletedSize;
  LocalDesFolderScanHandle.Free;
end;


procedure TShareDownHandle.ScanPathHandle;
begin
  DebugLock.Debug( 'ScanPathHandle' );

    // ���ڷ���
  ShareDownAppApi.SetAnalyzeRestore( SharePath, OwnerID );

  if IsFile then
    ScanFileHandle
  else
    ScanFolderHandle;
end;

procedure TShareDownHandle.SetRestoreCompleted;
begin
  ShareDownAppApi.RestoreCompleted( SharePath, OwnerID );
end;

procedure TShareDownHandle.SetRestoreScanInfo(_RestoreScanInfo: TShareDownJobInfo);
begin
  RestoreScanInfo := _RestoreScanInfo;
  SharePath := RestoreScanInfo.SharePath;
  OwnerID := RestoreScanInfo.OwnerID;
  IsFile := RestoreScanInfo.IsFile;
end;

procedure TShareDownHandle.SetRestoreStop;
begin
  ShareDownAppApi.RestoreStop( SharePath, OwnerID );
end;

procedure TShareDownHandle.Update;
begin
    // ֹͣ
  if not MyShareDownHandler.getIsRun then
    Exit;

    // ����Դ ��������
  if not getRestoreFromIsBackup then
    Exit;

    // ����Ŀ�� ��������
  if not getSavePathIsBackup then
    Exit;

    // �����һ�εĴ�����Ϣ
  ShareDownErrorApi.ClearItem( SharePath, OwnerID );

    // ��������
  ContinuesHandle;

    // ɨ����Ҫ�ָ����ļ�
  ScanPathHandle;

    // ɨ�����
  if getIsScanCompleted then
    ResetRestorePathSpace; // ����ָ��ռ���Ϣ

    // �ָ�ɨ����
  ResetStartRestoreFile;
  RestoreFileHandle;

    // ���ûָ����
  if getIsScanCompleted and getIsRestoreCompleted then
    SetRestoreCompleted;

    // ����Ƿ��ܵ���Ѱ�����
  FreeLimitShowCheck;
end;

{ TRestoreResultHandle }

procedure TShareDownResultHandle.LogShareDownCompleted;
var
  Prams : TShareDownAddLogParams;
begin
  Prams.SharePath := SharePath;
  Prams.OwnerPcID := OwnerID;
  Prams.FilePath := SourceFilePath;
  Prams.SendTime := Now;
  ShareDownLogApi.AddCompleted( Prams );
end;

procedure TShareDownResultHandle.LogShareDownIncompleted;
var
  Prams : TShareDownAddLogParams;
begin
  Prams.SharePath := SharePath;
  Prams.OwnerPcID := OwnerID;
  Prams.FilePath := SourceFilePath;
  ShareDownLogApi.AddIncompleted( Prams );
end;

procedure TShareDownResultHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownResultHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareDownResultHandle.SetScanResultInfo(
  _ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  SourceFilePath := ScanResultInfo.SourceFilePath;
end;

procedure TShareDownResultHandle.SetSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareDownResultHandle.Update;
begin
  try
    DebugLock.Debug( ScanResultInfo.ClassName + ' : ' + ScanResultInfo.SourceFilePath );

      // �����·����Ϣ
    SaveFilePath := MyFilePath.getReceivePath( SharePath, SourceFilePath, SavePath );

      // ���ݽ������
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
    if ScanResultInfo is TScanResultGetZipInfo then
      SourceFileGetZip;
  except
  end;
end;

{ TRestoreExplorerHandle }

constructor TShareFolderExplorerHandle.Create;
begin
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
end;

destructor TShareFolderExplorerHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

procedure TShareFolderExplorerHandle.SetShareScanInfo(
  _ShareScanInfo: TShareDownJobInfo);
begin
  ShareScanInfo := _ShareScanInfo;
  SharePath := ShareScanInfo.SharePath;
  OwnerID := ShareScanInfo.OwnerID;
  IsSearch := ( ShareScanInfo as TShareDownScanExplorerInfo ).IsSearch;
end;

procedure TShareFolderExplorerHandle.ShowScanResult;
var
  p : TScanFilePair;
  pf : TScanFolderPair;
  ParentPath, FolderPath : string;
  Params : TExplorerResultParams;
begin
  ParentPath := MyFilePath.getPath( SharePath );

  Params.IsFile := False;
  for pf in ScanFolderHash do
  begin
    Params.FilePath := ParentPath + pf.Value.FolderName;
    if IsSearch then
      ShareSearchAppApi.ShowExplorer( Params )
    else
      ShareExplorerAppApi.ShowFolderResult( Params );
  end;

  Params.IsFile := True;
  for p in ScanFileHash do
  begin
    Params.FilePath := ParentPath + p.Value.FileName;
    Params.FileSize := p.Value.FileSize;
    Params.FileTime := p.Value.FileTime;
    if IsSearch then
      ShareSearchAppApi.ShowExplorer( Params )
    else
      ShareExplorerAppApi.ShowFolderResult( Params );
  end;
end;

procedure TShareFolderExplorerHandle.Update;
begin
  FindScanResult;
  ShowScanResult;
end;

{ TShareDownContinuesHandle }

function TShareDownContinuesHandle.getIsDesChange: Boolean;
begin
  Result := MyFileInfo.getFileSize( SaveFilePath ) <> Position;
end;

procedure TShareDownContinuesHandle.RemoveContinusInfo;
begin
  ShareDownContinusApi.RemoveItem( SharePath, OwnerID, FilePath );
end;

procedure TShareDownContinuesHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownContinuesHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownContinuesHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareDownContinuesHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareDownContinuesHandle.SetSourceFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownContinuesHandle.SetSpaceInfo(_FileSize, _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TShareDownContinuesHandle.Update;
begin
  SaveFilePath := MyFilePath.getReceivePath( SharePath, FilePath, SavePath );

    // Դ�ļ������仯, Ŀ���ļ������仯
  if getIsSourceChange or getIsDesChange then
  begin
    RemoveContinusInfo; // ɾ��������¼
    Exit;
  end;

    // �ļ�����
  if FileCopy then
    RemoveContinusInfo;  // ɾ��������¼
end;

{ TLocalShareDownContinuesHandle }

function TLocalShareDownContinuesHandle.FileCopy: Boolean;
var
  ShareFileCopyHandle : TShareFileCopyHandle;
begin
  ShareFileCopyHandle := TShareFileCopyHandle.Create( FilePath, SaveFilePath );
  ShareFileCopyHandle.SetPosition( Position );
  ShareFileCopyHandle.SetItemInfo( SharePath, OwnerID );
  ShareFileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  Result := ShareFileCopyHandle.Update;
  ShareFileCopyHandle.Free;
end;

function TLocalShareDownContinuesHandle.getIsSourceChange: Boolean;
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

{ TNetworkShareDownContinuesHandle }

function TNetworkShareDownContinuesHandle.FileCopy: Boolean;
var
  NetworkFileRestoreReceiveHandle : TNetworkFileRestoreReceiveHandle;
begin
    // ����������Ϣ
  MySocketUtil.SendString( TcpSocket, FileReq_ContinuesGet );
  MySocketUtil.SendString( TcpSocket, FilePath );
  MySocketUtil.SendString( TcpSocket, IntToStr( Position ) );

    // �����ļ�
  NetworkFileRestoreReceiveHandle := TNetworkFileRestoreReceiveHandle.Create( SaveFilePath );
  NetworkFileRestoreReceiveHandle.SetItemInfo( SharePath, OwnerID );
  NetworkFileRestoreReceiveHandle.SetShareFilePath( FilePath );
  NetworkFileRestoreReceiveHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  NetworkFileRestoreReceiveHandle.SetTcpSocket( TcpSocket );
  NetworkFileRestoreReceiveHandle.Update;
  NetworkFileRestoreReceiveHandle.Free;
end;

function TNetworkShareDownContinuesHandle.getIsSourceChange: Boolean;
var
  SourceIsExist : Boolean;
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  Result := True;

  NetworkFileFindHandle := TNetworkFileFindHandle.Create( FilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  SourceIsExist := NetworkFileFindHandle.getIsExist;
  SourceFileSize := NetworkFileFindHandle.getFileSize;
  SourceFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Free;

  if not SourceIsExist then
    Exit;

  if SourceFileSize <> FileSize then
    Exit;

  if not MyDatetime.Equals( FileTime, SourceFileTime )  then
    Exit;

  Result := False;
end;

procedure TNetworkShareDownContinuesHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TShareDownHandleThread }

function TShareDownHandleThread.getHandler: TMyShareDownBaseHandler;
begin
  Result := MyShareDownHandler;
end;

procedure TShareDownHandleThread.StartScanHandle;
begin
    // ��ʼ�ָ�
  ShareDownAppApi.StartRestore;

  MyShareDownHandler.IsDownRun := True;
end;

procedure TShareDownHandleThread.StopScan(RestoreScanInfo: TShareDownJobInfo);
begin
  ShareDownAppApi.RestoreStop( RestoreScanInfo.SharePath, RestoreScanInfo.OwnerID );

  inherited;
end;

procedure TShareDownHandleThread.StopScanHandle;
begin
    // ֹͣ�ָ�
  if not MyShareDownHandler.IsDownRun then
    ShareDownAppApi.PauseRestore
  else
    ShareDownAppApi.StopRestore;
end;

{ TShareDownExploererThread }

function TShareDownExplorerThread.getHandler: TMyShareDownBaseHandler;
begin
  Result := MyShareExplorerHandler;
end;

procedure TShareDownExplorerThread.StartScanHandle;
begin
  ShareExplorerAppApi.StartExplorer;
end;

procedure TShareDownExplorerThread.StopScanHandle;
begin
  ShareExplorerAppApi.StopExplorer;
end;

{ TMyShareExplorerHandler }

function TMyShareExplorerHandler.CreateThread: TShareDownHandleBaseThread;
begin
  Result := TShareDownExplorerThread.Create;
end;

{ TShareFilePreviewHandle }

procedure TShareFilePreviewHandle.SetShareScanInfo(
  _ShareScanInfo: TShareDownJobInfo);
begin
  ShareScanInfo := _ShareScanInfo;
  SharePath := ShareScanInfo.SharePath;
  OwnerID := ShareScanInfo.OwnerID;
end;

{ TNetworkShareFilePreviewHandle }

procedure TNetworkShareFilePreviewHandle.Preview;
begin
  if ShareScanInfo is TShareDownScanNetworkPreviewPictureInfo then
    PreviewPicture
  else
  if ShareScanInfo is TShareDownScanNetworkPreviewWordInfo then
    PreviewWord
  else
  if ShareScanInfo is TShareDownScanNetworkPreviewExcelInfo then
    PreviewExcel
  else
  if ShareScanInfo is TShareDownScanNetworkPreviewZipInfo then
    PreviewZip
  else
  if ShareScanInfo is TShareDownScanNetworkPreviewExeInfo then
    PreviewExe
  else
  if ShareScanInfo is TShareDownScanNetworkPreviewMusicInfo then
    PreviewMusic
  else
    PreviewText;
end;

procedure TNetworkShareFilePreviewHandle.PreviewExcel;
var
  NetworkShareFilePreviewReceiveHandle : TNetworkShareFilePreviewReceiveHandle;
  ExcelText, RevStr : string;
  RestoreFilePreviewExcelFace : TRestoreFilePreviewExcelFace;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewExcel );
  MySocketUtil.SendData( TcpSocket, SharePath );

    // ����word�ı�
  ExcelText := MySocketUtil.RevData( TcpSocket );

    // ��ʾ
  RestoreFilePreviewExcelFace := TRestoreFilePreviewExcelFace.Create;
  RestoreFilePreviewExcelFace.SetFilePath( SharePath );
  RestoreFilePreviewExcelFace.SetExcelText( ExcelText );
  RestoreFilePreviewExcelFace.AddChange;
end;


procedure TNetworkShareFilePreviewHandle.PreviewExe;
var
  NetworkShareFilePreviewReceiveHandle : TNetworkShareFilePreviewReceiveHandle;
  ExeText : string;
  NetworkShareFilePreviewExeReceiveHandle : TNetworkShareFilePreviewExeReceiveHandle;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewExe );
  MySocketUtil.SendData( TcpSocket, SharePath );

    // ���� Exe ������Ϣ
  ExeText := MySocketUtil.RevData( TcpSocket );

    // ���� Exe ͼ��
  NetworkShareFilePreviewExeReceiveHandle := TNetworkShareFilePreviewExeReceiveHandle.Create( SharePath );
  NetworkShareFilePreviewExeReceiveHandle.SetExeText( ExeText );
  NetworkShareFilePreviewExeReceiveHandle.SetTcpSocket( TcpSocket );
  NetworkShareFilePreviewExeReceiveHandle.Update;
  NetworkShareFilePreviewExeReceiveHandle.Free;
end;

procedure TNetworkShareFilePreviewHandle.PreviewMusic;
var
  NetworkShareFilePreviewReceiveHandle : TNetworkShareFilePreviewReceiveHandle;
  MusicText : string;
  RestoreFilePreviewMusicFace : TRestoreFilePreviewMusicFace;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewMusic );
  MySocketUtil.SendData( TcpSocket, SharePath );

    // ���� Exe ������Ϣ
  MusicText := MySocketUtil.RevData( TcpSocket );

  RestoreFilePreviewMusicFace := TRestoreFilePreviewMusicFace.Create;
  RestoreFilePreviewMusicFace.SetMusicText( MusicText );
  RestoreFilePreviewMusicFace.SetFilePath( SharePath );
  RestoreFilePreviewMusicFace.AddChange;
end;

procedure TNetworkShareFilePreviewHandle.PreviewPicture;
var
  NetworkShareFilePreviewPictureReceiveHandle : TNetworkShareFilePreviewPictureReceiveHandle;
  ShareDownScanNetworkPreviewInfo : TShareDownScanNetworkPreviewPictureInfo;
begin
  ShareDownScanNetworkPreviewInfo := ShareScanInfo as TShareDownScanNetworkPreviewPictureInfo;

    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewPicture );
  MySocketUtil.SendData( TcpSocket, SharePath );
  MySocketUtil.SendData( TcpSocket, ShareDownScanNetworkPreviewInfo.PreviewWidth );
  MySocketUtil.SendData( TcpSocket, ShareDownScanNetworkPreviewInfo.PreviewHeight );

  NetworkShareFilePreviewPictureReceiveHandle := TNetworkShareFilePreviewPictureReceiveHandle.Create( SharePath );
  NetworkShareFilePreviewPictureReceiveHandle.SetTcpSocket( TcpSocket );
  NetworkShareFilePreviewPictureReceiveHandle.Update;
  NetworkShareFilePreviewPictureReceiveHandle.Free;
end;


procedure TNetworkShareFilePreviewHandle.PreviewText;
var
  NetworkShareFilePreviewTextReceiveHandle : TNetworkShareFilePreviewTextReceiveHandle;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewText );
  MySocketUtil.SendData( TcpSocket, SharePath );

  NetworkShareFilePreviewTextReceiveHandle := TNetworkShareFilePreviewTextReceiveHandle.Create( SharePath );
  NetworkShareFilePreviewTextReceiveHandle.SetTcpSocket( TcpSocket );
  NetworkShareFilePreviewTextReceiveHandle.Update;
  NetworkShareFilePreviewTextReceiveHandle.Free;
end;


procedure TNetworkShareFilePreviewHandle.PreviewWord;
var
  NetworkShareFilePreviewReceiveHandle : TNetworkShareFilePreviewReceiveHandle;
  DocText, RevStr : string;
  RestoreFilePreviewWordFace : TRestoreFilePreviewWordFace;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewWord );
  MySocketUtil.SendData( TcpSocket, SharePath );

    // ����word�ı�
  DocText := '';
  while True do
  begin
    RevStr := MySocketUtil.RevData( TcpSocket );
    if ( RevStr = '' ) or ( RevStr = Split_Word ) then
      Break;
    DocText := DocText + RevStr;
  end;

    // ��ʾ
  RestoreFilePreviewWordFace := TRestoreFilePreviewWordFace.Create;
  RestoreFilePreviewWordFace.SetFilePath( SharePath );
  RestoreFilePreviewWordFace.SetWordText( DocText );
  RestoreFilePreviewWordFace.AddChange;
end;

procedure TNetworkShareFilePreviewHandle.PreviewZip;
var
  NetworkShareFilePreviewReceiveHandle : TNetworkShareFilePreviewReceiveHandle;
  ZipText : string;
  RestoreFilePreviewZipFace : TRestoreFilePreviewZipFace;
begin
    // ���������ļ�
  MySocketUtil.SendData( TcpSocket, FileReq_PreviewZip );
  MySocketUtil.SendData( TcpSocket, SharePath );

    // ����word�ı�
  ZipText := MySocketUtil.RevData( TcpSocket );

    // ��ʾ
  RestoreFilePreviewZipFace := TRestoreFilePreviewZipFace.Create;
  RestoreFilePreviewZipFace.SetFilePath( SharePath );
  RestoreFilePreviewZipFace.SetZipText( ZipText );
  RestoreFilePreviewZipFace.AddChange;
end;

procedure TNetworkShareFilePreviewHandle.Update;
var
  ShareConnResult : string;
begin
  TcpSocket := MyShareDownConnectHandler.getShareConn( SharePath, OwnerID, ShareConnect_Preview );
  if not Assigned( TcpSocket ) then
    Exit;

    // ��ȡ���ʽ��
  ShareConnResult := MySocketUtil.RevData( TcpSocket );

    // ���ӳɹ�
  if ShareConnResult = ShareConnResult_OK then
    Preview;

    // ��������
  MySocketUtil.SendData( TcpSocket, FileReq_End );

      // ���ն˿�
  MyShareDownConnectHandler.AddLastConn( OwnerID, TcpSocket );
end;

{ TNetworkShareFilePreviewReceiveHandle }

function TNetworkShareFilePreviewReceiveHandle.CreateWriteStream: Boolean;
var
  IsSuccessRead : Boolean;
begin
  IsSuccessRead := MySocketUtil.RevBoolData( TcpSocket );
  Result := IsSuccessRead;
  if not Result then
    Exit;

  WriteStream := TMemoryStream.Create;
  PreviewStream := WriteStream;
end;

function TNetworkShareFilePreviewReceiveHandle.getIsEnoughSapce: Boolean;
begin
  Result := True;
end;

procedure TNetworkShareFilePreviewReceiveHandle.LastRefreshCompletedSpace;
begin
  inherited;

  try
    TThread.Synchronize( MySharePreviewHandler.ShareDownBaseHandleThread, ShowPreviewFile );
  except
  end;
end;


procedure TNetworkShareFilePreviewReceiveHandle.ResetFileTime;
begin

end;

{ TShareDownPreviewThread }

function TShareDownPreviewThread.getHandler: TMyShareDownBaseHandler;
begin
  Result := MySharePreviewHandler;
end;

procedure TShareDownPreviewThread.StartScanHandle;
begin
  inherited;
  SharePreviewApi.StartPreview;
end;

procedure TShareDownPreviewThread.StopScanHandle;
begin
  inherited;
  SharePreviewApi.StopPreview;
end;

{ TMyShareDownBaseHandler }

procedure TMyShareDownBaseHandler.AddShareDownJob(
  ShareDownJobInfo: TShareDownJobInfo);
begin
  if not IsRun then
    Exit;

  ThreadLock.Enter;

  ShareDownScanList.Add( ShareDownJobInfo );

  if not IsCreateThread then
  begin
    IsCreateThread := True;
    ShareDownBaseHandleThread := CreateThread;
    ShareDownBaseHandleThread.Resume;
  end;

  ThreadLock.Leave;
end;

constructor TMyShareDownBaseHandler.Create;
begin
  IsRun := True;

  ThreadLock := TCriticalSection.Create;
  ShareDownScanList := TShareDownJobList.Create;
  ShareDownScanList.OwnsObjects := False;
  IsCreateThread := False;
end;

destructor TMyShareDownBaseHandler.Destroy;
begin
  ShareDownScanList.OwnsObjects := True;
  ShareDownScanList.Free;
  ThreadLock.Free;

  inherited;
end;

function TMyShareDownBaseHandler.getShareDownJob: TShareDownJobInfo;
begin
  ThreadLock.Enter;
  if ShareDownScanList.Count > 0 then
  begin
    Result := ShareDownScanList[ 0 ];
    ShareDownScanList.Delete( 0 );
  end
  else
  begin
    Result := nil;
    IsCreateThread := False;
  end;
  ThreadLock.Leave;
end;

procedure TMyShareDownBaseHandler.StopRun;
begin
  IsRun := False;

  while IsCreateThread do
    Sleep( 100 );
end;

{ TMySharePreviewHandler }

function TMySharePreviewHandler.CreateThread: TShareDownHandleBaseThread;
begin
  Result := TShareDownPreviewThread.Create;
end;

{ TShareDownScanNetworkPreviewInfo }

procedure TShareDownScanNetworkPreviewPictureInfo.SetPreviewSize(_PreviewWidth,
  _PreviewHeight: Integer);
begin
  PreviewWidth := _PreviewWidth;
  PreviewHeight := _PreviewHeight;
end;

{ TNetworkShareFilePreviewPictureReceiveHandle }

procedure TNetworkShareFilePreviewPictureReceiveHandle.ShowPreviewFile;
var
  RestoreFilePreviewPictureFace : TRestoreFilePreviewPictureFace;
begin
  RestoreFilePreviewPictureFace := TRestoreFilePreviewPictureFace.Create;
  RestoreFilePreviewPictureFace.SetFilePath( ReceiveFilePath );
  RestoreFilePreviewPictureFace.SetFileStream( PreviewStream );
  RestoreFilePreviewPictureFace.Update;
  RestoreFilePreviewPictureFace.Free;
end;

{ TNetworkShareFilePreviewTextReceiveHandle }

procedure TNetworkShareFilePreviewTextReceiveHandle.ShowPreviewFile;
var
  RestoreFilePreviewTextFace : TRestoreFilePreviewTextFace;
begin
  RestoreFilePreviewTextFace := TRestoreFilePreviewTextFace.Create;
  RestoreFilePreviewTextFace.SetFilePath( ReceiveFilePath );
  RestoreFilePreviewTextFace.SetFileStream( PreviewStream );
  RestoreFilePreviewTextFace.Update;
  RestoreFilePreviewTextFace.Free;
end;

{ TNetworkShareFilePreviewExeReceiveHandle }

function TNetworkShareFilePreviewExeReceiveHandle.CreateWriteStream: Boolean;
begin
  Result := inherited;
  if Result then
    Exit;

  try
    TThread.Synchronize( MySharePreviewHandler.ShareDownBaseHandleThread, ShowPreviewFile );
  except
  end;
end;

procedure TNetworkShareFilePreviewExeReceiveHandle.SetExeText(_ExeText: string);
begin
  ExeText := _ExeText;
end;

procedure TNetworkShareFilePreviewExeReceiveHandle.ShowPreviewFile;
var
  RestoreFilePreviewExeFace : TRestoreFilePreviewExeFace;
begin
  RestoreFilePreviewExeFace := TRestoreFilePreviewExeFace.Create;
  RestoreFilePreviewExeFace.SetFilePath( ReceiveFilePath );
  RestoreFilePreviewExeFace.SetExeText( ExeText );
  RestoreFilePreviewExeFace.SetIconStream( PreviewStream );
  RestoreFilePreviewExeFace.Update;
  RestoreFilePreviewExeFace.Free;
end;

{ TMyShareSearchHandler }

function TMyShareSearchHandler.CreateThread: TShareDownHandleBaseThread;
begin
  Result := TShareDownSearchThread.Create;
end;

function TMyShareSearchHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsSearchRun;
end;

{ TShareDownSearchThread }

function TShareDownSearchThread.getHandler: TMyShareDownBaseHandler;
begin
  Result := MyShareSearchHandler;
end;

procedure TShareDownSearchThread.StartScanHandle;
begin
  inherited;
  MyShareSearchHandler.IsSearchRun := True;
  ShareSearchAppApi.StartSearch;
end;

procedure TShareDownSearchThread.StopScanHandle;
begin
  inherited;
  MyShareSearchHandler.IsSearchRun := False;
  ShareSearchAppApi.StopSearch;
end;

{ TNetworkShareSearchHandle }

function TNetworkShareSearchHandle.getIsStop: Boolean;
begin
  Result := not MyShareSearchHandler.getIsRun;
end;

procedure TNetworkShareSearchHandle.HandleResultHash;
var
  Params : TSearchResultParams;
  p : TScanFilePair;
  pf : TScanFolderPair;
  ParentPath : string;
begin
  ParentPath := MyFilePath.getPath( SharePath );

    // ��ʾ�ļ��������
  Params.IsFile := True;
  for p in ResultFileHash do
  begin
    Params.FilePath :=  ParentPath + p.Value.FileName;
    Params.FileSize := p.Value.FileSize;
    Params.FileTime := p.Value.FileTime;
    ShareSearchAppApi.ShowResult( Params );
  end;

    // ��ʾĿ¼�������
  Params.IsFile := False;
  for pf in ResultFolderHash do
  begin
    Params.FilePath := ParentPath + pf.Value.FolderName;
    ShareSearchAppApi.ShowResult( Params );
  end;
end;

procedure TNetworkShareSearchHandle.SetSharePath(_SharePath: string);
begin
  SharePath := _SharePath;
end;

{ TShareDownSearchNetworkExplorerInfo }

procedure TShareDownScanNetworSearchInfo.SetSearchName(
  _SearchName: string);
begin
  SearchName := _SearchName;
end;

{ TShareFileSearchHandle }

procedure TShareFileSearchHandle.SearchFolder;
var
  NetworkShareSearchHandle : TNetworkShareSearchHandle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_SearchFolder );
  MySocketUtil.SendData( TcpSocket, SharePath );
  MySocketUtil.SendData( TcpSocket, SearchName );

  NetworkShareSearchHandle := TNetworkShareSearchHandle.Create;
  NetworkShareSearchHandle.SetSharePath( SharePath );
  NetworkShareSearchHandle.SetTcpSocket( TcpSocket );
  NetworkShareSearchHandle.Update;
  NetworkShareSearchHandle.Free;
end;

procedure TShareFileSearchHandle.SetShareSearchScanInfo(
  _ShareSearchScanInfo: TShareDownScanNetworSearchInfo);
begin
  ShareSearchScanInfo := _ShareSearchScanInfo;
  SharePath := ShareSearchScanInfo.SharePath;
  OwnerID := ShareSearchScanInfo.OwnerID;
  SearchName := ShareSearchScanInfo.SearchName;
end;

procedure TShareFileSearchHandle.Update;
var
  ShareConnResult : string;
begin
  TcpSocket := MyShareDownConnectHandler.getShareConn( SharePath, OwnerID, ShareConnect_Search );
  if not Assigned( TcpSocket ) then
    Exit;

    // ��ȡ���ʽ��
  ShareConnResult := MySocketUtil.RevData( TcpSocket );

    // ���ӳɹ�
  if ShareConnResult = ShareConnResult_OK then
    SearchFolder;

    // ��������
  MySocketUtil.SendString( TcpSocket, FileReq_End );

    // ���ն˿�
  MyShareDownConnectHandler.AddLastConn( OwnerID, TcpSocket );
end;

{ TShareDownScanExplorerInfo }

procedure TShareDownScanExplorerInfo.SetIsSearch(_IsSearch: Boolean);
begin
  IsSearch := _IsSearch;
end;

{ TMyShareDownConnectHandler }

procedure TMyShareDownConnectHandler.AddBackConn(TcpSocket: TCustomIpClient);
begin
  BackConnSocket := TcpSocket;
  IsConnSuccess := True;
end;

procedure TMyShareDownConnectHandler.AddLastConn(LastOwnerID : string;
  TcpSocket: TCustomIpClient);
var
  ShareDownSocketInfo : TShareDownSocketInfo;
begin
    // �����ѶϿ�
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

  ConnectLock.Enter;
  try
      // ��󱣴�������Ϊ 10
    if ShareDownSocketList.Count >= 10 then
    begin
      ShareDownSocketList[0].CloseSocket;
      ShareDownSocketList.Delete( 0 );
    end;
    ShareDownSocketInfo := TShareDownSocketInfo.Create( LastOwnerID );
    ShareDownSocketInfo.SetTcpSocket( TcpSocket );
    ShareDownSocketList.Add( ShareDownSocketInfo );
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyShareDownConnectHandler.BackConnBusy;
begin
  IsConnBusy := True;
end;

procedure TMyShareDownConnectHandler.BackConnError;
begin
  IsConnError := True;
end;

constructor TMyShareDownConnectHandler.Create;
begin
  ConnectLock := TCriticalSection.Create;
  ShareDownSocketList := TShareDownSocketList.Create;
end;

destructor TMyShareDownConnectHandler.Destroy;
begin
  ShareDownSocketList.Free;
  ConnectLock.Free;
  inherited;
end;

function TMyShareDownConnectHandler.getBackConnect: TCustomIpClient;
begin
    // �ȴ����
  WaitBackConn;

    // ���ؽ��
  if IsConnSuccess then
    Result := BackConnSocket
  else
    Result := nil;
end;

function TMyShareDownConnectHandler.getConnect: TCustomIpClient;
var
  TcpSocket : TCustomIpClient;
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
  IsConnected, IsDesBusy : Boolean;
begin
  Result := nil;

    // �����Ѵ���
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // ��ȡ Pc ��Ϣ
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( OwnerID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( OwnerID );

    // Pc ����
  if not MyNetPcInfoReadUtil.ReadIsOnline( OwnerID ) then
    Exit;

    // �޷�����
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( OwnerID ) then
  begin
    Result := getBackConnect; // ʹ�÷�������
    Exit;
  end;

    // ���� Ŀ�� Pc
  TcpSocket := TCustomIpClient.Create( nil );
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_ShareFile );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  IsConnected := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ʹ�÷�������
  if not IsConnected then
  begin
    TcpSocket.Free;
    NetworkPcApi.SetCanConnectTo( OwnerID, False );  // �����޷�����
    Result := getBackConnect;
    Exit;
  end;

    // �Ƿ���շ�æ
  IsDesBusy := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), True );
  if IsDesBusy then
  begin
    TcpSocket.Free;
    HandleBusy;
    Exit;
  end;

  Result := TcpSocket;
end;

function TMyShareDownConnectHandler.getIsHandlerRun: Boolean;
begin
  if ShareConn = ShareConnect_Down then
    Result := MyShareDownHandler.getIsRun
  else
  if ShareConn = ShareConnect_Explorer then
    Result :=MyShareExplorerHandler.IsRun
  else
  if ShareConn = ShareConnect_Search then
    Result :=MyShareSearchHandler.getIsRun
  else
  if ShareConn = ShareConnect_Preview then
    Result :=MySharePreviewHandler.IsRun
  else
    Result := True;
end;

function TMyShareDownConnectHandler.getLastConnect: TCustomIpClient;
var
  i: Integer;
  ShareDownSocketInfo : TShareDownSocketInfo;
  LastSocket : TCustomIpClient;
  FileReq : string;
begin
  Result := nil;

    // Ѱ���ϴζ˿�
  LastSocket := nil;
  for i := 0 to ShareDownSocketList.Count - 1 do
  begin
    ShareDownSocketInfo := ShareDownSocketList[i];
    if ShareDownSocketInfo.OwnerID = OwnerID then
    begin
      LastSocket := ShareDownSocketInfo.TcpSocket;
      ShareDownSocketList.Delete( i );
      Break;
    end;
  end;

    // ������
  if not Assigned( LastSocket ) then
    Exit;

    // �ж϶˿��Ƿ�����
  MySocketUtil.SendData( LastSocket, FileReq_New );
  FileReq := MySocketUtil.RevData( LastSocket );
  if FileReq <> FileReq_New then  // �˿��쳣
  begin
    LastSocket.Free;
    Result := getLastConnect; // ����һ��
    Exit;
  end;

    // �����ϴζ˿�
  Result := LastSocket;
end;

function TMyShareDownConnectHandler.getShareConn(_SharePath,
  _OwnerID, _ShareConn: string ): TCustomIpClient;
begin
  ConnectLock.Enter;

  SharePath := _SharePath;
  OwnerID := _OwnerID;
  ShareConn := _ShareConn;

    // ��ȡ����
  try
    Result := getConnect;

      // ���ͳ�ʼ����Ϣ
    if Assigned( Result ) then
    begin
      MySocketUtil.SendData( Result, SharePath );
      MySocketUtil.SendData( Result, PcInfo.PcID );
    end;

  except
    Result := nil;
  end;

  ConnectLock.Leave;
end;

procedure TMyShareDownConnectHandler.HandleBusy;
begin
  if ShareConn = ShareConnect_Down then
    ShareDownAppApi.SetIsDesBusy( SharePath, OwnerID, True )
  else
  if ShareConn = ShareConnect_Explorer then
    ShareExplorerAppApi.SharePcBusy
  else
  if ShareConn = ShareConnect_Search then
    ShareSearchAppApi.SharePcBusy
  else
  if ShareConn = ShareConnect_Preview then
    SharePreviewApi.SharePcBusy;
end;

procedure TMyShareDownConnectHandler.HandleNotConn;
begin
  if ShareConn = ShareConnect_Down then
    ShareDownAppApi.SetIsConnect( SharePath, OwnerID, False )
  else
  if ShareConn = ShareConnect_Explorer then
    ShareExplorerAppApi.SharePcNotConn
  else
  if ShareConn = ShareConnect_Search then
    ShareSearchAppApi.SharePcNotConn
  else
  if ShareConn = ShareConnect_Preview then
    SharePreviewApi.SharePcNotConn;
end;

procedure TMyShareDownConnectHandler.LastConnRefresh;
var
  i: Integer;
begin
  ConnectLock.Enter;
  try
    for i := ShareDownSocketList.Count - 1 downto 0 do
    begin
        // ���������ӣ�ɾ��
      if MinutesBetween( Now, ShareDownSocketList[i].LastTime ) >= 3 then
      begin
          // �رն˿�
        ShareDownSocketList[i].CloseSocket;
          // ɾ��
        ShareDownSocketList.Delete( i );
        Continue;
      end;
        // ��������
      MySocketUtil.SendData( ShareDownSocketList[i].TcpSocket, FileReq_HeartBeat );
    end;
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyShareDownConnectHandler.StopRun;
var
  i: Integer;
begin
  ConnectLock.Enter;
  try
    for i := 0 to ShareDownSocketList.Count - 1 do
      ShareDownSocketList[i].CloseSocket;
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyShareDownConnectHandler.WaitBackConn;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // �Է��޷����ӱ���
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( OwnerID ) then
  begin
    HandleNotConn;
    Exit;
  end;

    // ��ʼ�������Ϣ
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // ��������
  ShareDownBackConnEvent.AddDown( OwnerID );

    // �ȴ����շ�����
  StartTime := Now;
  while getIsHandlerRun and ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // Ŀ�� Pc ��æ
  if IsConnBusy then
  begin
    HandleBusy;
    Exit;
  end;

    // �޷�����
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( OwnerID, False ); // ���öԷ��޷�����
    HandleNotConn;
    Exit;
  end;
end;

{ TShareDownFileHandle }

procedure TShareDownFileHandle.IniHandle;
begin

end;

procedure TShareDownFileHandle.LastCompleted;
begin

end;

procedure TShareDownFileHandle.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownFileHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareDownFileHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLocalShareDownFileHandle }

procedure TLocalShareDownFileHandle.Handle(ScanResultInfo: TScanResultInfo);
var
  LocalRestoreResultHandle : TLocalRestoreResultHandle;
begin
  LocalRestoreResultHandle := TLocalRestoreResultHandle.Create;
  LocalRestoreResultHandle.SetItemInfo( SharePath, OwnerID );
  LocalRestoreResultHandle.SetSavePath( SavePath );
  LocalRestoreResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  LocalRestoreResultHandle.SetScanResultInfo(  ScanResultInfo);
  LocalRestoreResultHandle.Update;
  LocalRestoreResultHandle.Free;
end;

{ TNetworkShareDownFileHandle }

procedure TNetworkShareDownFileHandle.CheckHeartBeat;
begin
  if SecondsBetween( Now, HeartTime ) < 10 then
    Exit;

  MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat );

  HeartTime := Now;
end;

constructor TNetworkShareDownFileHandle.Create;
begin
  ShareDownThreadList := TShareDownThreadList.Create;
  ZipThreadIndex := -1;
  ZipCount := 0;
  ZipSize := 0;
  HeartTime := Now;
end;

destructor TNetworkShareDownFileHandle.Destroy;
begin
  ShareDownThreadList.Free;
  inherited;
end;

procedure TNetworkShareDownFileHandle.DownloadFile(
  ScanResultInfo: TScanResultInfo);
var
  IsFindThread : Boolean;
  i : Integer;
begin
    // Ѱ�ҿ��е��߳�
  IsFindThread := False;
  for i := 0 to ShareDownThreadList.Count - 1 do
    if not ShareDownThreadList[i].IsRun and not ShareDownThreadList[i].IsLostConn and
       ( i <> ZipThreadIndex )    // ѹ���̲߳������ļ�
    then
    begin
      ShareDownThreadList[i].AddScanResultInfo( ScanResultInfo );
      IsFindThread := True;
      Break;
    end;

    // û���ҵ��̣߳���ǰ�̴߳���
  if not IsFindThread then
    HandleNow( ScanResultInfo );
end;


procedure TNetworkShareDownFileHandle.DownloadZip;
var
  TempPath : string;
  ScanResultGetZipInfo : TScanResultGetZipInfo;
begin
    // û��ѹ��
  if ZipThreadIndex = -1 then
    Exit;

    // ����ѹ���ļ�
  TempPath := MyFilePath.getPath( SharePath ) + Name_TempShareDownZip;
  ScanResultGetZipInfo := TScanResultGetZipInfo.Create( TempPath );
  ShareDownThreadList[ ZipThreadIndex ].AddScanResultInfo( ScanResultGetZipInfo );

  ZipThreadIndex := -1;
  ZipCount := 0;
  ZipSize := 0;
end;

procedure TNetworkShareDownFileHandle.DownZipNow;
var
  TempPath : string;
  ScanResultGetZipInfo : TScanResultGetZipInfo;
begin
    // û��ѹ���ļ�
  if ZipCount = 0 then
    Exit;

    // ����ѹ���ļ�
  TempPath := MyFilePath.getPath( SharePath ) + Name_TempShareDownZip;
  ScanResultGetZipInfo := TScanResultGetZipInfo.Create( TempPath );
  HandleNow( ScanResultGetZipInfo );

  ZipCount := 0;
  ZipSize := 0;
end;


function TNetworkShareDownFileHandle.FindZipThread: Boolean;
var
  IsFindThread, IsExistConnectedThread : Boolean;
  i: Integer;
begin
  Result := True;

    // �Ѵ���
  if ZipThreadIndex <> -1 then
    Exit;

  DebugLock.Debug( 'FindZipThread' );
  while MyShareDownHandler.getIsRun do
  begin
    // ��û��ָ��ѹ���̣߳���Ѱ��
    IsExistConnectedThread := False; // ���������̶߳��Ͽ�������
    IsFindThread := False;
    for i := 0 to ShareDownThreadList.Count - 1 do
    begin
      IsExistConnectedThread := IsExistConnectedThread or not ShareDownThreadList[i].IsLostConn;
      if ( not ShareDownThreadList[i].IsRun ) and ( not ShareDownThreadList[i].IsLostConn ) then
      begin
        IsFindThread := True;
        ZipThreadIndex := i;
        Break;
      end;
    end;

      // ���ҵ��̣߳�������
    if IsFindThread then
      Break;

      // �������κ��������߳�
    if not IsExistConnectedThread then
    begin
      Result := False;
      Break;
    end;

      // û���ҵ������ٴ�Ѱ��
    Sleep( 100 );

    CheckHeartBeat; // ��ʱ����
  end;
end;

function TNetworkShareDownFileHandle.getNewConnect: TCustomIpClient;
var
  NewTcpSocket : TCustomIpClient;
  ShareConnResult : string;
begin
  Result := nil;

  NewTcpSocket := MyShareDownConnectHandler.getShareConn( SharePath, OwnerID, ShareConnect_Down );
  if not Assigned( NewTcpSocket ) then
    Exit;

    // ��ȡ���ʽ��
  ShareConnResult := MySocketUtil.RevData( NewTcpSocket );

    // ����ʧ��
  if ShareConnResult <> ShareConnResult_OK then
    Exit;

  Result := NewTcpSocket;
end;

procedure TNetworkShareDownFileHandle.Handle(ScanResultInfo: TScanResultInfo);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
  FileSize : Int64;
begin
    // ��ǰ�̴߳���
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
  begin
    HandleNow( ScanResultInfo );
    Exit;
  end;

    // �����ļ������
  ScanResultAddFileInfo := ScanResultInfo as TScanResultAddFileInfo;
  FileSize := ScanResultAddFileInfo.FileSize;

    // ѹ�����߷����ļ�
  if IsFile or ( FileSize = 0 ) or ( FileSize > 128 * Size_KB ) then
    DownloadFile( ScanResultInfo )
  else
    ZipFile( ScanResultInfo );

    // ��ʱ��������
  CheckHeartBeat;
end;

procedure TNetworkShareDownFileHandle.HandleNow(
  ScanResultInfo: TScanResultInfo);
var
  NetworkRestoreResultHandle : TNetworkRestoreResultHandle;
begin
  NetworkRestoreResultHandle := TNetworkRestoreResultHandle.Create;
  NetworkRestoreResultHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreResultHandle.SetItemInfo( SharePath, OwnerID );
  NetworkRestoreResultHandle.SetSavePath( SavePath );
  NetworkRestoreResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  NetworkRestoreResultHandle.SetScanResultInfo(  ScanResultInfo );
  NetworkRestoreResultHandle.Update;
  NetworkRestoreResultHandle.Free;
end;

procedure TNetworkShareDownFileHandle.HandleZipError;
var
  ZipErrorList : TStringList;
  i: Integer;
  ScanResultInfo : TScanResultInfo;
begin
  ZipErrorList := TStringList.Create;

    // ��ȡ�����̵߳�ѹ������
  for i := 0 to ShareDownThreadList.Count - 1 do
    ShareDownThreadList[i].getErrorList( ZipErrorList );

    // ����ѹ������
  for i := 0 to ZipErrorList.Count - 1 do
  begin
    ScanResultInfo := TScanResultAddFileInfo.Create( ZipErrorList[i] );
    HandleNow( ScanResultInfo );
    ScanResultInfo.Free;
  end;

  ZipErrorList.Free;
end;

procedure TNetworkShareDownFileHandle.IniHandle;
var
  i: Integer;
  NewDownFileThread : TShareDownThread;
  NewTcpSocket : TCustomIpClient;
begin
  IsExistThread := False;

    // �ļ� ���� ��Job �������߳�
  if IsFile or not IsExistJob then
    Exit;

    // ������ Pc
  if not MyNetPcInfoReadUtil.ReadIsLanPc( OwnerID ) then
    Exit;

    // ���߳�����
  for i := 1 to 3 do
  begin
    NewTcpSocket := getNewConnect;
    if not Assigned( NewTcpSocket ) then
      Continue;
    NewDownFileThread := TShareDownThread.Create;
    NewDownFileThread.SetItemInfo( SharePath, OwnerID );
    NewDownFileThread.SetSavePath( SavePath );
    NewDownFileThread.SetTcpSocket( NewTcpSocket );
    NewDownFileThread.SetRefreshSpeedInfo( RefreshSpeedInfo );
    NewDownFileThread.Resume;
    ShareDownThreadList.Add( NewDownFileThread );
  end;

    // �Ƿ���������߳�
  IsExistThread := ShareDownThreadList.Count > 0;
end;

procedure TNetworkShareDownFileHandle.LastCompleted;
var
  IsFind : Boolean;
  i : Integer;
begin
    // �������� Zip
  if IsExistThread then
    DownloadZip
  else
    DownZipNow; // ��ǰ�߳�����

    // �ȴ��߳̽���
  DebugLock.Debug( 'Wait Thread Stop' );
  while MyShareDownHandler.getIsRun do
  begin
    IsFind := False;
    for i := 0 to ShareDownThreadList.Count - 1 do
      if ShareDownThreadList[i].IsRun and not ShareDownThreadList[i].IsLostConn then
      begin
        IsFind := True;
        Break;
      end;
    if not IsFind then
      Break;
    Sleep( 100 );
    CheckHeartBeat;
  end;

    // ���� Zip Error
  HandleZipError;
end;

procedure TNetworkShareDownFileHandle.SetDownInfo(_IsFile,
  _IsExistJob: Boolean);
begin
  IsFile := _IsFile;
  IsExistJob := _IsExistJob;
end;

procedure TNetworkShareDownFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkShareDownFileHandle.ZipFile(ScanResultInfo: TScanResultInfo);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
  FilePath : string;
begin
  FilePath := ScanResultInfo.SourceFilePath;

    // �Ƿ���߳�
  if IsExistThread then
  begin
    if not FindZipThread then  // Ѱ��ѹ�����߳�
    begin
      IsExistThread := False;  // �����̶߳��Ѿ��Ͽ�
      ZipFile( ScanResultInfo );  // ���뵥�߳�ģʽ
      Exit;
    end;
    ShareDownThreadList[ ZipThreadIndex ].SendZip( FilePath ); // ����ѹ������
  end
  else
  begin  // ��ǰ�̷߳���ѹ������
    MySocketUtil.SendData( TcpSocket, FileReq_AddZip );
    MySocketUtil.SendData( TcpSocket, FilePath );
  end;

    // ѹ����Ϣ
  ScanResultAddFileInfo := ScanResultInfo as TScanResultAddFileInfo;
  ZipSize := ZipSize + ScanResultAddFileInfo.FileSize;
  ZipCount := ZipCount + 1;

    // δ�ﵽ��ֵ
  if ( ZipCount < 1000 ) and ( ZipSize < 10 * Size_MB ) then
    Exit;

    // �Ƿ���ڶ��߳�
  if IsExistThread then
    DownloadZip  // ����ѹ���ļ�
  else
    DownZipNow; // ��ǰ�߳�����ѹ���ļ�
end;

{ TShareDownThread }

procedure TShareDownThread.AddScanResultInfo(_ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  IsRun := True;
end;

constructor TShareDownThread.Create;
begin
  inherited Create;
  SocketLock := TCriticalSection.Create;
  IsRun := False;
  IsLostConn := False;
end;

destructor TShareDownThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  SocketLock.Free;
  inherited;
end;

procedure TShareDownThread.Execute;
begin
  while not Terminated and not IsLostConn do
  begin
    WaitToDown;
    if Terminated or not IsRun then
      Break;
    DownloadFile;
    if not IsLostConn then
      IsRun := False;
  end;
  DebugLock.Debug( 'Share Down Stop' );

    // ���ͽ�������
  MySocketUtil.SendData( TcpSocket, FileReq_End );

    // ���ն˿�
  MyShareDownConnectHandler.AddLastConn( OwnerID, TcpSocket );

  inherited;
end;

procedure TShareDownThread.getErrorList(ErrorList: TStringList);
var
  ErrorStr : string;
  StrList : TStringList;
  i: Integer;
begin
    // ��������б�
  MySocketUtil.SendData( TcpSocket, FileReq_ReadZipError );
  ErrorStr := MySocketUtil.RevData( TcpSocket );

    // ��ӵ�ͳ����
  StrList := MySplitStr.getList( ErrorStr, ZipErrorSplit_File );
  for i := 0 to StrList.Count - 1 do
    ErrorList.Add( StrList[i] );
  StrList.Free;
end;

procedure TShareDownThread.DownloadFile;
var
  NetworkRestoreResultHandle : TNetworkRestoreResultHandle;
begin
  NetworkRestoreResultHandle := TNetworkRestoreResultHandle.Create;
  NetworkRestoreResultHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreResultHandle.SetItemInfo( SharePath, OwnerID );
  NetworkRestoreResultHandle.SetSavePath( SavePath );
  NetworkRestoreResultHandle.SetSpeedInfo( RefreshSpeedInfo );
  NetworkRestoreResultHandle.SetScanResultInfo( ScanResultInfo );
  NetworkRestoreResultHandle.Update;
  NetworkRestoreResultHandle.Free;
  DebugLock.Debug( 'DownloadFile Stop' );

    // ���������ع��̶Ͽ�����
  IsLostConn := not TcpSocket.Connected;
end;

procedure TShareDownThread.SendZip(FilePath: string);
begin
  SocketLock.Enter;
  MySocketUtil.SendData( TcpSocket, FileReq_AddZip );
  MySocketUtil.SendData( TcpSocket, FilePath );
  SocketLock.Leave;
end;

procedure TShareDownThread.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownThread.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareDownThread.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareDownThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TShareDownThread.WaitToDown;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'Wait To Down' );

  StartTime := Now;
  while not IsRun and not IsLostConn and not Terminated and MyShareDownHandler.getIsRun do
  begin
    Sleep( 100 );
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 �뷢��һ������
      Continue;

      // ��������
    SocketLock.Enter;
    if not MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat ) then  // �Է��ѶϿ�����
    begin
      TcpSocket.Disconnect;
      IsLostConn := True;
    end;
    SocketLock.Leave;

    StartTime := Now;
  end;
end;

{ TNetworkFileRestoreReceiveZipHandle }

function TNetworkFileRestoreReceiveZipHandle.CreateWriteStream: Boolean;
begin
  WriteStream := TMemoryStream.Create;
  Result := True;
end;

procedure TNetworkFileRestoreReceiveZipHandle.LastRefreshCompletedSpace;
var
  ZipFile : TZipFile;
  FileName, FilePath : string;
  FileDate : TDateTime;
  i: Integer;
  StartTime : TDateTime;
  TotalSize, DelZipSize : Int64;
begin
  inherited;

    // �����ѶϿ�
  if not TcpSocket.Connected then
    Exit;

    // ��ѹ�ļ�
  TotalSize := 0;
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
          LogCompleted( FileName );
          FileName := StringReplace( FileName, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getPath( SavePath ) + FileName;
          FileDate := FileDateToDateTime( ZipFile.FileInfo[i].ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );
          TotalSize := TotalSize + ZipFile.FileInfo[i].UncompressedSize;
        except
        end;
        HeartBeatReceiver.CheckSend( TcpSocket, StartTime );  // ��ѹʱ����ܹ�������ʱ��������
      end;
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;

  try   // ˢ��ѹ���ռ�
    DelZipSize := TotalSize - WriteStream.Size;
    ShareDownAppApi.AddCompletedSpace( SharePath, OwnerID, DelZipSize );
  except
  end;
end;

procedure TNetworkFileRestoreReceiveZipHandle.LogCompleted(ZipName: string);
var
  LogFilePath : string;
  Params : TShareDownAddLogParams;
begin
  LogFilePath := MyFilePath.getPath( SharePath ) + ZipName;

  Params.SharePath := SharePath;
  Params.OwnerPcID := OwnerID;
  Params.FilePath := LogFilePath;
  Params.SendTime := Now;
  ShareDownLogApi.AddCompleted( Params );
end;

procedure TNetworkFileRestoreReceiveZipHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TShareDownSocketInfo }

procedure TShareDownSocketInfo.CloseSocket;
begin
    // �رն˿�
  try
    MySocketUtil.SendData( TcpSocket, FileReq_End );
    TcpSocket.Free;
  except
  end;
end;

constructor TShareDownSocketInfo.Create(_OwnerID: string);
begin
  OwnerID := _OwnerID;
  LastTime := Now;
end;

procedure TShareDownSocketInfo.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TShareDownCancelReader }

constructor TShareDownCancelReader.Create;
begin
  ScanTime := Now;
  SleepCount := 0;
end;

function TShareDownCancelReader.getIsRun: Boolean;
begin
  Result := MyShareDownHandler.getIsRun;

    // �Ƿ���Ҫ��ͣһ��
  Inc( SleepCount );
  if SleepCount >= 10 then
  begin
    SleepCount := 0;
    Sleep(1);
  end;

  if SecondsBetween( Now, ScanTime ) >= 1 then  // ��� BackupItem ɾ��
  begin
    Result := Result and ShareDownInfoReadUtil.ReadIsExist( SharePath, OwnerID );
    ScanTime := Now;
  end;
end;

procedure TShareDownCancelReader.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

{ TNetworkShareDownCancelReader }

function TNetworkShareDownCancelReader.getIsRun: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

procedure TNetworkShareDownCancelReader.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TShareDownFreeLimitReader }

function TShareDownFreeLimitReader.AddResult(
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

    // �����������
  if MyShareDown_ShareDownCount < 3 then
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

constructor TShareDownFreeLimitReader.Create;
begin
  FreeLimitType := '';
end;

function TShareDownFreeLimitReader.getFreeLimitType: string;
begin
  Result := FreeLimitType;
end;

procedure TShareDownFreeLimitReader.IniHandle;
begin
  IsFreeLimit := MyRegisterInfo.IsFreeLimit;
end;

procedure TShareDownFreeLimitReader.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

end.
