unit UMyTimerThread;

interface

uses SysUtils, Generics.Collections, classes, SyncObjs, DateUtils, udebuglock;

type

    // 数据结构
  TTimerDataInfo = class
  public
    HandleType : string;
    SecondInterval : Integer;
  public
    IsNowCheck : Boolean;
    LastTime : TDateTime;
  public
    constructor Create( _HandleType : string );
    procedure SetSecondInterval( _SecondInterval : Integer );
  end;
  TTimerDataList = class( TObjectList<TTimerDataInfo> )end;

    // 处理线程
  TTimerHandleThread = class( TDebugThread )
  public
    DataLock : TCriticalSection;
    TimerDataList : TTimerDataList;
  public
    constructor Create;
    procedure IniTimerData;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddTimer( HandleType : string; SecondInterval : Integer );
    procedure RemoveTimer( HandleType : string );
    procedure NowCheck( HandleType : string );
  private
    procedure HandleCheck;
    procedure HandleTimer( HandleType : string );
  end;

    // 操作对象
  TMyTimerHandler = class
  public
    IsRun : Boolean;
    TimerHandleThread : TTimerHandleThread;
  public
    constructor Create;
    procedure StartRun;
    procedure StopRun;
  public
    procedure AddTimer( HandleType : string; SecondInterval : Integer );
    procedure RemoveTimer( HandleType : string );
    procedure NowCheck( HandleType : string );
  end;

const
  HandleType_RefreshSpeed = 'RefreshSpeed';
  HandleType_SendBusy = 'SendBusy';
  HandleType_SendLostConn = 'SendLostConn';
  HandleType_SendIncompleted = 'SendIncompleted';
  HandleType_AutoSend = 'AutoSend';
  HandleType_ShareDownBusy = 'ShareDownBusy';
  HandleType_ShareDownLostConn = 'ShareDownLostConn';
  HandleType_ShareDownIncompleted = 'ShareDownIncompleted';
  HandleType_SaveXml = 'SaveXml';

  HandleType_RestartNetwork = 'RestartNetwork';
  HandleType_PortMapping = 'PortMapping';
  HandleType_RefreshConnecting = 'RefreshConnecting';
  HandleType_ClientHeartBeat = 'ClientHeartBeat';
  HandleType_RegisterTimeCheck = 'RegisterTimeCheck';
  HandleType_MarkAppRunTime = 'MarkAppRunTime';
  HandleType_MakePiracyError = 'MakePiracyError';
  HandleType_ShowPiracyError = 'ShowPiracyError';
  HandleType_DownloadRarDll = 'DownloadRarDll';
  HandleType_ShareDownConnHeart = 'ShareDownConnHeart';
  HandleType_SendFileConnHeart = 'SendFileConnHeart';
  HandleType_CheckAppUpdate = 'CheckAppUpdate';

var
  MyTimerHandler : TMyTimerHandler;

implementation

uses UAutoSendThread, UAutoShareDownThread, UMainFormThread, USearchServer, UMyClient,
     URegisterThread, UFolderTransfer, UAppEditionInfo, UShareDownThread, USendThread, UXmlUtil;

{ TTimerDataInfo }

constructor TTimerDataInfo.Create(_HandleType: string);
begin
  HandleType := _HandleType;
  LastTime := Now;
  IsNowCheck := False;
end;

procedure TTimerDataInfo.SetSecondInterval(_SecondInterval: Integer);
begin
  SecondInterval := _SecondInterval;
end;

{ TTimerHandleThread }

procedure TTimerHandleThread.AddTimer(HandleType: string;
  SecondInterval: Integer);
var
  TimerData : TTimerDataInfo;
begin
    // 添加
  DataLock.Enter;
  try
    TimerData := TTimerDataInfo.Create( HandleType );
    TimerData.SetSecondInterval( SecondInterval );
    TimerDataList.Add( TimerData );
  except
  end;
  DataLock.Leave;
end;

constructor TTimerHandleThread.Create;
begin
  inherited Create;
  DataLock := TCriticalSection.Create;
  TimerDataList := TTimerDataList.Create;
  IniTimerData;
end;

destructor TTimerHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  TimerDataList.Free;
  DataLock.Free;
  inherited;
end;

procedure TTimerHandleThread.Execute;
var
  i: Integer;
begin
  while not Terminated do
  begin
      // 1秒钟检测一次
    for i := 1 to 10 do
      if not Terminated then
        Sleep( 100 );

      // 结束程序
    if Terminated then
      Break;

      // 检测需要执行的操作
    DataLock.Enter;
    try
      HandleCheck;
    except
    end;
    DataLock.Leave;
  end;
  inherited;
end;

procedure TTimerHandleThread.HandleCheck;
var
  i: Integer;
  TimerData : TTimerDataInfo;
begin
  for i := 0 to TimerDataList.Count - 1 do
  begin
    try
      if i >= TimerDataList.Count then
        Break;
      TimerData := TimerDataList[i];
      if TimerData.IsNowCheck or ( SecondsBetween( Now, TimerData.LastTime ) >= TimerData.SecondInterval ) then
      begin
        HandleTimer( TimerData.HandleType );
        TimerData.IsNowCheck := False;
        TimerData.LastTime := Now;
      end;
    except
    end;
  end;
end;

procedure TTimerHandleThread.HandleTimer(HandleType: string);
begin
  if HandleType = HandleType_SendBusy then
    MyAutoSendApi.CheckBusySend
  else
  if HandleType = HandleType_SendLostConn then
    MyAutoSendApi.CheckLostConnectSend
  else
  if HandleType = HandleType_SendIncompleted then
    MyAutoSendApi.CheckIncompletedSend
  else
  if HandleType = HandleType_AutoSend then
    MyAutoSendApi.CheckAutoSend
  else
  if HandleType = HandleType_ShareDownBusy then
    MyAutoShareDownApi.CheckShareDownBusy
  else
  if HandleType = HandleType_ShareDownLostConn then
    MyAutoShareDownApi.CheckShareDownLostConn
  else
  if HandleType = HandleType_ShareDownIncompleted then
    MyAutoShareDownApi.CheckShareDownIncompleted
  else
  if HandleType = HandleType_RefreshSpeed then
    MyRefreshSpeedHandler.RefreshSpeed
  else
  if HandleType = HandleType_RestartNetwork then
    MySearchMasterTimerApi.CheckRestartNetwork
  else
  if HandleType = HandleType_PortMapping then
    MySearchMasterTimerApi.MakePortMapping
  else
  if HandleType = HandleType_ClientHeartBeat then
    MyClientOnTimerApi.SendHeartBeat
  else
  if HandleType = HandleType_RefreshConnecting then
    MySearchMasterTimerApi.RefreshConnecting
  else
  if HandleType = HandleType_RegisterTimeCheck then
    MyRegisterAutoApi.UpdateRunTime
  else
  if HandleType = HandleType_MarkAppRunTime then
    MyFolderTransferAutoApi.MarkAppRunTime
  else
  if HandleType = HandleType_MakePiracyError then
    MyAppPiracyAutoApi.MakeAppError
  else
  if HandleType = HandleType_DownloadRarDll then
    MyFolderTransferAutoApi.DownloadRarDllFile
  else
  if HandleType = HandleType_ShareDownConnHeart then
    MyShareDownConnectHandler.LastConnRefresh
  else
  if HandleType = HandleType_SendFileConnHeart then
    MyFileSendConnectHandler.LastConnRefresh
  else
  if HandleType = HandleType_SaveXml then
    MyXmlSaveAutoApi.SaveNow
  else
  if HandleType = HandleType_CheckAppUpdate then
    MyFolderTransferAutoApi.CheckAppUpdate
  else
  if HandleType = HandleType_ShowPiracyError then
    MyAppPiracyAutoApi.ShowCreackedEdition;
end;

procedure TTimerHandleThread.IniTimerData;
var
  TimerData : TTimerDataInfo;
begin
    // 定时检测 自动备份
  TimerData := TTimerDataInfo.Create( HandleType_RefreshSpeed );
  TimerData.SetSecondInterval( 1 );
  TimerDataList.Add( TimerData );

    // 定时检测 发送 Busy
  TimerData := TTimerDataInfo.Create( HandleType_SendBusy );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 发送 LostConn
  TimerData := TTimerDataInfo.Create( HandleType_SendLostConn );
  TimerData.SetSecondInterval( 60 );
  TimerDataList.Add( TimerData );

    // 定时检测 发送 Incompleted
  TimerData :=TTimerDataInfo.Create( HandleType_SendIncompleted );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 发送 Incompleted
  TimerData :=TTimerDataInfo.Create( HandleType_AutoSend );
  TimerData.SetSecondInterval( 60 );
  TimerDataList.Add( TimerData );

    // 定时检测 共享下载 Busy
  TimerData := TTimerDataInfo.Create( HandleType_ShareDownBusy );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 共享下载 LostConn
  TimerData := TTimerDataInfo.Create( HandleType_ShareDownLostConn );
  TimerData.SetSecondInterval( 60 );
  TimerDataList.Add( TimerData );

    // 定时检测 共享下载 Incompleted
  TimerData :=TTimerDataInfo.Create( HandleType_ShareDownIncompleted );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时 保存 Xml
  TimerData := TTimerDataInfo.Create( HandleType_SaveXml );
  TimerData.SetSecondInterval( 600 );
  TimerDataList.Add( TimerData );
end;

procedure TTimerHandleThread.NowCheck(HandleType: string);
var
  i: Integer;
begin
  DataLock.Enter;
  try
    for i := 0 to TimerDataList.Count - 1 do
      if TimerDataList[i].HandleType = HandleType then
      begin
        TimerDataList[i].IsNowCheck := True;
        Break;
      end;
  except
  end;
  DataLock.Leave;
end;

procedure TTimerHandleThread.RemoveTimer(HandleType: string);
var
  i: Integer;
begin
    // 删除
  DataLock.Enter;
  try
    for i := 0 to TimerDataList.Count - 1 do
      if TimerDataList[i].HandleType = HandleType then
      begin
        TimerDataList.Delete( i );
        Break;
      end;
  except
  end;
  DataLock.Leave;
end;

{ TMyTimerHandler }

procedure TMyTimerHandler.AddTimer(HandleType: string; SecondInterval: Integer);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.AddTimer( HandleType, SecondInterval );
end;

constructor TMyTimerHandler.Create;
begin
  IsRun := True;
  TimerHandleThread := TTimerHandleThread.Create;
end;

procedure TMyTimerHandler.NowCheck(HandleType: string);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.NowCheck( HandleType );
end;

procedure TMyTimerHandler.RemoveTimer(HandleType: string);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.RemoveTimer( HandleType );
end;

procedure TMyTimerHandler.StartRun;
begin
  TimerHandleThread.Resume;
end;

procedure TMyTimerHandler.StopRun;
begin
  IsRun := False;

  TimerHandleThread.Free;
end;

end.
