{$I AMQP.Options.inc}

unit AMQP.Helper;

interface

Uses
  AMQP.Payload, AMQP.Header, AMQP.Method;

Type
  TAMQPPayloadHelper = Class Helper for TAMQPPayload
  Public
    Function AsMethod : TAMQPMethod;
    Function AsHeader : TAMQPHeader;
    Function AsBody   : TAMQPBody;
  End;

implementation

{ TAMQPPayloadHelper }

function TAMQPPayloadHelper.AsBody: TAMQPBody;
begin
  Result := Self as TAMQPBody;
end;

function TAMQPPayloadHelper.AsHeader: TAMQPHeader;
begin
  Result := Self as TAMQPHeader;
end;

function TAMQPPayloadHelper.AsMethod: TAMQPMethod;
begin
  Result := Self as TAMQPMethod;
end;

end.
