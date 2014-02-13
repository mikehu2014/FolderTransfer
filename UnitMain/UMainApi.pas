unit UMainApi;

interface

type

  MyHintAppApi = class
  public
    class procedure ShowSending( FileName, Destination : string; IsFile : Boolean );
    class procedure ShowSendCompleted( FileName, Destination : string; IsFile : Boolean );
  public
    class procedure ShowReceiving( FileName, Destination : string; IsFile : Boolean );
    class procedure ShowReceiveCompelted( FileName, Destination : string; IsFile : Boolean );
  public
    class procedure ShowDownloadingShare( FileName, Destination : string; IsFile : Boolean );
    class procedure ShowDownShareCompleted( FileName, Destination : string; IsFile : Boolean );
  public
    class procedure SetShowHintTime( ShowHintTime : Integer );
    class procedure ShowSendFileBtn;
  end;

  MainFormApi = class
  public
    class procedure ShowNewReceive;
    class procedure ShowNewShare;
  end;

const
  Main_Send = '0';
  Main_Receive = '1';
  Main_Share = '2';
  Main_Settings = '3';
  Main_Help = '4';
  Main_Exit = '5';

  Help_Check4Update = '6';
  Help_Register = '7';
  Help_OnlineManual = '8';
  Help_ContactUs = '9';
  Help_BuyNow = 'a';
  Help_HomePage = 'b';
  Help_About = 'c';
  Help_BackupAndSync = 'd';

  Send_Add = 'e';
  Send_View = 'f';
  Send_View_Online = 'g';
  Send_View_Group = 'h';
  Send_View_All = 'i';
  Send_View_NetworkStatus = 'j';
  Send_NetworMode = 'k';
  Send_NetworMode_EnterLocal = 'l';
  Send_NetworMode_EnterGroup = 'm';
  Send_NetworMode_EnterConnPc = 'n';
  Send_NetworMode_SignGroup = 'o';
  Send_NetworMode_JoinGroup = 'p';
  Send_NetworMode_ConnPc = 'q';
  Send_SendAgain = 'r';
  Send_Schedule = 's';
  Send_Remove = 't';
  Send_Explorer = 'u';
  Send_ShowLog = 'v';

  SendForm_OK = 'w';
  SendForm_Next = 'x';
  SendForm_Files = 'y';
  SendForm_SendTo = 'z';
  SendForm_Schedule = '-0';
  SendForm_Advanced = '-1';
  SendForm_SelectFile = '-2';
  SendForm_SelectDes = '-3';
  SendForm_Schedule_Manual = '-4';
  SendForm_Schedule_FewMin = '-5';
  SendForm_Schedule_FewHour = '-6';
  SendForm_Schedule_Daily = '-7';
  SendForm_Schedule_Weekly = '-8';
  SendForm_Schedule_Monthly = '-9';
  SendForm_Include_File = '-a';
  SendForm_Include_Mask = '-b';
  SendForm_Include_Space = '-c';
  SendForm_Include_Delete = '-d';
  SendForm_Exclude_File = '-e';
  SendForm_Exclude_Mask = '-f';
  SendForm_Exclude_Space = '-g';
  SendForm_Exclude_Delete = '-h';

  Receive_Explorer = '-i';
  Receive_Run = '-j';
  Receive_Remove = '-k';
  Receive_Add = '-l';

  Share_Down = '-m';
  Share_Manager = '-n';
  ShareDown_Expolrer = '-o';
  ShareDown_Run = '-p';
  ShareDown_Remove = '-q';
  ShareDown_DownAgagin = '-r';
  ShareDown_ShowLogs = '-s';
  ShareDown_Hide = '+a';

  ShareForm_OK = '-t';
  ShareForm_Cancel = '-u';
  ShareForm_Close = '-v';
  ShareForm_SearchTab = '-w';
  ShareForm_FileSelect = '-x';
  ShareForm_PathBrowse = '-y';
  ShareForm_PathDown = '-z';
  ShareForm_PathEnter = '+0';
  ShareForm_Search_Enter = '+1';
  ShareForm_Search_click = '+2';
  ShareForm_Search_FileSelect = '+3';
  ShareForm_Preview = '+4';
  ShareForm_SearchPreview = '+5';

  ShareManagerForm_OK = '+6';
  ShareManagerForm_Cancel = '+7';
  ShareManagerForm_Close = '+8';
  ShareManagerForm_Select = '+9';

  JoinGroupForm_OK = '+b';
  JoinGroupForm_Cancel = '+c';
  JoinGroupForm_Close = '+d';
  JoinGroupForm_Signup = '+e';
  JoinGroupForm_NameTextEnter = '+f';
  JoinGroupForm_PasswordTextEnter = '+g';

  SignupGroupForm_OK = '+h';
  SignupGroupForm_Cancel = '+i';
  SignupGroupForm_Close = '+j';
  SignupGroupForm_NameTextEnter = '+k';
  SignupGroupForm_EmailTextEnter = '+l';
  SignupGroupForm_PasswordTextEnter = '+m';
  SignupGroupForm_Password2TextEnter = '+n';

  ConnPcForm_OK = '+o';
  ConnPcForm_Cancel = '+p';
  ConnPcForm_Close = '+q';
  ConnPcForm_IpTextEnter = '+r';
  ConnPcForm_PortTextEnter = '+s';
  ConnPcForm_MyIpTab = '+t';
  ConnPcForm_LanIpTextEnter = '+u';
  ConnPcForm_LanPortTextEnter = '+v';
  ConnPcForm_InternetIpTextEnter = '+w';
  ConnPcForm_InternetPortTextEnter = '+x';


implementation

uses UMainFormFace, USettingInfo;

{ MyHintAppApi }

class procedure MyHintAppApi.SetShowHintTime(ShowHintTime: Integer);
var
  ShowHintTimeSetFace : TShowHintTimeSetFace;
begin
  ShowHintTimeSetFace := TShowHintTimeSetFace.Create( ShowHintTime );
  ShowHintTimeSetFace.AddChange;
end;

class procedure MyHintAppApi.ShowDownloadingShare(FileName,
  Destination: string; IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowDownloadingShare then
    Exit;

//  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
//  ShowHintWriteFace.SetHintType( HintType_DownloadSharing );
//  ShowHintWriteFace.SetIsFile( IsFile );
//  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowDownShareCompleted(FileName,
  Destination: string; IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowDownloadShareCompleted then
    Exit;

//  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
//  ShowHintWriteFace.SetHintType( HintType_DownShareCompleted );
//  ShowHintWriteFace.SetIsFile( IsFile );
//  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowReceiveCompelted(FileName,
  Destination: string; IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowReceiveCompleted then
    Exit;

  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
  ShowHintWriteFace.SetHintType( HintType_ReceiveCompelted );
  ShowHintWriteFace.SetIsFile( IsFile );
  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowReceiving(FileName, Destination: string; IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowReceiving then
    Exit;

//  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
//  ShowHintWriteFace.SetHintType( HintType_Receiving );
//  ShowHintWriteFace.SetIsFile( IsFile );
//  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowSendCompleted(FileName, Destination: string;
  IsFile : Boolean );
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowSendCompleted then
    Exit;

//  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
//  ShowHintWriteFace.SetHintType( HintType_SendCompleted );
//  ShowHintWriteFace.SetIsFile( IsFile );
//  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowSendFileBtn;
var
  ShowSendFileBtnFace : TShowSendFileBtnFace;
begin
  ShowSendFileBtnFace := TShowSendFileBtnFace.Create;
  ShowSendFileBtnFace.AddChange;
end;

class procedure MyHintAppApi.ShowSending(FileName, Destination: string;
  IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowSending then
    Exit;

//  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
//  ShowHintWriteFace.SetHintType( HintType_Sending );
//  ShowHintWriteFace.SetIsFile( IsFile );
//  ShowHintWriteFace.AddChange;
end;

{ MainFormApi }

class procedure MainFormApi.ShowNewReceive;
var
  ShowNewReceiveFace : TShowNewReceiveFace;
begin
  ShowNewReceiveFace := TShowNewReceiveFace.Create;
  ShowNewReceiveFace.AddChange;
end;

class procedure MainFormApi.ShowNewShare;
var
  ShowNewShareFace : TShowNewShareFace;
begin
  ShowNewShareFace := TShowNewShareFace.Create;
  ShowNewShareFace.AddChange;
end;

end.
