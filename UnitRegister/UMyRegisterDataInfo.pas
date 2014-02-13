unit UMyRegisterDataInfo;

interface

uses Generics.Collections, UDataSetInfo, SysUtils;

type

{$Region ' Pc激活 数据结构 ' }

    // 激活Pc信息
  TActivatePcInfo = class
  public
    PcID : string;
    LicenseStr : string;
  public
    constructor Create( _PcID : string );
    procedure SetLicenseStr( _LicenseStr : string );
  end;
  TActivatePcList = class( TObjectList<TActivatePcInfo> )end;

{$EndRegion}

{$Region ' Pc激活 数据接口 ' }

    // 访问 数据 List 接口
  TActivatePcListAccessInfo = class
  protected
    ActivatePcList : TActivatePcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TActivatePcAccessInfo = class( TActivatePcListAccessInfo )
  public
    PcID : string;
  protected
    ActivatePcIndex : Integer;
    ActivatePcInfo : TActivatePcInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindActivatePcInfo: Boolean;
  end;

{$EndRegion}

{$Region ' Pc激活 数据修改 ' }

    // 修改父类
  TActivatePcWriteInfo = class( TActivatePcAccessInfo )
  end;


    // 添加
  TActivatePcAddInfo = class( TActivatePcWriteInfo )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;
  end;

    // 删除
  TActivatePcRemoveInfo = class( TActivatePcWriteInfo )
  public
    procedure Update;
  end;



{$EndRegion}

{$Region ' Pc激活 数据读取 ' }

    // 读取 License 信息
  TActivatePcReadLicense = class( TActivatePcAccessInfo )
  public
    function get : string;
  end;

    // 读取 激活信息
  ActivatePcInfoReadUtil = class
  public
    class function ReadLicenseStr( PcID : string ): string;
  end;

{$EndRegion}


{$Region ' Pc注册 数据结构 ' }

    // Pc 注册信息
  TRegisterPcInfo = class
  public
    PcID : string;
    HardCode : string;
    RegisterEdition : string;
  public
    constructor Create( _PcID : string );
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
  end;
  TRegisterPcList = class( TObjectList<TRegisterPcInfo> )end;

{$EndRegion}

{$Region ' Pc注册 数据接口 ' }

    // 访问 数据 List 接口
  TRegisterPcListAccessInfo = class
  protected
    RegisterPcList : TRegisterPcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TRegisterPcAccessInfo = class( TRegisterPcListAccessInfo )
  public
    PcID : string;
  protected
    RegisterPcIndex : Integer;
    RegisterPcInfo : TRegisterPcInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindRegisterPcInfo: Boolean;
  end;

    // 修改父类
  TRegisterPcWriteInfo = class( TRegisterPcAccessInfo )
  end;

    // 读取父类
  TRegisterPcReadInfo = class( TRegisterPcAccessInfo )
  end;

{$EndRegion}

{$Region ' Pc注册 数据修改 ' }

    // 添加
  TRegisterPcAddInfo = class( TRegisterPcWriteInfo )
  public
    HardCode : string;
    RegisterEdition : string;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;
  end;

      // 修改
  TRegisterPcSetRegisterEditionInfo = class( TRegisterPcWriteInfo )
  public
    RegisterEdition : string;
  public
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;
  end;


    // 删除
  TRegisterPcRemoveInfo = class( TRegisterPcWriteInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Pc注册 数据读取 ' }

    // 是否收到免费版限制
  TRegisterPcIsFreeLimtRead = class( TRegisterPcReadInfo )
  public
    function get : Boolean;
  end;

  RegisterPcInfoReadUtil = class
  public
    class function ReadIsFreeLimit( PcID : string ): Boolean;
  end;

{$EndRegion}


    // 注册信息
  TMyRegisterInfo = class( TMyDataInfo )
  public  // 本机信息
    RegisterEdition : string;
    LastDate : TDateTime;
    IsFreeLimit, IsRemoteLimit : Boolean;
  public  // 其他 Pc 注册信息
    RegisterPcList : TRegisterPcList;
  public  // 批激活信息
    ActivatePcList : TActivatePcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;


var
  MyRegisterInfo : TMyRegisterInfo;

implementation

uses UMyRegisterApiInfo;

{ TActivateInfo }

constructor TActivatePcInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TActivatePcInfo.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

{ TMyRegisterInfo }

constructor TMyRegisterInfo.Create;
begin
  inherited;
  RegisterPcList := TRegisterPcList.Create;
  ActivatePcList := TActivatePcList.Create;
end;

destructor TMyRegisterInfo.Destroy;
begin
  RegisterPcList.Free;
  ActivatePcList.Free;
  inherited;
end;

{ TActivatePcListAccessInfo }

constructor TActivatePcListAccessInfo.Create;
begin
  MyRegisterInfo.EnterData;
  ActivatePcList := MyRegisterInfo.ActivatePcList;
end;

destructor TActivatePcListAccessInfo.Destroy;
begin
  MyRegisterInfo.LeaveData;
  inherited;
end;

{ TActivatePcAccessInfo }

constructor TActivatePcAccessInfo.Create( _PcID : string );
begin
  inherited Create;
  PcID := _PcID;
end;

function TActivatePcAccessInfo.FindActivatePcInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to ActivatePcList.Count - 1 do
    if ( ActivatePcList[i].PcID = PcID ) then
    begin
      Result := True;
      ActivatePcIndex := i;
      ActivatePcInfo := ActivatePcList[i];
      break;
    end;
end;

{ TActivatePcAddInfo }

procedure TActivatePcAddInfo.SetLicenseStr( _LicenseStr : string );
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcAddInfo.Update;
begin
  if FindActivatePcInfo then
    Exit;

  ActivatePcInfo := TActivatePcInfo.Create( PcID );
  ActivatePcInfo.SetLicenseStr( LicenseStr );
  ActivatePcList.Add( ActivatePcInfo );
end;

{ TActivatePcRemoveInfo }

procedure TActivatePcRemoveInfo.Update;
begin
  if not FindActivatePcInfo then
    Exit;

  ActivatePcList.Delete( ActivatePcIndex );
end;

{ ActivatePcInfoReadUtil }

class function ActivatePcInfoReadUtil.ReadLicenseStr(PcID: string): string;
var
  ActivatePcReadLicense : TActivatePcReadLicense;
begin
  ActivatePcReadLicense := TActivatePcReadLicense.Create( PcID );
  Result := ActivatePcReadLicense.get;
  ActivatePcReadLicense.Free;
end;

{ TActivatePcReadLicense }

function TActivatePcReadLicense.get: string;
begin
  Result := '';
  if not FindActivatePcInfo then
    Exit;
  Result := ActivatePcInfo.LicenseStr;
end;

{ TRegisterPcInfo }

constructor TRegisterPcInfo.Create( _PcID : string );
begin
  PcID := _PcID;
end;

procedure TRegisterPcInfo.SetHardCode(_HardCode: string);
begin
  HardCode := _HardCode;
end;

procedure TRegisterPcInfo.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

{ TRegisterPcListAccessInfo }

constructor TRegisterPcListAccessInfo.Create;
begin
  MyRegisterInfo.EnterData;
  RegisterPcList := MyRegisterInfo.RegisterPcList;
end;

destructor TRegisterPcListAccessInfo.Destroy;
begin
  MyRegisterInfo.LeaveData;
  inherited;
end;

{ TRegisterPcAccessInfo }

constructor TRegisterPcAccessInfo.Create( _PcID : string );
begin
  inherited Create;
  PcID := _PcID;
end;

function TRegisterPcAccessInfo.FindRegisterPcInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to RegisterPcList.Count - 1 do
    if ( RegisterPcList[i].PcID = PcID ) then
    begin
      Result := True;
      RegisterPcIndex := i;
      RegisterPcInfo := RegisterPcList[i];
      break;
    end;
end;

{ TRegisterPcAddInfo }

procedure TRegisterPcAddInfo.SetHardCode(_HardCode: string);
begin
  HardCode := _HardCode;
end;

procedure TRegisterPcAddInfo.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterPcAddInfo.Update;
begin
  if not FindRegisterPcInfo then
  begin
    RegisterPcInfo := TRegisterPcInfo.Create( PcID );
    RegisterPcList.Add( RegisterPcInfo );
  end;

  RegisterPcInfo.SetHardCode( HardCode );
  RegisterPcInfo.SetRegisterEdition( RegisterEdition );
end;

{ TRegisterPcRemoveInfo }

procedure TRegisterPcRemoveInfo.Update;
begin
  if not FindRegisterPcInfo then
    Exit;

  RegisterPcList.Delete( RegisterPcIndex );
end;

{ TRegisterPcSetRegisterEditionInfo }

procedure TRegisterPcSetRegisterEditionInfo.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterPcSetRegisterEditionInfo.Update;
begin
  if not FindRegisterPcInfo then
    Exit;
  RegisterPcInfo.RegisterEdition := RegisterEdition;
end;


{ RegisterPcInfoReadUtil }

class function RegisterPcInfoReadUtil.ReadIsFreeLimit(PcID: string): Boolean;
var
  RegisterPcIsFreeLimtRead : TRegisterPcIsFreeLimtRead;
begin
  RegisterPcIsFreeLimtRead := TRegisterPcIsFreeLimtRead.Create( PcID );
  Result := RegisterPcIsFreeLimtRead.get;
  RegisterPcIsFreeLimtRead.Free;
end;

{ TRegisterPcIsFreeLimtRead }

function TRegisterPcIsFreeLimtRead.get: Boolean;
begin
  Result := True;
  if not FindRegisterPcInfo then
    Exit;
  Result := ( RegisterPcInfo.RegisterEdition <> RegisterEdition_Professional ) and
            ( RegisterPcInfo.RegisterEdition <> RegisterEdition_Enterprise );
end;

end.
