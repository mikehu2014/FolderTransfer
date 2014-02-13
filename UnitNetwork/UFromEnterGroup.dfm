object frmJoinGroup: TfrmJoinGroup
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Join a Group'
  ClientHeight = 149
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000262626004F4C4C00595353005D5C5C0077626200707070007C7C7C008359
    5900826E6E0096676600B8797400EEA14500FFBE4C00D3816700DD9B7400E7B0
    6D00FFC85D002E75B40045B1E800848080008F8F8F0094949400A9878700BA99
    9800B6A5A500BCBBB800CD949400C4989800D6A28300D2A39900D9BD9200C1A3
    A100CEA4A400D3ABA900D8BDA400C9BCB800D2B7B600D0BDBD00FFDB8200FFDD
    8800FFE29300F3DFA000FFECA400FFEFAB00CDC2C200EBE1E100ECECEC000000
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
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    1414141400000000001414141400001419190506140000001419190506141425
    2020180914000014252020180914142F2E261C17000000142F2E261C17000014
    221B0B03000000001E221B0B0400250F0C100F0A040404040F0C100F0807211F
    0D11110E011212011F0D11110E0621232729280F15131314232729280F062123
    2A2C2B10002D0121232A2C2B101621212121211D00240121212121211D000000
    00000000061A01020606000000000000000000250F0C100F0807000000000000
    000000211F0D11110E0600000000000000000021232729280F06000000000000
    00000021232A2C2B101600000000000000000021212121211D0000000000C3E1
    000081C00000018000000381000083C100000000000000000000000000000200
    000002010000FC0F0000F80F0000F80F0000F80F0000F80F0000F81F0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PcMain: TRzPageControl
    Left = 0
    Top = 0
    Width = 310
    Height = 149
    ActivePage = tsJoinGroup
    Align = alClient
    BoldCurrentTab = True
    ShowCardFrame = False
    ShowFocusRect = False
    ShowFullFrame = False
    ShowShadow = False
    TabOrder = 0
    TabStyle = tsRoundCorners
    OnPageChange = PcMainPageChange
    FixedDimension = 0
    object tsJoinGroup: TRzTabSheet
      TabVisible = False
      Caption = 'Join a Group'
      object Label1: TLabel
        Left = 35
        Top = 17
        Width = 63
        Height = 13
        Caption = 'Group Name:'
      end
      object Label2: TLabel
        Left = 16
        Top = 43
        Width = 82
        Height = 13
        Caption = 'Group Password:'
      end
      object edtGroupName: TEdit
        Left = 101
        Top = 14
        Width = 185
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 0
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtPassword: TEdit
        Left = 101
        Top = 43
        Width = 185
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 1
        OnKeyUp = edtPasswordKeyUp
      end
      object btnOK: TButton
        Left = 58
        Top = 78
        Width = 75
        Height = 25
        Caption = 'OK'
        TabOrder = 2
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 177
        Top = 78
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        TabOrder = 3
        OnClick = btnCancelClick
      end
      object Panel1: TPanel
        Left = 0
        Top = 117
        Width = 310
        Height = 32
        Align = alBottom
        BevelEdges = [beTop]
        BevelKind = bkTile
        BevelOuter = bvNone
        TabOrder = 4
        object Label3: TLabel
          Left = 199
          Top = 8
          Width = 96
          Height = 13
          Cursor = crHandPoint
          Caption = 'Sign Up a Group >>'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 13395456
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          OnClick = Label3Click
        end
        object lkCreateGroup: TLinkLabel
          Left = 13
          Top = 8
          Width = 182
          Height = 17
          AutoSize = False
          Caption = 'If you don'#39't have a group yet, please '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnLinkClick = lkCreateGroupLinkClick
        end
      end
    end
    object tsSignupGroup: TRzTabSheet
      TabVisible = False
      Caption = 'Sign Up a Group'
      object Label4: TLabel
        Left = 35
        Top = 9
        Width = 63
        Height = 13
        Caption = 'Group Name:'
      end
      object Label5: TLabel
        Left = 28
        Top = 35
        Width = 70
        Height = 13
        Caption = 'Email Address:'
      end
      object Label6: TLabel
        Left = 16
        Top = 62
        Width = 82
        Height = 13
        Caption = 'Group Password:'
      end
      object Label7: TLabel
        Left = 10
        Top = 92
        Width = 88
        Height = 13
        Caption = 'Retype Password:'
      end
      object edtSignName: TEdit
        Left = 102
        Top = 6
        Width = 187
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 0
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtSignEmail: TEdit
        Left = 102
        Top = 35
        Width = 187
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 1
        OnKeyUp = edtGroupNameKeyUp
      end
      object btnSignOK: TButton
        Left = 53
        Top = 119
        Width = 75
        Height = 25
        Caption = 'Sign Up'
        TabOrder = 4
        OnClick = btnSignOKClick
      end
      object btnSignCancel: TButton
        Left = 183
        Top = 119
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 5
        OnClick = btnCancelClick
      end
      object edtSignPassword: TEdit
        Left = 102
        Top = 62
        Width = 187
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 2
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtSignPassword2: TEdit
        Left = 102
        Top = 89
        Width = 187
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 3
        OnKeyUp = edtSignPassword2KeyUp
      end
    end
  end
end
