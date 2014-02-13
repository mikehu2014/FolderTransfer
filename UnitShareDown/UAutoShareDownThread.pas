unit UAutoShareDownThread;

interface

uses classes, SysUtils, DateUtils;

type

    // 检测繁忙的发送，然后启动
  TAutoShareDownHandle = class
  public
    procedure Update;
  end;

    // 检测断开的发送，然后启动
  TShareDownLostConnHandle = class
  public
    procedure Update;
  end;

    // 检测未完成的发送，然后启动
  TShareDownIncompletedHandle = class
  public
    procedure Update;
  end;

  MyAutoShareDownApi = class
  public
    class procedure CheckShareDownBusy;
    class procedure CheckShareDownLostConn;
    class procedure CheckShareDownIncompleted;
  end;

implementation

uses UMySendDataInfo, UMySendApiInfo, UMyUtil, UMyShareDOwnDataInfo, UMyShareDownApiInfo, UMyNetPcInfo;

{ TAutoBackupHandle }

procedure TAutoShareDownHandle.Update;
var
  ShareDonwReadDataList : TShareDonwReadDataList;
  i: Integer;
  ShareDownInfo : TShareDownReadDataInfo;
begin
  ShareDonwReadDataList := ShareDownInfoReadUtil.ReadDesBusyList;
  for i := 0 to ShareDonwReadDataList.Count - 1 do
  begin
    ShareDownInfo := ShareDonwReadDataList[i];
    ShareDownUserApi.DownSelectNetworkItem( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
  end;
  ShareDonwReadDataList.Free;
end;

{ MyAutoShareDownApi }

class procedure MyAutoShareDownApi.CheckShareDownBusy;
var
  AutoBackupHandle : TAutoShareDownHandle;
begin
  AutoBackupHandle := TAutoShareDownHandle.Create;
  AutoBackupHandle.Update;
  AutoBackupHandle.Free;
end;

class procedure MyAutoShareDownApi.CheckShareDownIncompleted;
var
  ShareDownIncompletedHandle : TShareDownIncompletedHandle;
begin
    // 用户停止下载
  if UserShareDown_IsStop then
    Exit;

  ShareDownIncompletedHandle := TShareDownIncompletedHandle.Create;
  ShareDownIncompletedHandle.Update;
  ShareDownIncompletedHandle.Free;
end;

class procedure MyAutoShareDownApi.CheckShareDownLostConn;
var
  ShareDownLostConnHandle : TShareDownLostConnHandle;
begin
  ShareDownLostConnHandle := TShareDownLostConnHandle.Create;
  ShareDownLostConnHandle.Update;
  ShareDownLostConnHandle.Free;
end;

{ TShareDownLostConnHandle }

procedure TShareDownLostConnHandle.Update;
var
  ShareDonwReadDataList : TShareDonwReadDataList;
  i: Integer;
  ShareDownInfo : TShareDownReadDataInfo;
begin
  ShareDonwReadDataList := ShareDownInfoReadUtil.ReadLostConnList;
  for i := 0 to ShareDonwReadDataList.Count - 1 do
  begin
    ShareDownInfo := ShareDonwReadDataList[i];
    ShareDownUserApi.DownSelectNetworkItem( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
  end;
  ShareDonwReadDataList.Free;
end;

{ TShareDownIncompletedHandle }

procedure TShareDownIncompletedHandle.Update;
var
  ShareDonwReadDataList : TShareDonwReadDataList;
  i: Integer;
  ShareDownInfo : TShareDownReadDataInfo;
begin
  ShareDonwReadDataList := ShareDownInfoReadUtil.ReadIncompletedList;
  for i := 0 to ShareDonwReadDataList.Count - 1 do
  begin
    ShareDownInfo := ShareDonwReadDataList[i];
    if not MyNetPcInfoReadUtil.ReadIsOnline( ShareDownInfo.OwnerPcID ) then  // 离线
      Continue;
    ShareDownUserApi.DownSelectNetworkItem( ShareDownInfo.SharePath, ShareDownInfo.OwnerPcID );
  end;
  ShareDonwReadDataList.Free;
end;

end.
