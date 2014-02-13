unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UMyUtil, UModelUtil, UMyTcp, sockets,
     Classes, Math, winapi.winsock, StrUtils, LbCipher,LbProc, uDebugLock,
     Winapi.GDIPAPI, Winapi.GDIPOBJ, winapi.GDIPUTIL, Winapi.ActiveX, graphics, shellapi, uDebug, zlib, SyncObjs;

type

{$Region ' �ļ�ɨ�� ' }

     // �������ļ���Ϣ
  TScanFileInfo = class
  public
    FileName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getEquals( ScanFileInfo : TScanFileInfo ): Boolean;
  end;
  TScanFilePair = TPair< string , TScanFileInfo >;
  TScanFileHash = class( TStringDictionary< TScanFileInfo > );

  TScanFolderHash = class;

      // ����Ŀ¼����Ϣ
  TScanFolderInfo = class
  public
    FolderName : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    IsReaded : Boolean;
  public
    constructor Create( _FolderName : string );
    destructor Destroy; override;
  end;
  TScanFolderPair = TPair< string , TScanFolderInfo >;
  TScanFolderHash = class( TStringDictionary< TScanFolderInfo > );

      // ��Ϣ ������
  ScanFileInfoUtil = class
  public
    class procedure CopyFile( OldFileHash, NewFileHash : TScanFileHash );
    class procedure CopyFolder( OldFOlderHash, NewFolderHash : TScanFolderHash );
  end;


  {$Region ' ɨ��Ŀ¼ �����Ϣ ' }

    // �ļ��ȽϽ��
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // ��� �ļ�
  TScanResultAddFileInfo = class( TScanResultInfo )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
  end;

    // ��� Ŀ¼
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // ɾ�� �ļ�
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // ɾ�� Ŀ¼
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

    // ��� ѹ���ļ�
  TScanResultAddZipInfo = class( TScanResultInfo )
  public
    ZipStream : TMemoryStream;
    TotalSize : Int64;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

    // ��ȡ ѹ���ļ�
  TScanResultGetZipInfo = class( TScanResultInfo )
  end;

  {$EndRegion}

  {$Region ' ɨ��Ŀ¼ �㷨 ' }

  {$Region ' ɨ�踸�� ' }

    // ����Ŀ¼ ����
  TFolderFindBaseHandle = class
  public
    FolderPath : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFolderPath( _FolderPath : string );
  end;

    // ���� ����Ŀ¼
  TFolderFindHandle = class( TFolderFindBaseHandle )
  public
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;virtual;
    function IsFolderFilter( FolderPath : string ): Boolean;virtual;
  end;

    // ���� ����Ŀ¼
  TFolderAccessFindHandle = class( TFolderFindBaseHandle )
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' ����ɨ�� ' }

    // ���� ����Ŀ¼
  TLocalFolderFindHandle = class( TFolderFindHandle )
  public
    SleepCount : Integer;
  public
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure CheckSleep;virtual;  // Cpu ����
  end;

    // ���� �������Ŀ¼
  TLocalFolderFindDeepHandle = class( TFolderFindHandle )
  public
    SleepCount : Integer;
    DeepCount : Integer;
  public
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetDeepCount( _DeepCount : Integer );
    procedure Update;
  private
    procedure SearchLocalFolder;
    procedure SearchChildFolder;
  private        // ��̬
    function CreateSearchLocalFolder : TLocalFolderFindHandle;virtual;
    function CreateSearchChildFolder : TLocalFolderFindDeepHandle;virtual;
  end;

  {$EndRegion}

  {$Region ' ��������ɨ�� ' }

    // �������� ����
  TNetworkFolderFindBaseHandle = class( TFolderFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  protected
    procedure SendFileReq;virtual;abstract;
  end;

    // ���� ����Ŀ¼
  TNetworkFolderFindHandle = class( TNetworkFolderFindBaseHandle )
  protected
    procedure SendFileReq;override;
  end;

    // ���� ������Ŀ¼
  TNetworkFolderFindDeepHandle = class( TNetworkFolderFindBaseHandle )
  protected
    procedure SendFileReq;override;
  end;

  {$EndRegion}

  {$Region ' ���类������ ������ ' }

    // ������������
  THeatBeatHelper = class
  public
    TcpSocket : TCustomIpClient;
    StartTime : TDateTime;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure CheckHeartBeat;
  end;

    // ����������
  HeartBeatReceiver = class
  public
    class function CheckReceive( TcpSocket : TCustomIpClient ): string;
    class procedure CheckSend( TcpSocket : TCustomIpClient; var StartTime : TDateTime );
  end;

    // ���������ļ���
  TLocalFolderFindAdvanceHandle = class( TLocalFolderFindHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected
    procedure CheckSleep;override;
  end;

    // �������ɸ��ļ�
  TLocalFolderFindDeepAdvanceHandle = class( TLocalFolderFindDeepHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  private        // ��̬
    function CreateSearchLocalFolder : TLocalFolderFindHandle;override;
    function CreateSearchChildFolder : TLocalFolderFindDeepHandle;override;
  end;

  {$EndRegion}

  {$Region ' ���类������ ' }

    // �������� ����
  TNetworkFolderAccessFindBaseHandle = class( TFolderAccessFindHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  protected
    procedure SearchFolderInfo;virtual;abstract; // ������Ϣ
    procedure SendFolderInfo;  // ���ͽ����Ϣ
  end;

    // �������� ����Ŀ¼
  TNetworkFolderAccessFindHandle = class( TNetworkFolderAccessFindBaseHandle )
  protected
    procedure SearchFolderInfo;override; // ������Ϣ
  end;

    // �������� ������Ŀ¼
  TNetworkFolderAccessFindDeepHandle = class( TNetworkFolderAccessFindBaseHandle )
  protected
    procedure SearchFolderInfo;override; // ������Ϣ
  end;

  {$EndRegion}

  {$Region ' ����ɨ����Ϣ���� ' }

    // ��ȡ �ļ���ȡ��Ϣ
  TFindNetworkFileResultHandle = class
  public
    FileStr : string;
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _FileStr : string );
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure Update;
  private
    procedure ReadFileInfo( FileInfoStr : string );
  end;

    // ��ȡ Ŀ¼��ȡ��Ϣ
  TFindNetworkFolderResultHandle = class
  public
    FolderStr : string;
    ScanFolderHash : TScanFolderHash;
    FolderLevel : Integer;
  public
    constructor Create( _FolderStr : string );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
    procedure SetFolderLevel( _FolderLevel : Integer );
    procedure Update;
  private
    procedure ReadFolderInfo( FolderInfoStr : string );
  end;

    // ��ȡ ����Ŀ¼��ȡ��Ϣ
  TFindNetworkFullFolderResultHandle = class
  private
    ReadResultStr : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  private
    FolderStr, FileStr : string;
  public
    constructor Create( _ReadResultStr : string );
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
    procedure Update;
  private
    procedure ReadFolder;
    procedure ReadFile;
  end;



    // ���� �ļ��б� �ַ���
  TGetNetworkFileResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _ScanFileHash : TScanFileHash );
    function get : string;
  end;

      // ���� Ŀ¼�б� �ַ���
  TGetNetworkFolderResultStrHandle = class
  public
    ScanFolderHash : TScanFolderHash;
    FolderLevel : Integer;
  public
    constructor Create( _ScanFolderHash : TScanFolderHash );
    procedure SetFolderLevel( _FolderLevel : Integer );
    function get : string;
  private
    function getChildFileStr( FolderName : string ) : string;
    function getChildFolderStr( FolderName : string ) : string;
  end;

    // ���� ����Ŀ¼ �ַ���
  TGetNetworkFullFolderResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFileHash( _ScanFileHash : TScanFileHash );
    procedure SetFolderHash( _ScanFolderHash : TScanFolderHash );
    function get : string;
  private
    function getFolderStr : string;
    function getFileStr : string;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' ɨ���ļ� �㷨 ' }

    // �����ļ���Ϣ
  TFileFindHandle = class
  public
    FilePath : string;
  protected
    IsExist : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
  public
    function getIsExist : Boolean;
    function getFileSize : Int64;
    function getFileTime : TDateTime;
  end;

    // ���� �����ļ�
  TLocalFileFindHandle = class( TFileFindHandle )
  public
    procedure Update;
  end;

    // �������� �����ļ�
  TNetworkFileFindHandle = class( TFileFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

    // �������� �����ļ�
  TNetworkFileAccessFindHandle = class
  protected
    FilePath : string;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _FilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

  {$EndRegion}


    // Ŀ¼�Ƚ��㷨
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // �ļ���Ϣ
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // Ŀ¼��Ϣ
    SourceFolderHash : TScanFolderHash;
    DesFolderHash : TScanFolderHash;
  public   // �ռ���
    FileCount, CompletedCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public   // �Ƿ�ɾ��Ŀ������ļ�
    IsSupportDeleted : Boolean;
    IsDesEmpty, IsDesReaded : Boolean;  // Ŀ��Ŀ¼�Ƿ�Ϊ�գ�Ŀ���Ƿ��Ѷ�ȡ
    EncryptType, PasswordExt : string; // ���ܵ����
  public
    constructor Create;
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure SetIsSupportDeleted( _IsSupportDeleted : Boolean );
    procedure SetIsDesEmpty( _IsDesEmpty : Boolean );
    procedure SetIsDesReaded( _IsDesReaded : Boolean );
    procedure SetEncrypt( _EncryptType, _PasswordExt : string );
    procedure Update;
    destructor Destroy; override;
  protected
    procedure FindSourceFileInfo;virtual;abstract;
    procedure FindDesFileInfo;virtual;abstract;
    procedure FileCompare;
    procedure FolderCompare;virtual;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;virtual;
    procedure DesFolderEmptyHandle; virtual; // Ŀ��Ŀ¼Ϊ��
  private        // �ȽϽ��
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string; FileSize : Int64 );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
    function getDesFileName( SourceFileName : string ): string;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // �ļ��Ƚ��㷨
  TFileScanHandle = class
  public
    SourceFilePath : string;
    EncryptType, PasswordExt : string; // ���ܵ����
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // �ռ���
    CompletedCount : Integer;
    CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public
    ParentFileHash : TScanFileHash;
  public
    constructor Create;
    procedure SetSourceFilePath( _SourceFilePath : string );
    procedure SetEncryptInfo( _EncryptType, _PasswordExt : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
    destructor Destroy; override;
  protected
    function FindSourceFileInfo: Boolean;virtual;abstract;
    function FindDesFileInfo: Boolean;virtual;abstract;
  private        // �ȽϽ��
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  protected
    procedure FindParentFileHash;virtual;
    procedure RemoveOtherDesFile;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

  TDataBuf = array[0..524287] of Byte; // 512 KB, ���̶�д��λ
  TSendBuf = array[0..1023] of Byte;  // 1 KB, ���紫�䵥λ

  TDataBufObj = class
  public
    DataBuf : TDataBuf;
    BufSize : Integer;
  public
    constructor Create( _DataBuf : TDataBuf; _BufSize : Integer );
  end;
  TDataBufList = class( TObjectList<TDataBufObj> )end;

  TMyDataBuf = class
  public
    DataBufList : TDataBufList;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddBuf( var InputBuf : TDataBuf; BufSize : Integer );
    procedure Clear;
    procedure ReadBuf( var OutputBuf : TDataBuf; BufPos, BufSize : Integer );
  end;

    // �����ļ�������
  CopyFileUtil = class
  public
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
  private
    class procedure EncryptData( var Buf : TDataBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // �����ļ�������
  SendFileUtil = class
  public             // �ӽ���
    class procedure Encrypt( var Buf : TSendBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TSendBuf; BufSize : Integer; Password : string );
  public             // ѹ��, ��ѹ
    class procedure CompressStream( SourceStream, ComStream : TMemoryStream );
    class procedure DecompressStream( ComStream, DesStream : TMemoryStream );
  private
    class procedure EncryptData( var Buf : TSendBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // ˢ���ٶ���Ϣ
  TRefreshSpeedInfo = class
  public
    SpeedLock : TCriticalSection;
    SpeedTime : TDateTime;
    Speed, LastSpeed : Int64;
  public
    IsLimited : Boolean;
    LimitSpeed : Int64;
  public
    constructor Create;
    procedure SetLimitInfo( _IsLimited : Boolean; _LimitSpeed : Int64 );
    function AddCompleted( CompletedSpace : Integer ): Boolean;
    destructor Destroy; override;
  end;

    // �����ļ� ����
  TFileCopyHandle = class
  protected
    SourceFilePath, DesFilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
    IsEncrypt, IsDecrypt : Boolean;
    EncPassword, DecPassword : string;
  protected
    AddCompletedSpace : Int64;
    RefreshTime : TDateTime;  // ��ʱ ˢ����Ϣ
    SleepCount : Integer; // Cpu �ͷ�
    RefreshSpeedInfo : TRefreshSpeedInfo; // �ٶ���Ϣ
  protected
    ReadStream : TFileStream;  // ������
    WriteStream : TFileStream; // д����
    BufStream : TMemoryStream;  // �ڴ���
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetEncPassword( _IsEncrypt : Boolean; _EncPassword : string );
    procedure SetDecPassword( _IsDecrypt : Boolean; _DecPassword : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function getDesIsEnoughSpace : Boolean;  // ����Ƿ����㹻�Ŀռ�
    function CreateReadStream : Boolean;  // ����������
    function CreateWriteStream : Boolean;  // ����д����
    function FileCopy: Boolean;  // ������
    function ReadBufStream : Integer;
    function WriteBufStream : Integer;
    procedure DestoryStream;
  protected
    function CheckNextCopy : Boolean;virtual; // ����Ƿ��������
    procedure RefreshCompletedSpace;virtual; // ˢ������ɿռ�
  protected
    procedure MarkContinusCopy;virtual; // ����ʱ����
    procedure DesWriteSpaceLack;virtual; // �ռ䲻��
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
  end;

      // �������շ�״̬�߳�
  TWatchRevThread = class( TDebugThread )
  public
    TcpSocket : TCustomIpClient;
  public
    IsRevStop, IsRevLostConn, IsRevCompleted : Boolean;
    RevSpeed, RevLimitSpace : Int64;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure StartWatch;
    procedure StopWatch;
  end;

    // ���������ļ�
  TNetworkFileSendHandle = class
  protected
    SendFilePath : string;
    TcpSocket : TCustomIpClient;
    FileSize, FilePos : Int64;
    FileTime : TDateTime;
    IsStopTransfer, IsLostConn : Boolean;
  protected
    ReadStream : TStream;
    BufStream : TMemoryStream;
    AddCompletedSpace : Int64;
    RefreshTime : TDateTime;
  protected
    RevLimitSpace : Int64;
    TotalSendDataBuf, SendDataBuf : TDataBuf;  // ÿ�η��͵����ݽṹ
  protected
    WatchRevThread : TWatchRevThread; // ������Ϣ�߳�
  public
    constructor Create( _SendFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetFilePos( _FilePos : Int64 );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FileSend: Boolean;
    function ReadBufStream: Integer; // ��ȡ����
    function SendBufStream: Boolean;  // ��������
    function RevWriteSize( ReadSize : Integer ) : Boolean; // �Է�д����ٿռ�
    function ReadSendBlockSize : Int64; // ÿ�η��͵Ŀռ�
    function ReadIsStopTransfer : Boolean; // �Ƿ�ֹͣ����
    function ReadIsNextSend( IsSendSuccess : Boolean ) : Boolean; // �Ƿ��������
  protected
    function getIsEnouthSpace : Boolean;virtual;
    function CreateReadStream : Boolean;virtual;
    function CheckNextSend : Boolean;virtual; // ����Ƿ��������
    procedure RefreshCompletedSpace;virtual;  // ˢ������ɿռ�
    procedure AddSpeedSpace( Space : Integer );virtual; // ˢ���ٶ���Ϣ
    function getLimitBlockSize : Int64;virtual;
  protected     // �쳣�����
    procedure RevFileLackSpaceHandle;virtual; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusSend;virtual; // ����ʱ����
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
    procedure LostConnectError;virtual; //�Ͽ����ӳ���
    procedure SendFileError;virtual; // �����ļ�����
  end;

    // Ԥ������
  TNetworkFilePreviewSendHandle = class( TNetworkFileSendHandle )
  protected
    function getIsEnouthSpace : Boolean;override;
  end;

     // Ԥ��ͼƬ
  TNetworkFilePreviewPictureSendHandle = class( TNetworkFilePreviewSendHandle )
  public
    PreviewWidth, PreviewHeight : Integer;
  public
    procedure SetPreviewSize( _PreviewWidth, _PreviewHeight : Integer );
  protected
    function CreateReadStream : Boolean;override;
  end;

    // Ԥ�� Exe
  TNetworkFilePreviewExeSendHandle = class( TNetworkFilePreviewSendHandle )
  protected
    function CreateReadStream : Boolean;override;
  end;


    // ���ı���ʽԤ��
  TNetworkFilePreviewTextSendHandle = class( TNetworkFilePreviewSendHandle )
  protected
    function CreateReadStream : Boolean;override;
  end;


     // ���������ļ�
  TNetworkFileReceiveHandle = class
  protected
    ReceiveFilePath : string;
    TcpSocket : TCustomIpClient;
    FileSize, FilePos : Int64;
    FileTime : TDateTime;
  protected
    RefreshTime : TDateTime;
    AddCompletedSpace : Int64;
    IsStopTransfer, IsLostConn : Boolean;
  protected
    RevStartTime : TDateTime;
  protected
    WriteStream : TStream;
    BufStream : TMemoryStream;
    SendDataBuf, TotalSendDataBuf : TDataBuf;  // ÿ�η��͵����ݽṹ
  public
    constructor Create( _ReceiveFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FileReceive: Boolean;
    function ReceiveBufStream( BufSize : Integer ): Boolean; // ���� 512 KB ����
    function WriteBufStream: Integer;
    function SendWriteSize( WriteSize, ReadSize : Integer ): Boolean;
    procedure SendRevSpeed( RevSize : Int64 ); // ���ͽ�������
    function ReadIsStopTransfer : Boolean; // �Ƿ�ֹͣ����
    function ReadIsNextRev( IsSuccessRev : Boolean ) : Boolean; // �Ƿ��������
  protected
    function getIsEnoughSapce : Boolean;virtual;
    function CreateWriteStream : Boolean;virtual;
    function CheckNextReceive : Boolean;virtual; // ����Ƿ��������
    procedure RefreshCompletedSpace;virtual;
    procedure LastRefreshCompletedSpace;virtual;
    procedure AddSpeedSpace( Space : Integer );virtual; // ˢ���ٶ���Ϣ
    function getLimitBlockSize : Int64;virtual;
    procedure ResetFileTime;virtual;
  protected     // �쳣�����
    procedure RevFileLackSpaceHandle;virtual; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusRev;virtual; // ����ʱ����
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
    procedure LostConnectError;virtual; //�Ͽ����ӳ���
    procedure ReceiveFileError;virtual; // �����ļ�����
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

  TEditonPathParams = record
  public
    FilePath : string;
    EditionNum : Integer;
    IsEncrypted : Boolean;
    PasswordExt : string;
  end;

    // ������
  FileRecycledUtil = class
  public
    class function getEditionPath( Params : TEditonPathParams ): string;
  end;

    // Ŀ���ļ� ����
  TFileRecycleHandle = class
  public
    DesFilePath, RecycledPath : string;
    SaveDeletedEdition : Integer;
    IsEcnrtyped : Boolean;
    PasswordExt : string;
  public
    constructor Create( _DesFilePath, _RecycledPath : string );
    procedure SetSaveDeletedEdition( _SaveDeletedEdition : Integer );
    procedure SetEncryptInfo( _IsEcnrtyped : Boolean; _PasswordExt : string );
    procedure Update;
  protected
    procedure CheckKeedEditionCount;
    function FileCopy: Boolean;virtual;
    procedure FileRemove;
  private
    function getExistEditionCount : Integer;
    function getEditionPath( FilePath : string; EditionNum : Integer ): string;
  end;

    // Ŀ��Ŀ¼ ����
  TFolderRecycleHandle = class
  public
    DesFolderPath : string;
    RecycleFolderPath : string;
    SleepCount : Integer;
  public
    KeepEditionCount : Integer;
  public
    IsEncrypt : Boolean;
    PasswordExt : string;
  public
    constructor Create( _DesFolderPath : string );
    procedure SetRecycleFolderPath( _RecycleFolderPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetKeepEditionCount( _KeepEditionCount : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordExt : string );
    procedure Update;
  protected
    procedure SearchFile( FileName : string );virtual;
    procedure SearchFolder( FolderName : string );virtual;
    procedure FolderRemove;
  protected
    function CheckNextRecycled : Boolean;virtual;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

    // �ļ����� ���
  TFolderSearchHandle = class
  private
    FolderPath : string;
    SearchName : string;
    ResultFolderPath : string;
  private
    IsEncrypted : Boolean;
    PasswordExt : string;
  private
    RefreshTime : TDateTime;
    SleepCount : Integer;
  protected
    ResultFileHash : TScanFileHash;
    ResultFolderHash : TScanFolderHash;
  private
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    constructor Create;
    procedure SetFolderPath( _FolderPath : string );
    procedure SetSerachName( _SearchName : string );
    procedure SetResultFolderPath( _ResultFolderPath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetRefreshTime( _RefreshTime : TDateTime );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetResultFile( _ResultFileHash : TScanFileHash );
    procedure SetResultFolder( _ResultFolderHash : TScanFolderHash );
    function Update: Boolean;
    procedure LastRefresh;virtual;
    destructor Destroy; override;
  private
    function FindScanHash: Boolean;
    function FindResultHash: Boolean;
    function SearchChildFolder: Boolean;
  protected
    function CheckNextSearch: Boolean;virtual;
    procedure HandleResultHash; virtual;abstract;
    function getIsStop : Boolean; virtual;
    function getFolderSearchHandle : TFolderSearchHandle;virtual;abstract;
  end;

    // ����Ŀ¼ ��������
  TNetworkFolderSearchHandle = class
  public
    TcpSocket : TCustomIpClient;
  protected
    ResultFileHash : TScanFileHash;
    ResultFolderHash : TScanFolderHash;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure HandleResult( ResultStr : string );
  protected
    function getIsStop : Boolean;virtual;
    procedure HandleResultHash; virtual;abstract;
  end;

    // ����Ŀ¼ ��������
  TNetworkFolderSearchAccessHandle = class( TFolderSearchHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure LastRefresh;override;
  protected
    procedure HandleResultHash;override;
    function getIsStop : Boolean; override;
    function getFolderSearchHandle : TFolderSearchHandle;override;
  end;

{$EndRegion}

const
  EncryptType_Enc = 'Enc';
  EncryptType_Dec = 'Dec';
  EncryptType_No = '';


const
  ScanCount_Sleep = 100;
  CopyCount_Sleep = 2;

    // �ļ�����
  FileReq_End = '-1';
  FileReq_ReadFile = '0';
  FileReq_ReadFolder = '1';
  FileReq_ReadRecycleFile = '10';
  FileReq_ReadRecycleFolder = '11';
  FileReq_ReadFolderList = '16';
  FileReq_ReadRecycleFolderList = '17';
  FileReq_GetContinues = '18';
  FileReq_GetContinuesRecycle = '19';
  FileReq_ReadFileDeltedList = '20';

  FileReq_SearchFolder = '21';
  FileReq_SearchRecycleFolder = '22';

  FileReq_PreviewPicture = '23';
  FileReq_PreviewWord = '24';
  FileReq_PreviewExcel = '25';
  FileReq_PreviewZip = '26';
  FileReq_PreviewText = '27';
  FileReq_PreviewExe = '28';
  FileReq_PreviewMusic = '29';

  FileReq_ZipFile = '30';

  FileReq_ReadFolderDeep = '31';
  FileReq_ReadRecycleFolderDeep = '32';

  FileReq_HeartBeat = '<33>';

  FileReq_AddZip = '34';
  FileReq_GetZip = '35';
  FileReq_ReadZipError = '36';

  FileReq_New = '37';

  FileReq_AddFile = '2';
  FileReq_AddFolder = '3';
  FileReq_RemoveFile = '4';
  FileReq_RemoveFolder = '5';
  FileReq_RecycleFile = '6';
  FileReq_RecycleFolder = '7';
  FileReq_GetFile = '8';
  FileReq_GetRecycleFile = '9';

  FileReq_SetSpace = '12';
  FileReq_SetCompleted = '13';
  FileReq_ContinuesAdd = '14';
  FileReq_ContinuesGet = '15';

  FileReqBack_Continues = '0';
  FileReqBack_End = '1';

    // ��������
  ConnReq_Continuse = '0';
  ConnReq_Close = '-1';

    // Ŀ¼��ȡ���
  FolderReadResult_End = '-1';
  FolderReadResult_File = '0';
  FolderReadResult_Folder = '1';

    // Ŀ¼�������
  FolderSearchResult_End = '-1';

const
  FolderListSplit_ReqFolder = '<fo>';

  FolderListSplit_Type = '<t>';
  FolderListSplit_File = '<f>';
  FolderListSplit_FileInfo = '<fi>';
  FolderListSplit_Folder = '<fo%s>';
  FolderListSplit_FolderInfo = '<foi%s>';


  Type_Empty = '<Empty>';
  Type_Count = 2;
  Type_Folder = 0;
  Type_File = 1;

  FileInfo_Count = 3;
  Info_FileName = 0;
  Info_FileSize = 1;
  Info_FileTime = 2;

  FolderInfo_Count = 4;
  Info_FolderName = 0;
  Info_IsReaded = 1;
  Info_FolderChildFiles = 2;
  Info_FolderChildFolders = 3;

  ZipErrorSplit_File = '<f>';

const
  RecycleSplit_Type = '<Type>';
  RecycleSplit_Count = 3;

  RecycleSplit_KeepEditionCount = 0;
  RecycleSplit_IsEncrypted = 1;
  RecycleSplit_PasswordExt = 2;

const
  DeepCount_Max = 5000;

const
  ReceiveStatus_Speed = 'Speed';
  ReceiveStatus_LimitSpace = 'LimitSpace';
  ReceiveStatus_Completed = 'Completed';
  ReceiveStatus_Stop = 'Stop';

const
  Split_Word = '<BackupCow_Word_567>';

implementation

{ TScanFileInfo }

constructor TScanFileInfo.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TScanFileInfo.getEquals(ScanFileInfo: TScanFileInfo): Boolean;
begin
  Result := ( ScanFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( FileTime, ScanFileInfo.FileTime ) );
end;

procedure TScanFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TScanResultInfo }

constructor TScanResultInfo.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TFolderCompareHandle }

procedure TFolderScanHandle.AddFileResult(FileName : string; FileSize : Int64);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getChildPath( FileName ) );
  ScanResultAddFileInfo.SetFileSize( FileSize );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

procedure TFolderScanHandle.AddFolderResult(FolderName: string);
var
  ScanResultAddFolderInfo : TScanResultAddFolderInfo;
begin
  ScanResultAddFolderInfo := TScanResultAddFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultAddFolderInfo );
end;

function TFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TFolderScanHandle.CompareChildFolder(SourceFolderName: string);
var
  ChildFolderPath : string;
  FolderScanHandle : TFolderScanHandle;
begin
  ChildFolderPath := MyFilePath.getPath( SourceFolderPath ) + SourceFolderName;
  FolderScanHandle := getScanHandle( SourceFolderName );
  FolderScanHandle.SetSourceFolderPath( ChildFolderPath );
  FolderScanHandle.SetResultList( ScanResultList );
  FolderScanHandle.SetIsSupportDeleted( IsSupportDeleted );
  FolderScanHandle.SetIsDesEmpty( IsDesEmpty );
  FolderScanHandle.SetEncrypt( EncryptType, PasswordExt );
  FolderScanHandle.FileCount := FileCount;
  FolderScanHandle.FileSize := FileSize;
  FolderScanHandle.CompletedCount := CompletedCount;
  FolderScanHandle.CompletedSize := CompletedSize;
  FolderScanHandle.SleepCount := SleepCount;
  FolderScanHandle.ScanTime := ScanTime;
  FolderScanHandle.Update;
  FileCount := FolderScanHandle.FileCount;
  FileSize := FolderScanHandle.FileSize;
  CompletedCount := FolderScanHandle.CompletedCount;
  CompletedSize := FolderScanHandle.CompletedSize;
  SleepCount := FolderScanHandle.SleepCount;
  ScanTime := FolderScanHandle.ScanTime;
  FolderScanHandle.Free;
end;

constructor TFolderScanHandle.Create;
begin
  SourceFileHash := TScanFileHash.Create;
  DesFileHash := TScanFileHash.Create;
  SourceFolderHash := TScanFolderHash.Create;
  DesFolderHash := TScanFolderHash.Create;
  FileCount := 0;
  FileSize := 0;
  CompletedCount := 0;
  CompletedSize := 0;
  SleepCount := 0;
  ScanTime := Now;
  IsSupportDeleted := True;
  IsDesEmpty := False;
  IsDesReaded := False;
  EncryptType := EncryptType_No;
  PasswordExt := '';
end;

procedure TFolderScanHandle.DesFolderEmptyHandle;
begin

end;

destructor TFolderScanHandle.Destroy;
begin
  SourceFileHash.Free;
  DesFileHash.Free;
  SourceFolderHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TFolderScanHandle.FileCompare;
var
  p : TScanFilePair;
  SourceFileName, DesFileName : string;
begin
    // ���� Դ�ļ�
  for p in SourceFileHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextScan then
      Break;

      // ��ӵ�ͳ����Ϣ
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

      // �ļ���
    SourceFileName := p.Value.FileName;
    DesFileName := getDesFileName( SourceFileName );
    if DesFileName = '' then  // �ǽ����ļ�
      Continue;

      // Ŀ���ļ�������
    if not DesFileHash.ContainsKey( DesFileName ) then
    begin
      AddFileResult( SourceFileName, p.Value.FileSize );
      Continue;
    end;

      // Ŀ���ļ���Դ�ļ���һ��
    if not p.Value.getEquals( DesFileHash[ DesFileName ] ) then
    begin
      RemoveFileResult( DesFileName ); // ��ɾ��
      AddFileResult( SourceFileName, p.Value.FileSize );  // �����
    end
    else  // Ŀ���ļ���Դ�ļ�һ��
    begin
      CompletedSize := CompletedSize + p.Value.FileSize;
      CompletedCount := CompletedCount + 1;
    end;

      // ɾ��Ŀ���ļ�
    DesFileHash.Remove( DesFileName );
  end;

    // ����Ŀ���ļ�
  if IsSupportDeleted then
    for p in DesFileHash do
      RemoveFileResult( p.Value.FileName );  // ɾ��Ŀ���ļ�
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TScanFolderPair;
  FolderName : string;
begin
    // ����ԴĿ¼
  for p in SourceFolderHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextScan then
      Break;

    FolderName := p.Value.FolderName;

      // ������Ŀ��Ŀ¼���򴴽�
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName );

      // �Ƚ���Ŀ¼
    CompareChildFolder( FolderName );

      // �Ƴ���¼
    if DesFolderHash.ContainsKey( FolderName ) then
      DesFolderHash.Remove( FolderName );
  end;

    // ����Ŀ��Ŀ¼
  for p in DesFolderHash do
    RemoveFolderResult( p.Value.FolderName );
end;

function TFolderScanHandle.getChildPath(ChildName: string): string;
begin
  Result := MyFilePath.getPath( SourceFolderPath ) + ChildName;
end;

function TFolderScanHandle.getDesFileName(SourceFileName: string): string;
var
  LengthExt : Integer;
  IsEncrypt : Boolean;
begin
  Result := SourceFileName;
  if EncryptType = EncryptType_No then
  else  // ���� / ����
  if ( EncryptType = EncryptType_Enc ) or ( EncryptType = EncryptType_Dec ) then
  begin
    IsEncrypt := EncryptType = EncryptType_Enc;
      // ������һ�����ܵ��ļ�
    if ( not IsEncrypt ) and ( RightStr( SourceFileName, Length( PasswordExt ) ) <> PasswordExt ) then
      Result := ''
    else
      Result := MyFilePath.getDesFileName( SourceFileName, PasswordExt, IsEncrypt );
  end;
end;

procedure TFolderScanHandle.RemoveFileResult(FileName : string);
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFolderScanHandle.RemoveFolderResult(FolderName: string);
var
  ScanResultRemoveFolderInfo : TScanResultRemoveFolderInfo;
begin
  ScanResultRemoveFolderInfo := TScanResultRemoveFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultRemoveFolderInfo );
end;

procedure TFolderScanHandle.SetEncrypt(_EncryptType, _PasswordExt : string);
begin
  EncryptType := _EncryptType;
  PasswordExt := _PasswordExt;
end;

procedure TFolderScanHandle.SetIsDesEmpty(_IsDesEmpty: Boolean);
begin
  IsDesEmpty := _IsDesEmpty;
end;

procedure TFolderScanHandle.SetIsDesReaded(_IsDesReaded: Boolean);
begin
  IsDesReaded := _IsDesReaded;
end;

procedure TFolderScanHandle.SetIsSupportDeleted(_IsSupportDeleted: Boolean);
begin
  IsSupportDeleted := _IsSupportDeleted;
end;

procedure TFolderScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFolderScanHandle.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TFolderScanHandle.Update;
begin
    // ��Դ�ļ���Ϣ
  FindSourceFileInfo;

    // ���Ŀ�������Ŀ¼����ɨ��
  if not IsDesEmpty then
  begin
      // ��Ŀ���ļ���Ϣ
    FindDesFileInfo;

      // Ŀ��Ŀ¼�Ƿ������Ŀ¼
    IsDesEmpty := DesFolderHash.Count = 0;
  end
  else   // Ŀ��Ϊ�յĴ���
    DesFolderEmptyHandle;

    // �ļ��Ƚ�
  FileCompare;

    // Ŀ¼�Ƚ�
  FolderCompare;
end;

{ TFileScanHandle }

procedure TFileScanHandle.AddFileResult;
var
  FilePath : string;
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  FilePath := SourceFilePath;
  if EncryptType = EncryptType_Dec then
    FilePath := FilePath + PasswordExt;

  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( FilePath );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

constructor TFileScanHandle.Create;
begin
  ParentFileHash := TScanFileHash.Create;
end;

destructor TFileScanHandle.Destroy;
begin
  ParentFileHash.Free;
  inherited;
end;

procedure TFileScanHandle.FindParentFileHash;
begin

end;

function TFileScanHandle.IsEqualsDes: Boolean;
begin
  Result := ( SourceFileSize = DesFileSize ) and
            ( MyDatetime.Equals( SourceFileTime, DesFileTime ) );
end;

procedure TFileScanHandle.RemoveFileResult;
var
  DesFilePath : string;
  IsEncrypt : Boolean;
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
    // ����
  DesFilePath := SourceFilePath;
  if EncryptType = EncryptType_Enc then
    DesFilePath := DesFilePath + PasswordExt;

  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( DesFilePath );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFileScanHandle.RemoveOtherDesFile;
var
  DesFilePath : string;
  p : TScanFilePair;
  FileName, SourceFileName, DesFileName : string;
  ParentPath, RemovePath : string;
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
    // ��ȡ ���ļ���Ϣ
  FindParentFileHash;

    // Ѱ����ͬ���ļ�
  ParentPath := ExtractFilePath( SourceFilePath );
  SourceFileName := ExtractFileName( SourceFilePath );
  DesFileName := SourceFileName;
  if EncryptType = EncryptType_Enc then
    DesFileName := DesFileName + PasswordExt;
  for p in ParentFileHash do
  begin
    FileName := p.Value.FileName;
    if ( LeftStr( FileName, Length( SourceFileName ) ) = SourceFileName ) and
       ( FileName <> DesFileName ) and
       ( ( FileName = SourceFileName ) or ( Pos( Sign_Encrypt, ExtractFileExt( FileName ) ) > 0 ) )
    then
    begin
      RemovePath := MyFilePath.getPath( ParentPath ) + FileName;
      ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( RemovePath );
      ScanResultList.Add( ScanResultRemoveFileInfo );
    end;
  end;
end;

procedure TFileScanHandle.SetEncryptInfo(_EncryptType, _PasswordExt: string);
begin
  EncryptType := _EncryptType;
  PasswordExt := _PasswordExt;
end;

procedure TFileScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFileScanHandle.SetSourceFilePath(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

procedure TFileScanHandle.Update;
begin
  CompletedSize := 0;
  CompletedCount := 0;

    // Դ�ļ�������
  if not FindSourceFileInfo then
    Exit;

    // Ŀ���ļ�������
  if not FindDesFileInfo then
    AddFileResult
  else   // Ŀ���ļ���Դ�ļ���һ��
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
  begin
    CompletedSize := SourceFileSize;
    CompletedCount := 1;
  end;

    // ɾ�� ��ǰ�ļ����ļ�
  RemoveOtherDesFile;
end;


{ TLocalFolderFindHandle }

procedure TLocalFolderFindHandle.CheckSleep;
begin
    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TLocalFolderFindHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TLocalFolderFindHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  DesScanFileInfo : TScanFileInfo;
  DesScanFolderInfo : TScanFolderInfo;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
        // Cpu ����
      CheckSleep;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // �ļ�������
        Continue;

        // ��ӵ�Ŀ¼���
      if IsFolder then
      begin
        DesScanFolderInfo := TScanFolderInfo.Create( FileName );
        ScanFolderHash.AddOrSetValue( FileName, DesScanFolderInfo );
      end
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��ӵ��ļ����������
        DesScanFileInfo := TScanFileInfo.Create( FileName );
        DesScanFileInfo.SetFileInfo( FileSize, FileTime );
        ScanFileHash.AddOrSetValue( FileName, DesScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

{ TFolderFindHandle }

function TFolderFindHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := False;
end;

function TFolderFindHandle.IsFolderFilter(FolderPath: string): Boolean;
begin
  Result := False;
end;

procedure TFolderFindHandle.SetScanFile(_ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash
end;

procedure TFolderFindHandle.SetScanFolder(_ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

{ TNetworkFolderFindHandle }

procedure TNetworkFolderFindHandle.SendFileReq;
begin
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ReadFolder );
end;

{ TNetworkFolderAccessFindHandle }

procedure TNetworkFolderAccessFindHandle.SearchFolderInfo;
var
  HeatBeatHelper : THeatBeatHelper;
  LocalFolderFindAdvanceHandle : TLocalFolderFindAdvanceHandle;
begin
  HeatBeatHelper := THeatBeatHelper.Create( TcpSocket );

  LocalFolderFindAdvanceHandle := TLocalFolderFindAdvanceHandle.Create;
  LocalFolderFindAdvanceHandle.SetFolderPath( FolderPath );
  LocalFolderFindAdvanceHandle.SetScanFile( ScanFileHash );
  LocalFolderFindAdvanceHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindAdvanceHandle.SetSleepCount( 0 );
  LocalFolderFindAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );
  LocalFolderFindAdvanceHandle.Update;
  LocalFolderFindAdvanceHandle.Free;

  HeatBeatHelper.Free;
end;

{ TFileCopyHandle }

function TFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= CopyCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;

    // 1 ���� ˢ��һ�ν���
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // ˢ�½���
    RefreshCompletedSpace;

    RefreshTime := Now;
  end;
end;


constructor TFileCopyHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourceFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
  Position := 0;
  SleepCount := 0;
  AddCompletedSpace := 0;
  RefreshTime := Now;
  IsEncrypt := False;
  IsDecrypt := False;
  BufStream := TMemoryStream.Create;
  ReadStream := nil;
  WriteStream := nil;
end;

function TFileCopyHandle.CreateReadStream: Boolean;
begin
  try
    ReadStream := TFileStream.Create( SourceFilePath, fmOpenRead or fmShareDenyNone );

    if ReadStream.Size = MyFileInfo.getFileSize( SourceFilePath ) then
    begin
      ReadStream.Position := Position;
      Result := True;
    end
    else
    begin
      ReadStream.Free;
      ReadStream := nil;
      Result := False
    end;
  except
    ReadStream := nil;
    Result := False;
  end;
end;

function TFileCopyHandle.CreateWriteStream: Boolean;
begin
  try
      // Ŀ���ļ�
    if Position > 0 then  // ����
    begin
      WriteStream := TFileStream.Create( DesFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := Position;
    end
    else
    begin  // ��һ�δ�
      ForceDirectories( ExtractFileDir( DesFilePath ) );
      WriteStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );
    end;
    Result := True;
  except
    WriteStream := nil;
    Result := False;
  end;
end;

procedure TFileCopyHandle.DestoryStream;
begin
  try
    if Assigned( ReadStream ) then
    begin
      ReadStream.Free;
      ReadStream := nil;
    end;
    if Assigned( WriteStream ) then
    begin
      WriteStream.Free;
      WriteStream := nil;
    end;
  except
  end;
end;

destructor TFileCopyHandle.Destroy;
begin
  BufStream.Free;
  DestoryStream;
  inherited;
end;

procedure TFileCopyHandle.DesWriteSpaceLack;
begin

end;

function TFileCopyHandle.FileCopy: Boolean;
var
  Buf : TDataBuf;
  TotalReadSize, TotalWriteSize: Integer;
  RemainSize : Int64;
begin
  Result := False;

  try
    RemainSize := ReadStream.Size - Position;

    try    // �����ļ�
      while RemainSize > 0 do
      begin
          // ȡ������ �� �������
        if not CheckNextCopy then
          Break;

          // ���ļ�
        TotalReadSize := ReadBufStream; // ��ȡ 8MB �ļ�

          // ���ļ�����
        if TotalReadSize <= 0 then
        begin
          ReadFileError;
          Break;
        end;

          // д�ļ�
        TotalWriteSize := WriteBufStream;

          // д�ļ����� �� �ռ� ����
        if TotalWriteSize <> TotalReadSize then
        begin
          WriteFileError;
          Break;
        end;

          // ˢ��״̬
        RemainSize := RemainSize - TotalReadSize;
        Position := Position + TotalReadSize;
        AddCompletedSpace := AddCompletedSpace + TotalReadSize;
      end;
    except
    end;

      // �������ɿռ�
    RefreshCompletedSpace;

      // �����Ƿ������
    Result := RemainSize <= 0;
  except
  end;
end;

function TFileCopyHandle.getDesIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  FreeSize := MyHardDisk.getHardDiskFreeSize( ExtractFileDir( DesFilePath ) );

    // �Ƿ����㹻�Ŀռ�
  Result := FreeSize >= ( FileSize - Position ) ;
end;

procedure TFileCopyHandle.MarkContinusCopy;
begin

end;

function TFileCopyHandle.ReadBufStream: Integer;
var
  RemainSize : Int64;
  i, ReadSize, WriteSize : Integer;
  FullBufSize, TotalReadSize : Integer;
  Buf : TDataBuf;
begin
  DebugLock.DebugFile( 'Read Stream Data', SourceFilePath );
  Result := -1;

  try
    FullBufSize := SizeOf( Buf );
    RemainSize := ReadStream.Size - Position;
    BufStream.Clear;
    TotalReadSize := 0;
    for i := 0 to 15 do  // ��ȡ 8MB �ļ�
    begin
      ReadSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, ReadSize );

        // �����ļ�
      if IsEncrypt then
        CopyFileUtil.Encrypt( Buf, ReadSize, EncPassword )
      else
      if IsDecrypt then
        CopyFileUtil.Deccrypt( Buf, ReadSize, DecPassword );

        // ��ӵ�������
      WriteSize := BufStream.Write( Buf, ReadSize );
      if ReadSize <> WriteSize then  // û����ȫд��
        Exit;

        // ͳ�ƶ�ȡ����
      TotalReadSize := TotalReadSize + ReadSize;

        // ��ȡ ���
      if ( RemainSize - TotalReadSize ) <= 0 then
        Break;
    end;
    Result := TotalReadSize;
  except
  end;
end;

procedure TFileCopyHandle.ReadFileError;
begin

end;

procedure TFileCopyHandle.RefreshCompletedSpace;
begin

end;

procedure TFileCopyHandle.SetSpeedInfo(_RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TFileCopyHandle.SetDecPassword(_IsDecrypt : Boolean;_DecPassword: string);
begin
  IsDecrypt := _IsDecrypt;
  DecPassword := _DecPassword;
end;

procedure TFileCopyHandle.SetEncPassword(_IsEncrypt : Boolean;_EncPassword: string);
begin
  IsEncrypt := _IsEncrypt;
  EncPassword := _EncPassword;
end;

procedure TFileCopyHandle.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

function TFileCopyHandle.Update: Boolean;
begin
  DebugLock.DebugFile( 'Copy File', SourceFilePath );

  Result := False;

    // Դ�ļ�������
  if not FileExists( SourceFilePath ) then
    Exit;

    // �����ļ�������
  if ( Position > 0 ) and not FileExists( DesFilePath ) then
    Exit;

    // ��ȡ Դ�ļ���Ϣ
  FileSize := MyFileInfo.getFileSize( SourceFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );

    // Ŀ��·��û���㹻�Ŀռ�
  if not getDesIsEnoughSpace then
  begin
    DesWriteSpaceLack; // �ռ䲻��
    Exit;
  end;

    // �޷�����������
  if not CreateReadStream then
  begin
    ReadFileError;
    Exit;
  end;

    // �޷�����д����
  if not CreateWriteStream then
  begin
    WriteFileError;
    Exit;
  end;

    // �ļ� ����ʧ��
  if not FileCopy then
  begin
    MarkContinusCopy; // ���������Ϣ
    Exit;
  end;

      // �ر���
  DestoryStream;

      // �����޸�ʱ��
  MyFileSetTime.SetTime( DesFilePath, FileTime );
  Result := True;
end;

function TFileCopyHandle.WriteBufStream: Integer;
var
  RemainSize : Int64;
  i, ReadSize, WriteSize : Integer;
  FullBufSize, TotalWriteSize : Integer;
  Buf : TDataBuf;
begin
  DebugLock.DebugFile( 'Write Stream Data', SourceFilePath );
  Result := -1;

    // д�ļ�
  try
    RemainSize := BufStream.Size;
    BufStream.Position := 0;
    FullBufSize := SizeOf( Buf );
    TotalWriteSize := 0;
    while RemainSize > 0 do
    begin
      ReadSize := Min( FullBufSize, RemainSize );
      ReadSize := BufStream.Read( Buf, ReadSize );
      WriteSize := WriteStream.Write( Buf, ReadSize );
      if WriteSize <> ReadSize then // û����ȫд��
        Exit;
      RemainSize := RemainSize - WriteSize;
      TotalWriteSize := TotalWriteSize + WriteSize;
    end;
    Result := TotalWriteSize;
  except
  end;
end;

procedure TFileCopyHandle.WriteFileError;
begin

end;

{ TRefreshSpeedInfo }

function TRefreshSpeedInfo.AddCompleted(CompletedSpace: Integer): Boolean;
var
  SleepMisecond, SendMisecond : Integer;
  LastTime : TDateTime;
begin
  SpeedLock.Enter;

  Speed := Speed + CompletedSpace;
  Result := SecondsBetween( Now, SpeedTime ) >= 1;

    // �ٶ�����
  if IsLimited and ( Speed >= LimitSpeed ) and not Result then
  begin
    LastTime := IncSecond( SpeedTime, 1 );
    SleepMisecond := MilliSecondsBetween( LastTime, Now );
    Sleep( SleepMisecond );
    Result := True;
  end;

    // ���¼����ٶ�
  if Result then
  begin
    SendMisecond := MilliSecondsBetween( Now, SpeedTime );
    Speed := ( Speed * 1000 ) div SendMisecond;
    LastSpeed := Speed;
    Speed := 0;
    SpeedTime := Now;
  end;

  SpeedLock.Leave;
end;

constructor TRefreshSpeedInfo.Create;
begin
  Speed := 0;
  SpeedTime := Now;
  IsLimited := False;
  SpeedLock := TCriticalSection.Create;
end;

destructor TRefreshSpeedInfo.Destroy;
begin
  SpeedLock.Free;
  inherited;
end;

procedure TRefreshSpeedInfo.SetLimitInfo(_IsLimited: Boolean;
  _LimitSpeed: Int64);
begin
  IsLimited := _IsLimited;
  LimitSpeed := _LimitSpeed;
end;

{ TBackupFileReceiveHandle }

procedure TNetworkFileReceiveHandle.AddSpeedSpace(Space: Integer);
begin

end;

function TNetworkFileReceiveHandle.CheckNextReceive: Boolean;
begin
  Result := True;

    // 1 ���� ˢ��һ�ν���
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // ˢ�½���
    RefreshCompletedSpace;

    RefreshTime := Now;
  end;
end;

constructor TNetworkFileReceiveHandle.Create(_ReceiveFilePath: string);
begin
  ReceiveFilePath := _ReceiveFilePath;
  RefreshTime := Now;
  AddCompletedSpace := 0;
  FilePos := 0;
  IsStopTransfer := False;
  IsLostConn := False;
  BufStream := TMemoryStream.Create;
end;

function TNetworkFileReceiveHandle.CreateWriteStream: Boolean;
var
  IsCreateWrite, IsCreateRead : Boolean;
begin
  Result := False;

  try       // ����д����
    if FilePos > 0 then
    begin
      WriteStream := TFileStream.Create( ReceiveFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := FilePos;
    end
    else
    begin
      ForceDirectories( ExtractFileDir( ReceiveFilePath ) );
      WriteStream := TFileStream.Create( ReceiveFilePath, fmCreate or fmShareDenyNone );
    end;
    IsCreateWrite := True;
  except
    IsCreateWrite := False;
  end;

    // ֪ͨ���ͷ��Ƿ񴴽��ɹ�
  MySocketUtil.SendJsonStr( TcpSocket, 'IsCreateWrite', IsCreateWrite );
  if not IsCreateWrite then // ����ʧ��
  begin
    WriteFileError;
    Exit;
  end;

    // ��ȡ���ͷ��Ƿ񴴽��ɹ�
  IsCreateRead := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsCreateRead then // ���ͷ�����ʧ��
  begin
    WriteStream.Free;  // �ر�д����
    ReadFileError;
    Exit;
  end;

  Result := True;
end;

destructor TNetworkFileReceiveHandle.Destroy;
begin
  BufStream.Free;
  inherited;
end;

function TNetworkFileReceiveHandle.FileReceive: Boolean;
var
  RevStr : string;
  IsReadOK, IsSuccessRev, IsSuccessWrite : Boolean;
  ReadSize, BufSize, ReceiveSize, WriteSize, ZipSize : Integer;
begin
  Result := False;

  try   // ���� д����
    DebugLock.DebugFile( 'Create Write Stream', ReceiveFilePath );
    if not CreateWriteStream then // ����ʧ��, ��������
      Exit;

      // �������ռ���Ϣ
    FileSize := MySocketUtil.RevJsonInt64( TcpSocket );

    try
      while FileSize > FilePos do
      begin
          // ���� �Ƿ��ȡ�ļ��ɹ�
        IsReadOK := MySocketUtil.RevJsonBool( TcpSocket );
        if not IsReadOK then
        begin
          ReadFileError; // ���ļ�����
          Break;
        end;

          // ��ȡ ��ȡ�ļ��ռ�
        ReadSize := MySocketUtil.RevJsonInt( TcpSocket );

          // ��ȡ �����ļ��ռ�
        BufSize := MySocketUtil.RevJsonInt( TcpSocket );

          // ���� �ļ�
        DebugLock.DebugFile( 'Rev Stream Data', ReceiveFilePath );
        BufStream.Clear;
        IsSuccessRev := ReceiveBufStream( BufSize );

          // �Ƿ��������
        if not ReadIsNextRev( IsSuccessRev ) then
          Break;

          // д��
        DebugLock.DebugFile( 'Write Stream Data', ReceiveFilePath );
        WriteSize := WriteBufStream;

          // ����д��ռ�
        IsSuccessWrite := SendWriteSize( WriteSize, ReadSize );
        if not IsSuccessWrite then
          Break;

          // ˢ��ѹ���ռ�
        ZipSize := WriteSize - BufSize;
        if ZipSize <> 0 then
        begin
          AddCompletedSpace := AddCompletedSpace + ZipSize;
          AddSpeedSpace( ZipSize );
        end;

          // �ƶ��ļ�λ��
        FilePos := FilePos + WriteSize;
      end;

         // ����ˢ�� ��ɿռ���Ϣ
      LastRefreshCompletedSpace;

        // �Ƿ�ȫ������
      Result := FileSize = FilePos;
    except
    end;
    WriteStream.Free;
  except
  end;
end;

function TNetworkFileReceiveHandle.getIsEnoughSapce: Boolean;
var
  RemainSize : Int64;
  ReceiveFolderPath : string;
begin
  DebugLock.DebugFile( 'getIsEnoughSapce', ReceiveFilePath );

  Result := True;

    // �����Ƿ����㹻�Ŀռ䣬 �����ͽ��
  RemainSize := FileSize - FilePos;
  ReceiveFolderPath := ExtractFileDir( ReceiveFilePath );
  ForceDirectories( ReceiveFolderPath );
  Result := MyHardDisk.getHardDiskFreeSize( ReceiveFolderPath ) >= RemainSize;

    // �жϴ����Ƿ� FAT32, FAT32���4GB
  if Result and ( FileSize > 4 * Size_GB ) and MyHardDisk.getIsFAT32( ReceiveFilePath ) then
    Result := False;

  MySocketUtil.SendJsonStr( TcpSocket, 'IsEnoughSapce', BoolToStr( Result ) );

    // �ռ䲻��
  if not Result then
    RevFileLackSpaceHandle; // ȱ�ٿռ�Ĵ���
end;

function TNetworkFileReceiveHandle.getLimitBlockSize: Int64;
begin
  Result := -1;
end;

procedure TNetworkFileReceiveHandle.LastRefreshCompletedSpace;
begin
  DebugLock.DebugFile( 'LastRefreshCompleted', ReceiveFilePath );

  RefreshCompletedSpace;
end;

procedure TNetworkFileReceiveHandle.LostConnectError;
begin

end;

procedure TNetworkFileReceiveHandle.MarkContinusRev;
begin

end;

procedure TNetworkFileReceiveHandle.ReadFileError;
begin

end;

function TNetworkFileReceiveHandle.ReadIsNextRev( IsSuccessRev : Boolean ): Boolean;
begin
  Result := False;

    // ֹͣ����
  if IsStopTransfer then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // ����Ͽ�
  if IsLostConn then
  begin
    TcpSocket.Disconnect;
    LostConnectError; // ʧȥ����
    Exit;
  end;

    // �����ļ�����
  if not IsSuccessRev then
  begin
    TcpSocket.Disconnect;
    ReceiveFileError;
    Exit;
  end;

  Result := True;
end;

function TNetworkFileReceiveHandle.ReadIsStopTransfer: Boolean;
var
  IsStopSend, IsStopRev : Boolean;
begin
    // �Ƿ�ֹͣ����
  IsStopSend := MySocketUtil.RevJsonBool( TcpSocket );

    // �Ƿ�ֹͣ����
  IsStopRev := not CheckNextReceive;
  if IsStopRev then
    MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus',ReceiveStatus_Stop );

    // �Ƿ�ֹͣ����
  Result := IsStopSend or IsStopRev;

    // �����ٶ�����
  MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus', ReceiveStatus_LimitSpace );
  MySocketUtil.SendJsonStr( TcpSocket, 'LimitBlockSize', getLimitBlockSize );
end;

function TNetworkFileReceiveHandle.ReceiveBufStream(BufSize: Integer): Boolean;
var
  BufPos, RemainSize : Int64;
  RevSizeTotal, RevSize, RevRemainSize, RevPos : Int64;
begin
  try
      // ��ʼ����Ϣ
    BufPos := 0;
    RemainSize := BufSize;
    while RemainSize > 0 do
    begin
        // �����������
      RevStartTime := Now;

        // �������ݵ��ܿռ�
      RevSizeTotal :=  MySocketUtil.RevJsonInt64( TcpSocket );
      if RevSizeTotal <= 0 then // �����ѶϿ�
        IsLostConn := True;

        // ��������
      DebugLock.DebugFile( 'Rev Data Buf Start', ReceiveFilePath );
      RevRemainSize := RevSizeTotal;
      RevPos := 0;
      while RevRemainSize > 0 do
      begin
        RevSize := MySocketUtil.RevBuf( TcpSocket, SendDataBuf, RevRemainSize );
        if ( RevSize = SOCKET_ERROR ) or ( ( RevSize <= 0 ) and ( RevRemainSize > 0 ) ) then // Ŀ��Ͽ�����
        begin
          IsLostConn := True;
          Break;
        end;
        CopyMemory( @TotalSendDataBuf[RevPos], @SendDataBuf, RevSize );
        RevRemainSize := RevRemainSize - RevSize;
        RevPos := RevPos + RevSize;
      end;
      RevSizeTotal := RevSizeTotal - RevRemainSize;
      DebugLock.DebugFile( 'Rev Data Buf Stop', IntToStr( RevSizeTotal ) );

        // ���ý��յ�����
      BufStream.WriteBuffer( TotalSendDataBuf, RevSizeTotal );

        // ����ʣ���λ��
      BufPos := BufPos + RevSizeTotal;
      RemainSize := RemainSize - RevSizeTotal;
      AddCompletedSpace := AddCompletedSpace + RevSizeTotal; // ͳ����Ϣ
      AddSpeedSpace( RevSizeTotal ); // ˢ���ٶ�

        // ���������Ƿ�Ͽ�
      if IsLostConn then
        Break;

        // �Ƿ�ֹͣ����
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;

        // ���ͽ�������
      SendRevSpeed( RevSizeTotal );
    end;

      // ���ؽ��յĿռ���Ϣ
    Result := RemainSize = 0;
  except
    Result := False;
  end;

    // ��������ɽ���
  MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus', ReceiveStatus_Completed );
end;


procedure TNetworkFileReceiveHandle.ReceiveFileError;
begin

end;

procedure TNetworkFileReceiveHandle.RefreshCompletedSpace;
begin

end;

procedure TNetworkFileReceiveHandle.ResetFileTime;
begin
    // �����ļ��޸�ʱ��
  MyFileSetTime.SetTime( ReceiveFilePath, FileTime );
end;

procedure TNetworkFileReceiveHandle.RevFileLackSpaceHandle;
begin

end;

procedure TNetworkFileReceiveHandle.SendRevSpeed(RevSize: Int64);
var
  RevTime, RevSpeed : Int64;
begin
    // ��������λ
  RevSize := RevSize * 1000;

    // ���˶��ٺ���
  RevTime := MilliSecondsBetween( Now, RevStartTime );
  RevTime := Max( 1, RevTime );

    // ��λ�Ǽ䴫��Ŀռ�
  RevSpeed := RevSize div RevTime;

    // ���� 2 KB
  RevSpeed := Max( 2 * Size_KB, RevSpeed );

    // ���ͽ�������
  MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus', ReceiveStatus_Speed );
  MySocketUtil.SendJsonStr( TcpSocket, 'RevSpeed', RevSpeed );
end;

function TNetworkFileReceiveHandle.SendWriteSize(WriteSize, ReadSize: Integer): Boolean;
var
  IsEnoughSpace : Boolean;
begin
  Result := True;

  MySocketUtil.SendJsonStr( TcpSocket, 'WriteSize', WriteSize );
  if WriteSize = ReadSize then  // д��ɹ�
    Exit;

      // �Ƿ����㹻�Ŀռ�
  IsEnoughSpace :=  MyHardDisk.getHardDiskFreeSize( ExtractFileDir( ReceiveFilePath ) ) >= ( FileSize - FilePos );
  MySocketUtil.SendData( TcpSocket, IsEnoughSpace );
  if not IsEnoughSpace then
    RevFileLackSpaceHandle  // �ռ䲻��
  else
    WriteFileError; // д�ļ�����

  Result := False;
end;

procedure TNetworkFileReceiveHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

function TNetworkFileReceiveHandle.Update: Boolean;
var
  TimeStr : string;
begin
  DebugLock.DebugFile( 'Reveice File', ReceiveFilePath );

  Result := False;

    // �����ļ���Ϣ
  FileSize := StrToInt64Def( MySocketUtil.RevJsonStr( TcpSocket ), -1 );
  FilePos := StrToInt64Def( MySocketUtil.RevJsonStr( TcpSocket ), -1 );
  TimeStr := MySocketUtil.RevJsonStr( TcpSocket );
  FileTime := MyRegionUtil.ReadLocalTime( TimeStr );

    // �Ѿ��Ͽ�����
  if ( FileSize = -1 ) or ( FilePos = -1 ) or ( FileTime = -1 ) then
  begin
    TcpSocket.Disconnect;
    LostConnectError;
    Exit;
  end;

    // �ռ䲻��
  if not getIsEnoughSapce then
    Exit;

    // �ļ�����
  if not FileReceive then
  begin
    MarkContinusRev; // ���� ����
    Exit;
  end;

    // �����ļ��޸�ʱ��
  ResetFileTime;

  Result := True;
end;

function TNetworkFileReceiveHandle.WriteBufStream: Integer;
var
  StartTime : TDateTime;
  TempStream, ActivateStream : TMemoryStream;
  WriteSize, RemainSize : Integer;
  FullBufSize, WriteDataSize : Integer;
  DataBuf : TDataBuf;
begin
  TempStream := TMemoryStream.Create;

  try
      // ��ѹ���ļ������ѹ
    StartTime := Now;
    DebugLock.Debug( 'Uncompress Data Stream: ' + ReceiveFilePath );
    ActivateStream := BufStream;
    if not MyFilePath.getIsZip( ReceiveFilePath ) then
    begin
      ActivateStream := TempStream;
      SendFileUtil.DecompressStream( BufStream, TempStream );
    end;

      // д�ļ�
    WriteSize := 0;
    RemainSize := ActivateStream.Size;
    ActivateStream.Position := 0;
    FullBufSize := SizeOf( DataBuf );
    while RemainSize > 0 do
    begin
      WriteDataSize := Min( FullBufSize, RemainSize );
      ActivateStream.ReadBuffer( DataBuf, WriteDataSize );
      WriteDataSize := WriteStream.Write( DataBuf, WriteDataSize );
      if WriteDataSize <= 0 then
        Break;
      WriteSize := WriteSize + WriteDataSize;
      RemainSize := RemainSize - WriteDataSize;
      HeartBeatReceiver.CheckSend( TcpSocket, StartTime );
    end;
  except
  end;
  Result := WriteSize;

  TempStream.Free;
end;

procedure TNetworkFileReceiveHandle.WriteFileError;
begin

end;

{ TNetworkFileSendHandle }

procedure TNetworkFileSendHandle.AddSpeedSpace(Space: Integer);
begin

end;

function TNetworkFileSendHandle.CheckNextSend: Boolean;
begin
  Result := True;

    // 1 ���� ˢ��һ�ν���
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // ˢ�½���
    RefreshCompletedSpace;

    RefreshTime := Now;
  end;
end;

constructor TNetworkFileSendHandle.Create(_SendFilePath: string);
begin
  SendFilePath := _SendFilePath;
  RefreshTime := Now;
  AddCompletedSpace := 0;
  RevLimitSpace := -1;
  IsStopTransfer := False;
  IsLostConn := False;
  BufStream := TMemoryStream.Create;
  WatchRevThread := TWatchRevThread.Create;
end;

function TNetworkFileSendHandle.CreateReadStream: Boolean;
var
  IsCreateWrite, IsCreateRead : Boolean;
begin
  Result := False;

    // ��ȡ���շ��Ƿ񴴽��ɹ�
  IsCreateWrite := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsCreateWrite then  // ���շ�����ʧ��
  begin
    WriteFileError;
    Exit;
  end;

    // �������ļ���
  try
    ReadStream := TFileStream.Create( SendFilePath, fmOpenRead or fmShareDenyNone );
    IsCreateRead := True;
  except
    IsCreateRead := False;
  end;

    // delphi bug �ж��Ƿ����ռ��ȡ����
  if IsCreateRead then
  begin
    IsCreateRead := ReadStream.Size = MyFileInfo.getFileSize( SendFilePath );
    if not IsCreateRead then
      ReadStream.Free;
  end;

    // �Ƿ񴴽��������ɹ�
  MySocketUtil.SendJsonStr( TcpSocket, 'IsCreateRead', IsCreateRead );
  if not IsCreateRead then  // ����������ʧ��
  begin
    ReadFileError;
    Exit;
  end;

  Result := True;
end;

destructor TNetworkFileSendHandle.Destroy;
begin
  WatchRevThread.Free;
  BufStream.Free;
  inherited;
end;

function TNetworkFileSendHandle.FileSend: Boolean;
var
  ReadSize, BufSize, ZipSize : Integer;
  IsReadOK, IsSendSuccess, IsWriteSuccess : Boolean;
begin
  Result := False;

  try
      // ������ʧ��
    if not CreateReadStream then
      Exit;

      // �������ռ���Ϣ
    FileSize := ReadStream.Size;
    MySocketUtil.SendJsonStr( TcpSocket, 'StreamFileSize', FileSize );

    try
        // �����ļ�
      ReadStream.Position := FilePos;  // �ƶ��ļ�λ��
      while FileSize > FilePos do
      begin
          // ͳ��Ҫ���͵Ŀռ�
        DebugLock.DebugFile( 'Read Stream Data', SendFilePath );
        ReadSize := ReadBufStream;  // ��ȡ 8M ���ݣ�����ʵ�ʶ�ȡ�Ŀռ���Ϣ

          // ��ȡ�ļ� �Ƿ�ɹ�
        IsReadOK := ReadSize <> -1;
        MySocketUtil.SendJsonStr( TcpSocket, 'IsReadOK', IsReadOK );
        if not IsReadOK then // ��ȡ����
        begin
          ReadFileError; // ��������
          Break;
        end;

          // ���� �ļ���ȡ�ռ�
        MySocketUtil.SendJsonStr( TcpSocket, 'ReadSize', ReadSize );

          // ���� �ļ����Ϳռ�
        BufSize := BufStream.Size;
        MySocketUtil.SendJsonStr( TcpSocket, 'BufSize', BufSize );

          // ���� 8M ����
        DebugLock.DebugFile( 'Send Stream Data', SendFilePath );
        WatchRevThread.StartWatch;
        IsSendSuccess := SendBufStream;
        WatchRevThread.StopWatch;

          // �Ƿ��������
        if not ReadIsNextSend( IsSendSuccess ) then
          Break;

          // д��ʧ��
        IsWriteSuccess := RevWriteSize( ReadSize );
        if not IsWriteSuccess then
          Break;

          // ��� ѹ���ռ�
        ZipSize := ReadSize - BufSize;
        if ZipSize <> 0 then
        begin
          AddCompletedSpace := AddCompletedSpace + ZipSize;
          AddSpeedSpace( ZipSize );
        end;

          // �����ѷ��͵��ļ�λ��
        FilePos := FilePos + ReadSize;
      end;

        // ����ˢ��
      RefreshCompletedSpace;

        // �Ƿ������
      Result := FileSize = FilePos;
    except
    end;
    ReadStream.Free;
  except
  end;
end;

function TNetworkFileSendHandle.getIsEnouthSpace: Boolean;
var
  IsEnoughSpaceStr : string;
  IsEnoughSpace : Boolean;
begin
  DebugLock.DebugFile( 'getIsEnouthSpace', SendFilePath );

  Result := False;

    // ���� �Ƿ����㹻�Ŀռ�
  IsEnoughSpaceStr := MySocketUtil.RevJsonStr( TcpSocket );
  if IsEnoughSpaceStr = '' then // Ŀ�� Pc �Ͽ�����
  begin
    TcpSocket.Disconnect;
    LostConnectError;
    Exit;
  end;

   //  �Ƿ����㹻�Ŀռ�
  IsEnoughSpace := StrToBoolDef( IsEnoughSpaceStr, False );
  if not IsEnoughSpace then
  begin
    RevFileLackSpaceHandle; // ����ȱ�ٿռ�
    Exit;
  end;

  Result := True;
end;

function TNetworkFileSendHandle.getLimitBlockSize: Int64;
begin
  Result := -1;
end;

procedure TNetworkFileSendHandle.LostConnectError;
begin

end;

procedure TNetworkFileSendHandle.MarkContinusSend;
begin

end;

procedure TNetworkFileSendHandle.ReadFileError;
begin

end;

function TNetworkFileSendHandle.ReadIsNextSend( IsSendSuccess : Boolean ): Boolean;
begin
  Result := False;

      // ֹͣ����
  if IsStopTransfer or WatchRevThread.IsRevStop then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // ����Ͽ�
  if IsLostConn or WatchRevThread.IsRevLostConn then
  begin
    TcpSocket.Disconnect;
    LostConnectError; // ʧȥ����
    Exit;
  end;

    // δ֪�Ĵ���, δ�����ط����ļ�
  if not IsSendSuccess or not WatchRevThread.IsRevCompleted then
  begin
    TcpSocket.Disconnect;
    SendFileError;
    Exit;
  end;

  Result := True;
end;

function TNetworkFileSendHandle.ReadIsStopTransfer: Boolean;
var
  IsStopSend, IsStopRev : Boolean;
begin
    // �Ƿ�ֹͣ����
  IsStopSend := not CheckNextSend;
  MySocketUtil.SendJsonStr( TcpSocket, 'IsStopSend', IsStopSend );

    // �Ƿ�ֹͣ����
  IsStopRev := WatchRevThread.IsRevStop;

    // �Ƿ�ֹͣ����
  Result := IsStopSend or IsStopRev;

    // �����ٶ�����
  RevLimitSpace := WatchRevThread.RevLimitSpace;
end;

function TNetworkFileSendHandle.ReadSendBlockSize: Int64;
var
  LimitBlockSize : Int64;
begin
  Result := WatchRevThread.RevSpeed;
  LimitBlockSize := getLimitBlockSize;
  if LimitBlockSize > 0 then
    Result := Min( Result, LimitBlockSize );
  if RevLimitSpace > 0 then
    Result := Min( Result, RevLimitSpace );
  Result := Max( Result, 1 * Size_KB ); // ���� 1 KB
end;

function TNetworkFileSendHandle.RevWriteSize( ReadSize : Integer ): Boolean;
var
  WriteSizeStr : string;
  WriteSize : Integer;
  IsEnouthSpace : Boolean;
begin
  Result := True;

    // ��ȡ �Է�д��Ŀռ���Ϣ��������
  WriteSizeStr := MySocketUtil.RevJsonStr( TcpSocket );
  if WriteSizeStr = '' then  // д��ʱ�䳬�����������ӶϿ�
  begin
    WriteFileError;
    Result := False;
    Exit;
  end;

    // ת��Ϊ�ռ���Ϣ
  WriteSize := StrToIntDef( WriteSizeStr, 0 );
  if WriteSize = ReadSize then // ��Ҫ���͵Ŀռ�һ��
    Exit;

    // ��ȡ�Ƿ���Ϊ�ռ䲻��
  IsEnouthSpace := MySocketUtil.RevBoolData( TcpSocket );
  if not IsEnouthSpace then
    RevFileLackSpaceHandle  // �ռ䲻��
  else
    WriteFileError; // д������

  Result := False;
end;

function TNetworkFileSendHandle.ReadBufStream: Integer;
var
  StartTime : TDateTime;
  RemainSize : Int64;
  TempStream, ActivateStream : TMemoryStream;
  i, BufSize, ReadSize : Integer;
  FullBufSize, TotalReadSize : Integer;
  Buf : TDataBuf;
begin
  TempStream := TMemoryStream.Create;
  BufStream.Clear;

    // �������ѹ���ļ�����ѹ���ļ�
  ActivateStream := BufStream;
  if not MyFilePath.getIsZip( SendFilePath ) then
    ActivateStream := TempStream;

  try
      // ��ȡ 8M ����
    StartTime := Now;
    RemainSize := ReadStream.Size - ReadStream.Position;
    FullBufSize := SizeOf( Buf );
    TotalReadSize := 0;
    for i := 0 to 15 do
    begin
      BufSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, BufSize );
      if ( ReadSize <= 0 ) and ( ReadSize <> BufSize ) then // ��ȡ����
        Exit;
      TotalReadSize := TotalReadSize + ReadSize;
      ActivateStream.WriteBuffer( Buf, ReadSize );
      if ( RemainSize - TotalReadSize ) <= 0 then // ��ȡ���
        Break;
      HeartBeatReceiver.CheckSend( TcpSocket, StartTime ); // ��ʱ��������
    end;

      // ѹ����
    if not MyFilePath.getIsZip( SendFilePath ) then
      SendFileUtil.CompressStream( TempStream, BufStream );

      // ����
    Result := TotalReadSize;
  except
    Result := -1;
  end;

  TempStream.Free;
end;

procedure TNetworkFileSendHandle.RefreshCompletedSpace;
begin

end;

procedure TNetworkFileSendHandle.RevFileLackSpaceHandle;
begin

end;

function TNetworkFileSendHandle.SendBufStream: Boolean;
var
  BufPos, RemainSize : Int64;
  TotalSendSize, SendSize, SendRemainSize, SendPos : Int64;
begin
  try
      // ��ʼ����Ϣ
    BufPos := 0;
    RemainSize := BufStream.Size;
    BufStream.Position := 0;
    while RemainSize > 0 do
    begin
        // ��ȡ �������ݵĴ�С
      TotalSendSize := ReadSendBlockSize;
      TotalSendSize := Min( TotalSendSize, RemainSize );
      TotalSendSize := Min( TotalSendSize, SIzeOf( TotalSendDataBuf ) );
      MySocketUtil.SendJsonStr( TcpSocket, 'TotalSendSize', TotalSendSize );

        // �����ѶϿ�
      if TotalSendSize <= 0 then
        IsLostConn := True;

        // ��ȡ Ҫ���͵�����
      BufStream.ReadBuffer( TotalSendDataBuf, TotalSendSize );

        // ��������
      DebugLock.DebugFile( 'Send Data Buf Start', SendFilePath );
      SendRemainSize := TotalSendSize;
      SendPos := 0;
      while SendRemainSize > 0 do
      begin
          // ���Ʒ��͵�����
        CopyMemory( @SendDataBuf, @TotalSendDataBuf[SendPos], SendRemainSize );

          // ��������
        SendSize := TcpSocket.SendBuf( SendDataBuf, SendRemainSize );
        if ( SendSize = SOCKET_ERROR ) or ( ( SendSize <= 0 ) and ( SendRemainSize > 0 ) ) then // Ŀ��Ͽ�����
        begin
          IsLostConn := True;
          Break;
        end;
        SendRemainSize := SendRemainSize - SendSize;
        SendPos := SendPos + SendSize;
      end;
      TotalSendSize := TotalSendSize - SendRemainSize;
      DebugLock.DebugFile( 'Send Data Buf Stop', IntToStr( TotalSendSize ) );

        // ����ʣ���λ��
      BufPos := BufPos + TotalSendSize;
      RemainSize := RemainSize - TotalSendSize;
      AddCompletedSpace := AddCompletedSpace + TotalSendSize;
      AddSpeedSpace( TotalSendSize ); // ˢ���ٶ�

        // �ѶϿ�����
      if IsLostConn or WatchRevThread.IsRevLostConn then
        Break;

        // ֹͣ����
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;
    end;

      // ���� ���͵Ŀռ���Ϣ
    Result := RemainSize = 0;
  except
    Result := False;
  end;
end;

procedure TNetworkFileSendHandle.SendFileError;
begin

end;

procedure TNetworkFileSendHandle.SetFilePos(_FilePos: Int64);
begin
  FilePos := _FilePos;
end;

procedure TNetworkFileSendHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  WatchRevThread.SetTcpSocket( TcpSocket );
end;

function TNetworkFileSendHandle.Update: Boolean;
begin
  DebugLock.DebugFile( 'Send File', SendFilePath );

  Result := False;

    // ���� �ļ���Ϣ
  FileSize := MyFileInfo.getFileSize( SendFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SendFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileSize', FileSize );
  MySocketUtil.SendJsonStr( TcpSocket, 'FilePos', FilePos );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileTime', MyRegionUtil.ReadRemoteTimeStr( FileTime ) );

    // �ռ䲻�� �� �ѶϿ�����
  if not getIsEnouthSpace then
    Exit;

    // �ļ�����
  if not FileSend then
  begin
    MarkContinusSend; // ��������
    Exit;
  end;

  Result := True;
end;

procedure TNetworkFileSendHandle.WriteFileError;
begin

end;

{ TFileFindHandle }

constructor TFileFindHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TFileFindHandle.getFileSize: Int64;
begin
  Result := FileSize;
end;

function TFileFindHandle.getFileTime: TDateTime;
begin
  Result := FileTime;
end;

function TFileFindHandle.getIsExist: Boolean;
begin
  Result := IsExist;
end;

{ TLocalFileFindHandle }

procedure TLocalFileFindHandle.Update;
begin
  IsExist := FileExists( FilePath );
  if not IsExist then
    Exit;
  FileSize := MyFileInfo.getFileSize( FilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( FilePath );
end;

{ TNetworkFileFindHandle }

procedure TNetworkFileFindHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileFindHandle.Update;
var
  TimeStr : string;
begin
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ReadFile );
  MySocketUtil.SendJsonStr( TcpSocket, 'FilePath', FilePath );
  IsExist := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsExist then // Ŀ���ļ�������
    Exit;
  FileSize := MySocketUtil.RevJsonInt64( TcpSocket );
  TimeStr := MySocketUtil.RevJsonStr( TcpSocket );
  FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
end;

{ TNetworkFileAccessFindHandle }

constructor TNetworkFileAccessFindHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TNetworkFileAccessFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileAccessFindHandle.Update;
var
  LocalFileFindHandle : TLocalFileFindHandle;
  IsExist : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
begin
    // ��ȡ�ļ���Ϣ
  LocalFileFindHandle := TLocalFileFindHandle.Create( FilePath );
  LocalFileFindHandle.Update;
  IsExist := LocalFileFindHandle.getIsExist;
  FileSize := LocalFileFindHandle.getFileSize;
  FileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;

    // �����ļ���Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, 'IsExist', BoolToStr( IsExist ) );
  if not IsExist then
    Exit;
  MySocketUtil.SendJsonStr( TcpSocket, 'FileSize', IntToStr( FileSize ) );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileTime', MyRegionUtil.ReadRemoteTimeStr( FileTime ) );
end;

{ TDesFileRecycleHandle }

procedure TFileRecycleHandle.CheckKeedEditionCount;
var
  ExistEditionCount : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
  ExistEditionCount := getExistEditionCount;
  if ( ExistEditionCount = 0 ) or ( SaveDeletedEdition = 0 ) then
    Exit;

    // �汾 ������
    // ɾ�� ��Ͱ汾
  if ExistEditionCount >= SaveDeletedEdition then
  begin
    FilePath1 := getEditionPath( RecycledPath, SaveDeletedEdition - 1 );
    MyFolderDelete.FileDelete( FilePath1 );
  end;

    // �����汾��
  ExistEditionCount := Min( ExistEditionCount, SaveDeletedEdition  );

    // �汾����
  for i := ExistEditionCount downto 2 do
  begin
    FilePath1 := getEditionPath( RecycledPath, i - 1 );
    FilePath2 := getEditionPath( RecycledPath, i );
    RenameFile( FilePath1, FilePath2 );
  end;

    // ��ǰ�汾��Ϊ���һ���汾
  RenameFile( RecycledPath, getEditionPath( RecycledPath, 1 ) )
end;


constructor TFileRecycleHandle.Create(_DesFilePath, _RecycledPath: string);
begin
  DesFilePath := _DesFilePath;
  RecycledPath := _RecycledPath;
  IsEcnrtyped := False;
  PasswordExt := '';
end;

function TFileRecycleHandle.FileCopy: Boolean;
begin
end;

procedure TFileRecycleHandle.FileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

function TFileRecycleHandle.getEditionPath(FilePath: string;
  EditionNum: Integer): string;
var
  Params : TEditonPathParams;
begin
  Params.FilePath := FilePath;
  Params.EditionNum := EditionNum;
  Params.IsEncrypted := IsEcnrtyped;
  Params.PasswordExt := PasswordExt;

  Result := FileRecycledUtil.getEditionPath( Params );
end;

function TFileRecycleHandle.getExistEditionCount: Integer;
begin
  Result := 0;
  if not FileExists( RecycledPath ) then
    Exit;
  Inc( Result );

  while FileExists( getEditionPath( RecycledPath, Result ) ) do
    Inc( Result );
end;


procedure TFileRecycleHandle.SetEncryptInfo(_IsEcnrtyped: Boolean;
  _PasswordExt: string);
begin
  IsEcnrtyped := _IsEcnrtyped;
  PasswordExt := _PasswordExt;
end;

procedure TFileRecycleHandle.SetSaveDeletedEdition(
  _SaveDeletedEdition: Integer);
begin
  SaveDeletedEdition := _SaveDeletedEdition;
end;

procedure TFileRecycleHandle.Update;
begin
    // ��鱣��İ汾��
  CheckKeedEditionCount;

    // �ļ�����
  if FileCopy then
    FileRemove; // �ļ�ɾ��
end;

{ FileRecycledUtil }

class function FileRecycledUtil.getEditionPath(Params : TEditonPathParams): string;
var
  IsEncrypted : Boolean;
  PasswordExt : string;
  FilePath : string;
  AfterStr : string;
  BeforeStr : string;
begin
  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.PasswordExt;

  FilePath := Params.FilePath;
  if IsEncrypted then
    FilePath := MyFilePath.getDesFilePath( FilePath, PasswordExt, False );

  AfterStr := ExtractFileExt( FilePath );
  BeforeStr := MyString.CutStopStr( AfterStr, FilePath );
  FilePath := BeforeStr + '.(' + IntToStr( Params.EditionNum ) + ')' + AfterStr;

  if IsEncrypted then
    FilePath := MyFilePath.getDesFilePath( FilePath, PasswordExt, True );

  Result := FilePath;
end;


{ TFolderRecycleHandle }

function TFolderRecycleHandle.CheckNextRecycled: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

constructor TFolderRecycleHandle.Create(_DesFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
  SleepCount := 0;
  IsEncrypt := False;
  PasswordExt := '';
end;

procedure TFolderRecycleHandle.FolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TFolderRecycleHandle.SearchFile(FileName: string);
begin

end;

procedure TFolderRecycleHandle.SearchFolder(FolderName: string);
begin

end;

procedure TFolderRecycleHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordExt: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordExt := _PasswordExt;
end;

procedure TFolderRecycleHandle.SetKeepEditionCount(_KeepEditionCount: Integer);
begin
  KeepEditionCount := _KeepEditionCount;
end;

procedure TFolderRecycleHandle.SetRecycleFolderPath(_RecycleFolderPath: string);
begin
  RecycleFolderPath := _RecycleFolderPath;
end;

procedure TFolderRecycleHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TFolderRecycleHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextRecycled then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( FileName )
      else
        SearchFile( FileName );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // Ŀ¼ɾ��
  FolderRemove;
end;

{ TScanFolderInfo }

constructor TScanFolderInfo.Create(_FolderName: string);
begin
  FolderName := _FolderName;
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
  IsReaded := False;
end;

destructor TScanFolderInfo.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

{ TNetworkChildFolderFindHandle }

procedure TNetworkFolderFindDeepHandle.SendFileReq;
begin
  MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_ReadFolderDeep );
end;

{ TFindNetworkFolderResultHandle }

constructor TFindNetworkFullFolderResultHandle.Create(_ReadResultStr: string);
begin
  ReadResultStr := _ReadResultStr;
end;

procedure TFindNetworkFullFolderResultHandle.ReadFile;
var
  FindNetworkFileResultHandle : TFindNetworkFileResultHandle;
begin
  FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( FileStr );
  FindNetworkFileResultHandle.SetScanFile( ScanFileHash );
  FindNetworkFileResultHandle.Update;
  FindNetworkFileResultHandle.Free;
end;

procedure TFindNetworkFullFolderResultHandle.ReadFolder;
var
  FindNetworkFolderResultHandle : TFindNetworkFolderResultHandle;
begin
  FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( FolderStr );
  FindNetworkFolderResultHandle.SetScanFolder( ScanFolderHash );
  FindNetworkFolderResultHandle.SetFolderLevel( 1 );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;
end;

procedure TFindNetworkFullFolderResultHandle.SetScanFile(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TFindNetworkFullFolderResultHandle.SetScanFolder(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

procedure TFindNetworkFullFolderResultHandle.Update;
var
  TypeList : TStringList;
begin
  TypeList := MySplitStr.getList( ReadResultStr, FolderListSplit_Type );
  if TypeList.Count = Type_Count then
  begin
    FolderStr := TypeList[ Type_Folder ];
    FileStr := TypeList[ Type_File ];

      // ��ȡ Ŀ¼��Ϣ
    if FolderStr <> Type_Empty then
      ReadFolder;

      // ��ȡ �ļ���Ϣ
    if FileStr <> Type_Empty then
      ReadFile;
  end;
  TypeList.Free;
end;

{ TFindNetworkFolderResultHandle }

constructor TFindNetworkFolderResultHandle.Create(_FolderStr: string);
begin
  FolderStr := _FolderStr;
  FolderLevel := 1;
end;

procedure TFindNetworkFolderResultHandle.ReadFolderInfo(FolderInfoStr: string);
var
  FolderInfoSplit : string;
  FolderInfoList : TStringList;
  ScanFolderInfo : TScanFolderInfo;
  FolderName : string;
  IsReaded : Boolean;
  ChildFiles, ChildFolders : string;
  FindNetworkFileResultHandle : TFindNetworkFileResultHandle;
  FindNetworkFolderResultHandle : TFindNetworkFolderResultHandle;
begin
    // ��ͬĿ¼��Ĳ�ͬ�ָ���
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [ IntToStr( FolderLevel ) ] );

    // ��ȡĿ¼��Ϣ
  FolderInfoList := MySplitStr.getList( FolderInfoStr, FolderInfoSplit );
  if FolderInfoList.Count = FolderInfo_Count then
  begin
      // ��ȡ��Ϣ
    FolderName := FolderInfoList[ Info_FolderName ];
    IsReaded := StrToBoolDef( FolderInfoList[ Info_IsReaded ], False );
    ChildFiles := FolderInfoList[ Info_FolderChildFiles ];
    ChildFolders := FolderInfoList[ Info_FolderChildFolders ];

      // ����Ŀ¼
    ScanFolderInfo := TScanFolderInfo.Create( FolderName );
    ScanFolderInfo.IsReaded := IsReaded;
    ScanFolderHash.AddOrSetValue( FolderName, ScanFolderInfo );

      // Ŀ¼��Ϣ�Ѿ���ȡ
    if IsReaded then
    begin
        // ��ȡ���ļ�
      FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( ChildFiles );
      FindNetworkFileResultHandle.SetScanFile( ScanFolderInfo.ScanFileHash );
      FindNetworkFileResultHandle.Update;
      FindNetworkFileResultHandle.Free;

        // ��ȡ��Ŀ¼
      FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( ChildFolders );
      FindNetworkFolderResultHandle.SetScanFolder( ScanFolderInfo.ScanFolderHash );
      FindNetworkFolderResultHandle.SetFolderLevel( FolderLevel + 1 ); // ��һ��
      FindNetworkFolderResultHandle.Update;
      FindNetworkFolderResultHandle.Free;
    end;
  end;
  FolderInfoList.Free;
end;

procedure TFindNetworkFolderResultHandle.SetFolderLevel(_FolderLevel: Integer);
begin
  FolderLevel := _FolderLevel;
end;

procedure TFindNetworkFolderResultHandle.SetScanFolder(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

procedure TFindNetworkFolderResultHandle.Update;
var
  FolderSplit : string;
  FolderList : TStringList;
  i: Integer;
begin
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );

  FolderList := MySplitStr.getList( FolderStr, FolderSplit );
  for i := 0 to FolderList.Count - 1 do
    ReadFolderInfo( FolderList[i] );
  FolderList.Free;
end;

{ ScanFileInfoUtil }

class procedure ScanFileInfoUtil.CopyFile(OldFileHash,
  NewFileHash: TScanFileHash);
var
  p: TScanFilePair;
  ScanFileInfo : TScanFileInfo;
begin
  for p in NewFileHash do
  begin
    ScanFileInfo := TScanFileInfo.Create( p.Value.FileName );
    ScanFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    OldFileHash.Add( p.Value.FileName, ScanFileInfo );
  end;
end;

class procedure ScanFileInfoUtil.CopyFolder(OldFOlderHash,
  NewFolderHash: TScanFolderHash);
var
  p: TScanFolderPair;
  NewFolderInfo : TScanFolderInfo;
begin
  for p in NewFolderHash do
  begin
    NewFolderInfo := TScanFolderInfo.Create( p.Value.FolderName );
    OldFOlderHash.AddOrSetValue( p.Value.FolderName, NewFolderInfo );
  end;
end;

{ TFindNetworkFileResultHandle }

constructor TFindNetworkFileResultHandle.Create(_FileStr: string);
begin
  FileStr := _FileStr;
end;

procedure TFindNetworkFileResultHandle.ReadFileInfo(FileInfoStr: string);
var
  FileInfoList : TStringList;
  FileName : string;
  FileSize : Int64;
  TimeStr : string;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
begin
  FileInfoList := MySplitStr.getList( FileInfoStr, FolderListSplit_FileInfo );
  if FileInfoList.Count = FileInfo_Count then
  begin
    FileName := FileInfoList[ Info_FileName ];
    FileSize := StrToInt64Def( FileInfoList[ Info_FileSize ], 0 );
    TimeStr := FileInfoList[ Info_FileTime ];
    FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
    ScanFileInfo := TScanFileInfo.Create( FileName );
    ScanFileInfo.SetFileInfo( FileSize, FileTime );
    ScanFileHash.AddOrSetValue( FileName, ScanFileInfo );
  end;
  FileInfoList.Free;
end;

procedure TFindNetworkFileResultHandle.SetScanFile(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TFindNetworkFileResultHandle.Update;
var
  FileList : TStringList;
  i: Integer;
begin
  FileList := MySplitStr.getList( FileStr, FolderListSplit_File );
  for i := 0 to FileList.Count - 1 do
    ReadFileInfo( FileList[i] );
  FileList.Free;
end;

{ TGetNetworkFileResultStrHandle }

constructor TGetNetworkFileResultStrHandle.Create(_ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

function TGetNetworkFileResultStrHandle.get: string;
var
  FileStr, FileInfoStr : string;
  p : TScanFilePair;
begin
    // ���ļ���Ϣ
  FileStr := '';
  for p in ScanFileHash do
  begin
    if FileStr <> '' then
      FileStr := FileStr + FolderListSplit_File;
    FileInfoStr := p.Value.FileName + FolderListSplit_FileInfo;
    FileInfoStr := FileInfoStr + IntToStr( p.Value.FileSize ) + FolderListSplit_FileInfo ;
    FileInfoStr := FileInfoStr + MyRegionUtil.ReadRemoteTimeStr( p.Value.FileTime );
    FileStr := FileStr + FileInfoStr;
  end;

    // û���ļ��ı�־
  if FileStr = '' then
    FileStr := Type_Empty;

  Result := FileStr;
end;

{ CopyFileUtil }

class procedure SendFileUtil.CompressStream(SourceStream,
  ComStream: TMemoryStream);
var
  cs: TCompressionStream; {����ѹ����}
  num: Integer;           {ԭʼ�ļ���С}
begin
  num := SourceStream.Size;
  ComStream.Write(num, SizeOf(num));

  cs := TCompressionStream.Create(ComStream);
  SourceStream.SaveToStream(cs);
  cs.Free;
end;

class procedure SendFileUtil.Deccrypt(var Buf: TSendBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, False );
end;

class procedure SendFileUtil.DecompressStream(ComStream,
  DesStream: TMemoryStream);
var
  ds: TDecompressionStream;
  num: Integer;
begin
    // ��ȡԴ���Ŀռ���Ϣ
  ComStream.Position := 0;
  ComStream.ReadBuffer(num,SizeOf(num));
  DesStream.SetSize(num);

    // ��ѹ
  ds := TDecompressionStream.Create(ComStream);
  ds.Read(DesStream.Memory^, num);
  ds.Free;
end;


class procedure SendFileUtil.Encrypt(var Buf: TSendBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, True );
end;

class procedure SendFileUtil.EncryptData(var Buf: TSendBuf; BufSize: Integer;
  Key: string; IsEncrypt: Boolean);
var
  Key64 : TKey64;
  Context    : TDESContext;
  EncryptChar : Char;
  BlockCount, BlockSize, RemainSize : Integer;
  i, j, StartPos : Integer;
  Block : TDESBlock;
begin
  GenerateLMDKey( Key64, SizeOf(Key64), Key );
  InitEncryptDES( Key64, Context, IsEncrypt );

    // ���ܿ�
  BlockSize := SizeOf( Block );
  BlockCount := ( BufSize div BlockSize );
  for i := 0 to BlockCount - 1 do
  begin
    StartPos := i * BlockSize;
    for j := 0 to BlockSize - 1 do
      Block[j] := Buf[ StartPos + j ];
    EncryptDES(Context, Block);
    for j := 0 to BlockSize - 1 do
      Buf[ StartPos + j ] := Block[j];
  end;

    // ���ܲ����Ĳ���
  StartPos := BlockCount * BlockSize;
  RemainSize := BufSize mod BlockSize;
  for i := 0 to RemainSize - 1 do
  begin
    j := ( i mod Length( Key ) ) + 1;
    EncryptChar := Key[j];
    if IsEncrypt then
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] + Integer( EncryptChar ) ) mod 256
    else
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] - Integer( EncryptChar ) ) mod 256
  end;
end;

{ SendFileUtil }

class procedure CopyFileUtil.Deccrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, False );
end;

class procedure CopyFileUtil.Encrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, True );
end;

class procedure CopyFileUtil.EncryptData(var Buf: TDataBuf; BufSize: Integer;
  Key: string; IsEncrypt: Boolean);
var
  Key64 : TKey64;
  Context    : TDESContext;
  EncryptChar : Char;
  BlockCount, BlockSize, RemainSize : Integer;
  i, j, StartPos : Integer;
  Block : TDESBlock;
begin
  GenerateLMDKey( Key64, SizeOf(Key64), Key );
  InitEncryptDES( Key64, Context, IsEncrypt );

    // ���ܿ�
  BlockSize := SizeOf( Block );
  BlockCount := ( BufSize div BlockSize );
  for i := 0 to BlockCount - 1 do
  begin
    StartPos := i * BlockSize;
    for j := 0 to BlockSize - 1 do
      Block[j] := Buf[ StartPos + j ];
    EncryptDES(Context, Block);
    for j := 0 to BlockSize - 1 do
      Buf[ StartPos + j ] := Block[j];
  end;

    // ���ܲ����Ĳ���
  StartPos := BlockCount * BlockSize;
  RemainSize := BufSize mod BlockSize;
  for i := 0 to RemainSize - 1 do
  begin
    j := ( i mod Length( Key ) ) + 1;
    EncryptChar := Key[j];
    if IsEncrypt then
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] + Integer( EncryptChar ) ) mod 256
    else
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] - Integer( EncryptChar ) ) mod 256
  end;
end;

{ TMyDataBuf }

procedure TMyDataBuf.AddBuf(var InputBuf: TDataBuf; BufSize: Integer);
var
  DataBufObj : TDataBufObj;
begin
  DataBufObj := TDataBufObj.Create( InputBuf, BufSize );
  DataBufList.Add( DataBufObj );
end;

procedure TMyDataBuf.Clear;
begin
  DataBufList.Clear;
end;

constructor TMyDataBuf.Create;
begin
  DataBufList := TDataBufList.Create;
end;

destructor TMyDataBuf.Destroy;
begin
  DataBufList.Free;
  inherited;
end;

procedure TMyDataBuf.ReadBuf( var OutputBuf : TDataBuf; BufPos, BufSize : Integer );
var
  ReadPos, ReadNum, WritePos, TotalReadSize, ReadSize, BlockReadSize : Integer;
  i: Integer;
begin
  ReadPos := BufPos;
  for i := 0 to DataBufList.Count - 1 do
  begin
    if DataBufList[i].BufSize <= ReadPos then
    begin
      ReadPos := ReadPos - DataBufList[i].BufSize;
      Continue;
    end;
    ReadNum := i;
    Break;
  end;

  TotalReadSize := BufSize;
  WritePos := 0;
  while TotalReadSize > 0 do
  begin
    BlockReadSize := DataBufList[ ReadNum ].BufSize - ReadPos;
    ReadSize := Min( BlockReadSize, TotalReadSize );
    CopyMemory( @OutputBuf[WritePos], @DataBufList[ ReadNum ].DataBuf[ReadPos], ReadSize );

      // ��ȥ�Ѷ�ȡ��
    TotalReadSize := TotalReadSize - ReadSize;

      // �ƶ�дλ��
    WritePos := WritePos + ReadSize;

      // ��ȡ��һ��
    inc( ReadNum );
    ReadPos := 0;
  end;
end;

{ TDataBufObj }

constructor TDataBufObj.Create( _DataBuf : TDataBuf; _BufSize : Integer );
begin
  DataBuf := _DataBuf;
  BufSize := _BufSize;
end;

{ TFolderSearchHandle }

function TFolderSearchHandle.CheckNextSearch: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // 1 ���� ˢ��һ�� �������
    if SecondsBetween( now , RefreshTime ) >= 1 then
    begin
      HandleResultHash; // ������
      ResultFileHash.Clear;
      ResultFolderHash.Clear;

      if getIsStop then // ��������Ͽ�����
        Result := False;
      RefreshTime := Now;
    end;
  end;
end;

constructor TFolderSearchHandle.Create;
begin
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
  RefreshTime := Now;
  SleepCount := 0;
end;

destructor TFolderSearchHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

function TFolderSearchHandle.FindResultHash: Boolean;
var
  p : TScanFilePair;
  ResultFileInfo : TScanFileInfo;
  ParentPath, ChildPath : string;
  FileName : string;
  pf : TScanFolderPair;
  ResultFolderInfo : TScanFolderInfo;
begin
  Result := True;

  ParentPath := MyFilePath.getPath( ResultFolderPath );

    // �����ļ�
  for p in ScanFileHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��ȡ�ļ���
    FileName := p.Value.FileName;
    if IsEncrypted then  // �ļ�������
      FileName := MyFilePath.getDesFileName( FileName, PasswordExt, False );

      // ��������������
    if not MyMatchMask.Check( FileName, SearchName ) then
      Continue;

      // ��ӵ����������
    ChildPath := ParentPath + FileName;
    ResultFileInfo := TScanFileInfo.Create( ChildPath );
    ResultFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    ResultFileHash.AddOrSetValue( ChildPath, ResultFileInfo );
  end;
  ScanFileHash.Clear; // �ͷ��ڴ�

    // ��������
  if not Result then
    Exit;

    // ����Ŀ¼
  for pf in ScanFolderHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��������������
    if not MyMatchMask.Check( pf.Value.FolderName, SearchName ) then
      Continue;

      // ��ӵ����������
    ChildPath := ParentPath + pf.Value.FolderName;
    ResultFolderInfo := TScanFolderInfo.Create( ChildPath );
    ResultFolderHash.AddOrSetValue( ChildPath, ResultFolderInfo );
  end;
end;

function TFolderSearchHandle.FindScanHash: Boolean;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // ����Ŀ¼��Ϣ
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( FolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( ScanFileHash );
  LocalFolderFindHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;

  Result := CheckNextSearch;
end;

function TFolderSearchHandle.getIsStop: Boolean;
begin
  Result := False;
end;

procedure TFolderSearchHandle.LastRefresh;
begin
  HandleResultHash;
end;

function TFolderSearchHandle.SearchChildFolder: Boolean;
var
  ParentPath, ParentResultFolderPath, ChildPath, ChildResultFolderPath : string;
  pf : TScanFolderPair;
  FolderSearchHandle : TFolderSearchHandle;
begin
  Result := True;

  ParentPath := MyFilePath.getPath( FolderPath );
  ParentResultFolderPath := MyFilePath.getPath( ResultFolderPath );

    // ����Ŀ¼
  for pf in ScanFolderHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��ӵ����������
    ChildPath := ParentPath + pf.Value.FolderName;
    ChildResultFolderPath := ParentResultFolderPath + pf.Value.FolderName;
    FolderSearchHandle := getFolderSearchHandle;
    FolderSearchHandle.SetFolderPath( ChildPath );
    FolderSearchHandle.SetSerachName( SearchName );
    FolderSearchHandle.SetResultFolderPath( ChildResultFolderPath );
    FolderSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
    FolderSearchHandle.SetRefreshTime( RefreshTime );
    FolderSearchHandle.SetSleepCount( SleepCount );
    FolderSearchHandle.SetResultFile( ResultFileHash );
    FolderSearchHandle.SetResultFolder( ResultFolderHash );
    Result := FolderSearchHandle.Update;
    RefreshTime := FolderSearchHandle.RefreshTime;
    SleepCount := FolderSearchHandle.SleepCount;
    FolderSearchHandle.Free;

      // ��������
    if not Result then
      Break;
  end;
end;

procedure TFolderSearchHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TFolderSearchHandle.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

procedure TFolderSearchHandle.SetRefreshTime(_RefreshTime: TDateTime);
begin
  RefreshTime := _RefreshTime;
end;

procedure TFolderSearchHandle.SetResultFile(_ResultFileHash: TScanFileHash);
begin
  ResultFileHash := _ResultFileHash;
end;

procedure TFolderSearchHandle.SetResultFolder(
  _ResultFolderHash: TScanFolderHash);
begin
  ResultFolderHash := _ResultFolderHash;
end;

procedure TFolderSearchHandle.SetResultFolderPath(_ResultFolderPath: string);
begin
  ResultFolderPath := _ResultFolderPath;
end;

procedure TFolderSearchHandle.SetSerachName(_SearchName: string);
begin
  SearchName := _SearchName;
end;

procedure TFolderSearchHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

function TFolderSearchHandle.Update: Boolean;
begin
    // �����ļ���Ϣ
  Result := FindScanHash and FindResultHash and SearchChildFolder;
end;

{ TNetworkFolderSearchHandle }

constructor TNetworkFolderSearchHandle.Create;
begin
  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;
end;

destructor TNetworkFolderSearchHandle.Destroy;
begin
  ResultFileHash.Free;
  ResultFolderHash.Free;
  inherited;
end;

function TNetworkFolderSearchHandle.getIsStop: Boolean;
begin
  Result := False;
end;

procedure TNetworkFolderSearchHandle.HandleResult(ResultStr: string);
var
  FindNetworkFolderResultHandle : TFindNetworkFullFolderResultHandle;
begin
    // ��ȡ��Ϣ
  FindNetworkFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( ResultStr );
  FindNetworkFolderResultHandle.SetScanFile( ResultFileHash );
  FindNetworkFolderResultHandle.SetScanFolder( ResultFolderHash );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;

    // ��������Ϣ
  HandleResultHash;

    // ����Ѵ�����Ϣ
  ResultFileHash.Clear;
  ResultFolderHash.Clear;
end;

procedure TNetworkFolderSearchHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderSearchHandle.Update;
var
  ResultStr : string;
  IsStop : Boolean;
begin
  while True do
  begin
    DebugLock.Debug( 'Wait Search Result' );
    ResultStr := MySocketUtil.RevData( TcpSocket );
    if ResultStr = FolderSearchResult_End then // ��������
      Break;
    if ResultStr = '' then  // �Ͽ�������
    begin
      TcpSocket.Disconnect;
      Break;
    end;
      // �����������
    HandleResult( ResultStr );

      // �ж��Ƿ�ֹͣ����
    IsStop := getIsStop;
    MySocketUtil.SendData( TcpSocket, IsStop );

      // ��������
    if IsStop then
      Break;
  end;
end;

{ TNetworkFolderSearchAccessHandle }

function TNetworkFolderSearchAccessHandle.getFolderSearchHandle: TFolderSearchHandle;
var
  NetworkFolderSearchAccessHandle : TNetworkFolderSearchAccessHandle;
begin
  NetworkFolderSearchAccessHandle := TNetworkFolderSearchAccessHandle.Create;
  NetworkFolderSearchAccessHandle.SetTcpSocket( TcpSocket );
  Result := NetworkFolderSearchAccessHandle;
end;

function TNetworkFolderSearchAccessHandle.getIsStop: Boolean;
begin
  Result := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), True );
end;

procedure TNetworkFolderSearchAccessHandle.HandleResultHash;
var
  GetNetworkFullFolderResultStrHandle : TGetNetworkFullFolderResultStrHandle;
  ReadResultStr : string;
begin
    // ���������ת��Ϊ�ַ���
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ResultFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ResultFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // ���Ͷ�ȡ���
  MySocketUtil.SendData( TcpSocket, ReadResultStr );
end;

procedure TNetworkFolderSearchAccessHandle.LastRefresh;
begin
  inherited;

  MySocketUtil.SendData( TcpSocket, FolderSearchResult_End );
end;

procedure TNetworkFolderSearchAccessHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TGetNetworkFolderResultStrHandle }

constructor TGetNetworkFolderResultStrHandle.Create(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
  FolderLevel := 1;
end;

function TGetNetworkFolderResultStrHandle.get: string;
var
  FolderStr, FolderInfoStr: string;
  ps : TScanFolderPair;
  FolderSplit, FolderInfoSplit : string;
begin
    // ÿһ��Ŀ¼�ķָ�������һ��
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [IntToStr( FolderLevel )] );

    // Ŀ¼��Ϣ
  FolderStr := '';
  for ps in ScanFolderHash do
  begin
    if FolderStr <> '' then
      FolderStr := FolderStr + FolderSplit;
    FolderInfoStr := ps.Value.FolderName + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + BoolToStr( ps.Value.IsReaded ) + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + getChildFileStr( ps.Value.FolderName ) + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + getChildFolderStr( ps.Value.FolderName );
    FolderStr := FolderStr + FolderInfoStr;
  end;

    // û��Ŀ¼�ı�־
  if FolderStr = '' then
    FolderStr := Type_Empty;

    // ����
  Result := FolderStr;
end;

function TGetNetworkFolderResultStrHandle.getChildFileStr(
  FolderName: string): string;
var
  GetNetworkFileResultStrHandle : TGetNetworkFileResultStrHandle;
begin
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFolderHash[ FolderName ].ScanFileHash );
  Result := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;
end;

function TGetNetworkFolderResultStrHandle.getChildFolderStr(
  FolderName: string): string;
var
  GetNetworkFolderResultStrHandle : TGetNetworkFolderResultStrHandle;
begin
  GetNetworkFolderResultStrHandle := TGetNetworkFolderResultStrHandle.Create( ScanFolderHash[ FolderName ].ScanFolderHash );
  GetNetworkFolderResultStrHandle.SetFolderLevel( FolderLevel + 1 ); // ��һ��
  Result := GetNetworkFolderResultStrHandle.get;
  GetNetworkFolderResultStrHandle.Free;
end;

procedure TGetNetworkFolderResultStrHandle.SetFolderLevel(
  _FolderLevel: Integer);
begin
  FolderLevel := _FolderLevel;
end;

{ TGetNetworkFullFolderResultStrHandle }

function TGetNetworkFullFolderResultStrHandle.get: string;
var
  FolderStr, FileStr : string;
begin
    // Ŀ¼��Ϣ�б�
  FolderStr := getFolderStr;

    // �ļ���Ϣ�б�
  FileStr := getFileStr;

    // ���
  Result := FolderStr + FolderListSplit_Type + FileStr;
end;

function TGetNetworkFullFolderResultStrHandle.getFileStr: string;
var
  GetNetworkFileResultStrHandle : TGetNetworkFileResultStrHandle;
begin
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFileHash );
  Result := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;
end;

function TGetNetworkFullFolderResultStrHandle.getFolderStr: string;
var
  GetNetworkFolderResultStrHandle : TGetNetworkFolderResultStrHandle;
begin
  GetNetworkFolderResultStrHandle := TGetNetworkFolderResultStrHandle.Create( ScanFolderHash );
  GetNetworkFolderResultStrHandle.SetFolderLevel( 1 );
  Result := GetNetworkFolderResultStrHandle.get;
  GetNetworkFolderResultStrHandle.Free;
end;

procedure TGetNetworkFullFolderResultStrHandle.SetFileHash(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TGetNetworkFullFolderResultStrHandle.SetFolderHash(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

{ TNetworkFilePreviewSendHandle }

function TNetworkFilePreviewPictureSendHandle.CreateReadStream: Boolean;
var
  InpuParams : TInputParams;
  OutputParams : TOutputParams;
  Img, SmallImg : TGPImage;
  Stream : IStream;
  ImgGUID :TGUID;
begin
  try
    Img := TGPImage.Create( SendFilePath );

    InpuParams.SourceWidth := Img.GetWidth;
    InpuParams.SourceHeigh := Img.GetHeight;
    InpuParams.DesWidth := PreviewWidth;
    InpuParams.DesHeigh := PreviewHeight;
    InpuParams.IsKeepSpace := False;
    MyPictureUtil.FindPreviewPoint( InpuParams, OutputParams );

    SmallImg := Img.GetThumbnailImage( OutputParams.ShowWidth, OutputParams.ShowHeigh );

    ReadStream := TMemoryStream.Create;
    Stream := TStreamAdapter.Create( ReadStream );
    GetEncoderClsid('image/jpeg', ImgGUID);
    SmallImg.Save( Stream, ImgGUID );
    SmallImg.Free;

    Img.Free;

    Result := True;
  except
    Result := False;
  end;

    // �����Ƿ񴴽��ɹ�
  MySocketUtil.SendData( TcpSocket, Result );
end;

procedure TNetworkFilePreviewPictureSendHandle.SetPreviewSize(_PreviewWidth,
  _PreviewHeight: Integer);
begin
  PreviewWidth := _PreviewWidth;
  PreviewHeight := _PreviewHeight;
end;

{ TNetworkFilePreviewSendHandle }

function TNetworkFilePreviewSendHandle.getIsEnouthSpace: Boolean;
begin
  Result := True;
end;

{ TNetworkFilePreviewTextSendHandle }

function TNetworkFilePreviewTextSendHandle.CreateReadStream: Boolean;
var
  FileStream : TStream;
  Buf : TDataBuf;
  ReadSize : Integer;
begin
  Result := True;

  try    // ��ȡ 512KB ����
    FileStream := TFileStream.Create( SendFilePath, fmOpenRead or fmShareDenyNone );
    try
      if FileStream.Size > Size_MB then  // ���� 1 MB ���ܲ����ı��ļ�
        ReadSize := 1 * Size_KB
      else  // ֻ��ȡ�����ļ���
        ReadSize := Min( FileStream.Size, SizeOf( Buf ) );

      ReadSize := FileStream.Read( Buf, ReadSize );
    except
      Result := False;
    end;
      FileStream.Free;
  except
    Result := False;
  end;

    // ��ȡ �ɹ�
  if Result then
  begin
       // Ԥ�� 512KB ����
    try
      ReadStream := TMemoryStream.Create;
      ReadStream.WriteBuffer( buf, ReadSize );
    except
      Result := False;
    end;
  end;

      // �����Ƿ񴴽��ɹ�
  MySocketUtil.SendData( TcpSocket, Result );
end;

{ TNetworkFilePreviewExeSendHandle }

function TNetworkFilePreviewExeSendHandle.CreateReadStream: Boolean;
var
  ico : TIcon;
begin
  ReadStream := TMemoryStream.Create;

  ico := TIcon.Create;
  try
    ico.Handle := ExtractIcon(HInstance, PChar(SendFilePath), 0);
    ico.SaveToStream(ReadStream);
    Result := True;
  except
    ReadStream.Free;
    Result := False;
  end;
  ico.Free;

      // �����Ƿ񴴽��ɹ�
  MySocketUtil.SendData( TcpSocket, Result );
end;

{ TLocalFolderFindDeepHandle }

function TLocalFolderFindDeepHandle.CreateSearchChildFolder: TLocalFolderFindDeepHandle;
begin
  Result := TLocalFolderFindDeepHandle.Create;
end;

function TLocalFolderFindDeepHandle.CreateSearchLocalFolder: TLocalFolderFindHandle;
begin
  Result := TLocalFolderFindHandle.Create;
end;

procedure TLocalFolderFindDeepHandle.SearchChildFolder;
var
  p : TScanFolderPair;
  ChildFolderPath : string;
  LocalFolderFindDeepHandle : TLocalFolderFindDeepHandle;
begin
  for p in ScanFolderHash do
  begin
        // ������Χ������
    if DeepCount >= DeepCount_Max then
      Break;

    ChildFolderPath := MyFilePath.getPath( FolderPath ) + p.Value.FolderName;

    LocalFolderFindDeepHandle := CreateSearchChildFolder;
    LocalFolderFindDeepHandle.SetFolderPath( ChildFolderPath );
    LocalFolderFindDeepHandle.SetScanFile( p.Value.ScanFileHash );
    LocalFolderFindDeepHandle.SetScanFolder( p.Value.ScanFolderHash );
    LocalFolderFindDeepHandle.SetDeepCount( DeepCount );
    LocalFolderFindDeepHandle.SetSleepCount( SleepCount );
    LocalFolderFindDeepHandle.Update;
    DeepCount := LocalFolderFindDeepHandle.DeepCount;
    SleepCount := LocalFolderFindDeepHandle.SleepCount;
    LocalFolderFindDeepHandle.Free;

    p.Value.IsReaded := True;
  end;
end;


procedure TLocalFolderFindDeepHandle.SearchLocalFolder;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
  LocalFolderFindHandle := CreateSearchLocalFolder;
  LocalFolderFindHandle.SetFolderPath( FolderPath );
  LocalFolderFindHandle.SetScanFile( ScanFileHash );
  LocalFolderFindHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;

  DeepCount := DeepCount + ScanFileHash.Count;
  DeepCount := DeepCount + ScanFolderHash.Count;
end;

procedure TLocalFolderFindDeepHandle.SetDeepCount(_DeepCount: Integer);
begin
  DeepCount := _DeepCount;
end;

procedure TLocalFolderFindDeepHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TLocalFolderFindDeepHandle.Update;
begin
    // ������ǰĿ¼
  SearchLocalFolder;

    // ������Ŀ¼
  SearchChildFolder;
end;

{ TNetworkChildFolderAccessFindHandle }

procedure TNetworkFolderAccessFindDeepHandle.SearchFolderInfo;
var
  HeatBeatHelper : THeatBeatHelper;
  LocalFolderFindDeepAdvanceHandle : TLocalFolderFindDeepAdvanceHandle;
begin
  HeatBeatHelper := THeatBeatHelper.Create( TcpSocket );

  LocalFolderFindDeepAdvanceHandle := TLocalFolderFindDeepAdvanceHandle.Create;
  LocalFolderFindDeepAdvanceHandle.SetFolderPath( FolderPath );
  LocalFolderFindDeepAdvanceHandle.SetScanFile( ScanFileHash );
  LocalFolderFindDeepAdvanceHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindDeepAdvanceHandle.SetDeepCount( 0 );
  LocalFolderFindDeepAdvanceHandle.SetSleepCount( 0 );
  LocalFolderFindDeepAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );
  LocalFolderFindDeepAdvanceHandle.Update;
  LocalFolderFindDeepAdvanceHandle.Free;

  HeatBeatHelper.Free;
end;

{ TFolderFindBaseHandle }

procedure TFolderFindBaseHandle.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

{ TFolderAccessFindHandle }

constructor TFolderAccessFindHandle.Create;
begin
  inherited;
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
end;

destructor TFolderAccessFindHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

{ TNetworkFolderFindBaseHandle }

procedure TNetworkFolderFindBaseHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderFindBaseHandle.Update;
var
  FolderReadResult : string;
  FindNetworkFolderResultHandle : TFindNetworkFullFolderResultHandle;
begin
    // ����������Ϣ
  SendFileReq;
  MySocketUtil.SendJsonStr( TcpSocket, 'FolderPath', FolderPath );

    // ���ս����Ϣ�� ������
  FolderReadResult := MySocketUtil.RevJsonStr( TcpSocket );
  if FolderReadResult = '' then  // �Է��Ͽ�����
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // ��ȡ��Ϣ
  FindNetworkFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( FolderReadResult );
  FindNetworkFolderResultHandle.SetScanFile( ScanFileHash );
  FindNetworkFolderResultHandle.SetScanFolder( ScanFolderHash );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;
end;

{ TNetworkFolderAccessFindBaseHandle }

procedure TNetworkFolderAccessFindBaseHandle.SendFolderInfo;
var
  GetNetworkFullFolderResultStrHandle : TGetNetworkFullFolderResultStrHandle;
  ReadResultStr : string;
begin
    // ���������ת��Ϊ�ַ���
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ScanFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ScanFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // ���Ͷ�ȡ���
  MySocketUtil.SendJsonStr( TcpSocket, 'ReadResultStr', ReadResultStr );
end;

procedure TNetworkFolderAccessFindBaseHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderAccessFindBaseHandle.Update;
begin
    // ����Ŀ¼��Ϣ
  SearchFolderInfo;

    // �����������
  SendFolderInfo;
end;

{ TScanResultAddZipInfo }

procedure TScanResultAddZipInfo.SetTotalSize(_TotalSize: Int64);
begin
  TotalSize := _TotalSize;
end;

procedure TScanResultAddZipInfo.SetZipStream(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

{ TScanResultAddFileInfo }

procedure TScanResultAddFileInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

{ TWatchReceiveStatusThread }

constructor TWatchRevThread.Create;
begin
  inherited Create;
  RevSpeed := 2 * Size_KB;
  RevLimitSpace := -1;
  IsRevStop := False;
  IsRevLostConn := False;
  IsRevCompleted := False;
end;

destructor TWatchRevThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TWatchRevThread.Execute;
var
  RevStr : string;
begin
  while not Terminated do
  begin
    RevStr := MySocketUtil.RevJsonStr( TcpSocket );
    if RevStr = ReceiveStatus_Speed then  // ���ý����ٶ�
      RevSpeed := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_LimitSpace then  // ���մ�������
      RevLimitSpace := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_Stop then  // ֹͣ����
      IsRevStop := True
    else
    begin
      if RevStr = ReceiveStatus_Completed then // �������
        IsRevCompleted := True
      else                                // ���նϿ�
        IsRevLostConn := True;

      if not Terminated then
        Suspend;
    end;
  end;
end;

procedure TWatchRevThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TWatchRevThread.StartWatch;
begin
  IsRevStop := False;
  IsRevCompleted := False;
  IsRevLostConn := False;
  Resume;
end;

procedure TWatchRevThread.StopWatch;
begin
    // ������� �� �Ѿ��Ͽ�����
  while not IsRevCompleted and not IsRevLostConn do
    Sleep( 100 );
end;


{ TLocalFolderFindAdvanceHandle }

procedure TLocalFolderFindAdvanceHandle.CheckSleep;
begin
  inherited;

     // ��ʱ��������
  HeatBeatHelper.CheckHeartBeat;
end;

procedure TLocalFolderFindAdvanceHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

{ TLocalFolderFindDeepAdvanceHandle }

function TLocalFolderFindDeepAdvanceHandle.CreateSearchChildFolder: TLocalFolderFindDeepHandle;
var
  LocalFolderFindDeepAdvanceHandle : TLocalFolderFindDeepAdvanceHandle;
begin
  LocalFolderFindDeepAdvanceHandle := TLocalFolderFindDeepAdvanceHandle.Create;
  LocalFolderFindDeepAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );

  Result := LocalFolderFindDeepAdvanceHandle;
end;

function TLocalFolderFindDeepAdvanceHandle.CreateSearchLocalFolder: TLocalFolderFindHandle;
var
  LocalFolderFindAdvanceHandle : TLocalFolderFindAdvanceHandle;
begin
  LocalFolderFindAdvanceHandle := TLocalFolderFindAdvanceHandle.Create;
  LocalFolderFindAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );

  Result := LocalFolderFindAdvanceHandle;
end;

procedure TLocalFolderFindDeepAdvanceHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

{ TFindAdvaceObj }

procedure THeatBeatHelper.CheckHeartBeat;
begin
    // ��ʱ��������
  HeartBeatReceiver.CheckSend( TcpSocket, StartTime );
end;

constructor THeatBeatHelper.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  StartTime := Now;
end;

{ HeartBeatReader }

class procedure HeartBeatReceiver.CheckSend(TcpSocket: TCustomIpClient;
  var StartTime: TDateTime);
begin
    // ��ʱ��������
  if SecondsBetween( Now, StartTime ) > 10 then
  begin
    StartTime := Now;
    MySocketUtil.SendJsonStr( TcpSocket, 'FileReq', FileReq_HeartBeat );
  end;
end;

class function HeartBeatReceiver.CheckReceive(TcpSocket: TCustomIpClient): string;
begin
  while True do
  begin
    Result := MySocketUtil.RevJsonStr( TcpSocket );
    if Result <> FileReq_HeartBeat then  // ����������ȴ�����
      Break;
  end;
end;

end.

