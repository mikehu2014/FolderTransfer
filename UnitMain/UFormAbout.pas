unit UFormAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, GIFImg, UFormUtil;

type
  TfrmAbout = class(TForm)
    plFolderTransfer: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    lbFolderTransferEdition: TLabel;
    Image2: TImage;
    LinkLabel2: TLinkLabel;
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormCreate(Sender: TObject);
  private
    function getAppEdition : string;
  public
    { Public declarations }
  end;

const
  PageIndex_BackupCow = 0;
  PageIndex_FolderTransfer = 1;

var
  frmAbout: TfrmAbout;

implementation

uses UMyUtil, UAppEditionInfo, UMainForm, UMyUrl;

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lbFolderTransferEdition.Caption := getAppEdition;
  FormUtil.BindEseClose( Self );
end;

function TfrmAbout.getAppEdition: string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(Application.ExeName), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');
                                                        // ^^^^^^^此处换成ProductVersion得到的是"产品版本"
        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure TfrmAbout.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.getHome );
end;

end.
