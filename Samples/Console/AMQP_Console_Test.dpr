program AMQP_Console_Test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ThreadingClasses in '..\ThreadingClasses.pas',
  AMQP.Connection, AMQP.Interfaces, AMQP.Classes;

type
  TConsoleMessageHandler = class
  public
    procedure OnConsumer1Message(msg: String);
    procedure OnConsumer2Message(msg: String);
    procedure OnProducerMessage(msg: String);
  end;


{ ConsoleMessageHandler }

procedure TConsoleMessageHandler.OnConsumer1Message(msg: String);
begin
  WriteLn('Consumer 1: ' + msg);
end;

procedure TConsoleMessageHandler.OnConsumer2Message(msg: String);
begin
  WriteLn('Consumer 2: ' + msg);
end;

procedure TConsoleMessageHandler.OnProducerMessage(msg: String);
begin
  WriteLn('Producer  : ' + msg);
end;


var
  AMQP: TAMQPConnection;
  Producer: TProducerThread;
  Consumer1: TConsumerThread;
  Consumer2: TConsumerThread;
  MessageHandler: TConsoleMessageHandler;
  Channel: IAMQPChannel;


begin
  try
    try
      AMQP := TAMQPConnection.Create;
      AMQP.MaxChannel    := 4;
      AMQP.HeartbeatSecs := 60;
      AMQP.Host          := 'broomcloset';
      AMQP.Port          := 45672;
      AMQP.VirtualHost   := '/';
      AMQP.Username      := 'guest';
      AMQP.Password      := 'guest';
      AMQP.Timeout := INFINITE;
      AMQP.Connect;
      Channel := AMQP.OpenChannel;
      Channel.ExchangeDeclare( 'Work', 'direct', [] );
      Channel.QueueDeclare( 'WorkQueue' , []);
      Channel.QueueBind( 'WorkQueue', 'Work', 'work.unit' , []);

      MessageHandler := TConsoleMessageHandler.Create;

      Producer := TProducerThread.Create( AMQP, 100, 100 );
      Producer.OnMessage := MessageHandler.OnProducerMessage;

      Consumer1 := TConsumerThread.Create( AMQP );
      Consumer1.OnMessage := MessageHandler.OnConsumer1Message;

      Consumer2 := TConsumerThread.Create( AMQP );
      Consumer2.OnMessage := MessageHandler.OnConsumer2Message;

      repeat
        Producer.WaitFor;
        sleep(1);
      until (False);
    finally
      FreeAndNil(Producer);
      FreeAndNil(Consumer1);
      FreeAndNil(Consumer2);
      FreeAndNil(MessageHandler);
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
