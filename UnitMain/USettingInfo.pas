unit USettingInfo;

interface

uses UMyUtil, Math, Generics.Collections, SysUtils;

type

    // Pc ��Ϣ
  TPcSettingInfo = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
  end;


    // �ư�ȫ ����
  TCloudSafeSettingInfo = class
  public
    IsCloudSafe : Boolean;
    CloudIDNum : string;
  public
    function getCloudIDNumMD5 : string;
  end;

    // Ӧ�ó��� ����
  TApplicationSettingInfo = class
  public
    IsRunAppStartUp : Boolean;
    IsShowDialogBeforeExist : Boolean;
  end;

    // ������ʾ ����
  THintSettingInfo = class
  public
    IsShowSending : Boolean;
    IsShowSendCompleted : Boolean;
  public
    IsShowReceiving : Boolean;
    IsShowReceiveCompleted : Boolean;
  public
    IsShowDownloadingShare : Boolean;
    IsShowDownloadShareCompleted : Boolean;
  public
    ShowHintTime : Integer;
  end;

const
  TransferSpeed_Fast = 2;
  TransferSpeed_Normal = 1;
  TransferSpeed_Slow = 0;

var
  PcSettingInfo : TPcSettingInfo;
  CloudSafeSettingInfo : TCloudSafeSettingInfo;
  ApplicationSettingInfo : TApplicationSettingInfo;
  HintSettingInfo : THintSettingInfo;

implementation


{ TCloudSafeSettingInfo }

function TCloudSafeSettingInfo.getCloudIDNumMD5: string;
begin
  if IsCloudSafe then
    Result := MyEncrypt.EncodeMD5String( CloudIDNum )
  else
    Result := '';
end;


end.

