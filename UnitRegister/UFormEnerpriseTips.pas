unit UFormEnerpriseTips;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList;

type
  TfrmEnterpriseTips = class(TForm)
    Label1: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    btnBuyNow: TButton;
    btnClose: TButton;
    ilEdition: TImageList;
    procedure btnCloseClick(Sender: TObject);
    procedure btnBuyNowClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEnterpriseTips: TfrmEnterpriseTips;

implementation

uses UMyUtil, UMyUrl, UFormRegister;

{$R *.dfm}

procedure TfrmEnterpriseTips.btnBuyNowClick(Sender: TObject);
begin
  Close;
  frmRegister.Show;
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmEnterpriseTips.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
