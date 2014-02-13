unit UMySendApiInfo;

interface

uses SysUtils, UFileBaseInfo, classes, sockets;

type


{$Region ' 接收路径 增删 ' }

    // 父类
  TSendRootItemWriteHandle = class
  public
    SendRootItemID : string;
  public
    constructor Create( _SendRootItemID : string );
  end;

    // 读取 本地 Des
  TSendRootItemReadLocalHandle = class( TSendRootItemWriteHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;virtual;
  end;

    // 添加 本地 Des
  TSendRootItemAddLocalHandle = class( TSendRootItemReadLocalHandle )
  public
    procedure Update;override;
  protected
    procedure AddToFace;override;
    procedure AddToXml;
  end;

    // 读取 网络 Des
  TSendRootItemReadNetworkHandle = class( TSendRootItemWriteHandle )
  private
    IsOnline : Boolean;
    AvailableSpace : Int64;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络 Des
  TSendRootItemAddNetworkHandle = class( TSendRootItemReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 修改  可用空间
  TSendRootItemSetAvailableSpaceHandle = class( TSendRootItemWriteHandle )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 删除
  TSendRootItemRemoveHandle = class( TSendRootItemWriteHandle )
  public
    procedure Update;
  protected
    procedure RemoveFromInfo;
    procedure RemoveFromFace;virtual;
    procedure RemoveFromXml;
  end;

    // 删除 本地
  TSendRootItemRemoveLocalHandle = class( TSendRootItemRemoveHandle )
  protected
    procedure RemoveFromFace;override;
  end;

    // 删除 网络
  TSendRootItemRemoveNetworkHandle = class( TSendRootItemRemoveHandle )
  protected
    procedure RemoveFromFace;override;
  end;

{$EndRegion}

{$Region ' 接收路径 状态 ' }

      // 修改 是否存在路径
  TSendRootItemSetIsExistHandle = class( TSendRootItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否可写
  TSendRootItemSetIsWriteHandle = class( TSendRootItemWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否缺少空间
  TSendRootItemSetIsLackSpaceHandle = class( TSendRootItemWriteHandle )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否可连接
  TSendRootItemSetIsConnectedHandle = class( TSendRootItemWriteHandle )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;


{$EndRegion}

{$Region ' 目标路径 其他操作 ' }

    // 备份本地目标
  TBackupDesSelectLocalItemHandle = class( TSendRootItemWriteHandle )
  public
    procedure Update;
  end;

    // 备份网络目标
  TBackupDesSelectNetworkItemHandle = class( TSendRootItemWriteHandle )
  public
    procedure Update;
  end;

    // Pc 上/下线
  TNetworkDesPcSetIsOnline = class
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

{$EndRegion}


{$Region ' 发送路径 增删 ' }

    // 添加
  TSendItemWriteHandle = class( TSendRootItemWriteHandle )
  public
    SourcePath : string;
  public
    procedure SetSourceInfo( _SourcePath : string );
  end;

    // 读取
  TSendItemReadHandle = class( TSendItemWriteHandle )
  public  // 路径信息
    IsFile : Boolean;
    IsCompleted, IsZip : Boolean;
    ZipPath : string;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public  // 定时发送
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
    LastSendTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure SetZipInfo( _IsZip : Boolean; _ZipPath : string );
    procedure SetScheduleInfo( _ScheduleType, _ScheduleValue1, _ScheduleValue2 : Integer );
    procedure SetLastSendTime( _LastSendTime : TDateTime );
  end;

    // 读取 本地
  TSendItemReadLocalHandle = class( TSendItemReadHandle )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 本地发送
  TSendItemAddLocalHandle = class( TSendItemReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

      // 读取 网络本地
  TSendItemReadNetworkHandle = class( TSendItemReadHandle )
  public
    IsAddToReceive : Boolean; // 是否需要添加接收方
    IsRemoveToReceive : Boolean;  // 是否需要删除接收方
  public
    IsReceiveCancel : Boolean; // 是否接收方已经取消
  public
    procedure SetReceiveInfo( _IsAddToReceive, _IsRemoveToReceive : Boolean );
    procedure SetIsReceiveCancel( _IsReceiveCancel : Boolean );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络发送
  TSendItemAddNetworkHandle = class( TSendItemReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TSendItemRemoveHandle = class( TSendItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // 删除 本地备份
  TSendItemRemoveLocalHandle = class( TSendItemRemoveHandle )
  end;

    // 删除 网络备份
  TSendItemRemoveNetworkHandle = class( TSendItemRemoveHandle )
  end;

    // 删除本地的发送
  TNetworkSendItemStopHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  private
    procedure SetRemoveToReceive;
    procedure RemoveFace;
    procedure RemoveEvent;
  private
    procedure RemoveSendItemNow;
  end;

{$EndRegion}

{$Region ' 发送路径 状态 ' }

    // 修改 是否存在
  TSendItemSetIsExistHandle = class( TSendItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 状态
  TSendItemSetStatusHandle = class( TSendItemWriteHandle )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TSendItemSetSpeedHandle = class( TSendItemWriteHandle )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
    procedure Update;
  private
     procedure SetToFace;
  end;

      // 修改
  TSendItemSetCompressHandle = class( TSendItemWriteHandle )
  public
    CompressCount : Integer;
  public
    procedure SetCompressCount( _CompressCount : Integer );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 修改
  TSendItemSetAnalyizeHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  private
    procedure AddToHint;
  end;

    // 修改
  TSendItemSetAnalyizeCountHandle = class( TSendItemWriteHandle )
  public
    AnalyizeCount : integer;
  public
    procedure SetAnalyizeCount( _AnalyizeCount : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TSendItemSetIsCompletedHandle = class( TSendItemWriteHandle )
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
  TSendItemSetIsLostConnHandle = class( TSendItemWriteHandle )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // 修改
  TSendItemSetIsBackupingHandle = class( TSendItemWriteHandle )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

    // 修改
  TSendItemSetIsAddToReceiveHandle = class( TSendItemWriteHandle )
  public
    IsAddToReceive : boolean;
  public
    procedure SetIsAddToReceive( _IsAddToReceive : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToXml;
  end;


    // 修改
  TSendItemSetIsRemoveToReceiveHandle = class( TSendItemWriteHandle )
  public
    IsRemoveToReceive : boolean;
  public
    procedure SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToXml;
  end;

    // 修改
  TSendItemSetIsReceiveCancelHandle = class( TSendItemWriteHandle )
  public
    IsReceiveCancel : boolean;
  public
    procedure SetIsReceiveCancel( _IsReceiveCancel : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TSendItemSetIsDesBusyHandle = class( TSendItemWriteHandle )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;
  
{$EndRegion}

{$Region ' 发送路径 空间信息 ' }

    // 修改 统计空间信息
  TSendItemSetSpaceInfoHandle = class( TSendItemWriteHandle )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TSendItemAddCompletedSpaceHandle = class( TSendItemWriteHandle )
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

{$EndRegion}

{$Region ' 源路径 自动备份 ' }

    // 修改
  TSendItemSetLastSendTimeHandle = class( TSendItemWriteHandle )
  public
    LastSendTime : TDateTime;
  public
    procedure SetLastSendTime( _LastSendTime : TDateTime );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

  TSendItemSetScheduleHandle = class( TSendItemWriteHandle )
  public
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
  public
    procedure SetScheduleType( _ScheduleType : Integer );
    procedure SetScheduleValue( _ScheduleValue1, _ScheduleValue2 : Integer );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 源路径 过滤信息 ' }

    // 读取 包含过滤
  TSendItemIncludeFilterReadHandle = class( TSendItemWriteHandle )
  public
    IncludeFilterList : TFileFilterList;
  public
    procedure SetIncludeFilterList( _IncludeFilterList : TFileFilterList );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 包含过滤
  TSendItemIncludeFilterSetHandle = class( TSendItemIncludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // 读取 排除过滤
  TSendItemExcludeFilterReadHandle = class( TSendItemWriteHandle )
  public
    ExcludeFilterList : TFileFilterList;
  public
    procedure SetExcludeFilterList( _ExcludeFilterList : TFileFilterList );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 排除过滤
  TSendItemExcludeFilterSetHandle = class( TSendItemExcludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 源路径 续传信息 ' }

    // 修改
  TSendContinusWriteHandle = class( TSendItemWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 读取
  TSendContinusReadHandle = class( TSendContinusWriteHandle )
  public
    FileSize, Position : int64;
    FileTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize, _Posiiton : int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TSendContinusAddHandle = class( TSendContinusReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TSendContinusRemoveHandle = class( TSendContinusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;


{$EndRegion}

{$Region ' 源路径 错误信息 ' }

      // 添加 错误
  TSendItemErrorAddHandle = class( TSendItemWriteHandle )
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
  TSendItemErrorClearHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearToFace;
  end;

{$EndRegion}

{$Region ' 源路径 日志信息 ' }

    // 修改
  TBackupLogWriteHandle = class( TSendItemWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 读取
  TBackupLogCompletedReadHandle = class( TBackupLogWriteHandle )
  public
    BackupTime : TDateTime;
  public
    procedure SetBackupTime( _BackupTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TBackupLogCompletedAddHandle = class( TBackupLogCompletedReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取
  TBackupLogIncompletedReadHandle = class( TBackupLogWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TBackupLogIncompletedAddHandle = class( TBackupLogIncompletedReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 清空已完成
  TBackupLogClearCompletedHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearInfo;
    procedure ClearFace;
    procedure ClearXml;
  end;

    // 清空未完成
  TBackupLogClearIncompletedHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearInfo;
    procedure ClearFace;
    procedure ClearXml;
  end;

{$EndRegion}


{$Region ' 发送路径 历史信息 ' }

    // 读取
  TSendFileHistoryReadHandle = class
  public
    SendPathList : TStringList;
  public
    constructor Create( _SendPathList : TStringList );
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
  TSendFileHistoryAddHandle = class( TSendFileHistoryReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TSendFileHistoryRemoveHandle = class
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
  TSendFileHistoryClearHandle = class
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromFace;
    procedure ClearFromXml;
  end;

{$EndRegion}

{$Region ' 发送目标 历史信息 ' }

    // 读取
  TSendDesHistoryReadHandle = class
  public
    SendDesList : TStringList;
  public
    constructor Create( _SendDesList : TStringList );
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
  TSendDesHistoryAddHandle = class( TSendDesHistoryReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TSendDesHistoryRemoveHandle = class
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
  TSendDesHistoryClearHandle = class
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromFace;
    procedure ClearFromXml;
  end;

{$EndRegion}

{$Region ' 源路径 其他操作 ' }

    // 父类
  TSendSelectedItemHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  protected
    function getIsAddToScan : Boolean;virtual;
    procedure AddToScan;virtual;abstract;
  end;

    // 备份 本地路径
  TSendSelectedLocalItemHandle = class( TSendSelectedItemHandle )
  protected
    procedure AddToScan;override;
  end;

    // 备份 网络路径
  TSendSelectedNetworkItemHandle = class( TSendSelectedItemHandle )
  protected
    function getIsAddToScan : Boolean;override;
    procedure AddToScan;override;
  end;

    // 添加 发送
  TWaitingSendSelectItemHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  end;


    // 备份停止
  TBackupItemStopHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  end;


    // 备份完成
  TBackupItemCompletedHandle = class( TSendItemWriteHandle )
  public
    procedure Update;
  protected
    procedure AddToHint;virtual;abstract;
  end;

    // 本地 备份完成
  TBackupItemLocalCompletedHandle = class( TBackupItemCompletedHandle )
  protected
    procedure AddToHint;override;
  end;

    // 网络 备份完成
  TBackupItemNetworkCompletedHandle = class( TBackupItemCompletedHandle )
  protected
    procedure AddToHint;override;
  end;

    // 本地续传
  TBackupItemLocalOnlineBackup = class
  public
    procedure Update;
  end;

    // 网络续传
  TBackupItemNetworkOnlineBackup = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  end;

    // 启动备份
  TSendFileStartHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 停止备份
  TSendFileStopHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 继续备份
  TSendFileContinuseHandle = class
  public
    procedure Update;
  end;

    // 暂停备份
  TSendFilePauseHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}


{$Region ' 备份速度信息 ' }

    // 读取 速度限制
  TBackupSpeedLimitReadHandle = class
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
  TBackupSpeedLimitHandle = class( TBackupSpeedLimitReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 信息读取 ' }

  BackupSpeedInfoReadUtil = class
  public
    class function getIsLimit : Boolean;
    class function getLimitType : Integer;
    class function getLimitValue : Integer;
    class function getLimitSpeed : Int64;
  end;

{$EndRegion}

    // 目标路径 用户接口
  SendRootItemUserApi = class
  public
    class procedure AddLocalItem( DesItemID : string );
    class procedure RemoveLocalItem( DesItemID : string );
    class procedure RemoveNetworkItem( DesItemID : string );
  public
    class procedure BackupSelectLocalItem( DesItemID : string );
    class procedure BackupSelectNetworkItem( DesItemID : string );
  end;

    // 目标路径 程序接口
  SendRootItemAppApi = class
  public
    class procedure AddNetworkItem( DesItemID : string; AvailableSpace : Int64 );
    class procedure SetNetworkPcIsOnline( DesPcID : string; IsOnline : Boolean );
  public
    class procedure SetIsExist( DesItemID : string; IsExist : Boolean );
    class procedure SetIsWrite( DesItemID : string; IsWrite : Boolean );
    class procedure SetIsConnected( DesItemID : string; IsConnected : Boolean );
    class procedure SetIsLackSpace( DesItemID : string; IsLackSpace : Boolean );
    class procedure SetAvaialbleSpace( DesItemID : string; AvailableSpace : Int64 );
  end;

    // 自动备份参数
  TBackupAutoSynParams = record
  public
    DesItemID, BackupPath : string;
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  end;

    // 加密参数
  TBackupEncryptParams = record
  public
    DesItemID, BackupPath : string;
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  end;

    // 保存删除参数
  TBackupSaveDeletedParams = record
  public
    DesItemID, BackupPath : string;
    IsSaveDeleted : Boolean;
    SaveDeletedEdition : Integer;
  end;

    // 设置空间信息参数
  TBackupSetSpaceParams = record
  public
    DesItemID, BackupPath : string;
    FileCount : Integer;
    FileSpace, CompletedSpce : Int64;
  end;

    // 添加参数
  TSendItemAddParams = record
  public
    DesItemID, BackupPath : string;
    ScheduleType, ScheduleValue1, ScheduleValue2 : Integer;
  end;

  TScheduleSetParams = record
  public
    DesItemID, BackupPath : string;
    ScheduleType, ScheduleValue1, ScheduleValue2 : Integer;
  end;

    // 备份路径 用户接口
  SendItemUserApi = class
  public              // 增删 备份路径
    class procedure AddLocalItem( DesItemID, BackupPath: string );
    class procedure AddNetworkItem( Params : TSendItemAddParams );
    class procedure RemoveLocalItem( DesItemID, BackupPath : string );
    class procedure RemoveNetworkItem( DesItemID, BackupPath : string );
    class procedure StopNetworkItem( DesItemID, BackupPath : string );
  public              // 修改 过滤器
    class procedure SetIncludeFilterList( DesItemID, BackupPath : string; IncludeFilterList : TFileFilterList );
    class procedure SetExcludeFilterList( DesItemID, BackupPath : string; ExcludeFilterList : TFileFilterList );
  public              // 备份操作
    class procedure SendSelectLocalItem( DesItemID, BackupPath : string );
    class procedure SendSelectNetworkItem( DesitemID, BackupPath : string );
    class procedure WaitingSendSelectNetworkItem( DesItemID, BackupPath : string );
  public
    class procedure SetSchedule( Params : TScheduleSetParams );
  end;

    // 备份路径 程序接口
  SendItemAppApi = class
  public              // 备份路径
    class procedure SetIsExist( DesItemID, BackupPath : string; IsExist : Boolean );
    class procedure SetIsCompleted( DesItemID, BackupPath : string; IsCompleted : Boolean );
    class procedure SetIsLostConn( DesItemID, BackupPath : string; IsLostConn : Boolean );
    class procedure SetIsAddToReceive( DesItemID, BackupPath : string; IsAddToReceive : Boolean );
    class procedure SetIsRemoveToReceive( DesItemID, BackupPath : string; IsRemoveToReceive : Boolean );
    class procedure SetIsReceiveCancel( DesItemID, BackupPath : string; IsReceiveCancel : Boolean );
    class procedure SetIsDesBusy( DesItemID, BackupPath : string; IsDesBusy : Boolean );
    class procedure SetSpaceInfo( Params : TBackupSetSpaceParams );
    class procedure SetLastBackupTime( DesItemID, BackupPath : string; LastBackupTime : TDateTime );
  public              // 备份路径 备份过程
    class procedure SetWaitingBackup( DesItemID, BackupPath : string );
    class procedure SetAnalyzeBackup( DesItemID, BackupPath : string );
    class procedure SetScaningCount( DesItemID, BackupPath : string; FileCount : Integer );
    class procedure SetStartBackup( DesItemID, BackupPath : string );
    class procedure SetSpeed( DesItemID, BackupPath : string; Speed : Int64 );
    class procedure SetCompress( DesItemID, BackupPath : string; CompressCount : Integer );
    class procedure AddBackupCompletedSpace( DesItemID, BackupPath : string; CompletedSpace : Int64 );
    class procedure SetStopBackup( DesItemID, BackupPath : string );
  public              // 备份完成
    class procedure SetLocalBackupCompleted( DesItemID, BackupPath : string );
    class procedure SetNetworkBackupCompleted( DesItemID, BackupPath : string );
  public              // 备份状态
    class procedure SetBackupItemStatus( DesItemID, BackupPath, ItemStatus : string );
    class procedure SetIsBackuping( DesItemID, BackupPath : string; IsBackuping : Boolean );
    class procedure BackupStart;
    class procedure BackupStop;
    class procedure BackupPause;
    class procedure BackupContinue;
  public              // 续传
    class procedure LocalOnlineSend;
    class procedure PcOnlineSend( OnlinePcID : string );
  end;

    // 添加 参数
  TSendContinusAddParams = record
  public
    SendRootItemID, SourcePath : string;
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  end;

    // 续传Api
  SendContinusAppApi = class
  public
    class procedure AddItem( Params : TSendContinusAddParams );
    class procedure RemoveItem( DesItemID, SourcePath, FilePath : string );
  end;

    // 添加 参数
  TSendErrorAddParams = record
  public
    SendRootItemID : string;
    SourcePath : string;
    FilePath : string;
    FileSize, CompletedSize : Int64;
    ErrorStatus : string;
  end;
  
    // 错误 Api
  SendErrorAppApi = class
  public
    class procedure ReadFileError( Params : TSendErrorAddParams );
    class procedure WriteFileError( Params : TSendErrorAddParams );
    class procedure LostConnectError( Params : TSendErrorAddParams );
    class procedure SendFileError( Params : TSendErrorAddParams );
    class procedure ClearItem( DesItemID, SourcePath : string );
  private
    class procedure AddItem( Params : TSendErrorAddParams );
  end;
  
    // 添加参数
  TSendLogAddParams = record
  public
    SendRootItemID, SourcePath : string;
    FilePath : string;
    SendTime : TDateTime;
  end;

    // 备份 Log Api
  SendLogApi = class
  public
    class procedure AddCompleted( Prams : TSendLogAddParams );
    class procedure ClearCompleted( DesItemID, BackupPath : string );
  public
    class procedure AddIncompleted( Prams : TSendLogAddParams );
    class procedure ClearIncompleted( DesItemID, BackupPath : string );
  public
    class procedure RefreshLogFace( DesItemID, SourcePath : string );
  end;

      // 备份限速
  SendFileSpeedApi = class
  public
    class procedure SetLimit( IsLimit : Boolean; LimitType, LimitValue : Integer );
  end;


  SendFileHistoryApi = class
  public
    class procedure AddItem( SendPathList : TStringList );
    class procedure ClearItem;
  end;

  SendDesHistoryApi = class
  public
    class procedure AddItem( SendDesList : TStringList );
    class procedure ClearItem;
  end;

const
  HistoryCount_Max = 10;

const
  ActionType_AddSend = 'Add to Send';

const
  LimitType_KB = 0;
  LimitType_MB = 1;

var
  UserTransfer_IsStop : Boolean = False;

var
  MySendItem_SendCount : Integer = 0;

implementation

uses UMySendDataInfo, UMySendFaceInfo, UMySendXmlInfo, UMyNetPcInfo, UMyUtil, USendThread,
     UMySendEventInfo, UMyShareDownApiInfo, UAutoSendThread, UMainApi, UFormSendLog;

{ LocalBackupUserApi }

class procedure SendItemUserApi.AddLocalItem(DesItemID, BackupPath: string );
var
  SavePath : string;
  IsFile : Boolean;
  SendItemAddLocalHandle : TSendItemAddLocalHandle;
begin
  IsFile := FileExists( BackupPath );

    // 获取不存在的路径
  SavePath := MyFilePath.getPath( DesItemID ) + ExtractFileName( BackupPath );
  SavePath := MyFilePath.getNowExistPath( SavePath, IsFile );

    // 添加路径
  SendItemAddLocalHandle := TSendItemAddLocalHandle.Create( DesItemID );
  SendItemAddLocalHandle.SetSourceInfo( BackupPath );
  SendItemAddLocalHandle.SetIsFile( IsFile );
  SendItemAddLocalHandle.SetIsCompleted( False );
  SendItemAddLocalHandle.SetSpaceInfo( -1, 0, 0 );
  SendItemAddLocalHandle.SetZipInfo( False, '' );
  SendItemAddLocalHandle.SetSavePath( SavePath );
  SendItemAddLocalHandle.Update;
  SendItemAddLocalHandle.Free;
end;


class procedure SendItemUserApi.AddNetworkItem(Params : TSendItemAddParams);
var
  IsFile : Boolean;
  SendItemAddNetworkHandle : TSendItemAddNetworkHandle;
begin
  IsFile := FileExists( Params.BackupPath );

    // 添加路径
  SendItemAddNetworkHandle := TSendItemAddNetworkHandle.Create( Params.DesItemID );
  SendItemAddNetworkHandle.SetSourceInfo( Params.BackupPath );
  SendItemAddNetworkHandle.SetScheduleInfo( Params.ScheduleType, Params.ScheduleValue1, Params.ScheduleValue2 );
  SendItemAddNetworkHandle.SetLastSendTime( 0 );
  SendItemAddNetworkHandle.SetIsFile( IsFile );
  SendItemAddNetworkHandle.SetIsCompleted( False );
  SendItemAddNetworkHandle.SetSpaceInfo( -1, 0, 0 );
  SendItemAddNetworkHandle.SetZipInfo( False, '' );
  SendItemAddNetworkHandle.SetReceiveInfo( True, False );
  SendItemAddNetworkHandle.SetIsReceiveCancel( False );
  SendItemAddNetworkHandle.Update;
  SendItemAddNetworkHandle.Free;
end;

class procedure SendItemUserApi.SendSelectLocalItem(DesItemID,
  BackupPath: string);
var
  BackupSelectedItemHandle : TSendSelectedLocalItemHandle;
begin
  BackupSelectedItemHandle := TSendSelectedLocalItemHandle.Create( DesItemID );
  BackupSelectedItemHandle.SetSourceInfo( BackupPath );
  BackupSelectedItemHandle.Update;
  BackupSelectedItemHandle.Free;
end;

class procedure SendItemUserApi.SendSelectNetworkItem(DesitemID,
  BackupPath: string);
var
  BackupSelectedNetworkItemHandle : TSendSelectedNetworkItemHandle;
begin
  BackupSelectedNetworkItemHandle := TSendSelectedNetworkItemHandle.Create( DesItemID );
  BackupSelectedNetworkItemHandle.SetSourceInfo( BackupPath );
  BackupSelectedNetworkItemHandle.Update;
  BackupSelectedNetworkItemHandle.Free;
end;

class procedure SendItemUserApi.WaitingSendSelectNetworkItem(DesItemID,
  BackupPath: string);
var
  WaitingSendSelectItemHandle : TWaitingSendSelectItemHandle;
begin
  WaitingSendSelectItemHandle := TWaitingSendSelectItemHandle.Create( DesItemID );
  WaitingSendSelectItemHandle.SetSourceInfo( BackupPath );
  WaitingSendSelectItemHandle.Update;
  WaitingSendSelectItemHandle.Free;
end;

class procedure SendItemUserApi.RemoveLocalItem(DesItemID,
  BackupPath: string);
var
  BackupItemRemoveLocalHandle : TSendItemRemoveLocalHandle;
begin
  BackupItemRemoveLocalHandle := TSendItemRemoveLocalHandle.Create( DesItemID );
  BackupItemRemoveLocalHandle.SetSourceInfo( BackupPath );
  BackupItemRemoveLocalHandle.Update;
  BackupItemRemoveLocalHandle.Free;
end;

class procedure SendItemUserApi.RemoveNetworkItem(DesItemID,
  BackupPath: string);
var
  BackupItemRemoveNetworkHandle : TSendItemRemoveNetworkHandle;
begin
  BackupItemRemoveNetworkHandle := TSendItemRemoveNetworkHandle.Create( DesItemID );
  BackupItemRemoveNetworkHandle.SetSourceInfo( BackupPath );
  BackupItemRemoveNetworkHandle.Update;
  BackupItemRemoveNetworkHandle.Free;
end;

class procedure SendItemUserApi.SetExcludeFilterList(DesItemID,
  BackupPath: string; ExcludeFilterList: TFileFilterList);
var
  BackupItemExcludeFilterSetHandle : TSendItemExcludeFilterSetHandle;
begin
  BackupItemExcludeFilterSetHandle := TSendItemExcludeFilterSetHandle.Create( DesItemID );
  BackupItemExcludeFilterSetHandle.SetSourceInfo( BackupPath );
  BackupItemExcludeFilterSetHandle.SetExcludeFilterList( ExcludeFilterList );
  BackupItemExcludeFilterSetHandle.Update;
  BackupItemExcludeFilterSetHandle.Free;
end;

class procedure SendItemUserApi.SetIncludeFilterList(DesItemID,
  BackupPath: string; IncludeFilterList: TFileFilterList);
var
  BackupItemIncludeFilterSetHandle : TSendItemIncludeFilterSetHandle;
begin
  BackupItemIncludeFilterSetHandle := TSendItemIncludeFilterSetHandle.Create( DesItemID );
  BackupItemIncludeFilterSetHandle.SetSourceInfo( BackupPath );
  BackupItemIncludeFilterSetHandle.SetIncludeFilterList( IncludeFilterList );
  BackupItemIncludeFilterSetHandle.Update;
  BackupItemIncludeFilterSetHandle.Free;
end;

class procedure SendItemUserApi.SetSchedule(Params: TScheduleSetParams);
var
  SendItemSetScheduleHandle : TSendItemSetScheduleHandle;
begin
  SendItemSetScheduleHandle := TSendItemSetScheduleHandle.Create( Params.DesItemID );
  SendItemSetScheduleHandle.SetSourceInfo( Params.BackupPath );
  SendItemSetScheduleHandle.SetScheduleType( Params.ScheduleType );
  SendItemSetScheduleHandle.SetScheduleValue( Params.ScheduleValue1, Params.ScheduleValue2 );
  SendItemSetScheduleHandle.Update;
  SendItemSetScheduleHandle.Free;
end;

class procedure SendItemUserApi.StopNetworkItem(DesItemID, BackupPath: string);
var
  NetworkSendItemStopHandle : TNetworkSendItemStopHandle;
begin
  NetworkSendItemStopHandle := TNetworkSendItemStopHandle.Create( DesItemID );
  NetworkSendItemStopHandle.SetSourceInfo( BackupPath );
  NetworkSendItemStopHandle.Update;
  NetworkSendItemStopHandle.Free;
end;

{ TLocalBackupDesItemWriteHandle }

constructor TSendRootItemWriteHandle.Create(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;


{ TlocalBackupDeItemRemoveHandle }

procedure TSendRootItemRemoveHandle.RemoveFromFace;
var
  DesItemRemoveFace : TSendRootItemRemoveFace;
begin
  DesItemRemoveFace := TSendRootItemRemoveFace.Create( SendRootItemID );
  DesItemRemoveFace.AddChange;
end;

procedure TSendRootItemRemoveHandle.RemoveFromInfo;
var
  LocalDesItemRemoveInfo : TSendRootItemRemoveInfo;
begin
  LocalDesItemRemoveInfo := TSendRootItemRemoveInfo.Create( SendRootItemID );
  LocalDesItemRemoveInfo.Update;
  LocalDesItemRemoveInfo.Free;
end;

procedure TSendRootItemRemoveHandle.RemoveFromXml;
var
  LocalDesItemRemoveXml : TSendRootItemRemoveXml;
begin
  LocalDesItemRemoveXml := TSendRootItemRemoveXml.Create( SendRootItemID );
  LocalDesItemRemoveXml.AddChange;
end;

procedure TSendRootItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

procedure TSendItemWriteHandle.SetSourceInfo( _SourcePath : string );
begin
  SourcePath := _SourcePath;
end;

procedure TSendItemReadHandle.SetIsFile( _IsFile : Boolean );
begin
  IsFile := _IsFile;
end;

procedure TSendItemReadHandle.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemReadHandle.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemReadHandle.SetScheduleInfo(_ScheduleType, _ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleType := _ScheduleType;
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemReadHandle.SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemReadHandle.SetZipInfo(_IsZip: Boolean; _ZipPath: string);
begin
  IsZip := _IsZip;
  ZipPath := _ZipPath;
end;

{ TLocalBackupItemRemoveHandle }

procedure TSendItemRemoveHandle.RemoveFromFace;
var
  BackupItemRemoveFace : TSendItemRemoveFace;
begin
  BackupItemRemoveFace := TSendItemRemoveFace.Create( SendRootItemID );
  BackupItemRemoveFace.SetSourcePath( SourcePath );
  BackupItemRemoveFace.AddChange;
end;

procedure TSendItemRemoveHandle.RemoveFromInfo;
var
  LocalBackupItemRemoveInfo : TSendItemRemoveInfo;
begin
  LocalBackupItemRemoveInfo := TSendItemRemoveInfo.Create( SendRootItemID );
  LocalBackupItemRemoveInfo.SetBackupPath( SourcePath );
  LocalBackupItemRemoveInfo.Update;
  LocalBackupItemRemoveInfo.Free;
end;

procedure TSendItemRemoveHandle.RemoveFromXml;
var
  LocalBackupItemRemoveXml : TSendItemRemoveXml;
begin
  LocalBackupItemRemoveXml := TSendItemRemoveXml.Create( SendRootItemID );
  LocalBackupItemRemoveXml.SetSourcePath( SourcePath );
  LocalBackupItemRemoveXml.AddChange;
end;

procedure TSendItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;


{ LocalBackupAppApi }

class procedure SendItemAppApi.BackupContinue;
var
  SendFileContinuseHandle : TSendFileContinuseHandle;
begin
  SendFileContinuseHandle := TSendFileContinuseHandle.Create;
  SendFileContinuseHandle.Update;
  SendFileContinuseHandle.Free;
end;

class procedure SendItemAppApi.BackupPause;
var
  SendFilePauseHandle : TSendFilePauseHandle;
begin
  SendFilePauseHandle := TSendFilePauseHandle.Create;
  SendFilePauseHandle.Update;
  SendFilePauseHandle.Free;
end;

class procedure SendItemAppApi.BackupStart;
var
  BackupStartHandle : TSendFileStartHandle;
begin
  BackupStartHandle := TSendFileStartHandle.Create;
  BackupStartHandle.Update;
  BackupStartHandle.Free;
end;

class procedure SendItemAppApi.BackupStop;
var
  BackupStopHandle : TSendFileStopHandle;
begin
  BackupStopHandle := TSendFileStopHandle.Create;
  BackupStopHandle.Update;
  BackupStopHandle.Free;
end;

class procedure SendItemAppApi.LocalOnlineSend;
var
  BackupItemLocalOnlineBackup : TBackupItemLocalOnlineBackup;
begin
  BackupItemLocalOnlineBackup := TBackupItemLocalOnlineBackup.Create;
  BackupItemLocalOnlineBackup.Update;
  BackupItemLocalOnlineBackup.Free;
end;

class procedure SendItemAppApi.PcOnlineSend(OnlinePcID: string);
var
  BackupItemNetworkOnlineBackup : TBackupItemNetworkOnlineBackup;
begin
  BackupItemNetworkOnlineBackup := TBackupItemNetworkOnlineBackup.Create( OnlinePcID );
  BackupItemNetworkOnlineBackup.Update;
  BackupItemNetworkOnlineBackup.Free;
end;

class procedure SendItemAppApi.AddBackupCompletedSpace(DesItemID,
  BackupPath: string; CompletedSpace: Int64);
var
  BackupItemAddCompletedSpaceHandle : TSendItemAddCompletedSpaceHandle;
begin
  BackupItemAddCompletedSpaceHandle := TSendItemAddCompletedSpaceHandle.Create( DesItemID );
  BackupItemAddCompletedSpaceHandle.SetSourceInfo( BackupPath );
  BackupItemAddCompletedSpaceHandle.SetAddCompletedSpace( CompletedSpace );
  BackupItemAddCompletedSpaceHandle.Update;
  BackupItemAddCompletedSpaceHandle.Free;
end;

class procedure SendItemAppApi.SetAnalyzeBackup(DesItemID,
  BackupPath: string);
var
  SendItemSetAnalyizeHandle : TSendItemSetAnalyizeHandle;
begin
  SendItemSetAnalyizeHandle := TSendItemSetAnalyizeHandle.Create( DesItemID );
  SendItemSetAnalyizeHandle.SetSourceInfo( BackupPath );
  SendItemSetAnalyizeHandle.Update;
  SendItemSetAnalyizeHandle.Free;
end;

class procedure SendItemAppApi.SetBackupItemStatus(DesItemID, BackupPath,
  ItemStatus: string);
var
  BackupItemSetBackupItemStatusHandle : TSendItemSetStatusHandle;
begin
  BackupItemSetBackupItemStatusHandle := TSendItemSetStatusHandle.Create( DesItemID );
  BackupItemSetBackupItemStatusHandle.SetSourceInfo( BackupPath );
  BackupItemSetBackupItemStatusHandle.SetBackupItemStatus( ItemStatus );
  BackupItemSetBackupItemStatusHandle.Update;
  BackupItemSetBackupItemStatusHandle.Free;
end;

class procedure SendItemAppApi.SetCompress(DesItemID, BackupPath: string;
  CompressCount: Integer);
var
  SendItemSetCompressHandle : TSendItemSetCompressHandle;
begin
  SendItemSetCompressHandle := TSendItemSetCompressHandle.Create( DesItemID );
  SendItemSetCompressHandle.SetSourceInfo( BackupPath );
  SendItemSetCompressHandle.SetCompressCount( CompressCount );
  SendItemSetCompressHandle.Update;
  SendItemSetCompressHandle.Free;
end;

class procedure SendItemAppApi.SetIsAddToReceive(DesItemID, BackupPath: string;
  IsAddToReceive: Boolean);
var
  SendItemSetIsAddToReceiveHandle : TSendItemSetIsAddToReceiveHandle;
begin
  SendItemSetIsAddToReceiveHandle := TSendItemSetIsAddToReceiveHandle.Create( DesItemID );
  SendItemSetIsAddToReceiveHandle.SetSourceInfo( BackupPath );
  SendItemSetIsAddToReceiveHandle.SetIsAddToReceive( IsAddToReceive );
  SendItemSetIsAddToReceiveHandle.Update;
  SendItemSetIsAddToReceiveHandle.Free;
end;



class procedure SendItemAppApi.SetIsBackuping(DesItemID, BackupPath: string;
  IsBackuping: Boolean);
var
  BackupItemSetIsBackupingHandle : TSendItemSetIsBackupingHandle;
begin
  BackupItemSetIsBackupingHandle := TSendItemSetIsBackupingHandle.Create( DesItemID );
  BackupItemSetIsBackupingHandle.SetSourceInfo( BackupPath );
  BackupItemSetIsBackupingHandle.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingHandle.Update;
  BackupItemSetIsBackupingHandle.Free;
end;



class procedure SendItemAppApi.SetIsCompleted(DesItemID, BackupPath: string;
  IsCompleted: Boolean);
var
  BackupItemSetIsCompletedHandle : TSendItemSetIsCompletedHandle;
begin
  BackupItemSetIsCompletedHandle := TSendItemSetIsCompletedHandle.Create( DesItemID );
  BackupItemSetIsCompletedHandle.SetSourceInfo( BackupPath );
  BackupItemSetIsCompletedHandle.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedHandle.Update;
  BackupItemSetIsCompletedHandle.Free;
end;

class procedure SendItemAppApi.SetIsDesBusy(DesItemID, BackupPath: string;
  IsDesBusy: Boolean);
var
  SendItemSetIsDesBusyHandle : TSendItemSetIsDesBusyHandle;
begin
  SendItemSetIsDesBusyHandle := TSendItemSetIsDesBusyHandle.Create( DesItemID );
  SendItemSetIsDesBusyHandle.SetSourceInfo( BackupPath );
  SendItemSetIsDesBusyHandle.SetIsDesBusy( IsDesBusy );
  SendItemSetIsDesBusyHandle.Update;
  SendItemSetIsDesBusyHandle.Free;
end;
  

class procedure SendItemAppApi.SetIsExist(DesItemID,
  BackupPath: string; IsExist: Boolean);
var
  BackupItemSetIsExistHandle : TSendItemSetIsExistHandle;
begin
  BackupItemSetIsExistHandle := TSendItemSetIsExistHandle.Create( DesItemID );
  BackupItemSetIsExistHandle.SetSourceInfo( BackupPath );
  BackupItemSetIsExistHandle.SetIsExist( IsExist );
  BackupItemSetIsExistHandle.Update;
  BackupItemSetIsExistHandle.Free;
end;

class procedure SendItemAppApi.SetIsReceiveCancel(DesItemID, BackupPath: string;
  IsReceiveCancel: Boolean);
var
  SendItemSetIsReceiveCancelHandle : TSendItemSetIsReceiveCancelHandle;
begin
  SendItemSetIsReceiveCancelHandle := TSendItemSetIsReceiveCancelHandle.Create( DesItemID );
  SendItemSetIsReceiveCancelHandle.SetSourceInfo( BackupPath );
  SendItemSetIsReceiveCancelHandle.SetIsReceiveCancel( IsReceiveCancel );
  SendItemSetIsReceiveCancelHandle.Update;
  SendItemSetIsReceiveCancelHandle.Free;
end;

class procedure SendItemAppApi.SetIsRemoveToReceive(DesItemID,
  BackupPath: string; IsRemoveToReceive: Boolean);
var
  SendItemSetIsRemoveToReceiveHandle : TSendItemSetIsRemoveToReceiveHandle;
begin
  SendItemSetIsRemoveToReceiveHandle := TSendItemSetIsRemoveToReceiveHandle.Create( DesItemID );
  SendItemSetIsRemoveToReceiveHandle.SetSourceInfo( BackupPath );
  SendItemSetIsRemoveToReceiveHandle.SetIsRemoveToReceive( IsRemoveToReceive );
  SendItemSetIsRemoveToReceiveHandle.Update;
  SendItemSetIsRemoveToReceiveHandle.Free;
end;



class procedure SendItemAppApi.SetIsLostConn(DesItemID, BackupPath: string;
  IsLostConn: Boolean);
var
  SendItemSetIsSendAgainHandle : TSendItemSetIsLostConnHandle;
begin
  SendItemSetIsSendAgainHandle := TSendItemSetIsLostConnHandle.Create( DesItemID );
  SendItemSetIsSendAgainHandle.SetSourceInfo( BackupPath );
  SendItemSetIsSendAgainHandle.SetIsLostConn( IsLostConn );
  SendItemSetIsSendAgainHandle.Update;
  SendItemSetIsSendAgainHandle.Free;
end;

class procedure SendItemAppApi.SetLastBackupTime(DesItemID, BackupPath: string;
  LastBackupTime: TDateTime);
var
  SendItemSetLastSendTimeHandle : TSendItemSetLastSendTimeHandle;
begin
  SendItemSetLastSendTimeHandle := TSendItemSetLastSendTimeHandle.Create( DesItemID );
  SendItemSetLastSendTimeHandle.SetSourceInfo( BackupPath );
  SendItemSetLastSendTimeHandle.SetLastSendTime( LastBackupTime );
  SendItemSetLastSendTimeHandle.Update;
  SendItemSetLastSendTimeHandle.Free;
end;

class procedure SendItemAppApi.SetLocalBackupCompleted(
  DesItemID, BackupPath : string);
var
  BackupItemLocalCompletedHandle : TBackupItemLocalCompletedHandle;
begin
  BackupItemLocalCompletedHandle := TBackupItemLocalCompletedHandle.Create( DesItemID );
  BackupItemLocalCompletedHandle.SetSourceInfo( BackupPath );
  BackupItemLocalCompletedHandle.Update;
  BackupItemLocalCompletedHandle.Free;
end;

class procedure SendItemAppApi.SetNetworkBackupCompleted(
  DesItemID, BackupPath : string);
var
  BackupItemNetworkCompletedHandle : TBackupItemNetworkCompletedHandle;
begin
  BackupItemNetworkCompletedHandle := TBackupItemNetworkCompletedHandle.Create( DesItemID );
  BackupItemNetworkCompletedHandle.SetSourceInfo( BackupPath );
  BackupItemNetworkCompletedHandle.Update;
  BackupItemNetworkCompletedHandle.Free;
end;

class procedure SendItemAppApi.SetScaningCount(DesItemID,
  BackupPath: string; FileCount: Integer);
var
  BackupItemSetAnalyizeCountHandle : TSendItemSetAnalyizeCountHandle;
begin
  BackupItemSetAnalyizeCountHandle := TSendItemSetAnalyizeCountHandle.Create( DesItemID );
  BackupItemSetAnalyizeCountHandle.SetSourceInfo( BackupPath );
  BackupItemSetAnalyizeCountHandle.SetAnalyizeCount( FileCount );
  BackupItemSetAnalyizeCountHandle.Update;
  BackupItemSetAnalyizeCountHandle.Free;
end;



class procedure SendItemAppApi.SetSpaceInfo(Params : TBackupSetSpaceParams);
var
  BackupItemSetSpaceInfoHandle : TSendItemSetSpaceInfoHandle;
begin
  BackupItemSetSpaceInfoHandle := TSendItemSetSpaceInfoHandle.Create( Params.DesItemID );
  BackupItemSetSpaceInfoHandle.SetSourceInfo( Params.BackupPath );
  BackupItemSetSpaceInfoHandle.SetSpaceInfo( Params.FileCount, Params.FileSpace, Params.CompletedSpce );
  BackupItemSetSpaceInfoHandle.Update;
  BackupItemSetSpaceInfoHandle.Free;
end;

class procedure SendItemAppApi.SetSpeed(DesItemID,
  BackupPath: string; Speed: Int64);
var
  BackupItemSetSpeedHandle : TSendItemSetSpeedHandle;
begin
  BackupItemSetSpeedHandle := TSendItemSetSpeedHandle.Create( DesItemID );
  BackupItemSetSpeedHandle.SetSourceInfo( BackupPath );
  BackupItemSetSpeedHandle.SetSpeed( Speed );
  BackupItemSetSpeedHandle.Update;
  BackupItemSetSpeedHandle.Free;
end;



class procedure SendItemAppApi.SetStartBackup(DesItemID,
  BackupPath: string);
begin
  SetSpeed( DesItemID, BackupPath, 0 );
  SetBackupItemStatus( DesItemID, BackupPath, SendNodeStatus_Sending );
end;

class procedure SendItemAppApi.SetStopBackup(DesItemID, BackupPath: string);
var
  BackupItemStopHandle : TBackupItemStopHandle;
begin
  BackupItemStopHandle := TBackupItemStopHandle.Create( DesItemID );
  BackupItemStopHandle.SetSourceInfo( BackupPath );
  BackupItemStopHandle.Update;
  BackupItemStopHandle.Free;
end;

class procedure SendItemAppApi.SetWaitingBackup(DesItemID,
  BackupPath: string);
begin
  SetBackupItemStatus( DesItemID, BackupPath, SendNodeStatus_WaitingSend );
end;

{ TLocalDesItemSetIsExistHandle }

procedure TSendRootItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TSendRootItemSetIsExistHandle.SetToFace;
var
  DesItemSetIsExistFace : TSendRootItemSetIsExistFace;
begin
  DesItemSetIsExistFace := TSendRootItemSetIsExistFace.Create( SendRootItemID );
  DesItemSetIsExistFace.SetIsExist( IsExist );
  DesItemSetIsExistFace.AddChange;
end;

procedure TSendRootItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsWriteHandle }

procedure TSendRootItemSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TSendRootItemSetIsWriteHandle.SetToFace;
var
  DesItemSetIsWriteFace : TSendRootItemSetIsWriteFace;
begin
  DesItemSetIsWriteFace := TSendRootItemSetIsWriteFace.Create( SendRootItemID );
  DesItemSetIsWriteFace.SetIsWrite( IsWrite );
  DesItemSetIsWriteFace.AddChange;
end;

procedure TSendRootItemSetIsWriteHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsLackSpaceHandle }

procedure TSendRootItemSetIsLackSpaceHandle.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TSendRootItemSetIsLackSpaceHandle.SetToFace;
var
  DesItemSetIsLackSpaceFace : TSendRootItemSetIsLackSpaceFace;
begin
  DesItemSetIsLackSpaceFace := TSendRootItemSetIsLackSpaceFace.Create( SendRootItemID );
  DesItemSetIsLackSpaceFace.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceFace.AddChange;
end;

procedure TSendRootItemSetIsLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetIsExistHandle }

procedure TSendItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TSendItemSetIsExistHandle.SetToFace;
var
  LocalBackupItemSetIsExistFace : TSendItemSetIsExistFace;
begin
  LocalBackupItemSetIsExistFace := TSendItemSetIsExistFace.Create( SendRootItemID );
  LocalBackupItemSetIsExistFace.SetSourcePath( SourcePath );
  LocalBackupItemSetIsExistFace.SetIsExist( IsExist );
  LocalBackupItemSetIsExistFace.AddChange;
end;

procedure TSendItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetSpaceInfoHandle }

procedure TSendItemSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemSetSpaceInfoHandle.SetToInfo;
var
  LocalBackupItemSetSpaceInfoInfo : TSendItemSetSpaceInfoInfo;
begin
  LocalBackupItemSetSpaceInfoInfo := TSendItemSetSpaceInfoInfo.Create( SendRootItemID );
  LocalBackupItemSetSpaceInfoInfo.SetBackupPath( SourcePath );
  LocalBackupItemSetSpaceInfoInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoInfo.Update;
  LocalBackupItemSetSpaceInfoInfo.Free;
end;

procedure TSendItemSetSpaceInfoHandle.SetToXml;
var
  LocalBackupItemSetSpaceInfoXml : TSendItemSetSpaceInfoXml;
begin
  LocalBackupItemSetSpaceInfoXml := TSendItemSetSpaceInfoXml.Create( SendRootItemID );
  LocalBackupItemSetSpaceInfoXml.SetSourcePath( SourcePath );
  LocalBackupItemSetSpaceInfoXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoXml.AddChange;
end;

procedure TSendItemSetSpaceInfoHandle.SetToFace;
var
  LocalBackupItemSetSpaceInfoFace : TSendItemSetSpaceInfoFace;
begin
  LocalBackupItemSetSpaceInfoFace := TSendItemSetSpaceInfoFace.Create( SendRootItemID );
  LocalBackupItemSetSpaceInfoFace.SetSourcePath( SourcePath );
  LocalBackupItemSetSpaceInfoFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoFace.AddChange;
end;

procedure TSendItemSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetBackupItemStatusHandle }

procedure TSendItemSetStatusHandle.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TSendItemSetStatusHandle.SetToFace;
var
  LocalBackupItemSetBackupItemStatusFace : TSendItemSetStatusFace;
begin
  LocalBackupItemSetBackupItemStatusFace := TSendItemSetStatusFace.Create( SendRootItemID );
  LocalBackupItemSetBackupItemStatusFace.SetSourcePath( SourcePath );
  LocalBackupItemSetBackupItemStatusFace.SetBackupItemStatus( BackupItemStatus );
  LocalBackupItemSetBackupItemStatusFace.AddChange;
end;

procedure TSendItemSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetAddCompletedSpaceHandle }

procedure TSendItemAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TSendItemAddCompletedSpaceHandle.SetToInfo;
var
  LocalBackupItemSetAddCompletedSpaceInfo : TSendItemSetAddCompletedSpaceInfo;
begin
  LocalBackupItemSetAddCompletedSpaceInfo := TSendItemSetAddCompletedSpaceInfo.Create( SendRootItemID );
  LocalBackupItemSetAddCompletedSpaceInfo.SetBackupPath( SourcePath );
  LocalBackupItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceInfo.Update;
  LocalBackupItemSetAddCompletedSpaceInfo.Free;
end;

procedure TSendItemAddCompletedSpaceHandle.SetToXml;
var
  LocalBackupItemSetAddCompletedSpaceXml : TSendItemSetAddCompletedSpaceXml;
begin
  LocalBackupItemSetAddCompletedSpaceXml := TSendItemSetAddCompletedSpaceXml.Create( SendRootItemID );
  LocalBackupItemSetAddCompletedSpaceXml.SetSourcePath( SourcePath );
  LocalBackupItemSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceXml.AddChange;
end;

procedure TSendItemAddCompletedSpaceHandle.SetToFace;
var
  LocalBackupItemSetAddCompletedSpaceFace : TSendItemSetAddCompletedSpaceFace;
begin
  LocalBackupItemSetAddCompletedSpaceFace := TSendItemSetAddCompletedSpaceFace.Create( SendRootItemID );
  LocalBackupItemSetAddCompletedSpaceFace.SetSourcePath( SourcePath );
  LocalBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceFace.AddChange;
end;

procedure TSendItemAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupSelectedItemHandle }

procedure TSendSelectedLocalItemHandle.AddToScan;
var
  ScanPathInfo : TLocalScanPathInfo;
begin
    // 添加扫描路径
  ScanPathInfo := TLocalScanPathInfo.Create( SourcePath );
  ScanPathInfo.SetDesItemID( SendRootItemID );
  MyFileSendHandler.AddScanJob( ScanPathInfo );
end;


{ TLocalBackupItemSetSpeedHandle }

procedure TSendItemSetSpeedHandle.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TSendItemSetSpeedHandle.SetToFace;
var
  LocalBackupItemSetSpeedFace : TSendItemSetSpeedFace;
begin
  LocalBackupItemSetSpeedFace := TSendItemSetSpeedFace.Create( SendRootItemID );
  LocalBackupItemSetSpeedFace.SetSourcePath( SourcePath );
  LocalBackupItemSetSpeedFace.SetSpeed( Speed );
  LocalBackupItemSetSpeedFace.AddChange;
end;

procedure TSendItemSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ TBackupSelectedItemHandle }

function TSendSelectedItemHandle.getIsAddToScan: Boolean;
begin
  Result := True;
end;

procedure TSendSelectedItemHandle.Update;
begin
    // 发送中断
  if not getIsAddToScan then
    Exit;

    // 正在备份，跳过
  if SendItemInfoReadUtil.ReadIsBackuping( SendRootItemID, SourcePath ) then
    Exit;

    // 设置等待备份
  SendItemAppApi.SetWaitingBackup( SendRootItemID, SourcePath );

    // 正在备份
  SendItemAppApi.SetIsBackuping( SendRootItemID, SourcePath, True );

    // 并未备份完成
  SendItemAppApi.SetIsCompleted( SendRootItemID, SourcePath, False );

    // 设置 非繁忙
  SendItemAppApi.SetIsDesBusy( SendRootItemID, SourcePath, False );

    // 设置 非失去连接
  SendItemAppApi.SetIsLostConn( SendRootItemID, SourcePath, False );

    // 清空 未完成 log
  SendLogApi.ClearIncompleted( SendRootItemID, SourcePath );

    // 添加到扫描
  AddToScan;
end;

{ DesItemUserApi }

class procedure SendRootItemUserApi.AddLocalItem(DesItemID: string);
var
  DesItemAddLocalHandle : TSendRootItemAddLocalHandle;
begin
  DesItemAddLocalHandle := TSendRootItemAddLocalHandle.Create( DesItemID );
  DesItemAddLocalHandle.Update;
  DesItemAddLocalHandle.Free;
end;

class procedure SendRootItemUserApi.BackupSelectLocalItem(DesItemID: string);
var
  BackupDesSelectLocalItemHandle : TBackupDesSelectLocalItemHandle;
begin
  BackupDesSelectLocalItemHandle := TBackupDesSelectLocalItemHandle.Create( DesItemID );
  BackupDesSelectLocalItemHandle.Update;
  BackupDesSelectLocalItemHandle.Free;
end;

class procedure SendRootItemUserApi.BackupSelectNetworkItem(DesItemID: string);
var
  BackupDesSelectNetworkItemHandle : TBackupDesSelectNetworkItemHandle;
begin
  BackupDesSelectNetworkItemHandle := TBackupDesSelectNetworkItemHandle.Create( DesItemID );
  BackupDesSelectNetworkItemHandle.Update;
  BackupDesSelectNetworkItemHandle.Free;
end;

class procedure SendRootItemUserApi.RemoveNetworkItem(DesItemID: string);
var
  SendRootItemRemoveNetworkHandle : TSendRootItemRemoveNetworkHandle;
begin
  SendRootItemRemoveNetworkHandle := TSendRootItemRemoveNetworkHandle.Create( DesItemID );
  SendRootItemRemoveNetworkHandle.Update;
  SendRootItemRemoveNetworkHandle.Free;
end;

class procedure SendRootItemUserApi.RemoveLocalItem(DesItemID: string);
var
  SendRootItemRemoveLocalHandle : TSendRootItemRemoveLocalHandle;
begin
  SendRootItemRemoveLocalHandle := TSendRootItemRemoveLocalHandle.Create( DesItemID );
  SendRootItemRemoveLocalHandle.Update;
  SendRootItemRemoveLocalHandle.Free;
end;

{ DesItemAppApi }

class procedure SendRootItemAppApi.AddNetworkItem(DesItemID: string;
  AvailableSpace : Int64);
var
  DesItemAddNetworkHandle : TSendRootItemAddNetworkHandle;
begin
  DesItemAddNetworkHandle := TSendRootItemAddNetworkHandle.Create( DesItemID );
  DesItemAddNetworkHandle.SetIsOnline( True );
  DesItemAddNetworkHandle.SetAvailableSpace( AvailableSpace );
  DesItemAddNetworkHandle.Update;
  DesItemAddNetworkHandle.Free;
end;


class procedure SendRootItemAppApi.SetAvaialbleSpace(DesItemID: string;
  AvailableSpace: Int64);
var
  DesItemSetAvailableSpaceHandle : TSendRootItemSetAvailableSpaceHandle;
begin
  DesItemSetAvailableSpaceHandle := TSendRootItemSetAvailableSpaceHandle.Create( DesItemID );
  DesItemSetAvailableSpaceHandle.SetAvailableSpace( AvailableSpace );
  DesItemSetAvailableSpaceHandle.Update;
  DesItemSetAvailableSpaceHandle.Free;
end;


class procedure SendRootItemAppApi.SetIsConnected(DesItemID: string;
  IsConnected: Boolean);
var
  SendRootItemSetIsConnectedHandle : TSendRootItemSetIsConnectedHandle;
begin
  SendRootItemSetIsConnectedHandle := TSendRootItemSetIsConnectedHandle.Create( DesItemID );
  SendRootItemSetIsConnectedHandle.SetIsConnected( IsConnected );
  SendRootItemSetIsConnectedHandle.Update;
  SendRootItemSetIsConnectedHandle.Free;
end;



class procedure SendRootItemAppApi.SetIsExist(DesItemID: string; IsExist: Boolean);
var
  DesItemSetIsExistHandle : TSendRootItemSetIsExistHandle;
begin
  DesItemSetIsExistHandle := TSendRootItemSetIsExistHandle.Create( DesItemID );
  DesItemSetIsExistHandle.SetIsExist( IsExist );
  DesItemSetIsExistHandle.Update;
  DesItemSetIsExistHandle.Free;
end;


class procedure SendRootItemAppApi.SetNetworkPcIsOnline(DesPcID: string;
  IsOnline: Boolean);
var
  NetworkDesPcSetIsOnline : TNetworkDesPcSetIsOnline;
begin
  NetworkDesPcSetIsOnline := TNetworkDesPcSetIsOnline.Create( DesPcID );
  NetworkDesPcSetIsOnline.SetIsOnline( IsOnline );
  NetworkDesPcSetIsOnline.Update;
  NetworkDesPcSetIsOnline.Free;
end;

class procedure SendRootItemAppApi.SetIsLackSpace(DesItemID: string;
  IsLackSpace: Boolean);
var
  DesItemSetIsLackSpaceHandle : TSendRootItemSetIsLackSpaceHandle;
begin
  DesItemSetIsLackSpaceHandle := TSendRootItemSetIsLackSpaceHandle.Create( DesItemID );
  DesItemSetIsLackSpaceHandle.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceHandle.Update;
  DesItemSetIsLackSpaceHandle.Free;
end;

class procedure SendRootItemAppApi.SetIsWrite(DesItemID: string; IsWrite: Boolean);
var
  DesItemSetIsWriteHandle : TSendRootItemSetIsWriteHandle;
begin
  DesItemSetIsWriteHandle := TSendRootItemSetIsWriteHandle.Create( DesItemID );
  DesItemSetIsWriteHandle.SetIsWrite( IsWrite );
  DesItemSetIsWriteHandle.Update;
  DesItemSetIsWriteHandle.Free;
end;

{ TDesItemReadLocalHandle }

procedure TSendRootItemReadLocalHandle.AddToFace;
var
  AvailableSpace : Int64;
  DesItemAddLocalFace : TSendRootItemAddLocalFace;
  FrmLocalDesAdd : TFrmLocalDesAdd;
begin
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( SendRootItemID );

  DesItemAddLocalFace := TSendRootItemAddLocalFace.Create( SendRootItemID );
  DesItemAddLocalFace.SetAvailableSpace( AvailableSpace );
  DesItemAddLocalFace.AddChange;

  FrmLocalDesAdd := TFrmLocalDesAdd.Create( SendRootItemID );
  FrmLocalDesAdd.SetAvailableSpace( AvailableSpace );
  FrmLocalDesAdd.SetIsSelect( False );
  FrmLocalDesAdd.AddChange;
end;

procedure TSendRootItemReadLocalHandle.AddToInfo;
var
  DesItemAddLocalInfo : TSendRootItemAddLocalInfo;
begin
  DesItemAddLocalInfo := TSendRootItemAddLocalInfo.Create( SendRootItemID );
  DesItemAddLocalInfo.Update;
  DesItemAddLocalInfo.Free;
end;

procedure TSendRootItemReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddLocalHandle }

procedure TSendRootItemAddLocalHandle.AddToFace;
var
  AvailableSpace : Int64;
  DesItemAddLocalFace : TSendRootItemAddLocalFace;
  FrmLocalDesAdd : TFrmLocalDesAdd;
begin
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( SendRootItemID );

  DesItemAddLocalFace := TSendRootItemAddLocalFace.Create( SendRootItemID );
  DesItemAddLocalFace.SetAvailableSpace( AvailableSpace );
  DesItemAddLocalFace.AddChange;

  FrmLocalDesAdd := TFrmLocalDesAdd.Create( SendRootItemID );
  FrmLocalDesAdd.SetAvailableSpace( AvailableSpace );
  FrmLocalDesAdd.SetIsSelect( True );
  FrmLocalDesAdd.AddChange;
end;

procedure TSendRootItemAddLocalHandle.AddToXml;
var
  DesItemAddLocalXml : TSendRootItemAddLocalXml;
begin
  DesItemAddLocalXml := TSendRootItemAddLocalXml.Create( SendRootItemID );
  DesItemAddLocalXml.AddChange;
end;

procedure TSendRootItemAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TDesItemReadNetworkHandle }

procedure TSendRootItemReadNetworkHandle.AddToFace;
var
  DesPcName, PcName, DesName : string;
  ComputerID, ComputerName, DirectoryPath : string;
  IsLanPc : Boolean;
  DesItemAddNetworkFace : TSendRootItemAddNetworkFace;
  FrmNetworkDesAdd : TFrmNetworkDesAdd;
  FrmSendPcFilterAdd : TFrmSendPcFilterAdd;
begin
  ComputerID := NetworkDesItemUtil.getPcID( SendRootItemID );

    // 本机，不处理
  if ( ComputerID = PcInfo.PcID ) and not AppInfo_IsDebug then
    Exit;

  PcName := MyNetPcInfoReadUtil.ReadName( ComputerID );
  DesName := NetworkDesItemUtil.getCloudPath( SendRootItemID );
  DesPcName := MyNetPcInfoReadUtil.ReadDesItemShow( SendRootItemID );
  IsLanPc := MyNetPcInfoReadUtil.ReadIsLanPc( ComputerID );

  DesItemAddNetworkFace := TSendRootItemAddNetworkFace.Create( SendRootItemID );
  DesItemAddNetworkFace.SetPcName( PcName );
  DesItemAddNetworkFace.SetDesName( DesName );
  DesItemAddNetworkFace.SetIsOnline( IsOnline );
  DesItemAddNetworkFace.SetIsLan( IsLanPc );
  DesItemAddNetworkFace.SetAvailableSpace( AvailableSpace );
  DesItemAddNetworkFace.AddChange;

  FrmNetworkDesAdd := TFrmNetworkDesAdd.Create( SendRootItemID );
  FrmNetworkDesAdd.SetPcName( DesPcName );
  FrmNetworkDesAdd.SetIsOnline( IsOnline );
  FrmNetworkDesAdd.SetIsLan( IsLanPc );
  FrmNetworkDesAdd.SetAvailableSpace( AvailableSpace );
  FrmNetworkDesAdd.SetNameInfo( PcName, DesName );
  FrmNetworkDesAdd.AddChange;

  ComputerName := MyNetPcInfoReadUtil.ReadName( ComputerID );
  DirectoryPath := NetworkDesItemUtil.getCloudPath( SendRootItemID );

  FrmSendPcFilterAdd := TFrmSendPcFilterAdd.Create( SendRootItemID );
  FrmSendPcFilterAdd.SetPcName( ComputerName );
  FrmSendPcFilterAdd.SetDirectory( DirectoryPath );
  FrmSendPcFilterAdd.SetIsOnline( IsOnline );
  FrmSendPcFilterAdd.SetIsLan( IsLanPc );
  FrmSendPcFilterAdd.AddChange;
end;

procedure TSendRootItemReadNetworkHandle.AddToInfo;
var
  DesItemAddNetworkInfo : TSendRootItemAddNetworkInfo;
begin
  DesItemAddNetworkInfo := TSendRootItemAddNetworkInfo.Create( SendRootItemID );
  DesItemAddNetworkInfo.Update;
  DesItemAddNetworkInfo.Free;
end;

procedure TSendRootItemReadNetworkHandle.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TSendRootItemReadNetworkHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TSendRootItemReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddNetworkHandle }

procedure TSendRootItemAddNetworkHandle.AddToXml;
var
  DesItemAddNetworkXml : TSendRootItemAddNetworkXml;
begin
  DesItemAddNetworkXml := TSendRootItemAddNetworkXml.Create( SendRootItemID );
  DesItemAddNetworkXml.AddChange;
end;

procedure TSendRootItemAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupSelectedNetworkItemHandle }

procedure TSendSelectedNetworkItemHandle.AddToScan;
var
  ScanPathInfo : TNetworkScanPathInfo;
begin
    // 添加扫描路径
  ScanPathInfo := TNetworkScanPathInfo.Create( SourcePath );
  ScanPathInfo.SetDesItemID( SendRootItemID );
  MyFileSendHandler.AddScanJob( ScanPathInfo );
end;

{ TBackupItemCompletedHandle }

procedure TBackupItemStopHandle.Update;
begin
    // 设置 非正在备份
  SendItemAppApi.SetIsBackuping( SendRootItemID, SourcePath, False );

    // 设置 状态为空
  SendItemAppApi.SetBackupItemStatus( SendRootItemID, SourcePath, SendNodeStatus_Stop );
end;

{ TBackupItemCompletedHandle }

procedure TBackupItemCompletedHandle.Update;
begin
    // 设置 备份完成标记
  SendItemAppApi.SetIsCompleted( SendRootItemID, SourcePath, True );

    // 显示 Hint
  AddToHint;
end;

{ TBackupDesSelectLocalItemHandle }

procedure TBackupDesSelectLocalItemHandle.Update;
var
  BackupPathList : TStringList;
  i : Integer;
begin
  BackupPathList := SendRootItemInfoReadUtil.ReadBackupList( SendRootItemID );
  for i := 0 to BackupPathList.Count - 1 do
    SendItemUserApi.SendSelectLocalItem( SendRootItemID, BackupPathList[i] );
  BackupPathList.Free;
end;

{ TBackupDesSelectNetworkItemHandle }

procedure TBackupDesSelectNetworkItemHandle.Update;
var
  BackupPathList : TStringList;
  i : Integer;
begin
  BackupPathList := SendRootItemInfoReadUtil.ReadBackupList( SendRootItemID );
  for i := 0 to BackupPathList.Count - 1 do
    SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, BackupPathList[i] );
  BackupPathList.Free;
end;


{ TBackupStartHandle }

procedure TSendFileStartHandle.SetToFace;
var
  StartBackupFace : TStartBackupFace;
begin
  StartBackupFace := TStartBackupFace.Create;
  StartBackupFace.AddChange;
end;

procedure TSendFileStartHandle.Update;
begin
  UserTransfer_IsStop := False; // 标记开始传输

  SetToFace;
end;

{ TBackupStopHandle }

procedure TSendFileStopHandle.SetToFace;
var
  StopBackupFace : TStopBackupFace;
begin
  StopBackupFace := TStopBackupFace.Create;
  StopBackupFace.AddChange;
end;

procedure TSendFileStopHandle.Update;
begin
  SetToFace;
end;

{ TBackupItemSetIsBackupingHandle }

procedure TSendItemSetIsBackupingHandle.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TSendItemSetIsBackupingHandle.SetToInfo;
var
  BackupItemSetIsBackupingInfo : TSendItemSetIsBackupingInfo;
begin
  BackupItemSetIsBackupingInfo := TSendItemSetIsBackupingInfo.Create( SendRootItemID );
  BackupItemSetIsBackupingInfo.SetBackupPath( SourcePath );
  BackupItemSetIsBackupingInfo.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingInfo.Update;
  BackupItemSetIsBackupingInfo.Free;
end;

procedure TSendItemSetIsBackupingHandle.SetToFace;
var
  BackupItemSetIsBackupingFace : TSendItemSetIsBackupingFace;
begin
  BackupItemSetIsBackupingFace := TSendItemSetIsBackupingFace.Create( SendRootItemID );
  BackupItemSetIsBackupingFace.SetSourcePath( SourcePath );
  BackupItemSetIsBackupingFace.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingFace.AddChange;
end;

procedure TSendItemSetIsBackupingHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;



{ TBackupItemIncludeFilterSetHandle }

procedure TSendItemIncludeFilterReadHandle.SetIncludeFilterList(
  _IncludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
end;

procedure TSendItemIncludeFilterReadHandle.SetToFace;
var
  IncludeFilterStr : string;
  BackupItemSetIncludeFilterFace : TSendItemSetIncludeFilterFace;
begin
  IncludeFilterStr := FileFilterUtil.getFilterStr( IncludeFilterList );

  BackupItemSetIncludeFilterFace := TSendItemSetIncludeFilterFace.Create( SendRootItemID );
  BackupItemSetIncludeFilterFace.SetSourcePath( SourcePath );
  BackupItemSetIncludeFilterFace.SetIncludeFilterStr( IncludeFilterStr );
  BackupItemSetIncludeFilterFace.AddChange;
end;

procedure TSendItemIncludeFilterReadHandle.SetToInfo;
var
  BackupItemIncludeFilterClearInfo : TSendItemIncludeFilterClearInfo;
  BackupItemIncludeFilterAddInfo : TSendItemIncludeFilterAddInfo;
  i : Integer;
begin
    // 清空旧的
  BackupItemIncludeFilterClearInfo := TSendItemIncludeFilterClearInfo.Create( SendRootItemID );
  BackupItemIncludeFilterClearInfo.SetBackupPath( SourcePath );
  BackupItemIncludeFilterClearInfo.Update;
  BackupItemIncludeFilterClearInfo.Free;

    // 添加新的
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    BackupItemIncludeFilterAddInfo := TSendItemIncludeFilterAddInfo.Create( SendRootItemID );
    BackupItemIncludeFilterAddInfo.SetBackupPath( SourcePath );
    BackupItemIncludeFilterAddInfo.SetFilterInfo( IncludeFilterList[i].FilterType, IncludeFilterList[i].FilterStr );
    BackupItemIncludeFilterAddInfo.Update;
    BackupItemIncludeFilterAddInfo.Free;
  end;
end;

procedure TSendItemIncludeFilterReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupItemIncludeFilterSetHandle }

procedure TSendItemIncludeFilterSetHandle.SetToXml;
var
  BackupItemIncludeFilterClearXml : TSendItemIncludeFilterClearXml;
  BackupItemIncludeFilterAddXml : TSendItemIncludeFilterAddXml;
  i : Integer;
begin
    // 清空旧的
  BackupItemIncludeFilterClearXml := TSendItemIncludeFilterClearXml.Create( SendRootItemID );
  BackupItemIncludeFilterClearXml.SetSourcePath( SourcePath );
  BackupItemIncludeFilterClearXml.AddChange;

    // 添加新的
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    BackupItemIncludeFilterAddXml := TSendItemIncludeFilterAddXml.Create( SendRootItemID );
    BackupItemIncludeFilterAddXml.SetSourcePath( SourcePath );
    BackupItemIncludeFilterAddXml.SetFilterXml( IncludeFilterList[i].FilterType, IncludeFilterList[i].FilterStr );
    BackupItemIncludeFilterAddXml.AddChange;
  end;
end;


procedure TSendItemIncludeFilterSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupItemExcludeFilterReadHandle }

procedure TSendItemExcludeFilterReadHandle.SetExcludeFilterList(
  _ExcludeFilterList: TFileFilterList);
begin
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TSendItemExcludeFilterReadHandle.SetToFace;
var
  ExcludeFilterStr : string;
  BackupItemSetExcludeFilterFace : TSendItemSetExcludeFilterFace;
begin
  ExcludeFilterStr := FileFilterUtil.getFilterStr( ExcludeFilterList );

  BackupItemSetExcludeFilterFace := TSendItemSetExcludeFilterFace.Create( SendRootItemID );
  BackupItemSetExcludeFilterFace.SetSourcePath( SourcePath );
  BackupItemSetExcludeFilterFace.SetExcludeFilterStr( ExcludeFilterStr );
  BackupItemSetExcludeFilterFace.AddChange;
end;

procedure TSendItemExcludeFilterReadHandle.SetToInfo;
var
  BackupItemExcludeFilterClearInfo : TSendItemExcludeFilterClearInfo;
  BackupItemExcludeFilterAddInfo : TSendItemExcludeFilterAddInfo;
  i : Integer;
begin
    // 清空旧的
  BackupItemExcludeFilterClearInfo := TSendItemExcludeFilterClearInfo.Create( SendRootItemID );
  BackupItemExcludeFilterClearInfo.SetBackupPath( SourcePath );
  BackupItemExcludeFilterClearInfo.Update;
  BackupItemExcludeFilterClearInfo.Free;

    // 添加新的
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    BackupItemExcludeFilterAddInfo := TSendItemExcludeFilterAddInfo.Create( SendRootItemID );
    BackupItemExcludeFilterAddInfo.SetBackupPath( SourcePath );
    BackupItemExcludeFilterAddInfo.SetFilterInfo( ExcludeFilterList[i].FilterType, ExcludeFilterList[i].FilterStr );
    BackupItemExcludeFilterAddInfo.Update;
    BackupItemExcludeFilterAddInfo.Free;
  end;
end;


procedure TSendItemExcludeFilterReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupItemExcludeFilterSetHandle }

procedure TSendItemExcludeFilterSetHandle.SetToXml;
var
  BackupItemExcludeFilterClearXml : TSendItemExcludeFilterClearXml;
  BackupItemExcludeFilterAddXml : TSendItemExcludeFilterAddXml;
  i : Integer;
begin
    // 清空旧的
  BackupItemExcludeFilterClearXml := TSendItemExcludeFilterClearXml.Create( SendRootItemID );
  BackupItemExcludeFilterClearXml.SetSourcePath( SourcePath );
  BackupItemExcludeFilterClearXml.AddChange;

    // 添加新的
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    BackupItemExcludeFilterAddXml := TSendItemExcludeFilterAddXml.Create( SendRootItemID );
    BackupItemExcludeFilterAddXml.SetSourcePath( SourcePath );
    BackupItemExcludeFilterAddXml.SetFilterXml( ExcludeFilterList[i].FilterType, ExcludeFilterList[i].FilterStr );
    BackupItemExcludeFilterAddXml.AddChange;
  end;
end;


procedure TSendItemExcludeFilterSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TNetworkDesPcSetIsOnline }

constructor TNetworkDesPcSetIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TNetworkDesPcSetIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TNetworkDesPcSetIsOnline.SetToFace;
var
  IsLan : Boolean;
  DesItemSetPcIsOnlineFace : TSendRootItemSetPcIsOnlineFace;
  FrmNetworkDesIsOnline : TFrmNetworkDesIsOnline;
  FrmSendPcFilterIsOnline : TFrmSendPcFilterIsOnline;
begin
  IsLan := MyNetPcInfoReadUtil.ReadIsLanPc( DesPcID );
  DesItemSetPcIsOnlineFace := TSendRootItemSetPcIsOnlineFace.Create( DesPcID );
  DesItemSetPcIsOnlineFace.SetIsOnline( IsOnline );
  DesItemSetPcIsOnlineFace.SetIsLan( IsLan );
  DesItemSetPcIsOnlineFace.AddChange;

  FrmNetworkDesIsOnline := TFrmNetworkDesIsOnline.Create( DesPcID );
  FrmNetworkDesIsOnline.SetIsOnline( IsOnline );
  FrmNetworkDesIsOnline.SetIsLan( IsLan );
  FrmNetworkDesIsOnline.AddChange;

  FrmSendPcFilterIsOnline := TFrmSendPcFilterIsOnline.Create( DesPcID );
  FrmSendPcFilterIsOnline.SetIsOnline( IsOnline );
  FrmSendPcFilterIsOnline.SetIsLan( IsLan );
  FrmSendPcFilterIsOnline.AddChange;
end;

procedure TNetworkDesPcSetIsOnline.Update;
begin
  SetToFace;
end;

{ TBackupItemSetIsCompletedHandle }

procedure TSendItemSetIsCompletedHandle.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemSetIsCompletedHandle.SetToInfo;
var
  SendItemSetIsCompletedInfo : TSendItemSetIsCompletedInfo;
begin
  SendItemSetIsCompletedInfo := TSendItemSetIsCompletedInfo.Create( SendRootItemID );
  SendItemSetIsCompletedInfo.SetBackupPath( SourcePath );
  SendItemSetIsCompletedInfo.SetIsCompleted( IsCompleted );
  SendItemSetIsCompletedInfo.Update;
  SendItemSetIsCompletedInfo.Free;
end;

procedure TSendItemSetIsCompletedHandle.SetToXml;
var
  BackupItemSetIsCompletedXml : TSendItemSetIsCompletedXml;
begin
  BackupItemSetIsCompletedXml := TSendItemSetIsCompletedXml.Create( SendRootItemID );
  BackupItemSetIsCompletedXml.SetSourcePath( SourcePath );
  BackupItemSetIsCompletedXml.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedXml.AddChange;
end;

procedure TSendItemSetIsCompletedHandle.SetToFace;
var
  BackupItemSetIsCompletedFace : TSendItemSetIsCompletedFace;
begin
  BackupItemSetIsCompletedFace := TSendItemSetIsCompletedFace.Create( SendRootItemID );
  BackupItemSetIsCompletedFace.SetSourcePath( SourcePath );
  BackupItemSetIsCompletedFace.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedFace.AddChange;
end;

procedure TSendItemSetIsCompletedHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;


{ TBackupItemLocalOnlineBackup }

procedure TBackupItemLocalOnlineBackup.Update;
var
  OnlineBackupList : TOnlineSendList;
  i: Integer;
begin
  OnlineBackupList := SendItemInfoReadUtil.ReadLocalOnline;
  for i := 0 to OnlineBackupList.Count - 1 do
    SendItemUserApi.SendSelectLocalItem( OnlineBackupList[i].SendRootItemID, OnlineBackupList[i].SourcePath );
  OnlineBackupList.Free;
end;

{ TBackupItemNetworkOnlineBackup }

constructor TBackupItemNetworkOnlineBackup.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TBackupItemNetworkOnlineBackup.Update;
var
  OnlineBackupList : TNetworkOnlineSendList;
  i: Integer;
  OnlineSendInfo : TNetworkOnlineSendInfo;
  SendRootItemID, SourcePath : string;
begin
  OnlineBackupList := SendItemInfoReadUtil.ReadPcOnline( OnlinePcID );
  for i := 0 to OnlineBackupList.Count - 1 do
  begin
    OnlineSendInfo := OnlineBackupList[i];
    SendRootItemID := OnlineSendInfo.SendRootItemID;
    SourcePath := OnlineSendInfo.SourcePath;
    if OnlineSendInfo.IsAddToReceive then
      NetworkSendItemEvent.AddItem( SendRootItemID, SourcePath )
    else
    if OnlineSendInfo.IsRemoveToReceive then
      NetworkSendItemEvent.RemoveItem( SendRootItemID, SourcePath )
    else
      SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
  end;
  OnlineBackupList.Free;
end;

{ TBackupItemSetAnalyizeCountHandle }

procedure TSendItemSetAnalyizeCountHandle.SetAnalyizeCount( _AnalyizeCount : integer );
begin
  AnalyizeCount := _AnalyizeCount;
end;


procedure TSendItemSetAnalyizeCountHandle.SetToFace;
var
  BackupItemSetAnalyizeCountFace : TSendItemSetAnalyizeCountFace;
begin
  BackupItemSetAnalyizeCountFace := TSendItemSetAnalyizeCountFace.Create( SendRootItemID );
  BackupItemSetAnalyizeCountFace.SetSourcePath( SourcePath );
  BackupItemSetAnalyizeCountFace.SetAnalyizeCount( AnalyizeCount );
  BackupItemSetAnalyizeCountFace.AddChange;
end;

procedure TSendItemSetAnalyizeCountHandle.Update;
begin
  SetToFace;
end;


{ TDesItemSetAvailableSpaceHandle }

procedure TSendRootItemSetAvailableSpaceHandle.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TSendRootItemSetAvailableSpaceHandle.SetToFace;
var
  DesItemSetAvailableSpaceFace : TSendRootItemSetAvailableSpaceFace;
  FrmNetworkSetAvailableSpace : TFrmNetworkSetAvailableSpace;
begin
  DesItemSetAvailableSpaceFace := TSendRootItemSetAvailableSpaceFace.Create( SendRootItemID );
  DesItemSetAvailableSpaceFace.SetAvailableSpace( AvailableSpace );
  DesItemSetAvailableSpaceFace.AddChange;

  FrmNetworkSetAvailableSpace := TFrmNetworkSetAvailableSpace.Create( SendRootItemID );
  FrmNetworkSetAvailableSpace.SetAvailableSpace( AvailableSpace );
  FrmNetworkSetAvailableSpace.AddChange;
end;

procedure TSendRootItemSetAvailableSpaceHandle.Update;
begin
  SetToFace;
end;

{ BackupContinusAppApi }

class procedure SendContinusAppApi.AddItem(Params: TSendContinusAddParams);
var
  BackupContinusAddHandle : TSendContinusAddHandle;
begin
  BackupContinusAddHandle := TSendContinusAddHandle.Create( Params.SendRootItemID );
  BackupContinusAddHandle.SetSourceInfo( Params.SourcePath );
  BackupContinusAddHandle.SetFilePath( Params.FilePath );
  BackupContinusAddHandle.SetFileTime( Params.FileTime );
  BackupContinusAddHandle.SetSpaceInfo( Params.FileSize, Params.Position );
  BackupContinusAddHandle.Update;
  BackupContinusAddHandle.Free;
end;



class procedure SendContinusAppApi.RemoveItem(DesItemID, SourcePath,
  FilePath: string);
var
  BackupContinusRemoveHandle : TSendContinusRemoveHandle;
begin
  BackupContinusRemoveHandle := TSendContinusRemoveHandle.Create( DesItemID );
  BackupContinusRemoveHandle.SetSourceInfo( SourcePath );
  BackupContinusRemoveHandle.SetFilePath( FilePath );
  BackupContinusRemoveHandle.Update;
  BackupContinusRemoveHandle.Free;
end;



procedure TSendContinusWriteHandle.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;

{ TBackupContinusReadHandle }

procedure TSendContinusReadHandle.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TSendContinusReadHandle.SetSpaceInfo( _FileSize, _Posiiton : int64 );
begin
  FileSize := _FileSize;
  Position := _Posiiton;
end;

procedure TSendContinusReadHandle.AddToInfo;
var
  BackupContinusAddInfo : TSendContinusAddInfo;
begin
  BackupContinusAddInfo := TSendContinusAddInfo.Create( SendRootItemID );
  BackupContinusAddInfo.SetBackupPath( SourcePath );
  BackupContinusAddInfo.SetFilePath( FilePath );
  BackupContinusAddInfo.SetFileTime( FileTime );
  BackupContinusAddInfo.SetSpaceInfo( FileSize, Position );
  BackupContinusAddInfo.Update;
  BackupContinusAddInfo.Free;
end;

procedure TSendContinusReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupContinusAddHandle }

procedure TSendContinusAddHandle.AddToXml;
var
  BackupContinusAddXml : TSendContinusAddXml;
begin
  BackupContinusAddXml := TSendContinusAddXml.Create( SendRootItemID );
  BackupContinusAddXml.SetSourcePath( SourcePath );
  BackupContinusAddXml.SetFilePath( FilePath );
  BackupContinusAddXml.SetFileTime( FileTime );
  BackupContinusAddXml.SetSpaceInfo( FileSize, Position );
  BackupContinusAddXml.AddChange;
end;

procedure TSendContinusAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupContinusRemoveHandle }

procedure TSendContinusRemoveHandle.RemoveFromInfo;
var
  BackupContinusRemoveInfo : TSendContinusRemoveInfo;
begin
  BackupContinusRemoveInfo := TSendContinusRemoveInfo.Create( SendRootItemID );
  BackupContinusRemoveInfo.SetBackupPath( SourcePath );
  BackupContinusRemoveInfo.SetFilePath( FilePath );
  BackupContinusRemoveInfo.Update;
  BackupContinusRemoveInfo.Free;
end;

procedure TSendContinusRemoveHandle.RemoveFromXml;
var
  BackupContinusRemoveXml : TSendContinusRemoveXml;
begin
  BackupContinusRemoveXml := TSendContinusRemoveXml.Create( SendRootItemID );
  BackupContinusRemoveXml.SetSourcePath( SourcePath );
  BackupContinusRemoveXml.SetFilePath( FilePath );
  BackupContinusRemoveXml.AddChange;
end;

procedure TSendContinusRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;


{ TSendItemAddNetworkHandle }

procedure TSendItemAddNetworkHandle.AddToEvent;
begin
  NetworkSendItemEvent.AddItem( SendRootItemID, SourcePath );
end;

procedure TSendItemAddNetworkHandle.AddToXml;
var
  SendItemAddNetworkXml : TSendItemAddNetworkXml;
begin
  SendItemAddNetworkXml := TSendItemAddNetworkXml.Create( SendRootItemID );
  SendItemAddNetworkXml.SetSourcePath( SourcePath );
  SendItemAddNetworkXml.SetIsFile( IsFile );
  SendItemAddNetworkXml.SetIsCompleted( IsCompleted );
  SendItemAddNetworkXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendItemAddNetworkXml.SetZipInfo( IsZip, ZipPath );
  SendItemAddNetworkXml.SetReceiveInfo( IsAddToReceive, IsRemoveToReceive );
  SendItemAddNetworkXml.SetIsReceiveCancel( IsReceiveCancel );
  SendItemAddNetworkXml.SetScheduleInfo( ScheduleType, ScheduleValue1, ScheduleValue2 );
  SendItemAddNetworkXml.SetLastSendTime( LastSendTime );
  SendItemAddNetworkXml.AddChange;
end;

procedure TSendItemAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TSendItemReadLocalHandle }

procedure TSendItemReadLocalHandle.AddToFace;
var
  SendItemAddLocalFace : TSendItemAddLocalFace;
begin
  SendItemAddLocalFace := TSendItemAddLocalFace.Create( SendRootItemID );
  SendItemAddLocalFace.SetSourcePath( SourcePath );
  SendItemAddLocalFace.SetIsFile( IsFile );
  SendItemAddLocalFace.SetIsCompleted( IsCompleted );
  SendItemAddLocalFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendItemAddLocalFace.SetZipInfo( IsZip, ZipPath );
  SendItemAddLocalFace.SetSavePath( SavePath );
  SendItemAddLocalFace.AddChange;
end;

procedure TSendItemReadLocalHandle.AddToInfo;
var
  SendItemAddLocalInfo : TSendItemAddLocalInfo;
begin
  SendItemAddLocalInfo := TSendItemAddLocalInfo.Create( SendRootItemID );
  SendItemAddLocalInfo.SetBackupPath( SourcePath );
  SendItemAddLocalInfo.SetIsFile( IsFile );
  SendItemAddLocalInfo.SetIsCompleted( IsCompleted );
  SendItemAddLocalInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendItemAddLocalInfo.SetZipInfo( IsZip, ZipPath );
  SendItemAddLocalInfo.SetSavePath( SavePath );
  SendItemAddLocalInfo.Update;
  SendItemAddLocalInfo.Free;
end;

procedure TSendItemReadLocalHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TSendItemReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TSendItemAddLocalHandle }

procedure TSendItemAddLocalHandle.AddToXml;
var
  SendItemAddLocalXml : TSendItemAddLocalXml;
begin
  SendItemAddLocalXml := TSendItemAddLocalXml.Create( SendRootItemID );
  SendItemAddLocalXml.SetSourcePath( SourcePath );
  SendItemAddLocalXml.SetIsFile( IsFile );
  SendItemAddLocalXml.SetIsCompleted( IsCompleted );
  SendItemAddLocalXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendItemAddLocalXml.SetZipInfo( IsZip, ZipPath );
  SendItemAddLocalXml.SetSavePath( SavePath );
  SendItemAddLocalXml.AddChange;
end;

procedure TSendItemAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TSendItemReadNetworkHandle }

procedure TSendItemReadNetworkHandle.AddToFace;
var
  SendITemAddNetworkFace : TSendITemAddNetworkFace;
begin
  SendITemAddNetworkFace := TSendITemAddNetworkFace.Create( SendRootItemID );
  SendITemAddNetworkFace.SetSourcePath( SourcePath );
  SendITemAddNetworkFace.SetIsFile( IsFile );
  SendITemAddNetworkFace.SetIsCompleted( IsCompleted );
  SendITemAddNetworkFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendITemAddNetworkFace.SetZipInfo( IsZip, ZipPath );
  SendITemAddNetworkFace.SetIsReceiveCancel( IsReceiveCancel );
  SendITemAddNetworkFace.SetScheduleInfo( ScheduleType, ScheduleValue1, ScheduleValue2 );
  SendITemAddNetworkFace.SetLastSendTime( LastSendTime );
  SendITemAddNetworkFace.AddChange;
end;

procedure TSendItemReadNetworkHandle.AddToInfo;
var
  SendItemAddNetworkInfo : TSendItemAddNetworkInfo;
begin
  SendItemAddNetworkInfo := TSendItemAddNetworkInfo.Create( SendRootItemID );
  SendItemAddNetworkInfo.SetBackupPath( SourcePath );
  SendItemAddNetworkInfo.SetIsFile( IsFile );
  SendItemAddNetworkInfo.SetIsCompleted( IsCompleted );
  SendItemAddNetworkInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  SendItemAddNetworkInfo.SetZipInfo( IsZip, ZipPath );
  SendItemAddNetworkInfo.SetReceiveInfo( IsAddToReceive, IsRemoveToReceive );
  SendItemAddNetworkInfo.SetIsReceiveCancel( IsReceiveCancel );
  SendItemAddNetworkInfo.SetScheduleInfo( ScheduleType, ScheduleValue1, ScheduleValue2 );
  SendItemAddNetworkInfo.SetLastSendTime( LastSendTime );
  SendItemAddNetworkInfo.Update;
  SendItemAddNetworkInfo.Free;
end;


procedure TSendItemReadNetworkHandle.SetIsReceiveCancel(
  _IsReceiveCancel: Boolean);
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemReadNetworkHandle.SetReceiveInfo(_IsAddToReceive,
  _IsRemoveToReceive: Boolean);
begin
  IsAddToReceive := _IsAddToReceive;
  IsRemoveToReceive := _IsRemoveToReceive;
end;

procedure TSendItemReadNetworkHandle.Update;
begin
  AddToInfo;

    // 未删除则显示
  if not IsRemoveToReceive then
    AddToFace;
end;

{ TSendItemSetIsRemoveToReceiveHandle }

procedure TSendItemSetIsRemoveToReceiveHandle.SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
begin
  IsRemoveToReceive := _IsRemoveToReceive;
end;

procedure TSendItemSetIsRemoveToReceiveHandle.SetToInfo;
var
  SendItemSetIsRemoveToReceiveInfo : TSendItemSetIsRemoveToReceiveInfo;
begin
  SendItemSetIsRemoveToReceiveInfo := TSendItemSetIsRemoveToReceiveInfo.Create( SendRootItemID );
  SendItemSetIsRemoveToReceiveInfo.SetBackupPath( SourcePath );
  SendItemSetIsRemoveToReceiveInfo.SetIsRemoveToReceive( IsRemoveToReceive );
  SendItemSetIsRemoveToReceiveInfo.Update;
  SendItemSetIsRemoveToReceiveInfo.Free;
end;

procedure TSendItemSetIsRemoveToReceiveHandle.SetToXml;
var
  SendItemSetIsRemoveToReceiveXml : TSendItemSetIsRemoveToReceiveXml;
begin
  SendItemSetIsRemoveToReceiveXml := TSendItemSetIsRemoveToReceiveXml.Create( SendRootItemID );
  SendItemSetIsRemoveToReceiveXml.SetSourcePath( SourcePath );
  SendItemSetIsRemoveToReceiveXml.SetIsRemoveToReceive( IsRemoveToReceive );
  SendItemSetIsRemoveToReceiveXml.AddChange;
end;

procedure TSendItemSetIsRemoveToReceiveHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TSendItemSetIsAddToReceiveHandle }

procedure TSendItemSetIsAddToReceiveHandle.SetIsAddToReceive( _IsAddToReceive : boolean );
begin
  IsAddToReceive := _IsAddToReceive;
end;

procedure TSendItemSetIsAddToReceiveHandle.SetToInfo;
var
  SendItemSetIsAddToReceiveInfo : TSendItemSetIsAddToReceiveInfo;
begin
  SendItemSetIsAddToReceiveInfo := TSendItemSetIsAddToReceiveInfo.Create( SendRootItemID );
  SendItemSetIsAddToReceiveInfo.SetBackupPath( SourcePath );
  SendItemSetIsAddToReceiveInfo.SetIsAddToReceive( IsAddToReceive );
  SendItemSetIsAddToReceiveInfo.Update;
  SendItemSetIsAddToReceiveInfo.Free;
end;

procedure TSendItemSetIsAddToReceiveHandle.SetToXml;
var
  SendItemSetIsAddToReceiveXml : TSendItemSetIsAddToReceiveXml;
begin
  SendItemSetIsAddToReceiveXml := TSendItemSetIsAddToReceiveXml.Create( SendRootItemID );
  SendItemSetIsAddToReceiveXml.SetSourcePath( SourcePath );
  SendItemSetIsAddToReceiveXml.SetIsAddToReceive( IsAddToReceive );
  SendItemSetIsAddToReceiveXml.AddChange;
end;

procedure TSendItemSetIsAddToReceiveHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

function TSendSelectedNetworkItemHandle.getIsAddToScan: Boolean;
begin
  Result := False;

    // 通知接收方添加
  if SendItemInfoReadUtil.ReadIsAddToReceive( SendRootItemID, SourcePath ) then
  begin
    NetworkSendItemEvent.AddItem( SendRootItemID, SourcePath ); // 先添加
    Exit;
  end;

    // 通知接收方删除
  if SendItemInfoReadUtil.ReadIsRemoveToReceive( SendRootItemID, SourcePath ) then
  begin
    NetworkSendItemEvent.RemoveItem( SendRootItemID, SourcePath );
    Exit;
  end;

  Result := True;
end;

{ TNetworkSendItemStopHandle }

procedure TNetworkSendItemStopHandle.RemoveEvent;
begin
  NetworkSendItemEvent.RemoveItem( SendRootItemID, SourcePath );
end;

procedure TNetworkSendItemStopHandle.RemoveFace;
var
  BackupItemRemoveFace : TSendItemRemoveFace;
begin
  BackupItemRemoveFace := TSendItemRemoveFace.Create( SendRootItemID );
  BackupItemRemoveFace.SetSourcePath( SourcePath );
  BackupItemRemoveFace.AddChange;
end;

procedure TNetworkSendItemStopHandle.RemoveSendItemNow;
begin
  SendItemUserApi.RemoveNetworkItem( SendRootItemID, SourcePath );
end;

procedure TNetworkSendItemStopHandle.SetRemoveToReceive;
begin
  SendItemAppApi.SetIsRemoveToReceive( SendRootItemID, SourcePath, True );
end;

procedure TNetworkSendItemStopHandle.Update;
begin
    // 对方已经取消 或 已完成, 直接删除
  if SendItemInfoReadUtil.ReadIsReceiveCancel( SendRootItemID, SourcePath ) or
     SendItemInfoReadUtil.ReadIsCompleted( SendRootItemID, SourcePath )
  then
  begin
    RemoveSendItemNow;
    Exit;
  end;

    // 设置之 Item 属性
  SetRemoveToReceive;

    // 删除界面
  RemoveFace;

    // 用事件通知对方
  RemoveEvent;
end;

{ TWaitingSendSelectItemHandle }

procedure TWaitingSendSelectItemHandle.Update;
begin
    // 正在发送，则发送等待命令
  if MyFileSendHandler.getIsSending then
    NetworkSendItemEvent.WaitingSendItem( SendRootItemID, SourcePath )
  else  // 空闲则直接发送
    SendItemUserApi.SendSelectNetworkItem( SendRootItemID, SourcePath );
end;

{ TSendItemSetIsReceiveCancelHandle }

procedure TSendItemSetIsReceiveCancelHandle.SetIsReceiveCancel( _IsReceiveCancel : boolean );
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemSetIsReceiveCancelHandle.SetToInfo;
var
  SendItemSetIsReceiveCancelInfo : TSendItemSetIsReceiveCancelInfo;
begin
  SendItemSetIsReceiveCancelInfo := TSendItemSetIsReceiveCancelInfo.Create( SendRootItemID );
  SendItemSetIsReceiveCancelInfo.SetBackupPath( SourcePath );
  SendItemSetIsReceiveCancelInfo.SetIsReceiveCancel( IsReceiveCancel );
  SendItemSetIsReceiveCancelInfo.Update;
  SendItemSetIsReceiveCancelInfo.Free;
end;

procedure TSendItemSetIsReceiveCancelHandle.SetToXml;
var
  SendItemSetIsReceiveCancelXml : TSendItemSetIsReceiveCancelXml;
begin
  SendItemSetIsReceiveCancelXml := TSendItemSetIsReceiveCancelXml.Create( SendRootItemID );
  SendItemSetIsReceiveCancelXml.SetSourcePath( SourcePath );
  SendItemSetIsReceiveCancelXml.SetIsReceiveCancel( IsReceiveCancel );
  SendItemSetIsReceiveCancelXml.AddChange;
end;

procedure TSendItemSetIsReceiveCancelHandle.SetToFace;
var
  SendItemSetIsReceiveCancelFace : TSendItemSetIsReceiveCancelFace;
begin
  SendItemSetIsReceiveCancelFace := TSendItemSetIsReceiveCancelFace.Create( SendRootItemID );
  SendItemSetIsReceiveCancelFace.SetSourcePath( SourcePath );
  SendItemSetIsReceiveCancelFace.SetIsReceiveCancel( IsReceiveCancel );
  SendItemSetIsReceiveCancelFace.AddChange;
end;

procedure TSendItemSetIsReceiveCancelHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;




{ TBackupItemLocalCompletedHandle }

procedure TBackupItemLocalCompletedHandle.AddToHint;
var
  IsFile : Boolean;
begin
  IsFile := SendItemInfoReadUtil.ReadIsFile( SendRootItemID, SourcePath );
  MyHintAppApi.ShowSendCompleted( SourcePath, SendRootItemID, IsFile );
end;

{ TBackupItemNetworkCompletedHandle }

procedure TBackupItemNetworkCompletedHandle.AddToHint;
var
  Destinatiion : string;
  IsFile : Boolean;
begin
  Destinatiion := NetworkDesItemUtil.getPcID( SendRootItemID );
  Destinatiion := MyNetPcInfoReadUtil.ReadName( Destinatiion );
  IsFile := SendItemInfoReadUtil.ReadIsFile( SendRootItemID, SourcePath );
  MyHintAppApi.ShowSendCompleted( SourcePath, Destinatiion, IsFile );
end;

{ TSendItemSetIsDesBusyHandle }

procedure TSendItemSetIsDesBusyHandle.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TSendItemSetIsDesBusyHandle.SetToInfo;
var
  SendItemSetIsDesBusyInfo : TSendItemSetIsDesBusyInfo;
begin
  SendItemSetIsDesBusyInfo := TSendItemSetIsDesBusyInfo.Create( SendRootItemID ); 
  SendItemSetIsDesBusyInfo.SetBackupPath( SourcePath );
  SendItemSetIsDesBusyInfo.SetIsDesBusy( IsDesBusy );
  SendItemSetIsDesBusyInfo.Update;
  SendItemSetIsDesBusyInfo.Free;
end;

procedure TSendItemSetIsDesBusyHandle.SetToFace;
var
  SendItemSetIsDesBusyFace : TSendItemSetIsDesBusyFace;
begin
  SendItemSetIsDesBusyFace := TSendItemSetIsDesBusyFace.Create( SendRootItemID );
  SendItemSetIsDesBusyFace.SetSourcePath( SourcePath );
  SendItemSetIsDesBusyFace.SetIsDesBusy( IsDesBusy );
  SendItemSetIsDesBusyFace.AddChange;
end;

procedure TSendItemSetIsDesBusyHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;




{ TSendRootItemRemoveLocalHandle }

procedure TSendRootItemRemoveLocalHandle.RemoveFromFace;
var
  FrmLocalDesRemove : TFrmLocalDesRemove;
begin
  inherited;

  FrmLocalDesRemove := TFrmLocalDesRemove.Create( SendRootItemID );
  FrmLocalDesRemove.AddChange;
end;

{ TSendRootItemRemoveNetworkHandle }

procedure TSendRootItemRemoveNetworkHandle.RemoveFromFace;
var
  FrmNetworkDesRemove : TFrmNetworkDesRemove;
  FrmSendPcFilterRemove : TFrmSendPcFilterRemove;
begin
  inherited;

  FrmNetworkDesRemove := TFrmNetworkDesRemove.Create( SendRootItemID );
  FrmNetworkDesRemove.AddChange;

  FrmSendPcFilterRemove := TFrmSendPcFilterRemove.Create( SendRootItemID );
  FrmSendPcFilterRemove.AddChange;
end;

{ TSendItemErrorAddHandle }

procedure TSendItemErrorAddHandle.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TSendItemErrorAddHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendItemErrorAddHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TSendItemErrorAddHandle.AddToFace;
var
  SendItemErrorAddFace : TSendItemErrorAddFace;
begin
  SendItemErrorAddFace := TSendItemErrorAddFace.Create( SendRootItemID );
  SendItemErrorAddFace.SetSourcePath( SourcePath );
  SendItemErrorAddFace.SetFilePath( FilePath );
  SendItemErrorAddFace.SetSpaceInfo( FileSize, CompletedSpace );
  SendItemErrorAddFace.SetErrorStatus( ErrorStatus );
  SendItemErrorAddFace.AddChange;
end;

procedure TSendItemErrorAddHandle.Update;
begin
  AddToFace;
end;

{ TSendItemErrorClearHandle }

procedure TSendItemErrorClearHandle.ClearToFace;
var
  SendItemErrorClearFace : TSendItemErrorClearFace;
begin
  SendItemErrorClearFace := TSendItemErrorClearFace.Create( SendRootItemID );
  SendItemErrorClearFace.SetSourcePath( SourcePath );
  SendItemErrorClearFace.AddChange;
end;

procedure TSendItemErrorClearHandle.Update;
begin
  ClearToFace;
end;                                

{ SendErrorAppApi }

class procedure SendErrorAppApi.AddItem(Params: TSendErrorAddParams);
var
  SendItemErrorAddHandle : TSendItemErrorAddHandle;
begin
  SendItemErrorAddHandle := TSendItemErrorAddHandle.Create( Params.SendRootItemID );
  SendItemErrorAddHandle.SetSourceInfo( Params.SourcePath );
  SendItemErrorAddHandle.SetFilePath( Params.FilePath );
  SendItemErrorAddHandle.SetSpaceInfo( Params.FileSize, Params.CompletedSize );
  SendItemErrorAddHandle.SetErrorStatus( Params.ErrorStatus );
  SendItemErrorAddHandle.Update;
  SendItemErrorAddHandle.Free;
end;

class procedure SendErrorAppApi.ClearItem(DesItemID, SourcePath: string);
var
  SendItemErrorClearHandle : TSendItemErrorClearHandle;
begin
  SendItemErrorClearHandle := TSendItemErrorClearHandle.Create( DesItemID );
  SendItemErrorClearHandle.SetSourceInfo( SourcePath );
  SendItemErrorClearHandle.Update;
  SendItemErrorClearHandle.Free;
end;


class procedure SendErrorAppApi.LostConnectError(Params: TSendErrorAddParams);
begin
  Params.ErrorStatus := SendNodeStatus_LostConnectError;
  AddItem( Params );
end;

class procedure SendErrorAppApi.ReadFileError(Params: TSendErrorAddParams);
begin
  Params.ErrorStatus := SendNodeStatus_ReadFileError;
  AddItem( Params );
end;

class procedure SendErrorAppApi.SendFileError(Params: TSendErrorAddParams);
begin
  Params.ErrorStatus := SendNodeStatus_SendFileError;
  AddItem( Params );
end;

class procedure SendErrorAppApi.WriteFileError(Params: TSendErrorAddParams);
begin
  Params.ErrorStatus := SendNodeStatus_WriteFileError;
  AddItem( Params );
end;

{ TSendRootItemSetIsConnectedHandle }

procedure TSendRootItemSetIsConnectedHandle.SetIsConnected( _IsConnected : boolean );
begin
  IsConnected := _IsConnected;
end;

procedure TSendRootItemSetIsConnectedHandle.SetToFace;
var
  SendRootItemSetIsConnectedFace : TSendRootItemSetIsConnectedFace;
begin
  SendRootItemSetIsConnectedFace := TSendRootItemSetIsConnectedFace.Create( SendRootItemID );
  SendRootItemSetIsConnectedFace.SetIsConnected( IsConnected );
  SendRootItemSetIsConnectedFace.AddChange;
end;

procedure TSendRootItemSetIsConnectedHandle.Update;
begin
  SetToFace;
end;

{ SendFileHistoryApi }

class procedure SendFileHistoryApi.AddItem(SendPathList: TStringList);
var
  SendFileHistoryAddHandle : TSendFileHistoryAddHandle;
begin
  SendFileHistoryAddHandle := TSendFileHistoryAddHandle.Create( SendPathList );
  SendFileHistoryAddHandle.Update;
  SendFileHistoryAddHandle.Free;
end;

class procedure SendFileHistoryApi.ClearItem;
var
  SendFileHistoryClearHandle : TSendFileHistoryClearHandle;
begin
  SendFileHistoryClearHandle := TSendFileHistoryClearHandle.Create;
  SendFileHistoryClearHandle.Update;
  SendFileHistoryClearHandle.Free;
end;

{ TSendFileHistoryReadHandle }

constructor TSendFileHistoryReadHandle.Create(_SendPathList: TStringList);
begin
  SendPathList := _SendPathList;
end;


procedure TSendFileHistoryReadHandle.RemoveExistItem;
var
  ExistIndex : Integer;
begin
  ExistIndex := SendFileHistoryInfoReadUtil.ReadExistIndex( SendPathList );
  if ExistIndex < 0 then
    Exit;

     // 先删除已存在的
  RemoveItem( ExistIndex );
end;

procedure TSendFileHistoryReadHandle.RemoveItem(RemoveIndex: Integer);
var
  SendFileHistoryRemoveHandle : TSendFileHistoryRemoveHandle;
begin
  SendFileHistoryRemoveHandle := TSendFileHistoryRemoveHandle.Create( RemoveIndex );
  SendFileHistoryRemoveHandle.Update;
  SendFileHistoryRemoveHandle.Free;
end;

procedure TSendFileHistoryReadHandle.RemoveMaxCount;
var
  HistoryCount, RemoveIndex : Integer;
begin
  HistoryCount := SendFileHistoryInfoReadUtil.ReadHistoryCount;
  if HistoryCount < HistoryCount_Max then
    Exit;

    // 删除最后一个
  RemoveIndex := HistoryCount - 1;
  RemoveItem( RemoveIndex );
end;

procedure TSendFileHistoryReadHandle.AddToInfo;
var
  CloneSendPathList : TStringList;
  SendFileHistoryAddInfo : TSendFileHistoryAddInfo;
begin
  CloneSendPathList := MyStringList.getStrings( SendPathList );

  SendFileHistoryAddInfo := TSendFileHistoryAddInfo.Create( CloneSendPathList );
  SendFileHistoryAddInfo.Update;
  SendFileHistoryAddInfo.Free;
end;

procedure TSendFileHistoryReadHandle.AddToFace;
var
  CloneSendPathList : TStringList;
  SendFileHistoryAddFace : TSendFileHistoryAddFace;
begin
  CloneSendPathList := MyStringList.getStrings( SendPathList );

  SendFileHistoryAddFace := TSendFileHistoryAddFace.Create( CloneSendPathList );
  SendFileHistoryAddFace.AddChange;
end;

procedure TSendFileHistoryReadHandle.Update;
begin
  RemoveExistItem;
  RemoveMaxCount;
  AddToInfo;
  AddToFace;
end;

{ TSendFileHistoryAddHandle }

procedure TSendFileHistoryAddHandle.AddToXml;
var
  CloneSendPathList : TStringList;
  SendFileHistoryAddXml : TSendFileHistoryAddXml;
begin
  CloneSendPathList := MyStringList.getStrings( SendPathList );

  SendFileHistoryAddXml := TSendFileHistoryAddXml.Create( CloneSendPathList );
  SendFileHistoryAddXml.AddChange;
end;

procedure TSendFileHistoryAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TSendFileHistoryRemoveHandle }

procedure TSendFileHistoryRemoveHandle.RemoveFromInfo;
var
  SendFileHistoryRemoveInfo : TSendFileHistoryRemoveInfo;
begin
  SendFileHistoryRemoveInfo := TSendFileHistoryRemoveInfo.Create( RemoveIndex );
  SendFileHistoryRemoveInfo.Update;
  SendFileHistoryRemoveInfo.Free;
end;

constructor TSendFileHistoryRemoveHandle.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendFileHistoryRemoveHandle.RemoveFromFace;
var
  SendFileHistoryRemoveFace : TSendFileHistoryRemoveFace;
begin
  SendFileHistoryRemoveFace := TSendFileHistoryRemoveFace.Create( RemoveIndex );
  SendFileHistoryRemoveFace.AddChange;
end;

procedure TSendFileHistoryRemoveHandle.RemoveFromXml;
var
  SendFileHistoryRemoveXml : TSendFileHistoryRemoveXml;
begin
  SendFileHistoryRemoveXml := TSendFileHistoryRemoveXml.Create( RemoveIndex );
  SendFileHistoryRemoveXml.AddChange;
end;

procedure TSendFileHistoryRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;




{ TSendFileHistoryClearHandle }

procedure TSendFileHistoryClearHandle.ClearFromFace;
var
  SendFileHistoryClearFace : TSendFileHistoryClearFace;
begin
  SendFileHistoryClearFace := TSendFileHistoryClearFace.Create;
  SendFileHistoryClearFace.AddChange;
end;

procedure TSendFileHistoryClearHandle.ClearFromInfo;
var
  SendFileHistoryClearInfo : TSendFileHistoryClearInfo;
begin
  SendFileHistoryClearInfo := TSendFileHistoryClearInfo.Create;
  SendFileHistoryClearInfo.Update;
  SendFileHistoryClearInfo.Free;
end;

procedure TSendFileHistoryClearHandle.ClearFromXml;
var
  SendFileHistoryClearXml : TSendFileHistoryClearXml;
begin
  SendFileHistoryClearXml := TSendFileHistoryClearXml.Create;
  SendFileHistoryClearXml.AddChange;
end;

procedure TSendFileHistoryClearHandle.Update;
begin
  ClearFromInfo;
  ClearFromFace;
  ClearFromXml;
end;


{ TSendDesHistoryReadHandle }

constructor TSendDesHistoryReadHandle.Create(_SendDesList: TStringList);
begin
  SendDesList := _SendDesList;
end;


procedure TSendDesHistoryReadHandle.RemoveExistItem;
var
  ExistIndex : Integer;
begin
  ExistIndex := SendDesHistoryInfoReadUtil.ReadExistIndex( SendDesList );
  if ExistIndex < 0 then
    Exit;

     // 先删除已存在的
  RemoveItem( ExistIndex );
end;

procedure TSendDesHistoryReadHandle.RemoveItem(RemoveIndex: Integer);
var
  SendDesHistoryRemoveHandle : TSendDesHistoryRemoveHandle;
begin
  SendDesHistoryRemoveHandle := TSendDesHistoryRemoveHandle.Create( RemoveIndex );
  SendDesHistoryRemoveHandle.Update;
  SendDesHistoryRemoveHandle.Free;
end;

procedure TSendDesHistoryReadHandle.RemoveMaxCount;
var
  HistoryCount, RemoveIndex : Integer;
begin
  HistoryCount := SendDesHistoryInfoReadUtil.ReadHistoryCount;
  if HistoryCount < HistoryCount_Max then
    Exit;

    // 删除最后一个
  RemoveIndex := HistoryCount - 1;
  RemoveItem( RemoveIndex );
end;

procedure TSendDesHistoryReadHandle.AddToInfo;
var
  CloneSendPathList : TStringList;
  SendDesHistoryAddInfo : TSendDesHistoryAddInfo;
begin
  CloneSendPathList := MyStringList.getStrings( SendDesList );

  SendDesHistoryAddInfo := TSendDesHistoryAddInfo.Create( CloneSendPathList );
  SendDesHistoryAddInfo.Update;
  SendDesHistoryAddInfo.Free;
end;

procedure TSendDesHistoryReadHandle.AddToFace;
var
  CloneSendPathList : TStringList;
  SendDesHistoryAddFace : TSendDesHistoryAddFace;
  i: Integer;
begin
  CloneSendPathList := MyStringList.getStrings( SendDesList );
  for i := 0 to CloneSendPathList.Count - 1 do
    CloneSendPathList[i] := MyNetPcInfoReadUtil.ReadDesItemShow( CloneSendPathList[i] );

  SendDesHistoryAddFace := TSendDesHistoryAddFace.Create( CloneSendPathList );
  SendDesHistoryAddFace.AddChange;
end;

procedure TSendDesHistoryReadHandle.Update;
begin
  RemoveExistItem;
  RemoveMaxCount;
  AddToInfo;
  AddToFace;
end;

{ TSendDesHistoryAddHandle }

procedure TSendDesHistoryAddHandle.AddToXml;
var
  CloneSendPathList : TStringList;
  SendDesHistoryAddXml : TSendDesHistoryAddXml;
begin
  CloneSendPathList := MyStringList.getStrings( SendDesList );

  SendDesHistoryAddXml := TSendDesHistoryAddXml.Create( CloneSendPathList );
  SendDesHistoryAddXml.AddChange;
end;

procedure TSendDesHistoryAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TSendDesHistoryRemoveHandle }

procedure TSendDesHistoryRemoveHandle.RemoveFromInfo;
var
  SendDesHistoryRemoveInfo : TSendDesHistoryRemoveInfo;
begin
  SendDesHistoryRemoveInfo := TSendDesHistoryRemoveInfo.Create( RemoveIndex );
  SendDesHistoryRemoveInfo.Update;
  SendDesHistoryRemoveInfo.Free;
end;

constructor TSendDesHistoryRemoveHandle.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendDesHistoryRemoveHandle.RemoveFromFace;
var
  SendDesHistoryRemoveFace : TSendDesHistoryRemoveFace;
begin
  SendDesHistoryRemoveFace := TSendDesHistoryRemoveFace.Create( RemoveIndex );
  SendDesHistoryRemoveFace.AddChange;
end;

procedure TSendDesHistoryRemoveHandle.RemoveFromXml;
var
  SendDesHistoryRemoveXml : TSendDesHistoryRemoveXml;
begin
  SendDesHistoryRemoveXml := TSendDesHistoryRemoveXml.Create( RemoveIndex );
  SendDesHistoryRemoveXml.AddChange;
end;

procedure TSendDesHistoryRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;




{ TSendDesHistoryClearHandle }

procedure TSendDesHistoryClearHandle.ClearFromFace;
var
  SendDesHistoryClearFace : TSendDesHistoryClearFace;
begin
  SendDesHistoryClearFace := TSendDesHistoryClearFace.Create;
  SendDesHistoryClearFace.AddChange;
end;

procedure TSendDesHistoryClearHandle.ClearFromInfo;
var
  SendDesHistoryClearInfo : TSendDesHistoryClearInfo;
begin
  SendDesHistoryClearInfo := TSendDesHistoryClearInfo.Create;
  SendDesHistoryClearInfo.Update;
  SendDesHistoryClearInfo.Free;
end;

procedure TSendDesHistoryClearHandle.ClearFromXml;
var
  SendDesHistoryClearXml : TSendDesHistoryClearXml;
begin
  SendDesHistoryClearXml := TSendDesHistoryClearXml.Create;
  SendDesHistoryClearXml.AddChange;
end;

procedure TSendDesHistoryClearHandle.Update;
begin
  ClearFromInfo;
  ClearFromFace;
  ClearFromXml;
end;


{ SendDesHistoryApi }

class procedure SendDesHistoryApi.AddItem(SendDesList: TStringList);
var
  SendDesHistoryAddHandle : TSendDesHistoryAddHandle;
begin
  SendDesHistoryAddHandle := TSendDesHistoryAddHandle.Create( SendDesList );
  SendDesHistoryAddHandle.Update;
  SendDesHistoryAddHandle.Free;
end;

class procedure SendDesHistoryApi.ClearItem;
var
  SendDesHistoryClearHandle : TSendDesHistoryClearHandle;
begin
  SendDesHistoryClearHandle := TSendDesHistoryClearHandle.Create;
  SendDesHistoryClearHandle.Update;
  SendDesHistoryClearHandle.Free;
end;

{ TSendItemSetAnalyizeHandle }

procedure TSendItemSetAnalyizeHandle.AddToHint;
var
  Destination : string;
  IsFile : Boolean;
begin
  Destination := NetworkDesItemUtil.getPcID( SendRootItemID );
  Destination := MyNetPcInfoReadUtil.ReadName( Destination );
  IsFile := SendItemInfoReadUtil.ReadIsFile( SendRootItemID, SourcePath );
  MyHintAppApi.ShowSending( SourcePath, Destination, IsFile );
end;

procedure TSendItemSetAnalyizeHandle.Update;
begin
    // 重置统计数
  SendItemAppApi.SetScaningCount( SendRootItemID, SourcePath, 0 );

    // 设置显示状态
  SendItemAppApi.SetBackupItemStatus( SendRootItemID, SourcePath, SendNodeStatus_Analyizing );

    // 显示 Hint
  AddToHint;
end;

{ TSendFileContinuseHandle }

procedure TSendFileContinuseHandle.Update;
var
  SendRootList : TStringList;
  i: Integer;
  SendPcID : string;
begin
  SendRootList := SendRootItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to SendRootList.Count - 1 do
  begin
    SendPcID := NetworkDesItemUtil.getPcID( SendRootList[i] );
    if not MyNetPcInfoReadUtil.ReadIsOnline( SendPcID ) then
      Continue;
    SendItemAppApi.PcOnlineSend( SendPcID );
  end;
  SendRootList.Free;
end;

{ TSendFilePauseHandle }

procedure TSendFilePauseHandle.SetToFace;
var
  PauseBackupFace : TPauseBackupFace;
begin
  PauseBackupFace := TPauseBackupFace.Create;
  PauseBackupFace.AddChange;
end;

procedure TSendFilePauseHandle.Update;
begin
  UserTransfer_IsStop := True; // 标记暂停传输

  SetToFace;
end;

{ TBackupSpeedLimitHandle }

procedure TBackupSpeedLimitHandle.SetToXml;
var
  BackupSpeedLimitXml : TBackupSpeedLimitXml;
begin
  BackupSpeedLimitXml := TBackupSpeedLimitXml.Create;
  BackupSpeedLimitXml.SetIsLimit( IsLimit );
  BackupSpeedLimitXml.SetLimitXml( LimitValue, LimitType );
  BackupSpeedLimitXml.AddChange;
end;

procedure TBackupSpeedLimitHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupSpeedLimitReadHandle }


constructor TBackupSpeedLimitReadHandle.Create(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitReadHandle.SetLimitInfo(_LimitType,
  _LimitValue: Integer);
begin
  LimitType := _LimitType;
  LimitValue := _LimitValue;
end;

procedure TBackupSpeedLimitReadHandle.SetToFace;
var
  BackupSpeedLimitFace : TBackupSpeedLimitFace;
  LimitSpeed : Int64;
begin
  LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;

  BackupSpeedLimitFace := TBackupSpeedLimitFace.Create;
  BackupSpeedLimitFace.SetIsLimit( IsLimit );
  BackupSpeedLimitFace.SetLimitSpeed( LimitSpeed );
  BackupSpeedLimitFace.AddChange;
end;

procedure TBackupSpeedLimitReadHandle.SetToInfo;
var
  BackupSpeedLimitInfo : TSendSpeedLimitInfo;
begin
  BackupSpeedLimitInfo := TSendSpeedLimitInfo.Create;
  BackupSpeedLimitInfo.SetIsLimit( IsLimit );
  BackupSpeedLimitInfo.SetLimitInfo( LimitValue, LimitType );
  BackupSpeedLimitInfo.Update;
  BackupSpeedLimitInfo.Free;
end;

procedure TBackupSpeedLimitReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ BackupSpeedInfoReadUtil }

class function BackupSpeedInfoReadUtil.getIsLimit: Boolean;
begin
  Result := MySendInfo.SendSpeedInfo.IsLimit;
end;

class function BackupSpeedInfoReadUtil.getLimitSpeed: Int64;
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

class function BackupSpeedInfoReadUtil.getLimitType: Integer;
begin
  Result := MySendInfo.SendSpeedInfo.LimitType;
end;

class function BackupSpeedInfoReadUtil.getLimitValue: Integer;
begin
  Result := MySendInfo.SendSpeedInfo.LimitValue;
end;

class procedure SendFileSpeedApi.SetLimit(IsLimit : Boolean;
  LimitType, LimitValue: Integer);
var
  BackupSpeedLimitHandle : TBackupSpeedLimitHandle;
begin
  BackupSpeedLimitHandle := TBackupSpeedLimitHandle.Create( IsLimit );
  BackupSpeedLimitHandle.SetLimitInfo( LimitType, LimitValue );
  BackupSpeedLimitHandle.Update;
  BackupSpeedLimitHandle.Free;
end;

{ TSendItemSetCompressHandle }

procedure TSendItemSetCompressHandle.SetCompressCount(_CompressCount: Integer);
begin
  CompressCount := _CompressCount;
end;

procedure TSendItemSetCompressHandle.SetToFace;
var
  SendItemSetCompressFace : TSendItemSetCompressFace;
begin
  SendItemSetCompressFace := TSendItemSetCompressFace.Create( SendRootItemID );
  SendItemSetCompressFace.SetSourcePath( SourcePath );
  SendItemSetCompressFace.SetCompressCount( CompressCount );
  SendItemSetCompressFace.AddChange;
end;

procedure TSendItemSetCompressHandle.Update;
begin
  SetToFace;
end;

{ TSendItemSetIsSendAgainHandle }

procedure TSendItemSetIsLostConnHandle.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TSendItemSetIsLostConnHandle.SetToInfo;
var
  SendItemSetIsSendAgainInfo : TSendItemSetIsLostConnInfo;
begin
  SendItemSetIsSendAgainInfo := TSendItemSetIsLostConnInfo.Create( SendRootItemID );
  SendItemSetIsSendAgainInfo.SetBackupPath( SourcePath );
  SendItemSetIsSendAgainInfo.SetIsLostConn( IsLostConn );
  SendItemSetIsSendAgainInfo.Update;
  SendItemSetIsSendAgainInfo.Free;
end;

procedure TSendItemSetIsLostConnHandle.Update;
begin
  SetToInfo;
end;

{ TBackupLogWriteHandle }

procedure TBackupLogWriteHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupLogCompletedReadHandle }

procedure TBackupLogCompletedReadHandle.AddToInfo;
var
  BackupLogAddCompletedLogInfo : TSendAddCompletedLogInfo;
begin
  BackupLogAddCompletedLogInfo := TSendAddCompletedLogInfo.Create( SendRootItemID );
  BackupLogAddCompletedLogInfo.SetBackupPath( SourcePath );
  BackupLogAddCompletedLogInfo.SetFilePath( FilePath );
  BackupLogAddCompletedLogInfo.SetSendTime( BackupTime );
  BackupLogAddCompletedLogInfo.Update;
  BackupLogAddCompletedLogInfo.Free;
end;

procedure TBackupLogCompletedReadHandle.SetBackupTime(_BackupTime: TDateTime);
begin
  BackupTime := _BackupTime;
end;

procedure TBackupLogCompletedReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupLogCompletedAddHandle }

procedure TBackupLogCompletedAddHandle.AddToXml;
var
  BackupLogAddCompletedXml : TSendLogAddCompletedXml;
begin
  BackupLogAddCompletedXml := TSendLogAddCompletedXml.Create( SendRootItemID );
  BackupLogAddCompletedXml.SetSourcePath( SourcePath );
  BackupLogAddCompletedXml.SetFilePath( FilePath );
  BackupLogAddCompletedXml.SetSendTime( BackupTime );
  BackupLogAddCompletedXml.AddChange;
end;

procedure TBackupLogCompletedAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupLogIncompletedReadHandle }

procedure TBackupLogIncompletedReadHandle.AddToInfo;
var
  BackupLogAddIncompletedLogInfo : TSendAddIncompletedLogInfo;
begin
  BackupLogAddIncompletedLogInfo := TSendAddIncompletedLogInfo.Create( SendRootItemID );
  BackupLogAddIncompletedLogInfo.SetBackupPath( SourcePath );
  BackupLogAddIncompletedLogInfo.SetFilePath( FilePath );
  BackupLogAddIncompletedLogInfo.Update;
  BackupLogAddIncompletedLogInfo.Free;
end;

procedure TBackupLogIncompletedReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupLogIncompletedAddHandle }

procedure TBackupLogIncompletedAddHandle.AddToXml;
var
  BackupLogAddIncompletedXml : TSendLogAddIncompletedXml;
begin
  BackupLogAddIncompletedXml := TSendLogAddIncompletedXml.Create( SendRootItemID );
  BackupLogAddIncompletedXml.SetSourcePath( SourcePath );
  BackupLogAddIncompletedXml.SetFilePath( FilePath );
  BackupLogAddIncompletedXml.AddChange;
end;

procedure TBackupLogIncompletedAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TBackupLogClearIncompletedHandle.ClearFace;
begin

end;

procedure TBackupLogClearIncompletedHandle.ClearInfo;
var
  BackupLogClearIncompletedInfo : TSendClearIncompletedLogInfo;
begin
  BackupLogClearIncompletedInfo := TSendClearIncompletedLogInfo.Create( SendRootItemID );
  BackupLogClearIncompletedInfo.SetBackupPath( SourcePath );
  BackupLogClearIncompletedInfo.Update;
  BackupLogClearIncompletedInfo.Free;
end;

procedure TBackupLogClearIncompletedHandle.ClearXml;
var
  BackupLogClearIncompletedXml : TSendLogClearIncompletedXml;
begin
  BackupLogClearIncompletedXml := TSendLogClearIncompletedXml.Create( SendRootItemID );
  BackupLogClearIncompletedXml.SetSourcePath( SourcePath );
  BackupLogClearIncompletedXml.AddChange;
end;

procedure TBackupLogClearIncompletedHandle.Update;
begin
  ClearInfo;
  ClearXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TBackupLogClearCompletedHandle.ClearFace;
begin

end;

procedure TBackupLogClearCompletedHandle.ClearInfo;
var
  BackupLogClearCompletedInfo : TSendClearCompletedLogInfo;
begin
  BackupLogClearCompletedInfo := TSendClearCompletedLogInfo.Create( SendRootItemID );
  BackupLogClearCompletedInfo.SetBackupPath( SourcePath );
  BackupLogClearCompletedInfo.Update;
  BackupLogClearCompletedInfo.Free;
end;

procedure TBackupLogClearCompletedHandle.ClearXml;
var
  BackupLogClearCompletedXml : TSendLogClearCompletedXml;
begin
  BackupLogClearCompletedXml := TSendLogClearCompletedXml.Create( SendRootItemID );
  BackupLogClearCompletedXml.SetSourcePath( SourcePath );
  BackupLogClearCompletedXml.AddChange;
end;

procedure TBackupLogClearCompletedHandle.Update;
begin
  ClearInfo;
  ClearXml;
end;

class procedure SendLogApi.AddCompleted(Prams: TSendLogAddParams);
var
  BackupLogCompletedAddHandle : TBackupLogCompletedAddHandle;
begin
  BackupLogCompletedAddHandle := TBackupLogCompletedAddHandle.Create( Prams.SendRootItemID );
  BackupLogCompletedAddHandle.SetSourceInfo( Prams.SourcePath );
  BackupLogCompletedAddHandle.SetFilePath( Prams.FilePath );
  BackupLogCompletedAddHandle.SetBackupTime( Prams.SendTime );
  BackupLogCompletedAddHandle.Update;
  BackupLogCompletedAddHandle.Free;
end;

class procedure SendLogApi.AddIncompleted(Prams: TSendLogAddParams);
var
  BackupLogIncompletedAddHandle : TBackupLogIncompletedAddHandle;
begin
  BackupLogIncompletedAddHandle := TBackupLogIncompletedAddHandle.Create( Prams.SendRootItemID );
  BackupLogIncompletedAddHandle.SetSourceInfo( Prams.SourcePath );
  BackupLogIncompletedAddHandle.SetFilePath( Prams.FilePath );
  BackupLogIncompletedAddHandle.Update;
  BackupLogIncompletedAddHandle.Free;
end;



class procedure SendLogApi.ClearCompleted( DesItemID, BackupPath : string );
var
  BackupLogClearCompletedHandle : TBackupLogClearCompletedHandle;
begin
  BackupLogClearCompletedHandle := TBackupLogClearCompletedHandle.Create( DesItemID );
  BackupLogClearCompletedHandle.SetSourceInfo( BackupPath );
  BackupLogClearCompletedHandle.Update;
  BackupLogClearCompletedHandle.Free;
end;

class procedure SendLogApi.ClearIncompleted( DesItemID, BackupPath : string );
var
  BackupLogClearIncompletedHandle : TBackupLogClearIncompletedHandle;
begin
  BackupLogClearIncompletedHandle := TBackupLogClearIncompletedHandle.Create( DesItemID );
  BackupLogClearIncompletedHandle.SetSourceInfo( BackupPath );
  BackupLogClearIncompletedHandle.Update;
  BackupLogClearIncompletedHandle.Free;
end;

class procedure SendLogApi.RefreshLogFace(DesItemID, SourcePath: string);
var
  CompletedLogList : TSendCompletedLogList;
  InCompletedLogList : TSendIncompletedLogList;
  i: Integer;
begin
    // 清空旧的
  frmSendLog.ClearItems;

    // 添加已完成的
  CompletedLogList := SendItemInfoReadUtil.ReadCompletedLogList( DesItemID, SourcePath );
  for i := 0 to CompletedLogList.Count - 1 do
    frmSendLog.AddCompleted( CompletedLogList[i].FilePath, CompletedLogList[i].SendTime );
  CompletedLogList.Free;

    // 添加未完成的
  IncompletedLogList := SendItemInfoReadUtil.ReadIncompletedLogList( DesItemID, SourcePath );
  for i := 0 to IncompletedLogList.Count - 1 do
    frmSendLog.AddIncompleted( IncompletedLogList[i].FilePath );
  IncompletedLogList.Free;
end;

{ TSendItemSetLastSendTimeHandle }

procedure TSendItemSetLastSendTimeHandle.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemSetLastSendTimeHandle.SetToFace;
var
  SendItemSetLastSendTimeFace : TSendItemSetLastSendTimeFace;
begin
  SendItemSetLastSendTimeFace := TSendItemSetLastSendTimeFace.Create( SendRootItemID );
  SendItemSetLastSendTimeFace.SetSourcePath( SourcePath );
  SendItemSetLastSendTimeFace.SetLastSendTime( LastSendTime );
  SendItemSetLastSendTimeFace.AddChange;
end;

procedure TSendItemSetLastSendTimeHandle.SetToInfo;
var
  SendItemSetLastSendTimeInfo : TSendItemSetLastSendTimeInfo;
begin
  SendItemSetLastSendTimeInfo := TSendItemSetLastSendTimeInfo.Create( SendRootItemID );
  SendItemSetLastSendTimeInfo.SetBackupPath( SourcePath );
  SendItemSetLastSendTimeInfo.SetLastSendTime( LastSendTime );
  SendItemSetLastSendTimeInfo.Update;
  SendItemSetLastSendTimeInfo.Free;
end;

procedure TSendItemSetLastSendTimeHandle.SetToXml;
var
  SendItemSetLastSendTimeXml : TSendItemSetLastSendTimeXml;
begin
  SendItemSetLastSendTimeXml := TSendItemSetLastSendTimeXml.Create( SendRootItemID );
  SendItemSetLastSendTimeXml.SetSourcePath( SourcePath );
  SendItemSetLastSendTimeXml.SetLastSendTime( LastSendTime );
  SendItemSetLastSendTimeXml.AddChange;
end;

procedure TSendItemSetLastSendTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TSendItemSetScheduleHandle }

procedure TSendItemSetScheduleHandle.SetScheduleType(_ScheduleType: Integer);
begin
  ScheduleType := _ScheduleType;
end;

procedure TSendItemSetScheduleHandle.SetScheduleValue(_ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemSetScheduleHandle.SetToFace;
var
  SendItemSetScheduleFace : TSendItemSetScheduleFace;
begin
  SendItemSetScheduleFace := TSendItemSetScheduleFace.Create( SendRootItemID );
  SendItemSetScheduleFace.SetSourcePath( SourcePath );
  SendItemSetScheduleFace.SetSchduleType( ScheduleType );
  SendItemSetScheduleFace.SetSchduleValue( ScheduleValue1, ScheduleValue2 );
  SendItemSetScheduleFace.AddChange;
end;

procedure TSendItemSetScheduleHandle.SetToInfo;
var
  SendItemSetScheduleInfo : TSendItemSetScheduleInfo;
begin
  SendItemSetScheduleInfo := TSendItemSetScheduleInfo.Create( SendRootItemID );
  SendItemSetScheduleInfo.SetBackupPath( SourcePath );
  SendItemSetScheduleInfo.SetSchduleType( ScheduleType );
  SendItemSetScheduleInfo.SetSchduleValue( ScheduleValue1, ScheduleValue2 );
  SendItemSetScheduleInfo.Update;
  SendItemSetScheduleInfo.Free;
end;


procedure TSendItemSetScheduleHandle.SetToXml;
var
  SendItemSetScheduleXml : TSendItemSetScheduleXml;
begin
  SendItemSetScheduleXml := TSendItemSetScheduleXml.Create( SendRootItemID );
  SendItemSetScheduleXml.SetSourcePath( SourcePath );
  SendItemSetScheduleXml.SetSchduleType( ScheduleType );
  SendItemSetScheduleXml.SetSchduleValue( ScheduleValue1, ScheduleValue2 );
  SendItemSetScheduleXml.AddChange;
end;


procedure TSendItemSetScheduleHandle.Update;
begin
  SetToInfo;
  SetToXml;
  SetToFace;
end;

end.
