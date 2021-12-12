{$I AMQP.Options.inc}  
unit AMQP.Frame;

interface

Uses
  AMQP.Payload;

const
  FRAME_TYPE_METHOD    = 1;
  FRAME_TYPE_HEADER    = 2;
  FRAME_TYPE_CONTENT   = 3;
  FRAME_TYPE_HEARTBEAT = 8;
  FRAME_END = $CE;
  FRAME_MIN_SIZE: Word = 4096;

Type
  TFrameKind = ( fkMethod    = FRAME_TYPE_METHOD,
                 fkHeader    = FRAME_TYPE_HEADER,
                 fkBody      = FRAME_TYPE_CONTENT,
                 fkHeartbeat = FRAME_TYPE_HEARTBEAT );

  IAMQPFrame = interface ['{4BE40EEF-D60D-477D-9315-3005DD6C135E}']
    Function Kind     : TFrameKind;
    Function Channel  : Word;
    Function Size     : Cardinal;
    Function Payload  : TAMQPPayload;
    Function FrameEnd : Byte;
    Procedure SetKind( AKind: TFrameKind );
    Procedure SetChannel( AChannel: Word );
    Procedure SetSize( ASize: Cardinal );
    Procedure SetPayload( APayload: TAMQPPayload );
    Procedure SetFrameEnd( AFrameEnd: Byte );
  end;

  TAMQPFrame = Class( TInterfacedObject, IAMQPFrame )
  Strict Private
    FKind     : TFrameKind;
    FChannel  : Word;
    FSize     : Cardinal;
    FPayload  : TAMQPPayload;
    FFrameEnd : Byte;
  Public
    Function Kind     : TFrameKind;
    Function Channel  : Word;
    Function Size     : Cardinal;
    Function Payload  : TAMQPPayload;
    Function FrameEnd : Byte;

    Procedure SetKind( AKind: TFrameKind );
    Procedure SetChannel( AChannel: Word );
    Procedure SetSize( ASize: Cardinal );
    Procedure SetPayload( APayload: TAMQPPayload );
    Procedure SetFrameEnd( AFrameEnd: Byte );

    Procedure Clear;
    Constructor Create;
    Destructor Destroy; Override;
  End;

implementation

{ TAMQPFrame }

function TAMQPFrame.Channel: Word;
begin
  Result := FChannel;
end;

procedure TAMQPFrame.Clear;
begin
  Payload.Free;
  FKind     := fkMethod;
  FChannel  := 0;
  FSize     := 0;
  FPayload  := nil;
  FFrameEnd := 0;
end;

constructor TAMQPFrame.Create;
begin
  FKind     := fkMethod;
  FChannel  := 0;
  FSize     := 0;
  FPayload  := nil;
  FFrameEnd := 0;
end;

destructor TAMQPFrame.Destroy;
begin
  FPayload.Free;
  inherited;
end;

function TAMQPFrame.FrameEnd: Byte;
begin
  Result := FFrameEnd;
end;

function TAMQPFrame.Kind: TFrameKind;
begin
  Result := FKind;
end;

function TAMQPFrame.Payload: TAMQPPayload;
begin
  Result := FPayload;
end;


procedure TAMQPFrame.SetChannel(AChannel: Word);
begin
  FChannel := AChannel;
end;

procedure TAMQPFrame.SetFrameEnd(AFrameEnd: Byte);
begin
  FFrameEnd := AFrameEnd;
end;

procedure TAMQPFrame.SetKind(AKind: TFrameKind);
begin
  FKind := AKind;
end;

procedure TAMQPFrame.SetPayload(APayload: TAMQPPayload);
begin
  FPayload := APayload;
end;

procedure TAMQPFrame.SetSize(ASize: Cardinal);
begin
  FSize := ASize;
end;

function TAMQPFrame.Size: Cardinal;
begin
  Result := FSize;
end;

end.
