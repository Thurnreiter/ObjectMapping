unit Test.Order.ObjectMapping;

interface

{$M+}

uses
  System.Generics.Collections,
  DUnitX.TestFramework,
  Nathan.ObjectMapping.Core,
  Nathan.ObjectMapping.Types;

type
  TOrderDetails = class
  strict private
    FItemNumber: string;
    FQuantity: Double;
    FPrice: Double;
  public
    property ItemNumber: string read FItemNumber write FItemNumber;
    property Quantity: Double read FQuantity write FQuantity;
    property Price: Double read FPrice write FPrice;
  end;

  IOrderBase = interface
    ['{74DB4495-7EBB-4F96-A46F-7D520E722D12}']
  end;

  TOrderBase = class(TInterfacedObject, IOrderBase)
  strict private
    FId: Integer;
  public
    property Id: Integer read FId write FId;
  end;

  TOrder = class(TOrderBase)
  strict private
    FOrderId: Integer;
    FCustomerName: string;
    FOrderDetails: TOrderDetails;
    FExtension: string;
    FInnerValue: string;
  private
    procedure SetOrderDetails(AValue: TOrderDetails);

    function GetExtension(): string;
    procedure SetExtension(const AValue: string);
  public
    function Total(): Double;

    property OrderId: Integer read FOrderId write FOrderId;
    property CustomerName: string read FCustomerName write FCustomerName;
    property OrderDetails: TOrderDetails read FOrderDetails write SetOrderDetails;
    property Extension: string read GetExtension write SetExtension;
  end;

  IOrderDTO = interface
    ['{91D41461-9BD6-4609-BEE2-ED2D6F0B85A5}']
  end;

  TOrderDTO = class(TInterfacedObject, IOrderBase)
  public
    OrderId: Integer;
    CustomerName: string;
    Total: Double;
    InnerValue: string;
  end;





  [TestFixture]
  TTestObjectMapping = class
  private
    FCut: INathanObjectMappingCore<TOrder, TOrderDTO>;
    FOrder: TOrder;
    FDetails: TOrderDetails;
    procedure InitOrderDummy();
    function GetStubDict: TDictionary<string, TMappedSrcDest>;
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    // [Ignore('Ignore this test')]
    procedure Test_HasNoMemoryLeaks;

    [Test]
    procedure Test_First_MapCallWithEx;

    [Test]
    procedure Test_CallMap;
  end;

{$M-}

implementation

uses
  System.SysUtils,
  Nathan.ObjectMapping.Config;

{ **************************************************************************** }

{ TOrder }

function TOrder.GetExtension: string;
begin
  Result := FExtension;
end;

procedure TOrder.SetExtension(const AValue: string);
begin
  FExtension := AValue;
end;

procedure TOrder.SetOrderDetails(AValue: TOrderDetails);
begin
  FOrderDetails := AValue;
end;

function TOrder.Total: Double;
begin
  Result := FOrderDetails.Quantity * FOrderDetails.Price;
  FInnerValue := Result.ToString;
end;

{ **************************************************************************** }

{ TTestObjectMapping }

procedure TTestObjectMapping.Setup();
begin
  FCut := nil;
  FDetails := nil;
  FOrder := nil;
end;

procedure TTestObjectMapping.TearDown();
begin
  if Assigned(FDetails) then
    FDetails.Free;

  if Assigned(FOrder) then
    FOrder.Free;

  FCut := nil;
end;

procedure TTestObjectMapping.InitOrderDummy;
begin
  FDetails := TOrderDetails.Create;
  FDetails.ItemNumber := 'A123';
  FDetails.Quantity := 2;
  FDetails.Price := 9.95;

  FOrder := TOrder.Create;
  FOrder.OrderId := 1;
  FOrder.CustomerName := 'Nathan Thurnreiter';
  FOrder.OrderDetails := FDetails;
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
  InitOrderDummy;
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

  //  Act...
  Assert.WillRaise(
    procedure
    begin
      FCut.Map(FOrder);
    end,
    ENoMappingsFoundException);
end;

function TTestObjectMapping.GetStubDict: TDictionary<string, TMappedSrcDest>;
var
  Config: INathanObjectMappingConfig<TOrder, TOrderDTO>;
begin
  Config := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
  Result := Config.CreateMap;
end;

procedure TTestObjectMapping.Test_CallMap;
var
  Config: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  Dict: TDictionary<string, TMappedSrcDest>;
  Actual: TOrderDTO;
begin
  //  Arrange...
  InitOrderDummy;
  Config := TNathanObjectMappingConfig<TOrder, TOrderDTO>.Create;
  Dict := Config.CreateMap;
  //  Dict := GetStubDict;
  FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create(Dict);

  //  Act...
  Actual := FCut.Map(FOrder);
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
  TDUnitX.RegisterTestFixture(TTestObjectMapping, 'Frist');

end.
