unit Nathan.ObjectMapping.Types;

interface

uses
  System.SysUtils,
  System.Rtti;

{$M+}

type
  TMappingType = (mtUnknown, mtField, mtProperty, mtMethod);

  TCoreMapDetails = record
    RttiTypeName: string;
    Name: string;
    TypeOfWhat: TTypeKind;
    MappingType: TMappingType;
    MemberClass: TRttiMember;
  end;

  MappedSrcDest = (msdSource, msdDestination);

  TMappedSrcDest = array [MappedSrcDest] of TCoreMapDetails;

{$M+}

implementation

end.
