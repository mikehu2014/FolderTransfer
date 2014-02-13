unit UFormLocalSelect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  RzTabs, UMyUtil, ShellApi, UMainForm, Vcl.ToolWin;

type
  TFrmLocalSelect = class(TForm)
    PcMain: TRzPageControl;
    tsFileSend: TRzTabSheet;
    tsFileShare: TRzTabSheet;
    Panel1: TPanel;
    LvLocalDes: TListView;
    Panel12: TPanel;
    Panel2: TPanel;
    lvSharePath: TListView;
    FileDialog: TOpenDialog;
    tbMySendDirectory: TToolBar;
    Panel4: TPanel;
    tbtnAddFolder: TToolButton;
    tbtnManuallyInput: TToolButton;
    tbtnRemove: TToolButton;
    edtPaste: TEdit;
    Panel5: TPanel;
    tbSharePath: TToolBar;
    tbtnAddShareFile: TToolButton;
    tbtnAddShareFolder: TToolButton;
    tbtnManualInput: TToolButton;
    tbtnShareRmove: TToolButton;
    Panel3: TPanel;
    procedure btnRemoveLocalDesClick(Sender: TObject);
    procedure LvLocalDesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnAddFileClick(Sender: TObject);
    procedure btnAddShareClick(Sender: TObject);
    procedure lvSharePathChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnDeletedShareClick(Sender: TObject);
    procedure tbtnAddFolderClick(Sender: TObject);
    procedure tbtnRemoveClick(Sender: TObject);
    procedure tbtnManuallyInputClick(Sender: TObject);
    procedure Panel12Click(Sender: TObject);
    procedure tbtnAddShareFileClick(Sender: TObject);
    procedure tbtnAddShareFolderClick(Sender: TObject);
    procedure tbtnManualInputClick(Sender: TObject);
    procedure tbtnShareRmoveClick(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
  private
    LastSelectFolder : string;
  public
    procedure ShowFileSend;
    procedure ShowFileShare;
  end;

  TFrmLocalDropFileHandle = class( TDropFileHandle )
  public
    procedure Update;
  private
    procedure AddReceivePath;
    procedure AddSharePath;
  end;

var
  FrmLocalSelect: TFrmLocalSelect;

implementation

uses UMySendFaceInfo, UMySendApiInfo, UIconUtil, UFormUtil, UMyShareApiInfo, UMyShareFaceInfo;

{$R *.dfm}

procedure TFrmLocalSelect.btnAddClick(Sender: TObject);
var
  SelectPath : string;
begin
  SelectPath := '';
  if not MySelectFolderDialog.Select( 'Select folder for receive', SelectPath, SelectPath ) then
    Exit;
  SendRootItemUserApi.AddLocalItem( SelectPath );
end;

procedure TFrmLocalSelect.btnAddFileClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;
  for i := 0 to FileDialog.Files.Count - 1 do
    MySharePathApi.AddLocalItem( FileDialog.Files[i], True );
end;

procedure TFrmLocalSelect.btnAddShareClick(Sender: TObject);
var
  SelectPath : string;
begin
  SelectPath := '';
  if not MySelectFolderDialog.Select( 'Select folder for share', SelectPath, SelectPath ) then
    Exit;
  MySharePathApi.AddLocalItem( SelectPath, False );
end;

procedure TFrmLocalSelect.btnDeletedShareClick(Sender: TObject);
var
  i: Integer;
  ItemData : TLocalSharePathData;
begin
  for i := 0 to lvSharePath.Items.Count - 1 do
    if lvSharePath.Items[i].Selected then
    begin
      ItemData := lvSharePath.Items[i].Data;
      MySharePathApi.RemoveLocalItem( ItemData.FullPath );
    end;
end;

procedure TFrmLocalSelect.btnRemoveLocalDesClick(Sender: TObject);
var
  i: Integer;
  ItemData : TLocalDesData;
begin
  for i := 0 to LvLocalDes.Items.Count - 1 do
    if LvLocalDes.Items[i].Selected then
    begin
      ItemData := LvLocalDes.Items[i].Data;
      SendRootItemUserApi.RemoveLocalItem( ItemData.DesPath );
    end;
end;

procedure TFrmLocalSelect.DropFiles(var Msg: TMessage);
var
  FrmLocalDropFileHandle : TFrmLocalDropFileHandle;
begin
  FrmLocalDropFileHandle := TFrmLocalDropFileHandle.Create( Msg );
  FrmLocalDropFileHandle.Update;
  FrmLocalDropFileHandle.Free;

  FormUtil.ForceForegroundWindow( Handle );
end;

procedure TFrmLocalSelect.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True); // 设置需要处理文件 WM_DROPFILES 拖放消息
  LvLocalDes.SmallImages := MyIcon.getSysIcon;
  lvSharePath.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindRemoveData( LvLocalDes );
  ListviewUtil.BindRemoveData( lvSharePath );
  FormUtil.BindEseClose( Self );
end;

procedure TFrmLocalSelect.LvLocalDesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  tbtnRemove.Enabled := LvLocalDes.SelCount > 0;
end;

procedure TFrmLocalSelect.lvSharePathChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  tbtnShareRmove.Enabled := lvSharePath.SelCount > 0;
end;

procedure TFrmLocalSelect.Panel12Click(Sender: TObject);
begin
  MyExplore.OpenFolder( MySystemPath.getMyDoc );
end;

procedure TFrmLocalSelect.Panel3Click(Sender: TObject);
begin
  MyExplore.OpenFolder( MySystemPath.getMyDoc );
end;

procedure TFrmLocalSelect.ShowFileSend;
begin
  PcMain.ActivePage := tsFileSend;
  Show;
end;

procedure TFrmLocalSelect.ShowFileShare;
begin
  PcMain.ActivePage := tsFileShare;
  Show;
end;

procedure TFrmLocalSelect.tbtnAddFolderClick(Sender: TObject);
begin
  if not MySelectFolderDialog.Select( 'Select folder for receive', '', LastSelectFolder ) then
    Exit;
  SendRootItemUserApi.AddLocalItem( LastSelectFolder );
end;

procedure TFrmLocalSelect.tbtnAddShareFileClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;
  for i := 0 to FileDialog.Files.Count - 1 do
    MySharePathApi.AddLocalItem( FileDialog.Files[i], True );
end;


procedure TFrmLocalSelect.tbtnAddShareFolderClick(Sender: TObject);
begin
  if not MySelectFolderDialog.Select( 'Select folder for share', '', LastSelectFolder ) then
    Exit;
  MySharePathApi.AddLocalItem( LastSelectFolder, False );
end;

procedure TFrmLocalSelect.tbtnManualInputClick(Sender: TObject);
var
  InputPath : string;
begin
  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and ( not FileExists( InputPath ) and not DirectoryExists( InputPath ) ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'Enter Path', InputPath ) then
    Exit;

  if not FileExists( InputPath ) and not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist.' );
    Exit;
  end;

  MySharePathApi.AddLocalItem( LastSelectFolder, FileExists( InputPath ) );
end;

procedure TFrmLocalSelect.tbtnManuallyInputClick(Sender: TObject);
var
  InputPath : string;
begin
  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and not DirectoryExists( InputPath ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'Enter Path', InputPath ) then
    Exit;
  if not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist or it is not is a folder path' );
    Exit;
  end;
  SendRootItemUserApi.AddLocalItem( InputPath );
end;

procedure TFrmLocalSelect.tbtnRemoveClick(Sender: TObject);
var
  i: Integer;
  ItemData : TLocalDesData;
begin
  for i := 0 to LvLocalDes.Items.Count - 1 do
    if LvLocalDes.Items[i].Selected then
    begin
      ItemData := LvLocalDes.Items[i].Data;
      SendRootItemUserApi.RemoveLocalItem( ItemData.DesPath );
    end;
end;

procedure TFrmLocalSelect.tbtnShareRmoveClick(Sender: TObject);
var
  i: Integer;
  ItemData : TLocalSharePathData;
begin
  for i := 0 to lvSharePath.Items.Count - 1 do
    if lvSharePath.Items[i].Selected then
    begin
      ItemData := lvSharePath.Items[i].Data;
      MySharePathApi.RemoveLocalItem( ItemData.FullPath );
    end;
end;

{ TFrmLocalDropFileHandle }

procedure TFrmLocalDropFileHandle.AddReceivePath;
var
  i : Integer;
begin
  for I := 0 to FilePathList.Count - 1 do
    if DirectoryExists( FilePathList[i] ) then
      SendRootItemUserApi.AddLocalItem( FilePathList[i] );
end;

procedure TFrmLocalDropFileHandle.AddSharePath;
var
  i : Integer;
begin
  for I := 0 to FilePathList.Count - 1 do
    MySharePathApi.AddLocalItem( FilePathList[i], FileExists( FilePathList[i] ) );
end;

procedure TFrmLocalDropFileHandle.Update;
begin
  if FrmLocalSelect.PcMain.ActivePage = FrmLocalSelect.tsFileSend then
    AddReceivePath
  else
    AddSharePath;
end;

end.
