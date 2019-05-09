unit Nathan.ObjectMapping.Core;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Nathan.ObjectMapping.Config,
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
    function Config(): INathanObjectMappingConfig<S, D>; overload;
    function Config(AValue: INathanObjectMappingConfig<S, D>): INathanObjectMappingCore<S, D>; overload;
    function Map(ASource: S): D;
  end;

  TNathanObjectMappingCore<S, D: class> = class(TInterfacedObject, INathanObjectMappingCore<S, D>)
  strict private
    FConfig: INathanObjectMappingConfig<S, D>;

    function CreateDestination(): D;

    function GetInnerValue(AMappingType: TMappingType; AMember: TRttiMember; AValueFromObject: TValue): TValue;
    procedure SetInnerValue(AMappingType: TMappingType; AMember: TRttiMember; AValueFromObject, AValueToSet: TValue);

    procedure UpdateDestination(ASrc: S; ADest: D);
  public
    constructor Create(); overload;
    destructor Destroy; override;

    function Config(): INathanObjectMappingConfig<S, D>; overload;
    function Config(AValue: INathanObjectMappingConfig<S, D>): INathanObjectMappingCore<S, D>; overload;

    function Map(ASource: S): D; experimental;
  end;

{$M-}

implementation

constructor TNathanObjectMappingCore<S, D>.Create();
begin
  inherited Create;
  FConfig := nil;
end;

destructor TNathanObjectMappingCore<S, D>.Destroy;
begin
  //...
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
        ValueD := RMethCreateD.Invoke(RInstanceTypeD.MetaclassType, ArgsD);

        Exit(ValueD.AsType<D>);
      end;
    end;
  end;
end;

function TNathanObjectMappingCore<S, D>.GetInnerValue(
  AMappingType: TMappingType;
  AMember: TRttiMember;
  AValueFromObject: TValue): TValue;
begin
  case AMappingType of
    mtUnknown: Result := nil;
    mtField: Result := TRttiField(AMember).GetValue(AValueFromObject.AsObject);
    mtProperty: Result := TRttiProperty(AMember).GetValue(AValueFromObject.AsObject);
    mtMethod: Result := nil;
    mtFuncProc:
      begin
        Result := nil;
      end
  else
    Result := nil;
  end;
end;

procedure TNathanObjectMappingCore<S, D>.SetInnerValue(
  AMappingType: TMappingType;
  AMember: TRttiMember;
  AValueFromObject, AValueToSet: TValue);
begin
  case AMappingType of
    mtField: TRttiField(AMember).SetValue(AValueFromObject.AsObject, AValueToSet);
    mtProperty: TRttiProperty(AMember).SetValue(AValueFromObject.AsObject, AValueToSet);
    mtMethod: ;
    mtFuncProc: ;
  end;
end;

procedure TNathanObjectMappingCore<S, D>.UpdateDestination(ASrc: S; ADest: D);
var
  Idx: Integer;
  LValue: TValue;
  ValueFromS: TValue;
  ValueFromD: TValue;
  MemberS: TRttiMember;
  MemberD: TRttiMember;
  Item: TPair<string, TMappedSrcDest>;
begin
  ValueFromS := TValue.From<S>(ASrc);
  ValueFromD := TValue.From<D>(ADest);

  for Item in FConfig.GetMemberMap do
  begin
    MemberS := Item.Value[msdSource].MemberClass;
    MemberD := Item.Value[msdDestination].MemberClass;

    LValue := GetInnerValue(Item.Value[msdSource].MappingType, MemberS, ValueFromS);
    SetInnerValue(Item.Value[msdDestination].MappingType, MemberD, ValueFromD, LValue);
  end;

  for Idx := 0 to FConfig.GetUserMap.Count - 1 do
    FConfig.GetUserMap.Items[Idx](ASrc, ADest);
end;

function TNathanObjectMappingCore<S, D>.Map(ASource: S): D;
begin
  if ((not Assigned(FConfig))
  or ((FConfig.GetMemberMap.Count = 0) and (FConfig.GetUserMap.Count = 0))) then
    raise ENoMappingsFoundException.Create('No mapping information found.');

  //  Create an empty destination object...
  Result := CreateDestination;

  //  Update our destination class...
  UpdateDestination(ASource, Result);
end;

function TNathanObjectMappingCore<S, D>.Config: INathanObjectMappingConfig<S, D>;
begin
  Result := FConfig;
end;

function TNathanObjectMappingCore<S, D>.Config(AValue: INathanObjectMappingConfig<S, D>): INathanObjectMappingCore<S, D>;
begin
  FConfig := AValue;
  Result := Self;
end;

end.
