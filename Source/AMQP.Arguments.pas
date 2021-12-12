{$I AMQP.Options.inc}
unit AMQP.Arguments;

interface

Const
  AMQP_TTL_SECOND = 1000;
  AMQP_TTL_MINUTE = AMQP_TTL_SECOND * 60;
  AMQP_TTL_HOUR   = AMQP_TTL_MINUTE * 60;
  AMQP_TTL_DAY    = AMQP_TTL_HOUR   * 24;

Type
  TArgument = Record
    Name: String;
    Value: Variant;
  End;

  TArguments = Array of TArgument;
  TQueueMode = (qmDefault, qmLazy);

  { TArgumentHelper }

  TArgumentHelper = Record Helper for TArguments
  private
    const CQueueMode: array[TQueueMode] of String = ('default', 'lazy');
  public
    Function Add( Name: String; Value: Variant ): TArguments;
    Function SetMessageTTL( TimeToLiveMS: Int64 ): TArguments;
    Function SetXMatchAll: TArguments;
    Function SetXMatchAny: TArguments;
    Function AddXMatchAll: TArguments;
    Function AddXMatchAny: TArguments;
    Function AddXMessageTTL( TimeToLiveMS: Int64 ): TArguments;
    Function SetXQueueMode(AMode: TQueueMode): TArguments;
    Function AddXQueueMode(AMode: TQueueMode): TArguments;
  End;

function MakeArgument( Name: String; Value: Variant): TArgument;
Function MakeArguments: TArguments; overload;
Function MakeArguments( Name: String; Value: Variant ): TArguments; overload;

implementation

function MakeArgument( Name: String; Value: Variant): TArgument;
begin
 Result.Value:= Value;
 Result.Name:= Name;
end;

Function MakeArguments( Name: String; Value: Variant ): TArguments;
var
  Arg: TArgument;
Begin
  Arg := MakeArgument(Name, Value);
  Result := [ Arg ];
End;

Function MakeArguments: TArguments;
Begin
  Result := [];
End;

{ TArgumentHelper }

function TArgumentHelper.Add(Name: String; Value: Variant): TArguments;
begin
  Result := self + MakeArguments( Name, Value );
end;

function TArgumentHelper.AddXMatchAll: TArguments;
begin
  Result := Self + SetXMatchAll;
end;

function TArgumentHelper.AddXMatchAny: TArguments;
begin
  Result := Self + SetXMatchAny;
end;

function TArgumentHelper.AddXMessageTTL(TimeToLiveMS: Int64): TArguments;
begin
  Result := Self + SetMessageTTL(TimeToLiveMS);
end;

function TArgumentHelper.AddXQueueMode(AMode: TQueueMode): TArguments;
begin
  Result := Self + SetXQueueMode(AMode);
end;

function TArgumentHelper.SetMessageTTL(TimeToLiveMS: Int64): TArguments;
begin
  Result := MakeArguments( 'x-message-ttl', TimeToLiveMS );
end;

function TArgumentHelper.SetXMatchAll: TArguments;
begin
  Result := MakeArguments('x-match', 'all');
end;

function TArgumentHelper.SetXMatchAny: TArguments;
begin
 Result := MakeArguments('x-match', 'any');
end;

function TArgumentHelper.SetXQueueMode(AMode: TQueueMode): TArguments;
begin
  Result := MakeArguments('x-queue-mode', CQueueMode[AMode]);
end;

end.
