unit ThreadingClasses;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  AMQP.Connection, AMQP.Interfaces, AMQP.Classes, AMQP.Message, AMQP.StreamHelper;

type
  tOnMessageEvent = procedure(msg: String) of object;

  TProducerThread = Class(TThread)
  Strict Private
    FAMQP: TAMQPConnection;
    fOnMessage: tOnMessageEvent;
    FMaxWork: Integer;
    FSleepMS: Integer;
    Procedure WriteLine( Text: String );
  Protected
    Procedure Execute; Override;
  public
    property OnMessage: tOnMessageEvent read fOnMessage write fOnMessage;
    Constructor Create( AAMQP: TAMQPConnection; AMaxWork, ASleepMS: Integer ); Reintroduce;
  End;

  TConsumerThread = Class(TThread)
  Strict Private
    FAMQP: TAMQPConnection;
    fOnMessage: tOnMessageEvent;
    FChannel: IAMQPChannel;
    Procedure WriteLine( Text: String );
  Protected
    Procedure TerminatedSet; Override;
    Procedure Execute; Override;
  public
    property OnMessage: tOnMessageEvent read fOnMessage write fOnMessage;
    Constructor Create( AAMQP: TAMQPConnection ); Reintroduce;
  End;

implementation

{ TConsumerThread }

constructor TConsumerThread.Create(AAMQP: TAMQPConnection);
begin
  FAMQP := AAMQP;
  inherited Create;
end;

procedure TConsumerThread.Execute;
var
  Queue   : TAMQPMessageQueue;
  Msg     : TAMQPMessage;
begin
  WriteLine( 'Thread starting' );
  NameThreadForDebugging( 'ConsumerThread' );
  Queue    := TAMQPMessageQueue.Create;
  FChannel := FAMQP.OpenChannel(0, 10);
  Try
    FChannel.BasicConsume( Queue, 'WorkQueue', 'consumer' );
    Repeat
      Msg := Queue.Get(INFINITE);
      if Msg = nil then
        Terminate;
      if not Terminated then
      Begin
        WriteLine( 'Consumed: ' + Msg.Body.AsString[ TEncoding.ASCII ] );
        Msg.Ack;
        Msg.Free;
        //Sleep(Random(50));
      End;
    Until Terminated;
  Finally
    FChannel := nil;
    Queue.Free;
  End;
  WriteLine( 'Thread stopped' );
end;

procedure TConsumerThread.TerminatedSet;
begin
  inherited;
  if FChannel.State = cOpen then
    FChannel.Close;
end;

procedure TConsumerThread.WriteLine(Text: String);
begin
  if Assigned(fOnMessage) then
  begin
    Queue( Procedure
           Begin
             fOnMessage( Text );
           End );
  end;
end;

{ TProducerThread }

constructor TProducerThread.Create(AAMQP: TAMQPConnection; AMaxWork, ASleepMS: Integer);
begin
  FAMQP    := AAMQP;
  FMaxWork := AMaxWork;
  FSleepMS := ASleepMS;
  inherited Create;
end;

procedure TProducerThread.Execute;
var
  Channel : IAMQPChannel;
  Work    : String;
  Counter : Integer;
begin
  WriteLine( 'Thread starting' );
  NameThreadForDebugging( 'ProducerThread' );
  Counter := 1;
  Channel := FAMQP.OpenChannel;
  Try
    Repeat
      Work := 'Work unit ' + Counter.ToString;
      WriteLine( 'Produced: ' + Work );
      Channel.BasicPublish( 'Work', 'work.unit', Work );
      Inc( Counter );
      Sleep( FSleepMS );
    Until Terminated or (Counter > FMaxWork);
  Finally
    Channel := nil;
  End;
  WriteLine( 'Thread stopped' );
end;

procedure TProducerThread.WriteLine(Text: String);
begin
  if Assigned(fOnMessage) then
  begin
    Queue( Procedure
           Begin
             fOnMessage( Text );
           End );
  end;
end;

end.
