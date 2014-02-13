unit UMySendEventInfo;

interface

uses SysUtils, UMyUtil;

type

  TBackupCompletedEventParams = record
  public
    DesItemID, SourcePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpce : Int64;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  end;

    // 网络备份 事件
  NetworkSendItemEvent = class
  public
    class procedure AddItem( DesItemID, SourcePath : string );
    class procedure WaitingSendItem( DesItemID, SourcePath : string );
    class procedure RemoveItem( DesItemID, SourcePath : string );
  end;

    // 反向连接
  NetworkBackConnEvent = class
  public
    class procedure AddItem( ReceivePcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo, UMyShareDownApiInfo, UMySendApiInfo, UMySendDataInfo;

{ NetworkBackupMsgEvent }

class procedure NetworkSendItemEvent.AddItem(DesItemID, SourcePath: string);
var
  ReceivePcID, ReceiveRootPath : string;
  SendItemAddMsg : TSendItemAddMsg;
  IsZip : Boolean;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );
  ReceiveRootPath := NetworkDesItemUtil.getCloudPath( DesItemID );
  IsZip := SendItemInfoReadUtil.ReadIsZip( DesItemID, SourcePath );

  SendItemAddMsg := TSendItemAddMsg.Create;
  SendItemAddMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemAddMsg.SetSourcePath( SourcePath );
  SendItemAddMsg.SetIsFile( FileExists( SourcePath ) );
  SendItemAddMsg.SetIsZip( IsZip );
  SendItemAddMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( ReceivePcID, SendItemAddMsg );
end;

class procedure NetworkSendItemEvent.RemoveItem(DesItemID,
  SourcePath: string);
var
  ReceivePcID, ReceiveRootPath : string;
  SendItemRemoveMsg : TSendItemRemoveMsg;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );
  ReceiveRootPath := NetworkDesItemUtil.getCloudPath( DesItemID );

  SendItemRemoveMsg := TSendItemRemoveMsg.Create;
  SendItemRemoveMsg.SetPcID( PcInfo.PcID );
  SendItemRemoveMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemRemoveMsg.SetSourcePath( SourcePath );
  MyClient.SendMsgToPc( ReceivePcID, SendItemRemoveMsg );
end;

class procedure NetworkSendItemEvent.WaitingSendItem(DesItemID,
  SourcePath: string);
var
  ReceivePcID, ReceiveRootPath : string;
  SendItemWaitingMsg : TSendItemWaitingMsg;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );
  ReceiveRootPath := NetworkDesItemUtil.getCloudPath( DesItemID );

  SendItemWaitingMsg := TSendItemWaitingMsg.Create;
  SendItemWaitingMsg.SetReceiveRootPath( ReceiveRootPath );
  SendItemWaitingMsg.SetSourcePath( SourcePath );
  SendItemWaitingMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( ReceivePcID, SendItemWaitingMsg );
end;

{ NetworkBackConnEvent }

class procedure NetworkBackConnEvent.AddItem(ReceivePcID: string);
var
  SendItemBackConnMsg : TSendItemBackConnMsg;
begin
  SendItemBackConnMsg := TSendItemBackConnMsg.Create;
  SendItemBackConnMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( ReceivePcID, SendItemBackConnMsg );
end;

end.
