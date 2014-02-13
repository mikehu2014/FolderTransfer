unit UMySendDataInfo;

interface

uses UFileBaseInfo, Generics.Collections, UDataSetInfo, UMyUtil, DateUtils, classes, SysUtils;

type

{$Region ' ���ݽṹ ' }

    // ������Ϣ
  TSendContinusInfo = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
  end;
  TSendContinusList = class( TObjectList< TSendContinusInfo > )end;

      // ���ݽṹ
  TSendLogInfo = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;
  TSendLogList = class( TObjectList< TSendLogInfo > )end;

    // ����� Log
  TSendCompletedLogInfo = class( TSendLogInfo )
  public
    SendTime : TDateTime;
  public
    procedure SetSendTime( _SendTime : TDateTime );
  end;
  TSendCompletedLogList = class( TObjectList< TSendCompletedLogInfo > )end;

      // δ��� Log
  TSendIncompletedLogInfo = class( TSendLogInfo )end;
  TSendIncompletedLogList = class( TObjectList< TSendIncompletedLogInfo > )end;



    // ���� Item ��Ϣ
  TSendItemInfo = class
  public  // ·����Ϣ
    SourcePath : string;
    IsFile : Boolean;
    IsCompleted, IsLostConn : Boolean; // �Ƿ�����ɣ��Ƿ�Ͽ�����
    IsSending, IsZip : Boolean; // �Ƿ����ڷ��ͣ� �Ƿ�ѹ���ļ�
    ZipPath : string;
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public  // ��ʱ����
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
    LastSendTime, NextSendTime : TDateTime;
  public  // ������
    IncludeFilterList : TFileFilterList;  // �����ļ� ������
    ExcludeFilterList : TFileFilterList;  // �ų��ļ� ������
  public  // ������Ϣ
    SendContinusList : TSendContinusList;
  public
    SendCompletedLogList : TSendCompletedLogList;  // ���������־�б�
    SendIncompletedLogList : TSendIncompletedLogList;  // ����ʧ����־�б�
  public
    constructor Create( _SourcePath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure SetZipInfo( _IsZip : Boolean; _ZipPath : string );
    procedure SetScheduleInfo( _ScheduleType, _ScheduleValue1, _ScheduleValue2 : Integer );
    procedure SetLastSendTime( _LastSendTime : TDateTime );
    destructor Destroy; override;
  end;
  TSendItemList = class( TObjectList<TSendItemInfo> )end;

    // ���ط���
  TLocalSendItemInfo = class( TSendItemInfo )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  end;

    // ���緢��
  TNetworkSendItemInfo = class( TSendItemInfo )
  public
    IsAddToReceive : Boolean; // �Ƿ���Ҫ��ӽ��շ�
    IsRemoveToReceive : Boolean;  // �Ƿ���Ҫɾ�����շ�
    IsDesBusy : Boolean; // Ŀ���Ƿ�æ
  public
    IsReceiveCancel : Boolean; // �Ƿ���շ��Ѿ�ȡ��
  public
    procedure SetReceiveInfo( _IsAddToReceive, _IsRemoveToReceive : Boolean );
    procedure SetIsReceiveCancel( _IsReceiveCancel : Boolean );
  end;

    // Ŀ�� Item
  TSendRootItemInfo = class
  public
    SendRootItemID : string;
    SendItemList : TSendItemList;
  public
    constructor Create( _SendRootItemID : string );
    destructor Destroy; override;
  end;
  TSendRootItemList = class( TObjectList<TSendRootItemInfo> )end;

    // ����Ŀ�� Item
  TLocalSendRootItemInfo = class( TSendRootItemInfo )
  end;

    // ����Ŀ�� Item
  TNetworkSendRootItemInfo = class( TSendRootItemInfo )
  end;

      // �����ٶ���Ϣ
  TSendSpeedInfo = class
  public
    IsLimit : Boolean;
    LimitValue : Integer;
    LimitType : Integer;
  public
    constructor Create;
  end;

    // �����ļ���ʷ��Ϣ
  TSendFileHistoryInfo = class
  public
    SendPathList : TStringList;
  public
    constructor Create;
    procedure AddPath( NewSendPathList : TStringList );
    destructor Destroy; override;
  end;
  TSendFileHistoryList = class( TObjectList< TSendFileHistoryInfo > )end;

    // ����Ŀ����ʷ
  TSendDesHistoryInfo = class
  public
    SendDesList : TStringList;
  public
    constructor Create;
    procedure AddPath( NewSendDesList : TStringList );
    destructor Destroy; override;
  end;
  TSendDesHistoryList = class( TObjectList< TSendDesHistoryInfo > )end;

    // ������Ϣ
  TMySendInfo = class( TMyDataInfo )
  public
    DesItemList : TSendRootItemList;
    BackupLogList : TSendLogList;
    SendSpeedInfo : TSendSpeedInfo;
  public
    SendFileHistoryList : TSendFileHistoryList;
    SendDesHistoryList : TSendDesHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TSendRootItemListAccessInfo = class
  protected
    DesItemList : TSendRootItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TSendRootItemAccessInfo = class( TSendRootItemListAccessInfo )
  public
    DesItemID : string;
  protected
    DesItemIndex : Integer;
    DesItemInfo : TSendRootItemInfo;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindDesItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TSendItemListAccessInfo = class( TSendRootItemAccessInfo )
  protected
    BackupItemList : TSendItemList;
  protected
    function FindBackupItemList : Boolean;
  end;

    // ���� ���ݽӿ�
  TSendItemAccessInfo = class( TSendItemListAccessInfo )
  public
    BackupPath : string;
  protected
    BackupItemIndex : Integer;
    BackupItemInfo : TSendItemInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TSendContinusListAccessInfo = class( TSendItemAccessInfo )
  protected
    BackupContinusList : TSendContinusList;
  protected
    function FindBackupContinusList : Boolean;
  end;

    // ���� ���ݽӿ�
  TSendContinusAccessInfo = class( TSendContinusListAccessInfo )
  public
    FilePath : string;
  protected
    BackupContinusIndex : Integer;
    BackupContinusInfo : TSendContinusInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupContinusInfo: Boolean;
  end;

     // ���� ���� List �ӿ�
  TSendCompletedLogListAccessInfo = class( TSendItemAccessInfo )
  protected
    SendCompletedLogList : TSendCompletedLogList;
  protected
    function FindSendCompletedLogList : Boolean;
  end;

     // ���� ���� List �ӿ�
  TSendIncompletedLogListAccessInfo = class( TSendItemAccessInfo )
  protected
    SendIncompletedLogList : TSendIncompletedLogList;
  protected
    function FindSendIncompletedLogList : Boolean;
  end;

    // ���� ���� List �ӿ�
  TSendLogListAccessInfo = class
  protected
    BackupLogList : TSendLogList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���� List �ӿ�
  TSendFileHistoryListAccessInfo = class
  protected
    SendFileHistoryList : TSendFileHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���� List �ӿ�
  TSendDesHistoryListAccessInfo = class
  protected
    SendDesHistoryList : TSendDesHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

      // �����ٶ� ���ݽӿ�
  TSendSpeedAccessInfo = class
  public
    SendSpeedInfo : TSendSpeedInfo;
  public
    constructor Create;
  end;

{$EndRegion}

{$Region ' Ŀ����Ϣ �����޸� ' }

    // ���
  TSendRootItemAddInfo = class( TSendRootItemAccessInfo )
  public
    procedure Update;
  protected
    procedure CreateItemInfo;virtual;abstract;
  end;

    // ��� ����Ŀ��
  TSendRootItemAddLocalInfo = class( TSendRootItemAddInfo )
  protected
    procedure CreateItemInfo;override;
  end;

    // ��� ����Ŀ��
  TSendRootItemAddNetworkInfo = class( TSendRootItemAddInfo )
  protected
    procedure CreateItemInfo;override;
  end;

    // ɾ��
  TSendRootItemRemoveInfo = class( TSendRootItemAccessInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ������Ϣ �����޸� ' }

    // �޸ĸ���
  TSendItemWriteInfo = class( TSendItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ·����ɾ ' }

    // ���
  TSendItemAddInfo = class( TSendItemWriteInfo )
  public
    IsFile : boolean;
    IsCompleted, IsZip : boolean;
    ZipPath : string;
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public  // ��ʱ����
    ScheduleType : Integer;
    ScheduleValue1, ScheduleValue2 : Integer;
    LastSendTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure SetZipInfo( _IsZip : boolean; _ZipPath : string );
    procedure SetScheduleInfo( _ScheduleType, _ScheduleValue1, _ScheduleValue2 : Integer );
    procedure SetLastSendTime( _LastSendTime : TDateTime );
    procedure Update;
  protected
    procedure CreateSendItem;virtual;abstract;
  end;

    // ��� Local Item
  TSendItemAddLocalInfo = class( TSendItemAddInfo )
  public
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
  protected
    procedure CreateSendItem;override;
  end;

    // ��� Network Item
  TSendItemAddNetworkInfo = class( TSendItemAddInfo )
  public
    IsAddToReceive : Boolean; // �Ƿ���Ҫ��ӽ��շ�
    IsRemoveToReceive : Boolean;  // �Ƿ���Ҫɾ�����շ�
  public
    IsReceiveCancel : Boolean;
  public
    procedure SetReceiveInfo( _IsAddToReceive, _IsRemoveToReceive : Boolean );
    procedure SetIsReceiveCancel( _IsReceiveCancel : Boolean );
  protected
    procedure CreateSendItem;override;
  end;

    // ɾ��
  TSendItemRemoveInfo = class( TSendItemAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

      // �޸�
  TSendItemSetIsCompletedInfo = class( TSendItemWriteInfo )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  end;

        // �޸�
  TSendItemSetIsLostConnInfo = class( TSendItemWriteInfo )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  end;


      // �޸�
  TSendItemSetIsBackupingInfo = class( TSendItemWriteInfo )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
    procedure Update;
  end;

    // �޸�
  TSendItemSetIsAddToReceiveInfo = class( TSendItemWriteInfo )
  public
    IsAddToReceive : boolean;
  public
    procedure SetIsAddToReceive( _IsAddToReceive : boolean );
    procedure Update;
  end;

    // �޸�
  TSendItemSetIsRemoveToReceiveInfo = class( TSendItemWriteInfo )
  public
    IsRemoveToReceive : boolean;
  public
    procedure SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
    procedure Update;
  end;

    // �޸�
  TSendItemSetIsReceiveCancelInfo = class( TSendItemWriteInfo )
  public
    IsReceiveCancel : boolean;
  public
    procedure SetIsReceiveCancel( _IsReceiveCancel : boolean );
    procedure Update;
  end;

    // �޸�
  TSendItemSetIsDesBusyInfo = class( TSendItemWriteInfo )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ŀռ� ' }

    // ���� �ռ���Ϣ
  TSendItemSetSpaceInfoInfo = class( TSendItemAccessInfo )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  end;


    // ��� �������Ϣ
  TSendItemSetAddCompletedSpaceInfo = class( TSendItemAccessInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ķ�ʱ���� ' }

    // ��� �������Ϣ
  TSendItemSetLastSendTimeInfo = class( TSendItemWriteInfo )
  public
    LastSendTime : TDateTime;
  public
    procedure SetLastSendTime( _LastSendTime : TDateTime );
    procedure Update;
  end;

    // ���� ͬ������
  TSendItemSetScheduleInfo = class( TSendItemWriteInfo )
  private
    SchduleType : Integer;
    SchduleValue1, SchduleValue2 : Integer;
  public
    procedure SetSchduleType( _SchduleType : Integer );
    procedure SetSchduleValue( _SchduleValue1, _SchduleValue2 : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ������Ϣ ' }

    // ��� ����
  TSendItemFilterAddInfo = class( TSendItemAccessInfo )
  public
    FilterType, FilterValue : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterValue : string );
  end;

    // ���
  TSendItemIncludeFilterClearInfo = class( TSendItemAccessInfo )
  public
    procedure Update;
  end;

    // ���
  TSendItemIncludeFilterAddInfo = class( TSendItemFilterAddInfo )
  public
    procedure Update;
  end;

    // ���
  TSendItemExcludeFilterClearInfo = class( TSendItemAccessInfo )
  public
    procedure Update;
  end;

    // ���
  TSendItemExcludeFilterAddInfo = class( TSendItemFilterAddInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ������Ϣ ' }

      // �޸ĸ���
  TSendContinusWriteInfo = class( TSendContinusAccessInfo )
  end;

      // ���
  TSendContinusAddInfo = class( TSendContinusWriteInfo )
  public
    FileTime : TDateTime;
    FileSize, Position : int64;
  public
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetSpaceInfo( _FileSize, _Position : int64 );
    procedure Update;
  end;

    // ɾ��
  TSendContinusRemoveInfo = class( TSendContinusWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ��־��Ϣ ' }

    // ��� �ɹ����ݵ�log
  TSendAddCompletedLogInfo = class( TSendCompletedLogListAccessInfo )
  public
    FilePath : string;
    SendTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSendTime( _SendTime : TDateTime );
    procedure Update;
  end;

    // ���
  TSendClearCompletedLogInfo = class( TSendCompletedLogListAccessInfo )
  public
    procedure Update;
  end;


    // ��� ����ʧ�ܵ�log
  TSendAddIncompletedLogInfo = class( TSendIncompletedLogListAccessInfo )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure Update;
  end;

    // ���δ��ɵ�
  TSendClearIncompletedLogInfo = class( TSendIncompletedLogListAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �ٶ���Ϣ �����޸� ' }

    // �ٶ�����
  TSendSpeedLimitInfo = class( TSendSpeedAccessInfo )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitValue, _LimitType : Integer );
    procedure Update;
  end;

{$EndRegion}


{$Region ' �����ļ���ʷ �����޸� ' }

    // ���
  TSendFileHistoryAddInfo = class( TSendFileHistoryListAccessInfo )
  public
    SendPathList : TStringList;
  public
    constructor Create( _SendPathList : TStringList );
    procedure Update;
    destructor Destroy; override;
  end;

    // ɾ��
  TSendFileHistoryRemoveInfo = class( TSendFileHistoryListAccessInfo )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  end;

    // ���
  TSendFileHistoryClearInfo = class( TSendFileHistoryListAccessInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ����Ŀ����ʷ �����޸� ' }

    // ���
  TSendDesHistoryAddInfo = class( TSendDesHistoryListAccessInfo )
  public
    SendDesList : TStringList;
  public
    constructor Create( _SendDesList : TStringList );
    procedure Update;
    destructor Destroy; override;
  end;

    // ɾ��
  TSendDesHistoryRemoveInfo = class( TSendDesHistoryListAccessInfo )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  end;

    // ���
  TSendDesHistoryClearInfo = class( TSendDesHistoryListAccessInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Ŀ����Ϣ ���ݶ�ȡ ' }


    // ��ȡ ����Ŀ���б�
  TSendItemListReadLocalList = class( TSendRootItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ����Ŀ���б�
  TSendItemListReadNetworkList = class( TSendRootItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���б���·��
  TSendItemReadBackupList = class( TSendItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡĿ�귱æ��Item
  TSendItemReadDesBusyList = class( TSendItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡĿ��Ͽ����ӵ�Item
  TSendItemReadLostConnList = class( TSendItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡĿ��Ͽ����ӵ�Item
  TSendItemReadOnTimeList = class( TSendItemListAccessInfo )
  public
    function get : TStringList;
  end;


    // ��ȡδ��ɵ�Item
  TSendItemReadIncompletedList = class( TSendItemListAccessInfo )
  public
    function get : TStringList;
  end;

      // Ŀ����Ϣ ��ȡ
  SendRootItemInfoReadUtil = class
  public
    class function ReadLocaDesList : TStringList;
    class function ReadNetworkDesList : TStringList;
  public
    class function ReadBackupList( DesItemID : string ): TStringList;  // ��ȡ ���б���·��
    class function ReadDesBusyList( DesItemID : string ): TStringList; // ��ȡ��æ·��
    class function ReadLostConnList( DesItemID : string ): TStringList; // ��ȡ�Ͽ�����·��
    class function ReadIncompletedList( DesItemID : string ): TStringList; // ��ȡδ���·��
    class function ReadOnTimeSendList( DesItemID : string ): TStringList;  // ��ʱ�����б�
  end;

{$EndRegion}

{$Region ' ������Ϣ ���ݶ�ȡ ' }

    // ��ȡ �Ƿ���� BackupItem
  TSendItemReadExistChild = class( TSendRootItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ� ����
  TSendItemReadIsExist = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;


    // ��ȡ �Ƿ��Ѿ��ռ����
  TSendItemReadIsCompletedSpace = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ��Ѿ�״̬���
  TSendItemReadIsCompleted = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

      // ��ȡ �Ƿ��Ѿ�״̬���
  TSendItemReadIsLostConn = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ڷ���
  TSendItemReadIsBackuping = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ڷ���
  TSendItemReadIsAddToReceive = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ڷ���
  TSendItemReadIsRemoveToReceive = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ڷ���
  TSendItemReadIsReceiveCancel = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ļ�
  TSendItemReadIsFile = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ����ڷ���
  TSendItemReadLocalSavePath = class( TSendItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ �Ƿ�ѹ������
  TSendItemReadIsZip = class( TSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ�ѹ��·��
  TSendItemReadZipPath = class( TSendItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ ����������
  TSendItemReadIncludeFilter = class( TSendItemAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ �ų�������
  TSendItemReadExcludeFilter = class( TSendItemAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ ������Ϣ
  TSendItemReadContinusList = class( TSendItemAccessInfo )
  public
    function get : TSendContinusList;
  end;

    // ��ȡ ������Ϣ
  TBackupItemReadCompletedLogList = class( TSendCompletedLogListAccessInfo )
  public
    function get : TSendCompletedLogList;
  end;

    // ��ȡ ������Ϣ
  TBackupItemReadIncompletedLogList = class( TSendIncompletedLogListAccessInfo )
  public
    function get : TSendIncompletedLogList;
  end;

    // ���߷�����Ϣ
  TOnlineSendInfo = class
  public
    SendRootItemID, SourcePath : string;
  public
    constructor Create( _SendRootItemID, _SourcePath : string );
  end;
  TOnlineSendList = class( TObjectList< TOnlineSendInfo > )end;

    // Pc ���߷����ļ�
  TNetworkOnlineSendInfo = class( TOnlineSendInfo )
  public
    IsAddToReceive, IsRemoveToReceive : Boolean;
  public
    procedure SetReceiveInfo( _IsAddToReceive, _IsRemoveToReceive : Boolean );
  end;
  TNetworkOnlineSendList = class( TObjectList< TNetworkOnlineSendInfo > )end;

    // ��ȡ ����δ��ɱ���
  TSendItemReadLocalOnlineInfo = class( TSendRootItemListAccessInfo )
  public
    function get : TOnlineSendList;
  end;

    // ��ȡ Pcδ��ɱ���
  TSendItemReadPcOnlineInfo = class( TSendRootItemListAccessInfo )
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    function get : TNetworkOnlineSendList;
  end;

    // ������Ϣ ��ȡ
  SendItemInfoReadUtil = class
  public
    class function ReadIsEnable( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsCompletedSpace( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsCompleted( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsLostConn( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsBackuping( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsAddToReceive( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsRemoveToReceive( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsReceiveCancel( DesItemID, BackupPath : string ): Boolean;
    class function ReadExistSend( DesItemID : string ): Boolean;
    class function ReadLocalSavePath( DesItemID, BackupPath : string ): string;
    class function ReadIsFile( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsZip( DesItemID, BackupPath : string ): Boolean;
    class function ReadZipPath( DesItemID, BackupPath : string ): string;
  public
    class function ReadLocalOnline : TOnlineSendList;
    class function ReadPcOnline( OnlinePcID : string ) : TNetworkOnlineSendList;
  public
    class function ReadIncludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
    class function ReadExcludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
  public
    class function ReadContinuesList( DesItemID, BackupPath : string ): TSendContinusList;
  public
    class function ReadCompletedLogList( DesItemID, BackupPath : string ): TSendCompletedLogList;
    class function ReadIncompletedLogList( DesItemID, BackupPath : string ): TSendIncompletedLogList;
  end;


{$EndRegion}

{$Region ' �����ļ���ʷ ���ݶ�ȡ ' }

  TSendFileHistoryReadExistIndex = class( TSendFileHistoryListAccessInfo )
  public
    SendPathList : TStringList;
  public
    procedure SetSendPathList( _SendPathList : TStringList );
    function get : Integer;
  end;

  TSendFileHistoryReadCount = class( TSendFileHistoryListAccessInfo )
  public
    function get : Integer;
  end;

  TSendFileHistoryReadList = class( TSendFileHistoryListAccessInfo )
  public
    HistoryIndex : Integer;
  public
    procedure SetHistoryIndex( _HistoryIndex : Integer );
    function get : TStringList;
  end;

  SendFileHistoryInfoReadUtil = class
  public
    class function ReadExistIndex( SendPathList : TStringList ): Integer;
    class function ReadPathList( HistoryIndex : Integer ): TStringList;
    class function ReadHistoryCount : Integer;
  end;

{$EndRegion}

{$Region ' �����ļ���ʷ ���ݶ�ȡ ' }

  TSendDesHistoryReadExistIndex = class( TSendDesHistoryListAccessInfo )
  public
    SendDesList : TStringList;
  public
    procedure SetSendPathList( _SendDesList : TStringList );
    function get : Integer;
  end;

  TSendDesHistoryReadCount = class( TSendDesHistoryListAccessInfo )
  public
    function get : Integer;
  end;

  TSendDesHistoryReadList = class( TSendDesHistoryListAccessInfo )
  public
    HistoryIndex : Integer;
  public
    procedure SetHistoryIndex( _HistoryIndex : Integer );
    function get : TStringList;
  end;

  SendDesHistoryInfoReadUtil = class
  public
    class function ReadExistIndex( SendPathList : TStringList ): Integer;
    class function ReadPathList( HistoryIndex : Integer ): TStringList;
    class function ReadHistoryCount : Integer;
  end;

{$EndRegion}

var
  MySendInfo : TMySendInfo;

implementation

{ TMyBackupInfo }

constructor TMySendInfo.Create;
begin
  inherited;
  DesItemList := TSendRootItemList.Create;
  BackupLogList := TSendLogList.Create;
  SendSpeedInfo := TSendSpeedInfo.Create;
  SendFileHistoryList := TSendFileHistoryList.Create;
  SendDesHistoryList := TSendDesHistoryList.Create;
end;

destructor TMySendInfo.Destroy;
begin
  SendDesHistoryList.Free;
  SendFileHistoryList.Free;
  SendSpeedInfo.Free;
  BackupLogList.Free;
  DesItemList.Free;
  inherited;
end;

{ TBackupItemInfo }

constructor TSendItemInfo.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
  IncludeFilterList := TFileFilterList.Create;
  ExcludeFilterList := TFileFilterList.Create;
  SendContinusList := TSendContinusList.Create;
  SendCompletedLogList := TSendCompletedLogList.Create;
  SendIncompletedLogList := TSendIncompletedLogList.Create;
end;

destructor TSendItemInfo.Destroy;
begin
  SendIncompletedLogList.Free;
  SendCompletedLogList.Free;
  SendContinusList.Free;
  ExcludeFilterList.Free;
  IncludeFilterList.Free;
  inherited;
end;

procedure TSendItemInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TSendItemInfo.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemInfo.SetScheduleInfo(_ScheduleType, _ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleType := _ScheduleType;
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemInfo.SetSpaceInfo(_FileCount : Integer;
  _ItemSize, _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;


procedure TSendItemInfo.SetZipInfo(_IsZip: Boolean; _ZipPath: string);
begin
  IsZip := _IsZip;
  ZipPath := _ZipPath;
end;

{ TDesItemInfo }

constructor TSendRootItemInfo.Create(_SendRootItemID: string);
begin
  SendRootItemID := _SendRootItemID;
  SendItemList := TSendItemList.Create;
end;

destructor TSendRootItemInfo.Destroy;
begin
  SendItemList.Free;
  inherited;
end;

{ TDesItemListAccessInfo }

constructor TSendRootItemListAccessInfo.Create;
begin
  MySendInfo.EnterData;
  DesItemList := MySendInfo.DesItemList;
end;

destructor TSendRootItemListAccessInfo.Destroy;
begin
  MySendInfo.LeaveData;
  inherited;
end;

{ TDesItemAccessInfo }

constructor TSendRootItemAccessInfo.Create( _DesItemID : string );
begin
  inherited Create;
  DesItemID := _DesItemID;
end;

function TSendRootItemAccessInfo.FindDesItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to DesItemList.Count - 1 do
    if ( DesItemList[i].SendRootItemID = DesItemID ) then
    begin
      Result := True;
      DesItemIndex := i;
      DesItemInfo := DesItemList[i];
      break;
    end;
end;

{ TDesItemAddInfo }

procedure TSendRootItemAddInfo.Update;
begin
  if FindDesItemInfo then
    Exit;

  CreateItemInfo;
  DesItemList.Add( DesItemInfo );
end;

{ TDesItemRemoveInfo }

procedure TSendRootItemRemoveInfo.Update;
begin
  if not FindDesItemInfo then
    Exit;

  DesItemList.Delete( DesItemIndex );
end;

{ TBackupItemListAccessInfo }

function TSendItemListAccessInfo.FindBackupItemList : Boolean;
begin
  Result := FindDesItemInfo;
  if Result then
    BackupItemList := DesItemInfo.SendItemList
  else
    BackupItemList := nil;
end;

{ TBackupItemAccessInfo }

procedure TSendItemAccessInfo.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TSendItemAccessInfo.FindBackupItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if ( BackupItemList[i].SourcePath = BackupPath ) then
    begin
      Result := True;
      BackupItemIndex := i;
      BackupItemInfo := BackupItemList[i];
      break;
    end;
end;

{ TBackupItemAddInfo }

procedure TSendItemAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TSendItemAddInfo.SetLastSendTime(_LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemAddInfo.SetIsCompleted(_IsCompleted: boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemAddInfo.SetScheduleInfo(_ScheduleType, _ScheduleValue1,
  _ScheduleValue2: Integer);
begin
  ScheduleType := _ScheduleType;
  ScheduleValue1 := _ScheduleValue1;
  ScheduleValue2 := _ScheduleValue2;
end;

procedure TSendItemAddInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemAddInfo.SetZipInfo(_IsZip: boolean; _ZipPath: string);
begin
  IsZip := _IsZip;
  ZipPath := _ZipPath;
end;

procedure TSendItemAddInfo.Update;
begin
  if FindBackupItemInfo or ( BackupItemList = nil ) then
    Exit;

    // ����
  CreateSendItem;

  BackupItemInfo.SetIsFile( IsFile );
  BackupItemInfo.SetIsCompleted( IsCompleted );
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemInfo.SetZipInfo( IsZip, ZipPath );
  BackupItemInfo.SetScheduleInfo( ScheduleType, ScheduleValue1, ScheduleValue2 );
  BackupItemInfo.LastSendTime := LastSendTime;
  BackupItemInfo.IsSending := False;
  BackupItemInfo.IsLostConn := False;
  BackupItemList.Add( BackupItemInfo );

    // ˢ���´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemRemoveInfo }

procedure TSendItemRemoveInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemList.Delete( BackupItemIndex );
end;

{ DesItemInfoReadUtil }

class function SendRootItemInfoReadUtil.ReadBackupList(
  DesItemID: string): TStringList;
var
  DesItemReadBackupList : TSendItemReadBackupList;
begin
  DesItemReadBackupList := TSendItemReadBackupList.Create( DesItemID );
  Result := DesItemReadBackupList.get;
  DesItemReadBackupList.Free;
end;

class function SendRootItemInfoReadUtil.ReadDesBusyList(
  DesItemID: string): TStringList;
var
  SendItemReadDesBusyList : TSendItemReadDesBusyList;
begin
  SendItemReadDesBusyList := TSendItemReadDesBusyList.Create( DesItemID );
  Result := SendItemReadDesBusyList.get;
  SendItemReadDesBusyList.Free;
end;

class function SendRootItemInfoReadUtil.ReadIncompletedList(
  DesItemID: string): TStringList;
var
  SendItemReadIncompletedList : TSendItemReadIncompletedList;
begin
  SendItemReadIncompletedList := TSendItemReadIncompletedList.Create( DesItemID );
  Result := SendItemReadIncompletedList.get;
  SendItemReadIncompletedList.Free;
end;

class function SendRootItemInfoReadUtil.ReadLocaDesList: TStringList;
var
  DesItemListReadLocalList : TSendItemListReadLocalList;
begin
  DesItemListReadLocalList := TSendItemListReadLocalList.Create;
  Result := DesItemListReadLocalList.get;
  DesItemListReadLocalList.Free;
end;

class function SendRootItemInfoReadUtil.ReadLostConnList(
  DesItemID: string): TStringList;
var
  SendItemReadLostConnList : TSendItemReadLostConnList;
begin
  SendItemReadLostConnList := TSendItemReadLostConnList.Create( DesItemID );
  Result := SendItemReadLostConnList.get;
  SendItemReadLostConnList.Free;
end;

class function SendRootItemInfoReadUtil.ReadNetworkDesList: TStringList;
var
  DesItemListReadNetworkList : TSendItemListReadNetworkList;
begin
  DesItemListReadNetworkList := TSendItemListReadNetworkList.Create;
  Result := DesItemListReadNetworkList.get;
  DesItemListReadNetworkList.Free;
end;

class function SendRootItemInfoReadUtil.ReadOnTimeSendList(
  DesItemID: string): TStringList;
var
  SendItemReadOnTimeList : TSendItemReadOnTimeList;
begin
  SendItemReadOnTimeList := TSendItemReadOnTimeList.Create( DesItemID );
  Result :=  SendItemReadOnTimeList.get;
  SendItemReadOnTimeList.Free;
end;

{ TDesItemListReadLocalList }

function TSendItemListReadLocalList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalSendRootItemInfo then
      Result.Add( DesItemList[i].SendRootItemID );
end;

{ TDesItemReadBackupList }

function TSendItemReadBackupList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    Result.Add( BackupItemList[i].SourcePath );
end;

{ TBackupItemReadIsEnable }

function TSendItemReadIsExist.get: Boolean;
begin
  Result := FindBackupItemInfo;
end;

{ TBackupReadIncludeFilter }

function TSendItemReadIncludeFilter.get: TFileFilterList;
var
  IncludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  IncludeFilterList := BackupItemInfo.IncludeFilterList;
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    FilterType := IncludeFilterList[i].FilterType;
    FilterStr := IncludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupReadExcludeFilter }

function TSendItemReadExcludeFilter.get: TFileFilterList;
var
  ExcludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  ExcludeFilterList := BackupItemInfo.ExcludeFilterList;
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    FilterType := ExcludeFilterList[i].FilterType;
    FilterStr := ExcludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupItemSetSpaceInfoInfo }

procedure TSendItemSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendItemSetSpaceInfoInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.FileCount := FileCount;
  BackupItemInfo.ItemSize := ItemSize;
  BackupItemInfo.CompletedSize := CompletedSize;
end;


{ TBackupItemSetAddCompletedSpaceInfo }

procedure TSendItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TSendItemSetAddCompletedSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.CompletedSize := BackupItemInfo.CompletedSize + AddCompletedSpace;
end;


{ TDesItemAddLocalInfo }

procedure TSendRootItemAddLocalInfo.CreateItemInfo;
begin
  DesItemInfo := TLocalSendRootItemInfo.Create( DesItemID );
end;


{ TDesItemAddNetworkInfo }

procedure TSendRootItemAddNetworkInfo.CreateItemInfo;
begin
  DesItemInfo := TNetworkSendRootItemInfo.Create( DesItemID );
end;

{ BackupItemReadUtil }

class function SendItemInfoReadUtil.ReadCompletedLogList(DesItemID,
  BackupPath: string): TSendCompletedLogList;
var
  BackupItemReadCompletedLogList : TBackupItemReadCompletedLogList;
begin
  BackupItemReadCompletedLogList := TBackupItemReadCompletedLogList.Create( DesItemID );
  BackupItemReadCompletedLogList.SetBackupPath( BackupPath );
  Result := BackupItemReadCompletedLogList.get;
  BackupItemReadCompletedLogList.Free;
end;

class function SendItemInfoReadUtil.ReadContinuesList(DesItemID,
  BackupPath: string): TSendContinusList;
var
  BackupItemReadContinusList : TSendItemReadContinusList;
begin
  BackupItemReadContinusList := TSendItemReadContinusList.Create( DesItemID );
  BackupItemReadContinusList.SetBackupPath( BackupPath );
  Result := BackupItemReadContinusList.get;
  BackupItemReadContinusList.Free;
end;

class function SendItemInfoReadUtil.ReadExcludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadExcludeFilter : TSendItemReadExcludeFilter;
begin
  BackupItemReadExcludeFilter := TSendItemReadExcludeFilter.Create( DesItemID );
  BackupItemReadExcludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadExcludeFilter.get;
  BackupItemReadExcludeFilter.Free;
end;

class function SendItemInfoReadUtil.ReadExistSend(
  DesItemID: string): Boolean;
var
  DesItemReadExistBackup : TSendItemReadExistChild;
begin
  DesItemReadExistBackup := TSendItemReadExistChild.Create( DesItemID );
  Result := DesItemReadExistBackup.get;
  DesItemReadExistBackup.Free;
end;

class function SendItemInfoReadUtil.ReadIncludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadIncludeFilter : TSendItemReadIncludeFilter;
begin
  BackupItemReadIncludeFilter := TSendItemReadIncludeFilter.Create( DesItemID );
  BackupItemReadIncludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadIncludeFilter.get;
  BackupItemReadIncludeFilter.Free;
end;

class function SendItemInfoReadUtil.ReadIncompletedLogList(DesItemID,
  BackupPath: string): TSendIncompletedLogList;
var
  BackupItemReadIncompletedLogList : TBackupItemReadIncompletedLogList;
begin
  BackupItemReadIncompletedLogList := TBackupItemReadIncompletedLogList.Create( DesItemID );
  BackupItemReadIncompletedLogList.SetBackupPath( BackupPath );
  Result := BackupItemReadIncompletedLogList.get;
  BackupItemReadIncompletedLogList.Free;
end;

class function SendItemInfoReadUtil.ReadIsAddToReceive(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsAddToReceive : TSendItemReadIsAddToReceive;
begin
  SendItemReadIsAddToReceive := TSendItemReadIsAddToReceive.Create( DesItemID );
  SendItemReadIsAddToReceive.SetBackupPath( BackupPath );
  Result := SendItemReadIsAddToReceive.get;
  SendItemReadIsAddToReceive.Free;
end;

class function SendItemInfoReadUtil.ReadIsBackuping(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsBackuping : TSendItemReadIsBackuping;
begin
  BackupItemReadIsBackuping := TSendItemReadIsBackuping.Create( DesItemID );
  BackupItemReadIsBackuping.SetBackupPath( BackupPath );
  Result := BackupItemReadIsBackuping.get;
  BackupItemReadIsBackuping.Free;
end;

class function SendItemInfoReadUtil.ReadIsCompleted(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsCompleted : TSendItemReadIsCompleted;
begin
  SendItemReadIsCompleted := TSendItemReadIsCompleted.Create( DesItemID );
  SendItemReadIsCompleted.SetBackupPath( BackupPath );
  Result := SendItemReadIsCompleted.get;
  SendItemReadIsCompleted.Free;
end;

class function SendItemInfoReadUtil.ReadIsCompletedSpace(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsCompletedSpace : TSendItemReadIsCompletedSpace;
begin
  SendItemReadIsCompletedSpace := TSendItemReadIsCompletedSpace.Create( DesItemID );
  SendItemReadIsCompletedSpace.SetBackupPath( BackupPath );
  Result := SendItemReadIsCompletedSpace.get;
  SendItemReadIsCompletedSpace.Free;
end;

class function SendItemInfoReadUtil.ReadIsEnable(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsEnable : TSendItemReadIsExist;
begin
  BackupItemReadIsEnable := TSendItemReadIsExist.Create( DesItemID );
  BackupItemReadIsEnable.SetBackupPath( BackupPath );
  Result := BackupItemReadIsEnable.get;
  BackupItemReadIsEnable.Free;
end;


class function SendItemInfoReadUtil.ReadIsFile(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsFile : TSendItemReadIsFile;
begin
  SendItemReadIsFile := TSendItemReadIsFile.Create( DesItemID );
  SendItemReadIsFile.SetBackupPath( BackupPath );
  Result := SendItemReadIsFile.get;
  SendItemReadIsFile.Free;
end;

class function SendItemInfoReadUtil.ReadIsReceiveCancel(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsReceiveCancel : TSendItemReadIsReceiveCancel;
begin
  SendItemReadIsReceiveCancel := TSendItemReadIsReceiveCancel.Create( DesItemID );
  SendItemReadIsReceiveCancel.SetBackupPath( BackupPath );
  Result := SendItemReadIsReceiveCancel.get;
  SendItemReadIsReceiveCancel.Free;
end;

class function SendItemInfoReadUtil.ReadIsRemoveToReceive(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsRemoveToReceive : TSendItemReadIsRemoveToReceive;
begin
  SendItemReadIsRemoveToReceive := TSendItemReadIsRemoveToReceive.Create( DesItemID );
  SendItemReadIsRemoveToReceive.SetBackupPath( BackupPath );
  Result := SendItemReadIsRemoveToReceive.get;
  SendItemReadIsRemoveToReceive.Free;
end;

class function SendItemInfoReadUtil.ReadIsLostConn(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsSendAgain : TSendItemReadIsLostConn;
begin
  SendItemReadIsSendAgain := TSendItemReadIsLostConn.Create( DesItemID );
  SendItemReadIsSendAgain.SetBackupPath( BackupPath );
  Result := SendItemReadIsSendAgain.get;
  SendItemReadIsSendAgain.Free;
end;

class function SendItemInfoReadUtil.ReadIsZip(DesItemID,
  BackupPath: string): Boolean;
var
  SendItemReadIsZip : TSendItemReadIsZip;
begin
  SendItemReadIsZip := TSendItemReadIsZip.Create( DesItemID );
  SendItemReadIsZip.SetBackupPath( BackupPath );
  Result := SendItemReadIsZip.get;
  SendItemReadIsZip.Free;
end;

class function SendItemInfoReadUtil.ReadLocalOnline: TOnlineSendList;
var
  BackupItemReadLocalOnlineInfo : TSendItemReadLocalOnlineInfo;
begin
  BackupItemReadLocalOnlineInfo := TSendItemReadLocalOnlineInfo.Create;
  Result := BackupItemReadLocalOnlineInfo.get;
  BackupItemReadLocalOnlineInfo.Free;
end;

class function SendItemInfoReadUtil.ReadLocalSavePath(DesItemID,
  BackupPath: string): string;
var
  SendItemReadLocalSavePath : TSendItemReadLocalSavePath;
begin
  SendItemReadLocalSavePath := TSendItemReadLocalSavePath.Create( DesItemID );
  SendItemReadLocalSavePath.SetBackupPath( BackupPath );
  Result := SendItemReadLocalSavePath.get;
  SendItemReadLocalSavePath.Free;
end;

class function SendItemInfoReadUtil.ReadPcOnline(
  OnlinePcID: string): TNetworkOnlineSendList;
var
  BackupItemReadPcOnlineInfo : TSendItemReadPcOnlineInfo;
begin
  BackupItemReadPcOnlineInfo := TSendItemReadPcOnlineInfo.Create;
  BackupItemReadPcOnlineInfo.SetOnlinePcID( OnlinePcID );
  Result := BackupItemReadPcOnlineInfo.get;
  BackupItemReadPcOnlineInfo.Free;
end;

class function SendItemInfoReadUtil.ReadZipPath(DesItemID,
  BackupPath: string): string;
var
  SendItemReadZipPath : TSendItemReadZipPath;
begin
  SendItemReadZipPath := TSendItemReadZipPath.Create( DesItemID );
  SendItemReadZipPath.SetBackupPath( BackupPath );
  Result := SendItemReadZipPath.get;
  SendItemReadZipPath.Free;
end;

{ TBackupItemSetIsBackupingInfo }

procedure TSendItemSetIsBackupingInfo.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TSendItemSetIsBackupingInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsSending := IsBackuping;
end;

{ TBackupItemIncludeFilterClearInfo }

procedure TSendItemIncludeFilterClearInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IncludeFilterList.Clear;
end;

{ TBackupItemFilterAddInfo }

procedure TSendItemFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterValue: string);
begin
  FilterType := _FilterType;
  FilterValue := _FilterValue;
end;

{ TBackupItemIncludeFilterAddInfo }

procedure TSendItemIncludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
  if not FindBackupItemInfo then
    Exit;
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
  BackupItemInfo.IncludeFilterList.Add( FilterInfo );
end;

{ TBackupItemExcludeFilterClearInfo }

procedure TSendItemExcludeFilterClearInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.ExcludeFilterList.Clear;
end;

{ TBackupItemExcludeFilterAddInfo }

procedure TSendItemExcludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
  if not FindBackupItemInfo then
    Exit;
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
  BackupItemInfo.ExcludeFilterList.Add( FilterInfo );
end;

{ TDesItemListReadNetworkList }

function TSendItemListReadNetworkList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkSendRootItemInfo then
      Result.Add( DesItemList[i].SendRootItemID );
end;


{ TBackupLogListAccessInfo }

constructor TSendLogListAccessInfo.Create;
begin
  MySendInfo.EnterData;
  BackupLogList := MySendInfo.BackupLogList;
end;

destructor TSendLogListAccessInfo.Destroy;
begin
  MySendInfo.LeaveData;
  inherited;
end;

{ TBackupItemReadIsCompleted }

function TSendItemReadIsCompletedSpace.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.CompletedSize >= BackupItemInfo.ItemSize;
end;

{ TDesItemReadExistBackup }

function TSendItemReadExistChild.get: Boolean;
begin
  Result := False;
  if not FindDesItemInfo then
    Exit;
  Result := DesItemInfo.SendItemList.Count > 0;
end;

{ TBackupItemSetIsCompletedInfo }

procedure TSendItemSetIsCompletedInfo.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TSendItemSetIsCompletedInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsCompleted := IsCompleted;
end;



{ TOnlineBackupInfo }

constructor TOnlineSendInfo.Create(_SendRootItemID, _SourcePath: string);
begin
  SendRootItemID := _SendRootItemID;
  SourcePath := _SourcePath;
end;

{ TBackupItemReadLocalOnlineInfo }

function TSendItemReadLocalOnlineInfo.get: TOnlineSendList;
var
  i, j: Integer;
  OnlineBackupIfno : TOnlineSendInfo;
  BackupItemInfo : TSendItemInfo;
begin
  Result := TOnlineSendList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalSendRootItemInfo then
      for j := 0 to DesItemList[i].SendItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].SendItemList[j];
        if BackupItemInfo.IsCompleted then // ����ɣ�����
          Continue;
        OnlineBackupIfno := TOnlineSendInfo.Create( DesItemList[i].SendRootItemID, BackupItemInfo.SourcePath );
        Result.Add( OnlineBackupIfno );
      end;
end;

{ TBackupItemReadPcOnlineInfo }

function TSendItemReadPcOnlineInfo.get: TNetworkOnlineSendList;
var
  i, j: Integer;
  SelectPcID : string;
  OnlineBackupIfno : TNetworkOnlineSendInfo;
  BackupItemInfo : TSendItemInfo;
  NetworkSendItemInfo : TNetworkSendItemInfo;
begin
  Result := TNetworkOnlineSendList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkSendRootItemInfo then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( DesItemList[i].SendRootItemID );
      if SelectPcID <> OnlinePcID then
        Continue;
      for j := 0 to DesItemList[i].SendItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].SendItemList[j];
        if BackupItemInfo.IsCompleted then
          Continue;
        if not ( BackupItemInfo is TNetworkSendItemInfo ) then
          Continue;
        NetworkSendItemInfo := BackupItemInfo as TNetworkSendItemInfo;
        OnlineBackupIfno := TNetworkOnlineSendInfo.Create( DesItemList[i].SendRootItemID, NetworkSendItemInfo.SourcePath );
        OnlineBackupIfno.SetReceiveInfo( NetworkSendItemInfo.IsAddToReceive, NetworkSendItemInfo.IsRemoveToReceive );
        Result.Add( OnlineBackupIfno );
      end;
    end;
end;

procedure TSendItemReadPcOnlineInfo.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

{ TBackupItemReadIsBackuping }

function TSendItemReadIsBackuping.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsSending;
end;

{ TBackupContinusInfo }

constructor TSendContinusInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendContinusInfo.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TSendContinusInfo.SetSpaceInfo(_FileSize, _Position : Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

{ TBackupContinusListAccessInfo }

function TSendContinusListAccessInfo.FindBackupContinusList : Boolean;
begin
  Result := FindBackupItemInfo;
  if Result then
    BackupContinusList := BackupItemInfo.SendContinusList
  else
    BackupContinusList := nil;
end;

{ TBackupContinusAccessInfo }

procedure TSendContinusAccessInfo.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TSendContinusAccessInfo.FindBackupContinusInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupContinusList then
    Exit;
  for i := 0 to BackupContinusList.Count - 1 do
    if ( BackupContinusList[i].FilePath = FilePath ) then
    begin
      Result := True;
      BackupContinusIndex := i;
      BackupContinusInfo := BackupContinusList[i];
      break;
    end;
end;

{ TBackupContinusAddInfo }

procedure TSendContinusAddInfo.SetFileTime( _FileTime : TDateTime );
begin
  FileTime := _FileTime;
end;

procedure TSendContinusAddInfo.SetSpaceInfo( _FileSize, _Position : int64 );
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TSendContinusAddInfo.Update;
begin
    // �������򴴽�
  if not FindBackupContinusInfo then
  begin
    if BackupContinusList = nil then
      Exit;
    BackupContinusInfo := TSendContinusInfo.Create( FilePath );
    BackupContinusInfo.SetFileTime( FileTime );
    BackupContinusInfo.SetSpaceInfo( FileSize, Position );
    BackupContinusList.Add( BackupContinusInfo );
  end;
  BackupContinusInfo.Position := Position;
end;

{ TBackupContinusRemoveInfo }

procedure TSendContinusRemoveInfo.Update;
begin
  if not FindBackupContinusInfo then
    Exit;

  BackupContinusList.Delete( BackupContinusIndex );
end;




{ TBackupItemReadContinusList }

function TSendItemReadContinusList.get: TSendContinusList;
var
  BackupContinuseList : TSendContinusList;
  i: Integer;
  OldContinuesInfo, NewContinuesInfo : TSendContinusInfo;
begin
  Result := TSendContinusList.Create;
  if not FindBackupItemInfo then
    Exit;
  BackupContinuseList := BackupItemInfo.SendContinusList;
  for i := 0 to BackupContinuseList.Count - 1 do
  begin
    OldContinuesInfo := BackupContinuseList[i];
    NewContinuesInfo := TSendContinusInfo.Create( OldContinuesInfo.FilePath );
    NewContinuesInfo.SetSpaceInfo( OldContinuesInfo.FileSize, OldContinuesInfo.Position );
    NewContinuesInfo.SetFileTime( OldContinuesInfo.FileTime );
    Result.Add( NewContinuesInfo );
  end;
end;

{ TSendItemAddNetworkInfo }

procedure TSendItemAddNetworkInfo.CreateSendItem;
var
  NetworkSendItemInfo : TNetworkSendItemInfo;
begin
  NetworkSendItemInfo := TNetworkSendItemInfo.Create( BackupPath );
  NetworkSendItemInfo.SetReceiveInfo( IsAddToReceive, IsRemoveToReceive );
  NetworkSendItemInfo.SetIsReceiveCancel( IsReceiveCancel );
  NetworkSendItemInfo.IsDesBusy := False;
  BackupItemInfo := NetworkSendItemInfo;
end;


procedure TSendItemAddNetworkInfo.SetIsReceiveCancel(
  _IsReceiveCancel: Boolean);
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemAddNetworkInfo.SetReceiveInfo(_IsAddToReceive,
  _IsRemoveToReceive: Boolean);
begin
  IsAddToReceive := _IsAddToReceive;
  IsRemoveToReceive := _IsRemoveToReceive;
end;

{ TSendItemAddLocalInfo }

procedure TSendItemAddLocalInfo.CreateSendItem;
var
  LocalSendItemInfo : TLocalSendItemInfo;
begin
  LocalSendItemInfo := TLocalSendItemInfo.Create( BackupPath );
  LocalSendItemInfo.SetSavePath( SavePath );
  BackupItemInfo := LocalSendItemInfo;
end;

procedure TSendItemAddLocalInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLocalSendItemInfo }

procedure TLocalSendItemInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TSendItemReadSavePath }

function TSendItemReadLocalSavePath.get: string;
begin
  Result := '';
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TLocalSendItemInfo then
    Result := ( BackupItemInfo as TLocalSendItemInfo ).SavePath;
end;

{ TNetworkSendItemInfo }

procedure TNetworkSendItemInfo.SetIsReceiveCancel(_IsReceiveCancel: Boolean);
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TNetworkSendItemInfo.SetReceiveInfo(_IsAddToReceive,
  _IsRemoveToReceive: Boolean);
begin
  IsAddToReceive := _IsAddToReceive;
  IsRemoveToReceive := _IsRemoveToReceive;
end;

{ TSendItemSetIsAddToReceiveInfo }

procedure TSendItemSetIsAddToReceiveInfo.SetIsAddToReceive( _IsAddToReceive : boolean );
begin
  IsAddToReceive := _IsAddToReceive;
end;

procedure TSendItemSetIsAddToReceiveInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    ( BackupItemInfo as TNetworkSendItemInfo ).IsAddToReceive := IsAddToReceive;
end;

{ TSendItemSetIsRemoveToReceiveInfo }

procedure TSendItemSetIsRemoveToReceiveInfo.SetIsRemoveToReceive( _IsRemoveToReceive : boolean );
begin
  IsRemoveToReceive := _IsRemoveToReceive;
end;

procedure TSendItemSetIsRemoveToReceiveInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    ( BackupItemInfo as TNetworkSendItemInfo ).IsRemoveToReceive := IsRemoveToReceive;
end;



{ TSendItemReadIsAddToReceive }

function TSendItemReadIsAddToReceive.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    Result := ( BackupItemInfo as TNetworkSendItemInfo ).IsAddToReceive;
end;

{ TSendItemReadIsRemoveToReceive }

function TSendItemReadIsRemoveToReceive.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    Result := ( BackupItemInfo as TNetworkSendItemInfo ).IsRemoveToReceive;
end;

{ TNetworkOnlineSendInfo }

procedure TNetworkOnlineSendInfo.SetReceiveInfo(_IsAddToReceive,
  _IsRemoveToReceive: Boolean);
begin
  IsAddToReceive := _IsAddToReceive;
  IsRemoveToReceive := _IsRemoveToReceive;
end;

{ TSendItemSetIsReceiveCancelInfo }

procedure TSendItemSetIsReceiveCancelInfo.SetIsReceiveCancel( _IsReceiveCancel : boolean );
begin
  IsReceiveCancel := _IsReceiveCancel;
end;

procedure TSendItemSetIsReceiveCancelInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    ( BackupItemInfo as TNetworkSendItemInfo ).IsReceiveCancel := IsReceiveCancel;
end;



{ TSendItemReadIsReceiveCancel }

function TSendItemReadIsReceiveCancel.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    Result := ( BackupItemInfo as TNetworkSendItemInfo ).IsReceiveCancel;
end;

{ TSendItemSetIsDesBusyInfo }

procedure TSendItemSetIsDesBusyInfo.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TSendItemSetIsDesBusyInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  if BackupItemInfo is TNetworkSendItemInfo then
    ( BackupItemInfo as TNetworkSendItemInfo ).IsDesBusy := IsDesBusy;
end;



{ TSendItemReadDesBusyList }

function TSendItemReadDesBusyList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TSendItemInfo;
begin
  Result := TStringList.Create;

  if not FindBackupItemList then
    Exit;

  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if ( BackupItemInfo is TNetworkSendItemInfo ) and
       ( BackupItemInfo as TNetworkSendItemInfo ).IsDesBusy
    then
      Result.Add( BackupItemInfo.SourcePath );
  end;
end;

{ TSendItemReadIsCompleted }

function TSendItemReadIsCompleted.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsCompleted;
end;

{ TSendFileHistoryInfo }

procedure TSendFileHistoryInfo.AddPath(NewSendPathList: TStringList);
var
  i: Integer;
begin
  for i := 0 to NewSendPathList.Count - 1 do
    SendPathList.Add( NewSendPathList[i] );
end;

constructor TSendFileHistoryInfo.Create;
begin
  SendPathList := TStringList.Create;
end;

destructor TSendFileHistoryInfo.Destroy;
begin
  SendPathList.Free;
  inherited;
end;

{ TSendDesHistoryInfo }

procedure TSendDesHistoryInfo.AddPath(NewSendDesList: TStringList);
var
  i: Integer;
begin
  for i := 0 to NewSendDesList.Count - 1 do
    SendDesList.Add( NewSendDesList[i] );
end;

constructor TSendDesHistoryInfo.Create;
begin
  SendDesList := TStringList.Create;
end;

destructor TSendDesHistoryInfo.Destroy;
begin
  SendDesList.Free;
  inherited;
end;

{ TSendFileHistoryListAccessInfo }

constructor TSendFileHistoryListAccessInfo.Create;
begin
  MySendInfo.EnterData;
  SendFileHistoryList := MySendInfo.SendFileHistoryList;
end;

destructor TSendFileHistoryListAccessInfo.Destroy;
begin
  MySendInfo.LeaveData;
  inherited;
end;

{ TSendDesHistoryListAccessInfo }

constructor TSendDesHistoryListAccessInfo.Create;
begin
  MySendInfo.EnterData;
  SendDesHistoryList := MySendInfo.SendDesHistoryList;
end;

destructor TSendDesHistoryListAccessInfo.Destroy;
begin
  MySendInfo.LeaveData;
  inherited;
end;

{ TSendFileHistoryAddInfo }

constructor TSendFileHistoryAddInfo.Create(_SendPathList: TStringList);
begin
  inherited Create;
  SendPathList := _SendPathList;
end;

destructor TSendFileHistoryAddInfo.Destroy;
begin
  SendPathList.Free;
  inherited;
end;

procedure TSendFileHistoryAddInfo.Update;
var
  SendFileHistoryInfo : TSendFileHistoryInfo;
begin
  SendFileHistoryInfo := TSendFileHistoryInfo.Create;
  SendFileHistoryInfo.AddPath( SendPathList );
  SendFileHistoryList.Insert( 0, SendFileHistoryInfo );
end;

{ TSendFileHistoryRemoveInfo }

constructor TSendFileHistoryRemoveInfo.Create(_RemoveIndex: Integer);
begin
  inherited Create;
  RemoveIndex := _RemoveIndex;
end;

procedure TSendFileHistoryRemoveInfo.Update;
begin
  if SendFileHistoryList.Count <= RemoveIndex then
    Exit;

  SendFileHistoryList.Delete( RemoveIndex );
end;

{ TSendFileHistoryClearInfo }

procedure TSendFileHistoryClearInfo.Update;
begin
  SendFileHistoryList.Clear;
end;

{ SendFileHistoryInfoReadUtil }

class function SendFileHistoryInfoReadUtil.ReadHistoryCount: Integer;
var
  SendFileHistoryReadCount : TSendFileHistoryReadCount;
begin
  SendFileHistoryReadCount := TSendFileHistoryReadCount.Create;
  Result := SendFileHistoryReadCount.get;
  SendFileHistoryReadCount.Free;
end;

class function SendFileHistoryInfoReadUtil.ReadPathList(
  HistoryIndex: Integer): TStringList;
var
  SendFileHistoryReadList : TSendFileHistoryReadList;
begin
  SendFileHistoryReadList := TSendFileHistoryReadList.Create;
  SendFileHistoryReadList.SetHistoryIndex( HistoryIndex );
  Result := SendFileHistoryReadList.get;
  SendFileHistoryReadList.Free;
end;

class function SendFileHistoryInfoReadUtil.ReadExistIndex(
  SendPathList: TStringList): Integer;
var
  SendFileHistoryReadExistIndex : TSendFileHistoryReadExistIndex;
begin
  SendFileHistoryReadExistIndex := TSendFileHistoryReadExistIndex.Create;
  SendFileHistoryReadExistIndex.SetSendPathList( SendPathList );
  Result := SendFileHistoryReadExistIndex.get;
  SendFileHistoryReadExistIndex.Free;
end;

{ TSendFileHistoryReadExistIndex }

function TSendFileHistoryReadExistIndex.get: Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to SendFileHistoryList.Count - 1 do
    if MyStringList.getIsEquals( SendFileHistoryList[i].SendPathList, SendPathList ) then
    begin
      Result := i;
      Break;
    end;
end;

procedure TSendFileHistoryReadExistIndex.SetSendPathList(
  _SendPathList: TStringList);
begin
  SendPathList := _SendPathList;
end;

{ TSendFileHistoryReadCount }

function TSendFileHistoryReadCount.get: Integer;
begin
  Result := SendFileHistoryList.Count;
end;

{ TSendFileHistoryReadList }

function TSendFileHistoryReadList.get: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  if SendFileHistoryList.Count <= HistoryIndex then
    Exit;
  for i := 0 to SendFileHistoryList[HistoryIndex].SendPathList.Count - 1 do
    Result.Add( SendFileHistoryList[HistoryIndex].SendPathList[i] );
end;

procedure TSendFileHistoryReadList.SetHistoryIndex(_HistoryIndex: Integer);
begin
  HistoryIndex := _HistoryIndex;
end;

{ TSendDesHistoryAddInfo }

constructor TSendDesHistoryAddInfo.Create(_SendDesList: TStringList);
begin
  inherited Create;
  SendDesList := _SendDesList;
end;

destructor TSendDesHistoryAddInfo.Destroy;
begin
  SendDesList.Free;
  inherited;
end;

procedure TSendDesHistoryAddInfo.Update;
var
  SendDesHistoryInfo : TSendDesHistoryInfo;
begin
  SendDesHistoryInfo := TSendDesHistoryInfo.Create;
  SendDesHistoryInfo.AddPath( SendDesList );
  SendDesHistoryList.Insert( 0, SendDesHistoryInfo );
end;

{ TSendDesHistoryRemoveInfo }

constructor TSendDesHistoryRemoveInfo.Create(_RemoveIndex: Integer);
begin
  inherited Create;
  RemoveIndex := _RemoveIndex;
end;

procedure TSendDesHistoryRemoveInfo.Update;
begin
  if SendDesHistoryList.Count <= RemoveIndex then
    Exit;

  SendDesHistoryList.Delete( RemoveIndex );
end;

{ TSendDesHistoryClearInfo }

procedure TSendDesHistoryClearInfo.Update;
begin
  SendDesHistoryList.Clear;
end;

{ TSendDesHistoryReadExistIndex }

function TSendDesHistoryReadExistIndex.get: Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to SendDesHistoryList.Count - 1 do
    if MyStringList.getIsEquals( SendDesHistoryList[i].SendDesList, SendDesList ) then
    begin
      Result := i;
      Break;
    end;
end;

procedure TSendDesHistoryReadExistIndex.SetSendPathList(
  _SendDesList: TStringList);
begin
  SendDesList := _SendDesList;
end;

{ TSendDesHistoryReadCount }

function TSendDesHistoryReadCount.get: Integer;
begin
  Result := SendDesHistoryList.Count;
end;

{ TSendDesHistoryReadList }

function TSendDesHistoryReadList.get: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  if SendDesHistoryList.Count <= HistoryIndex then
    Exit;
  for i := 0 to SendDesHistoryList[HistoryIndex].SendDesList.Count - 1 do
    Result.Add( SendDesHistoryList[HistoryIndex].SendDesList[i] );
end;

procedure TSendDesHistoryReadList.SetHistoryIndex(_HistoryIndex: Integer);
begin
  HistoryIndex := _HistoryIndex;
end;


{ SendDesHistoryInfoReadUtil }

class function SendDesHistoryInfoReadUtil.ReadHistoryCount: Integer;
var
  SendDesHistoryReadCount : TSendDesHistoryReadCount;
begin
  SendDesHistoryReadCount := TSendDesHistoryReadCount.Create;
  Result := SendDesHistoryReadCount.get;
  SendDesHistoryReadCount.Free;
end;

class function SendDesHistoryInfoReadUtil.ReadPathList(
  HistoryIndex: Integer): TStringList;
var
  SendDesHistoryReadList : TSendDesHistoryReadList;
begin
  SendDesHistoryReadList := TSendDesHistoryReadList.Create;
  SendDesHistoryReadList.SetHistoryIndex( HistoryIndex );
  Result := SendDesHistoryReadList.get;
  SendDesHistoryReadList.Free;
end;

class function SendDesHistoryInfoReadUtil.ReadExistIndex(
  SendPathList: TStringList): Integer;
var
  SendDesHistoryReadExistIndex : TSendDesHistoryReadExistIndex;
begin
  SendDesHistoryReadExistIndex := TSendDesHistoryReadExistIndex.Create;
  SendDesHistoryReadExistIndex.SetSendPathList( SendPathList );
  Result := SendDesHistoryReadExistIndex.get;
  SendDesHistoryReadExistIndex.Free;
end;

{ TSendItemReadIsFile }

function TSendItemReadIsFile.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsFile;
end;

{ TSendSpeedInfo }

constructor TSendSpeedInfo.Create;
begin
  IsLimit := False;
end;

{ TSendSpeedAccessInfo }

constructor TSendSpeedAccessInfo.Create;
begin
  SendSpeedInfo := MySendInfo.SendSpeedInfo;
end;

{ TSendSpeedLimitInfo }

procedure TSendSpeedLimitInfo.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TSendSpeedLimitInfo.SetLimitInfo(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TSendSpeedLimitInfo.Update;
begin
  SendSpeedInfo.IsLimit := IsLimit;
  SendSpeedInfo.LimitValue := LimitValue;
  SendSpeedInfo.LimitType := LimitType;
end;

constructor TSendLogInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TSendItemSetIsSendAgainInfo }

procedure TSendItemSetIsLostConnInfo.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TSendItemSetIsLostConnInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsLostConn := IsLostConn;
end;

{ TSendItemReadIsSendAgain }

function TSendItemReadIsLostConn.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsLostConn;
end;

{ TSendItemReadIsZip }

function TSendItemReadIsZip.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsZip;
end;

{ TSendItemReadZipPath }

function TSendItemReadZipPath.get: string;
begin
  Result := '';
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.ZipPath;
end;

{ TSendItemReadLostConnList }

function TSendItemReadLostConnList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TSendItemInfo;
begin
  Result := TStringList.Create;

  if not FindBackupItemList then
    Exit;

  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if ( BackupItemInfo is TNetworkSendItemInfo ) and
       ( BackupItemInfo as TNetworkSendItemInfo ).IsLostConn
    then
      Result.Add( BackupItemInfo.SourcePath );
  end;
end;

{ TSendCompletedLogInfo }

procedure TSendCompletedLogInfo.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

{ TSendCompletedLogListAccessInfo }

function TSendCompletedLogListAccessInfo.FindSendCompletedLogList: Boolean;
begin
  Result := FindBackupItemInfo;
  if Result then
    SendCompletedLogList := BackupItemInfo.SendCompletedLogList
  else
    SendCompletedLogList := nil;
end;

{ TSendIncompletedLogListAccessInfo }

function TSendIncompletedLogListAccessInfo.FindSendIncompletedLogList: Boolean;
begin
  Result := FindBackupItemInfo;
  if Result then
    SendIncompletedLogList := BackupItemInfo.SendIncompletedLogList
  else
    SendIncompletedLogList := nil;
end;

{ TSendAddCompletedLogInfo }

procedure TSendAddCompletedLogInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendAddCompletedLogInfo.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TSendAddCompletedLogInfo.Update;
var
  SendCompletedLogInfo : TSendCompletedLogInfo;
begin
    // ������
  if not FindSendCompletedLogList then
    Exit;

    // ɾ�������Ĳ���
  if SendCompletedLogList.Count >= 20 then
    SendCompletedLogList.Delete( SendCompletedLogList.Count - 1 );

    // ���
  SendCompletedLogInfo := TSendCompletedLogInfo.Create( FilePath );
  SendCompletedLogInfo.SetSendTime( SendTime );
  SendCompletedLogList.Insert( 0, SendCompletedLogInfo );
end;

{ TSendAddIncompletedLogInfo }

procedure TSendAddIncompletedLogInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSendAddIncompletedLogInfo.Update;
var
  SendIncompletedLogInfo : TSendIncompletedLogInfo;
begin
    // ������
  if not FindSendIncompletedLogList then
    Exit;

    // ���
  SendIncompletedLogInfo := TSendIncompletedLogInfo.Create( FilePath );
  SendIncompletedLogList.Add( SendIncompletedLogInfo );
end;

{ TSendClearCompletedLogInfo }

procedure TSendClearCompletedLogInfo.Update;
begin
  if not FindSendCompletedLogList then
    Exit;

  SendCompletedLogList.Clear;
end;

{ TSendClearIncompletedLogInfo }

procedure TSendClearIncompletedLogInfo.Update;
begin
  if not FindSendIncompletedLogList then
    Exit;

  SendIncompletedLogList.Clear;
end;

{ TBackupItemReadCompletedLogList }

function TBackupItemReadCompletedLogList.get: TSendCompletedLogList;
var
  i: Integer;
  LogInfo : TSendCompletedLogInfo;
begin
  Result := TSendCompletedLogList.Create;
  if not FindSendCompletedLogList then
    Exit;
  for i := 0 to SendCompletedLogList.Count - 1 do
  begin
    LogInfo := TSendCompletedLogInfo.Create( SendCompletedLogList[i].FilePath );
    LogInfo.SetSendTime( SendCompletedLogList[i].SendTime );
    Result.Add( LogInfo );
  end;
end;

{ TBackupItemReadIncompletedLogList }

function TBackupItemReadIncompletedLogList.get: TSendIncompletedLogList;
var
  i: Integer;
  LogInfo : TSendIncompletedLogInfo;
begin
  Result := TSendIncompletedLogList.Create;
  try
    if not FindSendIncompletedLogList then
      Exit;
    for i := 0 to SendIncompletedLogList.Count - 1 do
    begin
      LogInfo := TSendIncompletedLogInfo.Create( SendIncompletedLogList[i].FilePath );
      Result.Add( LogInfo );
    end;
  except
  end;
end;


{ TSendItemReadIncompletedList }

function TSendItemReadIncompletedList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TSendItemInfo;
  NetworkSendItemInfo : TNetworkSendItemInfo;
begin
  Result := TStringList.Create;

  if not FindBackupItemList then
    Exit;

  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if not ( BackupItemInfo is TNetworkSendItemInfo ) then
      Continue;
    NetworkSendItemInfo := BackupItemInfo as TNetworkSendItemInfo;

      // �����״̬,����
    if NetworkSendItemInfo.IsDesBusy or NetworkSendItemInfo.IsReceiveCancel or
       NetworkSendItemInfo.IsAddToReceive or NetworkSendItemInfo.IsRemoveToReceive or
       NetworkSendItemInfo.IsLostConn or NetworkSendItemInfo.IsSending or NetworkSendItemInfo.IsCompleted
    then
      Continue;

    Result.Add( NetworkSendItemInfo.SourcePath );
  end;
end;

{ TSendItemSetLastSendTimeInfo }

procedure TSendItemSetLastSendTimeInfo.SetLastSendTime(
  _LastSendTime: TDateTime);
begin
  LastSendTime := _LastSendTime;
end;

procedure TSendItemSetLastSendTimeInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.LastSendTime := LastSendTime;
  RefreshNextSyncTime;
end;

{ TSendItemWriteInfo }

procedure TSendItemWriteInfo.RefreshNextSyncTime;
begin
  BackupItemInfo.NextSendTime := ScheduleUtil.getNextBackupTime( BackupItemInfo.ScheduleType, BackupItemInfo.ScheduleValue1, BackupItemInfo.ScheduleValue2, BackupItemInfo.LastSendTime );
end;

{ TSendItemSetScheduleInfo }

procedure TSendItemSetScheduleInfo.SetSchduleType(_SchduleType: Integer);
begin
  SchduleType := _SchduleType;
end;

procedure TSendItemSetScheduleInfo.SetSchduleValue(_SchduleValue1,
  _SchduleValue2: Integer);
begin
  SchduleValue1 := _SchduleValue1;
  SchduleValue2 := _SchduleValue2;
end;

procedure TSendItemSetScheduleInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.ScheduleType := SchduleType;
  BackupItemInfo.ScheduleValue1 := SchduleValue1;
  BackupItemInfo.ScheduleValue2 := SchduleValue2;
  RefreshNextSyncTime;
end;

{ TSendItemReadOnTimeList }

function TSendItemReadOnTimeList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TSendItemInfo;
begin
  Result := TStringList.Create;

  if not FindBackupItemList then
    Exit;

  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if BackupItemInfo.IsSending or not BackupItemInfo.IsCompleted or
       ( BackupItemInfo.ScheduleType = ScheduleType_Manual ) or
       ( BackupItemInfo.NextSendTime > Now )
    then
      Continue;
    Result.Add( BackupItemInfo.SourcePath );
  end;
end;

end.
