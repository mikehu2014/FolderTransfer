unit UAutoSendThread;

interface

uses classes, SysUtils, DateUtils;

type

    // ��ⷱæ�ķ��ͣ�Ȼ������
  TDesBusySendHandle = class
  public
    procedure Update;
  end;

    // ���Ͽ��ķ��ͣ�Ȼ������
  TDesLostConnectHandle = class
  public
    procedure Update;
  end;

    // ���δ��ɵķ��ͣ�Ȼ������
  TDesIncompletedHandle = class
  public
    procedure Update;
  end;

    // ��ⶨʱ����
  TDesAutoSendHandle = class
  public
    procedure Update;
  end;

  MyAutoSendApi = class
  public
    class procedure CheckBusySend;
    class procedure CheckLostConnectSend;
    class procedure CheckIncompletedSend;
    class procedure CheckAutoSend;
  end;

implementation

uses UMySendDataInfo, UMySendApiInfo, UMyUtil, UMyNetPcInfo;

{ TAutoBackupHandle }

procedure TDesBusySendHandle.Update;
var
  SendRootItemList : TStringList;
  DesBusyItemList : TStringList;
  SendRootItemID, SourcePath : string;
  j : Integer;
  i: Integer;
begin
  SendRootItemList := SendRootItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to SendRootItemList.Count - 1 do
  begin
    SendRootItemID := SendRootItemList[i];
    DesBusyItemList := SendRootItemInfoReadUtil.ReadDesBusyList( SendRootItemID );
    for j := 0 to DesBusyItemList.Count - 1 do
    begin
      SourcePath := DesBusyItemList[j];
      SendItemAppApi.SetIsDesBusy( SendRootItemID, SourcePath, False );
      SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
    end;
    DesBusyItemList.Free;
  end;
  SendRootItemList.Free;
end;


{ MySendTimerHandle }

class procedure MyAutoSendApi.CheckAutoSend;
var
  DesAutoSendHandle : TDesAutoSendHandle;
begin
  DesAutoSendHandle := TDesAutoSendHandle.Create;
  DesAutoSendHandle.Update;
  DesAutoSendHandle.Free;
end;

class procedure MyAutoSendApi.CheckBusySend;
var
  AutoSendHandle : TDesBusySendHandle;
begin
  AutoSendHandle := TDesBusySendHandle.Create;
  AutoSendHandle.Update;
  AutoSendHandle.Free;
end;

{ TDesLostConnectHandle }

procedure TDesLostConnectHandle.Update;
var
  SendRootItemList : TStringList;
  LostConnItemList : TStringList;
  SendRootItemID, SourcePath : string;
  j : Integer;
  i: Integer;
begin
  SendRootItemList := SendRootItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to SendRootItemList.Count - 1 do
  begin
    SendRootItemID := SendRootItemList[i];
    if not MyNetPcInfoReadUtil.ReadDesIsOnline( SendRootItemID ) then  // Pc ����
      Continue;
    LostConnItemList := SendRootItemInfoReadUtil.ReadLostConnList( SendRootItemID );
    for j := 0 to LostConnItemList.Count - 1 do
    begin
      SourcePath := LostConnItemList[j];
      SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
    end;
    LostConnItemList.Free;
  end;
  SendRootItemList.Free;
end;

class procedure MyAutoSendApi.CheckIncompletedSend;
var
  DesIncompletedHandle : TDesIncompletedHandle;
begin
  if UserTransfer_IsStop then  // �û��Ѿ���������
    Exit;

  DesIncompletedHandle := TDesIncompletedHandle.Create;
  DesIncompletedHandle.Update;
  DesIncompletedHandle.Free;
end;

class procedure MyAutoSendApi.CheckLostConnectSend;
var
  DesLostConnectHandle : TDesLostConnectHandle;
begin
  DesLostConnectHandle := TDesLostConnectHandle.Create;
  DesLostConnectHandle.Update;
  DesLostConnectHandle.Free;
end;

{ TDesIncompletedHandle }

procedure TDesIncompletedHandle.Update;
var
  SendRootItemList : TStringList;
  IncompletedItemList : TStringList;
  SendRootItemID, PcID, SourcePath : string;
  j : Integer;
  i: Integer;
begin
  SendRootItemList := SendRootItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to SendRootItemList.Count - 1 do
  begin
    SendRootItemID := SendRootItemList[i];
    PcID := NetworkDesItemUtil.getPcID( SendRootItemID );
    if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then // Pc�Ƿ�����
      Continue;
      // ��ȡ���� Incompleted Ȼ������
    IncompletedItemList := SendRootItemInfoReadUtil.ReadIncompletedList( SendRootItemID );
    for j := 0 to IncompletedItemList.Count - 1 do
    begin
      SourcePath := IncompletedItemList[j];
      SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
    end;
    IncompletedItemList.Free;
  end;
  SendRootItemList.Free;
end;

{ TDesAutoSendHandle }

procedure TDesAutoSendHandle.Update;
var
  SendRootItemList : TStringList;
  OnTimeItemList : TStringList;
  SendRootItemID, SourcePath : string;
  j : Integer;
  i: Integer;
begin
  SendRootItemList := SendRootItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to SendRootItemList.Count - 1 do
  begin
    SendRootItemID := SendRootItemList[i];
    if not MyNetPcInfoReadUtil.ReadDesIsOnline( SendRootItemID ) then  // Pc ����
      Continue;
    OnTimeItemList := SendRootItemInfoReadUtil.ReadOnTimeSendList( SendRootItemID );
    for j := 0 to OnTimeItemList.Count - 1 do
    begin
      SourcePath := OnTimeItemList[j];
      SendItemUserApi.WaitingSendSelectNetworkItem( SendRootItemID, SourcePath );
    end;
    OnTimeItemList.Free;
  end;
  SendRootItemList.Free;
end;

end.
