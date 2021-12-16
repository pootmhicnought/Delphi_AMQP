unit ThreadSampleWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AMQP.Connection, AMQP.Interfaces, AMQP.Classes;

type
  TProducerThread = Class(TThread)
  Strict Private
    FAMQP: TAMQPConnection;
    FMaxWork: Integer;
    FSleepMS: Integer;
    Procedure WriteLine( Text: String );
  Protected
    Procedure Execute; Override;
    Constructor Create( AAMQP: TAMQPConnection; AMaxWork, ASleepMS: Integer ); Reintroduce;
  End;

  TConsumerThread = Class(TThread)
  Strict Private
    FAMQP: TAMQPConnection;
    FChannel: IAMQPChannel;
    FMemo: TMemo;
    Procedure WriteLine( Text: String );
  Protected
    Procedure TerminatedSet; Override;
    Procedure Execute; Override;
    Constructor Create( AAMQP: TAMQPConnection; AMemo: TMemo ); Reintroduce;
  End;

  TThreadSampleForm = class(TForm)
    MemoConsumer2: TMemo;
    MemoProducer: TMemo;
    ButtonStartConsumer2: TButton;
    ButtonStartProducer: TButton;
    ButtonStopProducer: TButton;
    ButtonStopConsumer2: TButton;
    SpinEditCount: TSpinEdit;
    SpinEditInterval: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    MemoConsumer1: TMemo;
    ButtonStartConsumer1: TButton;
    ButtonStopConsumer1: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonStartProducerClick(Sender: TObject);
    procedure ButtonStopProducerClick(Sender: TObject);
    procedure ButtonStartConsumer2Click(Sender: TObject);
    procedure ButtonStopConsumer2Click(Sender: TObject);
    procedure ButtonStartConsumer1Click(Sender: TObject);
    procedure ButtonStopConsumer1Click(Sender: TObject);
  private
    { Private declarations }
  public
    AMQP: TAMQPConnection;
    Producer: TProducerThread;
    Consumer1: TConsumerThread;
    Consumer2: TConsumerThread;
  end;

var
  ThreadSampleForm: TThreadSampleForm;

implementation

Uses
  AMQP.Message, AMQP.StreamHelper, AMQP.Arguments;

{$R *.dfm}

procedure TThreadSampleForm.ButtonStartConsumer1Click(Sender: TObject);
begin
  ButtonStopConsumer1.Click;
  Consumer1 := TConsumerThread.Create( AMQP, MemoConsumer1 );
end;

procedure TThreadSampleForm.ButtonStartConsumer2Click(Sender: TObject);
begin
  ButtonStopConsumer2.Click;
  Consumer2 := TConsumerThread.Create( AMQP, MemoConsumer2 );
end;

procedure TThreadSampleForm.ButtonStartProducerClick(Sender: TObject);
begin
  ButtonStopProducer.Click;
  Producer := TProducerThread.Create( AMQP, SpinEditCount.Value, SpinEditInterval.Value );
end;

procedure TThreadSampleForm.ButtonStopConsumer1Click(Sender: TObject);
begin
  If Consumer1 <> nil then
    Consumer1.Free;
  Consumer1 := nil;
end;

procedure TThreadSampleForm.ButtonStopConsumer2Click(Sender: TObject);
begin
  If Consumer2 <> nil then
    Consumer2.Free;
  Consumer2 := nil;
end;

procedure TThreadSampleForm.ButtonStopProducerClick(Sender: TObject);
begin
  If Producer <> nil then
    Producer.Free;
  Producer := nil;
end;

procedure TThreadSampleForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AMQP.Free;
end;

procedure TThreadSampleForm.FormShow(Sender: TObject);
var
  Channel: IAMQPChannel;
begin
  Producer  := nil;
  Consumer1 := nil;
  Consumer2 := nil;
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
end;

{ TConsumerThread }

constructor TConsumerThread.Create(AAMQP: TAMQPConnection; AMemo: TMemo);
begin
  FAMQP := AAMQP;
  FMemo := AMemo;
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
  Queue( Procedure
         Begin
           FMemo.Lines.Add( Text );
         End );
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
  Queue( Procedure
         Begin
           ThreadSampleForm.MemoProducer.Lines.Add( Text );
         End );
end;

end.
