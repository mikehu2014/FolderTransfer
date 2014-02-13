object frmUnstall: TfrmUnstall
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Questionnaire for Uninstallation'
  ClientHeight = 288
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    000049494B005B5B5B007E7E7E00A3797900648754006488540095A37F0058D4
    900006BEFA007CD6EF008C8A8A00989797009C9A970092969F00999599009B98
    9C00B0888800AD909000A29D9D00B69494008EA5840090AA85008FA89E0099A1
    9D00AAA19600A5A89400A2A29C00A39EA40099A8A3008DBDAD00A2A4A400A8A6
    A700A1A9A000A8A1AD00ACA9A900BEA7A700B1AEAB00A9B0AB00AEB3AF00A6AB
    B400A0A9B900AEB3BD00B7B6B600B9B5B600B1BCB600BCBBBB00CCAFAF00CAB8
    B800B5C2B800BFC0BF00AFBACC00C0B7C900C1C0C000C9C6C700CACAC900CBD5
    DC00D1D1D100D8D7D800E1C4C400EBCACA00EFDDDE00F9D8D800E1E0E100E8E8
    E800FEE2E200F4F3F300FFF1F100000000000000000000000000000000000000
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
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000FFFFFF000003
    030303030303030303030202140000FF420D232E311D151616030505140000FF
    131F2E39424219151603050614000013230C20374040381B160305061400001F
    22222C23363433181603063C14000023211A2501231C0B0B1603063E1400001E
    08072C2B35100F103D0341411400002A1723353F40321F0E3D033D41140000FF
    272E3942FF3A290A0A030943140000FF04272D3735280A0A0A03090A14000003
    03030303030303030303090A1400000004060606060606090909090A14000000
    04432F2F2F2F2F2F2F2F2F431400000014141414141414141414141411000004
    00241212121212121212123000040000003B3B3B3B3B3B3B3B3B3B3B00000001
    0000000100000001000000010000000100000001000000010000000100000001
    00000001000000010000C0010000C0010000C0010000A0020000E0030000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object plReasons: TPanel
    Left = 0
    Top = 0
    Width = 439
    Height = 122
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 439
      Height = 19
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label2: TLabel
        Left = 2
        Top = 2
        Width = 51
        Height = 13
        BiDiMode = bdLeftToRight
        Caption = 'Reasons:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
    end
    object clbReasons: TCheckListBox
      Left = 0
      Top = 19
      Width = 439
      Height = 82
      Align = alClient
      ItemHeight = 13
      Items.Strings = (
        
          'Network computer not found,though the software is installed on b' +
          'oth computers.'
        'Fails to transfer files'
        'My computer runs abnormally since installation'
        'I need online transfer service, not transfer between computers'
        'I don'#39't know how to use'
        'Others')
      TabOrder = 1
      OnClick = clbReasonsClick
      ExplicitHeight = 85
    end
    object plOthers: TPanel
      Left = 0
      Top = 101
      Width = 439
      Height = 21
      Align = alBottom
      BevelEdges = [beBottom]
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      ExplicitTop = 81
      object edtOthers: TEdit
        Left = 0
        Top = 0
        Width = 439
        Height = 19
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 128
        ExplicitTop = 8
        ExplicitWidth = 121
        ExplicitHeight = 21
      end
    end
  end
  object plSuggestions: TPanel
    Left = 0
    Top = 122
    Width = 439
    Height = 100
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 105
    ExplicitHeight = 88
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 439
      Height = 35
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label3: TLabel
        Left = 2
        Top = 2
        Width = 139
        Height = 13
        BiDiMode = bdLeftToRight
        Caption = 'Suggestions/Comments:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object Label4: TLabel
        Left = 2
        Top = 17
        Width = 392
        Height = 13
        Caption = 
          '(Please tell us your exact needs, and we may add new features fo' +
          'r you for free.)'
      end
    end
    object mmoSuggestion: TMemo
      Left = 0
      Top = 35
      Width = 439
      Height = 65
      Align = alClient
      TabOrder = 1
      OnKeyUp = mmoSuggestionKeyUp
      ExplicitTop = 19
      ExplicitHeight = 22
    end
  end
  object plButton: TPanel
    Left = 0
    Top = 253
    Width = 439
    Height = 35
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = -2
    object btnUnstall: TButton
      Left = 102
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Unstall'
      Enabled = False
      TabOrder = 0
      OnClick = btnUnstallClick
    end
    object btnCancel: TButton
      Left = 250
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object plEmail: TPanel
    Left = 0
    Top = 222
    Width = 439
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitTop = 221
    object Label1: TLabel
      Left = 2
      Top = 7
      Width = 33
      Height = 13
      Caption = 'Email:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtEmail: TEdit
      Left = 41
      Top = 4
      Width = 398
      Height = 21
      TabOrder = 0
      OnKeyUp = edtEmailKeyUp
    end
  end
  object tmrCheckButton: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrCheckButtonTimer
    Left = 328
    Top = 120
  end
end
