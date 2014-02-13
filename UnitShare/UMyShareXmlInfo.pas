unit UMyShareXmlInfo;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc;

type

{$Region ' 数据修改 ' }

    // 父类
  TSharePathChangeXml = class( TXmlChangeInfo )
  protected
    MySharePathNode : IXMLNode;
    SharePathNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TSharePathWriteXml = class( TSharePathChangeXml )
  public
    FullPath : string;
  protected
    SharePathIndex : Integer;
    SharePathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode: Boolean;
  end;

      // 添加
  TSharePathAddXml = class( TSharePathWriteXml )
  public
    IsFile : boolean;
  public
    procedure SetIsFile( _IsFile : boolean );
  protected
    procedure Update;override;
  protected
    procedure AddOtherXml;virtual;abstract;
  end;

      // 添加
  TSharePathAddLocalXml = class( TSharePathAddXml )
  protected
    procedure AddOtherXml;override;
  end;

      // 添加
  TSharePathAddNetworkXml = class( TSharePathAddXml )
  protected
    procedure AddOtherXml;override;
  end;


    // 删除
  TSharePathRemoveXml = class( TSharePathWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TSharePathReadXml = class
  public
    SharePathNode : IXMLNode;
  public
    constructor Create( _SharePathNode : IXMLNode );
    procedure Update;
  end;

    // 读取
  TMySharePathXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_MySharePathInfo = 'mspi';
  Xml_SharePathList = 'spl';

  Xml_FullPath = 'fp';
  Xml_IsFile = 'if';
  Xml_ShareType = 'st';

const
  ShareType_Local = 'Local';
  ShareType_Network = 'Network';



implementation

uses UMyShareApiInfo;

{ TSharePathChangeXml }

procedure TSharePathChangeXml.Update;
begin
  MySharePathNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MySharePathInfo );
  SharePathNodeList := MyXmlUtil.AddChild( MySharePathNode, Xml_SharePathList );
end;

{ TSharePathWriteXml }

constructor TSharePathWriteXml.Create( _FullPath : string );
begin
  FullPath := _FullPath;
end;


function TSharePathWriteXml.FindSharePathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to SharePathNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := SharePathNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath ) = FullPath ) then
    begin
      Result := True;
      SharePathIndex := i;
      SharePathNode := SharePathNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TSharePathAddXml }

procedure TSharePathAddXml.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TSharePathAddXml.Update;
begin
  inherited;

  if FindSharePathNode then
    Exit;

  SharePathNode := MyXmlUtil.AddListChild( SharePathNodeList );
  MyXmlUtil.AddChild( SharePathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( SharePathNode, Xml_IsFile, IsFile );
  AddOtherXml;
end;

{ TSharePathRemoveXml }

procedure TSharePathRemoveXml.Update;
begin
  inherited;

  if not FindSharePathNode then
    Exit;

  MyXmlUtil.DeleteListChild( SharePathNodeList, SharePathIndex );
end;



{ TMySharePathXmlRead }

procedure TMySharePathXmlRead.Update;
var
  MySharePathNode : IXMLNode;
  SharePathNodeList : IXMLNode;
  i : Integer;
  SharePathNode : IXMLNode;
  SharePathReadXml : TSharePathReadXml;
begin
  MySharePathNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MySharePathInfo );
  SharePathNodeList := MyXmlUtil.AddChild( MySharePathNode, Xml_SharePathList );
  for i := 0 to SharePathNodeList.ChildNodes.Count - 1 do
  begin
    SharePathNode := SharePathNodeList.ChildNodes[i];
    SharePathReadXml := TSharePathReadXml.Create( SharePathNode );
    SharePathReadXml.Update;
    SharePathReadXml.Free;
  end;
end;



{ SharePathNode }

constructor TSharePathReadXml.Create( _SharePathNode : IXMLNode );
begin
  SharePathNode := _SharePathNode;
end;

procedure TSharePathReadXml.Update;
var
  FullPath : string;
  IsFile : boolean;
  ShareType : string;
  SharePathReadLocalHandle : TSharePathReadLocalHandle;
  SharePathReadNetworkHandle : TSharePathReadNetworkHandle;
begin
  FullPath := MyXmlUtil.GetChildValue( SharePathNode, Xml_FullPath );
  IsFile := MyXmlUtil.GetChildBoolValue( SharePathNode, Xml_IsFile );
  ShareType := MyXmlUtil.GetChildValue( SharePathNode, Xml_ShareType );
  if ShareType = ShareType_Local then
  begin
    SharePathReadLocalHandle := TSharePathReadLocalHandle.Create( FullPath );
    SharePathReadLocalHandle.SetIsFile( IsFile );
    SharePathReadLocalHandle.Update;
    SharePathReadLocalHandle.Free;
  end
  else
  begin
    SharePathReadNetworkHandle := TSharePathReadNetworkHandle.Create( FullPath );
    SharePathReadNetworkHandle.SetIsFile( IsFile );
    SharePathReadNetworkHandle.Update;
    SharePathReadNetworkHandle.Free;
  end;
end;



{ TSharePathAddLocalXml }

procedure TSharePathAddLocalXml.AddOtherXml;
begin
  MyXmlUtil.AddChild( SharePathNode, Xml_ShareType, ShareType_Local );
end;

{ TSharePathAddNetworkXml }

procedure TSharePathAddNetworkXml.AddOtherXml;
begin
  MyXmlUtil.AddChild( SharePathNode, Xml_ShareType, ShareType_Network );
end;

end.
