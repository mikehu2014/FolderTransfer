unit UNetworkEventInfo;

interface

type

    // ����
  TNetworkPcEventBase = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ����
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

    // ����
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

    // �¼�������
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
    // ���� ������ע����Ϣ
  MyRegisterUserApi.SetRegisterOnline( PcID );

    // ע����Ϣ Pc ����
  RegisterShowAppApi.SetIsOnline( PcID, True );

    // ���ͼ�����Ϣ
  RegisterActivatePcApi.PcOnline( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToSendFile;
begin
    // ���÷���Ŀ�� ����
  SendRootItemAppApi.SetNetworkPcIsOnline( PcID, True );

    // ��������
  SendItemAppApi.PcOnlineSend( PcID );
end;

procedure TNetworkPcOnlineEvent.SettoShareDown;
begin
    // �ָ����� ����
  ShareDownAppApi.SetPcOnline( PcID, True );

    // �����ָ� Job
  ShareDownAppApi.CheckPcOnlineRestore( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToReceiveFile;
begin
    // ���ͽ���·���б�
  ReceiveRootItemUserApi.OnlineSendRootList( PcID );

   // ���ý���Ŀ�� ����
  ReceiveItemAppApi.SetPcIsOnline( PcID, True );
end;

procedure TNetworkPcOnlineEvent.SetToShareShow;
begin
    // ���� Pc ����
  MyShareShowRootItemApi.AddNetworkItem( PcID );

    // ���͹����б�
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
