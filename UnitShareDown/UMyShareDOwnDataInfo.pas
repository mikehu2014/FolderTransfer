unit UMyShareDOwnDataInfo;

interface

uses Generics.Collections, UDataSetInfo, UMyUtil, classes;

type

{$Region ' 数据结构 ' }

    // 续传信息
  TShareDownContinusInfo = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
  end;
  TShareDownContinusList = class( TObjectList< TShareDownContinusInfo > )end;

    // 日志信息
  TShareDownLogInfo = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;
  TShareDownCompletedLogInfo = class( TShareDownLogInfo )
  public
    DownTime : TDateTime;
  public
    procedure SetDownTime( _DownTime : TDateTime );
  end;
  TShareDownCompletedLogList = class( TObjectList<TShareDownCompletedLogInfo> )end;
  TShareDownIncompletedLogInfo = class( TShareDownLogInfo )end;
  TShareDownIncompletedLogList = class( TObjectList<TShareDownIncompletedLogInfo> )end;

    // 数据结构
  TShareDownInfo = class
  public
    SharePath, OwnerPcID : string;
    IsFile, IsCompleted, IsDownloading, IsLostConn : Boolean;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath, DownCompletedType : string;
  public
    ShareDownContinusList : TShareDownContinusList;
  public
    ShareDownCompletedLogList : TShareDownCompletedLogList;
    ShareDownIncompletedLogList : TShareDownIncompletedLogList;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsDownloading( _IsDownloading : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure SetDownCompletedType( _DownCompletedType : string );
    destructor Destroy; override;
  end;
  TShareDownList = class( TObjectList<TShareDownInfo> );

    // 恢复本地文件
  TShareDownLocalInfo = class( TShareDownInfo )
  end;

    // 恢复网络文件
  TShareDownNetworkInfo = class( TShareDownInfo )
  public
    IsDesBusy : Boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : Boolean );
  end;

    // 备份速度信息
  TRestoreSpeedInfo = class
  public
    IsLimit : Boolean;
    LimitValue : Integer;
    LimitType : Integer;
  public
    constructor Create;
  end;


    // 浏览历史
  TShareExplorerHistoryInfo = class
  public
    OwnerID : string;
    FilePath : string;
  public
    constructor Create( _OwnerID, _FilePath : string );
  end;
  TShareExplorerHistoryList = class( TObjectList<TShareExplorerHistoryInfo> )end;

    // 数据集
  TMyShareDownInfo = class( TMyDataInfo )
  public
    ShareDownList : TShareDownList;
    RestoreSpeedInfo : TRestoreSpeedInfo;
  public
    ShareExplorerHistoryList : TShareExplorerHistoryList;
    ShareSavePathList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 数据访问 ' }

    // 访问 数据 List 接口
  TShareDownListAccessInfo = class
  protected
    ShareDownList : TShareDownList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TShareDownAccessInfo = class( TShareDownListAccessInfo )
  public
    SharePath, OwnerPcID : string;
  protected
    ShareDownIndex : Integer;
    ShareDownInfo : TShareDownInfo;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
  protected
    function FindShareDownInfo: Boolean;
  end;

    // 访问 数据 List 接口
  TShareDownContinusListAccessInfo = class( TShareDownAccessInfo )
  protected
    ShareDownContinusList : TShareDownContinusList;
  protected
    function FindShareDownContinusList : Boolean;
  end;

    // 访问 数据 List 接口
  TShareDownCompletedLogListAccessInfo = class( TShareDownAccessInfo )
  protected
    ShareDownCompletedLogList : TShareDownCompletedLogList;
  protected
    function FindShareDownCompletedLogList : Boolean;
  end;

    // 访问 数据 List 接口
  TShareDownIncompletedLogListAccessInfo = class( TShareDownAccessInfo )
  protected
    ShareDownIncompletedLogList : TShareDownIncompletedLogList;
  protected
    function FindShareDownIncompletedLogList : Boolean;
  end;


    // 访问 数据接口
  TShareDownContinusAccessInfo = class( TShareDownContinusListAccessInfo )
  public
    FilePath : string;
  protected
    ShareDownContinusIndex : Integer;
    ShareDownContinusInfo : TShareDownContinusInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindShareDownContinusInfo: Boolean;
  end;

    // 访问 数据 List 接口
  TShareExplorerHistoryListAccessInfo = class
  protected
    ShareExplorerHistoryList : TShareExplorerHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据 List 接口
  TShareSavePathListAccessInfo = class
  protected
    ShareSavePathList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 备份速度 数据接口
  TRestoreSpeedAccessInfo = class
  public
    RestoreSpeedInfo : TRestoreSpeedInfo;
  public
    constructor Create;
  end;

{$EndRegion}

{$Region ' 数据修改 ' }

    // 修改父类
  TShareDownWriteInfo = class( TShareDownAccessInfo )
  end;

  {$Region ' 增删修改 ' }

    // 添加
  TShareDownAddInfo = class( TShareDownWriteInfo )
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
    procedure SetDownCompletedType( _DownCompletedType : string );
    procedure Update;
  protected
    procedure CreateItemInfo;virtual;abstract;
  end;

    // 添加 本地恢复
  TShareDownAddLocalInfo = class( TShareDownAddInfo )
  protected
    procedure CreateItemInfo;override;
  end;

    // 添加 网络恢复
  TShareDownAddNetworkInfo = class( TShareDownAddInfo )
  protected
    procedure CreateItemInfo;override;
  end;

    // 删除
  TShareDownRemoveInfo = class( TShareDownWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 状态信息 ' }

    // 修改
  TShareDownSetIsDownloadingInfo = class( TShareDownWriteInfo )
  public
    IsDownloading : boolean;
  public
    procedure SetIsDownloading( _IsDownloading : boolean );
    procedure Update;
  end;

      // 修改
  TShareDownSetIsCompletedInfo = class( TShareDownWriteInfo )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  end;

    // 修改
  TShareDownSetIsDesBusyInfo = class( TShareDownWriteInfo )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  end;

    // 修改
  TShareDownSetIsLostConnInfo = class( TShareDownWriteInfo )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  end;

    // 修改 下载完成后操作
  TShareDownSetDownCompletedTypeInfo = class( TShareDownWriteInfo )
  public
    DownCompletedType : string;
  public
    procedure SetDownCompletedType( _DownCompletedType : string );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 空间信息 ' }

    // 修改
  TShareDownSetSpaceInfoInfo = class( TShareDownWriteInfo )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure Update;
  end;

    // 修改
  TShareDownSetAddCompletedSpaceInfo = class( TShareDownWriteInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;

      // 修改
  TShareDownSetCompletedSizeInfo = class( TShareDownWriteInfo )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

      // 修改父类
  TShareDownContinusWriteInfo = class( TShareDownContinusAccessInfo )
  end;

    // 添加
  TShareDownContinusAddInfo = class( TShareDownContinusWriteInfo )
  public
    FileSize, Postion : int64;
  public
    FileTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize, _Postion : int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure Update;
  end;

    // 删除
  TShareDownContinusRemoveInfo = class( TShareDownContinusWriteInfo )
  public
    procedure Update;
  end;



  {$EndRegion}

  {$Region ' 日志信息 ' }

    // 添加 成功备份的log
  TShareDownAddCompletedLogInfo = class( TShareDownCompletedLogListAccessInfo )
  public
    FilePath : string;
    SendTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSendTime( _SendTime : TDateTime );
    procedure Update;
  end;

    // 清空
  TShareDownClearCompletedLogInfo = class( TShareDownCompletedLogListAccessInfo )
  public
    procedure Update;
  end;


    // 添加 备份失败的log
  TShareDownAddIncompletedLogInfo = class( TShareDownIncompletedLogListAccessInfo )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure Update;
  end;

    // 清空未完成的
  TShareDownClearIncompletedLogInfo = class( TShareDownIncompletedLogListAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 速度限制
  TRestoreSpeedLimitInfo = class( TRestoreSpeedAccessInfo )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitValue, _LimitType : Integer );
    procedure Update;
  end;

  {$EndRegion}


  {$Region ' 浏览历史信息 ' }

      // 添加
  TShareExplorerHistoryAddInfo = class( TShareExplorerHistoryListAccessInfo )
  public
    OwnerID, FilePath : string;
  public
    constructor Create( _OwnerID, _FilePath : string );
    procedure Update;
  end;

    // 删除
  TShareExplorerHistoryRemoveInfo = class( TShareExplorerHistoryListAccessInfo )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  end;

    // 清空
  TShareExplorerHistoryClearInfo = class( TShareExplorerHistoryListAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 保存路径历史 ' }

  TShareSavePathAddInfo = class( TShareSavePathListAccessInfo )
  public
    SavePath : string;
  public
    constructor Create( _SavePath : string );
    procedure Update;
  end;

  TShareSavePathRemoveInfo = class( TShareSavePathListAccessInfo )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  end;

  TShareSavePathClearInfo = class( TShareSavePathListAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取父类
  TRestoreDownReadInfo = class( TShareDownAccessInfo )
  end;

    // 读取 恢复保存路径
  TRestoreDownReadSavePath = class( TRestoreDownReadInfo )
  public
    function get : string;
  end;

    // 读取恢复下载 是否生效
  TRestoreDownReadIsEnableInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否已完成
  TRestoreDownReadIsCompletedInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否已完成
  TRestoreDownReadIsRestoringInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否文件
  TRestoreDownReadIsFileInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否断开连接
  TRestoreDownReadIsLostConnInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否文件
  TRestoreDownReadCompletedType = class( TRestoreDownReadInfo )
  public
    function get : string;
  end;

    // 读取 续传列表
  TShareDownReadContinusList = class( TShareDownContinusListAccessInfo )
  public
    function get : TShareDownContinusList;
  end;

    // 读取 已完成 Log 列表
  TShareDownReadCompletedLogList = class( TShareDownCompletedLogListAccessInfo )
  public
    function get : TShareDownCompletedLogList;
  end;

    // 读取 未完成 Log 列表
  TShareDownReadIncompletedLogList = class( TShareDownIncompletedLogListAccessInfo )
  public
    function get : TShareDownIncompletedLogList;
  end;

    // 读取的数据列表
  TShareDownReadDataInfo = class
  public
    SharePath, OwnerPcID : string;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
  end;
  TShareDonwReadDataList = class( TObjectList<TShareDownReadDataInfo> )end;

    // pc 上线 读取 Pc 的恢复Job
  TRestoreDownReadOnlineRestore = class( TShareDownListAccessInfo )
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    function get : TShareDonwReadDataList;
  end;

    // 程序运行，读取本地开始恢复
  TRestoreDownReadLocalStartRestore = class( TShareDownListAccessInfo )
  public
    function get : TShareDonwReadDataList;
  end;

    // 继续下载，读取网络开始恢复
  TRestoreDownReadNetworkStartRestore = class( TShareDownListAccessInfo )
  public
    function get : TShareDonwReadDataList;
  end;

    // 读取 繁忙列表
  TShareDownReadDesBusyList = class( TShareDownListAccessInfo )
  public
    function get : TShareDonwReadDataList;
  end;

    // 读取 断开列表
  TShareDownReadLostConnList = class( TShareDownListAccessInfo )
  public
    function get : TShareDonwReadDataList;
  end;

    // 读取 未完成列表
  TShareDownReadIncompletedList = class( TShareDownListAccessInfo )
  public
    function get : TShareDonwReadDataList;
  end;


    // 读取 恢复下载扫描信息
  TRestoreDownScanInfo = class
  public
    IsFile : Boolean;
    IsDeleted : Boolean;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
  end;

    // 读取 恢复下载 扫描信息
  TRestoreDownReadScanInfo = class( TShareDownAccessInfo )
  public
    function get : TRestoreDownScanInfo;
  end;

      // 读取 辅助类
  ShareDownInfoReadUtil = class
  public
    class function ReadSavePath( RestorePath, OwnerPcID : string ): string;
    class function ReadIsExist( RestorePath, OwnerPcID : string ): Boolean;
    class function ReadIsCompleted( RestorePath, OwnerPcID : string ): Boolean;
    class function ReadIsDownloading( RestorePath, OwnerPcID : string ): Boolean;
    class function ReadIsLostConn( RestorePath, OwnerPcID : string ): Boolean;
    class function ReadIsFile( RestorePath, OwnerPcID : string ): Boolean;
    class function ReadCompletedType( RestorePath, OwnerPcID : string ): string;
  public
    class function ReadLocalStartRestore : TShareDonwReadDataList;
    class function ReadNeworkStartRestore : TShareDonwReadDataList;
    class function ReadOnlineRestore( OnlinePcID : string ):TShareDonwReadDataList;
    class function ReadScanInfo( RestorePath, OwnerPcID : string ): TRestoreDownScanInfo;
  public
    class function ReadDesBusyList : TShareDonwReadDataList;
    class function ReadLostConnList : TShareDonwReadDataList;
    class function ReadIncompletedList : TShareDonwReadDataList;
    class function ReadContinuesList( RestorePath, OwnerPcID : string ): TShareDownContinusList;
  public
    class function ReadCompletedLogList( RestorePath, OwnerPcID : string ): TShareDownCompletedLogList;
    class function ReadIncompletedLogList( RestorePath, OwnerPcID : string ): TShareDownIncompletedLogList;
  end;

{$EndRegion}

{$Region ' 浏览历史 数据读取 ' }

 TShareExplorerHistoryReadExistIndex = class( TShareExplorerHistoryListAccessInfo )
  public
    OwnerID, FilePath : string;
  public
    procedure SetExplorerInfo( _OwnerID, _FilePath : string );
    function get : Integer;
  end;

  TShareExplorerHistoryReadCount = class( TShareExplorerHistoryListAccessInfo )
  public
    function get : Integer;
  end;

  TShareExplorerHistoryReadList = class( TShareExplorerHistoryListAccessInfo )
  public
    HistoryIndex : Integer;
  public
    procedure SetHistoryIndex( _HistoryIndex : Integer );
    function get : TShareExplorerHistoryInfo;
  end;

  ShareExplorerHistoryInfoReadUtil = class
  public
    class function ReadExistIndex( OwnerID, FilePath : string ): Integer;
    class function ReadHistoryInfo( HistoryIndex : Integer ): TShareExplorerHistoryInfo;
    class function ReadHistoryCount : Integer;
  end;

{$EndRegion}

{$Region ' 保存路径 数据读取 ' }

  TShareSavePathReadIndexInfo = class( TShareSavePathListAccessInfo )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
    function get : Integer;
  end;

  TShareSavePathReadCountInfo = class( TShareSavePathListAccessInfo )
  public
    function get : Integer;
  end;

  ShareSavePathInfoReadUtil = class
  public
    class function ReadIndex( SavePath : string ): Integer;
    class function ReadPathCount : Integer;
  end;

{$EndRegion}

var
  MyShareDownInfo : TMyShareDownInfo;

implementation

{ TRestoreDownInfo }

constructor TShareDownInfo.Create( _SharePath, _OwnerPcID : string );
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
  ShareDownContinusList := TShareDownContinusList.Create;
  ShareDownCompletedLogList := TShareDownCompletedLogList.Create;
  ShareDownIncompletedLogList := TShareDownIncompletedLogList.Create;
end;

procedure TShareDownInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

destructor TShareDownInfo.Destroy;
begin
  ShareDownCompletedLogList.Free;
  ShareDownIncompletedLogList.Free;
  ShareDownContinusList.Free;
  inherited;
end;

procedure TShareDownInfo.SetDownCompletedType(_DownCompletedType: string);
begin
  DownCompletedType := _DownCompletedType;
end;

procedure TShareDownInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareDownInfo.SetIsDownloading(_IsDownloading: Boolean);
begin
  IsDownloading := _IsDownloading;
end;

procedure TShareDownInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TMyRestoreDownInfo }

constructor TMyShareDownInfo.Create;
begin
  inherited Create;
  ShareDownList := TShareDownList.Create;
  RestoreSpeedInfo := TRestoreSpeedInfo.Create;
  ShareExplorerHistoryList := TShareExplorerHistoryList.Create;
  ShareSavePathList := TStringList.Create;
end;

destructor TMyShareDownInfo.Destroy;
begin
  ShareSavePathList.Free;
  ShareExplorerHistoryList.Free;
  RestoreSpeedInfo.Free;
  ShareDownList.Free;
  inherited;
end;

{ TRestoreDownListAccessInfo }

constructor TShareDownListAccessInfo.Create;
begin
  MyShareDownInfo.EnterData;
  ShareDownList := MyShareDownInfo.ShareDownList;
end;

destructor TShareDownListAccessInfo.Destroy;
begin
  MyShareDownInfo.LeaveData;
  inherited;
end;

{ TRestoreDownAccessInfo }

constructor TShareDownAccessInfo.Create( _SharePath, _OwnerPcID : string );
begin
  inherited Create;
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
end;

function TShareDownAccessInfo.FindShareDownInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to ShareDownList.Count - 1 do
    if ( ShareDownList[i].SharePath = SharePath ) and
       ( ShareDownList[i].OwnerPcID = OwnerPcID )
    then
    begin
      Result := True;
      ShareDownIndex := i;
      ShareDownInfo := ShareDownList[i];
      break;
    end;
end;

{ TRestoreDownAddInfo }

procedure TShareDownAddInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownAddInfo.Update;
begin
  if FindShareDownInfo then
    Exit;

  CreateItemInfo;
  ShareDownInfo.SetIsFile( IsFile );
  ShareDownInfo.SetIsCompleted( IsCompleted );
  ShareDownInfo.SetIsDownloading( False );
  ShareDownInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  ShareDownInfo.SetSavePath( SavePath );
  ShareDownInfo.SetDownCompletedType( DownCompletedType );
  ShareDownInfo.IsLostConn := False;
  ShareDownList.Add( ShareDownInfo );
end;

procedure TShareDownAddInfo.SetDownCompletedType(_DownCompletedType: string);
begin
  DownCompletedType := _DownCompletedType;
end;

procedure TShareDownAddInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownAddInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareDownAddInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveInfo }

procedure TShareDownRemoveInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;

  ShareDownList.Delete( ShareDownIndex );
end;

{ TRestoreDownAddLocalInfo }

procedure TShareDownAddLocalInfo.CreateItemInfo;
begin
  ShareDownInfo := TShareDownLocalInfo.Create( SharePath, OwnerPcID );
end;

{ TRestoreDownAddNetworkInfo }

procedure TShareDownAddNetworkInfo.CreateItemInfo;
var
  ShareDownNetworkInfo : TShareDownNetworkInfo;
begin
  ShareDownNetworkInfo := TShareDownNetworkInfo.Create( SharePath, OwnerPcID );
  ShareDownNetworkInfo.SetIsDesBusy( False );
  ShareDownInfo := ShareDownNetworkInfo;
end;

{ TRestoreDownReadSavePath }

function TRestoreDownReadSavePath.get: string;
begin
  Result := '';
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.SavePath;
end;

{ TRestoreDownSetSpaceInfoInfo }

procedure TShareDownSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetSpaceInfoInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.FileCount := FileCount;
  ShareDownInfo.FileSize := FileSize;
  ShareDownInfo.CompletedSize := CompletedSize;
end;

{ TRestoreDownSetAddCompletedSpaceInfo }

procedure TShareDownSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TShareDownSetAddCompletedSpaceInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.CompletedSize := ShareDownInfo.CompletedSize + AddCompletedSpace;
end;

{ TRestoreDownReadIsEnableInfo }

function TRestoreDownReadIsEnableInfo.get: Boolean;
begin
  Result := FindShareDownInfo;
end;

{ TRestoreDownSetCompletedSizeInfo }

procedure TShareDownSetCompletedSizeInfo.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetCompletedSizeInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.CompletedSize := CompletedSize;
end;



{ TOnlineRestoreInfo }

constructor TShareDownReadDataInfo.Create(_SharePath, _OwnerPcID: string);
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
end;

{ TRestoreDownReadOnlineRestore }

function TRestoreDownReadOnlineRestore.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownInfo;
  SelectPcID : string;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i] is TShareDownNetworkInfo then
    begin
      ShareDownInfo := ShareDownList[i];
      if ( ShareDownInfo.OwnerPcID = OnlinePcID ) and ( not ShareDownInfo.IsCompleted ) then
      begin
        OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
        Result.Add( OnlineShareDownInfo );
      end;
    end;
end;

procedure TRestoreDownReadOnlineRestore.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

{ RestoreDownInfoReadUtil }

class function ShareDownInfoReadUtil.ReadIsDownloading(RestorePath, OwnerPcID: string): Boolean;
var
  RestoreDownReadIsRestoringInfo : TRestoreDownReadIsRestoringInfo;
begin
  RestoreDownReadIsRestoringInfo := TRestoreDownReadIsRestoringInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadIsRestoringInfo.get;
  RestoreDownReadIsRestoringInfo.Free;
end;

class function ShareDownInfoReadUtil.ReadCompletedLogList(RestorePath,
  OwnerPcID: string): TShareDownCompletedLogList;
var
  ShareDownReadCompletedLogList : TShareDownReadCompletedLogList;
begin
  ShareDownReadCompletedLogList := TShareDownReadCompletedLogList.Create( RestorePath, OwnerPcID );
  Result := ShareDownReadCompletedLogList.get;
  ShareDownReadCompletedLogList.Free;
end;

class function ShareDownInfoReadUtil.ReadCompletedType(RestorePath,
  OwnerPcID: string): string;
var
  RestoreDownReadCompletedType : TRestoreDownReadCompletedType;
begin
  RestoreDownReadCompletedType := TRestoreDownReadCompletedType.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadCompletedType.get;
  RestoreDownReadCompletedType.Free;
end;

class function ShareDownInfoReadUtil.ReadContinuesList(RestorePath,
  OwnerPcID: string): TShareDownContinusList;
var
  ShareDownReadContinusList : TShareDownReadContinusList;
begin
  ShareDownReadContinusList := TShareDownReadContinusList.Create( RestorePath, OwnerPcID );
  Result := ShareDownReadContinusList.get;
  ShareDownReadContinusList.Free;
end;

class function ShareDownInfoReadUtil.ReadDesBusyList: TShareDonwReadDataList;
var
  ShareDownReadDesBusyList : TShareDownReadDesBusyList;
begin
  ShareDownReadDesBusyList := TShareDownReadDesBusyList.Create;
  Result := ShareDownReadDesBusyList.get;
  ShareDownReadDesBusyList.Free;
end;

class function ShareDownInfoReadUtil.ReadIncompletedList: TShareDonwReadDataList;
var
  ShareDownReadIncompletedList : TShareDownReadIncompletedList;
begin
  ShareDownReadIncompletedList := TShareDownReadIncompletedList.Create;
  Result := ShareDownReadIncompletedList.get;
  ShareDownReadIncompletedList.Free;
end;

class function ShareDownInfoReadUtil.ReadIncompletedLogList(RestorePath,
  OwnerPcID: string): TShareDownIncompletedLogList;
var
  ShareDownReadIncompletedLogList : TShareDownReadIncompletedLogList;
begin
  ShareDownReadIncompletedLogList := TShareDownReadIncompletedLogList.Create( RestorePath, OwnerPcID );
  Result := ShareDownReadIncompletedLogList.get;
  ShareDownReadIncompletedLogList.Free;
end;

class function ShareDownInfoReadUtil.ReadIsCompleted(RestorePath, OwnerPcID: string): Boolean;
var
  RestoreDownReadIsCompletedInfo : TRestoreDownReadIsCompletedInfo;
begin
  RestoreDownReadIsCompletedInfo := TRestoreDownReadIsCompletedInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadIsCompletedInfo.get;
  RestoreDownReadIsCompletedInfo.Free;
end;

class function ShareDownInfoReadUtil.ReadIsExist(RestorePath, OwnerPcID: string): Boolean;
var
  RestoreDownReadIsEnableInfo : TRestoreDownReadIsEnableInfo;
begin
  RestoreDownReadIsEnableInfo := TRestoreDownReadIsEnableInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadIsEnableInfo.get;
  RestoreDownReadIsEnableInfo.Free;
end;

class function ShareDownInfoReadUtil.ReadIsFile(RestorePath,
  OwnerPcID: string): Boolean;
var
  RestoreDownReadIsFileInfo : TRestoreDownReadIsFileInfo;
begin
  RestoreDownReadIsFileInfo := TRestoreDownReadIsFileInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadIsFileInfo.get;
  RestoreDownReadIsFileInfo.Free;
end;

class function ShareDownInfoReadUtil.ReadIsLostConn(RestorePath,
  OwnerPcID: string): Boolean;
var
  RestoreDownReadIsLostConnInfo : TRestoreDownReadIsLostConnInfo;
begin
  RestoreDownReadIsLostConnInfo := TRestoreDownReadIsLostConnInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadIsLostConnInfo.get;
  RestoreDownReadIsLostConnInfo.Free;
end;


class function ShareDownInfoReadUtil.ReadLocalStartRestore: TShareDonwReadDataList;
var
  RestoreDownReadLocalStartRestore : TRestoreDownReadLocalStartRestore;
begin
  RestoreDownReadLocalStartRestore := TRestoreDownReadLocalStartRestore.Create;
  Result := RestoreDownReadLocalStartRestore.get;
  RestoreDownReadLocalStartRestore.Free;
end;

class function ShareDownInfoReadUtil.ReadLostConnList: TShareDonwReadDataList;
var
  ShareDownReadLostConnList : TShareDownReadLostConnList;
begin
  ShareDownReadLostConnList := TShareDownReadLostConnList.Create;
  Result := ShareDownReadLostConnList.get;
  ShareDownReadLostConnList.Free;
end;

class function ShareDownInfoReadUtil.ReadNeworkStartRestore: TShareDonwReadDataList;
var
  RestoreDownReadNetworkStartRestore : TRestoreDownReadNetworkStartRestore;
begin
  RestoreDownReadNetworkStartRestore := TRestoreDownReadNetworkStartRestore.Create;
  Result := RestoreDownReadNetworkStartRestore.get;
  RestoreDownReadNetworkStartRestore.Free;
end;

class function ShareDownInfoReadUtil.ReadOnlineRestore(
  OnlinePcID: string): TShareDonwReadDataList;
var
  RestoreDownReadOnlineRestore : TRestoreDownReadOnlineRestore;
begin
  RestoreDownReadOnlineRestore := TRestoreDownReadOnlineRestore.Create;
  RestoreDownReadOnlineRestore.SetOnlinePcID( OnlinePcID );
  Result := RestoreDownReadOnlineRestore.get;
  RestoreDownReadOnlineRestore.Free;
end;

class function ShareDownInfoReadUtil.ReadSavePath(RestorePath,
  OwnerPcID: string): string;
var
  RestoreDownReadSavePath : TRestoreDownReadSavePath;
begin
  RestoreDownReadSavePath := TRestoreDownReadSavePath.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadSavePath.get;
  RestoreDownReadSavePath.Free;
end;

class function ShareDownInfoReadUtil.ReadScanInfo(RestorePath, OwnerPcID: string): TRestoreDownScanInfo;
var
  RestoreDownReadScanInfo : TRestoreDownReadScanInfo;
begin
  RestoreDownReadScanInfo := TRestoreDownReadScanInfo.Create( RestorePath, OwnerPcID );
  Result := RestoreDownReadScanInfo.get;
  RestoreDownReadScanInfo.Free;
end;

{ TRestoreDownScanInfo }

procedure TRestoreDownScanInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreDownScanInfo.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TRestoreDownScanInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

{ TRestoreDownReadScanInfo }

function TRestoreDownReadScanInfo.get: TRestoreDownScanInfo;
begin
  Result := TRestoreDownScanInfo.Create;
  if not FindShareDownInfo then
    Exit;
  Result.SetIsFile( ShareDownInfo.IsFile );
end;

{ TRestoreDownSetIsCompletedInfo }

procedure TShareDownSetIsCompletedInfo.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownSetIsCompletedInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.IsCompleted := IsCompleted;
end;



{ TRestoreDownReadIsCompletedInfo }

function TRestoreDownReadIsCompletedInfo.get: Boolean;
begin
  Result := False;
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.CompletedSize >= ShareDownInfo.FileSize;
end;

{ TRestoreDownReadLocalStartRestore }

function TRestoreDownReadLocalStartRestore.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownInfo;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i] is TShareDownLocalInfo then
    begin
      ShareDownInfo := ShareDownList[i];
      if not ShareDownInfo.IsCompleted then
      begin
        OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
        Result.Add( OnlineShareDownInfo );
      end;
    end;
end;

{ TRestoreDownSetIsRestoringInfo }

procedure TShareDownSetIsDownloadingInfo.SetIsDownloading( _IsDownloading : boolean );
begin
  IsDownloading := _IsDownloading;
end;

procedure TShareDownSetIsDownloadingInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.IsDownloading := IsDownloading;
end;



{ TRestoreDownReadIsRestoringInfo }

function TRestoreDownReadIsRestoringInfo.get: Boolean;
begin
  Result := False;
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.IsDownloading;
end;

{ TShareDownContinusInfo }

constructor TShareDownContinusInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownContinusInfo.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownContinusInfo.SetSpaceInfo(_FileSize, _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

{ TShareDownContinusListAccessInfo }

function TShareDownContinusListAccessInfo.FindShareDownContinusList : Boolean;
begin
  Result := FindShareDownInfo;
  if Result then
    ShareDownContinusList := ShareDownInfo.ShareDownContinusList
  else
    ShareDownContinusList := nil;
end;

{ TShareDownContinusAccessInfo }

procedure TShareDownContinusAccessInfo.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TShareDownContinusAccessInfo.FindShareDownContinusInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindShareDownContinusList then
    Exit;
  for i := 0 to ShareDownContinusList.Count - 1 do
    if ( ShareDownContinusList[i].FilePath = FilePath ) then
    begin
      Result := True;
      ShareDownContinusIndex := i;
      ShareDownContinusInfo := ShareDownContinusList[i];
      break;
    end;
end;

{ TShareDownContinusAddInfo }

procedure TShareDownContinusAddInfo.SetSpaceInfo( _FileSize, _Postion : int64 );
begin
  FileSize := _FileSize;
  Postion := _Postion;
end;

procedure TShareDownContinusAddInfo.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TShareDownContinusAddInfo.Update;
begin
  if not FindShareDownContinusInfo then
  begin
    if ShareDownContinusList = nil then
      Exit;

    ShareDownContinusInfo := TShareDownContinusInfo.Create( FilePath );
    ShareDownContinusInfo.SetSpaceInfo( FileSize, Postion );
    ShareDownContinusInfo.SetFileTime( FileTime );
    ShareDownContinusList.Add( ShareDownContinusInfo );
  end;
  ShareDownContinusInfo.Position := Postion;
end;

{ TShareDownContinusRemoveInfo }

procedure TShareDownContinusRemoveInfo.Update;
begin
  if not FindShareDownContinusInfo then
    Exit;

  ShareDownContinusList.Delete( ShareDownContinusIndex );
end;




{ TShareDownReadContinusList }

function TShareDownReadContinusList.get: TShareDownContinusList;
var
  i : Integer;
  OldContinuesInfo, NewContinuesInfo : TShareDownContinusInfo;
begin
  Result := TShareDownContinusList.Create;
  if not FindShareDownContinusList then
    Exit;

  for i := 0 to ShareDownContinusList.Count - 1 do
    begin
    OldContinuesInfo := ShareDownContinusList[i];
    NewContinuesInfo := TShareDownContinusInfo.Create( OldContinuesInfo.FilePath );
    NewContinuesInfo.SetSpaceInfo( OldContinuesInfo.FileSize, OldContinuesInfo.Position );
    NewContinuesInfo.SetFileTime( OldContinuesInfo.FileTime );
    Result.Add( NewContinuesInfo );
  end;
end;

{ TShareDownNetworkInfo }

procedure TShareDownNetworkInfo.SetIsDesBusy(_IsDesBusy: Boolean);
begin
  IsDesBusy := _IsDesBusy;
end;

{ TShareDownSetIsDesBusyInfo }

procedure TShareDownSetIsDesBusyInfo.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TShareDownSetIsDesBusyInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  if ShareDownInfo is TShareDownNetworkInfo then
    ( ShareDownInfo as TShareDownNetworkInfo ).IsDesBusy := IsDesBusy;
end;



{ TShareDownReadDesBusyList }

function TShareDownReadDesBusyList.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownNetworkInfo;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i] is TShareDownNetworkInfo then
    begin
      ShareDownInfo := ShareDownList[i] as TShareDownNetworkInfo;
      if ShareDownInfo.IsDesBusy then
      begin
        OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
        Result.Add( OnlineShareDownInfo );
      end;
    end;
end;

{ TShareExplorerHistory }

constructor TShareExplorerHistoryInfo.Create(_OwnerID, _FilePath: string);
begin
  OwnerID := _OwnerID;
  FilePath := _FilePath;
end;

{ TShareExplorerHistoryListAccessInfo }

constructor TShareExplorerHistoryListAccessInfo.Create;
begin
  MyShareDownInfo.EnterData;
  ShareExplorerHistoryList := MyShareDownInfo.ShareExplorerHistoryList;
end;

destructor TShareExplorerHistoryListAccessInfo.Destroy;
begin
  MyShareDownInfo.LeaveData;
  inherited;
end;

{ TShareExplorerHistoryAddInfo }

constructor TShareExplorerHistoryAddInfo.Create(_OwnerID, _FilePath: string);
begin
  inherited Create;
  OwnerID := _OwnerID;
  FilePath := _FilePath;
end;

procedure TShareExplorerHistoryAddInfo.Update;
var
  ShareExplorerHistoryInfo : TShareExplorerHistoryInfo;
begin
  ShareExplorerHistoryInfo := TShareExplorerHistoryInfo.Create( OwnerID, FilePath );
  ShareExplorerHistoryList.Insert( 0, ShareExplorerHistoryInfo );
end;

{ TShareExplorerHistoryRemoveInfo }

constructor TShareExplorerHistoryRemoveInfo.Create(_RemoveIndex: Integer);
begin
  inherited Create;
  RemoveIndex := _RemoveIndex;
end;

procedure TShareExplorerHistoryRemoveInfo.Update;
begin
  if ShareExplorerHistoryList.Count <= RemoveIndex then
    Exit;

  ShareExplorerHistoryList.Delete( RemoveIndex );
end;




{ TShareExplorerHistoryClearInfo }

procedure TShareExplorerHistoryClearInfo.Update;
begin
  ShareExplorerHistoryList.Clear;
end;

{ TShareExplorerHistoryReadExistIndex }

function TShareExplorerHistoryReadExistIndex.get: Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to ShareExplorerHistoryList.Count - 1 do
    if ( ShareExplorerHistoryList[i].OwnerID = OwnerID ) and
       ( ShareExplorerHistoryList[i].FilePath = FilePath )
    then
    begin
      Result := i;
      Break;
    end;
end;

procedure TShareExplorerHistoryReadExistIndex.SetExplorerInfo(_OwnerID,
  _FilePath: string);
begin
  OwnerID := _OwnerID;
  FilePath := _FilePath;
end;

{ TShareExplorerHistoryReadCount }

function TShareExplorerHistoryReadCount.get: Integer;
begin
  Result := ShareExplorerHistoryList.Count;
end;

{ TShareExplorerHistoryReadList }

function TShareExplorerHistoryReadList.get: TShareExplorerHistoryInfo;
var
  OwnerID, FilePath : string;
begin
  if ShareExplorerHistoryList.Count > HistoryIndex then
  begin
    OwnerID := ShareExplorerHistoryList[ HistoryIndex ].OwnerID;
    FilePath := ShareExplorerHistoryList[ HistoryIndex ].FilePath;
  end;

  Result := TShareExplorerHistoryInfo.Create( OwnerID, FilePath );
end;

procedure TShareExplorerHistoryReadList.SetHistoryIndex(_HistoryIndex: Integer);
begin
  HistoryIndex := _HistoryIndex;
end;

{ ShareExplorerHistoryInfoReadUtil }

class function ShareExplorerHistoryInfoReadUtil.ReadExistIndex(
   OwnerID, FilePath : string ): Integer;
var
  ShareExplorerHistoryReadExistIndex : TShareExplorerHistoryReadExistIndex;
begin
  ShareExplorerHistoryReadExistIndex := TShareExplorerHistoryReadExistIndex.Create;
  ShareExplorerHistoryReadExistIndex.SetExplorerInfo( OwnerID, FilePath );
  Result := ShareExplorerHistoryReadExistIndex.get;
  ShareExplorerHistoryReadExistIndex.Free;
end;

class function ShareExplorerHistoryInfoReadUtil.ReadHistoryCount: Integer;
var
  ShareExplorerHistoryReadCount : TShareExplorerHistoryReadCount;
begin
  ShareExplorerHistoryReadCount := TShareExplorerHistoryReadCount.Create;
  Result := ShareExplorerHistoryReadCount.get;
  ShareExplorerHistoryReadCount.Free;
end;

class function ShareExplorerHistoryInfoReadUtil.ReadHistoryInfo(
  HistoryIndex: Integer): TShareExplorerHistoryInfo;
var
  ShareExplorerHistoryReadList : TShareExplorerHistoryReadList;
begin
  ShareExplorerHistoryReadList := TShareExplorerHistoryReadList.Create;
  ShareExplorerHistoryReadList.SetHistoryIndex( HistoryIndex );
  Result := ShareExplorerHistoryReadList.get;
  ShareExplorerHistoryReadList.Free;
end;

{ TShareSavePathListAccessInfo }

constructor TShareSavePathListAccessInfo.Create;
begin
  MyShareDownInfo.EnterData;
  ShareSavePathList := MyShareDownInfo.ShareSavePathList;
end;

destructor TShareSavePathListAccessInfo.Destroy;
begin
  MyShareDownInfo.LeaveData;
  inherited;
end;

{ TShareSavePathAddInfo }

constructor TShareSavePathAddInfo.Create(_SavePath: string);
begin
  inherited Create;
  SavePath := _SavePath;
end;

procedure TShareSavePathAddInfo.Update;
begin
  ShareSavePathList.Insert( 0, SavePath );
end;

{ TShareSavePathRemoveInfo }

constructor TShareSavePathRemoveInfo.Create(_RemoveIndex: Integer);
begin
  inherited Create;
  RemoveIndex := _RemoveIndex;
end;

procedure TShareSavePathRemoveInfo.Update;
begin
  if ShareSavePathList.Count <= RemoveIndex then
    Exit;

  ShareSavePathList.Delete( RemoveIndex );
end;

{ TShareSavePathClearInfo }

procedure TShareSavePathClearInfo.Update;
begin
  ShareSavePathList.Clear;
end;

{ ShareSavePathInfoReadUtil }

class function ShareSavePathInfoReadUtil.ReadIndex(SavePath: string): Integer;
var
  ShareSavePathReadIndexInfo : TShareSavePathReadIndexInfo;
begin
  ShareSavePathReadIndexInfo := TShareSavePathReadIndexInfo.Create;
  ShareSavePathReadIndexInfo.SetSavePath( SavePath );
  Result := ShareSavePathReadIndexInfo.get;
  ShareSavePathReadIndexInfo.Free;
end;

class function ShareSavePathInfoReadUtil.ReadPathCount: Integer;
var
  ShareSavePathReadCountInfo : TShareSavePathReadCountInfo;
begin
  ShareSavePathReadCountInfo := TShareSavePathReadCountInfo.Create;
  Result := ShareSavePathReadCountInfo.get;
  ShareSavePathReadCountInfo.Free;
end;

{ TShareSavePathReadIndexInfo }

function TShareSavePathReadIndexInfo.get: Integer;
begin
  Result := ShareSavePathList.IndexOf( SavePath );
end;

procedure TShareSavePathReadIndexInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TShareSavePathReadCountInfo }

function TShareSavePathReadCountInfo.get: Integer;
begin
  Result := ShareSavePathList.Count;
end;

{ TRestoreDownReadNetworkStartRestore }

function TRestoreDownReadNetworkStartRestore.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownInfo;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i] is TShareDownNetworkInfo then
    begin
      ShareDownInfo := ShareDownList[i];
      if not ShareDownInfo.IsCompleted then
      begin
        OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
        Result.Add( OnlineShareDownInfo );
      end;
    end;
end;

{ TRestoreDownReadIsFileInfo }

function TRestoreDownReadIsFileInfo.get: Boolean;
begin
  Result := False;
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.IsFile;
end;

{ TBackupSpeedInfo }

constructor TRestoreSpeedInfo.Create;
begin
  IsLimit := False;
end;


{ TRestoreSpeedAccessInfo }

constructor TRestoreSpeedAccessInfo.Create;
begin
  RestoreSpeedInfo := MyShareDownInfo.RestoreSpeedInfo;
end;

{ TRestoreSpeedLimitInfo }

procedure TRestoreSpeedLimitInfo.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitInfo.SetLimitInfo(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TRestoreSpeedLimitInfo.Update;
begin
  RestoreSpeedInfo.IsLimit := IsLimit;
  RestoreSpeedInfo.LimitValue := LimitValue;
  RestoreSpeedInfo.LimitType := LimitType;
end;


{ TRestoreDownReadCompletedType }

function TRestoreDownReadCompletedType.get: string;
begin
  Result := '';
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.DownCompletedType;
end;

{ TShareDownSetDownCompletedTypeInfo }

procedure TShareDownSetDownCompletedTypeInfo.SetDownCompletedType(
  _DownCompletedType: string);
begin
  DownCompletedType := _DownCompletedType;
end;

procedure TShareDownSetDownCompletedTypeInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  ShareDownInfo.DownCompletedType := DownCompletedType;
end;

{ TShareDownSetIsLostConnInfo }

procedure TShareDownSetIsLostConnInfo.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TShareDownSetIsLostConnInfo.Update;
begin
  if not FindShareDownInfo then
    Exit;
  if ShareDownInfo is TShareDownNetworkInfo then
    ( ShareDownInfo as TShareDownNetworkInfo ).IsLostConn := IsLostConn;
end;

{ TRestoreDownReadIsLostConnInfo }

function TRestoreDownReadIsLostConnInfo.get: Boolean;
begin
  Result := False;
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.IsLostConn;
end;

{ TShareDownReadLostConnList }

function TShareDownReadLostConnList.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownNetworkInfo;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i] is TShareDownNetworkInfo then
    begin
      ShareDownInfo := ShareDownList[i] as TShareDownNetworkInfo;
      if ShareDownInfo.IsLostConn then
      begin
        OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
        Result.Add( OnlineShareDownInfo );
      end;
    end;
end;

{ TShareDownLogInfo }

constructor TShareDownLogInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TShareDownCompletedLogInfo }

procedure TShareDownCompletedLogInfo.SetDownTime(_DownTime: TDateTime);
begin
  DownTime := _DownTime;
end;

{ TShareDownCompletedLogListAccessInfo }

function TShareDownCompletedLogListAccessInfo.FindShareDownCompletedLogList: Boolean;
begin
  Result := FindShareDownInfo;
  if Result then
    ShareDownCompletedLogList := ShareDownInfo.ShareDownCompletedLogList;
end;

{ TShareDownIncompletedLogListAccessInfo }

function TShareDownIncompletedLogListAccessInfo.FindShareDownIncompletedLogList: Boolean;
begin
  Result := FindShareDownInfo;
  if Result then
    ShareDownIncompletedLogList := ShareDownInfo.ShareDownIncompletedLogList;
end;

{ TSendAddCompletedLogInfo }

procedure TShareDownAddCompletedLogInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownAddCompletedLogInfo.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TShareDownAddCompletedLogInfo.Update;
var
  SendCompletedLogInfo : TShareDownCompletedLogInfo;
begin
    // 不存在
  if not FindShareDownCompletedLogList then
    Exit;

    // 删除超出的部分
  if ShareDownCompletedLogList.Count >= 20 then
    ShareDownCompletedLogList.Delete( ShareDownCompletedLogList.Count - 1 );

    // 添加
  SendCompletedLogInfo := TShareDownCompletedLogInfo.Create( FilePath );
  SendCompletedLogInfo.SetDownTime( SendTime );
  ShareDownCompletedLogList.Insert( 0, SendCompletedLogInfo );
end;

{ TSendAddIncompletedLogInfo }

procedure TShareDownAddIncompletedLogInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownAddIncompletedLogInfo.Update;
var
  SendIncompletedLogInfo : TShareDownIncompletedLogInfo;
begin
    // 不存在
  if not FindShareDownIncompletedLogList then
    Exit;

    // 添加
  SendIncompletedLogInfo := TShareDownIncompletedLogInfo.Create( FilePath );
  ShareDownIncompletedLogList.Add( SendIncompletedLogInfo );
end;

{ TSendClearCompletedLogInfo }

procedure TShareDownClearCompletedLogInfo.Update;
begin
  if not FindShareDownCompletedLogList then
    Exit;

  ShareDownCompletedLogList.Clear;
end;

{ TSendClearIncompletedLogInfo }

procedure TShareDownClearIncompletedLogInfo.Update;
begin
  if not FindShareDownIncompletedLogList then
    Exit;

  ShareDownIncompletedLogList.Clear;
end;


{ TShareDownReadCompletedLogList }

function TShareDownReadCompletedLogList.get: TShareDownCompletedLogList;
var
  i: Integer;
  LogInfo : TShareDownCompletedLogInfo;
begin
  Result := TShareDownCompletedLogList.Create;
  if not FindShareDownCompletedLogList then
    Exit;
  for i := 0 to ShareDownCompletedLogList.Count - 1 do
  begin
    LogInfo := TShareDownCompletedLogInfo.Create( ShareDownCompletedLogList[i].FilePath );
    LogInfo.SetDownTime( ShareDownCompletedLogList[i].DownTime );
    Result.Add( LogInfo );
  end;
end;

{ TShareDownReadIncompletedLogList }

function TShareDownReadIncompletedLogList.get: TShareDownIncompletedLogList;
var
  i: Integer;
  LogInfo : TShareDownIncompletedLogInfo;
begin
  Result := TShareDownIncompletedLogList.Create;
  if not FindShareDownIncompletedLogList then
    Exit;
  for i := 0 to ShareDownIncompletedLogList.Count - 1 do
  begin
    LogInfo := TShareDownIncompletedLogInfo.Create( ShareDownIncompletedLogList[i].FilePath );
    Result.Add( LogInfo );
  end;
end;

{ TShareDownReadIncompletedList }

function TShareDownReadIncompletedList.get: TShareDonwReadDataList;
var
  i: Integer;
  OnlineShareDownInfo : TShareDownReadDataInfo;
  ShareDownInfo : TShareDownNetworkInfo;
begin
  Result := TShareDonwReadDataList.Create;

  for i := 0 to ShareDownList.Count - 1 do
  begin
    if not ( ShareDownList[i] is TShareDownNetworkInfo ) then
      Continue;

        // 特殊情况,跳过
    ShareDownInfo := ShareDownList[i] as TShareDownNetworkInfo;
    if ShareDownInfo.IsDesBusy or ShareDownInfo.IsLostConn or
       ShareDownInfo.IsDownloading or ShareDownInfo.IsCompleted
    then
      Continue;

      // 添加
    OnlineShareDownInfo := TShareDownReadDataInfo.Create( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
    Result.Add( OnlineShareDownInfo );
  end;
end;

end.
