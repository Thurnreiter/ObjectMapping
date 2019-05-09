unit Test.Core.ObjectMapping.Order;

interface

{$M+}

uses
  DUnitX.TestFramework,
  Test.Order.Classes,
  Nathan.ObjectMapping.Core;

type
  [TestFixture]
  TTestObjectMapping = class
  private
    FCut: INathanObjectMappingCore<TOrder, TOrderDTO>;
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    procedure Test_HasNoMemoryLeaks;

    [Test]
    procedure Test_First_MapCallWithEx;

    [Test]
    procedure Test_CallMap_TOrder;
  end;

{$M-}

implementation

uses
  System.SysUtils,
  Nathan.ObjectMapping.Config;

procedure TTestObjectMapping.Setup();
begin
  FCut := nil;
end;

procedure TTestObjectMapping.TearDown();
begin
  TOrderDummyFactory.Release;
  FCut := nil;
end;

procedure TTestObjectMapping.Test_HasNoMemoryLeaks;
begin
  //  Assert...
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;
  Assert.IsNotNull(FCut);
end;

procedure TTestObjectMapping.Test_First_MapCallWithEx;
begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDummy;
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

  //  Act...
  Assert.WillRaise(
    procedure
    begin
      FCut.Map(TOrderDummyFactory.Order);
    end,
    ENoMappingsFoundException);
end;

procedure TTestObjectMapping.Test_CallMap_TOrder;
var
  Cfg: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  Actual: TOrderDTO;
begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDummy;
  Cfg := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
  Cfg
    .UserMap(
      procedure(ASrc: TOrder; ADest: TOrderDTO)
      begin
        ADest.Total := ASrc.Total;
      end)
    .CreateMap;

  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

  //  Act...
  Actual := FCut
    .Config(Cfg)
    .Map(TOrderDummyFactory.Order);

  try
    //  Assert...
    Assert.IsNotNull(Actual);
    Assert.AreEqual(1, Actual.OrderId);
    Assert.AreEqual('Nathan Thurnreiter', Actual.CustomerName);
    Assert.AreEqual<Double>(19.9, TOrderDTO(Actual).Total);
  finally
    FreeAndNil(Actual);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMapping, 'Map.TOrder');

end.
