unit UFormBackupSpeedLimit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmBackupSpeedLimit = class(TForm)
    rbNoLimit: TRadioButton;
    rbLimit: TRadioButton;
    edtSpeed: TEdit;
    cbbSpeedType: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure rbNoLimitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edtSpeedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    function ResetLimit( IsLimit : Boolean; LimitValue, LimitType : Integer ) : Boolean;
  public
    function getIsLimit : Boolean;
    function getSpeedType : Integer;
    function getSpeedValue : Integer;
  end;

var
  frmBackupSpeedLimit: TfrmBackupSpeedLimit;

implementation

{$R *.dfm}

procedure TfrmBackupSpeedLimit.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupSpeedLimit.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmBackupSpeedLimit.edtSpeedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnOK.Click;
end;

procedure TfrmBackupSpeedLimit.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
  if rbLimit.Checked then
     edtSpeed.SetFocus;
end;

function TfrmBackupSpeedLimit.ResetLimit( IsLimit : Boolean;
  LimitValue, LimitType  : Integer ): Boolean;
begin
    // 是否限制
  if IsLimit then
    rbLimit.Checked := True
  else
    rbNoLimit.Checked := True;

    // 速度信息
  edtSpeed.Text := IntToStr( LimitValue );
  if ( LimitType < cbbSpeedType.Items.Count ) and ( LimitType >= 0 ) then
    cbbSpeedType.ItemIndex := LimitType;

    // 是否 点击 OK 结束
  Result := ShowModal = mrOk;
end;

function TfrmBackupSpeedLimit.getIsLimit: Boolean;
begin
  Result := rbLimit.Checked;
end;

function TfrmBackupSpeedLimit.getSpeedType: Integer;
begin
  Result := cbbSpeedType.ItemIndex;
end;

function TfrmBackupSpeedLimit.getSpeedValue: Integer;
begin
  Result := StrToIntDef( edtSpeed.Text, 0 );
end;

procedure TfrmBackupSpeedLimit.rbNoLimitClick(Sender: TObject);
var
  IsEnable : Boolean;
begin
  IsEnable := rbLimit.Checked;
  edtSpeed.Enabled := IsEnable;
  cbbSpeedType.Enabled := IsEnable;
end;

end.
