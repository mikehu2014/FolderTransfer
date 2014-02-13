object frmSelectShare: TfrmSelectShare
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Select files or folders to share'
  ClientHeight = 406
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000333333003B33330044333300593333001D2858002B2D4600204659003653
    71004A4A4A004D4D4D00555555006666660077777700173A9900344D86003A58
    9E001744AA002653B3001976A3005374BC00205FC500236BD0002673D9001A80
    AC000080B3000083B600008CBF003784AA0054808F005D909900748895007486
    AC000099CC00349AC1002080D6002A85E8003F90EC003499FF0042A8CA0070B8
    D30059ABF90076BCFD0078CBD90065C9EA0076CAE50061D9EC0074D9FF007BDB
    FF007EE4FE008C98980080CDE6009ED8EC0087C8FF0086ECF20086ECFF0096E2
    FD008AF0FF008EF5FF0093F9FF0097F9FC0099FFFF009EFFFF00B3E1F100BFE5
    F700BCE9FF00A2F3FC00ADF3FC00A5F8FF00AAFEFF00B4FBFF00B0FFFF00BAFF
    FF00C8C8C800DBDBDB00CBECF500D5EFF900CBF6FF00C5F9FF00CBFAFF00CCFD
    FF00D2FEFF00DAFFFF00DFFFFF00E3FAFF00E2FFFF00F2FBFF00F2FFFF000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000304
    00000000050F1012080C000000000902010115121712111626240F0000000B09
    49062A292516230E282D351400000C0D4A324141414B1F2827131F1F00000707
    0101201E201F3739392E1D000000212F19443B3B3B3B3B3B3B421C000000212F
    19503E3E3E3E3E3E3E4633180000213027344D53514848484841531C00002138
    312C272728545453514D571818002142393B393A36272222404CFF5718002146
    3E3B3E46433E3B362218181818002150453E4E2B28333F4E501B000000000021
    2121210000001B1B1B000000000000000000000000000000000000000000FFFF
    0000FFFF00003C0F000000070000000300000003000000070000000700000003
    000000030000000100000001000000010000000F0000871F0000FFFF0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object vstSelectPath: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 477
    Height = 365
    Align = alClient
    BorderWidth = 1
    CheckImageKind = ckXP
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    TabOrder = 0
    TreeOptions.AnimationOptions = [toAnimatedToggle]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.SelectionOptions = [toRightClickSelect]
    OnFocusChanged = vstSelectPathFocusChanged
    OnGetText = vstSelectPathGetText
    OnGetImageIndex = vstSelectPathGetImageIndex
    OnInitChildren = vstSelectPathInitChildren
    OnInitNode = vstSelectPathInitNode
    Columns = <
      item
        CheckBox = True
        Position = 0
        Width = 271
        WideText = 'File Name'
      end
      item
        Position = 1
        Width = 80
        WideText = 'File Size'
      end
      item
        Position = 2
        Width = 120
        WideText = 'File Date'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 365
    Width = 477
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 125
      Top = 9
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 285
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
