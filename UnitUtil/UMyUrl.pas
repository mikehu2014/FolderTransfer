unit UMyUrl;

interface

//const
//  Url_Home = 'http://127.0.0.1:2456/WebSite/';
//  Url_Register = Url_Home;

//  Url_Home = 'http://www.backupcow.com/';
//  Url_Register = Url_Home + 'register/';
//  Url_Download = Url_Home + 'Download/';
//
//  Url_GetIp = Url_Register + 'ip/default.aspx?act=getip';
//  Url_GetTrialKey = Url_Register + 'Activate/GetTrialKey.aspx';
//  Url_GetPayLicenseKey = Url_Register + 'Activate/GetPayKey.aspx';
//  Url_GetBatPayLicenseKey = Url_Register + 'Activate/GetBatPayKey.aspx';
//
//  Url_GetCompanyList = Url_Register + 'company/GetCompanyList.aspx';
//  Url_RemoteRegister = Url_Home + 'remotegroup.aspx';
//  Url_ForgetPassword = Url_Home + 'ForgetPassword.aspx';
//  Url_RemoteInstruction = Url_Home + 'Instruction.aspx';
//
//  Url_Contact = Url_Home + 'ContactUs.asp';
//  Url_BuyNow = Url_Home + 'BuyNow.asp';
//  Url_OnlineManual = Url_Home + 'support.asp';
//
//  Url_AppUpgrade = Url_Download + 'BackupCowUpgrade.inf';
//  Url_AppUpgrade_Private = Url_Download + 'BackupCowUpgrade_Private.inf';

type

  MyUrl = class
  public
    class function getHome : string;
    class function getRegister : string;
    class function getDownload : string;
    class function getRarDllPath : string;
  public
    class function getIp : string;
    class function getTrialKey : string;
    class function getBatPayKey : string;
  public
    class function getGroupPcList : string;
    class function GroupSignup : string;
    class function GroupSignupHandle : string;
    class function GroupForgetPassword : string;
    class function GroupInstruction : string;
  public
    class function ContactUs : string;
    class function BuyNow : string;
    class function OnlineManual : string;
  public
    class function getAppUpgrade : string;
    class function getAppUpgradePrite : string;
    class function getAppRunMark : string;
    class function getAppUninstallMark : string;
    class function getAppSuggestiionMark : string;
  public
    class function getAdsRunMark : string;
    class function getDebug : string;
  end;

  MyOtherWebUrl = class
  public
    class function getBackupCow : string;
    class function getC4s : string;
    class function getDuplicateFilter : string;
    class function getKeywordCompeting : string;
    class function getTextFinding : string;
  end;

const
  Url_FolderTranferHome = 'http://www.foldertransfer.com/';
  Url_Register = 'register/';


//  Url_FolderTranferHome = 'http://localhost:4092/FolderTransfer/';
//  Url_Register = '';


var
  Url_AppHomePage : string = Url_FolderTranferHome;

implementation

{ MyUrl }

class function MyUrl.getHome: string;
begin
  Result := Url_AppHomePage;
end;

class function MyUrl.getIp: string;
begin
  Result := getRegister + 'ip/default.aspx?act=getip';
end;

class function MyUrl.getRarDllPath: string;
begin
  Result := getDownload + 'unrar.dll';
end;

class function MyUrl.getRegister: string;
begin
  Result := getHome + Url_Register;
end;

class function MyUrl.BuyNow: string;
begin
  Result := getHome + 'BuyNow.asp';
end;

class function MyUrl.ContactUs: string;
begin
  Result := getHome + 'ContactUs.asp';
end;

class function MyUrl.getAdsRunMark: string;
begin
  Result := getRegister + 'Ads/AdsMark.aspx';
end;

class function MyUrl.getAppRunMark: string;
begin
  Result := getRegister + 'AppRunMark.aspx';
end;

class function MyUrl.getAppSuggestiionMark: string;
begin
  Result := getRegister + 'SuggestionMark.aspx';
end;

class function MyUrl.getAppUninstallMark: string;
begin
  Result := getRegister + 'AppUninstallMark.aspx';
end;

class function MyUrl.getAppUpgrade: string;
begin
  Result := getDownload + 'BackupCowUpgrade.inf';
end;

class function MyUrl.getAppUpgradePrite: string;
begin
  Result := getDownload + 'BackupCowUpgrade_Private.inf';
end;

class function MyUrl.getBatPayKey: string;
begin
  Result := getRegister + 'Activate/GetBatPayKey.aspx';
end;

class function MyUrl.getTrialKey: string;
begin
  Result := getRegister + 'Activate/GetTrialKey.aspx';
end;

class function MyUrl.GroupForgetPassword: string;
begin
  Result := getHome + 'ForgetPassword.aspx';
end;

class function MyUrl.GroupInstruction: string;
begin
  Result := getHome + 'Instruction.aspx';
end;

class function MyUrl.GroupSignup: string;
begin
  Result := getHome + 'remotegroup.aspx';
end;

class function MyUrl.GroupSignupHandle: string;
begin
  Result := getHome + 'RemoteGroupSignup.aspx';
end;

class function MyUrl.OnlineManual: string;
begin
  Result := getHome + 'support.asp';
end;

class function MyUrl.getDebug: string;
begin
  Result := getRegister + 'ErrorLogAdd.aspx';
end;

class function MyUrl.getDownload: string;
begin
  Result := getHome + 'Download/';
end;

class function MyUrl.getGroupPcList: string;
begin
  Result := getRegister + 'company/GetCompanyList.aspx';
end;

{ MyOtherWebUrl }

class function MyOtherWebUrl.getBackupCow: string;
begin
  Result := 'http://www.backupcow.com/';
end;

class function MyOtherWebUrl.getC4s: string;
begin
  Result := 'http://www.chat4support.com/';
end;

class function MyOtherWebUrl.getDuplicateFilter: string;
begin
  Result := 'http://www.duplicatefilter.com/';
end;

class function MyOtherWebUrl.getKeywordCompeting: string;
begin
  Result := 'http://www.keywordcompeting.com/';
end;

class function MyOtherWebUrl.getTextFinding: string;
begin
  Result := 'http://www.textfinding.com/';
end;

end.
