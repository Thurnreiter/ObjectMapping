unit Nathan.ObjectMapping.NamingConvention;

interface

uses
  System.SysUtils;

{$M+}

type
  INamingConvention = interface
    ['{4768B825-816A-42E3-8244-4C209CA5B232}']
    function GenerateKeyName(const AValue: string): string;
  end;

  /// <summary>
  ///   Base class for all derived naming converation.
  /// </summary>
  TNamingConvention = class(TInterfacedObject, INamingConvention)
    function GenerateKeyName(const AValue: string): string; virtual;
  end;

  /// <summary>
  ///   Base decorator class for all derived.
  /// </summary>
  TNamingConventionDecorator = class(TNamingConvention)
  strict private
    FNamingConvention: INamingConvention;
  public
    constructor Create(ANamingConvention: INamingConvention); overload;
    function GenerateKeyName(const AValue: string): string; override;
  end;

  /// <summary>
  ///   Replaces all leading "F".
  /// </summary>
  TPrefixFNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  /// <summary>
  ///   Put all in lower case letters.
  /// </summary>
  TLowerNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  /// <summary>
  ///   Removes all underscores.
  /// </summary>
  TUnderscoreNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  /// <summary>
  ///   Removes all leading "GET" or "SET".
  /// </summary>
  TGetterSetterNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  /// <summary>
  ///   Own function to replace.
  /// </summary>
  TOwnFuncNamingConvention = class(TNamingConventionDecorator)
  strict private
    FOwnFunc: TFunc<string, string>;
  public
    constructor Create(ANamingConvention: INamingConvention; AOwnFunc: TFunc<string, string>); overload;
    function GenerateKeyName(const AValue: string): string; override;
  end;

{$M-}

implementation

uses
  System.StrUtils;

{ **************************************************************************** }

{ TNamingConvention }

function TNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  Result := AValue;
end;

{ **************************************************************************** }

{ TNamingConventionDecorator }

constructor TNamingConventionDecorator.Create(ANamingConvention: INamingConvention);
begin
  inherited Create();
  FNamingConvention := ANamingConvention;
end;

{ **************************************************************************** }

function TNamingConventionDecorator.GenerateKeyName(const AValue: string): string;
begin
  Result := FNamingConvention.GenerateKeyName(AValue);
end;

{ **************************************************************************** }

{ TPrefixFNamingConvention }

function TPrefixFNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  Result := inherited GenerateKeyName(IfThen(AValue.ToLower.StartsWith('f'), AValue.Substring(1), AValue))
end;

{ **************************************************************************** }

{ TLowerNamingConvention }

function TLowerNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  //  That is, userAccount is a camel case and UserAccount is a Pascal case.
  Result := inherited GenerateKeyName(AValue.ToLower)
end;

{ **************************************************************************** }

{ TUnderscoreNamingConvention }

function TUnderscoreNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  Result := inherited GenerateKeyName(AValue.Replace('_', ''))
end;

{ **************************************************************************** }

{ TGetterSetterNamingConvention }

function TGetterSetterNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  Result := inherited GenerateKeyName(
    AValue
      .Replace('set', '', [rfIgnoreCase])
      .Replace('get', '', [rfIgnoreCase]))
end;

{ **************************************************************************** }

{ TOwnFuncNamingConvention }

constructor TOwnFuncNamingConvention.Create(ANamingConvention: INamingConvention; AOwnFunc: TFunc<string, string>);
begin
  inherited Create(ANamingConvention);
  FOwnFunc := AOwnFunc;
end;

function TOwnFuncNamingConvention.GenerateKeyName(const AValue: string): string;
begin
  Result := inherited GenerateKeyName(FOwnFunc(AValue))
end;

end.
