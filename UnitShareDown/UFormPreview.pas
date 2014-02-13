unit UFormPreview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, math, RzTabs, Generics.Collections,
  RzPanel, Vcl.ComCtrls, Vcl.ToolWin, Winapi.GDIPAPI, Winapi.GDIPOBJ, Vcl.ImgList, Winapi.ActiveX,
  Vcl.Grids, Vcl.ValEdit, Vcl.Menus;

type

  TImagePageInfo = class
  public
    Page : TRzTabSheet;
    Image : TImage;
    FilePath : string;
  public
    constructor Create( _Page : TRzTabSheet; _Image : TImage );
  end;
  TImagePageList = class( TObjectList<TImagePageInfo> )end;

  TfrmPreView = class(TForm)
    PcMain: TRzPageControl;
    tsPirture: TRzTabSheet;
    tsText: TRzTabSheet;
    iPreview: TImage;
    PcImage: TRzPageControl;
    tsEmptyImage: TRzTabSheet;
    tsImage1: TRzTabSheet;
    tsImage2: TRzTabSheet;
    tsImage3: TRzTabSheet;
    tsImage4: TRzTabSheet;
    tsImage5: TRzTabSheet;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    plMain: TPanel;
    ilTb: TImageList;
    plCenter: TPanel;
    tsDoc: TRzTabSheet;
    reDoc: TRichEdit;
    tsExcel: TRzTabSheet;
    LvExcel: TListView;
    tsZip: TRzTabSheet;
    LvZip: TListView;
    tsExe: TRzTabSheet;
    plExe: TPanel;
    tsMusic: TRzTabSheet;
    Panel2: TPanel;
    plPreviewTitle: TPanel;
    ImgPreview: TImage;
    edtPreviewPath: TEdit;
    veMusic: TValueListEditor;
    veExe: TValueListEditor;
    pbPreview: TProgressBar;
    tmrProgress: TTimer;
    pmSelect: TPopupMenu;
    miDownRun: TMenuItem;
    miDownExplorer: TMenuItem;
    ilTbGray: TImageList;
    plStatus: TPanel;
    Image1: TImage;
    lbStatus: TLabel;
    plTextCenter: TPanel;
    plSearch: TPanel;
    Label1: TLabel;
    cbbSearchName: TComboBox;
    btnNext: TButton;
    plSearchNotFind: TPanel;
    Image2: TImage;
    Label2: TLabel;
    mmoPreview: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbtnMaxClick(Sender: TObject);
    procedure tbtnDownloadClick(Sender: TObject);
    procedure tmrProgressTimer(Sender: TObject);
    procedure tbtnRunClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNextClick(Sender: TObject);
    procedure cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rePreviewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mmoPreviewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure AddSearchHistory( SearchName : string );
    procedure SaveIni;
    procedure LoadIni;
  private
    procedure IniImageList;
    procedure ClearImg;
  public
    ImagePos : Integer;
    ImagePageList : TImagePageList;
    ShowPath, SavePath : string;
  public
    procedure SetIniPosition( FormHandle : Integer );
    procedure PreviewFile( FilePath, OwnerPcID : string );
  public
    procedure SetShowPath( _ShowPath : string );
  end;

      // 预览文件入口
  TPreviewFileHandle = class
  public
    FilePath : string;
    OwnerID : string;
  public
    constructor Create( _FilePath : string );
    procedure SetOwnerID( _OwnerID : string );
    procedure Update;
  private
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewCompress;
    procedure PreviewExe;
    procedure PreviewText;
    procedure PreviewMusic;
  end;

const
  ImgTag_Next = 1;
  ImgTag_Last = 2;

var
  frmPreView: TfrmPreView;
  PreviewForm_IsShow : Boolean = False;

  Original_Width : Integer;
  Original_Height : Integer;

implementation

uses UFormShareDownExplorer, UMyUtil, UIconUtil, UMyShareDownApiInfo, UMyRegisterApiInfo,
      UFormSelectShareDown, IniFiles;

{$R *.dfm}

procedure TfrmPreView.AddSearchHistory(SearchName: string);
var
  i: Integer;
begin
    // 已存在
  if cbbSearchName.Items.IndexOf( SearchName ) >= 0 then
    Exit;

    // 超过限制，删除组后一个
  if cbbSearchName.Items.Count >= 10 then
    cbbSearchName.Items.Delete( 9 );

    // 添加
  cbbSearchName.Items.Insert( 0, SearchName );
end;

procedure TfrmPreView.btnNextClick(Sender: TObject);
var
  StartPos, FindPos : Integer;
  SearchText:string;
  FullText : string;
begin
  try
    SearchText := LowerCase( cbbSearchName.Text ); //查找edit1中输入的文本
    StartPos := mmoPreview.SelStart + mmoPreview.SelLength;
    FullText := LowerCase( mmoPreview.Text );
    FullText := Copy( FullText, StartPos + 1, length( FullText ) - StartPos );

    FindPos := Pos( SearchText, FullText ); //求出首次出现SearchText的位置
    if FindPos <= 0 then // 找不到，则从头开始
    begin
      StartPos := 0;
      FullText := LowerCase( mmoPreview.Text );
      FindPos := Pos( SearchText, FullText );
      if FindPos <= 0 then // 没有找到
      begin
        plSearchNotFind.Visible := True;
        Exit;
      end;
    end;

    mmoPreview.SelStart := StartPos + FindPos - 1;
    mmoPreview.SelLength := length( SearchText );
    mmoPreview.SetFocus;  //这一句很重要，否则就会看不到文字被选中

    plSearchNotFind.Visible := False;;

      // 添加到历史
    AddSearchHistory( SearchText );
  except
  end;
end;

procedure TfrmPreView.cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.ClearImg;
var
  i : Integer;
  ImagePageInfo : TImagePageInfo;
begin
  for i := 0 to ImagePageList.Count - 1 do
  begin
    ImagePageInfo := ImagePageList[i];
    ImagePageInfo.FilePath := '';
    ImagePageInfo.Image.Picture := nil;
  end;
  ImagePos := 0;
  ShowPath := '';
end;

procedure TfrmPreView.PreviewFile(FilePath, OwnerPcID: string);
var
  PreviewFileHandle : TPreviewFileHandle;
begin
  PreviewFileHandle := TPreviewFileHandle.Create( FilePath );
  PreviewFileHandle.SetOwnerID( OwnerPcID );
  PreviewFileHandle.Update;
  PreviewFileHandle.Free;

    // 检查是否企业版
  RegisterLimitApi.EnterpriseAction;
end;

procedure TfrmPreView.rePreviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PreviewForm_IsShow := False;
  frmRestoreExplorer.SetPreviewBtn( False );
  ClearImg;
  if frmRestoreExplorer.Showing then
    frmRestoreExplorer.Position := poMainFormCenter;
  if frmSelectRestore.Showing then
    frmSelectRestore.Position := poMainFormCenter;
end;

procedure TfrmPreView.FormCreate(Sender: TObject);
begin
  IniImageList;
  LvZip.SmallImages := MyIcon.getSysIcon;
  LoadIni;
end;

procedure TfrmPreView.FormDestroy(Sender: TObject);
begin
  ImagePageList.Free;
  SaveIni;
end;

procedure TfrmPreView.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmPreView.FormShow(Sender: TObject);
begin
  PreviewForm_IsShow := True;
  frmRestoreExplorer.SetPreviewBtn( True );
end;

procedure TfrmPreView.IniImageList;
var
  ImagePageInfo : TImagePageInfo;
begin
  ImagePageList := TImagePageList.Create;

  ImagePageInfo := TImagePageInfo.Create( tsImage1, img1 );
  ImagePageList.Add( ImagePageInfo );

  ImagePageInfo := TImagePageInfo.Create( tsImage2, img2 );
  ImagePageList.Add( ImagePageInfo );

  ImagePageInfo := TImagePageInfo.Create( tsImage3, img3 );
  ImagePageList.Add( ImagePageInfo );

  ImagePageInfo := TImagePageInfo.Create( tsImage4, img4 );
  ImagePageList.Add( ImagePageInfo );

  ImagePageInfo := TImagePageInfo.Create( tsImage5, img5 );
  ImagePageList.Add( ImagePageInfo );

  ImagePos := 0;
end;

procedure TfrmPreView.LoadIni;
var
  IniFile : TIniFile;
  i, ItemCount: Integer;
  s : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ItemCount := IniFile.ReadInteger( Self.Name, cbbSearchName.Name + 'Count', 0 );
  for i := 0 to ItemCount - 1 do
  begin
    s := IniFile.ReadString( Self.Name, cbbSearchName.Name + IntToStr(i), '' );
    cbbSearchName.Items.Add( s );
  end;
  IniFile.Free;
end;

procedure TfrmPreView.mmoPreviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, cbbSearchName.Name + 'Count', cbbSearchName.Items.Count );
    for i := 0 to cbbSearchName.Items.Count - 1 do
      IniFile.WriteString( Self.Name, cbbSearchName.Name + IntToStr(i), cbbSearchName.Items[i] );
  except
  end;
  IniFile.Free;
end;

procedure TfrmPreView.SetIniPosition( FormHandle : Integer );
var
  R:TRect;
begin
  try
    GetWindowRect( FormHandle, R );
    Height := frmRestoreExplorer.Height;
    Width := frmRestoreExplorer.Width;
    Original_Height := Height;
    Original_Width := Width;
    MoveWindow( Handle, r.Left - Width, r.Top, Width, Height, True );
  except
  end;
end;

procedure TfrmPreView.SetShowPath(_ShowPath: string);
begin
  ShowPath := _ShowPath;
  edtPreviewPath.Text := ShowPath;
  frmPreView.Caption := ExtractFileName( ShowPath ) + ' - Preview';

  try
    MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFileExt( ShowPath ), ImgPreview.Picture.Icon );
  except
  end;
end;

procedure TfrmPreView.tbtnMaxClick(Sender: TObject);
begin
  frmPreView.WindowState := wsMaximized;
end;

procedure TfrmPreView.tbtnDownloadClick(Sender: TObject);
var
  NowPath : string;
  Params : TShareDownAddParams;
  SavePath : string;
begin
  NowPath := frmPreView.ShowPath;
  if NowPath = '' then
    Exit;

  SavePath := frmRestoreExplorer.getSavePath;
  SavePath := MyFilePath.getPath( SavePath ) + ExtractFileName( NowPath );
  SavePath := MyFilePath.getNowExistPath( SavePath, True );

    // 立刻下载
  Params.SharePath := NowPath;
  Params.OwnerPcID := frmRestoreExplorer.OwnerID;
  Params.IsFile := True;
  Params.SavePath := SavePath;
  ShareDownUserApi.AddNetworkItem( Params );
end;

procedure TfrmPreView.tmrProgressTimer(Sender: TObject);
begin
  tmrProgress.Enabled := False;
  pbPreview.Style := pbstMarquee;
  pbPreview.Visible := True;
end;

procedure TfrmPreView.tbtnRunClick(Sender: TObject);
begin
  if miDownRun.Checked then
    MyExplore.OpenFile( SavePath )
  else
    MyExplore.OpenFolder( SavePath );
end;

{ TImagePage }

constructor TImagePageInfo.Create(_Page: TRzTabSheet; _Image : TImage);
begin
  Page := _Page;
  Image := _Image;
  FilePath := '';
end;

{ TPreviewFileHandle }

constructor TPreviewFileHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TPreviewFileHandle.PreviewExcel;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsExcel;
  frmPreView.LvExcel.Items.Clear;
  frmPreView.LvExcel.Columns.Clear;
  SharePreviewApi.PreviewExcel( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.PreviewExe;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsExe;
  with frmPreView do
    veExe.Strings.Clear;
  SharePreviewApi.PreviewExe( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.PreviewMusic;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsMusic;
  with frmPreView do
    veMusic.Strings.Clear;
  SharePreviewApi.PreviewMusic( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.PreviewPicture;
var
  Img : TImage;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsPirture;
  if ShareExplorerFormUtil.getIsExistPreviewPicture( FilePath ) then  // 已存在
    Exit
  else
    frmPreView.PcImage.ActivePage := frmPreView.tsEmptyImage;

    // 启动
  if ( frmPreView.ImagePos < 0 ) or ( frmPreView.ImagePos >= frmPreView.ImagePageList.Count ) then
    frmPreView.ImagePos := 0;
  Img := frmPreView.ImagePageList[ frmPreView.ImagePos ].Image;
  SharePreviewApi.PreviewPicture( FilePath, OwnerID, Img.Width, Img.Height )
end;

procedure TPreviewFileHandle.PreviewText;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsText;
  frmPreView.mmoPreview.Clear;
  SharePreviewApi.PreviewText( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.PreviewWord;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsDoc;
  frmPreView.reDoc.Clear;
  SharePreviewApi.PreviewWord( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

procedure TPreviewFileHandle.PreviewCompress;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsZip;
  frmPreView.LvZip.Items.Clear;
  SharePreviewApi.PreviewCompress( FilePath, OwnerID );
end;

procedure TPreviewFileHandle.Update;
begin
    // 设置正在预览的文件
  frmPreView.SetShowPath( FilePath );

    // 预览图片
  if MyPictureUtil.getIsPictureFile( FilePath ) then
    PreviewPicture
  else  // 预览 word
  if MyPreviewUtil.getIsDocFile( FilePath )  then
    PreviewWord
  else  // 预览 Excel
  if MyPreviewUtil.getIsExcelFile( FilePath ) then
    PreviewExcel
  else  // 预览 Zip
  if MyPreviewUtil.getIsCompressFile( FilePath ) then
    PreviewCompress
  else  // 预览 Exe
  if MyPreviewUtil.getIsExeFile( FilePath ) then
    PreviewExe
  else  // 预览 Music
  if MyPreviewUtil.getIsMusicFile( FilePath ) then
    PreviewMusic
  else   // 以文本方式预览
    PreviewText;
end;


end.
