object frmFreeTips: TfrmFreeTips
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Folder Transfer(Unregistered)'
  ClientHeight = 352
  ClientWidth = 538
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
  object Label13: TLabel
    Left = 8
    Top = 16
    Width = 248
    Height = 25
    Caption = ' Unregistered free edition!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 107
    Width = 538
    Height = 245
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object plRestoreTitle: TPanel
      Left = 0
      Top = 0
      Width = 538
      Height = 25
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = ' You may be interested in the software'
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
      TabOrder = 0
    end
    object pcMain: TRzPageControl
      Left = 0
      Top = 25
      Width = 538
      Height = 220
      ActivePage = tsBackupCow
      Align = alClient
      BackgroundColor = clBtnFace
      ParentBackgroundColor = False
      ParentColor = False
      ShowCardFrame = False
      ShowFocusRect = False
      ShowFullFrame = False
      ShowShadow = False
      TabOrder = 1
      FixedDimension = 0
      object tsBackupCow: TRzTabSheet
        TabVisible = False
        Caption = 'tsBackupCow'
        object pcBackupCow: TRzPageControl
          Left = 0
          Top = 81
          Width = 538
          Height = 139
          ActivePage = tsNetworkTools
          Align = alClient
          BackgroundColor = clBtnFace
          UseColoredTabs = True
          ParentBackgroundColor = False
          ParentColor = False
          ShowCardFrame = False
          ShowFocusRect = False
          ShowFullFrame = False
          ShowShadow = False
          TabOrder = 0
          FixedDimension = 0
          object tsBackupAndSync: TRzTabSheet
            TabVisible = False
            Caption = 'tsBackupAndSync'
            object Label3: TLabel
              Left = 16
              Top = 22
              Width = 139
              Height = 16
              Caption = 'Backup and Sync Tool'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label4: TLabel
              Left = 16
              Top = 46
              Width = 497
              Height = 48
              Caption = 
                'Backup and sync files between computers.'#13'Automactically back up ' +
                'files to multiple targets including network or local folders, US' +
                'B, external hard drives, and anywhere on your network.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
              WordWrap = True
            end
            object lkBackupAndSync: TLinkLabel
              Left = 16
              Top = 105
              Width = 62
              Height = 17
              Caption = '<a> Read more </a>'
              TabOrder = 0
              OnLinkClick = lkBackupAndSyncLinkClick
            end
          end
          object tsNetworkTools: TRzTabSheet
            TabVisible = False
            Caption = 'tsNetworkTools'
            object Label5: TLabel
              Left = 13
              Top = 24
              Width = 168
              Height = 16
              Caption = 'Network Backup Software'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label6: TLabel
              Left = 13
              Top = 56
              Width = 520
              Height = 32
              Caption = 
                'Backup files to your networked computers.'#13'Remote backup over Int' +
                'ernet/Intranet. Support breakpoint transmission. No ftp is requi' +
                'red.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
            end
            object lkNetworkTools: TLinkLabel
              Left = 13
              Top = 105
              Width = 62
              Height = 17
              Caption = '<a> Read more </a>'
              TabOrder = 0
              OnLinkClick = lkNetworkToolsLinkClick
            end
          end
          object tsCloudBuilder: TRzTabSheet
            TabVisible = False
            Caption = 'tsCloudBuilder'
            object Label7: TLabel
              Left = 11
              Top = 16
              Width = 346
              Height = 16
              Caption = 'Free Software to Build Internal Private Cloud Storage'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label8: TLabel
              Left = 11
              Top = 43
              Width = 396
              Height = 48
              Caption = 
                'Set up a private dropbox to implement internal private cloud bac' +
                'kup. '#13'No worry about public cloud security anymore.'#13' Never pay m' +
                'onthly subscription fees.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
            end
            object lkCloudBuilder: TLinkLabel
              Left = 11
              Top = 105
              Width = 62
              Height = 17
              Caption = '<a> Read more </a>'
              TabOrder = 0
              OnLinkClick = lkCloudBuilderLinkClick
            end
          end
          object tsFileSearch: TRzTabSheet
            TabVisible = False
            Caption = 'tsFileSearch'
            object Label9: TLabel
              Left = 13
              Top = 16
              Width = 181
              Height = 16
              Caption = 'Easy File Search and Access'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label10: TLabel
              Left = 13
              Top = 43
              Width = 400
              Height = 48
              Caption = 
                '- Search all backups and sources files with a powerful filter'#13'- ' +
                'Download or obtain files from any user'#13'- View each file'#39's detail' +
                'ed information including its owner and location'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
            end
            object lkFileSearch: TLinkLabel
              Left = 16
              Top = 105
              Width = 62
              Height = 17
              Caption = '<a> Read more </a>'
              TabOrder = 0
              OnLinkClick = lkFileSearchLinkClick
            end
          end
          object tsDataTransfer: TRzTabSheet
            TabVisible = False
            Caption = 'tsDataTransfer'
            object Label11: TLabel
              Left = 13
              Top = 12
              Width = 255
              Height = 16
              Caption = 'Data Transfer Viewer and Management'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label12: TLabel
              Left = 13
              Top = 36
              Width = 336
              Height = 64
              Caption = 
                '- View real-time data transfer status'#13'- Adjust download/upload s' +
                'peed, simultaneous file amount'#13'- Pause, stop or resume any data ' +
                'transfer or backup tasks'#13'- Forbid data transfer to any remote lo' +
                'cations'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Tahoma'
              Font.Style = []
              ParentFont = False
            end
            object lkDataTransfer: TLinkLabel
              Left = 16
              Top = 113
              Width = 62
              Height = 17
              Caption = '<a> Read more </a>'
              TabOrder = 0
              OnLinkClick = lkDataTransferLinkClick
            end
          end
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 538
          Height = 81
          Align = alTop
          BevelEdges = [beBottom]
          BevelKind = bkTile
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 1
          object Image1: TImage
            Left = 8
            Top = 9
            Width = 64
            Height = 64
            Picture.Data = {
              0954506E67496D61676589504E470D0A1A0A0000000D49484452000000400000
              00400806000000AA6971DE0000000467414D410000AFC837058AE90000001974
              455874536F6674776172650041646F626520496D616765526561647971C9653C
              000016C94944415478DAD55B09741455BAFE2A9DCE4EC84A2010088100B2CAA2
              28B20ACAB0282AE273F0C128F360D4D1D191199DF13D9DD151DF1BCF7300477D
              A3A38E2802B208C80E225BD865872484EC21FBBE7577BA3B5DF3FF75AB52D59D
              EE4E6098779C7BCE4D55AAAB6EDDEFFBF75B55922CCBE0264912AEA74D9C78F2
              6E97CBDE1F905324C93C824688A27DC9640A1D7B5D0351733A9B4FD1FD692AAE
              FAD6D6E6CB346EBECBD5927BEAD4DC7DF4730BF5D6EB1DD35FD3302BB83B43C0
              840927FAD2662E5D3A3A202068BC24997ADDCC09F96B4446A9D3D974BCB5D572
              B1B1F1E2E6F4F4DF64A8A4C8373A66A70860D09214B094C0DE4F3DC9DF803D7A
              84202E2E10BD7B072332D20C9309E8D6CD8CE8E820D86C322A2B018B45223032
              499BC4D92AA1B0D0828A0A17EDF36F0EB4B4B45077D2EF2D1D10D25266B7D7EE
              ADA939F45E56D69B97E890F57AC9F04BC08409274711E0D7020202677BBB3821
              2108A3474760F0E03005F8D0A1A1342906A70CADECF3903CAED817A0AF5E051A
              1A2465DFE180B2BD7285C1CB045CA20ED8ED62BFB9D906ABD54AFBCD3446238D
              E1F00AC4E1A83B575D7DE895CCCC570ED2BFCDCCCF3F44C0C489DFBF1E10607E
              C5F3823E7DC2316B5657DC7557244936481DC40852FCCF04B074B59B6804F06F
              999982000DBCC321232B4B4253130387428020416CF9779B4D23C64E633560D0
              A026E4E636B403D4D070E98B33671E7B99762BA8DB6F8880C993CFBC2B4981CF
              EAA79908781C9E7C320A63C6047B0CA00F622480B5C0480C379B0D282991515D
              2DA4CF9D41959602555570937C47FBDC7AF67490F6D5E0C2856A224FF78D0D0D
              17769F39B380E75F08E123AE8F8029532EB41D95A40822A4179E79C6AC684660
              2094CEB6CD96E20DBC51FDAD5659B179966E6D2D54E0020C83E6CEC4741638EF
              B34618DB0B2FB870E9D2351C3952DF76ECE4C9394F5A2CF9DB68B7047EFC825F
              020203BB929DF7C11B6F00C1C132FD2F41F38F9A74357FC10E8CA5CE5BE1CCE4
              36293B9D9202BAB9595208A9A779D6D70B13D0545D745FC0DDCD82C7F26C5BB6
              4878FFFD82361232337FB7B6AC6CF33BB47B8EBAF38608484EEE4FDE3B144B96
              488AC44D2619010102704080AEE6460234200CDC6E67C042C2DC853D7BDF1AA5
              DB91267004F16C8B174B346F1B6DB394FF33325EDE5A5EBE7D05ED1EA36EB921
              02162C188EA34781E79E13E059DA9E1AC0AACE60B5B0A67506CFE01890E7BE26
              710DAC370DF024C6B86F9CB45103CC6660DEBC0B2A01BFDD5E5EBEE33DDA4DA3
              DE7443047CF2C93045FD535224CC9ECD52E7C35A8E20B7853CEE461218A431C4
              7992A0495A90A16F7D69803886B67D4FFCAFBE2AE6B77933B062C54D2460DFBE
              612828602284139B3C19E8D5CB78B1A6FA22E4F1BE510BBC13A049BF2393F0E6
              17DCED7FD428094B97CA484D95F0EDB7C0EAD532F2F22EDE5C02B8F1CD0F1C90
              70F0A0706EC38649141665848549ED483012A01321BB698506B4BD49E86A6FD4
              0A23310909B22288471F9528F91249D536F2F5972F8B7B1514DC440DD8BB77B8
              F2BF507D71839C1CE0FC79896E20425C7CBC44A92F101A0A4A7DF5F4D608DED3
              2C8C1A6124C36802DA96358EC966D26FBD150A680EA7972EB15080F27277B2FF
              2904786B2C710E65A5A532F2F3B58948A8AB13640405C9E49474A7A96988E638
              35DFC13D2E4E4648089408D3AD9B4E6A7CBCB8B6A808282B038A8B41D99F4C75
              83E445CBC4B6B0F0FF8900F741C4D6680A3C6126439310274F4C0A6FB93139EC
              B58383A16C35101C6D9858BE967B7535BC9A9511B4B1DF5402F6EC110478AB8E
              65AFB995BB872E299194F8CFA408A9CB4A0DD0D0E0DB5F0813F20EAE7D97DB11
              515474139DA04640E79A3B784E7F2B2A643533D455BEB252D8B63661CFFC41CF
              1C75801D75CDBF702F2EBEA91AC051A0A3D5A1F6719901B36F600727EC5E4895
              43294BDFD3511AC3670B39D6D2E256D4563A5151D2AA4C30345C54A82121948E
              92430E0C0984640AA06E6AA7012525379180DDBB87E93F4AC68B7CD3C1AACE52
              66B002B89E1F70E1C3933502660D68AC67C9B5A2EC1A0377D131561719651607
              AA5B5CA874B860216DE86996114729781C3B1297584009EE1280A09060048405
              2120C44CC4DF44133012D051D34A5E06D9D828BB499EC7E51298FD81069A4DA4
              84001717098957589CC86874A0C2DE4C9E308F4E4AF773370A33724FBA513FF4
              9602308834422977483BEC0135148F5DC8B87A1308D8B973785B0EE00F343706
              C6362F9C9E3BF8BA3A5ED911C099A02B1904BAC885A36536E43431E0E37472B9
              6FBC5D291988EA4EB130936CC40716675F04D4A6E216B911F1144932AC378980
              CE344E4CB8C465123C97C0389471199C93E3426EB68C1DE936643757101B54A4
              B93CE6151C4585C724A40E4BC09014604022854F0A91A41868A04CB19E7A0DF9
              95E3D9E4F88A7229E6515656522CD24837C9C4D24DBFCF46EDF1BFA0F2C0E774
              A41A3E96C8FC12B065CB308ADDDE9D20A7A90C8C010A497B2E8B09F0E994B16D
              3DD2823D859418B41E6D0F3A610412C68CC59C3B81A149E423682C327BD888CC
              D040D1C3A8770DA2BA9694A49814E6080D55C529B3535D7AAAA8103931674CAC
              6A6E64D8CBE16CDA8BFA8B7F46E1EA760BA77E0978F7DDE14AE2C2898A3B7801
              DA38881138DBFFE1132E2CDFD18CA29AEF48353CD43B61089226DC85D96329CD
              8D519D25F5DE114012F53ED4E32933AC26732AA79ED740A92F6999455D0FBD25
              5A6804FFBE9F14E0588145AFB298F56BD738231279B6B1B5DAB2E1A85D8FE6FC
              8DC8FF8CAA07B4C80606DA11B06C996E029EBE40B37F6D094CAC034A484F9771
              344DC687974ED184CEEB1744920D0F9D8C07A7472299409BE8F230227618EDA7
              740152BB92F048EAA524C072AB006827E1B610D136EA1B725553700853A8236C
              7144D29DDD807134B49D8EAF22BF79393D4F5F816968105E99B70E8FD5E4D33F
              BB8DFE5E25CCF53E0978E71DF728605C0CF124229BECF2E07E0E692EC5D8D614
              10010E8AC94903113E7E12260D2113A7301E44616C5C023086F2FCA1D1025025
              01AEB2E9E3F3828FC3250860F05622661945B72687E84C00FFDEB606A7E4DAA1
              B88BC61D4C6336D158DB898C86F463BA6634368ACEC408027ECD564E98AFFA24
              E0EDB787FB2580CFE774F7E82117AE95C8DA200A016B0BBF1704CC5F822164DB
              FD22818503801F91436FE29C9D5C418D4D2CAD055337535757DB147368933E9D
              6BA1ED0B84A599B058387172C9FA628446800654718866242576C7A4BE24E24A
              E0C411C2589C297EE3E24210B09CFEAE240CE77C12F0D65BC3DD1220ADD061D3
              E27BA61D68454E9ECA86AA092E9584AFAE11014E22E0818711931483EA9F00E7
              E8DE997562EEE166E1DCD8C97182C704B059F068AD06E93360EE8F7C4BC3B9A0
              AFB91BA52FF261F7D553CD0C82A2F0E482C1F8CB4A2221EF8C08579D25E0E9A7
              87C3DF73D21DDB9CB07838754D3BD615930938496F79AD2A3111F2126073BE50
              DF08B3E8E1AA870F65D3A01EA812C0CE9D256F550960B59FBD53F60DDEB8D464
              04AF9231FFE97BB1FA739A4BDE053D4A748680254BFC1370E208A5AF252EB700
              AB11B0BE98BC70EB3E60E4485EBB82FC94095B0B84CD33F81319767CF6A75D08
              7CF87E7C36933C7B8CD00259557F2378EED3BF71BA83F7947E452542726A30EA
              89A9387A9EC262C9953602663D350BDBBF384D045C54979EEA6DB8F0E2FB34CD
              CF09F3059F042C5AE49F80DCEC56A49FA30820E914B85473D84401BB15EB8011
              231412E46782B0BD5078F72E14D3EF7B722779C3D14222A5A568F8EB38610272
              7BF0ECFDA76DB0FA95FEC0DC5CCC7C6E1A1548C2B77CF60D81CF2501C826DCB5
              683A8E7C4939487EBAB8DE52588B8C379980358439DD27010B17FA5E0FE0564F
              1E3FEDBB56FADDA5FA08FDC4B42A2BCAED5F01030702A34723F73F225044584B
              286477210D98FDABFD1421128553AAAC8465CB1C4503D801B2D36B3680FFE64C
              0BDED84FB13D3A465F82D6160D54D5EF13D215D367F554AEA92392F713766BFA
              1620B61706DF371AE91F7E4D3F54A913BF780DD9EF719ABC913067FB2460FE7C
              FF04F0E987F7B5C0DAAC4B5F52F3827412758665AD58D79A34097B1F8B416CA8
              70828A06FC92F27F5393EA9492D0B8ED76F5519BEEFC4E13E68FDFDC8C73DF9D
              43C9D8F1C0D8D1509EB478B17D53E228FCE876711D4F216D0F9D924E1A189788
              8459E351BEE2237DE295873250F8256BC056C25CE89380471EE99880F4730EA5
              8C6D537F654BE53019F2B7B55F92970B03EEBE1B1F3C9888A9C9C0C90A41804C
              97BC4C3F0F0AB7E20F0B421143357FA0EA0338C62FFBF3096C597910D99114CB
              A68E016262752767B1E8CBC85A0F4BC0C0DBFAE1BE41E47F087CC1E175E29CE1
              445A7F1A63D5E7FAC40B571F46E5C18F696F37612EF749C0430FF9CF031432CB
              5B71E98CDD408A1E1637D7EEA22D05E269D3F0FCBD29F8F51DC09E6BC2043802
              44A8A190C3202749EC03D24E57E14F2FAE467E4D2B6AEF992C4CC818E6D8BBB3
              1670D716178C4468C468E78F27CD8988106BE75ACB78633D2C45AB68EFA0DF4C
              F0BEFB8675F8BE105F736CBF154EBBA40DD2A6095B6A29F990291F183A147D6F
              1B87DC9F037FA5431181863CC0A467889C143DFFD32FB1AF8E263C738A78046D
              0AC1BC012604D2EE9AD324F9F2029D0022E3EB57A7E2A1FFDAE94E82460093F3
              D043509EEE9C3EAD0AA6C589B3BFF890F6C83E718AE6DFE2938019333A4740F6
              25072A4B9D6D4990660E7B2B6DB099378AC7497D07435E968C753922E70F3724
              414C40A09A09BEB4780D0E4593CA0E1D8CE1BD22F10E09B037D50A474951B713
              8E0D67C86F645E6C8BF5F2A61990666E6E4F804B15C3E2C5BCB62748E0262200
              3B84D5D42FFA2D86EEB947AC09FAF301EC721A6A5CB872D6AAE703BC024C9B02
              AB1D179DEBF989093F6A46E6DB77209FE6CD2F76847A485F23E0774FAFC5D12E
              44D82D03F1F89DF1583498CC3F18384E04ECA06A771775CBA61D22696002763C
              00E9EEB53A70AD36E7C64F5166CD2259AF150B928ACD1ECC221FF009ED916490
              E3B71C9E32455F14F5244103AFE025C0174F34C361D5D55F098D747C5B338522
              1369D98054FCCFE28998399434E39A2EFD20350DE62C90EFF1DFBF5887532154
              E20D48C1E431BD31A3AF383787484B2B254DE6175F366D16173001FBFE0DD2B8
              CFB4B536F7497212969A4A69E93AFD58D6B25D68CC5C437BBBA997FB2560C284
              CE13505B6E4761564B9B0F90D471B7355194311D55CC20E58E99B84C35D8FF52
              95CCCB789AF4B53A80EFB17CE97A9C0D8C228D4942D4E04118D95D905446E67F
              8542A8AD9176B66C53D6FF3822C8690B218DF9085EDB9C39E2FD9B93278DF6CF
              D2DF40FD281B845F02C68EF5BF26A881E7D6CA2F3A9D69A02DDA7C00939156E7
              4043E826E189A3A351B16A06D6E68B6C2D5893BE4A006DF0C14B1B71D9450943
              52023F4A027A26C11C1B05075748B594341DA61AA38997A184A3934F2DF64E00
              DF6FEE5CCA88F68BC5116EF5174A90FDFE4A0807C8AB432EBF048C1EDDF94551
              BEB4BAC88AAA6B36375FD0483699266F141E3D3616AF3DFB0026DD4A9A51A897
              C19AFDF3687FFBCF4DC86AA1BD1EB1C29E39EE137170908A6792230BE64C50B5
              777EEBECFB25DE09B8E516D1BFFE5A3F56B0EA38AA0E73F8DB0AF10295FF25B1
              1123DC9F0EFB22A0EDD9206941DEF93A4A72DC53E3DD76BA57E049452ADD46FF
              18F97F94B0F4B800DF46806A66D3283BFE685D39D6A69D6B9FF36B319EFE0F4E
              9E8BB32BBA2AE30F9EF369FBC93DF0805823D4C29F2880183C39251C667DE890
              80D4D441A485416D27301146A91BA5AF0DD65066234DB0283E40D020238312FB
              C2F0AD420B68BCCB6B1EC391A600C5B36BEAAFF900762BD39380EEE4236EFF03
              8D91F595EEE19988AE43F17FBF1A89B97706E3F98F9BB07ACD9AF6E0BB91139D
              3A958A886FF4F2B7F240360AD770E863EFCF0590B34302626313101797007F4D
              072FC032416594F03BAC8E3612D817EC31F10B9CB54AB673EB8479D8F4FBAE78
              F184C1FE25E3CB37A4F514FA16535A7BE87B079E7E9BA4682DC3FC07A7623915
              550AF04D54EDD82ABC4F6ACA14015C737EDCD25FDF0A6B31DB03A5A728D3E7EF
              87007E16D7BFFF204ABA4C1D80D7A381A26D5627AAB26A94FF391CF2F678931D
              CD313BF4F96C598495D70271993831194C4056C775A92BC5BC76B830995C81CD
              890D471D78F543328DBA8BBE25C2C517BF42B277AF5821E65677BE04391F702C
              640228355596C67D13307EFCE17D6673D7BB797FD0A0AE4849E9A3BC82E20DBC
              3702F8DFE6F226EACDAA1688DFF7851C165A406DE4C47958F7FB68FCF4A0770D
              D008E0C288F385FDCB8FF907AEB5891385F435DB17D2DF49D2E762603B84F3F3
              FF5CA0478FFB87A4A4BCB02B28284679252A3999DF16ED83F4F40014174B1EE0
              01633E605C266FCCAB81DD62574C808948A35AD516BFABEDDA839F3F81534E33
              D664AB04A83EC048002F8FF15A60E6DB3E62BDB1F5EB278A277E77C662314A9F
              E33EC562B04DB8BD33E8EB65E9B0A8A831B7A7A6FEF6BDF0F0FE43F8189BC3E4
              C9DDD1B76F0C112129AFAA682BCC9ED2D708E0E7FBD6826AB4B6D89590C8E31F
              E8421A18A056A0DDA6A2614B3FCCD92D164ADA3440F51D4C000714D68292E51D
              10C065374B9F5F3BCFCB532745894FE61FF7A8D2DFE1297D7F04F05C2893C080
              BE7D9FFD5962E2C38F9ACD515DF8B7E868336598D14AAFAA0A569E0770B4D116
              5B3D1F91B9F8BDE0E20AB86CC22966DAEC28EBF16DDB4DEF99F9285EFB7924E6
              EEF56E0255C73311515A8DA6E124D983E4359B8ABD13C0652F4BFDCC19FD98F0
              FC943783C2014EC3CB1BA3FEBE17E03F9492A127F521FDFA2D5D181F3F6D5248
              48628C7641F7EE21942BC428AFD08784842AEF03F10711BC65ED606204092E38
              4B2A205152C3923D64AEA20249B7D1D75F5A80D821A178E984BB06584BE9BC3A
              1B7A8EE885E212F21DD55454EDFBA43D782AB7D185E473EA940895DC5A2A9A70
              E915567BA216FCB94DA9A7F43B22406BFC5A13DD19EC0F0630090909B3274646
              8EE8473E225C3B2998F2DA6EDD42D1BB773885CE1098CD8188A132CE44B15F79
              5DA6AC15459424956535A289B46257207955A9445C4CC5CFC18F66E16F9566AC
              BC62986519CDB99C188DECA2BC2216288F823363953B82244A1AFA52C574F6AC
              78F2A3A97EF67B87D198B54755FD4CF8F876E07ABE19622238F58A57C9488E8C
              1C3E342666FC50DA26878626C58686F68A828FD6BD7BB8708C9576388A5BA924
              7621A7074D5A6A7123E1D30A26419D540DE5FEFBE81CA7F29D0D468EA7ECEFD0
              7A7DD03E7DC45AC3F9F37AB9CBEDDAC60B28DFC392DF499DD4020DBEE675DD1F
              4D4184EC50950C4AD2C126C1D912A55F888D8B9B981A1292D42D3C7C001D7399
              C2C252624CA650FECAC27DD07A174ED70640EE531BDB768C4878FDB9E9A84E0C
              C58A0BEAE36707C5C0737918191585B3993540C53E71BC7F7F51F0F0E727466F
              5C73A210799F72A86147C32F47B0C7F5F9F9CC8D10606C7C22E7CAE16A0F53B7
              912A41112A597C3CA41D09DC7ACD1D87847BEF371E62C7F8D41391F877C26A21
              A7A9A8CECA95E2477EB1906B7CAE0B7273759BE726421E4BFE10F503105EDFE7
              B7023783006F2D40252544DDB2E998D5ADB7812390FCF85388BD7389DB510A91
              6FBED00F47C842765C25E7CD397F02291569024A4AF42CCF1D3C4BFD980A9E63
              A1FFCFCEFE49045C6F636212D177D16F103572110282DC3E4AE28C71E18FA3F1
              CB0D6412193B458831BE9DD11E3C4B3FA733E07F2804E824C44F9E87C4FB5F45
              607864A7AE626F5FB22D9D1C1E0750767647AE07FC0F89008D847884F5BE03C9
              3F790BA1BD06F93D9BE37CC117A728D471E6C3292E6F8BAE07FC0F8D006EEC3F
              58FA0390306D3EBACF5884C0882E6E67B0D42BBEBB8AE2CD0C9A3F9DE5EA8EEB
              7B8A95FE1DDEBF0201CAED2122470FEA83D16BDEE3881D7BAFE21BAA8F15A074
              FB39381AF8B5165ED3E347DBECE93909E8D497A2FF0A04688D172158FAFCAD32
              9B03057EC54C18306776F9D4293180E306C7FFC113A0352D03E5848B4D84CB2E
              5E54E0D456FE07C66D47C0DF01786B5871BAED42F30000000049454E44AE4260
              82}
          end
          object Label1: TLabel
            Left = 80
            Top = 16
            Width = 108
            Height = 25
            Caption = 'BackupCow'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -21
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label2: TLabel
            Left = 80
            Top = 49
            Width = 444
            Height = 19
            Caption = 'Automatic Backup Software and Internal Cloud Storage Builder'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lkHome: TLinkLabel
            Left = 244
            Top = 24
            Width = 64
            Height = 17
            Caption = '<a> Home page </a>'
            TabOrder = 0
            OnLinkClick = lkHomeLinkClick
          end
        end
      end
    end
  end
  object lkRegister: TLinkLabel
    Left = 17
    Top = 64
    Width = 143
    Height = 20
    Caption = '<a> Click here to register... </a>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnLinkClick = lkRegisterLinkClick
  end
end
