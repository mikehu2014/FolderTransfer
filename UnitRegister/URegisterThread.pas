unit URegisterThread;

interface

uses classes, SysUtils, DateUtils;

type

    // �޸� ϵͳ����ʱ��
  TUpdateAppRunTime = class
  private
    DelRunTime : Integer;
  private
    RunTime : Int64;
  public
    constructor Create( _DelRunTime : Integer );
    procedure Update;
  private
    procedure ReadRunTime;
    procedure UpdateRunTIme;
    procedure WriteRunTime;
  private
    procedure CheckAppStartTime;
    procedure CheckWebTime;
  end;

    // ʱ�Ӽ�¼
  MyRegisterAutoApi = class
  public
    class procedure UpdateRunTime;
  end;

implementation

uses URegisterInfoIO, UMyRegisterApiInfo;

{ TWriteAppRunTime }

procedure TUpdateAppRunTime.CheckAppStartTime;
var
  ReadAppStartTime : TReadAppStartTime;
  IsExistStartTimeKey : Boolean;
  WriteAppStartTime : TWriteAppStartTime;
begin
    // ��ȡ ����ʼʱ�� Key , �ж��Ƿ����
  ReadAppStartTime := TReadAppStartTime.Create;
  ReadAppStartTime.ReadKey;
  IsExistStartTimeKey := ( ReadAppStartTime.RegistryKey <> '' ) or
                         ( ReadAppStartTime.AppDataKey <> '' );
  ReadAppStartTime.Free;

    // ���� ��
  if IsExistStartTimeKey then
    Exit;

    // ��������д��
  WriteAppStartTime := TWriteAppStartTime.Create( Now );
  WriteAppStartTime.Update;
  WriteAppStartTime.Free;
end;

procedure TUpdateAppRunTime.CheckWebTime;
var
  GetWebTime : TGetWebTime;
  WebTime : TDateTime;
  WriteWebTime : TWriteWebTime;
begin
    // ������վ ��ȡ����ʱ��
  GetWebTime := TGetWebTime.Create;
  WebTime := GetWebTime.get;
  GetWebTime.Free;

    // �޷�������վ
  if WebTime <> -1 then
  begin
      // ��¼��η�����վ��ʱ��
    WriteWebTime := TWriteWebTime.Create( WebTime );
    WriteWebTime.Update;
    WriteWebTime.Free;
  end;
end;

constructor TUpdateAppRunTime.Create(_DelRunTime: Integer);
begin
  DelRunTime := _DelRunTime;
end;

procedure TUpdateAppRunTime.UpdateRunTIme;
begin
  RunTime := RunTime + DelRunTime;
end;


procedure TUpdateAppRunTime.ReadRunTime;
var
  ReadAppRunTime : TReadAppRunTime;
begin
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;
end;

procedure TUpdateAppRunTime.WriteRunTime;
var
  WriteAppRunTime : TWriteAppRunTime;
begin
  WriteAppRunTime := TWriteAppRunTime.Create( RunTime );
  WriteAppRunTime.Update;
  WriteAppRunTime.Free;
end;

procedure TUpdateAppRunTime.Update;
begin
  ReadRunTime;
  UpdateRunTIme;
  WriteRunTime;

  CheckAppStartTime;
  CheckWebTime;
end;


{ RegisterAutoHandle }

class procedure MyRegisterAutoApi.UpdateRunTime;
var
  UpdateAppRunTime : TUpdateAppRunTime;
begin
  UpdateAppRunTime := TUpdateAppRunTime.Create( 30 );
  UpdateAppRunTime.Update;
  UpdateAppRunTime.Free;
end;

end.
