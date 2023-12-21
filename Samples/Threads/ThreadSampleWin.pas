unit ThreadSampleWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AMQP.Connection, AMQP.Interfaces, AMQP.Classes,
  ThreadingClasses;

type
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
    procedure OnConsumer1Message(msg: String);
    procedure OnConsumer2Message(msg: String);
    procedure OnProducerMessage(msg: String);
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
  Consumer1 := TConsumerThread.Create( AMQP );
  Consumer1.OnMessage := OnConsumer1Message;
end;

procedure TThreadSampleForm.ButtonStartConsumer2Click(Sender: TObject);
begin
  ButtonStopConsumer2.Click;
  Consumer2 := TConsumerThread.Create( AMQP );
  Consumer2.OnMessage := OnConsumer2Message;
end;

procedure TThreadSampleForm.ButtonStartProducerClick(Sender: TObject);
begin
  ButtonStopProducer.Click;
  Producer := TProducerThread.Create( AMQP, SpinEditCount.Value, SpinEditInterval.Value );
  Producer.OnMessage := OnProducerMessage;
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

procedure TThreadSampleForm.OnConsumer1Message(msg: String);
begin
  MemoConsumer1.Lines.Add(msg);
end;

procedure TThreadSampleForm.OnConsumer2Message(msg: String);
begin
  MemoConsumer2.Lines.Add(msg);
end;

procedure TThreadSampleForm.OnProducerMessage(msg: String);
begin
  MemoProducer.Lines.Add(msg)
end;

end.
