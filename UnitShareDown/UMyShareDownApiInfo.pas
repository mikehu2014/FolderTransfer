unit UMyShareDownApiInfo;

interface

uses SysUtils, classes, Generics.Collections;

type

{$Region ' 恢复文件 Explorer ' }


    // 用户 Api
  ShareExplorerUserApi = class
  public
    class procedure ReadLocal( RestorePath, OwnerID : string; IsFile, IsSearch : Boolean );
    class procedure ReadNetwork( RestorePath, OwnerID : string; IsFile, IsSearch : Boolean );
  end;


  TExplorerResultParams = record
  public
    FilePath : string;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  end;

    // 程序 Api
  ShareExplorerAppApi = class
  public
    class procedure StartExplorer;
    class procedure SharePcNotConn;
    class procedure SharePcBusy;
    class procedure StopExplorer;
  public
    class procedure ShowFolderResult( Params : TExplorerResultParams );
    class procedure ShowFileResult( Params : TExplorerResultParams );
  end;

  {$Region ' 浏览历史 ' }

      // 读取
  TShareExplorerHistoryReadHandle = class
  public
    OwnerID, FilePath : string;
  public
    constructor Create( _OwnerID, _FilePath : string );
    procedure Update;virtual;
  private
    procedure RemoveExistItem;
    procedure RemoveMaxCount;
    procedure AddToInfo;
    procedure AddToFace;
  private
    procedure RemoveItem( RemoveIndex : Integer );
  end;

    // 添加
  TShareExplorerHistoryAddHandle = class( TShareExplorerHistoryReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareExplorerHistoryRemoveHandle = class
  private
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // 清空
  TShareExplorerHistoryClearHandle = class
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromFace;
    procedure ClearFromXml;
  end;

    // 共享历史
  ShareExplorerHistoryApi = class
  public
    class procedure AddItem( OwnerID, FilePath : string );
    class procedure ClearItem;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复下载 数据修改 ' }

    // 修改
  TShareDownWriteHandle = class
  public
    SharePath, OwnerPcID : string;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
  end;

  {$Region ' 增删修改 ' }

    // 读取
  TShareDownReadHandle = class( TShareDownWriteHandle )
  public
    IsFile, IsCompleted : Boolean;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath, DownCompletedType : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure SetDownCompeltedType( _DownCompletedType : string );
  end;

    // 读取 本地恢复下载
  TShareDownReadLocalHandle = class( TShareDownReadHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 本地恢复下载
  TShareDownAddLocalHandle = class( TShareDownReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取 网络恢复下载
  TShareDownReadNetworkHandle = class( TShareDownReadHandle )
  private
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络恢复下载
  TShareDownAddNetworkHandle = class( TShareDownReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareDownRemoveHandle = class( TShareDownWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 状态修改 ' }

      // 设置 状态
  TShareDownSetStautsHandle = class( TShareDownWriteHandle )
  public
    NodeStatus : string;
  public
    procedure SetNodeStatus( _NodeStatus : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 是否缺少空间
  TShareDownSetIsLackSpaceHandle = class( TShareDownWriteHandle )
  public
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 修改
  TShareDownSetIsWriteHandle = class( TShareDownWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 设置 是否存在恢复源
  TShareDownSetIsExistHandle = class( TShareDownWriteHandle )
  public
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 修改
  TShareDownSetSpeedHandle = class( TShareDownWriteHandle )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;

      // 修改
  TShareDownSetAnalyzeHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  private
    procedure AddToHint;
  end;

    // 修改
  TShareDownSetAnalyzeCountHandle = class( TShareDownWriteHandle )
  public
    AnalyzeCount : integer;
  public
    procedure SetAnalyzeCount( _AnalyzeCount : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;


    // Pc 上/下线
  TShareDownPcIsOnlineHandle = class
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 修改
  TShareDownSetIsCompletedHandle = class( TShareDownWriteHandle )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TShareDownSetIsRestoringHandle = class( TShareDownWriteHandle )
  public
    IsRestoring : boolean;
  public
    procedure SetIsRestoring( _IsRestoring : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

    // 修改
  TShareDownSetIsDesBusyHandle = class( TShareDownWriteHandle )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

    // 修改
  TShareDownSetIsLostConnHandle = class( TShareDownWriteHandle )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

      // 修改
  TShareDownSetIsConnectedHandle = class( TShareDownWriteHandle )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' 空间修改 ' }

    // 修改
  TShareDownSetSpaceInfoHandle = class( TShareDownWriteHandle )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

      // 修改
  TShareDownSetAddCompletedSpaceHandle = class( TShareDownWriteHandle )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TShareDownSetCompletedSizeHandle = class( TShareDownWriteHandle )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

      // 修改
  TShareDownContinusWriteHandle = class( TShareDownWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

      // 读取
  TShareDownContinusReadHandle = class( TShareDownContinusWriteHandle )
  public
    FileSize, Postion : int64;
  public
    FileTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize, _Postion : int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TShareDownContinusAddHandle = class( TShareDownContinusReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareDownContinusRemoveHandle = class( TShareDownContinusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;



  {$EndRegion}

  {$Region ' 源路径 日志信息 ' }

    // 修改
  TShareDownLogWriteHandle = class( TShareDownWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 读取
  TShareDownLogCompletedReadHandle = class( TShareDownLogWriteHandle )
  public
    BackupTime : TDateTime;
  public
    procedure SetBackupTime( _BackupTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TShareDownLogCompletedAddHandle = class( TShareDownLogCompletedReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取
  TShareDownLogIncompletedReadHandle = class( TShareDownLogWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TShareDownLogIncompletedAddHandle = class( TShareDownLogIncompletedReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 清空已完成
  TShareDownLogClearCompletedHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  private
    procedure ClearInfo;
    procedure ClearXml;
  end;

    // 清空未完成
  TShareDownLogClearIncompletedHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  private
    procedure ClearInfo;
    procedure ClearXml;
  end;

{$EndRegion}


  {$Region ' 速度信息 ' }

    // 读取 速度限制
  TRestoreSpeedLimitReadHandle = class
  public
    IsLimit : Boolean;
    LimitType, LimitValue : Integer;
  public
    constructor Create( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitType, _LimitValue : Integer );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 速度限制
  TRestoreSpeedLimitHandle = class( TRestoreSpeedLimitReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

  {$EndRegion}


  {$Region ' 错误信息 ' }

        // 添加 错误
  TShareDownErrorAddHandle = class( TShareDownWriteHandle )
  public
    FilePath : string;
    FileSize, CompletedSpace : Int64;
    ErrorStatus : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetErrorStatus( _ErrorStatus : string );
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 清空 错误
  TShareDownErrorClearHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  private
    procedure ClearToFace;
  end;

  {$EndRegion}

  {$Region ' 恢复操作 ' }

    // 恢复选中 父类
  TShareDownSelectItemHandle = class( TShareDownWriteHandle )
  public
    IsFile : Boolean;
    IsDeleted : Boolean;
  public
    procedure Update;
  protected
    procedure ReadRestoreScanInfo;
    procedure AddToScan;virtual;abstract;
  end;

    // 恢复 本地
  TShareDownSelectLocalItemHandle = class( TShareDownSelectItemHandle )
  protected
    procedure AddToScan;override;
  end;

    // 恢复 网络
  TShareDownSelectNetworkItemHandle = class( TShareDownSelectItemHandle )
  protected
    procedure AddToScan;override;
  end;

    // 恢复 停止
  TShareItemStopHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  end;

    // 恢复 完成
  TShareCompletedHandle = class( TShareDownWriteHandle )
  public
    procedure Update;
  private
    procedure CheckDownCompletedType;
    procedure RefreshIcon;
    procedure AddToHint;
  end;

    // 恢复子路径
  TChildRestoreInfo = class
  public
    FilePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSize : Int64;
  public
    constructor Create( _FilePath : string; _IsFile : Boolean );
    procedure SetFileInfo( _FileCount, _FileSize : Int64 );
  end;
  TChildRestoreList = class( TObjectList< TChildRestoreInfo > );

    // 解密，选择恢复路径
  TRestoreFileSelectHandle = class
  public
    RestorePath : string;
    IsFile : Boolean;
    IsLocalRestore : Boolean;
    OwnerID, OwnerName : string;
    RestoreFrom, RestoreFromName : string;
  public
    IsDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    ChildRestoreList : TChildRestoreList;
    RestorePassword : string;
    SavePath : string;
  public
    constructor Create( _RestorePath : string; _IsFile : Boolean );
    procedure SetIsLocalRestore( _IsLocalRestore : Boolean );
    procedure SetOwnerID( _OwnerID, _OwerName : string );
    procedure SetRestoreFrom( _RestoreFrom, _RestoreFromName : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
    procedure AddChildPath( ChildRestoreInfo : TChildRestoreInfo );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FindSavePath : Boolean;
    procedure AddRestoreDown;
  end;

    // Pc 上线，启动恢复
  TCheckPcOnlineRestoreHandle = class
  public
    OnlinePcID : string;
  public
    constructor Create( _DesPcID : string );
    procedure Update;
  end;

    // 程序运行，启动自动恢复
  TCheckLocalOnlineRestoreHandle = class
  public
    procedure Update;
  end;

    // 开始下载
  TShareDownStartHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 结束下载
  TShareDownStopHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 暂停下载
  TShareDownPauseHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 继续下载
  TSharedownContiueHandle = class
  public
    procedure Update;
  end;


  {$EndRegion}

  {$Region ' 保存路径历史 ' }

  TShareSavePathReadHandle = class
  public
    SavePath : string;
  public
    constructor Create( _SavePath : string );
    procedure Update;virtual;
  private
    procedure RemoveExistItem;
    procedure RemoveMaxCount;
    procedure AddToInfo;
    procedure AddToFace;
  private
    procedure RemoveItem( RemoveIndex : Integer );
  end;

  TShareSavePathAddHandle = class( TShareSavePathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  TShareSavePathRemoveHandle = class
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  TShareSavePathClearHandle = class
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromFace;
    procedure ClearFromXml;
  end;

  ShareSavePathHistory = class
  public
    class procedure AddItem( SavePath : string );
    class procedure ClearItem;
  end;

  {$EndRegion}

  {$Region ' 信息读取 ' }

  RestoreSpeedInfoReadUtil = class
  public
    class function getIsLimit : Boolean;
    class function getLimitType : Integer;
    class function getLimitValue : Integer;
    class function getLimitSpeed : Int64;
  end;

  {$EndRegion}

    // 添加 参数
  TShareDownAddParams = record
  public
    SharePath, OwnerPcID : string;
    IsFile : Boolean;
    SavePath, DownCompletedType : string;
  end;

    // 设置空间 参数
  TShareDownSetSpaceParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  end;

    // 共享下载
  ShareDownUserApi = class
  public
    class procedure AddLocalItem( Params : TShareDownAddParams );
    class procedure AddNetworkItem( Params : TShareDownAddParams );
    class procedure RemoveItem( RestorePath, OwnerPcID : string );
  public
    class procedure DownSelectLocalItem( RestorePath, OwnerPcID : string );
    class procedure DownSelectNetworkItem( RestorePath, OwnerPcID : string );
  end;

      // 添加 参数
  TShareDownContinusAddParams = record
  public
    SharePath, OwnerID : string;
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  end;


    // 共享下载 续传
  ShareDownContinusApi = class
  public
    class procedure AddItem( Params : TShareDownContinusAddParams );
    class procedure RemoveItem( SharePath, OwnerID, FilePath : string );
  end;

    // 共享显示信息
  ShareDownAppApi = class
  public               // 恢复过程状态
    class procedure WaitingRestore( RestorePath, OwnerPcID : string );
    class procedure SetAnalyzeRestore( RestorePath, OwnerPcID : string );
    class procedure SetScaningCount( RestorePath, OwnerPcID : string; FileCount : Integer );
    class procedure SetSpaceInfo( Params : TShareDownSetSpaceParams );
    class procedure SetStartRestore( RestorePath, OwnerPcID : string );
    class procedure SetSpeed( RestorePath, OwnerPcID : string; Speed : Int64 );
    class procedure AddCompletedSpace( RestorePath, OwnerPcID : string; CompletedSpace : Int64 );
    class procedure RestoreCompleted( RestorePath, OwnerPcID : string );
    class procedure RestoreStop( RestorePath, OwnerPcID : string );
  public
    class procedure SetStatus( RestorePath, OwnerPcID, NodeStatus : string );
    class procedure SetIsExist( RestorePath, OwnerPcID  : string; IsExist : Boolean );
    class procedure SetIsWrite( RestorePath, OwnerPcID  : string; IsWrite : Boolean );
    class procedure SetIsLackSpace( RestorePath, OwnerPcID : string; IsLackSpace : Boolean );
    class procedure SetPcOnline( DesPcID : string; IsOnline : Boolean );
    class procedure SetIsRestoring( RestorePath, OwnerPcID : string; IsRestoring : Boolean );
    class procedure SetIsCompleted( RestorePath, OwnerPcID : string; IsCompleted : Boolean );
    class procedure SetIsDesBusy( RestorePath, OwnerPcID : string; IsDesBusy : Boolean );
    class procedure SetIsLostConn( RestorePath, OwnerPcID : string; IsLostConn : Boolean );
    class procedure SetIsConnect( RestorePath, OwnerPcID : string; IsConnect : Boolean );
    class procedure SetCompletedSpace( RestorePath, OwnerPcID : string; CompletedSpace : Int64 );
  public              // 续传
    class procedure CheckLocalRestoreOnline;
    class procedure CheckPcOnlineRestore( DesPcID : string );
  public              // 开始/结束 恢复
    class procedure StartRestore;
    class procedure StopRestore;
    class procedure PauseRestore;
    class procedure ContinueRestore;
  end;

      // 添加 参数
  TShareDownErrorAddParams = record
  public
    SharePath, OwnerID : string;
    FilePath : string;
    FileSize, CompletedSize : Int64;
    ErrorStatus : string;
  end;

    // 下载的错误信息
  ShareDownErrorApi = class
  public
    class procedure ReadFileError( Params : TShareDownErrorAddParams );
    class procedure WriteFileError( Params : TShareDownErrorAddParams );
    class procedure LostConnectError( Params : TShareDownErrorAddParams );
    class procedure ReceiveFileError( Params : TShareDownErrorAddParams );
    class procedure ClearItem( SharePath, OwnerID : string );
  private
    class procedure AddItem( Params : TShareDownErrorAddParams );
  end;

      // 恢复限速
  ShareDownSpeedApi = class
  public
    class procedure SetLimit( IsLimit : Boolean; LimitType, LimitValue : Integer );
  end;

    // 添加参数
  TShareDownAddLogParams = record
  public
    SharePath, OwnerPcID : string;
    FilePath : string;
    SendTime : TDateTime;
  end;

    // 备份 Log Api
  ShareDownLogApi = class
  public
    class procedure AddCompleted( Prams : TShareDownAddLogParams );
    class procedure ClearCompleted( SharePath, OwnerPcID : string );
  public
    class procedure AddIncompleted( Prams : TShareDownAddLogParams );
    class procedure ClearIncompleted( SharePath, OwnerPcID : string );
  public
    class procedure RefreshLogFace( DesItemID, SourcePath : string );
  end;


{$EndRegion}

{$Region ' 恢复文件 预览 ' }

  SharePreviewApi = class
  public
    class procedure PreviewPicture( RestorePath, OwnerID : string; ImgWidth, ImgHeigh : Integer  );
    class procedure PreviewWord( RestorePath, OwnerID : string );
    class procedure PreviewExcel( RestorePath, OwnerID : string );
    class procedure PreviewCompress( RestorePath, OwnerID : string );
    class procedure PreviewExe( RestorePath, OwnerID : string );
    class procedure PreviewMusic( RestorePath, OwnerID : string );
    class procedure PreviewText( RestorePath, OwnerID : string );
  public
    class procedure StartPreview;
    class procedure SharePcNotConn;
    class procedure SharePcBusy;
    class procedure StopPreview;
  end;

{$EndRegion}

{$Region ' 恢复文件 搜索 ' }

  ShareSearchUserApi = class
  public
    class procedure AddNetworkItem( SharePath, OwnerID, SearchName : string );
  end;

  TSearchResultParams = record
  public
    FilePath : string;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  end;

    // 程序 Api
  ShareSearchAppApi = class
  public
    class procedure StartSearch;
    class procedure SharePcNotConn;
    class procedure SharePcBusy;
    class procedure StopSearch;
  public
    class procedure ShowResult( Params : TSearchResultParams );
    class procedure ShowExplorer( Params : TExplorerResultParams );
  end;

{$EndRegion}

const
  OwnerID_MyComputer = 'My Computer';
  OwnerName_MyComputer = 'My Computer';

  DownCompletedType_Run = 'Run';
  DownCompletedType_Explorer = 'Explorer';

const
  HistoryCount_Max = 15;
  SaveHistoryCount_Max = 10;

var
  UserShareDown_IsStop : Boolean = False;

implementation

uses UMyShareDownFaceInfo, UMyNetPcInfo, UMyShareDownDataInfo, UMyShareDownXmlInfo, UShareDownThread,
     UFormShareDownExplorer, UFormSelectShareDown, UMyUtil, UMainApi, UMySendApiInfo, UMyRegisterApiInfo,
     UFormShareDownLog;



{ TRestoreDownReadHandle }

procedure TShareDownReadHandle.SetDownCompeltedType(_DownCompletedType: string);
begin
  DownCompletedType := _DownCompletedType;
end;

procedure TShareDownReadHandle.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownReadHandle.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareDownReadHandle.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownReadHandle.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveHandle }

procedure TShareDownRemoveHandle.RemoveFromInfo;
var
  RestoreDownRemoveInfo : TShareDownRemoveInfo;
begin
  RestoreDownRemoveInfo := TShareDownRemoveInfo.Create( SharePath, OwnerPcID );
  RestoreDownRemoveInfo.Update;
  RestoreDownRemoveInfo.Free;
end;

procedure TShareDownRemoveHandle.RemoveFromFace;
var
  RestoreDownRemoveFace : TShareDownRemoveFace;
begin
  RestoreDownRemoveFace := TShareDownRemoveFace.Create( SharePath, OwnerPcID );
  RestoreDownRemoveFace.AddChange;
end;

procedure TShareDownRemoveHandle.RemoveFromXml;
var
  RestoreDownRemoveXml : TShareDownRemoveXml;
begin
  RestoreDownRemoveXml := TShareDownRemoveXml.Create( SharePath, OwnerPcID );
  RestoreDownRemoveXml.AddChange;
end;

procedure TShareDownRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;






{ RestoreDownUserApi }

class procedure ShareDownUserApi.AddLocalItem(Params: TShareDownAddParams);
var
  RestoreDownAddLocalHandle : TShareDownAddLocalHandle;
begin
    // 添加
  RestoreDownAddLocalHandle := TShareDownAddLocalHandle.Create( Params.SharePath, Params.OwnerPcID );
  RestoreDownAddLocalHandle.SetIsFile( Params.IsFile );
  RestoreDownAddLocalHandle.SetIsCompleted( False );
  RestoreDownAddLocalHandle.SetSpaceInfo( -1, 0, 0 );
  RestoreDownAddLocalHandle.SetSavePath( Params.SavePath );
  RestoreDownAddLocalHandle.SetDownCompeltedType( Params.DownCompletedType );
  RestoreDownAddLocalHandle.Update;
  RestoreDownAddLocalHandle.Free;

    // 开始 恢复
  DownSelectLocalItem( Params.SharePath, Params.OwnerPcID );
end;

class procedure ShareDownUserApi.AddNetworkItem(
  Params: TShareDownAddParams);
var
  RestoreDownAddNetworkHandle : TShareDownAddNetworkHandle;
begin
    // 添加
  RestoreDownAddNetworkHandle := TShareDownAddNetworkHandle.Create( Params.SharePath, Params.OwnerPcID );
  RestoreDownAddNetworkHandle.SetIsOnline( True );
  RestoreDownAddNetworkHandle.SetIsFile( Params.IsFile );
  RestoreDownAddNetworkHandle.SetIsCompleted( False );
  RestoreDownAddNetworkHandle.SetSpaceInfo( -1, 0, 0 );
  RestoreDownAddNetworkHandle.SetSavePath( Params.SavePath );
  RestoreDownAddNetworkHandle.SetDownCompeltedType( Params.DownCompletedType );
  RestoreDownAddNetworkHandle.Update;
  RestoreDownAddNetworkHandle.Free;

    // 开始 恢复
  DownSelectNetworkItem( Params.SharePath, Params.OwnerPcID );
end;

class procedure ShareDownUserApi.RemoveItem(RestorePath,
  OwnerPcID: string);
var
  RestoreDownRemoveHandle : TShareDownRemoveHandle;
begin
  RestoreDownRemoveHandle := TShareDownRemoveHandle.Create( RestorePath, OwnerPcID );
  RestoreDownRemoveHandle.Update;
  RestoreDownRemoveHandle.Free;
end;

class procedure ShareDownUserApi.DownSelectLocalItem( RestorePath, OwnerPcID : string );
var
  RestoreSelectLocalItemHandle : TShareDownSelectLocalItemHandle;
begin
  RestoreSelectLocalItemHandle := TShareDownSelectLocalItemHandle.Create( RestorePath, OwnerPcID );
  RestoreSelectLocalItemHandle.Update;
  RestoreSelectLocalItemHandle.Free;
end;

class procedure ShareDownUserApi.DownSelectNetworkItem(RestorePath,
  OwnerPcID: string);
var
  RestoreSelectNetworkItemHandle : TShareDownSelectNetworkItemHandle;
begin
  RestoreSelectNetworkItemHandle := TShareDownSelectNetworkItemHandle.Create( RestorePath, OwnerPcID );
  RestoreSelectNetworkItemHandle.Update;
  RestoreSelectNetworkItemHandle.Free;
end;

{ TRestoreDownReadLocalHandle }

procedure TShareDownReadLocalHandle.AddToFace;
var
  OwnerName : string;
  RestoreDownAddLocalFace : TShareDownAddLocalFace;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerPcID );

  RestoreDownAddLocalFace := TShareDownAddLocalFace.Create( SharePath, OwnerPcID );
  RestoreDownAddLocalFace.SetIsFile( IsFile );
  RestoreDownAddLocalFace.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalFace.SetOwnerPcName( OwnerName );
  RestoreDownAddLocalFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalFace.SetSavePath( SavePath );
  RestoreDownAddLocalFace.AddChange;
end;

procedure TShareDownReadLocalHandle.AddToInfo;
var
  RestoreDownAddLocalInfo : TShareDownAddLocalInfo;
begin
  RestoreDownAddLocalInfo := TShareDownAddLocalInfo.Create( SharePath, OwnerPcID );
  RestoreDownAddLocalInfo.SetIsFile( IsFile );
  RestoreDownAddLocalInfo.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalInfo.SetSavePath( SavePath );
  RestoreDownAddLocalInfo.SetDownCompletedType( DownCompletedType );
  RestoreDownAddLocalInfo.Update;
  RestoreDownAddLocalInfo.Free;
end;

procedure TShareDownReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreDownReadNetworkHandle }

procedure TShareDownReadNetworkHandle.AddToFace;
var
  OwnerName : string;
  RestoreDownAddNtworkFace : TShareDownAddNtworkFace;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerPcID );

  RestoreDownAddNtworkFace := TShareDownAddNtworkFace.Create( SharePath, OwnerPcID );
  RestoreDownAddNtworkFace.SetIsOnline( IsOnline );
  RestoreDownAddNtworkFace.SetIsFile( IsFile );
  RestoreDownAddNtworkFace.SetIsCompleted( IsCompleted );
  RestoreDownAddNtworkFace.SetOwnerPcName( OwnerName );
  RestoreDownAddNtworkFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNtworkFace.SetSavePath( SavePath );
  RestoreDownAddNtworkFace.AddChange;
end;

procedure TShareDownReadNetworkHandle.AddToInfo;
var
  RestoreDownAddNetworkInfo : TShareDownAddNetworkInfo;
begin
  RestoreDownAddNetworkInfo := TShareDownAddNetworkInfo.Create( SharePath, OwnerPcID );
  RestoreDownAddNetworkInfo.SetIsFile( IsFile );
  RestoreDownAddNetworkInfo.SetIsCompleted( IsCompleted );
  RestoreDownAddNetworkInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNetworkInfo.SetSavePath( SavePath );
  RestoreDownAddNetworkInfo.SetDownCompletedType( DownCompletedType );
  RestoreDownAddNetworkInfo.Update;
  RestoreDownAddNetworkInfo.Free;
end;

procedure TShareDownReadNetworkHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareDownReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreDownAddLocalHandle }

procedure TShareDownAddLocalHandle.AddToXml;
var
  RestoreDownAddLocalXml : TShareDownAddLocalXml;
begin
  RestoreDownAddLocalXml := TShareDownAddLocalXml.Create( SharePath, OwnerPcID );
  RestoreDownAddLocalXml.SetIsFile( IsFile );
  RestoreDownAddLocalXml.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalXml.SetSavePath( SavePath );
  RestoreDownAddLocalXml.AddChange;
end;

procedure TShareDownAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreDownAddNetworkHandle }

procedure TShareDownAddNetworkHandle.AddToXml;
var
  RestoreDownAddNetworkXml : TShareDownAddNetworkXml;
begin
  RestoreDownAddNetworkXml := TShareDownAddNetworkXml.Create( SharePath, OwnerPcID );
  RestoreDownAddNetworkXml.SetIsFile( IsFile );
  RestoreDownAddNetworkXml.SetIsCompleted( IsCompleted );
  RestoreDownAddNetworkXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNetworkXml.SetSavePath( SavePath );
  RestoreDownAddNetworkXml.AddChange;
end;

procedure TShareDownAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreDownWriteHandle }

constructor TShareDownWriteHandle.Create(_SharePath, _OwnerPcID: string);
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
end;

{ RestoreDownAppApi }

class procedure ShareDownAppApi.AddCompletedSpace(RestorePath,
  OwnerPcID: string; CompletedSpace: Int64);
var
  RestoreDownSetAddCompletedSpaceHandle : TShareDownSetAddCompletedSpaceHandle;
begin
  RestoreDownSetAddCompletedSpaceHandle := TShareDownSetAddCompletedSpaceHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetAddCompletedSpaceHandle.SetAddCompletedSpace( CompletedSpace );
  RestoreDownSetAddCompletedSpaceHandle.Update;
  RestoreDownSetAddCompletedSpaceHandle.Free;
end;



class procedure ShareDownAppApi.CheckLocalRestoreOnline;
var
  CheckLocalOnlineRestoreHandle : TCheckLocalOnlineRestoreHandle;
begin
  CheckLocalOnlineRestoreHandle := TCheckLocalOnlineRestoreHandle.Create;
  CheckLocalOnlineRestoreHandle.Update;
  CheckLocalOnlineRestoreHandle.Free;
end;

class procedure ShareDownAppApi.CheckPcOnlineRestore(DesPcID: string);
var
  CheckPcOnlineRestoreHandle : TCheckPcOnlineRestoreHandle;
begin
  CheckPcOnlineRestoreHandle := TCheckPcOnlineRestoreHandle.Create( DesPcID );
  CheckPcOnlineRestoreHandle.Update;
  CheckPcOnlineRestoreHandle.Free;
end;

class procedure ShareDownAppApi.ContinueRestore;
var
  SharedownContiueHandle : TSharedownContiueHandle;
begin
  SharedownContiueHandle := TSharedownContiueHandle.Create;
  SharedownContiueHandle.Update;
  SharedownContiueHandle.Free;
end;

class procedure ShareDownAppApi.PauseRestore;
var
  ShareDownPauseHandle : TShareDownPauseHandle;
begin
  ShareDownPauseHandle := TShareDownPauseHandle.Create;
  ShareDownPauseHandle.Update;
  ShareDownPauseHandle.Free;
end;

class procedure ShareDownAppApi.RestoreCompleted(RestorePath,
  OwnerPcID: string);
var
  RestoreCompletedHandle : TShareCompletedHandle;
begin
  RestoreCompletedHandle := TShareCompletedHandle.Create( RestorePath, OwnerPcID );
  RestoreCompletedHandle.Update;
  RestoreCompletedHandle.Free;
end;

class procedure ShareDownAppApi.RestoreStop(RestorePath, OwnerPcID: string);
var
  RestoreStopHandle : TShareItemStopHandle;
begin
  RestoreStopHandle := TShareItemStopHandle.Create( RestorePath, OwnerPcID );
  RestoreStopHandle.Update;
  RestoreStopHandle.Free;
end;

class procedure ShareDownAppApi.SetAnalyzeRestore(RestorePath, OwnerPcID: string);
var
  ShareDownSetAnalyzeHandle : TShareDownSetAnalyzeHandle;
begin
  ShareDownSetAnalyzeHandle := TShareDownSetAnalyzeHandle.Create( RestorePath, OwnerPcID );
  ShareDownSetAnalyzeHandle.Update;
  ShareDownSetAnalyzeHandle.Free;
end;

class procedure ShareDownAppApi.SetCompletedSpace(RestorePath,
  OwnerPcID: string; CompletedSpace: Int64);
var
  RestoreDownSetCompletedSizeHandle : TShareDownSetCompletedSizeHandle;
begin
  RestoreDownSetCompletedSizeHandle := TShareDownSetCompletedSizeHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetCompletedSizeHandle.SetCompletedSize( CompletedSpace );
  RestoreDownSetCompletedSizeHandle.Update;
  RestoreDownSetCompletedSizeHandle.Free;
end;



class procedure ShareDownAppApi.SetIsCompleted(RestorePath,
  OwnerPcID: string; IsCompleted: Boolean);
var
  RestoreDownSetIsCompletedHandle : TShareDownSetIsCompletedHandle;
begin
  RestoreDownSetIsCompletedHandle := TShareDownSetIsCompletedHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetIsCompletedHandle.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedHandle.Update;
  RestoreDownSetIsCompletedHandle.Free;
end;


class procedure ShareDownAppApi.SetIsConnect(RestorePath, OwnerPcID: string;
  IsConnect: Boolean);
var
  ShareDownSetIsConnectedHandle : TShareDownSetIsConnectedHandle;
begin
  ShareDownSetIsConnectedHandle := TShareDownSetIsConnectedHandle.Create( RestorePath, OwnerPcID );
  ShareDownSetIsConnectedHandle.SetIsConnected( IsConnect );
  ShareDownSetIsConnectedHandle.Update;
  ShareDownSetIsConnectedHandle.Free;
end;

class procedure ShareDownAppApi.SetIsDesBusy(RestorePath, OwnerPcID: string;
  IsDesBusy: Boolean);
var
  ShareDownSetIsDesBusyHandle : TShareDownSetIsDesBusyHandle;
begin
  ShareDownSetIsDesBusyHandle := TShareDownSetIsDesBusyHandle.Create( RestorePath, OwnerPcID );
  ShareDownSetIsDesBusyHandle.SetIsDesBusy( IsDesBusy );
  ShareDownSetIsDesBusyHandle.Update;
  ShareDownSetIsDesBusyHandle.Free;
end;



class procedure ShareDownAppApi.SetIsExist(RestorePath,
  OwnerPcID : string; IsExist: Boolean);
var
  RestoreDownSetIsExistHandle : TShareDownSetIsExistHandle;
begin
  RestoreDownSetIsExistHandle := TShareDownSetIsExistHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetIsExistHandle.SetIsExist( IsExist );
  RestoreDownSetIsExistHandle.Update;
  RestoreDownSetIsExistHandle.Free;
end;

class procedure ShareDownAppApi.SetIsLackSpace(RestorePath,
  OwnerPcID: string; IsLackSpace: Boolean);
var
  RestoreDownSetIsLackSpaceHandle : TShareDownSetIsLackSpaceHandle;
begin
  RestoreDownSetIsLackSpaceHandle := TShareDownSetIsLackSpaceHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetIsLackSpaceHandle.SetIsLackSpace( IsLackSpace );
  RestoreDownSetIsLackSpaceHandle.Update;
  RestoreDownSetIsLackSpaceHandle.Free;
end;

class procedure ShareDownAppApi.SetIsLostConn(RestorePath, OwnerPcID: string;
  IsLostConn: Boolean);
var
  ShareDownSetIsLostConnHandle : TShareDownSetIsLostConnHandle;
begin
  ShareDownSetIsLostConnHandle := TShareDownSetIsLostConnHandle.Create( RestorePath, OwnerPcID );
  ShareDownSetIsLostConnHandle.SetIsLostConn( IsLostConn );
  ShareDownSetIsLostConnHandle.Update;
  ShareDownSetIsLostConnHandle.Free;
end;

class procedure ShareDownAppApi.SetIsRestoring(RestorePath,
  OwnerPcID: string; IsRestoring: Boolean);
var
  RestoreDownSetIsRestoringHandle : TShareDownSetIsRestoringHandle;
begin
  RestoreDownSetIsRestoringHandle := TShareDownSetIsRestoringHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetIsRestoringHandle.SetIsRestoring( IsRestoring );
  RestoreDownSetIsRestoringHandle.Update;
  RestoreDownSetIsRestoringHandle.Free;
end;



class procedure ShareDownAppApi.SetIsWrite(RestorePath,
  OwnerPcID: string; IsWrite: Boolean);
var
  RestoreDownSetIsWriteHandle : TShareDownSetIsWriteHandle;
begin
  RestoreDownSetIsWriteHandle := TShareDownSetIsWriteHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetIsWriteHandle.SetIsWrite( IsWrite );
  RestoreDownSetIsWriteHandle.Update;
  RestoreDownSetIsWriteHandle.Free;
end;



class procedure ShareDownAppApi.SetPcOnline(DesPcID: string;
  IsOnline: Boolean);
var
  RestoreDownPcIsOnlineHandle : TShareDownPcIsOnlineHandle;
begin
  RestoreDownPcIsOnlineHandle := TShareDownPcIsOnlineHandle.Create( DesPcID );
  RestoreDownPcIsOnlineHandle.SetIsOnline( IsOnline );
  RestoreDownPcIsOnlineHandle.Update;
  RestoreDownPcIsOnlineHandle.Free;
end;

class procedure ShareDownAppApi.SetStatus(RestorePath, OwnerPcID,
  NodeStatus: string);
var
  RestoreDownSetStautsHandle : TShareDownSetStautsHandle;
begin
  RestoreDownSetStautsHandle := TShareDownSetStautsHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetStautsHandle.SetNodeStatus( NodeStatus );
  RestoreDownSetStautsHandle.Update;
  RestoreDownSetStautsHandle.Free;
end;

class procedure ShareDownAppApi.SetScaningCount(RestorePath,
  OwnerPcID: string; FileCount: Integer);
var
  RestoreDownSetAnalyzeCountHandle : TShareDownSetAnalyzeCountHandle;
begin
  RestoreDownSetAnalyzeCountHandle := TShareDownSetAnalyzeCountHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetAnalyzeCountHandle.SetAnalyzeCount( FileCount );
  RestoreDownSetAnalyzeCountHandle.Update;
  RestoreDownSetAnalyzeCountHandle.Free;
end;



class procedure ShareDownAppApi.SetSpaceInfo(
  Params: TShareDownSetSpaceParams);
var
  RestoreDownSetSpaceInfoHandle : TShareDownSetSpaceInfoHandle;
begin
  RestoreDownSetSpaceInfoHandle := TShareDownSetSpaceInfoHandle.Create( Params.RestorePath, Params.OwnerPcID );
  RestoreDownSetSpaceInfoHandle.SetSpaceInfo( Params.FileCount, Params.FileSize, Params.CompletedSize );
  RestoreDownSetSpaceInfoHandle.Update;
  RestoreDownSetSpaceInfoHandle.Free;
end;



class procedure ShareDownAppApi.SetSpeed(RestorePath, OwnerPcID: string;
  Speed: Int64);
var
  RestoreDownSetSpeedHandle : TShareDownSetSpeedHandle;
begin
  RestoreDownSetSpeedHandle := TShareDownSetSpeedHandle.Create( RestorePath, OwnerPcID );
  RestoreDownSetSpeedHandle.SetSpeed( Speed );
  RestoreDownSetSpeedHandle.Update;
  RestoreDownSetSpeedHandle.Free;
end;



class procedure ShareDownAppApi.SetStartRestore(RestorePath, OwnerPcID: string);
begin
  SetSpeed( RestorePath, OwnerPcID, 0 );
  SetStatus( RestorePath, OwnerPcID, RestoreNodeStatus_Restoreing );
end;

class procedure ShareDownAppApi.WaitingRestore(RestorePath,
  OwnerPcID: string);
begin
  SetStatus( RestorePath, OwnerPcID, RestoreNodeStatus_WaitingRestore );
end;


class procedure ShareDownAppApi.StartRestore;
var
  RestoreStartHandle : TShareDownStartHandle;
begin
  RestoreStartHandle := TShareDownStartHandle.Create;
  RestoreStartHandle.Update;
  RestoreStartHandle.Free;
end;

class procedure ShareDownAppApi.StopRestore;
var
  RestoreStopHandle : TShareDownStopHandle;
begin
  RestoreStopHandle := TShareDownStopHandle.Create;
  RestoreStopHandle.Update;
  RestoreStopHandle.Free;
end;

{ TRestoreDownSetStautsHandle }

procedure TShareDownSetStautsHandle.SetNodeStatus(_NodeStatus: string);
begin
  NodeStatus := _NodeStatus;
end;

procedure TShareDownSetStautsHandle.SetToFace;
var
  RestoreDownSetStautsFace : TShareDownSetStautsFace;
begin
  RestoreDownSetStautsFace := TShareDownSetStautsFace.Create( SharePath, OwnerPcID );
  RestoreDownSetStautsFace.SetNodeStatus( NodeStatus );
  RestoreDownSetStautsFace.AddChange;
end;

procedure TShareDownSetStautsHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetIsLackSpaceHandle }

procedure TShareDownSetIsLackSpaceHandle.SetIsLackSpace(
  _IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TShareDownSetIsLackSpaceHandle.SetToFace;
var
  RestoreDownSetIsLackSpaceFace : TShareDownSetIsLackSpaceFace;
begin
  RestoreDownSetIsLackSpaceFace := TShareDownSetIsLackSpaceFace.Create( SharePath, OwnerPcID );
  RestoreDownSetIsLackSpaceFace.SetIsLackSpace( IsLackSpace );
  RestoreDownSetIsLackSpaceFace.AddChange;
end;

procedure TShareDownSetIsLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetIsHandle }

procedure TShareDownSetIsExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TShareDownSetIsExistHandle.SetToFace;
var
  RestoreDownSetIsExistFace : TShareDownSetIsExistFace;
begin
  RestoreDownSetIsExistFace := TShareDownSetIsExistFace.Create( SharePath, OwnerPcID );
  RestoreDownSetIsExistFace.SetIsExist( IsExist );
  RestoreDownSetIsExistFace.AddChange;
end;


procedure TShareDownSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetSpaceInfoHandle }

procedure TShareDownSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetSpaceInfoHandle.SetToInfo;
var
  RestoreDownSetSpaceInfoInfo : TShareDownSetSpaceInfoInfo;
begin
  RestoreDownSetSpaceInfoInfo := TShareDownSetSpaceInfoInfo.Create( SharePath, OwnerPcID );
  RestoreDownSetSpaceInfoInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoInfo.Update;
  RestoreDownSetSpaceInfoInfo.Free;
end;

procedure TShareDownSetSpaceInfoHandle.SetToXml;
var
  RestoreDownSetSpaceInfoXml : TShareDownSetSpaceInfoXml;
begin
  RestoreDownSetSpaceInfoXml := TShareDownSetSpaceInfoXml.Create( SharePath, OwnerPcID );
  RestoreDownSetSpaceInfoXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoXml.AddChange;
end;

procedure TShareDownSetSpaceInfoHandle.SetToFace;
var
  RestoreDownSetSpaceInfoFace : TShareDownSetSpaceInfoFace;
begin
  RestoreDownSetSpaceInfoFace := TShareDownSetSpaceInfoFace.Create( SharePath, OwnerPcID );
  RestoreDownSetSpaceInfoFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoFace.AddChange;
end;

procedure TShareDownSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TRestoreDownSetAddCompletedSpaceHandle }

procedure TShareDownSetAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TShareDownSetAddCompletedSpaceHandle.SetToInfo;
var
  RestoreDownSetAddCompletedSpaceInfo : TShareDownSetAddCompletedSpaceInfo;
begin
  RestoreDownSetAddCompletedSpaceInfo := TShareDownSetAddCompletedSpaceInfo.Create( SharePath, OwnerPcID );
  RestoreDownSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceInfo.Update;
  RestoreDownSetAddCompletedSpaceInfo.Free;
end;

procedure TShareDownSetAddCompletedSpaceHandle.SetToXml;
var
  RestoreDownSetAddCompletedSpaceXml : TShareDownSetAddCompletedSpaceXml;
begin
  RestoreDownSetAddCompletedSpaceXml := TShareDownSetAddCompletedSpaceXml.Create( SharePath, OwnerPcID );
  RestoreDownSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceXml.AddChange;
end;

procedure TShareDownSetAddCompletedSpaceHandle.SetToFace;
var
  RestoreDownSetAddCompletedSpaceFace : TShareDownSetAddCompletedSpaceFace;
begin
  RestoreDownSetAddCompletedSpaceFace := TShareDownSetAddCompletedSpaceFace.Create( SharePath, OwnerPcID );
  RestoreDownSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceFace.AddChange;
end;

procedure TShareDownSetAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TRestoreDownSetSpeedHandle }

procedure TShareDownSetSpeedHandle.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TShareDownSetSpeedHandle.SetToFace;
var
  RestoreDownSetSpeedFace : TShareDownSetSpeedFace;
begin
  RestoreDownSetSpeedFace := TShareDownSetSpeedFace.Create( SharePath, OwnerPcID );
  RestoreDownSetSpeedFace.SetSpeed( Speed );
  RestoreDownSetSpeedFace.AddChange;
end;

procedure TShareDownSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ TRestoreSelectLocalItemHandle }

procedure TShareDownSelectLocalItemHandle.AddToScan;
var
  RestoreScanLocalInfo : TShareDownScanLocalInfo;
begin
  RestoreScanLocalInfo := TShareDownScanLocalInfo.Create( SharePath, OwnerPcID );
  RestoreScanLocalInfo.SetIsFile( IsFile );
  MyShareDownHandler.AddShareDownJob( RestoreScanLocalInfo );
end;

{ TRestoreSelectItemHandle }

procedure TShareDownSelectItemHandle.ReadRestoreScanInfo;
var
  ScanInfo : TRestoreDownScanInfo;
begin
  ScanInfo := ShareDownInfoReadUtil.ReadScanInfo( SharePath, OwnerPcID );
  IsFile := ScanInfo.IsFile;
  IsDeleted := ScanInfo.IsDeleted;
  ScanInfo.Free;
end;

procedure TShareDownSelectItemHandle.Update;
begin
    // 正在恢复
  if ShareDownInfoReadUtil.ReadIsDownloading( SharePath, OwnerPcID ) then
    Exit;

    // 读取扫描信息
  ReadRestoreScanInfo;

    // 正在恢复
  ShareDownAppApi.SetIsRestoring( SharePath, OwnerPcID, True );

    // 刷新界面显示
  ShareDownAppApi.WaitingRestore( SharePath, OwnerPcID );

    // 设置 恢复未完成
  ShareDownAppApi.SetIsCompleted( SharePath, OwnerPcID, False );

    // 设置 非远程繁忙
  ShareDownAppApi.SetIsDesBusy( SharePath, OwnerPcID, False );

    // 设置 非断开连接
  ShareDownAppApi.SetIsLostConn( SharePath, OwnerPcID, False );

    // 添加到扫描线程
  AddToScan;
end;

{ TRestoreSelectNetworkItemHandle }

procedure TShareDownSelectNetworkItemHandle.AddToScan;
var
  RestoreScanNetworkInfo : TShareDownScanNetworkInfo;
begin
  RestoreScanNetworkInfo := TShareDownScanNetworkInfo.Create( SharePath, OwnerPcID );
  RestoreScanNetworkInfo.SetIsFile( IsFile );
  MyShareDownHandler.AddShareDownJob( RestoreScanNetworkInfo );
end;

{ RestoreExplorerUserApi }

class procedure ShareExplorerUserApi.ReadLocal(RestorePath, OwnerID: string;
  IsFile, IsSearch : Boolean);
var
  RestoreScanLocalExplorerInfo : TShareDownScanLocalExplorerInfo;
begin
    // 扫描
  RestoreScanLocalExplorerInfo := TShareDownScanLocalExplorerInfo.Create( RestorePath, OwnerID );
  RestoreScanLocalExplorerInfo.SetIsFile( IsFile );
  RestoreScanLocalExplorerInfo.SetIsSearch( IsSearch );
  MyShareExplorerHandler.AddShareDownJob( RestoreScanLocalExplorerInfo );
end;

class procedure ShareExplorerUserApi.ReadNetwork(RestorePath,
  OwnerID : string; IsFile, IsSearch : Boolean);
var
  RestoreScanNetworkExplorerInfo : TShareDownScanNetworkExplorerInfo;
begin
    // 扫描
  RestoreScanNetworkExplorerInfo := TShareDownScanNetworkExplorerInfo.Create( RestorePath, OwnerID );
  RestoreScanNetworkExplorerInfo.SetIsFile( IsFile );
  RestoreScanNetworkExplorerInfo.SetIsSearch( IsSearch );
  MyShareExplorerHandler.AddShareDownJob( RestoreScanNetworkExplorerInfo );

    // 添加到历史
  if not IsFile then
    ShareExplorerHistoryApi.AddItem( OwnerID, RestorePath );
end;

{ RestoreExplorerAppApi }

class procedure ShareExplorerAppApi.SharePcBusy;
var
  ShareExplorerBusyFace : TShareExplorerBusyFace;
begin
  ShareExplorerBusyFace := TShareExplorerBusyFace.Create;
  ShareExplorerBusyFace.AddChange;
end;

class procedure ShareExplorerAppApi.SharePcNotConn;
var
  ShareExplorerNotConnFace : TShareExplorerNotConnFace;
begin
  ShareExplorerNotConnFace := TShareExplorerNotConnFace.Create;
  ShareExplorerNotConnFace.AddChange;
end;

class procedure ShareExplorerAppApi.ShowFileResult(
  Params: TExplorerResultParams);
var
  ShareExplorerSetFace : TShareExplorerSetFace;
begin
  ShareExplorerSetFace := TShareExplorerSetFace.Create( Params.FilePath );
  ShareExplorerSetFace.SetFileInfo( Params.FileSize, Params.FileTime );
  ShareExplorerSetFace.AddChange;
end;

class procedure ShareExplorerAppApi.ShowFolderResult(Params: TExplorerResultParams);
var
  RestoreExplorerAddFace : TShareExplorerAddFace;
begin
  RestoreExplorerAddFace := TShareExplorerAddFace.Create( Params.FilePath );
  RestoreExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreExplorerAddFace.AddChange;
end;

class procedure ShareExplorerAppApi.StartExplorer;
var
  ShareExplorerStartFace : TShareExplorerStartFace;
begin
  ShareExplorerStartFace := TShareExplorerStartFace.Create;
  ShareExplorerStartFace.AddChange;
end;

class procedure ShareExplorerAppApi.StopExplorer;
var
  ShareExplorerStopFace : TShareExplorerStopFace;
begin
  ShareExplorerStopFace := TShareExplorerStopFace.Create;
  ShareExplorerStopFace.AddChange;
end;

{ TRestoreFileSelectHandle }

procedure TRestoreFileSelectHandle.AddChildPath(ChildRestoreInfo : TChildRestoreInfo);
begin
  ChildRestoreList.Add( ChildRestoreInfo );
end;

procedure TRestoreFileSelectHandle.AddRestoreDown;
var
  Params : TShareDownAddParams;
  i : Integer;
  ChildPath, FolderSavePath : string;
begin
  Params.OwnerPcID := OwnerID;

  for i := 0 to ChildRestoreList.Count - 1 do
  begin
    ChildPath := ChildRestoreList[i].FilePath;
    Params.SharePath := ChildPath;
    Params.IsFile := ChildRestoreList[i].IsFile;

    if ChildPath = RestorePath then
      FolderSavePath := SavePath
    else
      FolderSavePath := MyFilePath.getPath( SavePath ) + ExtractFileName( ChildPath );
    Params.SavePath := FolderSavePath;

    if IsLocalRestore then
      ShareDownUserApi.AddLocalItem( Params )
    else
      ShareDownUserApi.AddNetworkItem( Params );
  end;
end;

constructor TRestoreFileSelectHandle.Create(_RestorePath: string;
  _IsFile : Boolean);
begin
  RestorePath := _RestorePath;
  IsFile := _IsFile;
  ChildRestoreList := TChildRestoreList.Create;
end;

destructor TRestoreFileSelectHandle.Destroy;
begin
  ChildRestoreList.Free;
  inherited;
end;

function TRestoreFileSelectHandle.FindSavePath: Boolean;
begin
//  frmSelectRestore.SetRestoreInfo( RestorePath, OwnerName, IsFile, IsDeleted );
//  frmSelectRestore.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
//  Result := frmSelectRestore.getIsRestore;
  if not Result then
    Exit;
//  SavePath := frmSelectRestore.getRestoreTo;
//  RestorePassword := frmSelectRestore.getPassword;
end;

procedure TRestoreFileSelectHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreFileSelectHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TRestoreFileSelectHandle.SetIsLocalRestore(_IsLocalRestore: Boolean);
begin
  IsLocalRestore := _IsLocalRestore;
end;

procedure TRestoreFileSelectHandle.SetOwnerID(_OwnerID, _OwerName: string);
begin
  OwnerID := _OwnerID;
  OwnerName := _OwerName;
end;

procedure TRestoreFileSelectHandle.SetRestoreFrom(_RestoreFrom, _RestoreFromName: string);
begin
  RestoreFrom := _RestoreFrom;
  RestoreFromName := _RestoreFromName;
end;

function TRestoreFileSelectHandle.Update: Boolean;
begin
  Result := FindSavePath;
  if not Result then
    Exit;

  AddRestoreDown;
end;

{ TChildRestoreInfo }

constructor TChildRestoreInfo.Create(_FilePath: string; _IsFile: Boolean);
begin
  FilePath := _FilePath;
  IsFile := _IsFile;
end;

procedure TChildRestoreInfo.SetFileInfo(_FileCount, _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

{ TRestoreDownSetIsWriteHandle }

procedure TShareDownSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TShareDownSetIsWriteHandle.SetToFace;
var
  RestoreDownSetIsWriteFace : TShareDownSetIsWriteFace;
begin
  RestoreDownSetIsWriteFace := TShareDownSetIsWriteFace.Create( SharePath, OwnerPcID );
  RestoreDownSetIsWriteFace.SetIsWrite( IsWrite );
  RestoreDownSetIsWriteFace.AddChange;
end;

procedure TShareDownSetIsWriteHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownPcIsOnlineHandle }

constructor TShareDownPcIsOnlineHandle.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TShareDownPcIsOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareDownPcIsOnlineHandle.SetToFace;
var
  RestoreDownSetPcIsOnlineFace : TShareDownSetPcIsOnlineFace;
begin
  RestoreDownSetPcIsOnlineFace := TShareDownSetPcIsOnlineFace.Create( DesPcID );
  RestoreDownSetPcIsOnlineFace.SetIsOnline( IsOnline );
  RestoreDownSetPcIsOnlineFace.AddChange;
end;

procedure TShareDownPcIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetCompletedSizeHandle }

procedure TShareDownSetCompletedSizeHandle.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetCompletedSizeHandle.SetToInfo;
var
  RestoreDownSetCompletedSizeInfo : TShareDownSetCompletedSizeInfo;
begin
  RestoreDownSetCompletedSizeInfo := TShareDownSetCompletedSizeInfo.Create( SharePath, OwnerPcID );
  RestoreDownSetCompletedSizeInfo.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeInfo.Update;
  RestoreDownSetCompletedSizeInfo.Free;
end;

procedure TShareDownSetCompletedSizeHandle.SetToXml;
var
  RestoreDownSetCompletedSizeXml : TShareDownSetCompletedSizeXml;
begin
  RestoreDownSetCompletedSizeXml := TShareDownSetCompletedSizeXml.Create( SharePath, OwnerPcID );
  RestoreDownSetCompletedSizeXml.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeXml.AddChange;
end;

procedure TShareDownSetCompletedSizeHandle.SetToFace;
var
  RestoreDownSetCompletedSizeFace : TShareDownSetCompletedSizeFace;
begin
  RestoreDownSetCompletedSizeFace := TShareDownSetCompletedSizeFace.Create( SharePath, OwnerPcID );
  RestoreDownSetCompletedSizeFace.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeFace.AddChange;
end;

procedure TShareDownSetCompletedSizeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;




{ TCheckPcOnlineRestoreHandle }

constructor TCheckPcOnlineRestoreHandle.Create(_DesPcID: string);
begin
  OnlinePcID := _DesPcID;
end;

procedure TCheckPcOnlineRestoreHandle.Update;
var
  OnlineRestoreList : TShareDonwReadDataList;
  OnlineRestoreInfo : TShareDownReadDataInfo;
  i : Integer;
begin
  OnlineRestoreList := ShareDownInfoReadUtil.ReadOnlineRestore( OnlinePcID );
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    ShareDownUserApi.DownSelectNetworkItem( OnlineRestoreInfo.SharePath, OnlineRestoreInfo.OwnerPcID );
  end;
  OnlineRestoreList.Free
end;

{ TRestoreDownSetIsCompletedHandle }

procedure TShareDownSetIsCompletedHandle.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownSetIsCompletedHandle.SetToInfo;
var
  RestoreDownSetIsCompletedInfo : TShareDownSetIsCompletedInfo;
begin
  RestoreDownSetIsCompletedInfo := TShareDownSetIsCompletedInfo.Create( SharePath, OwnerPcID );
  RestoreDownSetIsCompletedInfo.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedInfo.Update;
  RestoreDownSetIsCompletedInfo.Free;
end;

procedure TShareDownSetIsCompletedHandle.SetToXml;
var
  RestoreDownSetIsCompletedXml : TShareDownSetIsCompletedXml;
begin
  RestoreDownSetIsCompletedXml := TShareDownSetIsCompletedXml.Create( SharePath, OwnerPcID );
  RestoreDownSetIsCompletedXml.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedXml.AddChange;
end;

procedure TShareDownSetIsCompletedHandle.SetToFace;
var
  RestoreDownSetIsCompletedFace : TShareDownSetIsCompletedFace;
begin
  RestoreDownSetIsCompletedFace := TShareDownSetIsCompletedFace.Create( SharePath, OwnerPcID );
  RestoreDownSetIsCompletedFace.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedFace.AddChange;
end;

procedure TShareDownSetIsCompletedHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TCheckLocalOnlineRestoreHandle }

procedure TCheckLocalOnlineRestoreHandle.Update;
var
  OnlineRestoreList : TShareDonwReadDataList;
  OnlineRestoreInfo : TShareDownReadDataInfo;
  i : Integer;
begin
  OnlineRestoreList := ShareDownInfoReadUtil.ReadLocalStartRestore;
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    ShareDownUserApi.DownSelectLocalItem( OnlineRestoreInfo.SharePath, OnlineRestoreInfo.OwnerPcID );
  end;
  OnlineRestoreList.Free
end;

{ TRestoreDownSetIsRestoringHandle }

procedure TShareDownSetIsRestoringHandle.SetIsRestoring( _IsRestoring : boolean );
begin
  IsRestoring := _IsRestoring;
end;

procedure TShareDownSetIsRestoringHandle.SetToInfo;
var
  RestoreDownSetIsRestoringInfo : TShareDownSetIsDownloadingInfo;
begin
  RestoreDownSetIsRestoringInfo := TShareDownSetIsDownloadingInfo.Create( SharePath, OwnerPcID );
  RestoreDownSetIsRestoringInfo.SetIsDownloading( IsRestoring );
  RestoreDownSetIsRestoringInfo.Update;
  RestoreDownSetIsRestoringInfo.Free;
end;


procedure TShareDownSetIsRestoringHandle.SetToFace;
var
  RestoreDownSetIsRestoringFace : TShareDownSetIsDownloadingFace;
begin
  RestoreDownSetIsRestoringFace := TShareDownSetIsDownloadingFace.Create( SharePath, OwnerPcID );
  RestoreDownSetIsRestoringFace.SetIsRestoring( IsRestoring );
  RestoreDownSetIsRestoringFace.AddChange;
end;

procedure TShareDownSetIsRestoringHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;




{ TRestoreStopHandle }

procedure TShareItemStopHandle.Update;
begin
    // 设置 非正在恢复
  ShareDownAppApi.SetIsRestoring( SharePath, OwnerPcID, False );

    // 设置 界面状态为空
  ShareDownAppApi.SetStatus( SharePath, OwnerPcID, RestoreNodeStatus_Empty );
end;

{ TRestoreStopHandle }

procedure TShareDownStopHandle.SetToFace;
var
  RestoreDownStopFace : TShareDownStopFace;
begin
  RestoreDownStopFace := TShareDownStopFace.Create;
  RestoreDownStopFace.AddChange;
end;

procedure TShareDownStopHandle.Update;
begin
  SetToFace;
end;

{ TRestoreCompletedHandle }

procedure TShareCompletedHandle.AddToHint;
var
  OwnerName, Destination : string;
  IsFile : Boolean;
begin
    // 显示 Hint
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerPcID );
  Destination := ShareDownInfoReadUtil.ReadSavePath( SharePath, OwnerPcID );
  IsFile := ShareDownInfoReadUtil.ReadIsFile( SharePath, OwnerPcID );

  MyHintAppApi.ShowDownShareCompleted( Destination, OwnerName, IsFile );
end;

procedure TShareCompletedHandle.CheckDownCompletedType;
var
  DownCompletedType, SavePath : string;
  ShareDownSetDownCompletedTypeInfo : TShareDownSetDownCompletedTypeInfo;
begin
  DownCompletedType := ShareDownInfoReadUtil.ReadCompletedType( SharePath, OwnerPcID );
  if DownCompletedType = '' then
    Exit;

    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SavePath := ShareDownInfoReadUtil.ReadSavePath( SharePath, OwnerPcID );

      // 处理
  if DownCompletedType = DownCompletedType_Run then
    MyExplore.OpenFile( SavePath )
  else
  if DownCompletedType = DownCompletedType_Explorer then
    MyExplore.OpenFolder( SavePath );

    // 值重置
  ShareDownSetDownCompletedTypeInfo := TShareDownSetDownCompletedTypeInfo.Create( SharePath, OwnerPcID );
  ShareDownSetDownCompletedTypeInfo.SetDownCompletedType( '' );
  ShareDownSetDownCompletedTypeInfo.Update;
  ShareDownSetDownCompletedTypeInfo.Free;
end;

procedure TShareCompletedHandle.RefreshIcon;
var
  ShareDownRefreshIconFace : TShareDownRefreshIconFace;
begin
  ShareDownRefreshIconFace := TShareDownRefreshIconFace.Create( SharePath, OwnerPcID );
  ShareDownRefreshIconFace.AddChange;
end;

procedure TShareCompletedHandle.Update;
begin
    // 设置 备份完成
  ShareDownAppApi.SetIsCompleted( SharePath, OwnerPcID, True );

    // 检查下载完成后的操作
  CheckDownCompletedType;

    // 显示 Hint
  AddToHint;

    // 刷新图标
  RefreshIcon;
end;

{ TRestoreStartHandle }

procedure TShareDownStartHandle.SetToFace;
var
  RestoreDownStartFace : TShareDownStartFace;
begin
  RestoreDownStartFace := TShareDownStartFace.Create;
  RestoreDownStartFace.AddChange;
end;

procedure TShareDownStartHandle.Update;
begin
  UserShareDown_IsStop := False;

  SetToFace;
end;

{ TRestoreDownSetAnalyzeCountHandle }

procedure TShareDownSetAnalyzeCountHandle.SetAnalyzeCount( _AnalyzeCount : integer );
begin
  AnalyzeCount := _AnalyzeCount;
end;

procedure TShareDownSetAnalyzeCountHandle.SetToFace;
var
  RestoreDownSetAnalyzeCountFace : TShareDownSetAnalyzeCountFace;
begin
  RestoreDownSetAnalyzeCountFace := TShareDownSetAnalyzeCountFace.Create( SharePath, OwnerPcID );
  RestoreDownSetAnalyzeCountFace.SetAnalyzeCount( AnalyzeCount );
  RestoreDownSetAnalyzeCountFace.AddChange;
end;

procedure TShareDownSetAnalyzeCountHandle.Update;
begin
  SetToFace;
end;


procedure TShareDownContinusWriteHandle.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;

{ TShareDownContinusReadHandle }

procedure TShareDownContinusReadHandle.SetSpaceInfo( _FileSize, _Postion : int64 );
begin
  FileSize := _FileSize;
  Postion := _Postion;
end;

procedure TShareDownContinusReadHandle.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TShareDownContinusReadHandle.AddToInfo;
var
  ShareDownContinusAddInfo : TShareDownContinusAddInfo;
begin
  ShareDownContinusAddInfo := TShareDownContinusAddInfo.Create( SharePath, OwnerPcID );
  ShareDownContinusAddInfo.SetFilePath( FilePath );
  ShareDownContinusAddInfo.SetSpaceInfo( FileSize, Postion );
  ShareDownContinusAddInfo.SetFileTime( FileTime );
  ShareDownContinusAddInfo.Update;
  ShareDownContinusAddInfo.Free;
end;

procedure TShareDownContinusReadHandle.Update;
begin
  AddToInfo;
end;

{ TShareDownContinusAddHandle }

procedure TShareDownContinusAddHandle.AddToXml;
var
  ShareDownContinusAddXml : TShareDownContinusAddXml;
begin
  ShareDownContinusAddXml := TShareDownContinusAddXml.Create( SharePath, OwnerPcID );
  ShareDownContinusAddXml.SetFilePath( FilePath );
  ShareDownContinusAddXml.SetSpaceInfo( FileSize, Postion );
  ShareDownContinusAddXml.SetFileTime( FileTime );
  ShareDownContinusAddXml.AddChange;
end;

procedure TShareDownContinusAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TShareDownContinusRemoveHandle }

procedure TShareDownContinusRemoveHandle.RemoveFromInfo;
var
  ShareDownContinusRemoveInfo : TShareDownContinusRemoveInfo;
begin
  ShareDownContinusRemoveInfo := TShareDownContinusRemoveInfo.Create( SharePath, OwnerPcID );
  ShareDownContinusRemoveInfo.SetFilePath( FilePath );
  ShareDownContinusRemoveInfo.Update;
  ShareDownContinusRemoveInfo.Free;
end;

procedure TShareDownContinusRemoveHandle.RemoveFromXml;
var
  ShareDownContinusRemoveXml : TShareDownContinusRemoveXml;
begin
  ShareDownContinusRemoveXml := TShareDownContinusRemoveXml.Create( SharePath, OwnerPcID );
  ShareDownContinusRemoveXml.SetFilePath( FilePath );
  ShareDownContinusRemoveXml.AddChange;
end;

procedure TShareDownContinusRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;






{ ShareDownContinusApi }

class procedure ShareDownContinusApi.AddItem(
  Params: TShareDownContinusAddParams);
var
  ShareDownContinusAddHandle : TShareDownContinusAddHandle;
begin
  ShareDownContinusAddHandle := TShareDownContinusAddHandle.Create( Params.SharePath, Params.OwnerID );
  ShareDownContinusAddHandle.SetFilePath( Params.FilePath );
  ShareDownContinusAddHandle.SetSpaceInfo( Params.FileSize, Params.Position );
  ShareDownContinusAddHandle.SetFileTime( Params.FileTime );
  ShareDownContinusAddHandle.Update;
  ShareDownContinusAddHandle.Free;
end;


class procedure ShareDownContinusApi.RemoveItem(SharePath, OwnerID,
  FilePath: string);
var
  ShareDownContinusRemoveHandle : TShareDownContinusRemoveHandle;
begin
  ShareDownContinusRemoveHandle := TShareDownContinusRemoveHandle.Create( SharePath, OwnerID );
  ShareDownContinusRemoveHandle.SetFilePath( FilePath );
  ShareDownContinusRemoveHandle.Update;
  ShareDownContinusRemoveHandle.Free;
end;



{ ShareDownErrorApi }

class procedure ShareDownErrorApi.AddItem(Params: TShareDownErrorAddParams);
var
  ShareDownErrorAddHandle : TShareDownErrorAddHandle;
begin
  ShareDownErrorAddHandle := TShareDownErrorAddHandle.Create( Params.SharePath, Params.OwnerID );
  ShareDownErrorAddHandle.SetFilePath( Params.FilePath );
  ShareDownErrorAddHandle.SetSpaceInfo( Params.FileSize, Params.CompletedSize );
  ShareDownErrorAddHandle.SetErrorStatus( Params.ErrorStatus );
  ShareDownErrorAddHandle.Update;
  ShareDownErrorAddHandle.Free;
end;

class procedure ShareDownErrorApi.ClearItem(SharePath, OwnerID: string);
var
  ShareDownErrorClearHandle : TShareDownErrorClearHandle;
begin
  ShareDownErrorClearHandle := TShareDownErrorClearHandle.Create( SharePath, OwnerID );
  ShareDownErrorClearHandle.Update;
  ShareDownErrorClearHandle.Free;
end;

class procedure ShareDownErrorApi.LostConnectError(
  Params: TShareDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_LostConnectError;
  AddItem( Params );
end;

class procedure ShareDownErrorApi.ReadFileError(
  Params: TShareDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_ReadFileError;
  AddItem( Params );
end;

class procedure ShareDownErrorApi.ReceiveFileError(
  Params: TShareDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_ReceiveFileError;
  AddItem( Params );
end;

class procedure ShareDownErrorApi.WriteFileError(
  Params: TShareDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_WriteFileError;
  AddItem( Params );
end;

{ TShareDownErrorAddHandle }

procedure TShareDownErrorAddHandle.AddToFace;
var
  SendItemErrorAddFace : TShareDownErrorAddFace;
begin
  SendItemErrorAddFace := TShareDownErrorAddFace.Create( SharePath, OwnerPcID );
  SendItemErrorAddFace.SetFilePath( FilePath );
  SendItemErrorAddFace.SetSpaceInfo( FileSize, CompletedSpace );
  SendItemErrorAddFace.SetErrorStatus( ErrorStatus );
  SendItemErrorAddFace.AddChange;
end;

procedure TShareDownErrorAddHandle.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TShareDownErrorAddHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownErrorAddHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TShareDownErrorAddHandle.Update;
begin
  AddToFace;
end;

{ TShareDownErrorClearHandle }

procedure TShareDownErrorClearHandle.ClearToFace;
var
  SendItemErrorClearFace : TShareDownErrorClearFace;
begin
  SendItemErrorClearFace := TShareDownErrorClearFace.Create( SharePath, OwnerPcID );
  SendItemErrorClearFace.AddChange;
end;

procedure TShareDownErrorClearHandle.Update;
begin
  ClearToFace;
end;

{ TShareDownSetIsDesBusyHandle }

procedure TShareDownSetIsDesBusyHandle.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TShareDownSetIsDesBusyHandle.SetToInfo;
var
  ShareDownSetIsDesBusyInfo : TShareDownSetIsDesBusyInfo;
begin
  ShareDownSetIsDesBusyInfo := TShareDownSetIsDesBusyInfo.Create( SharePath, OwnerPcID );
  ShareDownSetIsDesBusyInfo.SetIsDesBusy( IsDesBusy );
  ShareDownSetIsDesBusyInfo.Update;
  ShareDownSetIsDesBusyInfo.Free;
end;


procedure TShareDownSetIsDesBusyHandle.SetToFace;
var
  ShareDownSetIsDesBusyFace : TShareDownSetIsDesBusyFace;
begin
  ShareDownSetIsDesBusyFace := TShareDownSetIsDesBusyFace.Create( SharePath, OwnerPcID );
  ShareDownSetIsDesBusyFace.SetIsDesBusy( IsDesBusy );
  ShareDownSetIsDesBusyFace.AddChange;
end;

procedure TShareDownSetIsDesBusyHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TShareDownSetIsConnectedHandle }

procedure TShareDownSetIsConnectedHandle.SetIsConnected( _IsConnected : boolean );
begin
  IsConnected := _IsConnected;
end;

procedure TShareDownSetIsConnectedHandle.SetToFace;
var
  ShareDownSetIsConnectedFace : TShareDownSetIsConnectedFace;
begin
  ShareDownSetIsConnectedFace := TShareDownSetIsConnectedFace.Create( SharePath, OwnerPcID );
  ShareDownSetIsConnectedFace.SetIsConnected( IsConnected );
  ShareDownSetIsConnectedFace.AddChange;
end;

procedure TShareDownSetIsConnectedHandle.Update;
begin
  SetToFace;
end;

{ TShareExplorerHistoryReadHandle }

constructor TShareExplorerHistoryReadHandle.Create(_OwnerID, _FilePath : string);
begin
  OwnerID := _OwnerID;
  FilePath := _FilePath;
end;


procedure TShareExplorerHistoryReadHandle.RemoveExistItem;
var
  ExistIndex : Integer;
begin
  ExistIndex := ShareExplorerHistoryInfoReadUtil.ReadExistIndex( OwnerID, FilePath );
  if ExistIndex < 0 then
    Exit;

     // 先删除已存在的
  RemoveItem( ExistIndex );
end;

procedure TShareExplorerHistoryReadHandle.RemoveItem(RemoveIndex: Integer);
var
  ShareExplorerHistoryRemoveHandle : TShareExplorerHistoryRemoveHandle;
begin
  ShareExplorerHistoryRemoveHandle := TShareExplorerHistoryRemoveHandle.Create( RemoveIndex );
  ShareExplorerHistoryRemoveHandle.Update;
  ShareExplorerHistoryRemoveHandle.Free;
end;

procedure TShareExplorerHistoryReadHandle.RemoveMaxCount;
var
  HistoryCount, RemoveIndex : Integer;
begin
  HistoryCount := ShareExplorerHistoryInfoReadUtil.ReadHistoryCount;
  if HistoryCount < HistoryCount_Max then
    Exit;

    // 删除最后一个
  RemoveIndex := HistoryCount - 1;
  RemoveItem( RemoveIndex );
end;

procedure TShareExplorerHistoryReadHandle.AddToInfo;
var
  ShareExplorerHistoryAddInfo : TShareExplorerHistoryAddInfo;
begin
  ShareExplorerHistoryAddInfo := TShareExplorerHistoryAddInfo.Create( OwnerID, FilePath );
  ShareExplorerHistoryAddInfo.Update;
  ShareExplorerHistoryAddInfo.Free;
end;

procedure TShareExplorerHistoryReadHandle.AddToFace;
var
  OwnerName : string;
  ShareExplorerHistoryAddFace : TShareExplorerHistoryAddFace;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );

  ShareExplorerHistoryAddFace := TShareExplorerHistoryAddFace.Create( OwnerName, FilePath );
  ShareExplorerHistoryAddFace.AddChange;
end;

procedure TShareExplorerHistoryReadHandle.Update;
begin
  RemoveExistItem;
  RemoveMaxCount;
  AddToInfo;
  AddToFace;
end;

{ TShareExplorerHistoryAddHandle }

procedure TShareExplorerHistoryAddHandle.AddToXml;
var
  ShareExplorerHistoryAddXml : TShareExplorerHistoryAddXml;
begin
  ShareExplorerHistoryAddXml := TShareExplorerHistoryAddXml.Create( OwnerID, FilePath );
  ShareExplorerHistoryAddXml.AddChange;
end;

procedure TShareExplorerHistoryAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TShareExplorerHistoryRemoveHandle }

procedure TShareExplorerHistoryRemoveHandle.RemoveFromInfo;
var
  ShareExplorerHistoryRemoveInfo : TShareExplorerHistoryRemoveInfo;
begin
  ShareExplorerHistoryRemoveInfo := TShareExplorerHistoryRemoveInfo.Create( RemoveIndex );
  ShareExplorerHistoryRemoveInfo.Update;
  ShareExplorerHistoryRemoveInfo.Free;
end;

constructor TShareExplorerHistoryRemoveHandle.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareExplorerHistoryRemoveHandle.RemoveFromFace;
var
  ShareExplorerHistoryRemoveFace : TShareExplorerHistoryRemoveFace;
begin
  ShareExplorerHistoryRemoveFace := TShareExplorerHistoryRemoveFace.Create( RemoveIndex );
  ShareExplorerHistoryRemoveFace.AddChange;
end;

procedure TShareExplorerHistoryRemoveHandle.RemoveFromXml;
var
  ShareExplorerHistoryRemoveXml : TShareExplorerHistoryRemoveXml;
begin
  ShareExplorerHistoryRemoveXml := TShareExplorerHistoryRemoveXml.Create( RemoveIndex );
  ShareExplorerHistoryRemoveXml.AddChange;
end;

procedure TShareExplorerHistoryRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;




{ TShareExplorerHistoryClearHandle }

procedure TShareExplorerHistoryClearHandle.ClearFromFace;
var
  ShareExplorerHistoryClearFace : TShareExplorerHistoryClearFace;
begin
  ShareExplorerHistoryClearFace := TShareExplorerHistoryClearFace.Create;
  ShareExplorerHistoryClearFace.AddChange;
end;

procedure TShareExplorerHistoryClearHandle.ClearFromInfo;
var
  ShareExplorerHistoryClearInfo : TShareExplorerHistoryClearInfo;
begin
  ShareExplorerHistoryClearInfo := TShareExplorerHistoryClearInfo.Create;
  ShareExplorerHistoryClearInfo.Update;
  ShareExplorerHistoryClearInfo.Free;
end;

procedure TShareExplorerHistoryClearHandle.ClearFromXml;
var
  ShareExplorerHistoryClearXml : TShareExplorerHistoryClearXml;
begin
  ShareExplorerHistoryClearXml := TShareExplorerHistoryClearXml.Create;
  ShareExplorerHistoryClearXml.AddChange;
end;

procedure TShareExplorerHistoryClearHandle.Update;
begin
  ClearFromInfo;
  ClearFromFace;
  ClearFromXml;
end;


{ ShareExplorerHistoryApi }

class procedure ShareExplorerHistoryApi.AddItem(OwnerID, FilePath: string);
var
  ShareExplorerHistoryAddHandle : TShareExplorerHistoryAddHandle;
begin
  ShareExplorerHistoryAddHandle := TShareExplorerHistoryAddHandle.Create( OwnerID, FilePath );
  ShareExplorerHistoryAddHandle.Update;
  ShareExplorerHistoryAddHandle.Free;
end;

class procedure ShareExplorerHistoryApi.ClearItem;
var
  ShareExplorerHistoryClearHandle : TShareExplorerHistoryClearHandle;
begin
  ShareExplorerHistoryClearHandle := TShareExplorerHistoryClearHandle.Create;
  ShareExplorerHistoryClearHandle.Update;
  ShareExplorerHistoryClearHandle.Free;
end;

{ TShareSavePathReadHandle }

procedure TShareSavePathReadHandle.AddToFace;
var
  ShareSavePathAddFace : TShareSavePathAddFace;
begin
  ShareSavePathAddFace := TShareSavePathAddFace.Create( SavePath );
  ShareSavePathAddFace.AddChange;
end;

procedure TShareSavePathReadHandle.AddToInfo;
var
  ShareSavePathAddInfo : TShareSavePathAddInfo;
begin
  ShareSavePathAddInfo := TShareSavePathAddInfo.Create( SavePath );
  ShareSavePathAddInfo.Update;
  ShareSavePathAddInfo.Free;
end;

constructor TShareSavePathReadHandle.Create(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareSavePathReadHandle.RemoveExistItem;
var
  ExistIndex : Integer;
begin
  ExistIndex := ShareSavePathInfoReadUtil.ReadIndex( SavePath );
  if ExistIndex < 0 then
    Exit;

     // 先删除已存在的
  RemoveItem( ExistIndex );
end;

procedure TShareSavePathReadHandle.RemoveItem(RemoveIndex: Integer);
var
  ShareSavePathRemoveHandle : TShareSavePathRemoveHandle;
begin
  ShareSavePathRemoveHandle := TShareSavePathRemoveHandle.Create( RemoveIndex );
  ShareSavePathRemoveHandle.Update;
  ShareSavePathRemoveHandle.Free;
end;

procedure TShareSavePathReadHandle.RemoveMaxCount;
var
  HistoryCount, RemoveIndex : Integer;
begin
  HistoryCount := ShareSavePathInfoReadUtil.ReadPathCount;
  if HistoryCount <  SaveHistoryCount_Max then
    Exit;

    // 删除最后一个
  RemoveIndex := HistoryCount - 1;
  RemoveItem( RemoveIndex );
end;

procedure TShareSavePathReadHandle.Update;
begin
  RemoveExistItem;
  RemoveMaxCount;
  AddToInfo;
  AddToFace;
end;

{ TShareSavePathAddHandle }

procedure TShareSavePathAddHandle.AddToXml;
var
  ShareSavePathAddXml : TShareSavePathAddXml;
begin
  ShareSavePathAddXml := TShareSavePathAddXml.Create( SavePath );
  ShareSavePathAddXml.AddChange;
end;

procedure TShareSavePathAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TShareSavePathRemoveHandle }

constructor TShareSavePathRemoveHandle.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareSavePathRemoveHandle.RemoveFromFace;
var
  ShareSavePathRemoveFace : TShareSavePathRemoveFace;
begin
  ShareSavePathRemoveFace := TShareSavePathRemoveFace.Create( RemoveIndex );
  ShareSavePathRemoveFace.AddChange;
end;

procedure TShareSavePathRemoveHandle.RemoveFromInfo;
var
  ShareSavePathRemoveInfo : TShareSavePathRemoveInfo;
begin
  ShareSavePathRemoveInfo := TShareSavePathRemoveInfo.Create( RemoveIndex );
  ShareSavePathRemoveInfo.Update;
  ShareSavePathRemoveInfo.Free;
end;

procedure TShareSavePathRemoveHandle.RemoveFromXml;
var
  ShareSavePathRemoveXml : TShareSavePathRemoveXml;
begin
  ShareSavePathRemoveXml := TShareSavePathRemoveXml.Create( RemoveIndex );
  ShareSavePathRemoveXml.AddChange;
end;

procedure TShareSavePathRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TShareSavePathClearHandle }

procedure TShareSavePathClearHandle.ClearFromFace;
var
  ShareSavePathClearFace : TShareSavePathClearFace;
begin
  ShareSavePathClearFace := TShareSavePathClearFace.Create;
  ShareSavePathClearFace.AddChange;
end;

procedure TShareSavePathClearHandle.ClearFromInfo;
var
  ShareSavePathClearInfo : TShareSavePathClearInfo;
begin
  ShareSavePathClearInfo := TShareSavePathClearInfo.Create;
  ShareSavePathClearInfo.Update;
  ShareSavePathClearInfo.Free;
end;

procedure TShareSavePathClearHandle.ClearFromXml;
var
  ShareSavePathClearXml : TShareSavePathClearXml;
begin
  ShareSavePathClearXml := TShareSavePathClearXml.Create;
  ShareSavePathClearXml.AddChange;
end;

procedure TShareSavePathClearHandle.Update;
begin
  ClearFromInfo;
  ClearFromFace;
  ClearFromXml;
end;

{ ShareSavePathHistory }

class procedure ShareSavePathHistory.AddItem(SavePath: string);
var
  ShareSavePathAddHandle : TShareSavePathAddHandle;
begin
  ShareSavePathAddHandle := TShareSavePathAddHandle.Create( SavePath );
  ShareSavePathAddHandle.Update;
  ShareSavePathAddHandle.Free;
end;

class procedure ShareSavePathHistory.ClearItem;
var
  ShareSavePathClearHandle : TShareSavePathClearHandle;
begin
  ShareSavePathClearHandle := TShareSavePathClearHandle.Create;
  ShareSavePathClearHandle.Update;
  ShareSavePathClearHandle.Free;
end;

{ TShareDownSetAnalyzeHandle }

procedure TShareDownSetAnalyzeHandle.AddToHint;
var
  OwnerName, Destination : string;
  IsFile : Boolean;
begin
    // 显示 Hint
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerPcID );
  Destination := ShareDownInfoReadUtil.ReadSavePath( SharePath, OwnerPcID );
  IsFile := ShareDownInfoReadUtil.ReadIsFile( SharePath, OwnerPcID );

  MyHintAppApi.ShowDownloadingShare( Destination, OwnerName, IsFile );
end;

procedure TShareDownSetAnalyzeHandle.Update;
begin
    // 重设统计数
  ShareDownAppApi.SetScaningCount( SharePath, OwnerPcID, 0 );

    // 设置状态为正在分析
  ShareDownAppApi.SetStatus( SharePath, OwnerPcID, RestoreNodeStatus_Analyizing );

    // 显示 Hint
  AddToHint;
end;

{ TShareDownPauseHandle }

procedure TShareDownPauseHandle.SetToFace;
var
  ShareDownPauseFace : TShareDownPauseFace;
begin
  ShareDownPauseFace := TShareDownPauseFace.Create;
  ShareDownPauseFace.AddChange;
end;

procedure TShareDownPauseHandle.Update;
begin
  UserShareDown_IsStop := True;

  SetToFace;
end;

{ TSharedownContiueHandle }

procedure TSharedownContiueHandle.Update;
var
  OnlineRestoreList : TShareDonwReadDataList;
  OnlineRestoreInfo : TShareDownReadDataInfo;
  i : Integer;
begin
  OnlineRestoreList := ShareDownInfoReadUtil.ReadNeworkStartRestore;
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    if not MyNetPcInfoReadUtil.ReadIsOnline( OnlineRestoreInfo.OwnerPcID ) then  // Pc 离线
      Continue;
    ShareDownUserApi.DownSelectNetworkItem( OnlineRestoreInfo.SharePath, OnlineRestoreInfo.OwnerPcID );
  end;
  OnlineRestoreList.Free
end;

{ TBackupSpeedLimitHandle }

procedure TRestoreSpeedLimitHandle.SetToXml;
var
  RestoreSpeedLimitXml : TRestoreSpeedLimitXml;
begin
  RestoreSpeedLimitXml := TRestoreSpeedLimitXml.Create;
  RestoreSpeedLimitXml.SetIsLimit( IsLimit );
  RestoreSpeedLimitXml.SetLimitXml( LimitValue, LimitType );
  RestoreSpeedLimitXml.AddChange;
end;

procedure TRestoreSpeedLimitHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupSpeedLimitReadHandle }


constructor TRestoreSpeedLimitReadHandle.Create(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitReadHandle.SetLimitInfo(_LimitType,
  _LimitValue: Integer);
begin
  LimitType := _LimitType;
  LimitValue := _LimitValue;
end;

procedure TRestoreSpeedLimitReadHandle.SetToFace;
var
  RestoreSpeedLimitFace : TRestoreSpeedLimitFace;
  LimitSpeed : Int64;
begin
  LimitSpeed := RestoreSpeedInfoReadUtil.getLimitSpeed;

  RestoreSpeedLimitFace := TRestoreSpeedLimitFace.Create;
  RestoreSpeedLimitFace.SetIsLimit( IsLimit );
  RestoreSpeedLimitFace.SetLimitSpeed( LimitSpeed );
  RestoreSpeedLimitFace.AddChange;
end;

procedure TRestoreSpeedLimitReadHandle.SetToInfo;
var
  RestoreSpeedLimitInfo : TRestoreSpeedLimitInfo;
begin
  RestoreSpeedLimitInfo := TRestoreSpeedLimitInfo.Create;
  RestoreSpeedLimitInfo.SetIsLimit( IsLimit );
  RestoreSpeedLimitInfo.SetLimitInfo( LimitValue, LimitType );
  RestoreSpeedLimitInfo.Update;
  RestoreSpeedLimitInfo.Free;
end;

procedure TRestoreSpeedLimitReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ RestoreSpeedInfoReadUtil }

class function RestoreSpeedInfoReadUtil.getIsLimit: Boolean;
begin
  Result := MyShareDownInfo.RestoreSpeedInfo.IsLimit;
end;

class function RestoreSpeedInfoReadUtil.getLimitSpeed: Int64;
var
  LimitType, LimitValue : Integer;
  SizeBase : Int64;
begin
  LimitType := getLimitType;
  LimitValue := getLimitValue;

  SizeBase := Size_KB;
  if LimitType = LimitType_KB then
    SizeBase := Size_KB
  else
  if LimitType = LimitType_MB then
    SizeBase := Size_MB
  else
    SizeBase := Size_KB;

  Result := LimitValue * SizeBase;
end;

class function RestoreSpeedInfoReadUtil.getLimitType: Integer;
begin
  Result := MyShareDownInfo.RestoreSpeedInfo.LimitType;
end;

class function RestoreSpeedInfoReadUtil.getLimitValue: Integer;
begin
  Result := MyShareDownInfo.RestoreSpeedInfo.LimitValue;
end;

{ RestoreSpeedApi }

class procedure ShareDownSpeedApi.SetLimit(IsLimit: Boolean; LimitType,
  LimitValue: Integer);
var
  RestoreSpeedLimitHandle : TRestoreSpeedLimitHandle;
begin
  RestoreSpeedLimitHandle := TRestoreSpeedLimitHandle.Create( IsLimit );
  RestoreSpeedLimitHandle.SetLimitInfo( LimitType, LimitValue );
  RestoreSpeedLimitHandle.Update;
  RestoreSpeedLimitHandle.Free;
end;

{ SharePreviewApi }

class procedure SharePreviewApi.PreviewExcel(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewExcelInfo : TShareDownScanNetworkPreviewExcelInfo;
begin
  ShareDownScanNetworkPreviewExcelInfo := TShareDownScanNetworkPreviewExcelInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewExcelInfo );
end;

class procedure SharePreviewApi.PreviewExe(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewExeInfo : TShareDownScanNetworkPreviewExeInfo;
begin
  ShareDownScanNetworkPreviewExeInfo := TShareDownScanNetworkPreviewExeInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewExeInfo );
end;

class procedure SharePreviewApi.PreviewMusic(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewMusicInfo : TShareDownScanNetworkPreviewMusicInfo;
begin
  ShareDownScanNetworkPreviewMusicInfo := TShareDownScanNetworkPreviewMusicInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewMusicInfo );
end;


class procedure SharePreviewApi.PreviewPicture(RestorePath, OwnerID: string;
  ImgWidth, ImgHeigh: Integer);
var
  ShareDownScanNetworkPreviewInfo : TShareDownScanNetworkPreviewPictureInfo;
begin
  ShareDownScanNetworkPreviewInfo := TShareDownScanNetworkPreviewPictureInfo.Create( RestorePath, OwnerID );
  ShareDownScanNetworkPreviewInfo.SetPreviewSize( ImgWidth, ImgHeigh );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewInfo );
end;


class procedure SharePreviewApi.PreviewText(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewInfo : TShareDownScanNetworkPreviewTextInfo;
begin
  ShareDownScanNetworkPreviewInfo := TShareDownScanNetworkPreviewTextInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewInfo );
end;

class procedure SharePreviewApi.PreviewWord(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewWordInfo : TShareDownScanNetworkPreviewWordInfo;
begin
  ShareDownScanNetworkPreviewWordInfo := TShareDownScanNetworkPreviewWordInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewWordInfo );
end;

class procedure SharePreviewApi.PreviewCompress(RestorePath, OwnerID: string);
var
  ShareDownScanNetworkPreviewZipInfo : TShareDownScanNetworkPreviewZipInfo;
begin
  ShareDownScanNetworkPreviewZipInfo := TShareDownScanNetworkPreviewZipInfo.Create( RestorePath, OwnerID );
  MySharePreviewHandler.AddShareDownJob( ShareDownScanNetworkPreviewZipInfo );
end;

class procedure SharePreviewApi.SharePcBusy;
var
  SharePreivewBusyFace : TSharePreivewBusyFace;
begin
  SharePreivewBusyFace := TSharePreivewBusyFace.Create;
  SharePreivewBusyFace.AddChange;
end;

class procedure SharePreviewApi.SharePcNotConn;
var
  SharePreivewNotConnFace : TSharePreivewNotConnFace;
begin
  SharePreivewNotConnFace := TSharePreivewNotConnFace.Create;
  SharePreivewNotConnFace.AddChange;
end;

class procedure SharePreviewApi.StartPreview;
var
  RestoreFilePreviewStartFace : TRestoreFilePreviewStartFace;
begin
  RestoreFilePreviewStartFace := TRestoreFilePreviewStartFace.Create;
  RestoreFilePreviewStartFace.AddChange;
end;

class procedure SharePreviewApi.StopPreview;
var
  RestoreFilePreviewStopFace : TRestoreFilePreviewStopFace;
begin
  RestoreFilePreviewStopFace := TRestoreFilePreviewStopFace.Create;
  RestoreFilePreviewStopFace.AddChange;
end;

{ ShareSearchAppApi }

class procedure ShareSearchAppApi.ShowExplorer(Params: TExplorerResultParams);
var
  RestoreSearchExplorerAddFace : TShareSearchExplorerAddFace;
begin
  RestoreSearchExplorerAddFace := TShareSearchExplorerAddFace.Create( Params.FilePath );
  RestoreSearchExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreSearchExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreSearchExplorerAddFace.AddChange;
end;

class procedure ShareSearchAppApi.ShowResult(Params: TSearchResultParams);
var
  ShareSearchAddFace : TShareSearchAddFace;
begin
  ShareSearchAddFace := TShareSearchAddFace.Create( Params.FilePath );
  ShareSearchAddFace.SetIsFile( Params.IsFile );
  ShareSearchAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  ShareSearchAddFace.AddChange;
end;

class procedure ShareSearchAppApi.StartSearch;
var
  ShareExplorerStartFace : TShareSearchStartFace;
begin
  ShareExplorerStartFace := TShareSearchStartFace.Create;
  ShareExplorerStartFace.AddChange;
end;

class procedure ShareSearchAppApi.StopSearch;
var
  ShareExplorerStopFace : TShareSearchStopFace;
begin
  ShareExplorerStopFace := TShareSearchStopFace.Create;
  ShareExplorerStopFace.AddChange;
end;

class procedure ShareSearchAppApi.SharePcBusy;
var
  ShareExplorerBusyFace : TShareSearchBusyFace;
begin
  ShareExplorerBusyFace := TShareSearchBusyFace.Create;
  ShareExplorerBusyFace.AddChange;
end;

class procedure ShareSearchAppApi.SharePcNotConn;
var
  ShareExplorerNotConnFace : TShareSearchNotConnFace;
begin
  ShareExplorerNotConnFace := TShareSearchNotConnFace.Create;
  ShareExplorerNotConnFace.AddChange;
end;

{ ShareSearchUserApi }

class procedure ShareSearchUserApi.AddNetworkItem(SharePath, OwnerID,
  SearchName: string);
var
  ShareDownScanNetworSearchInfo : TShareDownScanNetworSearchInfo;
begin
  ShareDownScanNetworSearchInfo := TShareDownScanNetworSearchInfo.Create( SharePath, OwnerID );
  ShareDownScanNetworSearchInfo.SetSearchName( SearchName );
  MyShareSearchHandler.AddShareDownJob( ShareDownScanNetworSearchInfo );
end;

{ TShareDownSetIsLostConnHandle }

procedure TShareDownSetIsLostConnHandle.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TShareDownSetIsLostConnHandle.SetToInfo;
var
  ShareDownSetIsLostConnInfo : TShareDownSetIsLostConnInfo;
begin
  ShareDownSetIsLostConnInfo := TShareDownSetIsLostConnInfo.Create( SharePath, OwnerPcID );
  ShareDownSetIsLostConnInfo.SetIsLostConn( IsLostConn );
  ShareDownSetIsLostConnInfo.Update;
  ShareDownSetIsLostConnInfo.Free;
end;

procedure TShareDownSetIsLostConnHandle.Update;
begin
  SetToInfo;
end;


{ TBackupLogWriteHandle }

procedure TShareDownLogWriteHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupLogCompletedReadHandle }

procedure TShareDownLogCompletedReadHandle.AddToInfo;
var
  BackupLogAddCompletedLogInfo : TShareDownAddCompletedLogInfo;
begin
  BackupLogAddCompletedLogInfo := TShareDownAddCompletedLogInfo.Create( SharePath, OwnerPcID );
  BackupLogAddCompletedLogInfo.SetFilePath( FilePath );
  BackupLogAddCompletedLogInfo.SetSendTime( BackupTime );
  BackupLogAddCompletedLogInfo.Update;
  BackupLogAddCompletedLogInfo.Free;
end;

procedure TShareDownLogCompletedReadHandle.SetBackupTime(_BackupTime: TDateTime);
begin
  BackupTime := _BackupTime;
end;

procedure TShareDownLogCompletedReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupLogCompletedAddHandle }

procedure TShareDownLogCompletedAddHandle.AddToXml;
var
  BackupLogAddCompletedXml : TShareDownLogAddCompletedXml;
begin
  BackupLogAddCompletedXml := TShareDownLogAddCompletedXml.Create( SharePath, OwnerPcID );
  BackupLogAddCompletedXml.SetFilePath( FilePath );
  BackupLogAddCompletedXml.SetSendTime( BackupTime );
  BackupLogAddCompletedXml.AddChange;
end;

procedure TShareDownLogCompletedAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupLogIncompletedReadHandle }

procedure TShareDownLogIncompletedReadHandle.AddToInfo;
var
  BackupLogAddIncompletedLogInfo : TShareDownAddIncompletedLogInfo;
begin
  BackupLogAddIncompletedLogInfo := TShareDownAddIncompletedLogInfo.Create( SharePath, OwnerPcID );
  BackupLogAddIncompletedLogInfo.SetFilePath( FilePath );
  BackupLogAddIncompletedLogInfo.Update;
  BackupLogAddIncompletedLogInfo.Free;
end;

procedure TShareDownLogIncompletedReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupLogIncompletedAddHandle }

procedure TShareDownLogIncompletedAddHandle.AddToXml;
var
  BackupLogAddIncompletedXml : TShareDownLogAddIncompletedXml;
begin
  BackupLogAddIncompletedXml := TShareDownLogAddIncompletedXml.Create( SharePath, OwnerPcID );
  BackupLogAddIncompletedXml.SetFilePath( FilePath );
  BackupLogAddIncompletedXml.AddChange;
end;

procedure TShareDownLogIncompletedAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TShareDownLogClearIncompletedHandle.ClearInfo;
var
  BackupLogClearIncompletedInfo : TShareDownClearIncompletedLogInfo;
begin
  BackupLogClearIncompletedInfo := TShareDownClearIncompletedLogInfo.Create( SharePath, OwnerPcID );
  BackupLogClearIncompletedInfo.Update;
  BackupLogClearIncompletedInfo.Free;
end;

procedure TShareDownLogClearIncompletedHandle.ClearXml;
var
  BackupLogClearIncompletedXml : TShareDownLogClearIncompletedXml;
begin
  BackupLogClearIncompletedXml := TShareDownLogClearIncompletedXml.Create( SharePath, OwnerPcID );
  BackupLogClearIncompletedXml.AddChange;
end;

procedure TShareDownLogClearIncompletedHandle.Update;
begin
  ClearInfo;
  ClearXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TShareDownLogClearCompletedHandle.ClearInfo;
var
  BackupLogClearCompletedInfo : TShareDownClearCompletedLogInfo;
begin
  BackupLogClearCompletedInfo := TShareDownClearCompletedLogInfo.Create( SharePath, OwnerPcID );
  BackupLogClearCompletedInfo.Update;
  BackupLogClearCompletedInfo.Free;
end;

procedure TShareDownLogClearCompletedHandle.ClearXml;
var
  BackupLogClearCompletedXml : TShareDownLogClearCompletedXml;
begin
  BackupLogClearCompletedXml := TShareDownLogClearCompletedXml.Create( SharePath, OwnerPcID );
  BackupLogClearCompletedXml.AddChange;
end;

procedure TShareDownLogClearCompletedHandle.Update;
begin
  ClearInfo;
  ClearXml;
end;

{ TBackupLogClearCompletedHandle }


class procedure ShareDownLogApi.AddCompleted(Prams: TShareDownAddLogParams);
var
  ShareDownLogCompletedAddHandle : TShareDownLogCompletedAddHandle;
begin
  ShareDownLogCompletedAddHandle := TShareDownLogCompletedAddHandle.Create( Prams.SharePath, Prams.OwnerPcID );
  ShareDownLogCompletedAddHandle.SetFilePath( Prams.FilePath );
  ShareDownLogCompletedAddHandle.SetBackupTime( Prams.SendTime );
  ShareDownLogCompletedAddHandle.Update;
  ShareDownLogCompletedAddHandle.Free;
end;

class procedure ShareDownLogApi.AddIncompleted(Prams: TShareDownAddLogParams);
var
  ShareDownLogIncompletedAddHandle : TShareDownLogIncompletedAddHandle;
begin
  ShareDownLogIncompletedAddHandle := TShareDownLogIncompletedAddHandle.Create( Prams.SharePath, Prams.OwnerPcID );
  ShareDownLogIncompletedAddHandle.SetFilePath( Prams.FilePath );
  ShareDownLogIncompletedAddHandle.Update;
  ShareDownLogIncompletedAddHandle.Free;
end;



class procedure ShareDownLogApi.ClearCompleted( SharePath, OwnerPcID : string );
var
  BackupLogClearCompletedHandle : TShareDownLogClearCompletedHandle;
begin
  BackupLogClearCompletedHandle := TShareDownLogClearCompletedHandle.Create( SharePath, OwnerPcID );
  BackupLogClearCompletedHandle.Update;
  BackupLogClearCompletedHandle.Free;
end;

class procedure ShareDownLogApi.ClearIncompleted( SharePath, OwnerPcID : string );
var
  BackupLogClearIncompletedHandle : TShareDownLogClearIncompletedHandle;
begin
  BackupLogClearIncompletedHandle := TShareDownLogClearIncompletedHandle.Create( SharePath, OwnerPcID );
  BackupLogClearIncompletedHandle.Update;
  BackupLogClearIncompletedHandle.Free;
end;

class procedure ShareDownLogApi.RefreshLogFace(DesItemID, SourcePath: string);
var
  CompletedLogList : TShareDownCompletedLogList;
  InCompletedLogList : TShareDownIncompletedLogList;
  i: Integer;
begin
    // 清空旧的
  frmShareDownLog.ClearItems;

    // 添加已完成的
  CompletedLogList := ShareDownInfoReadUtil.ReadCompletedLogList( DesItemID, SourcePath );
  for i := 0 to CompletedLogList.Count - 1 do
    frmShareDownLog.AddCompleted( CompletedLogList[i].FilePath, CompletedLogList[i].DownTime );
  CompletedLogList.Free;

    // 添加未完成的
  IncompletedLogList := ShareDownInfoReadUtil.ReadIncompletedLogList( DesItemID, SourcePath );
  for i := 0 to IncompletedLogList.Count - 1 do
    frmShareDownLog.AddIncompleted( IncompletedLogList[i].FilePath );
  IncompletedLogList.Free;
end;


end.
