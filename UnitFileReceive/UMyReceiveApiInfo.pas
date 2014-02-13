unit UMyReceiveApiInfo;

interface

uses SysUtils, classes, UMyUtil, sockets;

type

{$Region ' 接收路径 增删 ' }

      // 修改
  TReceiveRootItemWriteHandle = class
  public
    RootPath : string;
  public
    constructor Create( _RootPath : string );
  end;

    // 读取
  TReceiveRootItemReadHandle = class( TReceiveRootItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TReceiveRootItemAddHandle = class( TReceiveRootItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TReceiveRootItemHandle = class( TReceiveRootItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
    procedure RemoveFromEvent;
  end;

{$EndRegion}

{$Region ' 接收路径 状态信息 ' }

    // 修改
  TReceiveRootItemSetAvailableSpaceHandle = class( TReceiveRootItemWriteHandle )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TReceiveRootItemSetIsExistHandle = class( TReceiveRootItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;


    // 修改
  TReceiveRootItemSetIsWriteHandle = class( TReceiveRootItemWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 发送路径 增删 ' }

    // 修改
  TReceiveItemWriteHandle = class( TReceiveRootItemWriteHandle )
  public
    SourcePath, OwnerID : string;
  public
    procedure SetSourceInfo( _SourcePath, _OwnerID : string );
  end;

    // 读取
  TReceiveItemReadHandle = class( TReceiveItemWriteHandle )
  public
    IsFile : boolean;
    IsCompleted, IsCancel, IsZip : Boolean;
    IsFirstReceive : Boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSapce : int64;
  public
    IsNewReceive : Boolean;
    ReceiveTime : TDateTime;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetStatusInfo( _IsCompleted, _IsCancel : boolean );
    procedure SetIsFirstReceive( _IsFirstReceive : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSapce : int64 );
    procedure SetIsNewReceive( _IsNewReceive : Boolean );
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetSavePath( _SavePath : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TReceiveItemAddHandle = class( TReceiveItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToNewCount;
  end;

    // 删除
  TReceiveItemRemoveHandle = class( TReceiveItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromEvent;
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;


{$EndRegion}

{$Region ' 发送路径 空间信息 ' }

    // 修改
  TReceiveItemSetSpaceInfoHandle = class( TReceiveItemWriteHandle )
  public
    FileCount : integer;
    ItemSize, CompletedSpace : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TReceiveItemSetAddCompletedSpaceHandle = class( TReceiveItemWriteHandle )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;


{$EndRegion}

{$Region ' 发送路径 状态信息 ' }

    // 修改
  TReceiveItemSetIsReceivingHandle = class( TReceiveItemWriteHandle )
  public
    IsReceiving : boolean;
  public
    procedure SetIsReceiving( _IsReceiving : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

    // 修改
  TReceiveItemSetIsCompletedHandle = class( TReceiveItemWriteHandle )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TReceiveItemSetIsCancelHandle = class( TReceiveItemWriteHandle )
  public
    IsCancel : boolean;
  public
    procedure SetIsCancel( _IsCancel : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

      // 修改
  TReceiveItemSetSpeedHandle = class( TReceiveItemWriteHandle )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TReceiveItemSetStatusHandle = class( TReceiveItemWriteHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
     procedure SetToFace;
  end;


    // 开始接收
  TReceiveItemSetStartReceiveHandle = class( TReceiveItemWriteHandle )
  public
    procedure Update;
  private
    procedure AddToHint;
  end;

    // 接收完成
  TReceiveItemSetReceiveCompletedHandle = class( TReceiveItemWriteHandle )
  public
    procedure Update;
  private
    procedure RefreashIcon;
    procedure AddToHint;
  end;

    // 接收完成时间
  TReceiveItemSetReceiveTimeHandle = class( TReceiveItemWriteHandle )
  public
    ReceiveTime : TDateTime;
  public
    procedure SetReceiveTime( _ReceiveTime : TDateTime );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 接收完成时间
  TReceiveItemSetIsFirstReceiveHandle = class( TReceiveItemWriteHandle )
  public
    IsFirstReceive : Boolean;
  public
    procedure SetIsFirstReceive( _IsFirstReceive : boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

    // Pc 上/下线
  TReceiveItemSetPcIsOnlineHandle = class
  public
    OnlinePcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _OnlinePcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 其他操作 ' }

    // 通知上线Pc接收路径
  TOnlineSendReceiveListHanlde = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  end;

    // 添加
  TReceiveRootNewCountAddHandle = class
  public
    procedure Update;
  private
    procedure AddToFace;
    procedure AddToXml;
  end;

    // 清空
  TReceiveRootNewCountClearHandle = class
  public
    procedure Update;
  private
    procedure ClearToFace;
    procedure ClearToXml;
  end;

    // 读取
  TReceiveRootReadNewCountHandle = class
  private
    NewCount : Integer;
  public
    constructor Create( _NewCount : Integer );
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}


    // 共享路径
  ReceiveRootItemUserApi = class
  public               // 路径增删
    class procedure AddItem( RootPath : string );
    class procedure RemoveItem( RootPath : string );
  public              // pc 上线
    class procedure OnlineSendRootList( OnlinePcID : string );
  public              // 新接收的信息
    class procedure AddNewCount;
    class procedure ClearNewCount;
  end;

    // 接收路径
  ReceiveRootItemAppApi = class
  public
    class procedure SetAvailableSpace( RootPath : string; AvailableSpace : Int64 );
    class procedure SetIsExist( RootPath : string; IsExist : Boolean );
    class procedure SetIsWrite( RootPath : string; IsWrite : Boolean );
  end;

    // 添加参数
  TReceiveItemAddParams = record
  public
    RootPath, SourcePath, OwnerID : string;
    IsFile, IsZip : Boolean;
  end;

    // 设置空间参数
  TReceiveItemSetSpaceParams = record
  public
    RootPath, SourcePath, OwnerID : string;
    FileCount : Integer;
    FileSize, CompletedSpace : Int64;
  end;

    // 接收路径
  ReceiveItemAppApi = class
  public              // 增删
    class procedure AddItem( Params : TReceiveItemAddParams );
    class procedure RemoveItem( RootPath, OwnerID, SourcePath : string );
  public              // 设置空间信息
    class procedure SetWaitingReceive( RootPath, OwnerID, SourcePath : string );
    class procedure SetStartReceive( RootPath, OwnerID, SourcePath : string );
    class procedure SetSpaceInfo( Params : TReceiveItemSetSpaceParams );
    class procedure AddCompletedSpace( RootPath, OwnerID, SourcePath : string; AddCompletedSpace : Int64 );
    class procedure SetStopReceive( RootPath, OwnerID, SourcePath : string );
    class procedure SetCompletedReceive( RootPath, OwnerID, SourcePath : string );
    class procedure ShowRecieveHint( RootPath, OwnerID, SourcePath : string );
  public              // 设置状态
    class procedure SetIsReceiving( RootPath, OwnerID, SourcePath : string; IsReceiving : Boolean );
    class procedure SetIsCompleted( RootPath, OwnerID, SourcePath : string; IsCompleted : Boolean );
    class procedure SetIsCancel( RootPath, OwnerID, SourcePath : string; IsCancel : Boolean );
    class procedure SetSpeedInfo( RootPath, OwnerID, SourcePath : string; Speed : Integer );
    class procedure SetReceiveStatus( RootPath, OwnerID, SourcePath, Status : string );
    class procedure SetReceiveTime( RootPath, OwnerID, SourcePath : string; ReceiveTime : TDateTime );
    class procedure SetIsFirstReceive( RootPath, OwnerID, SourcePath : string; IsFirstReceive : Boolean );
  public              // Pc 上/下线
    class procedure SetPcIsOnline( OnlinePcID : string; IsOnline : Boolean );
    class procedure AddBackConn( SendPcID : string );
  end;

const
  ReceiveConnResult_OK = 'OK';
  ReceiveConnResult_NotExist = 'NotExit';
  ReceiveConnResult_Cancel = 'Cancel';
  ReceiveConnResult_CannotWrite = 'CannotWrite';

var
  TransferPage_IsShowReceive : Boolean = False;

implementation

uses UMyReceiveDataInfo, UMyReceiveXmlInfo, UMyReceiveEventInfo, UMyNetPcInfo,
     UMyReceiveFaceInfo, UMyTcp, UReceiveThread, UMainApi;


constructor TReceiveRootItemWriteHandle.Create( _RootPath : string );
begin
  RootPath := _RootPath;
end;


{ TCloudPathReadHandle }

procedure TReceiveRootItemReadHandle.AddToInfo;
var
  CloudPathAddInfo : TReceiveRootItemAddInfo;
begin
  CloudPathAddInfo := TReceiveRootItemAddInfo.Create( RootPath );
  CloudPathAddInfo.Update;
  CloudPathAddInfo.Free;
end;

procedure TReceiveRootItemReadHandle.AddToFace;
var
  AvailablseSpace : Int64;
  CloudPathAddFace : TReceiveRootItemAddFace;
begin
  AvailablseSpace := MyHardDisk.getHardDiskFreeSize( RootPath );

  CloudPathAddFace := TReceiveRootItemAddFace.Create( RootPath );
  CloudPathAddFace.SetAvailableSpace( AvailablseSpace );
  CloudPathAddFace.AddChange;
end;

procedure TReceiveRootItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TCloudPathAddHandle }

procedure TReceiveRootItemAddHandle.AddToEvent;
begin
  ReceiveRootEvent.AddItem( RootPath );
end;

procedure TReceiveRootItemAddHandle.AddToXml;
var
  CloudPathAddXml : TReceiveRootItemAddXml;
begin
  CloudPathAddXml := TReceiveRootItemAddXml.Create( RootPath );
  CloudPathAddXml.AddChange;
end;

procedure TReceiveRootItemAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TCloudPathRemoveHandle }

procedure TReceiveRootItemHandle.RemoveFromInfo;
var
  CloudPathRemoveInfo : TReceiveRootItemRemoveInfo;
begin
  CloudPathRemoveInfo := TReceiveRootItemRemoveInfo.Create( RootPath );
  CloudPathRemoveInfo.Update;
  CloudPathRemoveInfo.Free;
end;

procedure TReceiveRootItemHandle.RemoveFromEvent;
begin
  ReceiveRootEvent.RemoveItem( RootPath );
end;

procedure TReceiveRootItemHandle.RemoveFromFace;
var
  CloudPathRemoveFace : TReceiveRootItemRemoveFace;
begin
  CloudPathRemoveFace := TReceiveRootItemRemoveFace.Create( RootPath );
  CloudPathRemoveFace.AddChange;
end;

procedure TReceiveRootItemHandle.RemoveFromXml;
var
  CloudPathRemoveXml : TReceiveRootItemRemoveXml;
begin
  CloudPathRemoveXml := TReceiveRootItemRemoveXml.Create( RootPath );
  CloudPathRemoveXml.AddChange;
end;

procedure TReceiveRootItemHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
  RemoveFromEvent;
end;




{ MyCloudShareUserApi }

class procedure ReceiveRootItemUserApi.AddItem(RootPath: string);
var
  ReceiveRootItemAddHandle : TReceiveRootItemAddHandle;
begin
  ReceiveRootItemAddHandle := TReceiveRootItemAddHandle.Create( RootPath );
  ReceiveRootItemAddHandle.Update;
  ReceiveRootItemAddHandle.Free;
end;

class procedure ReceiveRootItemUserApi.AddNewCount;
var
  ReceiveRootNewCountAddHandle : TReceiveRootNewCountAddHandle;
begin
  if TransferPage_IsShowReceive then
    Exit;

  ReceiveRootNewCountAddHandle := TReceiveRootNewCountAddHandle.Create;
  ReceiveRootNewCountAddHandle.Update;
  ReceiveRootNewCountAddHandle.Free;
end;

class procedure ReceiveRootItemUserApi.ClearNewCount;
var
  ReceiveRootNewCountClearHandle : TReceiveRootNewCountClearHandle;
begin
  ReceiveRootNewCountClearHandle := TReceiveRootNewCountClearHandle.Create;
  ReceiveRootNewCountClearHandle.Update;
  ReceiveRootNewCountClearHandle.Free;
end;

class procedure ReceiveRootItemUserApi.OnlineSendRootList(OnlinePcID: string);
var
  OnlineSendReceiveListHanlde : TOnlineSendReceiveListHanlde;
begin
  OnlineSendReceiveListHanlde := TOnlineSendReceiveListHanlde.Create( OnlinePcID );
  OnlineSendReceiveListHanlde.Update;
  OnlineSendReceiveListHanlde.Free;
end;

class procedure ReceiveRootItemUserApi.RemoveItem(RootPath: string);
var
  ReceiveRootItemHandle : TReceiveRootItemHandle;
begin
  ReceiveRootItemHandle := TReceiveRootItemHandle.Create( RootPath );
  ReceiveRootItemHandle.Update;
  ReceiveRootItemHandle.Free;
end;

{ MyCloudPcBackupAppApi }

class procedure ReceiveItemAppApi.AddBackConn(SendPcID: string);
begin
  MyReceiveFileHandler.ReceiveBackConn( SendPcID );
end;

class procedure ReceiveItemAppApi.AddCompletedSpace(RootPath, OwnerID,
  SourcePath: string; AddCompletedSpace: Int64);
var
  ReceiveItemSetAddCompletedSpaceHandle : TReceiveItemSetAddCompletedSpaceHandle;
begin
  ReceiveItemSetAddCompletedSpaceHandle := TReceiveItemSetAddCompletedSpaceHandle.Create( RootPath );
  ReceiveItemSetAddCompletedSpaceHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetAddCompletedSpaceHandle.SetAddCompletedSpace( AddCompletedSpace );
  ReceiveItemSetAddCompletedSpaceHandle.Update;
  ReceiveItemSetAddCompletedSpaceHandle.Free;
end;



class procedure ReceiveItemAppApi.AddItem(Params: TReceiveItemAddParams);
var
  SavePath : string;
  ReceiveItemAddHandle : TReceiveItemAddHandle;
begin
  SavePath := MyFilePath.getPath( Params.RootPath ) + ExtractFileName( Params.SourcePath );
  SavePath := MyFilePath.getNowExistPath( SavePath, Params.IsFile );

    // 添加 路径 Item
  ReceiveItemAddHandle := TReceiveItemAddHandle.Create( Params.RootPath );
  ReceiveItemAddHandle.SetSourceInfo( Params.SourcePath, Params.OwnerID );
  ReceiveItemAddHandle.SetIsFile( Params.IsFile );
  ReceiveItemAddHandle.SetStatusInfo( False, False );
  ReceiveItemAddHandle.SetIsZip( Params.IsZip );
  ReceiveItemAddHandle.SetSpaceInfo( -1, 0, 0 );
  ReceiveItemAddHandle.SetIsNewReceive( True );
  ReceiveItemAddHandle.SetReceiveTime( 0 );
  ReceiveItemAddHandle.SetIsFirstReceive( True );
  ReceiveItemAddHandle.SetSavePath( SavePath );
  ReceiveItemAddHandle.Update;
  ReceiveItemAddHandle.Free;
end;

class procedure ReceiveItemAppApi.RemoveItem(RootPath, OwnerID,
  SourcePath: string);
var
  CloudPcBackupPathRemoveHandle : TReceiveItemRemoveHandle;
begin
  CloudPcBackupPathRemoveHandle := TReceiveItemRemoveHandle.Create( RootPath );
  CloudPcBackupPathRemoveHandle.SetSourceInfo( SourcePath, OwnerID );
  CloudPcBackupPathRemoveHandle.Update;
  CloudPcBackupPathRemoveHandle.Free;
end;


class procedure ReceiveItemAppApi.SetCompletedReceive(RootPath, OwnerID,
  SourcePath: string);
var
  ReceiveItemSetReceiveCompletedHandle : TReceiveItemSetReceiveCompletedHandle;
begin
  ReceiveItemSetReceiveCompletedHandle := TReceiveItemSetReceiveCompletedHandle.Create( RootPath );
  ReceiveItemSetReceiveCompletedHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetReceiveCompletedHandle.Update;
  ReceiveItemSetReceiveCompletedHandle.Free;
end;

class procedure ReceiveItemAppApi.SetIsCancel(RootPath, OwnerID,
  SourcePath: string; IsCancel: Boolean);
var
  ReceiveItemSetIsCancelHandle : TReceiveItemSetIsCancelHandle;
begin
  ReceiveItemSetIsCancelHandle := TReceiveItemSetIsCancelHandle.Create( RootPath );
  ReceiveItemSetIsCancelHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCancelHandle.SetIsCancel( IsCancel );
  ReceiveItemSetIsCancelHandle.Update;
  ReceiveItemSetIsCancelHandle.Free;
end;


class procedure ReceiveItemAppApi.SetIsCompleted(RootPath, OwnerID,
  SourcePath: string; IsCompleted: Boolean);
var
  ReceiveItemSetIsCompletedHandle : TReceiveItemSetIsCompletedHandle;
begin
  ReceiveItemSetIsCompletedHandle := TReceiveItemSetIsCompletedHandle.Create( RootPath );
  ReceiveItemSetIsCompletedHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCompletedHandle.SetIsCompleted( IsCompleted );
  ReceiveItemSetIsCompletedHandle.Update;
  ReceiveItemSetIsCompletedHandle.Free;
end;


class procedure ReceiveItemAppApi.SetIsFirstReceive(RootPath, OwnerID,
  SourcePath: string; IsFirstReceive: Boolean);
var
  ReceiveItemSetIsFirstReceiveHandle : TReceiveItemSetIsFirstReceiveHandle;
begin
  ReceiveItemSetIsFirstReceiveHandle := TReceiveItemSetIsFirstReceiveHandle.Create( RootPath );
  ReceiveItemSetIsFirstReceiveHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsFirstReceiveHandle.SetIsFirstReceive( IsFirstReceive );
  ReceiveItemSetIsFirstReceiveHandle.Update;
  ReceiveItemSetIsFirstReceiveHandle.Free;
end;

class procedure ReceiveItemAppApi.SetIsReceiving(RootPath, OwnerID,
  SourcePath: string; IsReceiving: Boolean);
var
  ReceiveItemSetIsReceivingHandle : TReceiveItemSetIsReceivingHandle;
begin
  ReceiveItemSetIsReceivingHandle := TReceiveItemSetIsReceivingHandle.Create( RootPath );
  ReceiveItemSetIsReceivingHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsReceivingHandle.SetIsReceiving( IsReceiving );
  ReceiveItemSetIsReceivingHandle.Update;
  ReceiveItemSetIsReceivingHandle.Free;
end;



class procedure ReceiveItemAppApi.SetPcIsOnline(OnlinePcID: string;
  IsOnline: Boolean);
var
  ReceiveItemSetPcIsOnlineHandle : TReceiveItemSetPcIsOnlineHandle;
begin
  ReceiveItemSetPcIsOnlineHandle := TReceiveItemSetPcIsOnlineHandle.Create( OnlinePcID );
  ReceiveItemSetPcIsOnlineHandle.SetIsOnline( IsOnline );
  ReceiveItemSetPcIsOnlineHandle.Update;
  ReceiveItemSetPcIsOnlineHandle.Free;
end;

class procedure ReceiveItemAppApi.SetReceiveStatus(RootPath, OwnerID,
  SourcePath, Status: string);
var
  ReceiveItemSetStatusHandle : TReceiveItemSetStatusHandle;
begin
  ReceiveItemSetStatusHandle := TReceiveItemSetStatusHandle.Create( RootPath );
  ReceiveItemSetStatusHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetStatusHandle.SetStatus( Status );
  ReceiveItemSetStatusHandle.Update;
  ReceiveItemSetStatusHandle.Free;
end;


class procedure ReceiveItemAppApi.SetReceiveTime(RootPath, OwnerID,
  SourcePath: string; ReceiveTime: TDateTime);
var
  ReceiveItemSetReceiveTimeHandle : TReceiveItemSetReceiveTimeHandle;
begin
  ReceiveItemSetReceiveTimeHandle := TReceiveItemSetReceiveTimeHandle.Create( RootPath );
  ReceiveItemSetReceiveTimeHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetReceiveTimeHandle.SetReceiveTime( ReceiveTime );
  ReceiveItemSetReceiveTimeHandle.Update;
  ReceiveItemSetReceiveTimeHandle.Free;
end;

class procedure ReceiveItemAppApi.SetSpaceInfo(
  Params: TReceiveItemSetSpaceParams);
var
  ReceiveItemSetSpaceInfoHandle : TReceiveItemSetSpaceInfoHandle;
begin
  ReceiveItemSetSpaceInfoHandle := TReceiveItemSetSpaceInfoHandle.Create( Params.RootPath );
  ReceiveItemSetSpaceInfoHandle.SetSourceInfo( Params.SourcePath, Params.OwnerID );
  ReceiveItemSetSpaceInfoHandle.SetSpaceInfo( Params.FileCount, Params.FileSize, Params.CompletedSpace );
  ReceiveItemSetSpaceInfoHandle.Update;
  ReceiveItemSetSpaceInfoHandle.Free;
end;



class procedure ReceiveItemAppApi.SetSpeedInfo(RootPath, OwnerID,
  SourcePath: string; Speed: Integer);
var
  ReceiveItemSetSpeedHandle : TReceiveItemSetSpeedHandle;
begin
  ReceiveItemSetSpeedHandle := TReceiveItemSetSpeedHandle.Create( RootPath );
  ReceiveItemSetSpeedHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetSpeedHandle.SetSpeed( Speed );
  ReceiveItemSetSpeedHandle.Update;
  ReceiveItemSetSpeedHandle.Free;
end;



class procedure ReceiveItemAppApi.SetStartReceive(RootPath, OwnerID,
  SourcePath: string);
var
  ReceiveItemSetStartReceiveHandle : TReceiveItemSetStartReceiveHandle;
begin
  ReceiveItemSetStartReceiveHandle := TReceiveItemSetStartReceiveHandle.Create( RootPath );
  ReceiveItemSetStartReceiveHandle.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetStartReceiveHandle.Update;
  ReceiveItemSetStartReceiveHandle.Free;
end;

class procedure ReceiveItemAppApi.SetStopReceive(RootPath, OwnerID,
  SourcePath: string);
begin
  SetReceiveStatus( RootPath, OwnerID, SourcePath, ReceiveNodeStatus_Stop );
  SetIsReceiving( RootPath, OwnerID, SourcePath, False );
end;

class procedure ReceiveItemAppApi.SetWaitingReceive(RootPath, OwnerID,
  SourcePath: string);
begin
  SetIsReceiving( RootPath, OwnerID, SourcePath, True );
  SetIsCompleted( RootPath, OwnerID, SourcePath, False );
  SetReceiveStatus( RootPath, OwnerID, SourcePath, ReceiveNodeStatus_Waiting );
end;

class procedure ReceiveItemAppApi.ShowRecieveHint(RootPath, OwnerID,
  SourcePath: string);
var
  OwnerName, Destination : string;
  IsFile : Boolean;
begin
    // 已经提示过了
  if not ReceiveItemInfoReadUtil.ReadIsFirstReceive( RootPath, SourcePath, OwnerID ) then
    Exit;

    // 提示
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );
  Destination := ReceiveItemInfoReadUtil.ReadSavePath( RootPath, SourcePath, OwnerID );
  IsFile := ReceiveItemInfoReadUtil.ReadIsFile( RootPath, SourcePath, OwnerID );
  MyHintAppApi.ShowReceiveCompelted( Destination, OwnerName, IsFile );

    // 设置已经提示过了
  ReceiveItemAppApi.SetIsFirstReceive( RootPath, OwnerID, SourcePath, False );
end;

procedure TReceiveItemWriteHandle.SetSourceInfo( _SourcePath, _OwnerID : string );
begin
  SourcePath := _SourcePath;
  OwnerID := _OwnerID;
end;

{ TCloudPcBackupPathReadHandle }

procedure TReceiveItemReadHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TReceiveItemReadHandle.SetIsFirstReceive(_IsFirstReceive: Boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemReadHandle.SetIsNewReceive(_IsNewReceive: Boolean);
begin
  IsNewReceive := _IsNewReceive;
end;

procedure TReceiveItemReadHandle.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TReceiveItemReadHandle.SetReceiveTime(_ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemReadHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TReceiveItemReadHandle.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSapce : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSapce := _CompletedSapce;
end;

procedure TReceiveItemReadHandle.SetStatusInfo(_IsCompleted,
  _IsCancel: boolean);
begin
  IsCompleted := _IsCompleted;
  IsCancel := _IsCancel;
end;

procedure TReceiveItemReadHandle.AddToFace;
var
  OwnerName : string;
  IsOnline : Boolean;
  ReceiveItemAddFace : TReceiveItemAddFace;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );
  IsOnline := MyNetPcInfoReadUtil.ReadIsOnline( OwnerID );

  ReceiveItemAddFace := TReceiveItemAddFace.Create( RootPath );
  ReceiveItemAddFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemAddFace.SetIsFile( IsFile );
  ReceiveItemAddFace.SetStatusInfo( IsCompleted, IsCancel );
  ReceiveItemAddFace.SetIsZip( IsZip );
  ReceiveItemAddFace.SetOwnerInfo( OwnerName, IsOnline );
  ReceiveItemAddFace.SetSpaceInfo( FileCount, ItemSize, CompletedSapce );
  ReceiveItemAddFace.SetIsNewReceive( IsNewReceive );
  ReceiveItemAddFace.SetReceiveTime( ReceiveTime );
  ReceiveItemAddFace.SetSavePath( SavePath );
  ReceiveItemAddFace.AddChange;
end;

procedure TReceiveItemReadHandle.AddToInfo;
var
  ReceiveItemAddInfo : TReceiveItemAddInfo;
begin
  ReceiveItemAddInfo := TReceiveItemAddInfo.Create( RootPath );
  ReceiveItemAddInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemAddInfo.SetIsFile( IsFile );
  ReceiveItemAddInfo.SetStatusInfo( IsCompleted, IsCancel );
  ReceiveItemAddInfo.SetIsZip( IsZip );
  ReceiveItemAddInfo.SetIsFirstReceive( IsFirstReceive );
  ReceiveItemAddInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSapce );
  ReceiveItemAddInfo.SetSavePath( SavePath );
  ReceiveItemAddInfo.Update;
  ReceiveItemAddInfo.Free;
end;


procedure TReceiveItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TCloudPcBackupPathAddHandle }

procedure TReceiveItemAddHandle.AddToNewCount;
begin
  MainFormApi.ShowNewReceive;
//  ReceiveRootItemUserApi.AddNewCount;
end;

procedure TReceiveItemAddHandle.AddToXml;
var
  CloudPcBackupPathAddXml : TReceiveItemAddXml;
begin
  CloudPcBackupPathAddXml := TReceiveItemAddXml.Create( RootPath );
  CloudPcBackupPathAddXml.SetSourceInfo( SourcePath, OwnerID );
  CloudPcBackupPathAddXml.SetIsFile( IsFile );
  CloudPcBackupPathAddXml.SetStatusInfo( IsCompleted, IsCancel );
  CloudPcBackupPathAddXml.SetIsZip( IsZip );
  CloudPcBackupPathAddXml.SetIsFirstReceive( IsFirstReceive );
  CloudPcBackupPathAddXml.SetSpaceInfo( FileCount, ItemSize, CompletedSapce );
  CloudPcBackupPathAddXml.SetSavePath( SavePath );
  CloudPcBackupPathAddXml.SetReceiveTime( ReceiveTime );
  CloudPcBackupPathAddXml.AddChange;
end;

procedure TReceiveItemAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToNewCount;
end;

{ TCloudPcBackupPathRemoveHandle }

procedure TReceiveItemRemoveHandle.RemoveFromEvent;
begin
    // 没有发送取消，则通知发送方
  if not ReceiveItemInfoReadUtil.ReadIsSendCancel( RootPath, SourcePath, OwnerID ) then
    ReceiveItemEvent.RemoveItem( RootPath, OwnerID, SourcePath );
end;

procedure TReceiveItemRemoveHandle.RemoveFromFace;
var
  ReceiveItemRemoveFace : TReceiveItemRemoveFace;
begin
  ReceiveItemRemoveFace := TReceiveItemRemoveFace.Create( RootPath );
  ReceiveItemRemoveFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemRemoveFace.AddChange;
end;

procedure TReceiveItemRemoveHandle.RemoveFromInfo;
var
  CloudPcBackupPathRemoveInfo : TReceiveItemRemoveInfo;
begin
  CloudPcBackupPathRemoveInfo := TReceiveItemRemoveInfo.Create( RootPath );
  CloudPcBackupPathRemoveInfo.SetSourceInfo( SourcePath, OwnerID );
  CloudPcBackupPathRemoveInfo.Update;
  CloudPcBackupPathRemoveInfo.Free;
end;


procedure TReceiveItemRemoveHandle.RemoveFromXml;
var
  CloudPcBackupPathRemoveXml : TReceiveItemRemoveXml;
begin
  CloudPcBackupPathRemoveXml := TReceiveItemRemoveXml.Create( RootPath );
  CloudPcBackupPathRemoveXml.SetSourceInfo( SourcePath, OwnerID );
  CloudPcBackupPathRemoveXml.AddChange;
end;

procedure TReceiveItemRemoveHandle.Update;
begin
  RemoveFromEvent;
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TReceiveItemSetSpaceInfoHandle }

procedure TReceiveItemSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSpace : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveItemSetSpaceInfoHandle.SetToInfo;
var
  ReceiveItemSetSpaceInfoInfo : TReceiveItemSetSpaceInfoInfo;
begin
  ReceiveItemSetSpaceInfoInfo := TReceiveItemSetSpaceInfoInfo.Create( RootPath );
  ReceiveItemSetSpaceInfoInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetSpaceInfoInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSpace );
  ReceiveItemSetSpaceInfoInfo.Update;
  ReceiveItemSetSpaceInfoInfo.Free;
end;

procedure TReceiveItemSetSpaceInfoHandle.SetToXml;
var
  ReceiveItemSetSpaceInfoXml : TReceiveItemSetSpaceInfoXml;
begin
  ReceiveItemSetSpaceInfoXml := TReceiveItemSetSpaceInfoXml.Create( RootPath );
  ReceiveItemSetSpaceInfoXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetSpaceInfoXml.SetSpaceInfo( FileCount, ItemSize, CompletedSpace );
  ReceiveItemSetSpaceInfoXml.AddChange;
end;

procedure TReceiveItemSetSpaceInfoHandle.SetToFace;
var
  ReceiveItemSetSpaceInfoFace : TReceiveItemSetSpaceInfoFace;
begin
  ReceiveItemSetSpaceInfoFace := TReceiveItemSetSpaceInfoFace.Create( RootPath );
  ReceiveItemSetSpaceInfoFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetSpaceInfoFace.SetSpaceInfo( FileCount, ItemSize, CompletedSpace );
  ReceiveItemSetSpaceInfoFace.AddChange;
end;

procedure TReceiveItemSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TReceiveItemSetAddCompletedSpaceHandle }

procedure TReceiveItemSetAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TReceiveItemSetAddCompletedSpaceHandle.SetToInfo;
var
  ReceiveItemSetAddCompletedSpaceInfo : TReceiveItemSetAddCompletedSpaceInfo;
begin
  ReceiveItemSetAddCompletedSpaceInfo := TReceiveItemSetAddCompletedSpaceInfo.Create( RootPath );
  ReceiveItemSetAddCompletedSpaceInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  ReceiveItemSetAddCompletedSpaceInfo.Update;
  ReceiveItemSetAddCompletedSpaceInfo.Free;
end;

procedure TReceiveItemSetAddCompletedSpaceHandle.SetToXml;
var
  ReceiveItemSetAddCompletedSpaceXml : TReceiveItemSetAddCompletedSpaceXml;
begin
  ReceiveItemSetAddCompletedSpaceXml := TReceiveItemSetAddCompletedSpaceXml.Create( RootPath );
  ReceiveItemSetAddCompletedSpaceXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  ReceiveItemSetAddCompletedSpaceXml.AddChange;
end;

procedure TReceiveItemSetAddCompletedSpaceHandle.SetToFace;
var
  ReceiveItemSetAddCompletedSpaceFace : TReceiveItemSetAddCompletedSpaceFace;
begin
  ReceiveItemSetAddCompletedSpaceFace := TReceiveItemSetAddCompletedSpaceFace.Create( RootPath );
  ReceiveItemSetAddCompletedSpaceFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  ReceiveItemSetAddCompletedSpaceFace.AddChange;
end;

procedure TReceiveItemSetAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;


{ TReceiveItemSetIsReceivingHandle }

procedure TReceiveItemSetIsReceivingHandle.SetIsReceiving( _IsReceiving : boolean );
begin
  IsReceiving := _IsReceiving;
end;

procedure TReceiveItemSetIsReceivingHandle.SetToInfo;
var
  ReceiveItemSetIsReceivingInfo : TReceiveItemSetIsReceivingInfo;
begin
  ReceiveItemSetIsReceivingInfo := TReceiveItemSetIsReceivingInfo.Create( RootPath );
  ReceiveItemSetIsReceivingInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsReceivingInfo.SetIsReceiving( IsReceiving );
  ReceiveItemSetIsReceivingInfo.Update;
  ReceiveItemSetIsReceivingInfo.Free;
end;

procedure TReceiveItemSetIsReceivingHandle.SetToFace;
var
  ReceiveItemSetIsReceivingFace : TReceiveItemSetIsReceivingFace;
begin
  ReceiveItemSetIsReceivingFace := TReceiveItemSetIsReceivingFace.Create( RootPath );
  ReceiveItemSetIsReceivingFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetIsReceivingFace.SetIsReceiving( IsReceiving );
  ReceiveItemSetIsReceivingFace.AddChange;
end;

procedure TReceiveItemSetIsReceivingHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TReceiveItemSetIsCompletedHandle }

procedure TReceiveItemSetIsCompletedHandle.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TReceiveItemSetIsCompletedHandle.SetToInfo;
var
  ReceiveItemSetIsCompletedInfo : TReceiveItemSetIsCompletedInfo;
begin
  ReceiveItemSetIsCompletedInfo := TReceiveItemSetIsCompletedInfo.Create( RootPath );
  ReceiveItemSetIsCompletedInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCompletedInfo.SetIsCompleted( IsCompleted );
  ReceiveItemSetIsCompletedInfo.Update;
  ReceiveItemSetIsCompletedInfo.Free;
end;

procedure TReceiveItemSetIsCompletedHandle.SetToXml;
var
  ReceiveItemSetIsCompletedXml : TReceiveItemSetIsCompletedXml;
begin
  ReceiveItemSetIsCompletedXml := TReceiveItemSetIsCompletedXml.Create( RootPath );
  ReceiveItemSetIsCompletedXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCompletedXml.SetIsCompleted( IsCompleted );
  ReceiveItemSetIsCompletedXml.AddChange;
end;

procedure TReceiveItemSetIsCompletedHandle.SetToFace;
var
  ReceiveItemSetIsCompletedFace : TReceiveItemSetIsCompletedFace;
begin
  ReceiveItemSetIsCompletedFace := TReceiveItemSetIsCompletedFace.Create( RootPath );
  ReceiveItemSetIsCompletedFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetIsCompletedFace.SetIsCompleted( IsCompleted );
  ReceiveItemSetIsCompletedFace.AddChange;
end;

procedure TReceiveItemSetIsCompletedHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;


{ TReceiveItemSetIsCancelHandle }

procedure TReceiveItemSetIsCancelHandle.SetIsCancel( _IsCancel : boolean );
begin
  IsCancel := _IsCancel;
end;

procedure TReceiveItemSetIsCancelHandle.SetToInfo;
var
  ReceiveItemSetIsCancelInfo : TReceiveItemSetIsCancelInfo;
begin
  ReceiveItemSetIsCancelInfo := TReceiveItemSetIsCancelInfo.Create( RootPath );
  ReceiveItemSetIsCancelInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCancelInfo.SetIsCancel( IsCancel );
  ReceiveItemSetIsCancelInfo.Update;
  ReceiveItemSetIsCancelInfo.Free;
end;

procedure TReceiveItemSetIsCancelHandle.SetToXml;
var
  ReceiveItemSetIsCancelXml : TReceiveItemSetIsCancelXml;
begin
  ReceiveItemSetIsCancelXml := TReceiveItemSetIsCancelXml.Create( RootPath );
  ReceiveItemSetIsCancelXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsCancelXml.SetIsCancel( IsCancel );
  ReceiveItemSetIsCancelXml.AddChange;
end;

procedure TReceiveItemSetIsCancelHandle.SetToFace;
var
  ReceiveItemSetIsCancelFace : TReceiveItemSetIsCancelFace;
begin
  ReceiveItemSetIsCancelFace := TReceiveItemSetIsCancelFace.Create( RootPath );
  ReceiveItemSetIsCancelFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetIsCancelFace.SetIsCancel( IsCancel );
  ReceiveItemSetIsCancelFace.AddChange;
end;

procedure TReceiveItemSetIsCancelHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;






{ TReceiveItemSetPcIsOnlineHandle }

constructor TReceiveItemSetPcIsOnlineHandle.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TReceiveItemSetPcIsOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TReceiveItemSetPcIsOnlineHandle.SetToFace;
var
  ReceiveItemSetPcIsOnlineFace : TReceiveItemSetPcIsOnlineFace;
begin
  ReceiveItemSetPcIsOnlineFace := TReceiveItemSetPcIsOnlineFace.Create( OnlinePcID );
  ReceiveItemSetPcIsOnlineFace.SetIsOnline( IsOnline );
  ReceiveItemSetPcIsOnlineFace.AddChange;
end;

procedure TReceiveItemSetPcIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TReceiveItemSetSpeedHandle }

procedure TReceiveItemSetSpeedHandle.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TReceiveItemSetSpeedHandle.SetToFace;
var
  ReceiveItemSetSpeedFace : TReceiveItemSetSpeedFace;
begin
  ReceiveItemSetSpeedFace := TReceiveItemSetSpeedFace.Create( RootPath );
  ReceiveItemSetSpeedFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetSpeedFace.SetSpeed( Speed );
  ReceiveItemSetSpeedFace.AddChange;
end;

procedure TReceiveItemSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ TReceiveItemSetStatusHandle }

procedure TReceiveItemSetStatusHandle.SetStatus( _Status : string );
begin
  Status := _Status;
end;


procedure TReceiveItemSetStatusHandle.SetToFace;
var
  ReceiveItemSetStatusFace : TReceiveItemSetStatusFace;
begin
  ReceiveItemSetStatusFace := TReceiveItemSetStatusFace.Create( RootPath );
  ReceiveItemSetStatusFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetStatusFace.SetStatus( Status );
  ReceiveItemSetStatusFace.AddChange;
end;

procedure TReceiveItemSetStatusHandle.Update;
begin
  SetToFace;
end;

{ ReceiveRootItemAppApi }

class procedure ReceiveRootItemAppApi.SetAvailableSpace(RootPath: string;
  AvailableSpace: Int64);
var
  ReceiveRootItemSetAvailableSpaceHandle : TReceiveRootItemSetAvailableSpaceHandle;
begin
  ReceiveRootItemSetAvailableSpaceHandle := TReceiveRootItemSetAvailableSpaceHandle.Create( RootPath );
  ReceiveRootItemSetAvailableSpaceHandle.SetAvailableSpace( AvailableSpace );
  ReceiveRootItemSetAvailableSpaceHandle.Update;
  ReceiveRootItemSetAvailableSpaceHandle.Free;
end;

class procedure ReceiveRootItemAppApi.SetIsExist(RootPath: string;
  IsExist: Boolean);
var
  ReceiveRootItemSetIsExistHandle : TReceiveRootItemSetIsExistHandle;
begin
  ReceiveRootItemSetIsExistHandle := TReceiveRootItemSetIsExistHandle.Create( RootPath );
  ReceiveRootItemSetIsExistHandle.SetIsExist( IsExist );
  ReceiveRootItemSetIsExistHandle.Update;
  ReceiveRootItemSetIsExistHandle.Free;
end;

class procedure ReceiveRootItemAppApi.SetIsWrite(RootPath: string;
  IsWrite: Boolean);
var
  ReceiveRootItemSetIsWriteHandle : TReceiveRootItemSetIsWriteHandle;
begin
  ReceiveRootItemSetIsWriteHandle := TReceiveRootItemSetIsWriteHandle.Create( RootPath );
  ReceiveRootItemSetIsWriteHandle.SetIsWrite( IsWrite );
  ReceiveRootItemSetIsWriteHandle.Update;
  ReceiveRootItemSetIsWriteHandle.Free;
end;


{ TReceiveRootItemSetAvailableSpaceHandle }

procedure TReceiveRootItemSetAvailableSpaceHandle.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TReceiveRootItemSetAvailableSpaceHandle.SetToFace;
var
  ReceiveRootItemSetAvailableSpaceFace : TReceiveRootItemSetAvailableSpaceFace;
begin
  ReceiveRootItemSetAvailableSpaceFace := TReceiveRootItemSetAvailableSpaceFace.Create( RootPath );
  ReceiveRootItemSetAvailableSpaceFace.SetAvailableSpace( AvailableSpace );
  ReceiveRootItemSetAvailableSpaceFace.AddChange;
end;

procedure TReceiveRootItemSetAvailableSpaceHandle.Update;
begin
  SetToFace;
end;

{ TReceiveRootItemSetIsExistHandle }

procedure TReceiveRootItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TReceiveRootItemSetIsExistHandle.SetToFace;
var
  ReceiveRootItemSetIsExistFace : TReceiveRootItemSetIsExistFace;
begin
  ReceiveRootItemSetIsExistFace := TReceiveRootItemSetIsExistFace.Create( RootPath );
  ReceiveRootItemSetIsExistFace.SetIsExist( IsExist );
  ReceiveRootItemSetIsExistFace.AddChange;
end;

procedure TReceiveRootItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TReceiveRootItemSetIsWriteHandle }

procedure TReceiveRootItemSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TReceiveRootItemSetIsWriteHandle.SetToFace;
var
  ReceiveRootItemSetIsWriteFace : TReceiveRootItemSetIsWriteFace;
begin
  ReceiveRootItemSetIsWriteFace := TReceiveRootItemSetIsWriteFace.Create( RootPath );
  ReceiveRootItemSetIsWriteFace.SetIsWrite( IsWrite );
  ReceiveRootItemSetIsWriteFace.AddChange;
end;

procedure TReceiveRootItemSetIsWriteHandle.Update;
begin
  SetToFace;
end;


{ TOnlineSendReceiveListHanlde }

constructor TOnlineSendReceiveListHanlde.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TOnlineSendReceiveListHanlde.Update;
var
  CloudPathList : TStringList;
  i: Integer;
begin
  CloudPathList := ReceiveRootInfoReadUtil.ReadPathList;
  for i := 0 to CloudPathList.Count - 1 do
    ReceiveRootEvent.OnlineSendItem( OnlinePcID, CloudPathList[i] );
  CloudPathList.Free;
end;

{ TReceiveItemSetStartReceiveHandle }

procedure TReceiveItemSetStartReceiveHandle.AddToHint;
var
  Destiantion, SavePath : string;
  IsFile : Boolean;
begin
  Destiantion := MyNetPcInfoReadUtil.ReadName( OwnerID );
  SavePath := ReceiveItemInfoReadUtil.ReadSavePath( RootPath, SourcePath, OwnerID );
  IsFile := ReceiveItemInfoReadUtil.ReadIsFile( RootPath, SourcePath, OwnerID );

  MyHintAppApi.ShowReceiving( SavePath, Destiantion, IsFile );
end;

procedure TReceiveItemSetStartReceiveHandle.Update;
begin
    // 正在接收
  ReceiveItemAppApi.SetIsReceiving( RootPath, OwnerID, SourcePath, True );

    // 接收未完成
  ReceiveItemAppApi.SetIsCompleted( RootPath, OwnerID, SourcePath, False );

    // 重置速度
  ReceiveItemAppApi.SetSpeedInfo( RootPath, OwnerID, SourcePath, 0 );

    // 设置接收状态
  ReceiveItemAppApi.SetReceiveStatus( RootPath, OwnerID, SourcePath, ReceiveNodeStatus_Receiving );

    // 显示 Hint
  AddToHint;
end;

{ TReceiveItemSetReceiveCompletedHandle }

procedure TReceiveItemSetReceiveCompletedHandle.AddToHint;
begin
  ReceiveItemAppApi.ShowRecieveHint( RootPath, OwnerID, SourcePath );
end;

procedure TReceiveItemSetReceiveCompletedHandle.RefreashIcon;
var
  ReceiveItemRefreshIconFace : TReceiveItemRefreshIconFace;
begin
  ReceiveItemRefreshIconFace := TReceiveItemRefreshIconFace.Create( RootPath );
  ReceiveItemRefreshIconFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemRefreshIconFace.AddChange;
end;

procedure TReceiveItemSetReceiveCompletedHandle.Update;
begin
    // 设置已完成
  ReceiveItemAppApi.SetIsCompleted( RootPath, OwnerID, SourcePath, True );

    // 显示Hint
  AddToHint;

    // 刷新图标
  RefreashIcon;
end;

{ TReceiveRootNewCountAddHandle }

procedure TReceiveRootNewCountAddHandle.AddToFace;
var
  ReceiveRootNewCountAddFace : TReceiveRootNewCountAddFace;
begin
  ReceiveRootNewCountAddFace := TReceiveRootNewCountAddFace.Create;
  ReceiveRootNewCountAddFace.AddChange;
end;

procedure TReceiveRootNewCountAddHandle.AddToXml;
var
  ReceiveRootNewCountAddXml : TReceiveRootNewCountAddXml;
begin
  ReceiveRootNewCountAddXml := TReceiveRootNewCountAddXml.Create;
  ReceiveRootNewCountAddXml.AddChange;
end;

procedure TReceiveRootNewCountAddHandle.Update;
begin
  AddToFace;
  AddToXml;
end;

{ TReceiveRootReadNewCountHandle }

constructor TReceiveRootReadNewCountHandle.Create(_NewCount: Integer);
begin
  NewCount := _NewCount;
end;

procedure TReceiveRootReadNewCountHandle.SetToFace;
var
  ReceiveRootNewCountReadFace : TReceiveRootNewCountReadFace;
begin
  ReceiveRootNewCountReadFace := TReceiveRootNewCountReadFace.Create( NewCount );
  ReceiveRootNewCountReadFace.AddChange;
end;

procedure TReceiveRootReadNewCountHandle.Update;
begin
  SetToFace;
end;

{ TReceiveRootNewCountClearHandle }

procedure TReceiveRootNewCountClearHandle.ClearToFace;
var
  ReceiveRootNewCountClearFace : TReceiveRootNewCountClearFace;
begin
  ReceiveRootNewCountClearFace := TReceiveRootNewCountClearFace.Create;
  ReceiveRootNewCountClearFace.AddChange;
end;

procedure TReceiveRootNewCountClearHandle.ClearToXml;
var
  ReceiveRootNewCountClearXml : TReceiveRootNewCountClearXml;
begin
  ReceiveRootNewCountClearXml := TReceiveRootNewCountClearXml.Create;
  ReceiveRootNewCountClearXml.AddChange;
end;

procedure TReceiveRootNewCountClearHandle.Update;
begin
  ClearToFace;
  ClearToXml;
end;

{ TReceiveItemSetReceiveTimeHandle }

procedure TReceiveItemSetReceiveTimeHandle.SetReceiveTime(
  _ReceiveTime: TDateTime);
begin
  ReceiveTime := _ReceiveTime;
end;

procedure TReceiveItemSetReceiveTimeHandle.SetToFace;
var
  ReceiveItemSetReceiveTimeFace : TReceiveItemSetReceiveTimeFace;
begin
  ReceiveItemSetReceiveTimeFace := TReceiveItemSetReceiveTimeFace.Create( RootPath );
  ReceiveItemSetReceiveTimeFace.SetSourcePath( SourcePath, OwnerID );
  ReceiveItemSetReceiveTimeFace.SetReceiveTime( ReceiveTime );
  ReceiveItemSetReceiveTimeFace.AddChange;
end;

procedure TReceiveItemSetReceiveTimeHandle.SetToXml;
var
  ReceiveItemSetReceiveTimeXml : TReceiveItemSetReceiveTimeXml;
begin
  ReceiveItemSetReceiveTimeXml := TReceiveItemSetReceiveTimeXml.Create( RootPath );
  ReceiveItemSetReceiveTimeXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetReceiveTimeXml.SetReceiveTime( ReceiveTime );
  ReceiveItemSetReceiveTimeXml.AddChange;
end;

procedure TReceiveItemSetReceiveTimeHandle.Update;
begin
  SetToFace;
  SetToXml;
end;

{ TReceiveItemSetIsFirstReceiveHandle }

procedure TReceiveItemSetIsFirstReceiveHandle.SetIsFirstReceive(
  _IsFirstReceive: boolean);
begin
  IsFirstReceive := _IsFirstReceive;
end;

procedure TReceiveItemSetIsFirstReceiveHandle.SetToInfo;
var
  ReceiveItemSetIsFirstReceiveInfo : TReceiveItemSetIsFirstReceiveInfo;
begin
  ReceiveItemSetIsFirstReceiveInfo := TReceiveItemSetIsFirstReceiveInfo.Create( RootPath );
  ReceiveItemSetIsFirstReceiveInfo.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsFirstReceiveInfo.SetIsFirstReceive( IsFirstReceive );
  ReceiveItemSetIsFirstReceiveInfo.Update;
  ReceiveItemSetIsFirstReceiveInfo.Free;
end;

procedure TReceiveItemSetIsFirstReceiveHandle.SetToXml;
var
  ReceiveItemSetIsFirstReceiveXml : TReceiveItemSetIsFirstReceiveXml;
begin
  ReceiveItemSetIsFirstReceiveXml := TReceiveItemSetIsFirstReceiveXml.Create( RootPath );
  ReceiveItemSetIsFirstReceiveXml.SetSourceInfo( SourcePath, OwnerID );
  ReceiveItemSetIsFirstReceiveXml.SetIsFirstReceive( IsFirstReceive );
  ReceiveItemSetIsFirstReceiveXml.AddChange;
end;

procedure TReceiveItemSetIsFirstReceiveHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

end.
