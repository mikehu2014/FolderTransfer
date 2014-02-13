unit UFormFreeTips;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, RzTabs, Vcl.Imaging.jpeg;

type
  TfrmFreeTips = class(TForm)
    Panel1: TPanel;
    plRestoreTitle: TPanel;
    pcMain: TRzPageControl;
    tsBackupCow: TRzTabSheet;
    pcBackupCow: TRzPageControl;
    tsBackupAndSync: TRzTabSheet;
    Panel2: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    tsNetworkTools: TRzTabSheet;
    tsCloudBuilder: TRzTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lkBackupAndSync: TLinkLabel;
    lkNetworkTools: TLinkLabel;
    Label7: TLabel;
    Label8: TLabel;
    lkCloudBuilder: TLinkLabel;
    tsFileSearch: TRzTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    lkFileSearch: TLinkLabel;
    tsDataTransfer: TRzTabSheet;
    Label11: TLabel;
    Label12: TLabel;
    lkDataTransfer: TLinkLabel;
    Label13: TLabel;
    lkHome: TLinkLabel;
    lkRegister: TLinkLabel;
    procedure lkBackupAndSyncLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkNetworkToolsLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkCloudBuilderLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkFileSearchLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkDataTransferLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkHomeLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkRegisterLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  private
    { Private declarations }
  public
    procedure ShowRandomPage;
  end;

var
  frmFreeTips: TfrmFreeTips;

implementation

uses UMyUtil, UMyUrl;

{$R *.dfm}

procedure TfrmFreeTips.lkBackupAndSyncLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.BackupAndSync );
end;

procedure TfrmFreeTips.lkNetworkToolsLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.getFeature );
end;

procedure TfrmFreeTips.lkCloudBuilderLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.CloudBuilder );
end;

procedure TfrmFreeTips.lkFileSearchLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.getFeature );
end;

procedure TfrmFreeTips.lkDataTransferLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.getFeature );
end;

procedure TfrmFreeTips.lkHomeLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyBackupCowUrl.getHome );
end;

procedure TfrmFreeTips.lkRegisterLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmFreeTips.ShowRandomPage;
var
  MainPage : Integer;
begin
  Randomize;
  MainPage := Random( pcBackupCow.PageCount );
  pcBackupCow.ActivePageIndex := MainPage;
  ShowModal;
end;

end.
