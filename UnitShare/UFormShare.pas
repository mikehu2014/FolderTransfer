unit UFormShare;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VirtualTrees, Vcl.StdCtrls;

type

  PShellObjectData = ^TShellObjectData;
  TShellObjectData = record
    FullPath, Display: WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
    DisplayIcon : Integer;
  end;

  TfrmSelectShare = class(TForm)
    vstSelectPath: TVirtualStringTree;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure vstSelectPathGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectPathInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectPathInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure vstSelectPathFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
  private
    OtherPathList : TStringList;
    procedure AddDriver( Path : string );
    procedure AddOtherPaths;
    procedure AddOtherPath( FolderPath : string );
  private
    function AddFileNode( ParentNode : PVirtualNode; FileName : string ): PVirtualNode;
    function AddFolderNode( ParentNode : PVirtualNode; FolderName : string ): PVirtualNode;
  private
    procedure SetUnCheckedSource( Node : PVirtualNode );   // ��� Checked
    procedure AddSourceItem( SourcePath : string );
    procedure FindSourcePathList( Node : PVirtualNode; SourcePathList : TStringList ); // Find Path
  public
    function AddShare( PathList : TStringList ): Boolean;
    function getShare : TStringList;
  end;

      // ������
  SelectBackupFormUtil = class
  public
    class function getIsOtherPath( SourcePath : string ): Boolean;
    class function getOtherFirstNode : PVirtualNode;
  end;

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

var
  frmSelectShare: TfrmSelectShare;
  SystemPath_Share_DriverCount : Integer = 0;
  SystemPath_NetHood : string;

implementation

uses UIconUtil, UMyUtil;

{$R *.dfm}

procedure TfrmSelectShare.AddDriver(Path: string);
var
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
begin
    // ���̲�����
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
    Inc( SystemPath_Share_DriverCount );
  except
  end;
end;

function TfrmSelectShare.AddFileNode(ParentNode: PVirtualNode;
  FileName: string): PVirtualNode;
var
  SelectNode, UpNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // Ѱ��λ��
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

    // �ҵ�λ��
  if Assigned( UpNode ) then
    Result := vstSelectPath.InsertNode( UpNode, amInsertAfter )
  else  // ��ӵ���һ��λ��
    Result := vstSelectPath.InsertNode( ParentNode, amAddChildFirst );
end;

function TfrmSelectShare.AddFolderNode(ParentNode: PVirtualNode;
  FolderName: string): PVirtualNode;
var
  SelectNode, DownNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // Ѱ��λ��
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

    // �ҵ�λ��
  if Assigned( DownNode ) then
    Result := vstSelectPath.InsertNode( DownNode, amInsertBefore )
  else  // ��ӵ���һ��λ��
    Result := vstSelectPath.AddChild( ParentNode );
end;

procedure TfrmSelectShare.AddOtherPath(FolderPath: string);
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

procedure TfrmSelectShare.AddOtherPaths;
begin
  AddOtherPath( MySystemPath.getDesktop );
  AddOtherPath( MySystemPath.getMyDoc );
  SystemPath_NetHood := MySystemPath.getNetworkFolder;
end;

function TfrmSelectShare.AddShare(PathList: TStringList): Boolean;
var
  i: Integer;
begin
  SetUnCheckedSource( vstSelectPath.RootNode );
  for i := 0 to PathList.Count - 1 do
    AddSourceItem( PathList[i] );
  Result := ShowModal = mrOk;
end;

procedure TfrmSelectShare.AddSourceItem(SourcePath: string);
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

      // �ҵ��˽ڵ�
    if SourcePath = NodePath then
    begin
      IsAdd := True;
      vstSelectPath.CheckState[ ChildNode ] := csCheckedNormal;
      Break;
    end;

      // �ҵ��˸��ڵ�
    if MyMatchMask.CheckChild( SourcePath, NodePath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      vstSelectPath.CheckState[ ChildNode ] := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // ��һ���ڵ�
    ChildNode := ChildNode.NextSibling;
  end;

    // ��� �ɹ�
  if IsAdd then
    Exit;

    // �����ڵ�
  NewNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
  NewNode.CheckState := csCheckedNormal;
  NodeData := vstSelectPath.GetNodeData( NewNode );
  NodeData.FullPath := SourcePath;
  NodeData.Display := ExtractFileName( SourcePath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( SourcePath );
  NodeData.IsFolder := FileExists( SourcePath );
end;

procedure TfrmSelectShare.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectShare.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSelectShare.FindSourcePathList(Node: PVirtualNode;
  SourcePathList: TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ( ChildNode.CheckState = csCheckedNormal ) then  // �ҵ�ѡ���·��
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      SourcePathList.Add( NodeData.FullPath );
    end
    else
    if ChildNode.CheckState = csMixedNormal then  // ����һ��
      FindSourcePathList( ChildNode, SourcePathList );
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectShare.FormCreate(Sender: TObject);
var
  LastDriverList : TStringList;
  i : Integer;
begin
  OtherPathList := TStringList.Create;

  vstSelectPath.NodeDataSize := SizeOf( TShellObjectData );
  vstSelectPath.Images := MyIcon.getSysIcon;

  LastDriverList := MyHardDisk.getPathList;
  for i := 0 to LastDriverList.Count - 1 do
    AddDriver( LastDriverList[i] );

  AddOtherPaths;
end;

procedure TfrmSelectShare.FormDestroy(Sender: TObject);
begin
  OtherPathList.Free;
end;

procedure TfrmSelectShare.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSelectShare.getShare: TStringList;
begin
  Result := TStringList.Create;
  FindSourcePathList( vstSelectPath.RootNode, Result );
end;

procedure TfrmSelectShare.SetUnCheckedSource(Node: PVirtualNode);
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

procedure TfrmSelectShare.vstSelectPathFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if not Assigned( Node ) then
    Exit;
  Sender.CheckState[ Node ] := csCheckedNormal;
end;

procedure TfrmSelectShare.vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
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

procedure TfrmSelectShare.vstSelectPathGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
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

procedure TfrmSelectShare.vstSelectPathInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data, ChildData: PShellObjectData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // ����Ŀ¼����Ϣ���Ҳ���������
  Data := Sender.GetNodeData(Node);
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // ��·��
      FilePath := FullPath + FileName;

        // �����·��
      if OtherPathList.IndexOf( FilePath ) >= 0 then
        Continue;

        // �ӽڵ�����
      if DirectoryExists( FilePath ) then
        ChildNode := AddFolderNode( Node, FileName )
      else
        ChildNode := AddFileNode( Node, FileName );
      ChildData := Sender.GetNodeData(ChildNode);
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

        // ��ʼ��
      if Node.CheckState = csCheckedNormal then   // ������ڵ�ȫ��Check, ���ӽڵ� check
        ChildNode.CheckState := csCheckedNormal;
      Sender.ValidateNode(ChildNode, False);

        // �ӽڵ���Ŀ
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;

procedure TfrmSelectShare.vstSelectPathInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Data.DisplayIcon := MyIcon.getIconByFilePath( Data.FullPath );

  if MyFilePath.getHasChild( Data.FullPath ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

{ FormUtil }

class function SelectBackupFormUtil.getIsOtherPath(SourcePath: string): Boolean;
var
  OtherPathList : TStringList;
  i : Integer;
begin
  Result := False;

  OtherPathList := frmSelectShare.OtherPathList;
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
  with frmSelectShare do
  begin
    Result := vstSelectPath.RootNode.FirstChild;
    for i := 0 to SystemPath_Share_DriverCount - 1 do
    begin
      if not Assigned( Result ) then
        Break;
      Result := Result.NextSibling;
    end;
  end;
end;


end.
