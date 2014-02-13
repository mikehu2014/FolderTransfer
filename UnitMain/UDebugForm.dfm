object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  Caption = 'frmDebug'
  ClientHeight = 445
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object plControl: TPanel
    Left = 0
    Top = 400
    Width = 441
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnRefresh: TButton
      Left = 108
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Refresh'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
    object btnClose: TButton
      Left = 246
      Top = 11
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
  object pcMain: TRzPageControl
    Left = 0
    Top = 0
    Width = 441
    Height = 400
    ActivePage = tsDetails
    Align = alClient
    TabIndex = 0
    TabOrder = 1
    TabStyle = tsRoundCorners
    ExplicitLeft = 64
    ExplicitTop = 104
    ExplicitWidth = 300
    ExplicitHeight = 150
    FixedDimension = 19
    object tsDetails: TRzTabSheet
      Caption = 'Debug Details'
      Padding.Top = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmoResult: TMemo
        Left = 0
        Top = 5
        Width = 437
        Height = 369
        Align = alClient
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitTop = -3
        ExplicitHeight = 377
      end
    end
    object tsList: TRzTabSheet
      Caption = 'Debug List'
      Padding.Top = 5
      ExplicitLeft = 2
      ExplicitTop = 17
      ExplicitHeight = 377
      object lvDebug: TListView
        Left = 0
        Top = 5
        Width = 437
        Height = 369
        Align = alClient
        Columns = <
          item
            Caption = 'Thread ID'
            Width = 80
          end
          item
            AutoSize = True
            Caption = 'Thread Name'
          end>
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitTop = 2
      end
    end
  end
end
