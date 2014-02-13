unit UPortMap;

interface

uses SysUtils, idhttp, classes, idudpclient, Forms, windows;

const
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH     = 8;

type

    // �˿�ӳ��
  TPortMapping = class
  private
    IdUdpClient : TIdUDPClient;
  private
    location, server, usn: string;
    st : string;
    routerip: string;
    routerport: integer;
  public
    controlurl: string;
    HasDivice, IsPortMapable : Boolean;  // �Ƿ���Խ��ж˿�ӳ��
  public
    constructor Create;
    destructor Destroy; override;
  public   // UPNP �˿�ӳ��
    function AddMapping( LocalIp, InternetPort : string ): Boolean;
    procedure RemoveMapping( InternetPort : string );
    function getInternetIp : string;
  private   // UPNP �豸����
    function Find( Ip : string ): Boolean;
    function FindDivice: Boolean;
    function FindControl: Boolean;
  private  // ��Ϣ��ȡ
    function FindDeviceInfo(ResponseStr : string):Boolean;
    function FindControlURL(ResponseStr: string): Boolean;
  end;

  {$Region ' ��ȡ���ص�ַ ' }

  TIPAddressString = Array[0..4*4-1] of AnsiChar;

  PIPAddrString = ^TIPAddrString;
    TIPAddrString = Record
    Next      : PIPAddrString;
    IPAddress : TIPAddressString;
    IPMask    : TIPAddressString;
    Context   : Integer;
  End;

  PIPAdapterInfo = ^TIPAdapterInfo;
    TIPAdapterInfo = Record { IP_ADAPTER_INFO }
    Next                : PIPAdapterInfo;
    ComboIndex          : Integer;
    AdapterName         : Array[0..MAX_ADAPTER_NAME_LENGTH+3] of ansiChar;
    Description         : Array[0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of ansiChar;
    AddressLength       : Integer;
    Address             : Array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index               : Integer;
    _Type               : Integer;
    DHCPEnabled         : Integer;
    CurrentIPAddress    : PIPAddrString;
    IPAddressList       : TIPAddrString;
    GatewayList         : TIPAddrString;
  End;

  MyGateWayIpList = class
  public
    class function get: TStringList;
  private
    class function getBroadcastIp( IpStr, MaskStr : string ): string;
  end;

  {$EndRegion}

implementation

Function GetAdaptersInfo(AI : PIPAdapterInfo; Var BufLen : Integer) : Integer;
StdCall; External 'iphlpapi.dll' Name 'GetAdaptersInfo';

{ TPortMapping }

function TPortMapping.AddMapping( LocalIp, InternetPort : string ): Boolean;
var
  LocalPort : string;
  Protocol : string;
  InternalPort, ExternalPort: Integer;
  InternalClient, RemoteHost: string;
  PortMappingDeion: string;
  LeaseDuration: integer;
  cmd, body{, request} : string;
  IdHttp : TIdHTTP;
  HttpParams : TStringList;
  a: TMemoryStream;
  ResponseStr: string;
begin
  Result := False;

    // ���ܽ��ж˿�ӳ��
  if not IsPortMapable then
    Exit;

  LocalPort := InternetPort;
  Protocol := 'TCP';
  InternalClient := LocalIp;
  RemoteHost := '';
  InternalPort := StrToIntdef( LocalPort, -1 );
  ExternalPort := StrToIntdef( InternetPort, -1 );
  PortMappingDeion := 'BackupCow';
  LeaseDuration := 0;

    // Port ��ʽ����ȷ
  if ( InternalPort = -1 ) or ( ExternalPort = -1 ) then
    Exit;

  cmd := 'AddPortMapping';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"'#13#10
    + 's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '<NewRemoteHost>' + RemoteHost + '</NewRemoteHost>'#13#10
    + '<NewExternalPort>' + inttostr(ExternalPort) + '</NewExternalPort>'#13#10
    + '<NewProtocol>' + Protocol + '</NewProtocol>'#13#10
    + '<NewInternalPort>' + inttostr(InternalPort) + '</NewInternalPort>'#13#10
    + '<NewInternalClient>' + InternalClient + '</NewInternalClient>'#13#10
    + '<NewEnabled>1</NewEnabled>'#13#10
    + '<NewPortMappingDescription>' + PortMappingDeion + '</NewPortMappingDescription>'#13#10
    + '<NewLeaseDuration>' + inttostr(LeaseDuration) + '</NewLeaseDuration>'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;
  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;
    ResponseStr := IdHTTP.Post( controlurl , a);
    Result := True;
  except
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;
end;

procedure TPortMapping.RemoveMapping( InternetPort : string );
var
  Protocol: string;
  ExternalPort: Integer;
  cmd, body, request : string;
  IdHttp : TIdHTTP;
  a: TMemoryStream;
  HttpParams : TStringList;
  res: string;
begin
    // ���ܽ��ж˿�ӳ��
  if not IsPortMapable then
    Exit;

  Protocol := 'TCP';
  ExternalPort := StrToInt( InternetPort );

  cmd := 'DeletePortMapping';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '<NewRemoteHost></NewRemoteHost>'#13#10
    + '<NewExternalPort>' + inttostr(ExternalPort) + '</NewExternalPort>'#13#10
    + '<NewProtocol>TCP</NewProtocol>'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;
  request := 'POST ' + controlurl + ' HTTP/1.0'#13#10
    + 'Host: ' + routerip + ':' + inttostr(routerport) + #13#10
    + 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"'#13#10
    + 'Content-Type: text/xml; charset="utf-8"'#13#10
    + 'Content-Length: ' + inttostr(length(body)) + #13#10#13#10 + body;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;

  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;

    res := IdHTTP.Post( controlurl, a);
  except
    on e: Exception do begin
    end;
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;
end;

constructor TPortMapping.Create;
var
  IpList : TStringList;
  i : Integer;
begin
  if Find( '239.255.255.250' ) then  // ���͵�Ĭ�ϵ� Ip ��ַ
    Exit;
  IpList := MyGateWayIpList.get; // ���͵����صĵ�ַ
  for i := 0 to IpList.Count - 1 do
    if Find( IpList[i] ) then
      Break;
  IpList.Free;
end;

function TPortMapping.Find(Ip: string): Boolean;
var
  i : Integer;
begin
  IdUdpClient := TIdUDPClient.Create(nil);
  IdUdpClient.BroadcastEnabled := True;
  IdUdpClient.Host := Ip;
  IdUdpClient.port := 1900;

  IsPortMapable := False;
  HasDivice := False;

    // ���� 10 �ζ˿�ӳ��
  for i := 1 to 10 do
  begin
      // �˿�ӳ��ɹ�, ����
    if FindDivice and FindControl then
    begin
      IsPortMapable := True;
      Break;
    end;
      // ӳ�䲻�ɹ�, �Ҳ�����ӳ���豸, ����
    if not HasDivice then
      Break;

    Application.ProcessMessages;
    Sleep(50);
  end;

  Result := IsPortMapable;
end;

function TPortMapping.FindControl: Boolean;
var
  IdHttp : TIdHTTP;
  ResponseStr: string;
begin
  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;

  try
    ResponseStr := IdHttp.Get(location);
    Result := FindControlURL(ResponseStr);
  except
    Result := False;
  end;

  IdHttp.Free;
end;

function TPortMapping.FindControlURL(ResponseStr: string): Boolean;
var
  tmpstr, tmp: string;
  j: integer;
  FulllAdress : string;
begin
  result := False;
  tmpstr := ResponseStr;


   // �����豸urn:schemas-upnp-org:device:InternetGatewayDevice:1��������...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:InternetGatewayDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:InternetGatewayDevice:1</deviceType>') - 1);


   // �ٲ���urn:schemas-upnp-org:device:WANDevice:1��������...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:WANDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:WANDevice:1</deviceType>') - 1);


   // �ٲ���urn:schemas-upnp-org:device:WANConnectionDevice:1��������...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:WANConnectionDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:WANConnectionDevice:1</deviceType>') - 1);


   // ����ҵ�����urn:schemas-upnp-org:service:WANIPConnection:1��������...

  j := pos(uppercase('<serviceType>urn:schemas-upnp-org:service:WANIPConnection:1</serviceType>'), uppercase(tmpstr));
  if j <= 0 then exit;
  delete(tmpstr, 1, j + length('<serviceType>urn:schemas-upnp-org:service:WANIPConnection:1</serviceType>') - 1);


   // �õ�ControlURL...

  j := pos(uppercase('<controlURL>'), uppercase(tmpstr));
  if j <= 0 then exit;
  delete(tmpstr, 1, j + length('<controlURL>') - 1);
  j := pos(uppercase('</controlURL>'), uppercase(tmpstr));
  if j <= 0 then exit;

  controlurl := copy(tmpstr, 1, j - 1);

  FulllAdress := 'http://' + routerip + ':' + inttostr(routerport);
  if Pos( FulllAdress, controlurl ) <= 0 then
    controlurl := FulllAdress + controlurl;

  Result := True;
end;


function TPortMapping.FindDivice: Boolean;
var
  RequestStr: string;
  ResponseStr:string;
begin
  RequestStr := 'M-SEARCH * HTTP/1.1'#13#10
    + 'HOST: 239.255.255.250:1900'#13#10
    + 'MAN: "ssdp:discover"'#13#10
    + 'MX: 3'#13#10
    + 'ST: upnp:rootdevice'#13#10#13#10;

  try
    IdUdpClient.Send(RequestStr);
    ResponseStr := IdUdpClient.ReceiveString(2000);
    HasDivice := Trim(ResponseStr) <> '';
    Result := FindDeviceInfo( ResponseStr );
  except
    Result := False;
  end;
end;

function TPortMapping.getInternetIp: string;
var
  cmd, body, request : string;
  IdHttp : TIdHTTP;
  HttpParams : TStringList;
  a: TMemoryStream;
  ResponeStr : string;
  PosIp : Integer;
begin
  Result := '';

      // ���ܽ��ж˿�ӳ��
  if not IsPortMapable then
    Exit;

  cmd := 'GetExternalIPAddress';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;

  request := 'POST ' + controlurl + ' HTTP/1.0'#13#10
    + 'Host: ' + routerip + ':' + inttostr(routerport) + #13#10
    + 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"'#13#10
    + 'Content-Type: text/xml; charset="utf-8"'#13#10
    + 'Content-Length: ' + inttostr(length(body)) + #13#10#13#10 + body;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;

  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;
    ResponeStr := IdHTTP.Post( controlurl , a);
  except
    on e: Exception do begin
    end;
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;

    // �ӷ�����Ϣ����ȡ Ip
  PosIp := Pos( '<NEWEXTERNALIPADDRESS>', UpperCase( ResponeStr ) );
  if PosIp > 0 then
  begin
    delete( ResponeStr, 1, PosIp + 21 );
    PosIp := pos( '</', ResponeStr );
    ResponeStr := trim( copy( ResponeStr, 1, PosIp - 1 ) );
  end;
  Result := ResponeStr;
end;

function TPortMapping.FindDeviceInfo(ResponseStr: string):Boolean;
var
  tmpstr: string;
  buffer: array[0..4096] of char;
  j: integer;
begin
  Result := False;

  tmpstr := ResponseStr;

    // �յ�����Ϣ�����豸��Ѱ��������ԣ�
  if uppercase(copy(tmpstr, 1, 5)) <> 'HTTP/' then
    exit;

    // �ҳ� ST
  st := tmpstr;
  j := Pos( 'ST:', UpperCase( st ) );
  if j < 0 then
    Exit
  else
  begin
    delete(ST, 1, j + 2);
    j := pos(#13#10, ST);
    ST := trim(copy(ST, 1, j - 1));
    if LowerCase(ST) <> 'upnp:rootdevice' then
      Exit;
  end;

  // �ҳ� Location
  location := tmpstr;
  j := pos('LOCATION:', uppercase(location));
  if j < 0 then
    Exit
  else
  begin
    delete(location, 1, j + 8);
    j := pos(#13#10, location);
    location := trim(copy(location, 1, j - 1));
  end;

   // �ҳ� Server
  server := tmpstr;
  j := pos('SERVER:', uppercase(server));
  if j < 0 then
    Exit
  else
  begin
    delete(server, 1, j + 6);
    j := pos(#13#10, server);
    server := trim(copy(server, 1, j - 1));
  end;

   // �ҳ� USN
  usn := tmpstr;
  j := pos('USN:', uppercase(usn));
  if j < 0 then
    Exit
  else
  begin
    delete(usn, 1, j + 3);
    j := pos(#13#10, usn);
    usn := trim(copy(usn, 1, j - 1));
  end;


    // �ҳ� Ip
  tmpstr := location;
  if copy(uppercase(tmpstr), 1, 7) = 'HTTP://' then
    delete(tmpstr, 1, 7);
  j := pos(':', tmpstr);
  if j <= 0 then
    exit;
  routerip := copy(tmpstr, 1, j - 1);
  delete(tmpstr, 1, j);

   // �ҳ� Port
  j := pos('/', tmpstr);
  if j > 1 then
  begin
    routerport := StrToIntDef(copy(tmpstr, 1, j - 1), -1);
    delete(tmpstr, 1, j - 1);
  end
  else
  begin
    j := pos(#13#10, tmpstr);
    if j <= 1 then
      exit;
    routerport := strtointdef(copy(tmpstr, 1, j - 1), -1);
  end;

    // ��������
  if ( location = '' )  or ( server = '' ) or ( usn = '' ) or
     ( routerip = '' ) or ( routerport < 0 )
  then
    Exit;

  Result := True;
end;

destructor TPortMapping.Destroy;
begin
  IdUdpClient.Free;
  inherited;
end;


{ MyBroadcastIpList }

class function MyGateWayIpList.get: TStringList;
var
  AI,Work : PIPAdapterInfo;
  Size    : Integer;
  Res     : Integer;
  IpStr, MaskStr : string;
  BroadcastIp : string;
begin
  Result := TStringList.Create;
  Size := 5120;
  GetMem(AI,Size);
  try
    work:=ai;
    Res := GetAdaptersInfo(AI,Size);
    If (Res <> ERROR_SUCCESS) Then
    Begin
      SetLastError(Res);
      RaiseLastWin32Error;
      exit;
    End;
    repeat
      IpStr := work.IPAddressList.IPAddress;
      MaskStr := work.IPAddressList.IPMask;
      BroadcastIp := getBroadcastIp( IpStr, MaskStr );
      if Result.IndexOf( BroadcastIp ) < 0 then  // ���������
        Result.Add( BroadcastIp );
      work:=work^.Next ;
    until (work=nil);
  except
  end;
  FreeMem(AI, Size);
end;

class function MyGateWayIpList.getBroadcastIp(IpStr, MaskStr: string): string;
var
  IpList, MaskList : TStringList;
  i : Integer;
  MaskNum, IpNum, BroNum : Byte;
begin
  Result := '';

  IpList := TStringList.Create;
  IpList.Delimiter := '.';
  IpList.DelimitedText := IpStr;

  MaskList := TStringList.Create;
  MaskList.Delimiter := '.';
  MaskList.DelimitedText := MaskStr;
  if ( MaskList.Count = 4 ) and ( IpList.Count = 4 ) then
  begin
    for i := 0 to MaskList.Count - 1 do
    begin
      MaskNum := StrToIntDef( MaskList[i], 0 );
      MaskNum := not MaskNum;
      IpNum := StrToIntDef( IpList[i], 0 );
      BroNum := IpNum or MaskNum;
      if Result <> '' then
        Result := Result + '.';
      if i = 3 then
        Result := Result + '1'
      else
        Result := Result + IntToStr( BroNum );
    end;
  end;
  MaskList.Free;

  IpList.Free;
end;

end.
