unit Test.Core.ObjectMapping.Address;

interface

{$M+}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  Test.Address.Classes,
  Nathan.ObjectMapping.Core,
  Nathan.ObjectMapping.Config;

type
  [TestFixture]
  TTestObjectMapping = class
  private
    FCut: INathanObjectMappingCore<IAddress, IAddressDTO>;
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    procedure Test_Map_Address_AddressDTO;
  end;

{$M-}

implementation

procedure TTestObjectMapping.Setup();
begin
  FCut := nil;
end;

procedure TTestObjectMapping.TearDown();
begin
  FCut := nil;
end;

procedure TTestObjectMapping.Test_Map_Address_AddressDTO;
var
  FCut2: TNathanObjectMappingCore<IAddress, TAddressDTO>;
  Actual: IAddressDTO;
begin
  //  Arrange...
  FCut2 := TNathanObjectMappingCore<IAddress, TAddressDTO>.Create;

  //  Act...
  Actual := FCut2
    .Config(TNathanObjectMappingConfig<IAddress, TAddressDTO>
      .Create
      .UserMap(
          procedure(ADest: IAddress; ASrc: TAddressDTO)
          begin
            (ASrc as IAddressDto).Zipcode := ADest.Zip.Zipcode;
            (ASrc as IAddressDto).City := ADest.Zip.City;
          end)
      .CreateMap)
    .Map(TAddressFactory.CreateAddress);

  //  Assert...
  Assert.IsNotNull(Actual);
  Assert.AreEqual('Nathan Thurnreiter', Actual.Name);
  Assert.AreEqual(1234, Actual.Zipcode);
  Assert.AreEqual('City', Actual.City);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMapping, 'Map.TOrder');

end.
