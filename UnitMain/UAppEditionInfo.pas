unit UAppEditionInfo;

interface

uses classes, SysUtils, DateUtils, Defence, Forms, UChangeInfo, IniFiles, UMyUtil;

type

    // ��ʾ������Ϣ
  TShowPiracyFaceInfo = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // ����������Ϣ
  TShowPiracyErrorFaceInfo = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // ����Ƿ����
  TAppPiracyCheckHandle = class
  public
    procedure Update;
  private
    function getAppPiracy : Boolean;
    procedure ShowPiracyFace;
  end;

    // ��ʱ��
  MyAppPiracyAutoApi = class
  public
    class procedure CheckIsPiracy;
    class procedure MakeAppError;
    class procedure ShowCreackedEdition;
  end;

implementation

uses UMainForm, UMyClient, UNetworkFace, UMyNetPcInfo, UMyTimerThread,
     UMySendDataInfo, UMyReceiveDataInfo, UMyShareDataInfo, UMyShareDOwnDataInfo;

{ TShowPiracyFaceInfo }

procedure TShowPiracyFaceInfo.Update;
begin
  frmMainForm.Caption := ' ' + frmMainForm.Caption;
end;

{ MyAppPiracyAutoApi }

class procedure MyAppPiracyAutoApi.CheckIsPiracy;
var
  AppPiracyCheckHandle : TAppPiracyCheckHandle;
begin
  AppPiracyCheckHandle := TAppPiracyCheckHandle.Create;
  AppPiracyCheckHandle.Update;
  AppPiracyCheckHandle.Free;
end;

class procedure MyAppPiracyAutoApi.MakeAppError;
var
  RanNum : Integer;
begin
    // ʮ���Ӽ��һ�Σ� ����ĸ��� 1 / 6 , һСʱ��
  Randomize;
  if Random( 6 ) <> 0 then
    Exit;

    // �������
  RanNum := Random( 5 );
  if RanNum = 0 then
    MySendInfo := nil
  else
  if RanNum = 1 then
    MyFileReceiveInfo := nil
  else
  if RanNum = 2 then
    MyShareDownInfo := nil
  else
  if RanNum = 3 then
    MySharePathInfo := nil
  else
  if RanNum = 4 then
    MyNetPcInfo := nil;
  MyTimerHandler.AddTimer( HandleType_ShowPiracyError, 30 );  // 30��󵯳�����
end;

class procedure MyAppPiracyAutoApi.ShowCreackedEdition;
var
  ShowPiracyErrorFaceInfo : TShowPiracyErrorFaceInfo;
begin
  MyTimerHandler.RemoveTimer( HandleType_ShowPiracyError );
  ShowPiracyErrorFaceInfo := TShowPiracyErrorFaceInfo.Create;
  ShowPiracyErrorFaceInfo.AddChange;
end;

{ TAppPiracyCheckHandle }

function TAppPiracyCheckHandle.getAppPiracy: Boolean;
var
  MyCRC32: longInt;
  strA, strB: string;
begin
  MyCRC32 := $00112233;
  MyFileCRC32(Application.ExeName, MyCRC32);
  strA := inttohex(TrueCRC32, 8);
  strB := inttohex(MyCRC32, 8);
  Result := CompareStr(strA, strB) <> 0;
end;

procedure TAppPiracyCheckHandle.ShowPiracyFace;
var
  ShowPiracyFaceInfo : TShowPiracyFaceInfo;
begin
  ShowPiracyFaceInfo := TShowPiracyFaceInfo.Create;
  ShowPiracyFaceInfo.AddChange;
end;

procedure TAppPiracyCheckHandle.Update;
begin
    // �ǵ��棬����
  if not getAppPiracy then
    Exit;

    // ����ģʽ
  if AppInfo_IsDebug then
    Exit;

    // ������ʾ������Ϣ
  ShowPiracyFace;

    // ���ͷ��ڴ�
  Memory_IsFree := False;

    // ��ʱ����ʮ���Ӽ��һ��
  MyTimerHandler.AddTimer( HandleType_MakePiracyError, 600 );
end;

{ TShowPiracyErrorFaceInfo }

procedure TShowPiracyErrorFaceInfo.Update;
begin
  MyMessageBox.ShowError( 'Cracked Version' );
end;

end.
