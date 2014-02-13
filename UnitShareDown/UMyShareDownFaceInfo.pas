unit UMyShareDownFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UIconUtil, UMyUtil, SysUtils, Vcl.ExtCtrls, Menus, stdctrls,
     classes, Vcl.Graphics, RzTabs, Winapi.GDIPAPI, Winapi.GDIPOBJ, Winapi.ActiveX, math,
     Vcl.ComCtrls, uDebug;

type

{$Region ' 恢复文件 Explorer ' }

    // 数据结构
  TShareExplorerData = record
  public
    FilePath : WideString;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    ShowName : WideString;
    ShowIcon : Integer;
  end;
  PVstShareExplorerData = ^TShareExplorerData;

    // 父类
  TShareExplorerChangeFace = class( TFaceChangeInfo )
  public
    VstShareExplorer : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改 父类
  TShareExplorerWriteFace = class( TShareExplorerChangeFace )
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;

      // 添加
  TShareExplorerAddFace = class( TShareExplorerWriteFace )
  public
    IsFile : boolean;
    FileSize : int64;
    FileTime : TDateTime;
  private
    ParentNode : PVirtualNode;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
  protected
    procedure Update;override;
  private
    function FindParentNode : Boolean;
    function AddNode: PVirtualNode;
  private
    function AddFileNode: PVirtualNode;
    function AddFolderNode: PVirtualNode;
  end;

    // 设置 文件信息
  TShareExplorerSetFace = class( TShareExplorerWriteFace )
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
  protected
    procedure Update;override;
  end;

  {$Region ' 状态修改 ' }

  TShareExplorerStatusChangeFace = class( TFaceChangeInfo )
  public
    plStatus : TPanel;
    lbStatus : TLabel;
  public
    procedure Update;override;
  end;

    // 开始
  TShareExplorerStartFace = class( TShareExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 结束
  TShareExplorerStopFace = class( TShareExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 繁忙
  TShareExplorerBusyFace = class( TShareExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 无法连接
  TShareExplorerNotConnFace = class( TShareExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 浏览历史 ' }

      // 父类
  TShareExplorerHistoryChangeFace = class( TFaceChangeInfo )
  public
    PmExplorerHistory : TPopupMenu;
  protected
    procedure Update;override;
  end;

      // 添加
  TShareExplorerHistoryAddFace = class( TShareExplorerHistoryChangeFace )
  public
    OwnerName, FilePath : string;
  public
    constructor Create( _OwnerName, _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TShareExplorerHistoryRemoveFace = class( TShareExplorerHistoryChangeFace )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;

    // 清空
  TShareExplorerHistoryClearFace = class( TShareExplorerHistoryChangeFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 保存路径历史 ' }

  TShareSavePathChangeFace = class( TFaceChangeInfo )
  protected
    cbbDownHistory : TComboBox;
    cbbExplorerDownHistory : TComboBox;
  protected
    procedure Update;override;
  end;

  TShareSavePathAddFace = class( TShareSavePathChangeFace )
  public
    SavePath : string;
  public
    constructor Create( _SavePath : string );
  protected
    procedure Update;override;
  end;

  TShareSavePathRemoveFace = class( TShareSavePathChangeFace )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;

  TShareSavePathClearFace = class( TShareSavePathChangeFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件下载 ' }

  {$Region ' 数据结构 ' }

    // 数据结构
  TVstShareDownData = record
  public
    SharePath, OwnerPcID : WideString;
    OwnerPcName : WideString;
    IsFile, IsCompleted, IsDownloading : Boolean;
    IsOnline, IsShareExist, IsDesBusy : Boolean;
    IsWrite, IsLackSpace, IsConnected  : Boolean;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
    Percentage : Integer;
    Speed : Integer;
    AnalyzeCount : Integer;
  public
    SavePath : WideString;
  public
    MainIcon : Integer;
    NodeStatus, NodeType : WideString;
  end;
  PVstShareDownData = ^TVstShareDownData;

  {$EndRegion}

  {$Region ' 数据修改 ' }

    // 父类
  TShareDownChangeFace = class( TFaceChangeInfo )
  public
    VstShareDown : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownWriteFace = class( TShareDownChangeFace )
  public
    SharePath, OwnerPcID : string;
  protected
    ShareDownNode : PVirtualNode;
    ShareDownData : PVstShareDownData;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
  protected
    function FindShareDownNode : Boolean;
    procedure RefreshPercentage;
    procedure RefreshNode;
  end;

  {$Region ' 增删节点 ' }

    // 添加
  TShareDownAddFace = class( TShareDownWriteFace )
  public
    IsFile, IsCompleted : Boolean;
    OwnerPcName : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetOwnerPcName( _OwnerPcName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  protected
    procedure AddItemInfo;virtual;abstract;
  end;

    // 添加 本地恢复 下载
  TShareDownAddLocalFace = class( TShareDownAddFace )
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络恢复 下载
  TShareDownAddNtworkFace = class( TShareDownAddFace )
  private
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure AddItemInfo;override;
  end;

    // 删除
  TShareDownRemoveFace = class( TShareDownWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 状态 ' }

    // 设置 状态
  TShareDownSetStautsFace = class( TShareDownWriteFace )
  public
    NodeStatus : string;
  public
    procedure SetNodeStatus( _NodeStatus : string );
  protected
    procedure Update;override;
  end;

    // 设置 是否存在恢复源
  TShareDownSetIsExistFace = class( TShareDownWriteFace )
  public
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
  protected
    procedure Update;override;
  end;

    // 修改保存位置是否可写
  TShareDownSetIsWriteFace = class( TShareDownWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // 设置 是否缺少空间
  TShareDownSetIsLackSpaceFace = class( TShareDownWriteFace )
  public
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
  protected
    procedure Update;override;
  end;

    // 修改 速度
  TShareDownSetSpeedFace = class( TShareDownWriteFace )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownSetAnalyzeCountFace = class( TShareDownWriteFace )
  public
    AnalyzeCount : integer;
  public
    procedure SetAnalyzeCount( _AnalyzeCount : integer );
  protected
    procedure Update;override;
  end;

      // 修改
  TShareDownSetIsDesBusyFace = class( TShareDownWriteFace )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
  protected
    procedure Update;override;
  end;


      // 修改
  TShareDownSetIsConnectedFace = class( TShareDownWriteFace )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
  protected
    procedure Update;override;
  end;



    // 设置 Pc 是否上线
  TShareDownSetPcIsOnlineFace = class( TShareDownChangeFace )
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  end;

      // 修改
  TShareDownSetIsCompletedFace = class( TShareDownWriteFace )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

      // 修改
  TShareDownSetIsDownloadingFace = class( TShareDownWriteFace )
  public
    IsRestoring : boolean;
  public
    procedure SetIsRestoring( _IsRestoring : boolean );
  protected
    procedure Update;override;
  end;

    // 刷新图标
  TShareDownRefreshIconFace = class( TShareDownWriteFace )
  protected
    procedure Update;override;
  end;

    // 开始下载
  TShareDownStartFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 结束下载
  TShareDownStopFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 暂停下载
  TShareDownPauseFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 空间信息 ' }

      // 修改
  TShareDownSetSpaceInfoFace = class( TShareDownWriteFace )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownSetAddCompletedSpaceFace = class( TShareDownWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

      // 修改
  TShareDownSetCompletedSizeFace = class( TShareDownWriteFace )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 错误的信息 ' }

      // 添加 错误
  TShareDownErrorAddFace = class( TShareDownWriteFace )
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
  TShareDownErrorClearFace = class( TShareDownWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' 数据读取 ' }

  ShareDownFaceReadUtil = class
  public
    class function ReadStatusText( Node : PVirtualNode ): string;
    class function ReadStatusImg( Node : PVirtualNode ): Integer;
  public
    class function ReadHintStr( Node : PVirtualNode ): string;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复速度 ' }

        // 速度限制
  TRestoreSpeedLimitFace = class( TFaceChangeInfo )
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

{$Region ' 恢复文件 预览 ' }

    // 预览父类
  TRestorePreviewShowFace = class( TFaceChangeInfo )
  protected
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure Update;override;
  protected
    procedure ShowPreview;virtual;
  end;

    // 从流中预览
  TRestorePreviewStreamShowFace = class( TRestorePreviewShowFace )
  protected
    FileStream : TStream;
  public
    procedure SetFileStream( _FileStream : TStream );
  end;

    // 预览图片
  TRestoreFilePreviewPictureFace = class( TRestorePreviewStreamShowFace )
  protected
    procedure ShowPreview;override;
  end;

    // 预览 word
  TRestoreFilePreviewWordFace = class( TRestorePreviewShowFace )
  private
    WordText : string;
  public
    procedure SetWordText( _WordText : string );
  protected
    procedure ShowPreview;override;
  end;

    // 预览 Excel
  TRestoreFilePreviewExcelFace = class( TRestorePreviewShowFace )
  private
    ExcelText : string;
    LvExcel : TListView;
  public
    procedure SetExcelText( _ExcelText : string );
  protected
    procedure ShowPreview;override;
  private
    procedure IniColumnShow( ColumnCount : Integer );
    procedure ShowRow( RowStr : string );
  end;

    // 预览 Zip
  TRestoreFilePreviewZipFace = class( TRestorePreviewShowFace )
  private
    ZipText : string;
    LvZip : TListView;
  public
    procedure SetZipText( _ZipText : string );
  protected
    procedure ShowPreview;override;
  private
    procedure ShowFile( FileInfoStr : string );
  end;

    // 预览 exe
  TRestoreFilePreviewExeFace = class( TRestorePreviewShowFace )
  private
    ExeText : string;
  private
    IconStream : TStream;
  public
    procedure SetExeText( _ExeText : string );
    procedure SetIconStream( _IconStream : TStream );
  protected
    procedure ShowPreview;override;
  private
    procedure ShowIcon;
    procedure ShowText;
  end;

    // 预览 Music
  TRestoreFilePreviewMusicFace = class( TRestorePreviewShowFace )
  private
    MusicText : string;
  public
    procedure SetMusicText( _MusicText : string );
  protected
    procedure ShowPreview;override;
  end;


    // 预览文本文档
  TRestoreFilePreviewTextFace = class( TRestorePreviewStreamShowFace )
  protected
    procedure ShowPreview;override;
  end;

  {$Region ' 预览状态显示 ' }

    // 开始加载预览
  TRestoreFilePreviewStartFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 结束加载预览
  TRestoreFilePreviewStopFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

      // 繁忙
  TSharePreivewBusyFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

    // 无法连接
  TSharePreivewNotConnFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件 搜索 ' }

    // 数据结构
  TShareSearchData = record
  public
    FilePath : WideString;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    ShowName : WideString;
    ShowIcon : Integer;
  end;
  PShareSearchData = ^TShareSearchData;

    // 父类
  TShareSearchChangeFace = class( TFaceChangeInfo )
  public
    VstShareSearch : TVirtualStringTree;
  public
    FilePath : string;
    IsFile : boolean;
    FileSize : int64;
    FileTime : TDateTime;
  public
    ParentNode : PVirtualNode;
  public
    constructor Create( _FilePath : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
  protected
    procedure Update;override;
  protected    // 创建节点
    function AddNode : PVirtualNode;
    function AddFolderNode: PVirtualNode;
    function AddFileNode: PVirtualNode;
  end;

    // 添加
  TShareSearchAddFace = class( TShareSearchChangeFace )
  protected
    procedure Update;override;
  end;

      // 添加 子节点
  TShareSearchExplorerAddFace = class( TShareSearchChangeFace )
  protected
    procedure Update;override;
  private
    function FindParentNode : Boolean;
  private
    procedure RemoveRootExist;
  end;

  {$Region ' 搜索状态显示 ' }

  TShareSearchStatusChangeFace = class( TFaceChangeInfo )
  public
    plStatus : TPanel;
    lbStatus : TLabel;
    pbSearch : TProgressBar;
  public
    btnSearch : TButton;
    btnStop : TButton;
  public
    procedure Update;override;
  end;

    // 开始
  TShareSearchStartFace = class( TShareSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 结束
  TShareSearchStopFace = class( TShareSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 繁忙
  TShareSearchBusyFace = class( TShareSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 无法连接
  TShareSearchNotConnFace = class( TShareSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

  {$EndRegion}



{$EndRegion}

const
  RestoreIcon_PcOnline = 1;
  RestoreIcon_Folder = 5;

  RestoreNodeType_LocalDes = 'LocalDes';
  RestoreNodeType_LocalRestore = 'LocalRestore';
  RestoreNodeType_NetworkDes = 'NetworkDes';
  RestoreNodeType_NetworkRestore = 'NetworkRestore';

const
  ExplorerStatus_Waiting = 'Share directory is Loading...';
  ExplorerStatus_Stop = '';
  ExplorerStatus_Busy = 'Owner Busy';
  ExplorerStatus_NotConn = 'Cannot Connect to Owner';

const
  RestoreDownNodeType_Local = 'Local';
  RestoreDownNodeType_Network = 'Network';
  RestoreDownNodeType_Error = 'Error';

  RestoreNodeStatus_WaitingRestore = 'Waiting';
  RestoreNodeStatus_Restoreing = 'Downloading';
  RestoreNodeStatus_Analyizing = 'Analyzing';
  RestoreNodeStatus_Empty = '';

  RestoreNodeStatus_ReadFileError = 'Read File Error';
  RestoreNodeStatus_WriteFileError = 'Write File Error';
  RestoreNodeStatus_LostConnectError = 'Lost Connect Error';
  RestoreNodeStatus_ReceiveFileError = 'Receive File Error';

  RestoreStatusShow_NotExist = 'Share Path Not Exist';
  RestoreStatusShow_NotWrite = 'Can not Write';
  RestoreStatusShow_NotSpace = 'Space Insufficient';
  RestoreStatusShow_DesBusy = 'Owner Busy';
  RestoreStatusShow_PcOffline = 'Owner Offline';
  RestoreStatusShow_NotConnect = 'Can not Connect to Owner';
  RestoreStatusShow_Analyizing = 'Analyzing %s Files';

  RestoreStatusShow_Incompleted = 'Incompleted';
  RestoreStatusShow_Completed = 'Download Completed';

var
  RestoreSearch_IsShow : Boolean = False;

implementation

uses UMainForm, UFormShareDownExplorer, UFormSelectShareDown, UFormPreview;


{ TRestoreDownChangeFace }

procedure TShareDownChangeFace.Update;
begin
  VstShareDown := frmMainForm.vstShareDown;
end;

{ TRestoreDownWriteFace }

constructor TShareDownWriteFace.Create( _SharePath, _OwnerPcID : string );
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
end;


function TShareDownWriteFace.FindShareDownNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  Result := False;
  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if ( SelectData.SharePath = SharePath ) and
       ( SelectData.OwnerPcID = OwnerPcID )
    then
    begin
      Result := True;
      ShareDownNode := SelectNode;
      ShareDownData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TShareDownWriteFace.RefreshNode;
begin
  VstShareDown.RepaintNode( ShareDownNode );
end;

procedure TShareDownWriteFace.RefreshPercentage;
begin
  ShareDownData.Percentage := MyPercentage.getPercent( ShareDownData.CompletedSize, ShareDownData.FileSize );
end;

{ TRestoreDownAddFace }

procedure TShareDownAddFace.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareDownAddFace.SetOwnerPcName(_OwnerPcName: string);
begin
  OwnerPcName := _OwnerPcName;
end;

procedure TShareDownAddFace.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownAddFace.Update;
begin
  inherited;

  if FindShareDownNode then
    Exit;

    // 完成则添加，未完成则插入
  ShareDownNode := VstShareDown.InsertNode( VstShareDown.RootNode, amAddChildFirst );
  ShareDownData := VstShareDown.GetNodeData( ShareDownNode );
  ShareDownData.SharePath := SharePath;
  ShareDownData.OwnerPcID := OwnerPcID;
  ShareDownData.OwnerPcName := OwnerPcName;
  ShareDownData.IsFile := IsFile;
  ShareDownData.IsCompleted := IsCompleted;
  ShareDownData.IsDownloading := False;
  ShareDownData.IsOnline := True;
  ShareDownData.IsShareExist := True;
  ShareDownData.IsWrite := True;
  ShareDownData.IsLackSpace := False;
  ShareDownData.IsDesBusy := False;
  ShareDownData.IsConnected := True;
  ShareDownData.FileCount := FileCount;
  ShareDownData.FileSize := FileSize;
  ShareDownData.CompletedSize := CompletedSize;
  ShareDownData.SavePath := SavePath;
  ShareDownData.NodeStatus := '';
  if IsFile then
  begin
    if FileExists( SavePath ) then
      ShareDownData.MainIcon := MyIcon.getIconByFilePath( SavePath )
    else
      ShareDownData.MainIcon := MyIcon.getIconByFilePath( SharePath )
  end
  else
    ShareDownData.MainIcon := MyShellIconUtil.getFolderIcon;

  AddItemInfo;

    // 刷新百分比
  RefreshPercentage;

    // 出现了下载
  if ( VstShareDown.RootNodeCount = 1 ) and not frmMainForm.plRestoreDown.Visible then
  begin
    frmMainForm.plRestoreDown.Visible := True;
    frmMainForm.slRestoreDown.Visible := True;
  end
  else  // 隐藏则显示
  if frmMainForm.btnHideShareDown.Tag = 1 then
    frmMainForm.btnHideShareDown.Click;

  if IsCompleted then
    frmMainForm.tbtnShareDownClear.Enabled := True;
end;

procedure TShareDownAddFace.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveFace }

procedure TShareDownRemoveFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteNode( ShareDownNode );
end;

{ TRestoreDownSetStautsFace }

procedure TShareDownSetStautsFace.SetNodeStatus(_NodeStatus: string);
begin
  NodeStatus := _NodeStatus;
end;

procedure TShareDownSetStautsFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  ShareDownData.NodeStatus := NodeStatus;

  RefreshNode;
end;

{ TRestoreDownSetIsLackSpaceFace }

procedure TShareDownSetIsLackSpaceFace.SetIsLackSpace(_IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TShareDownSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  ShareDownData.IsLackSpace := IsLackSpace;

  RefreshNode;
end;

{ TRestoreDownSetIsFace }

procedure TShareDownSetIsExistFace.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TShareDownSetIsExistFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  ShareDownData.IsShareExist := IsExist;

  RefreshNode;
end;

{ TRestoreDownSetSpaceInfoFace }

procedure TShareDownSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.FileCount := FileCount;
  ShareDownData.FileSize := FileSize;
  ShareDownData.CompletedSize := CompletedSize;

  RefreshPercentage;

  RefreshNode;
end;

{ TRestoreDownSetAddCompletedSpaceFace }

procedure TShareDownSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TShareDownSetAddCompletedSpaceFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.CompletedSize := ShareDownData.CompletedSize + AddCompletedSpace;

  RefreshPercentage;

  RefreshNode;
end;



{ RestoreDownFaceReadUtil }

class function ShareDownFaceReadUtil.ReadHintStr(Node: PVirtualNode): string;
var
  NodeData : PVstShareDownData;
begin
  NodeData := frmMainForm.vstShareDown.GetNodeData( Node );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Remote Files', NodeData.OwnerPcName + ' ' + Format( DesName_Show, [NodeData.SharePath] ) );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Download to', 'My Computer ' +  Format( DesName_Show, [NodeData.SavePath] ) );
  Result := Result + MyHtmlHintShowStr.getHintRow( 'File Quantity', MyCount.getCountStr( NodeData.FileCount ) );
end;

class function ShareDownFaceReadUtil.ReadStatusImg(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstShareDownData;
begin
  NodeData := frmMainForm.vstShareDown.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
  if not NodeData.IsShareExist or
     not NodeData.IsOnline or
     not NodeData.IsWrite or
     not NodeData.IsConnected or
     NodeData.IsLackSpace
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.IsDesBusy then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = RestoreNodeStatus_WaitingRestore then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Analyizing then
    Result := MyShellTransActionIconUtil.getAnalyze
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Restoreing then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function ShareDownFaceReadUtil.ReadStatusText(
  Node: PVirtualNode): string;
var
  NodeData : PVstShareDownData;
begin
  NodeData := frmMainForm.vstShareDown.GetNodeData( Node );

  if NodeData.IsCompleted then
    Result := RestoreStatusShow_Completed
  else
  if not NodeData.IsOnline then
    Result := RestoreStatusShow_PcOffline
  else
  if not NodeData.IsShareExist then
    Result := RestoreStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := RestoreStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := RestoreStatusShow_NotSpace
  else
  if NodeData.IsDesBusy then
    Result := RestoreStatusShow_DesBusy
  else
  if not NodeData.IsConnected then
    Result := RestoreStatusShow_NotConnect
  else
  if NodeData.NodeStatus = RestoreNodeStatus_WaitingRestore then
    Result := RestoreNodeStatus_WaitingRestore
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Analyizing then
  begin
    if NodeData.AnalyzeCount > 0 then
      Result := Format( RestoreStatusShow_Analyizing, [ MyCount.getCountStr( NodeData.AnalyzeCount ) ] )
    else
      Result := NodeData.NodeStatus;
  end
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Restoreing then
  begin
    if NodeData.Speed > 0 then
      Result := MySpeed.getSpeedStr( NodeData.Speed )
    else
      Result := NodeData.NodeStatus;
    if NodeData.Percentage < 100 then
      Result := Result + '   ' + MyPercentage.getPercentageStr( NodeData.Percentage );
  end
  else
  begin
    Result := RestoreStatusShow_Incompleted;
    if NodeData.Percentage < 100 then
      Result := Result + ' ( ' + MyPercentage.getPercentageStr( NodeData.Percentage ) + ' )';
  end;
end;

{ TRestoreDownSetSpeedFace }

procedure TShareDownSetSpeedFace.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TShareDownSetSpeedFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.Speed := Speed;
  RefreshNode;
end;

{ TRestoreExplorerChangeFace }

procedure TShareExplorerChangeFace.Update;
begin
  VstShareExplorer := frmRestoreExplorer.vstExplorer
end;

{ TRestoreExplorerAddFace }

procedure TShareExplorerAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

function TShareExplorerAddFace.AddFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVstShareExplorerData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareExplorer.GetNodeData( SelectNode );
    if ( not SelectData.IsFile ) or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstShareExplorer.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstShareExplorer.InsertNode( ParentNode, amAddChildFirst );
end;

function TShareExplorerAddFace.AddFolderNode: PVirtualNode;
var
  FolderName : string;
  SelectNode, DownNode : PVirtualNode;
  SelectData : PVstShareExplorerData;
begin
  FolderName := ExtractFileName( FilePath );

    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareExplorer.GetNodeData( SelectNode );
    if ( SelectData.IsFile ) or ( CompareText( SelectData.ShowName, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := VstShareExplorer.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstShareExplorer.AddChild( ParentNode );
end;

function TShareExplorerAddFace.AddNode: PVirtualNode;
begin
  if IsFile then
    Result := AddFileNode
  else
    Result := AddFolderNode;
end;

function TShareExplorerAddFace.FindParentNode: Boolean;
var
  ParentPath : string;
  SelectNode : PVirtualNode;
  SelectData : PVstShareExplorerData;
begin
  Result := False;
  ParentPath := ExtractFileDir( FilePath );

  SelectNode := VstShareExplorer.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareExplorer.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.FilePath = ParentPath then
    begin
      ParentNode := SelectNode;
      Result := True;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TShareExplorerAddFace.SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TShareExplorerAddFace.Update;
var
  RestoreExplorerNode : PVirtualNode;
  RestoreExplorerData : PVstShareExplorerData;
begin
  inherited;

  if not FindParentNode then
    Exit;

  RestoreExplorerNode := AddNode;
  if not IsFile then
    VstShareExplorer.HasChildren[ RestoreExplorerNode ] := True;
  RestoreExplorerData := VstShareExplorer.GetNodeData( RestoreExplorerNode );
  RestoreExplorerData.FilePath := FilePath;
  RestoreExplorerData.IsFile := IsFile;
  RestoreExplorerData.FileSize := FileSize;
  RestoreExplorerData.FileTime := FileTime;
  RestoreExplorerData.ShowName := ExtractFileName( FilePath );
  if IsFile then
    RestoreExplorerData.ShowIcon := MyIcon.getIconByFileExt( FilePath )
  else
    RestoreExplorerData.ShowIcon := MyShellIconUtil.getFolderIcon;
  ParentNode.ChildCount := ParentNode.ChildCount + 1;
  if not VstShareExplorer.Expanded[ ParentNode ] then
    VstShareExplorer.Expanded[ ParentNode ] := True;
end;

{ TRestoreDownSetIsWriteFace }

procedure TShareDownSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TShareDownSetIsWriteFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.IsWrite := IsWrite;
  RefreshNode;
end;



{ TRestoreDownSetPcIsOnlineFace }

constructor TShareDownSetPcIsOnlineFace.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TShareDownSetPcIsOnlineFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareDownSetPcIsOnlineFace.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
  SelectPcID : string;
begin
  inherited;

  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if SelectData.NodeType = RestoreDownNodeType_Network then
    begin
      SelectPcID := SelectData.OwnerPcID;
      if SelectPcID = DesPcID then
      begin
        SelectData.IsOnline := IsOnline;
        VstShareDown.RepaintNode( SelectNode );
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestoreDownAddLocalFace }

procedure TShareDownAddLocalFace.AddItemInfo;
begin
  ShareDownData.NodeType := RestoreDownNodeType_Local;
end;

{ TRestoreDownAddNtworkFace }

procedure TShareDownAddNtworkFace.AddItemInfo;
begin
  ShareDownData.IsOnline := IsOnline;
  ShareDownData.NodeType := RestoreDownNodeType_Network;
end;

procedure TShareDownAddNtworkFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

{ TRestoreDownSetCompletedSizeFace }

procedure TShareDownSetCompletedSizeFace.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetCompletedSizeFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.CompletedSize := CompletedSize;
  RefreshPercentage;
  RefreshNode;
end;

{ TRestoreDownSetIsCompletedFace }

procedure TShareDownSetIsCompletedFace.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownSetIsCompletedFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.IsCompleted := IsCompleted;
  RefreshNode;

  if IsCompleted then
    frmMainForm.tbtnShareDownClear.Enabled := True;
end;

{ TRestoreDownSetIsRestoringFace }

procedure TShareDownSetIsDownloadingFace.SetIsRestoring( _IsRestoring : boolean );
begin
  IsRestoring := _IsRestoring;
end;

procedure TShareDownSetIsDownloadingFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.IsDownloading := IsRestoring;
  RefreshNode;
end;



{ TRestoreDownStartFace }

procedure TShareDownStartFace.Update;
begin
  with frmMainForm do
  begin
    tbtnShareDownAgain.Enabled := False;
    tbtnShareDownStart.Visible := False;
    tbtnShareDownStop.Enabled := True;
    tbtnShareDownStop.Visible := True;
  end;
end;

{ TRestoreDownStopFace }

procedure TShareDownStopFace.Update;
begin
  with frmMainForm do
  begin
    tbtnShareDownStop.Visible := False;
    tbtnShareDownAgain.Enabled := vstShareDown.SelectedCount > 0;
  end;
end;

{ TRestoreDownSetAnalyzeCountFace }

procedure TShareDownSetAnalyzeCountFace.SetAnalyzeCount( _AnalyzeCount : integer );
begin
  AnalyzeCount := _AnalyzeCount;
end;

procedure TShareDownSetAnalyzeCountFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.AnalyzeCount := AnalyzeCount;
  RefreshNode;
end;


{ TRestoreExplorerWriteFace }

constructor TShareExplorerWriteFace.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TShareExplorerSetFace }

procedure TShareExplorerSetFace.SetFileInfo(_FileSize: int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TShareExplorerSetFace.Update;
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareExplorerData;
begin
  inherited;

  SelectNode := VstShareExplorer.RootNode.FirstChild;
  if not Assigned( SelectNode ) then
    Exit;
  NodeData := VstShareExplorer.GetNodeData( SelectNode );
  if NodeData.FilePath <> FilePath then
    Exit;
  NodeData.FileSize := FileSize;
  NodeData.FileTime := FileTime;
  VstShareExplorer.RepaintNode( SelectNode );
end;

{ TShareDownErrorAddFace }

procedure TShareDownErrorAddFace.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TShareDownErrorAddFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownErrorAddFace.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TShareDownErrorAddFace.Update;
var
  ErrorNode : PVirtualNode;
  ErrorData : PVstShareDownData;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  ErrorNode := VstShareDown.AddChild( ShareDownNode );
  ErrorData := VstShareDown.GetNodeData( ErrorNode );
  ErrorData.SharePath := FilePath;
  ErrorData.FileSize := FileSize;
  ErrorData.Percentage := MyPercentage.getPercent( CompletedSpace, FileSize );
  ErrorData.NodeType := RestoreDownNodeType_Error;
  ErrorData.NodeStatus := ErrorStatus;
  ErrorData.MainIcon := MyIcon.getIconByFileExt( FilePath );

  VstShareDown.Expanded[ ShareDownNode ] := True;
end;

{ TShareDownErrorClearFace }

procedure TShareDownErrorClearFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteChildren( ShareDownNode );
end;

{ TShareDownSetIsDesBusyFace }

procedure TShareDownSetIsDesBusyFace.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TShareDownSetIsDesBusyFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.IsDesBusy := IsDesBusy;
  RefreshNode;
end;



{ TShareExplorerStartFace }

procedure TShareExplorerStartFace.Update;
begin
  inherited;

  frmRestoreExplorer.tmrShowExplorering.Enabled := True;
  plStatus.Visible := False;
end;

{ TShareExplorerStatusChangeFace }

procedure TShareExplorerStatusChangeFace.Update;
begin
  plStatus := frmRestoreExplorer.plStatus;
  lbStatus := frmRestoreExplorer.lbStatus;
end;

{ TShareExplorerStopFace }

procedure TShareExplorerStopFace.Update;
begin
  inherited;

  frmRestoreExplorer.tmrShowExplorering.Enabled := False;
  frmRestoreExplorer.pbExplorer.Visible := False;
  frmRestoreExplorer.pbExplorer.Style := pbstNormal;

  frmRestoreExplorer.vstExplorer.Refresh;
end;

{ TShareExplorerBusyFace }

procedure TShareExplorerBusyFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_Busy;
  plStatus.Visible := True;
end;

{ TShareExplorerNotConnFace }

procedure TShareExplorerNotConnFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_NotConn;
  plStatus.Visible := True;
end;

{ TShareDownSetIsConnectedFace }

procedure TShareDownSetIsConnectedFace.SetIsConnected( _IsConnected : boolean );
begin
  IsConnected := _IsConnected;
end;

procedure TShareDownSetIsConnectedFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  ShareDownData.IsConnected := IsConnected;
  RefreshNode;
end;



{ TShareExplorerHistoryChangeFace }

procedure TShareExplorerHistoryChangeFace.Update;
begin
  PmExplorerHistory := frmMainForm.pmShareHistory;
end;

{ TShareExplorerHistoryAddFace }

constructor TShareExplorerHistoryAddFace.Create(_OwnerName, _FilePath: string);
begin
  OwnerName := _OwnerName;
  FilePath := _FilePath;
end;

procedure TShareExplorerHistoryAddFace.Update;
var
  ShowStr : string;
  mi : TMenuItem;
begin
  inherited;

  ShowStr := OwnerName + ' ( ' + FilePath + ' )';

  mi := TMenuItem.Create(nil);
  mi.Caption := ShowStr;
  mi.ImageIndex := -1;
  mi.OnClick := frmMainForm.ShareExplorerHistoryClick;
  PmExplorerHistory.Items.Insert( 0, mi );

//  frmMainForm.tbtnShareShowDown.DropdownMenu := frmMainForm.pmShareHistory;
end;

{ TShareExplorerHistoryRemoveFace }

constructor TShareExplorerHistoryRemoveFace.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareExplorerHistoryRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if PmExplorerHistory.Items.Count <= RemoveIndex then
    Exit;

  mi := PmExplorerHistory.Items[ RemoveIndex ];
  PmExplorerHistory.Items.Delete( RemoveIndex );
  mi.free;
end;

{ TShareExplorerHistoryClearFace }

procedure TShareExplorerHistoryClearFace.Update;
var
  IsStartDelete : Boolean;
  i: Integer;
  mi : TMenuItem;
begin
  inherited;

  IsStartDelete := False;
  for i := PmExplorerHistory.Items.Count - 1 downto 0 do
  begin
    mi := PmExplorerHistory.Items[i];
    if mi.Caption = '-' then
    begin
      IsStartDelete := True;
      Continue;
    end;
    if not IsStartDelete then
      Continue;
    PmExplorerHistory.Items.Delete( i );
    mi.Free;
  end;

//  frmMainForm.tbtnShareShowDown.DropdownMenu := nil;
end;

{ TShareSavePathChangeFace }

procedure TShareSavePathChangeFace.Update;
begin
  cbbDownHistory := frmSelectRestore.cbbSavePath;
  cbbExplorerDownHistory := frmRestoreExplorer.cbbSavePath;
end;

{ TShareSavePathAddFace }

constructor TShareSavePathAddFace.Create(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareSavePathAddFace.Update;
begin
  inherited;

  cbbDownHistory.Items.Insert( 0, SavePath );
  cbbDownHistory.Text := SavePath;

  cbbExplorerDownHistory.Items.Insert( 0, SavePath );
  cbbExplorerDownHistory.Text := SavePath;
end;

{ TShareSavePathRemoveFace }

constructor TShareSavePathRemoveFace.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareSavePathRemoveFace.Update;
begin
  inherited;

  if RemoveIndex >= cbbDownHistory.Items.Count then
    Exit;
  cbbDownHistory.Items.Delete( RemoveIndex );

  if RemoveIndex >= cbbExplorerDownHistory.Items.Count then
    Exit;
  cbbExplorerDownHistory.Items.Delete( RemoveIndex );
end;

{ TShareSavePathClearFace }

procedure TShareSavePathClearFace.Update;
begin
  inherited;
  cbbDownHistory.Items.Clear;
  cbbExplorerDownHistory.Items.Clear;
end;

{ TShareDownPauseFace }

procedure TShareDownPauseFace.Update;
begin
  with frmMainForm do
  begin
    tbtnShareDownStop.Visible := False;
    tbtnShareDownStart.Enabled := True;
    tbtnShareDownStart.Visible := True;
    tbtnShareDownAgain.Enabled := vstShareDown.SelectedCount > 0;
  end;
end;

{ TRestoreSpeedLimitFace }

procedure TRestoreSpeedLimitFace.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitFace.SetLimitSpeed(_LimitSpeed: Int64);
begin
  LimitSpeed := _LimitSpeed;
end;

procedure TRestoreSpeedLimitFace.Update;
var
  ShowType, ShowStr : string;
begin
  ShowType := 'Download Speed: ';
  if not IsLimit then
    ShowStr := 'Unlimited'
  else
    ShowStr := 'Limit to ' + MySpeed.getSpeedStr( LimitSpeed );

  ShowStr := MyHtmlHintShowStr.getHintRow( ShowType, ShowStr );
  frmMainForm.tbtnShareDownSpeed.Hint := ShowStr;
end;

{ TRestoreFilePreviewPictureFace }

procedure TRestoreFilePreviewPictureFace.ShowPreview;
var
  ImagePageList : TImagePageList;
  ImagePageInfo : TImagePageInfo;
  ImagePos : Integer;
  tsImg : TRzTabSheet;
  Img : TImage;
  GdiGraphics: TGPGraphics;
  GdiBrush : TGPSolidBrush;
  GdiStream : IStream;
  GdiImg : TGPImage;
  InpuParams : TInputParams;
  OutputParams : TOutputParams;
begin
    // 获取显示图片的分页
  ImagePageList := frmPreView.ImagePageList;
  ImagePos := frmPreView.ImagePos;
  if ImagePos >= ImagePageList.Count then
    ImagePos := ImagePageList.Count - 1;
  ImagePageInfo := ImagePageList[ ImagePos ];
  frmPreView.ImagePos := ( ImagePos + 1 ) mod ImagePageList.Count;
  tsImg := ImagePageInfo.Page;
  Img := ImagePageInfo.Image;
  ImagePageInfo.FilePath := FilePath;
  Img.Picture := nil;

    // 跳到图片列表
  frmPreView.PcImage.ActivePage := tsImg;

    // 画纸
  GdiGraphics := TGPGraphics.Create( Img.Canvas.Handle );

    // 填充背景颜色
  GdiBrush := TGPSolidBrush.Create( MakeColor( 255, 255, 255 ) );
  GdiGraphics.FillRectangle( GdiBrush, 0, 0, Img.Width, Img.Height );
  GdiBrush.Free;

    // 创建图片
  FileStream.Position := 0;
  GdiStream := TStreamAdapter.Create( FileStream );
  GdiImg := TGPImage.Create( GdiStream );

    // 画图片
  InpuParams.SourceWidth := GdiImg.GetWidth;
  InpuParams.SourceHeigh := GdiImg.GetHeight;
  InpuParams.DesWidth := Img.Width;
  InpuParams.DesHeigh := Img.Height;
  InpuParams.IsKeepSpace := True;
  MyPictureUtil.FindPreviewPoint( InpuParams, OutputParams );
  GdiGraphics.DrawImage( GdiImg, OutputParams.ShowX, OutputParams.ShowY, OutputParams.ShowWidth, OutputParams.ShowHeigh );
  GdiImg.Free;

  GdiGraphics.Free;
end;

{ TRestoreFilePreviewTextFace }

procedure TRestoreFilePreviewTextFace.ShowPreview;
begin
  try
    FileStream.Position := 0;
    frmPreView.mmoPreview.Lines.LoadFromStream( FileStream );
    if Length( AnsiString( frmPreView.mmoPreview.Text ) ) < ( FileStream.Size div 2 ) then
    begin
      frmPreView.mmoPreview.Lines.Clear;
      frmPreView.mmoPreview.Lines.Text := 'Can not preview this file';
    end;
  except
  end;
end;


{ TRestoreFilePreviewWordFace }

procedure TRestoreFilePreviewWordFace.SetWordText(_WordText: string);
begin
  WordText := _WordText;
end;

procedure TRestoreFilePreviewWordFace.ShowPreview;
begin
  frmPreView.reDoc.Text := WordText;
end;

{ TRestorePreviewShowFace }

procedure TRestorePreviewShowFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestorePreviewShowFace.ShowPreview;
begin

end;

procedure TRestorePreviewShowFace.Update;
begin
  if frmPreView.ShowPath = FilePath then
    ShowPreview;
end;

{ TRestorePreviewStreamShowFace }

procedure TRestorePreviewStreamShowFace.SetFileStream(_FileStream: TStream);
begin
  FileStream := _FileStream;
end;

{ TRestoreFilePreviewExcelFace }

procedure TRestoreFilePreviewExcelFace.IniColumnShow(ColumnCount: Integer);
var
  ColWidth, i : Integer;
begin
  ColWidth := ( LvExcel.Width - 20 ) div ColumnCount;
  for i := 1 to ColumnCount do
    with LvExcel.Columns.Add do
    begin
      Caption := 'Column ' + IntToStr( i );
      Width := ColWidth;
    end;
end;

procedure TRestoreFilePreviewExcelFace.SetExcelText(_ExcelText: string);
begin
  ExcelText := _ExcelText;
end;

procedure TRestoreFilePreviewExcelFace.ShowPreview;
var
  RowList : TStringList;
  i: Integer;
begin
  LvExcel := frmPreView.LvExcel;

  RowList := MySplitStr.getList( ExcelText, SplitExcel_Row );
  if RowList.Count > 0 then
    IniColumnShow( StrToIntDef( RowList[0], 0 ) );
  for i := 1 to RowList.Count - 1 do
    ShowRow( RowList[i] );
  RowList.Free;
end;


procedure TRestoreFilePreviewExcelFace.ShowRow(RowStr: string);
var
  ColumnList : TStringList;
  i: Integer;
  NewItem : TListItem;
  s : string;
begin
  NewItem := LvExcel.Items.Add;
  ColumnList := MySplitStr.getList( RowStr, SplitExcel_Col );
  for i := 0 to ColumnList.Count - 1 do
  begin
    s := ColumnList[i];
    if s = SplitExcel_Empt then // 空字符串
      s := '';
    if i = 0 then
      NewItem.Caption := s
    else
      NewItem.SubItems.Add( s );
  end;
  ColumnList.Free;
end;


{ TRestoreFilePreviewZipFace }

procedure TRestoreFilePreviewZipFace.SetZipText(_ZipText: string);
begin
  ZipText := _ZipText;
end;

procedure TRestoreFilePreviewZipFace.ShowFile(FileInfoStr: string);
var
  FileInfoList : TStringList;
  FileName, FileSizeStr : string;
  FileSize : Int64;
  TimeStr : string;
  FileTime : TDateTime;
  IsFolder : Boolean;
  MainIcon : Integer;
begin
  FileInfoList := MySplitStr.getList( FileInfoStr, SplitCompress_FileInfo );
  if FileInfoList.Count = 4 then
  begin
    FileName := FileInfoList[0];
    FileSize := StrToInt64Def( FileInfoList[1], 0 );
    TimeStr := FileInfoList[2];
    FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
    IsFolder := StrToBoolDef( FileInfoList[3], True );

    if IsFolder and ( FileSize <= 0 ) then
    begin
      MainIcon := MyShellIconUtil.getFolderIcon;
      FileSizeStr := '';
    end
    else
    begin
      MainIcon := MyIcon.getIconByFileExt( FileName );
      FileSizeStr := MySize.getFileSizeStr( FileSize );
    end;

    with LvZip.Items.Add do
    begin
      Caption := FileName;
      SubItems.Add( FileSizeStr );
      SubItems.Add( DateTimeToStr( FileTime ) );
      ImageIndex := MainIcon;
    end;
  end;
  FileInfoList.Free;
end;

procedure TRestoreFilePreviewZipFace.ShowPreview;
var
  FileList : TStringList;
  i: Integer;
begin
  LvZip := frmPreView.LvZip;
  FileList := MySplitStr.getList( ZipText, SplitCompress_FileList );
  for i := 0 to FileList.Count - 1 do
    ShowFile( FileList[i] );
  FileList.Free;
end;

{ TRestoreFilePreviewExeFace }

procedure TRestoreFilePreviewExeFace.SetExeText(_ExeText: string);
begin
  ExeText := _ExeText;
end;

procedure TRestoreFilePreviewExeFace.SetIconStream(_IconStream: TStream);
begin
  IconStream := _IconStream;
end;

procedure TRestoreFilePreviewExeFace.ShowIcon;
var
  ImgExe : TImage;
  c : Integer;
  red, green, blue : Byte;
  img : TGPImage;
  GdiStream : IStream;
  GdiGraphics: TGPGraphics;
  GdiBrush : TGPSolidBrush;
begin
  ImgExe := frmPreView.ImgPreview;
  ImgExe.Picture := nil;

  GdiGraphics := TGPGraphics.Create( ImgExe.Canvas.Handle ) ;

    // 填充背景色
  c := ColorToRGB( frmPreView.plExe.Color );
  red := GetRed( c );
  green := GetGreen( c );
  blue := GetBlue( c );
  GdiBrush := TGPSolidBrush.Create( MakeColor( red, green, blue ) );
  GdiGraphics.FillRectangle( GdiBrush, 0, 0, imgExe.Width, imgExe.Height );
  GdiBrush.Free;

    // 画图标
  GdiStream := TStreamAdapter.Create( IconStream );
  img := TGPImage.Create( GdiStream );
  GdiGraphics.DrawImage( img, 0, 0, imgExe.Width, imgExe.Height );
  img.Free;

  GdiGraphics.Free;
end;

procedure TRestoreFilePreviewExeFace.ShowPreview;
begin
    // 显示 图标
  if Assigned( IconStream ) and ( IconStream.Size > 0 ) then
    ShowIcon;

    // 显示 描述
  ShowText;
end;


procedure TRestoreFilePreviewExeFace.ShowText;
var
  ExeStrList : TStringList;
  Version : string;
  Description : string;
  Copyright : string;
  i: Integer;
  s : string;
begin
  ExeStrList := MySplitStr.getList( ExeText, SplitExe_FileInfo );
  for i := 0 to ExeStrList.Count - 1 do
    if ExeStrList[i] = SplitExe_Empty then
      ExeStrList[i] := '';
  if ExeStrList.Count = 3 then
  begin
    Version := ExeStrList[0];
    Description := ExeStrList[1];
    Copyright := ExeStrList[2];
  end;

  with frmPreView do
  begin
    s := 'File version=' + Version;
    veExe.Strings.Add( s );
    s := 'Description=' + Description;
    veExe.Strings.Add( s );
    s := 'Copyright=' + Copyright;
    veExe.Strings.Add( s );
  end;

  ExeStrList.Free;
end;

{ TRestoreFilePreviewMusicFace }

procedure TRestoreFilePreviewMusicFace.SetMusicText(_MusicText: string);
begin
  MusicText := _MusicText;
end;

procedure TRestoreFilePreviewMusicFace.ShowPreview;
var
  MusicList : TStringList;
  TitleStr, ArtStr : string;
  AblumStr, YearStr : string;
  i: Integer;
  s : string;
begin
  MusicList := MySplitStr.getList( MusicText, SplitMusic_FileInfo );
  for i := 0 to MusicList.Count - 1 do
    if MusicList[i] = SplitMusic_Empty then
      MusicList[i] := '';
  if MusicList.Count = 4 then
  begin
    TitleStr := MusicList[0];
    ArtStr := MusicList[1];
    AblumStr := MusicList[2];
    YearStr := MusicList[3];
  end;
  MusicList.Free;

  with frmPreView do
  begin
    s := 'Title=' + TitleStr;
    veMusic.Strings.Add( s );
    s := 'Artist=' + ArtStr;
    veMusic.Strings.Add( s );
    s := 'Album Title=' + AblumStr;
    veMusic.Strings.Add( s );
    s := 'Year=' + YearStr;
    veMusic.Strings.Add( s );
  end;
end;

{ TRestoreFilePreviewStopFace }

procedure TRestoreFilePreviewStopFace.Update;
begin
  frmPreView.tmrProgress.Enabled := False;
  frmPreView.pbPreview.Visible := False;
  frmPreView.pbPreview.Style := pbstNormal;
end;

{ TRestoreFilePreviewStartFace }

procedure TRestoreFilePreviewStartFace.Update;
begin
  frmPreView.tmrProgress.Enabled := True;
  frmPreView.plStatus.Visible := False;
end;

{ TShareSearchChangeFace }

function TShareSearchChangeFace.AddFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PShareSearchData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareSearch.GetNodeData( SelectNode );
    if not SelectData.IsFile or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstShareSearch.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstShareSearch.InsertNode( ParentNode, amAddChildFirst );
end;

function TShareSearchChangeFace.AddFolderNode: PVirtualNode;
var
  FolderName : string;
  SelectNode, DownNode : PVirtualNode;
  SelectData : PShareSearchData;
begin
  FolderName := ExtractFileName( FilePath );

    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareSearch.GetNodeData( SelectNode );
    if SelectData.IsFile or ( CompareText( SelectData.ShowName, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := VstShareSearch.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstShareSearch.AddChild( ParentNode );
end;

function TShareSearchChangeFace.AddNode: PVirtualNode;
begin
  if IsFile then
    Result := AddFileNode
  else
    Result := AddFolderNode;
end;

constructor TShareSearchChangeFace.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareSearchChangeFace.SetFileInfo(_FileSize: int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TShareSearchChangeFace.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareSearchChangeFace.Update;
begin
  VstShareSearch := frmRestoreExplorer.vstSearchFile;
end;

{ TShareSearchAddFace }

procedure TShareSearchAddFace.Update;
var
  MainIcon : Integer;
  RestoreSearchNode : PVirtualNode;
  RestoreSearchData : PShareSearchData;
begin
    // 搜索取消
  if not RestoreSearch_IsShow then
    Exit;

  inherited;

    // 选择图标
  if IsFile then
    MainIcon := MyIcon.getIconByFileExt( FilePath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

    // 添加节点
  ParentNode := VstShareSearch.RootNode;
  RestoreSearchNode := AddNode;
  RestoreSearchData := VstShareSearch.GetNodeData( RestoreSearchNode );
  RestoreSearchData.FilePath := FilePath;
  RestoreSearchData.IsFile := IsFile;
  RestoreSearchData.FileSize := FileSize;
  RestoreSearchData.FileTime := FileTime;
  RestoreSearchData.ShowName := ExtractFileName( FilePath );
  RestoreSearchData.ShowIcon := MainIcon;

    // 可以展开
  if not IsFile then
    VstShareSearch.HasChildren[ RestoreSearchNode ] := True;
end;

{ TShareExplorerStatusChangeFace }

procedure TShareSearchStatusChangeFace.Update;
begin
  plStatus := frmRestoreExplorer.plSearchStatus;
  lbStatus := frmRestoreExplorer.lbSearchStatus;
  pbSearch := frmRestoreExplorer.pbSearch;

  btnSearch := frmRestoreExplorer.btnSearch;
  btnStop := frmRestoreExplorer.btnStopSearch;
end;

{ TShareExplorerStopFace }

procedure TShareSearchStopFace.Update;
begin
  inherited;

  frmRestoreExplorer.tmrShowSearching.Enabled := False;
  pbSearch.Visible := False;
  pbSearch.Style := pbstNormal;

  btnStop.Visible := False;
  btnSearch.Visible := True;

  RestoreSearch_IsShow := False;

  frmRestoreExplorer.vstSearchFile.Refresh;
end;

{ TShareExplorerBusyFace }

procedure TShareSearchBusyFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_Busy;
  plStatus.Visible := True;
end;

{ TShareExplorerNotConnFace }

procedure TShareSearchNotConnFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_NotConn;
  plStatus.Visible := True;
end;

procedure TShareSearchStartFace.Update;
begin
  inherited;

  frmRestoreExplorer.tmrShowSearching.Enabled := True;
  plStatus.Visible := False;

  btnSearch.Visible := False;
  btnStop.Enabled := True;
  btnStop.Visible := True;

  RestoreSearch_IsShow := True;
end;

{ TShareSearchExplorerAddFace }

function TShareSearchExplorerAddFace.FindParentNode: Boolean;
var
  ParentPath : string;
  SelectNode : PVirtualNode;
  SelectData : PShareSearchData;
begin
  Result := False;
  ParentPath := ExtractFileDir( FilePath );

  SelectNode := VsTShareSearch.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VsTShareSearch.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.FilePath = ParentPath then
    begin
      ParentNode := SelectNode;
      Result := True;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) and
       VsTShareSearch.Expanded[ SelectNode ]
    then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TShareSearchExplorerAddFace.RemoveRootExist;
var
  SelectNode : PVirtualNode;
  SelectData : PShareSearchData;
begin
  SelectNode := VsTShareSearch.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VsTShareSearch.GetNodeData( SelectNode );

      // 删除同名的根节点
    if not SelectData.IsFile and ( SelectData.FilePath = FilePath ) then
    begin
      VsTShareSearch.DeleteNode( SelectNode );
      Break;
    end
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TShareSearchExplorerAddFace.Update;
var
  RestoreExplorerNode : PVirtualNode;
  RestoreExplorerData : PShareSearchData;
begin
  inherited;

  if not FindParentNode then
    Exit;

  RestoreExplorerNode := AddNode;
  if not IsFile then
    VsTShareSearch.HasChildren[ RestoreExplorerNode ] := True;
  RestoreExplorerData := VsTShareSearch.GetNodeData( RestoreExplorerNode );
  RestoreExplorerData.FilePath := FilePath;
  RestoreExplorerData.IsFile := IsFile;
  RestoreExplorerData.FileSize := FileSize;
  RestoreExplorerData.FileTime := FileTime;
  RestoreExplorerData.ShowName := ExtractFileName( FilePath );
  if IsFile then
    RestoreExplorerData.ShowIcon := MyIcon.getIconByFileExt( FilePath )
  else
    RestoreExplorerData.ShowIcon := MyShellIconUtil.getFolderIcon;
  ParentNode.ChildCount := ParentNode.ChildCount + 1;
  if not VsTShareSearch.Expanded[ ParentNode ] then
    VsTShareSearch.Expanded[ ParentNode ] := True;

    // 删除存在的根节点
  RemoveRootExist;
end;

{ TSharePreivewBusyFace }

procedure TSharePreivewBusyFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_Busy;
  frmPreView.plStatus.Visible := True;
end;

{ TSharePreivewNotConnFace }

procedure TSharePreivewNotConnFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_NotConn;
  frmPreView.plStatus.Visible := True;
end;

{ TShareDownRefreshIconFace }

procedure TShareDownRefreshIconFace.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  if ShareDownData.IsFile then
    ShareDownData.MainIcon := MyIcon.getIconByFilePath( ShareDownData.SavePath );
  RefreshNode;
end;

end.
