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
    function Map(ASource: S): D; overload;
    function MapReverse(ADestination: D): S; overload;
  end;

  TNathanObjectMappingCore<S, D: class> = class(TInterfacedObject, INathanObjectMappingCore<S, D>)
  strict private
    FConfig: INathanObjectMappingConfig<S, D>;

    function Creator(RType: TRttiType): TValue;
    function CreateDestination(): D;
    function CreateSource(): S;

    function GetInnerValue(AMappingType: TMappingType; AMember: TRttiMember; AValueFromObject: TValue): TValue;
    procedure SetInnerValue(AMappingType: TMappingType; AMember: TRttiMember; AValueFromObject, AValueToSet: TValue);

    procedure UpdateCreation(ASrc: S; ADest: D); overload;
    procedure UpdateCreation(ADest: D; ASrc: S); overload;

    procedure ValidateStarting;
  public
    constructor Create(); overload;
    destructor Destroy; override;

    function Config(): INathanObjectMappingConfig<S, D>; overload;
    function Config(AValue: INathanObjectMappingConfig<S, D>): INathanObjectMappingCore<S, D>; overload;

    function Map(ASource: S): D; overload;
    function MapReverse(ADestination: D): S; overload;
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

function TNathanObjectMappingCore<S, D>.Config: INathanObjectMappingConfig<S, D>;
begin
  Result := FConfig;
end;

function TNathanObjectMappingCore<S, D>.Config(AValue: INathanObjectMappingConfig<S, D>): INathanObjectMappingCore<S, D>;
begin
  FConfig := AValue;
  Result := Self;
end;

function TNathanObjectMappingCore<S, D>.Creator(RType: TRttiType): TValue;
var
  RMethCreate: TRttiMethod;
  RInstanceType: TRttiInstanceType;
  RValue: TValue;
  Args: array of TValue;
begin
  //  Example how to create the destination object...
  Args := ['Internal value for properties'];
  for RMethCreate in RType.GetMethods do
  begin
    if (RMethCreate.IsConstructor) then
    begin
      RInstanceType := RType.AsInstance;
      if (Length(RMethCreate.GetParameters) = 0) then
      begin
        //  Constructor parameters, here are emtpy []...
        RValue := RMethCreate.Invoke(RInstanceType.MetaclassType, []);

        //  v := t.GetMethod('Create').Invoke(t.AsInstance.MetaclassType,[]);
        Exit(RValue);
      end
      else
      if (Length(RMethCreate.GetParameters) = Length(Args)) then
      begin
        //  With constructor parameters, here are a dummy...
        RValue := RMethCreate.Invoke(RInstanceType.MetaclassType, Args);
        Exit(RValue);
      end;
    end;
  end;
end;

function TNathanObjectMappingCore<S, D>.CreateDestination: D;
var
  RTypeD: TRttiType;
  ValueD: TValue;
begin
  RTypeD := TRTTIContext.Create.GetType(TypeInfo(D));
  ValueD := Creator(RTypeD);
  Exit(ValueD.AsType<D>);
end;

function TNathanObjectMappingCore<S, D>.CreateSource: S;
var
  RTypeS: TRttiType;
  ValueS: TValue;
begin
  RTypeS := TRTTIContext.Create.GetType(TypeInfo(S));
  ValueS := Creator(RTypeS);
  Exit(ValueS.AsType<S>);
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
    mtMethod: Result := TRttiMethod(AMember).Invoke(AValueFromObject.AsObject, [])
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
    mtMethod:
      begin
        //  Will come in the future...
      end;
  end;
end;

procedure TNathanObjectMappingCore<S, D>.UpdateCreation(ASrc: S; ADest: D);
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

procedure TNathanObjectMappingCore<S, D>.UpdateCreation(ADest: D; ASrc: S);
var
  Idx: Integer;
  LValue: TValue;
  ValueFromS: TValue;
  ValueFromD: TValue;
  MemberS: TRttiMember;
  MemberD: TRttiMember;
  Item: TPair<string, TMappedSrcDest>;
begin
  ValueFromD := TValue.From<D>(ADest);
  ValueFromS := TValue.From<S>(ASrc);

  for Item in FConfig.GetMemberMap do
  begin
    MemberD := Item.Value[msdDestination].MemberClass;
    MemberS := Item.Value[msdSource].MemberClass;

    LValue := GetInnerValue(Item.Value[msdDestination].MappingType, MemberD, ValueFromD);
    SetInnerValue(Item.Value[msdSource].MappingType, MemberS, ValueFromS, LValue);
  end;

  for Idx := 0 to FConfig.GetUserMapReverse.Count - 1 do
    FConfig.GetUserMapReverse[Idx](ADest, ASrc);
end;

procedure TNathanObjectMappingCore<S, D>.ValidateStarting;
begin
  if ((not Assigned(FConfig))
  or ((FConfig.GetMemberMap.Count = 0) and (FConfig.GetUserMap.Count = 0))) then
    raise ENoMappingsFoundException.Create('No mapping information found.');
end;

function TNathanObjectMappingCore<S, D>.Map(ASource: S): D;
begin
  ValidateStarting;

  //  Create an empty destination object...
  Result := CreateDestination;

  //  Update our destination class...
  UpdateCreation(ASource, Result);
end;

function TNathanObjectMappingCore<S, D>.MapReverse(ADestination: D): S;
begin
  ValidateStarting;

  //  Create an empty source object...
  Result := CreateSource;

  //  Update our source class...
  UpdateCreation(ADestination, Result);
end;

end.
