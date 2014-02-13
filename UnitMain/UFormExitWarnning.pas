unit UFormExitWarnning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmExitConfirm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    ChkIsShow: TCheckBox;
    procedure btnYesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExitConfirm: TfrmExitConfirm;

implementation

uses UFormSetting, IniFiles, UMyUtil;

{$R *.dfm}

procedure TfrmExitConfirm.btnYesClick(Sender: TObject);
var
  IniFile : TIniFile;
begin
  if ChkIsShow.Checked then
  begin
      // Œﬁ∑®–¥»Î Ini
    if not MyIniFile.ConfirmWriteIni then
      Exit;

    IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
    try
      IniFile.WriteBool( frmSetting.Name, frmSetting.chkShowAppExistDialog.Name, False );
    except
    end;
    IniFile.Free;
  end;
end;

end.
