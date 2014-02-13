unit UFormPreviewPicture;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ExtCtrls;

type
  TfrmPreviewPic = class(TForm)
    pl: TPanel;
    plLeft: TPanel;
    tbMain: TToolBar;
    btnBig: TToolButton;
    tbtnSmall: TToolButton;
    ToolButton7: TToolButton;
    tbtnLast: TToolButton;
    tbtnNext: TToolButton;
    ToolButton5: TToolButton;
    tbtnMax: TToolButton;
    tbtnMin: TToolButton;
    ImageList1: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPreviewPic: TfrmPreviewPic;

implementation

{$R *.dfm}

end.
