unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UMyUtil, UModelUtil, UMyTcp, sockets,
     Classes, Math, winapi.winsock, StrUtils, LbCipher,LbProc, uDebugLock,
     Winapi.GDIPAPI, Winapi.GDIPOBJ, winapi.GDIPUTIL, Winapi.ActiveX, graphics, shellapi, uDebug, zlib, SyncObjs;

type

{$Region ' 文件扫描 ' }

     // 搜索的文件信息
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

      // 搜索目录的信息
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

      // 信息 辅助类
  ScanFileInfoUtil = class
  public
    class procedure CopyFile( OldFileHash, NewFileHash : TScanFileHash );
    class procedure CopyFolder( OldFOlderHash, NewFolderHash : TScanFolderHash );
  end;


  {$Region ' 扫描目录 结果信息 ' }

    // 文件比较结果
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // 添加 文件
  TScanResultAddFileInfo = class( TScanResultInfo )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
  end;

    // 添加 目录
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // 删除 文件
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // 删除 目录
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

    // 添加 压缩文件
  TScanResultAddZipInfo = class( TScanResultInfo )
  public
    ZipStream : TMemoryStream;
    TotalSize : Int64;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

    // 获取 压缩文件
  TScanResultGetZipInfo = class( TScanResultInfo )
  end;

  {$EndRegion}

  {$Region ' 扫描目录 算法 ' }

  {$Region ' 扫描父类 ' }

    // 搜索目录 父类
  TFolderFindBaseHandle = class
  public
    FolderPath : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFolderPath( _FolderPath : string );
  end;

    // 主动 搜索目录
  TFolderFindHandle = class( TFolderFindBaseHandle )
  public
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;virtual;
    function IsFolderFilter( FolderPath : string ): Boolean;virtual;
  end;

    // 被动 搜索目录
  TFolderAccessFindHandle = class( TFolderFindBaseHandle )
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' 本地扫描 ' }

    // 搜索 本地目录
  TLocalFolderFindHandle = class( TFolderFindHandle )
  public
    SleepCount : Integer;
  public
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure CheckSleep;virtual;  // Cpu 限制
  end;

    // 搜索 本地深层目录
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
  private        // 多态
    function CreateSearchLocalFolder : TLocalFolderFindHandle;virtual;
    function CreateSearchChildFolder : TLocalFolderFindDeepHandle;virtual;
  end;

  {$EndRegion}

  {$Region ' 网络主动扫描 ' }

    // 被动搜索 父类
  TNetworkFolderFindBaseHandle = class( TFolderFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  protected
    procedure SendFileReq;virtual;abstract;
  end;

    // 搜索 网络目录
  TNetworkFolderFindHandle = class( TNetworkFolderFindBaseHandle )
  protected
    procedure SendFileReq;override;
  end;

    // 搜索 网络子目录
  TNetworkFolderFindDeepHandle = class( TNetworkFolderFindBaseHandle )
  protected
    procedure SendFileReq;override;
  end;

  {$EndRegion}

  {$Region ' 网络被动查找 辅助类 ' }

    // 搜索辅助数据
  THeatBeatHelper = class
  public
    TcpSocket : TCustomIpClient;
    StartTime : TDateTime;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure CheckHeartBeat;
  end;

    // 心跳接收器
  HeartBeatReceiver = class
  public
    class function CheckReceive( TcpSocket : TCustomIpClient ): string;
    class procedure CheckSend( TcpSocket : TCustomIpClient; var StartTime : TDateTime );
  end;

    // 搜索单个文件夹
  TLocalFolderFindAdvanceHandle = class( TLocalFolderFindHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected
    procedure CheckSleep;override;
  end;

    // 搜索若干个文件
  TLocalFolderFindDeepAdvanceHandle = class( TLocalFolderFindDeepHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  private        // 多态
    function CreateSearchLocalFolder : TLocalFolderFindHandle;override;
    function CreateSearchChildFolder : TLocalFolderFindDeepHandle;override;
  end;

  {$EndRegion}

  {$Region ' 网络被动查找 ' }

    // 被动搜索 父类
  TNetworkFolderAccessFindBaseHandle = class( TFolderAccessFindHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  protected
    procedure SearchFolderInfo;virtual;abstract; // 搜索信息
    procedure SendFolderInfo;  // 发送结果信息
  end;

    // 被动搜索 网络目录
  TNetworkFolderAccessFindHandle = class( TNetworkFolderAccessFindBaseHandle )
  protected
    procedure SearchFolderInfo;override; // 搜索信息
  end;

    // 被动搜索 网络子目录
  TNetworkFolderAccessFindDeepHandle = class( TNetworkFolderAccessFindBaseHandle )
  protected
    procedure SearchFolderInfo;override; // 搜索信息
  end;

  {$EndRegion}

  {$Region ' 网络扫描信息交互 ' }

    // 获取 文件读取信息
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

    // 获取 目录读取信息
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

    // 获取 完整目录读取信息
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



    // 生成 文件列表 字符串
  TGetNetworkFileResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _ScanFileHash : TScanFileHash );
    function get : string;
  end;

      // 生成 目录列表 字符串
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

    // 生成 完整目录 字符串
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

  {$Region ' 扫描文件 算法 ' }

    // 搜索文件信息
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

    // 搜索 本地文件
  TLocalFileFindHandle = class( TFileFindHandle )
  public
    procedure Update;
  end;

    // 主动搜索 网络文件
  TNetworkFileFindHandle = class( TFileFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

    // 被动搜索 网络文件
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


    // 目录比较算法
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // 文件信息
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // 目录信息
    SourceFolderHash : TScanFolderHash;
    DesFolderHash : TScanFolderHash;
  public   // 空间结果
    FileCount, CompletedCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public   // 是否删除目标多余文件
    IsSupportDeleted : Boolean;
    IsDesEmpty, IsDesReaded : Boolean;  // 目标目录是否为空，目标是否已读取
    EncryptType, PasswordExt : string; // 加密的情况
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
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;virtual;
    procedure DesFolderEmptyHandle; virtual; // 目标目录为空
  private        // 比较结果
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string; FileSize : Int64 );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
    function getDesFileName( SourceFileName : string ): string;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // 文件比较算法
  TFileScanHandle = class
  public
    SourceFilePath : string;
    EncryptType, PasswordExt : string; // 加密的情况
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // 空间结果
    CompletedCount : Integer;
    CompletedSize : Int64;
  public   // 文件变化结果
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
  private        // 比较结果
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  protected
    procedure FindParentFileHash;virtual;
    procedure RemoveOtherDesFile;
  end;

{$EndRegion}

{$Region ' 文件复制 ' }

  TDataBuf = array[0..524287] of Byte; // 512 KB, 磁盘读写单位
  TSendBuf = array[0..1023] of Byte;  // 1 KB, 网络传输单位

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

    // 复制文件辅助类
  CopyFileUtil = class
  public
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
  private
    class procedure EncryptData( var Buf : TDataBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // 发送文件辅助类
  SendFileUtil = class
  public             // 加解密
    class procedure Encrypt( var Buf : TSendBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TSendBuf; BufSize : Integer; Password : string );
  public             // 压缩, 解压
    class procedure CompressStream( SourceStream, ComStream : TMemoryStream );
    class procedure DecompressStream( ComStream, DesStream : TMemoryStream );
  private
    class procedure EncryptData( var Buf : TSendBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // 刷新速度信息
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

    // 本地文件 复制
  TFileCopyHandle = class
  protected
    SourceFilePath, DesFilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
    IsEncrypt, IsDecrypt : Boolean;
    EncPassword, DecPassword : string;
  protected
    AddCompletedSpace : Int64;
    RefreshTime : TDateTime;  // 定时 刷新信息
    SleepCount : Integer; // Cpu 释放
    RefreshSpeedInfo : TRefreshSpeedInfo; // 速度信息
  protected
    ReadStream : TFileStream;  // 读入流
    WriteStream : TFileStream; // 写入流
    BufStream : TMemoryStream;  // 内存流
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetEncPassword( _IsEncrypt : Boolean; _EncPassword : string );
    procedure SetDecPassword( _IsDecrypt : Boolean; _DecPassword : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function getDesIsEnoughSpace : Boolean;  // 检查是否有足够的空间
    function CreateReadStream : Boolean;  // 创建读入流
    function CreateWriteStream : Boolean;  // 创建写入流
    function FileCopy: Boolean;  // 流复制
    function ReadBufStream : Integer;
    function WriteBufStream : Integer;
    procedure DestoryStream;
  protected
    function CheckNextCopy : Boolean;virtual; // 检测是否继续复制
    procedure RefreshCompletedSpace;virtual; // 刷新已完成空间
  protected
    procedure MarkContinusCopy;virtual; // 续传时调用
    procedure DesWriteSpaceLack;virtual; // 空间不足
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
  end;

      // 监听接收方状态线程
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

    // 发送网络文件
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
    TotalSendDataBuf, SendDataBuf : TDataBuf;  // 每次发送的数据结构
  protected
    WatchRevThread : TWatchRevThread; // 接收信息线程
  public
    constructor Create( _SendFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetFilePos( _FilePos : Int64 );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FileSend: Boolean;
    function ReadBufStream: Integer; // 读取数据
    function SendBufStream: Boolean;  // 发送数据
    function RevWriteSize( ReadSize : Integer ) : Boolean; // 对方写入多少空间
    function ReadSendBlockSize : Int64; // 每次发送的空间
    function ReadIsStopTransfer : Boolean; // 是否停止传输
    function ReadIsNextSend( IsSendSuccess : Boolean ) : Boolean; // 是否继续发送
  protected
    function getIsEnouthSpace : Boolean;virtual;
    function CreateReadStream : Boolean;virtual;
    function CheckNextSend : Boolean;virtual; // 检测是否继续发送
    procedure RefreshCompletedSpace;virtual;  // 刷新已完成空间
    procedure AddSpeedSpace( Space : Integer );virtual; // 刷新速度信息
    function getLimitBlockSize : Int64;virtual;
  protected     // 异常的情况
    procedure RevFileLackSpaceHandle;virtual; // 缺少空间的处理
    procedure MarkContinusSend;virtual; // 续传时调用
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
    procedure LostConnectError;virtual; //断开连接出错
    procedure SendFileError;virtual; // 发送文件出错
  end;

    // 预览父类
  TNetworkFilePreviewSendHandle = class( TNetworkFileSendHandle )
  protected
    function getIsEnouthSpace : Boolean;override;
  end;

     // 预览图片
  TNetworkFilePreviewPictureSendHandle = class( TNetworkFilePreviewSendHandle )
  public
    PreviewWidth, PreviewHeight : Integer;
  public
    procedure SetPreviewSize( _PreviewWidth, _PreviewHeight : Integer );
  protected
    function CreateReadStream : Boolean;override;
  end;

    // 预览 Exe
  TNetworkFilePreviewExeSendHandle = class( TNetworkFilePreviewSendHandle )
  protected
    function CreateReadStream : Boolean;override;
  end;


    // 以文本方式预览
  TNetworkFilePreviewTextSendHandle = class( TNetworkFilePreviewSendHandle )
  protected
    function CreateReadStream : Boolean;override;
  end;


     // 接收网络文件
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
    SendDataBuf, TotalSendDataBuf : TDataBuf;  // 每次发送的数据结构
  public
    constructor Create( _ReceiveFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FileReceive: Boolean;
    function ReceiveBufStream( BufSize : Integer ): Boolean; // 接收 512 KB 数据
    function WriteBufStream: Integer;
    function SendWriteSize( WriteSize, ReadSize : Integer ): Boolean;
    procedure SendRevSpeed( RevSize : Int64 ); // 发送接收速率
    function ReadIsStopTransfer : Boolean; // 是否停止传输
    function ReadIsNextRev( IsSuccessRev : Boolean ) : Boolean; // 是否继续接收
  protected
    function getIsEnoughSapce : Boolean;virtual;
    function CreateWriteStream : Boolean;virtual;
    function CheckNextReceive : Boolean;virtual; // 检测是否继续接收
    procedure RefreshCompletedSpace;virtual;
    procedure LastRefreshCompletedSpace;virtual;
    procedure AddSpeedSpace( Space : Integer );virtual; // 刷新速度信息
    function getLimitBlockSize : Int64;virtual;
    procedure ResetFileTime;virtual;
  protected     // 异常的情况
    procedure RevFileLackSpaceHandle;virtual; // 缺少空间的处理
    procedure MarkContinusRev;virtual; // 续传时调用
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
    procedure LostConnectError;virtual; //断开连接出错
    procedure ReceiveFileError;virtual; // 接收文件出错
  end;

{$EndRegion}

{$Region ' 文件回收 ' }

  TEditonPathParams = record
  public
    FilePath : string;
    EditionNum : Integer;
    IsEncrypted : Boolean;
    PasswordExt : string;
  end;

    // 辅助类
  FileRecycledUtil = class
  public
    class function getEditionPath( Params : TEditonPathParams ): string;
  end;

    // 目标文件 回收
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

    // 目标目录 回收
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

{$Region ' 文件搜索 ' }

    // 文件搜索 结果
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

    // 网络目录 主动搜索
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

    // 网络目录 被动搜索
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

    // 文件请求
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

    // 连接请求
  ConnReq_Continuse = '0';
  ConnReq_Close = '-1';

    // 目录读取结果
  FolderReadResult_End = '-1';
  FolderReadResult_File = '0';
  FolderReadResult_Folder = '1';

    // 目录搜索结果
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

    // N 个文件小停一次
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
    // 遍历 源文件
  for p in SourceFileHash do
  begin
      // 检查是否继续扫描
    if not CheckNextScan then
      Break;

      // 添加到统计信息
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

      // 文件名
    SourceFileName := p.Value.FileName;
    DesFileName := getDesFileName( SourceFileName );
    if DesFileName = '' then  // 非解密文件
      Continue;

      // 目标文件不存在
    if not DesFileHash.ContainsKey( DesFileName ) then
    begin
      AddFileResult( SourceFileName, p.Value.FileSize );
      Continue;
    end;

      // 目标文件与源文件不一致
    if not p.Value.getEquals( DesFileHash[ DesFileName ] ) then
    begin
      RemoveFileResult( DesFileName ); // 先删除
      AddFileResult( SourceFileName, p.Value.FileSize );  // 后添加
    end
    else  // 目标文件与源文件一致
    begin
      CompletedSize := CompletedSize + p.Value.FileSize;
      CompletedCount := CompletedCount + 1;
    end;

      // 删除目标文件
    DesFileHash.Remove( DesFileName );
  end;

    // 遍历目标文件
  if IsSupportDeleted then
    for p in DesFileHash do
      RemoveFileResult( p.Value.FileName );  // 删除目标文件
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TScanFolderPair;
  FolderName : string;
begin
    // 遍历源目录
  for p in SourceFolderHash do
  begin
      // 检查是否继续扫描
    if not CheckNextScan then
      Break;

    FolderName := p.Value.FolderName;

      // 不存在目标目录，则创建
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName );

      // 比较子目录
    CompareChildFolder( FolderName );

      // 移除记录
    if DesFolderHash.ContainsKey( FolderName ) then
      DesFolderHash.Remove( FolderName );
  end;

    // 遍历目标目录
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
  else  // 加密 / 解密
  if ( EncryptType = EncryptType_Enc ) or ( EncryptType = EncryptType_Dec ) then
  begin
    IsEncrypt := EncryptType = EncryptType_Enc;
      // 并不是一个解密的文件
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
    // 找源文件信息
  FindSourceFileInfo;

    // 如果目标存在子目录，则扫描
  if not IsDesEmpty then
  begin
      // 找目标文件信息
    FindDesFileInfo;

      // 目标目录是否存在子目录
    IsDesEmpty := DesFolderHash.Count = 0;
  end
  else   // 目标为空的处理
    DesFolderEmptyHandle;

    // 文件比较
  FileCompare;

    // 目录比较
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
    // 加密
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
    // 获取 父文件信息
  FindParentFileHash;

    // 寻找相同的文件
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

    // 源文件不存在
  if not FindSourceFileInfo then
    Exit;

    // 目标文件不存在
  if not FindDesFileInfo then
    AddFileResult
  else   // 目标文件与源文件不一致
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

    // 删除 以前的加密文件
  RemoveOtherDesFile;
end;


{ TLocalFolderFindHandle }

procedure TLocalFolderFindHandle.CheckSleep;
begin
    // N 个文件小停一次
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
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
        // Cpu 限制
      CheckSleep;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // 文件被过滤
        Continue;

        // 添加到目录结果
      if IsFolder then
      begin
        DesScanFolderInfo := TScanFolderInfo.Create( FileName );
        ScanFolderHash.AddOrSetValue( FileName, DesScanFolderInfo );
      end
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 添加到文件结果集合中
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

    // 1 秒钟 刷新一次界面
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // 刷新界面
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
      // 目标文件
    if Position > 0 then  // 续传
    begin
      WriteStream := TFileStream.Create( DesFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := Position;
    end
    else
    begin  // 第一次传
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

    try    // 复制文件
      while RemainSize > 0 do
      begin
          // 取消复制 或 程序结束
        if not CheckNextCopy then
          Break;

          // 读文件
        TotalReadSize := ReadBufStream; // 读取 8MB 文件

          // 读文件出错
        if TotalReadSize <= 0 then
        begin
          ReadFileError;
          Break;
        end;

          // 写文件
        TotalWriteSize := WriteBufStream;

          // 写文件出错 或 空间 不足
        if TotalWriteSize <> TotalReadSize then
        begin
          WriteFileError;
          Break;
        end;

          // 刷新状态
        RemainSize := RemainSize - TotalReadSize;
        Position := Position + TotalReadSize;
        AddCompletedSpace := AddCompletedSpace + TotalReadSize;
      end;
    except
    end;

      // 添加已完成空间
    RefreshCompletedSpace;

      // 返回是否已完成
    Result := RemainSize <= 0;
  except
  end;
end;

function TFileCopyHandle.getDesIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  FreeSize := MyHardDisk.getHardDiskFreeSize( ExtractFileDir( DesFilePath ) );

    // 是否有足够的空间
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
    for i := 0 to 15 do  // 读取 8MB 文件
    begin
      ReadSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, ReadSize );

        // 加密文件
      if IsEncrypt then
        CopyFileUtil.Encrypt( Buf, ReadSize, EncPassword )
      else
      if IsDecrypt then
        CopyFileUtil.Deccrypt( Buf, ReadSize, DecPassword );

        // 添加到缓冲区
      WriteSize := BufStream.Write( Buf, ReadSize );
      if ReadSize <> WriteSize then  // 没有完全写入
        Exit;

        // 统计读取总数
      TotalReadSize := TotalReadSize + ReadSize;

        // 读取 完成
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

    // 源文件不存在
  if not FileExists( SourceFilePath ) then
    Exit;

    // 续传文件不存在
  if ( Position > 0 ) and not FileExists( DesFilePath ) then
    Exit;

    // 获取 源文件信息
  FileSize := MyFileInfo.getFileSize( SourceFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );

    // 目标路径没有足够的空间
  if not getDesIsEnoughSpace then
  begin
    DesWriteSpaceLack; // 空间不足
    Exit;
  end;

    // 无法创建读入流
  if not CreateReadStream then
  begin
    ReadFileError;
    Exit;
  end;

    // 无法创建写入流
  if not CreateWriteStream then
  begin
    WriteFileError;
    Exit;
  end;

    // 文件 复制失败
  if not FileCopy then
  begin
    MarkContinusCopy; // 添加续传信息
    Exit;
  end;

      // 关闭流
  DestoryStream;

      // 设置修改时间
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

    // 写文件
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
      if WriteSize <> ReadSize then // 没有完全写入
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

    // 速度限制
  if IsLimited and ( Speed >= LimitSpeed ) and not Result then
  begin
    LastTime := IncSecond( SpeedTime, 1 );
    SleepMisecond := MilliSecondsBetween( LastTime, Now );
    Sleep( SleepMisecond );
    Result := True;
  end;

    // 重新计算速度
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

    // 1 秒钟 刷新一次界面
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // 刷新界面
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

  try       // 创建写入流
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

    // 通知发送方是否创建成功
  MySocketUtil.SendJsonStr( TcpSocket, 'IsCreateWrite', IsCreateWrite );
  if not IsCreateWrite then // 创建失败
  begin
    WriteFileError;
    Exit;
  end;

    // 获取发送方是否创建成功
  IsCreateRead := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsCreateRead then // 发送方创建失败
  begin
    WriteStream.Free;  // 关闭写入流
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

  try   // 创建 写入流
    DebugLock.DebugFile( 'Create Write Stream', ReceiveFilePath );
    if not CreateWriteStream then // 创建失败, 结束传输
      Exit;

      // 接收流空间信息
    FileSize := MySocketUtil.RevJsonInt64( TcpSocket );

    try
      while FileSize > FilePos do
      begin
          // 接收 是否读取文件成功
        IsReadOK := MySocketUtil.RevJsonBool( TcpSocket );
        if not IsReadOK then
        begin
          ReadFileError; // 读文件出错
          Break;
        end;

          // 获取 读取文件空间
        ReadSize := MySocketUtil.RevJsonInt( TcpSocket );

          // 获取 接收文件空间
        BufSize := MySocketUtil.RevJsonInt( TcpSocket );

          // 接收 文件
        DebugLock.DebugFile( 'Rev Stream Data', ReceiveFilePath );
        BufStream.Clear;
        IsSuccessRev := ReceiveBufStream( BufSize );

          // 是否继续接收
        if not ReadIsNextRev( IsSuccessRev ) then
          Break;

          // 写入
        DebugLock.DebugFile( 'Write Stream Data', ReceiveFilePath );
        WriteSize := WriteBufStream;

          // 发送写入空间
        IsSuccessWrite := SendWriteSize( WriteSize, ReadSize );
        if not IsSuccessWrite then
          Break;

          // 刷新压缩空间
        ZipSize := WriteSize - BufSize;
        if ZipSize <> 0 then
        begin
          AddCompletedSpace := AddCompletedSpace + ZipSize;
          AddSpeedSpace( ZipSize );
        end;

          // 移动文件位置
        FilePos := FilePos + WriteSize;
      end;

         // 立刻刷新 完成空间信息
      LastRefreshCompletedSpace;

        // 是否全部发送
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

    // 计算是否有足够的空间， 并发送结果
  RemainSize := FileSize - FilePos;
  ReceiveFolderPath := ExtractFileDir( ReceiveFilePath );
  ForceDirectories( ReceiveFolderPath );
  Result := MyHardDisk.getHardDiskFreeSize( ReceiveFolderPath ) >= RemainSize;

    // 判断磁盘是否 FAT32, FAT32最大4GB
  if Result and ( FileSize > 4 * Size_GB ) and MyHardDisk.getIsFAT32( ReceiveFilePath ) then
    Result := False;

  MySocketUtil.SendJsonStr( TcpSocket, 'IsEnoughSapce', BoolToStr( Result ) );

    // 空间不足
  if not Result then
    RevFileLackSpaceHandle; // 缺少空间的处理
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

    // 停止传输
  if IsStopTransfer then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // 网络断开
  if IsLostConn then
  begin
    TcpSocket.Disconnect;
    LostConnectError; // 失去连接
    Exit;
  end;

    // 接收文件出错
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
    // 是否停止发送
  IsStopSend := MySocketUtil.RevJsonBool( TcpSocket );

    // 是否停止接收
  IsStopRev := not CheckNextReceive;
  if IsStopRev then
    MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus',ReceiveStatus_Stop );

    // 是否停止发送
  Result := IsStopSend or IsStopRev;

    // 接收速度限制
  MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus', ReceiveStatus_LimitSpace );
  MySocketUtil.SendJsonStr( TcpSocket, 'LimitBlockSize', getLimitBlockSize );
end;

function TNetworkFileReceiveHandle.ReceiveBufStream(BufSize: Integer): Boolean;
var
  BufPos, RemainSize : Int64;
  RevSizeTotal, RevSize, RevRemainSize, RevPos : Int64;
begin
  try
      // 初始化信息
    BufPos := 0;
    RemainSize := BufSize;
    while RemainSize > 0 do
    begin
        // 计算接收速率
      RevStartTime := Now;

        // 接收数据的总空间
      RevSizeTotal :=  MySocketUtil.RevJsonInt64( TcpSocket );
      if RevSizeTotal <= 0 then // 连接已断开
        IsLostConn := True;

        // 接收数据
      DebugLock.DebugFile( 'Rev Data Buf Start', ReceiveFilePath );
      RevRemainSize := RevSizeTotal;
      RevPos := 0;
      while RevRemainSize > 0 do
      begin
        RevSize := MySocketUtil.RevBuf( TcpSocket, SendDataBuf, RevRemainSize );
        if ( RevSize = SOCKET_ERROR ) or ( ( RevSize <= 0 ) and ( RevRemainSize > 0 ) ) then // 目标断开连接
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

        // 设置接收的数据
      BufStream.WriteBuffer( TotalSendDataBuf, RevSizeTotal );

        // 计算剩余和位置
      BufPos := BufPos + RevSizeTotal;
      RemainSize := RemainSize - RevSizeTotal;
      AddCompletedSpace := AddCompletedSpace + RevSizeTotal; // 统计信息
      AddSpeedSpace( RevSizeTotal ); // 刷新速度

        // 网络连接是否断开
      if IsLostConn then
        Break;

        // 是否停止传输
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;

        // 发送接收速率
      SendRevSpeed( RevSizeTotal );
    end;

      // 返回接收的空间信息
    Result := RemainSize = 0;
  except
    Result := False;
  end;

    // 发送已完成接收
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
    // 设置文件修改时间
  MyFileSetTime.SetTime( ReceiveFilePath, FileTime );
end;

procedure TNetworkFileReceiveHandle.RevFileLackSpaceHandle;
begin

end;

procedure TNetworkFileReceiveHandle.SendRevSpeed(RevSize: Int64);
var
  RevTime, RevSpeed : Int64;
begin
    // 用秒做单位
  RevSize := RevSize * 1000;

    // 用了多少毫秒
  RevTime := MilliSecondsBetween( Now, RevStartTime );
  RevTime := Max( 1, RevTime );

    // 单位是间传输的空间
  RevSpeed := RevSize div RevTime;

    // 最少 2 KB
  RevSpeed := Max( 2 * Size_KB, RevSpeed );

    // 发送接收速率
  MySocketUtil.SendJsonStr( TcpSocket, 'ReceiveStatus', ReceiveStatus_Speed );
  MySocketUtil.SendJsonStr( TcpSocket, 'RevSpeed', RevSpeed );
end;

function TNetworkFileReceiveHandle.SendWriteSize(WriteSize, ReadSize: Integer): Boolean;
var
  IsEnoughSpace : Boolean;
begin
  Result := True;

  MySocketUtil.SendJsonStr( TcpSocket, 'WriteSize', WriteSize );
  if WriteSize = ReadSize then  // 写入成功
    Exit;

      // 是否有足够的空间
  IsEnoughSpace :=  MyHardDisk.getHardDiskFreeSize( ExtractFileDir( ReceiveFilePath ) ) >= ( FileSize - FilePos );
  MySocketUtil.SendData( TcpSocket, IsEnoughSpace );
  if not IsEnoughSpace then
    RevFileLackSpaceHandle  // 空间不足
  else
    WriteFileError; // 写文件出错

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

    // 接收文件信息
  FileSize := StrToInt64Def( MySocketUtil.RevJsonStr( TcpSocket ), -1 );
  FilePos := StrToInt64Def( MySocketUtil.RevJsonStr( TcpSocket ), -1 );
  TimeStr := MySocketUtil.RevJsonStr( TcpSocket );
  FileTime := MyRegionUtil.ReadLocalTime( TimeStr );

    // 已经断开连接
  if ( FileSize = -1 ) or ( FilePos = -1 ) or ( FileTime = -1 ) then
  begin
    TcpSocket.Disconnect;
    LostConnectError;
    Exit;
  end;

    // 空间不足
  if not getIsEnoughSapce then
    Exit;

    // 文件接收
  if not FileReceive then
  begin
    MarkContinusRev; // 续传 处理
    Exit;
  end;

    // 设置文件修改时间
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
      // 非压缩文件，则解压
    StartTime := Now;
    DebugLock.Debug( 'Uncompress Data Stream: ' + ReceiveFilePath );
    ActivateStream := BufStream;
    if not MyFilePath.getIsZip( ReceiveFilePath ) then
    begin
      ActivateStream := TempStream;
      SendFileUtil.DecompressStream( BufStream, TempStream );
    end;

      // 写文件
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

    // 1 秒钟 刷新一次界面
  if SecondsBetween( Now, RefreshTime ) >= 1 then
  begin
      // 刷新界面
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

    // 获取接收方是否创建成功
  IsCreateWrite := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsCreateWrite then  // 接收方创建失败
  begin
    WriteFileError;
    Exit;
  end;

    // 创建读文件流
  try
    ReadStream := TFileStream.Create( SendFilePath, fmOpenRead or fmShareDenyNone );
    IsCreateRead := True;
  except
    IsCreateRead := False;
  end;

    // delphi bug 判断是否流空间读取错误
  if IsCreateRead then
  begin
    IsCreateRead := ReadStream.Size = MyFileInfo.getFileSize( SendFilePath );
    if not IsCreateRead then
      ReadStream.Free;
  end;

    // 是否创建读入流成功
  MySocketUtil.SendJsonStr( TcpSocket, 'IsCreateRead', IsCreateRead );
  if not IsCreateRead then  // 读入流创建失败
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
      // 创建流失败
    if not CreateReadStream then
      Exit;

      // 发送流空间信息
    FileSize := ReadStream.Size;
    MySocketUtil.SendJsonStr( TcpSocket, 'StreamFileSize', FileSize );

    try
        // 发送文件
      ReadStream.Position := FilePos;  // 移动文件位置
      while FileSize > FilePos do
      begin
          // 统计要发送的空间
        DebugLock.DebugFile( 'Read Stream Data', SendFilePath );
        ReadSize := ReadBufStream;  // 读取 8M 数据，返回实际读取的空间信息

          // 读取文件 是否成功
        IsReadOK := ReadSize <> -1;
        MySocketUtil.SendJsonStr( TcpSocket, 'IsReadOK', IsReadOK );
        if not IsReadOK then // 读取出错
        begin
          ReadFileError; // 读错误处理
          Break;
        end;

          // 发送 文件读取空间
        MySocketUtil.SendJsonStr( TcpSocket, 'ReadSize', ReadSize );

          // 发送 文件发送空间
        BufSize := BufStream.Size;
        MySocketUtil.SendJsonStr( TcpSocket, 'BufSize', BufSize );

          // 发送 8M 数据
        DebugLock.DebugFile( 'Send Stream Data', SendFilePath );
        WatchRevThread.StartWatch;
        IsSendSuccess := SendBufStream;
        WatchRevThread.StopWatch;

          // 是否继续发送
        if not ReadIsNextSend( IsSendSuccess ) then
          Break;

          // 写入失败
        IsWriteSuccess := RevWriteSize( ReadSize );
        if not IsWriteSuccess then
          Break;

          // 添加 压缩空间
        ZipSize := ReadSize - BufSize;
        if ZipSize <> 0 then
        begin
          AddCompletedSpace := AddCompletedSpace + ZipSize;
          AddSpeedSpace( ZipSize );
        end;

          // 设置已发送的文件位置
        FilePos := FilePos + ReadSize;
      end;

        // 最后的刷新
      RefreshCompletedSpace;

        // 是否发送完成
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

    // 接收 是否有足够的空间
  IsEnoughSpaceStr := MySocketUtil.RevJsonStr( TcpSocket );
  if IsEnoughSpaceStr = '' then // 目标 Pc 断开连接
  begin
    TcpSocket.Disconnect;
    LostConnectError;
    Exit;
  end;

   //  是否有足够的空间
  IsEnoughSpace := StrToBoolDef( IsEnoughSpaceStr, False );
  if not IsEnoughSpace then
  begin
    RevFileLackSpaceHandle; // 处理缺少空间
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

      // 停止传输
  if IsStopTransfer or WatchRevThread.IsRevStop then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // 网络断开
  if IsLostConn or WatchRevThread.IsRevLostConn then
  begin
    TcpSocket.Disconnect;
    LostConnectError; // 失去连接
    Exit;
  end;

    // 未知的错误, 未完整地发送文件
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
    // 是否停止发送
  IsStopSend := not CheckNextSend;
  MySocketUtil.SendJsonStr( TcpSocket, 'IsStopSend', IsStopSend );

    // 是否停止接收
  IsStopRev := WatchRevThread.IsRevStop;

    // 是否停止传输
  Result := IsStopSend or IsStopRev;

    // 接收速度限制
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
  Result := Max( Result, 1 * Size_KB ); // 至少 1 KB
end;

function TNetworkFileSendHandle.RevWriteSize( ReadSize : Integer ): Boolean;
var
  WriteSizeStr : string;
  WriteSize : Integer;
  IsEnouthSpace : Boolean;
begin
  Result := True;

    // 获取 对方写入的空间信息，含心跳
  WriteSizeStr := MySocketUtil.RevJsonStr( TcpSocket );
  if WriteSizeStr = '' then  // 写入时间超长，导致连接断开
  begin
    WriteFileError;
    Result := False;
    Exit;
  end;

    // 转化为空间信息
  WriteSize := StrToIntDef( WriteSizeStr, 0 );
  if WriteSize = ReadSize then // 与要发送的空间一致
    Exit;

    // 读取是否因为空间不足
  IsEnouthSpace := MySocketUtil.RevBoolData( TcpSocket );
  if not IsEnouthSpace then
    RevFileLackSpaceHandle  // 空间不足
  else
    WriteFileError; // 写错误处理

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

    // 如果不是压缩文件，则压缩文件
  ActivateStream := BufStream;
  if not MyFilePath.getIsZip( SendFilePath ) then
    ActivateStream := TempStream;

  try
      // 读取 8M 数据
    StartTime := Now;
    RemainSize := ReadStream.Size - ReadStream.Position;
    FullBufSize := SizeOf( Buf );
    TotalReadSize := 0;
    for i := 0 to 15 do
    begin
      BufSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, BufSize );
      if ( ReadSize <= 0 ) and ( ReadSize <> BufSize ) then // 读取出错
        Exit;
      TotalReadSize := TotalReadSize + ReadSize;
      ActivateStream.WriteBuffer( Buf, ReadSize );
      if ( RemainSize - TotalReadSize ) <= 0 then // 读取完成
        Break;
      HeartBeatReceiver.CheckSend( TcpSocket, StartTime ); // 定时发送心跳
    end;

      // 压缩流
    if not MyFilePath.getIsZip( SendFilePath ) then
      SendFileUtil.CompressStream( TempStream, BufStream );

      // 返回
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
      // 初始化信息
    BufPos := 0;
    RemainSize := BufStream.Size;
    BufStream.Position := 0;
    while RemainSize > 0 do
    begin
        // 获取 发送数据的大小
      TotalSendSize := ReadSendBlockSize;
      TotalSendSize := Min( TotalSendSize, RemainSize );
      TotalSendSize := Min( TotalSendSize, SIzeOf( TotalSendDataBuf ) );
      MySocketUtil.SendJsonStr( TcpSocket, 'TotalSendSize', TotalSendSize );

        // 连接已断开
      if TotalSendSize <= 0 then
        IsLostConn := True;

        // 获取 要发送的数据
      BufStream.ReadBuffer( TotalSendDataBuf, TotalSendSize );

        // 发送数据
      DebugLock.DebugFile( 'Send Data Buf Start', SendFilePath );
      SendRemainSize := TotalSendSize;
      SendPos := 0;
      while SendRemainSize > 0 do
      begin
          // 复制发送的数据
        CopyMemory( @SendDataBuf, @TotalSendDataBuf[SendPos], SendRemainSize );

          // 发送数据
        SendSize := TcpSocket.SendBuf( SendDataBuf, SendRemainSize );
        if ( SendSize = SOCKET_ERROR ) or ( ( SendSize <= 0 ) and ( SendRemainSize > 0 ) ) then // 目标断开连接
        begin
          IsLostConn := True;
          Break;
        end;
        SendRemainSize := SendRemainSize - SendSize;
        SendPos := SendPos + SendSize;
      end;
      TotalSendSize := TotalSendSize - SendRemainSize;
      DebugLock.DebugFile( 'Send Data Buf Stop', IntToStr( TotalSendSize ) );

        // 计算剩余和位置
      BufPos := BufPos + TotalSendSize;
      RemainSize := RemainSize - TotalSendSize;
      AddCompletedSpace := AddCompletedSpace + TotalSendSize;
      AddSpeedSpace( TotalSendSize ); // 刷新速度

        // 已断开连接
      if IsLostConn or WatchRevThread.IsRevLostConn then
        Break;

        // 停止传输
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;
    end;

      // 返回 发送的空间信息
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

    // 发送 文件信息
  FileSize := MyFileInfo.getFileSize( SendFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SendFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileSize', FileSize );
  MySocketUtil.SendJsonStr( TcpSocket, 'FilePos', FilePos );
  MySocketUtil.SendJsonStr( TcpSocket, 'FileTime', MyRegionUtil.ReadRemoteTimeStr( FileTime ) );

    // 空间不足 或 已断开连接
  if not getIsEnouthSpace then
    Exit;

    // 文件发送
  if not FileSend then
  begin
    MarkContinusSend; // 处理续传
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
  if not IsExist then // 目标文件不存在
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
    // 提取文件信息
  LocalFileFindHandle := TLocalFileFindHandle.Create( FilePath );
  LocalFileFindHandle.Update;
  IsExist := LocalFileFindHandle.getIsExist;
  FileSize := LocalFileFindHandle.getFileSize;
  FileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;

    // 发送文件信息
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

    // 版本 数超多
    // 删除 最低版本
  if ExistEditionCount >= SaveDeletedEdition then
  begin
    FilePath1 := getEditionPath( RecycledPath, SaveDeletedEdition - 1 );
    MyFolderDelete.FileDelete( FilePath1 );
  end;

    // 改名版本数
  ExistEditionCount := Min( ExistEditionCount, SaveDeletedEdition  );

    // 版本上移
  for i := ExistEditionCount downto 2 do
  begin
    FilePath1 := getEditionPath( RecycledPath, i - 1 );
    FilePath2 := getEditionPath( RecycledPath, i );
    RenameFile( FilePath1, FilePath2 );
  end;

    // 当前版本设为最后一个版本
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
    // 检查保存的版本数
  CheckKeedEditionCount;

    // 文件回收
  if FileCopy then
    FileRemove; // 文件删除
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
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextRecycled then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( FileName )
      else
        SearchFile( FileName );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // 目录删除
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

      // 读取 目录信息
    if FolderStr <> Type_Empty then
      ReadFolder;

      // 读取 文件信息
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
    // 不同目录层的不同分隔符
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [ IntToStr( FolderLevel ) ] );

    // 提取目录信息
  FolderInfoList := MySplitStr.getList( FolderInfoStr, FolderInfoSplit );
  if FolderInfoList.Count = FolderInfo_Count then
  begin
      // 提取信息
    FolderName := FolderInfoList[ Info_FolderName ];
    IsReaded := StrToBoolDef( FolderInfoList[ Info_IsReaded ], False );
    ChildFiles := FolderInfoList[ Info_FolderChildFiles ];
    ChildFolders := FolderInfoList[ Info_FolderChildFolders ];

      // 创建目录
    ScanFolderInfo := TScanFolderInfo.Create( FolderName );
    ScanFolderInfo.IsReaded := IsReaded;
    ScanFolderHash.AddOrSetValue( FolderName, ScanFolderInfo );

      // 目录信息已经读取
    if IsReaded then
    begin
        // 提取子文件
      FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( ChildFiles );
      FindNetworkFileResultHandle.SetScanFile( ScanFolderInfo.ScanFileHash );
      FindNetworkFileResultHandle.Update;
      FindNetworkFileResultHandle.Free;

        // 提取子目录
      FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( ChildFolders );
      FindNetworkFolderResultHandle.SetScanFolder( ScanFolderInfo.ScanFolderHash );
      FindNetworkFolderResultHandle.SetFolderLevel( FolderLevel + 1 ); // 下一层
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
    // 发文件信息
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

    // 没有文件的标志
  if FileStr = '' then
    FileStr := Type_Empty;

  Result := FileStr;
end;

{ CopyFileUtil }

class procedure SendFileUtil.CompressStream(SourceStream,
  ComStream: TMemoryStream);
var
  cs: TCompressionStream; {定义压缩流}
  num: Integer;           {原始文件大小}
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
    // 读取源流的空间信息
  ComStream.Position := 0;
  ComStream.ReadBuffer(num,SizeOf(num));
  DesStream.SetSize(num);

    // 解压
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

    // 加密块
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

    // 加密不足块的部分
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

    // 加密块
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

    // 加密不足块的部分
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

      // 减去已读取的
    TotalReadSize := TotalReadSize - ReadSize;

      // 移动写位置
    WritePos := WritePos + ReadSize;

      // 读取下一块
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

    // N 个文件小停一次
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // 1 秒钟 刷新一次 搜索结果
    if SecondsBetween( now , RefreshTime ) >= 1 then
    begin
      HandleResultHash; // 处理结果
      ResultFileHash.Clear;
      ResultFolderHash.Clear;

      if getIsStop then // 处理结果后断开连接
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

    // 搜索文件
  for p in ScanFileHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 获取文件名
    FileName := p.Value.FileName;
    if IsEncrypted then  // 文件名解密
      FileName := MyFilePath.getDesFileName( FileName, PasswordExt, False );

      // 不符合搜索条件
    if not MyMatchMask.Check( FileName, SearchName ) then
      Continue;

      // 添加到搜索结果中
    ChildPath := ParentPath + FileName;
    ResultFileInfo := TScanFileInfo.Create( ChildPath );
    ResultFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    ResultFileHash.AddOrSetValue( ChildPath, ResultFileInfo );
  end;
  ScanFileHash.Clear; // 释放内存

    // 结束搜索
  if not Result then
    Exit;

    // 搜索目录
  for pf in ScanFolderHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 不符合搜索条件
    if not MyMatchMask.Check( pf.Value.FolderName, SearchName ) then
      Continue;

      // 添加到搜索结果中
    ChildPath := ParentPath + pf.Value.FolderName;
    ResultFolderInfo := TScanFolderInfo.Create( ChildPath );
    ResultFolderHash.AddOrSetValue( ChildPath, ResultFolderInfo );
  end;
end;

function TFolderSearchHandle.FindScanHash: Boolean;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // 搜索目录信息
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

    // 搜索目录
  for pf in ScanFolderHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 添加到搜索结果中
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

      // 结束搜索
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
    // 搜索文件信息
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
    // 提取信息
  FindNetworkFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( ResultStr );
  FindNetworkFolderResultHandle.SetScanFile( ResultFileHash );
  FindNetworkFolderResultHandle.SetScanFolder( ResultFolderHash );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;

    // 处理结果信息
  HandleResultHash;

    // 清空已处理信息
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
    if ResultStr = FolderSearchResult_End then // 结束搜索
      Break;
    if ResultStr = '' then  // 断开了连接
    begin
      TcpSocket.Disconnect;
      Break;
    end;
      // 处理搜索结果
    HandleResult( ResultStr );

      // 判断是否停止搜索
    IsStop := getIsStop;
    MySocketUtil.SendData( TcpSocket, IsStop );

      // 结束搜索
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
    // 把搜索结果转化为字符串
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ResultFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ResultFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // 发送读取结果
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
    // 每一层目录的分隔符都不一样
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [IntToStr( FolderLevel )] );

    // 目录信息
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

    // 没有目录的标志
  if FolderStr = '' then
    FolderStr := Type_Empty;

    // 加密
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
  GetNetworkFolderResultStrHandle.SetFolderLevel( FolderLevel + 1 ); // 下一层
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
    // 目录信息列表
  FolderStr := getFolderStr;

    // 文件信息列表
  FileStr := getFileStr;

    // 组合
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

    // 发送是否创建成功
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

  try    // 读取 512KB 数据
    FileStream := TFileStream.Create( SendFilePath, fmOpenRead or fmShareDenyNone );
    try
      if FileStream.Size > Size_MB then  // 超过 1 MB 可能不是文本文件
        ReadSize := 1 * Size_KB
      else  // 只读取部分文件数
        ReadSize := Min( FileStream.Size, SizeOf( Buf ) );

      ReadSize := FileStream.Read( Buf, ReadSize );
    except
      Result := False;
    end;
      FileStream.Free;
  except
    Result := False;
  end;

    // 读取 成功
  if Result then
  begin
       // 预览 512KB 数据
    try
      ReadStream := TMemoryStream.Create;
      ReadStream.WriteBuffer( buf, ReadSize );
    except
      Result := False;
    end;
  end;

      // 发送是否创建成功
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

      // 发送是否创建成功
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
        // 超出范围，结束
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
    // 搜索当前目录
  SearchLocalFolder;

    // 搜索子目录
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
    // 发送请求信息
  SendFileReq;
  MySocketUtil.SendJsonStr( TcpSocket, 'FolderPath', FolderPath );

    // 接收结果信息， 含心跳
  FolderReadResult := MySocketUtil.RevJsonStr( TcpSocket );
  if FolderReadResult = '' then  // 对方断开连接
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // 提取信息
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
    // 把搜索结果转化为字符串
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ScanFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ScanFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // 发送读取结果
  MySocketUtil.SendJsonStr( TcpSocket, 'ReadResultStr', ReadResultStr );
end;

procedure TNetworkFolderAccessFindBaseHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderAccessFindBaseHandle.Update;
begin
    // 搜索目录信息
  SearchFolderInfo;

    // 发送搜索结果
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
    if RevStr = ReceiveStatus_Speed then  // 设置接收速度
      RevSpeed := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_LimitSpace then  // 接收传输限制
      RevLimitSpace := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_Stop then  // 停止接收
      IsRevStop := True
    else
    begin
      if RevStr = ReceiveStatus_Completed then // 接收完成
        IsRevCompleted := True
      else                                // 接收断开
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
    // 接收完成 或 已经断开连接
  while not IsRevCompleted and not IsRevLostConn do
    Sleep( 100 );
end;


{ TLocalFolderFindAdvanceHandle }

procedure TLocalFolderFindAdvanceHandle.CheckSleep;
begin
  inherited;

     // 定时发送心跳
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
    // 定时发送心跳
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
    // 定时发送心跳
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
    if Result <> FileReq_HeartBeat then  // 心跳则继续等待接收
      Break;
  end;
end;

end.

