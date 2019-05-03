unit Nathan.ObjectMapping.NamingConvention;

interface

{$M+}

type
  INamingConvention = interface
    ['{4768B825-816A-42E3-8244-4C209CA5B232}']
    function GenerateKeyName(const AValue: string): string;
  end;

  TNamingConvention = class(TInterfacedObject, INamingConvention)
    function GenerateKeyName(const AValue: string): string; virtual;
  end;

  TNamingConventionDecorator = class(TNamingConvention)
  strict private
    FNamingConvention: INamingConvention;
  public
    constructor Create(ANamingConvention: INamingConvention); overload;
    function GenerateKeyName(const AValue: string): string; override;
  end;

  TPrefixFNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  TLowerNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  TUnderscoreNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

  TGetterSetterNamingConvention = class(TNamingConventionDecorator)
    function GenerateKeyName(const AValue: string): string; override;
  end;

{$M-}

implementation

uses
  System.SysUtils,
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
  if AValue.IsEmpty then
    Exit(string.empty);

  Result := IfThen(AValue.ToLower.StartsWith('f'), AValue.Substring(1), AValue);
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

end.
