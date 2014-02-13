unit UMyReceiveDataInfo;

interface

uses Generics.Collections, UDataSetInfo, UMyUtil, classes;

type

{$Region ' ���ݽṹ ' }

    // ���� Item
  TReceiveItemInfo = class
  public
    SourcePath, OwnerID : string;
    IsFile : boolean;
    IsReceiving : Boolean;
    IsCompleted, IsCancel, IsZip : Boolean;
    IsFirstReceive : Boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    SavePath : string;
  public
    constructor Create( _SourcePath, _OwnerID : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetIsReceiving( _IsReceiving : Boolean );
    procedure SetStatusInfo( _IsCompleted, _IsCancel : boolean );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetIsFirstReceive( _IsFirstReceive : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure SetSavePath( _SavePath : string );
  end;
  TReceiveItemList = class( TObjectList<TReceiveItemInfo> );

    // ���� ��·��
  TReceiveRootItemInfo = class
  public
    RootPath : string;
    ReceiveItemList : TReceiveItemList;
  public
    constructor Create( _RootPath : string );
    destructor Destroy; override;
  end;
  TReceiveRootItemList = class( TObjectList< TReceiveRootItemInfo > )end;


    // ��Pc��Ϣ
  TMyFileReceiveInfo = class( TMyDataInfo )
  public
    ReceiveRootItemList : TReceiveRootItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TReceiveRootItemListAccessInfo = class
  protected
    ReceiveRootItemList : TReceiveRootItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TReceiveRootItemAccessInfo = class( TReceiveRootItemListAccessInfo )
  public
    RootPath : string;
  protected
    ReceiveRootItemIndex : Integer;
    ReceiveRootItemInfo : TReceiveRootItemInfo;
  public
    constructor Create( _CloudPath : string );
  protected
    function FindReceiveRootItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TReceiveItemListAccessInfo = class( TReceiveRootItemAccessInfo )
  protected
    ReceiveItemList : TReceiveItemList;
  protected
    function FindReceiveItemList : Boolean;
  end;

    // ���� ���ݽӿ�
  TReceiveItemAccessInfo = class( TReceiveItemListAccessInfo )
  public
    SourcePath, OwnerID : string;
  protected
    ReceiveItemIndex : Integer;
    ReceiveItemInfo : TReceiveItemInfo;
  public
    procedure SetSourceInfo( _SourcePath, _OwnerID : string );
  protected
    function FindReceiveItemInfo: Boolean;
  end;

{$EndRegion}

{$Region ' �����޸� ��·����Ϣ ' }

    // �޸ĸ���
  TReceiveRootItemWriteInfo = class( TReceiveRootItemAccessInfo )
  end;

    // ���
  TReceiveRootItemAddInfo = class( TReceiveRootItemWriteInfo )
  public
    procedure Update;
  end;

    // ɾ��
  TReceiveRootItemRemoveInfo = class( TReceiveRootItemWriteInfo )
  public
    procedure Update;
  end;


{$EndRegion}

{$Region ' �����޸� Դ·����Ϣ ' }

  {$Region ' ��ɾ��Ϣ ' }

    // �޸ĸ���
  TReceiveItemWriteInfo = class( TReceiveItemAccessInfo )
  end;

      // ���
  TReceiveItemAddInfo = class( TReceiveItemWriteInfo )
  public
    IsFile : boolean;
    IsCompleted, IsCancel, IsZip : Boolean;
    IsFirstReceive : Boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetStatusInfo( _IsCompleted, _IsCancel : boolean );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetIsFirstReceive( _IsFirstReceive : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure Update;
  end;

    // ɾ��
  TReceiveItemRemoveInfo = class( TReceiveItemWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �ռ���Ϣ ' }

      // �޸�
  TReceiveItemSetSpaceInfoInfo = class( TReceiveItemWriteInfo )
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure Update;
  end;

    // �޸�
  TReceiveItemSetAddCompletedSpaceInfo = class( TReceiveItemWriteInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;


  {$EndRegion}

  {$Region ' ״̬��Ϣ ' }

      // �޸�
  TReceiveItemSetIsReceivingInfo = class( TReceiveItemWriteInfo )
  public
    IsReceiving : boolean;
  public
    procedure SetIsReceiving( _IsReceiving : boolean );
    procedure Update;
  end;

      // �޸�
  TReceiveItemSetIsCompletedInfo = class( TReceiveItemWriteInfo )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  end;

      // �޸�
  TReceiveItemSetIsCancelInfo = class( TReceiveItemWriteInfo )
  public
    IsCancel : boolean;
  public
    procedure SetIsCancel( _IsCancel : boolean );
    procedure Update;
  end;

  TReceiveItemSetIsFirstReceiveInfo = class( TReceiveItemWriteInfo )
  public
    IsFirstReceive : Boolean;
  public
    procedure SetIsFirstReceive( _IsFirstReceive : boolean );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ���ݶ�ȡ ' }

    // ��ȡ ������·��
  TReceiveRootPathReadList = class( TReceiveRootItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��·���Ƿ����
  TReceiveRootPathReadExist = class( TReceiveRootItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ���յ�ӵ�����б�
  TReceiveOnwerReadList = class( TReceiveItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ӵ���ߵĽ���·���б�
  TReceiveItemPathReadList = class( TReceiveItemListAccessInfo )
  public
    OwnerID : string;
  public
    procedure SetOwnerID( _OwnerID : string );
    function get : TReceiveItemList;
  end;

    // ��ȡ �Ƿ����
  TReceiveItemReadIsExist = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����
  TReceiveItemReadSavePath = class( TReceiveItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ �ռ��ѱ������
  TReceiveItemReadIsFile = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �ռ��ѱ������
  TReceiveItemReadIsSendCancel = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;


    // ��ȡ �ռ��ѱ������
  TReceiveItemReadIsSpaceCompleted = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;

      // ��ȡ �ռ��ѱ������
  TReceiveItemReadIsZip = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;

      // ��ȡ �ռ��ѱ������
  TReceiveItemReadIsFirstReceive = class( TReceiveItemAccessInfo )
  public
    function get : Boolean;
  end;


    // ���ո���Ϣ
  ReceiveRootInfoReadUtil = class
  public
    class function ReadPathList : TStringList;
    class function ReadIsExist( CloudPath : string ): Boolean;
    class function ReadOwnerList( CloudPath : string ) : TStringList;
    class function ReadOwnerPathList( CloudPath, OwnerID : string ) : TReceiveItemList;
  public
    class function ReadCloudPcPath( CloudPath, PcID : string ): string;
    class function ReadCloudFilePath( CloudPath, PcID, FilePath : string ): string;
    class function ReadCloudRecyclePath( CloudPath, PcID, FilePath : string ): string;
  end;

    // ����Item��Ϣ
  ReceiveItemInfoReadUtil = class
  public
    class function ReadIsExist( CloudPath, SourcePath, OwnerID : string ): Boolean;
    class function ReadSavePath( CloudPath, SourcePath, OwnerID : string ): string;
    class function ReadIsFile( CloudPath, SourcePath, OwnerID : string ): Boolean;
    class function ReadIsSendCancel( CloudPath, SourcePath, OwnerID : string ): Boolean;
    class function ReadIsSpaceCompleted( CloudPath, SourcePath, OwnerID : string ): Boolean;
    class function ReadIsZip( CloudPath, SourcePath, OwnerID : string ): Boolean;
    class function ReadIsFirstReceive( CloudPath, SourcePath, OwnerID : string ): Boolean;
  end;

{$EndRegion}

const
  NetworkBackup_RecycledFolder = 'Recycled';

var
  MyFileReceiveInfo : TMyFileReceiveInfo;

implementation

{ TCloudPcBackupInfo }

constructor TReceiveItemInfo.Create( _SourcePath, _OwnerID : string );
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;

procedure TReceiveItemInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TReceiveItemInfo.SetIsFirstReceive(_IsFirstReceive: Boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemInfo.SetIsReceiving(_IsReceiving: Boolean);
begin
  IsReceiving := _IsReceiving;
end;

procedure TReceiveItemInfo.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveItemInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TReceiveItemInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemInfo.SetStatusInfo(_IsCompleted, _IsCancel: boolean);
begin
  IsCompleted := _IsCompleted;
  IsCancel := _IsCancel;
end;

{ TMyCloudInfo }

constructor TMyFileReceiveInfo.Create;
begin
  inherited;
  ReceiveRootItemList := TReceiveRootItemList.Create;
end;

destructor TMyFileReceiveInfo.Destroy;
begin
  ReceiveRootItemList.Free;
  inherited;
end;

{ MyCloudInfoReadUtil }

class function ReceiveRootInfoReadUtil.ReadOwnerPathList(
  CloudPath, OwnerID : string ): TReceiveItemList;
var
  CloudBackupPathReadList : TReceiveItemPathReadList;
begin
  CloudBackupPathReadList := TReceiveItemPathReadList.Create( CloudPath );
  CloudBackupPathReadList.SetOwnerID( OwnerID );
  Result := CloudBackupPathReadList.get;
  CloudBackupPathReadList.Free;
end;

class function ReceiveRootInfoReadUtil.ReadCloudFilePath(CloudPath, PcID,
  FilePath: string): string;
begin
  Result := MyFilePath.getPath( ReadCloudPcPath( CloudPath, PcID ) );
  Result := Result + MyFilePath.getDownloadPath( FilePath );
end;

class function ReceiveRootInfoReadUtil.ReadOwnerList(
  CloudPath: string): TStringList;
var
  CloudOnwerReadList : TReceiveOnwerReadList;
begin
  CloudOnwerReadList := TReceiveOnwerReadList.Create( CloudPath );
  Result := CloudOnwerReadList.get;
  CloudOnwerReadList.Free;
end;

class function ReceiveRootInfoReadUtil.ReadIsExist(
  CloudPath: string): Boolean;
var
  CloudPathReadExist : TReceiveRootPathReadExist;
begin
  CloudPathReadExist := TReceiveRootPathReadExist.Create( CloudPath );
  Result := CloudPathReadExist.get;
  CloudPathReadExist.Free;
end;

class function ReceiveRootInfoReadUtil.ReadPathList: TStringList;
var
  CloudPathReadList : TReceiveRootPathReadList;
begin
  CloudPathReadList := TReceiveRootPathReadList.Create;
  Result := CloudPathReadList.get;
  CloudPathReadList.Free;
end;


class function ReceiveRootInfoReadUtil.ReadCloudPcPath(CloudPath, PcID: string): string;
begin
  Result := MyFilePath.getPath( CloudPath ) + PcID;
end;

class function ReceiveRootInfoReadUtil.ReadCloudRecyclePath(CloudPath, PcID,
  FilePath: string): string;
begin
  Result := MyFilePath.getPath( ReadCloudPcPath( CloudPath, PcID ) );
  Result := Result + MyFilePath.getPath( NetworkBackup_RecycledFolder );
  Result := Result + MyFilePath.getDownloadPath( FilePath );
end;

{ TCloudPathInfo }

constructor TReceiveRootItemInfo.Create(_RootPath: string);
begin
  RootPath := _RootPath;
  ReceiveItemList := TReceiveItemList.Create;
end;

destructor TReceiveRootItemInfo.Destroy;
begin
  ReceiveItemList.Free;
  inherited;
end;

{ TCloudPathListAccessInfo }

constructor TReceiveRootItemListAccessInfo.Create;
begin
  MyFileReceiveInfo.EnterData;
  ReceiveRootItemList := MyFileReceiveInfo.ReceiveRootItemList;
end;

destructor TReceiveRootItemListAccessInfo.Destroy;
begin
  MyFileReceiveInfo.LeaveData;
  inherited;
end;

{ TCloudPathAccessInfo }

constructor TReceiveRootItemAccessInfo.Create( _CloudPath : string );
begin
  inherited Create;
  RootPath := _CloudPath;
end;

function TReceiveRootItemAccessInfo.FindReceiveRootItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to ReceiveRootItemList.Count - 1 do
    if ( ReceiveRootItemList[i].RootPath = RootPath ) then
    begin
      Result := True;
      ReceiveRootItemIndex := i;
      ReceiveRootItemInfo := ReceiveRootItemList[i];
      break;
    end;
end;

{ TCloudPathAddInfo }

procedure TReceiveRootItemAddInfo.Update;
begin
  if FindReceiveRootItemInfo then
    Exit;

  ReceiveRootItemInfo := TReceiveRootItemInfo.Create( RootPath );
  ReceiveRootItemList.Add( ReceiveRootItemInfo );
end;

{ TCloudPathRemoveInfo }

procedure TReceiveRootItemRemoveInfo.Update;
begin
  if not FindReceiveRootItemInfo then
    Exit;

  ReceiveRootItemList.Delete( ReceiveRootItemIndex );
end;

{ TCloudPcBackupPathListAccessInfo }

function TReceiveItemListAccessInfo.FindReceiveItemList : Boolean;
begin
  Result := FindReceiveRootItemInfo;
  if Result then
    ReceiveItemList := ReceiveRootItemInfo.ReceiveItemList
  else
    ReceiveItemList := nil;
end;

{ TCloudPcBackupPathAccessInfo }

procedure TReceiveItemAccessInfo.SetSourceInfo( _SourcePath, _OwnerID : string );
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;


function TReceiveItemAccessInfo.FindReceiveItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindReceiveItemList then
    Exit;
  for i := 0 to ReceiveItemList.Count - 1 do
    if ( ReceiveItemList[i].SourcePath = SourcePath ) and
       ( ReceiveItemList[i].OwnerID = OwnerID )
    then
    begin
      Result := True;
      ReceiveItemIndex := i;
      ReceiveItemInfo := ReceiveItemList[i];
      break;
    end;
end;

{ TCloudPcBackupPathAddInfo }

procedure TReceiveItemAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TReceiveItemAddInfo.SetIsFirstReceive(_IsFirstReceive: Boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemAddInfo.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveItemAddInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TReceiveItemAddInfo.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemAddInfo.SetStatusInfo(_IsCompleted, _IsCancel: boolean);
begin
  IsCompleted := _IsCompleted;
  IsCancel := _IsCancel;
end;

procedure TReceiveItemAddInfo.Update;
begin
  if FindReceiveItemInfo or ( ReceiveItemList = nil ) then
    Exit;

  ReceiveItemInfo := TReceiveItemInfo.Create( SourcePath, OwnerID );
  ReceiveItemInfo.SetIsFile( IsFile );
  ReceiveItemInfo.SetIsReceiving( False );
  ReceiveItemInfo.SetStatusInfo( IsCompleted, IsCancel );
  ReceiveItemInfo.SetIsZip( IsZip );
  ReceiveItemInfo.SetIsFirstReceive( IsFirstReceive );
  ReceiveItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSpace );
  ReceiveItemInfo.SetSavePath( SavePath );
  ReceiveItemList.Add( ReceiveItemInfo );
end;

{ TCloudPcBackupPathRemoveInfo }

procedure TReceiveItemRemoveInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;

  ReceiveItemList.Delete( ReceiveItemIndex );
end;




{ TCloudPathReadList }

function TReceiveRootPathReadList.get: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to ReceiveRootItemList.Count - 1 do
    Result.Add( ReceiveRootItemList[i].RootPath );
end;

{ TCloudPathReadExist }

function TReceiveRootPathReadExist.get: Boolean;
begin
  Result := FindReceiveRootItemInfo;
end;

{ TCloudBackupPathReadList }

function TReceiveItemPathReadList.get: TReceiveItemList;
var
  i : Integer;
  OldCloudBackup, NewCloudBackup : TReceiveItemInfo;
begin
  Result := TReceiveItemList.Create;
  if not FindReceiveItemList then
    Exit;

  for i := 0 to ReceiveItemList.Count - 1 do
  begin
    OldCloudBackup := ReceiveItemList[i];
    if OldCloudBackup.OwnerID <> OwnerID then
      Continue;

    NewCloudBackup := TReceiveItemInfo.Create( OldCloudBackup.SourcePath, OldCloudBackup.OwnerID );
    NewCloudBackup.SetIsFile( OldCloudBackup.IsFile );
    NewCloudBackup.SetSpaceInfo( OldCloudBackup.FileCount, OldCloudBackup.ItemSize, OldCloudBackup.CompletedSpace );
    Result.Add( NewCloudBackup );
  end;
end;

{ TCloudPcReadList }

function TReceiveOnwerReadList.get: TStringList;
var
  i : Integer;
  OwnerID : string;
begin
  Result := TStringList.Create;
  if not FindReceiveItemList then
    Exit;
  for i := 0 to ReceiveItemList.Count - 1 do
  begin
    OwnerID := ReceiveItemList[i].OwnerID;
    if Result.IndexOf( OwnerID ) < 0 then
      Result.Add( OwnerID );
  end;
end;

procedure TReceiveItemPathReadList.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

{ TReceiveItemReadIsExist }

function TReceiveItemReadIsExist.get: Boolean;
begin
  Result := FindReceiveItemInfo;
end;

{ TReceiveItemReadSavePath }

function TReceiveItemReadSavePath.get: string;
begin
  Result := '';
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.SavePath;
end;

{ ReceiveItemInfoReadUtil }

class function ReceiveItemInfoReadUtil.ReadIsExist(CloudPath, SourcePath,
  OwnerID: string): Boolean;
var
  ReceiveItemReadIsExist : TReceiveItemReadIsExist;
begin
  ReceiveItemReadIsExist := TReceiveItemReadIsExist.Create( CloudPath );
  ReceiveItemReadIsExist.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsExist.get;
  ReceiveItemReadIsExist.Free;
end;

class function ReceiveItemInfoReadUtil.ReadSavePath(CloudPath, SourcePath,
  OwnerID: string): string;
var
  ReceiveItemReadSavePath : TReceiveItemReadSavePath;
begin
  ReceiveItemReadSavePath := TReceiveItemReadSavePath.Create( CloudPath );
  ReceiveItemReadSavePath.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadSavePath.get;
  ReceiveItemReadSavePath.Free;
end;

class function ReceiveItemInfoReadUtil.ReadIsFile(CloudPath, SourcePath,
  OwnerID: string): Boolean;
var
  ReceiveItemReadIsFile : TReceiveItemReadIsFile;
begin
  ReceiveItemReadIsFile := TReceiveItemReadIsFile.Create( CloudPath );
  ReceiveItemReadIsFile.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsFile.get;
  ReceiveItemReadIsFile.Free;
end;

class function ReceiveItemInfoReadUtil.ReadIsFirstReceive(CloudPath, SourcePath,
  OwnerID: string): Boolean;
var
  ReceiveItemReadIsFirstReceive : TReceiveItemReadIsFirstReceive;
begin
  ReceiveItemReadIsFirstReceive := TReceiveItemReadIsFirstReceive.Create( CloudPath );
  ReceiveItemReadIsFirstReceive.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsFirstReceive.get;
  ReceiveItemReadIsFirstReceive.Free;
end;

class function ReceiveItemInfoReadUtil.ReadIsSendCancel(CloudPath, SourcePath,
  OwnerID: string): Boolean;
var
  ReceiveItemReadIsSendCancel : TReceiveItemReadIsSendCancel;
begin
  ReceiveItemReadIsSendCancel := TReceiveItemReadIsSendCancel.Create( CloudPath );
  ReceiveItemReadIsSendCancel.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsSendCancel.get;
  ReceiveItemReadIsSendCancel.Free;
end;

class function ReceiveItemInfoReadUtil.ReadIsSpaceCompleted(CloudPath,
  SourcePath, OwnerID: string): Boolean;
var
  ReceiveItemReadIsSpaceCompleted : TReceiveItemReadIsSpaceCompleted;
begin
  ReceiveItemReadIsSpaceCompleted := TReceiveItemReadIsSpaceCompleted.Create( CloudPath );
  ReceiveItemReadIsSpaceCompleted.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsSpaceCompleted.get;
  ReceiveItemReadIsSpaceCompleted.Free;
end;

class function ReceiveItemInfoReadUtil.ReadIsZip(CloudPath, SourcePath,
  OwnerID: string): Boolean;
var
  ReceiveItemReadIsZip : TReceiveItemReadIsZip;
begin
  ReceiveItemReadIsZip := TReceiveItemReadIsZip.Create( CloudPath );
  ReceiveItemReadIsZip.SetSourceInfo( SourcePath, OwnerID );
  Result := ReceiveItemReadIsZip.get;
  ReceiveItemReadIsZip.Free;
end;

{ TReceiveItemSetSpaceInfoInfo }

procedure TReceiveItemSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemSetSpaceInfoInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.FileCount := FileCount;
  ReceiveItemInfo.ItemSize := ItemSize;
  ReceiveItemInfo.CompletedSpace := CompletedSpace;
end;

{ TReceiveItemSetAddCompletedSpaceInfo }

procedure TReceiveItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TReceiveItemSetAddCompletedSpaceInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.CompletedSpace := ReceiveItemInfo.CompletedSpace + AddCompletedSpace;
end;

{ TReceiveItemSetIsReceivingInfo }

procedure TReceiveItemSetIsReceivingInfo.SetIsReceiving( _IsReceiving : boolean );
begin
  IsReceiving := _IsReceiving;
end;

procedure TReceiveItemSetIsReceivingInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.IsReceiving := IsReceiving;
end;

{ TReceiveItemSetIsCompletedInfo }

procedure TReceiveItemSetIsCompletedInfo.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TReceiveItemSetIsCompletedInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.IsCompleted := IsCompleted;
end;

{ TReceiveItemSetIsCancelInfo }

procedure TReceiveItemSetIsCancelInfo.SetIsCancel( _IsCancel : boolean );
begin
  IsCancel := _IsCancel;
end;

procedure TReceiveItemSetIsCancelInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.IsCancel := IsCancel;
end;



{ TReceiveItemReadIsSpaceCompleted }

function TReceiveItemReadIsSpaceCompleted.get: Boolean;
begin
  Result := False;
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.CompletedSpace >= ReceiveItemInfo.ItemSize;
end;

{ TReceiveItemReadIsSendCancel }

function TReceiveItemReadIsSendCancel.get: Boolean;
begin
  Result := False;
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.IsCancel;
end;

{ TReceiveItemReadIsFile }

function TReceiveItemReadIsFile.get: Boolean;
begin
  Result := False;
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.IsFile;
end;

{ TReceiveItemReadIsZip }

function TReceiveItemReadIsZip.get: Boolean;
begin
  Result := False;
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.IsZip;
end;

{ TReceiveItemSetIsFirstReceiveInfo }

procedure TReceiveItemSetIsFirstReceiveInfo.SetIsFirstReceive(
  _IsFirstReceive: boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemSetIsFirstReceiveInfo.Update;
begin
  if not FindReceiveItemInfo then
    Exit;
  ReceiveItemInfo.IsFirstReceive := IsFirstReceive;
end;

{ TReceiveItemReadIsFirstReceive }

function TReceiveItemReadIsFirstReceive.get: Boolean;
begin
  Result := False;
  if not FindReceiveItemInfo then
    Exit;
  Result := ReceiveItemInfo.IsFirstReceive;
end;

end.
