unit Nathan.ObjectMapping.Core;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Nathan.ObjectMapping.Types;

{$REGION 'Info'}{
  ** Work in progres ** This project is a work in progress, check back soon for updates here.
}{$ENDREGION}

{$M+}

type
  ENoMappingsFoundException = class(Exception);

  //  INathanObjectMappingCore<S, D: IInterface> = interface
  //  INathanObjectMappingCore<S, D: constructor, class> = interface
  //  INathanObjectMappingCore<S, D: class> = interface
  INathanObjectMappingCore<S, D> = interface
    ['{40203DC3-18C7-487D-B356-0E50784609A7}']
    function Map(ASource: S): D;
  end;

  TNathanObjectMappingCore<S, D: class> = class(TInterfacedObject, INathanObjectMappingCore<S, D>)
  strict private
    FDict: TDictionary<string, TMappedSrcDest>;

    function CreateDestination(): D;
  public
    constructor Create(AMappingDict: TDictionary<string, TMappedSrcDest>); overload;
    destructor Destroy; override;

    function Map(ASource: S): D; experimental;
  end;

{$M-}

implementation

uses
  System.Rtti;

{ **************************************************************************** }

{ TNathanObjectMappingCore<S, D> }

constructor TNathanObjectMappingCore<S, D>.Create(AMappingDict: TDictionary<string, TMappedSrcDest>);
begin
  inherited Create;
  FDict := AMappingDict;
end;

destructor TNathanObjectMappingCore<S, D>.Destroy;
begin
  //  Not sure when I'll release the list...
  //  if Assigned(FDict) then
  //    FDict.Free;

  inherited;
end;

function TNathanObjectMappingCore<S, D>.CreateDestination: D;
var
  RTypeD: TRttiType;

  RMethCreateD: TRttiMethod;
  RInstanceTypeD: TRttiInstanceType;
  ValueD: TValue;
  ArgsD: array of TValue;
begin
  //  Example how to create the destination object...
  RTypeD := TRTTIContext.Create.GetType(TypeInfo(D));
  Argsd := ['Internal value for properties'];
  for RMethCreateD in RTypeD.GetMethods do
  begin
    if (RMethCreateD.IsConstructor) then
    begin
      RInstanceTypeD := RTypeD.AsInstance;
      if (Length(RMethCreateD.GetParameters) = 0) then
      begin
        //  Constructor parameters, here are emtpy []...
        ValueD := RMethCreateD.Invoke(RInstanceTypeD.MetaclassType, []);

        //  v := t.GetMethod('Create').Invoke(t.AsInstance.MetaclassType,[]);

        Exit(ValueD.AsType<D>);
      end
      else
      if (Length(RMethCreateD.GetParameters) = Length(ArgsD)) then
      begin
        //  With constructor parameters, here are a dummy...
        //
        ValueD := RMethCreateD.Invoke(RInstanceTypeD.MetaclassType, ArgsD);

        Exit(ValueD.AsType<D>);
      end;
    end;
  end;
end;

function TNathanObjectMappingCore<S, D>.Map(ASource: S): D;
var
  InnerStr: string;
  VS: TValue;
  VD: TValue;
  MemberS: TRttiMember;
  MemberD: TRttiMember;
begin
  if ((not Assigned(FDict)) or (FDict.Count = 0)) then
    raise ENoMappingsFoundException.Create('No mapping information found.');

  //  Create an empty destination object...
  Result := CreateDestination;

  //  Here we have an example how to read values...
  VS := TValue.From<S>(ASource);
  VD := TValue.From<D>(Result);

  //  Normally we have only "tolower" naming conversation...
  //  It's just a test of how to access it. Must still be abstracted....
  InnerStr := FDict.Items['customername'][msdSource].Name;
  InnerStr := FDict.Items['customername'][msdDestination].Name;
  MemberS := FDict.Items['customername'][msdSource].MemberClass;
  MemberD := FDict.Items['customername'][msdDestination].MemberClass;
  if MemberS.ClassName.Contains('TRttiInstancePropertyEx') then
    InnerStr := TRttiProperty(MemberS).GetValue(VS.AsObject).ToString;

  if MemberD.ClassName.Contains('TRttiInstanceFieldEx') then
  begin
    TRttiField(MemberD).SetValue(VD.AsObject, InnerStr);
    InnerStr := TRttiField(MemberD).GetValue(VD.AsObject).ToString;
  end;

  InnerStr := '';
end;

end.
