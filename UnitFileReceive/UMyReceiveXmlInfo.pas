unit UMyReceiveXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UMyUtil;

type

{$Region ' 接收路径 增删 ' }

    // 父类
  TReceiveRootItemChangeXml = class( TXmlChangeInfo )
  protected
    MyFileReceiveNode : IXMLNode;
    ReceiveRootItemNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveRootItemWriteXml = class( TReceiveRootItemChangeXml )
  public
    RootPath : string;
  protected
    ReceiveRootItemIndex : Integer;
    ReceiveRootItemNode : IXMLNode;
  public
    constructor Create( _RootPath : string );
  protected
    function FindReceiveRootItemNode: Boolean;
  end;

    // 添加
  TReceiveRootItemAddXml = class( TReceiveRootItemWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TReceiveRootItemRemoveXml = class( TReceiveRootItemWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 发送路径 增删 ' }

    // 父类
  TReceiveItemChangeXml = class( TReceiveRootItemWriteXml )
  protected
    ReceiveItemNodeList : IXMLNode;
  protected
    function FindReceiveItemNodeList : Boolean;
  end;

    // 修改
  TReceiveItemWriteXml = class( TReceiveItemChangeXml )
  public
    SourcePath, OwnerID : string;
  protected
    ReceiveItemIndex : Integer;
    ReceiveItemNode : IXMLNode;
  public
    procedure SetSourceInfo( _SourcePath, _OwnerID : string );
  protected
    function FindReceiveItemNode: Boolean;
  end;

    // 添加
  TReceiveItemAddXml = class( TReceiveItemWriteXml )
  public
    IsFile : boolean;
    IsCompleted, IsCancel, IsZip : Boolean;
    ReceiveTime : TDateTime;
    IsFirstReceive : Boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetStatusInfo( _IsCompleted, _IsCancel : boolean );
    procedure SetIsFirstReceive( _IsFirstReceive : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetSavePath( _SavePath : string );
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TReceiveItemRemoveXml = class( TReceiveItemWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 发送路径 空间信息 ' }

    // 修改
  TReceiveItemSetSpaceInfoXml = class( TReceiveItemWriteXml )
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetAddCompletedSpaceXml = class( TReceiveItemWriteXml )
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
  TReceiveItemSetIsCompletedXml = class( TReceiveItemWriteXml )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TReceiveItemSetIsCancelXml = class( TReceiveItemWriteXml )
  public
    IsCancel : boolean;
  public
    procedure SetIsCancel( _IsCancel : boolean );
  protected
    procedure Update;override;
  end;

  TReceiveItemSetReceiveTimeXml = class( TReceiveItemWriteXml )
  public
    ReceiveTime : TDateTime;
  public
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
  protected
    procedure Update;override;
  end;

  TReceiveItemSetIsFirstReceiveXml = class( TReceiveItemWriteXml )
  public
    IsFirstReceive : Boolean;
  public
    procedure SetIsFirstReceive( _IsFirstReceive : boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 接收路径新增 ' }

  TReceiveRootNewCountChangeXml = class( TXmlChangeInfo )
  protected
    MyFileReceiveNode : IXMLNode;
  protected
    procedure Update;override;
  end;

  TReceiveRootNewCountAddXml = class( TReceiveRootNewCountChangeXml )
  protected
    procedure Update;override;
  end;

  TReceiveRootNewCountClearXml = class( TReceiveRootNewCountChangeXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TReceiveItemReadXml = class
  public
    ReceiveItemNode : IXMLNode;
    RootPath : string;
  public
    constructor Create( _ReceiveItemNode : IXMLNode );
    procedure SetRootPath( _RootPath : string );
    procedure Update;
  end;

    // 读取
  TReceiveRootItemReadXml = class
  public
    ReceiveRootItemNode : IXMLNode;
    RootPath : string;
  public
    constructor Create( _ReceiveRootItemNode : IXMLNode );
    procedure Update;
  public
    procedure ReadReceiveRootItemList;
  end;

    // 读取
  TMyFileReceiveReadXml = class
  private
    MyFileReceiveNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadNewCount;
    procedure ReadReceiveList;
  end;

{$EndRegion}

const
  Xml_MyFileReceiveInfo = 'mfri';
  Xml_ReceiveRootItemList = 'rril';
  Xml_NewReceiveCount = 'nrc';

  Xml_RootPath = 'rp';
  Xml_ReceiveItemList = 'ril';

  Xml_SourcePath = 'srp';
  Xml_OwnerID = 'oi';
  Xml_IsFile = 'if';
  Xml_IsCompleted = 'ic';
  Xml_IsCancel = 'icl';
  Xml_IsZip = 'iz';
  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_CompletedSpace = 'cs';
  Xml_SavePath = 'sp';
  Xml_ReceiveTime = 'rt';
  Xml_IsFirstReceive = 'ifr';



implementation

uses UMyReceiveApiInfo;


procedure TMyFileReceiveReadXml.ReadNewCount;
var
  NewCount : Integer;
  ReceiveRootReadNewCountHandle : TReceiveRootReadNewCountHandle;
begin
  NewCount := MyXmlUtil.GetChildIntValue( MyFileReceiveNode, Xml_NewReceiveCount );

  ReceiveRootReadNewCountHandle := TReceiveRootReadNewCountHandle.Create( NewCount );
  ReceiveRootReadNewCountHandle.Update;
  ReceiveRootReadNewCountHandle.Free;
end;

procedure TMyFileReceiveReadXml.ReadReceiveList;
var
  CloudPathListNode : IXMLNode;
  i: Integer;
  CloudPathReadXml : TReceiveRootItemReadXml;
begin
  CloudPathListNode := MyXmlUtil.AddChild( MyFileReceiveNode, Xml_ReceiveRootItemList );
  for i := 0 to CloudPathListNode.ChildNodes.Count - 1 do
  begin
    CloudPathReadXml := TReceiveRootItemReadXml.Create( CloudPathListNode.ChildNodes[i] );
    CloudPathReadXml.Update;
    CloudPathReadXml.Free;
  end;
end;

procedure TMyFileReceiveReadXml.Update;
begin
  MyFileReceiveNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileReceiveInfo );

  ReadNewCount;

  ReadReceiveList;
end;


{ CloudPcBackupNode }

constructor TReceiveItemReadXml.Create( _ReceiveItemNode : IXMLNode );
begin
  ReceiveItemNode := _ReceiveItemNode;
end;

procedure TReceiveItemReadXml.SetRootPath(_RootPath: string);
begin
  RootPath := _RootPath;
end;

procedure TReceiveItemReadXml.Update;
var
  BackupPath, OwnerID : string;
  IsFile : boolean;
  IsCompleted, IsCancel, IsZip : Boolean;
  FileCount : integer;
  ItemSize, CompletedSpace : int64;
  SavePath : string;
  ReceiveTime : TDateTime;
  IsFirstReceive : Boolean;
  ReceiveTimeStr, IsFirstReceiveStr : string;
  CloudBackupPathReadHandle : TReceiveItemReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( ReceiveItemNode, Xml_SourcePath );
  OwnerID := MyXmlUtil.GetChildValue( ReceiveItemNode, Xml_OwnerID );
  IsFile := MyXmlUtil.GetChildBoolValue( ReceiveItemNode, Xml_IsFile );
  IsCompleted := MyXmlUtil.GetChildBoolValue( ReceiveItemNode, Xml_IsCompleted );
  IsCancel := MyXmlUtil.GetChildBoolValue( ReceiveItemNode, Xml_IsCancel );
  IsZip := MyXmlUtil.GetChildBoolValue( ReceiveItemNode, Xml_IsZip );
  FileCount := MyXmlUtil.GetChildIntValue( ReceiveItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( ReceiveItemNode, Xml_ItemSize );
  CompletedSpace := MyXmlUtil.GetChildInt64Value( ReceiveItemNode, Xml_CompletedSpace );
  SavePath := MyXmlUtil.GetChildValue( ReceiveItemNode, Xml_SavePath );
  ReceiveTimeStr := MyXmlUtil.GetChildValue( ReceiveItemNode, Xml_ReceiveTime );
  if ReceiveTimeStr = '' then
    ReceiveTime := 0
  else
    ReceiveTime := MyXmlUtil.GetChildFloatValue( ReceiveItemNode, Xml_ReceiveTime );
  IsFirstReceiveStr := MyXmlUtil.GetChildValue( ReceiveItemNode, Xml_IsFirstReceive );
  if IsFirstReceiveStr = '' then
    IsFirstReceive := False
  else
    IsFirstReceive := MyXmlUtil.GetChildBoolValue( ReceiveItemNode, Xml_IsFirstReceive );

  CloudBackupPathReadHandle := TReceiveItemReadHandle.Create( RootPath );
  CloudBackupPathReadHandle.SetSourceInfo( BackupPath, OwnerID );
  CloudBackupPathReadHandle.SetIsFile( IsFile );
  CloudBackupPathReadHandle.SetStatusInfo( IsCompleted, IsCancel );
  CloudBackupPathReadHandle.SetIsZip( IsZip );
  CloudBackupPathReadHandle.SetIsFirstReceive( IsFirstReceive );
  CloudBackupPathReadHandle.SetSpaceInfo( FileCount, ItemSize, CompletedSpace );
  CloudBackupPathReadHandle.SetIsNewReceive( False );
  CloudBackupPathReadHandle.SetReceiveTime( ReceiveTime );
  CloudBackupPathReadHandle.SetSavePath( SavePath );
  CloudBackupPathReadHandle.Update;
  CloudBackupPathReadHandle.Free;
end;

{ TCloudPathChangeXml }

procedure TReceiveRootItemChangeXml.Update;
begin
  MyFileReceiveNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileReceiveInfo );
  ReceiveRootItemNodeList := MyXmlUtil.AddChild( MyFileReceiveNode, Xml_ReceiveRootItemList );
end;

{ TCloudPathWriteXml }

constructor TReceiveRootItemWriteXml.Create( _RootPath : string );
begin
  RootPath := _RootPath;
end;


function TReceiveRootItemWriteXml.FindReceiveRootItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to ReceiveRootItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ReceiveRootItemNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_RootPath ) = RootPath ) then
    begin
      Result := True;
      ReceiveRootItemIndex := i;
      ReceiveRootItemNode := ReceiveRootItemNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPathAddXml }

procedure TReceiveRootItemAddXml.Update;
begin
  inherited;

  if FindReceiveRootItemNode then
    Exit;

  ReceiveRootItemNode := MyXmlUtil.AddListChild( ReceiveRootItemNodeList );
  MyXmlUtil.AddChild( ReceiveRootItemNode, Xml_RootPath, RootPath );
end;

{ TCloudPathRemoveXml }

procedure TReceiveRootItemRemoveXml.Update;
begin
  inherited;

  if not FindReceiveRootItemNode then
    Exit;

  MyXmlUtil.DeleteListChild( ReceiveRootItemNodeList, ReceiveRootItemIndex );
end;

{ TCloudPcBackupPathChangeXml }

function TReceiveItemChangeXml.FindReceiveItemNodeList : Boolean;
begin
  Result := FindReceiveRootItemNode;
  if Result then
    ReceiveItemNodeList := MyXmlUtil.AddChild( ReceiveRootItemNode, Xml_ReceiveItemList );
end;

{ TCloudPcBackupPathWriteXml }

procedure TReceiveItemWriteXml.SetSourceInfo( _SourcePath, _OwnerID : string );
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;


function TReceiveItemWriteXml.FindReceiveItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindReceiveItemNodeList then
    Exit;
  for i := 0 to ReceiveItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ReceiveItemNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_SourcePath ) = SourcePath ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_OwnerID ) = OwnerID )
    then
    begin
      Result := True;
      ReceiveItemIndex := i;
      ReceiveItemNode := ReceiveItemNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPcBackupPathAddXml }

procedure TReceiveItemAddXml.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TReceiveItemAddXml.SetIsFirstReceive(_IsFirstReceive: Boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemAddXml.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveItemAddXml.SetReceiveTime(_ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemAddXml.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TReceiveItemAddXml.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemAddXml.SetStatusInfo(_IsCompleted, _IsCancel: boolean);
begin
  IsCompleted := _IsCompleted;
  IsCancel := _IsCancel;
end;

procedure TReceiveItemAddXml.Update;
begin
  inherited;

  if FindReceiveItemNode then
    Exit;

  ReceiveItemNode := MyXmlUtil.AddListChild( ReceiveItemNodeList );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_SourcePath, SourcePath );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_OwnerID, OwnerID );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsCompleted, IsCompleted );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsCancel, IsCancel );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsZip, IsZip );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_CompletedSpace, CompletedSpace );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_SavePath, SavePath );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_ReceiveTime, ReceiveTime );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsFirstReceive, IsFirstReceive );
end;

{ TCloudPcBackupPathRemoveXml }

procedure TReceiveItemRemoveXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;

  MyXmlUtil.DeleteListChild( ReceiveItemNodeList, ReceiveItemIndex );
end;

{ CloudPathNode }

constructor TReceiveRootItemReadXml.Create( _ReceiveRootItemNode : IXMLNode );
begin
  ReceiveRootItemNode := _ReceiveRootItemNode;
end;

procedure TReceiveRootItemReadXml.ReadReceiveRootItemList;
var
  CloudBackupPathNodeList : IXMLNode;
  i : Integer;
  CloudBackupPathNode : IXMLNode;
  CloudBackupPathReadXml : TReceiveItemReadXml;
begin
  CloudBackupPathNodeList := MyXmlUtil.AddChild( ReceiveRootItemNode, Xml_ReceiveItemList );
  for i := 0 to CloudBackupPathNodeList.ChildNodes.Count - 1 do
  begin
    CloudBackupPathNode := CloudBackupPathNodeList.ChildNodes[i];
    CloudBackupPathReadXml := TReceiveItemReadXml.Create( CloudBackupPathNode );
    CloudBackupPathReadXml.SetRootPath( RootPath );
    CloudBackupPathReadXml.Update;
    CloudBackupPathReadXml.Free;
  end;
end;

procedure TReceiveRootItemReadXml.Update;
var
  CloudPathReadHandle : TReceiveRootItemReadHandle;
begin
  RootPath := MyXmlUtil.GetChildValue( ReceiveRootItemNode, Xml_RootPath );

  CloudPathReadHandle := TReceiveRootItemReadHandle.Create( RootPath );
  CloudPathReadHandle.Update;
  CloudPathReadHandle.Free;

  ReadReceiveRootItemList;
end;

{ TReceiveItemSetSpaceInfoXml }

procedure TReceiveItemSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_CompletedSpace, CompletedSpace );
end;

{ TReceiveItemSetAddCompletedSpaceXml }

procedure TReceiveItemSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TReceiveItemSetAddCompletedSpaceXml.Update;
var
  CompletedSpace : Int64;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  CompletedSpace := MyXmlUtil.GetChildInt64Value( ReceiveItemNode, Xml_CompletedSpace );
  CompletedSpace := CompletedSpace + AddCompletedSpace;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_CompletedSpace, CompletedSpace );
end;

{ TReceiveItemSetIsCompletedXml }

procedure TReceiveItemSetIsCompletedXml.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TReceiveItemSetIsCompletedXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsCompleted, IsCompleted );
end;

{ TReceiveItemSetIsCancelXml }

procedure TReceiveItemSetIsCancelXml.SetIsCancel( _IsCancel : boolean );
begin
  IsCancel := _IsCancel;
end;

procedure TReceiveItemSetIsCancelXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsCancel, IsCancel );
end;



{ TReceiveRootNewCountChangeXml }

procedure TReceiveRootNewCountChangeXml.Update;
begin
  MyFileReceiveNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileReceiveInfo );
end;

{ TReceiveRootNewCountAddXml }

procedure TReceiveRootNewCountAddXml.Update;
var
  NewCount : Integer;
begin
  inherited;
  NewCount := MyXmlUtil.GetChildIntValue( MyFileReceiveNode, Xml_NewReceiveCount );
  NewCount := NewCount + 1;
  MyXmlUtil.AddChild( MyFileReceiveNode, Xml_NewReceiveCount, NewCount );
end;

{ TReceiveRootNewCountClearXml }

procedure TReceiveRootNewCountClearXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyFileReceiveNode, Xml_NewReceiveCount, 0 );
end;

{ TReceiveItemSetReceiveTimeXml }

procedure TReceiveItemSetReceiveTimeXml.SetReceiveTime(_ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemSetReceiveTimeXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_ReceiveTime, ReceiveTime );
end;

{ TReceiveItemSetIsFirstReceiveXml }

procedure TReceiveItemSetIsFirstReceiveXml.SetIsFirstReceive(
  _IsFirstReceive: boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemSetIsFirstReceiveXml.Update;
begin
  inherited;

  if not FindReceiveItemNode then
    Exit;
  MyXmlUtil.AddChild( ReceiveItemNode, Xml_IsFirstReceive, IsFirstReceive );
end;

end.
