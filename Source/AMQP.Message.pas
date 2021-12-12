{$I AMQP.Options.inc}
unit AMQP.Message;

interface

Uses
  Classes, AMQP.Header, AMQP.Frame;

Type
  IAMQPBaseChannel = interface ['{A5198398-B9DC-461B-8ECF-69A0BD0AD49E}']
    Procedure BasicAck( ADeliveryTag: UInt64; AMultiple: Boolean = False ); Overload;
    Procedure BasicReject( ADeliveryTag: UInt64; ARequeue: Boolean = True ); overload;
  end;

  TAMQPMessage = Class
  Private
    FChannel      : IAMQPBaseChannel;
    FDeliveryTag  : UInt64;
    FRedelivered  : Boolean;
    FConsumerTag  : String;
    FExchange     : String;
    FRoutingKey   : String;
    FMessageCount : UInt32;
    FBody         : TMemoryStream;
    FHeader       : TAMQPHeader;
  Public
    Property Channel      : IAMQPBaseChannel read FChannel write FChannel;
    Property ConsumerTag  : String           read FConsumerTag;
    Property DeliveryTag  : UInt64           read FDeliveryTag;
    Property Redelivered  : Boolean          read FRedelivered;
    Property Exchange     : String           read FExchange;
    Property RoutingKey   : String           read FRoutingKey;
    Property MessageCount : UInt32           read FMessageCount;
    Property Header       : TAMQPHeader      read FHeader;
    Property Body         : TMemoryStream    read FBody;

    Procedure ReadFromData( AMethodFrame, AHeaderFrame: IAMQPFrame; var ABody: TMemoryStream );
    Procedure Ack;
    Procedure Reject;

    Constructor Create;
    Destructor Destroy; Override;
  End;

implementation

Uses
  SysUtils, AMQP.Method, AMQP.Helper;

{ TAMQPMessage }

procedure TAMQPMessage.Ack;
begin
  FChannel.BasicAck( DeliveryTag );
end;

constructor TAMQPMessage.Create;
Begin
  FConsumerTag  := '';
  FDeliveryTag  := 0;
  FRedelivered  := False;
  FExchange     := '';
  FRoutingKey   := '';
  FMessageCount := 0;
  FChannel      := nil;
  FHeader       := TAMQPHeader.Create;
  FBody         := TMemoryStream.Create;
End;

procedure TAMQPMessage.ReadFromData(AMethodFrame, AHeaderFrame: IAMQPFrame; var ABody: TMemoryStream);
var
  AMethod: TAMQPMethod;
begin
  //Copy GetOK properties
  AMethod := AMethodFrame.Payload.AsMethod;
  FDeliveryTag  := AMethod.Field[ 'delivery-tag'  ].AsLongLongUInt.Value;
  FRedelivered  := AMethod.Field[ 'redelivered'   ].AsBoolean.Value;
  FExchange     := AMethod.Field[ 'exchange'      ].AsShortString.Value;
  FRoutingKey   := AMethod.Field[ 'routing-key'   ].AsShortString.Value;
  if AMethod.FindField( 'consumer-tag' ) <> nil then
    FConsumerTag  := AMethod.Field[ 'consumer-tag'  ].AsShortString.Value;
  if AMethod.FindField( 'message-count' ) <> nil then
    FMessageCount := AMethod.Field[ 'message-count' ].AsLongUInt.Value;
  //Steal header (cheaper/faster than copying it)
  FHeader.Free;
  FHeader := AHeaderFrame.Payload.AsHeader;
  AHeaderFrame.SetPayload( nil ); //Steal payload
  //Steal body
  FBody.Free;
  FBody := ABody;
  ABody := nil; //Steal body
  FBody.Position := 0;
end;

procedure TAMQPMessage.Reject;
begin
  FChannel.BasicReject( DeliveryTag );
end;

destructor TAMQPMessage.Destroy;
begin
  FBody.Free;
  FHeader.Free;
  FChannel := nil;
  inherited;
end;

end.
