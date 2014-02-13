unit UFormShareDownLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls,
  RzTabs, Vcl.ImgList;

type

    // 数据结构
  TVstBackupLogData = record
  public
    FilePath : WideString;
    BackupTime : TDateTime;
  public
    ShowName, ShowDir : WideString;
    MainIcon : Integer;
  end;
  PVstBackupLogData = ^TVstBackupLogData;

  TfrmShareDownLog = class(TForm)
    Panel1: TPanel;
    btnClear: TButton;
    btnClose: TButton;
    PcMain: TRzPageControl;
    tsCompleted: TRzTabSheet;
    vstBackupLog: TVirtualStringTree;
    tsInCompleted: TRzTabSheet;
    vstIncompleted: TVirtualStringTree;
    ilPcMain: TImageList;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure vstBackupLogGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBackupLogGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure btnClearClick(Sender: TObject);
    procedure vstIncompletedGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstIncompletedGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
  private
    SharePath, OwnerPcID : string;
    IncompletedCount : Integer;
  public
    procedure ClearItems;
    procedure SetItemInfo( _SharePath, _OwnerPcID : string );
    procedure AddCompleted( FilePath : string; BackupTime : TDateTime );
    procedure AddIncompleted( FilePath : string );
    procedure ShowLog;
  end;

const
  vstBackupLog_FileName = 0;
  vstBackupLog_FileDir = 1;
  vstBackupLog_BackupTime = 2;

var
  frmShareDownLog: TfrmShareDownLog;

implementation

uses UMyShareDownApiInfo, UIconUtil, UMyUtil;

{$R *.dfm}

procedure TfrmShareDownLog.AddCompleted(FilePath: string; BackupTime: TDateTime);
var
  LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  LogNode := vstBackupLog.AddChild( vstBackupLog.RootNode );
  NodeData := vstBackupLog.GetNodeData( LogNode );
  NodeData.FilePath := FilePath;
  NodeData.BackupTime := BackupTime;
  NodeData.ShowName := ExtractFileName( FilePath );
  NodeData.ShowDir := ExtractFileDir( FilePath );
  NodeData.MainIcon := MyIcon.getIconByFilePath( FilePath );
end;

procedure TfrmShareDownLog.AddIncompleted(FilePath: string);
var
  LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  LogNode := vstIncompleted.AddChild( vstIncompleted.RootNode );
  NodeData := vstIncompleted.GetNodeData( LogNode );
  NodeData.FilePath := FilePath;
  NodeData.ShowName := ExtractFileName( FilePath );
  NodeData.ShowDir := ExtractFileDir( FilePath );
  NodeData.MainIcon := MyIcon.getIconByFilePath( FilePath );

  Inc( IncompletedCount );
end;

procedure TfrmShareDownLog.btnClearClick(Sender: TObject);
begin
  ShareDownLogApi.ClearCompleted( SharePath, OwnerPcID );
  ShareDownLogApi.ClearIncompleted( SharePath, OwnerPcID );
end;

procedure TfrmShareDownLog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmShareDownLog.ClearItems;
begin
  vstBackupLog.Clear;
  vstIncompleted.Clear;
  IncompletedCount := 0;
end;

procedure TfrmShareDownLog.FormCreate(Sender: TObject);
begin
  vstBackupLog.NodeDataSize := SizeOf( TVstBackupLogData );
  vstBackupLog.Images := MyIcon.getSysIcon;

  vstIncompleted.NodeDataSize := SizeOf( TVstBackupLogData );
  vstIncompleted.Images := MyIcon.getSysIcon;
end;

procedure TfrmShareDownLog.SetItemInfo(_SharePath, _OwnerPcID: string);
begin
  SharePath := _SharePath;
  OwnerPcID := _OwnerPcID;
  Self.Caption := MyFileInfo.getFileName( OwnerPcID ) + ' Logs';
end;

procedure TfrmShareDownLog.ShowLog;
begin
  if IncompletedCount <= 0 then
  begin
    tsCompleted.TabVisible := False;
    tsInCompleted.TabVisible := False;
    PcMain.ShowCardFrame := False;
    PcMain.ActivePage := tsCompleted;
  end
  else
  begin
    tsCompleted.TabVisible := True;
    tsInCompleted.TabVisible := True;
    PcMain.ShowCardFrame := True;
    PcMain.ActivePage := tsInCompleted;
    tsInCompleted.Caption := 'Incompleted (' + IntToStr(IncompletedCount) + ')';
  end;
  Show;
end;

procedure TfrmShareDownLog.vstBackupLogGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupLogData;
begin
  ImageIndex := -1;
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    if Column = vstBackupLog_FileName then
    begin
      NodeData := Sender.GetNodeData( Node );
      ImageIndex := NodeData.MainIcon;
    end;
  end;
end;

procedure TfrmShareDownLog.vstBackupLogGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstBackupLogData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = vstBackupLog_FileName then
    CellText := NodeData.ShowName
  else
  if Column = vstBackupLog_FileDir then
    CellText := NodeData.ShowDir
  else
  if Column = vstBackupLog_BackupTime then
    CellText := FormatDateTime( 'mm-dd hh:nn', NodeData.BackupTime )
  else
    CellText := '';
end;

procedure TfrmShareDownLog.vstIncompletedGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupLogData;
begin
  ImageIndex := -1;
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    if Column = vstBackupLog_FileName then
    begin
      NodeData := Sender.GetNodeData( Node );
      ImageIndex := NodeData.MainIcon;
    end;
  end;
end;

procedure TfrmShareDownLog.vstIncompletedGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstBackupLogData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = vstBackupLog_FileName then
    CellText := NodeData.ShowName
  else
  if Column = vstBackupLog_FileDir then
    CellText := NodeData.ShowDir
  else
    CellText := '';
end;

end.
