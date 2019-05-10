unit Test.Order.ObjectMapping.Config;

interface

{$M+}

uses
  System.SysUtils,
  System.Generics.Collections,
  DUnitX.TestFramework,
  Test.Order.Classes,
  Test.Order.ObjectMapping,
  Nathan.ObjectMapping.Config,
  Nathan.ObjectMapping.Types;

type
//  IFunc<Integer> = interface(TFunc<Integer>)
//  end;

//  PDelegate = ^IDelegate;
//  IDelegate = interface
//    procedure Invoke;
//  end;
//
//  TDelegate = class(TInterfacedObject, IDelegate)
//  private
//    FMethod: TMethod;
//    procedure Invoke;
//  public
//    constructor Create(const AMethod: TMethod);
//  end;

  TAddMapAnonymousEvents<TTEventPointer, TTEventReference>=class
  public
    class function Create(AEvent:TTEventReference): TTEventPointer;
  end;


  [TestFixture]
  TTestObjectMappingConfig = class
  strict private
    FCut: INathanObjectMappingConfig<TOrder, TOrderDTO>;
  private
    function GetStrings(ADict: TDictionary<string, TMappedSrcDest>): string;
    function GetDummyProc(const ACapValue: Integer): TFunc<Integer>;
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

    [Test]
    procedure Test_DictFromCreateMapOnlyOnce;

    [Test]
    procedure Test_RefreshDictTwoTimes;

    [Test]
    procedure Test_WithOwnMappingReverse;

    [Test]
    procedure Test_WithOwnMappingAndTwoReferences;
  end;

{$M-}

implementation

uses
  System.Rtti,
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
  Actual := FCut
    .CreateMap
    .GetMemberMap;

  //  Assert...
  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);
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
    .CreateMap
    .GetMemberMap;

  //  Assert...
  Assert.AreEqual('innervalue,orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(4, Actual.Count);
end;

procedure TTestObjectMappingConfig.Test_WithOwnMapping;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  //  Arrange...
  //  Act...
  Actual := FCut
    .UserMap(
      procedure(ASrc: TOrder; ADest: TOrderDTO)
      begin
        ADest.Total := ASrc.Total;
      end)
    .CreateMap
    .GetMemberMap;

  //  Assert...
  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);

  Assert.AreEqual(1, FCut.GetUserMap.Count);
end;

procedure TTestObjectMappingConfig.Test_DictFromCreateMapOnlyOnce;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  Actual := FCut
    .CreateMap
    .GetMemberMap;

  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);

  Actual := FCut
    .CreateMap
    .GetMemberMap;

  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);
end;

procedure TTestObjectMappingConfig.Test_RefreshDictTwoTimes;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  Actual := FCut
    .CreateMap
    .GetMemberMap;

  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);

  Actual := FCut
    .Clean
    .CreateMap
    .GetMemberMap;

  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);
end;

procedure TTestObjectMappingConfig.Test_WithOwnMappingReverse;
var
  Actual: TDictionary<string, TMappedSrcDest>;
begin
  //  Arrange...
  //  Act...
  Actual := FCut
    .UserMapReverse(
      procedure(ADest: TOrderDTO; ASrc: TOrder)
      begin
        ASrc.Extension := ADest.InnerValue;
      end)
    .CreateMap
    .GetMemberMap;

  //  Assert...
  Assert.AreEqual('orderid,total,customername,', GetStrings(Actual));
  Assert.AreEqual(3, Actual.Count);

  Assert.AreEqual(0, FCut.GetUserMap.Count);
  Assert.AreEqual(1, FCut.GetUserMapReverse.Count);
end;

function TTestObjectMappingConfig.GetDummyProc(const ACapValue: Integer): TFunc<Integer>;
begin
  result :=
    function: Integer
    var
      Idx: Integer;
    begin
      Idx := 2 * ACapValue;
      Result := Idx;
    end;
end;

procedure TTestObjectMappingConfig.Test_WithOwnMappingAndTwoReferences;
type
  PIInterface = ^IInterface;
var
  Actual: Integer;
  LFunc1, LFunc2: TFunc<Integer>;
  LIntfObj1, LIntfObj2: TInterfacedObject;
//  LFuncRev1, LFuncRev2: TFunc<Integer>;
//  Ptr1: Pointer;
begin
  //  https://stackoverflow.com/questions/5154914/how-and-when-are-variables-referenced-in-delphis-anonymous-methods-captured
  //  https://stackoverflow.com/questions/6581006/how-can-i-store-an-interface-method-in-a-method-pointer

  //  https://delphisorcery.blogspot.com/2012/04/creating-delegate-at-runtime.html
  //  http://blog.barrkel.com/2010/01/using-anonymous-methods-in-method.html
  //  http://tech.turbu-rpg.com/30/under-the-hood-of-an-anonymous-method
  //  https://delphisorcery.blogspot.com/2011/07/property-references-in-delphi-possible.html

  //  https://codereview.stackexchange.com/questions/52418/anonymous-events-in-delphi
  //  https://codar.club/blogs/delphi-s-interface-based-multicast-listener-mode-observer-mode.html

  LFunc1 := GetDummyProc(11);
  LFunc2 := LFunc1;
//  Ptr1 := @LFunc1;

  Assert.AreEqual<TFunc<Integer>>(LFunc1, LFunc2);

  LIntfObj1 := PIInterface(@LFunc1)^ as TInterfacedObject;
  LIntfObj2 := PIInterface(@LFunc2)^ as TInterfacedObject;

  Assert.AreEqual<TInterfacedObject>(LIntfObj1, LIntfObj2);

  Actual := LFunc1;
  Assert.AreEqual(22, Actual);

//  Button.OnClick := TAddMapAnonymousEvents<TNotifyEvent,TNotifyEventReference>.Create(
//    procedure (Sender:TObject)
//    begin
//      ShowMessage('it works!');
//    end);
end;

{ TAddMapAnonymousEvents<TTEventPointer, TTEventReference> }

class function TAddMapAnonymousEvents<TTEventPointer, TTEventReference>.Create(AEvent: TTEventReference): TTEventPointer;
type
  TVtable = array[0..3] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
//  TMethod(Result).Code := PPVtable(AEvent)^^[3];
//  TMethod(Result).Data := Pointer(AEvent);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectMappingConfig, 'Config');

end.
