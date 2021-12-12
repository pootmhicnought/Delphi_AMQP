{$I AMQP.Options.inc}  
unit AMQP.IMessageProperties;

interface

Uses
  Classes, AMQP.Types;

Type
  IAMQPMessageProperties = interface ['{2E874719-4F4E-4B62-BBD0-4F9E4C56C7CD}']
    Function ContentType        : TShortString;
    Function ContentEncoding    : TShortString;
    Function ApplicationHeaders : TFieldTable;
    Function DeliveryMode       : TShortShortUInt;
    Function Priority           : TShortShortUInt;
    Function CorrelationID      : TShortString;
    Function ReplyTo            : TShortString;
    Function Expiration         : TShortString;
    Function MessageID          : TShortString;
    Function Timestamp          : TTimestamp;
    Function &Type              : TShortString;
    Function UserID             : TShortString;
    Function AppID              : TShortString;
    Function Reserved           : TShortString;

    Procedure SaveToStream( AStream: TStream );
    Procedure LoadFromStream( AStream: TStream );
    Procedure Assign( AMessageProperties: IAMQPMessageProperties );
  end;

implementation

end.
