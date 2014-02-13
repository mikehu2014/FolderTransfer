unit UMyShareDownXmlInfo;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils;

type

{$Region ' 数据修改 ' }

    // 父类
  TShareDownChangeXml = class( TXmlChangeInfo )
  protected
    MyShareDownNode : IXMLNode;
    ShareDownNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownWriteXml = class( TShareDownChangeXml )
  public
    SharePath, OwnerPcID : string;
  protected
    ShareDownIndex : Integer;
    ShareDownNode : IXMLNode;
  public
    constructor Create( _SharePath, _OwnerPcID : string );
  protected
    function FindShareDownNode: Boolean;
  end;

  {$Region ' 增删操作 ' }

    // 添加
  TShareDownAddXml = class( TShareDownWriteXml )
  public
    IsFile, IsCompleted : Boolean;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean ) ;
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  protected
    procedure RefreshShareDownCount;
    procedure AddItemInfo;virtual;abstract;
  end;

    // 添加 本地恢复
  TShareDownAddLocalXml = class( TShareDownAddXml )
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络恢复
  TShareDownAddNetworkXml = class( TShareDownAddXml )
  protected
    procedure AddItemInfo;override;
  end;

    // 删除
  TShareDownRemoveXml = class( TShareDownWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 状态信息 ' }

      // 修改
  TShareDownSetIsCompletedXml = class( TShareDownWriteXml )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 空间信息 ' }

    // 修改
  TShareDownSetSpaceInfoXml = class( TShareDownWriteXml )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownSetAddCompletedSpaceXml = class( TShareDownWriteXml )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TShareDownSetCompletedSizeXml = class( TShareDownWriteXml )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

    // 父类
  TShareDownContinusChangeXml = class( TShareDownWriteXml )
  protected
    ShareDownContinusNodeList : IXMLNode;
  protected
    function FindShareDownContinusNodeList : Boolean;
  end;

    // 修改
  TShareDownContinusWriteXml = class( TShareDownContinusChangeXml )
  public
    FilePath : string;
  protected
    ShareDownContinusIndex : Integer;
    ShareDownContinusNode : IXMLNode;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindShareDownContinusNode: Boolean;
  end;

      // 添加
  TShareDownContinusAddXml = class( TShareDownContinusWriteXml )
  public
    FileSize, Postion : int64;
  public
    FileTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize, _Postion : int64 );
    procedure SetFileTime( _FileTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TShareDownContinusRemoveXml = class( TShareDownContinusWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 父类
  TRestoreSpeedChangeXml = class( TXmlChangeInfo )
  public
    MyRestoreDownNode : IXMLNode;
    RestoreSpeedNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 速度限制
  TRestoreSpeedLimitXml = class( TRestoreSpeedChangeXml )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitXml( _LimitValue, _LimitType : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 日志信息 ' }

      // 父类
  TShareDownCompletedLogChangeXml = class( TShareDownWriteXml )
  protected
    SendCompletedLogNodeList : IXMLNode;
  protected
    function FindSendCompletedLogNodeList : Boolean;
  end;

    // 添加 已完成
  TShareDownLogAddCompletedXml = class( TShareDownCompletedLogChangeXml )
  public
    SendTime : TDateTime;
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSendTime( _SendTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 清空 已完成
  TShareDownLogClearCompletedXml = class( TShareDownCompletedLogChangeXml )
  protected
    procedure Update;override;
  end;



      // 父类
  TShareDownIncompletedLogChangeXml = class( TShareDownWriteXml )
  protected
    SendIncompletedLogNodeList : IXMLNode;
  protected
    function FindSendIncompletedLogNodeList : Boolean;
  end;


    // 添加 未完成
  TShareDownLogAddIncompletedXml = class( TShareDownIncompletedLogChangeXml )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 清空
  TShareDownLogClearIncompletedXml = class( TShareDownIncompletedLogChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}


  {$Region ' 浏览历史信息 ' }

      // 父类
  TShareExplorerHistoryChangeXml = class( TXmlChangeInfo )
  protected
    MyShareDownNode : IXMLNode;
    ShareExplorerHistoryNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

      // 添加
  TShareExplorerHistoryAddXml = class( TShareExplorerHistoryChangeXml )
  public
    OwnerID, FilePath : string;
  public
    constructor Create( _OwnerID, _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TShareExplorerHistoryRemoveXml = class( TShareExplorerHistoryChangeXml )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;

    // 清空
  TShareExplorerHistoryClearXml = class( TShareExplorerHistoryChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 保存路径历史 ' }

  TShareSavePathChangeXml = class( TXmlChangeInfo )
  protected
    MyShareDownNode : IXMLNode;
    ShareSavePathListNode : IXMLNode;
  protected
    procedure Update;override;
  end;

  TShareSavePathAddXml = class( TShareSavePathChangeXml )
  public
    SavePath : string;
  public
    constructor Create( _SavePath : string );
  protected
    procedure Update;override;
  end;

  TShareSavePathRemoveXml = class( TShareSavePathChangeXml )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;

  TShareSavePathClearXml = class( TShareSavePathChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TShareDownContinusReadXml = class
  public
    ShareDownContinusNode : IXMLNode;
    SharePath, OwnerID : string;
  public
    constructor Create( _ShareDownContinusNode : IXMLNode );
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure Update;
  end;

    // 读取
  TShareDownCompletedLogReadXml = class
  public
    ShareDownCompletedNode : IXMLNode;
    SharePath, OwnerID : string;
  public
    constructor Create( _ShareDownCompletedNode : IXMLNode );
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure Update;
  end;

    // 读取
  TShareDownIncompletedLogReadXml = class
  public
    ShareDownIncompletedNode : IXMLNode;
    SharePath, OwnerID : string;
  public
    constructor Create( _ShareDownIncompletedNode : IXMLNode );
    procedure SetItemInfo( _SharePath, _OwnerID : string );
    procedure Update;
  end;


    // 读取 下载节点
  TShareDownReadXml = class
  public
    ShareDownNode : IXMLNode;
    SharePath, OwnerID : string;
  public
    constructor Create( _ShareDownNode : IXMLNode );
    procedure Update;
  private
    procedure ReadShareDownContinus;
    procedure ReadShareDownCompletedLog;
    procedure ReadShareDownIncompletedLog;
  end;

        // 读取
  TShareExplorerHistoryReadXml = class
  public
    ShareExplorerHistoryNode : IXMLNode;
  public
    constructor Create( _ShareExplorerHistoryNode : IXMLNode );
    procedure Update;
  end;

  TShareSaveHistoryReadXml = class
  public
    ShareSaveHistoryNode : IXMLNode;
  public
    constructor Create( _ShareSaveHistoryNode : IXMLNode );
    procedure Update;
  end;


     // 读取 备份速度
  TRestoreSpeedReadXml = class
  public
    RestoreSpeedNode : IXMLNode;
  public
    constructor Create( _RestoreSpeedNode : IXMLNode );
    procedure Update;
  end;

    // 读取 恢复下载
  TMyShareDownReadXml = class
  private
    MyShareDownNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadShareSaveHistoryList;
    procedure ReadShareDownList;
    procedure ReadhShareExplorerHistory;
    procedure ReadShareDownCount;
    procedure ReadRetoreSpeed;
  end;

{$EndRegion}

const
  RestoreDownType_Local = 'l';
  RestoreDownType_Network = 'n';

const
  Xml_MyShareDownInfo = 'msdi';
  Xml_ShareDownList = 'sdl';
  Xml_ShareDownCount = 'sdc';

  Xml_SharePath = 'sp';
  Xml_OwnerPcID = 'op';
  Xml_IsFile = 'if';
  Xml_IsCompleted = 'ic';
  Xml_FileCount = 'fc';
  Xml_FileSize = 'fs';
  Xml_CompletedSize = 'cs';
  Xml_SavePath = 'spt';
  Xml_RestoreDownType = 'rdt';
  Xml_ShareDownContinusList = 'sdcl';

  Xml_FilePath = 'fp';
//    Xml_FileSize = 'fs';
  Xml_Postion = 'pt';
  Xml_FileTime = 'ft';

const
  Xml_ShareDownCompletedLogList = 'sdcll';
  Xml_ShareDownTime = 'sdt';

  Xml_ShareDownIncompletedLogList = 'sdicll';

const
  Xml_ShareExplorerHistoryList = 'sehl';
  Xml_OwnerID = 'oid';
//  Xml_FilePath = 'fp';

const
  Xml_ShareSavePathList = 'sspl';
//  Xml_SavePath = 'sp';

const
  Xml_RestoreSpeed = 'rs';
  Xml_IsLimit = 'il';
  Xml_LimitType = 'lt';
  Xml_LimitValue = 'lv';


var
  MyShareDown_ShareDownCount : Integer = 0;

implementation

uses UMyShareDownApiInfo, UMyUtil;

{ TRestoreDownChangeXml }

procedure TShareDownChangeXml.Update;
begin
  MyShareDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyShareDownInfo );
  ShareDownNodeList := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareDownList );
end;

{ TRestoreDownWriteXml }

constructor TShareDownWriteXml.Create( _SharePath, _OwnerPcID : string );
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
end;


function TShareDownWriteXml.FindShareDownNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to ShareDownNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareDownNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_SharePath ) = SharePath ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_OwnerPcID ) = OwnerPcID )
    then
    begin
      Result := True;
      ShareDownIndex := i;
      ShareDownNode := ShareDownNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreDownAddXml }

procedure TShareDownAddXml.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownAddXml.Update;
begin
  inherited;

  if FindShareDownNode then
    Exit;

  ShareDownNode := MyXmlUtil.AddListChild( ShareDownNodeList );
  MyXmlUtil.AddChild( ShareDownNode, Xml_SharePath, SharePath );
  MyXmlUtil.AddChild( ShareDownNode, Xml_OwnerPcID, OwnerPcID );
  MyXmlUtil.AddChild( ShareDownNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( ShareDownNode, Xml_IsCompleted, IsCompleted );
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, CompletedSize );
  MyXmlUtil.AddChild( ShareDownNode, Xml_SavePath, SavePath );

  RefreshShareDownCount;

  AddItemInfo;
end;

procedure TShareDownAddXml.RefreshShareDownCount;
var
  LastShareDownCount : Integer;
begin
  LastShareDownCount := MyXmlUtil.GetChildIntValue( MyShareDownNode, Xml_ShareDownCount );
  LastShareDownCount := LastShareDownCount + 1;
  MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareDownCount, LastShareDownCount );
  inc( MyShareDown_ShareDownCount );
end;

procedure TShareDownAddXml.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShareDownAddXml.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveXml }

procedure TShareDownRemoveXml.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  MyXmlUtil.DeleteListChild( ShareDownNodeList, ShareDownIndex );
end;



{ TRestoreDownReadXmlHandle }

procedure TMyShareDownReadXml.ReadhShareExplorerHistory;
var
  ShareExplorerHistoryNodeList : IXMLNode;
  i : Integer;
  ShareExplorerHistoryNode : IXMLNode;
  ShareExplorerHistoryReadXml : TShareExplorerHistoryReadXml;
begin
  ShareExplorerHistoryNodeList := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareExplorerHistoryList );
  for i := 0 to ShareExplorerHistoryNodeList.ChildNodes.Count - 1 do
  begin
    ShareExplorerHistoryNode := ShareExplorerHistoryNodeList.ChildNodes[i];
    ShareExplorerHistoryReadXml := TShareExplorerHistoryReadXml.Create( ShareExplorerHistoryNode );
    ShareExplorerHistoryReadXml.Update;
    ShareExplorerHistoryReadXml.Free;
  end;
end;

procedure TMyShareDownReadXml.ReadRetoreSpeed;
var
  RestoreSpeedNode : IXMLNode;
  RestoreSpeedReadXml : TRestoreSpeedReadXml;
begin
  RestoreSpeedNode := MyXmlUtil.AddChild( MyShareDownNode, Xml_RestoreSpeed );

  RestoreSpeedReadXml := TRestoreSpeedReadXml.Create( RestoreSpeedNode );
  RestoreSpeedReadXml.Update;
  RestoreSpeedReadXml.Free;
end;

procedure TMyShareDownReadXml.ReadShareDownCount;
begin
  MyShareDown_ShareDownCount := MyXmlUtil.GetChildIntValue( MyShareDownNode, Xml_ShareDownCount );
end;

procedure TMyShareDownReadXml.ReadShareDownList;
var
  ShareDownNodeList : IXMLNode;
  i : Integer;
  ShareDownNode : IXMLNode;
  ShareDownReadXml : TShareDownReadXml;
begin
  ShareDownNodeList := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareDownList );
  for i := 0 to ShareDownNodeList.ChildNodes.Count - 1 do
  begin
    ShareDownNode := ShareDownNodeList.ChildNodes[i];
    ShareDownReadXml := TShareDownReadXml.Create( ShareDownNode );
    ShareDownReadXml.Update;
    ShareDownReadXml.Free;
  end;
end;

procedure TMyShareDownReadXml.ReadShareSaveHistoryList;
var
  ShareSavePathNodeList : IXMLNode;
  i : Integer;
  ShareSaveNode : IXMLNode;
  ShareSaveHistoryReadXml : TShareSaveHistoryReadXml;
begin
  ShareSavePathNodeList := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareSavePathList );
  for i := 0 to ShareSavePathNodeList.ChildNodes.Count - 1 do
  begin
    ShareSaveNode := ShareSavePathNodeList.ChildNodes[i];
    ShareSaveHistoryReadXml := TShareSaveHistoryReadXml.Create( ShareSaveNode );
    ShareSaveHistoryReadXml.Update;
    ShareSaveHistoryReadXml.Free;
  end;
end;


procedure TMyShareDownReadXml.Update;
begin
  MyShareDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyShareDownInfo );

  ReadShareSaveHistoryList;

  ReadShareDownList;

  ReadRetoreSpeed;

  ReadhShareExplorerHistory;

  ReadShareDownCount;
end;



{ RestoreDownNode }

constructor TShareDownReadXml.Create( _ShareDownNode : IXMLNode );
begin
  ShareDownNode := _ShareDownNode;
end;

procedure TShareDownReadXml.ReadShareDownCompletedLog;
var
  ShareDownCompletedNodeList : IXMLNode;
  i : Integer;
  ShareDownCompletedNode : IXMLNode;
  ShareDownCompletedLogReadXml : TShareDownCompletedLogReadXml;
begin
  ShareDownCompletedNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownCompletedLogList );
  for i := 0 to ShareDownCompletedNodeList.ChildNodes.Count - 1 do
  begin
    ShareDownCompletedNode := ShareDownCompletedNodeList.ChildNodes[i];
    ShareDownCompletedLogReadXml := TShareDownCompletedLogReadXml.Create( ShareDownCompletedNode );
    ShareDownCompletedLogReadXml.SetItemInfo( SharePath, OwnerID );
    ShareDownCompletedLogReadXml.Update;
    ShareDownCompletedLogReadXml.Free;
  end;
end;

procedure TShareDownReadXml.ReadShareDownContinus;
var
  ShareDownContinusNodeList : IXMLNode;
  i : Integer;
  ShareDownContinusNode : IXMLNode;
  ShareDownContinusReadXml : TShareDownContinusReadXml;
begin
  ShareDownContinusNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownContinusList );
  for i := 0 to ShareDownContinusNodeList.ChildNodes.Count - 1 do
  begin
    ShareDownContinusNode := ShareDownContinusNodeList.ChildNodes[i];
    ShareDownContinusReadXml := TShareDownContinusReadXml.Create( ShareDownContinusNode );
    ShareDownContinusReadXml.SetItemInfo( SharePath, OwnerID );
    ShareDownContinusReadXml.Update;
    ShareDownContinusReadXml.Free;
  end;
end;



procedure TShareDownReadXml.ReadShareDownIncompletedLog;
var
  ShareDownIncompletedNodeList : IXMLNode;
  i : Integer;
  ShareDownIncompletedNode : IXMLNode;
  ShareDownIncompletedLogReadXml : TShareDownIncompletedLogReadXml;
begin
  ShareDownIncompletedNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownIncompletedLogList );
  for i := 0 to ShareDownIncompletedNodeList.ChildNodes.Count - 1 do
  begin
    ShareDownIncompletedNode := ShareDownIncompletedNodeList.ChildNodes[i];
    ShareDownIncompletedLogReadXml := TShareDownIncompletedLogReadXml.Create( ShareDownIncompletedNode );
    ShareDownIncompletedLogReadXml.SetItemInfo( SharePath, OwnerID );
    ShareDownIncompletedLogReadXml.Update;
    ShareDownIncompletedLogReadXml.Free;
  end;
end;

procedure TShareDownReadXml.Update;
var
  IsFile, IsCompleted : Boolean;
  RestoreDownType : string;
  FileCount : integer;
  FileSize, CompletedSize : int64;
  SavePath : string;
  RestoreDownReadLocalHandle : TShareDownReadLocalHandle;
  RestoreDownReadNetworkHandle : TShareDownReadNetworkHandle;
begin
  SharePath := MyXmlUtil.GetChildValue( ShareDownNode, Xml_SharePath );
  OwnerID := MyXmlUtil.GetChildValue( ShareDownNode, Xml_OwnerPcID );
  IsFile := MyXmlUtil.GetChildBoolValue( ShareDownNode, Xml_IsFile );
  IsCompleted := MyXmlUtil.GetChildBoolValue( ShareDownNode, Xml_IsCompleted );
  FileCount := MyXmlUtil.GetChildIntValue( ShareDownNode, Xml_FileCount );
  FileSize := MyXmlUtil.GetChildInt64Value( ShareDownNode, Xml_FileSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( ShareDownNode, Xml_CompletedSize );

  SavePath := MyXmlUtil.GetChildValue( ShareDownNode, Xml_SavePath );
  RestoreDownType := MyXmlUtil.GetChildValue( ShareDownNode, Xml_RestoreDownType );

  if RestoreDownType = RestoreDownType_Local then
  begin
    RestoreDownReadLocalHandle := TShareDownReadLocalHandle.Create( SharePath, OwnerID );
    RestoreDownReadLocalHandle.SetIsFile( IsFile );
    RestoreDownReadLocalHandle.SetIsCompleted( IsCompleted );
    RestoreDownReadLocalHandle.SetSpaceInfo( FileCount, FileSize, CompletedSize );
    RestoreDownReadLocalHandle.SetSavePath( SavePath );
    RestoreDownReadLocalHandle.Update;
    RestoreDownReadLocalHandle.Free;
  end
  else
  begin
    RestoreDownReadNetworkHandle := TShareDownReadNetworkHandle.Create( SharePath, OwnerID );
    RestoreDownReadNetworkHandle.SetIsOnline( False );
    RestoreDownReadNetworkHandle.SetIsFile( IsFile );
    RestoreDownReadNetworkHandle.SetIsCompleted( IsCompleted );
    RestoreDownReadNetworkHandle.SetSpaceInfo( FileCount, FileSize, CompletedSize );
    RestoreDownReadNetworkHandle.SetSavePath( SavePath );
    RestoreDownReadNetworkHandle.Update;
    RestoreDownReadNetworkHandle.Free;
  end;

    // 读取 续传信息
  ReadShareDownContinus;

    // 读取 已完成日志
  ReadShareDownCompletedLog;

    // 读取 未完成日志
  ReadShareDownIncompletedLog;
end;



{ TRestoreDownAddLocalXml }

procedure TShareDownAddLocalXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( ShareDownNode, Xml_RestoreDownType, RestoreDownType_Local );
end;

{ TRestoreDownSetSpaceInfoXml }

procedure TShareDownSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetAddCompletedSpaceXml }

procedure TShareDownSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TShareDownSetAddCompletedSpaceXml.Update;
var
  CompletedSize : Int64;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  CompletedSize := MyXmlUtil.GetChildInt64Value( ShareDownNode, Xml_CompletedSize );
  CompletedSize := CompletedSize + AddCompletedSpace;
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetCompletedSizeXml }

procedure TShareDownSetCompletedSizeXml.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetCompletedSizeXml.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetIsCompletedXml }

procedure TShareDownSetIsCompletedXml.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TShareDownSetIsCompletedXml.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;
  MyXmlUtil.AddChild( ShareDownNode, Xml_IsCompleted, IsCompleted );
end;

{ TShareDownAddNetworkXml }

procedure TShareDownAddNetworkXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( ShareDownNode, Xml_RestoreDownType, RestoreDownType_Network );
end;

{ TShareDownContinusChangeXml }

function TShareDownContinusChangeXml.FindShareDownContinusNodeList : Boolean;
begin
  Result := FindShareDownNode;
  if Result then
    ShareDownContinusNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownContinusList );
end;

{ TShareDownContinusWriteXml }

procedure TShareDownContinusWriteXml.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TShareDownContinusWriteXml.FindShareDownContinusNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindShareDownContinusNodeList then
    Exit;
  for i := 0 to ShareDownContinusNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareDownContinusNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) then
    begin
      Result := True;
      ShareDownContinusIndex := i;
      ShareDownContinusNode := ShareDownContinusNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TShareDownContinusAddXml }

procedure TShareDownContinusAddXml.SetSpaceInfo( _FileSize, _Postion : int64 );
begin
  FileSize := _FileSize;
  Postion := _Postion;
end;

procedure TShareDownContinusAddXml.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TShareDownContinusAddXml.Update;
begin
  inherited;

  if not FindShareDownContinusNode then
  begin
    ShareDownContinusNode := MyXmlUtil.AddListChild( ShareDownContinusNodeList );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FilePath, FilePath );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FileSize, FileSize );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FileTime, FileTime );
  end;
  MyXmlUtil.AddChild( ShareDownContinusNode, Xml_Postion, Postion );
end;

{ TShareDownContinusRemoveXml }

procedure TShareDownContinusRemoveXml.Update;
begin
  inherited;

  if not FindShareDownContinusNode then
    Exit;

  MyXmlUtil.DeleteListChild( ShareDownContinusNodeList, ShareDownContinusIndex );
end;

{ ShareDownContinusNode }

constructor TShareDownContinusReadXml.Create( _ShareDownContinusNode : IXMLNode );
begin
  ShareDownContinusNode := _ShareDownContinusNode;
end;

procedure TShareDownContinusReadXml.SetItemInfo(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownContinusReadXml.Update;
var
  FilePath : string;
  FileSize, Postion : int64;
  FileTime : TDateTime;
  ShareDownContinusReadHandle : TShareDownContinusReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( ShareDownContinusNode, Xml_FilePath );
  FileSize := MyXmlUtil.GetChildInt64Value( ShareDownContinusNode, Xml_FileSize );
  Postion := MyXmlUtil.GetChildInt64Value( ShareDownContinusNode, Xml_Postion );
  FileTime := MyXmlUtil.GetChildFloatValue( ShareDownContinusNode, Xml_FileTime );

  ShareDownContinusReadHandle := TShareDownContinusReadHandle.Create( SharePath, OwnerID );
  ShareDownContinusReadHandle.SetFilePath( FilePath );
  ShareDownContinusReadHandle.SetSpaceInfo( FileSize, Postion );
  ShareDownContinusReadHandle.SetFileTime( FileTime );
  ShareDownContinusReadHandle.Update;
  ShareDownContinusReadHandle.Free;
end;

{ TShareExplorerHistoryChangeXml }

procedure TShareExplorerHistoryChangeXml.Update;
begin
  MyShareDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyShareDownInfo );
  ShareExplorerHistoryNodeList := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareExplorerHistoryList );
end;


{ TShareExplorerHistoryAddXml }

constructor TShareExplorerHistoryAddXml.Create(_OwnerID, _FilePath: string);
begin
  OwnerID := _OwnerID;
  FilePath := _FilePath;
end;

procedure TShareExplorerHistoryAddXml.Update;
var
  ShareExplorerHistoryNode : IXMLNode;
begin
  inherited;

  ShareExplorerHistoryNode := MyXmlUtil.AddListChild( ShareExplorerHistoryNodeList );
  MyXmlUtil.AddChild( ShareExplorerHistoryNode, Xml_OwnerID, OwnerID );
  MyXmlUtil.AddChild( ShareExplorerHistoryNode, Xml_FilePath, FilePath );
end;

{ TShareExplorerHistoryRemoveXml }

constructor TShareExplorerHistoryRemoveXml.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareExplorerHistoryRemoveXml.Update;
begin
  inherited;

  RemoveIndex := ShareExplorerHistoryNodeList.ChildNodes.Count - 1 - RemoveIndex;
  if ShareExplorerHistoryNodeList.ChildNodes.Count <= RemoveIndex then
    Exit;

  MyXmlUtil.DeleteListChild( ShareExplorerHistoryNodeList, RemoveIndex );
end;



{ TShareExplorerHistoryClearXml }

procedure TShareExplorerHistoryClearXml.Update;
begin
  inherited;

  ShareExplorerHistoryNodeList.ChildNodes.Clear;
end;

constructor TShareExplorerHistoryReadXml.Create(
  _ShareExplorerHistoryNode: IXMLNode);
begin
  ShareExplorerHistoryNode := _ShareExplorerHistoryNode;
end;

procedure TShareExplorerHistoryReadXml.Update;
var
  OwnerID, FilePath : string;
  ShareExplorerHistoryReadHandle : TShareExplorerHistoryReadHandle;
begin
  OwnerID := MyXmlUtil.GetChildValue( ShareExplorerHistoryNode, Xml_OwnerID );
  FilePath := MyXmlUtil.GetChildValue( ShareExplorerHistoryNode, Xml_FilePath );

  ShareExplorerHistoryReadHandle := TShareExplorerHistoryReadHandle.Create( OwnerID, FilePath );
  ShareExplorerHistoryReadHandle.Update;
  ShareExplorerHistoryReadHandle.Free;
end;

{ TShareSavePathChangeXml }

procedure TShareSavePathChangeXml.Update;
begin
  MyShareDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyShareDownInfo );
  ShareSavePathListNode := MyXmlUtil.AddChild( MyShareDownNode, Xml_ShareSavePathList );
end;

{ TShareSavePathAddXml }

constructor TShareSavePathAddXml.Create(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareSavePathAddXml.Update;
var
  ShareSavePathNode : IXMLNode;
begin
  inherited;

  ShareSavePathNode := MyXmlUtil.AddListChild( ShareSavePathListNode );
  MyXmlUtil.AddChild( ShareSavePathNode, Xml_SavePath, SavePath );
end;

{ TShareSavePathRemoveXml }

constructor TShareSavePathRemoveXml.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareSavePathRemoveXml.Update;
begin
  inherited;

  RemoveIndex := ShareSavePathListNode.ChildNodes.Count - 1 - RemoveIndex;
  if ( RemoveIndex < 0 ) or
     ( RemoveIndex >= ShareSavePathListNode.ChildNodes.Count )
  then
    Exit;

  ShareSavePathListNode.ChildNodes.Delete( RemoveIndex );
end;

{ TShareSavePathClearXml }

procedure TShareSavePathClearXml.Update;
begin
  inherited;

  ShareSavePathListNode.ChildNodes.Clear;
end;

{ TShareSaveHistoryReadXml }

constructor TShareSaveHistoryReadXml.Create(_ShareSaveHistoryNode: IXMLNode);
begin
  ShareSaveHistoryNode := _ShareSaveHistoryNode;
end;

procedure TShareSaveHistoryReadXml.Update;
var
  SavePath : string;
  ShareSavePathReadHandle : TShareSavePathReadHandle;
begin
  SavePath := MyXmlUtil.GetChildValue( ShareSaveHistoryNode, Xml_SavePath );

  ShareSavePathReadHandle := TShareSavePathReadHandle.Create( SavePath );
  ShareSavePathReadHandle.Update;
  ShareSavePathReadHandle.Free;
end;

{ TBackupSpeedChangeXml }

procedure TRestoreSpeedChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyShareDownInfo );
  RestoreSpeedNode := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreSpeed );
end;

{ TBackupSpeedLimitXml }

procedure TRestoreSpeedLimitXml.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitXml.SetLimitXml(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TRestoreSpeedLimitXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_IsLimit, IsLimit );
  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_LimitType, LimitType );
  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_LimitValue, LimitValue );
end;

{ TBackupSpeedReadXml }

constructor TRestoreSpeedReadXml.Create(_RestoreSpeedNode: IXMLNode);
begin
  RestoreSpeedNode := _RestoreSpeedNode;
end;

procedure TRestoreSpeedReadXml.Update;
var
  IsLimit : Boolean;
  LimitType, LimitValue : Integer;
  RestoreSpeedLimitReadHandle : TRestoreSpeedLimitReadHandle;
begin
  IsLimit := StrToBoolDef( MyXmlUtil.GetChildValue( RestoreSpeedNode, Xml_IsLimit ), False );
  LimitType := MyXmlUtil.GetChildIntValue( RestoreSpeedNode, Xml_LimitType );
  LimitValue := MyXmlUtil.GetChildIntValue( RestoreSpeedNode, Xml_LimitValue );

  RestoreSpeedLimitReadHandle := TRestoreSpeedLimitReadHandle.Create( IsLimit );
  RestoreSpeedLimitReadHandle.SetLimitInfo( LimitType, LimitValue );
  RestoreSpeedLimitReadHandle.Update;
  RestoreSpeedLimitReadHandle.Free
end;

{ TSendLogChangeXml }

function TShareDownCompletedLogChangeXml.FindSendCompletedLogNodeList: Boolean;
begin
  Result := FindShareDownNode;
  if Result then
    SendCompletedLogNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownCompletedLogList );
end;

{ TSendLogClearXml }

procedure TShareDownLogClearCompletedXml.Update;
begin
  inherited;

    // Item 不存在
  if not FindSendCompletedLogNodeList then
    Exit;

  SendCompletedLogNodeList.ChildNodes.Clear;
end;

{ TSendLogAddCompletedXml }

procedure TShareDownLogAddCompletedXml.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TShareDownLogAddCompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownLogAddCompletedXml.Update;
var
  BackupLogNode : IXMLNode;
begin
  inherited;

  if not FindSendCompletedLogNodeList then
    Exit;

  if SendCompletedLogNodeList.ChildNodes.Count >= 20 then
    SendCompletedLogNodeList.ChildNodes.Delete( SendCompletedLogNodeList.ChildNodes.Count - 1 );

  BackupLogNode := MyXmlUtil.AddListChild( SendCompletedLogNodeList );
  MyXmlUtil.AddChild( BackupLogNode, Xml_FilePath, FilePath );
  MyXmlUtil.AddChild( BackupLogNode, Xml_ShareDownTime, SendTime );
end;

{ TSendLogAddIncompletedXml }

procedure TShareDownLogAddIncompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareDownLogAddIncompletedXml.Update;
var
  BackupLogNode : IXMLNode;
begin
  inherited;

  if not FindSendIncompletedLogNodeList then
    Exit;

  BackupLogNode := MyXmlUtil.AddListChild( SendIncompletedLogNodeList );
  MyXmlUtil.AddChild( BackupLogNode, Xml_FilePath, FilePath );
end;

{ TSendLogClearIncompletedXml }

procedure TShareDownLogClearIncompletedXml.Update;
begin
  inherited;

  if not FindSendIncompletedLogNodeList then
    Exit;

  SendIncompletedLogNodeList.ChildNodes.Clear;
end;

{ TSendIncompletedLogChangeXml }

function TShareDownIncompletedLogChangeXml.FindSendIncompletedLogNodeList: Boolean;
begin
  Result := FindShareDownNode;
  if Result then
    SendIncompletedLogNodeList := MyXmlUtil.AddChild( ShareDownNode, Xml_ShareDownIncompletedLogList );
end;

{ TShareDownCompletedLogReadXml }

constructor TShareDownCompletedLogReadXml.Create(
  _ShareDownCompletedNode: IXMLNode);
begin
  ShareDownCompletedNode := _ShareDownCompletedNode;
end;

procedure TShareDownCompletedLogReadXml.SetItemInfo(_SharePath,
  _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownCompletedLogReadXml.Update;
var
  FilePath : string;
  ShareDownTime : TDateTime;
  ShareDownLogCompletedReadHandle : TShareDownLogCompletedReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( ShareDownCompletedNode, Xml_FilePath );
  ShareDownTime := MyXmlUtil.GetChildFloatValue( ShareDownCompletedNode, Xml_ShareDownTime );

  ShareDownLogCompletedReadHandle := TShareDownLogCompletedReadHandle.Create( SharePath, OwnerID );
  ShareDownLogCompletedReadHandle.SetFilePath( FilePath );
  ShareDownLogCompletedReadHandle.SetBackupTime( ShareDownTime );
  ShareDownLogCompletedReadHandle.Update;
  ShareDownLogCompletedReadHandle.Free;
end;

{ TShareDownIncompletedLogReadXml }

constructor TShareDownIncompletedLogReadXml.Create(
  _ShareDownIncompletedNode: IXMLNode);
begin
  ShareDownIncompletedNode := _ShareDownIncompletedNode;
end;

procedure TShareDownIncompletedLogReadXml.SetItemInfo(_SharePath,
  _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareDownIncompletedLogReadXml.Update;
var
  FilePath : string;
  ShareDownLogIncompletedReadHandle : TShareDownLogIncompletedReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( ShareDownIncompletedNode, Xml_FilePath );

  ShareDownLogIncompletedReadHandle := TShareDownLogIncompletedReadHandle.Create( SharePath, OwnerID );
  ShareDownLogIncompletedReadHandle.SetFilePath( FilePath );
  ShareDownLogIncompletedReadHandle.Update;
  ShareDownLogIncompletedReadHandle.Free;
end;

end.
