unit Test.NamingConvention;

interface

{$M+}

uses
  DUnitX.TestFramework,
  Nathan.ObjectMapping.NamingConvention;

type
  [TestFixture]
  TTestNamingConvention = class
  private
    FNamingConvention: TNamingConvention;
    FCut: INamingConvention;
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    procedure Test_Replace_PrefixF;

    [Test]
    procedure Test_ToLower;

    [Test]
    [TestCase('Getter', 'GetAnyVariableName,AnyVariableName')]
    [TestCase('Setter', 'SetAnyVariableName,AnyVariableName')]
    procedure Test_GetterSetter(const AValue, AExpected: string);

    [Test]
    [TestCase('PrefixF', 'FAnyVariableName,anyvariablename')]
    [TestCase('Lower', 'AnyVariableName,anyvariablename')]
    [TestCase('Underscore', 'AnyVariableName,anyvariablename')]
    [TestCase('Get', 'GetAnyVariableName,anyvariablename')]
    [TestCase('Set', 'SetAnyVariableName,anyvariablename')]
    procedure Test_NamingConvention(const AValue, AExpected: string);
  end;

{$M-}

implementation

uses
  System.SysUtils;

{ TTestNamingConvention }

procedure TTestNamingConvention.Setup();
begin
  FNamingConvention := TNamingConvention.Create;
  FCut := nil;
end;

procedure TTestNamingConvention.TearDown();
begin
  FCut := nil;
  FNamingConvention := nil;
end;

procedure TTestNamingConvention.Test_Replace_PrefixF;
var
  Actual: string;
begin
  //  Arrange...
  FCut := TPrefixFNamingConvention.Create(FNamingConvention);

  //  Act...
  Actual := FCut.GenerateKeyName('FAnyVariableName');

  //  Assert...
  Assert.AreEqual('AnyVariableName', Actual, False);
end;

procedure TTestNamingConvention.Test_ToLower;
var
  Actual: string;
begin
  //  Arrange...
  FCut := TLowerNamingConvention.Create(FNamingConvention);

  //  Act...
  Actual := FCut.GenerateKeyName('AnyVariableName');

  //  Assert...
  Assert.AreEqual('anyvariablename', Actual, False);
end;

procedure TTestNamingConvention.Test_GetterSetter;
var
  Actual: string;
begin
  //  Arrange...
  FCut := TGetterSetterNamingConvention.Create(FNamingConvention);

  //  Act...
  Actual := FCut.GenerateKeyName(AValue);

  //  Assert...
  Assert.AreEqual(AExpected, Actual, False);
end;

procedure TTestNamingConvention.Test_NamingConvention(const AValue, AExpected: string);
var
  Actual: string;
begin
  //  Arrange...
  FCut := TPrefixFNamingConvention.Create(FNamingConvention);
  FCut := TLowerNamingConvention.Create(FCut);
  FCut := TUnderscoreNamingConvention.Create(FCut);
  FCut := TGetterSetterNamingConvention.Create(FCut);

  //  Act...
  Actual := FCut.GenerateKeyName(AValue);

  //  Assert...
  Assert.AreEqual(AExpected, Actual, False);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNamingConvention, 'NamingConvention');

end.
