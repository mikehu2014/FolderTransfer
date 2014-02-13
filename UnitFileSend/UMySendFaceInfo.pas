unit UMySendFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UMyUtil, DateUtils, Vcl.ComCtrls, SysUtils, menus, classes;

type

{$Region ' 数据结构 ' }

  TFileSendData = record
  public
    ItemID : WideString;
    IsFile, IsCompleted : Boolean;
    IsSending : Boolean;
    IsReceiveCancel, IsZip : Boolean;
    SavePath, ZipPath : WideString;
  public   // 备份状态
    IsWrite, IsLackSpace, IsOnline, IsConnected : Boolean;  // 目标状态
    IsExist : Boolean; // 目标和源 状态
    IsDesBusy : Boolean; // 目标是否繁忙
    AvailableSpace : Int64; // 可用空间
  public  // 过滤
    IncludeFilterStr : WideString;
    ExcludeFilterStr : WideString;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
    Percentage : Integer;
    AnalyizeCount, CompressCount : Integer; // 分析文件数, 压缩文件数
    Speed : Int64; // 传输速度
    ShowStatusType : WideString; // 显示状态类型
  public  // 定时发送
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
    LastSendTime : TDateTime;
    NextSendTimeStr : WideString;
  public
    MainName, DesName : WideString;
    NodeType, NodeStatus : WideString;
    MainIcon : Integer;
  end;
  PVstSendData = ^TFileSendData;

{$EndRegion}

{$Region ' 备份信息 数据修改 ' }

  {$Region ' 接收路径 增删 ' }

  TSendRootItemChangeFace = class( TFaceChangeInfo )
  public
    VstFileSend : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改 目标路径
  TSendRootItemWriteFace = class( TSendRootItemChangeFace )
  public
    SendRootItemID : string;
  protected
    SendRootItemNode : PVirtualNode;
    SendRootItemData : PVstSendData;
  public
    constructor Create( _SendRootItemID : string );
  protected
    function FindSendRootItemNode : Boolean;
    procedure RefreshDesNode;
  end;

    // 添加 父类
  TSendRootItemAddFace = class( TSendRootItemWriteFace )
  protected
    AvailableSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  protected
    procedure CreateItemInfo;virtual;abstract;
    procedure AddItemInfo;virtual;abstract;
    procedure AddUpgradeItemInfo;virtual;
  end;

    // 添加 本地目标
  TSendRootItemAddLocalFace = class( TSendRootItemAddFace )
  protected
    procedure CreateItemInfo;override;
    procedure AddItemInfo;override;
  private
    function getFirstNetworkNode : PVirtualNode;
  end;

    // 添加 网络目标
  TSendRootItemAddNetworkFace = class( TSendRootItemAddFace )
  private
    PcName, DesName : string;
    IsOnline : Boolean;
    IsLan : Boolean;
  public
    procedure SetPcName( _PcName : string );
    procedure SetDesName( _DesName : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure CreateItemInfo;override;
    procedure AddItemInfo;override;
    procedure AddUpgradeItemInfo;override;
  private
    function getSameNameLastNode : PVirtualNode;
    function getLastOnlineNode : PVirtualNode;
  end;

    // 修改
  TSendRootItemSetAvailableSpaceFace = class( TSendRootItemWriteFace )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TSendRootItemRemoveFace = class( TSendRootItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 接收路径 状态 ' }

    // 修改 路径是否存在
  TSendRootItemSetIsExistFace = class( TSendRootItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 路径是否可写
  TSendRootItemSetIsWriteFace = class( TSendRootItemWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 目标路径是否缺少备份空间
  TSendRootItemSetIsLackSpaceFace = class( TSendRootItemWriteFace )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 是否可连接
  TSendRootItemSetIsConnectedFace = class( TSendRootItemWriteFace )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
  protected
    procedure Update;override;
  end;


    // 上线/离线
  TSendRootItemSetPcIsOnlineFace = class( TSendRootItemChangeFace )
  public
    DesPcID : string;
    IsOnline : Boolean;
    IsLan : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure Update;override;
  private
    function getLastOnlineNode : PVirtualNode;
  end;

  {$EndRegion}

  {$Region ' 接收路径 辅助类 ' }

  DesItemFaceUtil = class
  public
    class function ReadPcIcon( IsOnline, IsLan : Boolean ): Integer;
  end;

  {$EndRegion}


  {$Region ' 发送路径 增删 ' }

    // 修改 源路径
  TSendItemWriteFace = class( TSendRootItemWriteFace )
  protected
    SourcePath : string;
  protected
    SendItemNode : PVirtualNode;
    SendItemData : PVstSendData;
  public
    procedure SetSourcePath( _SourcePath : string );
  protected
    function FindSendItemNode : Boolean;
    procedure RefreshSendNode;
  protected
    procedure RefreshPercentage;
    procedure RefreshNextSchedule;
  end;

    // 添加 源路径
  TSendItemAddFace = class( TSendItemWriteFace )
  public
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
  protected
    procedure Update;override;
  protected
    procedure AddItemInfo;virtual;
  end;

    // 添加 本地
  TSendItemAddLocalFace = class( TSendItemAddFace )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络
  TSendITemAddNetworkFace = class( TSendItemAddFace )
  public
    IsReceiveCancel : Boolean; // 是否接收方已经取消
  public
    procedure SetIsReceiveCancel( _IsReceiveCancel : Boolean );
  protected
    procedure AddItemInfo;override;
  end;

    // 删除 源路径
  TSendItemRemoveFace = class( TSendItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 发送路径 状态 ' }

    // 修改 是否存在
  TSendItemSetIsExistFace = class( TSendItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetStatusFace = class( TSendItemWriteFace )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetSpeedFace = class( TSendItemWriteFace )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetCompressFace = class( TSendItemWriteFace )
  public
    CompressCount : Integer;
  public
    procedure SetCompressCount( _CompressCount : Integer );
  protected
    procedure Update;override;
  end;

      // 修改
  TSendItemSetAnalyizeCountFace = class( TSendItemWriteFace )
  public
    AnalyizeCount : integer;
  public
    procedure SetAnalyizeCount( _AnalyizeCount : integer );
  protected
    procedure Update;override;
  end;

      // 修改
  TSendItemSetIsCompletedFace = class( TSendItemWriteFace )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsBackupingFace = class( TSendItemWriteFace )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsReceiveCancelFace = class( TSendItemWriteFace )
  public
    IsReceiveCancel : boolean;
  public
    procedure SetIsReceiveCancel( _IsReceiveCancel : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsDesBusyFace = class( TSendItemWriteFace )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 发送路径 自动发送 ' }

      // 添加 已完成信息
  TSendItemSetLastSendTimeFace = class( TSendItemWriteFace )
  public
    LastSendTime : TDateTime;
  public
    procedure SetLastSendTime( _LastSendTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TSendItemSetScheduleFace = class( TSendItemWriteFace )
  private
    SchduleType : Integer;
    SchduleValue1, SchduleValue2 : Integer;
  public
    procedure SetSchduleType( _SchduleType : Integer );
    procedure SetSchduleValue( _SchduleValue1, _SchduleValue2 : Integer );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 发送路径 过滤信息 ' }

       // 修改
  TSendItemSetIncludeFilterFace = class( TSendItemWriteFace )
  public
    IncludeFilterStr : string;
  public
    procedure SetIncludeFilterStr( _IncludeFilterStr : string );
  protected
    procedure Update;override;
  end;

       // 修改
  TSendItemSetExcludeFilterFace = class( TSendItemWriteFace )
  public
    ExcludeFilterStr : string;
  public
    procedure SetExcludeFilterStr( _ExcludeFilterStr : string );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 发送路径 空间信息 ' }

   // 设置 空间信息
  TSendItemSetSpaceInfoFace = class( TSendItemWriteFace )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TSendItemSetAddCompletedSpaceFace = class( TSendItemWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 发送路径 错误信息 ' }

    // 添加 错误
  TSendItemErrorAddFace = class( TSendItemWriteFace )
  public
    FilePath : string;
    FileSize, CompletedSpace : Int64;
    ErrorStatus : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetErrorStatus( _ErrorStatus : string );
  protected
    procedure Update;override;
  end;

    // 清空 错误
  TSendItemErrorClearFace = class( TSendItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 选择窗口 数据修改 ' }

  {$Region ' 本地目标路径 ' }

  TLocalDesData = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
  end;

    // 父类
  TFrmLocalDesChange = class( TFaceChangeInfo )
  public
    LvDes : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TFrmLocalDesWrite = class( TFrmLocalDesChange )
  public
    DesPath : string;
  protected
    DesIndex : Integer;
    DesItem : TListItem;
    DesData : TLocalDesData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
  end;

    // 读取
  TFrmLocalDesAdd = class( TFrmLocalDesWrite )
  private
    AvailableSpace : Int64;
    IsSelect : Boolean;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure SetIsSelect( _IsSelect : Boolean );
  protected
    procedure Update;override;
  end;

      // 设置可用空间
  TFrmLocalSetAvailableSpace = class( TFrmLocalDesWrite )
  public
    AvaialbleSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TFrmLocalDesRemove = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 网络目标路径 ' }

  TNetworkDesData = record
  public
    DesItemID, DesItemName : WideString;
    IsOnline : Boolean;
    MainIcon : Integer;
    AvailaleSpace : Int64;
  public
    MainName, DesName : WideString;
  end;
  PNetworkDesData = ^TNetworkDesData;

    // 父类
  TFrmNetworkDesChange = class( TFaceChangeInfo )
  public
    vstNetworkDes : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 设置上线状态
  TFrmNetworkDesIsOnline = class( TFrmNetworkDesChange )
  public
    DesPcID : string;
    IsOnline : Boolean;
    IsLan : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure Update;override;
  private
    function getLastOnlineNode : PVirtualNode;
  end;

    // 修改
  TFrmNetworkDesWrite = class( TFrmNetworkDesChange )
  public
    DesItemID : string;
  protected
    NetworkDesNode : PVirtualNode;
    NetworkDesData : PNetworkDesData;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindNetworkDesItemNode : Boolean;
  end;

    // 添加
  TFrmNetworkDesAdd = class( TFrmNetworkDesWrite )
  public
    PcName : string;
    IsOnline : Boolean;
    IsLan : Boolean;
    AvailableSpace : Int64;
    MainName, DesName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure SetNameInfo( _MainName, _DesName : string );
  protected
    procedure Update;override;
  private
    procedure CreateDesNode;
    function getSameNameLastNode : PVirtualNode;
    function getLastOnlineNode : PVirtualNode;
  end;

    // 设置可用空间
  TFrmNetworkSetAvailableSpace = class( TFrmNetworkDesWrite )
  public
    AvaialbleSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TFrmNetworkDesRemove = class( TFrmNetworkDesWrite )
  protected
    procedure Update;override;
  end;

    // 读取图标
  FrmNetworkDesUtil = class
  public
    class function ReadIcon( IsOnline, IsLan : Boolean ): Integer;
    class function ReadFilterIcon( IsOnline : Boolean ): Integer;
    class function ReadHeight( IsOnline : Boolean ): Integer;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 显示发送Pc过滤窗口 ' }

  TSendPcFilterData = record
  public
    DesItemID, ComputerName, Directory : WideString;
    IsOnline : Boolean;
    MainIcon : Integer;
  end;
  PSendPcFilterData = ^TSendPcFilterData;

    // 父类
  TFrmSendPcFilterChange = class( TFaceChangeInfo )
  public
    vstSendPcFilter : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 设置上线状态
  TFrmSendPcFilterIsOnline = class( TFrmSendPcFilterChange )
  public
    DesPcID : string;
    IsOnline : Boolean;
    IsLan : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure Update;override;
  private
    function getLastOnlineNode : PVirtualNode;
  end;

    // 修改
  TFrmSendPcFilterWrite = class( TFrmSendPcFilterChange )
  public
    DesItemID : string;
  protected
    SendPcFilterNode : PVirtualNode;
    SendPcFilterData : PSendPcFilterData;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindSendPcFilterItemNode : Boolean;
  end;

    // 添加
  TFrmSendPcFilterAdd = class( TFrmSendPcFilterWrite )
  public
    PcName, Directory : string;
    IsOnline : Boolean;
    IsLan : Boolean;
  public
    procedure SetPcName( _PcName : string );
    procedure SetDirectory( _Directory : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure Update;override;
  private
    procedure CreateDesNode;
    function getSameNameLastNode : PVirtualNode;
    function getLastOnlineNode : PVirtualNode;
  end;

    // 删除
  TFrmSendPcFilterRemove = class( TFrmSendPcFilterWrite )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 速度信息 ' }

      // 速度限制
  TBackupSpeedLimitFace = class( TFaceChangeInfo )
  public
    IsLimit : Boolean;
    LimitSpeed : Int64;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitSpeed( _LimitSpeed : Int64 );
  protected
    procedure Update;override;
  end;

{$EndRegion}


{$Region ' 发送文件历史 数据修改 ' }

    // 父类
  TSendFileHistoryChangeFace = class( TFaceChangeInfo )
  public
    PmSendFileHistory : TPopupMenu;
  protected
    procedure Update;override;
  end;

    // 添加
  TSendFileHistoryAddFace = class( TSendFileHistoryChangeFace )
  public
    SendPathList : TStringList;
  public
    constructor Create( _SendPathList : TStringList );
    procedure Update;override;
    destructor Destroy; override;
  end;

    // 删除
  TSendFileHistoryRemoveFace = class( TSendFileHistoryChangeFace )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;override;
  end;

    // 清空
  TSendFileHistoryClearFace = class( TSendFileHistoryChangeFace )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 发送目标历史 数据修改 ' }

    // 父类
  TSendDesHistoryChangeFace = class( TFaceChangeInfo )
  public
    PmSendDesHistory : TPopupMenu;
  protected
    procedure Update;override;
  end;

    // 添加
  TSendDesHistoryAddFace = class( TSendDesHistoryChangeFace )
  public
    SendDesList : TStringList;
  public
    constructor Create( _SendDesList : TStringList );
    procedure Update;override;
    destructor Destroy; override;
  end;

    // 删除
  TSendDesHistoryRemoveFace = class( TSendDesHistoryChangeFace )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;override;
  end;

    // 清空
  TSendDesHistoryClearFace = class( TSendDesHistoryChangeFace )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 主窗口信息 ' }

  TStartBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  TPauseBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  TStopBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

  TBackupNodeGetHintStr = class
  public
    Node : PVirtualNode;
    NodeData : PVstSendData;
  public
    constructor Create( _Node : PVirtualNode );
    function get : string;
  private
    function getBaseStr : string;
    function getSavePathStr : string;
    function getScheduleStr : string;
    function getFilterStr : string;
  end;

  VstBackupUtil = class
  public             // 状态文本
    class function getDesStatus( Node : PVirtualNode ): string;
    class function getBackupStatus( Node : PVirtualNode ): string;
  public             // 状态图标
    class function getDesStatusIcon( Node : PVirtualNode ): Integer;
    class function getBackupStatusIcon( Node : PVirtualNode ): Integer;
  public             // 获取 Hint 信息
    class function getBackupHintStr( Node : PVirtualNode ): string;
    class function getNextSendText( Node : PVirtualNode ): string;
  public             // 节点类型
    class function getIsBackupNode( NodeType : string ): Boolean;
    class function getIsDesNode( NodeType : string ): Boolean;
  end;

{$EndRegion}

const
  ItemName_BackupRoot = ' or Shared Folders';
  SendRootIcon_Folder = 5;
  SendRootIcon_PcOffline = 0;
  SendRootIcon_PcOnline = 1;
  SendRootIcon_LanPc = 6;
  SendRootIcon_InternetPc = 7;

  SendNodeStatus_WaitingSend = 'Waiting';
  SendNodeStatus_Sending = 'Sending';
  SendNodeStatus_Analyizing = 'Analyzing';
  SendNodeStatus_Stop = '';

  SendNodeStatus_ReadFileError = 'Read File Error';
  SendNodeStatus_WriteFileError = 'Write File Error';
  SendNodeStatus_LostConnectError = 'Lost Connect Error';
  SendNodeStatus_SendFileError = 'Send File Error';


  SendStatusShow_NotExist = 'Not Exist';
  SendStatusShow_NotWrite = 'Cannot Write';
  SendStatusShow_NotSpace = 'Space Insufficient';
  SendStatusShow_PcOffline = 'Offline';
  SendStatusShow_Cancel = 'Receive Cancel';
  SendStatusShow_Analyizing = 'Analyzing %s Files';
  SendStatusShow_Compress = 'Compress %s Files';
  SendStatusShow_Busy = 'Destination Busy';
  SendStatusShow_NotConnect = 'Cannot Connect';

  SendStatusShow_Incompleted = 'Incompleted';
  SendStatusShow_Completed = 'Send Completed';

const
  ShowStatusType_Speed = 'Speed';
  ShowStatusType_Compress = 'Compress';

const
  FrmDesIcon_PcOffline = 0;
  FrmDesIcon_PcOnline = 1;
  FrmDesIcon_LanPc = SendRootIcon_LanPc;
  FrmDesIcon_InternetPc = SendRootIcon_InternetPc;

const
  SendNodeType_LocalRoot = 'LocalRoot';
  SendNodeType_LocalItem = 'LocalItem';

  SendNodeType_NetworkRoot = 'NetworkRoot';
  SendNodeType_NetworkItem = 'NetworkItem';

  SendNodeType_ErrorItem = 'ErrorItem';

implementation

uses UMainForm, UIconUtil, UFrmSelectSendItem, UFormSendLog, UFormLocalSelect, UFormSendPcFilter;

{ TVstBackupDesItemWrite }

constructor TSendRootItemWriteFace.Create(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;

function TSendRootItemWriteFace.FindSendRootItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
begin
  Result := False;
  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.ItemID = SendRootItemID then
    begin
      Result := True;
      SendRootItemNode := SelectNode;
      SendRootItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TSendRootItemWriteFace.RefreshDesNode;
begin
  VstFileSend.RepaintNode( SendRootItemNode );
end;

{ TVstBackupDesItemRemove }

procedure TSendRootItemRemoveFace.Update;
begin
  inherited;

    // 不存在
  if not FindSendRootItemNode then
    Exit;

  VstFileSend.DeleteNode( SendRootItemNode );
end;

{ TVstBackupItemWrite }

function TSendItemWriteFace.FindSendItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
begin
  Result := False;
  SendRootItemNode := nil;
  if not FindSendRootItemNode then
    Exit;
  SelectNode := SendRootItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.ItemID = SourcePath then
    begin
      Result := True;
      SendItemNode := SelectNode;
      SendItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TSendItemWriteFace.RefreshSendNode;
begin
  VstFileSend.RepaintNode( SendItemNode );
end;

procedure TSendItemWriteFace.RefreshNextSchedule;
var
  ShowStr : string;
  ShowTime : TDateTime;
  ScheduleType, ScheduleValue1, ScheduleValue2 : Integer;
begin
  ScheduleType := SendItemData.ScheduleType;
  ScheduleValue1 := SendItemData.ScheduleValue1;
  ScheduleValue2 := SendItemData.ScheduleValue2;
  if ScheduleType = ScheduleType_Manual then
    ShowStr := 'Manual'
  else
  begin
    ShowTime := ScheduleUtil.getNextBackupTime( ScheduleType, ScheduleValue1, ScheduleValue2, SendItemData.LastSendTime );
    ShowStr := FormatDateTime( 'mm-dd  hh:nn', ShowTime );
  end;
  SendItemData.NextSendTimeStr := ShowStr;
end;

procedure TSendItemWriteFace.RefreshPercentage;
begin
  SendItemData.Percentage := MyPercentage.getPercent( SendItemData.CompletedSize, SendItemData.ItemSize );
end;

procedure TSendItemWriteFace.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

{ TVstBackupItemAdd }

procedure TSendItemAddFace.AddItemInfo;
begin

end;

procedure TSendItemAddFace.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TSendItemAddFace.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemAddFace.SetScheduleInfo(_ScheduleType, _ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleType := _ScheduleType;
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemAddFace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemAddFace.SetZipInfo(_IsZip: Boolean; _ZipPath: string);
begin
  IsZip := _IsZip;
  ZipPath := _ZipPath;
end;

procedure TSendItemAddFace.Update;
begin
  inherited;

    // 已存在
  if FindSendItemNode or ( SendRootItemNode = nil ) then
    Exit;

    // 添加
  SendItemNode := VstFileSend.AddChild( SendRootItemNode );
  SendItemData := VstFileSend.GetNodeData( SendItemNode );
  SendItemData.ItemID := SourcePath;
  SendItemData.MainName := SourcePath;
  SendItemData.IsFile := IsFile;
  SendItemData.IsCompleted := IsCompleted;
  SendItemData.IsZip := IsZip;
  SendItemData.ZipPath := ZipPath;
  SendItemData.IsReceiveCancel := False;
  SendItemData.IsExist := True;
  SendItemData.IsSending := False;
  SendItemData.IsDesBusy := False;
  SendItemData.IncludeFilterStr := '';
  SendItemData.ExcludeFilterStr := '';
  SendItemData.FileCount := FileCount;
  SendItemData.ItemSize := ItemSize;
  SendItemData.CompletedSize := CompletedSize;
  SendItemData.ScheduleType := ScheduleType;
  SendItemData.ScheduleValue1 := ScheduleValue1;
  SendItemData.ScheduleValue2 := ScheduleValue2;
  SendItemData.LastSendTime := LastSendTime;
  SendItemData.NextSendTimeStr := '';
  SendItemData.NodeStatus := '';
  SendItemData.MainIcon := MyIcon.getIconByFilePath( SourcePath );

    // 添加额外信息
  AddItemInfo;

  VstFileSend.Expanded[ SendRootItemNode ] := True;

    // 刷新信息
  RefreshPercentage;

    // 刷新同步时间
  RefreshNextSchedule;

    // 启动清空
  if IsCompleted then
    frmMainForm.tbtnFileSendClear.Enabled := True;
end;

{ TVstBackupItemRemove }

procedure TSendItemRemoveFace.Update;
begin
  inherited;
  if not FindSendItemNode then
    Exit;
  VstFileSend.DeleteNode( SendItemNode );
end;

{ TBackupItemSetSpaceInfoFace }

procedure TSendItemSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.FileCount := FileCount;
  SendItemData.ItemSize := ItemSize;
  SendItemData.CompletedSize := CompletedSize;

    // 刷新节点
  RefreshPercentage;
  RefreshSendNode;
end;

{ TBackupItemSetAddCompletedSpaceFace }

procedure TSendItemSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TSendItemSetAddCompletedSpaceFace.Update;
var
  LastPercentage : Integer;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.CompletedSize := SendItemData.CompletedSize + AddCompletedSpace;


  LastPercentage := SendItemData.Percentage;
  RefreshPercentage;

    // 百分比发生变化, 刷新节点
  if SendItemData.Percentage <> LastPercentage then
    RefreshSendNode;
end;

{ TNetworkDesItemChangeFace }

procedure TFrmNetworkDesChange.Update;
begin
  vstNetworkDes := frmSelectSendItem.vstNetworkDes;
end;

{ TNetworkDesItemWriteFace }

constructor TFrmNetworkDesWrite.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TFrmNetworkDesWrite.FindNetworkDesItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  Result := False;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    if NodeData.DesItemID = DesItemID then
    begin
      Result := True;
      NetworkDesNode := SelectNode;
      NetworkDesData := NodeData;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TFrmNetworkDesAdd }

procedure TFrmNetworkDesAdd.CreateDesNode;
var
  SameNameLastNode, LastOnlineNode : PVirtualNode;
begin
  SameNameLastNode := getSameNameLastNode;
  if Assigned( SameNameLastNode ) then
    NetworkDesNode := vstNetworkDes.InsertNode( SameNameLastNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      NetworkDesNode := vstNetworkDes.InsertNode( LastOnlineNode, amInsertAfter )
    else
      NetworkDesNode := vstNetworkDes.InsertNode( vstNetworkDes.RootNode, amAddChildFirst );
  end
  else
    NetworkDesNode := vstNetworkDes.AddChild( vstNetworkDes.RootNode );
end;

function TFrmNetworkDesAdd.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
begin
  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TFrmNetworkDesAdd.getSameNameLastNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
  ReceivePcID, SelectPcID : string;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( SelectData.DesItemID );
    if SelectPcID = ReceivePcID then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmNetworkDesAdd.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TFrmNetworkDesAdd.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TFrmNetworkDesAdd.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmNetworkDesAdd.SetNameInfo(_MainName, _DesName: string);
begin
  MainName := _MainName;
  DesName := _DesName;
end;

procedure TFrmNetworkDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmNetworkDesAdd.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindNetworkDesItemNode then
  begin
    CreateDesNode;
    vstNetworkDes.CheckType[ NetworkDesNode ] := ctTriStateCheckBox;
    NetworkDesData := vstNetworkDes.GetNodeData( NetworkDesNode );
    NetworkDesData.DesItemID := DesItemID;
  end;
  NetworkDesData.IsOnline := IsOnline;
  NetworkDesData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline, IsLan );
  NetworkDesNode.NodeHeight := FrmNetworkDesUtil.ReadHeight( IsOnline );
  NetworkDesData.DesItemName := PcName;
  NetworkDesData.AvailaleSpace := AvailableSpace;
  NetworkDesData.MainName := MainName;
  NetworkDesData.DesName := Format( DesName_Show, [DesName] );
  vstNetworkDes.RepaintNode( NetworkDesNode );

  if vstNetworkDes.RootNode.ChildCount >= 5 then
    frmSelectSendItem.tbSendDes.Visible := True;
end;

{ TFrmNetworkDesRemove }

procedure TFrmNetworkDesRemove.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  vstNetworkDes.DeleteNode( NetworkDesNode );
end;

{ TDesItemChangeFace }

procedure TFrmLocalDesChange.Update;
begin
  LvDes := FrmLocalSelect.LvLocalDes;
end;

{ TDesItemChangeFace }

procedure TSendRootItemChangeFace.Update;
begin
  VstFileSend := FrmMainForm.VstFileSend;
end;

{ TDesItemWriteFace }

constructor TFrmLocalDesWrite.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;


function TFrmLocalDesWrite.FindDesItemNode : Boolean;
var
  SelectData : TLocalDesData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvDes.Items.Count - 1 do
  begin
    SelectData := LvDes.Items[i].Data;
    if ( SelectData.DesPath = DesPath ) then
    begin
      Result := True;
      DesIndex := i;
      DesItem := LvDes.Items[i];
      DesData := SelectData;
      Break;
    end;
  end;
end;



{ TDesData }

constructor TLocalDesData.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TFrmDesAdd }

procedure TFrmLocalDesAdd.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TFrmLocalDesAdd.SetIsSelect(_IsSelect: Boolean);
begin
  IsSelect := _IsSelect;
end;

procedure TFrmLocalDesAdd.Update;
begin
  inherited;

  if not FindDesItemNode then
  begin
    DesItem := LvDes.Items.Add;
    DesData := TLocalDesData.Create( DesPath );
    with DesItem do
    begin
      Caption := DesPath;
      SubItems.Add( MySize.getFileSizeStr( AvailableSpace ) );
      Data := DesData;
      ImageIndex := MyIcon.getIconByFilePath( DesPath );
    end;
  end;
end;

{ TFrmDesRemove }

procedure TFrmLocalDesRemove.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  LvDes.Items.Delete( DesIndex );
end;

{ TDesItemSetIsExistFace }

procedure TSendRootItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TSendRootItemSetIsExistFace.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;

  SendRootItemData.IsExist := IsExist;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsWriteFace }

procedure TSendRootItemSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TSendRootItemSetIsWriteFace.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;
  SendRootItemData.IsWrite := IsWrite;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsLackSpaceFace }

procedure TSendRootItemSetIsLackSpaceFace.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TSendRootItemSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;
  SendRootItemData.IsLackSpace := IsLackSpace;

    // 刷新节点
  RefreshDesNode;
end;

{ TBackupItemSetIsExistFace }

procedure TSendItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TSendItemSetIsExistFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemData.IsExist := IsExist;

    // 刷新节点
  RefreshSendNode;
end;

{ TBackupItemSetBackupItemStatusFace }

procedure TSendItemSetStatusFace.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TSendItemSetStatusFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.NodeStatus := BackupItemStatus;

    // 刷新节点
  RefreshSendNode;
end;



{ VstBackupUtil }

class function VstBackupUtil.getBackupHintStr(Node: PVirtualNode): string;
var
  BackupNodeGetHintStr : TBackupNodeGetHintStr;
begin
  BackupNodeGetHintStr := TBackupNodeGetHintStr.Create( Node );
  Result := BackupNodeGetHintStr.get;
  BackupNodeGetHintStr.Free;
end;

class function VstBackupUtil.getBackupStatus(Node: PVirtualNode): string;
var
  NodeData : PVstSendData;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := SendStatusShow_Completed
  else
  if NodeData.IsReceiveCancel then
    Result := SendStatusShow_Cancel
  else
  if NodeData.IsDesBusy then
    Result := SendStatusShow_Busy
  else
  if not NodeData.IsExist then
    Result := SendStatusShow_NotExist
  else
  if NodeData.NodeStatus = SendNodeStatus_Analyizing then
  begin
    if NodeData.AnalyizeCount <= 0 then
      Result := SendNodeStatus_Analyizing
    else
      Result := Format( SendStatusShow_Analyizing, [  MyCount.getCountStr( NodeData.AnalyizeCount ) ] );
  end
  else
  if NodeData.NodeStatus = SendNodeStatus_Sending then
  begin
    if NodeData.ShowStatusType = ShowStatusType_Compress then
      Result := Format( SendStatusShow_Compress, [  MyCount.getCountStr( NodeData.CompressCount ) ] )
    else
    begin
      if NodeData.Speed > 0 then
        Result := MySpeed.getSpeedStr( NodeData.Speed )
      else
        Result := SendNodeStatus_Sending;
      if NodeData.Percentage < 100 then
        Result := Result + '   ' + MyPercentage.getPercentageStr( NodeData.Percentage );
    end;
  end
  else
  if NodeData.NodeStatus <> '' then
    Result := NodeData.NodeStatus
  else
  begin
    Result := SendStatusShow_Incompleted;
    if NodeData.Percentage < 100 then
      Result := Result + ' ( ' + MyPercentage.getPercentageStr( NodeData.Percentage ) + ' )';
  end;
end;

class function VstBackupUtil.getBackupStatusIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstSendData;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
  if NodeData.IsReceiveCancel then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.IsDesBusy then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if not NodeData.IsExist then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.NodeStatus = SendNodeStatus_WaitingSend then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = SendNodeStatus_Analyizing then
    Result := MyShellTransActionIconUtil.getAnalyze
  else
  if NodeData.NodeStatus = SendNodeStatus_Sending then
    Result := MyShellTransActionIconUtil.getUpLoading
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function VstBackupUtil.getDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstSendData;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := SendStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := SendStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := SendStatusShow_NotSpace
  else
  if not NodeData.IsOnline then
    Result := SendStatusShow_PcOffline
  else
  if not NodeData.IsConnected then
    Result := SendStatusShow_NotConnect
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MySize.getFileSizeStr( NodeData.AvailableSpace ) + ' Available';
end;

class function VstBackupUtil.getDesStatusIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstSendData;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if not NodeData.IsExist or
     not NodeData.IsWrite or
     not NodeData.IsOnline or
     not NodeData.IsConnected or
     NodeData.IsLackSpace
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MyShellTransActionIconUtil.getSpace;
end;

class function VstBackupUtil.getIsBackupNode(NodeType: string): Boolean;
begin
  Result := ( NodeType = SendNodeType_LocalItem ) or ( NodeType = SendNodeType_NetworkItem );
end;

class function VstBackupUtil.getIsDesNode(NodeType: string): Boolean;
begin
  Result := ( NodeType = SendNodeType_LocalRoot ) or ( NodeType = SendNodeType_NetworkRoot );
end;

class function VstBackupUtil.getNextSendText(Node: PVirtualNode): string;
var
  NodeData : PVstSendData;
begin
  Result := '';
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if NodeData.IsSending or not NodeData.IsCompleted then
    Exit;
  Result := NodeData.NextSendTimeStr;
end;

{ TBackupItemSetSpeedFace }

procedure TSendItemSetSpeedFace.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TSendItemSetSpeedFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemData.Speed := Speed;
  SendItemData.ShowStatusType := ShowStatusType_Speed;

  RefreshSendNode;
end;

{ TDesItemAddLocalFace }

procedure TSendRootItemAddLocalFace.AddItemInfo;
begin
  SendRootItemData.IsOnline := True;
  SendRootItemData.MainName := SendRootItemID;
  SendRootItemData.MainIcon := SendRootIcon_Folder;
  SendRootItemData.NodeType := SendNodeType_LocalRoot;
end;

procedure TSendRootItemAddLocalFace.CreateItemInfo;
var
  FirstNetworkDesNode : PVirtualNode;
begin
  FirstNetworkDesNode := getFirstNetworkNode;
  if Assigned( FirstNetworkDesNode ) then
    SendRootItemNode := VstFileSend.InsertNode( FirstNetworkDesNode, amInsertBefore )
  else
    SendRootItemNode := VstFileSend.AddChild( VstFileSend.RootNode );
end;

function TSendRootItemAddLocalFace.getFirstNetworkNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
begin
  Result := nil;
  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.NodeType = SendNodeType_NetworkRoot then
    begin
      Result := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TDesItemAddNetworkFace }

procedure TSendRootItemAddNetworkFace.AddItemInfo;
begin
  SendRootItemData.IsOnline := IsOnline;
  SendRootItemData.NodeType := SendNodeType_NetworkRoot;
end;

procedure TSendRootItemAddNetworkFace.AddUpgradeItemInfo;
begin
  SendRootItemData.IsOnline := IsOnline;
  SendRootItemData.MainName := PcName;
  SendRootItemData.DesName := DesName;
  SendRootItemData.MainIcon := DesItemFaceUtil.ReadPcIcon( IsOnline, IsLan );
end;

procedure TSendRootItemAddNetworkFace.CreateItemInfo;
var
  SameNameLastNode, LastOnlineNode : PVirtualNode;
begin
  SameNameLastNode := getSameNameLastNode;
  if Assigned( SameNameLastNode ) then
    SendRootItemNode := VstFileSend.InsertNode( SameNameLastNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      SendRootItemNode := VstFileSend.InsertNode( LastOnlineNode, amInsertAfter )
    else
      SendRootItemNode := VstFileSend.InsertNode( VstFileSend.RootNode, amAddChildFirst );
  end
  else
    SendRootItemNode := VstFileSend.AddChild( VstFileSend.RootNode );
end;

function TSendRootItemAddNetworkFace.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
begin
  Result := nil;
  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.NodeType = SendNodeType_NetworkRoot then
    begin
      if SelectData.IsOnline then
        Result := SelectNode;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TSendRootItemAddNetworkFace.getSameNameLastNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
  ReceivePcID, SelectPcID : string;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( SendRootItemID );

  Result := nil;
  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.NodeType = SendNodeType_NetworkRoot then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( SelectData.ItemID );
      if SelectPcID = ReceivePcID then
        Result := SelectNode;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TSendRootItemAddNetworkFace.SetDesName(_DesName: string);
begin
  DesName := Format( DesName_Show, [_DesName] );
end;

procedure TSendRootItemAddNetworkFace.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TSendRootItemAddNetworkFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TSendRootItemAddNetworkFace.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

{ TStartBackupFace }

procedure TStartBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnSendSelected.Enabled := False;
    tbtnSendStart.Visible := False;
    tbtnSendStop.Enabled := True;
    tbtnSendStop.Visible := True;
  end;
end;

{ TStopBackupFace }

procedure TStopBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnSendSelected.Enabled := VstFileSend.SelectedCount > 0;
    tbtnSendStop.Visible := False;
  end;
end;

{ TBackupItemSetIsBackupingFace }

procedure TSendItemSetIsBackupingFace.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TSendItemSetIsBackupingFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.IsSending := IsBackuping;
  RefreshSendNode;
end;

{ TBackupNodeGetHintStr }

constructor TBackupNodeGetHintStr.Create(_Node: PVirtualNode);
begin
  Node := _Node;
end;

function TBackupNodeGetHintStr.get: string;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  Result := getBaseStr + getScheduleStr + getFilterStr;
end;

function TBackupNodeGetHintStr.getBaseStr: string;
var
  DestinationStr : string;
  ParentData : PVstSendData;
begin
  DestinationStr := '';
  if Assigned( Node.Parent ) then
  begin
    ParentData := frmMainForm.VstFileSend.GetNodeData( Node.Parent );
    DestinationStr := ParentData.MainName + ParentData.DesName;
  end;

  Result := MyHtmlHintShowStr.getHintRowNext( 'My Files', NodeData.MainName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Send To', DestinationStr );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'File Quantity', MyCount.getCountStr( NodeData.FileCount ) );
  Result := Result + getSavePathStr;
end;

function TBackupNodeGetHintStr.getFilterStr: string;
begin
  Result := '';
  if NodeData.IncludeFilterStr <> '' then
  begin
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Include Filter', '' );
    Result := Result + NodeData.IncludeFilterStr;
  end;

  if NodeData.ExcludeFilterStr <> '' then
  begin
    if Result <> '' then
      Result := Result + '<br />';
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Exclude Filter', '' );
    Result := Result + NodeData.ExcludeFilterStr;
  end;
end;

function TBackupNodeGetHintStr.getSavePathStr: string;
begin
  if NodeData.SavePath <> '' then
    Result := MyHtmlHintShowStr.getHintRowNext( 'Save Path', NodeData.SavePath )
  else
    Result := '';
end;

function TBackupNodeGetHintStr.getScheduleStr: string;
var
  ScheduleType, ScheduleValue1, ScheduleValue2 : Integer;
  ShowStr1, ShowStr2, ShowStr3 : string;
  ShowType2, ShowType3 : string;
begin
  ScheduleType := NodeData.ScheduleType;
  ScheduleValue1 := NodeData.ScheduleValue1;
  ScheduleValue2 := NodeData.ScheduleValue2;
  ShowStr1 := '';
  ShowType2 := '';
  ShowType3 := '';
  if ScheduleType = ScheduleType_Manual then
    ShowStr1 := 'Manual'
  else
  if ScheduleType = ScheduleType_Min then
  begin
    ShowStr1 := 'Every few minues';
    ShowType2 := 'How many';
    ShowStr2 := IntToStr( ScheduleUtil.getMinValue( ScheduleValue1 ) );
  end
  else
  if ScheduleType = ScheduleType_Hour then
  begin
    ShowStr1 := 'Every few hours';
    ShowType2 := 'How many';
    ShowStr2 := IntToStr( ScheduleUtil.getHourValue( ScheduleValue1 ) );
  end
  else
  if ScheduleType = ScheduleType_Day then
  begin
    ShowStr1 := 'Once a day';
    ShowType2 := 'What hour';
    ShowStr2 := IntToStr( ScheduleValue1 ) + ':00';
  end
  else
  if ScheduleType = ScheduleType_Week then
  begin
    ShowStr1 := 'Once a week';
    ShowType2 := 'What day';
    ShowStr2 := ScheduleUtil.getShowWeek( ScheduleValue1 );
    ShowType3 := 'What hour';
    ShowStr3 := IntToStr( ScheduleValue2 ) + ':00';
  end
  else
  if ScheduleType = ScheduleType_Month then
  begin
    ShowStr1 := 'Once a month';
    ShowType2 := 'What day';
    ShowStr2 := IntToStr( ScheduleValue1 + 1 );
    ShowType3 := 'What hour';
    ShowStr3 := IntToStr( ScheduleValue2 ) + ':00';
  end;
  Result := '<br />' + MyHtmlHintShowStr.getHintRowNext( 'Schedule', ShowStr1 );
  if ShowType2 <> '' then
    Result := Result + MyHtmlHintShowStr.getHintRowNext( ShowType2, ShowStr2 );
  if ShowStr3 <> '' then
    Result := Result + MyHtmlHintShowStr.getHintRowNext( ShowType3, ShowStr3 );
 end;

{ TBackupItemSetIncludeFilterFace }

procedure TSendItemSetIncludeFilterFace.SetIncludeFilterStr(
  _IncludeFilterStr: string);
begin
  IncludeFilterStr := _IncludeFilterStr;
end;

procedure TSendItemSetIncludeFilterFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemData.IncludeFilterStr := IncludeFilterStr;
end;

{ TBackupItemSetExcludeFilterFace }

procedure TSendItemSetExcludeFilterFace.SetExcludeFilterStr(
  _ExcludeFilterStr: string);
begin
  ExcludeFilterStr := _ExcludeFilterStr;
end;

procedure TSendItemSetExcludeFilterFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemData.ExcludeFilterStr := ExcludeFilterStr;
end;

{ TDesItemSetPcIsOnlineFace }

constructor TSendRootItemSetPcIsOnlineFace.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TSendRootItemSetPcIsOnlineFace.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSendData;
begin
  Result := nil;
  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileSend.GetNodeData( SelectNode );
    if SelectData.NodeType = SendNodeType_NetworkRoot then
    begin
      if SelectData.IsOnline then
        Result := SelectNode;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TSendRootItemSetPcIsOnlineFace.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TSendRootItemSetPcIsOnlineFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TSendRootItemSetPcIsOnlineFace.Update;
var
  LastOnlineNode : PVirtualNode;
  SelectNode, ChangeNode : PVirtualNode;
  NodeData : PVstSendData;
  SelectPcID : string;
begin
  inherited;

  if IsOnline then
    LastOnlineNode := getLastOnlineNode;

  SelectNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstFileSend.GetNodeData( SelectNode );
    if NodeData.NodeType = SendNodeType_NetworkRoot then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( NodeData.ItemID );
      if ( DesPcID = SelectPcID ) and ( IsOnline <> NodeData.IsOnline ) then
      begin
        NodeData.IsOnline := IsOnline;
        NodeData.MainIcon := DesItemFaceUtil.ReadPcIcon( IsOnline, IsLan );
        VstFileSend.RepaintNode( SelectNode );
        VstFileSend.IsVisible[ SelectNode ] := PcFilterUtil.getSendPcIsShow( SelectNode );

          // 位置发生变化，需要变量转换
        ChangeNode := SelectNode;
        SelectNode := SelectNode.NextSibling;
        if IsOnline then  // 上线时，向上显示
        begin
          if Assigned( LastOnlineNode ) and ( ChangeNode <> LastOnlineNode ) then
            VstFileSend.MoveTo( ChangeNode, LastOnlineNode, amInsertAfter, False )
          else
          if ChangeNode <> VstFileSend.RootNode.FirstChild then
            VstFileSend.MoveTo( ChangeNode, VstFileSend.RootNode, amAddChildFirst, False );
          LastOnlineNode := ChangeNode;
        end
        else       // 离线时，移到最后
        if ChangeNode <> VstFileSend.RootNode.LastChild then
          VstFileSend.MoveTo( ChangeNode, VstFileSend.RootNode, amAddChildLast, False );
        Continue;
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ DesItemFaceUtil }

class function DesItemFaceUtil.ReadPcIcon(IsOnline, IsLan: Boolean): Integer;
begin
  if IsOnline then
  begin
    if IsLan then
      Result := SendRootIcon_LanPc
    else
      Result := SendRootIcon_InternetPc;
  end
  else
    Result := SendRootIcon_PcOffline;
end;

{ TFrmNetworkDesIsOnline }

constructor TFrmNetworkDesIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TFrmNetworkDesIsOnline.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
begin
  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmNetworkDesIsOnline.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TFrmNetworkDesIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmNetworkDesIsOnline.Update;
var
  SelectPcID : string;
  LastOnlineNode : PVirtualNode;
  ChangeNode, SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  inherited;

  if IsOnline then
    LastOnlineNode := getLastOnlineNode;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( NodeData.DesItemID );
    if ( SelectPcID = DesPcID ) and ( IsOnline <> NodeData.IsOnline ) then
    begin
      NodeData.IsOnline := IsOnline;
      NodeData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline, IsLan );
      SelectNode.NodeHeight := FrmNetworkDesUtil.ReadHeight( IsOnline );
      vstNetworkDes.RepaintNode( SelectNode );

        // 位置发生变化，需要变量转换
      ChangeNode := SelectNode;
      SelectNode := SelectNode.NextSibling;
      if IsOnline then  // 上线时，向上显示
      begin
        if Assigned( LastOnlineNode ) and ( ChangeNode <> LastOnlineNode ) then
          vstNetworkDes.MoveTo( ChangeNode, LastOnlineNode, amInsertAfter, False )
        else
        if ChangeNode <> vstNetworkDes.RootNode.FirstChild then
          vstNetworkDes.MoveTo( ChangeNode, vstNetworkDes.RootNode, amAddChildFirst, False );
        LastOnlineNode := ChangeNode;
      end
      else       // 离线时，移到最后
      if ChangeNode <> vstNetworkDes.RootNode.LastChild then
        vstNetworkDes.MoveTo( ChangeNode, vstNetworkDes.RootNode, amAddChildLast, False );
      Continue;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;
{ FrmNetworkDesUtil }

class function FrmNetworkDesUtil.ReadFilterIcon(IsOnline: Boolean): Integer;
begin
  if IsOnline then
    Result := FrmDesIcon_PcOnline
  else
    Result := FrmDesIcon_PcOffline;
end;

class function FrmNetworkDesUtil.ReadHeight(IsOnline: Boolean): Integer;
begin
  if IsOnline then
    Result := 26
  else
    Result := 18;
end;

class function FrmNetworkDesUtil.ReadIcon(IsOnline, IsLan: Boolean): Integer;
begin
  if IsOnline then
  begin
    if IsLan then
      Result := FrmDesIcon_LanPc
    else
      Result := FrmDesIcon_InternetPc;
  end
  else
    Result := FrmDesIcon_PcOffline;
end;

{ TBackupItemSetIsCompletedFace }

procedure TSendItemSetIsCompletedFace.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemSetIsCompletedFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.IsCompleted := IsCompleted;

    // 启动清空
  if IsCompleted then
    frmMainForm.tbtnFileSendClear.Enabled := True;
end;

{ TBackupItemSetAnalyizeCountFace }

procedure TSendItemSetAnalyizeCountFace.SetAnalyizeCount( _AnalyizeCount : integer );
begin
  AnalyizeCount := _AnalyizeCount;
end;

procedure TSendItemSetAnalyizeCountFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.AnalyizeCount := AnalyizeCount;
  RefreshSendNode;
end;



{ TDesItemAddFace }

procedure TSendRootItemAddFace.AddUpgradeItemInfo;
begin

end;

procedure TSendRootItemAddFace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

{ TFrmSetAvailableSpaceFace }

procedure TFrmNetworkSetAvailableSpace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvaialbleSpace := _AvailableSpace;
end;

procedure TFrmNetworkSetAvailableSpace.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  NetworkDesData.AvailaleSpace := AvaialbleSpace;
  vstNetworkDes.RepaintNode( NetworkDesNode );
end;

{ TFrmLocalSetAvailableSpace }

procedure TFrmLocalSetAvailableSpace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvaialbleSpace := _AvailableSpace;
end;

procedure TFrmLocalSetAvailableSpace.Update;
begin
  inherited;
  if not FindDesItemNode then
    Exit;
  DesItem.SubItems[0] := MySize.getFileSizeStr( AvaialbleSpace );
end;

{ TDesItemSetAvailableSpaceFace }

procedure TSendRootItemSetAvailableSpaceFace.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TSendRootItemSetAvailableSpaceFace.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;
  SendRootItemData.AvailableSpace := AvailableSpace;
  RefreshDesNode;
end;

{ TSendItemAddLocalFace }

procedure TSendItemAddLocalFace.AddItemInfo;
begin
  SendItemData.NodeType := SendNodeType_LocalItem;
  SendItemData.SavePath := SavePath;
end;

procedure TSendItemAddLocalFace.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TSendITemAddNetworkFace }

procedure TSendITemAddNetworkFace.AddItemInfo;
begin
  SendItemData.NodeType := SendNodeType_NetworkItem;
  SendItemData.IsReceiveCancel := IsReceiveCancel;
end;

procedure TSendITemAddNetworkFace.SetIsReceiveCancel(_IsReceiveCancel: Boolean);
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

{ TSendItemSetIsReceiveCancelFace }

procedure TSendItemSetIsReceiveCancelFace.SetIsReceiveCancel( _IsReceiveCancel : boolean );
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemSetIsReceiveCancelFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.IsReceiveCancel := IsReceiveCancel;
  RefreshSendNode;
end;

{ TSendItemSetIsDesBusyFace }

procedure TSendItemSetIsDesBusyFace.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TSendItemSetIsDesBusyFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  SendItemData.IsDesBusy := IsDesBusy;
  RefreshSendNode;
end;



procedure TSendRootItemAddFace.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindSendRootItemNode then
  begin
    CreateItemInfo;
    SendRootItemNode.NodeHeight := 30;

    SendRootItemData := VstFileSend.GetNodeData( SendRootItemNode );
    SendRootItemData.ItemID := SendRootItemID;
    SendRootItemData.IsExist := True;
    SendRootItemData.IsWrite := True;
    SendRootItemData.IsLackSpace := False;
    SendRootItemData.IsConnected := True;
    SendRootItemData.NodeStatus := '';
    AddItemInfo;
    VstFileSend.IsVisible[ SendRootItemNode ] := PcFilterUtil.getSendPcIsShow( SendRootItemNode );
  end;
  SendRootItemData.AvailableSpace := AvailableSpace;
  AddUpgradeItemInfo;
  VstFileSend.RepaintNode( SendRootItemNode );
end;

{ TSendItemErrorWriteFace }

procedure TSendItemErrorAddFace.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TSendItemErrorAddFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendItemErrorAddFace.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TSendItemErrorAddFace.Update;
var
  ErrorNode : PVirtualNode;
  ErrorData : PVstSendData;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  ErrorNode := VstFileSend.AddChild( SendItemNode );
  ErrorData := VstFileSend.GetNodeData( ErrorNode );
  ErrorData.ItemID := FilePath;
  ErrorData.MainName := FilePath;
  ErrorData.ItemSize := FileSize;
  ErrorData.NodeType := SendNodeType_ErrorItem;
  ErrorData.MainIcon := MyIcon.getIconByFilePath( FilePath );
  ErrorData.Percentage := MyPercentage.getPercent( CompletedSpace, FileSize );
  ErrorData.NodeStatus := ErrorStatus;

  VstFileSend.Expanded[ SendItemNode ] := True;
end;

{ TSendItemErrorClearFace }

procedure TSendItemErrorClearFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  VstFileSend.DeleteChildren( SendItemNode );
end;

{ TSendRootItemSetIsConnectedFace }

procedure TSendRootItemSetIsConnectedFace.SetIsConnected( _IsConnected : boolean );
begin
  IsConnected := _IsConnected;
end;

procedure TSendRootItemSetIsConnectedFace.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;
  SendRootItemData.IsConnected := IsConnected;
  RefreshDesNode;
end;

{ TSendFileHistoryChangeFace }

procedure TSendFileHistoryChangeFace.Update;
begin
  PmSendFileHistory := frmSelectSendItem.pmFileHistory;
end;

{ TSendFileHistoryAddFace }


constructor TSendFileHistoryAddFace.Create(_SendPathList: TStringList);
begin
  SendPathList := _SendPathList;
end;

destructor TSendFileHistoryAddFace.Destroy;
begin
  SendPathList.Free;
  inherited;
end;

procedure TSendFileHistoryAddFace.Update;
var
  ShowStr : string;
  i: Integer;
  mi : TMenuItem;
begin
  inherited;

  if SendPathList.Count = 1 then
    ShowStr := SendPathList[0]
  else
  begin
    ShowStr := '';
    for i := 0 to SendPathList.Count - 1 do
    begin
        // 限制显示字符数
      if Length( ShowStr ) >= 40 then
      begin
        ShowStr := ShowStr + ' + ...( ' + IntToStr( SendPathList.Count ) +  ' )';
        Break;
      end;

      if ShowStr <> '' then
        ShowStr := ShowStr + ' + ';
      ShowStr := ShowStr + ExtractFileName( SendPathList[i] );
    end;
  end;


  mi := TMenuItem.Create(nil);
  mi.Caption := ShowStr;
  mi.ImageIndex := -1;
  mi.OnClick := frmSelectSendItem.SendFileHistoryClick;
  PmSendFileHistory.Items.Insert( 0, mi );

  frmSelectSendItem.tbtnSelectHistory.Enabled := True;
end;

{ TSendFileHistoryRemoveFace }

constructor TSendFileHistoryRemoveFace.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendFileHistoryRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if PmSendFileHistory.Items.Count <= RemoveIndex then
    Exit;

  mi := PmSendFileHistory.Items[ RemoveIndex ];
  PmSendFileHistory.Items.Delete( RemoveIndex );
  mi.free;
end;

{ TSendFileHistoryClearFace }

procedure TSendFileHistoryClearFace.Update;
var
  IsStartDelete : Boolean;
  i: Integer;
  mi : TMenuItem;
begin
  inherited;

  IsStartDelete := False;
  for i := PmSendFileHistory.Items.Count - 1 downto 0 do
  begin
    mi := PmSendFileHistory.Items[i];
    if mi.Caption = '-' then
    begin
      IsStartDelete := True;
      Continue;
    end;
    if not IsStartDelete then
      Continue;
    PmSendFileHistory.Items.Delete( i );
    mi.Free;
  end;

  frmSelectSendItem.tbtnSelectHistory.Enabled := False;
end;

{ TSendDesHistoryChangeFace }

procedure TSendDesHistoryChangeFace.Update;
begin
  PmSendDesHistory := frmSelectSendItem.pmDesHistory;
end;

{ TSendDesHistoryAddFace }

constructor TSendDesHistoryAddFace.Create(_SendDesList: TStringList);
begin
  SendDesList := _SendDesList;
end;

destructor TSendDesHistoryAddFace.Destroy;
begin
  SendDesList.Free;
  inherited;
end;

procedure TSendDesHistoryAddFace.Update;
var
  SendDes, ShowStr : string;
  i: Integer;
  mi : TMenuItem;
begin
  inherited;

  if SendDesList.Count = 1 then
    ShowStr := SendDesList[0]
  else
  begin
    ShowStr := '';
    for i := 0 to SendDesList.Count - 1 do
    begin
        // 限制显示字符数
      if Length( ShowStr ) >= 40 then
      begin
        ShowStr := ShowStr + ' + ...( ' + IntToStr( SendDesList.Count ) +  ' )';
        Break;
      end;

      if ShowStr <> '' then
        ShowStr := ShowStr + ' + ';
      SendDes := SendDesList[i];
      if Length( SendDes ) > 5 then  // 只显示前5字符
        SendDes := Copy( SendDes, 1, 5 ) + '...';
      ShowStr := ShowStr + SendDes;
    end;
  end;


  mi := TMenuItem.Create(nil);
  mi.Caption := ShowStr;
  mi.ImageIndex := -1;
  mi.OnClick := frmSelectSendItem.SendDesHistoryClick;
  PmSendDesHistory.Items.Insert( 0, mi );

  frmSelectSendItem.tbtnPcHistory.Enabled := True;
end;

{ TSendDesHistoryRemoveFace }

constructor TSendDesHistoryRemoveFace.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendDesHistoryRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if PmSendDesHistory.Items.Count <= RemoveIndex then
    Exit;

  mi := PmSendDesHistory.Items[ RemoveIndex ];
  PmSendDesHistory.Items.Delete( RemoveIndex );
  mi.Free;
end;

{ TSendDesHistoryClearFace }

procedure TSendDesHistoryClearFace.Update;
var
  IsStartDelete : Boolean;
  i: Integer;
  mi : TMenuItem;
begin
  inherited;

  IsStartDelete := False;
  for i := PmSendDesHistory.Items.Count - 1 downto 0 do
  begin
    mi := PmSendDesHistory.Items[i];
    if mi.Caption = '-' then
    begin
      IsStartDelete := True;
      Continue;
    end;
    if not IsStartDelete then
      Continue;
    PmSendDesHistory.Items.Delete( i );
    mi.Free;
  end;

  frmSelectSendItem.tbtnPcHistory.Enabled := False;
end;


{ TPauseBackupFace }

procedure TPauseBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnSendSelected.Enabled := VstFileSend.SelectedCount > 0;
    tbtnSendStop.Visible := False;
    tbtnSendStart.Enabled := True;
    tbtnSendStart.Visible := True;
  end;
end;

{ TBackupSpeedLimitFace }

procedure TBackupSpeedLimitFace.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitFace.SetLimitSpeed(_LimitSpeed: Int64);
begin
  LimitSpeed := _LimitSpeed;
end;

procedure TBackupSpeedLimitFace.Update;
var
  HintType, HintStr : string;
  ShowStr : string;
begin
  HintType := 'Transfer File Speed: ';
  if not IsLimit then
    HintStr := 'Unlimited'
  else
    HintStr := 'Limit to ' + MySpeed.getSpeedStr( LimitSpeed );
  HintStr := MyHtmlHintShowStr.getHintRow( HintType, HintStr );
  frmMainForm.tbtnSendSpeed.Hint := HintStr;

  ShowStr := 'Speed';
  if IsLimit then
    ShowStr := ShowStr + ' ( Limited )';
  frmMainForm.tbtnSendSpeed.Caption := ShowStr;
end;


{ TSendItemSetCompressFace }

procedure TSendItemSetCompressFace.SetCompressCount(_CompressCount: Integer);
begin
  CompressCount := _CompressCount;
end;

procedure TSendItemSetCompressFace.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemData.CompressCount := CompressCount;
  SendItemData.ShowStatusType := ShowStatusType_Compress;

  RefreshSendNode;
end;

{ TSendPcFilterItemChangeFace }

procedure TFrmSendPcFilterChange.Update;
begin
  vstSendPcFilter := frmSendPcFilter.vstGroupPc;
end;

{ TSendPcFilterItemWriteFace }

constructor TFrmSendPcFilterWrite.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TFrmSendPcFilterWrite.FindSendPcFilterItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PSendPcFilterData;
begin
  Result := False;

  SelectNode := vstSendPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstSendPcFilter.GetNodeData( SelectNode );
    if NodeData.DesItemID = DesItemID then
    begin
      Result := True;
      SendPcFilterNode := SelectNode;
      SendPcFilterData := NodeData;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TFrmSendPcFilterAdd }

procedure TFrmSendPcFilterAdd.CreateDesNode;
var
  SameNameLastNode, LastOnlineNode : PVirtualNode;
begin
  SameNameLastNode := getSameNameLastNode;
  if Assigned( SameNameLastNode ) then
    SendPcFilterNode := vstSendPcFilter.InsertNode( SameNameLastNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      SendPcFilterNode := vstSendPcFilter.InsertNode( LastOnlineNode, amInsertAfter )
    else
      SendPcFilterNode := vstSendPcFilter.InsertNode( vstSendPcFilter.RootNode, amAddChildFirst );
  end
  else
    SendPcFilterNode := vstSendPcFilter.AddChild( vstSendPcFilter.RootNode );
end;

function TFrmSendPcFilterAdd.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PSendPcFilterData;
begin
  Result := nil;
  SelectNode := vstSendPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSendPcFilter.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TFrmSendPcFilterAdd.getSameNameLastNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PSendPcFilterData;
  ReceivePcID, SelectPcID : string;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

  Result := nil;
  SelectNode := vstSendPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSendPcFilter.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( SelectData.DesItemID );
    if SelectPcID = ReceivePcID then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmSendPcFilterAdd.SetDirectory(_Directory: string);
begin
  Directory := _Directory;
end;

procedure TFrmSendPcFilterAdd.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TFrmSendPcFilterAdd.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmSendPcFilterAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmSendPcFilterAdd.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindSendPcFilterItemNode then
  begin
    CreateDesNode;
    vstSendPcFilter.CheckType[ SendPcFilterNode ] := ctTriStateCheckBox;
    SendPcFilterData := vstSendPcFilter.GetNodeData( SendPcFilterNode );
    SendPcFilterData.DesItemID := DesItemID;
    SendPcFilterData.IsOnline := IsOnline;
    SendPcFilterData.MainIcon := FrmNetworkDesUtil.ReadFilterIcon( IsOnline );
    if frmSendPcFilter.getIsChecked( DesItemID ) then
      vstSendPcFilter.CheckState[ SendPcFilterNode ] := csCheckedNormal;
  end;
  SendPcFilterData.ComputerName := PcName;
  SendPcFilterData.Directory := Directory;
end;

{ TFrmSendPcFilterRemove }

procedure TFrmSendPcFilterRemove.Update;
begin
  inherited;

  if not FindSendPcFilterItemNode then
    Exit;

  vstSendPcFilter.DeleteNode( SendPcFilterNode );
end;

{ TFrmSendPcFilterIsOnline }

constructor TFrmSendPcFilterIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TFrmSendPcFilterIsOnline.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PSendPcFilterData;
begin
  Result := nil;
  SelectNode := vstSendPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSendPcFilter.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmSendPcFilterIsOnline.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TFrmSendPcFilterIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmSendPcFilterIsOnline.Update;
var
  SelectPcID : string;
  LastOnlineNode : PVirtualNode;
  ChangeNode, SelectNode : PVirtualNode;
  NodeData : PSendPcFilterData;
begin
  inherited;

  if IsOnline then
    LastOnlineNode := getLastOnlineNode;

  SelectNode := vstSendPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstSendPcFilter.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( NodeData.DesItemID );
    if ( SelectPcID = DesPcID ) and ( IsOnline <> NodeData.IsOnline ) then
    begin
      NodeData.IsOnline := IsOnline;
      NodeData.MainIcon := FrmNetworkDesUtil.ReadFilterIcon( IsOnline );
      vstSendPcFilter.RepaintNode( SelectNode );

        // 位置发生变化，需要变量转换
      ChangeNode := SelectNode;
      SelectNode := SelectNode.NextSibling;
      if IsOnline then  // 上线时，向上显示
      begin
        if Assigned( LastOnlineNode ) and ( ChangeNode <> LastOnlineNode ) then
          vstSendPcFilter.MoveTo( ChangeNode, LastOnlineNode, amInsertAfter, False )
        else
        if ChangeNode <> vstSendPcFilter.RootNode.FirstChild then
          vstSendPcFilter.MoveTo( ChangeNode, vstSendPcFilter.RootNode, amAddChildFirst, False );
        LastOnlineNode := ChangeNode;
      end
      else       // 离线时，移到最后
      if ChangeNode <> vstSendPcFilter.RootNode.LastChild then
        vstSendPcFilter.MoveTo( ChangeNode, vstSendPcFilter.RootNode, amAddChildLast, False );
      Continue;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TSendItemSetLastSendTimeFace }

procedure TSendItemSetLastSendTimeFace.SetLastSendTime(
  _LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemSetLastSendTimeFace.Update;
begin
  inherited;
  if not FindSendItemNode then
    Exit;
  SendItemData.LastSendTime := LastSendTime;
  RefreshNextSchedule;
  RefreshSendNode;
end;

{ TSendItemSetScheduleFace }

procedure TSendItemSetScheduleFace.SetSchduleType(_SchduleType: Integer);
begin
  SchduleType := _SchduleType;
end;

procedure TSendItemSetScheduleFace.SetSchduleValue(_SchduleValue1,
  _SchduleValue2: Integer);
begin
  SchduleValue1 := _SchduleValue1;
  SchduleValue2 := _SchduleValue2;
end;

procedure TSendItemSetScheduleFace.Update;
begin
  inherited;
  if not FindSendItemNode then
    Exit;
  SendItemData.ScheduleType := SchduleType;
  SendItemData.ScheduleValue1 := SchduleValue1;
  SendItemData.ScheduleValue2 := SchduleValue2;
  RefreshNextSchedule;
  RefreshSendNode;
end;

end.
