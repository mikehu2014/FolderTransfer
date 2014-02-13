unit UMyShareEventInfo;

interface

type

  MySharePathEvent = class
  public
    class procedure AddItem( SharePath : string; IsFile : Boolean );
    class procedure RemoveItem( SharePath : string );
  public
    class procedure OnlineSendItem( OnlinePcID, SharePath : string; IsFile : Boolean );
  end;

  MySharePathBackConnEvent = class
  public
    class procedure ConnDownBusy( DownPcID : string );
    class procedure ConnDownError( DownPcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo;

{ MySharePathEvent }

class procedure MySharePathEvent.AddItem(SharePath: string; IsFile: Boolean);
var
  SharePathAddMsg : TSharePathAddMsg;
begin
  SharePathAddMsg := TSharePathAddMsg.Create;
  SharePathAddMsg.SetSharePath( SharePath );
  SharePathAddMsg.SetIsFile( IsFile );
  SharePathAddMsg.SetIsNewShare( True );
  SharePathAddMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToAll( SharePathAddMsg );
end;

class procedure MySharePathEvent.OnlineSendItem(OnlinePcID, SharePath: string;
  IsFile: Boolean);
var
  SharePathAddMsg : TSharePathAddMsg;
begin
  SharePathAddMsg := TSharePathAddMsg.Create;
  SharePathAddMsg.SetSharePath( SharePath );
  SharePathAddMsg.SetIsFile( IsFile );
  SharePathAddMsg.SetIsNewShare( False );
  SharePathAddMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( OnlinePcID, SharePathAddMsg );
end;

class procedure MySharePathEvent.RemoveItem(SharePath: string);
var
  SharePathRemoveMsg : TSharePathRemoveMsg;
begin
  SharePathRemoveMsg := TSharePathRemoveMsg.Create;
  SharePathRemoveMsg.SetSharePath( SharePath );
  SharePathRemoveMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToAll( SharePathRemoveMsg );
end;

{ MySharePathBackConnEvent }

class procedure MySharePathBackConnEvent.ConnDownBusy(DownPcID: string);
var
  ShareDownBackConnBusyMsg : TShareDownBackConnBusyMsg;
begin
  ShareDownBackConnBusyMsg := TShareDownBackConnBusyMsg.Create;
  ShareDownBackConnBusyMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DownPcID, ShareDownBackConnBusyMsg );
end;

class procedure MySharePathBackConnEvent.ConnDownError(DownPcID: string);
var
  ShareDownBackConnErrorMsg : TShareDownBackConnErrorMsg;
begin
  ShareDownBackConnErrorMsg := TShareDownBackConnErrorMsg.Create;
  ShareDownBackConnErrorMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DownPcID, ShareDownBackConnErrorMsg );
end;

end.
