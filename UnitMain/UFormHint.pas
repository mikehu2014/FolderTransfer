unit UFormHint;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, UMainForm, UIconUtil;

type

  TShowHintParams = record
  public
    FileName, Destination : string;
    IsFile : Boolean;
    FormCaption, DestinationType : string;
  end;

  TfrmHint = class(TForm)
    tmrClose: TTimer;
    plMain: TPanel;
    ilShowFile: TImage;
    lbDestination: TLabel;
    lbFileName: TLabel;
    plRestoreTitle: TPanel;
    Image1: TImage;
    tbnClose: TButton;
    Panel1: TPanel;
    lbTitle: TLabel;
    tbMain: TToolBar;
    tbtnExplorer: TToolButton;
    tbtnRun: TToolButton;
    procedure tmrCloseTimer(Sender: TObject);
    procedure tbtnExplorerClick(Sender: TObject);
    procedure tbtnRunClick(Sender: TObject);
    procedure tbnCloseClick(Sender: TObject);
    procedure plMainMouseEnter(Sender: TObject);
    procedure plMainMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure SaveIni;
    procedure LoadIni;
  private
    FilePath : string;
  public
    procedure ShowSending( Params : TShowHintParams );
    procedure ShowSendCompleted( Params : TShowHintParams );
  public
    procedure ShowReceiving( Params : TShowHintParams );
    procedure ShowReceiveCompelted( Params : TShowHintParams );
  public
    procedure ShowDownloadingShare( Params : TShowHintParams );
    procedure ShowDownShareCompleted( Params : TShowHintParams );
  private
    procedure ShowHint( Params : TShowHintParams );
  end;


const
  FormCaption_Sending = 'File Sending';
  FormCaption_SendCompleted = 'Send File Completed';

  FormCaption_Receiving = 'File Receiving';
  FormCaption_ReceiveCompelted = 'Receive File Completed';

  FormCaption_DownloadingShare = 'Shared File Downloading';
  FormCaption_DownlShareCompleted = 'Download Shared File Completed';

const
  Destination_SendTo = 'Send To';
  Destination_ReceiveFrom = 'Receive From';
  Destination_DownloadFrom = 'Download From';

  FormHintRecive_Heith = 136;
  FormHintNormal_Heith = 136 - 24;

var
  frmHint: TfrmHint;

implementation

uses UMyUtil, inifiles, UMyRegisterApiInfo;

{$R *.dfm}

procedure TfrmHint.FormCreate(Sender: TObject);
begin
  LoadIni;
end;

procedure TfrmHint.FormDestroy(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmHint.LoadIni;
var
  IniFile : TIniFile;
begin
//  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
//  chkAutoReceive.Checked := IniFile.ReadBool( Self.Name, chkAutoReceive.Name, False );
//  IniFile.Free;
end;

procedure TfrmHint.plMainMouseEnter(Sender: TObject);
begin
  tmrClose.Enabled := False;
end;

procedure TfrmHint.plMainMouseLeave(Sender: TObject);
begin
  tmrClose.Enabled := True;
end;

procedure TfrmHint.SaveIni;
var
  IniFile : TIniFile;
begin
//    // 无法写入 Ini
//  if not MyIniFile.ConfirmWriteIni then
//    Exit;
//
//  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
//  try
//    IniFile.WriteBool( Self.Name, chkAutoReceive.Name, chkAutoReceive.Checked );
//  except
//  end;
//  IniFile.Free;
end;

procedure TfrmHint.ShowDownloadingShare(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_DownloadingShare;
  Params.DestinationType := Destination_DownloadFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowDownShareCompleted(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_DownlShareCompleted;
  Params.DestinationType := Destination_DownloadFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowHint(Params : TShowHintParams);
begin
  FilePath := Params.FileName;
  tbtnExplorer.Enabled := True;
  tbtnRun.Enabled := Params.IsFile;

  try
    if Params.IsFile then
      MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFilePath( FilePath ), ilShowFile.Picture.Icon )
    else
      frmMainForm.ilFolder.GetIcon( 0, ilShowFile.Picture.Icon );
  except
  end;

  lbTitle.Caption := Params.FormCaption;
  lbFileName.Caption := 'Remote Files: ' + ExtractFileName( Params.FileName );
  lbDestination.Caption := Params.DestinationType + ': ' + Params.Destination;
  tmrClose.Enabled := False;
  tmrClose.Enabled := True;

//  if Params.FormCaption = FormCaption_ReceiveCompelted then
//  begin
//    Self.Height := FormHintRecive_Heith;
//    plAutoReceive.Visible := True;
//
//      // 自动 Explorer
//    if chkAutoReceive.Checked then
//      tbtnExplorer.Click;
//  end
//  else
//  begin
//    plAutoReceive.Visible := False;
//    Self.Height := FormHintNormal_Heith;
//  end;

  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;

  Show;
end;

procedure TfrmHint.ShowReceiveCompelted(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_ReceiveCompelted;
  Params.DestinationType := Destination_ReceiveFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowReceiving(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_Receiving;
  Params.DestinationType := Destination_ReceiveFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowSendCompleted(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_SendCompleted;
  Params.DestinationType := Destination_SendTo;
  ShowHint( Params );
end;

procedure TfrmHint.ShowSending( Params : TShowHintParams );
begin
  Params.FormCaption := FormCaption_Sending;
  Params.DestinationType := Destination_SendTo;
  ShowHint( Params );
end;

procedure TfrmHint.tbnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHint.tbtnExplorerClick(Sender: TObject);
begin
  MyExplore.OpenFolder( FilePath );
end;

procedure TfrmHint.tbtnRunClick(Sender: TObject);
begin
  MyExplore.OpenFile( FilePath );
end;

procedure TfrmHint.tmrCloseTimer(Sender: TObject);
begin
  Close;
  tmrClose.Enabled := False;
end;


end.
