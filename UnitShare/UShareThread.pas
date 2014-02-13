unit UShareThread;

interface

uses classes, Sockets, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, Syncobjs,
     UMyDebug, uDebugLock, zip, UChangeInfo;

type

    // ���� �����ļ�
  TShareFileSendHandle = class( TNetworkFileSendHandle )
  private
    ShareRootPath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    procedure SetShareRootPath( _ShareRootPath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
  protected
    function CheckNextSend : Boolean;override;
    procedure AddSpeedSpace( Space : Integer );override;
    function getLimitBlockSize : Int64;override;
  end;

      // ����ѹ���ļ�
  TShareFileSendZipHandle = class( TShareFileSendHandle )
  private
    ZipStream : TMemoryStream;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
  protected
    function CreateReadStream : Boolean;override;
  end;

     // ѹ�������ļ�
  TCompressShareFileHandle = class
  private
    SharePath : string;
  private
    ZipStream : TMemoryStream;
    ZipFile : TZipFile;
  private
    IsCreated : Boolean;
    TotalSize, ZipSize : Int64;
    ZipCount : Integer;
  private
    ZipErrorList : TStringList;
  public
    constructor Create;
    procedure SetSharePath( _SharePath : string );
    procedure AddZipFile( FilePath : string );
    function getZipStream : TMemoryStream;
    function getErrorStr : string;
    destructor Destroy; override;
  private
    function getIsAddFile( FilePath : string ): Boolean;
    function CreateZip: Boolean;
    function AddFile( FilePath : string ): Boolean;
    procedure DestoryZip;
  end;

    // ���ļ�����
  TShareFileHandle = class
  private
    FileReq : string;
    ShareFilePath : string;
  private
    TcpSocket : TCustomIpClient;
    ShareRootPath : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  private
    CompressShareFileHandle : TCompressShareFileHandle;
  public
    constructor Create( _FileReq : string );
    procedure SetShareFilePath( _ShareFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetShareRootPath( _ShareRootPath : string );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure SetCompressShareFileHandle( _CompressShareFileHandle : TCompressShareFileHandle );
    procedure Update;
  private       // ��ȡ
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadFolderDeep;
    procedure AddZip;
  private       // Get �ļ�
    procedure GetFile;
    procedure ContinuesGetFile;
    procedure GetZip;
  private       // �����ļ�
    procedure SearchFolder;
  private       // Preview �ļ�
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewZip;
    procedure PreviewExe;
    procedure PreviewText;
    procedure PreviewMusic;
  end;

    // �������
  TShareFileRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
    SharePath, DownloadPcID : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  private
    CompressShareFileHandle : TCompressShareFileHandle;  // �ļ�ѹ����
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ReadBaseInfo;  // ��ȡ������Ϣ
    function SendAccessResult: Boolean;  // ���ͷ��ʽ��
    procedure HandleRequest;  // �����������
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure HandleReq( FileReq, FilePath : string );
  end;

    // �������
  TShareRootRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure HandleShareFile;
    function WaitingNext: Boolean;
  end;

    // ���ļ������߳�
  TShareFileHandleThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  private
    IsConnnected : Boolean;
    DownPcID : string;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetBackConn( _DownPcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ConnToDownPc : Boolean;
    procedure HandleRequest; // ��������
  end;
  TReceiveFileHandleThreadList = class( TObjectList< TShareFileHandleThread > )end;


    // ���ļ�����
  TMyShareFileHandler = class
  public
    IsRun, IsShareRun : Boolean;
  public
    ThreadLock : TCriticalSection;
    ShareFileThreadList : TReceiveFileHandleThreadList;
  public
    constructor Create;
    function getIsRun : Boolean;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure ReceiveConn( TcpSocket : TCustomIpClient );
    procedure ReceiveBackConn( DownPcID : string );
    procedure RemoveThread( ThreadID : Cardinal );
  end;

const
  ThreadCount_Share = 50;

  ShareType_Down = 'Down';
  ShareType_Explorer = 'Explorer';
  ShareType_Search = 'Search';
  ShareType_Preview = 'Preview';

var
  MyShareFileHandler : TMyShareFileHandler;

implementation

uses UMyShareApiInfo, UMyShareDataInfo, UMyNetPcInfo, UMyShareEventInfo, UMainFormThread, UMyUrl;

{ TCloudBackupThread }

procedure TShareFileHandleThread.HandleRequest;
var
  ShareRootRequestHandle : TShareRootRequestHandle;
begin
  ShareRootRequestHandle := TShareRootRequestHandle.Create( TcpSocket );
  ShareRootRequestHandle.Update;
  ShareRootRequestHandle.Free;
end;

function TShareFileHandleThread.ConnToDownPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
begin
  DebugLock.Debug( 'ConnToDownPc' );

  Result := False;

  TcpSocket := TCustomIpClient.Create( nil );

    // ��ȡ Pc Socket ��Ϣ
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DownPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DownPcID );

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_ShareDown );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ���ӳɹ�
  if Result then
    Exit;

    // ����ʧ��
  MySharePathBackConnEvent.ConnDownError( DownPcID )
end;

constructor TShareFileHandleThread.Create;
begin
  inherited Create;
end;

destructor TShareFileHandleThread.Destroy;
begin
  inherited;
end;

procedure TShareFileHandleThread.Execute;
begin
  FreeOnTerminate := True;

  MyShareFileHandler.IsShareRun := True;

  try
      // ������ɨ��
    if IsConnnected or ConnToDownPc then
      HandleRequest;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Share File Error', e.Message );
  end;

    // �Ͽ�����
  TcpSocket.Free;

  MyShareFileHandler.RemoveThread( ThreadID );

  Terminate;
end;

procedure TShareFileHandleThread.SetBackConn(_DownPcID: string);
begin
  DownPcID := _DownPcID;
  IsConnnected := False;
end;

procedure TShareFileHandleThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  IsConnnected := True;
end;

{ TMyCloudBackupHandler }

constructor TMyShareFileHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  ShareFileThreadList := TReceiveFileHandleThreadList.Create;
  ShareFileThreadList.OwnsObjects := False;

  IsRun := True;
  IsShareRun := True;
end;

destructor TMyShareFileHandler.Destroy;
begin
  ShareFileThreadList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyShareFileHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsShareRun;
end;

procedure TMyShareFileHandler.ReceiveBackConn(DownPcID : string);
var
  IsBusy : Boolean;
  ReceiveThread : TShareFileHandleThread;
begin
      // �������
  if not IsRun then
    Exit;

    // Ѱ�ҹ�����߳�
  ThreadLock.Enter;
  IsBusy := True;
  if ShareFileThreadList.Count < ThreadCount_Share then
  begin
    IsBusy := False;
    ReceiveThread := TShareFileHandleThread.Create;
    ShareFileThreadList.Add( ReceiveThread );

    ReceiveThread.SetBackConn( DownPcID );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // �Ƿ�æ
  if not IsBusy then
    Exit;

    // ��æ�Ĵ���
  MySharePathBackConnEvent.ConnDownBusy( DownPcID )
end;

procedure TMyShareFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
  ReceiveThread : TShareFileHandleThread;
begin
    // �������
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // Ѱ�ҹ�����߳�
  ThreadLock.Enter;
  IsBusy := True;
  if ShareFileThreadList.Count < ThreadCount_Share then
  begin
    IsBusy := False;
    ReceiveThread := TShareFileHandleThread.Create;
    ShareFileThreadList.Add( ReceiveThread );

    MySocketUtil.SendData( TcpSocket, False );    // �����Ƿ�æ
    ReceiveThread.SetTcpSocket( TcpSocket );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // ֪ͨ�Է���æ
  if IsBusy then
  begin
    MySocketUtil.SendData( TcpSocket, True ); // �����Ƿ�æ
    TcpSocket.Free;
  end;
end;

procedure TMyShareFileHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to ShareFileThreadList.Count - 1 do
    if ShareFileThreadList[i].ThreadID = ThreadID then
    begin
      ShareFileThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyShareFileHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := ShareFileThreadList.Count > 0;
    ThreadLock.Leave;

    if not IsExistThread then
      Break;

    Sleep( 100 );
  end;
end;

{ TCloudBackupHandle }

constructor TShareFileRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  CompressShareFileHandle := TCompressShareFileHandle.Create;
end;

destructor TShareFileRequestHandle.Destroy;
begin
  CompressShareFileHandle.Free;
  RefreshSpeedInfo.Free;
  inherited;
end;

function TShareFileRequestHandle.getIsOtherReq(FileReq: string): Boolean;
var
  FilePath : string;
begin
  Result := True;

    // ����
  if FileReq = FileReq_HeartBeat then
  else  // ѹ�������ļ�
  if FileReq = FileReq_ReadZipError then
    MySocketUtil.SendData( TcpSocket, CompressShareFileHandle.getErrorStr )
  else
  if Pos( 'MsgType', FileReq ) > 0 then
  begin
    FileReq := MsgUtil.getMsgStr( FileReq );
    FilePath := MySocketUtil.RevJsonStr( TcpSocket );
    HandleReq( FileReq, FilePath );
  end
  else
    Result := False;
end;

procedure TShareFileRequestHandle.HandleReq(FileReq, FilePath: string);
var
  ShareFileHandle : TShareFileHandle;
begin
  DebugLock.Debug( 'HandleReq: ' + FileReq + '   ' + FilePath );

    // ����������Ϣ
  ShareFileHandle := TShareFileHandle.Create( FileReq );
  ShareFileHandle.SetShareFilePath( FilePath );
  ShareFileHandle.SetTcpSocket( TcpSocket );
  ShareFileHandle.SetShareRootPath( SharePath );
  ShareFileHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ShareFileHandle.SetCompressShareFileHandle( CompressShareFileHandle );
  ShareFileHandle.Update;
  ShareFileHandle.Free;
end;

procedure TShareFileRequestHandle.HandleRequest;
var
  FileReq, FilePath : string;
begin
  DebugLock.Debug( 'HandleRequest' );

    // ѭ������
  while True do
  begin
       // �ѶϿ�����
    if not TcpSocket.Connected then
      Exit;

      // ��������
    if not MyShareFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // ��ȡ ��������
    FileReq := MySocketUtil.RevData( TcpSocket );
    if FileReq = FileReq_End then   // �������
      Break;

      // �ѶϿ�����
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // ���������
    if getIsOtherReq( FileReq ) then
      Continue;

      // ��ȡ �����ļ�
    FilePath := MySocketUtil.RevData( TcpSocket );

      // ���ʳ���
    if Pos( SharePath, FilePath ) <= 0 then
      Break;

      // ����������Ϣ
    HandleReq( FileReq, FilePath );
  end;
end;

procedure TShareFileRequestHandle.ReadBaseInfo;
begin
  DebugLock.Debug( 'ReadBaseInfo' );

    // ����Ŀ¼
  SharePath := MySocketUtil.RevData( TcpSocket );
  DownloadPcID := MySocketUtil.RevData( TcpSocket );

    // ����ѹ������·��
  CompressShareFileHandle.SetSharePath( SharePath );
end;

function TShareFileRequestHandle.SendAccessResult: Boolean;
var
  AccessResult : string;
begin
  DebugLock.Debug( 'SendAccessResult' );

    // ���ͷ��ʽ��
  Result := False;
  if not SharePathInfoReadUtil.ReadIsExistParent( SharePath ) then
    AccessResult := ShareConnResult_NotExist
  else
  if not MyHardDisk.getPathDriverExist( SharePath ) then
    AccessResult := ShareConnResult_NotExist
  else
  begin
    Result := True;
    AccessResult := ShareConnResult_OK;
  end;
  MySocketUtil.SendString( TcpSocket, AccessResult );
end;

procedure TShareFileRequestHandle.Update;
begin
    // ��ȡ Ҫ�������Ϣ
  ReadBaseInfo;

    // ���ͽ��
  if not SendAccessResult then
    Exit;

    // ����������
  HandleRequest;
end;

{ TCloudFileSendHandle }

procedure TShareFileSendHandle.AddSpeedSpace(Space: Integer);
var
  IsLimited : Boolean;
begin
  MyRefreshSpeedHandler.AddUpload( Space );

    // ˢ���ٶȣ� 1����ˢ��һ��
  if RefreshSpeedInfo.AddCompleted( Space ) then
  begin
    IsLimited := RevLimitSpace > 0;
    RefreshSpeedInfo.SetLimitInfo( IsLimited, RevLimitSpace );
  end;
end;

function TShareFileSendHandle.CheckNextSend: Boolean;
begin
  Result := True;

    // 1 ���� ���һ�Σ��Ƿ���
  if SecondsBetween( Now, RefreshTime ) >= 1 then
    Result := SharePathInfoReadUtil.ReadIsExistParent( ShareRootPath );

  Result := Result and inherited and MyShareFileHandler.getIsRun;
end;

function TShareFileSendHandle.getLimitBlockSize: Int64;
begin
  if RefreshSpeedInfo.IsLimited then
    Result := RefreshSpeedInfo.LimitSpeed - RefreshSpeedInfo.Speed
  else
    Result := inherited;
end;

{ TCloudFileHandle }


procedure TShareFileHandle.AddZip;
begin
  CompressShareFileHandle.AddZipFile( ShareFilePath );
end;

procedure TShareFileHandle.ContinuesGetFile;
var
  Position : Int64;
  ShareFileSendHandle : TShareFileSendHandle;
begin
  Position := MySocketUtil.RevInt64Data( TcpSocket );

  ShareFileSendHandle := TShareFileSendHandle.Create( ShareFilePath );
  ShareFileSendHandle.SetShareRootPath( ShareRootPath );
  ShareFileSendHandle.SetFilePos( Position );
  ShareFileSendHandle.SetTcpSocket( TcpSocket );
  ShareFileSendHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ShareFileSendHandle.Update;
  ShareFileSendHandle.Free;
end;

constructor TShareFileHandle.Create(_FileReq: string);
begin
  FileReq := _FileReq;
end;

procedure TShareFileHandle.PreviewMusic;
var
  MusicText : string;
begin
  MusicText := MyPreviewUtil.getMusicText( ShareFilePath );
  MySocketUtil.SendData( TcpSocket, MusicText );
end;

procedure TShareFileHandle.PreviewWord;
var
  DocText : string;
begin
  DocText := MyPreviewUtil.getWordText( ShareFilePath );
  MySocketUtil.SendData( TcpSocket, DocText );
  MySocketUtil.SendData( TcpSocket, Split_Word );
end;

procedure TShareFileHandle.PreviewZip;
var
  ZipText : string;
begin
    // Dll �ļ������ڣ� ��������
  if MyPreviewUtil.getIsRarFile( ShareFilePath ) and not FileExists( MyPreviewUtil.getRarDllPath ) then
    MyPreviewUtil.DownloadRarDll( MyUrl.getRarDllPath );

  ZipText := MyPreviewUtil.getCompressText( ShareFilePath );
  MySocketUtil.SendData( TcpSocket, ZipText );
end;

procedure TShareFileHandle.PreviewExcel;
var
  ExcelText : string;
begin
  ExcelText := MyPreviewUtil.getExcelText( ShareFilePath );
  MySocketUtil.SendData( TcpSocket, ExcelText );
end;

procedure TShareFileHandle.PreviewExe;
var
  ExeText : string;
  NetworkFilePreviewExeSendHandle : TNetworkFilePreviewExeSendHandle;
begin
  ExeText := MyPreviewUtil.getExeText( ShareFilePath );
  MySocketUtil.SendData( TcpSocket, ExeText );

  NetworkFilePreviewExeSendHandle := TNetworkFilePreviewExeSendHandle.Create( ShareFilePath );
  NetworkFilePreviewExeSendHandle.SetTcpSocket( TcpSocket );
  NetworkFilePreviewExeSendHandle.Update;
  NetworkFilePreviewExeSendHandle.Free;
end;

procedure TShareFileHandle.PreviewPicture;
var
  ImgWidth, ImgHeigh : Integer;
  NetworkFilePreviewSendHandle : TNetworkFilePreviewPictureSendHandle;
begin
  ImgWidth := MySocketUtil.RevIntData( TcpSocket );
  ImgHeigh := MySocketUtil.RevIntData( TcpSocket );

  NetworkFilePreviewSendHandle := TNetworkFilePreviewPictureSendHandle.Create( ShareFilePath );
  NetworkFilePreviewSendHandle.SetPreviewSize( ImgWidth, ImgHeigh );
  NetworkFilePreviewSendHandle.SetTcpSocket( TcpSocket );
  NetworkFilePreviewSendHandle.Update;
  NetworkFilePreviewSendHandle.Free;
end;

procedure TShareFileHandle.PreviewText;
var
  ShareFileSendHandle : TNetworkFilePreviewTextSendHandle;
begin
  ShareFileSendHandle := TNetworkFilePreviewTextSendHandle.Create( ShareFilePath );
  ShareFileSendHandle.SetTcpSocket( TcpSocket );
  ShareFileSendHandle.Update;
  ShareFileSendHandle.Free;
end;


procedure TShareFileHandle.GetFile;
var
  ShareFileSendHandle : TShareFileSendHandle;
begin
  ShareFileSendHandle := TShareFileSendHandle.Create( ShareFilePath );
  ShareFileSendHandle.SetShareRootPath( ShareRootPath );
  ShareFileSendHandle.SetTcpSocket( TcpSocket );
  ShareFileSendHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ShareFileSendHandle.Update;
  ShareFileSendHandle.Free;
end;

procedure TShareFileHandle.GetZip;
var
  ShareFileSendZipHandle : TShareFileSendZipHandle;
begin
  ShareFileSendZipHandle := TShareFileSendZipHandle.Create( ShareFilePath );
  ShareFileSendZipHandle.SetShareRootPath( ShareRootPath );
  ShareFileSendZipHandle.SetTcpSocket( TcpSocket );
  ShareFileSendZipHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
  ShareFileSendZipHandle.SetZipStream( CompressShareFileHandle.getZipStream );
  ShareFileSendZipHandle.Update;
  ShareFileSendZipHandle.Free;

    // �ȴ��Է���ѹ���
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );
end;

procedure TShareFileHandle.ReadFile;
var
  NetworkFileAccessFindHandle : TNetworkFileAccessFindHandle;
begin
  NetworkFileAccessFindHandle := TNetworkFileAccessFindHandle.Create( ShareFilePath );
  NetworkFileAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileAccessFindHandle.Update;
  NetworkFileAccessFindHandle.Free;
end;

procedure TShareFileHandle.ReadFolder;
var
  NetworkFolderAccessFindHandle : TNetworkFolderAccessFindHandle;
begin
  NetworkFolderAccessFindHandle := TNetworkFolderAccessFindHandle.Create;
  NetworkFolderAccessFindHandle.SetFolderPath( ShareFilePath );
  NetworkFolderAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderAccessFindHandle.Update;
  NetworkFolderAccessFindHandle.Free;
end;

procedure TShareFileHandle.ReadFolderDeep;
var
  NetworkFolderAccessFindDeepHandle : TNetworkFolderAccessFindDeepHandle;
begin
  NetworkFolderAccessFindDeepHandle := TNetworkFolderAccessFindDeepHandle.Create;
  NetworkFolderAccessFindDeepHandle.SetFolderPath( ShareFilePath );
  NetworkFolderAccessFindDeepHandle.SetTcpSocket( TcpSocket );
  NetworkFolderAccessFindDeepHandle.Update;
  NetworkFolderAccessFindDeepHandle.Free;
end;

procedure TShareFileHandle.SearchFolder;
var
  SearchName : string;
  ResultFileHash : TScanFileHash;
  ResultFolderHash : TScanFolderHash;
  NetworkFolderSearchAccessHandle : TNetworkFolderSearchAccessHandle;
begin
  SearchName := MySocketUtil.RevData( TcpSocket );

  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;

  NetworkFolderSearchAccessHandle := TNetworkFolderSearchAccessHandle.Create;
  NetworkFolderSearchAccessHandle.SetTcpSocket( TcpSocket );
  NetworkFolderSearchAccessHandle.SetFolderPath( ShareFilePath );
  NetworkFolderSearchAccessHandle.SetSerachName( SearchName );
  NetworkFolderSearchAccessHandle.SetResultFolderPath( '' );
  NetworkFolderSearchAccessHandle.SetResultFile( ResultFileHash );
  NetworkFolderSearchAccessHandle.SetResultFolder( ResultFolderHash );
  NetworkFolderSearchAccessHandle.Update;
  NetworkFolderSearchAccessHandle.LastRefresh;
  NetworkFolderSearchAccessHandle.Free;

  ResultFileHash.Free;
  ResultFolderHash.Free;
end;

procedure TShareFileHandle.SetCompressShareFileHandle(
  _CompressShareFileHandle: TCompressShareFileHandle);
begin
  CompressShareFileHandle := _CompressShareFileHandle;
end;

procedure TShareFileHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareFileHandle.SetShareFilePath(_ShareFilePath: string);
begin
  ShareFilePath := _ShareFilePath;
end;

procedure TShareFileHandle.SetShareRootPath(_ShareRootPath: string);
begin
  ShareRootPath := _ShareRootPath;
end;

procedure TShareFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TShareFileHandle.Update;
begin
  if FileReq = FileReq_ReadFile then
    ReadFile
  else
  if FileReq = FileReq_ReadFolder then
    ReadFolder
  else
  if FileReq = FileReq_GetFile then
    GetFile
  else
  if FileReq = FileReq_ContinuesGet then
    ContinuesGetFile
  else
  if FileReq = FileReq_PreviewPicture then
    PreviewPicture
  else
  if FileReq = FileReq_PreviewWord then
    PreviewWord
  else
  if FileReq = FileReq_PreviewExcel then
    PreviewExcel
  else
  if FileReq = FileReq_PreviewZip then
    PreviewZip
  else
  if FileReq = FileReq_PreviewExe then
    PreviewExe
  else
  if FileReq = FileReq_PreviewText then
    PreviewText
  else
  if FileReq = FileReq_PreviewMusic then
    PreviewMusic
  else
  if FileReq = FileReq_SearchFolder then
    SearchFolder
  else
  if FileReq = FileReq_ReadFolderDeep then
    ReadFolderDeep
  else
  if FileReq = FileReq_AddZip then
    AddZip
  else
  if FileReq = FileReq_GetZip then
    GetZip;
end;

procedure TShareFileSendHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TShareFileSendHandle.SetShareRootPath(_ShareRootPath: string);
begin
  ShareRootPath := _ShareRootPath;
end;

{ TCompressShareFileHandle }

function TCompressShareFileHandle.AddFile(FilePath: string): Boolean;
var
  ZipName : string;
  fs : TFileStream;
  NewZipInfo : TZipHeader;
begin
  Result := False;

    // �ļ�������
  if not FileExists( FilePath ) then
    Exit;

  try    // ������ȡ�ļ���
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;
  end;

    // ��ȡѹ����Ϣ
  ZipName := ExtractRelativePath( MyFilePath.getPath( SharePath ), FilePath );
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );

  try    // ���ѹ���ļ�
    ZipFile.Add( fs, NewZipInfo );
    fs.Free;  // �ر��ļ���

      // ���ͳ����Ϣ
    TotalSize := TotalSize + NewZipInfo.UncompressedSize;
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    Result := True;
  except
  end;
end;

procedure TCompressShareFileHandle.AddZipFile(FilePath: string);
begin
    // �Ƿ�ɹ����ѹ���ļ�
  if getIsAddFile( FilePath ) then
    Exit;

    // ���ʧ��
  ZipErrorList.Add( FilePath );
end;

constructor TCompressShareFileHandle.Create;
begin
  IsCreated := False;
  ZipErrorList := TStringList.Create;
end;

function TCompressShareFileHandle.CreateZip: Boolean;
begin
  Result := False;

    // ����ѹ���ļ�
  try
    ZipStream := TMemoryStream.Create;
    ZipFile := TZipFile.Create;
    ZipFile.Open( ZipStream, zmWrite );
    IsCreated := True;
    TotalSize := 0;
    ZipSize := 0;
    ZipCount := 0;
    Result := True;
  except
  end;
end;

procedure TCompressShareFileHandle.DestoryZip;
begin
    // �ر�ѹ���ļ�
  try
    IsCreated := False;
    ZipFile.Close;
    ZipFile.Free;
  except
  end;
end;

destructor TCompressShareFileHandle.Destroy;
begin
  ZipErrorList.Free;
  inherited;
end;

function TCompressShareFileHandle.getErrorStr: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ZipErrorList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ZipErrorSplit_File;
    Result := Result + ZipErrorList[i];
  end;
end;

function TCompressShareFileHandle.getIsAddFile(FilePath: string): Boolean;
var
  SourceFileSize : Int64;
begin
  Result := False;

    // ֻѹ��С�� 128 KB ���ļ�
  SourceFileSize := MyFileInfo.getFileSize( FilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // �ȴ���ѹ���ļ�
  if not IsCreated then
  begin
    if not CreateZip then  // �����ļ�ʧ��
      Exit;
  end;

    // ���ѹ���ļ�ʧ��
  if not AddFile( FilePath ) then
    Exit;

  Result := True;
end;

function TCompressShareFileHandle.getZipStream : TMemoryStream;
begin
  if IsCreated then
  begin
    DestoryZip;
    Result := ZipStream;
  end
  else
    Result := TMemoryStream.Create;
end;

procedure TCompressShareFileHandle.SetSharePath(_SharePath: string);
begin
  SharePath := _SharePath;
end;

{ TShareFileSendZipHandle }

function TShareFileSendZipHandle.CreateReadStream: Boolean;
begin
  ReadStream := ZipStream;
  Result := True;
end;

procedure TShareFileSendZipHandle.SetZipStream(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

{ TShareRootRequestHandle }

constructor TShareRootRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TShareRootRequestHandle.HandleShareFile;
var
  ShareFileRequestHandle : TShareFileRequestHandle;
begin
  ShareFileRequestHandle := TShareFileRequestHandle.Create( TcpSocket );
  ShareFileRequestHandle.Update;
  ShareFileRequestHandle.Free;
end;

procedure TShareRootRequestHandle.Update;
begin
  while True do
  begin
      // ����
    HandleShareFile;

      // �ȴ���һ�δ���
    if not WaitingNext then
      Break;
  end;
end;

function TShareRootRequestHandle.WaitingNext: Boolean;
var
  FileReq : string;
  StartTime : TDateTime;
  Num : Integer;
begin
  Result := False;

    // �ȴ���һ�ε�����
  Num := 0;
  while TcpSocket.Connected and MyShareFileHandler.getIsRun do
  begin
      // ��ȡ �������ͣ��ȴ�һ��
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // ����
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // ֻ����ʼ���
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendData( TcpSocket, FileReq_New );  // ���ؿ�ʼ���
      Result := True;
      Break;
    end;

      // ����
    if FileReq = FileReq_End then
      Break;

      // 60��û������, ����
    if Num > 60 then
      Break;

      // ����
    inc( Num );
  end;
end;

end.
