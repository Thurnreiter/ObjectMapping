unit Nathan.ObjectMapping.Config;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Defaults,
  System.Generics.Collections,
  Nathan.ObjectMapping.Types,
  Nathan.ObjectMapping.NamingConvention;

{$M+}

type
  INathanObjectMappingConfig<S, D> = interface
    ['{9D498376-8130-4E82-AA98-066CA9833685}']
    function AddMap(ASrc: TFunc<TValue>; ADest: TProc<TValue>): INathanObjectMappingConfig<S, D>; overload;

    function Clean(): INathanObjectMappingConfig<S, D>; overload;

    function NamingConvention(): INamingConvention; overload;
    function NamingConvention(AValue: INamingConvention): INathanObjectMappingConfig<S, D>; overload;
    function NamingConvention(AValue: TFunc<INamingConvention>): INathanObjectMappingConfig<S, D>; overload;

    function CreateMap(): TDictionary<string, TMappedSrcDest>;
  end;

  TNathanObjectMappingConfig<S, D: class> = class(TInterfacedObject, INathanObjectMappingConfig<S, D>)
  strict private
    FListOfPropNameSource: TArray<TCoreMapDetails>;
    FListOfPropNameDestination: TArray<TCoreMapDetails>;

    FDict: TDictionary<string, TMappedSrcDest>;
    FNamingConvention: INamingConvention;
  private
    function GetAllProps(AInnerRttiType: TRttiType): TArray<TCoreMapDetails>;
    procedure Collate(ASrc, ADest: TArray<TCoreMapDetails>; ANamingConvention: INamingConvention);
  public
    constructor Create(); overload;
    destructor Destroy; override;

    function AddMap(ASrc: TFunc<TValue>; ADest: TProc<TValue>): INathanObjectMappingConfig<S, D>; overload;

    function NamingConvention(): INamingConvention; overload;
    function NamingConvention(AValue: INamingConvention): INathanObjectMappingConfig<S, D>; overload;
    function NamingConvention(AValue: TFunc<INamingConvention>): INathanObjectMappingConfig<S, D>; overload;

    function Clean(): INathanObjectMappingConfig<S, D>; overload;

    function CreateMap(): TDictionary<string, TMappedSrcDest>;
  end;

{$M-}

implementation

uses
  System.Types,
  System.TypInfo,
  Nathan.TArrayHelper;

{ TNathanObjectMappingConfig<S, D> }

constructor TNathanObjectMappingConfig<S, D>.Create;
begin
  inherited Create();
  FDict := TDictionary<string, TMappedSrcDest>.Create;
  FNamingConvention := nil;
end;

destructor TNathanObjectMappingConfig<S, D>.Destroy;
begin
  FDict.Free;
  inherited;
end;

function TNathanObjectMappingConfig<S, D>.NamingConvention: INamingConvention;
begin
  Result := FNamingConvention;
end;

function TNathanObjectMappingConfig<S, D>.NamingConvention(AValue: INamingConvention): INathanObjectMappingConfig<S, D>;
begin
  FNamingConvention := AValue;
  Result := Self;
end;

function TNathanObjectMappingConfig<S, D>.NamingConvention(AValue: TFunc<INamingConvention>): INathanObjectMappingConfig<S, D>;
begin
  FNamingConvention := AValue;
  Result := Self;
end;

function TNathanObjectMappingConfig<S, D>.GetAllProps(AInnerRttiType: TRttiType): TArray<TCoreMapDetails>;
var
  RField: TRttiField;
  RProp: TRttiProperty;
  RMeth: TRttiMethod;
  Fill: TFunc<TMappingType, TRttiMember, TTypeKind, TCoreMapDetails>;
begin
  Fill :=
    function(AMT: TMappingType; ARM: TRttiMember; ATK: TTypeKind): TCoreMapDetails
    begin
      Result.RttiTypeName := AInnerRttiType.ToString;
      Result.Name := ARM.Name;
      Result.TypeOfWhat := ATK;
      Result.MappingType := AMT;
      Result.MemberClass := ARM;
    end;

  //  All Fields...
  for RField in AInnerRttiType.GetDeclaredFields do
    TArray.Add<TCoreMapDetails>(Result, Fill(mtField, RField, RField.FieldType.TypeKind));

  //  Here we get all properties include inherited...
  for RProp in AInnerRttiType.GetDeclaredProperties do
    TArray.Add<TCoreMapDetails>(Result, Fill(mtProperty, RProp, RProp.PropertyType.TypeKind), [ahoIgnoreDuplicates]);

  //  All Method...
  for RMeth in AInnerRttiType.GetDeclaredMethods do
  begin
    if ((RMeth.MethodKind <> mkFunction) or (Length(RMeth.GetParameters) <> 1)) then
      Continue;

    TArray.Add<TCoreMapDetails>(Result, Fill(mtMethod, RMeth, RMeth.ReturnType.TypeKind), [ahoIgnoreDuplicates]);
  end;
end;

function TNathanObjectMappingConfig<S, D>.Clean: INathanObjectMappingConfig<S, D>;
begin
  FDict.Clear;
  TArray.Clear<TCoreMapDetails>(FListOfPropNameSource);
  TArray.Clear<TCoreMapDetails>(FListOfPropNameDestination);
  Result := Self;
end;

procedure TNathanObjectMappingConfig<S, D>.Collate(ASrc, ADest: TArray<TCoreMapDetails>; ANamingConvention: INamingConvention);
var
  Mapped: TMappedSrcDest;
  IdxS, IdxD: Integer;
begin
  if (not Assigned(ANamingConvention)) then
    ANamingConvention := TLowerNamingConvention.Create(TNamingConvention.Create);

  for IdxD := Low(ADest) to High(ADest) do
  begin
    for IdxS := Low(ASrc) to High(ASrc) do
    begin
      if (ASrc[IdxS].TypeOfWhat = ADest[IdxD].TypeOfWhat)
      and (ANamingConvention.GenerateKeyName(ASrc[IdxS].Name) = ANamingConvention.GenerateKeyName(ADest[IdxD].Name)) then
      begin
        Mapped[msdSource] := ASrc[IdxS];
        Mapped[msdDestination] := ADest[IdxD];
        FDict.AddOrSetValue(ANamingConvention.GenerateKeyName(ASrc[IdxS].Name), Mapped);
      end;
    end;
  end;
end;

function TNathanObjectMappingConfig<S, D>.CreateMap: TDictionary<string, TMappedSrcDest>;
var
  RTypeS: TRttiType;
  RTypeD: TRttiType;
begin
  //  We assume it's all been done before...
  if (High(FListOfPropNameSource) > -1)
  or (High(FListOfPropNameDestination) > -1) then
    Exit(FDict);

  RTypeS := TRTTIContext.Create.GetType(TypeInfo(S)); //  RTypeS := TRTTIContext.Create.GetType(ASource.ClassType);
  RTypeD := TRTTIContext.Create.GetType(TypeInfo(D));

  FListOfPropNameSource := GetAllProps(RTypeS);
  FListOfPropNameDestination := GetAllProps(RTypeD);

  Collate(FListOfPropNameSource, FListOfPropNameDestination, FNamingConvention);

  Result := FDict;
end;

function TNathanObjectMappingConfig<S, D>.AddMap(ASrc: TFunc<TValue>; ADest: TProc<TValue>): INathanObjectMappingConfig<S, D>;
var
  Mapped: TMappedSrcDest;
begin
  Mapped[msdSource].GetFunc := ASrc;
  Mapped[msdSource].MappingType := mtFuncProc;

  Mapped[msdDestination].SetProc := ADest;
  Mapped[msdDestination].MappingType := mtFuncProc;

  FDict.AddOrSetValue(FDict.Count.ToString, Mapped);
  Result := Self;
end;

end.
