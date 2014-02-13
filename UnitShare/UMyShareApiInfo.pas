unit UMyShareApiInfo;

interface

uses Sockets, SysUtils;

type

{$Region ' 我的共享 数据修改 ' }

    // 修改
  TSharePathWriteHandle = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 读取 父类
  TSharePathReadHandle = class( TSharePathWriteHandle )
  public
    IsFile : boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
  end;

    // 读取 本地共享
  TSharePathReadLocalHandle = class( TSharePathReadHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 本地共享
  TSharePathAddLocalHandle = class( TSharePathReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 读取 网络共享
  TSharePathReadNetworkHandle = class( TSharePathReadHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络共享
  TSharePathAddNetworkHandle = class( TSharePathReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TSharePathRemoveHandle = class( TSharePathWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  protected
    procedure RemoveFromFace;virtual;abstract;
    procedure RemoveFromEvent;virtual;abstract;
  end;

    // 删除 本地
  TSharePathRemoveLocalHandle = class( TSharePathRemoveHandle )
  protected
    procedure RemoveFromFace;override;
    procedure RemoveFromEvent;override;
  end;

    // 删除 网络
  TSharePathRemoveNetworkHandle = class( TSharePathRemoveHandle )
  protected
    procedure RemoveFromFace;override;
    procedure RemoveFromEvent;override;
  end;

    // 刷新 本地共享
  TRefreshLocalShareShowHandle = class
  public
    procedure Update;
  end;

    // Pc 上线 发送共享列表
  TOnlineSendShareListHandle = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  end;

{$EndRegion}

{$Region ' 网络共享 数据修改 ' }

  {$Region ' 共享根信息 ' }

    // 修改
  TShareShowRootItemWriteHandle = class
  public
    RootItemID : string;
  public
    constructor Create( _RootItemID : string );
  end;

    // 添加
  TShareShowRootItemAddHandle = class( TShareShowRootItemWriteHandle )
  public
    procedure Update;
  protected
    procedure AddToFace;virtual;abstract;
  end;

    // 添加 本地
  TShareShowRootItemAddLocalHandle = class( TShareShowRootItemAddHandle )
  protected
    procedure AddToFace;override;
  end;


    // 添加 网络
  TShareShowRootItemAddNetworkHandle = class( TShareShowRootItemAddHandle )
  protected
    procedure AddToFace;override;
  end;

    // 删除
  TShareShowRootItemRemoveHandle = class( TShareShowRootItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

  {$EndRegion}

  {$Region ' 共享路径信息 ' }

      // 修改
  TShareShowItemWriteHandle = class( TShareShowRootItemWriteHandle )
  public
    SharePath : string;
  public
    procedure SetSharePath( _SharePath : string );
  end;

    // 添加
  TShareShowItemAddHandle = class( TShareShowItemWriteHandle )
  public
    IsFile : boolean;
    IsNewShare : Boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetIsNewShare( _IsNewShare : Boolean );
    procedure Update;
  private
    procedure AddToFace;
    procedure AddToNotify;
  end;


    // 删除
  TShareShowItemRemoveHandle = class( TShareShowItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;


  {$EndRegion}

{$EndRegion}

    // 我的共享
  MySharePathApi = class
  public
    class procedure AddNetworkItem( FullPath : string; IsFile : Boolean );
    class procedure RemoveNetworkItem( FullPath : string );
  public
    class procedure AddLocalItem( FullPath : string; IsFile : Boolean );
    class procedure RemoveLocalItem( FullPath : string );
  public
    class procedure RefreshLocalShareList;
    class procedure OnlineSendShareList( OnlinePcID : string );
  public
    class procedure AddShareDownBackConn( DownPcID : string );
  end;

    // 网络共享根路径
  MyShareShowRootItemApi = class
  public
    class procedure AddLocalItem( RootItemID : string );
    class procedure AddNetworkItem( RootItemID : string );
    class procedure RemoveItem( RootItemID : string );
  public
    class procedure CheckExistShare;
  end;

    // 网络共享路径
  MyShareShowItemApi = class
  public
    class procedure AddItem( RootItemID, SharePath : string; IsFile, IsNewShare : Boolean );
    class procedure RemoveItem( RootItemID, SharePath : string );
  end;

const
  ShareConnResult_OK = 'OK';
  ShareConnResult_NotExist = 'NotExit';


const
  ShareShowRootID_MyComputer = 'My Computer';
  ShareShowRootName_MyComputer = 'My Computer';

implementation

uses UMyShareDataInfo, UMyShareXmlInfo,UMyShareFaceInfo, UMyNetPcInfo, UMyShareEventInfo, UMyTcp,
     UShareThread, UMainApi;

constructor TSharePathWriteHandle.Create( _FullPath : string );
begin
  FullPath := _FullPath;
end;

{ TSharePathReadHandle }

procedure TSharePathReadNetworkHandle.AddToInfo;
var
  SharePathAddNetworkInfo : TSharePathAddNetworkInfo;
begin
  SharePathAddNetworkInfo := TSharePathAddNetworkInfo.Create( FullPath );
  SharePathAddNetworkInfo.SetIsFile( IsFile );
  SharePathAddNetworkInfo.Update;
  SharePathAddNetworkInfo.Free;
end;

procedure TSharePathReadNetworkHandle.AddToFace;
var
  SharePathAddFace : TSharePathAddFace;
begin
  SharePathAddFace := TSharePathAddFace.Create( FullPath );
  SharePathAddFace.SetIsFile( IsFile );
  SharePathAddFace.AddChange;
end;

procedure TSharePathReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TSharePathAddHandle }

procedure TSharePathAddNetworkHandle.AddToEvent;
begin
  MySharePathEvent.AddItem( FullPath, IsFile );
end;

procedure TSharePathAddNetworkHandle.AddToXml;
var
  SharePathAddNetworkXml : TSharePathAddNetworkXml;
begin
  SharePathAddNetworkXml := TSharePathAddNetworkXml.Create( FullPath );
  SharePathAddNetworkXml.SetIsFile( IsFile );
  SharePathAddNetworkXml.AddChange;
end;

procedure TSharePathAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TSharePathReadHandle }

procedure TSharePathReadHandle.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

{ TSharePathRemoveHandle }

procedure TSharePathRemoveHandle.RemoveFromInfo;
var
  SharePathRemoveInfo : TSharePathRemoveInfo;
begin
  SharePathRemoveInfo := TSharePathRemoveInfo.Create( FullPath );
  SharePathRemoveInfo.Update;
  SharePathRemoveInfo.Free;
end;

procedure TSharePathRemoveHandle.RemoveFromXml;
var
  SharePathRemoveXml : TSharePathRemoveXml;
begin
  SharePathRemoveXml := TSharePathRemoveXml.Create( FullPath );
  SharePathRemoveXml.AddChange;
end;

procedure TSharePathRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
  RemoveFromEvent;
end;


{ MySharePathApi }

class procedure MySharePathApi.AddLocalItem(FullPath: string; IsFile: Boolean);
var
  SharePathAddLocalHandle : TSharePathAddLocalHandle;
begin
  SharePathAddLocalHandle := TSharePathAddLocalHandle.Create( FullPath );
  SharePathAddLocalHandle.SetIsFile( IsFile );
  SharePathAddLocalHandle.Update;
  SharePathAddLocalHandle.Free;
end;

class procedure MySharePathApi.AddNetworkItem(FullPath: string; IsFile: Boolean);
var
  SharePathAddNetworkHandle : TSharePathAddNetworkHandle;
begin
  SharePathAddNetworkHandle := TSharePathAddNetworkHandle.Create( FullPath );
  SharePathAddNetworkHandle.SetIsFile( IsFile );
  SharePathAddNetworkHandle.Update;
  SharePathAddNetworkHandle.Free;
end;


class procedure MySharePathApi.AddShareDownBackConn(DownPcID: string);
begin
  MyShareFileHandler.ReceiveBackConn( DownPcID );
end;

class procedure MySharePathApi.OnlineSendShareList(OnlinePcID: string);
var
  OnlineSendShareListHandle : TOnlineSendShareListHandle;
begin
  OnlineSendShareListHandle := TOnlineSendShareListHandle.Create( OnlinePcID );
  OnlineSendShareListHandle.Update;
  OnlineSendShareListHandle.Free;
end;

class procedure MySharePathApi.RefreshLocalShareList;
var
  RefreshLocalShareShowHandle : TRefreshLocalShareShowHandle;
begin
  RefreshLocalShareShowHandle := TRefreshLocalShareShowHandle.Create;
  RefreshLocalShareShowHandle.Update;
  RefreshLocalShareShowHandle.Free;
end;

class procedure MySharePathApi.RemoveLocalItem(FullPath: string);
var
  SharePathRemoveLocalHandle : TSharePathRemoveLocalHandle;
begin
  SharePathRemoveLocalHandle := TSharePathRemoveLocalHandle.Create( FullPath );
  SharePathRemoveLocalHandle.Update;
  SharePathRemoveLocalHandle.Free;
end;


class procedure MySharePathApi.RemoveNetworkItem(FullPath: string);
var
  SharePathRemoveNetworkHandle : TSharePathRemoveNetworkHandle;
begin
  SharePathRemoveNetworkHandle := TSharePathRemoveNetworkHandle.Create( FullPath );
  SharePathRemoveNetworkHandle.Update;
  SharePathRemoveNetworkHandle.Free;
end;

constructor TShareShowRootItemWriteHandle.Create( _RootItemID : string );
begin
  RootItemID := _RootItemID;
end;

{ TShareShowRootItemReadHandle }

procedure TShareShowRootItemAddHandle.Update;
begin
  AddToFace;
end;


{ TShareShowRootItemRemoveHandle }

procedure TShareShowRootItemRemoveHandle.RemoveFromFace;
var
  ShareShowRootItemRemoveFace : TShareShowRootItemRemoveFace;
begin
  ShareShowRootItemRemoveFace := TShareShowRootItemRemoveFace.Create( RootItemID );
  ShareShowRootItemRemoveFace.AddChange;
end;

procedure TShareShowRootItemRemoveHandle.Update;
begin
  RemoveFromFace;
end;

procedure TShareShowItemWriteHandle.SetSharePath( _SharePath : string );
begin
  SharePath := _SharePath;
end;

{ TShareShowItemReadHandle }

procedure TShareShowItemAddHandle.AddToNotify;
begin
  if IsNewShare then
    MainFormApi.ShowNewShare;
end;

procedure TShareShowItemAddHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TShareShowItemAddHandle.SetIsNewShare(_IsNewShare: Boolean);
begin
  IsNewShare := _IsNewShare;
end;

procedure TShareShowItemAddHandle.AddToFace;
var
  ShareShowItemAddFace : TShareShowItemAddFace;
begin
  ShareShowItemAddFace := TShareShowItemAddFace.Create( RootItemID );
  ShareShowItemAddFace.SetSharePath( SharePath );
  ShareShowItemAddFace.SetIsFile( IsFile );
  ShareShowItemAddFace.SetIsNewShare( IsNewShare );
  ShareShowItemAddFace.AddChange;
end;

procedure TShareShowItemAddHandle.Update;
begin
  AddToFace;

  AddToNotify;
end;

{ TShareShowItemRemoveHandle }


procedure TShareShowItemRemoveHandle.RemoveFromFace;
var
  ShareShowItemRemoveFace : TShareShowItemRemoveFace;
begin
  ShareShowItemRemoveFace := TShareShowItemRemoveFace.Create( RootItemID );
  ShareShowItemRemoveFace.SetSharePath( SharePath );
  ShareShowItemRemoveFace.AddChange;
end;

procedure TShareShowItemRemoveHandle.Update;
begin
  RemoveFromFace;
end;

{ MySharePcShowApi }

class procedure MyShareShowRootItemApi.AddLocalItem(RootItemID: string);
var
  ShareShowRootItemAddLocalHandle : TShareShowRootItemAddLocalHandle;
begin
  ShareShowRootItemAddLocalHandle := TShareShowRootItemAddLocalHandle.Create( RootItemID );
  ShareShowRootItemAddLocalHandle.Update;
  ShareShowRootItemAddLocalHandle.Free;
end;

class procedure MyShareShowRootItemApi.AddNetworkItem(RootItemID: string);
var
  ShareShowRootItemAddNetworkHandle : TShareShowRootItemAddNetworkHandle;
begin
  ShareShowRootItemAddNetworkHandle := TShareShowRootItemAddNetworkHandle.Create( RootItemID );
  ShareShowRootItemAddNetworkHandle.Update;
  ShareShowRootItemAddNetworkHandle.Free;
end;


class procedure MyShareShowRootItemApi.CheckExistShare;
var
  ShareShowCheckExistFace : TShareShowCheckExistFace;
begin
  ShareShowCheckExistFace := TShareShowCheckExistFace.Create;
  ShareShowCheckExistFace.AddChange;
end;

class procedure MyShareShowRootItemApi.RemoveItem(RootItemID: string);
var
  ShareShowRootItemRemoveHandle : TShareShowRootItemRemoveHandle;
begin
  ShareShowRootItemRemoveHandle := TShareShowRootItemRemoveHandle.Create( RootItemID );
  ShareShowRootItemRemoveHandle.Update;
  ShareShowRootItemRemoveHandle.Free;
end;


{ MyShareShowItemApi }

class procedure MyShareShowItemApi.AddItem(RootItemID, SharePath: string;
  IsFile, IsNewShare: Boolean);
var
  ShareShowItemAddHandle : TShareShowItemAddHandle;
begin
  ShareShowItemAddHandle := TShareShowItemAddHandle.Create( RootItemID );
  ShareShowItemAddHandle.SetSharePath( SharePath );
  ShareShowItemAddHandle.SetIsFile( IsFile );
  ShareShowItemAddHandle.SetIsNewShare( IsNewShare );
  ShareShowItemAddHandle.Update;
  ShareShowItemAddHandle.Free;
end;



class procedure MyShareShowItemApi.RemoveItem(RootItemID, SharePath: string);
var
  ShareShowItemRemoveHandle : TShareShowItemRemoveHandle;
begin
  ShareShowItemRemoveHandle := TShareShowItemRemoveHandle.Create( RootItemID );
  ShareShowItemRemoveHandle.SetSharePath( SharePath );
  ShareShowItemRemoveHandle.Update;
  ShareShowItemRemoveHandle.Free;
end;



{ TOnlineSendShareListHandle }

constructor TOnlineSendShareListHandle.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TOnlineSendShareListHandle.Update;
var
  SharePathList : TSharePathList;
  i: Integer;
  SharePathInfo : TSharePathInfo;
begin
  SharePathList := SharePathInfoReadUtil.ReadNetworkShareInfoList;
  for i := 0 to SharePathList.Count - 1 do
  begin
    SharePathInfo := SharePathList[i];
    MySharePathEvent.OnlineSendItem( OnlinePcID, SharePathInfo.FullPath, SharePathInfo.IsFile );
  end;
  SharePathList.Free;
end;

{ TSharePathReadLocalHandle }

procedure TSharePathReadLocalHandle.AddToFace;
var
  LocalSharePathAddFace : TLocalSharePathAddFace;
begin
  LocalSharePathAddFace := TLocalSharePathAddFace.Create( FullPath );
  LocalSharePathAddFace.SetIsFile( IsFile );
  LocalSharePathAddFace.AddChange;
end;

procedure TSharePathReadLocalHandle.AddToInfo;
var
  SharePathAddLocalInfo : TSharePathAddLocalInfo;
begin
  SharePathAddLocalInfo := TSharePathAddLocalInfo.Create( FullPath );
  SharePathAddLocalInfo.SetIsFile( IsFile );
  SharePathAddLocalInfo.Update;
  SharePathAddLocalInfo.Free;
end;


procedure TSharePathReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TSharePathAddLocalHandle }

procedure TSharePathAddLocalHandle.AddToEvent;
begin
  MyShareShowItemApi.AddItem( ShareShowRootID_MyComputer, FullPath, IsFile, False );
end;

procedure TSharePathAddLocalHandle.AddToXml;
var
  SharePathAddLocalXml : TSharePathAddLocalXml;
begin
  SharePathAddLocalXml := TSharePathAddLocalXml.Create( FullPath );
  SharePathAddLocalXml.SetIsFile( IsFile );
  SharePathAddLocalXml.AddChange;
end;

procedure TSharePathAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TSharePathRemoveNetworkHandle }

procedure TSharePathRemoveNetworkHandle.RemoveFromEvent;
begin
  MySharePathEvent.RemoveItem( FullPath );
end;

procedure TSharePathRemoveNetworkHandle.RemoveFromFace;
var
  SharePathRemoveFace : TSharePathRemoveFace;
begin
  SharePathRemoveFace := TSharePathRemoveFace.Create( FullPath );
  SharePathRemoveFace.AddChange;
end;


{ TSharePathRemoveLocalHandle }

procedure TSharePathRemoveLocalHandle.RemoveFromEvent;
begin
  MyShareShowItemApi.RemoveItem( ShareShowRootID_MyComputer, FullPath );
end;

procedure TSharePathRemoveLocalHandle.RemoveFromFace;
var
  LocalSharePathRemoveFace : TLocalSharePathRemoveFace;
begin
  LocalSharePathRemoveFace := TLocalSharePathRemoveFace.Create( FullPath );
  LocalSharePathRemoveFace.AddChange;
end;


{ TShareShowRootItemAddLocalHandle }

procedure TShareShowRootItemAddLocalHandle.AddToFace;
var
  ShareShowRootItemAddLocalFace : TShareShowRootItemAddLocalFace;
begin
  ShareShowRootItemAddLocalFace := TShareShowRootItemAddLocalFace.Create( RootItemID );
  ShareShowRootItemAddLocalFace.SetShowName( ShareShowRootName_MyComputer );
  ShareShowRootItemAddLocalFace.AddChange;
end;

{ TShareShowRootItemAddNetworkHandle }

procedure TShareShowRootItemAddNetworkHandle.AddToFace;
var
  PcName : string;
  IsLan : Boolean;
  ShareShowRootItemAddNetworkFace : TShareShowRootItemAddNetworkFace;
begin
  PcName := MyNetPcInfoReadUtil.ReadName( RootItemID );
  IsLan := MyNetPcInfoReadUtil.ReadIsLanPc( RootItemID );

  ShareShowRootItemAddNetworkFace := TShareShowRootItemAddNetworkFace.Create( RootItemID );
  ShareShowRootItemAddNetworkFace.SetShowName( PcName );
  ShareShowRootItemAddNetworkFace.SetIsLan( IsLan );
  ShareShowRootItemAddNetworkFace.AddChange;
end;


{ TRefreshLocalShareShowHandle }

procedure TRefreshLocalShareShowHandle.Update;
var
  SharePathList : TSharePathList;
  i: Integer;
  SharePathInfo : TSharePathInfo;
begin
  SharePathList := SharePathInfoReadUtil.ReadLocalShareInfoList;
  for i := 0 to SharePathList.Count - 1 do
  begin
    SharePathInfo := SharePathList[i];
    MyShareShowItemApi.AddItem( ShareShowRootID_MyComputer, SharePathInfo.FullPath, SharePathInfo.IsFile, False );
  end;
  SharePathList.Free;
end;

end.
