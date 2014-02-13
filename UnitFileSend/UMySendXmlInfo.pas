unit UMySendXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UFileBaseInfo, classes, Sysutils;

type

{$Region ' 数据修改 ' }

  {$Region ' 目标路径 ' }

  TSendRootItemChangeXml = class( TXmlChangeInfo )
  protected
    MyFileSendNode : IXMLNode;
    SendRootItemNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

  TSendRootItemWriteXml = class( TSendRootItemChangeXml )
  public
    SendRootItemID : string;
  protected
    SendRootItemIndex : Integer;
    SendRootItemNode : IXMLNode;
  public
    constructor Create( _SendRootItemID : string );
  protected
    function FindSendRootItemNode : Boolean;
  end;

  TSendRootItemAddXml = class( TSendRootItemWriteXml )
  protected
    procedure Update;override;
  protected
    procedure AddItemInfo;virtual;abstract;
  end;


    // 添加 本地
  TSendRootItemAddLocalXml = class( TSendRootItemAddXml )
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络
  TSendRootItemAddNetworkXml = class( TSendRootItemAddXml )
  protected
    procedure AddItemInfo;override;
  end;

    // 删除
  TSendRootItemRemoveXml = class( TSendRootItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 增删 ' }

  TSendItemChangeXml = class( TSendRootItemWriteXml )
  public
    SendItemNodeList : IXMLNode;
  public
    function FindSendItemNodeList : Boolean;
  end;

  TSendItemWriteXml = class( TSendItemChangeXml )
  public
    SourcePath : string;
  protected
    SendItemIndex : Integer;
    SendItemNode : IXMLNode;
  public
    procedure SetSourcePath( _SourcePath : string );
  protected
    function FindSendItemNode : Boolean;
  end;

  TSendItemAddXml = class( TSendItemWriteXml )
  public  // 路径信息
    IsFile : Boolean;
    IsCompleted, IsCancel, IsZip : Boolean;
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
    procedure RefreshSendCount;
  end;

    // 添加本地
  TSendItemAddLocalXml = class( TSendItemAddXml )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络
  TSendItemAddNetworkXml = class( TSendItemAddXml )
  public
    IsAddToReceive : Boolean; // 是否需要添加接收方
    IsRemoveToReceive : Boolean;  // 是否需要删除接收方
    IsReceiveCancel : Boolean; // 是否接收方已经取消
  public
    procedure SetReceiveInfo( _IsAddToReceive, _IsRemoveToReceive : Boolean );
    procedure SetIsReceiveCancel( _IsReceiveCancel : Boolean );
  protected
    procedure AddItemInfo;override;
  end;

  TSendItemRemoveXml = class( TSendItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 状态 ' }

      // 修改
  TSendItemSetIsCompletedXml = class( TSendItemWriteXml )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsAddToReceiveXml = class( TSendItemWriteXml )
  public
    IsAddToReceive : boolean;
  public
    procedure SetIsAddToReceive( _IsAddToReceive : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsRemoveToReceiveXml = class( TSendItemWriteXml )
  public
    IsRemoveToReceive : boolean;
  public
    procedure SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TSendItemSetIsReceiveCancelXml = class( TSendItemWriteXml )
  public
    IsReceiveCancel : boolean;
  public
    procedure SetIsReceiveCancel( _IsReceiveCancel : boolean );
  protected
    procedure Update;override;
  end;




  {$EndRegion}

  {$Region ' 源路径 空间信息 ' }

    // 修改
  TSendItemSetSpaceInfoXml = class( TSendItemWriteXml )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

  // 修改
  TSendItemSetAddCompletedSpaceXml = class( TSendItemWriteXml )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 自动发送 ' }

      // 添加 已完成信息
  TSendItemSetLastSendTimeXml = class( TSendItemWriteXml )
  public
    LastSendTime : TDateTime;
  public
    procedure SetLastSendTime( _LastSendTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TSendItemSetScheduleXml = class( TSendItemWriteXml )
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

  {$Region ' 源路径 过滤信息 ' }

    // 修改 过滤信息 父类
  TSendItemFilterWriteXml = class( TSendItemWriteXml )
  public
    IncludeFilterListNode : IXMLNode;
    ExcludeFilterListNode : IXMLNode;
  public
    function FindFilterList : Boolean;
  end;

    // 添加 父类
  TSendItemFilterAddXml = class( TSendItemFilterWriteXml )
  public
    FilterType, FilterValue : string;
  public
    procedure SetFilterXml( _FilterType, _FilterValue : string );
  end;

    // 清空
  TSendItemIncludeFilterClearXml = class( TSendItemFilterWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加
  TSendItemIncludeFilterAddXml = class( TSendItemFilterAddXml )
  protected
    procedure Update;override;
  end;

    // 清空
  TSendItemExcludeFilterClearXml = class( TSendItemFilterWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加
  TSendItemExcludeFilterAddXml = class( TSendItemFilterAddXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 续传信息 ' }

      // 父类
  TSendContinusChangeXml = class( TSendItemWriteXml )
  protected
    BackupContinusNodeList : IXMLNode;
  protected
    function FindBackupContinusNodeList : Boolean;
  end;

    // 修改
  TSendContinusWriteXml = class( TSendContinusChangeXml )
  public
    FilePath : string;
  protected
    BackupContinusIndex : Integer;
    BackupContinusNode : IXMLNode;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupContinusNode: Boolean;
  end;

    // 添加
  TSendContinusAddXml = class( TSendContinusWriteXml )
  public
    FileTime : TDateTime;
    FileSize, Postion : int64;
  public
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetSpaceInfo( _FileSize, _Position : int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TSendContinusRemoveXml = class( TSendContinusWriteXml )
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 源路径 日志信息 ' }

      // 父类
  TSendCompletedLogChangeXml = class( TSendItemWriteXml )
  protected
    SendCompletedLogNodeList : IXMLNode;
  protected
    function FindSendCompletedLogNodeList : Boolean;
  end;

    // 添加 已完成
  TSendLogAddCompletedXml = class( TSendCompletedLogChangeXml )
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
  TSendLogClearCompletedXml = class( TSendCompletedLogChangeXml )
  protected
    procedure Update;override;
  end;



      // 父类
  TSendIncompletedLogChangeXml = class( TSendItemWriteXml )
  protected
    SendIncompletedLogNodeList : IXMLNode;
  protected
    function FindSendIncompletedLogNodeList : Boolean;
  end;


    // 添加 未完成
  TSendLogAddIncompletedXml = class( TSendIncompletedLogChangeXml )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 清空
  TSendLogClearIncompletedXml = class( TSendIncompletedLogChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}


  {$Region ' 速度信息 ' }

    // 父类
  TBackupSpeedChangeXml = class( TXmlChangeInfo )
  public
    MyBackupNode : IXMLNode;
    BackupSpeedNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 速度限制
  TBackupSpeedLimitXml = class( TBackupSpeedChangeXml )
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


  {$Region ' 发送文件 历史信息 ' }

      // 父类
  TSendFileHistoryChangeXml = class( TXmlChangeInfo )
  protected
    MyBackupNode : IXMLNode;
    SendFileHistoryNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 添加 History
  TSendFileHistoryAddXml = class( TSendFileHistoryChangeXml )
  public
    SendPathList : TStringList;
  public
    constructor Create( _SendPathList : TStringList );
    procedure Update; override;
    destructor Destroy; override;
  end;

    // 删除
  TSendFileHistoryRemoveXml = class( TSendFileHistoryChangeXml )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;override;
  end;

    // 清空
  TSendFileHistoryClearXml = class( TSendFileHistoryChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 发送目标 历史信息 ' }

        // 父类
  TSendDesHistoryChangeXml = class( TXmlChangeInfo )
  protected
    MyBackupNode : IXMLNode;
    SendDesHistoryNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 添加 History
  TSendDesHistoryAddXml = class( TSendDesHistoryChangeXml )
  public
    SendDesList : TStringList;
  public
    constructor Create( _SendDesList : TStringList );
    procedure Update; override;
    destructor Destroy; override;
  end;

    // 删除
  TSendDesHistoryRemoveXml = class( TSendDesHistoryChangeXml )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;override;
  end;

    // 清空
  TSendDesHistoryClearXml = class( TSendDesHistoryChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取 包含过滤器
  TSendItemIncludeFilterReadXml = class
  public
    SendRootItemID : string;
    SourcePath : string;
    IncludeFilterListNode : IXMLNode;
  public
    constructor Create( _IncludeFilterListNode : IXMLNode );
    procedure SetSendRootItemID( _SendRootItemID : string );
    procedure SetSourcePath( _SourcePath : string );
    procedure Update;
  end;

    // 读取 排除过滤器
  TSendItemExcludeFilterReadXml = class
  public
    SendRootItemID : string;
    SourcePath : string;
    ExcludeFilterListNode : IXMLNode;
  public
    constructor Create( _ExcludeFilterListNode : IXMLNode );
    procedure SetSendRootItemID( _SendRootItemID : string );
    procedure SetSourcePath( _SourcePath : string );
    procedure Update;
  end;

      // 读取
  TSendContinusReadXml = class
  public
    SendContinusNode : IXMLNode;
    SendRootItemID, SourcePath : string;
  public
    constructor Create( _SendContinusNode : IXMLNode );
    procedure SetItemInfo( _SendRootItemID, _SourcePath : string );
    procedure Update;
  end;


      // 读取
  TBackupCompletedLogReadXml = class
  public
    BackupCompletedLog : IXMLNode;
    DesItemID, SourcePath : string;
  public
    constructor Create( _BackupCompletedLog : IXMLNode );
    procedure SetItemInfo( _SendRootItemID, _SourcePath : string );
    procedure Update;
  end;

    // 读取
  TBackupIncompletedLogReadXml = class
  public
    BackupIncompletedLog : IXMLNode;
    DesItemID, SourcePath : string;
  public
    constructor Create( _BackupIncompletedLog : IXMLNode );
    procedure SetItemInfo( _SendRootItemID, _SourcePath : string );
    procedure Update;
  end;


    // 读取 备份路径
  TSendItemReadXml = class
  private
    SendRootItemID : string;
    SendItemNode : IXMLNode;
    SourcePath : string;
    IsLocalItem : Boolean;
  public
    constructor Create( _SendItemNode : IXMLNode );
    procedure SetSendRootItemID( _SendRootItemID : string );
    procedure SetIsLocalItem( _IsLocalItem : Boolean );
    procedure Update;
  private
    procedure ReadFilterList;
    procedure ReadContinuseList;
    procedure ReadCompletedLogList;
    procedure ReadIncompletedLogList;
  end;

    // 读取 目标路径
  TSendRootItemReadXml = class
  private
    SendRootItemNode : IXMLNode;
  private
    SendRootItemID : string;
    IsLocalItem : Boolean;
  public
    constructor Create( _SendRootItemNode : IXMLNode );
    procedure Update;
  private
    procedure ReadSendItemList;
  end;

      // 读取 备份速度
  TBackupSpeedReadXml = class
  public
    BackupSpeedNode : IXMLNode;
  public
    constructor Create( _BackupSpeedNode : IXMLNode );
    procedure Update;
  end;

      // 读取
  TSendFileHistoryReadXml = class
  public
    SendFileHistoryNode : IXMLNode;
  public
    constructor Create( _SendFileHistoryNode : IXMLNode );
    procedure Update;
  end;

        // 读取
  TSendDesHistoryReadXml = class
  public
    SendDesHistoryNode : IXMLNode;
  public
    constructor Create( _SendDesHistoryNode : IXMLNode );
    procedure Update;
  end;


    // 读取 本地备份 信息
  TMyFileSendReadXmlHandle = class
  private
    MyFileSendRoot : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadSendRootItemList;
    procedure ReadBackupSpeed;
    procedure ReadSendFileHistoryList;
    procedure ReadSendDesHistoryList;
    procedure ReadSendCount;
  end;

{$EndRegion}


const
  Xml_MyFileSendInfo = 'mfsi';
  Xml_SendRootItemList = 'sril';
  Xml_SendCount = 'sc';

  Xml_SendRootItemID = 'srii';
  Xml_SendRootItemType = 'srit';
  Xml_SendItemList = 'sil';

  Xml_SourcePath = 'sp';
  Xml_IsFile = 'if';
  Xml_IsCompleted = 'ic';

  Xml_IsZip = 'iz';
  Xml_ZipPath = 'zp';

  Xml_ScheduleType = 'st';
  Xml_ScheduleValue1 = 'sv1';
  Xml_ScheduleValue2 = 'sv2';
  Xml_LastSendTime = 'lst';

  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_CompletedSize = 'cs';

  Xml_SavePath = 'spt';

  Xml_IsAddToReceive = 'iatr';
  Xml_IsRemoveToReceve = 'irtr';
  Xml_IsReceiveCancel = 'irc';

const   // 过滤器
  Xml_IncludeFilterList = 'ifl';
  Xml_ExcludeFilterList = 'efl';

  Xml_FilterType = 'ft';
  Xml_FilterValue = 'fv';

const   // 续传信息
  Xml_BackupContinusList = 'bcl';

  Xml_FilePath = 'fp';
  Xml_FileSize = 'fs';
  Xml_Position = 'pt';
  Xml_FileTime = 'ft';

const  // 日志信息
  Xml_BackupLogList = 'bll';
  Xml_Source = 's';
  Xml_Destination = 'd';
//  Xml_FilePath = 'fp';
  Xml_ActionType = 'at';
  Xml_ActionTime = 'atm';

  Xml_SendCompletedLogList = 'scll';
  Xml_SendTime = 'st';

  Xml_SendIncompletedLogList = 'sicll';

const  // 速度信息
  Xml_BackupSpeed = 'bs';
  Xml_IsLimit = 'il';
  Xml_LimitType = 'lt';
  Xml_LimitValue = 'lv';


const  // 发送文件历史
  Xml_SendFileHistoryList = 'sfhl';
  Xml_SendPathList = 'spl';
  Xml_SendPath = 'sp';

const  // 发送目标历史
  Xml_SendDesHistoryList = 'sdhl';
  Xml_SendDesList = 'sdl';
  Xml_SendDes = 'sd';


const
  DesItemType_Local = 'Local';
  DesItemType_Network = 'Network';

implementation

uses UMySendApiInfo, UMyUtil;

{ TDesItemWriteXml }

constructor TSendRootItemWriteXml.Create(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;

function TSendRootItemWriteXml.FindSendRootItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to SendRootItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := SendRootItemNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_SendRootItemID ) = SendRootItemID then
    begin
      Result := True;
      SendRootItemIndex := i;
      SendRootItemNode := SelectNode;
      Break;
    end;
  end;
end;

{ TDesItemRemoveXml }

procedure TSendRootItemRemoveXml.Update;
begin
  inherited;

  if not FindSendRootItemNode then
    Exit;

  SendRootItemNodeList.ChildNodes.Delete( SendRootItemIndex );
end;

{ TBackupItemWriteXml }

function TSendItemWriteXml.FindSendItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  SendItemNodeList := nil;
  if not FindSendItemNodeList then
    Exit;
  for i := 0 to SendItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := SendItemNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_SourcePath ) = SourcePath then
    begin
      Result := True;
      SendItemIndex := i;
      SendItemNode := SelectNode;
      Break;
    end;
  end;
end;

procedure TSendItemWriteXml.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

{ TBackupWriteXml }

function TSendItemChangeXml.FindSendItemNodeList: Boolean;
begin
  Result := FindSendRootItemNode;
  if Result then
    SendItemNodeList := MyXmlUtil.AddChild( SendRootItemNode, Xml_SendItemList );
end;

{ TBackupItemAddXml }

procedure TSendItemAddXml.AddItemInfo;
begin

end;

procedure TSendItemAddXml.RefreshSendCount;
var
  LastSendCount : Integer;
begin
  LastSendCount := MyXmlUtil.GetChildIntValue( MyFileSendNode, Xml_SendCount );
  LastSendCount := LastSendCount + 1;
  MyXmlUtil.AddChild( MyFileSendNode, Xml_SendCount, LastSendCount );
  Inc( MySendItem_SendCount );
end;

procedure TSendItemAddXml.SetIsCompleted(_IsCompleted : Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TSendItemAddXml.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemAddXml.SetScheduleInfo(_ScheduleType, _ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleType := _ScheduleType;
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemAddXml.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemAddXml.SetZipInfo(_IsZip: Boolean; _ZipPath: string);
begin
  IsZip := _IsZip;
  ZipPath := _ZipPath;
end;

procedure TSendItemAddXml.Update;
begin
  inherited;

  if FindSendItemNode or ( SendItemNodeList = nil ) then
    Exit;

  SendItemNode := MyXmlUtil.AddListChild( SendItemNodeList );
  MyXmlUtil.AddChild( SendItemNode, Xml_SourcePath, SourcePath );
  MyXmlUtil.AddChild( SendItemNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( SendItemNode, Xml_IsCompleted, IsCompleted );
  MyXmlUtil.AddChild( SendItemNode, Xml_IsReceiveCancel, IsCancel );

  MyXmlUtil.AddChild( SendItemNode, Xml_IsZip, IsZip );
  MyXmlUtil.AddChild( SendItemNode, Xml_ZipPath, ZipPath );

  MyXmlUtil.AddChild( SendItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( SendItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( SendItemNode, Xml_CompletedSize, CompletedSize );

  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleType, ScheduleType );
  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleValue1, ScheduleValue1 );
  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleValue2, ScheduleValue2 );
  MyXmlUtil.AddChild( SendItemNode, Xml_LastSendTime, LastSendTime );

    // 刷新总发送数目
  RefreshSendCount;

    // 添加额外信息
  AddItemInfo;
end;

{ TBackupItemRemoveXml }

procedure TSendItemRemoveXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  SendItemNodeList.ChildNodes.Delete( SendItemIndex );
end;

{ TBackupXmlReadHandle }

procedure TMyFileSendReadXmlHandle.ReadSendCount;
begin
  MySendItem_SendCount := MyXmlUtil.GetChildIntValue( MyFileSendRoot, Xml_SendCount );
end;

procedure TMyFileSendReadXmlHandle.ReadSendDesHistoryList;
var
  SendDesHistoryNodeList : IXMLNode;
  i : Integer;
  SendDesHistoryNode : IXMLNode;
  SendDesHistoryReadXml : TSendDesHistoryReadXml;
begin
  SendDesHistoryNodeList := MyXmlUtil.AddChild( MyFileSendRoot, Xml_SendDesHistoryList );
  for i := 0 to SendDesHistoryNodeList.ChildNodes.Count - 1 do
  begin
    SendDesHistoryNode := SendDesHistoryNodeList.ChildNodes[i];
    SendDesHistoryReadXml := TSendDesHistoryReadXml.Create( SendDesHistoryNode );
    SendDesHistoryReadXml.Update;
    SendDesHistoryReadXml.Free;
  end;
end;

procedure TMyFileSendReadXmlHandle.ReadSendFileHistoryList;
var
  SendFileHistoryNodeList : IXMLNode;
  i : Integer;
  SendFileHistoryNode : IXMLNode;
  SendFileHistoryReadXml : TSendFileHistoryReadXml;
begin
  SendFileHistoryNodeList := MyXmlUtil.AddChild( MyFileSendRoot, Xml_SendFileHistoryList );
  for i := 0 to SendFileHistoryNodeList.ChildNodes.Count - 1 do
  begin
    SendFileHistoryNode := SendFileHistoryNodeList.ChildNodes[i];
    SendFileHistoryReadXml := TSendFileHistoryReadXml.Create( SendFileHistoryNode );
    SendFileHistoryReadXml.Update;
    SendFileHistoryReadXml.Free;
  end;
end;



procedure TMyFileSendReadXmlHandle.ReadSendRootItemList;
var
  DesItemNodeList : IXMLNode;
  i : Integer;
  DesItemNode : IXMLNode;
  BackupDesItemReadXml : TSendRootItemReadXml;
begin
  DesItemNodeList := MyXmlUtil.AddChild( MyFileSendRoot, Xml_SendRootItemList );
  for i := 0 to DesItemNodeList.ChildNodes.Count - 1 do
  begin
    DesItemNode := DesItemNodeList.ChildNodes[i];

    BackupDesItemReadXml := TSendRootItemReadXml.Create( DesItemNode );
    BackupDesItemReadXml.Update;
    BackupDesItemReadXml.Free;
  end;
end;

procedure TMyFileSendReadXmlHandle.Update;
begin
  MyFileSendRoot := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileSendInfo );

  ReadSendRootItemList;

  ReadBackupSpeed;

  ReadSendFileHistoryList;

  ReadSendDesHistoryList;

  ReadSendCount;
end;

{ TBackupDesItemReadXml }

constructor TSendRootItemReadXml.Create(_SendRootItemNode: IXMLNode);
begin
  SendRootItemNode := _SendRootItemNode;
end;

procedure TSendRootItemReadXml.ReadSendItemList;
var
  BackupItemList : IXMLNode;
  i : Integer;
  BackupItemNode : IXMLNode;
  BackupItemReadXml : TSendItemReadXml;
begin
  BackupItemList := MyXmlUtil.AddChild( SendRootItemNode, Xml_SendItemList );
  for i := 0 to BackupItemList.ChildNodes.Count - 1 do
  begin
    BackupItemNode := BackupItemList.ChildNodes[i];

    BackupItemReadXml := TSendItemReadXml.Create( BackupItemNode );
    BackupItemReadXml.SetSendRootItemID( SendRootItemID );
    BackupItemReadXml.SetIsLocalItem( IsLocalItem );
    BackupItemReadXml.Update;
    BackupItemReadXml.Free;
  end;
end;

procedure TSendRootItemReadXml.Update;
var
  DesItemType : string;
  DesItemReadLocalHandle : TSendRootItemReadLocalHandle;
  DesItemReadNetworkHandle : TSendRootItemReadNetworkHandle;
begin
  SendRootItemID := MyXmlUtil.GetChildValue( SendRootItemNode, Xml_SendRootItemID );
  DesItemType := MyXmlUtil.GetChildValue( SendRootItemNode, Xml_SendRootItemType );
  IsLocalItem := DesItemType = DesItemType_Local;

    // 读取 本地目标路径
  if IsLocalItem then
  begin
    DesItemReadLocalHandle := TSendRootItemReadLocalHandle.Create( SendRootItemID );
    DesItemReadLocalHandle.Update;
    DesItemReadLocalHandle.Free;
  end
  else
  begin   // 读取 网络目标路径
    DesItemReadNetworkHandle := TSendRootItemReadNetworkHandle.Create( SendRootItemID );
    DesItemReadNetworkHandle.SetIsOnline( False );
    DesItemReadNetworkHandle.SetAvailableSpace( -1 );
    DesItemReadNetworkHandle.Update;
    DesItemReadNetworkHandle.Free;
  end;


    // 读取 目标路径 的源路径
  ReadSendItemList;
end;

{ TBackupItemReadXml }

constructor TSendItemReadXml.Create(_SendItemNode: IXMLNode);
begin
  SendItemNode := _SendItemNode;
end;

procedure TSendItemReadXml.ReadCompletedLogList;
var
  BackupCompletedLogList : IXMLNode;
  i : Integer;
  BackupCompletedNode : IXMLNode;
  BackupCompletedLogReadXml : TBackupCompletedLogReadXml;
begin
  BackupCompletedLogList := MyXmlUtil.AddChild( SendItemNode, Xml_SendCompletedLogList );
  for i := 0 to BackupCompletedLogList.ChildNodes.Count - 1 do
  begin
    BackupCompletedNode := BackupCompletedLogList.ChildNodes[i];
    BackupCompletedLogReadXml := TBackupCompletedLogReadXml.Create( BackupCompletedNode );
    BackupCompletedLogReadXml.SetItemInfo( SendRootItemID, SourcePath );
    BackupCompletedLogReadXml.Update;
    BackupCompletedLogReadXml.Free;
  end;
end;

procedure TSendItemReadXml.ReadContinuseList;
var
  SendContinusNodeList : IXMLNode;
  i : Integer;
  SendContinusNode : IXMLNode;
  SendContinusReadXml : TSendContinusReadXml;
begin
  SendContinusNodeList := MyXmlUtil.AddChild( SendItemNode, Xml_BackupContinusList );
  for i := 0 to SendContinusNodeList.ChildNodes.Count - 1 do
  begin
    SendContinusNode := SendContinusNodeList.ChildNodes[i];
    SendContinusReadXml := TSendContinusReadXml.Create( SendContinusNode );
    SendContinusReadXml.SetItemInfo( SendRootItemID, SourcePath );
    SendContinusReadXml.Update;
    SendContinusReadXml.Free;
  end;
end;






procedure TSendItemReadXml.ReadFilterList;
var
  IncludeFilterListNode, ExcludeFilterListNode : IXMLNode;
  BackupItemIncludeFilterReadXml : TSendItemIncludeFilterReadXml;
  BackupItemExcludeFilterReadXml : TSendItemExcludeFilterReadXml;
begin
    // 读取 包含过滤
  IncludeFilterListNode := MyXmlUtil.AddChild( SendItemNode, Xml_IncludeFilterList );
  BackupItemIncludeFilterReadXml := TSendItemIncludeFilterReadXml.Create( IncludeFilterListNode );
  BackupItemIncludeFilterReadXml.SetSendRootItemID( SendRootItemID );
  BackupItemIncludeFilterReadXml.SetSourcePath( SourcePath );
  BackupItemIncludeFilterReadXml.Update;
  BackupItemIncludeFilterReadXml.Free;

    // 读取 包含过滤
  ExcludeFilterListNode := MyXmlUtil.AddChild( SendItemNode, Xml_ExcludeFilterList );
  BackupItemExcludeFilterReadXml := TSendItemExcludeFilterReadXml.Create( ExcludeFilterListNode );
  BackupItemExcludeFilterReadXml.SetSendRootItemID( SendRootItemID );
  BackupItemExcludeFilterReadXml.SetSourcePath( SourcePath );
  BackupItemExcludeFilterReadXml.Update;
  BackupItemExcludeFilterReadXml.Free;
end;

procedure TSendItemReadXml.ReadIncompletedLogList;
var
  BackupCompletedLogList : IXMLNode;
  i : Integer;
  BackupIncompletedNode : IXMLNode;
  BackupIncompletedLogReadXml : TBackupIncompletedLogReadXml;
begin
  BackupCompletedLogList := MyXmlUtil.AddChild( SendItemNode, Xml_SendIncompletedLogList );
  for i := 0 to BackupCompletedLogList.ChildNodes.Count - 1 do
  begin
    BackupIncompletedNode := BackupCompletedLogList.ChildNodes[i];
    BackupIncompletedLogReadXml := TBackupIncompletedLogReadXml.Create( BackupIncompletedNode );
    BackupIncompletedLogReadXml.SetItemInfo( SendRootItemID, SourcePath );
    BackupIncompletedLogReadXml.Update;
    BackupIncompletedLogReadXml.Free;
  end;
end;

procedure TSendItemReadXml.SetIsLocalItem(_IsLocalItem: Boolean);
begin
  IsLocalItem := _IsLocalItem;
end;

procedure TSendItemReadXml.SetSendRootItemID(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;

procedure TSendItemReadXml.Update;
var
  IsFile, IsCompleted : Boolean;
  FileCount : Integer;
  ItemSize, CompletedSize : Int64; // 空间信息
  IsAddToReceive, IsRemoveToReceive : Boolean;
  IsReceiveCancel, IsZip : Boolean;
  SavePath, ZipPath : string;
  ScheduleTypeStr, LastSendTimeStr : string;
  ScheduleType, ScheduleValue1, ScheduleValue2 : Integer;
  LastSendTime : TDateTime;
  SendItemReadLocalHandle : TSendItemReadLocalHandle;
  SendItemReadNetworkHandle : TSendItemReadNetworkHandle;
begin
  SourcePath := MyXmlUtil.GetChildValue( SendItemNode, Xml_SourcePath );
  IsFile := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsFile );
  IsCompleted := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsCompleted );

  IsZip := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsZip );
  ZipPath := MyXmlUtil.GetChildValue( SendItemNode, Xml_ZipPath );

  FileCount := MyXmlUtil.GetChildIntValue( SendItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( SendItemNode, Xml_ItemSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( SendItemNode, Xml_CompletedSize );

  ScheduleTypeStr := MyXmlUtil.GetChildValue( SendItemNode, Xml_ScheduleType );
  if ScheduleTypeStr = '' then  // 版本兼容
    ScheduleType := ScheduleType_Manual
  else
  begin
    ScheduleType := MyXmlUtil.GetChildIntValue( SendItemNode, Xml_ScheduleType );
    ScheduleValue1 := MyXmlUtil.GetChildIntValue( SendItemNode, Xml_ScheduleValue1 );
    ScheduleValue2 := MyXmlUtil.GetChildIntValue( SendItemNode, Xml_ScheduleValue2 );
  end;
  LastSendTimeStr := MyXmlUtil.GetChildValue( SendItemNode, Xml_LastSendTime );
  if LastSendTimeStr = '' then
    LastSendTime := 0
  else
    LastSendTime := MyXmlUtil.GetChildFloatValue( SendItemNode, Xml_LastSendTime );

  if IsLocalItem then
  begin
    SavePath := MyXmlUtil.GetChildValue( SendItemNode, Xml_SavePath );
    SendItemReadLocalHandle := TSendItemReadLocalHandle.Create( SendRootItemID );
    SendItemReadLocalHandle.SetSourceInfo( SourcePath );
    SendItemReadLocalHandle.SetIsFile( IsFile );
    SendItemReadLocalHandle.SetIsCompleted( IsCompleted );
    SendItemReadLocalHandle.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
    SendItemReadLocalHandle.SetZipInfo( IsZip, ZipPath );
    SendItemReadLocalHandle.SetSavePath( SavePath );
    SendItemReadLocalHandle.Update;
    SendItemReadLocalHandle.Free;
  end
  else
  begin
    IsAddToReceive := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsAddToReceive );
    IsRemoveToReceive := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsRemoveToReceve );
    IsReceiveCancel := MyXmlUtil.GetChildBoolValue( SendItemNode, Xml_IsReceiveCancel );
    SendItemReadNetworkHandle := TSendItemReadNetworkHandle.Create( SendRootItemID );
    SendItemReadNetworkHandle.SetSourceInfo( SourcePath );
    SendItemReadNetworkHandle.SetIsFile( IsFile );
    SendItemReadNetworkHandle.SetIsCompleted( IsCompleted );
    SendItemReadNetworkHandle.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
    SendItemReadNetworkHandle.SetZipInfo( IsZip, ZipPath );
    SendItemReadNetworkHandle.SetReceiveInfo( IsAddToReceive, IsRemoveToReceive );
    SendItemReadNetworkHandle.SetIsReceiveCancel( IsReceiveCancel );
    SendItemReadNetworkHandle.SetScheduleInfo( ScheduleType, ScheduleValue1, ScheduleValue2 );
    SendItemReadNetworkHandle.SetLastSendTime( LastSendTime );
    SendItemReadNetworkHandle.Update;
    SendItemReadNetworkHandle.Free;
  end;

  ReadFilterList;

  ReadContinuseList;

  ReadCompletedLogList;

  ReadIncompletedLogList;
end;

{ TDesItemChangeXml }

procedure TSendRootItemChangeXml.Update;
begin
  MyFileSendNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileSendInfo );
  SendRootItemNodeList := MyXmlUtil.AddChild( MyFileSendNode, Xml_SendRootItemList );
end;


{ TBackupItemSetSpaceInfoXml }

procedure TSendItemSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( SendItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( SendItemNode, Xml_CompletedSize, CompletedSize );
end;

{ TBackupItemSetAddCompletedSpaceXml }

procedure TSendItemSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TSendItemSetAddCompletedSpaceXml.Update;
var
  CompletedSpace : Int64;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  CompletedSpace := MyXmlUtil.GetChildInt64Value( SendItemNode, Xml_CompletedSize );
  CompletedSpace := CompletedSpace + AddCompletedSpace;
  MyXmlUtil.AddChild( SendItemNode, Xml_CompletedSize, CompletedSpace );
end;

{ TDesItemAddLocalXml }

procedure TSendRootItemAddLocalXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( SendRootItemNode, Xml_SendRootItemType, DesItemType_Local );
end;

{ TDesItemAddNetworkXml }

procedure TSendRootItemAddNetworkXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( SendRootItemNode, Xml_SendRootItemType, DesItemType_Network );
end;

{ TBackupItemFilterAddXml }

procedure TSendItemFilterAddXml.SetFilterXml(_FilterType,
  _FilterValue: string);
begin
  FilterType := _FilterType;
  FilterValue := _FilterValue;
end;

{ TBackupItemIncludeFilterClearXml }

procedure TSendItemIncludeFilterClearXml.Update;
begin
  inherited;
  if not FindFilterList then
    Exit;
  IncludeFilterListNode.ChildNodes.Clear;
end;

{ TBackupItemFilterWriteXml }

function TSendItemFilterWriteXml.FindFilterList: Boolean;
begin
  Result := False;
  if not FindSendItemNode then
    Exit;
  IncludeFilterListNode := MyXmlUtil.AddChild( SendItemNode, Xml_IncludeFilterList );
  ExcludeFilterListNode := MyXmlUtil.AddChild( SendItemNode, Xml_ExcludeFilterList );
  Result := True;
end;

{ TBackupItemIncludeFilterAddXml }

procedure TSendItemIncludeFilterAddXml.Update;
var
  FilterNode : IXMLNode;
begin
  inherited;
  if not FindFilterList then
    Exit;
  FilterNode := MyXmlUtil.AddListChild( IncludeFilterListNode );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterValue, FilterValue );
end;

{ TBackupItemExcludeFilterClearXml }

procedure TSendItemExcludeFilterClearXml.Update;
begin
  inherited;
  if not FindFilterList then
    Exit;
  ExcludeFilterListNode.ChildNodes.Clear;
end;

{ TBackupItemExcludeFilterAddXml }

procedure TSendItemExcludeFilterAddXml.Update;
var
  FilterNode : IXMLNode;
begin
  inherited;
  if not FindFilterList then
    Exit;
  FilterNode := MyXmlUtil.AddListChild( ExcludeFilterListNode );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterValue, FilterValue );
end;


{ TBackupItemIncludeFilterReadXml }

constructor TSendItemIncludeFilterReadXml.Create(
  _IncludeFilterListNode: IXMLNode);
begin
  IncludeFilterListNode := _IncludeFilterListNode;
end;

procedure TSendItemIncludeFilterReadXml.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

procedure TSendItemIncludeFilterReadXml.SetSendRootItemID(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;

procedure TSendItemIncludeFilterReadXml.Update;
var
  FilterList : TFileFilterList;
  i: Integer;
  FilterNode : IXMLNode;
  FilterType, FilterValue : string;
  FilterInfo : TFileFilterInfo;
  BackupItemIncludeFilterReadHandle : TSendItemIncludeFilterReadHandle;
begin
    // 读取信息
  FilterList := TFileFilterList.Create;
  for i := 0 to IncludeFilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := IncludeFilterListNode.ChildNodes[i];
    FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
    FilterValue := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterValue );
    FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
    FilterList.Add( FilterInfo );
  end;

    // 处理信息
  BackupItemIncludeFilterReadHandle := TSendItemIncludeFilterReadHandle.Create( SendRootItemID );
  BackupItemIncludeFilterReadHandle.SetSourceInfo( SourcePath );
  BackupItemIncludeFilterReadHandle.SetIncludeFilterList( FilterList );
  BackupItemIncludeFilterReadHandle.Update;
  BackupItemIncludeFilterReadHandle.Free;

  FilterList.Free;
end;

{ TBackupItemExcludeFilterReadXml }

constructor TSendItemExcludeFilterReadXml.Create(
  _ExcludeFilterListNode: IXMLNode);
begin
  ExcludeFilterListNode := _ExcludeFilterListNode;
end;

procedure TSendItemExcludeFilterReadXml.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

procedure TSendItemExcludeFilterReadXml.SetSendRootItemID(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
end;

procedure TSendItemExcludeFilterReadXml.Update;
var
  FilterList : TFileFilterList;
  i: Integer;
  FilterNode : IXMLNode;
  FilterType, FilterValue : string;
  FilterInfo : TFileFilterInfo;
  BackupItemExcludeFilterReadHandle : TSendItemExcludeFilterReadHandle;
begin
    // 读取信息
  FilterList := TFileFilterList.Create;
  for i := 0 to ExcludeFilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := ExcludeFilterListNode.ChildNodes[i];
    FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
    FilterValue := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterValue );
    FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
    FilterList.Add( FilterInfo );
  end;

    // 处理信息
  BackupItemExcludeFilterReadHandle := TSendItemExcludeFilterReadHandle.Create( SendRootItemID );
  BackupItemExcludeFilterReadHandle.SetSourceInfo( SourcePath );
  BackupItemExcludeFilterReadHandle.SetExcludeFilterList( FilterList );
  BackupItemExcludeFilterReadHandle.Update;
  BackupItemExcludeFilterReadHandle.Free;

  FilterList.Free;
end;

{ TBackupItemSetIsCompletedXml }

procedure TSendItemSetIsCompletedXml.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemSetIsCompletedXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_IsCompleted, IsCompleted );
end;

{ TBackupContinusChangeXml }

function TSendContinusChangeXml.FindBackupContinusNodeList : Boolean;
begin
  Result := FindSendItemNode;
  if Result then
    BackupContinusNodeList := MyXmlUtil.AddChild( SendItemNode, Xml_BackupContinusList );
end;

{ TBackupContinusWriteXml }

procedure TSendContinusWriteXml.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TSendContinusWriteXml.FindBackupContinusNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindBackupContinusNodeList then
    Exit;
  for i := 0 to BackupContinusNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupContinusNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) then
    begin
      Result := True;
      BackupContinusIndex := i;
      BackupContinusNode := BackupContinusNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TBackupContinusAddXml }

procedure TSendContinusAddXml.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TSendContinusAddXml.SetSpaceInfo( _FileSize, _Position : int64 );
begin
  FileSize := _FileSize;
  Postion := _Position;
end;

procedure TSendContinusAddXml.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindBackupContinusNode then
  begin
    BackupContinusNode := MyXmlUtil.AddListChild( BackupContinusNodeList );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FilePath, FilePath );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FileSize, FileSize );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FileTime, FileTime );
  end;
  MyXmlUtil.AddChild( BackupContinusNode, Xml_Position, Postion );
end;

{ TBackupContinusRemoveXml }

procedure TSendContinusRemoveXml.Update;
begin
  inherited;

  if not FindBackupContinusNode then
    Exit;

  MyXmlUtil.DeleteListChild( BackupContinusNodeList, BackupContinusIndex );
end;


{ TSendItemAddLocalXml }

procedure TSendItemAddLocalXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( SendItemNode, Xml_SavePath, SavePath );
end;

procedure TSendItemAddLocalXml.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TSendItemAddNetworkXml }

procedure TSendItemAddNetworkXml.AddItemInfo;
begin
  MyXmlUtil.AddChild( SendItemNode, Xml_IsAddToReceive, IsAddToReceive );
  MyXmlUtil.AddChild( SendItemNode, Xml_IsRemoveToReceve, IsRemoveToReceive );
  MyXmlUtil.AddChild( SendItemNode, Xml_IsReceiveCancel, IsReceiveCancel );
end;

procedure TSendItemAddNetworkXml.SetIsReceiveCancel(_IsReceiveCancel: Boolean);
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemAddNetworkXml.SetReceiveInfo(_IsAddToReceive,
  _IsRemoveToReceive: Boolean);
begin
  IsAddToReceive := _IsAddToReceive;
  IsRemoveToReceive := _IsRemoveToReceive;
end;

{ TSendItemSetIsAddToReceiveXml }

procedure TSendItemSetIsAddToReceiveXml.SetIsAddToReceive( _IsAddToReceive : boolean );
begin
  IsAddToReceive := _IsAddToReceive;
end;

procedure TSendItemSetIsAddToReceiveXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_IsAddToReceive, IsAddToReceive );
end;

{ TSendItemSetIsRemoveToReceiveXml }

procedure TSendItemSetIsRemoveToReceiveXml.SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
begin
  IsRemoveToReceive := _IsRemoveToReceive;
end;

procedure TSendItemSetIsRemoveToReceiveXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_IsRemoveToReceve, IsRemoveToReceive );
end;

{ TSendItemSetIsReceiveCancelXml }

procedure TSendItemSetIsReceiveCancelXml.SetIsReceiveCancel( _IsReceiveCancel : boolean );
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemSetIsReceiveCancelXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_IsReceiveCancel, IsReceiveCancel );
end;



{ TSendRootItemAddXml }

procedure TSendRootItemAddXml.Update;
begin
  inherited;

    // 已存在
  if FindSendRootItemNode then
    Exit;

  SendRootItemNode := MyXmlUtil.AddListChild( SendRootItemNodeList );
  MyXmlUtil.AddChild( SendRootItemNode, Xml_SendRootItemID, SendRootItemID );
  AddItemInfo;
end;

{ SendContinusNode }

constructor TSendContinusReadXml.Create( _SendContinusNode : IXMLNode );
begin
  SendContinusNode := _SendContinusNode;
end;

procedure TSendContinusReadXml.SetItemInfo(_SendRootItemID,
  _SourcePath: string);
begin
  SendRootItemID := _SendRootItemID;
  SourcePath := _SourcePath;
end;

procedure TSendContinusReadXml.Update;
var
  FilePath : string;
  FileSize, Position : int64;
  FileTime : TDateTime;
  SendContinusReadHandle : TSendContinusReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( SendContinusNode, Xml_FilePath );
  FileSize := MyXmlUtil.GetChildInt64Value( SendContinusNode, Xml_FileSize );
  Position := MyXmlUtil.GetChildInt64Value( SendContinusNode, Xml_Position );
  FileTime := MyXmlUtil.GetChildFloatValue( SendContinusNode, Xml_FileTime );

  SendContinusReadHandle := TSendContinusReadHandle.Create( SendRootItemID );
  SendContinusReadHandle.SetSourceInfo( SourcePath );
  SendContinusReadHandle.SetFilePath( FilePath );
  SendContinusReadHandle.SetSpaceInfo( FileSize, Position );
  SendContinusReadHandle.SetFileTime( FileTime );
  SendContinusReadHandle.Update;
  SendContinusReadHandle.Free;
end;

{ TSendFileHistoryChangeXml }

procedure TSendFileHistoryChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileSendInfo );
  SendFileHistoryNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_SendFileHistoryList );
end;


{ TSendFileHistoryAddXml }

constructor TSendFileHistoryAddXml.Create(_SendPathList: TStringList);
begin
  SendPathList := _SendPathList;
end;

destructor TSendFileHistoryAddXml.Destroy;
begin
  SendPathList.Free;
  inherited;
end;

procedure TSendFileHistoryAddXml.Update;
var
  SendFileHistoryNode : IXMLNode;
  SendPathListNode, SendPathNode : IXMLNode;
  i: Integer;
begin
  inherited;

  SendFileHistoryNode := MyXmlUtil.AddListChild( SendFileHistoryNodeList );
  SendPathListNode := MyXmlUtil.AddChild( SendFileHistoryNode, Xml_SendPathList );
  for i := 0 to SendPathList.Count - 1 do
  begin
    SendPathNode := MyXmlUtil.AddListChild( SendPathListNode );
    MyXmlUtil.AddChild( SendPathNode, Xml_SendPath, SendPathList[i] );
  end;
end;

{ TSendFileHistoryRemoveXml }

constructor TSendFileHistoryRemoveXml.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendFileHistoryRemoveXml.Update;
begin
  inherited;

  RemoveIndex := SendFileHistoryNodeList.ChildNodes.Count - 1 - RemoveIndex;

  if SendFileHistoryNodeList.ChildNodes.Count <= RemoveIndex then
    Exit;

  MyXmlUtil.DeleteListChild( SendFileHistoryNodeList, RemoveIndex );
end;

{ TSendFileHistoryClearXml }

procedure TSendFileHistoryClearXml.Update;
begin
  inherited;

  SendFileHistoryNodeList.ChildNodes.Clear;
end;

{ SendFileHistoryNode }

constructor TSendFileHistoryReadXml.Create( _SendFileHistoryNode : IXMLNode );
begin
  SendFileHistoryNode := _SendFileHistoryNode;
end;

procedure TSendFileHistoryReadXml.Update;
var
  SendPathListNode, SendPathNode : IXMLNode;
  i : Integer;
  SendPathList : TStringList;
  SendPath : string;
  SendFileHistoryReadHandle : TSendFileHistoryReadHandle;
begin
  SendPathList := TStringList.Create;

  SendPathListNode := MyXmlUtil.AddChild( SendFileHistoryNode, Xml_SendPathList );
  for i := 0 to SendPathListNode.ChildNodes.Count - 1 do
  begin
    SendPathNode := SendPathListNode.ChildNodes[i];
    SendPath := MyXmlUtil.GetChildValue( SendPathNode, Xml_SendPath );
    SendPathList.Add( SendPath );
  end;

  SendFileHistoryReadHandle := TSendFileHistoryReadHandle.Create( SendPathList );
  SendFileHistoryReadHandle.Update;
  SendFileHistoryReadHandle.Free;

  SendPathList.Free;
end;

{ TSendDesHistoryChangeXml }

procedure TSendDesHistoryChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileSendInfo );
  SendDesHistoryNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_SendDesHistoryList );
end;


{ TSendDesHistoryAddXml }

constructor TSendDesHistoryAddXml.Create(_SendDesList: TStringList);
begin
  SendDesList := _SendDesList;
end;

destructor TSendDesHistoryAddXml.Destroy;
begin
  SendDesList.Free;
  inherited;
end;

procedure TSendDesHistoryAddXml.Update;
var
  SendDesHistoryNode : IXMLNode;
  SendDesListNode, SendDesNode : IXMLNode;
  i: Integer;
begin
  inherited;

  SendDesHistoryNode := MyXmlUtil.AddListChild( SendDesHistoryNodeList );
  SendDesListNode := MyXmlUtil.AddChild( SendDesHistoryNode, Xml_SendDesList );
  for i := 0 to SendDesList.Count - 1 do
  begin
    SendDesNode := MyXmlUtil.AddListChild( SendDesListNode );
    MyXmlUtil.AddChild( SendDesNode, Xml_SendDes, SendDesList[i] );
  end;
end;

{ TSendDesHistoryRemoveXml }

constructor TSendDesHistoryRemoveXml.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TSendDesHistoryRemoveXml.Update;
begin
  inherited;

  RemoveIndex := SendDesHistoryNodeList.ChildNodes.Count - 1 - RemoveIndex;

  if SendDesHistoryNodeList.ChildNodes.Count <= RemoveIndex then
    Exit;

  MyXmlUtil.DeleteListChild( SendDesHistoryNodeList, RemoveIndex );
end;

{ TSendDesHistoryClearXml }

procedure TSendDesHistoryClearXml.Update;
begin
  inherited;

  SendDesHistoryNodeList.ChildNodes.Clear;
end;

{ SendDesHistoryNode }

constructor TSendDesHistoryReadXml.Create( _SendDesHistoryNode : IXMLNode );
begin
  SendDesHistoryNode := _SendDesHistoryNode;
end;

procedure TSendDesHistoryReadXml.Update;
var
  SendDesListNode, SendDesNode : IXMLNode;
  i : Integer;
  SendDesList : TStringList;
  SendDes : string;
  SendDesHistoryReadHandle : TSendDesHistoryReadHandle;
begin
  SendDesList := TStringList.Create;

  SendDesListNode := MyXmlUtil.AddChild( SendDesHistoryNode, Xml_SendDesList );
  for i := 0 to SendDesListNode.ChildNodes.Count - 1 do
  begin
    SendDesNode := SendDesListNode.ChildNodes[i];
    SendDes := MyXmlUtil.GetChildValue( SendDesNode, Xml_SendDes );
    SendDesList.Add( SendDes );
  end;

  SendDesHistoryReadHandle := TSendDesHistoryReadHandle.Create( SendDesList );
  SendDesHistoryReadHandle.Update;
  SendDesHistoryReadHandle.Free;

  SendDesList.Free;
end;

{ TBackupSpeedChangeXml }

procedure TBackupSpeedChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyFileSendInfo );
  BackupSpeedNode := MyXmlUtil.AddChild( MyBackupNode, Xml_BackupSpeed );
end;

{ TBackupSpeedLimitXml }

procedure TBackupSpeedLimitXml.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitXml.SetLimitXml(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TBackupSpeedLimitXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( BackupSpeedNode, Xml_IsLimit, IsLimit );
  MyXmlUtil.AddChild( BackupSpeedNode, Xml_LimitType, LimitType );
  MyXmlUtil.AddChild( BackupSpeedNode, Xml_LimitValue, LimitValue );
end;

{ TBackupSpeedReadXml }

constructor TBackupSpeedReadXml.Create(_BackupSpeedNode: IXMLNode);
begin
  BackupSpeedNode := _BackupSpeedNode;
end;

procedure TBackupSpeedReadXml.Update;
var
  IsLimit : Boolean;
  LimitType, LimitValue : Integer;
  BackupSpeedLimitReadHandle : TBackupSpeedLimitReadHandle;
begin
  IsLimit := StrToBoolDef( MyXmlUtil.GetChildValue( BackupSpeedNode, Xml_IsLimit ), False );
  LimitType := MyXmlUtil.GetChildIntValue( BackupSpeedNode, Xml_LimitType );
  LimitValue := MyXmlUtil.GetChildIntValue( BackupSpeedNode, Xml_LimitValue );

  BackupSpeedLimitReadHandle := TBackupSpeedLimitReadHandle.Create( IsLimit );
  BackupSpeedLimitReadHandle.SetLimitInfo( LimitType, LimitValue );
  BackupSpeedLimitReadHandle.Update;
  BackupSpeedLimitReadHandle.Free
end;

procedure TMyFileSendReadXmlHandle.ReadBackupSpeed;
var
  BackupSpeedNode : IXMLNode;
  BackupSpeedReadXml : TBackupSpeedReadXml;
begin
  BackupSpeedNode := MyXmlUtil.AddChild( MyFileSendRoot, Xml_BackupSpeed );

  BackupSpeedReadXml := TBackupSpeedReadXml.Create( BackupSpeedNode );
  BackupSpeedReadXml.Update;
  BackupSpeedReadXml.Free;
end;

{ TSendLogChangeXml }

function TSendCompletedLogChangeXml.FindSendCompletedLogNodeList: Boolean;
begin
  Result := FindSendItemNode;
  if Result then
    SendCompletedLogNodeList := MyXmlUtil.AddChild( SendItemNode, Xml_SendCompletedLogList );
end;

{ TSendLogClearXml }

procedure TSendLogClearCompletedXml.Update;
begin
  inherited;

    // Item 不存在
  if not FindSendCompletedLogNodeList then
    Exit;

  SendCompletedLogNodeList.ChildNodes.Clear;
end;

{ TSendLogAddCompletedXml }

procedure TSendLogAddCompletedXml.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TSendLogAddCompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendLogAddCompletedXml.Update;
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
  MyXmlUtil.AddChild( BackupLogNode, Xml_SendTime, SendTime );
end;

{ TSendLogAddIncompletedXml }

procedure TSendLogAddIncompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendLogAddIncompletedXml.Update;
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

procedure TSendLogClearIncompletedXml.Update;
begin
  inherited;

  if not FindSendIncompletedLogNodeList then
    Exit;

  SendIncompletedLogNodeList.ChildNodes.Clear;
end;

{ TSendIncompletedLogChangeXml }

function TSendIncompletedLogChangeXml.FindSendIncompletedLogNodeList: Boolean;
begin
  Result := FindSendItemNode;
  if Result then
    SendIncompletedLogNodeList := MyXmlUtil.AddChild( SendItemNode, Xml_SendIncompletedLogList );
end;

{ TBackupCompletedLogReadXml }

constructor TBackupCompletedLogReadXml.Create(_BackupCompletedLog: IXMLNode);
begin
  BackupCompletedLog := _BackupCompletedLog;
end;

procedure TBackupCompletedLogReadXml.SetItemInfo(_SendRootItemID,
  _SourcePath: string);
begin
  DesItemID := _SendRootItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupCompletedLogReadXml.Update;
var
  FilePath : string;
  BackupTime : TDateTime;
  BackupLogCompletedReadHandle : TBackupLogCompletedReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( BackupCompletedLog, Xml_FilePath );
  BackupTime := MyXmlUtil.GetChildFloatValue( BackupCompletedLog, Xml_SendTime );

  BackupLogCompletedReadHandle := TBackupLogCompletedReadHandle.Create( DesItemID );
  BackupLogCompletedReadHandle.SetSourceInfo( SourcePath );
  BackupLogCompletedReadHandle.SetFilePath( FilePath );
  BackupLogCompletedReadHandle.SetBackupTime( BackupTime );
  BackupLogCompletedReadHandle.Update;
  BackupLogCompletedReadHandle.Free;
end;

{ TBackupIncompletedLogReadXml }

constructor TBackupIncompletedLogReadXml.Create(
  _BackupIncompletedLog: IXMLNode);
begin
  BackupIncompletedLog := _BackupIncompletedLog;
end;

procedure TBackupIncompletedLogReadXml.SetItemInfo(_SendRootItemID,
  _SourcePath: string);
begin
  DesItemID := _SendRootItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupIncompletedLogReadXml.Update;
var
  FilePath : string;
  BackupLogIncompletedReadHandle : TBackupLogIncompletedReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( BackupIncompletedLog, Xml_FilePath );

  BackupLogIncompletedReadHandle := TBackupLogIncompletedReadHandle.Create( DesItemID );
  BackupLogIncompletedReadHandle.SetSourceInfo( SourcePath );
  BackupLogIncompletedReadHandle.SetFilePath( FilePath );
  BackupLogIncompletedReadHandle.Update;
  BackupLogIncompletedReadHandle.Free;
end;


{ TSendItemSetLastSendTimeXml }

procedure TSendItemSetLastSendTimeXml.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemSetLastSendTimeXml.Update;
begin
  inherited;

  if not FindSendItemNode then
    Exit;

  MyXmlUtil.AddChild( SendItemNode, Xml_LastSendTime, LastSendTime );
end;

{ TSendItemSetScheduleXml }

procedure TSendItemSetScheduleXml.SetSchduleType(_SchduleType: Integer);
begin
  SchduleType := _SchduleType;
end;

procedure TSendItemSetScheduleXml.SetSchduleValue(_SchduleValue1,
  _SchduleValue2: Integer);
begin
  SchduleValue1 := _SchduleValue1;
  SchduleValue2 := _SchduleValue2;
end;

procedure TSendItemSetScheduleXml.Update;
begin
  inherited;
  if not FindSendItemNode then
    Exit;
  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleType, SchduleType );
  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleValue1, SchduleValue1 );
  MyXmlUtil.AddChild( SendItemNode, Xml_ScheduleValue2, SchduleValue2 );
end;

end.
