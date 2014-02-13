unit UMyReceiveFaceInfo;

interface

uses UChangeInfo, comctrls, UMyUtil, UIconUtil, VirtualTrees, math,  RzTabs, SysUtils;

type

{$Region ' 数据结构 ' }

  TReceiveItemData = record
  public
    ItemID : WideString;  // ID
    OwnerID, OwnerName : WideString; // 接收源
    IsFile : Boolean;
    IsReceiving, IsCompleted, IsCancel, IsZip : Boolean; // 状态信息
    IsOnline : Boolean;  // Pc 状态
    SavePath : WideString; // 位置
  public   // 根状态信息
    IsWrite, IsExist : Boolean; // 接收路径状态
    AvailableSpace : Int64; // 可用空间
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
    Percentage : Integer;
    Speed : Integer; // 传输速度
  public
    IsNewReceive : Boolean;
    ReceiveTime : TDateTime;
  public
    MainName, DesName : WideString;
    NodeStatus : WideString;
    MainIcon : Integer;
  end;
  PReceiveItemData = ^TReceiveItemData;

{$EndRegion}

{$Region ' 接收路径 增删 ' }

    // 父类
  TReceiveRootItemChangeFace = class( TFaceChangeInfo )
  public
    vstFileReceive : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveRootItemWriteFace = class( TReceiveRootItemChangeFace )
  public
    RootPath : string;
  protected
    ReceiveRootItemNode : PVirtualNode;
    ReceiveRootItemData : PReceiveItemData;
  public
    constructor Create( _RootPath : string );
  protected
    function FindReceiveRootItemNode : Boolean;
  protected
    procedure RefreshRootNode;
  end;

    // 添加
  TReceiveRootItemAddFace = class( TReceiveRootItemWriteFace )
  private
    AvailableSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TReceiveRootItemRemoveFace = class( TReceiveRootItemWriteFace )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 接收路径 状态 ' }

    // 修改
  TReceiveRootItemSetAvailableSpaceFace = class( TReceiveRootItemWriteFace )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveRootItemSetIsExistFace = class( TReceiveRootItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveRootItemSetIsWriteFace = class( TReceiveRootItemWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 发送路径 增删 ' }

    // 修改
  TReceiveItemWriteFace = class( TReceiveRootItemWriteFace )
  public
    SourcePath, OwnerID : string;
  protected
    ReceiveItemNode : PVirtualNode;
    ReceiveItemData : PReceiveItemData;
  public
    procedure SetSourcePath( _SourcePath, _OwnerID : string );
  protected
    function FindReceiveItemNode : Boolean;
  protected
    procedure RefreshItemNode;
    procedure RefreshPercentage;
  end;

      // 添加
  TReceiveItemAddFace = class( TReceiveItemWriteFace )
  public
    IsFile, IsCompleted, IsCancel, IsZip : boolean;
    IsOnline : Boolean;
    OwnerName : string;
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    IsNewReceive : Boolean;
    ReceiveTime : TDateTime;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetStatusInfo( _IsCompleted, _IsCancel : boolean );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetOwnerInfo( _OwnerName : string; _IsOnline : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure SetIsNewReceive( _IsNewReceive : Boolean );
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TReceiveItemRemoveFace = class( TReceiveItemWriteFace )
  protected
    procedure Update;override;
  end;



{$EndRegion}

{$Region ' 发送路径 空间信息 ' }

    // 修改
  TReceiveItemSetSpaceInfoFace = class( TReceiveItemWriteFace )
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

      // 修改
  TReceiveItemSetAddCompletedSpaceFace = class( TReceiveItemWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;





{$EndRegion}

{$Region ' 发送路径 状态信息 ' }

    // 修改
  TReceiveItemSetIsReceivingFace = class( TReceiveItemWriteFace )
  public
    IsReceiving : boolean;
  public
    procedure SetIsReceiving( _IsReceiving : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetIsCompletedFace = class( TReceiveItemWriteFace )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;


    // 修改
  TReceiveItemSetIsCancelFace = class( TReceiveItemWriteFace )
  public
    IsCancel : boolean;
  public
    procedure SetIsCancel( _IsCancel : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetSpeedFace = class( TReceiveItemWriteFace )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetStatusFace = class( TReceiveItemWriteFace )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
  protected
    procedure Update;override;
  end;

  TReceiveItemSetReceiveTimeFace = class( TReceiveItemWriteFace )
  public
    ReceiveTime : TDateTime;
  public
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
  protected
    procedure Update;override;
  end;

  TReceiveItemRefreshIconFace = class( TReceiveItemWriteFace )
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetPcIsOnlineFace = class( TReceiveRootItemChangeFace )
  public
    OnlinePcID : string;
    IsOnline : boolean;
  public
    constructor Create( _OnlinePcID : string );
    procedure SetIsOnline( _IsOnline : boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 发送路径 读取信息 ' }

  ReceiveItemFaceReadUtil = class
  public
    class function ReadRootStatus( Node : PVirtualNode ): string;
    class function ReadItemStatus( Node : PVirtualNode ): string;
  public
    class function ReadRootIcon( Node : PVirtualNode ): Integer;
    class function ReadItemIcon( Node : PVirtualNode ): Integer;
  public
    class function ReadHintStr( Node : PVirtualNode ): string;
  end;

{$EndRegion}

{$Region ' 新增接收根路径 ' }

  TReceiveRootNewCountChangeFace = class( TFaceChangeInfo )
  protected
    tsFileReceive : TRzTabSheet;
  protected
    procedure Update;override;
  protected
    function getIsEnable : Boolean;
    procedure RefreshShowCaption;
  end;

  TReceiveRootNewCountAddFace = class( TReceiveRootNewCountChangeFace )
  protected
    procedure Update;override;
  end;

  TReceiveRootNewCountClearFace = class( TReceiveRootNewCountChangeFace )
  protected
    procedure Update;override;
  end;

  TReceiveRootNewCountReadFace = class( TReceiveRootNewCountChangeFace )
  public
    NewCount : Integer;
  public
    constructor Create( _NewCount : Integer );
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  BackupIcon_Folder = 5;
  BackupIcon_PcOffline = 0;
  BackupIcon_PcOnline = 1;
  BackupIcon_MyComputer = 8;
  BackupIcon_ReceiveNew = 9;

const
  ReceiveNodeStatus_Waiting = 'Waiting';
  ReceiveNodeStatus_Receiving = 'Receiving';
  ReceiveNodeStatus_Stop = '';

  ReceiveStatusShow_NotExist = 'Not Exist';
  ReceiveStatusShow_NotWrite = 'Cannot Write';

  ReceiveStatusShow_PcOffline = 'Offline';
  ReceiveStatusShow_Waiting = 'Waiting';
  ReceiveStatusShow_Receiving = 'Receiving';
  ReceiveStatusShow_Cancel = 'Cancel';
  ReceiveStatusShow_Completed = 'Receive Completed';
  ReceiveStatusShow_InCompleted = 'Incompleted';

const
  ShowCaption_ReceivePage = 'Receive Files From Netowrk Computers';

implementation

uses UFormSetting, UMainForm;

{ TCloudPathChangeFace }

procedure TReceiveRootItemChangeFace.Update;
begin
  vstFileReceive := frmMainForm.vstFileReceive;
end;

{ TCloudPathWriteFace }

constructor TReceiveRootItemWriteFace.Create(_RootPath: string);
begin
  RootPath := _RootPath;
end;

function TReceiveRootItemWriteFace.FindReceiveRootItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PReceiveItemData;
begin
  Result := False;
  SelectNode := vstFileReceive.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstFileReceive.GetNodeData( SelectNode );
    if SelectData.ItemID = RootPath then
    begin
      Result := True;
      ReceiveRootItemNode := SelectNode;
      ReceiveRootItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TReceiveRootItemWriteFace.RefreshRootNode;
begin
  vstFileReceive.RepaintNode( ReceiveRootItemNode );
end;

{ TCloudPathAddFace }

procedure TReceiveRootItemAddFace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TReceiveRootItemAddFace.Update;
begin
  inherited;

  if FindReceiveRootItemNode then
    Exit;

  ReceiveRootItemNode := vstFileReceive.AddChild( vstFileReceive.RootNode );
  ReceiveRootItemNode.NodeHeight := 30;

  ReceiveRootItemData := vstFileReceive.GetNodeData( ReceiveRootItemNode );
  ReceiveRootItemData.ItemID := RootPath;
  ReceiveRootItemData.IsWrite := True;
  ReceiveRootItemData.IsExist := True;
  ReceiveRootItemData.AvailableSpace := AvailableSpace;
  ReceiveRootItemData.MainName := Format( DesName_Show, [RootPath] );
  ReceiveRootItemData.NodeStatus := '';
  ReceiveRootItemData.MainIcon := BackupIcon_MyComputer;
  ReceiveRootItemData.SavePath := RootPath;
end;

{ TCloudPathRemoveFace }

procedure TReceiveRootItemRemoveFace.Update;
begin
  inherited;

  if not FindReceiveRootItemNode then
    Exit;

  vstFileReceive.DeleteNode( ReceiveRootItemNode );
end;

{ TReceiveItemWriteFace }

procedure TReceiveItemWriteFace.RefreshItemNode;
begin
  vstFileReceive.RepaintNode( ReceiveItemNode );
end;

procedure TReceiveItemWriteFace.RefreshPercentage;
begin
  ReceiveItemData.Percentage := MyPercentage.getPercent( ReceiveItemData.CompletedSize, ReceiveItemData.ItemSize );
end;

procedure TReceiveItemWriteFace.SetSourcePath( _SourcePath, _OwnerID : string );
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;


function TReceiveItemWriteFace.FindReceiveItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PReceiveItemData;
begin
  Result := False;
  if not FindReceiveRootItemNode then
    Exit;
  SelectNode := ReceiveRootItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFileReceive.GetNodeData( SelectNode );
    if ( SelectData.ItemID = SourcePath ) and ( SelectData.OwnerID = OwnerID ) then
    begin
      Result := True;
      ReceiveItemNode := SelectNode;
      ReceiveItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TReceiveItemAddFace }

procedure TReceiveItemAddFace.SetStatusInfo(_IsCompleted, _IsCancel: boolean);
begin
  IsCompleted := _IsCompleted;
  IsCancel := _IsCancel;
end;

procedure TReceiveItemAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TReceiveItemAddFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemAddFace.SetIsNewReceive(_IsNewReceive: Boolean);
begin
  IsNewReceive := _IsNewReceive;
end;

procedure TReceiveItemAddFace.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveItemAddFace.SetOwnerInfo(_OwnerName: string;
  _IsOnline : Boolean);
begin
  OwnerName := _OwnerName;
  IsOnline := _IsOnline;
end;

procedure TReceiveItemAddFace.SetReceiveTime(_ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemAddFace.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

procedure TReceiveItemAddFace.Update;
begin
  inherited;

  if FindReceiveItemNode then
    Exit;

  ReceiveItemNode := vstFileReceive.AddChild( ReceiveRootItemNode );
  ReceiveItemData := vstFileReceive.GetNodeData( ReceiveItemNode );
  ReceiveItemData.ItemID := SourcePath;
  ReceiveItemData.OwnerID := OwnerID;
  ReceiveItemData.OwnerName := OwnerName;
  ReceiveItemData.IsFile := IsFile;
  ReceiveItemData.IsOnline := IsOnline;
  ReceiveItemData.IsCancel := IsCancel;
  ReceiveItemData.IsCompleted := IsCompleted;
  ReceiveItemData.IsReceiving := False;
  ReceiveItemData.IsZip := IsZip;
  ReceiveItemData.FileCount := FileCount;
  ReceiveItemData.ItemSize := ItemSize;
  ReceiveItemData.CompletedSize := CompletedSpace;
  ReceiveItemData.IsNewReceive := IsNewReceive;
  ReceiveItemData.ReceiveTime := ReceiveTime;
  ReceiveItemData.Speed := 0;
  ReceiveItemData.SavePath := SavePath;
  ReceiveItemData.MainName := SourcePath;
  ReceiveItemData.NodeStatus := ReceiveNodeStatus_Stop;
  if IsFile then
  begin
    if FileExists( SavePath ) then
      ReceiveItemData.MainIcon := MyIcon.getIconByFilePath( SavePath )
    else
      ReceiveItemData.MainIcon := MyIcon.getIconByFileExt( SourcePath )
  end
  else
    ReceiveItemData.MainIcon := MyShellIconUtil.getFolderIcon;

  vstFileReceive.Expanded[ ReceiveRootItemNode ] := True;

  RefreshPercentage;

  if IsCompleted then
    frmMainForm.tbtnReceiveClear.Enabled := True;
end;

{ TReceiveItemRemoveFace }

procedure TReceiveItemRemoveFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;

  vstFileReceive.DeleteNode( ReceiveItemNode );
end;

{ TReceiveItemSetSpaceInfoFace }

procedure TReceiveItemSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.FileCount := FileCount;
  ReceiveItemData.ItemSize := ItemSize;
  ReceiveItemData.CompletedSize := CompletedSpace;

  RefreshPercentage;
  RefreshItemNode;
end;

{ TReceiveItemSetAddCompletedSpaceFace }

procedure TReceiveItemSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TReceiveItemSetAddCompletedSpaceFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.CompletedSize := ReceiveItemData.CompletedSize + AddCompletedSpace;
  RefreshPercentage;
  RefreshItemNode;
end;

{ TReceiveItemSetIsReceivingFace }

procedure TReceiveItemSetIsReceivingFace.SetIsReceiving( _IsReceiving : boolean );
begin
  IsReceiving := _IsReceiving;
end;

procedure TReceiveItemSetIsReceivingFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.IsReceiving := IsReceiving;
  RefreshItemNode;
end;

{ TReceiveItemSetIsCompletedFace }

procedure TReceiveItemSetIsCompletedFace.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TReceiveItemSetIsCompletedFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.IsCompleted := IsCompleted;
  RefreshItemNode;

  if IsCompleted then
    frmMainForm.tbtnReceiveClear.Enabled := True;
end;

{ TReceiveItemSetIsCancelFace }

procedure TReceiveItemSetIsCancelFace.SetIsCancel( _IsCancel : boolean );
begin
  IsCancel := _IsCancel;
end;

procedure TReceiveItemSetIsCancelFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.IsCancel := IsCancel;
  RefreshItemNode;
end;




{ TReceiveItemSetPcIsOnlineFace }

constructor TReceiveItemSetPcIsOnlineFace.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TReceiveItemSetPcIsOnlineFace.SetIsOnline(_IsOnline: boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TReceiveItemSetPcIsOnlineFace.Update;
var
  RootNode, SelectNode : PVirtualNode;
  NodeData : PReceiveItemData;
begin
  inherited;

  RootNode := vstFileReceive.RootNode.FirstChild;
  while Assigned( RootNode ) do
  begin
    SelectNode := RootNode.FirstChild;
    while Assigned( SelectNode ) do
    begin
      NodeData := vstFileReceive.GetNodeData( SelectNode );
      if NodeData.OwnerID = OnlinePcID then
      begin
        NodeData.IsOnline := IsOnline;
        vstFileReceive.RepaintNode( SelectNode );
      end;
      SelectNode := SelectNode.NextSibling;
    end;
    RootNode := RootNode.NextSibling;
  end;
end;

{ ReceiveItemFaceReadUtil }

class function ReceiveItemFaceReadUtil.ReadHintStr(Node: PVirtualNode): string;
var
  NodeData : PReceiveItemData;
begin
  NodeData := frmMainForm.vstFileReceive.GetNodeData( Node );
  Result := MyHtmlHintShowStr.getHintRowNext( 'Remote Files', NodeData.OwnerName + ' ' + Format( DesName_Show, [NodeData.MainName] ) );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Receive To', 'My Computer ' + Format( DesName_Show, [NodeData.SavePath] ) );
  if NodeData.FileCount > 0 then
    Result := Result + MyHtmlHintShowStr.getHintRow( 'File Quantity', MyCount.getCountStr( NodeData.FileCount ) );
end;

class function ReceiveItemFaceReadUtil.ReadItemIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PReceiveItemData;
begin
  NodeData := frmMainForm.vstFileReceive.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if NodeData.IsCancel or not NodeData.IsOnline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.NodeStatus = ReceiveNodeStatus_Waiting then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = ReceiveNodeStatus_Receiving then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

class function ReceiveItemFaceReadUtil.ReadItemStatus(
  Node: PVirtualNode): string;
var
  NodeData : PReceiveItemData;
begin
  NodeData := frmMainForm.vstFileReceive.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := ReceiveStatusShow_Completed
  else
  if NodeData.IsCancel then
    Result := ReceiveStatusShow_Cancel
  else
  if not NodeData.IsOnline then
    Result := ReceiveStatusShow_PcOffline
  else
  if NodeData.NodeStatus = ReceiveNodeStatus_Receiving then
  begin
    if NodeData.Speed > 0 then
      Result := MySpeed.getSpeedStr( NodeData.Speed )
    else
      Result := NodeData.NodeStatus;
    if NodeData.Percentage < 100 then
      Result := Result + '   ' + MyPercentage.getPercentageStr( NodeData.Percentage );
  end
  else
  if NodeData.NodeStatus <> '' then
    Result := NodeData.NodeStatus
  else
  begin
    Result := ReceiveStatusShow_InCompleted;
    if NodeData.Percentage < 100 then
      Result := Result + ' ( ' + MyPercentage.getPercentageStr( NodeData.Percentage ) + ' )';
  end;
end;

class function ReceiveItemFaceReadUtil.ReadRootIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PReceiveItemData;
begin
  NodeData := frmMainForm.vstFileReceive.GetNodeData( Node );
  if not NodeData.IsExist or not NodeData.IsWrite then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MyShellTransActionIconUtil.getSpace
  else
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

class function ReceiveItemFaceReadUtil.ReadRootStatus(
  Node: PVirtualNode): string;
var
  NodeData : PReceiveItemData;
begin
  NodeData := frmMainForm.vstFileReceive.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := ReceiveStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := ReceiveStatusShow_NotWrite
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MySize.getFileSizeStr( NodeData.AvailableSpace ) + ' Available'
  else
    Result := ReceiveStatusShow_NotExist;
end;

{ TReceiveItemSetSpeedFace }

procedure TReceiveItemSetSpeedFace.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TReceiveItemSetSpeedFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;

  ReceiveItemData.Speed := Speed;
  RefreshItemNode;
end;

{ TReceiveItemSetStatusFace }

procedure TReceiveItemSetStatusFace.SetStatus( _Status : string );
begin
  Status := _Status;
end;

procedure TReceiveItemSetStatusFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.NodeStatus := Status;
  RefreshItemNode;
end;

{ TReceiveRootItemSetAvailableSpaceFace }

procedure TReceiveRootItemSetAvailableSpaceFace.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TReceiveRootItemSetAvailableSpaceFace.Update;
begin
  inherited;

  if not FindReceiveRootItemNode then
    Exit;
  ReceiveRootItemData.AvailableSpace := AvailableSpace;
  RefreshRootNode;
end;

{ TReceiveRootItemSetIsExistFace }

procedure TReceiveRootItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TReceiveRootItemSetIsExistFace.Update;
begin
  inherited;

  if not FindReceiveRootItemNode then
    Exit;
  ReceiveRootItemData.IsExist := IsExist;
  RefreshRootNode;
end;

{ TReceiveRootItemSetIsWriteFace }

procedure TReceiveRootItemSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TReceiveRootItemSetIsWriteFace.Update;
begin
  inherited;

  if not FindReceiveRootItemNode then
    Exit;
  ReceiveRootItemData.IsWrite := IsWrite;
  RefreshRootNode;
end;



{ TReceiveRootNewCountChangeFace }

function TReceiveRootNewCountChangeFace.getIsEnable: Boolean;
begin
  Result := False;
//  Result := frmMainForm.PcFileTransfer.ActivePage <> tsFileReceive;
end;

procedure TReceiveRootNewCountChangeFace.RefreshShowCaption;
var
  ShowInt : Integer;
  ShowStr : string;
begin
  ShowInt := tsFileReceive.Tag;
  ShowStr := ShowCaption_ReceivePage;
  if ShowInt > 0 then
  begin
    ShowStr := ShowStr + '   ( ' + IntToStr( ShowInt ) + ' new item';
    if ShowInt > 1 then
      ShowStr := ShowStr + 's';
    ShowStr := ShowStr + ' )';
  end;
  tsFileReceive.Caption := ShowStr;
end;

procedure TReceiveRootNewCountChangeFace.Update;
begin
//  tsFileReceive := frmMainForm.tsFileReceive;
end;

{ TReceiveRootNewCountReadFace }

constructor TReceiveRootNewCountReadFace.Create(_NewCount: Integer);
begin
  NewCount := _NewCount;
end;

procedure TReceiveRootNewCountReadFace.Update;
begin
  inherited;
//  if not getIsEnable then
//    Exit;
//  tsFileReceive.Tag := NewCount;
//  RefreshShowCaption;
end;

{ TReceiveRootNewCountAddFace }

procedure TReceiveRootNewCountAddFace.Update;
begin
  inherited;
//  if not getIsEnable then
//    Exit;
//  tsFileReceive.Tag := tsFileReceive.Tag + 1;
//  RefreshShowCaption;
end;

{ TReceiveRootNewCountClearFace }

procedure TReceiveRootNewCountClearFace.Update;
begin
  inherited;
//  tsFileReceive.Tag := 0;
//  RefreshShowCaption;
end;

{ TReceiveItemSetReceiveTimeFace }

procedure TReceiveItemSetReceiveTimeFace.SetReceiveTime(
  _ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemSetReceiveTimeFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  ReceiveItemData.ReceiveTime := ReceiveTime;
  RefreshItemNode;
end;

{ TReceiveItemRefreshIconFace }

procedure TReceiveItemRefreshIconFace.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;

  if ReceiveItemData.IsFile then
    ReceiveItemData.MainIcon := MyIcon.getIconByFilePath( ReceiveItemData.SavePath );

  RefreshItemNode;
end;

end.
