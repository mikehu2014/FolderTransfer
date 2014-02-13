unit UNetworkControl;

interface

uses Sockets, USearchServer, UMyNetPcInfo, UMyMaster, Menus, classes;

type

{$Region ' ������Ϣ �����޸� ' }

    // ��ȡ
  TMyPcInfoReadHandle = class
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort, _InternetPort : string );
    procedure Update;virtual;
  protected
    procedure SetToInfo;
    procedure SetToFace;virtual;
  end;

    // ��һ������
  TMyPcInfoFirstSetHandle = class( TMyPcInfoReadHandle )
  public
    procedure Update;override;
  protected
    procedure SetToXml;
  end;

    // ����
  TMyPcInfoSetHandle = class( TMyPcInfoFirstSetHandle )
  protected
    procedure SetToFace;override;
  end;

    // ������ʱ Lan Ip
  TMyPcInfoSetTempLanIpHandle = class
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

      // ���� ������ Ip
  TMyPcInfoSetLanIpHandle = class
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

      // ���� �������˿ں�
  TMyPcInfoSetLanPortHandle = class
  public
    LanPort : string;
  public
    constructor Create( _LanPort : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetInternetIpHandle = class
  public
    InternetIp : string;
  public
    constructor Create( _InternetIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetInternetPortHandle = class
  public
    InternetPort : string;
  public
    constructor Create( _InternetPort : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

  TMyPcInfoSetParams = record
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  end;

{$EndRegion}

{$Region ' ����Pc �����޸� ' }

    // ����
  TNetPcChangeHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

  {$Region ' ��ɾ��Ϣ ' }

    // ��ȡ
  TNetPcReadHandle = class( TNetPcChangeHandle )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToMainFace;
  end;

    // ��� ��Pc ��Ϣ
  TNetPcAddHandle = class( TNetPcReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToNetworkStatus;
    procedure AddToNetworkError;
  end;

  {$EndRegion}

  {$Region ' λ����Ϣ ' }

   // ��ȡ ����������Ϣ
  TNetPcSocketReadHandle = class( TNetPcChangeHandle )
  public
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    procedure Update;virtual;
  private
    procedure SetToInfo;
  end;

    // ���� ����������Ϣ
  TNetPcSetSocketHandle = class( TNetPcSocketReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
    procedure SetToNetworkStatus;
  end;

    // ���� �Ƿ������� Pc
  TNetPcSetCanConnectToHandle = class( TNetPcChangeHandle )
  private
    CanConnectTo : Boolean;
  public
    procedure SetCanConnectTo( _CanConnectTo : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // ���� �Ƿ��ܱ� Pc ����
  TNetPcSetCanConnectFromHandle = class( TNetPcChangeHandle )
  private
    CanConnectFrom : Boolean;
  public
    procedure SetCanConnectFrom( _CanConnectFrom : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

  {$EndRegion}

  {$Region ' ״̬��Ϣ ' }

    // ��������Pc��Ϣ
  TNetworkPcResetHandle = class
  public
    procedure Update;
  end;

    // ���� Pc ��Ϊ ������
  TNetPcBeServerHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToNetworkStatus;
  end;

    // ���� Pc ����
  TNetPcOnlineHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToEvent;
    procedure SetToNetworkStatus;
  end;

    // ���� Pc ����
  TNetPcOfflineHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToEvent;
    procedure SetToNetworkStatus;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ����״̬ ' }

    // �޸�
  TNetworkStatusWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ��ȡ
  TNetworkStatusAddHandle = class( TNetworkStatusWriteHandle )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;


    // ɾ��
  TNetworkStatusRemoveHandle = class( TNetworkStatusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

      // �޸�
  TNetworkStatusSetConnectInfoHandle = class( TNetworkStatusWriteHandle )
  public
    Ip, Port : string;
    IsConnect, IsLanConn : boolean;
  public
    procedure SetConnectInfo( _Ip, _Port : string; _IsConnect, _IsLanConn : boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;


      // �޸�
  TNetworkStatusSetIsOnlineHandle = class( TNetworkStatusWriteHandle )
  public
    IsOnline : boolean;
  public
    procedure SetIsOnline( _IsOnline : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;


      // �޸�
  TNetworkStatusSetIsServerHandle = class( TNetworkStatusWriteHandle )
  public
    IsServer : boolean;
  public
    procedure SetIsServer( _IsServer : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

      // �޸�
  TNetworkStatusClearItemHandle = class
  public
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}

{$Region ' Group �޸� ' }

    // �޸�
  TNetworkGroupWriteHandle = class
  public
    GroupName : string;
  public
    constructor Create( _GroupName : string );
  end;
  
    // ��ȡ
  TNetworkGroupReadHandle = class( TNetworkGroupWriteHandle )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;
  
    // ���
  TNetworkGroupAddHandle = class( TNetworkGroupReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // �޸�
  TNetworkGroupSetPasswordHandle = class( TNetworkGroupWriteHandle )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;
  
    // ɾ��
  TNetworkGroupRemoveHandle = class( TNetworkGroupWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' ConnToPc �޸� ' }

    // �޸�
  TNetworkPcConnWriteHandle = class
  public
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
  end;
  
    // ��ȡ
  TNetworkPcConnReadHandle = class( TNetworkPcConnWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;
  
    // ���
  TNetworkPcConnAddHandle = class( TNetworkPcConnReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;
  
    // ɾ��
  TNetworkPcConnRemoveHandle = class( TNetworkPcConnWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;
  


{$EndRegion}

{$Region ' NetworkMode �޸� ' }

    // ��ȡ ����ģʽ
  TNetworkModeReadHandle = class
  public
    SelectType : string;
    SelectValue1, SelectValue2 : string;
  public
    constructor Create( _SelectType : string );
    procedure SetValue( _SelectValue1, _SelectValue2 : string );
    procedure Update;virtual;
  protected
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� ����ģʽ
  TNetworkModeSetHandle = class( TNetworkModeReadHandle )
  public
    procedure Update;override;
  protected
    procedure SetToXml;
  end;

    // ����Group����
  TJoinAGroupHandle = class
  protected
    GroupName, Password : string;
  public
    constructor Create( _GroupName, _Password : string );
    procedure Update;
  private       // �������͵����ݱ仯
    procedure AddGroup;
    function SetPassword: Boolean;
  end;

    // ����һ̨ Pc
  TConnToPcHandle = class
  public
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
    procedure Update;
  private
    procedure AddToPc;
  end;

{$EndRegion}


    // ���ñ�����Ϣ Api
  MyPcInfoApi = class
  public
    class procedure SetItem( Params : TMyPcInfoSetParams );
    class procedure SetLanIp( LanIp : string );
    class procedure SetLanPort( LanPort : string );
    class procedure SetInternetIp( InternetIp : string );
    class procedure SetInternetPort( InternetPort : string );
  public
    class procedure SetTempLanIp( LanIp : string );
  end;


  NetworkPcApi = class
  public
    class procedure AddItem( PcID, PcName : string );
    class procedure PcOnline( PcID : string );
    class procedure PcOffline( PcID : string );
    class procedure BeServer( PcID : string );
  public
    class procedure SetSocketInfo( PcID, Ip, Port : string; IsLanConn : Boolean );
    class procedure SetCanConnectTo( PcID : string; CanConnectTo : Boolean );
    class procedure SetCanConnectFrom( PcID : string; CanConnectFrom : Boolean );
  public
    class procedure RestartNetwork;
  end;

  NetworkConnStatusShowApi = class
  public
    class procedure SetNotConnected;
    class procedure SetConnecting;
    class procedure SetConnected;
  public
    class procedure SetNotChangeNetwork;
    class procedure SetCanChangeNetwork;
  end;

  NetworkModeApi = class
  public              // Local Network �޸�
    class procedure SelectLocalNetwork;
    class procedure SelectLocalConn( PcID : string ); // �����������ӵĶ˿�
  public              // Group �޸�
    class procedure AddGroup( GroupName, Password : string );
    class procedure SetPassword( GroupName, Password : string );
    class procedure RemoveGroup( GroupName : string );
    class procedure SelectGroup( GroupName : string );
  public              // Conn To Pc �޸�
    class procedure AddConnToPc( Domain, Port : string );
    class procedure RemoveConnToPc( Domain, Port : string );
    class procedure SelectConnToPc( Domain, Port : string );
  public              // ���� ����ģʽ
    class procedure SetNetworkMode( SelectType, SelectValue1, SelectValue2 : string );
    class procedure RefreshSecurity;
  public             // ��������
    class procedure RestartNetwork;
    class procedure PmSelectGroupFace( Sender : TObject );
    class procedure PmSelectConnToPcFace( Sender : TObject );
  public             // �������
    class procedure JoinAGroup( GroupName, Password : string );
    class procedure ConnToAPc( Domain, Port : string );
  public              // ��������
    class procedure EnterLan;
    class procedure EnterGroup( GroupName : string );
    class procedure EnterConnToPc( Domain, Port : string );
  public              // Group ����
    class procedure PasswordError( GroupName : string );
    class procedure AccountNotExist( GroupName, Password : string );
  public              // Connect to Pc ����
    class procedure DnsIpError( Domain, Port : string );
    class procedure CloudIDError;
  end;

    // ����״̬
  NetworkStatusApi = class
  public
    class procedure AddItem( PcID, PcName : string );
    class procedure SetConnInfo( PcID, Ip, Port : string; IsConnect, IsLanConn : Boolean );
    class procedure SetIsOnline( PcID : string; IsOnline : Boolean );
    class procedure SetIsServer( PcID : string; IsServer : Boolean );
    class procedure ClearItem;
  end;

    // �ҵ�����״̬
  MyNetworkStatusApi = class
  public
    class procedure LanConnections;
    class procedure GroupConnections( GroupName : string );
    class procedure ConnToPcConnections( PcSocketInfo : string );
  public
    class procedure SetBroadcastDisable;
    class procedure SetBroadcastPort( BroadcastPort, ErrorStr : string );
  public
    class procedure SetLanSocket( LanIp, LanPort : string );
    class procedure SetLanSocketSuccess;
  public
    class procedure SetInternetSocket( InternetIp, InternetPort : string );
    class procedure SetInternetSocketSuccess;
  public
    class procedure SetIsExistUpnp( IsExist : Boolean; UpnpUrl : string );
    class procedure SetIsPortMapCompleted( IsCompleted : Boolean );
  end;

    // ��������ʧ�ܵ�״̬
  NetworkErrorStatusApi = class
  public
    class procedure ShowNoPc;
    class procedure ShowNoEditionMatch( Ip : string; IsNewEdition : Boolean );
    class procedure ShowGroupNotExist( GroupName : string );
    class procedure ShowGroupPasswordError( GroupName : string );
  public
    class procedure ShowIpError( Domain, Port : string );
    class procedure ShowCannotConn( Domain, Port : string );
    class procedure ShowSecurityError( Domain, Port : string );
  public
    class procedure ShowConnAgainRemain( RemainSecond : Integer );
    class procedure HideError;
    class procedure HideNoPcError;
  end;

  NetworkConnEditionErrorApi = class
  public
    class procedure AddItem( Ip, PcName : string );
    class procedure RemoveItem( Ip : string );
    class procedure ClearItem;
  end;

const
  SelectConnType_Local = 'Local';
  SelectConnType_Group = 'Group';
  SelectConnType_ConnPC = 'ConnPc';

implementation

uses  UNetworkFace, UMainForm, UNetPcInfoXml, UFormSetting, UNetworkEventInfo, UMyUtil, USettingInfo, UMainApi;


{ TNetPcChangeHandle }

constructor TNetPcChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetPcSetSocketHandle }

procedure TNetPcSetSocketHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetConnInfo( PcID, Ip, Port, True, IsLanConn );
end;

procedure TNetPcSetSocketHandle.SetToXml;
var
  NetPcSocketXml : TNetPcSocketXml;
begin
    // д Xml
  NetPcSocketXml := TNetPcSocketXml.Create( PcID );
  NetPcSocketXml.SetSocket( Ip, Port );
  NetPcSocketXml.SetIsLanConn( IsLanConn );
  NetPcSocketXml.AddChange;
end;

procedure TNetPcSetSocketHandle.Update;
begin
  inherited;
  SetToXml;
  SetToNetworkStatus;
end;

{ TNetPcBeMasterHandle }

procedure TNetPcBeServerHandle.SetToInfo;
var
  NetPcServerInfo : TNetPcServerInfo;
begin
  NetPcServerInfo := TNetPcServerInfo.Create( PcID );
  NetPcServerInfo.Update;
  NetPcServerInfo.Free;
end;

procedure TNetPcBeServerHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsServer( PcID, True );
end;

procedure TNetPcBeServerHandle.Update;
begin
  SetToInfo;
  SetToNetworkStatus;
end;

{ TNetPcOnlineHandle }

procedure TNetPcOnlineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOnline( PcID );
end;

procedure TNetPcOnlineHandle.SetToInfo;
var
  NetPcOnlineInfo : TNetPcOnlineInfo;
begin
  NetPcOnlineInfo := TNetPcOnlineInfo.Create( PcID );
  NetPcOnlineInfo.Update;
  NetPcOnlineInfo.Free;
end;

procedure TNetPcOnlineHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsOnline( PcID, True );
end;

procedure TNetPcOnlineHandle.Update;
begin
  SetToInfo;
  SetToEvent;
  SetToNetworkStatus;
end;

{ TNetPcReadHandle }

procedure TNetPcReadHandle.AddToInfo;
var
  NetPcAddInfo : TNetPcAddInfo;
begin
    // д �ڴ�
  NetPcAddInfo := TNetPcAddInfo.Create( PcID );
  NetPcAddInfo.SetPcName( PcName );
  NetPcAddInfo.Update;
  NetPcAddInfo.Free;
end;

procedure TNetPcReadHandle.AddToMainFace;
begin
  if PcID = PcInfo.PcID then
    Exit;

    // ��ʾ���Ͱ�ť
  MyHintAppApi.ShowSendFileBtn;
end;

procedure TNetPcReadHandle.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcReadHandle.Update;
begin
  AddToInfo;
  AddToMainFace;
end;

{ TNetPcSocketReadHandle }

procedure TNetPcSocketReadHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TNetPcSocketReadHandle.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketReadHandle.SetToInfo;
var
  NetPcSocketInfo : TNetPcSocketInfo;
begin
    // д �ڴ�
  NetPcSocketInfo := TNetPcSocketInfo.Create( PcID );
  NetPcSocketInfo.SetSocket( Ip, Port );
  NetPcSocketInfo.SetIsLanConn( IsLanConn );
  NetPcSocketInfo.Update;
  NetPcSocketInfo.Free;
end;

procedure TNetPcSocketReadHandle.Update;
begin
  SetToInfo;
end;

{ TNetworkPcResetHandle }

procedure TNetworkPcResetHandle.Update;
var
  ActivatePcList : TStringList;
  i: Integer;
begin
    // ���pc������
  ActivatePcList := MyNetPcInfoReadUtil.ReadActivatePcList;
  for i := 0 to ActivatePcList.Count - 1 do
    NetworkPcApi.PcOffline( ActivatePcList[i] );
  ActivatePcList.Free;

    // ������ӵ�Pc
  NetworkStatusApi.ClearItem;

    // ˢ�� ��ȫ
  NetworkModeApi.RefreshSecurity;

    // ���
  NetworkConnEditionErrorApi.ClearItem;
end;

{ TNetPcOfflineHandle }

procedure TNetPcOfflineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOffline( PcID );
end;

procedure TNetPcOfflineHandle.SetToInfo;
var
  NetPcOfflineInfo : TNetPcOfflineInfo;
begin
  NetPcOfflineInfo := TNetPcOfflineInfo.Create( PcID );
  NetPcOfflineInfo.Update;
  NetPcOfflineInfo.Free;
end;

procedure TNetPcOfflineHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsOnline( PcID, False );
end;

procedure TNetPcOfflineHandle.Update;
begin
  SetToInfo;
  SetToEvent;
  SetToNetworkStatus;
end;

{ TNetPcAddCloudHandle }

procedure TNetPcAddHandle.AddToNetworkError;
begin
    // ����
  if PcID = PcInfo.PcID then
    Exit;

    // ��������������
  NetworkErrorStatusApi.HideNoPcError;
end;

procedure TNetPcAddHandle.AddToNetworkStatus;
begin
  NetworkStatusApi.AddItem( PcID, PcName );
end;

procedure TNetPcAddHandle.AddToXml;
var
  NetPcAddXml : TNetPcAddXml;
begin
    // д Xml
  NetPcAddXml := TNetPcAddXml.Create( PcID );
  NetPcAddXml.SetPcName( PcName );
  NetPcAddXml.AddChange;
end;

procedure TNetPcAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToNetworkStatus;
  AddToNetworkError;
end;

{ NetworkPcApi }

class procedure NetworkPcApi.AddItem(PcID, PcName: string);
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( PcID );
  NetPcAddHandle.SetPcName( PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

class procedure NetworkPcApi.BeServer(PcID: string);
var
  NetPcBeServerHandle : TNetPcBeServerHandle;
begin
  NetPcBeServerHandle := TNetPcBeServerHandle.Create( PcID );
  NetPcBeServerHandle.Update;
  NetPcBeServerHandle.Free;
end;

class procedure NetworkPcApi.PcOffline(PcID: string);
var
  NetPcOfflineHandle : TNetPcOfflineHandle;
begin
  NetPcOfflineHandle := TNetPcOfflineHandle.Create( PcID );
  NetPcOfflineHandle.Update;
  NetPcOfflineHandle.Free;
end;

class procedure NetworkPcApi.PcOnline(PcID: string);
var
  NetPcOnlineHandle : TNetPcOnlineHandle;
begin
  NetPcOnlineHandle := TNetPcOnlineHandle.Create( PcID );
  NetPcOnlineHandle.Update;
  NetPcOnlineHandle.Free;
end;

class procedure NetworkPcApi.RestartNetwork;
begin
  MySearchMasterHandler.RestartNetwork;
end;

class procedure NetworkPcApi.SetCanConnectFrom(PcID: string;
  CanConnectFrom: Boolean);
var
  NetPcSetCanConnectFromHandle : TNetPcSetCanConnectFromHandle;
begin
  NetPcSetCanConnectFromHandle := TNetPcSetCanConnectFromHandle.Create( PcID );
  NetPcSetCanConnectFromHandle.SetCanConnectFrom( CanConnectFrom );
  NetPcSetCanConnectFromHandle.Update;
  NetPcSetCanConnectFromHandle.Free;
end;

class procedure NetworkPcApi.SetCanConnectTo(PcID: string;
  CanConnectTo: Boolean);
var
  NetPcSetCanConnectToHandle : TNetPcSetCanConnectToHandle;
begin
  NetPcSetCanConnectToHandle := TNetPcSetCanConnectToHandle.Create( PcID );
  NetPcSetCanConnectToHandle.SetCanConnectTo( CanConnectTo );
  NetPcSetCanConnectToHandle.Update;
  NetPcSetCanConnectToHandle.Free;
end;

class procedure NetworkPcApi.SetSocketInfo(PcID, Ip, Port: string;
  IsLanConn: Boolean);
var
  NetPcSetSocketHandle : TNetPcSetSocketHandle;
begin
  NetPcSetSocketHandle := TNetPcSetSocketHandle.Create( PcID );
  NetPcSetSocketHandle.SetSocket( Ip, Port );
  NetPcSetSocketHandle.SetIsLanConn( IsLanConn );
  NetPcSetSocketHandle.Update;
  NetPcSetSocketHandle.Free;
end;
{ NetworkModeApi }

class procedure NetworkModeApi.AddConnToPc(Domain, Port: string);
var
  NetworkPcConnAddHandle : TNetworkPcConnAddHandle;
begin
  NetworkPcConnAddHandle := TNetworkPcConnAddHandle.Create( Domain, Port );
  NetworkPcConnAddHandle.Update;
  NetworkPcConnAddHandle.Free;
end;
  


class procedure NetworkModeApi.AddGroup(GroupName, Password: string);
var
  NetworkGroupAddHandle : TNetworkGroupAddHandle;
begin
  NetworkGroupAddHandle := TNetworkGroupAddHandle.Create( GroupName );
  NetworkGroupAddHandle.SetPassword( Password );
  NetworkGroupAddHandle.Update;
  NetworkGroupAddHandle.Free;
end;
  

class procedure NetworkModeApi.ConnToAPc(Domain, Port: string);
var
  ConnToPcHandle : TConnToPcHandle;
begin
  ConnToPcHandle := TConnToPcHandle.Create( Domain, Port );
  ConnToPcHandle.Update;
  ConnToPcHandle.Free;
end;

class procedure NetworkModeApi.EnterConnToPc(Domain, Port: string);
begin
  SelectConnToPc( Domain, Port );
  RestartNetwork;
end;

class procedure NetworkModeApi.EnterGroup(GroupName: string);
begin
  SelectGroup( GroupName );
  RestartNetwork;
end;

class procedure NetworkModeApi.EnterLan;
begin
  SelectLocalNetwork;
  RestartNetwork;
end;

class procedure NetworkModeApi.JoinAGroup(GroupName, Password: string);
var
  JoinAGroupHandle : TJoinAGroupHandle;
begin
  JoinAGroupHandle := TJoinAGroupHandle.Create( GroupName, Password );
  JoinAGroupHandle.Update;
  JoinAGroupHandle.Free;
end;

class procedure NetworkModeApi.PmSelectConnToPcFace(Sender: TObject);
var
  miConnToPc : TMenuItem;
  ShowList : TStringList;
  PcStr : string;
begin
  miConnToPc := sender as TMenuItem;

  if miConnToPc.ImageIndex = -1 then
  begin
    PcStr := miConnToPc.Caption;
    if ComputerName_After <> '' then
      Delete( PcStr, pos( ComputerName_After, PcStr ), length( ComputerName_After ) );
    ShowList := MySplitStr.getList( PcStr, SplitStr_ConnPc );
    if ShowList.Count = 2 then
      NetworkModeApi.EnterConnToPc( ShowList[0], ShowList[1] );
    ShowList.Free;
  end
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

class procedure NetworkModeApi.PmSelectGroupFace(Sender: TObject);
var
  miGroup : TMenuItem;
  GroupName : string;
begin
  miGroup := sender as TMenuItem;

  if miGroup.ImageIndex = -1 then
  begin
    GroupName := miGroup.Caption;
    if GroupName_After <> '' then
      Delete( GroupName, Pos( GroupName_After, GroupName ), length( GroupName_After ) );
    NetworkModeApi.EnterGroup( GroupName )
  end
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

class procedure NetworkModeApi.RefreshSecurity;
var
  SbNetworkSecuritySetFace : TSbNetworkSecuritySetFace;
begin
  SbNetworkSecuritySetFace := TSbNetworkSecuritySetFace.Create;
  SbNetworkSecuritySetFace.SetIsSecurity( CloudSafeSettingInfo.IsCloudSafe );
  SbNetworkSecuritySetFace.AddChange;
end;

class procedure NetworkModeApi.RemoveConnToPc(Domain, Port: string);
var
  NetworkPcConnRemoveHandle : TNetworkPcConnRemoveHandle;
begin
  NetworkPcConnRemoveHandle := TNetworkPcConnRemoveHandle.Create( Domain, Port );
  NetworkPcConnRemoveHandle.Update;
  NetworkPcConnRemoveHandle.Free;
end;
  

class procedure NetworkModeApi.RemoveGroup(GroupName: string);
var
  NetworkGroupRemoveHandle : TNetworkGroupRemoveHandle;
begin
  NetworkGroupRemoveHandle := TNetworkGroupRemoveHandle.Create( GroupName );
  NetworkGroupRemoveHandle.Update;
  NetworkGroupRemoveHandle.Free;
end;
  


class procedure NetworkModeApi.RestartNetwork;
begin
      // ��������
  MySearchMasterHandler.RestartNetwork;
end;

class procedure NetworkModeApi.SelectConnToPc(Domain, Port: string);
begin
  SetNetworkMode( SelectConnType_ConnPC, Domain, Port );
end;

class procedure NetworkModeApi.SelectGroup(GroupName: string);
begin
  SetNetworkMode( SelectConnType_Group, GroupName, '' );
end;

class procedure NetworkModeApi.SelectLocalConn(PcID: string);
begin
  if MyNetworkConnInfo.SelectType = SelectConnType_Local then
    MyNetworkConnInfo.SelectValue1 := PcID;
end;

class procedure NetworkModeApi.SelectLocalNetwork;
begin
  SetNetworkMode( SelectConnType_Local, '', '' );
end;

class procedure NetworkModeApi.SetNetworkMode(SelectType, SelectValue1,
  SelectValue2: string);
var
  NetworkModeSetHandle : TNetworkModeSetHandle;
begin
  NetworkModeSetHandle := TNetworkModeSetHandle.Create( SelectType );
  NetworkModeSetHandle.SetValue( SelectValue1, SelectValue2 );
  NetworkModeSetHandle.Update;
  NetworkModeSetHandle.Free;
end;


class procedure NetworkModeApi.SetPassword(GroupName, Password: string);
var
  NetworkGroupSetPasswordHandle : TNetworkGroupSetPasswordHandle;
begin
  NetworkGroupSetPasswordHandle := TNetworkGroupSetPasswordHandle.Create( GroupName );
  NetworkGroupSetPasswordHandle.SetPassword( Password );
  NetworkGroupSetPasswordHandle.Update;
  NetworkGroupSetPasswordHandle.Free;
end;
  

constructor TNetworkGroupWriteHandle.Create( _GroupName : string );
begin
  GroupName := _GroupName;
end;

{ TNetworkGroupReadHandle }

procedure TNetworkGroupReadHandle.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupReadHandle.AddToInfo;
var
  NetworkGroupAddInfo : TNetworkGroupAddInfo;
begin
  NetworkGroupAddInfo := TNetworkGroupAddInfo.Create( GroupName );
  NetworkGroupAddInfo.SetPassword( Password );
  NetworkGroupAddInfo.Update;
  NetworkGroupAddInfo.Free;
end;

procedure TNetworkGroupReadHandle.AddToFace;
var
  NetworkGroupAddFace : TPmGroupAddFace;
  CbbGroupAddFace : TCbbGroupAddFace;
begin
  NetworkGroupAddFace := TPmGroupAddFace.Create( GroupName );
  NetworkGroupAddFace.AddChange;

  CbbGroupAddFace := TCbbGroupAddFace.Create( GroupName );
  CbbGroupAddFace.SetPassword( Password );
  CbbGroupAddFace.AddChange;
end;

procedure TNetworkGroupReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetworkGroupAddHandle }

procedure TNetworkGroupAddHandle.AddToXml;
var
  NetworkGroupAddXml : TNetworkGroupAddXml;
begin
  NetworkGroupAddXml := TNetworkGroupAddXml.Create( GroupName );
  NetworkGroupAddXml.SetPassword( Password );
  NetworkGroupAddXml.AddChange;
end;

procedure TNetworkGroupAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetworkGroupRemoveHandle }

procedure TNetworkGroupRemoveHandle.RemoveFromInfo;
var
  NetworkGroupRemoveInfo : TNetworkGroupRemoveInfo;
begin
  NetworkGroupRemoveInfo := TNetworkGroupRemoveInfo.Create( GroupName );
  NetworkGroupRemoveInfo.Update;
  NetworkGroupRemoveInfo.Free;
end;

procedure TNetworkGroupRemoveHandle.RemoveFromFace;
var
  NetworkGroupRemoveFace : TPmGroupRemoveFace;
  CbbGroupRemoveFace : TCbbGroupRemoveFace;
begin
  NetworkGroupRemoveFace := TPmGroupRemoveFace.Create( GroupName );
  NetworkGroupRemoveFace.AddChange;

  CbbGroupRemoveFace := TCbbGroupRemoveFace.Create( GroupName );
  CbbGroupRemoveFace.AddChange;
end;

procedure TNetworkGroupRemoveHandle.RemoveFromXml;
var
  NetworkGroupRemoveXml : TNetworkGroupRemoveXml;
begin
  NetworkGroupRemoveXml := TNetworkGroupRemoveXml.Create( GroupName );
  NetworkGroupRemoveXml.AddChange;
end;

procedure TNetworkGroupRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TNetworkGroupSetPasswordHandle }

procedure TNetworkGroupSetPasswordHandle.SetToInfo;
var
  NetworkGroupSetPasswordInfo : TNetworkGroupSetPasswordInfo;
begin
  NetworkGroupSetPasswordInfo := TNetworkGroupSetPasswordInfo.Create( GroupName );
  NetworkGroupSetPasswordInfo.SetPassword( Password );
  NetworkGroupSetPasswordInfo.Update;
  NetworkGroupSetPasswordInfo.Free;
end;

procedure TNetworkGroupSetPasswordHandle.SetToXml;
var
  NetworkGroupSetPasswordXml : TNetworkGroupSetPasswordXml;
begin
  NetworkGroupSetPasswordXml := TNetworkGroupSetPasswordXml.Create( GroupName );
  NetworkGroupSetPasswordXml.SetPassword( Password );
  NetworkGroupSetPasswordXml.AddChange;
end;

procedure TNetworkGroupSetPasswordHandle.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TNetworkGroupSetPasswordHandle.SetToFace;
var
  CbbGroupSetPasswordFace : TCbbGroupSetPasswordFace;
begin
  CbbGroupSetPasswordFace := TCbbGroupSetPasswordFace.Create( GroupName );
  CbbGroupSetPasswordFace.SetPassword( Password );
  CbbGroupSetPasswordFace.AddChange;
end;

procedure TNetworkGroupSetPasswordHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

constructor TNetworkPcConnWriteHandle.Create( _Domain, _Port : string );
begin
  Domain := _Domain;
  Port := _Port;
end;

{ TNetworkPcConnReadHandle }

procedure TNetworkPcConnReadHandle.AddToInfo;
var
  NetworkPcConnAddInfo : TNetworkPcConnAddInfo;
begin
  NetworkPcConnAddInfo := TNetworkPcConnAddInfo.Create( Domain, Port );
  NetworkPcConnAddInfo.Update;
  NetworkPcConnAddInfo.Free;
end;

procedure TNetworkPcConnReadHandle.AddToFace;
var
  NetworkPcConnAddFace : TPmPcConnAddFace;
  CbbConnToPcAddFace : TCbbConnToPcAddFace;
begin
  NetworkPcConnAddFace := TPmPcConnAddFace.Create( Domain, Port );
  NetworkPcConnAddFace.AddChange;

  CbbConnToPcAddFace := TCbbConnToPcAddFace.Create( Domain, Port );
  CbbConnToPcAddFace.AddChange;
end;

procedure TNetworkPcConnReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetworkPcConnAddHandle }

procedure TNetworkPcConnAddHandle.AddToXml;
var
  NetworkPcConnAddXml : TNetworkPcConnAddXml;
begin
  NetworkPcConnAddXml := TNetworkPcConnAddXml.Create( Domain, Port );
  NetworkPcConnAddXml.AddChange;
end;

procedure TNetworkPcConnAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetworkPcConnRemoveHandle }

procedure TNetworkPcConnRemoveHandle.RemoveFromInfo;
var
  NetworkPcConnRemoveInfo : TNetworkPcConnRemoveInfo;
begin
  NetworkPcConnRemoveInfo := TNetworkPcConnRemoveInfo.Create( Domain, Port );
  NetworkPcConnRemoveInfo.Update;
  NetworkPcConnRemoveInfo.Free;
end;

procedure TNetworkPcConnRemoveHandle.RemoveFromFace;
var
  NetworkPcConnRemoveFace : TPmPcConnRemoveFace;
  CbbConnToPcRemoveFace : TCbbConnToPcRemoveFace;
begin
  NetworkPcConnRemoveFace := TPmPcConnRemoveFace.Create( Domain, Port );
  NetworkPcConnRemoveFace.AddChange;

  CbbConnToPcRemoveFace := TCbbConnToPcRemoveFace.Create( Domain, Port );
  CbbConnToPcRemoveFace.AddChange;
end;

procedure TNetworkPcConnRemoveHandle.RemoveFromXml;
var
  NetworkPcConnRemoveXml : TNetworkPcConnRemoveXml;
begin
  NetworkPcConnRemoveXml := TNetworkPcConnRemoveXml.Create( Domain, Port );
  NetworkPcConnRemoveXml.AddChange;
end;

procedure TNetworkPcConnRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;


{ TNetworkModeSetHandle }

procedure TNetworkModeSetHandle.SetToXml;
var
  NetworkModeChangeXml : TNetworkModeChangeXml;
begin
  NetworkModeChangeXml := TNetworkModeChangeXml.Create( SelectType );
  NetworkModeChangeXml.SetValue( SelectValue1, SelectValue2 );
  NetworkModeChangeXml.AddChange;
end;

procedure TNetworkModeSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TNetworkModeReadHandle }

constructor TNetworkModeReadHandle.Create(_SelectType: string);
begin
  SelectType := _SelectType;
end;

procedure TNetworkModeReadHandle.SetToFace;
var
  NetworkModeSelectFace : TPmNetworkModeSelectFace;
  CbbNetworkModeSelectFace : TCbbNetworkModeSelectFace;
begin
  NetworkModeSelectFace := TPmNetworkModeSelectFace.Create( SelectType );
  NetworkModeSelectFace.SetValue( SelectValue1, SelectValue2 );
  NetworkModeSelectFace.AddChange;

  CbbNetworkModeSelectFace := TCbbNetworkModeSelectFace.Create( SelectType );
  CbbNetworkModeSelectFace.SetValue( SelectValue1, SelectValue2 );
  CbbNetworkModeSelectFace.AddChange;
end;

procedure TNetworkModeReadHandle.SetToInfo;
begin
  MyNetworkConnInfo.SelectType := SelectType;
  MyNetworkConnInfo.SelectValue1 := SelectValue1;
  MyNetworkConnInfo.SelectValue2 := SelectValue2;
end;

procedure TNetworkModeReadHandle.SetValue(_SelectValue1, _SelectValue2: string);
begin
  SelectValue1 := _SelectValue1;
  SelectValue2 := _SelectValue2;
end;

procedure TNetworkModeReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TJoinAGroupHandle }

procedure TJoinAGroupHandle.AddGroup;
begin
    // �Ѵ���
  if NetworkGroupInfoReadUtil.ReadIsExist( GroupName ) then
    Exit;

    // ���
  NetworkModeApi.AddGroup( GroupName, Password );
end;

constructor TJoinAGroupHandle.Create(_GroupName, _Password: string);
begin
  GroupName := _GroupName;
  Password := _Password;
end;

function TJoinAGroupHandle.SetPassword: Boolean;
begin
  Result := False;

    // ������ͬ
  if NetworkGroupInfoReadUtil.ReadPassword( GroupName ) = Password then
    Exit;

    // �޸�����
  NetworkModeApi.SetPassword( GroupName, Password );

  Result := True;
end;

procedure TJoinAGroupHandle.Update;
var
  IsChangePassword : Boolean;
begin
  AddGroup;
  IsChangePassword := SetPassword;

    // �Ѿ���������
  if ( MyNetworkConnInfo.SelectType = SelectConnType_Group ) and
     ( MyNetworkConnInfo.SelectValue1 = GroupName ) and
       not IsChangePassword
  then
    Exit;

    // ѡ�� Group ����
  NetworkModeApi.SelectGroup( GroupName );

    // ��������
  NetworkModeApi.RestartNetwork;
end;

{ TConnToPcHandle }

procedure TConnToPcHandle.AddToPc;
begin
    // �Ѵ���
  if NetworkConnToPcInfoReadUtil.ReadIsExist( Domain, Port ) then
    Exit;

    // ���
  NetworkModeApi.AddConnToPc( Domain, Port );
end;

constructor TConnToPcHandle.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TConnToPcHandle.Update;
begin
    // ������� Pc
  AddToPc;

    // ��ѡ��
  if ( MyNetworkConnInfo.SelectType = SelectConnType_ConnPC ) and
     ( MyNetworkConnInfo.SelectValue1 = Domain ) and
     ( MyNetworkConnInfo.SelectValue2 = Port )
  then
    Exit;

    // ����ѡ�������
  NetworkModeApi.SelectConnToPc( Domain, Port );

    // ��������
  NetworkPcApi.RestartNetwork;
end;

{ NetworkConnStatusShowApi }

class procedure NetworkConnStatusShowApi.SetCanChangeNetwork;
var
  PmNetworkOpenChangeInfo : TPmNetworkOpenChangeInfo;
begin
    // ���Ըı�����
  PmNetworkOpenChangeInfo := TPmNetworkOpenChangeInfo.Create;
  MyNetworkFace.AddChange( PmNetworkOpenChangeInfo );
end;

class procedure NetworkConnStatusShowApi.SetConnected;
var
  SbMyStatusConnInfo : TSbMyStatusConnInfo;
begin
  SbMyStatusConnInfo := TSbMyStatusConnInfo.Create;
  MyNetworkFace.AddChange( SbMyStatusConnInfo );
end;

class procedure NetworkConnStatusShowApi.SetConnecting;
var
  SbMyStatusConningInfo : TSbMyStatusConningInfo;
begin
  SbMyStatusConningInfo := TSbMyStatusConningInfo.Create;
  MyNetworkFace.AddChange( SbMyStatusConningInfo );
end;

class procedure NetworkConnStatusShowApi.SetNotChangeNetwork;
var
  PmNetworkCloseChangeInfo : TPmNetworkCloseChangeInfo;
begin
    // ���ܸı�����
  PmNetworkCloseChangeInfo := TPmNetworkCloseChangeInfo.Create;
  MyNetworkFace.AddChange( PmNetworkCloseChangeInfo );
end;

class procedure NetworkConnStatusShowApi.SetNotConnected;
var
  SbMyStatusNotConnInfo : TSbMyStatusNotConnInfo;
begin
  SbMyStatusNotConnInfo := TSbMyStatusNotConnInfo.Create;
  MyNetworkFace.AddChange( SbMyStatusNotConnInfo );
end;

{ NetworkStatusApi }

class procedure NetworkStatusApi.AddItem(PcID, PcName: string);
var
  NetworkStatusAddHandle : TNetworkStatusAddHandle;
begin
  NetworkStatusAddHandle := TNetworkStatusAddHandle.Create( PcID );
  NetworkStatusAddHandle.SetPcName( PcName );
  NetworkStatusAddHandle.Update;
  NetworkStatusAddHandle.Free;
end;



class procedure NetworkStatusApi.ClearItem;
var
  NetworkStatusClearItemHandle : TNetworkStatusClearItemHandle;
begin
  NetworkStatusClearItemHandle := TNetworkStatusClearItemHandle.Create;
  NetworkStatusClearItemHandle.Update;
  NetworkStatusClearItemHandle.Free;
end;

class procedure NetworkStatusApi.SetConnInfo(PcID, Ip, Port: string;
  IsConnect, IsLanConn: Boolean);
var
  NetworkStatusSetConnectInfoHandle : TNetworkStatusSetConnectInfoHandle;
begin
  NetworkStatusSetConnectInfoHandle := TNetworkStatusSetConnectInfoHandle.Create( PcID );
  NetworkStatusSetConnectInfoHandle.SetConnectInfo( Ip, Port, IsConnect, IsLanConn );
  NetworkStatusSetConnectInfoHandle.Update;
  NetworkStatusSetConnectInfoHandle.Free;
end;





class procedure NetworkStatusApi.SetIsOnline(PcID: string; IsOnline: Boolean);
var
  NetworkStatusSetIsOnlineHandle : TNetworkStatusSetIsOnlineHandle;
begin
  NetworkStatusSetIsOnlineHandle := TNetworkStatusSetIsOnlineHandle.Create( PcID );
  NetworkStatusSetIsOnlineHandle.SetIsOnline( IsOnline );
  NetworkStatusSetIsOnlineHandle.Update;
  NetworkStatusSetIsOnlineHandle.Free;
end;



class procedure NetworkStatusApi.SetIsServer(PcID: string; IsServer: Boolean);
var
  NetworkStatusSetIsServerHandle : TNetworkStatusSetIsServerHandle;
begin
  NetworkStatusSetIsServerHandle := TNetworkStatusSetIsServerHandle.Create( PcID );
  NetworkStatusSetIsServerHandle.SetIsServer( IsServer );
  NetworkStatusSetIsServerHandle.Update;
  NetworkStatusSetIsServerHandle.Free;
end;



constructor TNetworkStatusWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;

{ TNetworkStatusReadHandle }

procedure TNetworkStatusAddHandle.SetPcName( _PcName : string );
begin
  PcName := _PcName;
end;

procedure TNetworkStatusAddHandle.AddToFace;
var
  NetworkStatusAddFace : TNetworkStatusAddFace;
begin
  NetworkStatusAddFace := TNetworkStatusAddFace.Create( PcID );
  NetworkStatusAddFace.SetPcName( PcName );
  NetworkStatusAddFace.AddChange;
end;

procedure TNetworkStatusAddHandle.Update;
begin
  AddToFace;
end;


{ TNetworkStatusRemoveHandle }


procedure TNetworkStatusRemoveHandle.RemoveFromFace;
var
  NetworkStatusRemoveFace : TNetworkStatusRemoveFace;
begin
  NetworkStatusRemoveFace := TNetworkStatusRemoveFace.Create( PcID );
  NetworkStatusRemoveFace.AddChange;
end;

procedure TNetworkStatusRemoveHandle.Update;
begin
  RemoveFromFace;
end;

{ TNetworkStatusSetConnectInfoHandle }

procedure TNetworkStatusSetConnectInfoHandle.SetConnectInfo( _Ip, _Port : string;
  _IsConnect, _IsLanConn : boolean );
begin
  Ip := _Ip;
  Port := _Port;
  IsConnect := _IsConnect;
  IsLanConn := _IsLanConn;
end;

procedure TNetworkStatusSetConnectInfoHandle.SetToFace;
var
  NetworkStatusSetConnectInfoFace : TNetworkStatusSetConnectInfoFace;
begin
  NetworkStatusSetConnectInfoFace := TNetworkStatusSetConnectInfoFace.Create( PcID );
  NetworkStatusSetConnectInfoFace.SetConnectInfo( Ip, Port, IsConnect, IsLanConn );
  NetworkStatusSetConnectInfoFace.AddChange;
end;

procedure TNetworkStatusSetConnectInfoHandle.Update;
begin
  SetToFace;
end;

{ TNetworkStatusSetIsOnlineHandle }

procedure TNetworkStatusSetIsOnlineHandle.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TNetworkStatusSetIsOnlineHandle.SetToFace;
var
  NetworkStatusSetIsOnlineFace : TNetworkStatusSetIsOnlineFace;
begin
  NetworkStatusSetIsOnlineFace := TNetworkStatusSetIsOnlineFace.Create( PcID );
  NetworkStatusSetIsOnlineFace.SetIsOnline( IsOnline );
  NetworkStatusSetIsOnlineFace.AddChange;
end;

procedure TNetworkStatusSetIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TNetworkStatusSetIsServerHandle }

procedure TNetworkStatusSetIsServerHandle.SetIsServer( _IsServer : boolean );
begin
  IsServer := _IsServer;
end;

procedure TNetworkStatusSetIsServerHandle.SetToFace;
var
  NetworkStatusSetIsServerFace : TNetworkStatusSetIsServerFace;
begin
  NetworkStatusSetIsServerFace := TNetworkStatusSetIsServerFace.Create( PcID );
  NetworkStatusSetIsServerFace.SetIsServer( IsServer );
  NetworkStatusSetIsServerFace.AddChange;
end;

procedure TNetworkStatusSetIsServerHandle.Update;
begin
  SetToFace;
end;









{ TMyPcInfoReadHandle }

constructor TMyPcInfoReadHandle.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TMyPcInfoReadHandle.SetSocketInfo(_LanIp, _LanPort,
  _InternetPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoReadHandle.SetToFace;
var
  MyPcInfoRaadFace : TMyPcInfoRaadFace;
begin
  MyPcInfoRaadFace := TMyPcInfoRaadFace.Create( PcID, PcName );
  MyPcInfoRaadFace.SetSocketInfo( LanIp, LanPort, InternetPort );
  MyPcInfoRaadFace.AddChange;
end;

procedure TMyPcInfoReadHandle.SetToInfo;
begin
  PcInfo.PcID := PcID;
  PcInfo.PcName := PcName;
  PcInfo.LanIp := LanIp;
  PcInfo.LanPort := LanPort;
  PcInfo.InternetPort := InternetPort;

  PcInfo.RealLanIp := LanIp;
end;

procedure TMyPcInfoReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TMyPcInfoSetHandle }

procedure TMyPcInfoFirstSetHandle.SetToXml;
var
  MyPcInfoSetXml : TMyPcInfoSetXml;
begin
  MyPcInfoSetXml := TMyPcInfoSetXml.Create( PcID, PcName );
  MyPcInfoSetXml.SetSocketInfo( LanIp, LanPort, InternetPort );
  MyPcInfoSetXml.AddChange;
end;

procedure TMyPcInfoFirstSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TMyPcInfoSetHandle }

procedure TMyPcInfoSetHandle.SetToFace;
begin

end;

{ TMyPcInfoSetLanPortHandle }

constructor TMyPcInfoSetLanPortHandle.Create(_LanPort: string);
begin
  LanPort := _LanPort;
end;

procedure TMyPcInfoSetLanPortHandle.SetToFace;
var
  MyPcInfoSetLanPortFace : TMyPcInfoSetLanPortFace;
begin
  MyPcInfoSetLanPortFace := TMyPcInfoSetLanPortFace.Create( LanPort );
  MyPcInfoSetLanPortFace.AddChange;
end;

procedure TMyPcInfoSetLanPortHandle.SetToInfo;
begin
  PcInfo.LanPort := LanPort;
end;

procedure TMyPcInfoSetLanPortHandle.SetToXml;
var
  MyPcInfoSetLanPortXml : TMyPcInfoSetLanPortXml;
begin
  MyPcInfoSetLanPortXml := TMyPcInfoSetLanPortXml.Create( LanPort );
  MyPcInfoSetLanPortXml.AddChange;
end;

procedure TMyPcInfoSetLanPortHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TMyPcInfoSetInternetPortHandle }

constructor TMyPcInfoSetInternetPortHandle.Create(_InternetPort: string);
begin
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToFace;
var
  MyPcInfoSetInternetPortFace : TMyPcInfoSetInternetPortFace;
begin
  MyPcInfoSetInternetPortFace := TMyPcInfoSetInternetPortFace.Create( InternetPort );
  MyPcInfoSetInternetPortFace.AddChange;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToInfo;
begin
  PcInfo.InternetPort := InternetPort;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToXml;
var
  MyPcInfoSetInternetPortXml : TMyPcInfoSetInternetPortXml;
begin
  MyPcInfoSetInternetPortXml := TMyPcInfoSetInternetPortXml.Create( InternetPort );
  MyPcInfoSetInternetPortXml.AddChange;
end;

procedure TMyPcInfoSetInternetPortHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ MyPcInfoApi }

class procedure MyPcInfoApi.SetInternetIp(InternetIp: string);
var
  MyPcInfoSetInternetIpHandle : TMyPcInfoSetInternetIpHandle;
begin
  MyPcInfoSetInternetIpHandle := TMyPcInfoSetInternetIpHandle.Create( InternetIp );
  MyPcInfoSetInternetIpHandle.Update;
  MyPcInfoSetInternetIpHandle.Free;
end;

class procedure MyPcInfoApi.SetInternetPort(InternetPort: string);
var
  MyPcInfoSetInternetPortHandle : TMyPcInfoSetInternetPortHandle;
begin
  MyPcInfoSetInternetPortHandle := TMyPcInfoSetInternetPortHandle.Create( InternetPort );
  MyPcInfoSetInternetPortHandle.Update;
  MyPcInfoSetInternetPortHandle.Free;
end;

class procedure MyPcInfoApi.SetItem(Params: TMyPcInfoSetParams);
var
  MyPcInfoSetHandle : TMyPcInfoSetHandle;
begin
  MyPcInfoSetHandle := TMyPcInfoSetHandle.Create( Params.PcID, Params.PcName );
  MyPcInfoSetHandle.SetSocketInfo( Params.LanIp, Params.LanPort, Params.InternetPort );
  MyPcInfoSetHandle.Update;
  MyPcInfoSetHandle.Free;
end;

class procedure MyPcInfoApi.SetLanIp(LanIp: string);
var
  MyPcInfoSetLanIpHandle : TMyPcInfoSetLanIpHandle;
begin
  MyPcInfoSetLanIpHandle := TMyPcInfoSetLanIpHandle.Create( LanIp );
  MyPcInfoSetLanIpHandle.Update;
  MyPcInfoSetLanIpHandle.Free;
end;

class procedure MyPcInfoApi.SetLanPort(LanPort: string);
var
  MyPcInfoSetLanPortHandle : TMyPcInfoSetLanPortHandle;
begin
  MyPcInfoSetLanPortHandle := TMyPcInfoSetLanPortHandle.Create( LanPort );
  MyPcInfoSetLanPortHandle.Update;
  MyPcInfoSetLanPortHandle.Free;
end;

class procedure MyPcInfoApi.SetTempLanIp(LanIp: string);
var
  MyPcInfoSetTempLanIpHandle : TMyPcInfoSetTempLanIpHandle;
begin
  MyPcInfoSetTempLanIpHandle := TMyPcInfoSetTempLanIpHandle.Create( LanIp );
  MyPcInfoSetTempLanIpHandle.Update;
  MyPcInfoSetTempLanIpHandle.Free;
end;

{ TMyPcInfoSetLanIpHandle }

constructor TMyPcInfoSetLanIpHandle.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetLanIpHandle.SetToFace;
var
  MyPcInfoSetLanIpFace : TMyPcInfoSetLanIpFace;
begin
  MyPcInfoSetLanIpFace := TMyPcInfoSetLanIpFace.Create( LanIp );
  MyPcInfoSetLanIpFace.AddChange;
end;

procedure TMyPcInfoSetLanIpHandle.SetToInfo;
begin
  PcInfo.LanIp := LanIp;
  PcInfo.RealLanIp := LanIp;
end;

procedure TMyPcInfoSetLanIpHandle.SetToXml;
var
  MyPcInfoSetLanIpXml : TMyPcInfoSetLanIpXml;
begin
  MyPcInfoSetLanIpXml := TMyPcInfoSetLanIpXml.Create( LanIp );
  MyPcInfoSetLanIpXml.AddChange;
end;

procedure TMyPcInfoSetLanIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TMyPcInfoSetInternetIpHandle }

constructor TMyPcInfoSetInternetIpHandle.Create(_InternetIp: string);
begin
  InternetIp := _InternetIp;
end;

procedure TMyPcInfoSetInternetIpHandle.SetToFace;
var
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
    // ��ʾ�� Setting ����
  InternetSocketChangeInfo := TInternetSocketChangeInfo.Create( InternetIp );
  MyNetworkFace.AddChange( InternetSocketChangeInfo );
end;

procedure TMyPcInfoSetInternetIpHandle.SetToInfo;
begin
  PcInfo.InternetIp := InternetIp;
end;

procedure TMyPcInfoSetInternetIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ MyNetworkStatusApi }

class procedure MyNetworkStatusApi.ConnToPcConnections( PcSocketInfo : string );
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_ConnToPc );
  MyPcStatusNetworkModeSetFace.SetDetailShow( PcSocketInfo );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.GroupConnections( GroupName : string );
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_Group );
  MyPcStatusNetworkModeSetFace.SetDetailShow( GroupName );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.LanConnections;
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_LAN );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetBroadcastDisable;
var
  MyPcStatusBroadcastDisableFace : TMyPcStatusBroadcastDisableFace;
begin
  MyPcStatusBroadcastDisableFace := TMyPcStatusBroadcastDisableFace.Create;
  MyPcStatusBroadcastDisableFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetBroadcastPort(BroadcastPort, ErrorStr: string);
var
  MyPcStatusBroadcastSetPortFace : TMyPcStatusBroadcastSetPortFace;
begin
  MyPcStatusBroadcastSetPortFace := TMyPcStatusBroadcastSetPortFace.Create( BroadcastPort );
  MyPcStatusBroadcastSetPortFace.SetErrorStr( ErrorStr );
  MyPcStatusBroadcastSetPortFace.AddChange;
end;


class procedure MyNetworkStatusApi.SetInternetSocket(InternetIp,
  InternetPort: string);
var
  MyPcStatusInternetSetSocketFace : TMyPcStatusInternetSetSocketFace;
begin
  MyPcStatusInternetSetSocketFace := TMyPcStatusInternetSetSocketFace.Create( InternetIp, InternetPort );
  MyPcStatusInternetSetSocketFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetInternetSocketSuccess;
var
  MyPcStatusInternetSuccessFace : TMyPcStatusInternetSuccessFace;
begin
  MyPcStatusInternetSuccessFace := TMyPcStatusInternetSuccessFace.Create;
  MyPcStatusInternetSuccessFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetLanSocket(LanIp, LanPort: string);
var
  MyPcStatusLanSetSocketFace : TMyPcStatusLanSetSocketFace;
begin
  MyPcStatusLanSetSocketFace := TMyPcStatusLanSetSocketFace.Create( LanIp, LanPort );
  MyPcStatusLanSetSocketFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetLanSocketSuccess;
var
  MyPcStatusLanSuccessFace : TMyPcStatusLanSuccessFace;
begin
  MyPcStatusLanSuccessFace := TMyPcStatusLanSuccessFace.Create;
  MyPcStatusLanSuccessFace.AddChange;
end;

{ NetworkErrorStatusApi }

class procedure NetworkErrorStatusApi.HideError;
var
  PlNetworkConnHideInfo : TPlNetworkConnHideInfo;
begin
  PlNetworkConnHideInfo := TPlNetworkConnHideInfo.Create;
  PlNetworkConnHideInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.HideNoPcError;
var
  PlNetworkNoPcHideInfo : TPlNetworkNoPcHideInfo;
begin
  PlNetworkNoPcHideInfo := TPlNetworkNoPcHideInfo.Create;
  PlNetworkNoPcHideInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowCannotConn( Domain, Port : string );
var
  PlNetworkNotConnShowInfo : TPlNetworkConnPcError;
begin
  PlNetworkNotConnShowInfo := TPlNetworkConnPcError.Create;
  PlNetworkNotConnShowInfo.SetConnPcInfo( Domain, Port );
  PlNetworkNotConnShowInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowConnAgainRemain(
  RemainSecond: Integer);
var
  PlNetworkConnRemainInfo : TPlNetworkConnRemainInfo;
begin
  PlNetworkConnRemainInfo := TPlNetworkConnRemainInfo.Create( RemainSecond );
  PlNetworkConnRemainInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowGroupNotExist;
var
  PlNetworkGroupNotExist : TPlNetworkGroupNotExist;
begin
  PlNetworkGroupNotExist := TPlNetworkGroupNotExist.Create;
  PlNetworkGroupNotExist.SetGroupName( GroupName );
  PlNetworkGroupNotExist.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowGroupPasswordError(GroupName: string);
var
  PlNetworkGroupPasswordError : TPlNetworkGroupPasswordError;
begin
  PlNetworkGroupPasswordError := TPlNetworkGroupPasswordError.Create;
  PlNetworkGroupPasswordError.SetGroupName( GroupName );
  PlNetworkGroupPasswordError.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowIpError(Domain, Port: string);
var
  PlNetworkConnPcIpError : TPlNetworkConnPcIpError;
begin
  PlNetworkConnPcIpError := TPlNetworkConnPcIpError.Create;
  PlNetworkConnPcIpError.SetConnPcInfo( Domain, Port );
  PlNetworkConnPcIpError.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowNoEditionMatch( Ip : string;
  IsNewEdition : Boolean );
var
  PlNetworkPcNewEditionShowInfo : TPlNetworkPcNewEditionShowInfo;
  PlNetworkPcOldEditionShowInfo : TPlNetworkPcOldEditionShowInfo;
  PcName : string;
begin
    // �������°汾�� ��ʾ����
  if IsNewEdition then
  begin
    PlNetworkPcNewEditionShowInfo := TPlNetworkPcNewEditionShowInfo.Create;
    PlNetworkPcNewEditionShowInfo.AddChange;
    Exit;
  end;

    // �����˾ɰ汾
  PlNetworkPcOldEditionShowInfo := TPlNetworkPcOldEditionShowInfo.Create;
  PlNetworkPcOldEditionShowInfo.AddChange;

  PcName := MyNetPcInfoReadUtil.ReadPcNameByIp( Ip );
  NetworkConnEditionErrorApi.AddItem( Ip, PcName );
end;

class procedure NetworkErrorStatusApi.ShowNoPc;
var
  PlNetworkNotPcShowInfo : TPlNetworkNotPcShowInfo;
begin
  PlNetworkNotPcShowInfo := TPlNetworkNotPcShowInfo.Create;
  PlNetworkNotPcShowInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowSecurityError( Domain, Port : string );
var
  PlNetworkConnPcSecurityNumberError : TPlNetworkConnPcSecurityNumberError;
begin
  PlNetworkConnPcSecurityNumberError := TPlNetworkConnPcSecurityNumberError.Create;
  PlNetworkConnPcSecurityNumberError.SetConnPcInfo( Domain, Port );
  PlNetworkConnPcSecurityNumberError.AddChange;
end;

{ TNetworkStatusClearItemHandle }

procedure TNetworkStatusClearItemHandle.SetToFace;
var
  NetworkStatusClearFace : TNetworkStatusClearFace;
begin
  NetworkStatusClearFace := TNetworkStatusClearFace.Create;
  NetworkStatusClearFace.AddChange;
end;

procedure TNetworkStatusClearItemHandle.Update;
begin
  SetToFace;
end;

{ TNetPcSetCanConnectToHandle }

procedure TNetPcSetCanConnectToHandle.SetCanConnectTo(_CanConnectTo: Boolean);
begin
  CanConnectTo := _CanConnectTo;
end;

procedure TNetPcSetCanConnectToHandle.SetToInfo;
var
  NetPcSetCanConnectToInfo : TNetPcSetCanConnectToInfo;
begin
  NetPcSetCanConnectToInfo := TNetPcSetCanConnectToInfo.Create( PcID );
  NetPcSetCanConnectToInfo.SetCanConnectTo( CanConnectTo );
  NetPcSetCanConnectToInfo.Update;
  NetPcSetCanConnectToInfo.Free;
end;

procedure TNetPcSetCanConnectToHandle.Update;
begin
  SetToInfo;
end;

{ TNetPcSetCanConnectFromHandle }

procedure TNetPcSetCanConnectFromHandle.SetCanConnectFrom(_CanConnectFrom: Boolean);
begin
  CanConnectFrom := _CanConnectFrom;
end;

procedure TNetPcSetCanConnectFromHandle.SetToInfo;
var
  NetPcSetCanConnectFromInfo : TNetPcSetCanConnectFromInfo;
begin
  NetPcSetCanConnectFromInfo := TNetPcSetCanConnectFromInfo.Create( PcID );
  NetPcSetCanConnectFromInfo.SetCanConnectFrom( CanConnectFrom );
  NetPcSetCanConnectFromInfo.Update;
  NetPcSetCanConnectFromInfo.Free;
end;

procedure TNetPcSetCanConnectFromHandle.Update;
begin
  SetToInfo;
end;

class procedure NetworkModeApi.PasswordError(GroupName: string);
var
  StandardPasswordError : TStandardPasswordError;
begin
  StandardPasswordError := TStandardPasswordError.Create( GroupName );
  StandardPasswordError.AddChange;
end;

class procedure NetworkModeApi.AccountNotExist(GroupName, Password: string);
var
  StandardAccountError : TStandardAccountError;
begin
  StandardAccountError := TStandardAccountError.Create( GroupName );
  StandardAccountError.SetPassword( Password );
  StandardAccountError.AddChange;
end;

class procedure NetworkModeApi.DnsIpError(Domain, Port: string);
var
  AdvanceDnsError : TAdvanceDnsError;
begin
  AdvanceDnsError := TAdvanceDnsError.Create( Domain, Port );
  AdvanceDnsError.AddChange;
end;

class procedure NetworkModeApi.CloudIDError;
var
  AdvanceSecurityIDError : TAdvanceSecurityIDError;
begin
  AdvanceSecurityIDError := TAdvanceSecurityIDError.Create;
  AdvanceSecurityIDError.AddChange;
end;

{ NetworkConnEditionErrorApi }

class procedure NetworkConnEditionErrorApi.AddItem(Ip, PcName: string);
var
  ConnEditionAddFace : TConnEditionAddFace;
begin
  ConnEditionAddFace := TConnEditionAddFace.Create( Ip );
  ConnEditionAddFace.SetPcName( PcName );
  ConnEditionAddFace.AddChange;
end;

class procedure NetworkConnEditionErrorApi.ClearItem;
var
  ConnEditionClearFace : TConnEditionClearFace;
begin
  ConnEditionClearFace := TConnEditionClearFace.Create;
  ConnEditionClearFace.AddChange;
end;

class procedure NetworkConnEditionErrorApi.RemoveItem(Ip: string);
var
  ConnEditionRemoveFace : TConnEditionRemoveFace;
begin
  ConnEditionRemoveFace := TConnEditionRemoveFace.Create( Ip );
  ConnEditionRemoveFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetIsExistUpnp(IsExist: Boolean;
  UpnpUrl: string);
var
  MyPcStatusUpnpServerFace : TMyPcStatusUpnpServerFace;
begin
  MyPcStatusUpnpServerFace := TMyPcStatusUpnpServerFace.Create( IsExist, UpnpUrl );
  MyPcStatusUpnpServerFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetIsPortMapCompleted(IsCompleted: Boolean);
var
  MyPcStatusUpnpPortMapFace : TMyPcStatusUpnpPortMapFace;
begin
  MyPcStatusUpnpPortMapFace := TMyPcStatusUpnpPortMapFace.Create( IsCompleted );
  MyPcStatusUpnpPortMapFace.AddChange;
end;


{ TMyPcInfoSetTempLanIpHandle }

constructor TMyPcInfoSetTempLanIpHandle.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetTempLanIpHandle.SetToFace;
var
  MyPcInfoSetLanIpFace : TMyPcInfoSetLanIpFace;
begin
  MyPcInfoSetLanIpFace := TMyPcInfoSetLanIpFace.Create( LanIp );
  MyPcInfoSetLanIpFace.AddChange;
end;

procedure TMyPcInfoSetTempLanIpHandle.SetToInfo;
begin
  PcInfo.LanIp := LanIp;
end;

procedure TMyPcInfoSetTempLanIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

end.

