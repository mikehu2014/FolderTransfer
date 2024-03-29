unit UMainFormThread;

interface

uses classes, SyncObjs, UMyUtil, SysUtils, DateUtils;

type

    // 刷新速度控制器
  TMyRefreshSpeedHandler = class
  public
    DataLock : TCriticalSection;
    UploadSize : Integer;
    DownloadSize : Integer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddDownload( Space : Integer );
    procedure AddUpload( Space : Integer );
    procedure RefreshSpeed;
  end;

var
  MyRefreshSpeedHandler : TMyRefreshSpeedHandler;

implementation

uses UMainFormFace;

{ TMyRefreshSpeedHandler }

procedure TMyRefreshSpeedHandler.AddDownload(Space: Integer);
begin
  DataLock.Enter;
  DownloadSize := DownloadSize + Space;
  DataLock.Leave;
end;

procedure TMyRefreshSpeedHandler.AddUpload(Space: Integer);
begin
  DataLock.Enter;
  UploadSize := UploadSize + Space;
  DataLock.Leave;
end;

constructor TMyRefreshSpeedHandler.Create;
begin
  DataLock := TCriticalSection.Create;
  UploadSize := 0;
  DownloadSize := 0;
end;

destructor TMyRefreshSpeedHandler.Destroy;
begin
  DataLock.Free;
  inherited;
end;

procedure TMyRefreshSpeedHandler.RefreshSpeed;
var
  ShowStr : string;
  DownSpeedChangeInfo : TDownSpeedChangeInfo;
  UpSpeedChangeInfo : TUpSpeedChangeInfo;
begin
  DataLock.Enter;

    // 下载速度
  ShowStr := MySpeed.getSpeedStr( DownloadSize );
  DownSpeedChangeInfo := TDownSpeedChangeInfo.Create( ShowStr );
  DownSpeedChangeInfo.AddChange;
  DownloadSize := 0;

    // 上传速度
  ShowStr := MySpeed.getSpeedStr( UploadSize );
  UpSpeedChangeInfo := TUpSpeedChangeInfo.Create( ShowStr );
  UpSpeedChangeInfo.AddChange;
  UploadSize := 0;

  DataLock.Leave;
end;

end.
