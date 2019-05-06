unit Test.Order.ObjectMapping.Config;

interface

{$M+}

uses
  System.Generics.Collections,
  DUnitX.TestFramework,
  Test.Order.ObjectMapping,
  Nathan.ObjectMapping.Config,
  Nathan.ObjectMapping.Types;

type
  [TestFixture]
  TTestObjectMappingConfig = class
  strict private
    FCut: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  private
    function GetStrings(ADict: TDictionary<string, TMappedSrcDest>): string;
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    procedure Test_First_Call_ListOf;

    [Test]
    procedure Test_WithNamingConvention;

    [Test]
    procedure Test_WithOwnMapping;
  end;

{$M-}

implementation

uses
  System.Rtti,
  System.SysUtils,
  Nathan.ObjectMapping.NamingConvention;

{ TTestObjectMappingConfig }

procedure TTestObjectMappingConfig.Setup;
begin
  FCut := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
end;

procedure TTestObjectMappingConfig.TearDown;
begin
  FCut := nil;
end;

function TTestObjectMappingConfig.GetStrings(ADict: TDictionary<string, TMappedSrcDest>): string;
var
  Enumerator: TDictionary<string,TMappedSrcDest>.TPairEnumerator;
begin
  Enumerator := ADict.GetEnumerator;
  try
    while Enumerator.MoveNext do
      Result := Result + Enumerator.Current.Key + ',';
  finally
    Enumerator.Free;
  end;
end;

procedure TTestObjectMappingConfig.Test_First_Call_ListOf;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  //  Arrange...

  //  Act...
  Actual := FCut.CreateMap;

  //  Assert...
  Assert.AreEqual('orderid,customername,', GetStrings(Actual));
  Assert.AreEqual(2, Actual.Count);
end;

procedure TTestObjectMappingConfig.Test_WithNamingConvention;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  //  Arrange...

  //  Act...
  Actual := FCut
    .NamingConvention(
      function(): INamingConvention
      begin
        Result := TGetterSetterNamingConvention
          .Create(TUnderscoreNamingConvention
          .Create(TLowerNamingConvention
          .Create(TPrefixFNamingConvention
          .Create(TNamingConvention.Create))));
    end)
    .CreateMap;

  //  Assert...
  Assert.AreEqual('orderid,innervalue,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);
end;

procedure TTestObjectMappingConfig.Test_WithOwnMapping;
var
  ActualProcValue: string;
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  //  Arrange...
  ActualProcValue := '';

  //  Act...
  Actual := FCut.CreateMap;
  FCut
    .AddMap(
      function(): TValue
      begin
        Result := 'Nat';
      end,
      procedure(AValue: TValue)
      begin
        ActualProcValue := AValue.ToString;
      end);

  //  Assert...
  Assert.AreEqual('', ActualProcValue);
  Assert.AreEqual('orderid,2,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMappingConfig, 'Config');

end.
