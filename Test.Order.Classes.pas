unit Test.Order.Classes;

interface

{$M+}

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


  TOrderDummyFactory = class
    class var Order: TOrder;
    class var Details: TOrderDetails;

    class procedure InitOrderDummy;

    class procedure Release;
  end;

{$M-}

implementation

uses
  System.SysUtils;

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

{ TOrderDummyFactory }

class procedure TOrderDummyFactory.InitOrderDummy;
begin
  Details := TOrderDetails.Create;
  Details.ItemNumber := 'A123';
  Details.Quantity := 2;
  Details.Price := 9.95;

  Order := TOrder.Create;
  Order.OrderId := 1;
  Order.CustomerName := 'Nathan Thurnreiter';
  Order.OrderDetails := Details;
end;

class procedure TOrderDummyFactory.Release;
begin
  if Assigned(Details) then
    Details.Free;

  if Assigned(Order) then
    Order.Free;
end;

end.
