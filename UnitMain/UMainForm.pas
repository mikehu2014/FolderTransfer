unit UMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls,
  ShellCtrls, xmldom, XMLIntf, auHTTP, auAutoUpgrader, XPMan, ImgList,
  Menus, msxmldom, XMLDoc, RzPanel, RzButton, RzStatus, VirtualTrees, IniFiles,
  FileCtrl,
  ActnList, XPStyleActnCtrls, ActnMan,
  AppEvnts, ActiveX, ShellAPI, TlHelp32,
  Spin, Buttons, ShlObj, UIconUtil, Math,
  DateUtils, CommCtrl, RzShellDialogs, uDebugLock, RzPrgres,
   RzTabs, Grids, ValEdit, ActnCtrls, UFileBaseInfo,
  VCLTee.Series, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, htmlhint,UMyUtil, zlib,
  Generics.Collections;

const
  hfck = wm_user + $1000;
  AppName_FolderTransfer = 'FolderTransfer';

type

  TfrmMainForm = class(TForm)
    ilStatusBar: TImageList;
    ilTbMf16: TImageList;
    ilTbCoolBar: TImageList;
    pmHelp: TPopupMenu;
    miRegister1: TMenuItem;
    miAbout1: TMenuItem;
    xpmnfst1: TXPManifest;
    Upgrade1: TMenuItem;
    plMainForm: TPanel;
    N1: TMenuItem;
    N2: TMenuItem;
    ContactUs1: TMenuItem;
    HomePage1: TMenuItem;
    ilBackupSetting: TImageList;
    ilTbMf: TImageList;
    ilTbFs16: TImageList;
    ilTbFs16Gray: TImageList;
    ilNw16: TImageList;
    pmTrayIcon: TPopupMenu;
    miShow1: TMenuItem;
    miOpenFolder4: TMenuItem;
    Exit1: TMenuItem;
    SbMainForm: TRzStatusBar;
    sbNetworkMode: TRzGlyphStatus;
    sbDownSpeed: TRzGlyphStatus;
    sbUpSpeed: TRzGlyphStatus;
    sbEdition: TRzGlyphStatus;
    sbMyStatus: TRzGlyphStatus;
    ilNw: TImageList;
    tbMainForm: TRzToolbar;
    tbtnFileSharePage: TRzToolButton;
    tbtnSettings: TRzToolButton;
    tbtnHelp: TRzToolButton;
    tbtnExit: TRzToolButton;
    ilShellFile: TImageList;
    OnlineManual1: TMenuItem;
    auApp: TauAutoUpgrader;
    iShellBackupStatus: TImageList;
    ilShellTransAction: TImageList;
    tiApp: TTrayIcon;
    ilTbNw: TImageList;
    ilTbNwGray: TImageList;
    ilTb24: TImageList;
    ilTb24Gray: TImageList;
    tbtnFileTransferPage: TRzToolButton;
    PcMain: TRzPageControl;
    tsFileTransfer: TRzTabSheet;
    tsFileShare: TRzTabSheet;
    XmlDoc: TXMLDocument;
    plRestore: TPanel;
    slRestoreDown: TSplitter;
    HTMLHint1: THTMLHint;
    PmNetwork: TPopupMenu;
    miLocalNetwork: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    JoinaGroup1: TMenuItem;
    ConnecttoaComputer1: TMenuItem;
    plFileSend: TPanel;
    plBackupTitle: TPanel;
    tbBackup: TToolBar;
    tbtnSendStop: TToolButton;
    tbtnSendSelected: TToolButton;
    tbtnSendAdd: TToolButton;
    tbtnSendRemove: TToolButton;
    tbtnSendExplorer: TToolButton;
    ToolButton1: TToolButton;
    tbtnBackupNetwork: TToolButton;
    plBackupFileNoPc: TPanel;
    Label17: TLabel;
    Label18: TLabel;
    ilPageControl: TImageList;
    tbtnSendShowLog: TToolButton;
    tbtnFileSendClear: TToolButton;
    pmShareHistory: TPopupMenu;
    N3: TMenuItem;
    Clear1: TMenuItem;
    ilFolder: TImageList;
    plNetworkNotConn: TPanel;
    PcNetworkConn: TRzPageControl;
    tsNoPc: TRzTabSheet;
    tsCannotConn: TRzTabSheet;
    Image5: TImage;
    VstFileSend: TVirtualStringTree;
    tbtnSendStart: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    plShareShow: TPanel;
    plRestoreDown: TPanel;
    vstShareDown: TVirtualStringTree;
    tbRestoreDown: TToolBar;
    tbtnShareDownStop: TToolButton;
    tbtnShareDownStart: TToolButton;
    tbtnShareDownExplorer: TToolButton;
    tbtnShareDownRun: TToolButton;
    tbtnShareDownRemove: TToolButton;
    tbtnShareDownAgain: TToolButton;
    tbtnShareDownClear: TToolButton;
    plMyDownloadTitle: TPanel;
    btnHideShareDown: TButton;
    plNoShareShow: TPanel;
    Label2: TLabel;
    Image2: TImage;
    plRestoreTitle: TPanel;
    tbRestore: TToolBar;
    tbtnShareShowDown: TToolButton;
    ToolButton4: TToolButton;
    tbtnShareShowCollapse: TToolButton;
    tbtnShareShowExpand: TToolButton;
    ToolButton2: TToolButton;
    tbtnShareShowSettings: TToolButton;
    vstShareShow: TVirtualStringTree;
    tmrCheckNotShare: TTimer;
    ToolButton8: TToolButton;
    tbtnSendSpeed: TToolButton;
    tbtnShareDownSpeed: TToolButton;
    ToolButton11: TToolButton;
    PcRemoteWarinning: TRzPageControl;
    tsGroupNotEixst: TRzTabSheet;
    Image1: TImage;
    lbGroupNotExist: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    Button1: TButton;
    btnSignupGroup: TButton;
    tsGroupPasswordError: TRzTabSheet;
    Image3: TImage;
    lbGroupPassword: TLabel;
    Label4: TLabel;
    btnInputAgain: TButton;
    tsIpError: TRzTabSheet;
    Image4: TImage;
    lbIpError: TLabel;
    Label5: TLabel;
    lbIpErrorTime: TLabel;
    Button2: TButton;
    btnInputDomain: TButton;
    tsNotConnPc: TRzTabSheet;
    Image6: TImage;
    lbNotConnPcTitle: TLabel;
    lbRemotePcNotConn: TLabel;
    lbNetworkConn: TLabel;
    Label6: TLabel;
    btnConnNow: TButton;
    Button3: TButton;
    tsSecurityIDError: TRzTabSheet;
    Image7: TImage;
    lbConnPcSecurityID: TLabel;
    Label7: TLabel;
    Button4: TButton;
    N5: TMenuItem;
    BackupSyncTool1: TMenuItem;
    tmrRefreshHint: TTimer;
    BuyNow1: TMenuItem;
    tbtnSendPcFilter: TToolButton;
    PmSendPc: TPopupMenu;
    OnlinePc1: TMenuItem;
    AllComputers1: TMenuItem;
    GroupComputers1: TMenuItem;
    tbtnShareRemove: TToolButton;
    tsNoEdition: TRzTabSheet;
    tbtnShareDownLog: TToolButton;
    pcEditionNotMatch: TRzPageControl;
    tsNewEdition: TRzTabSheet;
    plNewEditionShow: TPanel;
    Image8: TImage;
    tsOldEdition: TRzTabSheet;
    Image9: TImage;
    Label14: TLabel;
    Label15: TLabel;
    btnCheck4Upgrade: TButton;
    btnNotPcClose: TButton;
    tbtnFileReceive: TRzToolButton;
    tsFileReceived: TRzTabSheet;
    plFileReceive: TPanel;
    vstFileReceive: TVirtualStringTree;
    Panel1: TPanel;
    tbFileReceive: TToolBar;
    tbtnReceiveAdd: TToolButton;
    tbtnReceiveRemove: TToolButton;
    tbtnReceiveClear: TToolButton;
    ToolButton3: TToolButton;
    tbtnReceiveExplorer: TToolButton;
    tbtnReceiveOpen: TToolButton;
    tsKeepOld: TRzTabSheet;
    plSuggestions: TPanel;
    Panel4: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    mmoSuggestion: TMemo;
    plEmail: TPanel;
    Label10: TLabel;
    edtEmail: TEdit;
    btnSumbit: TButton;
    ToolButton9: TToolButton;
    LinkLabel1: TLinkLabel;
    tbtnSplitDownAgain: TToolButton;
    N9: TMenuItem;
    NetworkStatus1: TMenuItem;
    SignUpaGroupRecommendedforRemoteNetwork1: TMenuItem;
    pmShare: TPopupMenu;
    ToolButton7: TToolButton;
    Label11: TLabel;
    Button5: TButton;
    tbtnSplitJob: TToolButton;
    tbtnJobSetting: TToolButton;
    procedure tbtnMainFormClick(Sender: TObject);
    procedure tbtnExitClick(Sender: TObject);
    procedure LvNetworkDeletion(Sender: TObject; Item: TListItem);
    procedure lvSearchFileDeletion(Sender: TObject; Item: TListItem);
    procedure lvCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure lvFileStatusDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnSettingsClick(Sender: TObject);
    procedure Upgrade1Click(Sender: TObject);
    procedure ContactUs1Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure miAbout1Click(Sender: TObject);
    procedure OnlineManual1Click(Sender: TObject);
    procedure miRegister1Click(Sender: TObject);
    procedure lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure miShow1Click(Sender: TObject);
    procedure lvSearchDownloadDeletion(Sender: TObject; Item: TListItem);
    procedure btnConnNowClick(Sender: TObject);
    procedure tiAppClick(Sender: TObject);
    procedure lvMyDestinationDeletion(Sender: TObject; Item: TListItem);
    procedure lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure lvMyFileReceiveDeletion(Sender: TObject; Item: TListItem);
    procedure lvLocalBackupSourceDeletion(Sender: TObject; Item: TListItem);
    procedure Enteragroup1Click(Sender: TObject);
    procedure Connectacomputer1Click(Sender: TObject);
    procedure BackupCow1Click(Sender: TObject);
    procedure VstFileSendGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstFileSendGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstFileSendDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VstFileSendChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnSendRemoveClick(Sender: TObject);
    procedure tbtnSendSelectedClick(Sender: TObject);
    procedure VstFileSendPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure tbtnSendExplorerClick(Sender: TObject);
    procedure vstShareShowGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstShareShowGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstShareShowChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnShareShowExplorerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbtnSendAddClick(Sender: TObject);
    procedure tbtnShareShowDownClick(Sender: TObject);
    procedure vstShareDownGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstShareDownGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstShareDownMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vstShareDownChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnShareDownExplorerClick(Sender: TObject);
    procedure tbtnShareDownRemoveClick(Sender: TObject);
    procedure tbtnShareDownAgainClick(Sender: TObject);
    procedure tbtnSendStopClick(Sender: TObject);
    procedure VstFileSendMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbtnShareShowSettingsClick(Sender: TObject);
    procedure tbtnBackupShowLogClick(Sender: TObject);
    procedure tbtnShareDownStopClick(Sender: TObject);
    procedure tbtnBackupNetworkClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure JoinaGroup1Click(Sender: TObject);
    procedure ConnecttoaComputer1Click(Sender: TObject);
    procedure miLocalNetworkClick(Sender: TObject);
    procedure tbtnReceiveAddClick(Sender: TObject);
    procedure tbtnReceiveRemoveClick(Sender: TObject);
    procedure vstFileReceiveGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstFileReceiveGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tbtnReceiveExplorerClick(Sender: TObject);
    procedure vstFileReceiveChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnSendShowLogClick(Sender: TObject);
    procedure tbtnSettingsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vstShareShowKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstShareShowDblClick(Sender: TObject);
    procedure tbtnFileSendClearClick(Sender: TObject);
    procedure vstFileReceivePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure VstFileSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VstFileSendDblClick(Sender: TObject);
    procedure vstFileReceiveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vstFileReceiveKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstFileReceiveDblClick(Sender: TObject);
    procedure tbtnReceiveClearClick(Sender: TObject);
    procedure vstShareDownDblClick(Sender: TObject);
    procedure vstShareDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbtnShareDownClearClick(Sender: TObject);
    procedure NetworkStatus2Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure tbtnReceiveOpenClick(Sender: TObject);
    procedure tbtnShareDownRunClick(Sender: TObject);
    procedure PcFileTransferPageChange(Sender: TObject);
    procedure tbtnShareShowCollapseClick(Sender: TObject);
    procedure tbtnShareShowExpandClick(Sender: TObject);
    procedure tbtnSendStartClick(Sender: TObject);
    procedure tbtnShareDownStartClick(Sender: TObject);
    procedure btnHideShareDownClick(Sender: TObject);
    procedure tmrCheckNotShareTimer(Sender: TObject);
    procedure vstShareShowPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure tbtnSendSpeedClick(Sender: TObject);
    procedure tbtnShareDownSpeedClick(Sender: TObject);
    procedure btnSignupGroupClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnInputAgainClick(Sender: TObject);
    procedure btnInputDomainClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure sbMyStatusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BackupSyncTool1Click(Sender: TObject);
    procedure tmrRefreshHintTimer(Sender: TObject);
    procedure BuyNow1Click(Sender: TObject);
    procedure tbtnSendPcFilterClick(Sender: TObject);
    procedure SendPcFilterClick(Sender: TObject);
    procedure GroupComputers1Click(Sender: TObject);
    procedure vstShareShowFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnShareRemoveClick(Sender: TObject);
    procedure btnEditionDetailsClick(Sender: TObject);
    procedure tbtnShareDownLogClick(Sender: TObject);
    procedure btnJoinAGroupClick(Sender: TObject);
    procedure tbtnHelpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCheck4UpgradeClick(Sender: TObject);
    procedure btnNotPcCloseClick(Sender: TObject);
    procedure btnSumbitClick(Sender: TObject);
    procedure mmoSuggestionKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure NetworkStatus1Click(Sender: TObject);
    procedure SignUpaGroupRecommendedforRemoteNetwork1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NewRestoreMenuItemClick(Sender: TObject);
    procedure tbtnJobSettingClick(Sender: TObject);
    procedure vstFileReceiveFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure createparams(var params: tcreateparams); override;
    procedure restorerequest(var Msg: TMessage); message hfck;
    procedure ShareExplorerHistoryClick(Sender: TObject);
    function getIsShowHint : Boolean;
  private
    procedure MainFormIni;
    procedure LoadMainFormIni;
    procedure BindDrogHint;
    procedure BindToolbar;
    procedure BindSort;
    procedure BindSysItemIcon;
    procedure BindVstData;
    procedure SaveMainFormIni;
  private // 托盘
    IsHideForm : Boolean;
    procedure ShowMainForm;
    procedure HideMainForm;
  public
    procedure CreateFolderTransfer;
    procedure AppUpgrade;
    procedure PmLocalNetworkSelect;
    procedure PmRemoteNetworkSelect(SelectStr: string);
  end;

{$Region ' Pc 过滤 ' }

  PcFilterUtil = class
  public
    class procedure SetSendPcFilter( SelectIndex : Integer );
    class function getSendPcFilter : Integer;
    class function getSendPcIsShow( Node : PVirtualNode ): Boolean;
    class procedure RefreshShowNode;
  end;

      // 临时信息保存
  TRestoreTempInfo = class
  public
    TagIndex : Integer;
    FileNode : PVirtualNode;
    IsFile, IsSaveDeleted : Boolean;
  public
    constructor Create( _TagIndex : Integer );
    procedure SetFileNode( _FileNode : PVirtualNode );
    procedure SetRestoreInfo( _IsFile, _IsSaveDeleted : Boolean );
  end;
  TRestoreTempList = class( TObjectList<TRestoreTempInfo> )end;


  MainFormUtil = class
  public
    class procedure RefreshShareDownBtn;
  public
    class function ShareDownFileHandle( FileNode : PVirtualNode ): Boolean;
    class function ShareDownFolderHandle( FileNode : PVirtualNode ): Boolean;
  end;

{$EndRegion}

{$Region ' 发送文件操作 ' }

    // 选择备份路径
  TSelectBackupItemHandle = class
  private
    DesItemList : TStringList;
    SourceItemList : TStringList;
  public
    constructor Create( _DesItemList : TStringList );
    procedure SetSourceItemList( _SourceItemList : TStringList );
    procedure Update;
  private
    procedure AddNewSelectedItem;
  end;

{$EndRegion}

{$Region ' 共享文件操作 ' }

  TShareExplorerSelectHandle = class
  public
    SharePath, OwnerID : string;
    IsFile, IsLocal : Boolean;
  public
    constructor Create( _SharePath, _OwnerID : string );
    procedure SetItemInfo( _IsFile, _IsLocal : Boolean );
    function Update: Boolean;
  end;

  TShareDownSelectHandle = class
  private
    vstShareShow : TVirtualStringTree;
  public
    procedure Update;
  private
    procedure ShareDownDefaultNode;
    procedure HandleSelect;
    procedure HandleFocuse;
  private
    function FileHandle( Node : PVirtualNode ): Boolean;
    function FolderHandle( Node : PVirtualNode ): Boolean;
  end;

{$EndRegion}

{$Region ' 拖动文件 ' }

    // 拖动 备份文件处理
  TAddDropSendFile = class
  private
    FilePathList: TStringList;
  private
    SendRootItemID : string;
    IsLocalDes : Boolean;
  public
    constructor Create( _FilePathList: TStringList );
    procedure Update;
  private
    procedure FindDropDesItem;
    procedure AddFileSendNow;
  private
    function ReadDefaultDes : string;
  end;

  // 拖动文件处理
  TFrmMainDropFileHandle = class( TDropFileHandle )
  public
    procedure Update;
  private
    procedure AddFileSend;
    procedure AddFileReceive;
    procedure AddFileShare;
  end;

{$EndRegion}

{$Region ' 停止程序 ' }

  TStopAppThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

{$EndRegion}

const // 拖动文件
  DropFile_Hint = 'Drag and drop files or folders here from Windows Explorer';
  DropFolder_Hint = 'Drag and drop folders here from Windows Explorer';
  DropFileSend_Hint = 'Drag and drop files here to start file transfer';

var // 拖动文件
  DragFile_LastX : Integer = 0;
  DragFile_LastY : Integer = 0;

const
  MainPage_FileTransfer = 0;
  MainPage_FileShare = 1;
  MainPage_FileReceive = 2;

  FileTransferPage_FileSend = 0;
  FileTransferPage_FileReceive = 1;

const
  VstFileSend_SendName = 0;
  VstFileSend_FileCount = 1;
  VstFileSend_FileSize = 2;
  VstFileSend_LastSend = 3;
  VstFileSend_NextSend = 4;
  VstFileSend_Percentage = 5;
  VstFileSend_Status = 6;


  VstFileReceive_ReceiveName = 0;
  VstFileReceive_ReceiveFrom = 1;
  VstFileReceive_FileCount = 2;
  VstFileReceive_FileSize = 3;
  VstFileReceive_Percentage = 4;
  VstFileReceive_ReceiveTime = 5;
  VstFileReceive_Status = 6;

  VstShareShow_ShareName = 0;

  VstRestoreDown_RestorePath = 0;
  VstRestoreDown_Owner = 1;
  VstRestoreDown_FileCount = 2;
  VstRestoreDown_FileSize = 3;
  VstRestoreDown_Percentage = 4;
  VstRestoreDown_Status = 5;

const
  ImgIndex_PcFilterSelect = 3;

const
  SendPcFilter_Online = 'Online';
  SendPcFilter_Group = 'Group';
  SendPcFilter_All = 'All';

const

  // NetworkMode Show Icon
  NetworkModeIcon_LAN = 1;
  NetworkModeIcon_Remote = 8;

const
  Time_ShowHint: Integer = 30000;

    // Network
  ShowForm_RestartNetwork = 'Are you sure to restart network?';

    // Remove
  ShowForm_RemoveSelected: string = 'Are you sure to remove?';
  ShowForm_Clear = 'Are you sure to clear all success records?';


const
  Icon_ReceiveNormal = 16;
  Icon_ReceiveNew = 17;
  Icon_ShareNormal = 13;
  Icon_ShareNew = 18;

var // 应用程序
  App_IsExit: Boolean = True;
  Filter_SendPc : string = SendPcFilter_Online;
  RestoreTempList : TRestoreTempList;

var
  frmMainForm: TfrmMainForm;

implementation

uses
  UFormUtil, UXmlUtil, UFolderTransfer,
  UMySendFaceInfo, UMySendApiInfo, UFrmSelectSendItem, UMySendDataInfo, USendThread,
  UMyShareDownFaceInfo, UMyReceiveDataInfo, UMyReceiveApiInfo,
  UFormSelectShareDown, UMyShareDownApiInfo, UFormShareDownExplorer, UShareDownThread,
  UMyReceiveFaceInfo, UMyShareFaceInfo, UMyShareApiInfo, UMyShareDownDataInfo,
  UNetworkFace, UNetworkControl,
  UMyNetPcInfo, UFormSetting, UMyUrl, UFormLocalSelect,
  UFormAbout, UFormRegister,
  UAppEditionInfo, URegisterInfoIO,
  USettingInfo, UFormFreeEdition,
  UFromEnterGroup, UFormConnPc,
  UFormExitWarnning, UMyRegisterApiInfo, UFormShare,
  UFormbroadcast, UFormFileSelect, UFormSendLog, UNetworkStatus,
  UFormBackupSpeedLimit, UFormRestoreSpeedLimit, UdebugForm, UFormPreview, UFormFreeTips,UFormSendPcFilter,
  UFormEditionNotMatch, UFormShareDownLog, UMyShareDataInfo, UJobSettings, UMyTimerThread;

{$R *.dfm}

procedure TfrmMainForm.AppUpgrade;
begin
  try
    auApp.InfoFileURL := MyUrl.getAppUpgrade;
    auApp.CheckUpdate;
  except
  end;
end;

procedure TfrmMainForm.BindDrogHint;
begin

end;

procedure TfrmMainForm.BindSort;
begin

end;

procedure TfrmMainForm.BindSysItemIcon;
begin
  VstFileSend.Images := MyIcon.getSysIcon;
  vstFileReceive.Images := MyIcon.getSysIcon;
  vstShareShow.Images := MyIcon.getSysIcon;
  vstShareDown.Images := MyIcon.getSysIcon;
end;

procedure TfrmMainForm.BindToolbar;
begin
  VstFileSend.PopupMenu := FormUtil.getPopMenu( tbBackup );
  vstFileReceive.PopupMenu := FormUtil.getPopMenu( tbFileReceive );
  vstShareShow.PopupMenu := FormUtil.getPopMenu( tbRestore );
  vstShareDown.PopupMenu := FormUtil.getPopMenu( tbRestoreDown );
end;

procedure TfrmMainForm.BindVstData;
begin
  VstFileSend.NodeDataSize := SizeOf(TFileSendData);
  vstShareShow.NodeDataSize := SizeOf(TShareShowData);
  vstShareDown.NodeDataSize := SizeOf(TVstShareDownData);
  vstFileReceive.NodeDataSize := SizeOf(TReceiveItemData);
end;

procedure TfrmMainForm.miAbout1Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMainForm.miRegister1Click(Sender: TObject);
begin
  frmRegister.Show;
end;

procedure TfrmMainForm.miShow1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  ShowMainForm;
end;

procedure TfrmMainForm.mmoSuggestionKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  IsEmail, IsSuggestion : Boolean;
begin
  IsEmail := Trim( edtEmail.Text ) <> '';
  IsSuggestion := Trim( mmoSuggestion.Text ) <> '';
  btnSumbit.Enabled := IsEmail and IsSuggestion;
end;

procedure TfrmMainForm.NetworkStatus1Click(Sender: TObject);
begin
  frmNeworkStatus.ShowNetworkStatus;
end;

procedure TfrmMainForm.NetworkStatus2Click(Sender: TObject);
begin
  frmNeworkStatus.ShowNetworkStatus;
end;

procedure TfrmMainForm.NewRestoreMenuItemClick(Sender: TObject);
var
  TagIndex : Integer;
  i: Integer;
begin
  TagIndex := ( Sender as TMenuItem ).Tag;
  for i := 0 to RestoreTempList.Count - 1 do
    if RestoreTempList[i].TagIndex = TagIndex then
    begin
      if RestoreTempList[i].IsFile and not RestoreTempList[i].IsSaveDeleted then
        MainFormUtil.ShareDownFileHandle( RestoreTempList[i].FileNode )
      else
        MainFormUtil.ShareDownFolderHandle( RestoreTempList[i].FileNode );
      Break;
    end;
end;

procedure TfrmMainForm.OnlineManual1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.OnlineManual);
end;

procedure TfrmMainForm.PcFileTransferPageChange(Sender: TObject);
begin
//  TransferPage_IsShowReceive := PcFileTransfer.ActivePage = tsFileReceive;
//  if TransferPage_IsShowReceive and Assigned( FolderTransfer ) then  // 清空
//    ReceiveRootItemUserApi.ClearNewCount;
end;

procedure TfrmMainForm.PmLocalNetworkSelect;
begin
  sbNetworkMode.Caption := 'Local Network';
  sbNetworkMode.ImageIndex := NetworkModeIcon_LAN;
end;

procedure TfrmMainForm.PmRemoteNetworkSelect(SelectStr: string);
begin
  sbNetworkMode.Caption := '';
  sbNetworkMode.ImageIndex := NetworkModeIcon_Remote;
end;

procedure TfrmMainForm.btnCheck4UpgradeClick(Sender: TObject);
begin
  auApp.ShowMessages := auApp.ShowMessages + [mNoUpdateAvailable];
  auApp.CheckUpdate;

  NetworkErrorStatusApi.HideError;
end;

procedure TfrmMainForm.btnConnNowClick(Sender: TObject);
begin
  NetworkPcApi.RestartNetwork;
end;

procedure TfrmMainForm.btnEditionDetailsClick(Sender: TObject);
begin
  frmEditonNotMatch.Show;
end;

var
  Height_MyDownload : Integer = 0;
procedure TfrmMainForm.btnHideShareDownClick(Sender: TObject);
var
  IsHide : Boolean;
begin
  IsHide := btnHideShareDown.Tag = 0;
  slRestoreDown.Visible := not IsHide;
  if IsHide then
  begin
    btnHideShareDown.Caption := 'Show >>';
    Height_MyDownload := plRestoreDown.Height;
    plRestoreDown.Height := plMyDownloadTitle.Height;
    btnHideShareDown.Tag := 1;
  end
  else
  begin
    btnHideShareDown.Caption := '<< Hide';
    plRestoreDown.Height := Height_MyDownload;
    btnHideShareDown.Tag := 0;
  end;
end;

procedure TfrmMainForm.btnInputAgainClick(Sender: TObject);
begin
  frmJoinGroup.ShowResetPassword( GroupError_Name );
end;

procedure TfrmMainForm.btnInputDomainClick(Sender: TObject);
begin
  frmConnComputer.ShowDnsError( ConnPcError_Domain, ConnPcError_Port );
end;

procedure TfrmMainForm.btnJoinAGroupClick(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.btnNotPcCloseClick(Sender: TObject);
begin
  NetworkErrorStatusApi.HideError;
end;

procedure TfrmMainForm.btnSignupGroupClick(Sender: TObject);
begin
  frmJoinGroup.ShowSignUpGroup( GroupError_Name );
end;

procedure TfrmMainForm.btnSumbitClick(Sender: TObject);
begin
    // 输入邮箱格式不正确
  if not MyEmail.IsVaildEmailAddr( edtEmail.Text ) then
  begin
    MyMessageBox.ShowWarnning( 'Email address is invalid' );
    Exit;
  end;

    // 超长
  if Length( edtEmail.Text ) > 190 then
    edtEmail.Text := Copy( edtEmail.Text, 1, 190 );

    // 超长
  if Length( mmoSuggestion.Text ) > 490 then
    mmoSuggestion.Text := Copy( mmoSuggestion.Text, 1, 490 );

    // 提交
  FolderTransferSuggestion.Sumbit( mmoSuggestion.Text, edtEmail.Text );

    // 提交结束
  MyMessageBox.ShowOk( 'Thank you' );
  mmoSuggestion.Clear;
  btnSumbit.Enabled := False;
end;

procedure TfrmMainForm.Button1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.Button3Click(Sender: TObject);
begin
  frmConnComputer.ShowDnsError( ConnPcError_Domain, ConnPcError_Port );
end;

procedure TfrmMainForm.Button4Click(Sender: TObject);
begin
  frmSetting.ShowResetCloudID;
end;

procedure TfrmMainForm.BuyNow1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmMainForm.Clear1Click(Sender: TObject);
begin
  ShareExplorerHistoryApi.ClearItem;
end;

procedure TfrmMainForm.Connectacomputer1Click(Sender: TObject);
begin
  frmConnComputer.ShowConnToPc;
end;

procedure TfrmMainForm.ConnecttoaComputer1Click(Sender: TObject);
begin
  frmConnComputer.ShowConnToPc;
end;

procedure TfrmMainForm.ContactUs1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.ContactUs);
end;

procedure TfrmMainForm.CreateFolderTransfer;
begin
  try
    FolderTransfer := TFolderTransfer.Create;
  except
  end;
end;

procedure TfrmMainForm.createparams(var params: tcreateparams);
begin
  try
    inherited createparams(params);
    params.WinClassName := AppName_FolderTransfer;
  except
  end;
end;

procedure TfrmMainForm.DropFiles(var Msg: TMessage);
var
  DropFileHandle: TFrmMainDropFileHandle;
begin
  try
    DropFileHandle := TFrmMainDropFileHandle.Create(Msg);
    DropFileHandle.Update;
    DropFileHandle.Free;

    FormUtil.ForceForegroundWindow( Handle );
  except
  end;
end;

procedure TfrmMainForm.Enteragroup1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.Exit1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  tbtnExit.Click;
end;

procedure TfrmMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not App_IsExit then
  begin
    CanClose := False;
    HideMainForm;
  end;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  RestoreTempList := TRestoreTempList.Create;

  try
    MainFormIni;
  except
  end;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  RestoreTempList.Free;
end;

function TfrmMainForm.getIsShowHint: Boolean;
begin
  Result := ( Self.WindowState = wsMinimized ) or( Self.IsHideForm ) and not App_IsExit;
end;

procedure TfrmMainForm.GroupComputers1Click(Sender: TObject);
begin
  if not frmSendPcFilter.getIsSelectPc then
    Exit;

    // 执行点击事件
  SendPcFilterClick( Sender );
end;

procedure TfrmMainForm.HideMainForm;
begin
  ShowWindow(Self.Handle, SW_HIDE);
  IsHideForm := True;
end;

procedure TfrmMainForm.HomePage1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.getHome);
end;

procedure TfrmMainForm.JoinaGroup1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.BackupCow1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( Url_FolderTranferHome );
end;

procedure TfrmMainForm.BackupSyncTool1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( 'http://www.BackupCow.com/' );
end;

procedure TfrmMainForm.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  frmEditonNotMatch.Show;
end;

procedure TfrmMainForm.LoadMainFormIni;
var
  MainPage, FileTransferPage: Integer;
  SendPcFilter : Integer;
  iniFile: TIniFile;
begin
  try
    iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
    MainPage := iniFile.ReadInteger(frmMainForm.Name, PcMain.Name, MainPage_FileTransfer );
//    FileTransferPage := iniFile.ReadInteger(frmMainForm.Name, PcFileTransfer.Name, FileTransferPage_FileSend );
    SendPcFilter := iniFile.ReadInteger(frmMainForm.Name, PmSendPc.Name, 0 );
    iniFile.Free;

      // 越界
    if ( MainPage < MainPage_FileTransfer ) or
       ( MainPage > MainPage_FileReceive )
    then
      MainPage := MainPage_FileTransfer;

      // 越界
    if ( FileTransferPage < FileTransferPage_FileSend ) or
       ( FileTransferPage > FileTransferPage_FileReceive )
    then
      FileTransferPage := FileTransferPage_FileSend;

      // 设置主页面和接收页面
    if MainPage = MainPage_FileTransfer then
      tbtnFileTransferPage.Down := True
    else
    if MainPage = MainPage_FileShare then
      tbtnFileSharePage.Down := True
    else
    if MainPage = MainPage_FileReceive then
      tbtnFileReceive.Down := True;
    PcMain.ActivePageIndex := MainPage;
//    PcFileTransfer.ActivePageIndex := FileTransferPage;

      // 是否处于接收页面
    TransferPage_IsShowReceive := FileTransferPage = FileTransferPage_FileReceive;

      // 发送文件Pc过滤
    PcFilterUtil.SetSendPcFilter( SendPcFilter );
  except
  end;
end;

procedure TfrmMainForm.miLocalNetworkClick(Sender: TObject);
begin
  if miLocalNetwork.ImageIndex = -1 then
    NetworkModeApi.EnterLan
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

procedure TfrmMainForm.lvCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvFileStatusDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvLocalBackupSourceDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyDestinationDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyFileReceiveDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.LvNetworkDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchDownloadDeletion(Sender: TObject;
  Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchFileDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.MainFormIni;
begin
  IsHideForm := not Application.ShowMainForm;
  App_IsExit := False;
  DragAcceptFiles(Handle, True); // 设置需要处理文件 WM_DROPFILES 拖放消息
  Application.HintHidePause := Time_ShowHint;
  MainFormHandle := Self.Handle;

  MyIcon := TMyIcon.Create; // 创建系统图标
  MyIcon.SaveMyIcon;

  LoadMainFormIni;
  BindSysItemIcon; // 系统图标
  BindToolbar; // ToolBar 绑定 控件右键 PopMenu
  BindSort; // 排序
  BindDrogHint; // 拖动文件排序
  BindVstData; // Vst NodeData Size 绑定
end;

procedure TfrmMainForm.restorerequest(var Msg: TMessage);
begin
  if not App_IsExit then
    ShowMainForm;
end;

procedure TfrmMainForm.SaveMainFormIni;
var
  iniFile: TIniFile;
begin
    // 无法写入 Ini
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  try
    iniFile.WriteInteger(Self.Name, PcMain.Name, PcMain.ActivePageIndex);
//    iniFile.WriteInteger(Self.Name, PcFileTransfer.Name, PcFileTransfer.ActivePageIndex);
    iniFile.WriteInteger(Self.Name, PmSendPc.Name, PcFilterUtil.getSendPcFilter);
  except
  end;
  iniFile.Free;
end;

procedure TfrmMainForm.sbMyStatusMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ( ssCtrl in Shift ) and ( Button = mbRight ) then
    frmDebug.Show;
end;

procedure TfrmMainForm.SendPcFilterClick(Sender: TObject);
var
  mi : TMenuItem;
  i, SendPcSelect: Integer;
begin
  mi := Sender as TMenuItem;
  SendPcSelect := -1;
  for i := 0 to PmSendPc.Items.Count - 1 do
    if PmSendPc.Items[i] = mi then
    begin
      SendPcSelect := i;
      Break;
    end;
  PcFilterUtil.SetSendPcFilter( SendPcSelect );
end;

procedure TfrmMainForm.Settings1Click(Sender: TObject);
begin
  frmSetting.PcMain.ActivePage := frmSetting.tsNetwork;
  frmSetting.Show;
end;

procedure TfrmMainForm.ShareExplorerHistoryClick(Sender: TObject);
var
  mi : TMenuItem;
  i, HistoryIndex: Integer;
  ShareExplorerHistoryInfo : TShareExplorerHistoryInfo;
  ShareExplorerSelectHandle : TShareExplorerSelectHandle;
begin
  mi := Sender as TMenuItem;

  HistoryIndex := -1;
  for i := 0 to pmShareHistory.Items.Count - 1 do
    if pmShareHistory.Items[i] = mi then
    begin
      HistoryIndex := i;
      Break;
    end;

  if HistoryIndex < 0 then
    Exit;

  ShareExplorerHistoryInfo := ShareExplorerHistoryInfoReadUtil.ReadHistoryInfo( HistoryIndex );

  ShareExplorerSelectHandle := TShareExplorerSelectHandle.Create( ShareExplorerHistoryInfo.FilePath, ShareExplorerHistoryInfo.OwnerID );
  ShareExplorerSelectHandle.SetItemInfo( False, False );
  ShareExplorerSelectHandle.Update;
  ShareExplorerSelectHandle.Free;

  ShareExplorerHistoryInfo.Free;
end;

procedure TfrmMainForm.ShowMainForm;
begin
  if not Self.Visible then
    Self.Visible := True;
  ShowWindow(Self.Handle, SW_RESTORE);
  SetForegroundWindow(Self.Handle);
  IsHideForm := False;
end;


procedure TfrmMainForm.SignUpaGroupRecommendedforRemoteNetwork1Click(
  Sender: TObject);
begin
  frmJoinGroup.ShowSignUpGroup('');
end;

procedure TfrmMainForm.tbtnSendSelectedClick(Sender: TObject);
var
  SelectNode, ChildNode : PVirtualNode;
  NodeData, ParentData : PVstSendData;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnSendSelected.Enabled := False;

  SelectNode := VstFileSend.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstFileSend.GetNodeData( SelectNode );

      // 本地备份 源路径
    if ( NodeData.NodeType = SendNodeType_LocalItem ) and
         not VstFileSend.Selected[ SelectNode.Parent ]
    then
    begin
      ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
      SendItemUserApi.SendSelectLocalItem( ParentData.ItemID, NodeData.ItemID );
    end
    else  // 网络备份 源路径
    if ( NodeData.NodeType = SendNodeType_NetworkItem ) and
         not VstFileSend.Selected[ SelectNode.Parent ]
    then
    begin
      ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
      SendItemUserApi.WaitingSendSelectNetworkItem( ParentData.ItemID, NodeData.ItemID );
    end
    else  // 目标路径
    if NodeData.NodeType = SendNodeType_LocalRoot then
      SendRootItemUserApi.BackupSelectLocalItem( NodeData.ItemID )
    else
    if NOdeData.NodeType = SendNodeType_NetworkRoot then
      SendRootItemUserApi.BackupSelectNetworkItem( NodeData.ItemID );
    SelectNode := VstFileSend.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnBackupShowLogClick(Sender: TObject);
begin
  frmSendLog.Show;
end;

procedure TfrmMainForm.tbtnShareShowCollapseClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstShareShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstShareShow.Expanded[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnSendStopClick(Sender: TObject);
begin
  tbtnSendStop.Enabled := False;
  MyFileSendHandler.IsSendRun := False;

    // 检查是否专业版
  RegisterLimitApi.ProfessionalAction;
end;

procedure TfrmMainForm.tbtnExitClick(Sender: TObject);
var
  StopAppThread : TStopAppThread;
begin
  if App_IsExit then
    Exit;

  try     // 显示退出提示
    if ApplicationSettingInfo.IsShowDialogBeforeExist then
    begin
      if frmExitConfirm.ShowModal <> mrYes then
        Exit;
    end;
  except
  end;

  App_IsExit := True;
  HideMainForm;

    // 定时强行结束程序
  try
    StopAppThread := TStopAppThread.Create;
    StopAppThread.Resume;
    try
      MyXmlUtil.LastSaveXml; // 立刻保存 Xml
      SaveMainFormIni;  // 保存界面信息
      FolderTransfer.Free;  // 释放主线程资源
      MyIcon.Free;  // 释放图标资源
    except
    end;
    StopAppThread.Free;
  except
  end;

  try
    Close;
  except
  end;
end;

procedure TfrmMainForm.tbtnShareShowExpandClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstShareShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstShareShow.Expanded[ SelectNode ] := True;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnFileSendClearClick(Sender: TObject);
var
  SelectRootNode, SelectChildNode : PVirtualNode;
  RootData, ChildData : PVstSendData;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if not MyMessageBox.ShowClearComfirm then
    Exit;
  SelectRootNode := VstFileSend.RootNode.FirstChild;
  while Assigned( SelectRootNode ) do
  begin
    RootData := VstFileSend.GetNodeData( SelectRootNode );
    SelectChildNode := SelectRootNode.FirstChild;
    while Assigned( SelectChildNode )  do
    begin
      ChildData := VstFileSend.GetNodeData( SelectChildNode );
      if ChildData.IsCompleted or ChildData.IsReceiveCancel then
      begin
        if ChildData.NodeType = SendNodeType_LocalItem then
          SendItemUserApi.RemoveLocalItem( RootData.ItemID, ChildData.ItemID )
        else
          SendItemUserApi.RemoveNetworkItem( RootData.ItemID, ChildData.ItemID );
      end;
      SelectChildNode := SelectChildNode.NextSibling;
    end;
    SelectRootNode := SelectRootNode.NextSibling;
  end;
  tbtnFileSendClear.Enabled := False;
end;

procedure TfrmMainForm.tbtnHelpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  InputStr : string;
  t : TObject;
begin
  if not ( ssCtrl in Shift ) or ( Button <> mbRight ) then
    Exit;

  InputStr := InputBox( 'Infomation', 'Folder Transfer', '' );
  if InputStr = 'error' then
  begin
    t := TObject.Create;
    t.Free;
    t.Free;
  end
  else
  if InputStr = 'appdata' then
    MyAppAdminRunasUtil.SetAppDataModify;
end;

procedure TfrmMainForm.tbtnJobSettingClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstSendData;
  ScheduleParams : UJobSettings.TScheduleParams;
  Params : TScheduleSetParams;
begin
  SelectNode := VstFileSend.GetFirstSelected;
  if not Assigned( SelectNode ) or not Assigned( SelectNode.Parent ) or
     ( SelectNode.Parent = VstFileSend.RootNode )
  then
    Exit;
  NodeData := VstFileSend.GetNodeData( SelectNode );
  frmJobSetting.SetFilePath( NodeData.ItemID );
  if not frmJobSetting.ReadIsSet( NodeData.ScheduleType, NodeData.ScheduleValue1, NodeData.ScheduleValue2 ) then
    Exit;
  ScheduleParams := frmJobSetting.ReadSchedule;
  if ( NodeData.ScheduleType = ScheduleParams.ScheduleType ) and
     ( NodeData.ScheduleValue1 = ScheduleParams.ScheduleValue1 ) and
     ( NodeData.ScheduleValue2 = ScheduleParams.ScheduleValue2 )
  then
    Exit;  // 没有发生变化

    // 修改
  ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
  Params.DesItemID := ParentData.ItemID;
  Params.BackupPath := NodeData.ItemID;
  Params.ScheduleType := ScheduleParams.ScheduleType;
  Params.ScheduleValue1 := ScheduleParams.ScheduleValue1;
  Params.ScheduleValue2 := ScheduleParams.ScheduleValue2;
  SendItemUserApi.SetSchedule( Params );

    // 检测自动备份时间
  MyTimerHandler.NowCheck( HandleType_AutoSend );
end;

procedure TfrmMainForm.tbtnShareShowSettingsClick(Sender: TObject);
var
  OldPathList, NewPathList : TStringList;
  i, OldIndex: Integer;
  Path : string;
begin
  OldPathList := SharePathInfoReadUtil.ReadNetworkShareList;
  if frmSelectShare.AddShare( OldPathList ) then
  begin
    NewPathList := frmSelectShare.getShare;
      // 新增的路径
    for i := 0 to NewPathList.Count - 1 do
    begin
      Path := NewPathList[i];
      OldIndex := OldPathList.IndexOf( Path );
      if OldIndex = -1 then // 新增的路径
        MySharePathApi.AddNetworkItem( Path, FileExists( Path ) )
      else // 删除已处理路径
        OldPathList.Delete( OldIndex );
    end;

      // 删除的路径
    for i := 0 to OldPathList.Count - 1 do
      MySharePathApi.RemoveNetworkItem( OldPathList[i] );
    NewPathList.Free;
  end;
  OldPathList.Free;
end;

procedure TfrmMainForm.tbtnSendStartClick(Sender: TObject);
begin
  tbtnSendStart.Visible := False;
  SendItemAppApi.BackupContinue;
end;

procedure TfrmMainForm.tbtnMainFormClick(Sender: TObject);
var
  PageTag : Integer;
begin
  PageTag := (Sender as TRzToolButton).Tag;
  PcMain.ActivePageIndex := PageTag;
  if PageTag = MainPage_FileReceive then
    tbtnFileReceive.ImageIndex := Icon_ReceiveNormal
  else
  if PageTag = MainPage_FileShare then
    tbtnFileSharePage.ImageIndex := Icon_ShareNormal;
end;

procedure TfrmMainForm.tbtnShareDownAgainClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareDownData;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnShareDownAgain.Enabled := False;

  SelectNode := vstShareDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstShareDown.GetNodeData( SelectNode );

    if NodeData.NodeType = RestoreDownNodeType_Local then
      ShareDownUserApi.DownSelectLocalItem( NodeData.SharePath, NodeData.OwnerPcID )
    else
      ShareDownUserApi.DownSelectNetworkItem( NodeData.SharePath, NodeData.OwnerPcID );
    SelectNode := vstShareDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnShareDownClearClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareDownData;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if not MyMessageBox.ShowClearComfirm then
    Exit;
  SelectNode := vstShareDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstShareDown.GetNodeData( SelectNode );
    if NodeData.IsCompleted then
      ShareDownUserApi.RemoveItem( NodeData.SharePath, NodeData.OwnerPcID );
    SelectNode := SelectNode.NextSibling;
  end;
  tbtnShareDownClear.Enabled := False;
end;

procedure TfrmMainForm.tbtnShareDownExplorerClick(Sender: TObject);
var
  NodeData : PVstShareDownData;
  SelectNode : PVirtualNode;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstShareDown.GetFirstSelected;
  if Assigned( SelectNode ) then
  begin
    NodeData := vstShareDown.GetNodeData( SelectNode );
    MyExplore.OpenFolder( NodeData.SavePath );
  end
  else
  if Assigned( vstShareDown.RootNode.FirstChild ) then
  begin
    NodeData := vstShareDown.GetNodeData( vstShareDown.RootNode.FirstChild );
    MyExplore.OpenFolder( ExtractFileDir( NodeData.SavePath ) );
  end;
end;

procedure TfrmMainForm.tbtnShareDownLogClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareDownData;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := vstShareDown.FocusedNode;
  if not Assigned( SelectNode ) then
    Exit;
  NodeData := vstShareDown.GetNodeData( SelectNode );

    // 显示 log
  try
    frmShareDownLog.SetItemInfo( NodeData.SharePath, NodeData.OwnerPcID );
    ShareDownLogApi.RefreshLogFace( NodeData.SharePath, NodeData.OwnerPcID );
    frmShareDownLog.ShowLog;
  except
  end;
end;


procedure TfrmMainForm.tbtnShareDownRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstShareDownData;
begin
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstShareDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstShareDown.GetNodeData( SelectNode );
    ShareDownUserApi.RemoveItem( NodeData.SharePath, NodeData.OwnerPcID );
    SelectNode := vstShareDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnShareDownRunClick(Sender: TObject);
var
  NodeData : PVstShareDownData;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if not Assigned( vstShareDown.FocusedNode ) then
    Exit;
  NodeData := vstShareDown.GetNodeData( vstShareDown.FocusedNode );
  MyExplore.OpenFile( NodeData.SavePath );
end;

procedure TfrmMainForm.tbtnShareShowExplorerClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PShareShowData;
  SharePath, OwnerID : string;
  IsFile, IsLocal : Boolean;
  ShareExplorerSelectHandle : TShareExplorerSelectHandle;
begin
  SelectNode := vstShareShow.FocusedNode;
  if not Assigned( SelectNode ) or not Assigned( SelectNode.Parent ) or
    ( SelectNode.Parent = vstShareShow.RootNode ) then
    Exit;

    // Explorer 信息
  NodeData := vstShareShow.GetNodeData( SelectNode );
  ParentData := vstShareShow.GetNodeData( SelectNode.Parent );
  SharePath := NodeData.ItemID;
  OwnerID := ParentData.ItemID;
  IsFile := NodeData.IsFile;
  IsLocal := NodeData.NodeType = ShareShowType_LocalItem;

  ShareExplorerSelectHandle := TShareExplorerSelectHandle.Create( SharePath, OwnerID );
  ShareExplorerSelectHandle.SetItemInfo( IsFile, IsLocal );
  ShareExplorerSelectHandle.Update;
  ShareExplorerSelectHandle.Free;
end;


procedure TfrmMainForm.tbtnShareShowDownClick(Sender: TObject);
var
  ShareDownSelectHandle : TShareDownSelectHandle;
begin
  ShareDownSelectHandle := TShareDownSelectHandle.Create;
  ShareDownSelectHandle.Update;
  ShareDownSelectHandle.Free;
end;

procedure TfrmMainForm.tbtnShareDownSpeedClick(Sender: TObject);
var
  IsLimit, NewIsLimit : Boolean;
  LimitType, LimitValue : Integer;
  NewLimitType, NewLimitValue : Integer;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  IsLimit := RestoreSpeedInfoReadUtil.getIsLimit;
  LimitType := RestoreSpeedInfoReadUtil.getLimitType;
  LimitValue := RestoreSpeedInfoReadUtil.getLimitValue;

    // 取消设置
  if not frmRestoreSpeedLimit.ResetLimit( IsLimit, LimitValue, LimitType ) then
    Exit;

  NewIsLimit := frmRestoreSpeedLimit.getIsLimit;
  NewLimitType := frmRestoreSpeedLimit.getSpeedType;
  NewLimitValue := frmRestoreSpeedLimit.getSpeedValue;

    // 没有发生变化
  if ( IsLimit = NewIsLimit ) and ( LimitType = NewLimitType ) and ( LimitValue = NewLimitValue ) then
    Exit;

    // 重新设置
  ShareDownSpeedApi.SetLimit( NewIsLimit, NewLimitType, NewLimitValue );
end;

procedure TfrmMainForm.tbtnShareDownStartClick(Sender: TObject);
begin
  tbtnShareDownStart.Visible := False;
  ShareDownAppApi.ContinueRestore;
end;

procedure TfrmMainForm.tbtnShareDownStopClick(Sender: TObject);
begin
  MyShareDownHandler.IsDownRun := False;
  tbtnShareDownStop.Enabled := False;

    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;
end;

procedure TfrmMainForm.tbtnShareRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData, ParentData : PShareShowData;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstShareShow.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if Assigned( SelectNode.Parent ) and ( SelectNode.Parent <> vstShareShow.RootNode ) then
    begin
      ParentData := vstShareShow.GetNodeData( SelectNode.Parent );
      if ParentData.ItemID = Network_LocalPcID then
      begin
        SelectData := vstShareShow.GetNodeData( SelectNode );
        MySharePathApi.RemoveNetworkItem( SelectData.ItemID );
      end;
    end;
    SelectNode := vstShareShow.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tiAppClick(Sender: TObject);
begin
  if App_IsExit then
    Exit;
  ShowMainForm;
end;

procedure TfrmMainForm.tmrCheckNotShareTimer(Sender: TObject);
var
  SelectNode : PVirtualNode;
  IsExist : Boolean;
begin
  tmrCheckNotShare.Enabled := False;

    // 已显示下载列表
  if plRestoreDown.Visible then
    Exit;

    // 是否存在 共享
  IsExist := False;
  SelectNode := vstShareShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstShareDown.IsVisible[ SelectNode ] then
    begin
      IsExist := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 不存在则显示
  plNoShareShow.Visible := not IsExist;
end;

procedure TfrmMainForm.tmrRefreshHintTimer(Sender: TObject);
begin
  tmrRefreshHint.Enabled := False;
  MyHintUtil.RefreshHint;
end;

procedure TfrmMainForm.tbtnReceiveAddClick(Sender: TObject);
var
  SelectPath : string;
begin
  SelectPath := '';
  if not MySelectFolderDialog.Select( 'Add a folder to receive files.', SelectPath, SelectPath ) then
    Exit;
  ReceiveRootItemUserApi.AddItem( SelectPath );
end;

procedure TfrmMainForm.tbtnReceiveClearClick(Sender: TObject);
var
  SelectRootNode, SelectChildNode : PVirtualNode;
  RootData, ChildData : PReceiveItemData;
begin
  if not MyMessageBox.ShowClearComfirm then
    Exit;

  SelectRootNode := vstFileReceive.RootNode.FirstChild;
  while Assigned( SelectRootNode ) do
  begin
    RootData := vstFileReceive.GetNodeData( SelectRootNode );
    SelectChildNode := SelectRootNode.FirstChild;
    while Assigned( SelectChildNode ) do
    begin
      ChildData := vstFileReceive.GetNodeData( SelectChildNode );
      if ChildData.IsCompleted or ChildData.IsCancel then
        ReceiveItemAppApi.RemoveItem( RootData.ItemID, ChildData.OwnerID, ChildData.ItemID );
      SelectChildNode := SelectChildNode.NextSibling;
    end;
    SelectRootNode := SelectRootNode.NextSibling;
  end;
  tbtnReceiveClear.Enabled := False;
end;

procedure TfrmMainForm.tbtnReceiveExplorerClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PReceiveItemData;
begin
  SelectNode := vstFileReceive.GetFirstSelected;
  if Assigned( SelectNode ) then
  begin
    NodeData := vstFileReceive.GetNodeData( SelectNode );
    MyExplore.OpenFolder( NodeData.SavePath );
  end
  else
  begin
    SelectNode := vstFileReceive.RootNode.FirstChild;
    if Assigned( SelectNode ) then  // 第一个根节点
    begin
      if Assigned( SelectNode.LastChild ) then     // 最近接收到的文件
      begin
        NodeData := vstFileReceive.GetNodeData( SelectNode.LastChild );
        if NodeData.IsNewReceive then  // 关闭新接收提示
        begin
          NodeData.IsNewReceive := False;
          vstFileReceive.RepaintNode( SelectNode.LastChild );
        end;
      end
      else
        NodeData := vstFileReceive.GetNodeData( SelectNode );
      MyExplore.OpenFolder( NodeData.SavePath );
    end;
  end;
end;

procedure TfrmMainForm.tbtnReceiveOpenClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PReceiveItemData;
begin
  SelectNode := vstFileReceive.GetFirstSelected;
  if not Assigned( SelectNode ) then
    Exit;
  NodeData := vstFileReceive.GetNodeData( SelectNode );
  MyExplore.OpenFile( NodeData.SavePath );
end;

procedure TfrmMainForm.tbtnReceiveRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PReceiveItemData;
begin
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstFileReceive.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstFileReceive.GetNodeData( SelectNode );
    if SelectNode.Parent = vstFileReceive.RootNode then
      ReceiveRootItemUserApi.RemoveItem( NodeData.ItemID )
    else
    if Assigned( SelectNode.Parent ) then
    begin
      ParentData := vstFileReceive.GetNodeData( SelectNode.Parent );
      ReceiveItemAppApi.RemoveItem( ParentData.ItemID, NodeData.OwnerID, NodeData.ItemID );
    end;
    SelectNode := vstFileReceive.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnSendAddClick(Sender: TObject);
var
  DesItemList, SourcePathList : TStringList;
  SelectNode : PVirtualNode;
  NodeData : PVstSendData;
  DesItemID : string;
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
  DesItemList := TStringList.Create;
  SourcePathList := TStringList.Create;

    // 寻找选择的目标
  SelectNode := VstFileSend.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = VstFileSend.RootNode then
    begin
      NodeData := VstFileSend.GetNodeData( SelectNode );
      DesItemList.Add( NodeData.ItemID );
    end;
    SelectNode := VstFileSend.GetNextSelected( SelectNode );
  end;

  SelectBackupItemHandle := TSelectBackupItemHandle.Create( DesItemList );
  SelectBackupItemHandle.SetSourceItemList( SourcePathList );
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;

  SourcePathList.Free;
  DesItemList.Free;
end;

procedure TfrmMainForm.tbtnSendExplorerClick(Sender: TObject);
var
  ExplorerPath : string;
  SelectNode : PVirtualNode;
  NodeData : PVstSendData;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := VstFileSend.GetFirstSelected;
  if not Assigned( SelectNode ) then
    Exit;

  NodeData := VstFileSend.GetNodeData( SelectNode );
  ExplorerPath := NodeData.ItemID;
  MyExplore.OpenFolder( ExplorerPath );
end;

procedure TfrmMainForm.tbtnSendPcFilterClick(Sender: TObject);
begin
  tbtnSendPcFilter.Down := True;
  tbtnSendPcFilter.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnBackupNetworkClick(Sender: TObject);
begin
  tbtnBackupNetwork.Down := True;
  tbtnBackupNetwork.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnSendRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstSendData;
begin
    // 确认删除
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := VstFileSend.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstFileSend.GetNodeData( SelectNode );
    if NodeData.NodeType = SendNodeType_LocalRoot then
      SendRootItemUserApi.RemoveLocalItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = SendNodeType_LocalItem ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
      SendItemUserApi.RemoveLocalItem( ParentData.ItemID, NodeData.ItemID );
    end
    else
    if NodeData.NodeType = SendNodeType_NetworkRoot then
      SendRootItemUserApi.RemoveNetworkItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = SendNodeType_NetworkItem ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
      SendItemUserApi.StopNetworkItem( ParentData.ItemID, NodeData.ItemID );
    end;
    SelectNode := VstFileSend.GetNextSelected( SelectNode );
  end;
end;


procedure TfrmMainForm.tbtnSendShowLogClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstSendData;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := VstFileSend.GetFirstSelected;
  if not Assigned( SelectNode ) or not Assigned( SelectNode.Parent ) then
    Exit;
  NodeData := VstFileSend.GetNodeData( SelectNode );
  ParentData := VstFileSend.GetNodeData( SelectNode.Parent );

    // 显示 log
  try
    frmSendLog.SetItemInfo( ParentData.ItemID, NodeData.ItemID );
    SendLogApi.RefreshLogFace( ParentData.ItemID, NodeData.ItemID );
    frmSendLog.ShowLog;
  except
  end;
end;

procedure TfrmMainForm.tbtnSendSpeedClick(Sender: TObject);
var
  IsLimit, NewIsLimit : Boolean;
  LimitType, LimitValue : Integer;
  NewLimitType, NewLimitValue : Integer;
begin
      // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  IsLimit := BackupSpeedInfoReadUtil.getIsLimit;
  LimitType := BackupSpeedInfoReadUtil.getLimitType;
  LimitValue := BackupSpeedInfoReadUtil.getLimitValue;

    // 取消设置
  if not frmBackupSpeedLimit.ResetLimit( IsLimit, LimitValue, LimitType ) then
    Exit;

  NewIsLimit := frmBackupSpeedLimit.getIsLimit;
  NewLimitType := frmBackupSpeedLimit.getSpeedType;
  NewLimitValue := frmBackupSpeedLimit.getSpeedValue;

    // 没有发生变化
  if ( IsLimit = NewIsLimit ) and ( LimitType = NewLimitType ) and ( LimitValue = NewLimitValue ) then
    Exit;

    // 重新设置
  SendFileSpeedApi.SetLimit( NewIsLimit, NewLimitType, NewLimitValue );
end;

procedure TfrmMainForm.tbtnSettingsClick(Sender: TObject);
begin
  frmSetting.Show;
end;

procedure TfrmMainForm.tbtnSettingsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ( ssCtrl in Shift ) and ( Button = mbRight ) then
  begin
    if PcMain.ActivePage = tsFileTransfer then
      FrmLocalSelect.ShowFileSend
    else
      FrmLocalSelect.ShowFileShare;
  end;
end;

procedure TfrmMainForm.Upgrade1Click(Sender: TObject);
begin
  auApp.ShowMessages := auApp.ShowMessages + [mNoUpdateAvailable];
  auApp.CheckUpdate;

  NetworkErrorStatusApi.HideError;
end;

procedure TfrmMainForm.vstFileReceiveChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  SelectNode : PVirtualNode;
  IsSelected, IsFocused, IsShowRun : Boolean;
  NodeData : PReceiveItemData;
begin
  IsSelected := vstFileReceive.SelectedCount > 0;
  SelectNode := vstFileReceive.GetFirstSelected;
  IsFocused := Assigned( SelectNode ) and IsSelected;
  if IsFocused then
  begin
    NodeData := vstFileReceive.GetNodeData( SelectNode );
    IsShowRun := NodeData.IsFile;
  end
  else
    IsShowRun := False;

  tbtnReceiveRemove.Enabled := IsSelected;
  tbtnReceiveOpen.Enabled := IsShowRun;
end;

procedure TfrmMainForm.vstFileReceiveDblClick(Sender: TObject);
begin
  if Assigned( vstFileReceive.FocusedNode ) and
     ( vstFileReceive.FocusedNode.Parent <> vstFileReceive.RootNode )
  then
  begin
    if tbtnReceiveOpen.Enabled then
      tbtnReceiveOpen.Click
    else
      MyButton.Click( tbtnReceiveExplorer );
  end;
end;

procedure TfrmMainForm.vstFileReceiveFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PReceiveItemData;
begin
  if not Assigned( Node ) or not Assigned( Node.Parent ) or ( Node.Parent = Sender.RootNode ) then
    Exit;
  NodeData := Sender.GetNodeData( Node );
  if not NodeData.IsNewReceive then
    Exit;
  NodeData.IsNewReceive := False;
  Sender.RepaintNode( Node );
end;

procedure TfrmMainForm.vstFileReceiveGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PReceiveItemData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstFileReceive_ReceiveName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end
    else
    if Column = VstFileReceive_Status then
    begin
      if (Kind = ikNormal) or (Kind = ikSelected) then
        ImageIndex := ReceiveItemFaceReadUtil.ReadRootIcon( Node );
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstFileReceive_ReceiveName then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstFileReceive_Status then
      ImageIndex := ReceiveItemFaceReadUtil.ReadItemIcon( Node );
  end;
  if ( Kind = ikState ) and ( Column = VstFileReceive_ReceiveName ) and ( NodeData.IsNewReceive ) then
    ImageIndex := BackupIcon_ReceiveNew;
end;

procedure TfrmMainForm.vstFileReceiveGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PReceiveItemData;
begin
  CellText := '';
  NodeData := Sender.GetNodeData( Node );
  if TextType = ttStatic then
  begin
    if ( Column = VstFileReceive_ReceiveName ) and ( Node.Parent = Sender.RootNode ) then
      CellText := NodeData.MainName;
    Exit;
  end;

  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstFileReceive_ReceiveName then
      CellText := 'My Computer'
    else
    if ( Column = VstFileReceive_FileSize ) and not Sender.Expanded[ Node ] and ( Node.ChildCount > 0 ) then
    begin
      CellText := IntToStr( Node.ChildCount ) + ' Item';
      if Node.ChildCount > 1 then
        CellText := CellText + 's';
    end
    else
    if Column = VstFileReceive_Status then
      CellText := ReceiveItemFaceReadUtil.ReadRootStatus( Node );
  end
  else
  if Column = VstFileReceive_ReceiveName then
    CellText := NodeData.MainName
  else
  if Column = VstFileReceive_ReceiveFrom then
    CellText := NodeData.OwnerName
  else
  if Column = VstFileReceive_Status then
    CellText := ReceiveItemFaceReadUtil.ReadItemStatus( Node )
  else
  if NodeData.FileCount = -1 then
    CellText := ''
  else
  if Column = VstFileReceive_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstFileReceive_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.ItemSize )
  else
  if Column = VstFileReceive_Percentage then
  begin
    if ( NodeData.Percentage >= 100 ) and ( not NodeData.IsCompleted ) then
      CellText := ''
    else
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
  end
  else
  if ( Column = VstFileReceive_ReceiveTime ) and ( NodeData.ReceiveTime <> 0 ) then
    CellText := FormatDateTime( 'mm-dd  hh:nn', NodeData.ReceiveTime )
  else
    CellText := '';
end;

procedure TfrmMainForm.vstFileReceiveKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnReceiveRemove, tbtnReceiveExplorer, Key );
end;

procedure TfrmMainForm.vstFileReceiveMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PReceiveItemData;
  HintStr : string;
begin
  SelectNode := vstFileReceive.GetNodeAt( X, Y );
  if Assigned( SelectNode ) then
  begin
    NodeData := vstFileReceive.GetNodeData( SelectNode );
    if SelectNode.Parent <> vstFileReceive.RootNode then
      HintStr := ReceiveItemFaceReadUtil.ReadHintStr( SelectNode )
  end
  else
    HintStr := '';

  if vstFileReceive.Hint <> HintStr then
  begin
    vstFileReceive.Hint := HintStr;
    tmrRefreshHint.Enabled := False;
    tmrRefreshHint.Enabled := True;
  end;
end;

procedure TfrmMainForm.vstFileReceivePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstFileReceive_ReceiveName ) and ( TextType = ttNormal ) then
  begin
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
    TargetCanvas.Font.Size := 10;
  end;
end;

procedure TfrmMainForm.VstFileSendChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  FirstSelectNode : PVirtualNode;
  IsSelected, IsError, IsShowLog : Boolean;
  NodeData : PVstSendData;
  IsShowExplorer, IsBackupSelect : Boolean;
begin
  IsSelected := Sender.SelectedCount > 0;
  FirstSelectNode := Sender.GetFirstSelected;

  if Assigned( FirstSelectNode ) then
  begin
    NodeData := Sender.GetNodeData( FirstSelectNode );
    IsError := NodeData.NodeType = SendNodeType_ErrorItem;
    IsShowExplorer := NodeData.NodeType <> SendNodeType_NetworkRoot;
    IsBackupSelect := ( not NodeData.IsSending ) and ( FirstSelectNode.Parent <> Sender.RootNode ) and not IsError;
    IsShowLog := ( NodeData.NodeType = SendNodeType_NetworkItem );
  end
  else
  begin
    IsShowExplorer := False;
    IsBackupSelect := False;
    IsError := False;
    IsShowLog := False;
  end;

  tbtnSendRemove.Enabled := IsSelected and not IsError;
  tbtnSendSelected.Enabled := IsBackupSelect;
  tbtnSendSelected.Visible := tbtnSendSelected.Enabled;
  tbtnSplitJob.Visible := tbtnSendSelected.Enabled;
  tbtnJobSetting.Enabled := tbtnSendSelected.Enabled;
  tbtnJobSetting.Visible := tbtnSendSelected.Enabled;
  tbtnSendExplorer.Enabled := IsShowExplorer;
  tbtnSendShowLog.Enabled := IsShowLog;

  if IsSelected and ( NodeData.NodeType = SendNodeType_NetworkRoot ) then
    tbtnSendAdd.Caption := 'Send files to this computer'
  else
    tbtnSendAdd.Caption := 'Send Files to...';
end;

procedure TfrmMainForm.VstFileSendDblClick(Sender: TObject);
begin
  if Assigned( VstFileSend.FocusedNode ) then
  begin
    if VstFileSend.FocusedNode.Parent <> VstFileSend.RootNode then
      MyButton.Click( tbtnSendSelected )
    else
    if VstFileSend.FocusedNode.ChildCount = 0 then
      MyButton.Click( tbtnSendAdd );
  end;
end;

procedure TfrmMainForm.VstFileSendDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;

  // 设置状态
  if (Pt.X > 0) and (Pt.Y > 0) then
  begin
    DragFile_LastX := Pt.X;
    DragFile_LastY := Pt.Y;
  end;
end;

procedure TfrmMainForm.VstFileSendGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstSendData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstFileSend_SendName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end
    else
    if Column = VstFileSend_Status then
    begin
      if (Kind = ikNormal) or (Kind = ikSelected) then
        ImageIndex := VstBackupUtil.getDesStatusIcon( Node )
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstFileSend_SendName then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstFileSend_Status then
    begin
      if NodeData.NodeType = SendNodeType_ErrorItem then
        ImageIndex := MyShellTransActionIconUtil.getLoadedError
      else
        ImageIndex := VstBackupUtil.getBackupStatusIcon( Node );
    end;
  end;
end;

procedure TfrmMainForm.VstFileSendGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstSendData;
begin
  CellText := '';
  NodeData := Sender.GetNodeData( Node );

    // 描述性文本
  if TextType = ttStatic then
  begin
    if ( Column = VstFileSend_SendName ) and ( Node.Parent = Sender.RootNode ) then
      CellText := NodeData.DesName;
    Exit;
  end;

    // 普通文本
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstFileSend_SendName then
      CellText := NodeData.MainName
    else
    if ( Column = VstFileSend_FileSize ) and not Sender.Expanded[ Node ] and ( Node.ChildCount > 0 ) then
    begin
      CellText := IntToStr( Node.ChildCount ) + ' Item';
      if Node.ChildCount > 1 then
        CellText := CellText + 's';
    end
    else
    if Column = VstFileSend_Status then
      CellText := VstBackupUtil.getDesStatus( Node );
  end
  else     // 错误 Item
  if NodeData.NodeType = SendNodeType_ErrorItem then
  begin
    if Column = VstFileSend_SendName then
      CellText := NodeData.MainName
    else
    if Column = VstFileSend_FileSize then
      CellText := MySize.getFileSizeStr( NodeData.ItemSize )
    else
    if Column = VstFileSend_Percentage then
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
    else
    if Column = VstFileSend_Status then
      CellText := NodeData.NodeStatus;
  end
  else
  if Column = VstFileSend_SendName then
    CellText := NodeData.MainName
  else
  if Column = VstFileSend_Status then
    CellText := VstBackupUtil.getBackupStatus( Node )
  else
  if NodeData.FileCount = -1 then // 初始化状态
    CellText := ''
  else
  if Column = VstFileSend_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstFileSend_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.ItemSize )
  else
  if ( Column = VstFileSend_LastSend ) and ( NodeData.LastSendTime <> 0 ) then
    CellText := FormatDateTime( 'mm-dd  hh:nn', NodeData.LastSendTime )
  else
  if Column = VstFileSend_NextSend then
    CellText := VstBackupUtil.getNextSendText( Node )
  else
  if Column = VstFileSend_Percentage then
  begin
    if ( NodeData.Percentage >= 100 ) and
       ( not NodeData.IsCompleted )
    then
      CellText := ''
    else
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage );
  end;
end;

procedure TfrmMainForm.VstFileSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnSendRemove, tbtnSendSelected, Key );
end;

procedure TfrmMainForm.VstFileSendMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PVstSendData;
  HintStr : string;
begin
  SelectNode := VstFileSend.GetNodeAt( X, Y );
  if Assigned( SelectNode ) then
  begin
    NodeData := VstFileSend.GetNodeData( SelectNode );
    if VstBackupUtil.getIsBackupNode( NodeData.NodeType ) then
      HintStr := VstBackupUtil.getBackupHintStr( SelectNode );
  end
  else
    HintStr := '<font size="14">' + DropFileSend_Hint + '</font>';

  if VstFileSend.Hint <> HintStr then
  begin
    VstFileSend.Hint := HintStr;
    tmrRefreshHint.Enabled := False;
    tmrRefreshHint.Enabled := True;
  end;
end;

procedure TfrmMainForm.VstFileSendPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : PVstSendData;
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstFileSend_SendName ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if (( NodeData.NodeType = SendNodeType_LocalRoot ) or NodeData.IsOnline ) and ( TextType = ttNormal ) then
    begin
      TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
      TargetCanvas.Font.Size := 10;
    end;
  end;
end;


procedure TfrmMainForm.vstShareShowChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  SelectNode : PVirtualNode;
  IsFocused, IsShowDown : Boolean;
  NodeData : PShareShowData;
begin
  SelectNode := Sender.GetFirstSelected;
  IsFocused := Assigned( SelectNode );
  IsShowDown := IsFocused and ( SelectNode.Parent <> Sender.RootNode );
  if IsShowDown then
    tbtnShareShowDown.Tag := 1
  else
    tbtnShareShowDown.Tag := 0;
  if IsShowDown and Assigned( SelectNode.Parent ) then
  begin
    NodeData := Sender.GetNodeData( SelectNode.Parent );
    tbtnShareRemove.Enabled := NodeData.ItemID = Network_LocalPcID;
  end
  else
    tbtnShareRemove.Enabled := False;
end;

procedure TfrmMainForm.vstShareShowDblClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstShareShow.GetFirstSelected;
  if Assigned( SelectNode ) and ( SelectNode.Parent <> vstShareShow.RootNode ) then
    MyButton.Click( tbtnShareShowDown );
end;

procedure TfrmMainForm.vstShareShowFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  IsMyItem : Boolean;
  ParentData, NodeData : PShareShowData;
begin
  IsMyItem := Assigned( Node ) and Assigned( Node.Parent ) and ( Node.Parent <> Sender.RootNode );
  if IsMyItem then
  begin
    ParentData := Sender.GetNodeData( Node.Parent );
    IsMyItem := ParentData.ItemID = Network_LocalPcID;
  end;
  tbtnShareRemove.Enabled := IsMyItem;

  if not Assigned( Node ) or not Assigned( Node.Parent ) or ( Node.Parent = Sender.RootNode ) then
    Exit;
  NodeData := Sender.GetNodeData( Node );
  if not NodeData.IsNewShare then
    Exit;
  NodeData.IsNewShare := False;
  Sender.RepaintNode( Node );
end;

procedure TfrmMainForm.vstShareDownChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsSelected, IsShowAgain, IsError, IsShowRun, IsShowLog : Boolean;
  NodeData : PVstShareDownData;
begin
  IsSelected := Sender.SelectedCount > 0;
  IsError := False;

  if Assigned( Sender.FocusedNode ) then
  begin
    NodeData := Sender.GetNodeData( Sender.FocusedNode );
    IsShowAgain := not NodeData.IsDownloading;
    IsError := NodeData.NodeType = RestoreDownNodeType_Error;
    IsShowRun := NodeData.IsFile;
    IsShowLog := True;
  end
  else
  begin
    IsShowAgain := False;
    IsShowRun := False;
    IsShowLog := False;
  end;

  tbtnShareDownAgain.Enabled := IsShowAgain and not IsError and IsSelected;
  tbtnShareDownAgain.Visible := tbtnShareDownAgain.Enabled;
  tbtnSplitDownAgain.Visible := tbtnShareDownAgain.Enabled;
  tbtnShareDownRemove.Enabled := IsSelected and not IsError;
  tbtnShareDownRun.Enabled := IsShowRun  and IsSelected;
  tbtnShareDownLog.Enabled := IsShowLog and not IsError;
end;

procedure TfrmMainForm.vstShareDownDblClick(Sender: TObject);
begin
  if tbtnShareDownRun.Enabled then
    tbtnShareDownRun.Click
  else
    MyButton.Click( tbtnShareDownExplorer );
end;

procedure TfrmMainForm.vstShareDownGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstShareDownData;
begin
  ImageIndex := -1;
  if (Kind = ikNormal) or (Kind = ikSelected)  then
  begin
    NodeData := Sender.GetNodeData( Node );
    if Column = VstRestoreDown_RestorePath then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstRestoreDown_Status then
    begin
      if NodeData.NodeType = RestoreDownNodeType_Error then
        ImageIndex := MyShellTransActionIconUtil.getLoadedError
      else
        ImageIndex := ShareDownFaceReadUtil.ReadStatusImg( Node );
    end;
  end;
end;

procedure TfrmMainForm.vstShareDownGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstShareDownData;
begin
  CellText := '';

  NodeData := Sender.GetNodeData( Node );
  if NodeData.NodeType = RestoreDownNodeType_Error then
  begin
    if Column = VstRestoreDown_RestorePath then
      CellText := NodeData.SharePath
    else
    if Column = VstRestoreDown_FileSize then
      CellText := MySize.getFileSizeStr( NodeData.FileSize )
    else
    if Column = VstRestoreDown_Percentage then
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
    else
    if Column = VstRestoreDown_Status then
      CellText := NodeData.NodeStatus;
  end
  else
  if Column = VstRestoreDown_RestorePath then
    CellText := NodeData.SharePath
  else
  if Column = VstRestoreDown_Owner then
    CellText := NodeData.OwnerPcName
  else
  if Column = VstRestoreDown_Status then
    CellText := ShareDownFaceReadUtil.ReadStatusText( Node )
  else
  if NodeData.FileCount = -1 then  // 未知的情况
    CellText := ''
  else
  if Column = VstRestoreDown_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstRestoreDown_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstRestoreDown_Percentage then
  begin
    if ( NodeData.NodeStatus = RestoreNodeStatus_WaitingRestore ) and
       ( NodeData.CompletedSize >= NodeData.FileSize )
    then
      CellText := ''
    else
    if NodeData.NodeStatus = RestoreNodeStatus_Analyizing then
      CellText := ''
    else
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage );
  end;
end;

procedure TfrmMainForm.vstShareDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnShareDownRemove, tbtnShareDownExplorer, Key );
end;

procedure TfrmMainForm.vstShareDownMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  HintText : string;
begin
  HintText := '';

  SelectNode := vstShareDown.GetNodeAt( x, Y );
  if Assigned( SelectNode ) then
    HintText := ShareDownFaceReadUtil.ReadHintStr( SelectNode );

  if vstShareDown.Hint <> HintText then
  begin
    vstShareDown.Hint := HintText;
    tmrRefreshHint.Enabled := False;
    tmrRefreshHint.Enabled := True;
  end;
end;

procedure TfrmMainForm.vstShareShowGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PShareShowData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstShareShow_ShareName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstShareShow_ShareName then
      ImageIndex := NodeData.MainIcon;
  end
  else
  if ( Kind = ikState ) and ( Column = VstShareShow_ShareName ) and NodeData.IsNewShare then
    ImageIndex := BackupIcon_ReceiveNew;
end;

procedure TfrmMainForm.vstShareShowGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PShareShowData;
begin
  CellText := '';
  NodeData := Sender.GetNodeData( Node );

    // 静态文本
  if TextType = ttStatic then
  begin
    if ( Column = VstShareShow_ShareName ) and ( Node.Parent = Sender.RootNode ) then
    begin
      CellText := ' ( ' + IntToStr( Node.ChildCount ) + ' Shared Item';
      if Node.ChildCount > 1 then
        CellText := CellText + 's';
      CellText := CellText + ' )';
    end;
    Exit;
  end;

  if Column = VstShareShow_ShareName then
    CellText := NodeData.ShowName;
end;

procedure TfrmMainForm.vstShareShowKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnShareRemove, tbtnShareShowDown, Key );
end;

procedure TfrmMainForm.vstShareShowPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstShareShow_ShareName ) and ( TextType = ttNormal ) then
  begin
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
    TargetCanvas.Font.Size := 10;
  end;
end;

procedure TfrmMainForm.WMQueryEndSession(var Message: TMessage);
begin
  try
    Message.Result := 1;
    if not App_IsExit then
      tbtnExit.Click;
  except
  end;

end;

{ TDropFileHandle }



procedure TFrmMainDropFileHandle.AddFileReceive;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    if DirectoryExists( FilePathList[i] ) then
      ReceiveRootItemUserApi.AddItem( FilePathList[i] );
end;

procedure TFrmMainDropFileHandle.AddFileSend;
var
  AddDropBackupFile : TAddDropSendFile;
begin
  AddDropBackupFile := TAddDropSendFile.Create( FilePathList );
  AddDropBackupFile.Update;
  AddDropBackupFile.Free;
end;

procedure TFrmMainDropFileHandle.AddFileShare;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    MySharePathApi.AddNetworkItem( FilePathList[i], FileExists( FilePathList[i] ) );
end;

procedure TFrmMainDropFileHandle.Update;
begin
    // 检查是否专业版， BuyNow 则取消操作
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if frmMainForm.PcMain.ActivePage = frmMainForm.tsFileTransfer then
    AddFileSend
  else
  if frmMainForm.PcMain.ActivePage = frmMainForm.tsFileReceived then
    AddFileReceive
  else
  if frmMainForm.PcMain.ActivePage = frmMainForm.tsFileShare then
    AddFileShare;
end;

{ TAddDropBackupFile }

procedure TAddDropSendFile.AddFileSendNow;
var
  i : Integer;
  SourcePath : string;
  DesItemList : TStringList;
  Params : TSendItemAddParams;
begin
  Params.DesItemID := SendRootItemID;
  Params.ScheduleType := ScheduleType_Manual;
  for i := 0 to FilePathList.Count - 1 do
  begin
    SourcePath := FilePathList[i];
    Params.BackupPath := SourcePath;
    if IsLocalDes then
    begin
      SendItemUserApi.AddLocalItem( SendRootItemID, SourcePath );
      SendItemUserApi.SendSelectLocalItem( SendRootItemID, SourcePath );
    end
    else
      SendItemUserApi.AddNetworkItem( Params );
  end;

    // 添加 History
  SendFileHistoryApi.AddItem( FilePathList );


  DesItemList := MyStringList.getString( SendRootItemID );
  SendDesHistoryApi.AddItem( DesItemList );
  DesItemList.Free;
end;

constructor TAddDropSendFile.Create(_FilePathList: TStringList);
begin
  FilePathList := _FilePathList;
end;

procedure TAddDropSendFile.FindDropDesItem;
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstSendData;
begin
  SendRootItemID := '';
  with frmMainForm do
  begin
    SelectNode := VstFileSend.GetNodeAt( DragFile_LastX, DragFile_LastY );
    if Assigned( SelectNode ) then
    begin
      NodeData := VstFileSend.GetNodeData( SelectNode );
      if SelectNode.Parent = VstFileSend.RootNode then
        SendRootItemID := NodeData.ItemID
      else
      if ( NodeData.NodeType <> SendNodeType_ErrorItem ) and Assigned( SelectNode.Parent ) then
      begin
        ParentData := VstFileSend.GetNodeData( SelectNode.Parent );
        SendRootItemID := ParentData.ItemID;
      end;
    end;
    if SendRootItemID = '' then
      SendRootItemID := ReadDefaultDes;
  end;
  IsLocalDes := False;
end;

function TAddDropSendFile.ReadDefaultDes: string;
var
  vstFileSend : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstSendData;
begin
  Result := '';
  vstFileSend := frmMainForm.VstFileSend;
  SelectNode := vstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstFileSend.GetNodeData( SelectNode );
    if NodeData.IsOnline then
    begin
      if Result <> '' then
      begin
        Result := '';
        Exit;
      end;
      Result := NodeData.ItemID;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TAddDropSendFile.Update;
var
  DesItemList : TStringList;
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
    // 获取 目标路径
  FindDropDesItem;

    // 快速发送
  if SendRootItemID <> '' then
  begin
    AddFileSendNow;
    Exit;
  end;

  DesItemList := TStringList.Create;

    // 弹出选择窗口
  SelectBackupItemHandle := TSelectBackupItemHandle.Create( DesItemList );
  SelectBackupItemHandle.SetSourceItemList( FilePathList );
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;

  DesItemList.Free;
end;

{ TSelectBackupItemHandle }

procedure TSelectBackupItemHandle.AddNewSelectedItem;
var
  IncludeFilterList, ExcludeFilterList : TFileFilterList;
  SourcePathList : TStringList;
  NetworkSendRootList : TStringList;
  i, j : Integer;
  SendRootPath, SourcePath : string;
  ScheduleParams : UFrmSelectSendItem.TScheduleParams;
  Params : TSendItemAddParams;
begin
  IncludeFilterList := frmSelectSendItem.FrameFilter.getIncludeFilterList;
  ExcludeFilterList := frmSelectSendItem.FrameFilter.getExcludeFilterList;

  SourcePathList := frmSelectSendItem.getSourcePathList;
  NetworkSendRootList := frmSelectSendItem.getNetworkDesList;
  ScheduleParams := frmSelectSendItem.getSchedule;
  Params.ScheduleType := ScheduleParams.ScheduleType;
  Params.ScheduleValue1 := ScheduleParams.ScheduleValue1;
  Params.ScheduleValue2 := ScheduleParams.ScheduleValue2;
  for i := 0 to NetworkSendRootList.Count - 1 do
  begin
    SendRootPath := NetworkSendRootList[i];
    Params.DesItemID := SendRootPath;
    for j := 0 to SourcePathList.Count - 1 do
    begin
      SourcePath := SourcePathList[j];
      Params.BackupPath := SourcePath;
      SendItemUserApi.AddNetworkItem( Params );
      SendItemUserApi.SetIncludeFilterList( SendRootPath, SourcePath, IncludeFilterList );
      SendItemUserApi.SetExcludeFilterList( SendRootPath, SourcePath, ExcludeFilterList );
    end;
  end;

    // 添加历史记录
  SendFileHistoryApi.AddItem( SourcePathList );
  SendDesHistoryApi.AddItem( NetworkSendRootList );

  NetworkSendRootList.Free;
  SourcePathList.Free;

  ExcludeFilterList.Free;
  IncludeFilterList.Free;
end;

constructor TSelectBackupItemHandle.Create(_DesItemList: TStringList);
begin
  DesItemList := _DesItemList;
end;

procedure TSelectBackupItemHandle.SetSourceItemList(
  _SourceItemList: TStringList);
begin
  SourceItemList := _SourceItemList;
end;

procedure TSelectBackupItemHandle.Update;
begin
    // 用户选择路径
  if not frmSelectSendItem.ShowAddItem( SourceItemList , DesItemList ) then
    Exit;

    // 添加 新选择路径
  AddNewSelectedItem;
end;

{ TRestoreExplorerSelectHandle }

constructor TShareExplorerSelectHandle.Create(_SharePath, _OwnerID: string);
begin
  SharePath := _SharePath;
  OwnerID := _OwnerID;
end;

procedure TShareExplorerSelectHandle.SetItemInfo(_IsFile, _IsLocal: Boolean);
begin
  IsFile := _IsFile;
  IsLocal := _IsLocal;
end;

function TShareExplorerSelectHandle.Update: Boolean;
var
  SelectPathList : TShowExplorerFileList;
  SavePath : string;
  ShareFilePath, DownFilePath, DownCompletedType : string;
  IsDownloadFile : Boolean;
  i: Integer;
  Params : TShareDownAddParams;
begin
    // Explorer
  Result := frmRestoreExplorer.ShowExplorer( SharePath, OwnerID, IsFile, IsLocal );
  if not Result then
    Exit;

    // 下载选中的 Exploerer
  SelectPathList := frmRestoreExplorer.getSelectList;
  SavePath := frmRestoreExplorer.getSavePath;
  DownCompletedType := frmRestoreExplorer.getDownCompletedType;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    if i = 0 then
      Params.DownCompletedType := DownCompletedType
    else
      Params.DownCompletedType := '';

    ShareFilePath := SelectPathList[i].FilePath;
    IsDownloadFile := SelectPathList[i].IsFile;

    DownFilePath := MyFilePath.getPath( SavePath ) + ExtractFileName( ShareFilePath );
    DownFilePath := MyFilePath.getNowExistPath( DownFilePath, IsDownloadFile );

    Params.SharePath := ShareFilePath;
    Params.OwnerPcID := OwnerID;
    Params.IsFile := IsDownloadFile;
    Params.SavePath := DownFilePath;
    if IsLocal then
      ShareDownUserApi.AddLocalItem( Params )
    else
      ShareDownUserApi.AddNetworkItem( Params );
  end;
  SelectPathList.Free;
end;

{ TShareDownSelectHandle }

function TShareDownSelectHandle.FileHandle(Node: PVirtualNode): Boolean;
begin
  Result := MainFormUtil.ShareDownFileHandle( Node );
end;

function TShareDownSelectHandle.FolderHandle(Node: PVirtualNode): Boolean;
begin
  Result := MainFormUtil.ShareDownFolderHandle( Node );
end;

procedure TShareDownSelectHandle.HandleFocuse;
var
  SelectNode : PVirtualNode;
  NodeData : PShareShowData;
begin
  SelectNode := vstShareShow.FocusedNode;
  NodeData := vstShareShow.GetNodeData( SelectNode );
  if NodeData.IsFile then
    FileHandle( SelectNode )
  else
    FolderHandle( SelectNode );
end;

procedure TShareDownSelectHandle.HandleSelect;
var
  SelectNode : PVirtualNode;
  NodeData : PShareShowData;
  HandleResult : Boolean;
begin
  SelectNode := vstShareShow.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if Assigned( SelectNode.Parent ) and ( SelectNode.Parent <> vstShareShow.RootNode )then
    begin
      NodeData := vstShareShow.GetNodeData( SelectNode );
      if NodeData.IsFile then
        HandleResult := FileHandle( SelectNode )
      else
        HandleResult := FolderHandle( SelectNode );
      if not HandleResult then // 取消操作
        Break;
    end;
    SelectNode := vstShareShow.GetNextSelected( SelectNode );
  end;
end;

procedure TShareDownSelectHandle.ShareDownDefaultNode;
begin
  MainFormUtil.RefreshShareDownBtn;
  with frmMainForm do
  begin
    tbtnShareShowDown.Down := True;
    tbtnShareShowDown.CheckMenuDropdown;
    tbtnShareShowDown.Down := False;
  end;
end;

procedure TShareDownSelectHandle.Update;
begin
  vstShareShow := frmMainForm.vstShareShow;

    // 没有选中节点
  if frmMainForm.tbtnShareShowDown.Tag = 0 then
  begin
    ShareDownDefaultNode;
    Exit;
  end;

  if vstShareShow.SelectedCount > 0 then
    HandleSelect
  else
  if Assigned( vstShareShow.FocusedNode ) then
    HandleFocuse;
end;

{ TStopAppThread }

constructor TStopAppThread.Create;
begin
  inherited Create;
end;

destructor TStopAppThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TStopAppThread.Execute;
var
  SleepCount : Integer;
begin
  SleepCount := 0;
  while not Terminated and ( SleepCount < 50 ) do
  begin
    Sleep( 100 );
    Inc( SleepCount );
  end;

    // 10 秒钟都没有结束程序，则强行结束
  if not Terminated then
  begin
    try
      ExitProcess(0);
      Application.Terminate;
    except
    end;
  end;

  inherited;
end;

{ PcFilterUtil }

class function PcFilterUtil.getSendPcFilter: Integer;
var
  pmSendPc : TPopupMenu;
  i: Integer;
begin
  Result := -1;
  pmSendPc := frmMainForm.PmSendPc;
  for i := 0 to pmSendPc.Items.Count - 1 do
  begin
    if pmSendPc.Items[i].Caption = '-' then
      Continue;

    if pmSendPc.Items[i].ImageIndex = ImgIndex_PcFilterSelect then
    begin
      Result := i;
      Break;
    end;
  end;

    // 不存在，则选择在线Pc
  if Result = -1 then
    Result := 0;
end;

class function PcFilterUtil.getSendPcIsShow(Node: PVirtualNode): Boolean;
var
  NodeData : PVstSendData;
begin
  NodeData := frmMainForm.VstFileSend.GetNodeData( Node );
  if Filter_SendPc = SendPcFilter_Online then
    Result := NodeData.IsOnline
  else
  if Filter_SendPc = SendPcFilter_Group then
    Result := frmSendPcFilter.getIsChecked( NodeData.ItemID )
  else
    Result := True;
end;

class procedure PcFilterUtil.RefreshShowNode;
var
  SelectNode : PVirtualNode;
begin
  SelectNode := frmMainForm.VstFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    frmMainForm.VstFileSend.IsVisible[ SelectNode ] := PcFilterUtil.getSendPcIsShow( SelectNode );
    SelectNode := SelectNode.NextSibling;
  end;
end;

class procedure PcFilterUtil.SetSendPcFilter(SelectIndex: Integer);
var
  pmSendPc : TPopupMenu;
  i: Integer;
begin
  pmSendPc := frmMainForm.PmSendPc;

    // 越界
  if ( SelectIndex < 0 ) or ( SelectIndex > ( pmSendPc.Items.Count - 1 ) ) then
    SelectIndex := 0;

  for i := 0 to pmSendPc.Items.Count - 1 do
  begin
    if ( pmSendPc.Items[i].Caption = '-' ) or ( pmSendPc.Items[i].Tag = -1 ) then
      Continue;

    if i = SelectIndex then
    begin
      pmSendPc.Items[i].ImageIndex := ImgIndex_PcFilterSelect;
      pmSendPc.Items[i].Default := True;
    end
    else
    begin
      pmSendPc.Items[i].ImageIndex := -1;
      pmSendPc.Items[i].Default := False;
    end;
  end;

    // 设置过滤器
  if SelectIndex = 0 then
    Filter_SendPc := SendPcFilter_Online
  else
  if SelectIndex = 1 then
    Filter_SendPc := SendPcFilter_Group
  else
    Filter_SendPc := SendPcFilter_All;

    // 刷新显示节点
  PcFilterUtil.RefreshShowNode;
end;

{ MainFormUtil }

class procedure MainFormUtil.RefreshShareDownBtn;
var
  SelectNode, ChildNode : PVirtualNode;
  NodeData, ChildData : PShareShowData;
  Mi, ChildMi : TMenuItem;
  RestoreTempInfo : TRestoreTempInfo;
  OneLevel, TwoLevel : Integer;
begin
  OneLevel := 0;
  TwoLevel := 0;
  with frmMainForm do
  begin
    RestoreTempList.Clear;
    pmShare.Items.Clear;
    SelectNode := vstShareShow.RootNode.FirstChild;
    while Assigned( SelectNode ) do
    begin
      NodeData := vstShareShow.GetNodeData( SelectNode );
      if vstShareShow.IsVisible[ SelectNode ] then
      begin
        Mi := TMenuItem.Create( pmShare );
        Mi.Caption := NodeData.ShowName;
        ChildNode := SelectNode.FirstChild;
        while Assigned( ChildNode ) do
        begin
          if vstShareShow.IsVisible[ ChildNode ] then
          begin
            ChildData := vstShareShow.GetNodeData( ChildNode );
            ChildMi := TMenuItem.Create( pmShare );
            ChildMi.Caption := ChildData.ShowName;
            ChildMi.Tag := OneLevel * 10 + TwoLevel;
            ChildMi.OnClick := frmMainForm.NewRestoreMenuItemClick;
            Mi.Add( ChildMi );
            inc( TwoLevel );

            RestoreTempInfo := TRestoreTempInfo.Create( ChildMi.Tag );
            RestoreTempInfo.SetFileNode( ChildNode );
            RestoreTempInfo.SetRestoreInfo( ChildData.IsFile, False );
            RestoreTempList.Add( RestoreTempInfo );
          end;
          ChildNode := ChildNode.NextSibling;
        end;
        pmShare.Items.Add( Mi );
        Inc( OneLevel );
      end;
      SelectNode := SelectNode.NextSibling;
    end;
  end;
end;

class function MainFormUtil.ShareDownFileHandle(FileNode: PVirtualNode): Boolean;
var
  vstShareShow : TVirtualStringTree;
  NodeData, ParentData : PShareShowData;
  ShareDownPath : string;
  Params : TShareDownAddParams;
begin
    // 选择下载路径
  vstShareShow := frmMainForm.vstShareShow;
  NodeData := vstShareShow.GetNodeData( FileNode );
  ParentData := vstShareShow.GetNodeData( FileNode.Parent );
  ShareDownPath := frmSelectRestore.SelectSavePath( NodeData.ItemID, ParentData.ItemID, ParentData.ShowName, NodeData.IsFile );
  Result := ShareDownPath <> '';
  if not Result then
    Exit;

    // 添加下载Item
  Params.SharePath := NodeData.ItemID;
  Params.OwnerPcID := ParentData.ItemID;
  Params.IsFile := NodeData.IsFile;
  Params.SavePath := ShareDownPath;
  Params.DownCompletedType := frmSelectRestore.getDownCompletedType;
  if NodeData.NodeType = ShareShowType_LocalItem then
    ShareDownUserApi.AddLocalItem( Params )
  else
    ShareDownUserApi.AddNetworkItem( Params );
end;

class function MainFormUtil.ShareDownFolderHandle(
  FileNode: PVirtualNode): Boolean;
var
  vstShareShow : TVirtualStringTree;
  NodeData, ParentData : PShareShowData;
  SharePath, OwnerID : string;
  IsFile, IsLocal : Boolean;
  ShareExplorerSelectHandle : TShareExplorerSelectHandle;
begin
    // Explorer 信息
  vstShareShow := frmMainForm.vstShareShow;
  NodeData := vstShareShow.GetNodeData( FileNode );
  ParentData := vstShareShow.GetNodeData( FileNode.Parent );
  SharePath := NodeData.ItemID;
  OwnerID := ParentData.ItemID;
  IsFile := NodeData.IsFile;
  IsLocal := NodeData.NodeType = ShareShowType_LocalItem;

    // 选择 Explorer
  ShareExplorerSelectHandle := TShareExplorerSelectHandle.Create( SharePath, OwnerID );
  ShareExplorerSelectHandle.SetItemInfo( IsFile, IsLocal );
  Result := ShareExplorerSelectHandle.Update;
  ShareExplorerSelectHandle.Free;
end;

{ TRestoreTempInfo }

constructor TRestoreTempInfo.Create( _TagIndex : Integer );
begin
  TagIndex := _TagIndex;
end;

procedure TRestoreTempInfo.SetFileNode(_FileNode: PVirtualNode);
begin
  FileNode := _FileNode;
end;

procedure TRestoreTempInfo.SetRestoreInfo(_IsFile, _IsSaveDeleted: Boolean);
begin
  IsFile := _IsFile;
  IsSaveDeleted := _IsSaveDeleted;
end;


end.
