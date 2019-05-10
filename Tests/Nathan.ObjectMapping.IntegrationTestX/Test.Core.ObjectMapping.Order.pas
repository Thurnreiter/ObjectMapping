unit Test.Core.ObjectMapping.Order;

interface

{$M+}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  Test.Order.Classes,
  Nathan.ObjectMapping.Core,
  Nathan.ObjectMapping.Config;

type
  [TestFixture]
  TTestObjectMapping = class
  private
    FCut: INathanObjectMappingCore<TOrder, TOrderDTO>;

    function GetConfig(AProc1, AProc2: TProc<TOrder, TOrderDTO>): INathanObjectMappingConfig<TOrder, TOrderDTO>;
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

    [Test]
    procedure Test_Map_TOrder_WithTwoUserAdd;

    [Test]
    procedure Test_Map_TOrder_NoExWithUserAddAreNil;

    [Test]
    procedure Test_ReverseMap_TOrderDTOToTOrder;
  end;

{$M-}

implementation

procedure TTestObjectMapping.Setup();
begin
  TOrderDummyFactory.Init;
  FCut := nil;
end;

procedure TTestObjectMapping.TearDown();
begin
  TOrderDummyFactory.Release;
  FCut := nil;
end;

function TTestObjectMapping.GetConfig(
  AProc1, AProc2: TProc<TOrder, TOrderDTO>): INathanObjectMappingConfig<TOrder, TOrderDTO>;
begin
  Result := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
  if Assigned(AProc1) then
    Result.UserMap(AProc1);

  if Assigned(AProc2) then
    Result.UserMap(AProc2);

  Result.CreateMap;
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
  Actual: TOrderDTO;
begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDummy;
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

  //  Act...
  Actual := FCut
    .Config(GetConfig(
        procedure(ASrc: TOrder; ADest: TOrderDTO)
        begin
          ADest.Total := ASrc.Total;
        end,
        nil))
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

procedure TTestObjectMapping.Test_Map_TOrder_WithTwoUserAdd;
var
  Cfg: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  Actual: TOrderDTO;
begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDummy;
  Cfg := GetConfig(
    procedure(ASrc: TOrder; ADest: TOrderDTO)
    begin
      ADest.Total := ASrc.Total * 2;
    end,
    procedure(ASrc: TOrder; ADest: TOrderDTO)
    begin
      ADest.InnerValue := ASrc.Extension;
    end);

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
    Assert.AreEqual('Chanan', Actual.InnerValue);
    Assert.AreEqual<Double>(39.8, TOrderDTO(Actual).Total);
  finally
    FreeAndNil(Actual);
  end;
end;

procedure TTestObjectMapping.Test_Map_TOrder_NoExWithUserAddAreNil;
var
  Cfg: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  Actual: TOrderDTO;
 begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDummy;
  Cfg := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
  Cfg
    .UserMap(nil)
    .UserMap(nil)
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
    Assert.AreEqual('', Actual.InnerValue);
    Assert.AreEqual<Double>(19.90, TOrderDTO(Actual).Total);
  finally
    FreeAndNil(Actual);
  end;
end;

procedure TTestObjectMapping.Test_ReverseMap_TOrderDTOToTOrder;
var
  Actual: TOrder;
 begin
  //  Arrange...
  TOrderDummyFactory.InitOrderDtoDummy;
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

  //  Act...
  Actual := FCut
    .Config(TNathanObjectMappingConfig<TOrder, TOrderDTO>
      .Create
      .UserMapReverse(
          procedure(ADest: TOrderDTO; ASrc: TOrder)
          begin
            ASrc.Extension := ADest.InnerValue;
          end)
      .CreateMap)
    .MapReverse(TOrderDummyFactory.OrderDTO);

  try
    //  Assert...
    Assert.AreEqual(2, TOrderDummyFactory.OrderDTO.OrderId);
    Assert.AreEqual('Peter Miller', TOrderDummyFactory.OrderDTO.CustomerName);
    Assert.AreEqual('Chanan', TOrderDummyFactory.OrderDTO.InnerValue);
    Assert.AreEqual<Double>(47.11, TOrderDummyFactory.OrderDTO.Total);

    Assert.IsNotNull(Actual);
    Assert.AreEqual(0, Actual.Id);
    Assert.AreEqual(2, Actual.OrderId);
    Assert.AreEqual('Peter Miller', Actual.CustomerName);
    Assert.AreEqual('Chanan', Actual.Extension);
    Assert.IsNull(Actual.OrderDetails);
    Assert.AreEqual<Double>(0.0, Actual.Total); //  Because is a function...
  finally
    FreeAndNil(Actual);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMapping, 'Map.TOrder');

end.
