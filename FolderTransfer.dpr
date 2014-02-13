program FolderTransfer;



uses
  Forms,
  Windows,
  Messages,
  Dialogs,
  SysUtils,
  UFileBaseInfo in 'UnitUtil\UFileBaseInfo.pas',
  UFormUtil in 'UnitUtil\UFormUtil.pas',
  UModelUtil in 'UnitUtil\UModelUtil.pas',
  UMyUtil in 'UnitUtil\UMyUtil.pas',
  UXmlUtil in 'UnitUtil\UXmlUtil.pas',
  UFolderTransfer in 'UnitMain\UFolderTransfer.pas',
  USearchServer in 'UnitNetwork\USearchServer.pas',
  UFormBroadcast in 'UnitNetwork\UFormBroadcast.pas' {frmBroadcast},
  UNetworkControl in 'UnitNetwork\UNetworkControl.pas',
  UMyNetPcInfo in 'UnitNetwork\UMyNetPcInfo.pas',
  uLkJSON in 'UnitUtil\uLkJSON.pas',
  UNetworkFace in 'UnitNetwork\UNetworkFace.pas',
  UMyTcp in 'UnitNetwork\UMyTcp.pas',
  UMyServer in 'UnitNetwork\UMyServer.pas',
  UMyClient in 'UnitNetwork\UMyClient.pas',
  UMyMaster in 'UnitNetwork\UMyMaster.pas',
  UChangeInfo in 'UnitUtil\UChangeInfo.pas',
  uDebug in 'UnitUtil\uDebug.pas',
  UFormSetting in 'UnitMain\UFormSetting.pas' {frmSetting},
  USettingInfo in 'UnitMain\USettingInfo.pas',
  uEncrypt in 'UnitUtil\uEncrypt.pas',
  UMainFormFace in 'UnitMain\UMainFormFace.pas',
  UNetPcInfoXml in 'UnitNetwork\UNetPcInfoXml.pas',
  CnMD5 in 'UnitUtil\CnMD5.pas',
  UIconUtil in 'UnitUtil\UIconUtil.pas',
  UMyUrl in 'UnitUtil\UMyUrl.pas',
  UFormAbout in 'UnitMain\UFormAbout.pas' {frmAbout},
  UFormRegister in 'UnitRegister\UFormRegister.pas' {frmRegister},
  CRC in 'UnitUtil\CRC.pas',
  FGInt in 'UnitUtil\FGInt.pas',
  FGIntRSA in 'UnitUtil\FGIntRSA.pas',
  kg_dnc in 'UnitUtil\kg_dnc.pas',
  URegisterInfoIO in 'UnitRegister\URegisterInfoIO.pas',
  UAppEditionInfo in 'UnitMain\UAppEditionInfo.pas',
  Defence in 'UnitUtil\Defence.pas',
  uDebugLock in 'UnitUtil\uDebugLock.pas',
  UFormFreeEdition in 'UnitRegister\UFormFreeEdition.pas' {frmFreeEdition},
  UFromEnterGroup in 'UnitNetwork\UFromEnterGroup.pas' {frmJoinGroup},
  UFormConnPc in 'UnitNetwork\UFormConnPc.pas' {frmConnComputer},
  UMainForm in 'UnitMain\UMainForm.pas' {frmMainForm},
  UFormExitWarnning in 'UnitMain\UFormExitWarnning.pas' {frmExitConfirm},
  UPortMap in 'UnitNetwork\UPortMap.pas',
  UFormFileSelect in 'UnitUtil\UFormFileSelect.pas' {frmFileSelect},
  UFormSelectMask in 'UnitUtil\UFormSelectMask.pas' {FrmEnterMask},
  UFormSpaceLimit in 'UnitUtil\UFormSpaceLimit.pas' {frmSpaceLimit},
  UFmFilter in 'UnitUtil\UFmFilter.pas' {FrameFilter: TFrame},
  UFrameFilter in 'UnitUtil\UFrameFilter.pas' {FrameFilterPage: TFrame},
  UDataSetInfo in 'UnitUtil\UDataSetInfo.pas',
  UNetworkEventInfo in 'UnitNetwork\UNetworkEventInfo.pas',
  UFolderCompare in 'UnitUtil\UFolderCompare.pas',
  UMyShareDownFaceInfo in 'UnitShareDown\UMyShareDownFaceInfo.pas',
  UMyShareDownApiInfo in 'UnitShareDown\UMyShareDownApiInfo.pas',
  UMyShareDOwnDataInfo in 'UnitShareDown\UMyShareDOwnDataInfo.pas',
  UMyShareDownXmlInfo in 'UnitShareDown\UMyShareDownXmlInfo.pas',
  UFormSelectShareDown in 'UnitShareDown\UFormSelectShareDown.pas' {frmSelectRestore},
  UShareDownThread in 'UnitShareDown\UShareDownThread.pas',
  UFormShareDownExplorer in 'UnitShareDown\UFormShareDownExplorer.pas' {frmRestoreExplorer},
  UMyShareDataInfo in 'UnitShare\UMyShareDataInfo.pas',
  UMyShareXmlInfo in 'UnitShare\UMyShareXmlInfo.pas',
  UMyShareFaceInfo in 'UnitShare\UMyShareFaceInfo.pas',
  UMyShareApiInfo in 'UnitShare\UMyShareApiInfo.pas',
  UMyShareEventInfo in 'UnitShare\UMyShareEventInfo.pas',
  UFormLocalSelect in 'UnitMain\UFormLocalSelect.pas' {FrmLocalSelect},
  UShareThread in 'UnitShare\UShareThread.pas',
  UAutoSendThread in 'UnitFileSend\UAutoSendThread.pas',
  USendThread in 'UnitFileSend\USendThread.pas',
  UFormSendLog in 'UnitFileSend\UFormSendLog.pas' {frmSendLog},
  UFrmSelectSendItem in 'UnitFileSend\UFrmSelectSendItem.pas' {frmSelectSendItem},
  UMySendApiInfo in 'UnitFileSend\UMySendApiInfo.pas',
  UMySendDataInfo in 'UnitFileSend\UMySendDataInfo.pas',
  UMySendEventInfo in 'UnitFileSend\UMySendEventInfo.pas',
  UMySendFaceInfo in 'UnitFileSend\UMySendFaceInfo.pas',
  UMySendXmlInfo in 'UnitFileSend\UMySendXmlInfo.pas',
  UReceiveThread in 'UnitFileReceive\UReceiveThread.pas',
  UMyReceiveApiInfo in 'UnitFileReceive\UMyReceiveApiInfo.pas',
  UMyReceiveDataInfo in 'UnitFileReceive\UMyReceiveDataInfo.pas',
  UMyReceiveEventInfo in 'UnitFileReceive\UMyReceiveEventInfo.pas',
  UMyReceiveFaceInfo in 'UnitFileReceive\UMyReceiveFaceInfo.pas',
  UMyReceiveXmlInfo in 'UnitFileReceive\UMyReceiveXmlInfo.pas',
  UMyRegisterApiInfo in 'UnitRegister\UMyRegisterApiInfo.pas',
  UMyRegisterDataInfo in 'UnitRegister\UMyRegisterDataInfo.pas',
  UMyRegisterXmlInfo in 'UnitRegister\UMyRegisterXmlInfo.pas',
  UMyRegisterFaceInfo in 'UnitRegister\UMyRegisterFaceInfo.pas',
  UMyRegisterEventInfo in 'UnitRegister\UMyRegisterEventInfo.pas',
  URegisterThread in 'UnitRegister\URegisterThread.pas',
  UAutoShareDownThread in 'UnitShareDown\UAutoShareDownThread.pas',
  UMyShareDownEventInfo in 'UnitShareDown\UMyShareDownEventInfo.pas',
  UNetworkStatus in 'UnitNetwork\UNetworkStatus.pas' {frmNeworkStatus},
  UMainFormThread in 'UnitMain\UMainFormThread.pas',
  UFormHint in 'UnitMain\UFormHint.pas' {frmHint},
  UMainApi in 'UnitMain\UMainApi.pas',
  UMyDebug in 'UnitMain\UMyDebug.pas',
  UFormBackupSpeedLimit in 'UnitFileSend\UFormBackupSpeedLimit.pas' {frmBackupSpeedLimit},
  UFormRestoreSpeedLimit in 'UnitShareDown\UFormRestoreSpeedLimit.pas' {frmRestoreSpeedLimit},
  UMyTimerThread in 'UnitMain\UMyTimerThread.pas',
  UDebugForm in 'UnitMain\UDebugForm.pas' {frmDebug},
  UFormPreview in 'UnitShareDown\UFormPreview.pas' {frmPreView},
  VersionInfo in 'UnitUtil\VersionInfo.pas',
  mp3_id3v1 in 'UnitUtil\mp3_id3v1.pas',
  TWmaTag in 'UnitUtil\TWmaTag.pas',
  UFormFreeTips in 'UnitRegister\UFormFreeTips.pas' {frmFreeTips},
  UFormEnerpriseTips in 'UnitRegister\UFormEnerpriseTips.pas' {frmEnterpriseTips},
  RAR in 'UnitUtil\RAR.pas',
  RAR_DLL in 'UnitUtil\RAR_DLL.pas',
  UFormSendPcFilter in 'UnitFileSend\UFormSendPcFilter.pas' {frmSendPcFilter},
  UFormEditionNotMatch in 'UnitNetwork\UFormEditionNotMatch.pas' {frmEditonNotMatch},
  UFormShareDownLog in 'UnitShareDown\UFormShareDownLog.pas' {frmShareDownLog},
  UFormUnstall in 'UnitMain\UFormUnstall.pas' {frmUnstall},
  UFormShare in 'UnitShare\UFormShare.pas' {frmSelectShare},
  UJobSettings in 'UnitFileSend\UJobSettings.pas' {frmJobSetting};

{$R *.res}

var
  myhandle : hwnd;
  ParamsStr : string;

{$R *.res}
begin
    // 设置防火墙
  MyFireWall.MakeThrough;

    // 参数信息
  ParamsStr := '';
  if ParamCount > 0 then
    ParamsStr := ParamStr( ParamCount );

    // 运行程序目的是通过管理员执行代码
  if MyAppAdminRunasUtil.getIsRunAsAdmin( ParamsStr ) then
    Exit
  else   // 卸载软件
  if ParamsStr = AppRunParams_RemoveApp then
  begin
      // 填写卸载信息
    frmUnstall := TfrmUnstall.Create(nil);
    frmUnstall.WaitUserRequest;
    frmUnstall.Free;
    Exit;
  end;

    // 防止多个 BackupCow 同时运行
  myhandle := findwindow( AppName_FolderTransfer, nil );
  if myhandle > 0 then  // 窗口在同一个 用户 ID 已经运行, 恢复之前的窗口
  begin
    postmessage( myhandle,hfck,0,0 );
    Exit;
  end
  else    // 存在相同的程序, 但不同 用户 ID, 结束程序
  if MyAppRun.getAppCount > 1 then
  begin
    if ParamsStr <> AppRunParams_Hide then // 隐藏则不显示
      MyMessageBox.ShowWarnning( 'Application is running' );
    Exit;
  end;

    // 是否以 隐藏方式 运行程序
  if ParamsStr = AppRunParams_Hide then
    Application.ShowMainForm := False;

  try
    ReportMemoryLeaksOnShutdown := DebugHook<>0;
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmJoinGroup, frmJoinGroup);
  Application.CreateForm(TfrmConnComputer, frmConnComputer);
  Application.CreateForm(TfrmExitConfirm, frmExitConfirm);
  Application.CreateForm(TfrmFileSelect, frmFileSelect);
  Application.CreateForm(TFrmEnterMask, FrmEnterMask);
  Application.CreateForm(TfrmSpaceLimit, frmSpaceLimit);
  Application.CreateForm(TfrmSelectSendItem, frmSelectSendItem);
  Application.CreateForm(TfrmSelectRestore, frmSelectRestore);
  Application.CreateForm(TfrmRestoreExplorer, frmRestoreExplorer);
  Application.CreateForm(TFrmLocalSelect, FrmLocalSelect);
  Application.CreateForm(TfrmSendLog, frmSendLog);
  Application.CreateForm(TfrmSelectSendItem, frmSelectSendItem);
  Application.CreateForm(TfrmNeworkStatus, frmNeworkStatus);
  Application.CreateForm(TfrmSetting, frmSetting);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmFreeEdition, frmFreeEdition);
  Application.CreateForm(TfrmRegister, frmRegister);
  Application.CreateForm(TfrmHint, frmHint);
  Application.CreateForm(TfrmBackupSpeedLimit, frmBackupSpeedLimit);
  Application.CreateForm(TfrmRestoreSpeedLimit, frmRestoreSpeedLimit);
  Application.CreateForm(TfrmDebug, frmDebug);
  Application.CreateForm(TfrmPreView, frmPreView);
  Application.CreateForm(TfrmFreeTips, frmFreeTips);
  Application.CreateForm(TfrmEnterpriseTips, frmEnterpriseTips);
  Application.CreateForm(TfrmSendPcFilter, frmSendPcFilter);
  Application.CreateForm(TfrmEditonNotMatch, frmEditonNotMatch);
  Application.CreateForm(TfrmShareDownLog, frmShareDownLog);
  Application.CreateForm(TfrmUnstall, frmUnstall);
  Application.CreateForm(TfrmSelectShare, frmSelectShare);
  Application.CreateForm(TfrmJobSetting, frmJobSetting);
  frmMainForm.CreateFolderTransfer;
    Application.Run;
  except
  end;
end.
