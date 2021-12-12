{$I AMQP.Options.inc}
unit AMQP.Types;

interface

Uses
  SysUtils, Classes, Generics.Collections,
  AMQP.StreamHelper, AMQP.Arguments;

const
  NewLine = #13#10;
  Tab = '    ';

Type
  AMQPTypeException = Class(Exception);

  TValueKind = (vkBool, vkShortShortInt, vkShortShortUInt, vkShortInt,
    vkShortUInt, vkLongInt, vkLongUInt, vkLongLongInt, vkLongLongUInt, vkFloat,
    vkDouble, vkDecimalValue, vkShortString, vkLongString, vkFieldArray,
    vkTimestamp, vkFieldTable, vkEmpty);

  TBoolean = class;
  TShortShortInt = class;
  TShortShortUInt = class;
  TShortInt = class;
  TShortUInt = class;
  TLongInt = class;
  TLongUInt = class;
  TLongLongInt = class;
  TLongLongUInt = class;
  TShortString = class;
  TLongString = class;
  TFieldTable = class;
  TFieldArray = class;

  TAMQPValue = Class
  strict protected
    FValueKind: TValueKind;
  Public
    Property ValueKind: TValueKind read FValueKind write FValueKind;
    function AsString(AIndent: String): String; virtual; abstract;
    function HeaderChar: AnsiChar;
    Procedure LoadFromStream(AStream: TStream); virtual; abstract;
    Procedure SaveToStream(AStream: TStream); virtual; abstract;
    function Size: Cardinal; virtual; abstract;
    Function AsBoolean: TBoolean;
    Function AsShortShortInt: TShortShortInt;
    Function AsShortShortUInt: TShortShortUInt;
    Function AsShortInt: TShortInt;
    Function AsShortUInt: TShortUInt;
    Function AsLongInt: TLongInt;
    Function AsLongUInt: TLongUInt;
    Function AsLongLongInt: TLongLongInt;
    Function AsLongLongUInt: TLongLongUInt;
    Function AsShortString: TShortString;
    Function AsLongString: TLongString;
    Function AsFieldTable: TFieldTable;
    function AsArray: TFieldArray;
  End;

  TBoolean = Class(TAMQPValue)
  strict private
    FValue: Boolean;
  Public
    function Size: Cardinal; override;
    Property Value: Boolean read FValue write FValue;
    function AsString(AIndent: String): String; Override;

    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Boolean);
  End;

  // Signed octet / Signed byte / ShortInt
  TShortShortInt = Class(TAMQPValue)
  strict private
    FValue: Int8;
  Public
    function Size: Cardinal; override;
    Property Value: Int8 read FValue write FValue;

    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Int8);
  End;

  // Unsigned octet / byte
  TShortShortUInt = Class(TAMQPValue)
  strict private
    FValue: UInt8;
  Public
    function Size: Cardinal; override;
    Property Value: UInt8 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: UInt8);
  End;

  TOctet = TShortShortUInt;

  // Signed 16 bit / SmallInt
  TShortInt = Class(TAMQPValue)
  strict private
    FValue: Int16;
  Public
    function Size: Cardinal; override;
    Property Value: Int16 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Int16);
  End;

  // Unsigned 16 bit / Word
  TShortUInt = Class(TAMQPValue)
  strict private
    FValue: UInt16;
  Public
    function Size: Cardinal; override;

    Property Value: UInt16 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: UInt16);
  End;

  // Signed 32 bit / Integer
  TLongInt = Class(TAMQPValue)
  strict private
    FValue: Int32;
  Public
    function Size: Cardinal; override;

    Property Value: Int32 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Int32);
  End;

  // Unsigned 32 bit / Cardinal
  TLongUInt = Class(TAMQPValue)
  strict private
    FValue: UInt32;
  Public
    function Size: Cardinal; override;
    Property Value: UInt32 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: UInt32);
  End;

  // Signed 64 bit
  TLongLongInt = Class(TAMQPValue)
  strict private
    FValue: Int64;
  Public
    function Size: Cardinal; override;

    Property Value: Int64 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Int64);
  End;

  // Unsigned 64 bit
  TLongLongUInt = Class(TAMQPValue)
  strict private
    FValue: UInt64;
  Public
    function Size: Cardinal; override;

    Property Value: UInt64 read FValue write FValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: UInt64);
  End;

  TTimestamp = TLongLongUInt;

  // Maxlength: 255
  TShortString = Class(TAMQPValue)
  Strict Protected
    FValue: String;
    procedure SetValue(const AValue: String); Virtual;
  Public
    function Size: Cardinal; override;
    Property Value: String read FValue write SetValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: String); Virtual;
  End;

  TLongString = Class(TShortString)
  Strict Protected
    procedure SetValue(const AValue: String); Override;
  Public

    Procedure SaveToStream(AStream: TStream); Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Constructor Create(AValue: String); Override;
    function Size: Cardinal; override;
    function AsString(AIndent: string): string; override;
  End;

  TFloat = class(TAMQPValue)
  Strict Protected
    FValue: Single;
    procedure SetValue(const Value: Single); Virtual;
  Public
    function Size: Cardinal; override;

    Property Value: Single read FValue write SetValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Single); Virtual;
  End;

  TDouble = class(TAMQPValue)
  Strict Protected
    FValue: Double;
    procedure SetValue(const Value: Double); Virtual;
  Public
    function Size: Cardinal; override;

    Property Value: Double read FValue write SetValue;
    function AsString(AIndent: String): String; Override;
    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;
    Constructor Create(AValue: Double); Virtual;
  End;

  TFieldArray = class(TAMQPValue)
  strict protected
    FValue: TObjectList<TAMQPValue>;
  public
    Constructor Create; Virtual;
    destructor Destroy; override;

    function AsString(AIndent: string): String; override;
    function Add(AValue: TAMQPValue): TFieldArray; overload;
    function Add(AValue: string): TFieldArray; overload;
    function Add(AValue: Double): TFieldArray; overload;
    function Add(AValue: Cardinal): TFieldArray; overload;
    function Count: Integer;
    procedure SaveToStream(AStream: TStream); override;

    function Size: Cardinal; override;
    procedure LoadFromStream(AStream: TStream); override;
    Function GetEnumerator: TEnumerator<TAMQPValue>;
  end;

  TFieldValuePair = Class
  strict private
    FName: TShortString;
    FValue: TAMQPValue;
  private
    procedure SetValue(const Value: TAMQPValue);
  public
    Property Name: TShortString read FName write FName;
    Property Value: TAMQPValue read FValue write SetValue;
    Procedure LoadFromStream(AStream: TStream);
    Procedure SaveToStream(AStream: TStream);
    Constructor Create(AName: String = ''; AValue: TAMQPValue = nil);
    Destructor Destroy; Override;
  End;

  { TFieldTable }

  TFieldTable = Class(TAMQPValue)
  Strict Private
    FFields: TObjectList<TFieldValuePair>;
    function GetCount: Integer;
    function GetNameValue(Index: Integer): TFieldValuePair;
    function GetField(FieldName: String): TAMQPValue;
  Public
    function Size: Cardinal; override;

    Property Field[FieldName: String]: TAMQPValue read GetField;
    Property NameValues[Index: Integer]: TFieldValuePair read GetNameValue;
    Property Count: Integer read GetCount;
    function Add(ANameValue: TFieldValuePair): TFieldTable; Overload;
    function Add(AName: String; AValue: TAMQPValue): TFieldTable; Overload;
    function Add(AName: String; AValue: Double): TFieldTable; overload;
    function Add(AName: String; AValue: Cardinal): TFieldTable; overload;
    function Add(AName: String; AValue: String): TFieldTable; overload;
    function Add(AName: String; AValue: Boolean): TFieldTable; overload;
    function Add(AName: String; AValue: Variant): TFieldTable; overload;
    Procedure Clear;
    Procedure Assign(AFieldTable: TFieldTable); Overload;
    Procedure Assign(AArguments: TArguments); Overload;
    function AsString(AIndent: String): String; Override;
    Function GetEnumerator: TEnumerator<TFieldValuePair>;

    Procedure LoadFromStream(AStream: TStream); Override;
    Procedure SaveToStream(AStream: TStream); Override;

    Constructor Create;
    Destructor Destroy; Override;
  End;

Function PadRight(S: String; PaddedLength: Integer): String;

implementation

Uses
  Math, Variants;

type
  PByteArray = ^TByteArray;
  TByteArray = array [0 .. 32767] of Byte;

Function PadRight(S: String; PaddedLength: Integer): String;
Begin
  Result := S;
  while Length(Result) < PaddedLength do
    Result := Result + ' ';
End;

{ TFieldTable }

function TFieldTable.Add(ANameValue: TFieldValuePair): TFieldTable;
begin
  FFields.Add(ANameValue);
  Result := Self;
end;

procedure TFieldTable.Clear;
begin
  FFields.Clear;
end;

constructor TFieldTable.Create;
begin
  FValueKind := vkFieldTable;
  FFields := TObjectList<TFieldValuePair>.Create;
end;

destructor TFieldTable.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TFieldTable.Add(AName: String; AValue: TAMQPValue): TFieldTable;
begin
  Add(TFieldValuePair.Create(AName, AValue));
  Result := Self;
end;

function TFieldTable.Add(AName: String; AValue: Variant): TFieldTable;
var VType: Integer;
begin
  VType:= tvardata(AValue).vtype;
  case VType of
    varempty: Result := Self;
    varnull:  Result := Self;
    varint64: Result := Add(AName, tvardata(AValue).vint64);
    varinteger:  Result := Add(AName, tvardata(AValue).vinteger);
    varword: Result := Add(AName, tvardata(AValue).vword);
    varbyte: Result := Add(AName, tvardata(AValue).vbyte);
    varshortint: Result := Add(AName, tvardata(AValue).vshortint);
    varstring, varustrarg:  Result := Add(AName, VarToStr(AValue));
    vardouble:  Result := Add(AName, tvardata(AValue).vdouble);
    varboolean:  Result := Add(AName, tvardata(AValue).vboolean);
  end;
end;

procedure TFieldTable.Assign(AFieldTable: TFieldTable);
var
  Stream: TMemoryStream;
begin
  Clear;
  Stream := TMemoryStream.Create;
  Try
    AFieldTable.SaveToStream(Stream);
    Stream.Position := 0;
    LoadFromStream(Stream);
  Finally
    Stream.Free;
  End;
end;

function TFieldTable.Add(AName: String; AValue: Double): TFieldTable;
begin
  Result := Add(AName, TDouble.Create(AValue));
end;

function TFieldTable.Add(AName: String; AValue: Cardinal): TFieldTable;
begin
  Result := Add(AName, TLongLongUInt.Create(AValue));
end;

procedure TFieldTable.Assign(AArguments: TArguments);

  Function MakeValue(AValue: Variant): TAMQPValue;
  var
    BasicType: Integer;
  begin
    BasicType := VarType(AValue) and VarTypeMask;
    case BasicType of
      varBoolean:
        Result := TBoolean.Create(AValue);
      varSmallInt, varByte, varShortInt,
      // : Result := TShortInt.Create(AValue);
      varWord, varInteger, // : Result := TLongInt.Create(AValue);
      varLongWord, varInt64:
        Result := TLongLongUInt.Create(AValue);
      varString, varUString: // If Length(AValue) <= 255 then
        // Result := TShortString.Create(AValue)  //unsupported by RabbitMQ
        // else
        Result := TLongString.Create(AValue);
    else
      raise EInvalidArgument.Create('Unsupported variant type in TArguments');
    end;
  end;

var
  Argument: TArgument;
begin
  Clear;
  for Argument in AArguments do
    Add(TFieldValuePair.Create(Argument.Name, MakeValue(Argument.Value)));
end;

function TFieldTable.AsString(AIndent: String): String;
var
  ValuePair: TFieldValuePair;
  MaxLength: Integer;
begin
  MaxLength := 0;
  for ValuePair in FFields do
    MaxLength := Max(MaxLength, ValuePair.Name.Value.Length);

  AIndent := AIndent + Tab;
  Result := NewLine + AIndent + '{ ' + NewLine;
  for ValuePair in FFields do
    Result := Result + AIndent + Tab + PadRight(ValuePair.Name.Value + ': ',
      MaxLength + 2) + ValuePair.Value.AsString(AIndent + Tab) + NewLine;
  Result := Result + AIndent + '}';
end;

function TFieldTable.GetEnumerator: TEnumerator<TFieldValuePair>;
begin
  Result := FFields.GetEnumerator;
end;

function TFieldTable.GetField(FieldName: String): TAMQPValue;
var
  ValuePair: TFieldValuePair;
begin
  for ValuePair in FFields do
    if SameText(ValuePair.Name.Value, FieldName) then
      Exit(ValuePair.Value);
  raise AMQPTypeException.Create('Field not found: ' + FieldName);
end;

function TFieldTable.GetNameValue(Index: Integer): TFieldValuePair;
begin
  Result := FFields[Index];
end;

procedure TFieldTable.LoadFromStream(AStream: TStream);
var
  Size: UInt32;
  StartOfTable: UInt32;
  ValuePair: TFieldValuePair;
begin
  AStream.ReadUInt32(Size);
  StartOfTable := AStream.Position;
  while (AStream.Position - StartOfTable) < Size do
  Begin
    ValuePair := TFieldValuePair.Create;
    FFields.Add(ValuePair);
    ValuePair.LoadFromStream(AStream);
  End;
end;

procedure TFieldTable.SaveToStream(AStream: TStream);
var
  ValuePair: TFieldValuePair;
  TableStream: TMemoryStream;
  Size: Cardinal;
begin
  TableStream := TMemoryStream.Create;
  Try
    for ValuePair in FFields do
      ValuePair.SaveToStream(TableStream);
    Size := TableStream.Size;
    AStream.WriteUInt32(Size);
    AStream.CopyFrom(TableStream, 0);
  Finally
    TableStream.Free;
  End;
end;

function TFieldTable.Size: Cardinal;
var
  ValuePair: TFieldValuePair;
  TableStream: TMemoryStream;
begin
  TableStream := TMemoryStream.Create;
  Try
    for ValuePair in FFields do
      ValuePair.SaveToStream(TableStream);
    Result := TableStream.Size;
  Finally
    TableStream.Free;
  End;
end;

function TFieldTable.GetCount: Integer;
begin
  Result := FFields.Count;
end;

{ TBoolValue }

constructor TBoolean.Create(AValue: Boolean);
begin
  FValue := AValue;
  FValueKind := vkBool;
end;

procedure TBoolean.LoadFromStream(AStream: TStream);
var
  B: Byte;
begin
  AStream.ReadUInt8(B);
  FValue := B <> 0;
end;

procedure TBoolean.SaveToStream(AStream: TStream);
var
  B: Byte;
begin
  B := 0;
  if Value then
    B := 1;
  AStream.WriteData(B);
end;

function TBoolean.Size: Cardinal;
begin
  Result := 1;
end;

function TBoolean.AsString(AIndent: String): String;
begin
  Result := BoolToStr(FValue, True);
end;

{ TShortStringValue }

constructor TShortString.Create(AValue: String);
begin
  FValue := AValue;
  FValueKind := vkShortString;
end;

procedure TShortString.LoadFromStream(AStream: TStream);
begin
  AStream.ReadShortStr(FValue);
end;

procedure TShortString.SaveToStream(AStream: TStream);
begin
  AStream.WriteShortStr(Value);
end;

procedure TShortString.SetValue(const AValue: String);
begin
  if AValue.Length > 255 then
    raise EInvalidArgument.Create('Max length exceeded');
  FValue := AValue;
end;

function TShortString.Size: Cardinal;
begin
  Result := Length(FValue);
end;

function TShortString.AsString(AIndent: String): String;
begin
  Result := FValue;
end;

{ TLongStringValue }

function TLongString.AsString(AIndent: string): string;
begin
 Result := FValue;
end;

constructor TLongString.Create(AValue: String);
begin
  inherited;
  FValueKind := vkLongString;
end;

procedure TLongString.LoadFromStream(AStream: TStream);
begin
  AStream.ReadLongStr(FValue);
end;

procedure TLongString.SaveToStream(AStream: TStream);
var
  Char: AnsiChar;
  Str: AnsiString;
  I: Cardinal;
begin
  I := Value.Length;
  Str := AnsiString(Value);
  AStream.WriteMSB(I, 4);
  for Char in Str do
    AStream.WriteData(Char);
end;

procedure TLongString.SetValue(const AValue: String);
begin
  FValue := AValue;
end;

function TLongString.Size: Cardinal;
begin
  Result := Length(FValue);
end;

function TFieldTable.Add(AName, AValue: String): TFieldTable;
begin
  Result := Add(AName, TLongString.Create(AValue));
end;

function TFieldTable.Add(AName: String; AValue: Boolean): TFieldTable;
begin
 Result := Add(AName, TBoolean.Create(AValue));
end;

{ TFieldValuePair }

constructor TFieldValuePair.Create(AName: String = '';
  AValue: TAMQPValue = nil);
begin
  FName := TShortString.Create(AName);
  FValue := AValue;
end;

destructor TFieldValuePair.Destroy;
begin
  FName.Free;
  FValue.Free;
  inherited;
end;

procedure TFieldValuePair.LoadFromStream(AStream: TStream);
var
  C: System.AnsiChar;
begin
  FValue.Free;
  FName.LoadFromStream(AStream);
  AStream.Read(C, 1);
  case C of
    't':
      FValue := TBoolean.Create(False);
    'b':
      FValue := TShortShortInt.Create(0);
    'B':
      FValue := TShortShortUInt.Create(0);
    'U':
      FValue := TShortInt.Create(0);
    'u':
      FValue := TShortUInt.Create(0);
    'I':
      FValue := TLongInt.Create(0);
    'i':
      FValue := TLongUInt.Create(0);
    // 'L' : FValue := TLongLongInt.Create(0);   //AMQP 0-9-1 specification
    // 'l' : FValue := TLongLongUInt.Create(0);  //AMQP 0-9-1 specification
    'l':
      FValue := TLongLongInt.Create(0);
      // RabbitMQ specification (see errata here: https://www.rabbitmq.com/amqp-0-9-1-errata.html)
    's':
      FValue := TShortString.Create('');
    'S':
      FValue := TLongString.Create('');
    'F':
      FValue := TFieldTable.Create;
    // TODO: Add support for these types!
    'f':
      FValue := TFloat.Create(0.0);
    'd':
      FValue := TDouble.Create(0.0);
    // 'D' : FValue := TDecimalValue.Create(0.0);
     'A' : FValue := TFieldArray.Create;
    // 'T' : FValue := TTimestamp.Create;
    // 'V' : FValue := TEmpty.Create;
  else
    raise AMQPTypeException.Create('Unsupported field-value: ' + C);
  end;
  FValue.LoadFromStream(AStream);
end;

procedure TFieldValuePair.SaveToStream(AStream: TStream);
begin
  FName.SaveToStream(AStream);
  AStream.WriteData(FValue.HeaderChar);
  FValue.SaveToStream(AStream);
end;

procedure TFieldValuePair.SetValue(const Value: TAMQPValue);
begin
  FValue.Free;
  FValue := Value;
end;

{ TShortShortInt }

function TShortShortInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TShortShortInt.Create(AValue: Int8);
begin
  FValueKind := vkShortShortInt;
  FValue := AValue;
end;

procedure TShortShortInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadInt8(FValue);
end;

procedure TShortShortInt.SaveToStream(AStream: TStream);
begin
  AStream.Write(FValue, 1);
end;

function TShortShortInt.Size: Cardinal;
begin
  Result := 1;
end;

{ TShortShortUInt }

function TShortShortUInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TShortShortUInt.Create(AValue: UInt8);
begin
  FValueKind := vkShortShortUInt;
  FValue := AValue;
end;

procedure TShortShortUInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadUInt8(FValue);
end;

procedure TShortShortUInt.SaveToStream(AStream: TStream);
begin
  AStream.Write(FValue, 1);
end;

function TShortShortUInt.Size: Cardinal;
begin
  Result := 1;
end;

{ TShortInt }

function TShortInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TShortInt.Create(AValue: Int16);
begin
  FValueKind := vkShortInt;
  FValue := AValue;
end;

procedure TShortInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadInt16(FValue);
end;

procedure TShortInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 2);
end;

function TShortInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TShortUInt }

function TShortUInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TShortUInt.Create(AValue: UInt16);
begin
  FValueKind := vkShortUInt;
  FValue := AValue;
end;

procedure TShortUInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadUInt16(FValue);
end;

procedure TShortUInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 2);
end;

function TShortUInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TLongInt }

function TLongInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TLongInt.Create(AValue: Int32);
begin
  FValueKind := vkLongInt;
  FValue := AValue;
end;

procedure TLongInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadInt32(FValue);
end;

procedure TLongInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 4);
end;

function TLongInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TLongUInt }

function TLongUInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TLongUInt.Create(AValue: UInt32);
begin
  FValueKind := vkLongUInt;
  FValue := AValue;
end;

procedure TLongUInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadUInt32(FValue);
end;

procedure TLongUInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 4);
end;

function TLongUInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TLongLongInt }

function TLongLongInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TLongLongInt.Create(AValue: Int64);
begin
  FValueKind := vkLongLongInt;
  FValue := AValue;
end;

procedure TLongLongInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadInt64(FValue);
end;

procedure TLongLongInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 8);
end;

function TLongLongInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TLongLongUInt }

function TLongLongUInt.AsString(AIndent: String): String;
begin
  Result := IntToStr(FValue);
end;

constructor TLongLongUInt.Create(AValue: UInt64);
begin
  FValueKind := vkLongLongUInt;
  FValue := AValue;
end;

procedure TLongLongUInt.LoadFromStream(AStream: TStream);
begin
  AStream.ReadUInt64(FValue);
end;

procedure TLongLongUInt.SaveToStream(AStream: TStream);
begin
  AStream.WriteMSB(FValue, 8);
end;

function TLongLongUInt.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TAMQPValue }

function TAMQPValue.AsArray: TFieldArray;
begin
 Result := Self As TFieldArray;
end;

function TAMQPValue.AsBoolean: TBoolean;
begin
  Result := Self as TBoolean;
end;

function TAMQPValue.AsFieldTable: TFieldTable;
begin
  Result := Self as TFieldTable;
end;

function TAMQPValue.AsLongInt: TLongInt;
begin
  Result := Self as TLongInt;
end;

function TAMQPValue.AsLongLongInt: TLongLongInt;
begin
  Result := Self as TLongLongInt;
end;

function TAMQPValue.AsLongLongUInt: TLongLongUInt;
begin
  Result := Self as TLongLongUInt;
end;

function TAMQPValue.AsLongString: TLongString;
begin
  Result := Self as TLongString;
end;

function TAMQPValue.AsLongUInt: TLongUInt;
begin
  Result := Self as TLongUInt;
end;

function TAMQPValue.AsShortInt: TShortInt;
begin
  Result := Self as TShortInt;
end;

function TAMQPValue.AsShortShortInt: TShortShortInt;
begin
  Result := Self as TShortShortInt;
end;

function TAMQPValue.AsShortShortUInt: TShortShortUInt;
begin
  Result := Self as TShortShortUInt;
end;

function TAMQPValue.AsShortString: TShortString;
begin
  Result := Self as TShortString;
end;

function TAMQPValue.AsShortUInt: TShortUInt;
begin
  Result := Self as TShortUInt;
end;

function TAMQPValue.HeaderChar: AnsiChar;
begin
  case FValueKind of
    vkBool:
      Result := 't';
    vkShortShortInt:
      Result := 'b';
    vkShortShortUInt:
      Result := 'B';
    vkShortInt:
      Result := 'U';
    vkShortUInt:
      Result := 'u';
    vkLongInt:
      Result := 'I';
    vkLongUInt:
      Result := 'i';
    vkLongLongInt:
      Result := 'L'; // AMQP 0-9-1 specification
    vkLongLongUInt:
      Result := 'l'; // AMQP 0-9-1 specification
    // vkLongLongInt    : Result := 'l';  //RabbitMQ specification (see errata here: https://www.rabbitmq.com/amqp-0-9-1-errata.html)
    vkShortString:
      Result := 's';
    vkLongString:
      Result := 'S';
    vkFieldTable:
      Result := 'F';
    vkFloat:
      Result := 'f';
    vkDouble:
      Result := 'd';
    vkDecimalValue:
      Result := 'D';
    vkFieldArray:
      Result := 'A';
    vkTimestamp:
      Result := 'T';
    vkEmpty:
      Result := 'V';
  else
    raise AMQPTypeException.Create('Unsupported ValueKind');
  end;
end;

{ TFloat }

function TFloat.AsString(AIndent: String): String;
begin
  Result := FloatToStr(FValue);
end;

constructor TFloat.Create(AValue: Single);
begin
  FValue := AValue;
  FValueKind := vkFloat;
end;

procedure TFloat.LoadFromStream(AStream: TStream);
begin
  AStream.ReadFloat(FValue);
end;

procedure TFloat.SaveToStream(AStream: TStream);
begin
  AStream.WriteFloat(FValue);
end;

procedure TFloat.SetValue(const Value: Single);
begin
  FValue := Value;
end;

function TFloat.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TDouble }

function TDouble.AsString(AIndent: String): String;
begin
  Result := FloatToStr(FValue);
end;

constructor TDouble.Create(AValue: Double);
begin
  FValue := AValue;
  FValueKind := vkDouble;
end;

procedure TDouble.LoadFromStream(AStream: TStream);
begin
  AStream.ReadDouble(FValue);
end;

procedure TDouble.SaveToStream(AStream: TStream);
begin
  AStream.WriteDouble(FValue);
end;

procedure TDouble.SetValue(const Value: Double);
begin
  FValue := Value;
end;

function TDouble.Size: Cardinal;
begin
  Result := SizeOf(FValue);
end;

{ TAMQPArray }

function TFieldArray.Add(AValue: TAMQPValue): TFieldArray;
begin
  FValue.Add(AValue);
  Result := Self;
end;

function TFieldArray.Add(AValue: string): TFieldArray;
begin
  Result := Add(TLongString.Create(AValue));
end;

function TFieldArray.Add(AValue: Double): TFieldArray;
begin
  Result := Add(TDouble.Create(AValue));
end;

function TFieldArray.Add(AValue: Cardinal): TFieldArray;
begin
  Result := Add(TLongLongUInt.Create(AValue));
end;

function TFieldArray.AsString(AIndent: string): String;
var
  Value: TAMQPValue;
  MaxLength: Integer;
begin
  MaxLength := 0;
  Result := 'Array:' + NewLine + AIndent + Tab+' { ' + NewLine;
  for Value in FValue do
    Result := Result + AIndent + Tab + Tab + Value.AsString(AIndent + Tab) + NewLine;
  Result := Result + AIndent + Tab + ' } ';
end;

function TFieldArray.Count: Integer;
begin
  Result := FValue.Count;
end;

constructor TFieldArray.Create;
begin
  FValue := TObjectList<TAMQPValue>.Create();
  FValueKind := vkFieldArray;
end;

destructor TFieldArray.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TFieldArray.GetEnumerator: TEnumerator<TAMQPValue>;
begin
 Result := FValue.GetEnumerator;
end;

procedure TFieldArray.LoadFromStream(AStream: TStream);
var
  LSize: UInt32;
  StartOfArray: UInt32;
  Value: TAMQPValue;
  C: System.AnsiChar;
begin
  AStream.ReadUInt32(LSize);
  StartOfArray := AStream.Position;
  Value := nil;
  while (AStream.Position - StartOfArray) < LSize do
  Begin
    AStream.Read(C, 1);
    case C of
      't':
        Value := TBoolean.Create(False);
      'b':
        Value := TShortShortInt.Create(0);
      'B':
        Value := TShortShortUInt.Create(0);
      'U':
        Value := TShortInt.Create(0);
      'u':
        Value := TShortUInt.Create(0);
      'I':
        Value := TLongInt.Create(0);
      'i':
        Value := TLongUInt.Create(0);
      // 'L' :  Value := TLongLongInt.Create(0);   //AMQP 0-9-1 specification
      // 'l' :  Value := TLongLongUInt.Create(0);  //AMQP 0-9-1 specification
      'l':
        Value := TLongLongInt.Create(0);
        // RabbitMQ specification (see errata here: https://www.rabbitmq.com/amqp-0-9-1-errata.html)
      's':
        Value := TShortString.Create('');
      'S':
        Value := TLongString.Create('');
      'F':
        Value := TFieldTable.Create;
      // TODO: Add support for these types!
      'f':
        Value := TFloat.Create(0.0);
      'd':
        Value := TDouble.Create(0.0);
      // 'D' : Value := TDecimalValue.Create(0.0);
      // 'A' : Value := TFieldArray.Create;
      // 'T' : Value := TTimestamp.Create;
      // 'V' : Value := TEmpty.Create;
    else
      raise AMQPTypeException.Create('Unsupported field-value: ' + C);
    end;
    Value.LoadFromStream(AStream);

    FValue.Add(Value);

  End;
end;

procedure TFieldArray.SaveToStream(AStream: TStream);
var
  Value: TAMQPValue;
  ArrayStream: TMemoryStream;
  LSize: Cardinal;
begin
  ArrayStream := TMemoryStream.Create;
  Try
    for Value in FValue do
    begin
      ArrayStream.WriteData(Value.HeaderChar);
      Value.SaveToStream(ArrayStream);
    end;
    LSize := ArrayStream.Size;
    AStream.WriteUInt32(LSize);
    AStream.CopyFrom(ArrayStream, 0);
  Finally
    ArrayStream.Free;
  End;
end;

function TFieldArray.Size: Cardinal;
var
  Value: TAMQPValue;
begin
  Result := 0;
  for Value in FValue do
    Inc(Result, Value.Size);
end;

end.
