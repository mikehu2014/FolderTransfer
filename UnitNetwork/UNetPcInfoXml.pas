unit UNetPcInfoXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' д ����Group ' }

    // ����
  TNetworkGroupChangeXml = class( TXmlChangeInfo )
  protected
    MyNetworkConnNode : IXMLNode;
    NetworkGroupNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // �޸�
  TNetworkGroupWriteXml = class( TNetworkGroupChangeXml )
  public
    GroupName : string;
  protected
    NetworkGroupIndex : Integer;
    NetworkGroupNode : IXMLNode;
  public
    constructor Create( _GroupName : string );
  protected
    function FindNetworkGroupNode: Boolean;
  end;

    // ����
  TNetworkGroupAddXml = class( TNetworkGroupWriteXml )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;

    // �޸�
  TNetworkGroupSetPasswordXml = class( TNetworkGroupWriteXml )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;


    // ɾ��
  TNetworkGroupRemoveXml = class( TNetworkGroupWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' д ����ConnToPc ' }

    // ����
  TNetworkPcConnChangeXml = class( TXmlChangeInfo )
  protected
    MyNetworkConnNode : IXMLNode;
    NetworkPcConnNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // �޸�
  TNetworkPcConnWriteXml = class( TNetworkPcConnChangeXml )
  public
    Domain, Port : string;
  protected
    NetworkPcConnIndex : Integer;
    NetworkPcConnNode : IXMLNode;
  public
    constructor Create( _Domain, _Port : string );
  protected
    function FindNetworkPcConnNode: Boolean;
  end;

    // ����
  TNetworkPcConnAddXml = class( TNetworkPcConnWriteXml )
  public
  protected
    procedure Update;override;
  end;

    // ɾ��
  TNetworkPcConnRemoveXml = class( TNetworkPcConnWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' д ����ģʽ ' }

  TNetworkModeChangeXml = class( TXmlChangeInfo )
  public
    SelectType : string;
    SelectValue1, SelectValue2 : string;
  public
    constructor Create( _SelectType : string );
    procedure SetValue( _SelectValue1, _SelectValue2 : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д ������Ϣ Xml ' }

    // ����
  TMyPcInfoWriteXml = class( TXmlChangeInfo )
  public
    MyPcNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // �޸� Pc ��Ϣ
  TMyPcInfoSetXml = class( TMyPcInfoWriteXml )
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort, _InternetPort : string );
  protected
    procedure Update;override;
  end;

    // ���� ������ Ip
  TMyPcInfoSetLanIpXml = class( TMyPcInfoWriteXml )
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
  protected
    procedure Update;override;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetLanPortXml = class( TMyPcInfoWriteXml )
  public
    LanPort : string;
  public
    constructor Create( _LanPort : string );
  protected
    procedure Update;override;
  end;

    // ���� �������˿ں�
  TMyPcInfoSetInternetPortXml = class( TMyPcInfoWriteXml )
  public
    InternetPort : string;
  public
    constructor Create( _InternetPort : string );
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' д ����Pc Xml ' }

  TNetPcChangeXml = class( TXmlChangeInfo )
  public
    MyNetPcInfoXml : IXMLNode;
    NetPcHashXml : IXMLNode;
  public
    procedure Update;override;
  end;

    // ���� Pc Ȼ���޸�
  TNetPcWriteXml = class( TNetPcChangeXml )
  public
    PcID : string;
  protected
    NetPcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetPcNode : Boolean;
  end;

    // ���� Pc
  TNetPcAddXml = class( TNetPcWriteXml )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // �޸� Socket
  TNetPcSocketXml = class( TNetPcWriteXml )
  private
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
  protected
    procedure Update;override;
  end;

    // �˿�ӳ���Ƿ�ɹ�
  TNetworkPortMapIsSuccessXml = class( TNetPcChangeXml )
  private
    IsSuccess : Boolean;
  public
    constructor Create( _IsSuccess : Boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' ��ȡ ����Xml ' }

  TMyPcXmlReadHandle = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' �� ���� Xml ' }

    // ��ȡ Pc �ڵ���Ϣ
  TNetPcNodeReadHandle = class
  public
    PcNode : IXMLNode;
  private
    PcID, PcName : string;
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    constructor Create( _PcNode : IXMLNode );
    procedure Update;
  private
    procedure FindPcInfo;
    procedure AddNetworkPc;
    procedure SetPcSocket;
  end;

  TNetPcXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ��ȡ ����ģʽ ' }

    // ��ȡ Group
  TNetworkGroupReadXml = class
  public
    NetworkGroupNode : IXMLNode;
  public
    constructor Create( _NetworkGroupNode : IXMLNode );
    procedure Update;
  end;

    // ��ȡ ConnToPc
  TNetworkPcConnReadXml = class
  public
    NetworkPcConnNode : IXMLNode;
  public
    constructor Create( _NetworkPcConnNode : IXMLNode );
    procedure Update;
  end;


    // ��ȡ����ģʽ
  TNetworkModeXmlRead = class
  private
    MyNetworkConnNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadGroupList;
    procedure ReadConnPcList;
    procedure ReadSelectNetwork;
  end;

{$EndRegion}

const
    // ����������Ϣ
  Xml_MyNetPcInfo  = 'mnpi';
  Xml_NetPcHash = 'nph';

    // Net Pc Info
  Xml_PcID = 'pi';
  Xml_PcName = 'pn';
  Xml_Ip = 'ip';
  Xml_Port = 'pt';
  Xml_IsLanConn = 'ilc';

const
  Xml_MyNetworkConnInfo = 'mnci';
  Xml_SelectType = 'st';
  Xml_SelectValue1 = 'sv1';
  Xml_SelectValue2 = 'sv2';
  Xml_NetworkGroupList = 'ngl';

  Xml_GroupName = 'gn';
  Xml_Password = 'pw';

  Xml_NetworkPcConnList = 'npcl';
  Xml_Domain = 'dm';

const
  Xml_MyPcInfo = 'mpi';
//  Xml_PcID = 'pi';
//  Xml_PcName = 'pn';
  Xml_LanIp = 'li';
  Xml_LanPort = 'lp';
  Xml_InternetPort = 'ip';
  Xml_IsPortMap = 'ipm';

var
  MyNetPcXmlWrite : TMyChildXmlChange;
  PortMap_IsSuccess : Boolean = True;

implementation

uses UMyNetPcInfo, UNetworkFace, UNetworkControl;

{ TNetPcSocketXml }

procedure TNetPcSocketXml.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TNetPcSocketXml.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketXml.Update;
begin
  inherited;

    // ������
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_Ip, Ip );
  MyXmlUtil.AddChild( NetPcNode, Xml_Port, Port );
  MyXmlUtil.AddChild( NetPcNode, Xml_IsLanConn, IsLanConn );
end;

{ TNetPcAddXml }

procedure TNetPcAddXml.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcAddXml.Update;
begin
  inherited;

    // �����ڣ��򴴽�
  if not FindNetPcNode then
  begin
    NetPcNode := MyXmlUtil.AddListChild( NetPcHashXml, PcID );
    MyXmlUtil.AddChild( NetPcNode, Xml_PcID, PcID );
  end;

    // ����
  MyXmlUtil.AddChild( NetPcNode, Xml_PcName, PcName );
end;

{ TNetPcWriteXml }

constructor TNetPcWriteXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TNetPcWriteXml.FindNetPcNode: Boolean;
begin
  NetPcNode := MyXmlUtil.FindListChild( NetPcHashXml, PcID );
  Result := NetPcNode <> nil;
end;

{ TNetPcXmlRead }

procedure TNetPcXmlRead.Update;
var
  MyNetPcInfoXml : IXMLNode;
  NetPcHashXml : IXMLNode;
  i : Integer;
  PcXmlNode : IXMLNode;
  NetPcNodeReadHandle : TNetPcNodeReadHandle;
begin
    // ����������Ϣ�� Xml �ڵ�
  MyNetPcInfoXml := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );

  for i := 0 to NetPcHashXml.ChildNodes.Count - 1 do
  begin
    PcXmlNode := NetPcHashXml.ChildNodes[i];
    NetPcNodeReadHandle := TNetPcNodeReadHandle.Create( PcXmlNode );
    NetPcNodeReadHandle.Update;
    NetPcNodeReadHandle.Free;
  end;
end;

{ TNetPcNodeReadHandle }

procedure TNetPcNodeReadHandle.AddNetworkPc;
var
  NetPcReadHandle : TNetPcReadHandle;
begin
  NetPcReadHandle := TNetPcReadHandle.Create( PcID );
  NetPcReadHandle.SetPcName( PcName );
  NetPcReadHandle.Update;
  NetPcReadHandle.Free;
end;

constructor TNetPcNodeReadHandle.Create(_PcNode: IXMLNode);
begin
  PcNode := _PcNode;
end;

procedure TNetPcNodeReadHandle.FindPcInfo;
begin
    // Pc ��Ϣ
  PcID := MyXmlUtil.GetChildValue( PcNode, Xml_PcID );
  PcName := MyXmlUtil.GetChildValue( PcNode, Xml_PcName );
  Ip := MyXmlUtil.GetChildValue( PcNode, Xml_Ip );
  Port := MyXmlUtil.GetChildValue( PcNode, Xml_Port );
  IsLanConn := StrToBoolDef( MyXmlUtil.GetChildValue( PcNode, Xml_IsLanConn ), True );
end;

procedure TNetPcNodeReadHandle.SetPcSocket;
var
  NetPcSocketReadHandle : TNetPcSocketReadHandle;
begin
  NetPcSocketReadHandle := TNetPcSocketReadHandle.Create( PcID );
  NetPcSocketReadHandle.SetSocket( Ip, Port );
  NetPcSocketReadHandle.SetIsLanConn( IsLanConn );
  NetPcSocketReadHandle.Update;
  NetPcSocketReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.Update;
begin
    // ��ȡ Pc ��Ϣ
  FindPcInfo;

    // ���� Pc ��Ϣ
  AddNetworkPc;
  SetPcSocket;
end;

{ TNetworkGroupChangeXml }

procedure TNetworkGroupChangeXml.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  NetworkGroupNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkGroupList );
end;

{ TNetworkGroupWriteXml }

constructor TNetworkGroupWriteXml.Create( _GroupName : string );
begin
  GroupName := _GroupName;
end;


function TNetworkGroupWriteXml.FindNetworkGroupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to NetworkGroupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := NetworkGroupNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_GroupName ) = GroupName ) then
    begin
      Result := True;
      NetworkGroupIndex := i;
      NetworkGroupNode := NetworkGroupNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TNetworkGroupAddXml }

procedure TNetworkGroupAddXml.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupAddXml.Update;
begin
  inherited;

  if FindNetworkGroupNode then
    Exit;

  NetworkGroupNode := MyXmlUtil.AddListChild( NetworkGroupNodeList );
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_GroupName, GroupName );
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_Password, Password );
end;

{ TNetworkGroupRemoveXml }

procedure TNetworkGroupRemoveXml.Update;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;

  MyXmlUtil.DeleteListChild( NetworkGroupNodeList, NetworkGroupIndex );
end;

{ TNetworkGroupSetPasswordXml }

procedure TNetworkGroupSetPasswordXml.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupSetPasswordXml.Update;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_Password, Password );
end;

{ TNetworkPcConnChangeXml }

procedure TNetworkPcConnChangeXml.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  NetworkPcConnNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkPcConnList );
end;

{ TNetworkPcConnWriteXml }

constructor TNetworkPcConnWriteXml.Create( _Domain, _Port : string );
begin
  Domain := _Domain;
  Port := _Port;
end;


function TNetworkPcConnWriteXml.FindNetworkPcConnNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to NetworkPcConnNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := NetworkPcConnNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_Domain ) = Domain ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_Port ) = Port ) then
    begin
      Result := True;
      NetworkPcConnIndex := i;
      NetworkPcConnNode := NetworkPcConnNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TNetworkPcConnAddXml }

procedure TNetworkPcConnAddXml.Update;
begin
  inherited;

  if FindNetworkPcConnNode then
    Exit;

  NetworkPcConnNode := MyXmlUtil.AddListChild( NetworkPcConnNodeList );
  MyXmlUtil.AddChild( NetworkPcConnNode, Xml_Domain, Domain );
  MyXmlUtil.AddChild( NetworkPcConnNode, Xml_Port, Port );
end;

{ TNetworkPcConnRemoveXml }

procedure TNetworkPcConnRemoveXml.Update;
begin
  inherited;

  if not FindNetworkPcConnNode then
    Exit;

  MyXmlUtil.DeleteListChild( NetworkPcConnNodeList, NetworkPcConnIndex );
end;



{ TNetworkModeChangeXml }

constructor TNetworkModeChangeXml.Create(_SelectType: string);
begin
  SelectType := _SelectType;
end;

procedure TNetworkModeChangeXml.SetValue(_SelectValue1, _SelectValue2: string);
begin
  SelectValue1 := _SelectValue1;
  SelectValue2 := _SelectValue2;
end;

procedure TNetworkModeChangeXml.Update;
var
  MyNetworkConnNode : IXMLNode;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectType, SelectType );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectValue1, SelectValue1 );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectValue2, SelectValue2 );
end;

{ TNetPcChangeXml }

procedure TNetPcChangeXml.Update;
begin
    // ����������Ϣ�� Xml �ڵ�
  MyNetPcInfoXml := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );
end;

{ TNetworkModeXmlRead }

procedure TNetworkModeXmlRead.ReadConnPcList;
var
  NetworkPcConnNodeList : IXMLNode;
  i : Integer;
  NetworkPcConnNode : IXMLNode;
  NetworkPcConnReadXml : TNetworkPcConnReadXml;
begin
  NetworkPcConnNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkPcConnList );
  for i := 0 to NetworkPcConnNodeList.ChildNodes.Count - 1 do
  begin
    NetworkPcConnNode := NetworkPcConnNodeList.ChildNodes[i];
    NetworkPcConnReadXml := TNetworkPcConnReadXml.Create( NetworkPcConnNode );
    NetworkPcConnReadXml.Update;
    NetworkPcConnReadXml.Free;
  end;
end;



procedure TNetworkModeXmlRead.ReadGroupList;
var
  NetworkGroupNodeList : IXMLNode;
  i : Integer;
  NetworkGroupNode : IXMLNode;
  NetworkGroupReadXml : TNetworkGroupReadXml;
begin
  NetworkGroupNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkGroupList );
  for i := 0 to NetworkGroupNodeList.ChildNodes.Count - 1 do
  begin
    NetworkGroupNode := NetworkGroupNodeList.ChildNodes[i];
    NetworkGroupReadXml := TNetworkGroupReadXml.Create( NetworkGroupNode );
    NetworkGroupReadXml.Update;
    NetworkGroupReadXml.Free;
  end;
end;

procedure TNetworkModeXmlRead.ReadSelectNetwork;
var
  SelectType : string;
  SelectValue1, SelectValue2 : string;
  NetworkModeReadHandle : TNetworkModeReadHandle;
begin
  SelectType := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectType );
  SelectValue1 := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectValue1 );
  SelectValue2 := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectValue2 );

    // Ĭ���� ������
  if SelectType = '' then
    SelectType := SelectConnType_Local;

  NetworkModeReadHandle := TNetworkModeReadHandle.Create( SelectType );
  NetworkModeReadHandle.SetValue( SelectValue1, SelectValue2 );
  NetworkModeReadHandle.Update;
  NetworkModeReadHandle.Free;
end;

procedure TNetworkModeXmlRead.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );

    // ��ȡ Group ��Ϣ
  ReadGroupList;

    // ��ȡ Connect Pc ��Ϣ
  ReadConnPcList;

    // ��ȡѡ����Ϣ
  ReadSelectNetwork;
end;

{ NetworkGroupNode }

constructor TNetworkGroupReadXml.Create( _NetworkGroupNode : IXMLNode );
begin
  NetworkGroupNode := _NetworkGroupNode;
end;

procedure TNetworkGroupReadXml.Update;
var
  GroupName, Password : string;
  NetworkGroupReadHandle : TNetworkGroupReadHandle;
begin
  GroupName := MyXmlUtil.GetChildValue( NetworkGroupNode, Xml_GroupName );
  Password := MyXmlUtil.GetChildValue( NetworkGroupNode, Xml_Password );

  NetworkGroupReadHandle := TNetworkGroupReadHandle.Create( GroupName );
  NetworkGroupReadHandle.SetPassword( Password );
  NetworkGroupReadHandle.Update;
  NetworkGroupReadHandle.Free;
end;

{ NetworkPcConnNode }

constructor TNetworkPcConnReadXml.Create( _NetworkPcConnNode : IXMLNode );
begin
  NetworkPcConnNode := _NetworkPcConnNode;
end;

procedure TNetworkPcConnReadXml.Update;
var
  Domain, Port : string;
  NetworkPcConnReadHandle : TNetworkPcConnReadHandle;
begin
  Domain := MyXmlUtil.GetChildValue( NetworkPcConnNode, Xml_Domain );
  Port := MyXmlUtil.GetChildValue( NetworkPcConnNode, Xml_Port );

  NetworkPcConnReadHandle := TNetworkPcConnReadHandle.Create( Domain, Port );
  NetworkPcConnReadHandle.Update;
  NetworkPcConnReadHandle.Free;
end;

{ TMyPcInfoWriteXml }

procedure TMyPcInfoWriteXml.Update;
begin
  MyPcNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyPcInfo );
end;

{ TMyPcInfoSetXml }

constructor TMyPcInfoSetXml.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TMyPcInfoSetXml.SetSocketInfo(_LanIp, _LanPort,
  _InternetPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_PcID, PcID );
  MyXmlUtil.AddChild( MyPcNode, Xml_PcName, PcName );
  MyXmlUtil.AddChild( MyPcNode, Xml_LanIp, LanIp );
  MyXmlUtil.AddChild( MyPcNode, Xml_LanPort, LanPort );
  MyXmlUtil.AddChild( MyPcNode, Xml_InternetPort, InternetPort );
end;

{ TMyPcInfoSetLanPortXml }

constructor TMyPcInfoSetLanPortXml.Create(_LanPort: string);
begin
  LanPort := _LanPort;
end;

procedure TMyPcInfoSetLanPortXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_LanPort, LanPort );
end;

{ TMyPcInfoSetInternetPortXml }

constructor TMyPcInfoSetInternetPortXml.Create(_InternetPort: string);
begin
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetInternetPortXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_InternetPort, InternetPort );
end;

{ TMyPcXmlReadHandle }

procedure TMyPcXmlReadHandle.Update;
var
  MyPcNode : IXMLNode;
  PcID, PcName : string;
  LanIp, LanPort, InternetPort : string;
  MyPcInfoReadHandle : TMyPcInfoReadHandle;
  MyPcInfoFirstSetHandle : TMyPcInfoFirstSetHandle;
begin
  MyPcNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyPcInfo );
  PcID := MyXmlUtil.GetChildValue( MyPcNode, Xml_PcID );
  PcName := MyXmlUtil.GetChildValue( MyPcNode, Xml_PcName );
  LanIp := MyXmlUtil.GetChildValue( MyPcNode, Xml_LanIp );
  LanPort := MyXmlUtil.GetChildValue( MyPcNode, Xml_LanPort );
  InternetPort := MyXmlUtil.GetChildValue( MyPcNode, Xml_InternetPort );
  PortMap_IsSuccess := MyXmlUtil.GetChildBoolValue( MyPcNode, Xml_IsPortMap );

  if PcID = '' then
  begin
    PcID := MyComputerID.get;
    PcName := MyComputerName.get;
    LanIp := MyIp.get;
    LanPort := '8585';
    InternetPort := MyUpnpUtil.getUpnpPort( LanIp );

    MyPcInfoFirstSetHandle := TMyPcInfoFirstSetHandle.Create( PcID, PcName );
    MyPcInfoFirstSetHandle.SetSocketInfo( LanIp, LanPort, InternetPort );
    MyPcInfoFirstSetHandle.Update;
    MyPcInfoFirstSetHandle.Free;
  end
  else
  begin
    MyPcInfoReadHandle := TMyPcInfoReadHandle.Create( PcID, PcName );
    MyPcInfoReadHandle.SetSocketInfo( LanIp, LanPort, InternetPort );
    MyPcInfoReadHandle.Update;
    MyPcInfoReadHandle.Free;
  end;
end;

{ TMyPcInfoSetLanIpXml }

constructor TMyPcInfoSetLanIpXml.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetLanIpXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_LanIp, LanIp );
end;

{ TNetworkPortMapIsSuccessXml }

constructor TNetworkPortMapIsSuccessXml.Create(_IsSuccess: Boolean);
begin
  IsSuccess := _IsSuccess;
end;

procedure TNetworkPortMapIsSuccessXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_IsPortMap, IsSuccess );
  PortMap_IsSuccess := IsSuccess;
end;

end.

