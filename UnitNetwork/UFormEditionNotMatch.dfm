object frmEditonNotMatch: TfrmEditonNotMatch
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Folder Transfer'
  ClientHeight = 311
  ClientWidth = 376
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvComputer: TListView
    Left = 0
    Top = 34
    Width = 376
    Height = 277
    Align = alClient
    Columns = <
      item
        Caption = 'Computer IP'
        Width = 130
      end
      item
        AutoSize = True
        Caption = 'Computer Name'
      end>
    ReadOnly = True
    RowSelect = True
    SmallImages = frmMainForm.ilNw16
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 376
    Height = 34
    Align = alTop
    BevelOuter = bvNone
    Caption = 
      'You must upgrade Folder Transfer programs running on all the com' +
      'puters.'
    TabOrder = 1
  end
end
