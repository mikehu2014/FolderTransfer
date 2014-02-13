unit UXmlUtil;

interface

uses xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, SysUtils, Forms, Classes, SyncObjs,
     DateUtils, UMyUtil, UChangeInfo, IniFiles, uDebugLock;

type

    // xml 信息 辅助类
  MyXmlUtil = class
  public
    class function getXmlPath : string;
    class procedure IniXml;
    class procedure LastSaveXml;
  public            // 修改
    class function AddChild( Parent : IXMLNode; ChildName : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName, Value : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Integer ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Int64 ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Double ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Boolean ):IXMLNode;overload;
    class procedure DeleteChild( Parent : IXMLNode; ChildName : string );
  public            // 读取
    class function GetChildValue( Parent : IXMLNode; ChildName : string ): string;
    class function GetChildIntValue( Parent : IXMLNode; ChildName : string ): Integer;
    class function GetChildInt64Value( Parent : IXMLNode; ChildName : string ): Int64;
    class function GetChildBoolValue( Parent : IXMLNode; ChildName : string ): Boolean;
    class function GetChildFloatValue( Parent : IXMLNode; ChildName : string ): Double;
  public            // Hash: Key - Value
    class function AddListChild( Parent : IXMLNode; Key : string ):IXMLNode;overload;
    class procedure DeleteListChild( Parent : IXMLNode; Key : string );overload;
    class function FindListChild( Parent : IXMLNode; Key : string ):IXMLNode;overload;
  public            // List
    class function AddListChild( Parent : IXMLNode ):IXMLNode;overload;
    class procedure DeleteListChild( Parent : IXMLNode; NodeIndex : Integer );overload;
  end;

      // 保存 Xml
  MyXmlSaveAutoApi = class
  public
    class procedure SaveNow;
  end;

  // Total
//Xml_MyNetworkConnInfo = 'mnci';
//Xml_MyNetPcInfo  = 'mnpi';
//Xml_MyFileSendInfo = 'mfsi';
//Xml_MyFileReceiveInfo = 'mfri';
//Xml_MySharePathInfo = 'mspi';
//Xml_MyShareDownInfo = 'msdi';
//Xml_MyPcInfo = 'mpi';

const
  Xml_ChildName : string = 'cn';
  Xml_AttrKey : string = 'k';
  Xml_ListChild : string = 'lc';

    // 根
  Xml_BackupCow = 'bc';

    // 读取 Xml信息
  XmlReadCount_Sleep = 10;

var
    // Xml Doc 根目录
  MyXmlDoc : TXMLDocument;


implementation

uses URegisterInfoIO;

{ TMyXmlUtil }

class procedure MyXmlUtil.DeleteChild(Parent: IXMLNode; ChildName: string);
var
  i : Integer;
begin
  for i := 0 to Parent.ChildNodes.Count - 1 do
    if Parent.ChildNodes[i].NodeName = ChildName then
    begin
      Parent.ChildNodes.Delete(i);
      Break;
    end;
end;

class procedure MyXmlUtil.DeleteListChild(Parent: IXMLNode; NodeIndex: Integer);
begin
  Parent.ChildNodes.Delete( NodeIndex );
end;

class procedure MyXmlUtil.DeleteListChild(Parent: IXMLNode; Key: string);
var
  i : Integer;
  Child : IXMLNode;
begin
  for i := 0 to Parent.ChildNodes.Count - 1 do
  begin
    Child := Parent.ChildNodes[i];
    if Child.Attributes[ Xml_AttrKey ] = Key then
    begin
      Parent.ChildNodes.Delete( i );
      Break;
    end;
  end;
end;

class function MyXmlUtil.FindListChild(Parent: IXMLNode; Key: string): IXMLNode;
var
  i : Integer;
  Child : IXMLNode;
begin
  Result := nil;

  for i := 0 to Parent.ChildNodes.Count - 1 do
  begin
    Child := Parent.ChildNodes[i];
    if Child.Attributes[ Xml_AttrKey ] = Key then
    begin
      Result := Child;
      Break;
    end;
  end;
end;


class function MyXmlUtil.GetChildBoolValue(Parent: IXMLNode;
  ChildName: string): Boolean;
begin
  Result := StrToBoolDef( GetChildValue( Parent, ChildName ), False );
end;

class function MyXmlUtil.GetChildFloatValue(Parent: IXMLNode;
  ChildName: string): Double;
begin
  Result := StrToFloatDef( GetChildValue( Parent, ChildName ), Now );
end;

class function MyXmlUtil.GetChildInt64Value(Parent: IXMLNode;
  ChildName: string): Int64;
begin
  Result := StrToInt64Def( GetChildValue( Parent, ChildName ), 0 );
end;

class function MyXmlUtil.GetChildIntValue(Parent: IXMLNode;
  ChildName: string): Integer;
begin
  Result := StrToIntDef( GetChildValue( Parent, ChildName ), 0 );
end;

class function MyXmlUtil.GetChildValue(Parent: IXMLNode;
  ChildName: string): string;
var
  Child : IXMLNode;
begin
  Result := '';
  Child := Parent.ChildNodes.FindNode( ChildName );
  if Child <> nil then
    Result := Child.Text;
end;

class function MyXmlUtil.getXmlPath: string;
begin
  try
    Result := MyAppDataUtil.get + 'MyInfo.dat';
  except
  end;
end;

class procedure MyXmlUtil.IniXml;
begin
  try
      // 创建 根目录
    if MyXmlDoc.DocumentElement = nil then
      MyXmlDoc.DocumentElement := MyXmlDoc.CreateNode( Xml_BackupCow );
  except
  end;
end;

class procedure MyXmlUtil.LastSaveXml;
begin
  XmlConfirm_ThisRun := True; // 最后保存，不询问管理员
  MyXmlSaveAutoApi.SaveNow; // 立刻保存
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName,
  Value: string): IXMLNode;
begin
  Result := AddChild( Parent, ChildName );
  Result.Text := Value;
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Int64): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, IntToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Integer): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, IntToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Boolean): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, BoolToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Double): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, FloatToStr( Value ) );
end;

class function MyXmlUtil.AddListChild(Parent: IXMLNode): IXMLNode;
begin
  Result := Parent.AddChild( Xml_ListChild );
end;

class function MyXmlUtil.AddListChild(Parent: IXMLNode; Key: string): IXMLNode;
var
  Child : IXMLNode;
begin
    // 找不到则创建
  Child := FindListChild( Parent, Key );
  if Child = nil then
  begin
    Child := Parent.AddChild( Xml_ChildName );
    Child.Attributes[ Xml_AttrKey ] := Key;
  end;

  Result := Child;
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode;
  ChildName: string): IXMLNode;
begin
  Result := Parent.ChildNodes.FindNode( ChildName );
  if Result = nil then
    Result := Parent.AddChild( ChildName );
end;

{ MyXmlSaveAutoApi }

class procedure MyXmlSaveAutoApi.SaveNow;
var
  Path : string;
begin
  try
    MyXmlChange.EnterXml;
    try
      Path := MyXmlUtil.getXmlPath;
      if MyAppDataUtil.ConfirmWriteFile( Path ) then  // 保存前先确认可写
        MyXmlDoc.SaveToFile( Path );
    except
    end;
    MyXmlChange.LeaveXml;
  except
  end;
end;

end.
