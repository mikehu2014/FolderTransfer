unit UMyShareDownEventInfo;

interface

type

  ShareDownBackConnEvent = class
  public
    class procedure AddDown( SharePcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo;

{ ShareDownBackConnEvent }

class procedure ShareDownBackConnEvent.AddDown(SharePcID: string);
var
  ShareDownBackConnMsg : TShareDownBackConnMsg;
begin
  ShareDownBackConnMsg := TShareDownBackConnMsg.Create;
  ShareDownBackConnMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( SharePcID, ShareDownBackConnMsg );
end;

end.
