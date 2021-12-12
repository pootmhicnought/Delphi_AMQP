{$I AMQP.Options.inc}
unit AMQP.Method;
interface

Uses
  Classes, Generics.Collections, AMQP.Types, AMQP.Payload, AMQP.Protocol;

Type
  TAMQPMethod = Class(TAMQPPayload)
  strict private
    FMethodID   : TShortUInt;
    FClassID    : TShortUInt;
    FFieldNames : TStringList;
    FFields     : TObjectList<TAMQPValue>;
    Procedure MakeFields( AClassID, AMethodID: UInt16 );
    function GetField(FieldName: String): TAMQPValue;
  Public
    Property ClassID  : TShortUInt read FClassID;
    Property MethodID : TShortUInt read FMethodID;
    Property Field[ FieldName: String ]: TAMQPValue read GetField;
    Function IsMethod( AMQPMethod: TAMQPMethodID ): Boolean;
    Procedure CheckMethod( AMQPMethod: TAMQPMethodID );
    function FindField(FieldName: String): TAMQPValue;
    Procedure Add( AFieldName: String; AValue: TAMQPValue );
    Procedure LoadFromStream( AStream: TStream ); Override;
    Procedure SaveToStream( AStream: TStream );
    Procedure Display( AStrings: TStrings );
    Constructor Create; Override;
    Constructor CreateMethod( AMQPMethod: TAMQPMethodID ); Overload;
    Destructor Destroy; Override;
  End;

implementation

Uses
  Math, SysUtils, AMQP.Classes;

{ TAMQPMethod }

procedure TAMQPMethod.Add(AFieldName: String; AValue: TAMQPValue);
begin
  FFieldNames.Add( AFieldName );
  FFields.Add( AValue );
end;

procedure TAMQPMethod.CheckMethod(AMQPMethod: TAMQPMethodID);
begin
  if not IsMethod( AMQPMethod ) then
    raise AMQPException.Create('Unexpected frame');
end;

constructor TAMQPMethod.Create;
begin
  inherited;
  FFieldNames := TStringList.Create;
  FFields   := TObjectList<TAMQPValue>.Create;
  FClassID  := TShortUInt.Create( 0 );
  FMethodID := TShortUInt.Create( 0 );
  Add( 'class-id',  FClassID  );
  Add( 'method-id', FMethodID );
end;

constructor TAMQPMethod.CreateMethod(AMQPMethod: TAMQPMethodID);
begin
  Create;
  MakeFields( AMQPMethod.ClassID, AMQPMethod.MethodID );
end;

destructor TAMQPMethod.Destroy;
begin
  FFields.Free;
  FFieldNames.Free;
  inherited;
end;

procedure TAMQPMethod.Display(AStrings: TStrings);
var
  MaxLength, Index: Integer;
begin
  MaxLength := 0;
  for Index := 0 to FFieldNames.Count-1 do
    MaxLength := Max( MaxLength, FFieldNames[Index].Length + 2 );
  AStrings.Add( 'Method: ' + Name );
  AStrings.Add( '-------------------------------' );
  for Index := 0 to FFields.Count-1 do
    AStrings.Add( (FFieldNames[Index] + ': ').PadRight( MaxLength ) + FFields[Index].AsString('') );
  AStrings.Add( '' );
end;

function TAMQPMethod.FindField(FieldName: String): TAMQPValue;
var
  Index: Integer;
begin
  Index := FFieldNames.IndexOf( FieldName );
  if Index = -1 then
    Result := nil
  else
    Result := FFields[ Index ];
end;

function TAMQPMethod.GetField(FieldName: String): TAMQPValue;
begin
  Result := FindField( FieldName );
  if Result = nil then
    raise AMQPException.Create('Field not found: ' + FieldName);
end;

function TAMQPMethod.IsMethod(AMQPMethod: TAMQPMethodID): Boolean;
begin
  Result := (ClassID.Value  = AMQPMethod.ClassID) and
            (MethodID.Value = AMQPMethod.MethodID);
end;

procedure TAMQPMethod.LoadFromStream(AStream: TStream);
var
  i: Integer;
begin
  FClassID.LoadFromStream( AStream );
  FMethodID.LoadFromStream( AStream );
  MakeFields( FClassID.Value, FMethodID.Value );

  for i := 2 to FFields.Count-1 do
    FFields[i].LoadFromStream( AStream );
end;

procedure TAMQPMethod.MakeFields(AClassID, AMethodID: UInt16);
begin
  ClassID.Value  := AClassID;
  MethodID.Value := AMethodID;
  case AClassID of
    AMQP_CLASS_CONNECTION:
      case AMethodID of
        10: Begin
              Name := 'connection.start';
              Add( 'version-major',     TShortShortUInt.Create(0) );
              Add( 'version-minor',     TShortShortUInt.Create(0) );
              Add( 'server-properties', TFieldTable.Create );
              Add( 'mechanisms',        TLongString.Create('') );
              Add( 'locales',           TLongString.Create('') );
            End;
        11: Begin
              Name := 'connection.start-ok';
              Add( 'client-properties', TFieldTable.Create );
              Add( 'mechanism',         TShortString.Create( 'AMQPLAIN' ) );
              Add( 'response',          TFieldTable.Create );
              Add( 'locale',            TShortString.Create( 'en_US' ) );
              Field[ 'client-properties' ].AsFieldTable.Add( 'library',         TLongString.Create( 'Delphi/FPC-AMQP' ) );
              Field[ 'client-properties' ].AsFieldTable.Add( 'library_version', TLongString.Create( '2.0' ) );
              Field[ 'response' ].AsFieldTable.Add( 'LOGIN',    TLongString.Create( '' ) );
              Field[ 'response' ].AsFieldTable.Add( 'PASSWORD', TLongString.Create( '' ) );
            End;
        30: Begin
              Name := 'connection.tune';
              Add( 'channel-max', TShortUInt.Create(0) );
              Add( 'frame-max',   TLongUInt.Create(0) );
              Add( 'heartbeat',   TShortUInt.Create(0) );
            End;
        31: Begin
              Name := 'connection.tune-ok';
              Add( 'channel-max', TShortUInt.Create( 0 ) );
              Add( 'frame-max',   TLongUInt.Create( 131072 ) );
              Add( 'heartbeat',   TShortUInt.Create( 60 ) );
            End;
        40: Begin
              Name := 'connection.open';
              Add( 'virtual-host', TShortString.Create( '/' ) );
              Add( 'capabilities', TShortString.Create( '' ) );
              Add( 'insist',       TBoolean.Create(false) );
            End;
        41: Begin
              Name := 'connection.open-ok';
              Add( 'known-hosts', TShortString.Create('') );
            End;
        50: Begin
              Name := 'connection.close';
              Add( 'reply-code',   TShortUInt.Create( 200 ) );
              Add( 'reply-text',   TShortString.Create( 'Goodbye' ) );
              Add( 'class-id',     TShortUInt.Create( 0 ) );
              Add( 'method-id',    TShortUInt.Create( 0 ) );
            End;
        51: Begin
              Name := 'connection.close-ok';
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
    AMQP_CLASS_CHANNEL:
      case AMethodID of
        10: Begin
              Name := 'channel.open';
              Add( 'out-of-order', TShortString.Create( '' ) );
            End;
        11: Begin
              Name := 'channel.open-ok';
              Add( 'mechanism', TShortString.Create( '' ) );
            End;
        20: Begin
              Name := 'channel.flow';
              Add( 'active', TBoolean.Create( False ) );
            End;
        21: Begin
              Name := 'channel.flow-ok';
              Add( 'active', TBoolean.Create( False ) );
            End;
        40: Begin
              Name := 'channel.close';
              Add( 'reply-code',   TShortUInt.Create( 0 ) );
              Add( 'reply-text',   TShortString.Create( '' ) );
              Add( 'class-id',     TShortUInt.Create( 0 ) );
              Add( 'method-id',    TShortUInt.Create( 0 ) );
            End;
        41: Begin
              Name := 'channel.close-ok';
              Add( 'active', TBoolean.Create( False ) );
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
    AMQP_CLASS_EXCHANGE:
      case AMethodID of
        10: Begin
              Name := 'exchange.declare';
              Add( 'ticket',     TShortUInt.Create( 0 ) );
              Add( 'exchange',   TShortString.Create( '' ) );
              Add( 'type',       TShortString.Create( '' ) );
              Add( 'passive',    TBoolean.Create( False ) );
              Add( 'durable',    TBoolean.Create( False ) );
              Add( 'autodelete', TBoolean.Create( False ) );
              Add( 'internal',   TBoolean.Create( False ) );
              Add( 'no-wait',    TBoolean.Create( False ) );
              Add( 'arguments',  TFieldTable.Create );
            end;
        11: Begin
              Name := 'exchange.declare-ok';
            End;
        20: Begin
              Name := 'exchange.delete';
              Add( 'ticket', TShortUInt.Create( 0 ) );
              Add( 'exchange',   TShortString.Create( '' ) );
              Add( 'if-unused',  TBoolean.Create( False ) );
              Add( 'no-wait',    TBoolean.Create( False ) );
            end;
        21: Begin
              Name := 'exchange.delete-ok';
            End;
        30: begin
              Name := 'exchange.bind';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'destination', TShortString.Create( '' ) );
              Add( 'source',      TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ));
              Add( 'no-wait',     TBoolean.Create( False ) );
              Add( 'arguments',   TFieldTable.Create);
            End;
        31: Begin
              Name := 'exchange.bind-ok';
            End;
        40: begin
              Name := 'exchange.unbind';
              Add( 'reserved-1',  TShortUInt.Create( 0 ) );
              Add( 'destination', TShortString.Create( '' ) );
              Add( 'source',      TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ));
              Add( 'no-wait',     TBoolean.Create( False ) );
              Add( 'arguments',   TFieldTable.Create);
            End;
        51: Begin
              Name := 'exchange.unbind-ok';
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
    AMQP_CLASS_QUEUE:
      case AMethodID of
        10: Begin
              Name := 'queue.declare';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'passive',     TBoolean.Create( False ) );
              Add( 'durable',     TBoolean.Create( False ) );
              Add( 'exclusive',   TBoolean.Create( False ) );
              Add( 'auto-delete', TBoolean.Create( False ) );
              Add( 'no-wait',     TBoolean.Create( False ) );
              Add( 'arguments',   TFieldTable.Create );
            end;
        11: Begin
              Name := 'queue.declare-ok';
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'message-count',  TLongUInt.Create( 0 ) );
              Add( 'consumer-count', TLongUInt.Create( 0 ) );
            End;
        20: Begin
              Name := 'queue.bind';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'exchange',    TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ) );
              Add( 'no-wait',     TBoolean.Create( False ) );
              Add( 'arguments',   TFieldTable.Create );
            end;
        21: Begin
              Name := 'queue.bind-ok';
            End;
        30: Begin
              Name := 'queue.purge';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'no-wait',     TBoolean.Create( False ) );
            end;
        31: Begin
              Name := 'queue.purge-ok';
            End;
        40: Begin
              Name := 'queue.delete';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'if-unused',   TBoolean.Create( False ) );
              Add( 'if-empty',    TBoolean.Create( False ) );
              Add( 'no-wait',     TBoolean.Create( False ) );
            end;
        41: Begin
              Name := 'queue.delete-ok';
              Add( 'message-count',  TLongUInt.Create( 0 ) );
            End;
        50: Begin
              Name := 'queue.unbind';
              Add( 'ticket',  TShortUInt.Create( 0 ) );
              Add( 'queue',       TShortString.Create( '' ) );
              Add( 'exchange',    TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ) );
              Add( 'arguments',   TFieldTable.Create );
            end;
        51: Begin
              Name := 'queue.unbind-ok';
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
    AMQP_CLASS_BASIC:
      case AMethodID of
        10: Begin
              Name := 'basic.qos';
              Add('prefetch-size', TLongUInt.Create(0));
              Add('prefetch-count', TShortUInt.Create(0));
              Add('global', TBoolean.Create(False));
            End;
        11: begin
              Name := 'basic.qos-ok';
            end;
        20: Begin
              Name := 'basic.consume';
              Add( 'ticket',   TShortUInt.Create( 0 ) );
              Add( 'queue',        TShortString.Create( '' ) );
              Add( 'consumer-tag', TShortString.Create( '' ) );
              Add( 'no-local',     TBoolean.Create( False ) );
              Add( 'no-ack',       TBoolean.Create( False ) );
              Add( 'exclusive',    TBoolean.Create( False ) );
              Add( 'no-wait',      TBoolean.Create( False ) );
              Add( 'arguments',    TFieldTable.Create );
            End;
        21: Begin
              Name := 'basic.consume-ok';
              Add( 'consumer-tag', TShortString.Create( '' ) );
            End;
        30: Begin
              Name := 'basic.consume';
              Add( 'consumer-tag', TShortString.Create( '' ) );
              Add( 'no-wait',      TBoolean.Create( False ) );
            End;
        31: Begin
              Name := 'basic.consume-ok';
              Add( 'consumer-tag', TShortString.Create( '' ) );
            End;
        40: Begin
              Name := 'basic.publish';
              Add( 'reserved',    TShortUInt.Create( 0 ) );
              Add( 'exchange',    TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ) );
              Add( 'mandatory',   TBoolean.Create( False ) ); //True => if undeliverable, a return will be fired
              Add( 'immediate',   TBoolean.Create( False ) );
            End;
        50: Begin
              Name := 'basic.return';
              Add( 'reply-code',  TShortUInt.Create( 0 ) );
              Add( 'reply-text',  TShortString.Create( '' ) );
              Add( 'exchange',    TShortString.Create( '' ) );
              Add( 'routing-key', TShortString.Create( '' ) );
            End;
        60: Begin
              Name := 'basic.deliver';
              Add( 'consumer-tag', TShortString.Create( '' ) );
              Add( 'delivery-tag', TLongLongUInt.Create( 0 ) );
              Add( 'redelivered',  TBoolean.Create( False ) );
              Add( 'exchange',     TShortString.Create( '' ) );
              Add( 'routing-key',  TShortString.Create( '' ) );
            End;
        70: Begin
              Name := 'basic.get';
              Add( 'reserved-1', TShortUInt.Create( 0 ) );
              Add( 'queue',      TShortString.Create( '' ) );
              Add( 'no-ack',     TBoolean.Create( False ) );
            End;
        71: Begin
              Name := 'basic.get-ok';
              Add( 'delivery-tag',  TLongLongUInt.Create( 0 ) );
              Add( 'redelivered',   TBoolean.Create( False ) );
              Add( 'exchange',      TShortString.Create( '' ) );
              Add( 'routing-key',   TShortString.Create( '' ) );
              Add( 'message-count', TLongUInt.Create( 0 ) );
            End;
        72: Begin
              Name := 'basic.get-empty';
              Add( 'reserved-1', TShortUInt.Create( 0 ) );
            End;
        80: Begin
              Name := 'basic.ack';
              Add( 'delivery-tag', TLongLongUInt.Create( 0 ) );
              Add( 'multiple',     TBoolean.Create( False ) );
            End;
        90: Begin
              Name := 'basic.reject';
              Add( 'delivery-tag', TLongLongUInt.Create( 0 ) );
              Add( 'requeue',      TBoolean.Create( False ) );
            End;
        100: Begin
              Name := 'basic.recover-async';
              Add( 'requeue',      TBoolean.Create( False ) );
            End;
        110: Begin
              Name := 'basic.recover';
              Add( 'requeue',      TBoolean.Create( False ) );
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
    AMQP_CLASS_CONFIRM:
      case AMethodID of
        10: Begin
              Name := 'confirm.select';
              Add( 'no-wait',     TBoolean.Create( False ) );
            End;
        11: Begin
              Name := 'confirm.select-ok';
            End;
        Else
          raise AMQPException.CreateFmt('Unsupported method: ClassID %d, MethodID %d', [ClassID, MethodID]);
      end;
  Else
    raise AMQPException.CreateFmt('Unsupported class: ClassID %d, MethodID %d', [ClassID, MethodID]);
  end;
end;

procedure TAMQPMethod.SaveToStream(AStream: TStream);
var
  Shift: Byte;
  BitField: Byte;
  Index: Integer;
  Field: TAMQPValue;
begin
  Index := 0;
  while Index < FFields.Count do
  Begin
    Field := FFields[Index];
    if Field.ValueKind = vkBool then
    Begin
      BitField := IfThen( Field.AsBoolean.Value, 1, 0 );
      Shift    := 1;
      while ((Index + 1) < FFields.Count) and (FFields[Index+1].ValueKind = vkBool) do
      Begin
        if Shift >= 8 then
          raise Exception.Create('More that 8 bits');
        Inc( Index );
        Field := FFields[Index];
        BitField := BitField + IfThen( Field.AsBoolean.Value, 1, 0 ) shl Shift;
        Inc( Shift );
      End;
      AStream.Write( BitField, 1 );
    End
    Else
      Field.SaveToStream( AStream );
    Inc( Index );
  End;
end;

end.

