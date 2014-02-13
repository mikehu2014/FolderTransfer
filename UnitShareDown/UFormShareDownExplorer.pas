unit UFormShareDownExplorer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VirtualTrees, Vcl.StdCtrls, Generics.Collections,
  Vcl.ComCtrls, Vcl.ToolWin, UMainForm, Vcl.ImgList, inifiles, RzTabs, StrUtils;

type

  TShowExplorerFileInfo = class
  public
    FilePath : string;
    IsFile : Boolean;
  public
    constructor Create( _FilePath : string; _IsFile : Boolean );
  end;
  TShowExplorerFileList = class( TObjectList< TShowExplorerFileInfo > )end;

  TfrmRestoreExplorer = class(TForm)
    vstExplorer: TVirtualStringTree;
    plButton: TPanel;
    plPathSelect: TPanel;
    Label1: TLabel;
    btnBrowse: TButton;
    plStatus: TPanel;
    cbbSavePath: TComboBox;
    tmrShowExplorering: TTimer;
    Image1: TImage;
    tbShareExplorer: TToolBar;
    tbtnPreview: TToolButton;
    ilTb: TImageList;
    ilTbGray: TImageList;
    tbtnSplit: TToolButton;
    chkExplorer: TCheckBox;
    PcMain: TRzPageControl;
    tsExplorer: TRzTabSheet;
    tsSearch: TRzTabSheet;
    plExplorer: TPanel;
    lbStatus: TLabel;
    ilPcMain: TImageList;
    plSearch: TPanel;
    btnSearch: TButton;
    btnStopSearch: TButton;
    plSearchStatus: TPanel;
    Image3: TImage;
    lbSearchStatus: TLabel;
    vstSearchFile: TVirtualStringTree;
    pbSearch: TProgressBar;
    tmrShowSearching: TTimer;
    pbExplorer: TProgressBar;
    plSearchFile: TPanel;
    ToolBar1: TToolBar;
    tbtnSearchPreview: TToolButton;
    tbtnSearchSplit: TToolButton;
    tmrStop: TTimer;
    cbbSearchName: TComboBox;
    plBtnRight: TPanel;
    plBtnCenter: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    tbtnSearch: TToolButton;
    tbtnSearchSearch: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure vstExplorerGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstExplorerGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstExplorerInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstExplorerInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure btnCancelClick(Sender: TObject);
    procedure vstExplorerChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnOKClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure cbbSavePathSelect(Sender: TObject);
    procedure tmrShowExploreringTimer(Sender: TObject);
    procedure vstExplorerFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnPreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vstExplorerDblClick(Sender: TObject);
    procedure vstExplorerChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnLeftClick(Sender: TObject);
    procedure tbtnRightClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstSearchFileGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstSearchFileGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure btnSearchClick(Sender: TObject);
    procedure tmrShowSearchingTimer(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnStopSearchClick(Sender: TObject);
    procedure vstSearchFileInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure FormShow(Sender: TObject);
    procedure tbtnSearchPreviewClick(Sender: TObject);
    procedure vstSearchFileFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure vstSearchFileChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSearchFileChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnSearchLeftClick(Sender: TObject);
    procedure tbtnSearchRightClick(Sender: TObject);
    procedure tmrStopTimer(Sender: TObject);
    procedure vstSearchFileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vstExplorerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure tbtnSearchClick(Sender: TObject);
    procedure tbtnSearchSearchClick(Sender: TObject);
  private
    procedure SaveIni;
    procedure LoadIni;
    procedure AddSearchHistory( FileName : string );
  public
    IsLocal : Boolean;
    SharePath, OwnerID : string;
  private
    procedure FindSelect( Node : PVirtualNode; PathList : TShowExplorerFileList );
    procedure FindSelectSearch( Node : PVirtualNode; PathList : TShowExplorerFileList );
  public
    function ShowExplorer( RootPath, _OwnerID : string; IsFile, _IsLocal : Boolean ): Boolean;
    procedure SetPreviewBtn( IsEnable : Boolean );
    procedure ExplorerFolder( FolderPath : string; IsFile, IsSearch : Boolean );
  public
    function getSelectList : TShowExplorerFileList;
    function getSavePath : string;
    function getDownCompletedType : string;
  private
    procedure ShowPreview;
    procedure RefreshSelectBtn;
    procedure RefreshSearchSelectBtn;
    procedure RefreshOKBtn;
    procedure SaveFormIni;
    procedure LoadFormIni;
  end;

    // 辅助类
  ShareExplorerFormUtil = class
  public
    class function getIsExistPreviewPicture( FilePath : string ): Boolean;
  public
    class function getSelectNode( FilePath : string ): PVirtualNode;
    class function getSelectSearchNode( FilePath : string ): PVirtualNode;
  end;


const
  VstExplorer_FileName = 0;
  VstExplorer_FileSize = 1;
  VstExplorer_FileTime = 2;

const
  ShowHint_RestoreTo = 'Please select files or folders you wish to save';

var
  frmRestoreExplorer: TfrmRestoreExplorer;


implementation

uses UMyShareDownFaceInfo, UIconUtil, UMyUtil, UMyShareDownApiInfo, UFormPreview, UShareDownThread,
     UMyRegisterApiInfo;

{$R *.dfm}


procedure TfrmRestoreExplorer.AddSearchHistory(FileName: string);
var
  i: Integer;
begin
    // 已存在
  if cbbSearchName.Items.IndexOf( FileName ) >= 0 then
    Exit;

    // 超过限制，删除组后一个
  if cbbSearchName.Items.Count >= 10 then
    cbbSearchName.Items.Delete( 9 );

    // 添加
  cbbSearchName.Items.Insert( 0, FileName );
end;

procedure TfrmRestoreExplorer.btnBrowseClick(Sender: TObject);
var
  SelectFolder : string;
begin
    // 选择下载路径
  SelectFolder := cbbSavePath.Text;
  if not MySelectFolderDialog.SelectNormal( ShowHint_RestoreTo, '', SelectFolder ) then
    Exit;
  ShareSavePathHistory.AddItem( SelectFolder );
end;

procedure TfrmRestoreExplorer.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRestoreExplorer.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
  if cbbSavePath.Items.IndexOf( cbbSavePath.Text ) < 0 then
    ShareSavePathHistory.AddItem( cbbSavePath.Text );
end;

procedure TfrmRestoreExplorer.btnSearchClick(Sender: TObject);
var
  SearchName : string;
begin
    // 清空旧结果
  vstSearchFile.Clear;

  SearchName := cbbSearchName.Text;
  if LeftStr( SearchName, 1 ) <> '*' then
    SearchName := '*' + SearchName;
  if RightStr( SearchName, 1 ) <> '*' then
    SearchName := SearchName + '*';

    // 开始搜索
  ShareSearchUserApi.AddNetworkItem( SharePath, OwnerID, SearchName );

    // 添加到历史中
  AddSearchHistory( cbbSearchName.Text );

    // 检查是否企业版
  RegisterLimitApi.EnterpriseAction;
end;

procedure TfrmRestoreExplorer.btnStopSearchClick(Sender: TObject);
begin
  btnStopSearch.Enabled := False;
  MyShareSearchHandler.IsSearchRun := False;
  RestoreSearch_IsShow := False;
end;

procedure TfrmRestoreExplorer.cbbSavePathSelect(Sender: TObject);
begin
  if cbbSavePath.Text <> '' then
    ShareSavePathHistory.AddItem( cbbSavePath.Text );
end;

procedure TfrmRestoreExplorer.cbbSearchNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ( Key = VK_RETURN ) and btnSearch.Enabled then
    btnSearch.Click;
end;

procedure TfrmRestoreExplorer.edtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( Key = VK_RETURN ) and btnSearch.Enabled then
    btnSearch.Click;
end;

procedure TfrmRestoreExplorer.ExplorerFolder(FolderPath: string;
  IsFile, IsSearch: Boolean);
begin
  if IsLocal then
    ShareExplorerUserApi.ReadLocal( FolderPath, OwnerID, IsFile, IsSearch )
  else
    ShareExplorerUserApi.ReadNetwork( FolderPath, OwnerID, IsFile, IsSearch );
end;

procedure TfrmRestoreExplorer.FindSelect(Node: PVirtualNode;
  PathList: TShowExplorerFileList);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareExplorerData;
  SelectInfo : TShowExplorerFileInfo;
begin
  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstExplorer.CheckState[ SelectNode ] = csCheckedNormal then
    begin
      NodeData := VstExplorer.GetNodeData( SelectNode );
      SelectInfo := TShowExplorerFileInfo.Create( NodeData.FilePath, NodeData.IsFile );
      PathList.Add( SelectInfo );
    end
    else
    if VstExplorer.CheckState[ SelectNode ] = csMixedNormal then
      FindSelect( SelectNode, PathList );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRestoreExplorer.FindSelectSearch(Node: PVirtualNode;
  PathList: TShowExplorerFileList);
var
  SelectNode : PVirtualNode;
  NodeData : PShareSearchData;
  SelectInfo : TShowExplorerFileInfo;
begin
  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstSearchFile.CheckState[ SelectNode ] = csCheckedNormal then
    begin
      NodeData := vstSearchFile.GetNodeData( SelectNode );
      SelectInfo := TShowExplorerFileInfo.Create( NodeData.FilePath, NodeData.IsFile );
      PathList.Add( SelectInfo );
    end
    else
    if vstSearchFile.CheckState[ SelectNode ] = csMixedNormal then
      FindSelectSearch( SelectNode, PathList );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRestoreExplorer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if PreviewForm_IsShow then
    frmPreView.Close;
  tmrStop.Enabled := True;
end;

procedure TfrmRestoreExplorer.FormCreate(Sender: TObject);
begin
  vstExplorer.NodeDataSize := SizeOf( TShareExplorerData );
  vstExplorer.Images := MyIcon.getSysIcon;
  vstSearchFile.NodeDataSize := SizeOf( TShareSearchData );
  vstSearchFile.Images := MyIcon.getSysIcon;
  LoadFormIni;
  LoadIni;
end;

procedure TfrmRestoreExplorer.FormDestroy(Sender: TObject);
begin
  SaveFormIni;
  SaveIni;
end;

procedure TfrmRestoreExplorer.FormResize(Sender: TObject);
begin
  plBtnRight.Width := ( plButton.Width - plBtnCenter.Width ) div 2;
end;

procedure TfrmRestoreExplorer.FormShow(Sender: TObject);
begin
  PcMain.ActivePage := tsExplorer;
end;

function TfrmRestoreExplorer.getDownCompletedType: string;
begin
  if chkExplorer.Checked then
    Result := DownCompletedType_Explorer
  else
    Result := '';
end;

function TfrmRestoreExplorer.getSavePath: string;
begin
  Result := cbbSavePath.Text;
end;

function TfrmRestoreExplorer.getSelectList: TShowExplorerFileList;
begin
  Result := TShowExplorerFileList.Create;
  FindSelect( vstExplorer.RootNode, Result );
  FindSelectSearch( vstSearchFile.RootNode, Result );
end;

procedure TfrmRestoreExplorer.LoadFormIni;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  chkExplorer.Checked := iniFile.ReadBool( Self.Name, chkExplorer.Name, False );
  iniFile.Free;
end;

procedure TfrmRestoreExplorer.LoadIni;
var
  IniFile : TIniFile;
  i, ItemCount: Integer;
  s : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ItemCount := IniFile.ReadInteger( Self.Name, cbbSearchName.Name + 'Count', 0 );
  for i := 0 to ItemCount - 1 do
  begin
    s := IniFile.ReadString( Self.Name, cbbSearchName.Name + IntToStr(i), '' );
    cbbSearchName.Items.Add( s );
  end;
  IniFile.Free;
end;

procedure TfrmRestoreExplorer.RefreshOKBtn;
begin
  btnOK.Enabled := ( vstExplorer.CheckedCount > 0 ) or ( vstSearchFile.CheckedCount > 0 );
end;

procedure TfrmRestoreExplorer.RefreshSearchSelectBtn;

begin

end;

procedure TfrmRestoreExplorer.RefreshSelectBtn;

begin

end;

procedure TfrmRestoreExplorer.SaveFormIni;
var
  iniFile: TIniFile;
begin
    // 无法写入 Ini
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  try
    iniFile.WriteBool(Self.Name, chkExplorer.Name, chkExplorer.Checked);
  except
    end;
  iniFile.Free;
end;

procedure TfrmRestoreExplorer.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, cbbSearchName.Name + 'Count', cbbSearchName.Items.Count );
    for i := 0 to cbbSearchName.Items.Count - 1 do
      IniFile.WriteString( Self.Name, cbbSearchName.Name + IntToStr(i), cbbSearchName.Items[i] );
  except
  end;
  IniFile.Free;
end;


procedure TfrmRestoreExplorer.SetPreviewBtn(IsEnable: Boolean);
begin
  tbtnPreview.Down := IsEnable;
  tbtnSplit.Visible := IsEnable;

  tbtnSearchPreview.Down := IsEnable;
  tbtnSearchSplit.Visible := IsEnable;
end;

function TfrmRestoreExplorer.ShowExplorer(RootPath, _OwnerID: string;
  IsFile, _IsLocal : Boolean): Boolean;
var
  ExplorerNode : PVirtualNode;
  NodeData : PVstShareExplorerData;
begin
  SharePath := RootPath;
  OwnerID := _OwnerID;
  IsLocal := _IsLocal;

  btnOK.Enabled := False;
  tbtnPreview.Visible := False;
  tbtnSplit.Visible := False;
  tbtnSearchPreview.Visible := False;
  tbtnSearchSplit.Visible := False;

    // 清空搜索结果
  vstSearchFile.Clear;

    // 添加根目录
  vstExplorer.Clear;
  ExplorerNode := vstExplorer.AddChild( vstExplorer.RootNode );
  NodeData := vstExplorer.GetNodeData( ExplorerNode );
  NodeData.FilePath := RootPath;
  NodeData.IsFile := IsFile;
  NodeData.ShowName := RootPath;
  if IsFile then
  begin
    NodeData.FileSize := -1;
    NodeData.ShowIcon := MyIcon.getIconByFileExt( RootPath );
  end
  else
    NodeData.ShowIcon := MyShellIconUtil.getFolderIcon;

    // 搜索文件
  ExplorerFolder( RootPath, IsFile, False );

  Result := ShowModal = mrOk;
end;

procedure TfrmRestoreExplorer.ShowPreview;
var
  DelWidth : Integer;
begin
    // 设置本窗口位置
  try
    DelWidth := Screen.WorkAreaWidth - ( Self.Width * 2 );
    if DelWidth < 10 then
    begin
      Self.Width := ( Screen.WorkAreaWidth div 2 ) - 20;
      DelWidth := 10;
    end
    else
      DelWidth := DelWidth div 2;
    Self.Left := Self.Width + DelWidth;
  except
  end;

    // 设置预览窗口
  frmPreView.Width := Self.Width;
  frmPreView.Height := Self.Height;
  frmPreView.SetIniPosition( Self.Handle );
  frmPreView.plPreviewTitle.Visible := True;
  frmPreView.Show;
end;

procedure TfrmRestoreExplorer.tbtnLeftClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstExplorer.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.PrevSibling;
  if Assigned( SelectNode ) then
  begin
    vstExplorer.Selected[ SelectNode ] := True;
    vstExplorer.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnPreviewClick(Sender: TObject);
var
  NodeData : PVstShareExplorerData;
begin
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

  if not Assigned( vstExplorer.FocusedNode ) then
    Exit;

  NodeData := vstExplorer.GetNodeData( vstExplorer.FocusedNode );
  frmPreView.PreviewFile( NodeData.FilePath, OwnerID );
  ShowPreview;
end;

procedure TfrmRestoreExplorer.tbtnRightClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstExplorer.FocusedNode;
  if Assigned( vstExplorer.FocusedNode ) then
    SelectNode := SelectNode.NextSibling;
  if Assigned( SelectNode ) then
  begin
    vstExplorer.Selected[ SelectNode ] := True;
    vstExplorer.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchClick(Sender: TObject);
begin
  tbtnSearchSearch.Down := True;
  PcMain.ActivePage := tsSearch;
end;

procedure TfrmRestoreExplorer.tbtnSearchLeftClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstSearchFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.PrevSibling;
  if Assigned( SelectNode ) then
  begin
    vstSearchFile.Selected[ SelectNode ] := True;
    vstSearchFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchPreviewClick(Sender: TObject);
var
  NodeData : PShareSearchData;
begin
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

  if not Assigned( vstSearchFile.FocusedNode ) then
    Exit;

  NodeData := vstSearchFile.GetNodeData( vstSearchFile.FocusedNode );
  frmPreView.PreviewFile( NodeData.FilePath, OwnerID );
  ShowPreview;
end;

procedure TfrmRestoreExplorer.tbtnSearchRightClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstSearchFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.NextSibling;
  if Assigned( SelectNode ) then
  begin
    vstSearchFile.Selected[ SelectNode ] := True;
    vstSearchFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchSearchClick(Sender: TObject);
begin
  PcMain.ActivePage := tsExplorer;
end;

procedure TfrmRestoreExplorer.tmrShowExploreringTimer(Sender: TObject);
begin
  tmrShowExplorering.Enabled := False;
  pbExplorer.Style := pbstMarquee;
  pbExplorer.Visible := True;
end;

procedure TfrmRestoreExplorer.tmrShowSearchingTimer(Sender: TObject);
begin
  tmrShowSearching.Enabled := False;
  pbSearch.Style := pbstMarquee;
  pbSearch.Visible := True;
end;

procedure TfrmRestoreExplorer.tmrStopTimer(Sender: TObject);
begin
  tmrStop.Enabled := False;
  if btnStopSearch.Visible and btnStopSearch.Enabled then
    btnStopSearch.Click;
end;

procedure TfrmRestoreExplorer.vstExplorerChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  RefreshSelectBtn;
end;

procedure TfrmRestoreExplorer.vstExplorerChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  RefreshOKBtn;
  RefreshSelectBtn;
end;

procedure TfrmRestoreExplorer.vstExplorerDblClick(Sender: TObject);
begin
  if tbtnPreview.Enabled and not PreviewForm_IsShow then
    tbtnPreview.Click;
end;

procedure TfrmRestoreExplorer.vstExplorerFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PVstShareExplorerData;
begin
  if not Assigned( Node ) then
    Exit;

  NodeData := Sender.GetNodeData( Node );
  tbtnPreview.Enabled := PreviewForm_IsShow or NodeData.IsFile;
  tbtnPreview.Visible := tbtnPreview.Enabled;
  tbtnSplit.Visible := tbtnPreview.Enabled;

  if PreviewForm_IsShow and NodeData.IsFile then
    frmPreView.PreviewFile( NodeData.FilePath, OwnerID );

  if not PreviewForm_IsShow then
    vstExplorer.CheckState[ Node ] := csCheckedNormal;

  RefreshSelectBtn;
end;

procedure TfrmRestoreExplorer.vstExplorerGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstShareExplorerData;
begin
  if ( Column = VstExplorer_FileName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.ShowIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestoreExplorer.vstExplorerGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstShareExplorerData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstExplorer_FileName then
    CellText := NodeData.ShowName
  else
  if not NodeData.IsFile then
    CellText := ''
  else
  if NodeData.FileSize = -1 then
    CellText := ''
  else
  if Column = VstExplorer_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstExplorer_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;

procedure TfrmRestoreExplorer.vstExplorerInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  NodeData : PVstShareExplorerData;
begin
  if Node.Parent = Sender.RootNode then
    Exit;
  NodeData := Sender.GetNodeData( Node );

      // 搜索文件
  ExplorerFolder( NodeData.FilePath, False, False );
end;

procedure TfrmRestoreExplorer.vstExplorerInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  Node.CheckType := ctTriStateCheckBox;
  if Assigned( ParentNode ) and ( ParentNode.CheckState = csCheckedNormal ) then
    Node.CheckState := csCheckedNormal
  else
    Node.CheckState := csUnCheckedNormal;
end;

procedure TfrmRestoreExplorer.vstExplorerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareExplorerData;
  HintStr : string;
begin
  SelectNode := vstExplorer.GetNodeAt( X, Y );
  if not Assigned( SelectNode ) then
    Exit;
  NodeData := vstExplorer.GetNodeData( SelectNode );
  HintStr := MyHtmlHintShowStr.getHintRow( 'FilePath', NodeData.FilePath );
  if vstExplorer.Hint <> HintStr then
    vstExplorer.Hint := HintStr;
end;


procedure TfrmRestoreExplorer.vstSearchFileChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  RefreshSearchSelectBtn;
end;

procedure TfrmRestoreExplorer.vstSearchFileChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  RefreshOKBtn;
  RefreshSearchSelectBtn;
end;

procedure TfrmRestoreExplorer.vstSearchFileFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PShareSearchData;
begin
  if not Assigned( Node ) then
    Exit;

  NodeData := Sender.GetNodeData( Node );
  tbtnSearchPreview.Enabled := PreviewForm_IsShow or NodeData.IsFile;
  tbtnSearchPreview.Visible := tbtnSearchPreview.Enabled;
  tbtnSearchSplit.Visible := tbtnSearchPreview.Enabled;

  if PreviewForm_IsShow and NodeData.IsFile then
    frmPreView.PreviewFile( NodeData.FilePath, OwnerID );

  if not PreviewForm_IsShow then
    vstSearchFile.CheckState[ Node ] := csCheckedNormal;

  RefreshSearchSelectBtn;
end;

procedure TfrmRestoreExplorer.vstSearchFileGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PShareSearchData;
begin
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if Column = VstExplorer_FileName then
      ImageIndex := NodeData.ShowIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestoreExplorer.vstSearchFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PShareSearchData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstExplorer_FileName then
    CellText := NodeData.ShowName
  else
  if not NodeData.IsFile then
    CellText := ''
  else
  if Column = VstExplorer_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstExplorer_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;


procedure TfrmRestoreExplorer.vstSearchFileInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  NodeData : PShareSearchData;
begin
  NodeData := Sender.GetNodeData( Node );

      // 搜索文件
  ExplorerFolder( NodeData.FilePath, False, True );
end;

procedure TfrmRestoreExplorer.vstSearchFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PShareSearchData;
  HintStr : string;
begin
  SelectNode := vstSearchFile.GetNodeAt( X, Y );
  if not Assigned( SelectNode ) then
    Exit;
  NodeData := vstSearchFile.GetNodeData( SelectNode );
  HintStr := MyHtmlHintShowStr.getHintRow( 'FilePath', NodeData.FilePath );
  if vstSearchFile.Hint <> HintStr then
    vstSearchFile.Hint := HintStr;
end;

{ TShowExplorerFileInfo }

constructor TShowExplorerFileInfo.Create(_FilePath: string; _IsFile: Boolean);
begin
  FilePath := _FilePath;
  IsFile := _IsFile;
end;

{ ShareExplorerFormUtil }

class function ShareExplorerFormUtil.getIsExistPreviewPicture(
  FilePath: string): Boolean;
var
  i : Integer;
  ImagePageList : TImagePageList;
begin
  Result := False;

  ImagePageList := frmPreView.ImagePageList;
  for i := 0 to ImagePageList.Count - 1 do
    if ImagePageList[i].FilePath = FilePath then
    begin
      Result := True;
      frmPreView.PcImage.ActivePage := ImagePageList[i].Page;
      Break;
    end;
end;

class function ShareExplorerFormUtil.getSelectNode(
  FilePath: string): PVirtualNode;
var
  vstExplorer : TVirtualStringTree;
  NodeData : PVstShareExplorerData;
  SelectNode : PVirtualNode;
begin
  Result := nil;

    // 找到了
  vstExplorer := frmRestoreExplorer.vstExplorer;
  if Assigned( vstExplorer.FocusedNode ) then
  begin
    NodeData := vstExplorer.GetNodeData( vstExplorer.FocusedNode );
    if NodeData.FilePath = FilePath then
    begin
      Result := vstExplorer.FocusedNode;
      Exit;
    end;
  end;

    // 从头开始寻找
  SelectNode := vstExplorer.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstExplorer.GetNodeData( SelectNode );

      // 找到父节点
    if NodeData.FilePath = FilePath then
    begin
      Result := SelectNode;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( FilePath, NodeData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

class function ShareExplorerFormUtil.getSelectSearchNode(
  FilePath: string): PVirtualNode;
var
  vstSearch : TVirtualStringTree;
  NodeData : PShareSearchData;
  SelectNode : PVirtualNode;
begin
  Result := nil;

    // 找到了
  vstSearch := frmRestoreExplorer.vstSearchFile;
  if Assigned( vstSearch.FocusedNode ) then
  begin
    NodeData := vstSearch.GetNodeData( vstSearch.FocusedNode );
    if NodeData.FilePath = FilePath then
    begin
      Result := vstSearch.FocusedNode;
      Exit;
    end;
  end;

    // 从头开始寻找
  SelectNode := vstSearch.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstSearch.GetNodeData( SelectNode );

      // 找到父节点
    if NodeData.FilePath = FilePath then
    begin
      Result := SelectNode;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( FilePath, NodeData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

end.
