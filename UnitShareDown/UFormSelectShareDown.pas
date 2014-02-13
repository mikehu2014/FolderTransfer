unit UFormSelectShareDown;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, UMyUtil,
  Vcl.ExtCtrls, UIconUtil, Vcl.ImgList, UMainForm, Vcl.Menus, RzButton, inifiles;

type
  TfrmSelectRestore = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbOwner: TLabel;
    btnBrows: TButton;
    edtSharePath: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    cbbSavePath: TComboBox;
    Label4: TLabel;
    edtSaveName: TEdit;
    igShow: TImage;
    btnPreview: TButton;
    tbtnDownCompleted: TRzToolButton;
    pmDownCompleted: TPopupMenu;
    miDown: TMenuItem;
    miRun: TMenuItem;
    miExplorer: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnBrowsClick(Sender: TObject);
    procedure cbbSavePathSelect(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miDownClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    SharePath, OwnerPcID : string;
  public
    function SelectSavePath( _SharePath, _OwnerPcID, OwnerName : string; IsFile : Boolean ): string;
    function getDownCompletedType : string;
  private
    procedure SaveFormIni;
    procedure LoadFormIni;
  private
    procedure ShowPreview;
  end;

const
  ShowHint_RestoreTo = 'Please select files or folders you wish to save';

var
  frmSelectRestore: TfrmSelectRestore;

implementation

uses UMyShareDownApiInfo, UFormShareDownExplorer, UFormPreview;

{$R *.dfm}

procedure TfrmSelectRestore.btnBrowsClick(Sender: TObject);
var
  SelectFolder : string;
begin
    // 选择下载路径
  SelectFolder := cbbSavePath.Text;
  if not MySelectFolderDialog.SelectNormal( ShowHint_RestoreTo, '', SelectFolder ) then
    Exit;
  ShareSavePathHistory.AddItem( SelectFolder );
end;

procedure TfrmSelectRestore.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectRestore.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
  if cbbSavePath.Items.IndexOf( cbbSavePath.Text ) < 0 then
    ShareSavePathHistory.AddItem( cbbSavePath.Text );
end;

procedure TfrmSelectRestore.btnPreviewClick(Sender: TObject);
begin
  if PreviewForm_IsShow then
  begin
//    frmPreView.Close;
    Exit;
  end;

  frmPreView.PreviewFile( SharePath, OwnerPcID );
  ShowPreview;
end;

procedure TfrmSelectRestore.cbbSavePathSelect(Sender: TObject);
begin
  if cbbSavePath.Text <> '' then
    ShareSavePathHistory.AddItem( cbbSavePath.Text );
end;

procedure TfrmSelectRestore.miDownClick(Sender: TObject);
var
  ShowStr, HintStr : string;
  miCheck : TMenuItem;
begin
  try
    if miDown.Checked then
    begin
      ShowStr := 'Download';
      miCheck := miDown;
    end
    else
    if miRun.Checked then
    begin
      ShowStr := 'Run';
      miCheck := miRun;
    end
    else
    if miExplorer.Checked then
    begin
      ShowStr := 'Explorer';
      miCheck := miExplorer;
    end;

    tbtnDownCompleted.Caption := ShowStr;
    if Assigned( miCheck ) then
      tbtnDownCompleted.Hint := miCheck.Hint;
  except
  end;
end;

procedure TfrmSelectRestore.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if PreviewForm_IsShow then
    frmPreView.Close;
end;

procedure TfrmSelectRestore.FormCreate(Sender: TObject);
begin
  LoadFormIni;
end;

procedure TfrmSelectRestore.FormDestroy(Sender: TObject);
begin
  SaveFormIni;
end;

procedure TfrmSelectRestore.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSelectRestore.getDownCompletedType: string;
begin
  if miRun.Checked then
    Result := DownCompletedType_Run
  else
  if miExplorer.Checked then
    Result := DownCompletedType_Explorer
  else
    Result := '';
end;

procedure TfrmSelectRestore.LoadFormIni;
var
  iniFile: TIniFile;
begin
  try
    iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
    miDown.Checked := iniFile.ReadBool( Self.Name, miDown.Name, True );
    miRun.Checked := iniFile.ReadBool( Self.Name, miRun.Name, False );
    miExplorer.Checked := iniFile.ReadBool( Self.Name, miExplorer.Name, False );
    iniFile.Free;

    miDownClick(nil);
  except
  end;
end;


procedure TfrmSelectRestore.SaveFormIni;
var
  iniFile: TIniFile;
begin
    // 无法写入 Ini
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  try
    iniFile.WriteBool( Self.Name, miDown.Name, miDown.Checked );
    iniFile.WriteBool( Self.Name, miRun.Name, miRun.Checked );
    iniFile.WriteBool( Self.Name, miExplorer.Name, miExplorer.Checked );
  except
  end;
  iniFile.Free;
end;

function TfrmSelectRestore.SelectSavePath(_SharePath, _OwnerPcID, OwnerName: string;
  IsFile: Boolean): string;
var
  DownloadPath : string;
  il : TImageList;
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;

    // 生成下载路径
  DownloadPath := MyFilePath.getPath( cbbSavePath.Text ) + ExtractFileName( SharePath );
  DownloadPath := MyFilePath.getNowExistPath( DownloadPath, IsFile );

    // 设置显示
  edtSharePath.Text := SharePath;
  lbOwner.Caption := OwnerName;
  edtSaveName.Text := ExtractFileName( DownloadPath );

    // 显示图标
  try
    if IsFile then
      MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFileExt( SharePath ), igShow.Picture.Icon )
    else
      frmMainForm.ilFolder.GetIcon( 0, igShow.Picture.Icon );
  except
  end;

  Result := '';
  if ShowModal = mrCancel then
    Exit;
  Result := MyFilePath.getPath( cbbSavePath.Text ) + edtSaveName.Text;
end;

procedure TfrmSelectRestore.ShowPreview;
var
  DelWidth : Integer;
begin
    // 设置本窗口位置
  try
    DelWidth := Screen.WorkAreaWidth - ( Self.Width * 2 );
    if DelWidth < 10 then
    begin
      Self.Width := ( Screen.WorkAreaWidth div 2 ) - 20;
      DelWidth := 10;
    end
    else
      DelWidth := DelWidth div 2;
    Self.Left := Self.Width + DelWidth;
  except
  end;

  frmPreView.SetIniPosition( Self.Handle );
  frmPreView.plPreviewTitle.Visible := False;
  frmPreView.Show;
end;

end.
