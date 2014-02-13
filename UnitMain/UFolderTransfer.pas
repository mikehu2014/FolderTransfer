unit UFolderTransfer;

interface

uses Forms, Windows, SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, uDebug, IniFiles, UMyDebug;

type

    // ��ȡ Xml ��Ϣ
  TMyXmlReadHandle = class
  public
    procedure Update;
  private
    procedure ReadMyPcXml;
    procedure ReacNetPcXml;
    procedure ReadFileSendXml;
    procedure ReadFileReceiveXml;
    procedure ReadShareXml;
    procedure ReadShareDownXml;
    procedure ReadRegisterXml;
  private
    procedure AddDefaultRegisterInfo;
    procedure AddDefaultPcInfo;
    procedure AddDefaultNetworkConnInfo;
    procedure AddDefaultReceive;
    procedure SetDefaultShareDownPath;
    procedure AddTrialInfoToWeb;
  end;

    // BackupCow ����
  TFolderTransferCreate = class
  public
    procedure Update;
  private
    procedure CreateSettingInfo;
    procedure CreateWriteXml;
    procedure CreateWriteFace;
  private
    procedure CreateMain;
    procedure CreateFileSend;
    procedure CreateFileReceive;
    procedure CreateShareDown;
    procedure CreateShare;
    procedure CreateRegister;
    procedure CreateNetwork;
  private
    procedure LoadSetting;
    procedure ReadXml;
    procedure StartNetwork;
    procedure MarkAppRunTime;
    procedure LoadRarDllFile;
    procedure CheckAppUpdate;
  end;

    // BackupCow ����
  TFolderTransferDestory = class
  public
    procedure Update;
  private
    procedure StopWriteThread;
  private
    procedure DestoryNetwork;
    procedure DestoryRegister;
    procedure DestoryShare;
    procedure DestoryShareDown;
    procedure DestoryFileReceive;
    procedure DestoryFileSend;
    procedure DestoryMain;
  private
    procedure DestoryWriteFace;
    procedure DestoryWriteXml;
    procedure DestorySettingInfo;
  end;

  FolderTransferSuggestion = class
  public
    class procedure Sumbit( SuggestionStr, EmailStr : string );
  end;

    // ��¼��������ʱ��
  MyFolderTransferAutoApi = class
  public
    class procedure MarkAppRunTime;
    class procedure DownloadRarDllFile;
    class procedure CheckAppUpdate;
  end;

    // FolderTransfer ���ĳ���
  TFolderTransfer = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  HttpMarkApp_PcID = 'PcID';
  HttpMarkApp_PcName = 'PcName';
  HttpMarkApp_NetworkMode = 'NetworkMode';
  HttpMarkApp_NetworkPc = 'NetworkPc';
  HttpMarkApp_SendFile = 'SendFile';
  HttpMarkApp_ShareDown = 'ShareDown';
  HttpMarkApp_AdsShowCount = 'AdsShowCount';
  HttpMarkApp_WinOS = 'WinOS';
  HttpMarkApp_Status = 'Status';

const
  HttpReqTrial_HardCode = 'HardCode';
  HttpReqTrial_PcName = 'PcName';
  HttpReqTrial_PcID = 'PcID';
  HttpReqTrial_WinOS = 'WinOS';

  HttpTrial_Split = '|';
  HttpTrial_True = 'True';
  HttpTrial_False = 'False';
  HttpTrialSplit_Count = 2;
  HttpTrialSplit_ResultStr = 0;
  HttpTrialSplit_Key = 1;

  HttpSuggestion_PcID = 'PcID';
  HttpSuggestion_Suggestions = 'Suggestions';
  HttpSuggestion_Email = 'Email';

const
  HttpMarkApp_StatusSplit = '|';

const
  AppRunParams_RemoveApp = 'ra';

var
  FolderTransfer : TFolderTransfer;

implementation

uses
     UMySendDataInfo, UMySendApiInfo, UMySendXmlInfo, USendThread, UAutoSendThread,
     UMyReceiveDataInfo, UMyReceiveXmlInfo, UReceiveThread, UMyReceiveApiInfo,
     UMyShareDownDataInfo, UMyShareDownXmlInfo, UShareDownThread, UMyShareDownApiInfo,
     UMyShareDataInfo, UMyShareXmlInfo, UMyShareApiInfo, UShareThread, UAutoShareDownThread,
     UMyRegisterDataInfo, UMyRegisterXmlInfo, URegisterThread, UMyRegisterApiInfo,
     UMyNetPcInfo, UNetworkControl, USearchServer, UFormBroadcast,UNetworkFace, UNetPcInfoXml,
     UMyMaster, UMyServer, UMyClient, UMyTcp,
     UPortMap, UMainFormThread, UMyTimerThread, UAppEditionInfo,
     UXmlUtil, UMainForm, uLkJSON, UMyUtil, UChangeInfo, UMyUrl,
     USettingInfo, UFormSetting, UMainFormFace, UFormRegister, IdHTTP;

{ TBackupCowCreate }

procedure TFolderTransferCreate.CreateShareDown;
begin
  MyShareDownInfo := TMyShareDownInfo.Create;

  MyShareDownHandler := TMyShareDownHandler.Create;

  MyShareExplorerHandler := TMyShareExplorerHandler.Create;

  MySharePreviewHandler := TMySharePreviewHandler.Create;

  MyShareSearchHandler := TMyShareSearchHandler.Create;

  MyShareDownConnectHandler := TMyShareDownConnectHandler.Create;

  MyTimerHandler.AddTimer( HandleType_ShareDownConnHeart, 20 );
end;

procedure TFolderTransferCreate.CreateFileSend;
begin
    // ���ݽṹ
  MySendInfo := TMySendInfo.Create;

    // �����߳�
  MyFileSendHandler := TMyFileSendHandler.Create;

    // ��������
  MyFileSendConnectHandler := TMyFileSendConnectHandler.Create;

    // ��ʱ��������
  MyTimerHandler.AddTimer( HandleType_SendFileConnHeart, 20 );
end;

procedure TFolderTransferCreate.CreateMain;
begin
  MyTimerHandler := TMyTimerHandler.Create;

  MyRefreshSpeedHandler := TMyRefreshSpeedHandler.Create;
end;

procedure TFolderTransferCreate.CheckAppUpdate;
begin
  MyTimerHandler.AddTimer( HandleType_CheckAppUpdate, 60 );
end;

procedure TFolderTransferCreate.CreateFileReceive;
begin
    // ���ݽṹ
  MyFileReceiveInfo := TMyFileReceiveInfo.Create;

    // �Ʊ����߳�
  MyReceiveFileHandler := TMyReceiveFileHandler.Create;

    // �����ٶ�
  ReceiveSpeedHandler := TReceiveSpeedHandler.Create;
end;

procedure TFolderTransferCreate.CreateNetwork;
begin
    // ������ Pc ��Ϣ
  PcInfo := TPcInfo.Create;
  Randomize;
  PcInfo.SetSortInfo( Now, Random( 1000000 ) );
  PcInfo.SetPcHardCode( MyMacAddress.getStr );

    // �������ӷ�ʽ
  MyNetworkConnInfo := TMyNetworkConnInfo.Create;

    // Master ��Ϣ
  MasterInfo := TMasterInfo.Create;

    // �������� ���ݽṹ
  MyNetPcInfo := TMyNetPcInfo.Create;

      // C/S ����
  MyServer := TMyServer.Create;
  MyClient := TMyClient.Create;

    // �������� ���������
  frmBroadcast := TfrmBroadcast.Create;
  MyMasterSendHandler := TMyMasterSendHandler.Create;
  MyMasterReceiveHanlder := TMyMasterReceiveHandler.Create;

    // ��������
  MyListener := TMyListener.Create;

    // ����������
  MySearchMasterHandler := TMySearchMasterHandler.Create;
end;

procedure TFolderTransferCreate.CreateRegister;
begin
  MyRegisterInfo := TMyRegisterInfo.Create;
end;

procedure TFolderTransferCreate.ReadXml;
var
  MyXmlReadHandle : TMyXmlReadHandle;
begin
  try
    MyXmlReadHandle := TMyXmlReadHandle.Create;
    MyXmlReadHandle.Update;
    MyXmlReadHandle.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Xml Read', e.Message );
  end;
end;

procedure TFolderTransferCreate.StartNetwork;
begin
     // ���� Master
  MySearchMasterHandler.StartRun;
end;

procedure TFolderTransferCreate.CreateSettingInfo;
begin
  PcSettingInfo := TPcSettingInfo.Create;

  CloudSafeSettingInfo := TCloudSafeSettingInfo.Create;

  ApplicationSettingInfo := TApplicationSettingInfo.Create;

  HintSettingInfo := THintSettingInfo.Create;
end;

procedure TFolderTransferCreate.CreateShare;
begin
  MySharePathInfo := TMySharePathInfo.Create;

  MyShareFileHandler := TMyShareFileHandler.Create;

  MyShareShowRootItemApi.AddLocalItem( ShareShowRootID_MyComputer );
end;

procedure TFolderTransferCreate.CreateWriteFace;
begin
    // ���� ���� �ܿ�����
  MyFaceChange := TMyFaceChange.Create;

    // ������ �������
  MyMainFormFace := TMyChildFaceChange.Create;

    // ������Ϣ
  Network_LocalPcID := MyComputerID.get;
  MyNetworkFace := TMyChildFaceChange.Create;
end;

procedure TFolderTransferCreate.CreateWriteXml;
begin
    // Xml ���ĵ� ��ʼ��
  try
    MyXmlDoc := frmMainForm.XmlDoc;
    MyXmlDoc.Active := True;
    if FileExists( MyXmlUtil.getXmlPath ) then
      MyXmlDoc.LoadFromFile( MyXmlUtil.getXmlPath );
    MyXmlUtil.IniXml;
  except
  end;

    // Xml ��ʼ��
  MyXmlChange := TMyXmlChange.Create;

    // ���� Pc ��Ϣ
  MyNetPcXmlWrite := TMyChildXmlChange.Create;
end;

procedure TFolderTransferCreate.LoadRarDllFile;
begin
  MyTimerHandler.AddTimer( HandleType_DownloadRarDll, 10 );  // ���� Rar �ļ�
end;

procedure TFolderTransferCreate.LoadSetting;
begin
  frmSetting.LoadIni;
  frmSetting.SetFirstApplySettings;
end;

procedure TFolderTransferCreate.MarkAppRunTime;
begin
  MyTimerHandler.AddTimer( HandleType_MarkAppRunTime, 60 );  // ��¼����������Ϣ
end;

procedure TFolderTransferCreate.Update;
begin
  CreateSettingInfo;  // Setting ��Ϣ
  CreateWriteXml;  // д Xml ��Ϣ
  CreateWriteFace; // д �������

  CreateMain;
  CreateFileSend;
  CreateFileReceive;  // ����Ϣ
  CreateShare;
  CreateShareDown;
  CreateRegister;
  CreateNetwork; // ������Ϣ

  LoadSetting;  // ���� Setting ����
  ReadXml;  // �� Xml ��Ϣ
  StartNetwork;  // ��������
  MarkAppRunTime; // ����������Ϣ
  LoadRarDllFile; // ���� Rar ��ѹ�ļ�
  CheckAppUpdate; // ���������

  MyAppPiracyAutoApi.CheckIsPiracy;  // ����Ƿ����
  MyTimerHandler.StartRun; // ������ʱ����
end;

{ TBackupCowDestory }

procedure TFolderTransferDestory.DestoryFileSend;
begin
  MyFileSendConnectHandler.Free;
  MyFileSendHandler.Free;
  MySendInfo.Free;
end;

procedure TFolderTransferDestory.DestoryMain;
begin
  MyTimerHandler.Free;
  MyRefreshSpeedHandler.Free;
end;

procedure TFolderTransferDestory.DestoryFileReceive;
begin
  ReceiveSpeedHandler.Free;
  MyReceiveFileHandler.Free;
  MyFileReceiveInfo.Free;
end;

procedure TFolderTransferDestory.DestoryNetwork;
begin
    // ֹͣ ���� Mster �߳�
  MySearchMasterHandler.Free;

    // �ر� �����˿�
  MyListener.Free;

  MyMasterReceiveHanlder.Free;
  MyMasterSendHandler.Free;
  frmBroadcast.Free;

  MyClient.Free;
  MyServer.Free;

  MyNetPcInfo.Free;
  MasterInfo.Free;
  MyNetworkConnInfo.Free;
  PcInfo.Free;
end;

procedure TFolderTransferDestory.DestoryRegister;
begin
  MyRegisterInfo.Free;
end;

procedure TFolderTransferDestory.DestoryShareDown;
begin
  MyShareDownConnectHandler.Free;
  MyShareSearchHandler.Free;
  MySharePreviewHandler.Free;
  MyShareExplorerHandler.Free;
  MyShareDownHandler.Free;
  MyShareDownInfo.Free;
end;

procedure TFolderTransferDestory.DestorySettingInfo;
begin
  PcSettingInfo.Free;
  CloudSafeSettingInfo.Free;
  ApplicationSettingInfo.Free;
  HintSettingInfo.Free;
end;

procedure TFolderTransferDestory.DestoryShare;
begin
  MyShareFileHandler.Free;
  MySharePathInfo.Free;
end;

procedure TFolderTransferDestory.DestoryWriteFace;
begin
  MyNetworkFace.Free;
  MyMainFormFace.Free;
  MyFaceChange.Free;
end;

procedure TFolderTransferDestory.DestoryWriteXml;
begin
    // ���� ���е� Xml ��Ϣ
  MyXmlChange.StopThread;

  MyNetPcXmlWrite.Free;
  MyXmlChange.Free;
end;

procedure TFolderTransferDestory.StopWriteThread;
begin
    // ֹͣ ����������
  MySearchMasterHandler.StopRun;

    // ֹͣ ��������
  MyListener.StopRun;

    // ֹͣ �������������Ӵ���
  MyMasterSendHandler.StopRun;
  MyMasterReceiveHanlder.StopRun;

  MyClient.StopRun;  // �Ͽ��ͻ���
  MyServer.StopRun;  // �Ͽ�������

  MyFaceChange.StopThread; // ֹͣ�������

  MyTimerHandler.StopRun;  // ֹͣ��ʱ��

    // ֹͣɨ��
  MyFileSendConnectHandler.StopRun;
  MyFileSendHandler.StopScan;
  MyReceiveFileHandler.StopRun;
  MyShareDownConnectHandler.StopRun;
  MyShareDownHandler.StopRun;
  MyShareFileHandler.StopRun;
  MyShareExplorerHandler.StopRun;
  MySharePreviewHandler.StopRun;
  MyShareSearchHandler.StopRun;
end;

procedure TFolderTransferDestory.Update;
begin
  try
    StopWriteThread;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Stop Run Thread', e.Message );
  end;

  DestoryNetwork;
  DestoryRegister;
  DestoryShare;
  DestoryShareDown;
  DestoryFileReceive;
  DestoryFileSend;
  DestoryMain;

  DestoryWriteFace;
  DestoryWriteXml;
  DestorySettingInfo;
end;

{ TBackupCow }

constructor TFolderTransfer.Create;
var
  FolderTransferCreate : TFolderTransferCreate;
begin
  try
    FolderTransferCreate := TFolderTransferCreate.Create;
    FolderTransferCreate.Update;
    FolderTransferCreate.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'FolderTransfer Create', e.Message );
  end;
end;

destructor TFolderTransfer.Destroy;
var
  FolderTransferDestory : TFolderTransferDestory;
begin
  try
    FolderTransferDestory := TFolderTransferDestory.Create;
    FolderTransferDestory.Update;
    FolderTransferDestory.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'FolderTransfer Destory', e.Message );
  end;

  inherited;
end;

{ TMyXmlReadHandle }

procedure TMyXmlReadHandle.AddDefaultNetworkConnInfo;
begin
  NetworkModeApi.SelectLocalNetwork;
end;

procedure TMyXmlReadHandle.AddDefaultPcInfo;
var
  PcID, PcName : string;
  LanIp, LanPort, InternetPort : string;
  MyPcInfoFirstSetHandle : TMyPcInfoFirstSetHandle;
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
end;

procedure TMyXmlReadHandle.AddDefaultReceive;
var
  ReceivePath : string;
begin
  ReceivePath := MyHardDisk.getBiggestHardDIsk + 'FolderTransfer.Receive';
  ReceiveRootItemUserApi.AddItem( ReceivePath );
end;

procedure TMyXmlReadHandle.AddDefaultRegisterInfo;
begin
  MyRegisterUserApi.SetLicense( '' );
end;

procedure TMyXmlReadHandle.AddTrialInfoToWeb;
var
  Url, HardCode, PcName, PcID, WinOS : string;
  ResultList : TStringList;
  HttpResult, ResultStr, ResultKey : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
  i: Integer;
  IsSuccess : Boolean;
begin
  Url := MyUrl.getTrialKey;
  HardCode := MyMacAddress.getStr;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;
  WinOS := MyOSUtil.getOsStr;

    // �ύ������Ϣ
  ParamList := TStringList.Create;
  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
  ParamList.Add( HttpReqTrial_PcID + '=' + PcID );
  ParamList.Add( HttpReqTrial_PcName + '=' + PcName );
  ParamList.Add( HttpReqTrial_WinOS + '=' + WinOS );
  for i := 1 to 3 do  // ��Ϊ����ԭ�򣬿��ܵ����޷���ȡ������
  begin
    IdHttp := TIdHTTP.Create(nil);
    IdHttp.ConnectTimeout := 30000;
    idhttp.ReadTimeout := 30000;
    try
      HttpResult := IdHttp.Post( Url, ParamList );
      IsSuccess := True;
    except
      IsSuccess := False;
    end;
    IdHttp.Free;
      // �ѳɹ�
    if IsSuccess then
      Break;
  end;
  ParamList.Free;
end;

procedure TMyXmlReadHandle.ReacNetPcXml;
var
  NetPcXmlRead : TNetPcXmlRead;
  NetworkModeXmlRead : TNetworkModeXmlRead;
begin
  try
    NetPcXmlRead := TNetPcXmlRead.Create;
    NetPcXmlRead.Update;
    NetPcXmlRead.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'NetPc Xml Read', e.Message );
  end;

  try
    NetworkModeXmlRead := TNetworkModeXmlRead.Create;
    NetworkModeXmlRead.Update;
    NetworkModeXmlRead.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'NetworkMode Xml Read', e.Message );
  end;
end;

procedure TMyXmlReadHandle.ReadFileSendXml;
var
  BackupReadXmlHandle : TMyFileSendReadXmlHandle;
begin
  try
    BackupReadXmlHandle := TMyFileSendReadXmlHandle.Create;
    BackupReadXmlHandle.Update;
    BackupReadXmlHandle.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'FileSend Xml Read', e.Message );
  end;

    // ����
  SendItemAppApi.LocalOnlineSend;
end;

procedure TMyXmlReadHandle.ReadMyPcXml;
var
  MyPcXmlReadHandle : TMyPcXmlReadHandle;
begin
  try
    MyPcXmlReadHandle := TMyPcXmlReadHandle.Create;
    MyPcXmlReadHandle.Update;
    MyPcXmlReadHandle.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'MyPc Xml Read', e.Message );
  end;
end;

procedure TMyXmlReadHandle.ReadRegisterXml;
var
  MyRegisterXmlRead : TMyRegisterXmlRead;
begin
  try
    MyRegisterXmlRead := TMyRegisterXmlRead.Create;
    MyRegisterXmlRead.Update;
    MyRegisterXmlRead.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Register Xml Read', e.Message );
  end;
end;

procedure TMyXmlReadHandle.ReadFileReceiveXml;
var
  MyCloudInfoReadXml : TMyFileReceiveReadXml;
begin
    // ��ȡ
  try
    MyCloudInfoReadXml := TMyFileReceiveReadXml.Create;
    MyCloudInfoReadXml.Update;
    MyCloudInfoReadXml.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'FileReceive Xml Read', e.Message );
  end;
end;

procedure TMyXmlReadHandle.ReadShareDownXml;
var
  MyRestoreDownReadXml : TMyShareDownReadXml;
begin
  try
    MyRestoreDownReadXml := TMyShareDownReadXml.Create;
    MyRestoreDownReadXml.Update;
    MyRestoreDownReadXml.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'ShareDown Xml Read', e.Message );
  end;

    // ��Ȿ�ؼ����ָ�
  ShareDownAppApi.CheckLocalRestoreOnline;
end;

procedure TMyXmlReadHandle.ReadShareXml;
var
  MySharePathXmlRead : TMySharePathXmlRead;
begin
  try
    MySharePathXmlRead := TMySharePathXmlRead.Create;
    MySharePathXmlRead.Update;
    MySharePathXmlRead.Free;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'FileShare Xml Read', e.Message );
  end;
  MySharePathApi.RefreshLocalShareList;
end;

procedure TMyXmlReadHandle.SetDefaultShareDownPath;
var
  LastDownPath : string;
begin
  LastDownPath := MyHardDisk.getBiggestHardDIsk + 'FolderTransfer.Download';
  ShareSavePathHistory.AddItem( LastDownPath );
end;

procedure TMyXmlReadHandle.Update;
begin
    // Xml �ļ����ڣ� ���ȡ Xml �ļ���Ϣ
  if FileExists( MyXmlUtil.getXmlPath ) then
  begin
    ReadMyPcXml;
    ReacNetPcXml;
    ReadFileSendXml;
    ReadFileReceiveXml;
    ReadShareXml;
    ReadShareDownXml;
    ReadRegisterXml;
  end
  else
  begin
    AddDefaultRegisterInfo;
    AddDefaultPcInfo;
    AddDefaultNetworkConnInfo;
    AddDefaultReceive;
    SetDefaultShareDownPath;
    AddTrialInfoToWeb;
  end;
end;

{ MyFolderTransferAutoApi }

class procedure MyFolderTransferAutoApi.CheckAppUpdate;
begin
  MyTimerHandler.RemoveTimer( HandleType_CheckAppUpdate );

  frmMainForm.AppUpgrade;
end;

class procedure MyFolderTransferAutoApi.DownloadRarDllFile;
var
  DllPath : string;
begin
    // �Ƴ���ʱ��
  MyTimerHandler.RemoveTimer( HandleType_DownloadRarDll );

    // �Ѵ���
  DllPath := MyPreviewUtil.getRarDllPath;
  if FileExists( DllPath ) then
    Exit;

    // ���� Dll
  try
    MyPreviewUtil.DownloadRarDll( MyUrl.getRarDllPath );
  except
  end;
end;

class procedure MyFolderTransferAutoApi.MarkAppRunTime;
var
  IniFile : TIniFile;
  PcID, PcName, NetworkMode : string;
  NetworkPc, SendFile, ShareDown, AdsShowCount, WinOS, Status : string;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
  MyTimerHandler.RemoveTimer( HandleType_MarkAppRunTime );

    // ������Ϣ
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  NetworkMode := MyNetworkConnInfo.SelectType;
  NetworkPc := IntToStr( MyNetPcInfo.NetPcInfoHash.Count );
  SendFile := IntToStr( MySendItem_SendCount );
  ShareDown := IntToStr( MyShareDown_ShareDownCount );
  AdsShowCount := IntToStr( MyRegisterItem_AdsShowCount );
  WinOS := MyOSUtil.getOsStr;
  if PortMap_IsSuccess then
    Status := 'PortMap'
  else
    Status := 'NoPortMap';
  Status := Status + HttpMarkApp_StatusSplit + MyEditionUtil.get;

    // ��¼����ȡ���� Pc ��Ϣ
  params := TStringList.Create;
  params.Add( HttpMarkApp_PcID + '=' + PcID );
  params.Add( HttpMarkApp_PcName + '=' + PcName );
  params.Add( HttpMarkApp_NetworkMode + '=' + NetworkMode );
  params.Add( HttpMarkApp_NetworkPc + '=' + NetworkPc );
  params.Add( HttpMarkApp_SendFile + '=' + SendFile );
  params.Add( HttpMarkApp_ShareDown + '=' + ShareDown );
  params.Add( HttpMarkApp_AdsShowCount + '=' + AdsShowCount );
  params.Add( HttpMarkApp_WinOS + '=' + WinOS );
  params.Add( HttpMarkApp_Status + '=' + Status );

    // ���� Http
  idhttp := TIdHTTP.Create(nil);
  idhttp.ConnectTimeout := 10000;
  idhttp.ReadTimeout := 10000;
  try
    idhttp.Post( MyUrl.getAppRunMark , params );
  except
  end;
  idhttp.Free;

  params.free;
end;


{ FolderTransferSuggestion }

class procedure FolderTransferSuggestion.Sumbit(SuggestionStr,
  EmailStr: string);
var
  PcID : string;
  Httpparams : TStringlist;
  idhttp : TIdHTTP;
  Str : string;
begin
    // ������Ϣ
  PcID := MyComputerID.get;

    // ��¼����ȡ���� Pc ��Ϣ
  Httpparams := TStringList.Create;
  Httpparams.Add( HttpSuggestion_PcID + '=' + PcID );
  Str := StringReplace( SuggestionStr, #13#10, '|', [rfReplaceAll] );
  Httpparams.Add( HttpSuggestion_Suggestions + '=' + Str );
  Httpparams.Add( HttpSuggestion_Email + '=' + EmailStr );

    // ���� Http
  idhttp := TIdHTTP.Create(nil);
  idhttp.ConnectTimeout := 10000;
  idhttp.ReadTimeout := 10000;
  try
    idhttp.Post( MyUrl.getAppSuggestiionMark, Httpparams );
  except
  end;
  idhttp.Free;

  Httpparams.free;
end;

end.
