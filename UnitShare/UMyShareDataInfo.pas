unit UMyShareDataInfo;

interface

uses Generics.Collections, UDataSetInfo, classes, UMyUtil;

type

{$Region ' ���ݽṹ ' }

  TSharePathInfo = class
  public
    FullPath : string;
    IsFile : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsFile( _IsFile : Boolean );
  end;
  TSharePathList = class( TObjectList<TSharePathInfo> )end;

  TLocalSharePathInfo = class( TSharePathInfo )
  end;

  TNetworkSharePathInfo = class( TSharePathInfo )
  end;

  TMySharePathInfo = class( TMyDataInfo )
  public
    SharePathList : TSharePathList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݷ��� ' }

    // ���� ���� List �ӿ�
  TSharePathListAccessInfo = class
  protected
    SharePathList : TSharePathList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TSharePathAccessInfo = class( TSharePathListAccessInfo )
  public
    FullPath : string;
  protected
    SharePathIndex : Integer;
    SharePathInfo : TSharePathInfo;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathInfo: Boolean;
  end;

{$EndRegion}

{$Region ' �����޸� ' }

    // �޸ĸ���
  TSharePathWriteInfo = class( TSharePathAccessInfo )
  end;

    // ���
  TSharePathAddInfo = class( TSharePathWriteInfo )
  public
    IsFile : boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure Update;
  protected
    procedure CreateInfo;virtual;abstract;
  end;

    // ��� ���ع���
  TSharePathAddLocalInfo = class( TSharePathAddInfo )
  protected
    procedure CreateInfo;override;
  end;

    // ��� ���繲��
  TSharePathAddNetworkInfo = class( TSharePathAddInfo )
  protected
    procedure CreateInfo;override;
  end;

    // ɾ��
  TSharePathRemoveInfo = class( TSharePathWriteInfo )
  public
    procedure Update;
  end;


{$EndRegion}

{$Region ' ���ݶ�ȡ ' }

    // ��ȡ ���繲����Ϣ
  TSharePathReadNetworkList = class( TSharePathListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���� ����·����Ϣ
  TSharePathReadLocalInfoList = class( TSharePathListAccessInfo )
  public
    function get : TSharePathList;
  end;

    // ��ȡ ���� ����·����Ϣ
  TSharePathReadNetworkInfoList = class( TSharePathListAccessInfo )
  public
    function get : TSharePathList;
  end;

    // ��ȡ �Ƿ���ڹ���·��
  TSharePathReadIsExist = class( TSharePathAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ���ڸ�����·��
  TSharePathReadIsExistParent = class( TSharePathListAccessInfo )
  public
    ShareChildPath : string;
  public
    procedure SetShareChildPath( _ShareChildPath : string );
    function get : Boolean;
  end;

  SharePathInfoReadUtil = class
  public
    class function ReadIsExist( SharePath : string ): Boolean;
    class function ReadIsExistParent( ShareChildPath : string ): Boolean;
  public            // ��ȡ�б�
    class function ReadLocalShareInfoList : TSharePathList;
    class function ReadNetworkShareInfoList : TSharePathList;
  public
    class function ReadNetworkShareList : TStringList; // Setting ����
  end;

{$EndRegion}


var
  MySharePathInfo : TMySharePathInfo;

implementation

{ TSharePathInfo }

constructor TSharePathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TSharePathInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

{ TMySharePathInfo }

constructor TMySharePathInfo.Create;
begin
  inherited;
  SharePathList := TSharePathList.Create;
end;

destructor TMySharePathInfo.Destroy;
begin
  SharePathList.Free;
  inherited;
end;

{ TSharePathListAccessInfo }

constructor TSharePathListAccessInfo.Create;
begin
  MySharePathInfo.EnterData;
  SharePathList := MySharePathInfo.SharePathList;
end;

destructor TSharePathListAccessInfo.Destroy;
begin
  MySharePathInfo.LeaveData;
  inherited;
end;

{ TSharePathAccessInfo }

constructor TSharePathAccessInfo.Create( _FullPath : string );
begin
  inherited Create;
  FullPath := _FullPath;
end;

function TSharePathAccessInfo.FindSharePathInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to SharePathList.Count - 1 do
    if ( SharePathList[i].FullPath = FullPath ) then
    begin
      Result := True;
      SharePathIndex := i;
      SharePathInfo := SharePathList[i];
      break;
    end;
end;

{ TSharePathAddInfo }

procedure TSharePathAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TSharePathAddInfo.Update;
begin
  if FindSharePathInfo then
    Exit;

  CreateInfo;
  SharePathInfo.SetIsFile( IsFile );
  SharePathList.Add( SharePathInfo );
end;

{ TSharePathRemoveInfo }

procedure TSharePathRemoveInfo.Update;
begin
  if not FindSharePathInfo then
    Exit;

  SharePathList.Delete( SharePathIndex );
end;




{ TSharePathReadList }

function TSharePathReadNetworkList.get: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to SharePathList.Count - 1 do
    if SharePathList[i] is TNetworkSharePathInfo then
      Result.Add( SharePathList[i].FullPath );
end;

{ SharePathInfoReadUtil }

class function SharePathInfoReadUtil.ReadIsExist(SharePath: string): Boolean;
var
  SharePathReadIsExist : TSharePathReadIsExist;
begin
  SharePathReadIsExist := TSharePathReadIsExist.Create( SharePath );
  Result := SharePathReadIsExist.get;
  SharePathReadIsExist.Free;
end;

class function SharePathInfoReadUtil.ReadIsExistParent(
  ShareChildPath: string): Boolean;
var
  SharePathReadIsExistParent : TSharePathReadIsExistParent;
begin
  SharePathReadIsExistParent := TSharePathReadIsExistParent.Create;
  SharePathReadIsExistParent.SetShareChildPath( ShareChildPath );
  Result := SharePathReadIsExistParent.get;
  SharePathReadIsExistParent.Free;
end;

class function SharePathInfoReadUtil.ReadLocalShareInfoList: TSharePathList;
var
  SharePathReadLocalInfoList : TSharePathReadLocalInfoList;
begin
  SharePathReadLocalInfoList := TSharePathReadLocalInfoList.Create;
  Result := SharePathReadLocalInfoList.get;
  SharePathReadLocalInfoList.Free;
end;

class function SharePathInfoReadUtil.ReadNetworkShareInfoList: TSharePathList;
var
  SharePathReadInfoList : TSharePathReadNetworkInfoList;
begin
  SharePathReadInfoList := TSharePathReadNetworkInfoList.Create;
  Result := SharePathReadInfoList.get;
  SharePathReadInfoList.Free;
end;

class function SharePathInfoReadUtil.ReadNetworkShareList: TStringList;
var
  SharePathReadNetworkList : TSharePathReadNetworkList;
begin
  SharePathReadNetworkList := TSharePathReadNetworkList.Create;
  Result := SharePathReadNetworkList.get;
  SharePathReadNetworkList.Free;
end;

{ TSharePathReadInfoList }

function TSharePathReadNetworkInfoList.get: TSharePathList;
var
  i: Integer;
  OldSharePathInfo, NewSharePathInfo : TSharePathInfo;
begin
  Result := TSharePathList.Create;
  for i := 0 to SharePathList.Count - 1 do
  begin
    OldSharePathInfo := SharePathList[i];
    if OldSharePathInfo is TNetworkSharePathInfo then
    begin
      NewSharePathInfo := TSharePathInfo.Create( OldSharePathInfo.FullPath );
      NewSharePathInfo.SetIsFile( OldSharePathInfo.IsFile );
      Result.Add( NewSharePathInfo );
    end;
  end;
end;

{ TSharePathAddLocalInfo }

procedure TSharePathAddLocalInfo.CreateInfo;
begin
  SharePathInfo := TLocalSharePathInfo.Create( FullPath );
end;

{ TSharePathAddNetworkInfo }

procedure TSharePathAddNetworkInfo.CreateInfo;
begin
  SharePathInfo := TNetworkSharePathInfo.Create( FullPath );
end;

{ TSharePathReadLocalInfoList }

function TSharePathReadLocalInfoList.get: TSharePathList;
var
  i: Integer;
  OldSharePathInfo, NewSharePathInfo : TSharePathInfo;
begin
  Result := TSharePathList.Create;
  for i := 0 to SharePathList.Count - 1 do
  begin
    OldSharePathInfo := SharePathList[i];
    if OldSharePathInfo is TLocalSharePathInfo then
    begin
      NewSharePathInfo := TSharePathInfo.Create( OldSharePathInfo.FullPath );
      NewSharePathInfo.SetIsFile( OldSharePathInfo.IsFile );
      Result.Add( NewSharePathInfo );
    end;
  end;
end;

{ TSharePathReadIsExist }

function TSharePathReadIsExist.get: Boolean;
begin
  Result := FindSharePathInfo;
end;

{ TSharePathReadIsExistParent }

function TSharePathReadIsExistParent.get: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to SharePathList.Count - 1 do
    if MyMatchMask.CheckEqualsOrChild( ShareChildPath, SharePathList[i].FullPath ) then
    begin
      Result := True;
      Break;
    end;
end;

procedure TSharePathReadIsExistParent.SetShareChildPath(
  _ShareChildPath: string);
begin
  ShareChildPath := _ShareChildPath;
end;

end.
