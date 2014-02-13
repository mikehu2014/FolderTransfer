object frmFreeEdition: TfrmFreeEdition
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 5
  Caption = 'Edition Feature Comparison'
  ClientHeight = 237
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000B3354700F4365B00F2375D00F6375E00F83A6200FF3B6600FF3C6600FF3E
    68009D4751009A50570092545B009D515A00A0505900A4505B00AC606900AD6F
    7B00AD737900D05F7800FF426B00FF456E00FF497200F7567900EA677F001397
    2200149723001A972800208A2D0013A6220016A2250014B6240014B8240021B8
    2F0027AB350024C3340036BF44004A98530043A84E0052AC5A006E83710066B4
    6D006EAD740050CA5C00CA708400D4748900EA819800E491A300000000000000
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
    00000000000000000000000000000000000000000000251C2700000000000000
    0000000000002A1F1C0000000000000000000000000000201F1A000000002419
    191919191919191C1F1F1B000000221F1F1F1F1F1F1F1F1F1F1F1F0000000000
    00000000000000211F1F0000000000000000000F0100001F1F29000000000000
    000011070800231F2600000000000000000007072B0000280000000000000000
    00030703090A0A0A0A0A0D0D0C00000017080807080808080808080808100000
    00150804122C2C2C2C2C2C2C2C000000000014070B0000000000000000000000
    00002E140300000000000000000000000000002D16000000000000000000FFFF
    0000FF1F0000FF1F0000FF8F00000007000000070000FF8F0000F98F0000F11F
    0000F1BF0000E0010000C0000000E0010000F1FF0000F1FF0000F9FF0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object plEditionCompare: TPanel
    Left = 0
    Top = 0
    Width = 585
    Height = 237
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lvEditionCompare: TListView
      Left = 0
      Top = 0
      Width = 585
      Height = 202
      Align = alClient
      Columns = <
        item
          Caption = 'Feature'
          Width = 100
        end
        item
          Caption = 'Feature Limit'
          Width = 280
        end
        item
          Caption = 'Free Edition'
          Width = 80
        end
        item
          Caption = 'Registered Edition'
          Width = 110
        end>
      Items.ItemData = {
        05040300000400000001000000FFFFFFFFFFFFFFFF03000000FFFFFFFF000000
        000D460069006C00650020005400720061006E00730066006500720027530065
        006E00640020006C0061007200670065002000660069006C0065007300200028
        0045006100630068002000660069006C0065002000730069007A00650020006C
        0069006D00690074002900384EFC15053100300020004D004200B030FC150955
        006E006C0069006D006900740065006400B05AFC1501000000FFFFFFFFFFFFFF
        FF03000000FFFFFFFF000000000D460069006C00650020005400720061006E00
        73006600650072002A460069006C00650020007100750061006E007400690074
        00790020006C0069006D0069007400200069006E0020006100200066006F006C
        00640065007200200074006F002000620065002000730065006E0074002883FC
        150235003000B835FC150955006E006C0069006D0069007400650064004882FC
        1502000000FFFFFFFFFFFFFFFF03000000FFFFFFFF000000000C460069006C00
        65002000530068006100720069006E0067003844006F0077006E006C006F0061
        00640020007300680061007200650064002000660069006C0065007300200066
        0072006F006D0020006F00740068006500720073002000280045006100630068
        002000660069006C0065002000730069007A00650020006C0069006D00690074
        002900405AFC15053100300020004D0042008082FC150955006E006C0069006D
        0069007400650064004053FC1502000000FFFFFFFFFFFFFFFF03000000FFFFFF
        FF000000000C460069006C0065002000530068006100720069006E0067003746
        0069006C00650020007100750061006E00740069007400790020006C0069006D
        0069007400200069006E0020006100200066006F006C00640065007200200074
        006F00200064006F0077006E006C006F00610064002000660072006F006D0020
        006F0074006800650072007300282FFC150235003000604BFC150955006E006C
        0069006D006900740065006400A84EFC15FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFF}
      ReadOnly = True
      RowSelect = True
      SmallImages = ilEdition
      TabOrder = 0
      ViewStyle = vsReport
    end
    object Panel1: TPanel
      Left = 0
      Top = 202
      Width = 585
      Height = 35
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object btnBuyNow: TButton
        Left = 202
        Top = 6
        Width = 75
        Height = 25
        Caption = 'Buy Now'
        TabOrder = 1
        OnClick = btnBuyNowClick
      end
      object btnClose: TButton
        Left = 312
        Top = 6
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Close'
        TabOrder = 0
        OnClick = btnCloseClick
      end
    end
  end
  object ilEdition: TImageList
    Left = 240
    Top = 160
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003772240000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000018799C001879
      9C0018799C0018799C0018799C0018799C0018799C0018799C0018799C001879
      9C0018799C0018799C0018799C00000000000000000000000000000000000000
      0000000000000000000000000000000000003772240037722400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000218AAD00107DA50031A2
      C60031A2C60031A2C60031A2C60031A2C60031A2C60031A2C60031A2C60031A2
      C60031A2C60031A2C600219EC60018799C00117BA80056A9CC00117BA8001663
      85002D5971004A5D6700666666006E6E6E00377224000FA41C00377224000000
      0000000000000000000000000000000000004433330059333300000000000000
      000000000000000000001D285800344D86003A589E002653B300365371006666
      6600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60063CBFF001092BD009CFB
      FF0052BADE0052BADE0052BADE0052BADE0052BADE0052BADE0052BADE0052BA
      DE0052BADE00A5E7FF0031A2C60018799C00117BA8009FCFE20079D9FF005BCB
      F50046BCE900006600000066000000660000006600001BB436000FA81C003772
      2400000000000000000000000000000000004A4A4A003B333300333333003333
      3300205FC5002653B3002673D9002653B3001744AA00236BD0003499FF002A85
      E800344D86000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60063CBFF002196BD009CF3
      FF00D6D3BD00D6D3BD00D6D3BD00D6D3BD00D6D3BD00D6D3BD00D6D3BD00D6D3
      BD00D6D3BD00D6D3BD0031A2C60018799C00117BA80070B7D600ACECFF007AE0
      FF007AE0FF000066000060F9930050E9830040D9730028C150001BB436000FA8
      1C0037722400000000000000000000000000555555004A4A4A00C8C8C8002B2D
      460076BCFD0059ABF9003F90EC00236BD0002080D600173A990070B8D30076CA
      E50087C8FF005374BC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60063CBFF002196BD009CF3
      FF00D6D3BD00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEB
      DE00FFEBDE00D6D3BD0031A2C60018799C00117BA8004EA8D200D9F9FF0085EB
      FF0085EBFF000066000060F9930050E9830040D9730033CC650028C150001BB4
      36000DA019001670160000000000000000006666660077777700DBDBDB008C98
      9800BCE9FF00BCE9FF00BCE9FF00CBECF5007488950070B8D30042A8CA001976
      A300748895007488950000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60063CBFF0031A2C6009CFB
      FF00D6D3BD00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEBDE00FFEB
      DE00FFEBDE00D6D3BD0031A2C60018799C00117BA80058B5E200AFD9E9008FF5
      FF008FF5FF00006600000066000000660000006600003ED7710033CC65001DAA
      3B0014631F000000000000000000000000002046590020465900333333003333
      33007486AC005D9099007486AC007488950086ECFF008AF0FF008AF0FF0061D9
      EC0054808F000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C6006BD3FF0031A2C6009CFB
      FF00D6D3BD00FFEBDE00FFD7AD00FFD7AD00FFD7AD00FFD7AD00FFD7AD00FFD7
      AD00FFEBDE00D6D3BD0031A2C60018799C00117BA80075B7D80066A9C600B9FF
      FF0099FFFF0099FFFF0099FFFF0099FFFF00377224004BE47E0022A53F003772
      2400297E9D000000000000000000000000000099CC0074D9FF000080B300A5F8
      FF0093F9FF0093F9FF0093F9FF0093F9FF0093F9FF0093F9FF0093F9FF00A2F3
      FC003784AA000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C6007BDFFF0031A2C600FFFB
      FF00FFE7D600FFFBFF00FFFBFF00FFFBFF00FFFBFF00FFFBFF00FFFBFF00FFFB
      FF00FFFBFF00FFE7D60031A2C60018799C00117BA8007EBDD90051849B00CAEC
      F500E3FFFF00D9F9FF00C6FFFF00B9FFFF00377224002DA3440037722400D6FF
      FF0086CCDF003D57630000000000000000000099CC0074D9FF000080B300CCFD
      FF009EFFFF009EFFFF009EFFFF009EFFFF009EFFFF009EFFFF009EFFFF00B4FB
      FF0080CDE6001A80AC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60084E7FF0031A2C60042A6
      BD009C827300CEB69C00CEB69C00CEB69C00CEB69C00CEB69C00CEB69C00CEB6
      9C00CEB69C009C82730031A2C60000000000117BA8008EC9D900A79A90009FA6
      990070A4AF0070AABE0080BCD200ECFFFF003772240037722400B7F2FF00F0FF
      FF00E3FFFF002C6F8E0000000000000000000099CC007BDBFF0042A8CA009ED8
      EC00CBF6FF00DFFFFF00D2FEFF00BAFFFF00BAFFFF00BAFFFF00BAFFFF00BCE9
      FF00DFFFFF003784AA0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C60094F7FF008CF7FF0094F7
      FF009C827300FFEBDE00FFF7E700FFF7E700FFF7E700FFF7E700FFF7E700FFF7
      E700FFF7E7009C8273000000000000000000117BA80099D2D900A79A9000FFCF
      9E00FFCF9E00FFD1A300CFB9990060A6C30037722400AFD2E200B3E2F200FEFE
      FE00FEFEFE0070B3CF0000000000000000000099CC0096E2FD007EE4FE0065C9
      EA0042A8CA0042A8CA0070B8D300E3FAFF00E3FAFF00DFFFFF00D2FEFF00CBF6
      FF00F2FFFF001A80AC001A80AC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000031A2C600FFFBFF009CFBFF009CFB
      FF009C827300FFF7E700FFDBB500FFDBB500FFDBB500FFDBB500FFDBB500FFDB
      B500FFF7EF009C8273000000000000000000117BA800A1D7D900A79A9000FFD1
      A300FFCF9E00FFD4A800FFCF9E00FFD1A300E4B8A700609FAC0039A9C9002C6F
      8E005497B30073A9C30000000000000000000099CC00A2F3FC008AF0FF0093F9
      FF008AF0FF008EF5FF0086ECF20042A8CA00349AC100349AC100BFE5F700D5EF
      F90000000000F2FFFF001A80AC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000031A2C600FFFBFF00FFFB
      FF009C827300FFFBF700FFFBF700FFFBF700FFFBF700FFFBF700FFFBF700FFE7
      CE00FFE7CE009C8273000000000000000000117BA800BED1D600A79A9000FEFE
      FE00FEFEFE00FFF7EF00FFEBD700FAE3CC00E5B5A70084A5AC005CB9D60089A2
      AF00000000000000000000000000000000000099CC00B4FBFF009EFFFF0093F9
      FF009EFFFF00B4FBFF00ADF3FC009EFFFF0093F9FF0086ECF200349AC1001A80
      AC001A80AC001A80AC001A80AC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000031A2C60031A2
      C6009C827300F7FFFF00FFDBB500FFDBB500FFDBB500FFDBB500FFFBFF00FFA6
      2900FFA62900FFA62900000000000000000000000000117BA800A79A9000FEFE
      FE00FEFEFE00FEFEFE00FFF9F400FAD09800DD984A005F737C007DA3B7000000
      0000000000000000000000000000000000000099CC00CCFDFF00AAFEFF009EFF
      FF00C5F9FF0078CBD90070B8D30080CDE600B3E1F100C5F9FF00CCFDFF00008C
      BF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009C827300FFF7EF00FFFBF700FFFBF700FFFBF700FFFBF700FFFBF700FFB6
      5A00FFB65A000000000000000000000000000000000000000000A79A9000FEFE
      FE00FEFEFE00F8F7F600F8F7F600F9DEB3009880690000000000000000000000
      000000000000000000000000000000000000000000000099CC000099CC000099
      CC000099CC00000000000000000000000000008CBF00008CBF00008CBF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00009C8273009C8273009C8273009C8273009C8273009C8273009C827300FFB6
      5A00000000000000000000000000000000000000000000000000A79A9000A79A
      9000A79A9000A79A9000A89C9400A79A90000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFF7FFFFF0000C001FF3FFFFF0000
      8000001F3C0F00000000000F0007000000000007000300000000000300030000
      0000000700070000000000070007000000000003000300000001000300030000
      000300030001000000030003000900008003000F00010000C003801F000F0000
      F007C07F871F0000F00FC0FFFFFF0000}
  end
end
