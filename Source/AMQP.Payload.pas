{$I AMQP.Options.inc}
unit AMQP.Payload;
interface

Uses
  Classes;

Type
  TAMQPPayload = Class
  strict private
    FName: String;
  Public
    Property Name: String read FName write FName;
    Procedure LoadFromStream( AStream: TStream ); Virtual; Abstract;
    Constructor Create; Virtual;
  End;

  TAMQPBody = Class( TAMQPPayload )
  strict private
    FStream: TMemoryStream;
  Public
    Property Stream: TMemoryStream read FStream;
    Procedure LoadFromStream( AStream: TStream ); Override;
    Constructor Create; Override;
    Destructor Destroy; Override;
  End;

implementation

{ TAMQPPayload }

constructor TAMQPPayload.Create;
begin
  FName := '';
end;

{ TAMQPBody }

constructor TAMQPBody.Create;
begin
  inherited;
  FStream := TMemoryStream.Create;
end;

destructor TAMQPBody.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TAMQPBody.LoadFromStream(AStream: TStream);
begin
  FStream.Clear;
  FStream.CopyFrom( AStream, AStream.Size - AStream.Position );
  FStream.Position := 0;
end;

end.
