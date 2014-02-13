unit UShareThread;

interface

uses classes, Sockets, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, Syncobjs,
     UMyDebug, uDebugLock, zip, UChangeInfo;

type

    // 发送 共享文件
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

      // 发送压缩文件
  TShareFileSendZipHandle = class( TShareFileSendHandle )
  private
    ZipStream : TMemoryStream;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
  protected
    function CreateReadStream : Boolean;override;
  end;

     // 压缩共享文件
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

    // 云文件处理
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
  private       // 读取
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadFolderDeep;
    procedure AddZip;
  private       // Get 文件
    procedure GetFile;
    procedure ContinuesGetFile;
    procedure GetZip;
  private       // 搜索文件
    procedure SearchFolder;
  private       // Preview 文件
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewZip;
    procedure PreviewExe;
    procedure PreviewText;
    procedure PreviewMusic;
  end;

    // 处理过程
  TShareFileRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
    SharePath, DownloadPcID : string;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  private
    CompressShareFileHandle : TCompressShareFileHandle;  // 文件压缩器
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ReadBaseInfo;  // 读取请求信息
    function SendAccessResult: Boolean;  // 发送访问结果
    procedure HandleRequest;  // 处理各种请求
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure HandleReq( FileReq, FilePath : string );
  end;

    // 处理过程
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

    // 云文件处理线程
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
    procedure HandleRequest; // 处理请求
  end;
  TReceiveFileHandleThreadList = class( TObjectList< TShareFileHandleThread > )end;


    // 云文件处理
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

    // 提取 Pc Socket 信息
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DownPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DownPcID );

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_ShareDown );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // 连接成功
  if Result then
    Exit;

    // 连接失败
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
      // 处理备份扫描
    if IsConnnected or ConnToDownPc then
      HandleRequest;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Share File Error', e.Message );
  end;

    // 断开连接
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
      // 程序结束
  if not IsRun then
    Exit;

    // 寻找挂起的线程
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

    // 非繁忙
  if not IsBusy then
    Exit;

    // 繁忙的处理
  MySharePathBackConnEvent.ConnDownBusy( DownPcID )
end;

procedure TMyShareFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
  ReceiveThread : TShareFileHandleThread;
begin
    // 程序结束
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // 寻找挂起的线程
  ThreadLock.Enter;
  IsBusy := True;
  if ShareFileThreadList.Count < ThreadCount_Share then
  begin
    IsBusy := False;
    ReceiveThread := TShareFileHandleThread.Create;
    ShareFileThreadList.Add( ReceiveThread );

    MySocketUtil.SendData( TcpSocket, False );    // 发送是否繁忙
    ReceiveThread.SetTcpSocket( TcpSocket );
    ReceiveThread.Resume;
  end;
  ThreadLock.Leave;

    // 通知对方繁忙
  if IsBusy then
  begin
    MySocketUtil.SendData( TcpSocket, True ); // 发送是否繁忙
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

    // 心跳
  if FileReq = FileReq_HeartBeat then
  else  // 压缩出错文件
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

    // 处理请求信息
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

    // 循环访问
  while True do
  begin
       // 已断开连接
    if not TcpSocket.Connected then
      Exit;

      // 共享方结束
    if not MyShareFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 读取 请求类型
    FileReq := MySocketUtil.RevData( TcpSocket );
    if FileReq = FileReq_End then   // 结束标记
      Break;

      // 已断开连接
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 特殊的命令
    if getIsOtherReq( FileReq ) then
      Continue;

      // 读取 请求文件
    FilePath := MySocketUtil.RevData( TcpSocket );

      // 访问出错
    if Pos( SharePath, FilePath ) <= 0 then
      Break;

      // 处理请求信息
    HandleReq( FileReq, FilePath );
  end;
end;

procedure TShareFileRequestHandle.ReadBaseInfo;
begin
  DebugLock.Debug( 'ReadBaseInfo' );

    // 接收目录
  SharePath := MySocketUtil.RevData( TcpSocket );
  DownloadPcID := MySocketUtil.RevData( TcpSocket );

    // 设置压缩器根路径
  CompressShareFileHandle.SetSharePath( SharePath );
end;

function TShareFileRequestHandle.SendAccessResult: Boolean;
var
  AccessResult : string;
begin
  DebugLock.Debug( 'SendAccessResult' );

    // 发送访问结果
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
    // 获取 要处理的信息
  ReadBaseInfo;

    // 发送结果
  if not SendAccessResult then
    Exit;

    // 处理请求结果
  HandleRequest;
end;

{ TCloudFileSendHandle }

procedure TShareFileSendHandle.AddSpeedSpace(Space: Integer);
var
  IsLimited : Boolean;
begin
  MyRefreshSpeedHandler.AddUpload( Space );

    // 刷新速度， 1秒钟刷新一次
  if RefreshSpeedInfo.AddCompleted( Space ) then
  begin
    IsLimited := RevLimitSpace > 0;
    RefreshSpeedInfo.SetLimitInfo( IsLimited, RevLimitSpace );
  end;
end;

function TShareFileSendHandle.CheckNextSend: Boolean;
begin
  Result := True;

    // 1 秒钟 检测一次，是否共享
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
    // Dll 文件不存在， 则先下载
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

    // 等待对方解压完成
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

    // 文件不存在
  if not FileExists( FilePath ) then
    Exit;

  try    // 创建读取文件流
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;
  end;

    // 提取压缩信息
  ZipName := ExtractRelativePath( MyFilePath.getPath( SharePath ), FilePath );
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );

  try    // 添加压缩文件
    ZipFile.Add( fs, NewZipInfo );
    fs.Free;  // 关闭文件流

      // 添加统计信息
    TotalSize := TotalSize + NewZipInfo.UncompressedSize;
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    Result := True;
  except
  end;
end;

procedure TCompressShareFileHandle.AddZipFile(FilePath: string);
begin
    // 是否成功添加压缩文件
  if getIsAddFile( FilePath ) then
    Exit;

    // 添加失败
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

    // 创建压缩文件
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
    // 关闭压缩文件
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

    // 只压缩小于 128 KB 的文件
  SourceFileSize := MyFileInfo.getFileSize( FilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // 先创建压缩文件
  if not IsCreated then
  begin
    if not CreateZip then  // 创建文件失败
      Exit;
  end;

    // 添加压缩文件失败
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
      // 处理
    HandleShareFile;

      // 等待下一次处理
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

    // 等待下一次的连接
  Num := 0;
  while TcpSocket.Connected and MyShareFileHandler.getIsRun do
  begin
      // 读取 请求类型，等待一秒
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // 心跳
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // 只允许开始标记
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendData( TcpSocket, FileReq_New );  // 返回开始标记
      Result := True;
      Break;
    end;

      // 结束
    if FileReq = FileReq_End then
      Break;

      // 60秒没有心跳, 结束
    if Num > 60 then
      Break;

      // 增加
    inc( Num );
  end;
end;

end.
