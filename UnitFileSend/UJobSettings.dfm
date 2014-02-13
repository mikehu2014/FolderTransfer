object frmJobSetting: TfrmJobSetting
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Job Settings'
  ClientHeight = 214
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    00007A7A7A009A87730086868600909090009D9D9D00B49D8400B7A18900B5A5
    9200ACACAC00B2B2B200BDBDBD00C7B09600C7B29B00D0BDA500E0CDB900C0C0
    C000CACACA00DAD8D800EAD9C800DFDFE000E3E1E000E8E5E500F2EEEA00F1F1
    F200F6F7F800F8F7F800F7F8F900000000000000000000000000000000000000
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
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000FFFFFF000000
    0B0101010101010101010101010000000B18181818181819181B191B03000000
    0214021402151415141414140400000F08020202060D181B191B1B1B05000208
    0F0707070D070214141414140900000E021818180702181B1B1B1B1B0A00020E
    0214141407020214141515140A0000170218181B07021A1B1B1B1B1B0A00020E
    170202020E0C0215151515150A0000170E170E0E07131B1B1B1B1B1B0B000000
    0214021402151515151515150B0000000B1B1B1B1B1B1B1B1B1B16140B000000
    0B1B1B1B1B1B1B1B1B100B0A0B0000000B1B16171B16171B16101B0B00000000
    101B10121B10121B10110B000000000010101810101A10101A1000000000C001
    0000C0010000C001000080010000000100008001000000010000800100000001
    000080010000C0010000C0010000C0010000C0030000C0070000C00F0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 181
    Width = 370
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 86
      Top = 2
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 208
      Top = 2
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 370
    Height = 181
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 10
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 10
      Top = 10
      Width = 350
      Height = 161
      Align = alClient
      Caption = 'When do you want to send'
      TabOrder = 0
      object img7: TImage
        Left = 16
        Top = 34
        Width = 32
        Height = 32
        AutoSize = True
        Picture.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
          00200806000000737A7AF4000000017352474200AECE1CE90000000467414D41
          0000B18F0BFC6105000000097048597300000AF200000AF2013D52F711000009
          5C4944415478DAD597797013E715C0DFEE6AB5ABD3B26CD9F8900CC618DB188C
          8DC311201EC2B88009D036100894FB480849C3240D010A532884A4741AC83899
          946628C9406886108E705F31908929870FC017C627D8C6B2E543966559AB3DFA
          762D880504D2F68F4E35F3CDEEEC77BCDF3BBEF79E084992E07FF923FE2F0088
          FE4B4CE1B6E8C1948AB49104194610408B82E8E205A1B1D3E3AD735FBE724B92
          BEEBF83902AD13B6C4AA54A4B7FAD8EAFAA702589E5B373A38C4FC0ACB6AC631
          2C13CDB06AA06915A8280A48A40051005EE0A1DBD37DC7E5729734395A0FD98B
          6A4F4AF65DB58F5524E9CD58AB2D3C47455373AB8EBC7BF12701C8E4D7836363
          6DDB432DA1F3189D1E579140922410CA93008AA400AD013482A8D52A6069FC0E
          2208BE6E70B6399D35754D278A0A2BB2A5F28F731F0827B2A2B2DE9C79DE62D2
          C7EDDDF77D0257B2FDD6630188A415A684C4B8B3317DADC3289A0567A747DE0D
          B48A5234074259D5038ADF49D91A082583840669A18F990515F05057DF040545
          D5C7F2CE14AE86E6D2A6510BE69D5BBB7C52F295C2AAEE4D6BBF48931C9F973E
          1660C0B43F7F336060DCAF195603ED4E37F03CA7981A65285650A30B18460DAC
          4603144D839713C12708A06369D06954A061556036B0101D66004AE4E1724139
          575E636F5F3C636C9835CA02DF9EBAD6BDEDFD7D6952D3DF1F05081DBB3E7350
          72FCE988A848B8D7D88CE66CF3E07C396AD9C0F9F8B68E76678E24FA38BD4E3F
          54AB6552CCE6A0D1969060C6146C4297A8404050835606A141CB5210A46721C4
          C000DA0D9053B1D4A5CBA55D1F6EFE472A5AA0FC1180A4E9DB0E24260DFC55B3
          A3151C4D2D372D11E167C3C32C0E2FE7639BDA3B4F5ECA9E9E1BE0AEA8F9B6E8
          E4B859FD6C110B12E3AD89B13111202833121875B4122372ACCAAE134511820C
          1AB874A5C4B56DC3EE54A96D4F650000D1678661C4E4896546A33EB2BECE7E2D
          2575F00186A1718148D4DBDBC8E2CA868FEB0E2C6F7F6C741304631AFDFBF9A3
          86C5AFCB1891608DB65AA0A3D38BC14A286E53E193E345B40C0B97AF9574666F
          FE32556ADD5D1100103E6EC3D09898E87C2FC7352626C5FFC91C6CF0F01CCFE3
          01BEB2AA7A6D6975DDE7F66F577A9F982F88D1A17153A66D9C3A3E65E933A903
          685737DF0381B7C7E5E141A765A0B0B0CC8500698F00F49FBA3583A2A8F36673
          70F6C4CCB1471D2D6D18F86437489290575263B95171E7A0F3C4DBFC53931641
          048D5BBAE3D68AF999E14E142ADF141F2F417B970FDDC24271D12D57F67B7BD3
          A4968700FA667D908541F2D5F8F1CF4E8B0C0F6DF3767B7982A4BC2089DCD5E2
          6AFDB9DCBC12297793F464E1A9C6318B5E39F3EA9C71C34592069F4F007983DB
          2B280026BD062ACA2A9CD91BF7A449CE3D550100B6495B5E64D4EA55B70FFF2E
          63F3FE5B5A2DABF51A0D0CB724238C5FF17E297CB226F129C209D598859F1E5F
          363B2353BE15AE2E2F0621091E9F086E0F02787C60366AA0ACE856EBF6B776A4
          4AC237771E7681AAEAC8D782245DFD59D5297ECA56A2FCC82A65AD65FC261D43
          11FB7FF15CF2C4F4E41870777118F98492AF7841024C13784525A0D514E45E2B
          F71DFDEA7C3C5FF7594D0040CC84CD6635CBFC51C3A84CCA3D0AD00E3F48A0A4
          627CA79C2E8F841ABF5575F45DBB62BDAC0F2C3445FC065F5BDA3B3C18B80411
          B0DF7F9E04124E914D64A8F1C2BD7D3D01FD00808E5CDC6FCADCCC8AF4618924
          CF0B4A7ED7A849E529E11122AE635183E339D7E1C20F656FB03AE693DAE36BFE
          ED5A1EFBC2D6E74541B85E73624D4B000011B6B0EFCBCBA7E427A72405CBC163
          C4B4AAD750C060D191CDA7C7EC76F19FC5F0F5912B2B1B73FEF0D1938424CED9
          45C44585E99E4D4BE23D42178B1789D16AF4AAFA7B4D8613A72E1C460567D79E
          589B1708605D12376BC1A4BCB4F464A380163020809641ED51B81A352F2EADE1
          BFD8FFC3070D67D7AF7F6A7CBCF42913131331327D50AC1DFB06066B051B1262
          122F5CB836B2BCA26A2B4112C3AA8FAE2E0904885E1C377BF1E4FC11C3071B04
          A1C70218C48AF9B9EE2EF868E7A9BBA507DF49C4F5EEA701C4CDFA9BDE1A113A
          3365A0AD4EE045B52889AC46A7E74F9FB9F8B6CFC78D7275B806D69D5E1F9807
          88A8C5717396BE903F66D41083844545F6BFEC77D9FC722AAD6F6C914E7E77BD
          F85241F91AA1E02F479F0410F3D25F83136C7D16C55AC33ABCBCA8D169B57CFE
          F5E2246C5C5E2309A931EFFCF78962CD6E672040E4A2FEF3974F2DC8189D62C0
          20C10CD6235C86E00551694A9C1D5D5070A3126E96D51EAAACAADFCA157C78E9
          710043E6EF1AD4CF1AF6727090D18BC580ABA9BE63B5DB9BE7609363AABF5B7F
          B170EF8A8C0737E40140C4A2B8456FFCB260FC98217AAF8FC7BA4F4137270096
          614CA522746226EBF2F2781D09686A6E87AA9A0668B43B4EB7B6B6EF6BBCDB78
          1A6EEF68C0B3946298B1F2C06C838E49F2B8BBD4CDF6E6411874197D636D3A09
          DBB7A2A2D2DFDE3DB92EFB5180E865094B5E9B9C9F993154237BBEBAD60EC126
          033058C19ADADC98D938E8C2DCDE8919CD83C59D47A82EB7075C1D1DE072757A
          DD9D9DC51CC755A2A574B49A89C1BB8FA5948C50B3ACC1623183C9A083DBE515
          8EE2FCFC046FC9672D8F03485C8A0033A68C6473724B61E7DEB387E2FB475847
          A4270D8B8C08834EAC6C8E7614E8E614886E8E57B293DC6460A463DEF76177E4
          031E2D26372640504AE3A6611930610ABED7700F2ACB2BE7359EDFB43B2049FD
          980766A6AC5CBBF06A58A889CEDE7964EFBDF35B5EC5CFA1A6675E5F963C78D0
          DCD8FEB628A33108733B403BD67A0E01E4DBA20C8C15091B0E395EE4C6431E02
          0EB921D160ABD6E670405D55C586BA9C2D1BE5DE01CFC553E4E5920249E28B68
          4E5B3A7248FAF04B2D8ED6C34507572FC1EFD80E83BC1853261369487E71B235
          6E5056487864B2DE6852D1B41A7762A72381D29A0B428F5B64E1F87F012DE103
          11FBC9CEB6E6227B75C9D6D6825D07FCE7C9259D93CF45B9D20300DBF3AB2608
          A4F69D86731B67E137150E03C87E0450CB6BFC1B75A42535D1149930C4141E3B
          4C6334DB546A2688A2542CC230186C82E0E3DCD8C8B67ADD1D375DF6CA632D85
          5FE6E03E875F38E7D7FE4700C50C583B2C43A6073B4A8F0992CF23FB44E787A0
          7B0D957FC820782F955E5303867EA18CC1A253B17A1AD5F7FABA5A9D5CD38D3A
          9C6BF70BA2FDEBEF0B562064A50362E041501084BA97F0FB42A95E83F40FD97A
          921F481E825F10F8E7C55E73BC1F80BFEFFB4782F0E11FD15351EF0BA3FC027B
          0BEF5D7225FF107B3D453F9432F79372FED37FC744AF92FFDFFCC3FE17D49BAB
          FD7DC0682C0000000049454E44AE426082}
      end
      object Label1: TLabel
        Left = 63
        Top = 43
        Width = 49
        Height = 13
        Caption = 'How often'
      end
      object cbbSchedule: TComboBox
        Left = 121
        Top = 40
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Manual'
        OnSelect = cbbScheduleSelect
        Items.Strings = (
          'Manual'
          'Every few minutes'
          'Every few hours'
          'Once a day'
          'Once a week'
          'Once a month')
      end
      object pcAutoBackup: TRzPageControl
        Left = 50
        Top = 67
        Width = 254
        Height = 77
        ActivePage = tsHour
        ShowCardFrame = False
        TabOrder = 1
        FixedDimension = 0
        object tsManual: TRzTabSheet
          TabVisible = False
          Caption = 't0sManual'
          ExplicitWidth = 0
          ExplicitHeight = 0
        end
        object tsMin: TRzTabSheet
          TabVisible = False
          Caption = 't1sMin'
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label2: TLabel
            Left = 13
            Top = 5
            Width = 50
            Height = 13
            Caption = 'How many'
          end
          object cbbMin: TComboBox
            Left = 71
            Top = 2
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 5
            TabOrder = 0
            Text = '30'
            Items.Strings = (
              '1'
              '5'
              '10'
              '15'
              '20'
              '30')
          end
        end
        object tsHour: TRzTabSheet
          TabVisible = False
          Caption = 't2sHour'
          object Label7: TLabel
            Left = 13
            Top = 5
            Width = 50
            Height = 13
            Caption = 'How many'
          end
          object cbbHour: TComboBox
            Left = 71
            Top = 2
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 0
            Text = '1'
            Items.Strings = (
              '1'
              '2'
              '3'
              '4'
              '5'
              '6'
              '12')
          end
        end
        object tsDay: TRzTabSheet
          TabVisible = False
          Caption = 't3sDay'
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label4: TLabel
            Left = 13
            Top = 5
            Width = 50
            Height = 13
            Caption = 'What hour'
          end
          object cbbDay: TComboBox
            Left = 71
            Top = 2
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 9
            TabOrder = 0
            Text = '9:00'
            Items.Strings = (
              '0:00'
              '1:00'
              '2:00'
              '3:00'
              '4:00'
              '5:00'
              '6:00'
              '7:00'
              '8:00'
              '9:00'
              '10:00'
              '11:00'
              '12:00'
              '13:00'
              '14:00'
              '15:00'
              '16:00'
              '17:00'
              '18:00'
              '19:00'
              '20:00'
              '21:00'
              '22:00'
              '23:00')
          end
        end
        object tsWeek: TRzTabSheet
          TabVisible = False
          Caption = 't4sWeek'
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label5: TLabel
            Left = 13
            Top = 5
            Width = 46
            Height = 13
            Caption = 'What day'
          end
          object Label6: TLabel
            Left = 13
            Top = 34
            Width = 50
            Height = 13
            Caption = 'What hour'
          end
          object cbbWeek1: TComboBox
            Left = 71
            Top = 2
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 0
            Text = 'Sunday'
            Items.Strings = (
              'Sunday'
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
              'Saturday')
          end
          object cbbWeek2: TComboBox
            Left = 71
            Top = 31
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 9
            TabOrder = 1
            Text = '9:00'
            Items.Strings = (
              '0:00'
              '1:00'
              '2:00'
              '3:00'
              '4:00'
              '5:00'
              '6:00'
              '7:00'
              '8:00'
              '9:00'
              '10:00'
              '11:00'
              '12:00'
              '13:00'
              '14:00'
              '15:00'
              '16:00'
              '17:00'
              '18:00'
              '19:00'
              '20:00'
              '21:00'
              '22:00'
              '23:00')
          end
        end
        object tsMonth: TRzTabSheet
          TabVisible = False
          Caption = 't5sMonth'
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label9: TLabel
            Left = 13
            Top = 5
            Width = 46
            Height = 13
            Caption = 'What day'
          end
          object Label10: TLabel
            Left = 13
            Top = 34
            Width = 50
            Height = 13
            Caption = 'What hour'
          end
          object cbbMonth1: TComboBox
            Left = 71
            Top = 2
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 0
            Text = '1'
            Items.Strings = (
              '1'
              '2'
              '3'
              '4'
              '5'
              '6'
              '7'
              '8'
              '9'
              '10'
              '11'
              '12'
              '13'
              '14'
              '15'
              '16'
              '17'
              '18'
              '19'
              '20'
              '21'
              '22'
              '23'
              '24'
              '25'
              '26'
              '27'
              '28'
              '29'
              '30'
              '31')
          end
          object cbbMonth2: TComboBox
            Left = 71
            Top = 31
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemIndex = 9
            TabOrder = 1
            Text = '9:00'
            Items.Strings = (
              '0:00'
              '1:00'
              '2:00'
              '3:00'
              '4:00'
              '5:00'
              '6:00'
              '7:00'
              '8:00'
              '9:00'
              '10:00'
              '11:00'
              '12:00'
              '13:00'
              '14:00'
              '15:00'
              '16:00'
              '17:00'
              '18:00'
              '19:00'
              '20:00'
              '21:00'
              '22:00'
              '23:00')
          end
        end
      end
    end
  end
end
