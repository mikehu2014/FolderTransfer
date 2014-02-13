unit UMyReceiveEventInfo;

interface

type

    // ����·�� �¼�
  ReceiveRootEvent = class
  public
    class procedure AddItem( RootPath : string );
    class procedure RemoveItem( RootPath : string );
  public
    class procedure OnlineSendItem( OnlinePcID, RootPath : string );
  end;

    // ����Item �¼�
  ReceiveItemEvent = class
  public
    class procedure RemoveItem( RootPath, OwnerID, SourcePath : string );
  end;

    // ��������ʱ��
  ReceiveBackConnEvent = class
  public
    class procedure ConnBusy( SendPcID : string );
    class procedure ConnError( SendPcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo, UMyUtil;


{ MyCloudPathEvent }

class procedure ReceiveRootEvent.AddItem(RootPath: string);
var
  AvailableSpace : Int64;
  CloudPathAddMsg : TReceiveRootItemAddMsg;
begin
    // ���ÿռ�
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( RootPath );

  CloudPathAddMsg := TReceiveRootItemAddMsg.Create;
  CloudPathAddMsg.SetPcID( PcInfo.PcID );
  CloudPathAddMsg.SetReceiveRootPath( RootPath );
  CloudPathAddMsg.SetAvailableSpace( AvailableSpace );
  MyClient.SendMsgToAll( CloudPathAddMsg );
end;

class procedure ReceiveRootEvent.OnlineSendItem(OnlinePcID, RootPath: string);
var
  AvailableSpace : Int64;
  CloudPathAddMsg : TReceiveRootItemAddMsg;
begin
    // ���ÿռ�
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( RootPath );

    // ����·��
  CloudPathAddMsg := TReceiveRootItemAddMsg.Create;
  CloudPathAddMsg.SetPcID( PcInfo.PcID );
  CloudPathAddMsg.SetReceiveRootPath( RootPath );
  CloudPathAddMsg.SetAvailableSpace( AvailableSpace );
  MyClient.SendMsgToPc( OnlinePcID, CloudPathAddMsg );
end;

class procedure ReceiveRootEvent.RemoveItem(RootPath: string);
var
  CloudPathRemoveMsg : TReceiveRootItemRemoveMsg;
begin
  CloudPathRemoveMsg := TReceiveRootItemRemoveMsg.Create;
  CloudPathRemoveMsg.SetPcID( PcInfo.PcID );
  CloudPathRemoveMsg.SetReceiveRootPath( RootPath );
  MyClient.SendMsgToAll( CloudPathRemoveMsg );
end;


{ ReceiveItemEvent }

class procedure ReceiveItemEvent.RemoveItem(RootPath, OwnerID,
  SourcePath: string);
var
  ReceiveItemRemoveMsg : TReceiveItemRemoveMsg;
begin
  ReceiveItemRemoveMsg := TReceiveItemRemoveMsg.Create;
  ReceiveItemRemoveMsg.SetReceiveRootPath( RootPath );
  ReceiveItemRemoveMsg.SetSourcePath( SourcePath );
  ReceiveItemRemoveMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( OwnerID, ReceiveItemRemoveMsg );
end;

{ ReceiveBackConnEvent }

class procedure ReceiveBackConnEvent.ConnBusy(SendPcID: string);
var
  SendItemBackConnBusyMsg : TSendItemBackConnBusyMsg;
begin
  SendItemBackConnBusyMsg := TSendItemBackConnBusyMsg.Create;
  SendItemBackConnBusyMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( SendPcID, SendItemBackConnBusyMsg );
end;

class procedure ReceiveBackConnEvent.ConnError(SendPcID: string);
var
  SendItemBackConnErrorMsg : TSendItemBackConnErrorMsg;
begin
  SendItemBackConnErrorMsg := TSendItemBackConnErrorMsg.Create;
  SendItemBackConnErrorMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( SendPcID, SendItemBackConnErrorMsg );
end;

end.
