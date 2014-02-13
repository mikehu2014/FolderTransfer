object FrmLocalSelect: TFrmLocalSelect
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'My Computers Options'
  ClientHeight = 354
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000A85E1800A7621E009C683A00A9642200BE782D00A5683100A76D3600AF6F
    3000B0713500BD7B3500B5773800B67B3F00C5782300C37A2B00C67E2C009F72
    4600A0734600B17E4700BA7F4500A77B5100AC7F5200A87F5700C1803700C784
    3700CF8C3700C4853900C5883D00CC8C3B00D38C3200DA933700DF973700DF98
    3900E29B3A00E9A43F00B1825000B4805200B4825500B3855A00B28B5F009A83
    6E009F8B7700AD8B6800BE966100BA976400BE966400B5916800BE976900A38A
    7600A08C7B00BB9D7600B1947900CD904A00D5984600DE9F4500D5974D00DB95
    4B00D69A4900D79D4900C6955300C2905900DFA95200E6A14300EBA74100E0A8
    4E00E9AA4C00ECAD4C00E4A95300E9AE5300ECAE5000E1AC5900EDB45A00C69D
    6500C1966900C7A16100D5A76F00DEB16300C6A27900DAAF7A00DFB37800E4B2
    6500EBB66100E5B86600E7B76D00EABA6A00EABB6F00EBBE6F00E5B67100E5B8
    7500E7B47A00F6C86800E7C57400EEC77000F1CF77009F999300AB988300A798
    8900A3998F00AD9B8800AF9F8800A99D9100B9A88600B9A38D00A9A19000AAA1
    9700B8AB9300D7B58F00CDB99500D1C09400E9CA8F00E9D28600F0D68600F4D8
    8000F7DC8400F3D88900E9C89100EBCE9200EDD19600EED79900F2D39700F6DB
    9F00FADA9B00FCE68D00FAE39200FAE69000FAE69600F7E09C00DBC8AE00DFCF
    B600D0C9BE00F3DAA000F5DEA300F5DDA500F8DCA200F5DEAE00EED7B700EFD9
    BA00F6E0A100FCE7AD00FCE8AA00FDE8AE00FEEBB200FCE9B700FDECBC00CFCA
    C100F2DFC400F6EAD500FBF2E100FAF6EE000000000000000000000000000000
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
    0000000061041000000000000000000000290000151C1B280000300000000000
    194008241741360924060103000000676F713D1A4447431A0D0F1D065E000000
    656E7A5A51575855413F202400000000004A7C5B2B2B2B485541211200006426
    3B715D2B000000003656210F14003888838B742A000000003953221F05024987
    798C6D150000000035503E1F0A1000624B777527000000004655371331000000
    674F8D750B0C3C4C7C5C3433000000006A868B83838383837E7C502E00000000
    9493744E828F8E733275722F0000000090815F005992914D00636C6700000000
    0000000066807F60000000000000000000000000006B6900000000000000FC7F
    0000EC370000C003000080010000C0030000E003000003C1000003C0000003C0
    000083C10000C0030000C0030000C0030000C4230000FC3F0000FE7F0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PcMain: TRzPageControl
    Left = 0
    Top = 0
    Width = 425
    Height = 354
    ActivePage = tsFileSend
    Align = alClient
    BoldCurrentTab = True
    Images = frmMainForm.ilPageControl
    ShowFocusRect = False
    ShowShadow = False
    TabIndex = 0
    TabOrder = 0
    TabStyle = tsSquareCorners
    FixedDimension = 22
    object tsFileSend: TRzTabSheet
      ImageIndex = 3
      Caption = 'Send to my directory'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 423
        Height = 327
        Align = alClient
        BevelOuter = bvNone
        Padding.Left = 5
        Padding.Top = 5
        Padding.Right = 5
        Padding.Bottom = 5
        TabOrder = 0
        object LvLocalDes: TListView
          Left = 5
          Top = 60
          Width = 413
          Height = 238
          Align = alClient
          Columns = <
            item
              AutoSize = True
              Caption = 'Directory'
            end
            item
              Caption = 'Available Space'
              Width = 100
            end>
          MultiSelect = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = LvLocalDesChange
        end
        object tbMySendDirectory: TToolBar
          Left = 5
          Top = 30
          Width = 413
          Height = 30
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 97
          Caption = 'tbMySendDirectory'
          DisabledImages = frmMainForm.ilTb24Gray
          Images = frmMainForm.ilTb24
          List = True
          ShowCaptions = True
          TabOrder = 1
          object tbtnAddFolder: TToolButton
            Left = 0
            Top = 0
            AutoSize = True
            Caption = 'Select Folder'
            ImageIndex = 27
            OnClick = tbtnAddFolderClick
          end
          object tbtnManuallyInput: TToolButton
            Left = 101
            Top = 0
            AutoSize = True
            Caption = 'Manually'
            ImageIndex = 29
            OnClick = tbtnManuallyInputClick
          end
          object tbtnRemove: TToolButton
            Left = 182
            Top = 0
            AutoSize = True
            Caption = 'Remove'
            Enabled = False
            ImageIndex = 3
            OnClick = tbtnRemoveClick
          end
        end
        object Panel4: TPanel
          Left = 5
          Top = 5
          Width = 413
          Height = 25
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = '  Select directory for receive my computers files'
          Color = 7449788
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = False
          TabOrder = 2
        end
        object edtPaste: TEdit
          Left = 23
          Top = 248
          Width = 121
          Height = 21
          ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
          TabOrder = 3
          Visible = False
        end
        object Panel12: TPanel
          Left = 5
          Top = 298
          Width = 413
          Height = 24
          Cursor = crHandPoint
          Align = alBottom
          BevelOuter = bvLowered
          Caption = 'Drag and drop folders here from Windows Explorer'
          TabOrder = 4
          OnClick = Panel12Click
        end
      end
    end
    object tsFileShare: TRzTabSheet
      ImageIndex = 4
      Caption = 'Share path for my computer'
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 423
        Height = 327
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
        object lvSharePath: TListView
          Left = 5
          Top = 60
          Width = 413
          Height = 242
          Align = alClient
          Columns = <
            item
              AutoSize = True
              Caption = 'My Share Path'
            end>
          MultiSelect = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = lvSharePathChange
        end
        object Panel5: TPanel
          Left = 5
          Top = 5
          Width = 413
          Height = 25
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = '  Select share path for my computer'
          Color = 7449788
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBackground = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = False
          TabOrder = 1
        end
        object tbSharePath: TToolBar
          Left = 5
          Top = 30
          Width = 413
          Height = 30
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 97
          Caption = 'tbSharePath'
          DisabledImages = frmMainForm.ilTb24Gray
          Images = frmMainForm.ilTb24
          List = True
          ShowCaptions = True
          TabOrder = 2
          object tbtnAddShareFile: TToolButton
            Left = 0
            Top = 0
            AutoSize = True
            Caption = 'Select Files'
            ImageIndex = 2
            OnClick = tbtnAddShareFileClick
          end
          object tbtnAddShareFolder: TToolButton
            Left = 92
            Top = 0
            AutoSize = True
            Caption = 'Select Folder'
            ImageIndex = 27
            OnClick = tbtnAddShareFolderClick
          end
          object tbtnManualInput: TToolButton
            Left = 193
            Top = 0
            AutoSize = True
            Caption = 'Manually'
            ImageIndex = 29
            OnClick = tbtnManualInputClick
          end
          object tbtnShareRmove: TToolButton
            Left = 274
            Top = 0
            AutoSize = True
            Caption = 'Remove'
            Enabled = False
            ImageIndex = 3
            OnClick = tbtnShareRmoveClick
          end
        end
        object Panel3: TPanel
          Left = 5
          Top = 302
          Width = 413
          Height = 20
          Cursor = crHandPoint
          Align = alBottom
          BevelOuter = bvLowered
          Caption = 'Drag and drop files or folders here from Windows Explorer'
          TabOrder = 3
          OnClick = Panel3Click
        end
      end
    end
  end
  object FileDialog: TOpenDialog
    Options = [ofHideReadOnly, ofShowHelp, ofAllowMultiSelect, ofEnableSizing]
    Left = 96
    Top = 162
  end
end
