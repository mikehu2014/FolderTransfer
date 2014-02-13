unit UMyShareFaceInfo;

interface

uses UChangeInfo, ComCtrls, SysUtils, UMyUtil, virtualtrees;

type

{$Region ' 我的网络共享 ' }

    // 数据结构
  TSharePathData = class
  public
    FullPath : string;
    IsFile : boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsFile( _IsFile : boolean );
  end;

    // 父类
  TSharePathChangeFace = class( TFaceChangeInfo )
  public
    LvSharePath : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TSharePathWriteFace = class( TSharePathChangeFace )
  public
    FullPath : string;
  protected
    SharePathIndex : Integer;
    SharePathNode : TListItem;
    SharePathData : TSharePathData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode : Boolean;
  end;

    // 添加
  TSharePathAddFace = class( TSharePathWriteFace )
  public
    IsFile : boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
  protected
    procedure Update;override;
  end;

    // 删除
  TSharePathRemoveFace = class( TSharePathWriteFace )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 我的本地共享 ' }

    // 数据结构
  TLocalSharePathData = class
  public
    FullPath : string;
    IsFile : boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsFile( _IsFile : boolean );
  end;

    // 父类
  TLocalSharePathChangeFace = class( TFaceChangeInfo )
  public
    LvSharePath : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TLocalSharePathWriteFace = class( TLocalSharePathChangeFace )
  public
    FullPath : string;
  protected
    SharePathIndex : Integer;
    SharePathNode : TListItem;
    SharePathData : TLocalSharePathData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode : Boolean;
  end;

    // 添加
  TLocalSharePathAddFace = class( TLocalSharePathWriteFace )
  public
    IsFile : boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
  protected
    procedure Update;override;
  end;

    // 删除
  TLocalSharePathRemoveFace = class( TLocalSharePathWriteFace )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 网络共享 ' }

  TShareShowData = record
  public
    ItemID : WideString;
    IsFile : Boolean;
    IsNewShare : Boolean;
  public
    ShowName, NodeType : WideString;
    MainIcon : Integer;
  end;
  PShareShowData = ^TShareShowData;


  {$Region ' 共享根路径 修改 ' }

      // 父类
  TShareShowRootItemChangeFace = class( TFaceChangeInfo )
  public
    VstShareShow : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TShareShowRootItemWriteFace = class( TShareShowRootItemChangeFace )
  public
    RootItemID : string;
  protected
    ShareShowRootItemNode : PVirtualNode;
    ShareShowRootItemData : PShareShowData;
  public
    constructor Create( _RootItemID : string );
  protected
    function FindShareShowRootItemNode : Boolean;
  end;

    // 添加
  TShareShowRootItemAddFace = class( TShareShowRootItemWriteFace )
  private
    ShowName : string;
    IsLan : Boolean;
  public
    procedure SetShowName( _ShowName : string );
    procedure SetIsLan( _IsLan : Boolean );
  protected
    procedure Update;override;
  protected
    procedure AddItemInfo;virtual;abstract;
  end;

    // 添加 本地
  TShareShowRootItemAddLocalFace = class( TShareShowRootItemAddFace )
  protected
    procedure AddItemInfo;override;
  end;

    // 添加 网络
  TShareShowRootItemAddNetworkFace = class( TShareShowRootItemAddFace )
  protected
    procedure AddItemInfo;override;
  end;

    // 删除
  TShareShowRootItemRemoveFace = class( TShareShowRootItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 共享路径 修改 ' }

      // 修改
  TShareShowItemWriteFace = class( TShareShowRootItemWriteFace )
  public
    SharePath : string;
  protected
    ShareShowItemNode : PVirtualNode;
    ShareShowItemData : PShareShowData;
  public
    procedure SetSharePath( _SharePath : string );
  protected
    function FindShareShowItemNode : Boolean;
  end;

      // 添加
  TShareShowItemAddFace = class( TShareShowItemWriteFace )
  public
    IsFile : boolean;
    IsNewShare : Boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetIsNewShare( _IsNewShare : Boolean );
    procedure Update;override;
  end;

    // 删除
  TShareShowItemRemoveFace = class( TShareShowItemWriteFace )
  protected
    procedure Update;override;
  end;

    // 检测 是否存在共享
  TShareShowCheckExistFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

const
  ShareShowType_LocalRoot = 'LocalRoot';
  ShareShowType_LocalItem = 'LocalItem';
  ShareShowType_NetworkRoot = 'NetworkRoot';
  ShareShowType_NetworkItem = 'NetworkItem';

const
  ShareShowIcon_PcOnline = 1;
  ShareShowIcon_Folder = 5;
  ShareShowIcon_Lan = 6;
  ShareShowIcon_Internet = 7;

implementation

uses UFormSetting, UIconUtil, UMainForm, UFormLocalSelect;

{ TSharePathData }

constructor TSharePathData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TSharePathData.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

{ TSharePathChangeFace }

procedure TSharePathChangeFace.Update;
begin
  LvSharePath := frmSetting.lvSharePath;
end;

{ TSharePathWriteFace }

constructor TSharePathWriteFace.Create( _FullPath : string );
begin
  FullPath := _FullPath;
end;


function TSharePathWriteFace.FindSharePathNode : Boolean;
var
  SelectNode : TListItem;
  SelectData : TSharePathData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvSharePath.Items.Count - 1 do
  begin
    SelectNode := LvSharePath.Items[i];
    SelectData := SelectNode.Data;
    if ( SelectData.FullPath = FullPath ) then
    begin
      Result := True;
      SharePathIndex := i;
      SharePathNode := SelectNode;
      SharePathData := SelectData;
      Break;
    end;
  end;
end;

{ TSharePathAddFace }

procedure TSharePathAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TSharePathAddFace.Update;
var
  MainIcon : Integer;
begin
  inherited;

  if FindSharePathNode then
    Exit;

    // 添加
  SharePathNode := LvSharePath.Items.Add;
  SharePathData := TSharePathData.Create( FullPath );
  SharePathData.SetIsFile( IsFile );

    // 提取图标信息
  if IsFile or DirectoryExists( FullPath ) then
    MainIcon := MyIcon.getIconByFilePath( FullPath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

    // 设置信息
  with SharePathNode do
  begin
    Caption := FullPath;
    ImageIndex := MainIcon;
    Data := SharePathData;
  end;
end;

{ TSharePathRemoveFace }

procedure TSharePathRemoveFace.Update;
begin
  inherited;

  if not FindSharePathNode then
    Exit;

  LvSharePath.Items.Delete( SharePathIndex );
end;

{ TShareShowRootItemChangeFace }

procedure TShareShowRootItemChangeFace.Update;
begin
  VstShareShow := frmMainForm.vstShareShow;
end;

{ TShareShowRootItemWriteFace }

constructor TShareShowRootItemWriteFace.Create( _RootItemID : string );
begin
  RootItemID := _RootItemID;
end;


function TShareShowRootItemWriteFace.FindShareShowRootItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PShareShowData;
begin
  Result := False;
  SelectNode := VstShareShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareShow.GetNodeData( SelectNode );
    if ( SelectData.ItemID = RootItemID ) then
    begin
      Result := True;
      ShareShowRootItemNode := SelectNode;
      ShareShowRootItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TShareShowRootItemAddFace }

procedure TShareShowRootItemAddFace.SetIsLan(_IsLan: Boolean);
begin
  IsLan := _IsLan;
end;

procedure TShareShowRootItemAddFace.SetShowName(_ShowName: string);
begin
  ShowName := _ShowName;
end;

procedure TShareShowRootItemAddFace.Update;
begin
  inherited;

  if FindShareShowRootItemNode then
    Exit;

  ShareShowRootItemNode := VstShareShow.AddChild( VstShareShow.RootNode );
  ShareShowRootItemNode.NodeHeight := 30;
  VstShareShow.IsVisible[ ShareShowRootItemNode ] := False;

  ShareShowRootItemData := VstShareShow.GetNodeData( ShareShowRootItemNode );
  ShareShowRootItemData.ItemID := RootItemID;
  ShareShowRootItemData.ShowName := ShowName;

  AddItemInfo;
end;

{ TShareShowRootItemRemoveFace }

procedure TShareShowRootItemRemoveFace.Update;
begin
  inherited;

  if not FindShareShowRootItemNode then
    Exit;

  VstShareShow.DeleteNode( ShareShowRootItemNode );
end;

{ TShareShowItemWriteFace }

procedure TShareShowItemWriteFace.SetSharePath( _SharePath : string );
begin
  SharePath := _SharePath;
end;


function TShareShowItemWriteFace.FindShareShowItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PShareShowData;
begin
  Result := False;
  if not FindShareShowRootItemNode then
    Exit;
  SelectNode := ShareShowRootItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareShow.GetNodeData( SelectNode );
    if ( SelectData.ItemID = SharePath ) then
    begin
      Result := True;
      ShareShowItemNode := SelectNode;
      ShareShowItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TShareShowItemAddFace }

procedure TShareShowItemAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TShareShowItemAddFace.SetIsNewShare(_IsNewShare: Boolean);
begin
  IsNewShare := _IsNewShare;
end;

procedure TShareShowItemAddFace.Update;
var
  MainIcon : Integer;
begin
  inherited;

  if FindShareShowItemNode then
    Exit;

  if not Assigned( ShareShowRootItemNode )  then
    Exit;

  if IsFile then
    MainIcon := MyIcon.getIconByFileExt( SharePath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

  ShareShowItemNode := VstShareShow.AddChild( ShareShowRootItemNode );
  ShareShowItemData := VstShareShow.GetNodeData( ShareShowItemNode );
  ShareShowItemData.ItemID := SharePath;
  ShareShowItemData.IsFile := IsFile;
  ShareShowItemData.IsNewShare := IsNewShare;
  ShareShowItemData.ShowName := SharePath;
  ShareShowItemData.MainIcon := MainIcon;

    // Item 类型
  if ShareShowRootItemData.NodeType = ShareShowType_LocalRoot then
    ShareShowItemData.NodeType := ShareShowType_LocalItem
  else
    ShareShowItemData.NodeType := ShareShowType_NetworkItem;

  VstShareShow.IsVisible[ ShareShowRootItemNode ] := True;
  VstShareShow.Expanded[ ShareShowRootItemNode ] := True;

  frmMainForm.tbtnShareShowCollapse.Enabled := True;
  frmMainForm.tbtnShareShowExpand.Enabled := True;
  frmMainForm.plNoShareShow.Visible := False;

        // 显示下载按钮
  frmMainForm.tbtnShareShowDown.Enabled := True;
end;

{ TShareShowItemRemoveFace }

procedure TShareShowItemRemoveFace.Update;
begin
  inherited;

  if not FindShareShowItemNode then
    Exit;

  VstShareShow.DeleteNode( ShareShowItemNode );
  if ShareShowRootItemNode.ChildCount = 0 then
    VstShareShow.IsVisible[ ShareShowRootItemNode ] := False;
end;


{ TLocalSharePathData }

constructor TLocalSharePathData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TLocalSharePathData.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

{ TLocalSharePathChangeFace }

procedure TLocalSharePathChangeFace.Update;
begin
  LvSharePath := FrmLocalSelect.lvSharePath;
end;

{ TLocalSharePathWriteFace }

constructor TLocalSharePathWriteFace.Create( _FullPath : string );
begin
  FullPath := _FullPath;
end;


function TLocalSharePathWriteFace.FindSharePathNode : Boolean;
var
  SelectNode : TListItem;
  SelectData : TLocalSharePathData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvSharePath.Items.Count - 1 do
  begin
    SelectNode := LvSharePath.Items[i];
    SelectData := SelectNode.Data;
    if ( SelectData.FullPath = FullPath ) then
    begin
      Result := True;
      SharePathIndex := i;
      SharePathNode := SelectNode;
      SharePathData := SelectData;
      Break;
    end;
  end;
end;

{ TLocalSharePathAddFace }

procedure TLocalSharePathAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TLocalSharePathAddFace.Update;
var
  MainIcon : Integer;
begin
  inherited;

  if FindSharePathNode then
    Exit;

    // 添加
  SharePathNode := LvSharePath.Items.Add;
  SharePathData := TLocalSharePathData.Create( FullPath );
  SharePathData.SetIsFile( IsFile );

    // 提取图标信息
  if IsFile or DirectoryExists( FullPath ) then
    MainIcon := MyIcon.getIconByFilePath( FullPath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

    // 设置信息
  with SharePathNode do
  begin
    Caption := FullPath;
    ImageIndex := MainIcon;
    Data := SharePathData;
  end;
end;

{ TLocalSharePathRemoveFace }

procedure TLocalSharePathRemoveFace.Update;
begin
  inherited;

  if not FindSharePathNode then
    Exit;

  LvSharePath.Items.Delete( SharePathIndex );
end;


{ TShareShowRootItemAddLocalFace }

procedure TShareShowRootItemAddLocalFace.AddItemInfo;
begin
  ShareShowRootItemData.NodeType := ShareShowType_LocalRoot;
  ShareShowRootItemData.MainIcon := ShareShowIcon_Folder;
end;

{ TShareShowRootItemAddNetworkFace }

procedure TShareShowRootItemAddNetworkFace.AddItemInfo;
begin
  ShareShowRootItemData.NodeType := ShareShowType_NetworkRoot;
  if IsLan then
    ShareShowRootItemData.MainIcon := ShareShowIcon_Lan
  else
    ShareShowRootItemData.MainIcon := ShareShowIcon_Internet;
end;

{ TShareShowCheckExistFace }

procedure TShareShowCheckExistFace.Update;
begin
  frmMainForm.tmrCheckNotShare.Enabled := True;
end;

end.
