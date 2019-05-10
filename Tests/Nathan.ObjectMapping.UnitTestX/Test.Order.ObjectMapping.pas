unit Test.Order.ObjectMapping;

interface

{$M+}

uses
  System.Generics.Collections,
  DUnitX.TestFramework,
  Delphi.Mocks,
  Test.Order.Classes,
  Nathan.ObjectMapping.Core,
  Nathan.ObjectMapping.Types;

type
  [TestFixture]
  TTestObjectMapping = class
  private
    FCut: INathanObjectMappingCore<TOrder, TOrderDTO>;
    FOrder: TOrder;
    FDetails: TOrderDetails;
    procedure InitOrderDummy();
  public
    [Setup]
    procedure Setup();

    [TearDown]
    procedure TearDown();

    [Test]
    procedure Test_First_MapCallWithEx;

    [Test]
    procedure Test_CallMap;
  end;

{$M-}

implementation

uses
  System.SysUtils,
  System.Rtti,
  Nathan.ObjectMapping.Config;

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

procedure TTestObjectMapping.InitOrderDummy;
begin
  TOrderDummyFactory.InitOrderDummy;
  FDetails := TOrderDummyFactory.Details;
  FOrder := TOrderDummyFactory.Order;
end;

procedure TTestObjectMapping.Test_CallMap;
var
  CfgMock: TMock<INathanObjectMappingConfig<TOrder, TOrderDTO>>;
  StubMemberList: TDictionary<string, TMappedSrcDest>;
  StubUserList: TList<TProc<TOrder, TOrderDTO>>;

  Actual: TOrderDTO;
begin
  //  Arrange...
  StubUserList := TList<TProc<TOrder, TOrderDTO>>.Create;
  StubUserList.Add(
        procedure(ASrc: TOrder; ADest: TOrderDTO)
        begin
          ADest.Total := ASrc.Total;
        end);

  StubMemberList := TDictionary<string, TMappedSrcDest>.Create;
  try
    CfgMock := TMock<INathanObjectMappingConfig<TOrder, TOrderDTO>>.Create;
    CfgMock.Setup.AllowRedefineBehaviorDefinitions := True;
    CfgMock.Setup.WillReturn(StubUserList).When.GetUserMap;
    CfgMock.Setup.WillReturn(StubMemberList).When.GetMemberMap;

    InitOrderDummy;

    FCut := TNathanObjectMappingCore<TOrder, TOrderDTO>.Create;

    //  Act...
    Actual := FCut
      .Config(CfgMock)
      .Map(FOrder);

    try
      //  Assert...
      Assert.IsNotNull(Actual);
      Assert.AreEqual<Double>(19.9, TOrderDTO(Actual).Total);
    finally
      FreeAndNil(Actual);
    end;
  finally
    StubUserList.Free;
    StubMemberList.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMapping, 'Frist');

end.
