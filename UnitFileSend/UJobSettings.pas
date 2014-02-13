unit UJobSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, RzTabs,
  Vcl.Imaging.pngimage;

type

  TScheduleParams = record
  public
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
  end;

  TfrmJobSetting = class(TForm)
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Panel3: TPanel;
    GroupBox1: TGroupBox;
    img7: TImage;
    Label1: TLabel;
    cbbSchedule: TComboBox;
    pcAutoBackup: TRzPageControl;
    tsManual: TRzTabSheet;
    tsMin: TRzTabSheet;
    Label2: TLabel;
    cbbMin: TComboBox;
    tsHour: TRzTabSheet;
    Label7: TLabel;
    cbbHour: TComboBox;
    tsDay: TRzTabSheet;
    Label4: TLabel;
    cbbDay: TComboBox;
    tsWeek: TRzTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    cbbWeek1: TComboBox;
    cbbWeek2: TComboBox;
    tsMonth: TRzTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    cbbMonth1: TComboBox;
    cbbMonth2: TComboBox;
    procedure cbbScheduleSelect(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function ReadScheduleValue1 : Integer;
    function ReadScheduleValue2 : Integer;
  public
    procedure SetFilePath( FilePath : string );
    function ReadIsSet( ScheduleType, ScheduleValue1, ScheduleValue2 : Integer ): Boolean;
    function ReadSchedule : TScheduleParams;
  end;

  JobSettingUtil = class
  public
    class procedure SetSchedule( ScheduleType, ScheduleValue1, ScheduleValue2 : Integer );
    class function getScheduleValue1( ScheduleType : Integer ): Integer;
    class function getScheduleValue2( ScheduleType : Integer ): Integer;
  end;

var
  frmJobSetting: TfrmJobSetting;

implementation

uses UMyUtil;

{$R *.dfm}

{ TfrmJobSetting }

procedure TfrmJobSetting.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmJobSetting.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmJobSetting.cbbScheduleSelect(Sender: TObject);
begin
  pcAutoBackup.ActivePageIndex := cbbSchedule.ItemIndex;
end;

procedure TfrmJobSetting.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmJobSetting.ReadIsSet(ScheduleType, ScheduleValue1,
  ScheduleValue2: Integer): Boolean;
begin
  JobSettingUtil.SetSchedule( ScheduleType, ScheduleValue1, ScheduleValue2 );
  pcAutoBackup.ActivePageIndex := ScheduleType;
  Result := ShowModal = mrOk;
end;

function TfrmJobSetting.ReadSchedule: TScheduleParams;
begin
  Result.ScheduleType := cbbSchedule.ItemIndex;
  Result.ScheduleValue1 := ReadScheduleValue1;
  Result.ScheduleValue2 := ReadScheduleValue2;
end;

function TfrmJobSetting.ReadScheduleValue1: Integer;
begin
  Result := JobSettingUtil.getScheduleValue1( cbbSchedule.ItemIndex );
end;

function TfrmJobSetting.ReadScheduleValue2: Integer;
begin
  Result := JobSettingUtil.getScheduleValue2( cbbSchedule.ItemIndex );
end;

procedure TfrmJobSetting.SetFilePath(FilePath: string);
begin
  Caption := MyFileInfo.getFileName( FilePath ) + ' Schedule';
end;

{ JobSettingUtil }

class function JobSettingUtil.getScheduleValue1(ScheduleType: Integer): Integer;
begin
  with frmJobSetting do
  begin
    if ScheduleType = ScheduleType_Min then
      Result := cbbMin.ItemIndex
    else
    if ScheduleType = ScheduleType_Hour then
      Result := cbbHour.ItemIndex
    else
    if ScheduleType = ScheduleType_Day then
      Result := cbbDay.ItemIndex
    else
    if ScheduleType = ScheduleType_Week then
      Result := cbbWeek1.ItemIndex
    else
    if ScheduleType = ScheduleType_Month then
      Result := cbbMonth1.ItemIndex
    else
      Result := 0;
  end;
end;

class function JobSettingUtil.getScheduleValue2(ScheduleType: Integer): Integer;
begin
  with frmJobSetting do
  begin
    if ScheduleType = ScheduleType_Week then
      Result := cbbWeek2.ItemIndex
    else
    if ScheduleType = ScheduleType_Month then
      Result := cbbMonth2.ItemIndex
    else
      Result := 0;
  end;
end;

class procedure JobSettingUtil.SetSchedule(ScheduleType, ScheduleValue1,
  ScheduleValue2: Integer);
begin
  with frmJobSetting do
  begin
    cbbSchedule.ItemIndex := ScheduleType;
    if ScheduleType = ScheduleType_Min then
      cbbMin.ItemIndex := ScheduleValue1
    else
    if ScheduleType = ScheduleType_Hour then
      cbbHour.ItemIndex := ScheduleValue1
    else
    if ScheduleType = ScheduleType_Day then
      cbbDay.ItemIndex := ScheduleValue1
    else
    if ScheduleType = ScheduleType_Week then
    begin
      cbbWeek1.ItemIndex := ScheduleValue1;
      cbbWeek2.ItemIndex := ScheduleValue2;
    end
    else
    if ScheduleType = ScheduleType_Month then
    begin
      cbbMonth1.ItemIndex := ScheduleValue1;
      cbbMonth2.ItemIndex := ScheduleValue2;
    end
  end;
end;

end.
