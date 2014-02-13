unit UDebugForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UPortMap, ExtCtrls, UChangeInfo, uDebugLock, RzTabs,
  Vcl.ComCtrls;

type
  TfrmDebug = class(TForm)
    plControl: TPanel;
    btnRefresh: TButton;
    btnClose: TButton;
    pcMain: TRzPageControl;
    tsDetails: TRzTabSheet;
    tsList: TRzTabSheet;
    mmoResult: TMemo;
    lvDebug: TListView;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    function getNewItem(tid: Integer): Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDebug: TfrmDebug;

implementation

{$R *.dfm}

procedure TfrmDebug.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDebug.btnRefreshClick(Sender: TObject);
var
  I: Integer;
  DebugLockItem: PDebugLockItem;
  s : string;
  NewItemIndex : Integer;
  NewItem : TListItem;
begin
  mmoResult.Text := DebugLock.TrackDebug;

  lvDebug.Clear;
  DebugLock.Lock;
  try
    for I := 0 to DebugLock.FList.Count - 1 do
    begin
      DebugLockItem := DebugLock.FList.Items[I];
      NewItemIndex := getNewItem( DebugLockItem^.ThreadId );
      if NewItemIndex >= 0 then
        NewItem := lvDebug.Items.Insert( NewItemIndex )
      else
        NewItem := lvDebug.Items.Add;
      NewItem.Caption := IntToStr( DebugLockItem^.ThreadId );
      NewItem.SubItems.Add( DebugLockItem^.ThreadName );
   end;
  except
  end;
  DebugLock.Unlock;
end;

function TfrmDebug.getNewItem(tid: Integer): Integer;
var
  i: Integer;
  SelectID : Integer;
begin
  Result := -1;
  for i := 0 to lvDebug.Items.Count - 1 do
  begin
    SelectID := StrToIntDef( lvDebug.Items[i].Caption, 0 );
    if SelectID > tid then
    begin
      Result := i;
      Break;
    end;
  end;
end;

end.
