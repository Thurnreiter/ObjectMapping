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
    function Clean(): INathanObjectMappingConfig<S, D>; overload;

    function NamingConvention(): INamingConvention; overload;
    function NamingConvention(AValue: INamingConvention): INathanObjectMappingConfig<S, D>; overload;
    function NamingConvention(AValue: TFunc<INamingConvention>): INathanObjectMappingConfig<S, D>; overload;

    function CreateMap(): INathanObjectMappingConfig<S, D>;

    function UserMap(AMappingProc: TProc<S, D>): INathanObjectMappingConfig<S, D>;
    function UserMapReverse(AMappingProc: TProc<D, S>): INathanObjectMappingConfig<S, D>;

    function GetMemberMap(): TDictionary<string, TMappedSrcDest>;
    function GetUserMap(): TList<TProc<S, D>>;
    function GetUserMapReverse(): TList<TProc<D, S>>;
  end;

  TNathanObjectMappingConfig<S, D: class> = class(TInterfacedObject, INathanObjectMappingConfig<S, D>)
  strict private
    FListOfPropNameSource: TArray<TCoreMapDetails>;
    FListOfPropNameDestination: TArray<TCoreMapDetails>;

    FDict: TDictionary<string, TMappedSrcDest>;
    FUserMapList: TList<TProc<S, D>>;
    FUserMapListReverse: TList<TProc<D, S>>;

    FNamingConvention: INamingConvention;
  private
    function GetAllProps(AInnerRttiType: TRttiType): TArray<TCoreMapDetails>;
    procedure Collate(ASrc, ADest: TArray<TCoreMapDetails>; ANamingConvention: INamingConvention);
  public
    constructor Create(); overload;
    destructor Destroy; override;

    function NamingConvention(): INamingConvention; overload;
    function NamingConvention(AValue: INamingConvention): INathanObjectMappingConfig<S, D>; overload;
    function NamingConvention(AValue: TFunc<INamingConvention>): INathanObjectMappingConfig<S, D>; overload;

    function Clean(): INathanObjectMappingConfig<S, D>; overload;

    function CreateMap(): INathanObjectMappingConfig<S, D>;

    function UserMap(AMappingProc: TProc<S, D>): INathanObjectMappingConfig<S, D>;
    function UserMapReverse(AMappingProc: TProc<D, S>): INathanObjectMappingConfig<S, D>;

    function GetMemberMap(): TDictionary<string, TMappedSrcDest>;
    function GetUserMap(): TList<TProc<S, D>>;
    function GetUserMapReverse(): TList<TProc<D, S>>;
  end;

{$M-}

implementation

uses
  System.Types,
  System.TypInfo,
  Nathan.TArrayHelper;

constructor TNathanObjectMappingConfig<S, D>.Create;
begin
  inherited Create();
  FDict := TDictionary<string, TMappedSrcDest>.Create;
  FUserMapList := TList<TProc<S, D>>.Create;
  FUserMapListReverse := TList<TProc<D, S>>.Create;
  FNamingConvention := nil;
end;

destructor TNathanObjectMappingConfig<S, D>.Destroy;
begin
  FDict.Free;
  FUserMapList.Free;
  FUserMapListReverse.Free;
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
    if ((RMeth.MethodKind <> mkFunction) or (Length(RMeth.GetParameters) > 1)) then
      Continue;

    TArray.Add<TCoreMapDetails>(Result, Fill(mtMethod, RMeth, RMeth.ReturnType.TypeKind), [ahoIgnoreDuplicates]);
  end;
end;

function TNathanObjectMappingConfig<S, D>.Clean: INathanObjectMappingConfig<S, D>;
begin
  FDict.Clear;
  FUserMapList.Clear;
  FUserMapListReverse.Clear;
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
if ADest[IdxD].Name.Contains('Total') then
  Mapped[msdDestination] := ADest[IdxD];

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

function TNathanObjectMappingConfig<S, D>.CreateMap: INathanObjectMappingConfig<S, D>;
var
  RTypeS: TRttiType;
  RTypeD: TRttiType;
begin
  //  We assume it's all been done before...
  if (High(FListOfPropNameSource) > -1)
  or (High(FListOfPropNameDestination) > -1) then
    Exit(Self);

  RTypeS := TRTTIContext.Create.GetType(TypeInfo(S)); //  RTypeS := TRTTIContext.Create.GetType(ASource.ClassType);
  RTypeD := TRTTIContext.Create.GetType(TypeInfo(D));

  FListOfPropNameSource := GetAllProps(RTypeS);
  FListOfPropNameDestination := GetAllProps(RTypeD);

  Collate(FListOfPropNameSource, FListOfPropNameDestination, FNamingConvention);

  Result := Self;
end;

function TNathanObjectMappingConfig<S, D>.UserMap(AMappingProc: TProc<S, D>): INathanObjectMappingConfig<S, D>;
begin
  if Assigned(AMappingProc) then
    FUserMapList.Add(AMappingProc);

  Result := Self;
end;

function TNathanObjectMappingConfig<S, D>.UserMapReverse(AMappingProc: TProc<D, S>): INathanObjectMappingConfig<S, D>;
begin
  if Assigned(AMappingProc) then
    FUserMapListReverse.Add(AMappingProc);

  Result := Self;
end;

function TNathanObjectMappingConfig<S, D>.GetMemberMap: TDictionary<string, TMappedSrcDest>;
begin
  Result := FDict;
end;

function TNathanObjectMappingConfig<S, D>.GetUserMap: TList<TProc<S, D>>;
begin
  Result := FUserMapList;
end;

function TNathanObjectMappingConfig<S, D>.GetUserMapReverse: TList<TProc<D, S>>;
begin
  Result := FUserMapListReverse;
end;

end.
