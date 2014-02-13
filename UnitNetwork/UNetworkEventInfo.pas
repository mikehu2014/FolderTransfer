unit UNetworkEventInfo;

interface

type

    // 父类
  TNetworkPcEventBase = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 上线
  TNetworkPcOnlineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToSendFile;
    procedure SetToReceiveFile;
    procedure SetToShareShow;
    procedure SettoShareDown;
    procedure SetToRegister;
  end;

    // 离线
  TNetworkPcOfflineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToSendFile;
    procedure SetToReceiveFile;
    procedure SetToShareShow;
    procedure SetToShareDown;
    procedure SetToRegister;
  end;

    // 事件调用器
  NetworkPcEvent = class
  public
    class procedure PcOnline( PcID : string );
    class procedure PcOffline( PcID : string );
  end;

implementation

uses UMySendApiInfo, UMyReceiveApiInfo, UMyShareDownApiInfo, UMyShareApiInfo, UMyRegisterApiInfo;

{ NetworkPcEvent }

class procedure NetworkPcEvent.PcOffline(PcID: string);
var
  NetworkPcOfflineEvent : TNetworkPcOfflineEvent;
begin
  NetworkPcOfflineEvent := TNetworkPcOfflineEvent.Create( PcID );
  NetworkPcOfflineEvent.Update;
  NetworkPcOfflineEvent.Free;
end;


class procedure NetworkPcEvent.PcOnline(PcID: string);
var
  NetworkPcOnlineEvent : TNetworkPcOnlineEvent;
begin
  NetworkPcOnlineEvent := TNetworkPcOnlineEvent.Create( PcID );
  NetworkPcOnlineEvent.Update;
  NetworkPcOnlineEvent.Free;
end;

{ TNetworkPcEventBase }

constructor TNetworkPcEventBase.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetworkPcOnlineEvent }

procedure TNetworkPcOnlineEvent.SetToRegister;
begin
    // 发送 本机的注册信息
  MyRegisterUserApi.SetRegisterOnline( PcID );

    // 注册信息 Pc 在线
  RegisterShowAppApi.SetIsOnline( PcID, True );

    // 发送激活信息
  RegisterActivatePcApi.PcOnline( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToSendFile;
begin
    // 设置发送目标 上线
  SendRootItemAppApi.SetNetworkPcIsOnline( PcID, True );

    // 上线续传
  SendItemAppApi.PcOnlineSend( PcID );
end;

procedure TNetworkPcOnlineEvent.SettoShareDown;
begin
    // 恢复下载 上线
  ShareDownAppApi.SetPcOnline( PcID, True );

    // 启动恢复 Job
  ShareDownAppApi.CheckPcOnlineRestore( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToReceiveFile;
begin
    // 发送接收路径列表
  ReceiveRootItemUserApi.OnlineSendRootList( PcID );

   // 设置接收目标 上线
  ReceiveItemAppApi.SetPcIsOnline( PcID, True );
end;

procedure TNetworkPcOnlineEvent.SetToShareShow;
begin
    // 共享 Pc 上线
  MyShareShowRootItemApi.AddNetworkItem( PcID );

    // 发送共享列表
  MySharePathApi.OnlineSendShareList( PcID );
end;

procedure TNetworkPcOnlineEvent.Update;
begin
  SetToSendFile;
  SetToReceiveFile;
  SetToShareShow;
  SettoShareDown;
  SetToRegister;
end;

{ TNetworkPcAOfflineEvent }

procedure TNetworkPcOfflineEvent.SetToRegister;
begin
  RegisterShowAppApi.SetIsOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToSendFile;
begin
  SendRootItemAppApi.SetNetworkPcIsOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToReceiveFile;
begin
  ReceiveItemAppApi.SetPcIsOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToShareDown;
begin
  ShareDownAppApi.SetPcOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToShareShow;
begin
  MyShareShowRootItemApi.RemoveItem( PcID );
end;

procedure TNetworkPcOfflineEvent.Update;
begin
  SetToSendFile;
  SetToReceiveFile;
  SetToShareShow;
  SetToShareDown;
  SetToRegister;
end;

end.
