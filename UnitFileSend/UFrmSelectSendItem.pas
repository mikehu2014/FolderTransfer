unit UFrmSelectSendItem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn, RzTabs,
  Spin, pngimage, UFmFilter, UFileBaseInfo, UFrameFilter, Vcl.ToolWin, UMainForm,
  Vcl.Menus;

type

  // This data record contains all necessary information about a particular file system object.
  // This can either be a folder (virtual or real) or an image file.
  PShellObjectData = ^TShellObjectData;
  TShellObjectData = record
    FullPath, Display: WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
    DisplayIcon : Integer;
  end;

  TScheduleParams = record
  public
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
  end;


  TfrmSelectSendItem = class(TForm)
    PcMain: TRzPageControl;
    TsSelectFile: TRzTabSheet;
    TsInclude: TRzTabSheet;
    vstSelectPath: TVirtualStringTree;
    ilPcMain16: TImageList;
    FrameFilter: TFrameFilterPage;
    tsSelectDes: TRzTabSheet;
    plBottom: TPanel;
    plBtnRight: TPanel;
    Panel5: TPanel;
    ilNw16: TImageList;
    Panel9: TPanel;
    FileDialog: TOpenDialog;
    Panel1: TPanel;
    tbSelectFile: TToolBar;
    tbtnSelectFile: TToolButton;
    tbtnSelectFolder: TToolButton;
    plBackupTitle: TPanel;
    ToolButton1: TToolButton;
    tbtnSelectHistory: TToolButton;
    pmFileHistory: TPopupMenu;
    tbtnUnSelect: TToolButton;
    N1: TMenuItem;
    Clear1: TMenuItem;
    tbtnManually: TToolButton;
    edtPaste: TEdit;
    Panel2: TPanel;
    tbSendDes: TToolBar;
    tbtnSelectOnline: TToolButton;
    tbtnSelectAll: TToolButton;
    tbtnUnSelectPc: TToolButton;
    ToolButton5: TToolButton;
    tbtnPcHistory: TToolButton;
    pmDesHistory: TPopupMenu;
    N2: TMenuItem;
    Clear2: TMenuItem;
    vstNetworkDes: TVirtualStringTree;
    tbtnRefresh: TToolButton;
    plBtnCenter: TPanel;
    btnNext: TButton;
    btnOK2: TButton;
    tsSchedule: TRzTabSheet;
    Panel3: TPanel;
    GroupBox1: TGroupBox;
    img7: TImage;
    Label1: TLabel;
    cbbSchedule: TComboBox;
    pcAutoBackup: TRzPageControl;
    tsManual: TRzTabSheet;
    tsMin: TRzTabSheet;
    Label2: TLabel;
    cbbMin: TComboBox;
    tsHour: TRzTabSheet;
    Label7: TLabel;
    cbbHour: TComboBox;
    tsDay: TRzTabSheet;
    Label4: TLabel;
    cbbDay: TComboBox;
    tsWeek: TRzTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    cbbWeek1: TComboBox;
    cbbWeek2: TComboBox;
    tsMonth: TRzTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    cbbMonth1: TComboBox;
    cbbMonth2: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure vstSelectPathGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstSelectPathFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectPathInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstSelectPathInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectPathChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormShow(Sender: TObject);
    procedure FrameIncludebtnSelectFileClick(Sender: TObject);
    procedure FrameExcludebtnSelectFileClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure PcMainPageChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FrameIncludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameIncludeLvMaskInsert(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure seSyncTimeClick(Sender: TObject);
    procedure btnAddFilesClick(Sender: TObject);
    procedure btnAddFoldersClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbtnSelectFileClick(Sender: TObject);
    procedure tbtnSelectFolderClick(Sender: TObject);
    procedure tbtnUnSelectClick(Sender: TObject);
    procedure tbtnSelectHistoryClick(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure Panel9Click(Sender: TObject);
    procedure tbtnManuallyClick(Sender: TObject);
    procedure tbtnSelectOnlineClick(Sender: TObject);
    procedure tbtnSelectAllClick(Sender: TObject);
    procedure tbtnUnSelectPcClick(Sender: TObject);
    procedure tbtnPcHistoryClick(Sender: TObject);
    procedure Clear2Click(Sender: TObject);
    procedure vstNetworkDesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstNetworkDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstNetworkDesChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstSelectPathFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnRefreshClick(Sender: TObject);
    procedure vstNetworkDesPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstNetworkDesFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FormResize(Sender: TObject);
    procedure cbbScheduleSelect(Sender: TObject);
  private
    LastDriverList : TStringList;
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure AddDriver( Path : string );
    procedure RemoveDriver( Path : string );
  private
    function ReadScheduleValue1 : Integer;
    function ReadScheduleValue2 : Integer;
    procedure ResetSchedule;
  private
    OtherPathList : TStringList;
    procedure AddOtherPaths;
    procedure AddOtherPath( FolderPath : string );
    procedure ResetSettings;
    procedure CheckBtnOkEnable;
  private       // 初始化节点
    function AddFileNode( ParentNode : PVirtualNode; FileName : string ): PVirtualNode;
    function AddFolderNode( ParentNode : PVirtualNode; FolderName : string ): PVirtualNode;
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure SendFileHistoryClick( Sender: TObject );
    procedure SendDesHistoryClick( Sender: TObject );
  private       // 设置
    procedure SetUnCheckedSource( Node : PVirtualNode );   // 清空 Checked
    procedure SetUnCheckDes;
    procedure AddSourceItemList( SourcePathList : TStringList );
    procedure AddSourceItem( SourcePath : string );
    procedure AddDesItemList( DesItemList : TStringList );
    function AddDefaultDes: Boolean;
  private       // 读取
    procedure FindSourcePathList( Node : PVirtualNode; SourcePathList : TStringList ); // Find Path
  public        // 添加
    function ShowAddItem( SourceItemList, DesItemList : TStringList ): Boolean;
  public
    function getSourcePathList : TStringList;   // 获取 选择路径
    function getNetworkDesList : TStringList;  // 网络目标
    function getSchedule : TScheduleParams; // 定时发送
  end;

    // 默认配置
  TReadDefaultSettings = class
  public
    procedure Update;
  end;

    // 指定配置
  TReadConfigSetttings = class
  public
    BackupConfigInfo : TBackupConfigInfo;
  public
    constructor Create( _BackupConfigInfo : TBackupConfigInfo );
    procedure Update;
  end;

    // 辅助类
  SelectBackupFormUtil = class
  public
    class function getIsOtherPath( SourcePath : string ): Boolean;
    class function getOtherFirstNode : PVirtualNode;
  public
    class function getScheduleValue1( ScheduleType : Integer ): Integer;
    class function getScheduleValue2( ScheduleType : Integer ): Integer;
  end;

  TSelectBackupDropFileHandle = class
  public
    Msg: TMessage;
  public
    DropFileType: string;
    FilePathList: TStringList;
  public
    constructor Create(_Msg: TMessage);
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindFilePathList;
    procedure FindDropFileType;
  private
    procedure AddBackupSource;
    procedure AddBackupDestination;
  end;
  
const
  DropFileType_BackupSource = 'BackupSource';
  DropFileType_BackupDestination = 'BackupDestination';
  
const
  ShowForm_SelectSource = 'Please select files or folders to send';
  ShowForm_SelectDes = 'Please select destination driectory';
  ShowForm_SelectBackupFolder = 'select a folder to send';

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

const
  VstSelectDes_ComputerName = 0;
  VstSelectDes_AvailableSpace = 1;

var
  frmSelectSendItem: TfrmSelectSendItem;
  SystemPath_NetHood : string;
  SystemPath_DriverCount : Integer;

implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UFormSetting, UFormUtil,
  UMySendApiInfo, UMySendFaceInfo, UMyNetPcInfo, UMySendDataInfo, UMyRegisterApiInfo;

{$R *.DFM}

procedure TfrmSelectSendItem.FormCreate(Sender: TObject);
var
  SFI: TSHFileInfo;
  i, Count, DriverCount: Integer;
  DriveMap, Mask: Cardinal;
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
  DriverPath : string;
begin
  DragAcceptFiles(Handle, True); // 设置需要处理文件 WM_DROPFILES 拖放消息

  vstSelectPath.NodeDataSize := SizeOf(TShellObjectData);
  vstSelectPath.Images := MyIcon.getSysIcon;
  vstSelectPath.PopupMenu := FormUtil.getPopMenu( tbSelectFile );
  vstNetworkDes.NodeDataSize := SizeOf( TNetworkDesData );

    // 初始化 磁盘路径
  SystemPath_DriverCount := 0;
  LastDriverList := MyHardDisk.getPathList;
  for i := 0 to LastDriverList.Count - 1 do
    AddDriver( LastDriverList[i] );

    // 特殊的路径
  OtherPathList := TStringList.Create;

    // 添加特殊路径
  AddOtherPaths;
  
    // 加载配置信息
  ResetSettings;
end;

procedure TfrmSelectSendItem.FormDestroy(Sender: TObject);
begin
  LastDriverList.Free;
  OtherPathList.Free;
end;

procedure TfrmSelectSendItem.FormResize(Sender: TObject);
begin
  plBtnRight.Width := ( plBottom.Width - plBtnCenter.Width ) div 2;
end;

procedure TfrmSelectSendItem.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmSelectSendItem.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectPathList := getSourcePathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

procedure TfrmSelectSendItem.FrameExcludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameFilter.FrameExcludeLvMaskDeletion( Sender, Item );
end;

procedure TfrmSelectSendItem.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectPathList := getSourcePathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

procedure TfrmSelectSendItem.FrameIncludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameFilter.FrameIncludeLvMaskDeletion( Sender, Item );
end;

procedure TfrmSelectSendItem.FrameIncludeLvMaskInsert(Sender: TObject;
  Item: TListItem);
begin
end;


//----------------------------------------------------------------------------------------------------------------------

function TfrmSelectSendItem.AddDefaultDes: Boolean;
var
  DefaultNode, SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  Result := False;

  DefaultNode := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    if NodeData.IsOnline then
    begin
      if Assigned( DefaultNode ) then
      begin
        Result := False;
        Exit;
      end;
      DefaultNode := SelectNode;
      Result := True;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

  if Assigned( DefaultNode ) then
    vstNetworkDes.CheckState[ DefaultNode ] := csCheckedNormal;
end;

procedure TfrmSelectSendItem.AddDesItemList(DesItemList: TStringList);
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    if DesItemList.IndexOf( NodeData.DesItemID ) >= 0 then
      vstNetworkDes.CheckState[ SelectNode ] := csCheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectSendItem.AddDriver(Path: string);
var
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
begin
    // 磁盘不存在
  if not MyHardDisk.getDriverExist( Path ) then
    Exit;

  try
      // Virtual Tree
    RootNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
    RootData := vstSelectPath.GetNodeData( RootNode );
    RootData.FullPath := Path;
    RootData.Display := Path;
    RootData.FileTime := MyFileInfo.getFileLastWriteTime( Path );
    RootData.IsFolder := True;
    Inc( SystemPath_DriverCount );
  except
  end;
end;

function TfrmSelectSendItem.AddFileNode(ParentNode: PVirtualNode;
  FileName: string): PVirtualNode;
var
  SelectNode, UpNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectPath.GetNodeData( SelectNode );
    if ( SelectData.IsFolder ) or ( CompareText( FileName, SelectData.Display ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := vstSelectPath.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := vstSelectPath.InsertNode( ParentNode, amAddChildFirst );
end;

function TfrmSelectSendItem.AddFolderNode(ParentNode: PVirtualNode;
  FolderName: string): PVirtualNode;
var
  SelectNode, DownNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectPath.GetNodeData( SelectNode );
    if ( not SelectData.IsFolder ) or ( CompareText( SelectData.Display, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := vstSelectPath.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := vstSelectPath.AddChild( ParentNode );
end;

procedure TfrmSelectSendItem.AddOtherPath(FolderPath: string);
var
  Node : PVirtualNode;
  NodeData : PShellObjectData;
begin
  OtherPathList.Add( FolderPath );
  
  Node := vstSelectPath.AddChild( vstSelectPath.RootNode );
  NodeData := vstSelectPath.GetNodeData( Node );
  NodeData.FullPath := FolderPath;
  NodeData.Display := ExtractFileName( FolderPath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( FolderPath );
  NodeData.IsFolder := True;
end;

procedure TfrmSelectSendItem.AddOtherPaths;
begin
  AddOtherPath( MySystemPath.getDesktop );
  AddOtherPath( MySystemPath.getMyDoc );
  SystemPath_NetHood := MySystemPath.getNetworkFolder;
//  AddOtherPath( SystemPath_NetHood );
end;

procedure TfrmSelectSendItem.AddSourceItem(SourcePath: string);
var
  IsAdd : Boolean;
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  NodePath : string;
  NewNode : PVirtualNode;
begin
  IsAdd := False;
  if SelectBackupFormUtil.getIsOtherPath( SourcePath ) then
    ChildNode := SelectBackupFormUtil.getOtherFirstNode
  else
    ChildNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    NodeData := vstSelectPath.GetNodeData( ChildNode );
    NodePath := NodeData.FullPath;

      // 找到了节点
    if SourcePath = NodePath then
    begin
      IsAdd := True;
      vstSelectPath.CheckState[ ChildNode ] := csCheckedNormal;
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( SourcePath, NodePath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      vstSelectPath.CheckState[ ChildNode ] := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;

    // 添加 成功
  if IsAdd then
    Exit;

    // 创建节点
  NewNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
  NewNode.CheckState := csCheckedNormal;
  NodeData := vstSelectPath.GetNodeData( NewNode );
  NodeData.FullPath := SourcePath;
  NodeData.Display := ExtractFileName( SourcePath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( SourcePath );
  NodeData.IsFolder := FileExists( SourcePath );  
end;

procedure TfrmSelectSendItem.AddSourceItemList(SourcePathList: TStringList);
var
  i: Integer;
begin
  for i := 0 to SourcePathList.Count - 1 do
    AddSourceItem( SourcePathList[i] );
end;

procedure TfrmSelectSendItem.btnAddClick(Sender: TObject);
var
  DestinationPath : string;
begin
  // 选择目录
  DestinationPath := MyHardDisk.getBiggestHardDIsk;
  if not MySelectFolderDialog.SelectNormal('Select your destination folder', '', DestinationPath) then
    Exit;
  SendRootItemUserApi.AddLocalItem( DestinationPath );
end;

procedure TfrmSelectSendItem.btnAddFilesClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;

  for i := 0 to FileDialog.Files.Count - 1 do
    AddSourceItem( FileDialog.Files[i] );
end;

procedure TfrmSelectSendItem.btnAddFoldersClick(Sender: TObject);
var
  SelectPath : string;
begin
  SelectPath := '';
  if not MySelectFolderDialog.SelectNormal( ShowForm_SelectBackupFolder, SelectPath, SelectPath ) then
    Exit;
  AddSourceItem( SelectPath );
end;

procedure TfrmSelectSendItem.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectSendItem.btnNextClick(Sender: TObject);
begin
    // 下一页
  PcMain.ActivePageIndex := PcMain.ActivePageIndex + 1;
end;

procedure TfrmSelectSendItem.btnOKClick(Sender: TObject);
begin
    // 没有选择 备份源
  if vstSelectPath.CheckedCount = 0 then
  begin
    MyMessageBox.ShowWarnning( ShowForm_SelectSource );
    PcMain.ActivePage := TsSelectFile;
    Exit;
  end;

    // 没有选择备份目标
  if vstNetworkDes.CheckedCount = 0 then
  begin
    MyMessageBox.ShowWarnning( ShowForm_SelectDes );
    PcMain.ActivePage := tsSelectDes;
    Exit;
  end;

  Close;
  ModalResult := mrOk;
end;


procedure TfrmSelectSendItem.cbbScheduleSelect(Sender: TObject);
begin
  ResetSchedule;
end;

procedure TfrmSelectSendItem.CheckBtnOkEnable;
begin
end;

procedure TfrmSelectSendItem.Clear1Click(Sender: TObject);
begin
  SendFileHistoryApi.ClearItem;
end;

procedure TfrmSelectSendItem.Clear2Click(Sender: TObject);
begin
  SendDesHistoryApi.ClearItem;
end;

procedure TfrmSelectSendItem.DropFiles(var Msg: TMessage);
var
  SelectBackupDropFileHandle : TSelectBackupDropFileHandle;
begin
  SelectBackupDropFileHandle := TSelectBackupDropFileHandle.Create( Msg );
  SelectBackupDropFileHandle.Update;
  SelectBackupDropFileHandle.Free;

  FormUtil.ForceForegroundWindow( Handle );
end;

function TfrmSelectSendItem.ReadScheduleValue1: Integer;
begin
  Result := SelectBackupFormUtil.getScheduleValue1( cbbSchedule.ItemIndex );
end;

function TfrmSelectSendItem.ReadScheduleValue2: Integer;
begin
  Result := SelectBackupFormUtil.getScheduleValue2( cbbSchedule.ItemIndex );
end;

procedure TfrmSelectSendItem.RemoveDriver(Path: string);
var
  SelectNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  try
      // Virtual Tree
    SelectNode := vstSelectPath.RootNode.FirstChild;
    while Assigned( SelectNode ) do
    begin
      NodeData := vstSelectPath.GetNodeData( SelectNode );
      if NodeData.FullPath = Path then
      begin
        vstSelectPath.DeleteNode( SelectNode );
        Break;
      end;
      SelectNode := SelectNode.NextSibling;
    end;
  except
  end;
end;

procedure TfrmSelectSendItem.ResetSchedule;
begin
  pcAutoBackup.ActivePageIndex := cbbSchedule.ItemIndex;
end;

procedure TfrmSelectSendItem.ResetSettings;
begin
  FrameFilter.IniFrame;
end;

procedure TfrmSelectSendItem.SendDesHistoryClick(Sender: TObject);
var
  mi : TMenuItem;
  i, HistoryIndex: Integer;
  SelectPathList : TStringList;
begin
  HistoryIndex := -1;

  mi := Sender as TMenuItem;
  for i := 0 to pmDesHistory.Items.Count - 1 do
    if pmDesHistory.Items[i] = mi then
    begin
      HistoryIndex := i;
      Break;
    end;

  if HistoryIndex < 0 then
    Exit;

    // 读取历史路径
  SelectPathList := SendDesHistoryInfoReadUtil.ReadPathList( HistoryIndex );
  AddDesItemList( SelectPathList );
  SelectPathList.Free;
end;


procedure TfrmSelectSendItem.SendFileHistoryClick(Sender: TObject);
var
  mi : TMenuItem;
  i, HistoryIndex: Integer;
  SelectPathList : TStringList;
begin
  HistoryIndex := -1;

  mi := Sender as TMenuItem;
  for i := 0 to pmFileHistory.Items.Count - 1 do
    if pmFileHistory.Items[i] = mi then
    begin
      HistoryIndex := i;
      Break;
    end;

  if HistoryIndex < 0 then
    Exit;

    // 读取历史路径
  SelectPathList := SendFileHistoryInfoReadUtil.ReadPathList( HistoryIndex );
  AddSourceItemList( SelectPathList );
  SelectPathList.Free;
end;

procedure TfrmSelectSendItem.seSyncTimeClick(Sender: TObject);
begin

end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSendItem.FindSourcePathList(Node: PVirtualNode;
  SourcePathList : TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ( ChildNode.CheckState = csCheckedNormal ) then  // 找到选择的路径
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      SourcePathList.Add( NodeData.FullPath );
    end
    else
    if ChildNode.CheckState = csMixedNormal then  // 找下一层
      FindSourcePathList( ChildNode, SourcePathList );
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectSendItem.getNetworkDesList: TStringList;
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  Result := TStringList.Create;
  SelectNode := vstNetworkDes.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    Result.Add( NodeData.DesItemID );
    SelectNode := vstNetworkDes.GetNextChecked( SelectNode );
  end;
end;


function TfrmSelectSendItem.getSchedule: TScheduleParams;
begin
  Result.ScheduleType := cbbSchedule.ItemIndex;
  Result.ScheduleValue1 := ReadScheduleValue1;
  Result.ScheduleValue2 := ReadScheduleValue2;
end;

function TfrmSelectSendItem.getSourcePathList: TStringList;
begin
  Result := TStringList.Create;
  FindSourcePathList( vstSelectPath.RootNode, Result );
end;

procedure TfrmSelectSendItem.Panel9Click(Sender: TObject);
begin
  MyExplore.OpenFolder( MySystemPath.getMyDoc );
end;

procedure TfrmSelectSendItem.PcMainPageChange(Sender: TObject);
begin
  btnNext.Enabled := PcMain.ActivePage <> TsInclude;
end;

procedure TfrmSelectSendItem.SetUnCheckDes;
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstNetworkDes.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectSendItem.SetUnCheckedSource(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if vstSelectPath.CheckState[ ChildNode ] <> csUncheckedNormal then
    begin
      vstSelectPath.CheckState[ ChildNode ] := csUncheckedNormal;
      SetUnCheckedSource( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectSendItem.ShowAddItem( SourceItemList, DesItemList : TStringList ): Boolean;
var
  ReadDefaultSettings : TReadDefaultSettings;
  IsSelectSource, IsSelectDes : Boolean;
begin
    // 读取默认配置
  ReadDefaultSettings := TReadDefaultSettings.Create;
  ReadDefaultSettings.Update;
  ReadDefaultSettings.Free;

    // 添加
  AddSourceItemList( SourceItemList );
  AddDesItemList( DesItemList );

    // 是否已选择
  IsSelectSource := SourceItemList.Count > 0;
  IsSelectDes := DesItemList.Count > 0;
  if not IsSelectDes then // 没有选择则尝试选择默认
    IsSelectDes := AddDefaultDes;

    // 已选择的源路径
  if IsSelectSource then
    PcMain.ActivePage := tsSelectDes
  else   // 没有选择路径
    PcMain.ActivePage := TsSelectFile;

    // Btn
  CheckBtnOkEnable;


    // 清空源路径按钮
  tbtnUnSelect.Enabled := IsSelectSource;

    // 返回是否OK
  Result := ShowModal = mrOk;
end;

procedure TfrmSelectSendItem.tbtnManuallyClick(Sender: TObject);
var
  InputPath : string;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and ( not FileExists( InputPath ) and not DirectoryExists( InputPath ) ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'File or Folder Name', InputPath ) then
    Exit;

  if not FileExists( InputPath ) and not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist.' );
    Exit;
  end;

  AddSourceItem( InputPath );
end;

procedure TfrmSelectSendItem.tbtnPcHistoryClick(Sender: TObject);
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnPcHistory.Down := True;
  tbtnPcHistory.CheckMenuDropdown;
end;

procedure TfrmSelectSendItem.tbtnRefreshClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  IsExpanded : Boolean;
begin
  SelectNode := vstSelectPath.FocusedNode;
  if not Assigned( SelectNode ) then
    Exit;
  IsExpanded := vstSelectPath.Expanded[ SelectNode ];
  vstSelectPath.DeleteChildren( SelectNode );
  vstSelectPath.InvalidateChildren( SelectNode, False );
  vstSelectPath.Expanded[ SelectNode ] := IsExpanded;
end;

procedure TfrmSelectSendItem.tbtnSelectAllClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstNetworkDes.CheckState[ SelectNode ] := csCheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectSendItem.tbtnSelectFileClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;

  for i := 0 to FileDialog.Files.Count - 1 do
    AddSourceItem( FileDialog.Files[i] );
end;


var
  DirPath_FileSend : string = '';
procedure TfrmSelectSendItem.tbtnSelectFolderClick(Sender: TObject);
begin
  if not MySelectFolderDialog.SelectNormal( ShowForm_SelectBackupFolder, '', DirPath_FileSend ) then
    Exit;
  AddSourceItem( DirPath_FileSend );
end;

procedure TfrmSelectSendItem.tbtnSelectHistoryClick(Sender: TObject);
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnSelectHistory.Down := True;
  tbtnSelectHistory.CheckMenuDropdown;
end;

procedure TfrmSelectSendItem.tbtnSelectOnlineClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    if NodeData.IsOnline then
      vstNetworkDes.CheckState[ SelectNode ] := csCheckedNormal
    else
      vstNetworkDes.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectSendItem.tbtnUnSelectClick(Sender: TObject);
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SetUnCheckedSource( vstSelectPath.RootNode );
  tbtnUnSelect.Enabled := False;
end;

procedure TfrmSelectSendItem.tbtnUnSelectPcClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstNetworkDes.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSendItem.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);

// Click handler to switch the column on which will be sorted. Since we cannot sort image data sorting is actually
// limited to the main column.

begin
  if Button = mbLeft then
  begin
    with Sender do
    begin
      if Column <> MainColumn then
        SortColumn := NoColumn
      else
      begin
        if SortColumn = NoColumn then
        begin
          SortColumn := Column;
          SortDirection := sdAscending;
        end
        else
          if SortDirection = sdAscending then
            SortDirection := sdDescending
          else
            SortDirection := sdAscending;
        Treeview.SortTree(SortColumn, SortDirection, False);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSendItem.vstNetworkDesChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  CheckBtnOkEnable;
  tbtnUnSelectPc.Enabled := Sender.CheckedCount > 0;
end;

procedure TfrmSelectSendItem.vstNetworkDesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if Assigned( Node ) then
    Sender.CheckState[ Node ] := csCheckedNormal;
end;

procedure TfrmSelectSendItem.vstNetworkDesGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PNetworkDesData;
begin
  ImageIndex := -1;
  if ( Column = VstSelectDes_ComputerName ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if NodeData.IsOnline and ( ( Kind = ikNormal ) or ( Kind = ikSelected ) ) then
      ImageIndex := NodeData.MainIcon;
    if not NodeData.IsOnline and ( Kind = ikState ) then
      ImageIndex := NodeData.MainIcon;
  end;
end;

procedure TfrmSelectSendItem.vstNetworkDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PNetworkDesData;
begin
  NodeData := Sender.GetNodeData( Node );
  CellText := '';
  if TextType = ttStatic then
  begin
    if Column = VstSelectDes_ComputerName then
      CellText := NodeData.DesName;
    Exit;
  end;

  if Column = VstSelectDes_ComputerName then
    CellText := NodeData.MainName
  else
  if Column = VstSelectDes_AvailableSpace then
  begin
    if NodeData.IsOnline then
      CellText := MySize.getFileSizeStr( NodeData.AvailaleSpace )
    else
      CellText := 'Offline';
  end;
end;

procedure TfrmSelectSendItem.vstNetworkDesPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : PNetworkDesData;
begin
  TargetCanvas.Font.Color := clBtnShadow;
  NodeData := Sender.GetNodeData( Node );

  if NodeData.IsOnline then
  begin
    TargetCanvas.Font.Color := clWindowText;
    if ( Column = VstSelectDes_ComputerName ) and ( TextType <> ttStatic ) then
    begin
      TargetCanvas.Font.Size := 10;
      TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
    end;
  end;
end;

procedure TfrmSelectSendItem.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  CheckBtnOkEnable;
  tbtnUnSelect.Enabled := Sender.CheckedCount > 0;
end;

procedure TfrmSelectSendItem.vstSelectPathFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  IsShowRefresh : Boolean;
  NodeData : PShellObjectData;
begin
  IsShowRefresh := False;
  if Assigned( Node ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    Sender.CheckState[ Node ] := csCheckedNormal;
    IsShowRefresh := NodeData.IsFolder
  end;
  tbtnRefresh.Enabled := IsShowRefresh;
end;

procedure TfrmSelectSendItem.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectSendItem.vstSelectPathGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PShellObjectData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    Data := Sender.GetNodeData(Node);
    ImageIndex := data.DisplayIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectSendItem.vstSelectPathGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData( Node );

  if Column = VstSelectBackupPath_FileName then
    CellText := Data.Display
  else
  if Column = VstSelectBackupPath_FileSize then
  begin
    if Data.IsFolder then
      CellText := ''
    else
     CellText := MySize.getFileSizeStr( Data.FileSize )
  end
  else
  if Column = VstSelectBackupPath_FileTime then
    CellText := DateTimeToStr( Data.FileTime )
  else
    CellText := '';
end;

procedure TfrmSelectSendItem.vstSelectPathInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  IsNetHood : Boolean;
  Data, ChildData: PShellObjectData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // 搜索目录的信息，找不到则跳过
  Data := Sender.GetNodeData(Node);
  IsNetHood := Data.FullPath = SystemPath_NetHood;
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // 子路径
      FilePath := FullPath + FileName;

        // 特殊的路径
      if OtherPathList.IndexOf( FilePath ) >= 0 then
        Continue;

        // 子节点数据
      if DirectoryExists( FilePath ) then
        ChildNode := AddFolderNode( Node, FileName )
      else
        ChildNode := AddFileNode( Node, FileName );
      ChildData := Sender.GetNodeData(ChildNode);
      if IsNetHood then
        ChildData.FullPath := MyFilePath.getLinkPath( FilePath )
      else
        ChildData.FullPath := FilePath;
      ChildData.Display := MyFileInfo.getFileName( FilePath );
      if DirectoryExists( FilePath ) then
        ChildData.IsFolder := True
      else
      begin
        ChildData.IsFolder := False;
        ChildData.FileSize := sr.Size
      end;
      FileTimeToSystemTime( sr.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      ChildData.FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

        // 初始化
      if Node.CheckState = csCheckedNormal then   // 如果父节点全部Check, 则子节点 check
        ChildNode.CheckState := csCheckedNormal;
      Sender.ValidateNode(ChildNode, False);

        // 子节点数目
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;


procedure TfrmSelectSendItem.vstSelectPathInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Data.DisplayIcon := MyIcon.getIconByFilePath( Data.FullPath );

  if MyFilePath.getHasChild( Data.FullPath ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

procedure TfrmSelectSendItem.WMDeviceChange(var Msg: TMessage);
var
  IsDriverChanged : Boolean;
  DriverList : TStringList;
  i, DriverIndex: Integer;
begin
  IsDriverChanged := ( Msg.WParam = 32768 ) or ( Msg.WParam = 32772 );
  if not IsDriverChanged then  // 驱动器变化
    Exit;

    // 比较前后驱动器
  DriverList := MyHardDisk.getPathList;
  try
    for i := 0 to DriverList.Count - 1 do
    begin
      DriverIndex := LastDriverList.IndexOf( DriverList[i] );
      if DriverIndex < 0 then
        AddDriver( DriverList[i] )
      else
        LastDriverList.Delete( DriverIndex );
    end;
    for i := LastDriverList.Count - 1 downto 0 do
      RemoveDriver( LastDriverList[i] );
  except
  end;
    // 刷新信息
  LastDriverList.Free;
  LastDriverList := DriverList;
end;

//----------------------------------------------------------------------------------------------------------------------


{ TReadDefaultSettings }

procedure TReadDefaultSettings.Update;
begin
  with frmSelectSendItem do
  begin
      // 取消以前选择的源
    SetUnCheckedSource( vstSelectPath.RootNode );

      // 取消以前选择的目标
    SetUnCheckDes;

    cbbSchedule.ItemIndex := 0;
    pcAutoBackup.ActivePage := tsManual;

      // Filter Settins
    FrameFilter.SetDefaultStatus;
  end;
end;

{ TReadConfigSetttings }

constructor TReadConfigSetttings.Create(_BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TReadConfigSetttings.Update;
begin
  with frmSelectSendItem do
  begin
      // 取消上次选择的源
    SetUnCheckedSource( vstSelectPath.RootNode );

      // 取消上次选择的目标
    SetUnCheckDes;

      // Filter Settings
    FrameFilter.SetClearMask;
    FrameFilter.SetIncludeFilterList( BackupConfigInfo.IncludeFilterList );
    FrameFilter.SetExcludeFilterList( BackupConfigInfo.ExcludeFilterList );
  end;
end;

{ FormUtil }

class function SelectBackupFormUtil.getIsOtherPath(SourcePath: string): Boolean;
var
  OtherPathList : TStringList;
  i : Integer;
begin
  Result := False;

  OtherPathList := frmSelectSendItem.OtherPathList;
  for i := 0 to OtherPathList.Count - 1 do
    if MyMatchMask.CheckEqualsOrChild( SourcePath, OtherPathList[i] ) then
    begin
      Result := True;
      Break;
    end;
end;

class function SelectBackupFormUtil.getOtherFirstNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  i: Integer;
begin
  with frmSelectSendItem do
  begin
    Result := vstSelectPath.RootNode.FirstChild;
    for i := 0 to SystemPath_DriverCount - 1 do
    begin
      if not Assigned( Result ) then
        Break;
      Result := Result.NextSibling;
    end;
  end;
end;

class function SelectBackupFormUtil.getScheduleValue1(
  ScheduleType: Integer): Integer;
begin
  with frmSelectSendItem do
  begin
    if ScheduleType = ScheduleType_Min then
      Result := cbbMin.ItemIndex
    else
    if ScheduleType = ScheduleType_Hour then
      Result := cbbHour.ItemIndex
    else
    if ScheduleType = ScheduleType_Day then
      Result := cbbDay.ItemIndex
    else
    if ScheduleType = ScheduleType_Week then
      Result := cbbWeek1.ItemIndex
    else
    if ScheduleType = ScheduleType_Month then
      Result := cbbMonth1.ItemIndex
    else
      Result := 0;
  end;
end;

class function SelectBackupFormUtil.getScheduleValue2(
  ScheduleType: Integer): Integer;
begin
  with frmSelectSendItem do
  begin
    if ScheduleType = ScheduleType_Week then
      Result := cbbWeek2.ItemIndex
    else
    if ScheduleType = ScheduleType_Month then
      Result := cbbMonth2.ItemIndex
    else
      Result := 0;
  end;
end;

{ TSelectBackupDropFileHandle }

procedure TSelectBackupDropFileHandle.AddBackupDestination;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    if not FileExists( FilePathList[i] ) then
      SendRootItemUserApi.AddLocalItem( FilePathList[i] );
end;

procedure TSelectBackupDropFileHandle.AddBackupSource;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    frmSelectSendItem.AddSourceItem( FilePathList[i] );
end;

constructor TSelectBackupDropFileHandle.Create(_Msg: TMessage);
begin
  Msg := _Msg;
  FilePathList := TStringList.Create;
end;

destructor TSelectBackupDropFileHandle.Destroy;
begin
  FilePathList.Free;
  inherited;
end;

procedure TSelectBackupDropFileHandle.FindDropFileType;
begin
  with frmSelectSendItem do
  begin
    if PcMain.ActivePage = TsSelectFile then
      DropFileType := DropFileType_BackupSource
    else
    if PcMain.ActivePage = tsSelectDes then
      DropFileType := DropFileType_BackupDestination
    else
      DropFileType := '';
  end;
end;

procedure TSelectBackupDropFileHandle.FindFilePathList;
var
  FilesCount: Integer; // 文件总数
  i: Integer;
  FileName: array [0 .. 255] of Char;
  FilePath: string;
begin
  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);

  try
    // 获取文件名
    for i := 0 to FilesCount - 1 do
    begin
      DragQueryFile(Msg.WParam, i, FileName, 256);
      FilePath := FileName;
      FilePath := MyFilePath.getLinkPath( FilePath );
      FilePathList.Add(FilePath);
    end;
  except
  end;

  // 释放
  DragFinish(Msg.WParam);
end;

procedure TSelectBackupDropFileHandle.Update;
begin
  try
        // 检查是否专业版， BuyNow 则取消操作
    if not RegisterLimitApi.ProfessionalAction then
      Exit;

    FindFilePathList;
    FindDropFileType;

    if DropFileType = DropFileType_BackupSource then
      AddBackupSource
    else
    if DropFileType = DropFileType_BackupDestination then
      AddBackupDestination;
  except
  end;
end;

end.
