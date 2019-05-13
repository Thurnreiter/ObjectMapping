unit Test.Address.Classes;

interface

{$M+}

type
{$REGION 'Interfaces'}
  IZipCode = interface
    ['{56B26B9F-1145-4E44-88E6-EBC0BA8CE17B}']
    function GetZipcode(): Integer;
    procedure SetZipcode(value: Integer);

    function GetCity(): string;
    procedure SetCity(const value: string);

    property Zipcode: Integer read GetZipcode write SetZipcode;
    property City: string read GetCity write SetCity;
  end;

  IAddress = interface
    ['{FE9165F2-4B32-45E7-920D-F899BE6A3430}']
    function GetName(): string;
    procedure SetName(const value: string);

    function GetZip(): IZipCode;
    procedure SetZip(value: IZipCode);

    property Name: string read GetName write SetName;
    property Zip: IZipCode read GetZip write SetZip;
  end;

  IAddressDto = interface
    ['{994F2661-8DED-406D-8881-A69F596A87C1}']
    function GetName(): string;
    procedure SetName(const value: string);

    function GetZipcode(): Integer;
    procedure SetZipcode(value: Integer);

    function GetCity(): string;
    procedure SetCity(const value: string);

    property Name: string read GetName write SetName;
    property Zipcode: Integer read GetZipcode write SetZipcode;
    property City: string read GetCity write SetCity;
  end;
{$ENDREGION}

{$REGION 'Implementations'}
  TZipCode = class(TInterfacedObject, IZipCode)
  strict private
    FZipcode: Integer;
    FCity: string;
  private
    function GetZipcode(): Integer;
    procedure SetZipcode(value: Integer);

    function GetCity(): string;
    procedure SetCity(const value: string);
  end;

  TAddress = class(TInterfacedObject, IAddress)
  strict private
    FName: string;
    FZip: IZipCode;
  private
    function GetName(): string;
    procedure SetName(const value: string);

    function GetZip(): IZipCode;
    procedure SetZip(value: IZipCode);
  end;


  TAddressDto = class(TInterfacedObject, IAddressDto)
  strict private
    FName: string;
    FZipcode: Integer;
    FCity: string;
  private
    function GetName(): string;
    procedure SetName(const value: string);

    function GetZipcode(): Integer;
    procedure SetZipcode(value: Integer);

    function GetCity(): string;
    procedure SetCity(const value: string);
  end;
{$ENDREGION}

{$REGION 'Factory'}
  TAddressFactory = class
    class function CreateAddress(): IAddress;
  end;
{$ENDREGION}

{$M-}

implementation

{ **************************************************************************** }

{ TZipCode }

function TZipCode.GetCity: string;
begin
  Result := FCity;
end;

function TZipCode.GetZipcode: Integer;
begin
  Result := FZipcode;
end;

procedure TZipCode.SetCity(const value: string);
begin
  FCity := value;
end;

procedure TZipCode.SetZipcode(value: Integer);
begin
  FZipcode := value;
end;

{ **************************************************************************** }

{ TAddress }

function TAddress.GetName: string;
begin
  Result := FName;
end;

function TAddress.GetZip: IZipCode;
begin
  Result := FZip;
end;

procedure TAddress.SetName(const value: string);
begin
  FName := value;
end;

procedure TAddress.SetZip(value: IZipCode);
begin
  FZip := value;
end;

{ **************************************************************************** }

{ TAddressDto }

function TAddressDto.GetCity: string;
begin
  Result := FCity;
end;

function TAddressDto.GetName: string;
begin
  Result := FName;
end;

function TAddressDto.GetZipcode: Integer;
begin
  Result := FZipcode;
end;

procedure TAddressDto.SetCity(const value: string);
begin
  FCity := value;
end;

procedure TAddressDto.SetName(const value: string);
begin
  FName := value;
end;

procedure TAddressDto.SetZipcode(value: Integer);
begin
  FZipcode := value;
end;

{ TAddressFactory }

class function TAddressFactory.CreateAddress(): IAddress;
begin
  Result := TAddress.Create;
  Result.Name := 'Nathan Chanan Thurnreiter';
  Result.Zip := TZipCode.Create;
  Result.Zip.Zipcode := 1234;
  Result.Zip.City := 'City';
end;

end.
